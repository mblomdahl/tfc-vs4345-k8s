
# Deploying the `hello-kubernetes` App Behind Vouch Proxy

## How to Deploy and Verify, Step by Step

*Prerequisites:* Have the EKS cluster, Nginx Ingress Controller, and DNS configuration set up per the instructions in
the [root README.md](../../README.md).

Change directory to `./k8s-examples/vouch-proxy/` and apply/verify the Deployment, Service, and
Ingress K8s configs:

    cd k8s-examples/vouch-proxy/
    kubectl apply -f 0-hello-kubernetes-resources.yml
    kubectl get deployment/hello-kubernetes -n spos
    kubectl get service/hello-kubernetes -n spos
    kubectl describe ingress/hello-kubernetes -n spos

Open the address in your browser and expect to be greeted with a "Hello world!" Kubernetes page with SSL encryption,
deployed on the `/hello-kubernetes/` path (example URL [works](https://eks.mabl.se/hello-kubernetes/)):

    open https://eks.mabl.se/hello-kubernetes/

Now let's add Vouch Proxy to the mix. First, follow the instructions
[here](https://kubernetes.github.io/ingress-nginx/examples/auth/oauth-external-auth/#example-vouch-proxy-kubernetes-dashboard)
to create a GitHub OAuth application. Update the `1-vouch-proxy-resources.yml` with the domain name, client ID and
client secret; then apply/verify the Vouch Proxy resources in Kubernetes:

    kubectl apply -f 1-vouch-proxy-resources.yml
    kubectl get deployment/vouch-proxy -n spos
    kubectl get service/vouch-proxy -n spos
    kubectl describe ingress/vouch-proxy -n spos

Finally, apply the updated `2-hello-kubernetes-ingress-update.yml` to include the Vouch Proxy annotations and
verify that you are now required to authorize a GitHub application called "`tfc-vs4345-k8s`" access to your profile
information, before you are redirected back to the _Hello Kubernetes_ app.

    kubectl apply -f 2-hello-kubernetes-ingress-update.yml
    kubectl describe ingress/hello-kubernetes -n spos
    open https://eks.mabl.se/hello-kubernetes/

Now go for Azure AD and Google Credentials! :boom:
