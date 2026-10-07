variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instances_config" {
  type = map(object({
    ami_id           = string
    instance_type    = string
    key_name         = string
    root_volume_type = string
    root_volume_size = number
    iops             = optional(number)
    tags             = map(string)
  }))
}

variable "account_a_id" {
  type    = string
  default = "000000000000"
}

variable "account_b_id" {
  type    = string
  default = "111111111111"
}

variable "s3_bucket_arn_account_b" {
  type    = string
  default = "arn:aws:s3:::my-app-data-bucket-account-b"
}