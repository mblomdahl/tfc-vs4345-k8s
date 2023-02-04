
# Deploying the `vs-studio` App to AWS EKS and RDS

*Prerequisites:* Have the EKS cluster, Nginx Ingress Controller, DNS configuration, and ACK Service Controllers for
RDS/S3 set up per the instructions in the [root README.md](../../README.md).

## 1. Create the App Namespace and Database Credentials

Change directory to `./k8s-examples/vs-studio/`, modify the `0-infra.yml` manifest by replacing `"eu-north-1"`
with your own region and create the namespace `"vs"`:

    cd k8s-examples/vs-studio/
    kubectl apply -f 0-infra.yml

Create a secret with the database credentials:

    export RDS_DB_PASSWORD="yourOwnSecurePassword"
    kubectl create secret generic -n vs \
      studio-postgres-password \
      --from-literal=password="${RDS_DB_PASSWORD}"


## 2. Create the RDS Postgres Database and S3 Bucket

Modify the `1-database.yml` by replacing the database subnet group name `"mb-eks-rds-subnet-group"` with your
own group name:

    cd ../../
    echo $(terraform output -raw ack_rds_database_subnet_group_name)
    cd k8s-examples/vs-studio/

Apply the database manifest and the field export of connection parameters into the `studio-postgres-conn` config map:

    kubectl apply -f 1-database.yml

Track the status of RDS database creation:

    kubectl describe -n vs dbinstance studio-postgres

Modify the `2-bucket.yml` by replacing `"mb-eks-vs-studio"` with your own S3 bucket name and
apply the field export of bucket name into the `studio-s3-bucket` config map:

    kubectl apply -f 2-bucket.yml

Track the status of S3 bucket creation:

    kubectl describe -n vs bucket studio-s3-bucket


## 3. Create Secrets and ConfigMaps for the Application

Review the values in `3-studio-config-maps.yml` config maps and adjust it to fit your deployment, then apply:

    kubectl apply -f 3-studio-config-maps.yml

Create a secret with the `AUTH0_API_EXPLORER_CLIENT_ID` and `AUTH0_API_EXPLORER_CLIENT_SECRET`,

    export AUTH0_API_EXPLORER_CLIENT_ID="myAuth0ApiExplorerClientId"
    export AUTH0_API_EXPLORER_CLIENT_SECRET="myAuth0ApiExplorerClientSecret"
    kubectl create secret generic -n vs \
      studio-auth0-mgmt-api \
      --from-literal=client_id="${AUTH0_API_EXPLORER_CLIENT_ID}" \
      --from-literal=client_secret="${AUTH0_API_EXPLORER_CLIENT_SECRET}"

Create a secret with the `DEFAULT_USER_EMAIL` and `DEFAULT_USER_PASSWORD`,

    export DEFAULT_USER_EMAIL="myEmail"
    export DEFAULT_USER_PASSWORD="mySecretPassword"
    kubectl create secret generic -n vs \
      studio-default-user \
      --from-literal=email="${DEFAULT_USER_EMAIL}" \
      --from-literal=password="${DEFAULT_USER_PASSWORD}"

Create a secret with the SMTP username and password,

    export MAILER_SMTP_USER="mySmtpUsername"
    export MAILER_SMTP_PASS="mySecretPassword"
    kubectl create secret generic -n vs \
      studio-smtp-user \
      --from-literal=username="${MAILER_SMTP_USER}" \
      --from-literal=password="${MAILER_SMTP_PASS}"

Create a secret for the Studio `EXTERNAL_API_ACCESS_KEY`:

    export EXTERNAL_API_ACCESS_KEY="theApiAccessKey"
    kubectl create secret generic -n vs \
      studio-external-api-access-key \
      --from-literal=access_key="${EXTERNAL_API_ACCESS_KEY}"

Create a secret for pulling the app container from your private registry:

    export REGISTRY_USERNAME="dev-deploy-ro"
    export REGISTRY_PASSWORD="myServiceAccountPassword"
    kubectl create secret -n vs docker-registry viewspot-artifactory-ro \
      --docker-server=https://smithmicro-viewspot-docker-release-local.jfrog.io/ \
      --docker-username="$REGISTRY_USERNAME" \
      --docker-password="$REGISTRY_PASSWORD"


## 4. Create the Deployment and Service for `studio-config-service`

Modify the `4-studio-config-service.yml` manifest and replace all occurrences of
app domain `"vs-studio.eks.mabl.online"` with your own domain name, then apply the application
deployment and service:

    kubectl apply -f 4-studio-config-service.yml

    kubectl get deployments -n vs
    kubectl get services -n vs

The `studio-config-service` pods should be marked as ready 2/2.


## 5. Create the Deployment and Service for `studio-server-service`

Modify the `5-studio-server-service.yml` manifest and replace all occurrences of
app domain `"vs-studio.eks.mabl.online"` with your own domain name, then apply the application
service account, deployment and service:

    kubectl apply -f 5-studio-server-service.yml

    kubectl get deployments -n vs
    kubectl get services -n vs

The `studio-server-service` pods should be marked as ready 2/2.


## 6. Create the StatefulSet for `studio-nginx-proxy`

Apply the manifest for the `studio-ngcmx-proxy` StatefulSet:

    kubectl apply -f 6-studio-nginx-proxy.yml

    kubectl get sts -n vs

The `studio-nginx-proxy` pods should be marked as ready 2/2.


## 7. Create the Ingress for the Services

Modify the `7-studio-ingress.yml` manifest and replace all occurrences of
app domain `"vs-studio.eks.mabl.online"` with your own domain name, then apply the ingress controller for
the application:

    kubectl apply -f 7-studio-ingress.yml

    kubectl describe ingress studio-ingress -n vs

The ingress should list the event message
_"Successfully created Certificate vs-studio-tls-secret"_.

Open the address in your browser and expect to see health status "ok":

    open https://vs-studio.eks.mabl.online/api/config/admin/health

Open the address in your browser and expect to be redirected to the Auth0 identity provider to authenticate:

    open https://vs-studio.eks.mabl.online/

After authenticating, you are redirected to a beautiful Angular UI for administrating experiences.

Now go celebrate! :boom:
