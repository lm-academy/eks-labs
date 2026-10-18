# Lab: Route to the Workload with an Ingress

## Goal

Put the running workload behind an Application Load Balancer by writing one Ingress. The controller is already installed and watching, so you write a single Kubernetes object and the controller builds the load balancer from it. By the end the nginx page loads over the internet on a load balancer that routes on paths.

## Starting point

The cluster with the Load Balancer Controller running in `kube-system` and holding a working IAM identity. The nginx Deployment and its ClusterIP Service are applied. A Classic Load Balancer from the earlier LoadBalancer Service is still running, and you leave it alone. You work in `starter/`.

## Configuration to target

- **New file `k8s/ingress.yaml`:** an Ingress named `nginx` in the `default` namespace, beside the workload, with `ingressClassName: alb`. The chart created that IngressClass, and an Ingress without a class is ignored.
- **The scheme:** `internet-facing`, set with the scheme annotation, so the load balancer is placed in the public subnets.
- **The target type:** `ip`, set with the target-type annotation, so the targets are pod addresses. The controller's default, `instance`, routes through a node port and a second hop.
- **The health check path:** `/`, which the workload serves, since health checks reach the pods directly.
- **The rule:** one path, `/` with `pathType: Prefix`, sending every request to the `nginx` Service on port 80.

## Tasks

1. **Write the Ingress.** One object with the class, the three annotations, and a single path rule.
2. **Apply it and wait for the address.** The `ADDRESS` column fills within seconds, and the page takes a few minutes longer to answer.
3. **Load the page and confirm what AWS built.** Open the address in a browser, then confirm AWS reports an internet-facing Application Load Balancer and Terraform reports no changes.

## Done when

- `kubectl get ingress nginx` shows an `ADDRESS`, and that address serves the nginx welcome page over HTTP.
- AWS reports one Application Load Balancer, `internet-facing` and `active`.
- Nothing in `infra/` changed, and `terraform plan` reports no differences.

## Note

The `ADDRESS` appears within seconds and the page starts answering after three to five minutes. Most of that gap is the load balancer itself: it reports `provisioning` for about two minutes, and its new name takes up to another minute to resolve. An address that serves nothing yet is the normal state during that wait.

If the `ADDRESS` column never fills, the controller's logs hold the reason and it is usually one of two things. Subnet discovery failed, meaning the tags it looks for are missing or point at another cluster. Or an AWS call was refused, meaning the controller's identity is not reaching its pod. If the address answers with `502` or `503` long after the wait, the targets are failing their health checks, and the health check path is the first thing to compare against what the pods serve.

The load balancer bills from the moment it is created, 2.7 cents an hour in Frankfurt plus 0.8 cents per capacity unit hour, and half a cent an hour for each of its two public addresses. Terraform does not know it exists. Deleting the Ingress is what removes it, so delete it before destroying the cluster.
