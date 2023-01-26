
# Terraform Cloud AWS EKS Setup

## What will This Do?

This Terraform configuration will setup a EKS cluster in your AWS account, then provision
a [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) for the Kubernetes
cluster and setup DNS names for it. Finally, it will deploy a couple of deplyoments exposed to the world via
the [Nginx Ingress Controller](https://aws.amazon.com/premiumsupport/knowledge-center/eks-access-kubernetes-services/).

## What are the Pre-Requisites?

You must have an AWS account and provide your AWS Access Key ID and AWS Secret Access Key to Terraform Cloud.
Terraform Cloud encrypts and stores variables using [Vault](https://www.vaultproject.io/). You must have the AWS
and Terraform CLIs installed on your local workstation.

The values for `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` should be saved as environment variables on
your workspace. For more information on how to store variables in Terraform Cloud,
see [our variable documentation](https://www.terraform.io/docs/cloud/workspaces/variables.html).

## Getting Started

### 1. Initialize the Base Infrastructure

1. Update the `./terraform.tf` to name your Terraform Cloud `organization` and `workspace` names
2. Update the `./variables.tf` to use your desired `resource_prefix`, and AWS `account_id` and `region`
3. Run `terraform init` in the repo root directory
4. Run `terraform plan && terraform apply` in the repo root and accept the proposed changes if they make sense to you
5. Open the AWS web console and verify your EKS cluster is up and looking good
6. Configure your `kubectl` command-line tool to use the new EKS cluster:

       export AWS_PROFILE=default
       export AWS_REGION=eu-north-1
       export CLUSTER_NAME=mb-eks-cluster
       aws --profile=$AWS_PROFILE eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

7. Verify your local configuration with `kubectl cluster-info`

### 2. Configure the AWS Load Balancer Controller Add-On

Deploy the AWS Load Balancer Controller by following
the [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html).

First create the `./iam-policies/eks-worker-policy.json` manifest:

    curl -o iam-policies/eks-worker-policy.json \
      https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json

Verify that the IAM policy manifest matches the version in Git (indentation ignored).

Then create the IAM policy if it does not already exist (replacing `AWS_PROFILE` export with what matches your locals):

    export AWS_PROFILE=default
    aws --profile=$AWS_PROFILE iam create-policy \
      --policy-name AWSLoadBalancerControllerIAMPolicy \
      --policy-document file://iam-policies/eks-worker-policy.json

Prepare for creating a Kubernetes service account named `aws-load-balancer-controller` in the `kube-system` namespace:

    # Ensure output matches expectation
    export CLUSTER_NAME=$(terraform output -raw cluster_name) && echo $CLUSTER_NAME

    # Ensure output matches expectation
    export OIDC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" \
      --output text | cut -d '/' -f 5) && echo $OIDC_ID

    # Expect output to show the OIDC_ID followed by a trailing "
    aws iam list-open-id-connect-providers | grep $OIDC_ID | cut -d "/" -f4

Review the `./iam-policies/load-balancer-role-trust-policy.json` manifest, replace account ID `878179636352` with
your own account number, `B498DC54986685B28E8A1F146AC30099` with your own OIDC ID, and `eu-north-1` with your own region
and create the IAM role (and replacing `AWS_PROFILE` export with what matches your locals):

    export AWS_PROFILE=default
    aws --profile=$AWS_PROFILE iam create-role \
      --role-name AmazonEKSLoadBalancerControllerRole \
      --assume-role-policy-document file://"iam-policies/load-balancer-role-trust-policy.json"

Attach the IAM policy to the IAM role, replacing account ID `878179636352` with your own account number:

    export AWS_PROFILE=default
    aws --profile=$AWS_PROFILE iam attach-role-policy \
      --policy-arn arn:aws:iam::878179636352:policy/AWSLoadBalancerControllerIAMPolicy \
      --role-name AmazonEKSLoadBalancerControllerRole

Review the `./iam-policies/aws-load-balancer-controller-service-account.yaml` manifest and replace account ID
`878179636352` with your own account number and apply on your Kubernetes cluster:

     kubectl apply -f iam-policies/aws-load-balancer-controller-service-account.yaml

Install the AWS Load Balancer Controller using [Helm V3](https://docs.aws.amazon.com/eks/latest/userguide/helm.html) or
later by applying the Kubernetes manifest:

    # Ensure output matches expectation
    export CLUSTER_NAME=$(terraform output -raw cluster_name) && echo $CLUSTER_NAME

    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
      -n kube-system \
      --set clusterName=$CLUSTER_NAME \
      --set serviceAccount.create=false \
      --set serviceAccount.name=aws-load-balancer-controller

Verify that the controller is installed:

    kubectl get deployment -n kube-system aws-load-balancer-controller

Example success output:

    kubectl get deployment -n kube-system aws-load-balancer-controller
    "NAME                           READY   UP-TO-DATE   AVAILABLE   AGE"
    "aws-load-balancer-controller   2/2     2            2           22h"

### 3. Deploy the Nginx Ingress Controller for Kubernetes

Deploy the Nginx Ingress Controller, "Option 1", by following the AWS
[External Access to Kubernetes](https://aws.amazon.com/premiumsupport/knowledge-center/eks-access-kubernetes-services/)
services guide.

    kubectl apply -f k8s-infra/deploy-nginx-controller-with-ssl.yaml

### 4. Verify the Deployed Resources

Verify that the AWS Load Balancer Controller is running:

    kubectl get all -n kube-system --selector app.kubernetes.io/instance=aws-load-balancer-controller

Verify that the Nginx Ingress Controller is running:

    kubectl get all -n ingress-nginx --selector app.kubernetes.io/instance=ingress-nginx

Verify that your Kubernetes cluster have ingress classes `alb` and `nginx`:

    kubectl get ingressclass

### 5. Configure DNS with Route53

Get the AWS Load Balancer Endpoint created by the Nginx Ingress Controller:

    kubectl describe -n ingress-nginx service ingress-nginx-controller | grep Ingress | cut -d':' -f2 | xargs

Example:

    "k8s-ingressn-ingressn-d7a33e1924-2dcfed4179033b4a.elb.eu-north-1.amazonaws.com"

Find the matching load balancer in the AWS Web Console under
[EC2 > Load Balancers](https://eu-north-1.console.aws.amazon.com/ec2/home?region=eu-north-1#LoadBalancers) and
copy the _Hosted Zone ID_ from the details' view, a string that looks something like `"Z1UDT6IFJ4EJM"`.

Open the [Route 53 > Hosted Zones](https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones#) view in the AWS Web
Console and copy the _Hosted Zone ID_ from your apex domain hosted zone, something like `"Z1TY55FUWSMGVV"`.

Modify the `./dns/variables.tf` config file by replacing the default value for `eks_elb_domain` and `eks_elb_zone_id`
with the Load Balancer Endpoint and Load Balancer Hosted Zone ID, and replacing `route53_apex_zone_id` with the
Apex Domain Hosted Zone ID.

Change directory to `./dns` and apply the Terraform configuration:

    cd dns/
    terraform init
    terraform plan
    terraform apply

### 6. Verify the DNS Setup

Verify that `nslookup` returns 2 records for `mb-eks.smithmicro.io`:

    nslookup mb-eks.smithmicro.io

Verify that `curl` receives a Nginx 404 response:

    curl -v http://mb-eks.smithmicro.io

### 7. Install Cert-Manager in EKS

Install Cert-Manager using Helm:

    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install cert-manager jetstack/cert-manager \
      --namespace cert-manager \
      --create-namespace \
      --set installCRDs=true

### 8. Configure Certificate Issuer

Modify the `./k8s-infra/letsencrypt-issuer.yaml` config file by adding your own email address, and apply:

    kubectl apply -f k8s-infra/letsencrypt-issuers.yaml

### 9. Deploy a Kubernetes Resource

Follow the setup steps in [./k8s-examples/README.md](./k8s-examples/README.md) to deploy your service and
verify that it becomes accessible via the DNS pretty-name.
