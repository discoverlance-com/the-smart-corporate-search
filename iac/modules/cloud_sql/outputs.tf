output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.name
}

output "connection_name" {
  description = "The connection name for the Cloud SQL instance"
  value       = google_sql_database_instance.instance.connection_name
}

output "private_ip_address" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.public_ip_address
}

output "databases" {
  description = "Map of created databases"
  value = {
    for db_key, db in google_sql_database.databases : db_key => {
      name      = db.name
      charset   = db.charset
      collation = db.collation
      self_link = db.self_link
    }
  }
}

output "database_names" {
  description = "List of database names"
  value       = [for db in google_sql_database.databases : db.name]
}

output "iam_users" {
  description = "List of IAM members granted Cloud SQL Instance User access"
  value       = var.iam_users
}

output "iam_service_account_users" {
  description = "Map of created IAM service account SQL users"
  value = {
    for user_key, user in google_sql_user.iam_service_account_users : user_key => {
      name = user.name
      type = user.type
    }
  }
}

output "iam_sql_users" {
  description = "Map of created IAM SQL users"
  value = {
    for user_key, user in google_sql_user.iam_users : user_key => {
      name = user.name
      type = user.type
    }
  }
}

output "service_account_email" {
  description = "The service account email address assigned to the instance"
  value       = google_sql_database_instance.instance.service_account_email_address
}
