#!/bin/bash
# -------------------------------------------------------------------
#
# Module:         k8s-jenkins
# Submodule:      load-jenkins.sh
# Environments:   all
# Purpose:        Bash shell script to apply any yaml files found in
#                 the jenkins directory. 
#
# Created on:     30 July 2019
# Created by:     David Sanders
# Creator email:  dsanderscanada@nospam-gmail.com
#
# -------------------------------------------------------------------
# Modifed On   | Modified By                 | Release Notes
# -------------------------------------------------------------------
# 30 Jul 2019  | David Sanders               | First release.
# -------------------------------------------------------------------
# 06 Aug 2019  | David Sanders               | Fix location of banner
#              |                             | source.
# -------------------------------------------------------------------
# 18 Aug 2019  | David Sanders               | Change error handling
#              |                             | to skip.
# -------------------------------------------------------------------
# 19 Aug 2019  | David Sanders               | Chmod of data drive to
#              |                             | root for docker.
# -------------------------------------------------------------------

# Include the banner function for logging purposes (see
# templates/banner.sh)
#
source ${datapath:-/datadrive/azadmin/k8s-jenkins}/banner.sh
error_list=""

log_banner "load-jenkins.sh" "Apply NFS Provisioner"

#short_banner "Changing file permissions"
#sudo chown -R root:root /datadrive/export/root

short_banner "Load YAML manifests"
if [ -z "$lbip" ]; then
    lbip="."$(cat ~/lbip.txt | grep "export LBIP" | cut -d'=' -f2)".xip.io"
fi

yaml_files=$(ls -1 ${datapath:-/datadrive/azadmin/k8s-jenkins}/[0-9]*.yaml)
for file in $yaml_files
do
    short_banner "Applying yaml for: $file"
    sed '
      s/\${lbip}/'"${lbip:-.none.xip.io}"'/g;
      s/\${storageclass}/'"${storageclass:-local-storage}"'/g;
      s/\${selectorkey}/'"${selectorkey:-role}"'/g;
      s/\${selectorvalue}/'"${selectorvalue:-worker}"'/g;
      s/\${registry}/'"${registry:-k8s-master:32080\/}"'/g;
    ' $file | kubectl apply -f -
    ret_stat="$?"
    if [ "$ret_stat" != "0" ]; 
    then 
        short_banner "*****"; 
        short_banner "Error applying $file - skipping"; 
        short_banner "*****"; 
        error_list=$error_list" ${file}---${ret_stat}"
    fi
    echo
done

for err in $error_list
do
  echo ">>> ERROR: $err"
done

short_banner "Remember to run /datadrive/azadmin//k8s-jenkins/get-jenkins-cloud-setup.sh"

short_banner "Done."
echo
