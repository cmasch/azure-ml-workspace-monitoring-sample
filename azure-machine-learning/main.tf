resource "azurerm_resource_group" "amlworkspace_rg" {
  name     = format("rg-aml-workspace-%s-%s", var.stage, var.suffix)
  location = var.region
  tags     = var.tags
}

resource "azurerm_application_insights" "amlworkspace_analytics_insights" {
  name                = format("ai-amlworkspace-%s", var.suffix)
  location            = azurerm_resource_group.amlworkspace_rg.location
  resource_group_name = azurerm_resource_group.amlworkspace_rg.name
  application_type    = "web"
  workspace_id        = var.log_analytics_ws
  
  tags = var.tags
}

resource "azurerm_container_registry" "amlworkspace_container_registry" {
  name                          = format("acramlworkspace%s", replace(var.suffix, "-", ""))
  resource_group_name           = azurerm_resource_group.amlworkspace_rg.name
  location                      = azurerm_resource_group.amlworkspace_rg.location
  sku                           = "Premium"
  admin_enabled                 = true
  public_network_access_enabled = true

  tags = var.tags
}

resource "azurerm_key_vault" "amlworkspace_key_vault" {
  name                = format("kvamlworkspace%s", replace(var.suffix, "-", ""))
  location            = azurerm_resource_group.amlworkspace_rg.location
  resource_group_name = azurerm_resource_group.amlworkspace_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  tags = var.tags
}

resource "azurerm_storage_account" "amlworkspace_storage" {
  name                     = format("stamlworkspace%s", replace(var.suffix, "-", ""))
  location                 = azurerm_resource_group.amlworkspace_rg.location
  resource_group_name      = azurerm_resource_group.amlworkspace_rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = var.tags
}

resource "azurerm_machine_learning_workspace" "aml_workspace" {
  name                    = format("aml-workspace-%s", var.suffix)
  location                = azurerm_resource_group.amlworkspace_rg.location
  resource_group_name     = azurerm_resource_group.amlworkspace_rg.name
  application_insights_id = azurerm_application_insights.amlworkspace_analytics_insights.id
  key_vault_id            = azurerm_key_vault.amlworkspace_key_vault.id
  storage_account_id      = azurerm_storage_account.amlworkspace_storage.id
  container_registry_id   = azurerm_container_registry.amlworkspace_container_registry.id
  
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

resource "azurerm_machine_learning_compute_cluster" "ml_cluster" {
  name                          = format("cpu-cluster-%s", var.suffix)
  location                      = azurerm_resource_group.amlworkspace_rg.location
  vm_priority                   = "LowPriority"
  vm_size                       = var.cluster_size
  machine_learning_workspace_id = azurerm_machine_learning_workspace.aml_workspace.id

  scale_settings {
    min_node_count                       = var.cluster_min_nodes
    max_node_count                       = var.cluster_max_nodes
    scale_down_nodes_after_idle_duration = "PT5M"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_machine_learning_compute_instance" "ml_instance" {
  name                          = format("ml-notebook-%s", replace(var.suffix, "-", ""))
  location                      = azurerm_resource_group.amlworkspace_rg.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.aml_workspace.id
  virtual_machine_size          = var.notebook_size
  authorization_type            = "personal"

  tags = var.tags
}

resource "null_resource" "azurecli_stop_notebook" {
  count = var.notebook_stop ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
    command     = <<EOT
      az ml compute stop --name $notebookName --workspace-name $amlWorkspace --resource-group $amlRg
    EOT
    
    environment = {
      notebookName = azurerm_machine_learning_compute_instance.ml_instance.name
      amlWorkspace = azurerm_machine_learning_workspace.aml_workspace.name
      amlRg = azurerm_resource_group.amlworkspace_rg.name
    }
  }
}


# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "aml_diagnostic" {
  name                       = format("diagnostic-%s", var.suffix)
  target_resource_id         = azurerm_machine_learning_workspace.aml_workspace.id
  log_analytics_workspace_id = var.log_analytics_ws

  log {
    category = "AmlComputeClusterEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "AmlComputeClusterNodeEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "AmlComputeJobEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "AmlComputeCpuGpuUtilization"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "AmlRunStatusChangedEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "ComputeInstanceEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "DataLabelChangeEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "DataLabelReadEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "DataSetChangeEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "DataSetReadEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "DataStoreChangeEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "DataStoreReadEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "DeploymentEventACI"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "DeploymentEventAKS"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "DeploymentReadEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "EnvironmentChangeEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "EnvironmentReadEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "InferencingOperationACI"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "InferencingOperationAKS"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "ModelsActionEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "ModelsChangeEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "ModelsReadEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "PipelineChangeEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "PipelineReadEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "RunEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "RunReadEvent"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  metric {
    category = "AllMetrics"

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}