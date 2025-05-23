# Terraform AWS Hybrid Web Hosting Project

## 🧰 Overview

This project demonstrates a hybrid web hosting solution using **Terraform** to provision:

- A web server on EC2 with Apache, PHP, and Git
- EBS volume attachment and mounting to host web content
- Static image hosting on S3
- Global content delivery via CloudFront CDN
- Integration of S3-hosted image into a dynamically rendered HTML page on the EC2 instance

This setup showcases how cloud-native services can be orchestrated using Infrastructure as Code (IaC) for real-world DevOps deployment scenarios.

---

## ⚙️ Services Used

- **Terraform** (IaC)
- **Amazon EC2** (Compute)
- **Amazon EBS** (Block Storage)
- **Amazon S3** (Object Storage)
- **Amazon CloudFront** (CDN)
- **Security Groups** for networking
- **Provisioners** for remote configuration

---

## 🗂️ Project Structure

```
.
├── main.tf               # Terraform script with all resources
├── README.md             # Project documentation
├── hybrid.jpg            # Image uploaded to S3 and rendered via CloudFront
├── cloud.pem             # SSH private key (not to be shared/public)
└── cloud.html            # Web page rendered with CloudFront image
```

---

## 🚀 Key Features

- Launches and configures an Apache web server
- Attaches and formats an EBS volume
- Mounts the EBS volume to the Apache root
- Clones a GitHub repo into `/var/www/html`
- Uploads an image to an S3 bucket
- Configures a CloudFront distribution for that image
- Dynamically inserts a CloudFront-served image into the HTML page
- Automatically opens the rendered web page in a browser

---

## ✅ Prerequisites

- AWS CLI and Terraform installed
- SSH key file (`saikey.pem`) configured correctly
- Replace file paths (`C:/...`) with appropriate paths on your machine
- Valid and unique S3 bucket name

---

## 🔐 Security Notes

- SSH (22), HTTP (80), and ICMP (ping) are open to all — restrict in production
- Never push `.pem` files or local image assets to public repositories
- Ensure the image key and bucket ACL are correctly set for public-read

---

## 👔 Recruiter Highlights

- Real-world **hybrid deployment** using EC2 + S3 + EBS + CloudFront
- Strong grasp of **provisioners, connections**, and remote-exec configuration
- Emphasizes **multi-service orchestration** using Terraform
- Reflects **DevOps readiness** and ability to build scalable cloud infra

---
## 👤 Author

**Sai Jayanth Rajamahendram**  
Cloud | DevOps | Infrastructure as Code  
[LinkedIn](https://www.linkedin.com/in/saijayanthraj/) | [GitHub](https://github.com/saijayanth41)
