variable "region" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "project_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "subnet_cidr" {
  type = string
  default = "10.10.0.0/24"
}

variable "db_machine_type" {
  type = string
}

variable "pg_image" {
  type = string
}
