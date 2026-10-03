# EKS Labs

Standalone hands-on labs for the Amazon EKS with Terraform course. Each folder is self-contained, with its own labs, its own cluster, and its own Terraform state, so you can start in any folder and destroy one cluster without touching another.

## The folders

- `external-secrets-operator/`: sync a secret from AWS Secrets Manager into a Kubernetes Secret with the External Secrets Operator.

## Inside a folder

```
external-secrets-operator/
  README.md    the order of the labs, and how to create and destroy the cluster
  labs/        one brief per lab, describing what to build
  starter/     where you work: a complete Terraform root with its own cluster, plus manifests
  solution/    starter/ with every lab in the folder finished
```

Open the folder's `README.md` first. It lists the labs in order and creates the cluster from `starter/infra`.

## Before you start

- An AWS account, credentials configured for the AWS CLI, and an existing S3 bucket for Terraform state. Each folder sets its own state key, so one bucket serves all of them.
- Docker plus VS Code with the Dev Containers extension. Open this repository's root in the devcontainer, which pins terraform, the AWS CLI, kubectl, and helm. To work without Docker, install the versions listed in `.tool-versions`.
- The AWS region is the `AWS_REGION` value in `.devcontainer/devcontainer.json`, set to `eu-central-1`. Change it there to work in a different region.

## Cost

Each folder's cluster bills for as long as it runs. Run `terraform destroy` from that folder's `starter/infra` when you finish.
