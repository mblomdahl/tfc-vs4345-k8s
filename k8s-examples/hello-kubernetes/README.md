
# Deploying the `hello-kubernetes` App to AWS EKS

## How to Deploy and Verify, Step by Step

*Prerequisites:* Have the EKS cluster, Nginx Ingress Controller, and DNS configuration set up per the instructions in
the [root README.md](../../README.md).

Change directory to `./k8s-examples/hello-kubernetes/` and apply/verify the Deployment, Service, and
Ingress K8s configs:

    cd k8s-examples/hello-kubernetes/
    kubectl apply -f hello-kubernetes-deployments.yml
    kubectl get deployments -n default

    kubectl apply -f hello-kubernetes-services.yml
    kubectl get services -n default

    kubectl apply -f hello-kubernetes-ingress.yml
    kubectl describe ingress -n default

Open the address in your browser and expect to be greeted with a "Hello world!" Kubernetes page with SSL encryption,
deployed on the `/hello-kubernetes/` path (example URL [works](https://eks.mabl.se/hello-kubernetes/)):

    open https://eks.mabl.se/hello-kubernetes/

Open the subdomain deployment address in your browser and again expect to be greeted with a "Hello world!" page with
SSL encryption and a slightly different title message:

    open https://hello-kubernetes.k8s.mabl.online/

Now go celebrate! :boom:
