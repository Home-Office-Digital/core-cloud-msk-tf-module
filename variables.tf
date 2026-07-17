variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_id" {
  description = "The MSK cluster's VPC ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the MSK Cluster"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "MSK Cluster Instance Type"
  type        = string
  default     = "kafka.t3.small"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to the MSK"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      contains(keys(var.tags), "account-code"),
      contains(keys(var.tags), "cost-centre"),
      contains(keys(var.tags), "portfolio-id"),
      contains(keys(var.tags), "project-id"),
      contains(keys(var.tags), "service-id"),
      contains(keys(var.tags), "environment-type"),
      contains(keys(var.tags), "owner-business"),
      contains(keys(var.tags), "budget-holder"),
      contains(keys(var.tags), "source-repo")
    ])
    error_message = "Tags must include all mandatory fields."
  }
}

variable "account_id" {
  description = "The AWS Account ID."
  type        = string
}

variable "kafka_version" {
  type    = string
  default = "3.9.x"
}

variable "number_of_broker_nodes" {
  type    = number
  default = 3
}

variable "ebs_volume_size" {
  description = "MSK EBS Volume Size"
  type        = number
  default     = 1000
}

variable "subnet_ids" {
  description = "A list of subnets that the MSK cluster should run in"
  type        = list(string)
}

variable "jmx_exporter_monitoring_enabled" {
  description = "Whether to enable JMX Exporter Open Monitoring"
  type        = bool
  default     = false
}

variable "node_exporter_monitoring_enabled" {
  description = "Whether to enable Node Exporter Open Monitoring"
  type        = bool
  default     = false
}

variable "storage_mode" {
  description = "Specify the storage mode for MSK brokers. Valid values: LOCAL (default) or TIERED."
  type        = string
  default     = "LOCAL"
}

variable "storage_autoscaling_max_capacity" {
  description = "The MSK cluster EBS maximum volume size for each broker. Value between 1 and 16384."
  type        = number
  default     = 1
  validation {
    condition = (
      var.storage_autoscaling_max_capacity >= 1 &&
      var.storage_autoscaling_max_capacity <= 16384
    )
    error_message = "Storage autoscaling max capacity must be between 1 and 16384."
  }
}

variable "storage_autoscaling_threshold" {
  description = "The percentage threshold that needs to be exceeded to trigger a scale up. Value between 10 and 80."
  type        = number
  default     = 65
  validation {
    condition = (
      var.storage_autoscaling_threshold >= 10 &&
      var.storage_autoscaling_threshold <= 80
    )
    error_message = "Storage autoscaling threshold must be between 10 and 80."
  }
}

variable "ca_arn" {
  description = "ARNs of existing private certificate authorities to attach to the MSK cluster when TLS authentication is enabled"
  type        = list(string)
  default     = []

  validation {
    condition     = var.certificate_authority != true || length(var.ca_arn) == 0
    error_message = "ca_arn cannot be set when certificate_authority is true. Provide either existing CA ARNs or create a CA with the module."
  }

  validation {
    condition = alltrue([
      for arn in var.ca_arn : can(regex("^arn:aws(-[a-z]+)*:acm-pca:[a-z0-9-]+:[0-9]{12}:certificate-authority/.+$", trimspace(arn)))
    ])
    error_message = "Each ca_arn value must be a valid ACM PCA certificate-authority ARN."
  }
}

variable "certificate_authority" {
  description = "True if PCA should be created on cluster creation and there is not an existing CA to use"
  type        = bool
  default     = null

  validation {
    condition     = var.certificate_authority != true || var.tls_authentication
    error_message = "certificate_authority can only be true when tls_authentication is enabled."
  }
}

variable "ca_type" {
  description = "The type of the certificate authority"
  type        = string
  default     = "ROOT"
}

variable "tls_authentication" {
  description = "Enables TLS client authentication"
  type        = bool
  default     = false
}

variable "client_unauthenticated" {
  description = "True if no client authentication. Should be false if TLS authentication enabled."
  type        = bool
  default     = true
}

variable "config_name" {
  description = "Name of the MSK configuration to create and attach to the cluster"
  type        = string
  default     = ""

  validation {
    condition     = !(var.config_name != "" && var.config_arn != "")
    error_message = "config_name and config_arn are mutually exclusive. Use either bring-your-own configuration inputs (config_arn + config_revision) or create-configuration inputs (config_name + config_kafka_versions + config_server_properties)."
  }
}

variable "config_kafka_versions" {
  description = "Kafka versions supported by the created MSK configuration"
  type        = list(string)
  default     = []

  validation {
    condition     = (var.config_name != "") == (length(var.config_kafka_versions) > 0)
    error_message = "config_name and config_kafka_versions must be set together."
  }
}

variable "config_server_properties" {
  description = "Kafka broker properties for the MSK configuration"
  type        = string
  default     = ""

  validation {
    condition     = var.config_name == "" || trimspace(var.config_server_properties) != ""
    error_message = "config_server_properties must be set when config_name is provided."
  }
}

variable "config_description" {
  description = "Description for the created MSK configuration"
  type        = string
  default     = ""
}

variable "config_revision" {
  description = "Revision of an existing MSK configuration to attach to the cluster"
  type        = number
  default     = null

  validation {
    condition     = (trimspace(var.config_arn) != "") == (var.config_revision != null)
    error_message = "config_revision must be set if and only if config_arn is set."
  }
}

variable "config_arn" {
  description = "ARN of an existing MSK configuration to attach to the cluster"
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.config_arn) == "" || can(regex("^arn:aws(-[a-z]+)*:kafka:[^:]+:[0-9]{12}:configuration/.+", trimspace(var.config_arn)))
    error_message = "config_arn must be empty or a valid MSK configuration ARN."
  }
}

variable "enhanced_monitoring" {
  description = "The desired enhanced MSK CloudWatch monitoring level"
  type        = string
  default     = "DEFAULT"

  validation {
    condition = contains([
      "DEFAULT",
      "PER_BROKER",
      "PER_TOPIC_PER_BROKER",
      "PER_TOPIC_PER_PARTITION"
    ], var.enhanced_monitoring)
    error_message = "enhanced_monitoring must be one of DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER, or PER_TOPIC_PER_PARTITION."
  }
}

variable "encryption_at_rest_kms_key_arn" {
  description = "Customer managed KMS key ARN to use for encryption at rest"
  type        = string
  default     = null

  validation {
    condition     = var.encryption_at_rest_kms_key_arn == null || can(regex("^arn:aws(-[a-z]+)*:kms:[a-z0-9-]+:[0-9]{12}:key/[0-9a-fA-F-]+$", trimspace(var.encryption_at_rest_kms_key_arn)))
    error_message = "encryption_at_rest_kms_key_arn must be null or a valid KMS key ARN."
  }
}