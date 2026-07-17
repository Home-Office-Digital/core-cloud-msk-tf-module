// Mock provider to avoid real AWS calls during tests.
mock_provider "aws" {}

override_data {
  target = data.aws_iam_policy_document.msk_ca_policy[0]
  values = {
    json = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "acm-pca:IssueCertificate",
            "acm-pca:GetCertificate"
          ],
          "Resource": "arn:aws:acm-pca:eu-west-2:100000000000:certificate-authority/11111111-2222-3333-4444-555555555555"
        }
      ]
    }
    EOT
  }
}

variables {
  account_id                       = "100000000000"
  certificate_authority            = true
  client_unauthenticated           = false
  cluster_name                     = "msk-test"
  ebs_volume_size                  = 1000
  environment                      = "test"
  instance_type                    = "kafka.t3.small"
  jmx_exporter_monitoring_enabled  = true
  node_exporter_monitoring_enabled = true
  number_of_broker_nodes           = 2
  project_name                     = "testproject"
  subnet_ids                       = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
  tls_authentication               = true
  vpc_id                           = "vpc-00000000000000000"
  vpc_cidr                         = ["10.0.0.0/8"]

  tags = {
    Environment      = "test"
    Project          = "test"
    cost-centre      = "CC1000"
    account-code     = "AC1000"
    portfolio-id     = "PF1000"
    project-id       = "PR1000"
    service-id       = "SV1000"
    environment-type = "test"
    owner-business   = "test"
    budget-holder    = "testteam"
    source-repo      = "UKHomeOffice/core-cloud-msk-tf-module"
  }
}

run "validate_existing_ca_path" {
  command = plan

  variables {
    certificate_authority = false
    ca_arn                = ["arn:aws:acm-pca:eu-west-2:100000000000:certificate-authority/11111111-2222-3333-4444-555555555555"]
  }

  assert {
    condition     = contains(flatten([for auth in aws_msk_cluster.msk_cluster.client_authentication : flatten([for tls in auth.tls : tls.certificate_authority_arns])]), "arn:aws:acm-pca:eu-west-2:100000000000:certificate-authority/11111111-2222-3333-4444-555555555555")
    error_message = "The cluster should attach the provided existing CA ARN when TLS authentication is enabled."
  }
}

run "validate_multiple_ca_path" {
  command = plan

  variables {
    certificate_authority = false
    ca_arn = [
      "arn:aws:acm-pca:eu-west-2:100000000000:certificate-authority/11111111-2222-3333-4444-555555555555",
      "arn:aws:acm-pca:eu-west-2:100000000000:certificate-authority/66666666-7777-8888-9999-000000000000"
    ]
  }

  assert {
    condition = alltrue([
      contains(flatten([for auth in aws_msk_cluster.msk_cluster.client_authentication : flatten([for tls in auth.tls : tls.certificate_authority_arns])]), "arn:aws:acm-pca:eu-west-2:100000000000:certificate-authority/11111111-2222-3333-4444-555555555555"),
      contains(flatten([for auth in aws_msk_cluster.msk_cluster.client_authentication : flatten([for tls in auth.tls : tls.certificate_authority_arns])]), "arn:aws:acm-pca:eu-west-2:100000000000:certificate-authority/66666666-7777-8888-9999-000000000000")
    ])
    error_message = "The cluster should attach all provided CA ARNs when TLS authentication is enabled."
  }
}

run "validate_configuration_creation_path" {
  command = plan

  variables {
    config_description       = "Test MSK configuration"
    config_kafka_versions    = ["3.9.x"]
    config_name              = "msk-test-config"
    config_server_properties = "auto.create.topics.enable = true"
  }

  assert {
    condition     = aws_msk_configuration.msk_cluster[0].name == "msk-test-config"
    error_message = "The module should create an MSK configuration when config_name is provided."
  }

  assert {
    condition     = length(aws_msk_cluster.msk_cluster.configuration_info) == 1
    error_message = "The cluster should include configuration_info when an MSK configuration is requested."
  }
}

run "validate_configuration_attach_path" {
  command = plan

  variables {
    config_arn      = "arn:aws:kafka:eu-west-2:100000000000:configuration/msk-shared-config/11111111-2222-3333-4444-555555555555-1"
    config_revision = 7
  }

  assert {
    condition     = length(aws_msk_cluster.msk_cluster.configuration_info) == 1
    error_message = "The cluster should include configuration_info when an existing MSK configuration is attached."
  }

  assert {
    condition     = aws_msk_cluster.msk_cluster.configuration_info[0].revision == 7
    error_message = "The cluster should use the provided revision for an attached existing MSK configuration."
  }

  assert {
    condition     = length(aws_msk_configuration.msk_cluster) == 0
    error_message = "The module should not create an MSK configuration when config_arn is provided."
  }
}

run "validate_enhanced_monitoring" {
  command = plan

  variables {
    enhanced_monitoring   = "PER_BROKER"
  }

  assert {
    condition     = aws_msk_cluster.msk_cluster.enhanced_monitoring == "PER_BROKER"
    error_message = "The cluster should preserve the requested enhanced monitoring level."
  }
}

run "validate_customer_managed_kms_key" {
  command = plan

  variables {
    encryption_at_rest_kms_key_arn = "arn:aws:kms:eu-west-2:100000000000:key/11111111-2222-3333-4444-555555555555"
  }

  assert {
    condition     = aws_msk_cluster.msk_cluster.encryption_info[0].encryption_at_rest_kms_key_arn == "arn:aws:kms:eu-west-2:100000000000:key/11111111-2222-3333-4444-555555555555"
    error_message = "The cluster should attach the provided customer managed KMS key ARN for encryption at rest."
  }
}

run "validate_config_name_and_versions_set_together" {
  command = plan

  variables {
    config_name           = ""
    config_kafka_versions = ["3.9.x"]
  }

  expect_failures = [
    var.config_kafka_versions
  ]
}

run "validate_certificate_authority_requires_tls_authentication" {
  command = plan

  variables {
    tls_authentication    = false
    certificate_authority = true
  }

  expect_failures = [
    var.certificate_authority
  ]
}

run "validate_config_name_and_config_arn_mutually_exclusive" {
  command = plan

  variables {
    config_name     = "msk-test-config"
    config_arn      = "arn:aws:kafka:eu-west-2:100000000000:configuration/msk-shared-config/11111111-2222-3333-4444-555555555555-1"
    config_revision = 7
  }

  expect_failures = [
    var.config_name
  ]
}

run "validate_config_arn_requires_config_revision" {
  command = plan

  variables {
    config_arn      = "arn:aws:kafka:eu-west-2:100000000000:configuration/msk-shared-config/11111111-2222-3333-4444-555555555555-1"
    config_revision = null
  }

  expect_failures = [
    var.config_revision
  ]
}

run "validate_config_revision_requires_config_arn" {
  command = plan

  variables {
    config_arn      = ""
    config_revision = 7
  }

  expect_failures = [
    var.config_revision
  ]
}

run "validate_config_arn_format" {
  command = plan

  variables {
    config_arn      = "not-an-arn"
    config_revision = 7
  }

  expect_failures = [
    var.config_arn
  ]
}

run "validate_config_arn_format_valid" {
  command = plan

  variables {
    config_arn      = "arn:aws:kafka:eu-west-2:100000000000:configuration/msk-shared-config/11111111-2222-3333-4444-555555555555-1"
    config_revision = 7
  }
}

run "validate_ca_arn_format" {
  command = plan

  variables {
    certificate_authority = false
    ca_arn                = ["not-an-arn"]
  }

  expect_failures = [
    var.ca_arn
  ]
}

run "validate_ca_arn_format_valid" {
  command = plan

  variables {
    certificate_authority = false
    ca_arn                = ["arn:aws:acm-pca:eu-west-2:100000000000:certificate-authority/11111111-2222-3333-4444-555555555555"]
  }
}

run "validate_kms_key_arn_format" {
  command = plan

  variables {
    encryption_at_rest_kms_key_arn = "not-an-arn"
  }

  expect_failures = [
    var.encryption_at_rest_kms_key_arn
  ]
}

run "validate_kms_key_arn_format_valid" {
  command = plan

  variables {
    encryption_at_rest_kms_key_arn = "arn:aws:kms:eu-west-2:100000000000:key/11111111-2222-3333-4444-555555555555"
  }
}