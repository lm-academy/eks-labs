# Expose a Workload Through an Application Load Balancer

Install the AWS Load Balancer Controller, give it an IAM identity through EKS Pod Identity, and turn an Ingress into an Application Load Balancer that routes on paths. Then route the same workloads through Gateway API, the successor to Ingress.

## The labs, in order

1. `labs/load-balancer-controller-install.md`: install the controller and give it an IAM identity.
2. `labs/ingress-and-alb.md`: write the Ingress that puts the workload behind an Application Load Balancer.
3. `labs/gateway-api-routing.md`: route two services through a Gateway the platform team owns, then retire the Ingress.

## What the folders contain

- **`starter/` is where you work.** `infra/` creates the cluster and installs the EKS Pod Identity Agent, and `k8s/` holds the workload manifests the labs hand you. The labs add files to both.
- **`solution/` is `starter/` with all three labs finished.** Compare your files against it, or copy from it to catch up. It holds files only, so the chart install and the Gateway API CRDs are not in it.

## Create the cluster

You need an AWS account, AWS CLI credentials, and an S3 bucket for Terraform state. Open the repository in its devcontainer, which pins every tool the labs use. Then, from the repository root:

```bash
cd load-balancer-controller/starter/infra
echo 'cluster_name = "lbc-lab"' > terraform.tfvars
terraform init -backend-config="bucket=your-state-bucket"
terraform apply
$(terraform output -raw update_kubeconfig_command)
kubectl get nodes
```

Any cluster name works. The state key is already set, so this cluster's state never mixes with another lab's. The apply takes about fifteen minutes, and two nodes reporting `Ready` means you can start.

## Clean up

The Gateway, the Ingress, and the `nginx-lb` Service created load balancers that Terraform does not know about, and deleting the objects is what removes them. Delete them before destroying the cluster, from `starter/`:

```bash
kubectl delete gateway public -n platform
kubectl delete ingress nginx --ignore-not-found
kubectl delete service nginx-lb --ignore-not-found
terraform -chdir=infra destroy
```

Skip the first line if you stopped before the Gateway API lab. A load balancer left behind keeps billing and stops the VPC from being deleted. The cluster bills for as long as it runs.
