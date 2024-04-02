######### CLIXX BLOCK ###########
##### DATABASE
resource "aws_db_instance" "CliXX" {
  count                  = var.stack_controls["clixx_create"] == "Y" ? 1 : 0
  snapshot_identifier    = "${data.aws_db_snapshot.clixxdb.id}"
  identifier             = var.clixx-db-identifier
  instance_class         = "db.t2.micro" 
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.RDS-SG.id]
  db_subnet_group_name   = aws_db_subnet_group.RDS-GRP.name 
}


######### BLOG BLOCK ###########
##### DATABASE
resource "aws_db_instance" "Blog" {
  count                  = var.stack_controls["blog_create"] == "Y" ? 1 : 0
  identifier             = var.blog-db-identifier
  snapshot_identifier    = "${data.aws_db_snapshot.blogdb.id}"
  instance_class         = "db.t2.micro" 
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.RDS-SG.id] 
  db_subnet_group_name   = aws_db_subnet_group.RDS-GRP.name 
}