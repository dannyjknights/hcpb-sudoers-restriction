# Create an organisation scope within global, named "ops-org"
# The global scope can contain multiple org scopes
resource "boundary_scope" "org" {
  scope_id                 = "global"
  name                     = "terraform-org"
  description              = "Support Ops Team"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

/* Create a project scope within the "ops-org" organsiation
Each org can contain multiple projects and projects are used to hold
infrastructure-related resources
*/
resource "boundary_scope" "project" {
  name                     = "ops_production"
  description              = "Manage Prod Resources"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

# Create a User with sudo privileges on Boundary when accessing target
resource "boundary_auth_method" "password" {
  scope_id = boundary_scope.org.id
  type     = "password"
}

resource "boundary_account_password" "admin" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "admin"
  password       = "password"
}

resource "boundary_user" "admin" {
  name        = "admin"
  description = "Admin's user resource"
  account_ids = [boundary_account_password.admin.id]
  scope_id    = boundary_scope.org.id
}


resource "boundary_role" "admin" {
  name          = "Admin"
  description   = "An Admin role"
  principal_ids = [boundary_user.admin.id]
  grant_strings = ["ids=*;type=*;actions=*"]
  scope_id      = boundary_scope.org.id
}

resource "boundary_role" "ops-admin" {
  name          = "Admin"
  description   = "An Admin role in ops project"
  principal_ids = [boundary_user.admin.id]
  grant_strings = ["ids=*;type=*;actions=*"]
  scope_id      = boundary_scope.project.id
}
