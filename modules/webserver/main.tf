# Data source to get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair
resource "aws_key_pair" "main" {
  key_name   = "${var.env_prefix}-key-${var.instance_suffix}"
  public_key = file(var.public_key)

  tags = merge(var.common_tags, {
    Name = "${var.env_prefix}-key-${var.instance_suffix}"
  })
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true

  user_data = file(var.script_path)

  tags = merge(var.common_tags, {
    Name = "${var.env_prefix}-${var.instance_name}"
  })

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    
    tags = merge(var.common_tags, {
      Name = "${var.env_prefix}-${var.instance_name}-root"
    })
  }
}
