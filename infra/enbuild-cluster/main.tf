#################
# Variables and Local Variables
#################
variable "aws_region" {
  default = "us-east-1"
}

variable "ssh_key_name" {
}

variable "public_zone_id" {
}

variable "allowed_cidrs" {
  type = map(list(string))
}

variable "kafka_cluster_size" {
  default = 1
}

variable "zookeeper_cluster_size" {
  default = 1
}

variable "manager_admin_password" {
  default = ""
}

variable "manager_lb_acm_certificate_arn" {
  default = ""
}

variable "zookeeper_instance_type" {
  default = "t3a.nano"
}

variable "kafka_instance_type" {
  default = "t3a.nano"
}

variable "manager_instance_type" {
  default = "t3a.nano"
}

#################
# Data
#################
data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = [
      "viv-dev-vpc"
    ]
  }
  filter {
    name = "state"
    values = [
      "available"
    ]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.this.id

  tags = {
    Name = "*private*"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.this.id

  tags = {
    Name = "*public*"
  }
}

data "aws_ami" "enbuild" {
  name_regex = "enbuild-kafka-2.5.1-hvm-*"
  owners = ["986602297069"]
  filter {
    name = "state"
    values = ["available"]
  }
  most_recent = true
}


#################
# Modules
#################
module "keypair" {
  source      = "rhythmictech/secretsmanager-keypair/aws"
  name_prefix = var.ssh_key_name
  description = "SSH keypair for kafka instances"
}

module "cluster" {
  source = "../.."
  manager_admin_password = var.manager_admin_password

  // Example of no Load Balancer, internally accessible manager
  manager_lb_enabled = false

   // Example of self signed certificate for development purpose
//  manager_lb_enabled = true
//  manager_lb_acm_certificate_arn = var.manager_lb_acm_certificate_arn

  vpc_id = data.aws_vpc.this.id
  private_subnet_ids = data.aws_subnet_ids.private.ids
  public_subnet_ids = data.aws_subnet_ids.public.ids
  key_pair_name = module.keypair.key_name # var.ssh_key_name
  public_zone_id = var.public_zone_id
  allowed_cidrs = var.allowed_cidrs
  enbuild_ami_id = data.aws_ami.enbuild.id
  kafka_storage_type = "root"
  kafka_storage_volume_type = "standard"
  kafka_cluster_size = var.kafka_cluster_size
  zookeeper_cluster_size = var.zookeeper_cluster_size

  zookeeper_instance_type = var.zookeeper_instance_type
  kafka_instance_type = var.kafka_instance_type
  manager_instance_type = var.manager_instance_type
}

#################
# Outputs
#################
output "zookeeper_kafka_connect" {
  value = module.cluster.zookeeper_kafka_connect
}

output "kafka_bootstrap_servers_private" {
  value = module.cluster.kafka_bootstrap_servers_private
}

output "manager_cruise_control_endpoint" {
  value = module.cluster.manager_cruise_control_endpoint
}

output "manager_cluster_manager_endpoint" {
  value = module.cluster.manager_cluster_manager_endpoint
}
