
# Deploying the `hello-kubernetes` App to AWS EKS

## How to Deploy and Verify, Step by Step

*Prerequisites:* Have the EKS cluster, Nginx Ingress Controller, and DNS configuration set up per the instructions in
the [root README.md](../README.md).

Change directory to `./k8s-examples` and apply/verify the Deployment, Service, and Ingress K8s configs:

    cd k8s-examples/
    kubectl apply -f hello-kubernetes-deployment.yml
    kubectl get deployment hello-kubernetes -n default
    kubectl apply -f hello-kubernetes-service.yml
    kubectl get service hello-kubernetes -n default
    kubectl apply -f hello-kubernetes-ingress.yml
    kubectl describe ingress -n default

Open the address in your browser and expect to be greeted with a "Hello world!" Kubernetes page (example URL
[works on my computer](https://mb-eks.smithmicro.io/hello-kubernetes/)):

    open https://mb-eks.smithmicro.io/hello-kubernetes/

And celebrate!
