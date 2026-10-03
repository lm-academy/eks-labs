terraform {
  # The bucket is passed at init: terraform init -backend-config="bucket=<your-bucket>"
  backend "s3" {
    key          = "eks-labs/external-secrets-operator/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
