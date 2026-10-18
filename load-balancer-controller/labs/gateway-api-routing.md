# Lab: Gateway API Routing

## Goal

Route the workloads through Gateway API, the successor to the frozen Ingress API. The platform team owns a Gateway and decides which namespaces may attach routes to it. The application team attaches one HTTPRoute that sends `/` to nginx and `/echo` to a second service. The controller builds one Application Load Balancer for both paths. By the end both paths answer on the Gateway's hostname, and the Ingress is gone with its load balancer.

## Starting point

The cluster with the Load Balancer Controller running in `kube-system`, and the `nginx` Ingress serving the page through its own Application Load Balancer. You work in `starter/`.

## Provided files

- `k8s/echo.yaml`: a second service, a Deployment and a ClusterIP Service named `echo`, which answers every request with the word `echo`.

## Configuration to target

- **The Gateway API CRDs:** the standard channel of release `v1.6.3`, applied server-side from `https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.3/standard-install.yaml`.
- **The controller:** restarted once the CRDs exist, since it checks for them only when it starts.
- **New file `k8s/gateway.yaml`:** everything the platform team owns, in the order below.
- **The platform namespace:** `platform`, holding every namespaced object in `k8s/gateway.yaml`.
- **The GatewayClass:** `aws-alb`, with the controller name `gateway.k8s.aws/alb`.
- **The target settings:** a TargetGroupConfiguration named `ip-targets` that sets the target type to `ip` and names no Service, so it serves as a default.
- **The load balancer settings:** a LoadBalancerConfiguration named `public` with the scheme `internet-facing` and `ip-targets` as its default target group configuration.
- **The Gateway:** `public`, of class `aws-alb`, pointing at the LoadBalancerConfiguration through `infrastructure.parametersRef`. One HTTP listener on port 80 admits routes only from namespaces labelled `gateway-access=public`.
- **The namespace label:** `gateway-access=public` on `default`, where both workloads run.
- **New file `k8s/httproute.yaml`:** an HTTPRoute named `web` in `default`, attached to the Gateway `public` in `platform`. The path prefix `/echo` goes to the `echo` Service on port 80, and the path prefix `/` goes to `nginx` on port 80.

## Tasks

1. **Install the Gateway API.** Apply the CRDs and restart the controller.
2. **Write the platform's Gateway.** Apply `k8s/gateway.yaml` and wait for the Gateway's address.
3. **Attach the application's route.** Apply the `echo` workload, label `default`, and apply `k8s/httproute.yaml`. Load `/` and `/echo` on the Gateway's address.
4. **Retire the Ingress.** Delete the `nginx` Ingress, and confirm the account holds one Application Load Balancer, the Gateway's.

## Done when

- `kubectl get gatewayclass aws-alb` shows `ACCEPTED` as `True`, and `kubectl -n platform get gateway public` shows `PROGRAMMED` as `True` with an address.
- The HTTPRoute `web` reports the condition `Accepted` for the Gateway `public`.
- `/` on the Gateway's address serves the nginx page, and `/echo` on the same address answers `echo`.
- `aws elbv2 describe-load-balancers` lists one Application Load Balancer, and its target groups use the target type `ip`.

## Note

A Gateway's load balancer is internal unless its LoadBalancerConfiguration sets `internet-facing`. The controller's default target type is `instance`. The TargetGroupConfiguration makes the pods themselves the targets, as the Ingress's annotation did.

The listener decides who may attach. A route from a namespace without the label is refused with the reason `NotAllowedByListeners`, so attaching to the Gateway takes the platform team's consent, given per namespace.

The Gateway and the route are Kubernetes objects, not Terraform resources. Deleting the Gateway is what removes its load balancer, so delete it before destroying the cluster.

The Gateway's load balancer bills like the Ingress's: 2.7 cents an hour in Frankfurt plus 0.8 cents per capacity unit hour, and half a cent an hour for each of its two public addresses. Retiring the Ingress leaves one load balancer serving both services.
