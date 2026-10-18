terraform {
  # The bucket is passed at init: terraform init -backend-config="bucket=<your-bucket>"
  backend "s3" {
    key          = "eks-labs/load-balancer-controller/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
