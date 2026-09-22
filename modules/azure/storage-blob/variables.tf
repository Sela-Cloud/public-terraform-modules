variable "name" {
  description = "The name of the storage blob. Must be unique within the storage container the blob is located. Changing this forces a new resource to be created."
  type        = string
  default     = "sample-blob.txt"

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 1024
    error_message = "The storage blob name must be between 1 and 1024 characters."
  }
}

variable "storage_container_id" {
  description = "The ID of the storage container in which this blob should be created. Changing this forces a new resource to be created."
  type        = string
  default     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-default/providers/Microsoft.Storage/storageAccounts/storagedefault/blobServices/default/containers/container-default"
}

variable "type" {
  description = "The type of the storage blob to be created. Possible values are 'Block', 'Append', or 'Page'. Changing this forces a new resource to be created."
  type        = string
  default     = "Block"

  validation {
    condition     = contains(["Block", "Append", "Page"], var.type)
    error_message = "type must be one of 'Block', 'Append', or 'Page'."
  }
}

variable "size" {
  description = "Used only for Page blobs to specify the size in bytes of the blob to be created. Must be a multiple of 512. Changing this forces a new resource to be created."
  type        = number
  default     = null

  validation {
    condition     = var.size == null || can(var.size % 512 == 0)
    error_message = "size must be a multiple of 512."
  }
}

variable "content_type" {
  description = "The content type of the storage blob. Cannot be defined if source_uri is defined. Defaults to 'application/octet-stream'."
  type        = string
  default     = "application/octet-stream"
}

variable "source_content" {
  description = "The content for this blob which should be defined inline. This field can only be specified for Block blobs and cannot be specified if source or source_uri is specified. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "source_file" {
  description = "An absolute path to a file on the local system. This field cannot be specified for Append blobs and cannot be specified if source_content or source_uri is specified. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "source_uri" {
  description = "The URI of an existing blob, or a file in the Azure File service, to use as the source contents for the blob to be created. Changing this forces a new resource to be created. This field cannot be specified for Append blobs and cannot be specified if source or source_content is specified."
  type        = string
  default     = null
}

variable "access_tier" {
  description = "The access tier of the storage blob. Possible values are 'Archive', 'Cool', 'Cold', and 'Hot'."
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Archive", "Cool", "Cold", "Hot"], var.access_tier)
    error_message = "access_tier must be one of 'Archive', 'Cool', 'Cold', or 'Hot'."
  }
}

variable "cache_control" {
  description = "Controls the Cache-Control header content of the response when the blob is requested."
  type        = string
  default     = null
}

variable "content_md5" {
  description = "The MD5 sum of the blob contents. Cannot be defined if source_uri is defined, or if blob type is Append or Page. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "encryption_scope" {
  description = "The encryption scope to use for this blob. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "parallelism" {
  description = "The number of workers per CPU core to run for concurrent uploads. Defaults to 8. Changing this forces a new resource to be created."
  type        = number
  default     = 8

  validation {
    condition     = var.parallelism > 0
    error_message = "parallelism must be greater than 0."
  }
}

variable "metadata" {
  description = "A map of custom key-value pairs to assign as metadata to the storage blob."
  type        = map(string)
  default     = {}
}
