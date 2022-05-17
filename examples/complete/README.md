<!-- BEGIN_TF_DOCS -->
# NX-OS OSPF Example

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

```hcl

locals {
  model_string = file("${path.module}/nxos_model.yaml")
  model        = yamldecode(local.model_string)
}

module "nxos_config" {
  source  = "netascode/config/nxos"
  version = ">= 0.0.1"

  model = local.model
}
```
<!-- END_TF_DOCS -->