variable "region" {
  default = "sa-east-1"
}

variable "remote_state_bucket" {}
variable "remote_state_key" {}

# Application variables for task
variable "ecs_service_name" {}
variable "docker_image_url" {}
variable "memory" {}
variable "docker_container_port" {}
variable "spring_profile" {}
variable "desired_task_number" {}