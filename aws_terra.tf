#provider
provider "aws" {
  profile = "jayanth"
  region  = "ap-south-1"
}


#creating securitygroup

resource "aws_security_group" "security_group" {
  name        = "security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-d6bda1be"

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_group"
  }
}

#ec2 instance launch

resource "aws_instance" "cloud" {
  ami             = "ami-0447a12f28fddb066"
  instance_type   = "t2.micro"
  security_groups = [ "security_group" ]
  key_name = "saikey"
 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/saijayanth/Downloads/saikey.pem")
    host        = aws_instance.cloud.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd"
    ]
  }
  tags = {
    Name = "cloud"
  }
}



output "os_out" {
  value = aws_instance.cloud.availability_zone
}


# create volume
resource "aws_ebs_volume" "myvolume" {
 availability_zone = aws_instance.cloud.availability_zone
 size = 1
 tags = {
   Name = "myvolume"
 }
}

# attach volume

resource "aws_volume_attachment" "myvolume" {

depends_on = [
    aws_ebs_volume.myvolume,
  ]
 device_name  = "/dev/xvdf"
 volume_id    = aws_ebs_volume.myvolume.id
 instance_id  = aws_instance.cloud.id
 force_detach = true

connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/saijayanth/Downloads/saikey.pem")
    host        = aws_instance.cloud.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdf",
      "sudo mount /dev/xvdf /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/saijayanth41/cloud.git /var/www/html/"

    ]
  }
}

# s3 bucket

resource "aws_s3_bucket" "cloudbucket" {
  bucket = "mybucket41"
  acl    = "public-read"
  region = "ap-south-1"

  tags = {
    Name = "mybucket41"
  }
}

# adding object to s3

resource "aws_s3_bucket_object" "image-upload" {

depends_on = [
    aws_s3_bucket.cloudbucket,
  ]
    bucket  = aws_s3_bucket.cloudbucket.bucket
    key     = "hybrid.jpg"
    source  = "C:/Users/saijayanth/Downloads/hybrid.jpg"
    acl     = "public-read"
}

output "bucketid" {
  value = aws_s3_bucket.cloudbucket.bucket
}
output "myos_ip" {
  value = aws_instance.cloud.public_ip
}
# cloud front

variable "oid" {
	type    = string
 	default = "S3-"
}

locals {
  s3_origin_id = "${var.oid}${aws_s3_bucket.cloudbucket.id}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
depends_on = [
    aws_s3_bucket_object.image-upload,
  ]
  origin {
    domain_name = aws_s3_bucket.cloudbucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  enabled             = true
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }


connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/saijayanth/Downloads/saikey.pem")
    host        = aws_instance.cloud.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo su <<END",
      "echo \"<img src='http://${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_bucket_object.image-upload.key}' height='459' width='612'>\" >> /var/www/html/cloud.html",
      "END",
    ]
  }
}

resource "null_resource" "openwebsite"  {
depends_on = [
    aws_cloudfront_distribution.s3_distribution, aws_volume_attachment.myvolume
  ]
	provisioner "local-exec" {
	   command = "start chrome http://${aws_instance.cloud.public_ip}/cloud.html"
  	}
}