#!/bin/bash
##H Creates Kubernetes cluster using openstack templates for DM Monitoring(cms-dm-monit)
##H Please
##H   - find a latest kubernetes template and use it:
##H     * 'openstack coe cluster template list'
##H     * 'openstack coe cluster template show kubernetes-1.25.3-3 -f yaml'
##H   - Define your master and node counts
##H   - Define your master and node FLAVORS: 'openstack flavor list'
##H   - Define EOS enabled or not, default NOT.
##H   - Define ingress controller, default NGINX; it can be traefik too!
##H Usage:
##H     ./create_cluster_dmmon.sh <cluster_name:put template version as suffix> <template_name:if not provided will use $template >
##H Example:
##H    ./create_cluster_dmmon.sh cms-dm-monit-v1.25.3-3 kubernetes-1.25.3-3
##H

namespace=${OS_PROJECT_NAME:-"CMS Web"}
name=$1
template=${2:-"kubernetes-1.25.3-3"}

if [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ] || [ "$1" == "help" ] || [ "$1" == "" ]; then
    grep "^##H" <"$0" | sed -e "s,##H,,g"
    exit 0
fi
echo "Creating cluster => NameSpace: ${namespace} , Name: ${name} , Template: ${template}"
echo "Check if EOS enabled! cms-dm-monit cluster does not need it."

sleep 10

openstack --os-project-name "$namespace" coe cluster create "$name" \
    --keypair cloud \
    --cluster-template "$template" \
    --master-count 1 \
    --master-flavor m2.large \
    --node-count 2 \
    --flavor m2.large \
    --merge-labels \
    --labels availability_zone="" \
    --labels cinder_csi_enabled="true" \
    --labels logging_include_internal="true" \
    --labels logging_http_destination="http://monit-logs.cern.ch:10012/" \
    --labels logging_installer=helm \
    --labels eos_enabled="false" \
    --labels monitoring_enabled="true" \
    --labels logging_producer="cmswebk8s" \
    --labels ingress_controller="nginx" \
    --labels cern_enabled="true" \
    --labels keystone_auth_enabled="true" \
    --labels logging_type="http"

# Ref: https://cms-http-group.docs.cern.ch/k8s_cluster/cmsweb-deployment/
#
# READ the DOC: https://cmsmonit-docs.web.cern.ch/k8s/cluster_upgrades/#dm-mon
