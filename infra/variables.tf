variable "aws_region" {
  type        = string
  description = "Default region of terraform configuration"
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR Block Range"
  default     = "10.80.0.0/16"
}


variable "public_subnet_config" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "Public subnet CIDR Block Range and AZ configuration"
  default = {
    "public_class6_subnet_1" = {
      cidr_block = "10.80.1.0/24"
      az         = "eu-west-1a"
    }
    "public_class6_subnet_2" = {
      cidr_block = "10.80.2.0/24"
      az         = "eu-west-1b"
    }
    "public_class6_subnet_3" = {
      cidr_block = "10.80.3.0/24"
      az         = "eu-west-1c"
    }
  }
}

variable "private_subnet_config" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "Private subnet CIDR Block Range and AZ configuration"
  default = {
    "splunkapp_subnet_1" = {
      cidr_block = "10.80.11.0/24"
      az         = "eu-west-1a"
    }
    "splunkapp_subnet_2" = {
      cidr_block = "10.80.12.0/24"
      az         = "eu-west-1b"
    }
    "splunkapp_subnet_3" = {
      cidr_block = "10.80.13.0/24"
      az         = "eu-west-1c"
    }
  }
}



