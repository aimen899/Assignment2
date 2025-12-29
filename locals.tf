# Data source to get current public IP
data "http" "my_ip" {
  url = "https://icanhazip.com"
}

locals {
  # Dynamic IP detection for security group rules
  my_ip = "${chomp(data.http.my_ip. response_body)}/32"

  # Common tags for all resources
  common_tags = {
    Environment = var.env_prefix
    Project     = "Assignment-2"
    ManagedBy   = "Terraform"
  }

  # Backend server configurations
  backend_servers = [
    {
      name        = "web-1"
      suffix      = "1"
      script_path = "./scripts/apache-setup.sh"
    },
    {
      name        = "web-2"
      suffix      = "2"
      script_path = "./scripts/apache-setup.sh"
    },
    {
      name        = "web-3"
      suffix      = "3"
      script_path = "./scripts/apache-setup.sh"
    }
  ]

  # Nginx server configuration
  nginx_config = {
    name        = "nginx-proxy"
    suffix      = "nginx"
    script_path = "./scripts/nginx-setup.sh"
  }
}
