# Core Cloud MSK Module

This MSK Child Module is written and maintained by the Core Cloud Platform team and includes the following checks and scans:
Terraform validate, Terraform fmt, TFLint, Checkov scan, Sonarqube scan and Semantic versioning - MAJOR.MINOR.PATCH.

## Module Structure

<strong>---| .github</strong>  
&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| [dependabot.yaml](https://github.com/Home-Office-Digital/core-cloud-msk-tf-module/blob/main/.github/dependabot.yaml)</strong> - Checks repository daily for any dependency updates and raises a PR into main for review.  \
&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| workflows</strong> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| [pull-request-sast.yaml](https://github.com/Home-Office-Digital/core-cloud-msk-tf-module/blob/main/.github/workflows/pull-request-sast.yaml)</strong> - Workflow containing terraform init, terraform validate, terraform fmt - referencing Core Cloud TFLint, Checkov scan and Sonarqube scan shared workflows. Runs on pull request and merge to main branch. \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| [pull-request-semver-label-check.yaml](https://github.com/Home-Office-Digital/core-cloud-msk-tf-module/blob/main/.github/workflows/pull-request-semver-label-check.yaml)</strong> - Verifies all PRs to main raised in the module must have an appropriate semver label: major/minor/patch. \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| [pull-request-semver-tag-merge.yaml](https://github.com/Home-Office-Digital/core-cloud-msk-tf-module/blob/main/.github/workflows/pull-request-semver-tag-merge.yaml)</strong> - Calculates the new semver value depending on the PR label and tags the repository with the correct tag. \
<strong>---| tests</strong> \
&nbsp;&nbsp;<strong>---| [msk_basic.tftest.hcl](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/tests/msk_basic.tftest.hcl)</strong> \
&nbsp;&nbsp;<strong>---| [msk_security.tftest.hcl](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/tests/msk_security.tftest.hcl)</strong> \
&nbsp;&nbsp;<strong>---| [msk_tagging.tftest.hcl](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/tests/msk_tagging.tftest.hcl)</strong> \
&nbsp;&nbsp;<strong>---| [msk_feature_behavior.tftest.hcl](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/tests/msk_feature_behavior.tftest.hcl)</strong> \
<strong>---| [CHANGELOG.md](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/CHANGELOG.md)</strong> - Contains all significant changes in relation to a semver tag made to this module. \
<strong>---| [CODEOWNERS](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/CODEOWNERS)</strong> \
<strong>---| [CODE_OF_CONDUCT](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/CODE_OF_CONDUCT.md)</strong> \
<strong>---| [CONTRIBUTING.md](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/CONTRIBUTING.md)</strong>  \
<strong>---| [LICENSE.md](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/LICENSE.md)</strong>  \
<strong>---| [README.md](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/README.md)</strong>  \
<strong>---| [main.tf](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/main.tf)</strong> - Contains the main set of configuration for this module.  \
<strong>---| [outputs.tf](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/outputs.tf)</strong> - Contains the output definitions for this module.  \
<strong>---| [variables.tf](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/variables.tf)</strong> - Contains the declarations for module variables, all variables have a defined type and short description outlining their purpose.  \
<strong>---| [versions.tf](https://github.com/UKHomeOffice/core-cloud-msk-tf-module/blob/main/versions.tf)</strong> - Contains the providers needed by the module.  


## Terraform Tests

All module tests are located in the tests/ folder and use Terraform test. These are written and maintained by the Core Cloud QA team.  \
The test files in this folder validate the MSK module configuration.  \
Please refer to the [Official Hashicorp Terraform Test documentation](https://developer.hashicorp.com/terraform/language/tests).

## Usage 

Recommended settings:

- Opt into Open Monitoring (prometheus_jmx_exporter and prometheus_node_exporter)
- Adhere to Core Cloud mandatory tags.
- Opt into TLS client authentication through AWS Certificate Manager.
- Reuse existing private CAs with `ca_arn` or let the module create one with `certificate_authority`.
- Attach an existing MSK configuration with `config_arn` and `config_revision`.
- Create and attach an MSK configuration with `config_name`, `config_kafka_versions`, and `config_server_properties`.
- Set `enhanced_monitoring` and `encryption_at_rest_kms_key_arn` when workloads need explicit monitoring depth or a customer managed AWS KMS key.

Note: When creating a PCA, once created via the console select the option to 'Install the CA Certificate' - the CA status will then update from 'Pending' to 'Active' for a successful Terraform apply.

```
terraform {
  source = "git::https://github.com/Home-Office-Digital/core-cloud-msk-tf-module.git?ref={tag}"
}

inputs = {
  account_id                       = "xxx"
  certificate_authority            = true
  # ca_arn                         = ["arn:aws:acm-pca:eu-west-2:123456789012:certificate-authority/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]
  client_unauthenticated           = false
  cluster_name                     = "msk-test"
  # config_arn                     = "arn:aws:kafka:eu-west-2:123456789012:configuration/test/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx-1"
  # config_revision                = 1
  # config_name                    = "msk-test-config"
  # config_kafka_versions          = ["3.9.x"]
  # config_server_properties       = <<-EOT
  #   auto.create.topics.enable = true
  # EOT
  ebs_volume_size                  = 1000
  # encryption_at_rest_kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  environment                      = "test"
  enhanced_monitoring              = "PER_BROKER"
  instance_type                    = "kafka.t3.small"
  jmx_exporter_monitoring_enabled  = true
  node_exporter_monitoring_enabled = true
  number_of_broker_nodes           = 2
  project_name                     = "xxx"
  storage_autoscaling_max_capacity = 1050
  subnet_ids                       = ["subnet-xxx", "subnet-xxx"]
  tls_authentication               = true
  vpc_id                           = "vpc-xxx"
  vpc_cidr                         = ["xxx"]


  # Tags for all resources
  tags = {
    cost-centre      = "xxx"
    account-code     = "xxx"
    portfolio-id     = "xxx"
    project-id       = "xxx"
    service-id       = "xxx"
    environment-type = "test"
    owner-business   = "xxx"
    budget-holder    = "xxx"
    source-repo      = "xxx"
  }
}

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.88.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.88.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acmpca_certificate_authority.msk_with_ca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_certificate_authority) | resource |
| [aws_appautoscaling_policy.msk_appautoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.msk_appautoscaling_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.msk_broker_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.msk_cloudwatch_logs_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.msk_iam_ca_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.msk_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.msk_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_msk_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.msk_ca_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_msk_cluster.msk_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster) | resource |
| [aws_msk_configuration.msk_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_configuration) | resource |
| [aws_security_group.sg_msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_policy_document.msk_ca_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS Account ID. | `string` | n/a | yes |
| <a name="input_ca_arn"></a> [ca\_arn](#input\_ca\_arn) | ARNs of existing private certificate authorities to attach to the MSK cluster | `list(string)` | `[]` | no |
| <a name="input_ca_type"></a> [ca\_type](#input\_ca\_type) | The type of the certificate authority | `string` | `"ROOT"` | no |
| <a name="input_certificate_authority"></a> [certificate\_authority](#input\_certificate\_authority) | True if PCA should be created on cluster creation and there is not an existing CA to use | `bool` | `null` | no |
| <a name="input_client_unauthenticated"></a> [client\_unauthenticated](#input\_client\_unauthenticated) | True if no client authentication. Should be false if TLS authentication enabled. | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the MSK Cluster | `string` | `""` | no |
| <a name="input_config_arn"></a> [config\_arn](#input\_config\_arn) | ARN of an existing MSK configuration to attach to the cluster | `string` | `""` | no |
| <a name="input_config_description"></a> [config\_description](#input\_config\_description) | Description for the created MSK configuration | `string` | `""` | no |
| <a name="input_config_kafka_versions"></a> [config\_kafka\_versions](#input\_config\_kafka\_versions) | Kafka versions supported by the created MSK configuration | `list(string)` | `[]` | no |
| <a name="input_config_name"></a> [config\_name](#input\_config\_name) | Name of the MSK configuration to create and attach to the cluster | `string` | `""` | no |
| <a name="input_config_revision"></a> [config\_revision](#input\_config\_revision) | Revision of an existing MSK configuration to attach to the cluster | `number` | `null` | no |
| <a name="input_config_server_properties"></a> [config\_server\_properties](#input\_config\_server\_properties) | Kafka broker properties for the MSK configuration | `string` | `""` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | MSK EBS Volume Size | `number` | `1000` | no |
| <a name="input_encryption_at_rest_kms_key_arn"></a> [encryption\_at\_rest\_kms\_key\_arn](#input\_encryption\_at\_rest\_kms\_key\_arn) | Customer managed KMS key ARN to use for encryption at rest | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_enhanced_monitoring"></a> [enhanced\_monitoring](#input\_enhanced\_monitoring) | The desired enhanced MSK CloudWatch monitoring level | `string` | `"DEFAULT"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | MSK Cluster Instance Type | `string` | `"kafka.t3.small"` | no |
| <a name="input_jmx_exporter_monitoring_enabled"></a> [jmx\_exporter\_monitoring\_enabled](#input\_jmx\_exporter\_monitoring\_enabled) | Whether to enable JMX Exporter Open Monitoring | `bool` | `false` | no |
| <a name="input_kafka_version"></a> [kafka\_version](#input\_kafka\_version) | Kafka version for the MSK cluster | `string` | `"3.9.x"` | no |
| <a name="input_node_exporter_monitoring_enabled"></a> [node\_exporter\_monitoring\_enabled](#input\_node\_exporter\_monitoring\_enabled) | Whether to enable Node Exporter Open Monitoring | `bool` | `false` | no |
| <a name="input_number_of_broker_nodes"></a> [number\_of\_broker\_nodes](#input\_number\_of\_broker\_nodes) | Number of broker nodes in the MSK cluster | `number` | `3` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-west-2"` | no |
| <a name="input_storage_autoscaling_max_capacity"></a> [storage\_autoscaling\_max\_capacity](#input\_storage\_autoscaling\_max\_capacity) | The MSK cluster EBS maximum volume size for each broker. Value between 1 and 16384. | `number` | `1` | no |
| <a name="input_storage_autoscaling_threshold"></a> [storage\_autoscaling\_threshold](#input\_storage\_autoscaling\_threshold) | The percentage threshold that needs to be exceeded to trigger a scale up. Value between 10 and 80. | `number` | `65` | no |
| <a name="input_storage_mode"></a> [storage\_mode](#input\_storage\_mode) | Specify the storage mode for MSK brokers. Valid values: LOCAL (default) or TIERED. | `string` | `"LOCAL"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnets that the MSK cluster should run in | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to the MSK | `map(string)` | `{}` | no |
| <a name="input_tls_authentication"></a> [tls\_authentication](#input\_tls\_authentication) | Enables TLS client authentication | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR Range | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The MSK cluster's VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_brokers_tls"></a> [bootstrap\_brokers\_tls](#output\_bootstrap\_brokers\_tls) | TLS connection host:port pairs |
| <a name="output_msk_cluster_arn"></a> [msk\_cluster\_arn](#output\_msk\_cluster\_arn) | The MSK cluster arn |
| <a name="output_msk_cluster_ca_arn"></a> [msk\_cluster\_ca\_arn](#output\_msk\_cluster\_ca\_arn) | The primary MSK cluster CA ARN (first value when multiple CA ARNs are provided) |
| <a name="output_msk_sg_id"></a> [msk\_sg\_id](#output\_msk\_sg\_id) | The MSK security group ID |
| <a name="output_zookeeper_connect_string"></a> [zookeeper\_connect\_string](#output\_zookeeper\_connect\_string) | Comma-separated ZooKeeper connection string |
