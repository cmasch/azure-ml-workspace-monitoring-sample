data "azurerm_subscription" "current" {}

data "template_file" "dash-template" {
  template = "${file("${path.module}/dashboard.json")}"
  vars     = {
    log_analytics_ws_id = azurerm_log_analytics_workspace.aml_log_workspace.id
  }
}



##################################################
### Resources for monitoring
##################################################

resource "azurerm_resource_group" "monitoring_rg" {
  name     = format("rg-aml-monitoring-%s-%s", var.stage, var.suffix)
  location = var.region
  tags     = merge(local.tags, var.tags)
}

resource "azurerm_log_analytics_workspace" "aml_log_workspace" {
  name                = format("logws-aml-monitoring-%s-%s", var.stage, var.suffix)
  location            = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = merge(local.tags, var.tags)
}

resource "azurerm_portal_dashboard" "aml_dashboard" {
  name                 = format("aml-dashboard-%s-%s", var.stage, var.suffix)
  resource_group_name  = azurerm_resource_group.monitoring_rg.name
  location             = azurerm_resource_group.monitoring_rg.location
  dashboard_properties = data.template_file.dash-template.rendered

  tags = merge(local.tags, var.tags)
}



##################################################
### AML workspaces
##################################################

module "aml_workspace_1" {
  source             = "./azure-machine-learning/"
  region             = var.region
  suffix             = format("%s-%s", var.suffix, 1)
  stage              = var.stage
  notebook_size      = var.notebook_size
  cluster_size       = var.cluster_size
  notebook_stop      = var.notebook_stop
  cluster_min_nodes  = var.cluster_min_nodes
  cluster_max_nodes  = var.cluster_max_nodes
  log_analytics_ws   = azurerm_log_analytics_workspace.aml_log_workspace.id

  tags = merge(local.tags, var.tags)
}

module "aml_workspace_2" {
  source             = "./azure-machine-learning/"
  region             = var.region
  suffix             = format("%s-%s", var.suffix, 2)
  stage              = var.stage
  notebook_size      = var.notebook_size
  cluster_size       = var.cluster_size
  notebook_stop      = var.notebook_stop
  cluster_min_nodes  = var.cluster_min_nodes
  cluster_max_nodes  = var.cluster_max_nodes
  log_analytics_ws   = azurerm_log_analytics_workspace.aml_log_workspace.id

  tags = merge(local.tags, var.tags)
}

module "aml_workspace_3" {
  source             = "./azure-machine-learning/"
  region             = var.region
  suffix             = format("%s-%s", var.suffix, 3)
  stage              = var.stage
  notebook_size      = var.notebook_size
  cluster_size       = var.cluster_size
  notebook_stop      = var.notebook_stop
  cluster_min_nodes  = var.cluster_min_nodes
  cluster_max_nodes  = var.cluster_max_nodes
  log_analytics_ws   = azurerm_log_analytics_workspace.aml_log_workspace.id

  tags = merge(local.tags, var.tags)
}