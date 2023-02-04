
# Deploying the `vs-location` App to AWS EKS and RDS

*Prerequisites:* Have the EKS cluster, Nginx Ingress Controller, DNS configuration, and ACK Service Controller for RDS
set up per the instructions in the [root README.md](../../README.md).

## 1. Create the App Namespace and Database Credentials

Change directory to `./k8s-examples/vs-location/`, modify the `0-infra.yml` manifest by replacing `"eu-north-1"`
with your own region and create the namespace `"vs"`:

    cd k8s-examples/vs-location/
    kubectl apply -f 0-infra.yml

Create a secret with the database credentials:

    export RDS_DB_PASSWORD="yourOwnSecurePassword"
    kubectl create secret generic -n vs \
      location-postgres-password \
      --from-literal=password="${RDS_DB_PASSWORD}"


## 2. Create the RDS Postgres Database

Modify the `1-database.yml` by replacing the database subnet group name `"mb-eks-rds-subnet-group"` with your
own group name:

    cd ../../
    echo $(terraform output -raw ack_rds_database_subnet_group_name)
    cd k8s-examples/vs-location/

Apply the database manifest:

    kubectl apply -f 1-database.yml

Track the status of RDS database creation:

    kubectl describe -n vs dbinstance location-postgres

Apply the field export of connection parameters into the `location-postgres-conn` config map:

    kubectl apply -f 2-rds-field-exports.yml


## 3. Create Secrets and ConfigMaps for the Application

Review the values in `3-location-config.yml` config map and adjust it to fit your deployment, then apply:

    kubectl apply -f 3-location-config.yml

Create a secret with the `AUTH0_API_EXPLORER_CLIENT_ID` and `AUTH0_API_EXPLORER_CLIENT_SECRET`,

    export AUTH0_API_EXPLORER_CLIENT_ID="myAuth0ApiExplorerClientId"
    export AUTH0_API_EXPLORER_CLIENT_SECRET="myAuth0ApiExplorerClientSecret"
    kubectl create secret generic -n vs \
      location-auth0-mgmt-api \
      --from-literal=client_id="${AUTH0_API_EXPLORER_CLIENT_ID}" \
      --from-literal=client_secret="${AUTH0_API_EXPLORER_CLIENT_SECRET}"

Create a secret for the cookie `SESSION_SECRET`:

    export SESSION_SECRET="myCookieSigningKey"
    kubectl create secret generic -n vs \
      location-session-secret \
      --from-literal=secret="${SESSION_SECRET}"

Create a secret for pulling the app container from your private registry:

    export REGISTRY_USERNAME="dev-deploy-ro"
    export REGISTRY_PASSWORD="myServiceAccountPassword"
    kubectl create secret -n vs docker-registry viewspot-artifactory-ro \
      --docker-server=https://smithmicro-viewspot-docker-release-local.jfrog.io/ \
      --docker-username="$REGISTRY_USERNAME" \
      --docker-password="$REGISTRY_PASSWORD"


## 4. Create the Deployment, Service, and Ingress for `vs-location`

Modify the `4-location-service.yml` manifest and replace all occurrences of
app domain `"vs-location.eks.mabl.online"` with your own domain name, then apply the application
deployment, service and ingress resources:

    kubectl apply -f 4-location-service.yml

    kubectl get deployments -n vs
    kubectl get services -n vs
    kubectl describe ingress location-service -n vs

The `location-service` pods should be marked as ready 2/2 and the ingress should list the event message
_"Successfully created Certificate vs-location-tls-secret"_.

Open the address in your browser and expect to be redirected to the Auth0 identity provider to authenticate:

    open https://vs-location.eks.mabl.online/

After authenticating, you are redirected to a beautiful Angular UI for administrating your locations. Then go
celebrating! :boom:
