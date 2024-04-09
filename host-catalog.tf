# Create a Static Host Catalog called DevOps for targets to be associated with.
resource "boundary_host_catalog_static" "devops" {
  name        = "DevOps"
  description = "For DevOps Team"
  scope_id    = boundary_scope.project.id
}

# Creates a dynamic host catalog for AWS
resource "boundary_host_catalog_plugin" "aws_plugin" {
  name        = "AWS Catalogue"
  description = "AWS Host Catalogue"
  scope_id    = boundary_scope.project.id
  plugin_name = "aws"
  attributes_json = jsonencode({
    "region" = "eu-west-2",
  "disable_credential_rotation" = true })


  secrets_json = jsonencode({
    "access_key_id"     = var.aws_access,
    "secret_access_key" = var.aws_secret
  })
}

resource "boundary_host_catalog_plugin" "azure_plugin" {
  name        = "Azure Catalogue"
  description = "Azure host catalogue"
  scope_id    = boundary_scope.project.id
  plugin_name = "azure"
  attributes_json = jsonencode({
    "disable_credential_rotation" = true,
    "tenant_id"                   = var.arm_tenant_id,
    "subscription_id"             = var.arm_subscription_id,
    "client_id"                   = var.arm_client_id
  })
  secrets_json = jsonencode({
    "secret_value" = var.arm_client_secret
  })
}
