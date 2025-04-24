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


##
resource "google_compute_router" "interconnect-router-secondary-a" {
  name    = "interconnect-router-secondary-a"
  network = module.landing-vpc.self_link
  project = module.landing-project.project_id
  region  = var.regions.secondary
  bgp {
    asn            = 16550
    advertise_mode = "CUSTOM"
    advertised_ip_ranges {
      range = "10.239.0.0/16"
    }
    advertised_ip_ranges {
      range = "199.36.153.8/30"
    }
    # advertised_ip_ranges {
    #   range = "35.199.192.0/19"
    # }
  }
}

resource "google_compute_router" "interconnect-router-secondary-b" {
  name    = "interconnect-router-secondary-b"
  network = module.landing-vpc.self_link
  project = module.landing-project.project_id
  region  = var.regions.secondary
  bgp {
    asn            = 16550
    advertise_mode = "CUSTOM"
    advertised_ip_ranges {
      range = "10.239.0.0/16"
    }
    advertised_ip_ranges {
      range = "199.36.153.8/30"
    }
    # advertised_ip_ranges {
    #   range = "35.199.192.0/19"
    # }
  }
}

module "rd-va-a-secondary-a" {
  source      = "../../../modules/net-vlan-attachment"
  network     = module.landing-vpc.self_link
  project_id  = module.landing-project.project_id
  region      = var.regions.secondary
  name        = "vlan-attachment-a-secondary-a"
  description = "interconnect-a-secondary vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-secondary-a.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  }
}

module "rd-va-b-secondary-a" {
  source      = "../../../modules/net-vlan-attachment"
  network     = module.landing-vpc.self_link
  project_id  = module.landing-project.project_id
  region      = var.regions.secondary
  name        = "vlan-attachment-b-secondary-a"
  description = "interconnect-b-secondary vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-secondary-a.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  }
}

module "rd-va-a-secondary-b" {
  source      = "../../../modules/net-vlan-attachment"
  network     = module.landing-vpc.self_link
  project_id  = module.landing-project.project_id
  region      = var.regions.secondary
  name        = "vlan-attachment-a-secondary-b"
  description = "interconnect-a-secondary vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-secondary-b.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  }
}

module "rd-va-b-secondary-b" {
  source      = "../../../modules/net-vlan-attachment"
  network     = module.landing-vpc.self_link
  project_id  = module.landing-project.project_id
  region      = var.regions.secondary
  name        = "vlan-attachment-b-secondary-b"
  description = "interconnect-b-secondary vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-secondary-b.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  }
}
