variable "project_id" {
  type        = string
  description = "The Google Cloud project id to deploy to."
  default     = "ooloruntoba-playground"
}

variable "environment" {
  type        = string
  description = "The deployment envionrment ex: test"
  default     = "test"
}

variable "storage_name" {
  type        = string
  description = "The storage name"
}

variable "storage_class" {
  type        = string
  description = "The storage class"
}

variable "uniform_bucket_level_access" {
  type        = bool
  description = "Enable uniform bucket level access"
}

variable "storage_versioning" {
  type        = bool
  description = "Enable storage versioning"
}