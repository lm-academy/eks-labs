# Lab: Install the Load Balancer Controller

## Goal

Give the cluster a controller that can turn an Ingress into an Application Load Balancer. The controller is an ordinary pod that calls AWS, so most of the work is the IAM identity it runs as: a published permissions policy, a role, and the Pod Identity association binding that role to the service account the chart creates. The install itself is one command. By the end the controller is running and watching, and the only load balancer in the account is the one the cluster made on its own beforehand.

## Starting point

The cluster from this lab's `starter/` folder, applied, with `kubectl get nodes` showing two nodes `Ready`. If you have not applied it yet, the lab's README walks through it, and the apply takes about fifteen minutes. The starter also runs the EKS Pod Identity Agent, which the controller needs to receive an IAM role. You work in `starter/`: Terraform files go into `infra/`, beside `cluster.tf`.

## Provided files

- `k8s/nginx.yaml`: a Deployment and a ClusterIP Service. Apply it now, so there is something to route to later.
- `k8s/nginx-loadbalancer.yaml`: a Service of type LoadBalancer for the same Deployment. You apply this before installing anything, and you leave it running.

## Configuration to target

- **New file `infra/lb_controller.tf`:** the controller's permissions policy, its role, and the association.
- **The permissions policy:** the file the project publishes with release `v3.6.2`, at `https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v3.6.2/docs/install/iam_policy.json`, saved as `infra/policies/aws-load-balancer-controller.json` and turned into a customer managed policy as published.
- **Who may assume the role (trust):** the service `pods.eks.amazonaws.com`, allowed `sts:AssumeRole` and `sts:TagSession`.
- **Role and policy name:** the cluster name followed by `-aws-load-balancer-controller`.
- **The association:** namespace `kube-system`, service account `aws-load-balancer-controller`.
- **The Load Balancer Controller Helm chart:** Repository `https://aws.github.io/eks-charts`, chart `eks/aws-load-balancer-controller`, version `3.6.2`, release name `aws-load-balancer-controller` in namespace `kube-system`. Pass your cluster name, and set the service account name explicitly so it matches the association.

## Tasks

1. **Expose the workload the way the cluster already allows.** Apply the provided objects, wait for the LoadBalancer Service's address, and load the page. AWS built a Classic Load Balancer for it, and it stays running.
2. **Vendor the permissions policy.** Download the published file into `infra/policies/`.
3. **Write the policy, the role, and the association.** The managed policy from the file, the trust policy, the role, the attachment, and the association naming a service account that does not exist yet. Apply, then confirm from AWS that the association exists.
4. **Install the controller.** Add the chart repository, install the pinned version into `kube-system`, and confirm the Deployment is ready.

## Done when

- `terraform apply` completes and `terraform validate` reports the configuration is valid.
- AWS lists one Pod Identity association for the cluster, targeting `kube-system` and `aws-load-balancer-controller`.
- The controller Deployment reports its replicas ready in `kube-system`.
- The account still holds the Classic Load Balancer from the first task.

## Note

The association is created before the service account exists. EKS takes both names as plain strings and checks neither, so a typo applies cleanly and grants nothing. If the controller behaves as though it has no permissions, compare those two strings against the chart's service account before suspecting the policy.

The published policy grants a lot, across load balancing, EC2 networking, certificates, and integrations this cluster will never use. That breadth is real: anyone who can create an Ingress here can cause a billed, internet-facing load balancer to exist.

The controller runs on nodes you already pay for. The Classic Load Balancer from the first task bills 3 cents an hour in Frankfurt plus 0.8 cents per GB it processes, and Terraform did not create it and will not remove it. Deleting that Service is what removes it.
