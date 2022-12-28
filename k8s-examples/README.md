
# Deploying the `hello-kubernetes` App to AWS EKS

## How to Verify, Step by Step

*Prerequisites:* Have the Terraform CLI installed, ensure the EKS cluster is set up, configure `kubectl` to use it, and
have Helm installed.

Step 1, verify you have Helm available and can add a repo:

    helm version && helm repo add eks https://aws.github.io/eks-charts

Step 2, verify you can get the cluster name output via Terraform:

    export CLUSTER_NAME=$(terraform output -raw cluster_name) && echo $CLUSTER_NAME

Step 3, verify your Terraform cluster endpoint matches the `kubectl` config:

    kubectl cluster-info && echo "\\nControl plane URL matches '$(terraform output -raw cluster_endpoint)'? Good!"

Step 4, install the AWS Load Balancer Controller:

    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
      --set autoDiscoverAwsRegion=true \
      --set autoDiscoverAwsVpcID=true \
      --set clusterName=$CLUSTER_NAME

Step 5, apply the Deployment, Service, and Ingress K8s configs:

    kubectl apply -f hello-kubernetes-deployment.yml
    kubectl apply -f hello-kubernetes-service.yml
    kubectl apply -f hello-kubernetes-ingress.yml

Step 6, wait for the AWS Application Load Balancer to be configured and invoke _`kubectl describe`_ on it until
the _Address_ field is populated with an URL:

    kubectl describe ingress hello-kubernetes

Step 7, open the address in your browser and expect to be greeted with a "Hello world!" Kubernetes page (example URL,
[works on my computer](http://k8s-default-hellokub-119340f37d-1621773271.eu-north-1.elb.amazonaws.com)):

    open http://k8s-default-hellokub-119340f37d-1621773271.eu-north-1.elb.amazonaws.com


## Attributions

All of this is stolen from the [`learnk8s`/"Provisioning Kubernetes clusters on AWS with Terraform and EKS" guide](https://learnk8s.io/terraform-eks#testing-the-cluster-by-deploying-a-simple-hello-world-app),
thanks @k-mitevski!


## Contributing

Do you want to make this work with a secure and stylish `https://my-cool-app.domain.top` URL? Reach out to the owner and
let's get some mob programming going! Or open a ticket/issue pointing to how this integrates well with AWS Certificate
Manager and/or Route 53
