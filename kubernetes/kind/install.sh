### Environment variables

# kindest version
export kindest_version='v1.23.0'

# local docker registry name
export reg_name='kind-registry'

# local docker registry container exposed port
export reg_port='5001'

## Kubernetes cluster

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# cluster with the local registry enabled in containerd
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:$reg_port"]
    endpoint = ["http://$reg_name:5000"]
nodes:
- role: control-plane
  image: kindest/node:$kindest_version
  kubeadmConfigPatches:
  # cluster with the ingress enabled
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
  image: kindest/node:$kindest_version
EOF

kubectl get pods --all-namespaces -o wide

## Docker registry

# create registry container unless it already exists
docker run -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" registry:2

# connect the registry to the cluster network if not already connected
docker network connect "kind" "${reg_name}"

# Document the local registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:$reg_port"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

## MetalLB load balancer

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml

kubectl wait deployment -n metallb-system controller --for condition=Available=True --timeout=90s

IP=$(docker network inspect -f '{{.IPAM.Config}}' kind | awk '{print $1}' | awk '{ split(substr($1,3), i,"."); print i[1]"."i[2]}')

echo "Kind Network IP Prefix: $IP"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $IP.255.200-$IP.255.250
EOF

kubectl rollout restart deployment -n metallb-system controller

## Nginx Ingress Controller

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

## Metrics Server

helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system --set 'args[0]=--kubelet-insecure-tls'
