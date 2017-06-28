variable "account"                  { }
variable "ami_id" 		    { }
variable "availability_zone"        { }
variable "environment"              { }
variable "owner"                    { default = "Terraform" }
variable "instance_type"	    { }
variable "created_by"               { }
variable "region"                   { default = "us-west-2" }
variable "vpc_id"                   { }
variable "subnet_id"                { }
variable "snapshot_id"              { }
variable "key_name"		    { }
variable "bucket"		    { }

provider "aws" {
  region = "${var.region}"
  }

resource "aws_iam_instance_profile" "test_profile" {
  name  = "s3instancerole"
  role = "${aws_iam_role.s3policyrole.name}"
}

resource "aws_iam_policy" "s3policy" {
  name  = "s3policy"
  policy = "${file("policies/iam.json")}"
  }

resource "aws_iam_role" "s3policyrole" {
  name = "s3role"
  path = "/"
  description = "Role to allow s3 sync"
  assume_role_policy = "${file("policies/ec2-role-access-policy.json")}"
  }
  
resource "aws_iam_role_policy_attachment" "policy-attach" {
    role       = "${aws_iam_role.s3policyrole.name}"
    policy_arn = "${aws_iam_policy.s3policy.arn}"
}


resource "aws_s3_bucket" "b" {
  bucket = "${var.bucket}"
  acl    = "public-read"
  policy = "${file("policies/policy.json")}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}


resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  tags {
    Name = "Sainsburys test vpc"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.my_vpc.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_subnet" "my_subnet" {
  vpc_id = "${aws_vpc.my_vpc.id}"
  cidr_block = "172.16.10.0/24"
  availability_zone = "${var.availability_zone}"
  tags {
    Name = "Sainsburys test vpc"
  }
}

resource "aws_network_interface" "sainsburys" {
  subnet_id = "${aws_subnet.my_subnet.id}"
  private_ips = ["172.16.10.100"]
  tags {
    Name = "primary_network_interface"
  }
}

resource "aws_ebs_volume" "enron" {
    availability_zone = "${var.availability_zone}"
    size = 210
    snapshot_id = "${var.snapshot_id}"
    tags {
        Name = "enron dataset"
    }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/xvdb"
  volume_id   = "${aws_ebs_volume.enron.id}"
  instance_id = "${aws_instance.sainsburys.id}"
}


resource "aws_instance" "sainsburys" {
  ami = "${var.ami_id}" 
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  associate_public_ip_address  = "true"
  iam_instance_profile = "s3instancerole"
  user_data = "${file("userdata.txt")}"

  }

