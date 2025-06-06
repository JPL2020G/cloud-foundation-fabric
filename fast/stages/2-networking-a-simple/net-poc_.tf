/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# tfdoc:file:description POC spoke VPC and related resources.

# locals {
#   # streamline VPC configuration conditionals for modules by moving them here
#   poc_cfg = {
#     cloudnat    = var.vpc_configs.poc.cloudnat.enable == true
#     dns_logging = var.vpc_configs.poc.dns.enable_logging == true
#     dns_policy  = var.vpc_configs.poc.dns.create_inbound_policy == true
#     fw_classic  = var.vpc_configs.poc.firewall.use_classic == true
#     fw_order = (
#       var.vpc_configs.poc.firewall.policy_has_priority == true
#       ? "BEFORE_CLASSIC_FIREWALL"
#       : "AFTER_CLASSIC_FIREWALL"
#     )
#     fw_policy = var.vpc_configs.poc.firewall.create_policy == true
#   }
# }

# module "poc-spoke-project" {
#   source          = "../../../modules/project"
#   billing_account = var.billing_account.id
#   name            = "gcp-poc-net-prj-spoke-0" 
#   parent = coalesce(
#     var.folder_ids.networking-poc,
#     var.folder_ids.networking
#   )
#   prefix = var.prefix
#   services = [
#     "container.googleapis.com",
#     "compute.googleapis.com",
#     "dns.googleapis.com",
#     "iap.googleapis.com",
#     "networkmanagement.googleapis.com",
#     "networksecurity.googleapis.com",
#     "servicenetworking.googleapis.com",
#     "stackdriver.googleapis.com",
#     "vpcaccess.googleapis.com",
#     "vmwareengine.googleapis.com"
#   ]
#   shared_vpc_host_config = {
#     enabled = true
#   }
#   metric_scopes = [module.landing-project.project_id]
#   # optionally delegate a fixed set of IAM roles to selected principals
#   iam = {
#     (var.custom_roles.project_iam_viewer) = try(local.iam_viewer["poc"], [])
#   }
#   iam_bindings = (
#     lookup(local.iam_admin_delegated, "poc", null) == null ? {} : {
#       sa_delegated_grants = {
#         role    = "roles/resourcemanager.projectIamAdmin"
#         members = try(local.iam_admin_delegated["poc"], [])
#         condition = {
#           title       = "poc_stage3_sa_delegated_grants"
#           description = "${var.environments["poc"].name} host project delegated grants."
#           expression = format(
#             "api.getAttribute('iam.googleapis.com/modifiedGrantsByRole', []).hasOnly([%s])",
#             local.iam_delegated
#           )
#         }
#       }
#     }
#   )
#   # tag_bindings = local.has_env_folders ? {} : {
#   #   environment = local.env_tag_values["poc"]
#   # }
# }

# module "poc-spoke-vpc" {
#   source                          = "../../../modules/net-vpc"
#   project_id                      = module.poc-spoke-project.project_id
#   name                            = "gcp-poc-net-spoke-0" 
#   mtu                             = var.vpc_configs.poc.mtu
#   delete_default_routes_on_create = true
#   dns_policy = !local.poc_cfg.dns_policy ? {} : {
#     inbound = true
#     logging = local.poc_cfg.dns_logging
#   }
#   factories_config = {
#     context        = { regions = var.regions }
#     subnets_folder = "${var.factories_config.subnets}/poc"
#   }
#   firewall_policy_enforcement_order = local.poc_cfg.fw_order
#   psa_configs                       = var.psa_ranges.poc
#   routes = {
#     default = {
#       dest_range    = "0.0.0.0/0"
#       next_hop      = "default-internet-gateway"
#       next_hop_type = "gateway"
#       priority      = 1000
#     }
#   }
# }

# module "poc-spoke-firewall" {
#   source     = "../../../modules/net-vpc-firewall"
#   count      = local.poc_cfg.fw_classic ? 1 : 0
#   project_id = module.poc-spoke-project.project_id
#   network    = module.poc-spoke-vpc.name
#   default_rules_config = {
#     disabled = true
#   }
#   factories_config = {
#     cidr_tpl_file = var.factories_config.firewall.cidr_file
#     rules_folder  = "${var.factories_config.firewall.classic_rules}/poc"
#   }
# }

# module "poc-firewall-policy" {
#   source    = "../../../modules/net-firewall-policy"
#   count     = local.poc_cfg.fw_policy ? 1 : 0
#   name      = "poc-spoke-0"
#   parent_id = module.poc-spoke-project.project_id
#   region    = "global"
#   attachments = {
#     poc-spoke-0 = module.poc-spoke-vpc.id
#   }
#   factories_config = {
#     cidr_file_path          = var.factories_config.firewall.cidr_file
#     egress_rules_file_path  = "${var.factories_config.firewall.policy_rules}/poc/egress.yaml"
#     ingress_rules_file_path = "${var.factories_config.firewall.policy_rules}/poc/ingress.yaml"
#   }
#   security_profile_group_ids = var.security_profile_groups
# }

# module "poc-spoke-cloudnat" {
#   source = "../../../modules/net-cloudnat"
#   for_each = toset(
#     local.poc_cfg.cloudnat ? values(module.poc-spoke-vpc.subnet_regions) : []
#   )
#   project_id     = module.poc-spoke-project.project_id
#   region         = each.value
#   name           = "poc-nat-${local.region_shortnames[each.value]}"
#   router_create  = true
#   router_network = module.poc-spoke-vpc.name
#   logging_filter = "ERRORS_ONLY"
#   config_port_allocation = {
#     enable_endpoint_independent_mapping = false
#     enable_dynamic_port_allocation      = true
#     min_ports_per_vm                    = 32
#     max_ports_per_vm                    = 2048
#   }

# }
