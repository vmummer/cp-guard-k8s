#!/usr/bin/env bash
# Feb 27, 2026 - Created aliase file for Lakera Guard Demo
VER=1.0.0

# Corrected Hostname Check
if hostname | grep -q '[A-Z]'; then
    echo ">>> WARNING <<< Hostname contains Capital Letters."
    echo "Rename hostname to all lower case to prevent MicroK8s failures!"
    exit 1
fi



# Environment Variables
export HOST_IP="$(hostname -I | awk '{print $1}')"


# Core Functions

echo "Check Point Lakera Guard Demo on Kubernetes Lab Alias Commands.  Use cphelp for list of commands. Ver: $VER"

check_microk8s() {
    if command -v microk8s >/dev/null 2>&1; then
        if microk8s status | grep -q "microk8s is running"; then
            echo "✅ MicroK8s is intstalled and running, setting up kubectl alias"
	    kubectl() { microk8s.kubectl "$@"; }
	    helm() { /snap/bin/microk8s.helm "$@"; }
	    export -f kubectl
	    export -f helm
            return 0
        else
            echo "❌ MicroK8s is installed but not running"
            return 1
        fi
    else
        echo "❌ MicroK8s is not installed"
        echo "Please install MicroK8s using: sudo snap install microk8s --classic"
        return 1
    fi
}

# Call the function
check_microk8s


alias  k="kubectl"
alias ka="kubectl apply"
alias kd="kubectl delete"
alias kp="kubectl get pods -A"
alias ks="kubectl get svc -A --output wide"


get_INGRESS_IP() {
    local IP=$(microk8s.kubectl get svc "$WAPAPP" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

    if [[ -z "$IP" || "$IP" == "null" ]]; then
        # Fallback: check for Hostname if IP isn't used (some environments use DNS names for LoadBalancers)
        IP=$(microk8s.kubectl get svc "$WAPAPP" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    fi

    if [[ -z "$IP" || "$IP" == "null" ]]; then
        echo "❌ Error: Could not retrieve Ingress IP for $WAPAPP." >&2
        return 1
    fi
    export INGRESS_IP="$IP"
}


if kubectl get pods -A | grep -q -o 'cp-appsec' ; then 
	get_INGRESS_IP
# 	get_WAFPOD  
fi

alias wafciserhost='k exec -it wafciser  -n wafciser -- bash'

alias cphost='printf "Host IP address used: $HOST_IP \n"'
alias cpingress='printf "Ingress IP address used: $INGRESS_IP \n"'
#alias cpmetallb='microk8s enable metallb:$INGRESS_IP-$INGRESS_IP'
alias cpmetallb='microk8s enable metallb:$HOST_IP-$HOST_IP'

alias cpuptemp='echo "Updating coredns.yaml using coredns.yaml.template with local Host IP address of ${INGRESS_IP}" && \
	         envsubst  < coredns.yaml.template > coredns.yaml '

alias cplglog='kubectl logs -n lakera -l app=guarddemo -f'

alias cphelp='printf "Check Point Lab Commands:     Ver: $VER
written by - Vince Mammoliti - vincem@checkpoint.com \n
cphost           Shows the IP address of the Host used
cpingress        Shows the IP address of the Ingress Controller used
cphelp           Alias Command to help with Check Point Lab
cpmetallb        Enables the MicroK8s Metallb with the External IP of the Host system
cpuptemp         Update the local yaml files using templates and update with local IPs (coredns.yaml)
cpstatus         Reports on status of Lab Enviroment

cplglog          Watch the Lakera Guard Application Logs

Kubectl Short Cuts
k                kubectl
ka               kubectl apply
kd               kubectl delete
kp               kubectl get pods -A 
ks               kubectl get svc -A --output wide
kdwaf            kubectl delete POD {WAF POD Name} --force 
"' 




cplabstatus() {
    echo -e "\n--- 🏥 Check Point WAF Lab Health Report ---"

    # 1. Check Infrastructure
    check_microk8s || return 1

    echo -ne "Checking the WAF Agent Registration Status ...\n"
    cpnanor
    echo -ne "Checking Ingress IP...  "
    if get_INGRESS_IP &>/dev/null; then
        echo -e "✅ Assigned ($INGRESS_IP)"
    else
        echo -e "❌ NOT ASSIGNED (Check MetalLB)"
    fi

}

# Add the alias at the very bottom
alias cpstatus='cplabstatus'

