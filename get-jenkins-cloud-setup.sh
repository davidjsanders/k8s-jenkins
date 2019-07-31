#!/bin/bash
ca_crt=$(cat ~/.kube/config | grep certificate-authority-data | cut -d':' -f2 | tr -d '[:space:]' | base64 -d)
client_crt=$(cat ~/.kube/config | grep client-certificate-data | cut -d':' -f2 | tr -d '[:space:]' | base64 -d)
client_key=$(cat ~/.kube/config | grep client-key-data | cut -d':' -f2 | tr -d '[:space:]' | base64 -d)
mkdir -p /tmp/jenkins
echo $ca_crt > /tmp/jenkins/ca.crt
echo $client_crt > /tmp/jenkins/client.crt
echo $client_key > /tmp/jenkins/client.key
openssl pkcs12 -export -out cert.pfx -inkey client.key -in client.crt -certfile ca.crt

echo
echo "ca_crt    : $ca_crt"
echo "client_crt: $client_crt"
echo "client_key: $client_key"
