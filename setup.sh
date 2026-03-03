#!/bin/bash

# Generate timestamped log filename
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILE="Guard-LAB-setup-$TIMESTAMP.log"
NAMESPACE="dev-environment"

# Function to log messages with timestamp
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_microk8s() {
    if command -v microk8s >/dev/null 2>&1; then
        if microk8s status | grep -q "microk8s is running"; then
            log "✅ MicroK8s is intstalled and running, setting up kubectl alias"
            kubectl() { microk8s.kubectl "$@"; }
            helm() { /snap/bin/microk8s.helm "$@"; }
            export -f kubectl
            export -f helm
            return 0
        else
            log "❌ MicroK8s is installed but not running"
            return 1
        fi
    else
        log "❌ MicroK8s is not installed"
        log "Please install MicroK8s using: sudo snap install microk8s --classic"
        return 1
    fi
}

# Call the function
#

log "🔧 Checking if  MicroK8s is installed..."
check_microk8s


log "🔧 Starting MicroK8s environment setup..."


# Enable DNS
log "📡 Enabling DNS add-on (CoreDNS)..."
microk8s enable dns >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  log "✅ DNS enabled. Internal service discovery is now active."
else
  log "❌ DNS enable failed. See log for details."
fi

# Enable Ingress
log "🌐 Enabling Ingress controller (NGINX)..."
microk8s enable ingress >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  log "✅ Ingress enabled. You can now expose services via HTTP/HTTPS."
else
  log "❌ Ingress enable failed. See log for details."
fi

# Enable HostPath Storage
log "💾 Enabling HostPath storage..."
microk8s enable hostpath-storage >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  log "✅ HostPath storage enabled. PVCs will use local disk paths."
else
  log "❌ HostPath storage enable failed. See log for details."
fi

# Apply Kubernetes namespace 
log "📄 Applying Kubernetes namespace "

for manifest in namespace.yaml ; do
  log "📄 Applying $manifest..."
  microk8s kubectl apply -f "$manifest" >> "$LOG_FILE" 2>&1
  if [ $? -eq 0 ]; then
    log "✅ $manifest applied successfully."
  else
    log "❌ Failed to apply $manifest. See log for details."
  fi
done

log "📄 Deleting the default ingressclass for nginx if one was installed in the past "

microk8s kubectl delete ingressclass nginx  >> "$LOG_FILE" 2>&1 

if [ $? -eq 0 ]; then
  log "✅ Cleared older if any ingressclass for nginx"
else
  log "❌ Failed to clear ingressclass for nginx. See log for details, could be there just was not set."
fi


# Installing Toolhive 
log  "📄 Install Toolhive "

microk8s.helm upgrade --install toolhive-operator-crds oci://ghcr.io/stacklok/toolhive/toolhive-operator-crds   >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  log "✅ Installed Toolhive Operator CRDS"
else
  log "❌ Toolhive Opertor CRDS Failed. See log for details."
fi

microk8s.helm upgrade --install toolhive-operator oci://ghcr.io/stacklok/toolhive/toolhive-operator -n toolhive-system --create-namespace >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  log "✅ Installed Toolhive Operator OCI"
else
  log "❌ Toolhive Opertor OCI Failed. See log for details."
fi


log "📄 Starting the K8S Pods"

microk8s.kubectl apply -f guard-demo.yaml -f ingress.yaml -f mcpserver_fetch.yaml -f mcpserver_filesystem.yaml  >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  log "✅ Deployed K8s Pods -  Lakera Guard, Ingress Controller, MCP Fetch Server and MCP Filesystem Server"
else
  log "❌ Errors Deployed K8s Pods. See log for details."
fi




log "🎉 MicroK8s setup complete. Log saved to '$LOG_FILE'."
