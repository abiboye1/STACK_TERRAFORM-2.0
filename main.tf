### Declare Key Pair
locals {
  ServerPrefix = ""
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

resource "aws_key_pair" "Stack_KP" {
  key_name   = "stack_dep_kp"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

######### BASTION SERVER ########
#Server 1
resource "aws_instance" "BASTION-SERVER1" {
  count                       = var.stack_controls["ec2_create"] == "Y" ? 1 : 0
  ami                         = local.db_creds.ami
  instance_type               = var.EC2_Components["instance_type"]
  vpc_security_group_ids      = [aws_security_group.STACK-PUB-SG.id]
  # user_data               = data.template_file.bootstrap.rendered
  key_name                    = aws_key_pair.Stack_KP.key_name
  subnet_id                   = aws_subnet.STACK-PUB1.id
  depends_on                  = [ aws_vpc.main ]
  associate_public_ip_address = true

  root_block_device {
      volume_type           = var.EC2_Components["volume_type"]
      volume_size           = var.EC2_Components["volume_size"]
      delete_on_termination = var.EC2_Components["delete_on_termination"]
      encrypted             = var.EC2_Components["encrypted"] 
    }
  
  tags = {
    Name = "Bastion-Server1"
  }
} 

#Server 1
resource "aws_instance" "BASTION-SERVER2" {
  count                       = var.stack_controls["ec2_create"] == "Y" ? 1 : 0
  ami                         = local.db_creds.ami
  instance_type               = var.EC2_Components["instance_type"]
  vpc_security_group_ids      = [aws_security_group.STACK-PUB-SG.id]
  # user_data               = data.template_file.bootstrap.rendered
  key_name                    = aws_key_pair.Stack_KP.key_name
  subnet_id                   = aws_subnet.STACK-PUB2.id
  depends_on                  = [ aws_vpc.main ]
  associate_public_ip_address = true

  root_block_device {
      volume_type           = var.EC2_Components["volume_type"]
      volume_size           = var.EC2_Components["volume_size"]
      delete_on_termination = var.EC2_Components["delete_on_termination"]
      encrypted             = var.EC2_Components["encrypted"] 
    }
  
  tags = {
    Name = "Bastion-Server2"
  }
}

######### CLIXX BLOCK ###########
resource "aws_efs_file_system" "clixx_efs" {
  count                  = var.stack_controls["clixx_create"] == "Y" ? 1 : 0
  creation_token         = "stack-terra-EFS"
  performance_mode       = "generalPurpose"
  throughput_mode        = "bursting"
  encrypted              = "false"
  tags = {
    Name = "stack_EFS"
  }
}

resource "aws_efs_mount_target" "clixx_mount" {
  count                  = var.stack_controls["clixx_create"] == "Y" ? 1 : 0
  file_system_id         = aws_efs_file_system.clixx_efs[count.index].id
  subnet_id              = aws_subnet.APP-SERVER1.id
  security_groups        = [aws_security_group.APP-SERVER-SG.id]
}

resource "aws_efs_mount_target" "clixx_mount2" {
  count                  = var.stack_controls["clixx_create"] == "Y" ? 1 : 0
  file_system_id         = aws_efs_file_system.clixx_efs[count.index].id
  subnet_id              = aws_subnet.APP-SERVER2.id
  security_groups        = [aws_security_group.APP-SERVER-SG.id]
}


######### BLOG BLOCK ###########
resource "aws_efs_file_system" "blog_efs" {
  count            = var.stack_controls["blog_create"] == "Y" ? 1 : 0
  creation_token   = "blog-terra-EFS"
  tags = {
    Name = "blog_EFS"
  }
}

resource "aws_efs_mount_target" "blog_mount" {
  count           = var.stack_controls["blog_create"] == "Y" ? 1 : 0
  file_system_id  = aws_efs_file_system.blog_efs[count.index].id
  subnet_id       = aws_subnet.APP-SERVER1.id
  security_groups = [aws_security_group.APP-SERVER-SG.id]
}

resource "aws_efs_mount_target" "blog_mount2" {
  count = var.stack_controls["blog_create"] == "Y" ? 1 : 0
  file_system_id  = aws_efs_file_system.blog_efs[count.index].id
  subnet_id       = aws_subnet.APP-SERVER2.id
  security_groups = [aws_security_group.APP-SERVER-SG.id]
}


# resource "aws_ebs_volume" "app-data" {
#   count             = var.num_ebs_volumes
#   availability_zone = aws_instance.server[0].availability_zone
#   size              = var.ebs_volumes[element(keys(var.ebs_volumes), count.index)]

#   tags = {
#     Name = "/dev/sdh-${element(keys(var.ebs_volumes), count.index)}"
#   }
# }

# #attach volumes to the instance
# resource "aws_volume_attachment" "app-vol" {
#   count        = var.num_ebs_volumes
#   device_name  = "/dev/sd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"], count.index)}"
#   volume_id    = aws_ebs_volume.app-data[count.index].id
#   instance_id  = aws_instance.server[0].id
#   force_detach = true
# }

# resource "null_resource" "mount_ebs_volumes" {
#   depends_on = [aws_volume_attachment.app-vol]
#   count      = var.num_ebs_volumes

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"  
#     private_key = file(var.PATH_TO_PRIVATE_KEY)
#     host        = aws_instance.server[0].public_ip
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "set -e",
#       "set -x",
#       "sudo mkdir -p /u0${count.index + 1}",  #create a mount point

#       #format the volume with ext4 filesystem
#       "sudo mkfs -t ext4 /dev/sd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"], count.index)}",

#       #check if the entry already exists in /etc/fstab
#       "if ! grep -q '/dev/sd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"], count.index)} /u0${count.index + 1}' /etc/fstab; then",

#       #add the entry to /etc/fstab
#       "echo '/dev/sd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"], count.index)} /u0${count.index + 1} ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab",  # Add entry to /etc/fstab
#       "fi",

#     ]
#   }
# }

# resource "null_resource" "mount_all_volumes" {
#   depends_on = [null_resource.mount_ebs_volumes]

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file(var.PATH_TO_PRIVATE_KEY)
#     host        = aws_instance.server[0].public_ip
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo mount -a",  # Mount all filesystems listed in /etc/fstab
#     ]
#   }
# }



# resource "aws_ebs_volume" "blog-data" {
#   count             = var.num_ebs_volumes
#   availability_zone = aws_instance.blogserver[0].availability_zone
#   size              = var.ebs_volumes[element(keys(var.ebs_volumes), count.index)]

#   tags = {
#     Name = "/dev/sdh-${element(keys(var.ebs_volumes), count.index)}"
#   }
# }

# #attach volumes to the instance
# resource "aws_volume_attachment" "blog-vol" {
#   count        = var.num_ebs_volumes
#   device_name  = "/dev/sd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"], count.index)}"
#   volume_id    = aws_ebs_volume.blog-data[count.index].id
#   instance_id  = aws_instance.blogserver[0].id
#   force_detach = true
# }

# resource "null_resource" "blog_ebs_volumes" {
#   depends_on = [aws_volume_attachment.blog-vol]
#   count = var.num_ebs_volumes

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"  
#     private_key = file(var.PATH_TO_PRIVATE_KEY)
#     host        = aws_instance.blogserver[0].public_ip
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "set -e",
#       "set -x",
#       "sudo mkdir -p /u0${count.index + 1}",  #create a mount point

#       #format the volume with ext4 filesystem
#       "sudo mkfs -t ext4 /dev/sd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"], count.index)}",

#       #check if the entry already exists in /etc/fstab
#       "if ! grep -q '/dev/sd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"], count.index)} /u0${count.index + 1}' /etc/fstab; then",

#       #add the entry to /etc/fstab
#       "echo '/dev/sd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"], count.index)} /u0${count.index + 1} ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab",  # Add entry to /etc/fstab
#       "fi",

#     ]
#   }
# }

# resource "null_resource" "mount_blog_volumes" {
#   depends_on = [null_resource.blog_ebs_volumes]

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file(var.PATH_TO_PRIVATE_KEY)
#     host        = aws_instance.blogserver[0].public_ip
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo mount -a",  # Mount all filesystems listed in /etc/fstab
#     ]
#   }
# }

