variable "project_name" {
    default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    project = "expense"
    Environment = "dev"
    terraform = "true"
  }
}

variable "zone_id" {
  default = "Z02390421VDGLE6J5KZ5U"
}

variable "domain_name" {
  default = "gonew.io"
}