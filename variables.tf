variable "network_settings" {
  type = object({
      general = object({
          environment  = string
          owner        = string
          project_name = string
          region       = string
      })
      vpc = object({
          auto_create_subnetworks         = bool
          delete_default_routes_on_create = bool
      })
      bastion_subnet = object({
          ip_cidr_range            = string
          private_ip_google_access = bool
      })
      public_subnet = object({
          ip_cidr_range            = string
          private_ip_google_access = bool
      })
      private_subnet = object({
          ip_cidr_range            = string
          private_ip_google_access = bool
      })
  })
}