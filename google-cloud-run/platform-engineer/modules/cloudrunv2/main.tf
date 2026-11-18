resource "google_cloud_run_v2_service" "app" {
  name     = var.workload_name
  project  = var.project_id
  location = var.region
  ingress  = var.ingress
  deletion_policy = "DELETE" #Just for POC Purpose, this could be changed to "ABANDON" or "NEVER" based on the requirement

  template {
    service_account = var.sa-email

    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = var.max_instance_count
    }

    containers {
      image = var.image_url

      ports {
        container_port = var.container_port
      }

      resources {
        limits = {
          cpu    = var.container_cpu_limit
          memory = var.container_memory_limit
        }
      }
    }
  }
}

# Optional: make it publicly invokable
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = google_cloud_run_v2_service.app.project
  location = google_cloud_run_v2_service.app.location
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}