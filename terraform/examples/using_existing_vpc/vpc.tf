module "an_already_existing_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.30.0"

  enable_dns_hostnames = true
  enable_dns_support   = true

  cidr = "10.0.1.0/16"

  azs            = ["${var.aws_az}"]
  public_subnets = ["10.0.1.0/24"]

  tags = {
    ManagedBy = "terraform"
    Name      = "Example vpc"
  }
}
