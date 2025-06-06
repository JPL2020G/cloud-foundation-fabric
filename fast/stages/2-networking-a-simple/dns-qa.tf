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

# tfdoc:file:description QA spoke DNS zones and peerings setup.

# GCP-specific environment zone

module "qa-dns-priv-example" {
  source     = "../../../modules/dns"
  project_id = module.qa-spoke-project.project_id
  name       = "qa-gcp-rd-com-br"
  zone_config = {
    domain = "qa.gcp.rd.com.br."
    private = {
      client_networks = [module.qa-spoke-vpc.self_link]
    }
  }
  recordsets = {
    "A localhost" = { records = ["127.0.0.1"] }
  }
}

# root zone peering to landing to centralize configuration; remove if unneeded

module "qa-dns-peer-landing-root" {
  source     = "../../../modules/dns"
  project_id = module.qa-spoke-project.project_id
  name       = "qa-root-dns-peering"
  zone_config = {
    domain = "."
    peering = {
      client_networks = [module.qa-spoke-vpc.self_link]
      peer_network    = module.landing-vpc.self_link
    }
  }
}

module "qa-dns-peer-landing-rev-10" {
  source     = "../../../modules/dns"
  project_id = module.qa-spoke-project.project_id
  name       = "qa-reverse-10-dns-peering"
  zone_config = {
    domain = "10.in-addr.arpa."
    peering = {
      client_networks = [module.qa-spoke-vpc.self_link]
      peer_network    = module.landing-vpc.self_link
    }
  }
}
