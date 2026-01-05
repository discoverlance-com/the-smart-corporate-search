resource "google_cloud_run_v2_service" "service" {
  name                = var.service_name
  project             = var.project_id
  location            = var.region
  description         = var.description
  deletion_protection = var.deletion_protection

  ingress = var.ingress

  invoker_iam_disabled = var.invoker_iam_disabled

  labels      = var.labels
  annotations = var.annotations

  dynamic "scaling" {
    for_each = var.scaling != null ? [var.scaling] : []
    content {
      min_instance_count    = scaling.value.min_instance_count
      max_instance_count    = scaling.value.max_instance_count
      scaling_mode          = scaling.value.scaling_mode
      manual_instance_count = scaling.value.manual_instance_count
    }
  }

  template {
    service_account = var.service_account

    dynamic "scaling" {
      for_each = var.template_scaling != null ? [var.template_scaling] : []
      content {
        min_instance_count = scaling.value.min_instance_count
        max_instance_count = scaling.value.max_instance_count
      }
    }

    timeout = var.timeout

    labels      = var.template_labels
    annotations = var.template_annotations

    # Execution environment
    execution_environment = var.execution_environment

    # Max concurrent requests per instance
    max_instance_request_concurrency = var.max_instance_request_concurrency

    # Session affinity
    session_affinity = var.session_affinity

    # Health check disabled
    health_check_disabled = var.health_check_disabled

    # VPC access configuration
    dynamic "vpc_access" {
      for_each = var.vpc_access != null ? [var.vpc_access] : []
      content {
        connector = vpc_access.value.connector
        egress    = vpc_access.value.egress

        # Direct VPC egress
        dynamic "network_interfaces" {
          for_each = vpc_access.value.network_interfaces != null ? vpc_access.value.network_interfaces : []
          content {
            network    = network_interfaces.value.network
            subnetwork = network_interfaces.value.subnetwork
            tags       = network_interfaces.value.tags
          }
        }
      }
    }

    # Containers
    dynamic "containers" {
      for_each = var.containers
      content {
        name        = containers.value.name
        image       = containers.value.image
        command     = containers.value.command
        args        = containers.value.args
        working_dir = containers.value.working_dir
        depends_on  = containers.value.depends_on

        dynamic "env" {
          for_each = containers.value.env != null ? containers.value.env : []
          content {
            name  = env.value.name
            value = env.value.value

            dynamic "value_source" {
              for_each = env.value.value_source != null ? [env.value.value_source] : []
              content {
                dynamic "secret_key_ref" {
                  for_each = value_source.value.secret_key_ref != null ? [value_source.value.secret_key_ref] : []
                  content {
                    secret  = secret_key_ref.value.secret
                    version = secret_key_ref.value.version
                  }
                }
              }
            }
          }
        }

        # Resource limits and requests
        dynamic "resources" {
          for_each = containers.value.resources != null ? [containers.value.resources] : []
          content {
            limits            = resources.value.limits
            cpu_idle          = resources.value.cpu_idle
            startup_cpu_boost = resources.value.startup_cpu_boost
          }
        }

        # Ports
        dynamic "ports" {
          for_each = containers.value.ports != null ? containers.value.ports : []
          content {
            name           = ports.value.name
            container_port = ports.value.container_port
          }
        }

        # Volume mounts
        dynamic "volume_mounts" {
          for_each = containers.value.volume_mounts != null ? containers.value.volume_mounts : []
          content {
            name       = volume_mounts.value.name
            mount_path = volume_mounts.value.mount_path
            sub_path   = volume_mounts.value.sub_path
          }
        }

        # Liveness probe
        dynamic "liveness_probe" {
          for_each = containers.value.liveness_probe != null ? [containers.value.liveness_probe] : []
          content {
            initial_delay_seconds = liveness_probe.value.initial_delay_seconds
            timeout_seconds       = liveness_probe.value.timeout_seconds
            period_seconds        = liveness_probe.value.period_seconds
            failure_threshold     = liveness_probe.value.failure_threshold

            dynamic "http_get" {
              for_each = liveness_probe.value.http_get != null ? [liveness_probe.value.http_get] : []
              content {
                path = http_get.value.path
                port = http_get.value.port

                dynamic "http_headers" {
                  for_each = http_get.value.http_headers != null ? http_get.value.http_headers : []
                  content {
                    name  = http_headers.value.name
                    value = http_headers.value.value
                  }
                }
              }
            }

            dynamic "grpc" {
              for_each = liveness_probe.value.grpc != null ? [liveness_probe.value.grpc] : []
              content {
                port    = grpc.value.port
                service = grpc.value.service
              }
            }

            dynamic "tcp_socket" {
              for_each = liveness_probe.value.tcp_socket != null ? [liveness_probe.value.tcp_socket] : []
              content {
                port = tcp_socket.value.port
              }
            }
          }
        }

        # Startup probe
        dynamic "startup_probe" {
          for_each = containers.value.startup_probe != null ? [containers.value.startup_probe] : []
          content {
            initial_delay_seconds = startup_probe.value.initial_delay_seconds
            timeout_seconds       = startup_probe.value.timeout_seconds
            period_seconds        = startup_probe.value.period_seconds
            failure_threshold     = startup_probe.value.failure_threshold

            dynamic "http_get" {
              for_each = startup_probe.value.http_get != null ? [startup_probe.value.http_get] : []
              content {
                path = http_get.value.path
                port = http_get.value.port

                dynamic "http_headers" {
                  for_each = http_get.value.http_headers != null ? http_get.value.http_headers : []
                  content {
                    name  = http_headers.value.name
                    value = http_headers.value.value
                  }
                }
              }
            }

            dynamic "grpc" {
              for_each = startup_probe.value.grpc != null ? [startup_probe.value.grpc] : []
              content {
                port    = grpc.value.port
                service = grpc.value.service
              }
            }

            dynamic "tcp_socket" {
              for_each = startup_probe.value.tcp_socket != null ? [startup_probe.value.tcp_socket] : []
              content {
                port = tcp_socket.value.port
              }
            }
          }
        }
      }
    }

    # Volumes
    dynamic "volumes" {
      for_each = var.volumes != null ? var.volumes : []
      content {
        name = volumes.value.name

        # Secret volume
        dynamic "secret" {
          for_each = volumes.value.secret != null ? [volumes.value.secret] : []
          content {
            secret       = secret.value.secret
            default_mode = secret.value.default_mode

            dynamic "items" {
              for_each = secret.value.items != null ? secret.value.items : []
              content {
                path    = items.value.path
                version = items.value.version
                mode    = items.value.mode
              }
            }
          }
        }

        # Cloud SQL instance volume
        dynamic "cloud_sql_instance" {
          for_each = volumes.value.cloud_sql_instance != null ? [volumes.value.cloud_sql_instance] : []
          content {
            instances = cloud_sql_instance.value.instances
          }
        }

        # Empty dir volume
        dynamic "empty_dir" {
          for_each = volumes.value.empty_dir != null ? [volumes.value.empty_dir] : []
          content {
            medium     = empty_dir.value.medium
            size_limit = empty_dir.value.size_limit
          }
        }
      }
    }
  }

  # Traffic configuration
  dynamic "traffic" {
    for_each = var.traffic != null ? var.traffic : []
    content {
      type     = traffic.value.type
      revision = traffic.value.revision
      percent  = traffic.value.percent
      tag      = traffic.value.tag
    }
  }
}

# Grant Cloud Run invoker role to specified members
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  for_each = toset(var.invoker_members)

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = each.value
}
