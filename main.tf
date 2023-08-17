# module "storage" {
#   source                      = "./modules/storage"
#   project_id                  = var.project_id
#   storage_name                = var.storage_name
#   storage_class               = var.storage_class
#   uniform_bucket_level_access = var.uniform_bucket_level_access
#   storage_versioning          = var.storage_versioning
# }

resource "google_storage_bucket" "main" {
  name                        = "olu-test-olu-test-2"
  storage_class               = "STANDARD"
  project                     = var.project_id
  location                    = "us-central1"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_object" "upload_folder" {
  name   = ".well-known/"
  content = " "
  bucket = google_storage_bucket.main.name
}

data "google_iam_policy" "viewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
        "allUsers",
    ] 
  }
}

data "google_iam_policy" "editor" {
  #checkov:skip=CKV_GCP_113:IAM policy is defined for public access
  binding {
    role = "roles/storage.legacyBucketOwner"
    members = [
        "allAuthenticatedUsers"
    ] 
  }
}

resource "google_storage_bucket_iam_policy" "reader" {
  bucket = google_storage_bucket.main.name
  policy_data = data.google_iam_policy.viewer.policy_data
}

resource "google_storage_bucket_iam_policy" "editor" {
  bucket = google_storage_bucket.main.name
  policy_data = data.google_iam_policy.editor.policy_data
}