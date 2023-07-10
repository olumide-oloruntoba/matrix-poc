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


resource "google_logging_metric" "logging_metric" {
  name    = "${var.environment}-metric-custom-lb"
  filter  = "resource.labels.project_id=\"${var.project_id}\" resource.type=\"http_load_balancer\"  jsonPayload.enforcedSecurityPolicy.outcome=\"ACCEPT\"" //metric will collect data only on requests that passed Armor
  project = var.project_id
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    labels {
      key         = "http_status"
      value_type  = "STRING"
      description = "http response code"
    }
  }
  label_extractors = {
    "http_status" = "EXTRACT(httpRequest.status)"
  }
}

resource "terraform_data" "metric_check" {
  provisioner "local-exec" {
    command = <<-EOT
        #!/bin/bash
        metric_name="test-metric-custom-lb"
        retry_interval=30
        max_retries=3
        retry_count=0
        while true; do
            gcloud logging metrics describe "$metric_name"
            
            if [ $? -eq 0 ]; then
                echo "Command executed successfully."
                break
            else
                echo "Command failed. Retrying in $retry_interval seconds..."
                sleep $retry_interval
                retry_count=$((retry_count+1))
                
                if [ $retry_count -eq $max_retries ]; then
                echo "Max retry attempts reached. Exiting..."
                break
                fi
            fi
        done
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    google_logging_metric.logging_metric
  ]
}


resource "google_monitoring_custom_service" "monitoring_service_custom" {
  service_id   = "custom-srv-request-slos"
  display_name = "My Custom Service"
  project      = var.project_id
}

resource "google_monitoring_slo" "monitoring_slo_custom" {
  service      = google_monitoring_custom_service.monitoring_service_custom.service_id
  display_name = "${var.environment}-slo-elb"
  project      = var.project_id

  goal            = 95 / 100
  calendar_period = "MONTH"

  windows_based_sli {
    window_period = "300s"
    good_total_ratio_threshold {
      threshold = 95 / 100
      performance {
        good_total_ratio {
          good_service_filter = "metric.type=\"logging.googleapis.com/user/${var.environment}-metric-custom-lb\" resource.type=\"l7_lb_rule\" metric.label.http_status=starts_with(\"2\")"

          bad_service_filter = "metric.type=\"logging.googleapis.com/user/${var.environment}-metric-custom-lb\" resource.type=\"l7_lb_rule\" metric.label.http_status=starts_with(\"5\")"
        }
      }
    }
  }

  depends_on = [
    terraform_data.metric_check
  ]
}