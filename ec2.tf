provider "aws" {
  region = var.region
  profile = "default"
}

terraform {
  backend "s3" {
    profile = "default"
    bucket = "terraformstatecode"
    key = "vpc/terraform.tfstate"
    region = var.region
    
  }
}

resource "aws_instance" "demoserver" {
    count = 2
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = "${element(var.subnet,count.index)}
    key_name = "devops"

    tags {
        Name = "demoserver${count.index+1}"
    }
}