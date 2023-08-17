resource "google_storage_bucket" "main" {
  name                        = var.storage_name
  storage_class               = var.storage_class
  location                    = "us-central1"
  project                     = var.project_id
  uniform_bucket_level_access = var.uniform_bucket_level_access
  force_destroy = true

  versioning {
    enabled = var.storage_versioning
  }
}

resource "google_storage_bucket_object" "content_folder" {
  name    = "empty_directory/another_directory/"
  content = "Not really a directory, but it's empty."
  bucket  = google_storage_bucket.main.name
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 9.0.0"

  project = var.project_id
  name    = "test-elb"

  managed_ssl_certificate_domains = ["xample.com"]
  ssl                   = true
  http_forward          = false
  https_redirect        = true
  create_address        = true
  load_balancing_scheme = "EXTERNAL_MANAGED"
  private_key = ""
  certificate = ""

  create_url_map = false
  url_map        = google_compute_url_map.url-map.self_link
  backends       = {}
}

resource "google_compute_backend_bucket" "image_backend" {
  name        = "image-backend-bucket-olu-test"
  description = "Contains beautiful images"
  project         = var.project_id
  bucket_name = google_storage_bucket.main.name
  enable_cdn  = true
}

# resource "google_storage_bucket" "image_bucket" {
#   name     = "image-store-bucket-olu-test"
#   location = "us-central1"
#   project         = var.project_id
# }

resource "google_compute_url_map" "url-map" {
  name            = "test-elb-url-map"
  default_service = google_compute_backend_bucket.image_backend.self_link
  project         = var.project_id

  host_rule {
    hosts        = ["xample.com"]
    path_matcher = "test-path-matcher"
  }

  path_matcher {
    name            = "test-path-matcher"
    default_service = google_compute_backend_bucket.image_backend.self_link
    path_rule {
      paths   = ["/home"]
      service = google_compute_backend_bucket.image_backend.self_link
    }
  }
}