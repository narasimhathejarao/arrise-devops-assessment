terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique-12345"
    key            = "devops-assignment/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}