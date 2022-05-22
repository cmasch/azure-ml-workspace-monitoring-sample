suffix = "csa"
stage  = "dev"
region = "westus"

tags   = {
  "Owner" = "Christopher Masch"
  "Project" = "AML Monitoring"
  "Deployment" = "Terraform"
  "CostCenter" = "0000"
  "Criticality" = "Low"
  "DataClassification" = "NonBusiness"
  "Workload" = "Demo"
}

## Azure Machine Learning
notebook_size = "STANDARD_DS2_V2"
notebook_stop = true                      ## if true --> notebook will be stopped after creation

cluster_size      = "STANDARD_DS2_V2"
cluster_min_nodes = 0
cluster_max_nodes = 3
