# Workload Resource Definition using the Humanitec Terraform Driver
# Provisions a Google Cloud Run v2 service with explicit ingress control
resource "humanitec_resource_definition" "google_cloud_run_workload" {
  driver_type = "humanitec/terraform"
  id          = "${var.object_prefix}workload"
  name        = "${var.object_prefix}workload"
  type        = "workload"

  driver_inputs = {
    values_string = jsonencode(merge(
      {
        script = <<-EOT
          terraform {
            required_version = ">= 1.5.0"
            required_providers {
              google = {
                source  = "hashicorp/google"
                version = "~> 6.0"
              }
            }
          }

          variable "project_id" {
            type        = string
            description = "Target GCP project ID"
          }

          variable "region" {
            type        = string
            description = "Target GCP region for Cloud Run"
          }

          variable "service_name" {
            type        = string
            description = "Cloud Run service name"
          }

          variable "service_account" {
            type        = string
            description = "Runtime GCP service account email"
          }

          variable "ingress" {
            type        = string
            description = "Cloud Run ingress traffic policy"
            default     = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
          }

          variable "workload" {
            type        = any
            description = "Rendered Score workload inputs from Humanitec"
          }

          provider "google" {
            project = var.project_id
            region  = var.region
          }

          locals {
            # Extract the first container defined in the Score workload inputs
            container_name = keys(var.workload.containers)[0]
            container_spec = var.workload.containers[local.container_name]

            # Map Score container environment variables to Cloud Run env blocks
            env_vars = try(local.container_spec.variables, {})

            # Resolve the first exposed container port if defined in Score
            service_ports = try(values(var.workload.service.ports), [])
            target_port   = length(local.service_ports) > 0 ? try(local.service_ports[0].targetPort, local.service_ports[0].port) : 8080
          }

          resource "google_cloud_run_v2_service" "workload" {
            name     = var.service_name
            location = var.region

            # Enforces org policy constraints/run.allowedIngress
            # Options: INGRESS_TRAFFIC_INTERNAL_ONLY | INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER | INGRESS_TRAFFIC_ALL
            ingress = var.ingress

            template {
              service_account = var.service_account

              containers {
                name  = local.container_name
                image = local.container_spec.image

                ports {
                  container_port = local.target_port
                }

                dynamic "env" {
                  for_each = local.env_vars
                  content {
                    name  = env.key
                    value = tostring(env.value)
                  }
                }
              }
            }
          }

          output "service_name" {
            description = "Deployed Cloud Run v2 service name"
            value       = google_cloud_run_v2_service.workload.name
          }

          output "uri" {
            description = "Cloud Run service URL"
            value       = google_cloud_run_v2_service.workload.uri
          }
        EOT

        variables = {
          project_id      = "$${resources[\"config.default#shared.env\"].outputs.gcp_project_id}"
          region          = "$${resources[\"config.default#shared.env\"].outputs.gcp_region}"
          service_name    = "${var.object_prefix}$${context.app.id}-$${context.env.id}-$${context.res.guresid}"
          service_account = "$${resources.gcp-service-account.outputs.email}"
          ingress         = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
          workload        = "$${context.workload.spec}"
        }
      },
      # Only include credentials_config when gcp_use_service_account_key is true (avoids null/nil schema error)
      var.gcp_use_service_account_key ? {
        credentials_config = {
          environment = {
            GOOGLE_APPLICATION_CREDENTIALS = "credentials"
          }
        }
      } : {}
    ))

    secrets_string = jsonencode(merge(
      var.gcp_use_service_account_key ? {
        credentials = "$${resources[\"config.default#shared.env\"].outputs.gcp_deployer_key}"
      } : {}
    ))
  }
}

resource "humanitec_resource_definition_criteria" "google_cloud_run_workload_criteria_0" {
  resource_definition_id = resource.humanitec_resource_definition.google_cloud_run_workload.id
  app_id                 = humanitec_application.google_cloud_run.id
  env_id                 = humanitec_environment.google_cloud_run_development.id
  class                  = "google-cloud-run"
  force_delete           = true
}