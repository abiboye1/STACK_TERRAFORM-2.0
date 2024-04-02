#Public Subnet NACL and Security Group

# #Network ACL
# resource "aws_network_acl" "STACK-PUB-NACL" {
#   vpc_id = aws_vpc.main.id
#   depends_on  = [ aws_vpc.main ]

#   egress {
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 22
#     to_port    = 22
#   }

#   egress {
#     protocol   = "tcp"
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 80
#     to_port    = 80
#   }

#   egress {
#     protocol   = "tcp"
#     rule_no    = 300
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 3306
#     to_port    = 3306
#   }  

#   egress {
#     protocol   = "tcp"
#     rule_no    = 400
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 2049
#     to_port    = 2049
#   } 

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 22
#     to_port    = 22
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 80
#     to_port    = 80
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 300
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 3306
#     to_port    = 3306
#   }  

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 400
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 2049
#     to_port    = 2049
#   }

#   tags = {
#     Name = "STACK-Pub-NACL"
#   }
# }

# #NACL Association
# resource "aws_network_acl_association" "STACK-PUB" {
#   network_acl_id = aws_network_acl.STACK-PUB-NACL.id
#   subnet_id      = aws_subnet.STACK-PUB.id
# }

# resource "aws_network_acl_association" "STACK-PUB2" {
#   network_acl_id = aws_network_acl.STACK-PUB-NACL.id
#   subnet_id      = aws_subnet.STACK-PUB2.id
# }

#Security Group
resource "aws_security_group" "STACK-PUB-SG" {
  vpc_id      = aws_vpc.main.id
  name        = "STACK-Pub-SG"
  description = "Security group for Application Servers"
  depends_on  = [ aws_vpc.main ]

  ingress {
    description       = "SSH from VPC"
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
    }

  ingress {
    description       = "EFS mount target"
    protocol          = "tcp"
    from_port         = 2049
    to_port           = 2049
    cidr_blocks       = ["0.0.0.0/0"]
    }

  ingress {
    description       = "HTTP from VPC"
    protocol          = "tcp"
    from_port         = 80
    to_port           = 80
    cidr_blocks       = ["0.0.0.0/0"]
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  timeouts {
    delete = "2m"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#######################################################
#######################################################
#Security Group App Server Subnet
resource "aws_security_group" "APP-SERVER-SG" {
  vpc_id      = aws_vpc.main.id
  name        = "App-Server-SG"
  description = "Security group for App Servers Subnets"
  depends_on  = [ aws_vpc.main ]

  ingress {
    description       = "SSH from VPC"
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
    security_groups   = [aws_security_group.STACK-PUB-SG.id]
    }

  ingress {
    description       = "EFS mount target"
    protocol          = "tcp"
    from_port         = 2049
    to_port           = 2049
    security_groups   = [aws_security_group.STACK-PUB-SG.id]
    }

  ingress {
    description       = "HTTP from VPC"
    protocol          = "tcp"
    from_port         = 80
    to_port           = 80
    security_groups   = [aws_security_group.STACK-PUB-SG.id]
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  timeouts {
    delete = "2m"
  }

  lifecycle {
    create_before_destroy = true
  }
}


#Security Group for RDS Subnet
resource "aws_security_group" "RDS-SG" {
  vpc_id      = aws_vpc.main.id
  name        = "RDS-SG"
  description = "Security group for RDS Subnets"
  depends_on  = [ aws_vpc.main ]

  ingress {
    description       = "Aurora/MySQL"
    protocol          = "tcp"
    from_port         = 3306
    to_port           = 3306
    security_groups = [aws_security_group.APP-SERVER-SG.id]
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  timeouts {
    delete = "2m"
  }

  lifecycle {
    create_before_destroy = true
  }
}