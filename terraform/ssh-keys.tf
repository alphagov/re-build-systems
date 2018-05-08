resource "aws_key_pair" "deployer-ssh-key" {
  key_name   = "jenkins2_key_${var.product}-${var.environment}"
  public_key = "${file("../../${var.product}-config/terraform/keys/${var.product}-${var.environment}-ssh-deployer.pub")}"
}
