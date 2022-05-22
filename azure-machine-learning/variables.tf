variable "region" {
  type = string
}

variable "suffix" {
  type = string
}

variable "stage" {
  type = string
}

variable "notebook_size" {
  type = string
}

variable "cluster_size" {
  type = string
}

variable "notebook_stop" {
  type = bool
  default = true
}

variable "cluster_min_nodes" {
  type = number
}

variable "cluster_max_nodes" {
  type = number
}

variable "log_analytics_ws" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}