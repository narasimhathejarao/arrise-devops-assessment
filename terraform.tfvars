aws_region   = "us-east-1"
account_a_id = "000000000000"
account_b_id = "111111111111"

instances_config = {
  "web-prod-01" = {
    ami_id           = "ami-0c55b159cbfafe1f0"
    instance_type    = "t3.medium"
    key_name         = "key-prod-web"
    root_volume_type = "gp3"
    root_volume_size = 30
    tags = {
      Name        = "web-prod-01"
      Environment = "production"
      Owner       = "web-team"
    }
  },
  "db-primary-01" = {
    ami_id           = "ami-0c55b159cbfafe1f0"
    instance_type    = "r5.large"
    key_name         = "key-prod-db"
    root_volume_type = "io2"
    root_volume_size = 100
    iops             = 3000
    tags = {
      Name        = "db-primary-01"
      Environment = "production"
      Owner       = "dba-team"
    }
  },
  "app-backend-01" = {
    ami_id           = "ami-0c55b159cbfafe1f0"
    instance_type    = "c5.large"
    key_name         = "key-backend"
    root_volume_type = "gp3"
    root_volume_size = 50
    tags = {
      Name        = "app-backend-01"
      Environment = "staging"
      Owner       = "backend-team"
    }
  },
  "cache-redis-01" = {
    ami_id           = "ami-0c55b159cbfafe1f0"
    instance_type    = "m5.large"
    key_name         = "key-cache"
    root_volume_type = "gp2"
    root_volume_size = 20
    tags = {
      Name        = "cache-redis-01"
      Environment = "production"
      Owner       = "platform-team"
    }
  },
  "analytics-worker-01" = {
    ami_id           = "ami-0c55b159cbfafe1f0"
    instance_type    = "t3.small"
    key_name         = "key-analytics"
    root_volume_type = "gp3"
    root_volume_size = 40
    tags = {
      Name        = "analytics-worker-01"
      Environment = "development"
      Owner       = "data-team"
    }
  }
}