set -u # or set -o nounset

source .env

: "$N_BYTES"
: "$N_TIMES"

envsubst < "deployment.yaml" > "deployment.out.yaml"

kubectl apply -f deployment.out.yaml