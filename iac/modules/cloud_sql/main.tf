# Cloud SQL instance with private networking
resource "google_sql_database_instance" "instance" {
  name             = var.instance_name
  project          = var.project_id
  region           = var.region
  database_version = var.database_version

  deletion_protection = var.deletion_protection

  settings {
    tier    = var.tier
    edition = var.edition

    # Enable IAM authentication
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    # Private IP configuration
    ip_configuration {
      ipv4_enabled                                  = var.ipv4_enabled
      private_network                               = var.private_network
      allocated_ip_range                            = var.allocated_ip_range
      enable_private_path_for_google_cloud_services = var.enable_private_path_for_google_cloud_services
      ssl_mode                                      = var.ssl_mode

      # Authorized networks for public access (if enabled)
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name            = authorized_networks.value.name
          value           = authorized_networks.value.value
          expiration_time = authorized_networks.value.expiration_time
        }
      }
    }

    # Availability type (REGIONAL for HA, ZONAL for single zone)
    availability_type = var.availability_type

    disk_size             = var.disk_size
    disk_type             = var.disk_type
    disk_autoresize       = var.disk_autoresize
    disk_autoresize_limit = var.disk_autoresize_limit

    # User labels
    user_labels = var.user_labels
  }
}

# Create databases
resource "google_sql_database" "databases" {
  for_each = var.databases

  name      = each.value.name
  project   = var.project_id
  instance  = google_sql_database_instance.instance.name
  charset   = each.value.charset
  collation = each.value.collation
}

# Grant Cloud SQL roles via IAM bindings
resource "google_project_iam_binding" "cloud_sql_instance_user" {
  count = length(var.iam_users) > 0 ? 1 : 0

  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  members = var.iam_users
}

resource "google_project_iam_binding" "cloud_sql_client" {
  count = length(var.iam_users) > 0 ? 1 : 0

  project = var.project_id
  role    = "roles/cloudsql.client"
  members = var.iam_users
}

# Create SQL IAM users for service accounts
resource "google_sql_user" "iam_service_account_users" {
  for_each = {
    for user in var.iam_users : user => user
    if startswith(user, "serviceAccount:")
  }

  # Database username must be the full email address in lowercase
  name = lower(replace(each.value, "serviceAccount:", ""))

  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project  = var.project_id
}

# Create SQL IAM users for regular users
resource "google_sql_user" "iam_users" {
  for_each = {
    for user in var.iam_users : user => user
    if startswith(user, "user:")
  }

  # Database username must be the full email address in lowercase
  name     = lower(replace(each.value, "user:", ""))
  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_USER"
  project  = var.project_id
}
