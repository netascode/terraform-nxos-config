
locals {
  model_string = file("${path.module}/nxos_model.yaml")
  model        = yamldecode(local.model_string)
}

module "nxos_config" {
  source  = "netascode/config/nxos"
  version = ">= 0.0.1"

  model = local.model
}
