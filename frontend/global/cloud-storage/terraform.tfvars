project_id = "boxpay-prod"

gcs_bucket = {
  boxpay-prod-tf-state-asia-south2 = {
    app_name           = "boxpay-prod-tf-state-asia-south2"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "terraform-state"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  prod-boxpay-cf-source-bucket-asia-south2 = {
    app_name           = "prod-boxpay-cf-source-bucket-asia-south2"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "cf-source-bucket"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  alb-logs-mu = {
    app_name           = "alb-logs-mu"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "logs"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  aws-cloudtrail-logs-911107148191-b5eb40b4 = {
    app_name           = "aws-cloudtrail-logs-911107148191-b5eb40b4"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "logs"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  aws-cloudtrail-logszzz = {
    app_name           = "aws-cloudtrail-logszzz"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "logs"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  boxpay-generic-recon-prod-tf-state = {
    app_name           = "boxpay-generic-recon-prod-tf-state"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "terraform-state"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  boxpay-india-prod-alb-logs = {
    app_name           = "boxpay-india-prod-alb-logs"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "alb-logs"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  boxpay-india-prod-tf-state = {
    app_name           = "boxpay-india-prod-tf-state"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "terraform-state"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  boxpay-nsc-backup = {
    app_name           = "boxpay-nsc-backup"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "backup"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  cf-templates-nqoi6z66dkdu-asia-south2 = {
    app_name           = "cf-templates-nqoi6z66dkdu-asia-south2"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "cf-templates"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  cf-templates-nqoi6z66dkdu-us-east-1 = {
    app_name           = "cf-templates-nqoi6z66dkdu-us-east-1"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "cf-templates"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  error-classification-service-india-prod-request-response-logs = {
    app_name           = "error-classification-service-india-prod-request-response-logs"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "logs"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  generic-recon-prod-record-files-storage = {
    app_name           = "generic-recon-prod-record-files-storage"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "record-files-storage"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-adyen-settlement = {
    app_name           = "india-prod-adyen-settlement"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "settlement"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-billdesk-converted-settlement = {
    app_name           = "india-prod-billdesk-converted-settlement"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "settlement"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-billdesk-excel-settlement = {
    app_name           = "india-prod-billdesk-excel-settlement"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "settlement"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-billdesk-zip-settlement = {
    app_name           = "india-prod-billdesk-zip-settlement"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "settlement"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-boxpay-settlement = {
    app_name           = "india-prod-boxpay-settlement"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "settlement"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-jiopay-settlement = {
    app_name           = "india-prod-jiopay-settlement"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "settlement"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-mastercard-bin = {
    app_name           = "india-prod-mastercard-bin"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "bin"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-paypal-csv-settlement = {
    app_name           = "india-prod-paypal-csv-settlement"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "settlement"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-rupay-bin = {
    app_name           = "india-prod-rupay-bin"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "bin"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-visa-bin = {
    app_name           = "india-prod-visa-bin"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "bin"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  india-prod-worldpay-bin = {
    app_name           = "india-prod-worldpay-bin"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "bin"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  pay-orch-api-india-prod-file-storage = {
    app_name           = "pay-orch-api-india-prod-file-storage"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "file-storage"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  pay-orch-api-india-prod-merchant-reports-storage = {
    app_name           = "pay-orch-api-india-prod-merchant-reports-storage"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "merchant-reports"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  wafsecurityautomations-accessloggingbucket-11lhiegscarzq = {
    app_name           = "wafsecurityautomations-accessloggingbucket-11lhiegscarzq"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "waf-logs"
      region      = "asia-south2"
    }
    retention_policy = null
  },
  cdn-cache-prod-boxpay = {
    app_name           = "cdn-cache-prod-boxpay"
    location           = "asia-south2"
    versioning         = true
    storage_class      = "STANDARD"
    bucket_policy_only = true
    force_destroy      = false
    enable_neg         = false
    data_locations     = []
    labels = {
      environment = "prod"
      purpose     = "cdn"
      region      = "asia-south2"
    }
    retention_policy = null
    iam_members=[
      {
        member = "serviceAccount:service-85024060585@https-lb.iam.gserviceaccount.com"
        role = "roles/storage.objectViewer"
      }
    ]
  }
}
