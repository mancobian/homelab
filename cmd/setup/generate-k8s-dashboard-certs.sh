#!/bin/bash
# https://github.com/kubernetes/dashboard/issues/2947#issuecomment-551415803
# https://stackoverflow.com/a/43665244

# Error handling
set -eu -o pipefail
function print_error {
    read line file <<<$(caller)
    echo "An error occurred in line $line of file $file:" >&2
    sed "${line}q;d" "$file" >&2
}
trap print_error ERR

# Setup storage
rm -rf ./certs
mkdir certs

# Create CSR config
cnf="[req]
prompt = no
default_bits = 2048
distinguished_name = req_distinguished_name

[req_distinguished_name]
C = US
ST = GA
L = Atlanta
O = Kludge City
OU = Hosting
CN = kubernetes-dashboard
"
v3ext="
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = k8s.kludge.city
"
v3_cnf="certs/v3.ext"
csr_cnf="certs/csr.cnf"
echo "$cnf" > "$csr_cnf"
echo "$v3ext" > "$v3_cnf"
 
# Generate self-signed certificates
openssl req -nodes -newkey rsa:2048 -keyout certs/dashboard.key -out certs/dashboard.csr -config $csr_cnf 
openssl x509 -req -sha256 -days 3650 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt -extfile $v3_cnf
rm $csr_cnf; rm $v3_cnf

# Delete the kubernetes-dashboard-certs if it already exists
microk8s kubectl get secret kubernetes-dashboard-certs -n kube-system
if [ $? == 0 ]; then
    microk8s kubectl delete secret kubernetes-dashboard-certs -n kube-system
fi

# Generate the kubernetes-dashboard-certs certificate file
microk8s kubectl create secret generic kubernetes-dashboard-certs --from-file=$(pwd)/certs -n kube-system

# Make sure the kubernetes- dashboards -certs secret has been imported correctly
microk8s kubectl -n kube-system describe secret/kubernetes-dashboard-certs
