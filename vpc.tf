resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

###############################################
#Two Public Subnets Created
resource "aws_subnet" "STACK-PUB1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/23"
  availability_zone = var.availability_zone[0]
  depends_on  = [ aws_vpc.main ]

  tags = {
    Name = "Public-Subnet1"
  }
}

resource "aws_subnet" "STACK-PUB2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/23"
  depends_on  = [ aws_vpc.main ]
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "Public-Subnet2"
  }
}

###############################################
#Two Application Server Private Subnets Created
resource "aws_subnet" "APP-SERVER1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = var.availability_zone[0]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "App-Server-1"
  }
}

resource "aws_subnet" "APP-SERVER2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.availability_zone[1]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "App-Server-2"
  }
}

################################################
#Two RDS Private Subnets Created
resource "aws_subnet" "RDS-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.8.0/22"
  availability_zone = var.availability_zone[0]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "RDS-1"
  }
}

resource "aws_subnet" "RDS-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.12.0/22"
  availability_zone = var.availability_zone[1]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "RDS-2"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "RDS-GRP" {
  name        = "rds_subnet_group"
  subnet_ids  = [aws_subnet.RDS-1.id, aws_subnet.RDS-2.id]
  description = "RDS Subnet Group"
  depends_on  = [ aws_vpc.main ]
}

################################################
#Two Oracle DB Private Subnets Created
resource "aws_subnet" "ORACLE-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.16.0/24"
  availability_zone = var.availability_zone[0]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "Oracle-DB-1"
  }
}

resource "aws_subnet" "ORACLE-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.17.0/24"
  availability_zone = var.availability_zone[1]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "Oracle-DB-2"
  }
}

# Oracle Subnet Group
resource "aws_db_subnet_group" "ORACLE-GRP" {
  name        = "oracle_subnet_group"
  subnet_ids  = [aws_subnet.ORACLE-1.id, aws_subnet.ORACLE-2.id]
  description = "Oracle Subnet Group"
  depends_on  = [ aws_vpc.main ]
}

################################################
#Two Java DB Private Subnets Created
resource "aws_subnet" "JAVA-DB-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.18.0/26"
  availability_zone = var.availability_zone[0]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "Java-DB-1"
  }
}

resource "aws_subnet" "JAVA-DB-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.19.0/26"
  availability_zone = var.availability_zone[1]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "Java-DB-2"
  }
}

# Java DB Subnet Group
resource "aws_db_subnet_group" "JAVA-DB-GRP" {
  name        = "java_db_subnet_group"
  subnet_ids  = [aws_subnet.JAVA-DB-1.id, aws_subnet.JAVA-DB-2.id]
  description = "Java DB Subnet Group"
  depends_on  = [ aws_vpc.main ]
}

################################################
#Two Java Server Private Subnets Created
resource "aws_subnet" "JAVA-SERVER-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.20.0/26"
  availability_zone = var.availability_zone[0]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "Java-Server-1"
  }
}

resource "aws_subnet" "JAVA-SERVER-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.21.0/26"
  availability_zone = var.availability_zone[1]
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "Java-Server-2"
  }
}

# Java DB Subnet Group
resource "aws_db_subnet_group" "JAVA-SERVER-GRP" {
  name        = "java_server_subnet_group"
  subnet_ids  = [aws_subnet.JAVA-SERVER-1.id, aws_subnet.JAVA-SERVER-2.id]
  description = "Java Server Subnet Group"
  depends_on  = [ aws_vpc.main ]
}

#Internet Gateway Created and Attached to VPC
resource "aws_internet_gateway" "STACK-IGW" {
  vpc_id = aws_vpc.main.id
  depends_on  = [ aws_vpc.main ]

  tags = {
    Name = "STACK-IGW"
  }
}

# resource "aws_internet_gateway_attachment" "STACK-IGW-ATT" {
#   internet_gateway_id = aws_internet_gateway.STACK-IGW.id
#   vpc_id              = aws_vpc.main.id
#   depends_on          = [ aws_vpc.main ]
# }

# NAT Gateways, Route Tables
#Create Elastic IP
resource "aws_eip" "STACK-NAT-EIP" {
}

resource "aws_nat_gateway" "STACK-NAT-PUB1" {
  allocation_id = aws_eip.STACK-NAT-EIP.id
  subnet_id     = aws_subnet.STACK-PUB1.id
  
  tags = {
    Name = "STACK-NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_vpc.main, aws_internet_gateway.STACK-IGW, aws_eip.STACK-NAT-EIP]
}

#Create Elastic IP2
resource "aws_eip" "STACK-NAT-EIP2" {
}

resource "aws_nat_gateway" "STACK-NAT-PUB2" {
  allocation_id = aws_eip.STACK-NAT-EIP2.id
  subnet_id     = aws_subnet.STACK-PUB2.id

  tags = {
    Name = "STACK-NAT2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_vpc.main, aws_internet_gateway.STACK-IGW, aws_eip.STACK-NAT-EIP2]
}


# Edit the vpc main route table
# resource "aws_route" "main-vpc-routetable_default" {
#   route_table_id         = aws_vpc.main-vpc.main_route_table_id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.main-int-gateway.id
# }

# Public Subnet Route Table
resource "aws_route_table" "STACK-PUB" {
  vpc_id      = aws_vpc.main.id
  depends_on  = [ aws_vpc.main ]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.STACK-IGW.id
  }

  tags = {
    Name = "STACK-TESTSTACKRT1"
  }
}

resource "aws_route_table_association" "STACK-PUB1" {
  subnet_id      = aws_subnet.STACK-PUB1.id
  route_table_id = aws_route_table.STACK-PUB.id
}

resource "aws_route_table_association" "STACK-PUB2" {
  subnet_id      = aws_subnet.STACK-PUB2.id
  route_table_id = aws_route_table.STACK-PUB.id
}

#############################################
# AZ-1 Route Table and Subnet Association
resource "aws_route_table" "AZ1-PRIV" {
  vpc_id    = aws_vpc.main.id
  depends_on  = [ aws_vpc.main ]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.STACK-NAT-PUB1.id
  } 

  tags = {
    Name = "AZ1-PRIV-RT"
  }
}

resource "aws_route_table_association" "APP-SERVER1" {
  subnet_id      = aws_subnet.APP-SERVER1.id
  route_table_id = aws_route_table.AZ1-PRIV.id
}

resource "aws_route_table_association" "RDS-1" {
  subnet_id      = aws_subnet.RDS-1.id
  route_table_id = aws_route_table.AZ1-PRIV.id
}

#############################################
# AZ-2 Route Table and Subnet Association
resource "aws_route_table" "AZ2-PRIV" {
  vpc_id    = aws_vpc.main.id
  depends_on  = [ aws_vpc.main ]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.STACK-NAT-PUB2.id
  } 

  tags = {
    Name = "AZ1-PRIV-RT"
  }
}

resource "aws_route_table_association" "APP-SERVER2" {
  subnet_id      = aws_subnet.APP-SERVER2.id
  route_table_id = aws_route_table.AZ2-PRIV.id
}

resource "aws_route_table_association" "RDS-2" {
  subnet_id      = aws_subnet.RDS-2.id
  route_table_id = aws_route_table.AZ2-PRIV.id
}






# # RDS Subnet Route Table
# resource "aws_route_table" "RDS" {
#   vpc_id    = aws_vpc.main.id
#   depends_on  = [ aws_vpc.main ]

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.STACK-NAT-PUB2.id 
#   }  

#   tags = {
#     Name = "RDS-RT"
#   }
# }

# resource "aws_route_table_association" "RDS-1" {
#   subnet_id      = aws_subnet.RDS-1.id
#   route_table_id = aws_route_table.RDS.id
# }

# resource "aws_route_table_association" "RDS-2" {
#   subnet_id      = aws_subnet.RDS-2.id
#   route_table_id = aws_route_table.RDS.id
# }

