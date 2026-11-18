output "service_url" {
  description = "The primary URL assigned to the Cloud Run service."
  value       = google_cloud_run_v2_service.default.uri
}

output "service_id" {
  description = "The full resource identifier."
  value       = google_cloud_run_v2_service.default.id
}

output "service_name" {
  description = "The short name of the Cloud Run service."
  value       = google_cloud_run_v2_service.default.name
}
