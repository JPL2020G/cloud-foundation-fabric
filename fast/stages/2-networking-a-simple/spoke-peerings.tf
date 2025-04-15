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

# tfdoc:file:description Peerings between landing and spokes.

module "peering-dev" {
  count         = local.spoke_connection == "peering" ? 1 : 0
  source        = "../../../modules/net-vpc-peering"
  prefix        = "dev-peering-0"
  local_network = module.dev-spoke-vpc.self_link
  peer_network  = module.landing-vpc.self_link
  routes_config = {
    local = {
      export        = var.spoke_configs.peering_configs.dev.export
      import        = var.spoke_configs.peering_configs.dev.import
      public_export = var.spoke_configs.peering_configs.dev.public_export
      public_import = var.spoke_configs.peering_configs.dev.public_import
    }
    peer = {
      export        = var.spoke_configs.peering_configs.dev.import
      import        = var.spoke_configs.peering_configs.dev.export
      public_export = var.spoke_configs.peering_configs.dev.public_import
      public_import = var.spoke_configs.peering_configs.dev.public_export
    }
  }
}

module "peering-prod" {
  count         = local.spoke_connection == "peering" ? 1 : 0
  source        = "../../../modules/net-vpc-peering"
  prefix        = "prod-peering-0"
  local_network = module.prod-spoke-vpc.self_link
  peer_network  = module.landing-vpc.self_link
  routes_config = {
    local = {
      export        = var.spoke_configs.peering_configs.prod.export
      import        = var.spoke_configs.peering_configs.prod.import
      public_export = var.spoke_configs.peering_configs.prod.public_export
      public_import = var.spoke_configs.peering_configs.prod.public_import
    }
    peer = {
      export        = var.spoke_configs.peering_configs.prod.import
      import        = var.spoke_configs.peering_configs.prod.export
      public_export = var.spoke_configs.peering_configs.prod.public_import
      public_import = var.spoke_configs.peering_configs.prod.public_export
    }
  }
  depends_on = [module.peering-dev]
}

module "stg-dev" {
  count         = local.spoke_connection == "peering" ? 1 : 0
  source        = "../../../modules/net-vpc-peering"
  prefix        = "stg-peering-0"
  local_network = module.stg-spoke-vpc.self_link
  peer_network  = module.landing-vpc.self_link
  routes_config = {
    local = {
      export        = var.spoke_configs.peering_configs.stg.export
      import        = var.spoke_configs.peering_configs.stg.import
      public_export = var.spoke_configs.peering_configs.stg.public_export
      public_import = var.spoke_configs.peering_configs.stg.public_import
    }
    peer = {
      export        = var.spoke_configs.peering_configs.stg.import
      import        = var.spoke_configs.peering_configs.stg.export
      public_export = var.spoke_configs.peering_configs.stg.public_import
      public_import = var.spoke_configs.peering_configs.stg.public_export
    }
  }
}

module "qa-dev" {
  count         = local.spoke_connection == "peering" ? 1 : 0
  source        = "../../../modules/net-vpc-peering"
  prefix        = "qa-peering-0"
  local_network = module.qa-spoke-vpc.self_link
  peer_network  = module.landing-vpc.self_link
  routes_config = {
    local = {
      export        = var.spoke_configs.peering_configs.qa.export
      import        = var.spoke_configs.peering_configs.qa.import
      public_export = var.spoke_configs.peering_configs.qa.public_export
      public_import = var.spoke_configs.peering_configs.qa.public_import
    }
    peer = {
      export        = var.spoke_configs.peering_configs.qa.import
      import        = var.spoke_configs.peering_configs.qa.export
      public_export = var.spoke_configs.peering_configs.qa.public_import
      public_import = var.spoke_configs.peering_configs.qa.public_export
    }
  }
}

module "poc-dev" {
  count         = local.spoke_connection == "peering" ? 1 : 0
  source        = "../../../modules/net-vpc-peering"
  prefix        = "poc-peering-0"
  local_network = module.poc-spoke-vpc.self_link
  peer_network  = module.landing-vpc.self_link
  routes_config = {
    local = {
      export        = var.spoke_configs.peering_configs.poc.export
      import        = var.spoke_configs.peering_configs.poc.import
      public_export = var.spoke_configs.peering_configs.poc.public_export
      public_import = var.spoke_configs.peering_configs.poc.public_import
    }
    peer = {
      export        = var.spoke_configs.peering_configs.poc.import
      import        = var.spoke_configs.peering_configs.poc.export
      public_export = var.spoke_configs.peering_configs.poc.public_import
      public_import = var.spoke_configs.peering_configs.poc.public_export
    }
  }
}