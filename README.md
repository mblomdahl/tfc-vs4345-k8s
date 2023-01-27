
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


### 3. Configure the AWS Elastic Block Storage for EKS

Configure persistent storage using EBS for EKS by following
the [Amazon EBS CSI Driver User Guide](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html), summarized below.

Modify the `./k8s-infra/aws-ebs-csi-driver-service-account.yaml` manifest by
replacing `"arn:aws:iam::878179636352:role/mb-eks-ebs-csi-driver-role"` with your own role ARN:

    echo $(terraform output -raw iam_aws_ebs_csi_driver_service_account_arn)

Apply the Kubernetes service account configuration for `ebs-csi-controller-sa` and the storage class manifest:

    kubectl apply -f k8s-infra/aws-ebs-csi-driver-service-account.yaml
    kubectl apply -f k8s-infra/aws-ebs-storageclass.yaml

Follow the steps in [./k8s-examples/ebs-storage/README.md](./k8s-examples/ebs-storage/README.md) to
verify that EBS persistent volumes and storage claims can be utilized in your cluster.


### 3. Configure the AWS Elastic File System Storage

Configure persistent storage using EFS for EKS by following
the [Amazon EFS CSI Driver User Guide](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html), summarized below.

Modify the `./k8s-infra/aws-efs-csi-driver-service-account.yaml` manifest by
replacing `"arn:aws:iam::878179636352:role/mb-eks-efs-csi-driver-role"` with your own role ARN:

    echo $(terraform output -raw iam_aws_efs_csi_driver_service_account_arn)

Apply the Kubernetes service account configuration for `efs-csi-controller-sa`:

    kubectl apply -f k8s-infra/aws-efs-csi-driver-service-account.yaml

Install the Amazon EFS driver using [Helm V3](https://docs.aws.amazon.com/eks/latest/userguide/helm.html) or later,
replacing `eu-north-1` with your region:

    helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver
    helm repo update
    helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
      --namespace kube-system \
      --set image.repository=602401143452.dkr.ecr.eu-north-1.amazonaws.com/eks/aws-efs-csi-driver \
      --set controller.serviceAccount.create=false \
      --set controller.serviceAccount.name=efs-csi-controller-sa

Identify the EFS filesystem ID:

    echo $(terraform output -raw efs_fs_id)

Modify the `./k8s-infra/aws-efs-storageclass.yaml` manifest by replacing `"fs-033a36bdf9a4002c5"` with
the filesystem ID from your environment and apply:

    kubectl apply -f k8s-infra/aws-efs-storageclass.yaml

Follow the steps in [./k8s-examples/efs-storage/README.md](./k8s-examples/efs-storage/README.md) to
verify that EFS persistent volumes and storage claims can be utilized in your cluster.


### 3. Configure the AWS Load Balancer Controller Add-On

Deploy the AWS Load Balancer Controller by following
the [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html),
summarized below.

Modify the `./k8s-infra/aws-load-balancer-controller-service-account.yaml` manifest by
replacing `"arn:aws:iam::878179636352:role/mb-eks-load-balancer-controller-role"` with your own role ARN:

    echo $(terraform output -raw iam_aws_load_balancer_service_account_arn)

Apply the Kubernetes service account configuration for `aws-load-balancer-controller`:

    kubectl apply -f k8s-infra/aws-load-balancer-controller-service-account.yaml

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


### 4. Deploy the Nginx Ingress Controller for Kubernetes and Verify

Deploy the Nginx Ingress Controller, "Option 1", by following the AWS
[External Access to Kubernetes](https://aws.amazon.com/premiumsupport/knowledge-center/eks-access-kubernetes-services/)
services guide, summarized in the following sections.

    kubectl apply -f k8s-infra/deploy-nginx-controller-with-ssl.yaml

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


### 9. Deploy Externally Accessible Kubernetes Resource

Follow the setup steps in [./k8s-examples/hello-kubernetes/README.md](./k8s-examples/hello-kubernetes/README.md) to
deploy the `hello-kubernetes` services and verify that it becomes accessible via the DNS pretty-names with SSL.
