provider "aws" {
  region = var.region
  profile = "default"
}

terraform {
  backend "s3" {
    profile = "default"
    bucket = "terraformstatecode"
    key = "vpc/terraform.tfstate"
    region = "us-east-2"
    
  }
}

resource "aws_instance" "demoserver" {
    count = 2
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = "${element(var.subnet,count.index)}"
    key_name = "devops"

    user_data = <<-EOF
        #! /bin/bash
        sudo apt-get update
        sudo apt-get install -y apache2
        sudo systemctl start apache2
        sudo systemctl enable apache2
     EOF

    tags = {
        Name = "demoserver.${count.index+1}"
    }
}
