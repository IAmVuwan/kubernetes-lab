set -u # or set -o nounset

source .env

: "$LOG_STORAGE_SIZE"

envsubst <"values.yaml" >"values.out.yaml"

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install --wait --timeout 600s loki grafana/loki-stack \
  --version 2.6.5 \
  --namespace monitoring --create-namespace \
  -f values.out.yaml

envsubst <"deployment.yaml" >"deployment.out.yaml"

kubectl apply -f deployment.out.yaml
