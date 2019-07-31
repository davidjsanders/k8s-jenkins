#!/bin/bash
mkdir -p /tmp/jenkins
cat ~/.kube/config | grep certificate-authority-data | cut -d':' -f2 | tr -d '[:space:]' | base64 -d > /tmp/jenkins/ca.crt
cat ~/.kube/config | grep client-certificate-data | cut -d':' -f2 | tr -d '[:space:]' | base64 -d > /tmp/jenkins/client.crt
cat ~/.kube/config | grep client-key-data | cut -d':' -f2 | tr -d '[:space:]' | base64 -d > /tmp/jenkins/client.key
openssl pkcs12 -export \
    -out /tmp/jenkins/cert.pfx \
    -inkey /tmp/jenkins/client.key \
    -in /tmp/jenkins/client.crt \
    -certfile /tmp/jenkins/ca.crt \
    -password pass:ThisIsTheJenkinsCert
echo
echo "pfx file   : /tmp/jenkins/cert.pfx"
echo "key        : /tmp/jenkins/client.key"
echo "client crt : /tmp/jenkins/client.crt"
echo "ca crt     : /tmp/jenkins/ca.crt"
echo "passphrase : ThisIsTheJenkinsCert"
echo