
# Deploying the Pod with EBS PersistentVolumeClaim to AWS EKS

## How to Deploy and Verify, Step by Step

*Prerequisites:* Have the EKS cluster set up with AWS Elastic Block Storage per the instructions in
the [root README.md](../../README.md).

Change directory to `./k8s-examples/ebs-storage/` and apply the Pod and PersistentVolumeClaim config:

    cd k8s-examples/ebs-storage/
    kubectl apply -f pod-with-pvc.yml

Get the EBS CSI controller pod names:

    kubectl get pods -n kube-system | grep ebs-csi-controller
    "ebs-csi-controller-746b99cfc-8pvjj              6/6     Running   0          12m"
    "ebs-csi-controller-746b99cfc-zsbls              6/6     Running   0          12m"

Check the logs from the two pods from the previous command:

    kubectl logs deployment/ebs-csi-controller -n kube-system -c csi-provisioner --tail 10

Confirm that a persistent volume was created with status of `Bound` to a `PersistentVolumeClaim`:

    kubectl get pv

View details about the `PersistentVolumeClaim` that was created:

    kubectl get pvc

View the sample app pod's status until the `STATUS` becomes `Running`.

    kubectl get pods -o wide

Confirm that the data is written to the volume:

    kubectl exec ebs-app -- bash -c "cat data/out.txt"

Delete the pod and then create it again:

    kubectl delete pods/ebs-app --now
    kubectl apply -f pod-with-pvc.yml

Verify that the old data is still attached and appended to:

    kubectl exec ebs-app -- bash -c "cat data/out.txt"

Now go celebrate! :boom:
