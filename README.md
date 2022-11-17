# Apache Kafka Cluster Terraform module

Terraform module which creates a cluster of Apache Kafka brokers along with 
Yahoo [CMAK](https://github.com/yahoo/CMAK) and LinkedIn [Cruise Control](https://github.com/linkedin/cruise-control).

## Available Features
* Multi-AZ Apache Kafka and Zookeeper clusters
* Dedicated Apache Zookeeper cluster
* Deployed with Yahoo [CMAK](https://github.com/yahoo/CMAK) (f.k.a Kafka Manager)
* Integrated with LinkedIn [Cruise Control](https://github.com/linkedin/cruise-control)
* Persistent EBS volumes for faster recovery
* Automatic reboot and EC2 instance recovery on status check failures
* EBS volumes encryption

## Usage
```hcl
module "enbuild" {
  source  = "enbuild-staging/kafka-terraform/aws"
  version = "1.6.0"

  manager_admin_password = "parameter/ENBUILD-manager-admin-password"
  manager_lb_enabled = true
  manager_lb_acm_certificate_arn = "arn:aws:acm:us-east-2:111111111111:certificate/8d3d569c-74b2-4d7d-aea7-061c7aa0e8bc"

  vpc_id = "vpc-12345678"
  private_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  public_subnet_ids = ["subnet-09876543", "subnet-56473821"]
  key_pair_name = "my-ssh-key-pair-name"
  public_zone_id = "Z20985FABH34A"
  allowed_cidrs = {
    ipv4 = [
      "10.20.0.0/20",
      "1.2.3.4/32"
    ]
    ipv6 = []
  }
  enbuild_ami_id = data.aws_ami.enbuild.id
  kafka_storage_type = "ebs"
  kafka_storage_volume_type = "gp2"
  kafka_cluster_size = 3
  zookeeper_cluster_size = 3
  tags = {
    Environment = "dev"
    Terraform = "true"
  }
}

data "aws_ami" "enbuild" {
  name_regex = "enbuild-kafka-2.5.1-hvm-*"
  owners = ["self"]
  filter {
    name = "state"
    values = ["available"]
  }
  most_recent = true
}
```

## Requirements

| Name      | Version |
|-----------|---------|
| terraform | >= 1.1  |
| aws       | >= 3.70 |
| null      | >= 3.1  |
