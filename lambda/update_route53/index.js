'use strict';

const AWS = require('aws-sdk');
const flatten = require('lodash').flatten;

const args = {
    hostedZoneId: process.env.HOSTED_ZONE_ID,
    domainName: process.env.DOMAIN_NAME,
    serviceName: process.env.SERVICE_NAME,
    serviceProtocol: process.env.SERVICE_PROTOCOL,
    servicePort: process.env.SERVICE_PORT,
    autoScalingGroups: process.env.AUTOSCALING_GROUPS.split(';'),
    topology: process.env.TOPOLOGY,
};

// Normalize the domain name to remove trailing period
if (args.domainName.endsWith('.')) {
    args.domainName = args.domainName.substr(0, args.domainName.length-1);
}

exports.handler = () => {
    let autoScaling = new AWS.AutoScaling();
    let ec2 = new AWS.EC2();
    let route53 = new AWS.Route53();

    console.log(args);
    console.log('Getting current autoscaling instances...');

    autoScaling.describeAutoScalingGroups({
        AutoScalingGroupNames: args.autoScalingGroups,
    }, (err, data) => {
        if (err) {
            console.error(err);
            return;
        }

        let instanceIds = flatten(data.AutoScalingGroups.map((asg) => {
            return asg.Instances.map((instance) => instance.InstanceId);
        }));

        console.log(`Instances: ${instanceIds.join(',')}`);

        console.log('Getting instance domain names...');
        ec2.describeInstances({
            InstanceIds: instanceIds,
            Filters: [
                {Name: 'instance-state-name', Values: ['running']},
            ],
        }, (err, data) => {
            if (err) {
                console.error(err);
                return;
            }

            let domainNames = flatten(data.Reservations.map((reservation) => {
                return reservation.Instances.map((instance) => {
                    if (args.topology.toLowerCase() == 'public') {
                        // Fallback to private if public is unavailable
                        return instance.PublicDnsName ||
                            instance.PrivateDnsName;
                    } else {
                        return instance.PrivateDnsName;
                    }
                });
            }));

            console.log(`Domain names: ${domainNames.join(',')}`);

            let srvDomainName = '_' + args.serviceName +
                '._' + args.serviceProtocol +
                '.' + args.domainName;

            let recordSet = {
                Name: srvDomainName,
                TTL: 60,
                Type: 'SRV',
                ResourceRecords: domainNames.map((domainName) => {
                    return {Value: `10 10 ${args.servicePort} ${domainName}`};
                }),
            };

            console.log(`Updating DNS SRV record ${recordSet.Name}...`);
            route53.changeResourceRecordSets({
                ChangeBatch: {
                    Changes: [{
                        Action: 'UPSERT',
                        ResourceRecordSet: recordSet,
                    }],
                },
                HostedZoneId: args.hostedZoneId,
            }, (err, data) => {
                if (err) {
                    console.error(err);
                    return;
                }

                console.log('Complete.');
            });
        });
    });
};
