provider "aws" {
  region = "us-east-1"
}

variable "cidr" {
  default = "10.0.0.0/16"
}
resource "aws_key_pair" "diksha_key" {
  key_name   = diksha34
  private_key = file("${path.module}/diksha34.pem")
  
}
resource "aws_vpc" "diksha_vpc" {
    cidr_block = "10.0.0.0/16"

   
  
}
resource "aws_subnet" "diksha_public_subnet" {
  vpc_id     = aws_vpc.diksha_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  
}
resource "aws_route_table" "diksha_route" {
    vpc_id     = aws_vpc.diksha_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.diksha_ig.id
  }
}

resource "aws_route_table_association" "diksha_association" {
    subnet_id = aws_subnet.diksha_public_subnet.id
    route_table_id = aws_route_table.diksha_route.id
  
}
resource "aws_security_group" "diksha" {
    name = "web"
    vpc_id = aws_vpc.diksha_vpc.id

    ingress {
        description = "HTTP from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

     ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

  
}
resource "aws_internet_gateway" "diksha_ig" {
  vpc_id = aws_vpc.diksha_vpc.id

 
}

resource "aws_instance" "diksha_ec2" {
    ami =     
    instance_type = "t2.micro"
    subnet_id = aws_subnet.diksha_public_subnet.id
    key_name  =  diksha34
    vpc_security_group_ids = [aws_security_group.diksha.id]


    connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("${path.module}/diksha34.pem")  # Replace with the path to your private key
    host        = self.public_ip
  } 


  provisioner "file" {
    source      = "app.py"  # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }

   provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",
    ]
  }
  
}


