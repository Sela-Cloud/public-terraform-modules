# AWS SQS Queue Root Module

This root module manages Amazon Simple Queue Service (SQS) standard and FIFO message queues via Sela Craft dynamic UI.

## Usage

```hcl
module "sqs" {
  source = "./modules/aws/sqs"

  region = "us-east-1"

  sqs = {
    "order-queue" = {
      name                       = "order-queue"
      visibility_timeout_seconds = 60
      tags = {
        Environment = "production"
      }
    }
  }
}
```
