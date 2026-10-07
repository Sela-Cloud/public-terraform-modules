# AWS RDS Frontend Module

Frontend catalog wrapper module for Amazon RDS instances supporting MySQL and PostgreSQL.

## Overview

This module provides catalog-ready schema mappings, validation metadata, and parameter definitions to provision Amazon RDS databases across AWS regions.

## Usage

```hcl
module "rds" {
  source = "./modules/aws/rds"

  region = "us-east-1"
  rds = {
    "my-app-db" = {
      identifier                  = "my-app-db"
      engine                      = "mysql"
      engine_version              = "8.0.35"
      instance_class              = "db.t4g.micro"
      allocated_storage           = 20
      db_name                     = "appdb"
      manage_master_user_password = true
      vpc_id                      = "vpc-0123456789abcdef0"
      subnet_ids                  = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
    }
  }
}
```
