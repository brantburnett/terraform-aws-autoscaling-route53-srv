## Example

To use the example, you must supply an EC2 key pair and set your shell environment variables with access keys for AWS.  Other variables are also available to perform different types of deployments, see `variables.tf`.

Linux example:

```sh
# This example assumes terraform is available in $PATH

export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=yyy

terraform init
terraform apply -var "key_pair_name=my_key" -var "hosted_zone_id=Z213423423"

# When done
terraform destroy -var "key_pair_name=my_key" -var "hosted_zone_id=Z213423423"
```

Windows example:

```powershell
# This example assumes Terraform is available in your path.  This will be true if installed via Chocolatey.

Set-AwsCredential -AccessKey xxx -SecretyKey yyy
.\SetAwsEnvironment.ps1

terraform init
terraform apply -var "key_pair_name=my_key" -var "hosted_zone_id=Z213423423"

# When done
terraform destroy -var "key_pair_name=my_key" -var "hosted_zone_id=Z213423423"
```