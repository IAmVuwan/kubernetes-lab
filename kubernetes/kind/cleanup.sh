export reg_name='kind-registry'

kind delete cluster

docker stop $reg_name

docker rm -v $reg_name