#!/bin/bash
# -------------------------------------------------------------------
#
# Module:         k8s-jenkins
# Submodule:      delete-jenkins.sh
# Environments:   all
# Purpose:        Bash shell script to delete any yaml files found in
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

# Include the banner function for logging purposes (see
# templates/banner.sh)
#
source ${datapath:-/datadrive/azadmin/k8s-jenkins}/banner.sh

log_banner "load-jenkins.sh" "Apply NFS Provisioner"

lbip=$(cat ~/lbip.txt | grep "export LBIP" | cut -d'=' -f2)
yaml_files=$(ls -r1 ${datapath:-/datadrive/azadmin/k8s-jenkins}/[0-9]*.yaml)
for file in $yaml_files
do
    short_banner "Applying yaml for: $file"
    sed '
      s/\${lbip}/'"${lbip:-.none.xip.io}"'/g;
      s/\${storageclass}/'"${storageclass:-local-storage}"'/g;
      s/\${selectorkey}/'"${selectorkey:-role}"'/g;
      s/\${selectorvalue}/'"${selectorvalue:-worker}"'/g;
      s/\${registry}/'"${registry:-k8s-master:32080\/}"'/g;
    ' $file | kubectl delete -f -
    if [ "$?" != "0" ];
    then 
        short_banner "*****";
        short_banner "Error applying $file - skipping";
        short_banner "*****";
    fi
    echo
done

short_banner "Done."
echo
