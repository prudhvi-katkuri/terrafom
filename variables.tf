variable "region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}
variable "aws_az"{
    type = "list"
    default = ["us-east-2a","us-east-2b","us-east-2c"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidrs" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "subnet" {
  type = list
  default = ["10.0.3.4","10.0.4.5"]  
}

variable "ami" {
  default = ["ami-0b9064170e32bde34"]
  
}

variable "instance_type" {
  default = ["t2.micro"]

}
