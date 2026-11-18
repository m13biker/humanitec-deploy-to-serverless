variable "project_id" {
  description = "Your Google Cloud project ID"
  type        = string
}
variable "region" { 
  description = "Google Cloud region to use for resources, e.g. 'europe-west3'"
  type        = string
  default = "us-east1" 
}

variable "workload_name" { 
  description = "The name of the Cloud Run service"
  type = string
}

variable "ingress" { 
  description = "Ingress settings for the service"
  type        = string
  default = "INGRESS_TRAFFIC_INTERNAL_ONLY" 
}

variable "sa-email" { 
  description = "Email address of the service account to use"
  type = string 
}
variable "min_instance_count" { 
  description = "Minimum number of instances for the service"
  type = number
  default = 0
}
variable "max_instance_count" { 
  description = "Maximum number of instances for the service"
  type = number
  default = 3
}
variable "image_url" {
  description = "URL of the Docker image to deploy"
  type = string
}
variable "container_port" {
  description = "Port number for the container"
  type = number
  default = 8080
}
variable "container_cpu_limit" {
  description = "CPU limit for the container"
  type = number
  default = 1
}
variable "container_memory_limit" {
  description = "Memory limit for the container"
  type = string
  default = "512Mi"
}