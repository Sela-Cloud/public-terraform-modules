# AWS SNS Topic Root Module

This root module manages Amazon Simple Notification Service (SNS) Topics via Sela Craft dynamic UI.

## Usage

```hcl
module "sns" {
  source = "./modules/aws/sns"

  region = "us-east-1"

  sns = {
    "order-events" = {
      name         = "order-events"
      display_name = "Order Events"
      tags = {
        Environment = "production"
      }
    }
  }
}
```
