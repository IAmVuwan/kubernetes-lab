helm delete -n monitoring prometheus
kubectl delete -f docker-containers.yaml
kubectl delete -f deployment.out.yaml
