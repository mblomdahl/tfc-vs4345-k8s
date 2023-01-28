
# Deploying the Pod with EFS PersistentVolumeClaim to AWS EKS

## How to Deploy and Verify, Step by Step

*Prerequisites:* Have the EKS cluster set up with AWS Elastic File System Storage per the instructions in
the [root README.md](../../README.md).

Change directory to `./k8s-examples/efs-storage/` and apply the Pod and PersistentVolumeClaim config:

    cd k8s-examples/efs-storage/
    kubectl apply -f pod-with-pvc.yml

Get the EFS CSI controller pod names:

    kubectl get pods -n kube-system | grep efs-csi-controller
    "efs-csi-controller-7bd4cb58f5-g4s9z             3/3     Running   0          14m"
    "efs-csi-controller-7bd4cb58f5-kxm2z             3/3     Running   0          14m"

Check the logs from the two pods from the previous command:

    kubectl logs deployment/efs-csi-controller -n kube-system -c csi-provisioner --tail 10

Confirm that a persistent volume was created with status of `Bound` to a `PersistentVolumeClaim`:

    kubectl get pv

View details about the `PersistentVolumeClaim` that was created:

    kubectl get pvc

View the sample app pod's status until the `STATUS` becomes `Running`.

    kubectl get pods -o wide

Confirm that the data is written to the volume:

    kubectl exec efs-app -- bash -c "cat data/out"

Delete the pod and then create it again:

    kubectl delete pods/efs-app --now
    kubectl apply -f pod-with-pvc.yml

Verify that the old data is still attached and appended to:

    kubectl exec efs-app -- bash -c "cat data/out"

Now go celebrate! :boom:
