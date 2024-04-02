provider "aws" {
  region = local.db_creds.AWS_REGION

assume_role {
  #the role ARN within Account A to assume role into. Created in step 1
  role_arn = "arn:aws:iam::730335195244:role/Engineer"

  }
}
