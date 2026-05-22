provider "aws" {
  region = "us-east-1" # You can change this to your preferred region (e.g., ap-southeast-2 for Sydney)
}

# Create a Security Group to allow Web Traffic and Monitoring
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow HTTP and Grafana traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# Launch a Free Tier EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c7217cdde317cfec" # Standard Ubuntu 22.04 LTS AMI (Double check your region's AMI ID)
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Bootstrapping script: Installs Docker automatically on startup
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # Run your Node app container directly on port 80
              sudo docker run -d -p 80:80 node:18-alpine npx express-generator --view=pug /app && cd /app && npm install && npm start
              EOF

  tags = {
    Name = "Observability-Demo-Server"
  }
}

output "instance_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "The public IP of your deployed web server"
}