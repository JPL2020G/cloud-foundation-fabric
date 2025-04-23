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

# tfdoc:file:description VPN between landing and onprem.

resource "google_compute_router" "interconnect-router" {
  name    = "landing-interconnect-router"
  network = module.landing-vpc.self_link
  project = module.landing-project.project_id
  region  = var.regions.secondary
  bgp {
    advertise_mode = "CUSTOM"
    asn            = 64514
    advertised_ip_ranges {
      range = "10.239.0.0/16"
    }
  }
}

# cliente deve primeiro provisionar uma interconexão no GCP 
# module "landing-va" {
#   source      = "../../../modules/net-vlan-attachment"
#   network     = module.landing-vpc.self_link
#   project_id  = module.landing-project.project_id
#   region      = var.regions.secondary
#   name        = "landing-vlan-attachment"
#   description = "landing vlan attachment"
#   peer_asn    = "65000"
#   router_config = {
#     create = false
#     name   = google_compute_router.interconnect-router.name
#   }
#   dedicated_interconnect_config = {
#     # cloud router gets 169.254.0.1 peer router gets 169.254.0.2
#     bandwidth    = "BPS_10G"
#     bgp_range    = "169.254.0.0/29"
#     interconnect = "https://www.googleapis.com/compute/v1/projects/my-project/global/interconnects/interconnect-a"
#     vlan_tag     = 4093
#   }
# }
# # 
