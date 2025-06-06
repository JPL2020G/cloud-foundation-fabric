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

# tfdoc:file:description Production spoke DNS zones and peerings setup.

# GCP-specific environment zone

module "prod-dns-private-zone" {
  source     = "../../../modules/dns"
  project_id = module.prod-spoke-project.project_id
  name       = "prod-gcp-example-com"
  zone_config = {
    domain = "prod.gcp.example.com."
    private = {
      client_networks = [module.prod-spoke-vpc.self_link]
    }
  }
  recordsets = {
    "A localhost" = { records = ["127.0.0.1"] }
  }
}

module "prod-dns-fwd-onprem-example" {
  source     = "../../../modules/dns"
  count      = length(var.dns.prod_resolvers) > 0 ? 1 : 0
  project_id = module.prod-spoke-project.project_id
  name       = "example-com"
  zone_config = {
    domain = "onprem.example.com."
    forwarding = {
      client_networks = [module.prod-spoke-vpc.self_link]
      forwarders      = { for ip in var.dns.prod_resolvers : ip => null }
    }
  }
}

module "prod-dns-fwd-onprem-rev-10" {
  source     = "../../../modules/dns"
  count      = length(var.dns.prod_resolvers) > 0 ? 1 : 0
  project_id = module.prod-spoke-project.project_id
  name       = "root-reverse-10"
  zone_config = {
    domain = "10.in-addr.arpa."
    forwarding = {
      client_networks = [module.prod-spoke-vpc.self_link]
      forwarders      = { for ip in var.dns.prod_resolvers : ip => null }
    }
  }
}

# Google APIs
# the zone fixes issues with missing MX/SRV records when forwarding onprem

module "prod-dns-priv-googleapis" {
  source     = "../../../modules/dns"
  project_id = module.prod-spoke-project.project_id
  name       = "googleapis-com"
  zone_config = {
    domain = "googleapis.com."
    private = {
      client_networks = [module.prod-spoke-vpc.self_link]
    }
  }
}

module "prod-dns-policy-googleapis" {
  source     = "../../../modules/dns-response-policy"
  project_id = module.prod-spoke-project.project_id
  name       = "googleapis"
  factories_config = {
    rules = var.factories_config.dns_policy_rules
  }
  networks = {
    prod = module.prod-spoke-vpc.self_link
  }
}
