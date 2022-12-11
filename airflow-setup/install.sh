set -u # or set -o nounset

source .env


: "$CLUSTER_FQDN"

envsubst <"values.yaml" >"values.out.yaml"

helm repo add airflow-stable https://airflow-helm.github.io/charts
helm repo update

helm upgrade --install --wait --timeout 600s airflow airflow-stable/airflow \
  --version 8.6.1 \
  --namespace airflow-system --create-namespace \
  -f values.out.yaml
