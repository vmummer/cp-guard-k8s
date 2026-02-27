#!/bin/bash

# Generate timestamped log filename
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILE="Guard-LAB-setup-$TIMESTAMP.log"
NAMESPACE="dev-environment"

# Function to log messages with timestamp
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

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

echo "Deleting the default ingressclass for nginx"

microk8s kubectl delete ingressclass nginx

log "🎉 MicroK8s setup complete. Log saved to '$LOG_FILE'."

