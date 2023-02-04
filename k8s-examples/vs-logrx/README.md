
# Deploying the `vs-logrx` App to AWS EKS with EFS

*Prerequisites:* Have the EKS cluster, Nginx Ingress Controller, DNS configuration, and AWS Elastic File System Storage
set up per the instructions in the [root README.md](../../README.md).


## 1. Create the App Namespace and Secrets

Change directory to `./k8s-examples/vs-logrx/`, modify the `0-infra.yml` manifest by replacing `"eu-north-1"`
with your own region and create the namespace `"vs"`:

    cd k8s-examples/vs-logrx/
    kubectl apply -f 0-infra.yml

Create a secret with the database credentials:

    export LOGRX_API_ACCESS_KEY="theApiAccessKey"
    kubectl create secret generic -n vs \
      logrx-api-access-key \
      --from-literal=access_key="${LOGRX_API_ACCESS_KEY}"

Create a secret for pulling the app container from your private registry:

    export REGISTRY_USERNAME="dev-deploy-ro"
    export REGISTRY_PASSWORD="myServiceAccountPassword"
    kubectl create secret -n vs docker-registry viewspot-artifactory-ro \
      --docker-server=https://smithmicro-viewspot-docker-release-local.jfrog.io/ \
      --docker-username="$REGISTRY_USERNAME" \
      --docker-password="$REGISTRY_PASSWORD"


## 2. Create ConfigMaps for the Application

Review the values in `1-logrx-config.yml` config map and adjust it to fit your deployment, then apply:

    kubectl apply -f 1-logrx-config.yml


## 3. Create the Storage, StatefulSet, Service, and Ingress for `vs-logrx`

Modify the `2-logrx-server.yml` manifest and replace all occurrences of
app domain `"vs-logrx.eks.mabl.online"` with your own domain name, then apply the application
storage, StatefulSet, service and ingress resources:

    kubectl apply -f 2-logrx-server.yml

    kubectl get sts logrx-server -n vs
    kubectl get service logrx-server -n vs
    kubectl describe ingress logrx-server -n vs

The `logrx-server` pods should be marked as ready 2/2 and the ingress should list the event message
_"Successfully created Certificate vs-logrx-tls-secret"_.

Verify that a log entry can be posted to `/v1/log`:

    curl -XPOST https://vs-logrx.eks.mabl.online/v1/log \
      -d "_model=LG-M430&app_vn=4.5.24&time=1553148000237"
    echo $?

Verify that a log entry can be posted to `/v2/log` using the API key:

    export LOGRX_API_ACCESS_KEY="theApiAccessKey"
    curl -v -XPOST https://vs-logrx.eks.mabl.online/v2/log \
      -H "X-Api-Access-Key: $LOGRX_API_ACCESS_KEY" \
      -d "_model=LG-M430&app_vn=4.5.24&time=1553148000237"

Verify that the server returns its build version, host and startup time:

    curl -XGET https://vs-logrx.eks.mabl.online/_config | jq .

Get the name of one of the `logrx-server` pods and use it to print the data recorded on storage:

    kubectl get pods -n vs
    export LOGRX_POD_NAME=logrx-server-6f9dbc747f-kh78j
    kubectl exec -n vs $LOGRX_POD_NAME -- bash -c "wc -l /data/* && cat /data/*.qs"

**TODO:** Configure the cron jobs to sync up logs to S3, or stick with streaming to Kafka...? :thinking:
