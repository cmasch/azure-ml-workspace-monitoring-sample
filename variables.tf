variable "suffix" {
  type = string
  validation {
    condition     = length(var.suffix) <= 4
    error_message = "Suffix must have length 4 or shorter."
  }
}

variable "region" {
  type = string
}

variable "stage" {
  type = string
}

variable "tags" {
  type = map(string)
}

##############################
## Azure Machine Learning
##############################

variable "notebook_size" {
  type = string
}

variable "notebook_stop" {
  type = bool
}

variable "cluster_size" {
  type = string
}

variable "cluster_min_nodes" {
  type = number
}

variable "cluster_max_nodes" {
  type = number
}