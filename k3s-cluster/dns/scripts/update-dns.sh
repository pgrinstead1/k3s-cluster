#!/bin/sh
set -e

ZONE_FILE="/etc/coredns/shared/k8s.internal.db"
TEMP_FILE="/tmp/k8s.internal.db.tmp"
DOMAIN="k8s.internal"
INTERVAL="30"
CLUSTERIP=$(kubectl get svc -n kube-system kube-dns -o jsonpath='{.spec.clusterIP}')

# Initialize zone file if it doesn't exist
if [ ! -f "${ZONE_FILE}" ]; then
  echo "Creating initial zone file..."
  cat > "${ZONE_FILE}" << EOL
${DOMAIN}. 300 IN SOA ${DOMAIN}. hostmaster.${DOMAIN}. (
           1     ; serial
           300   ; refresh
           300   ; retry
           300   ; expire
           300 ) ; minimum TTL
@ IN NS ns1.${DOMAIN}.
EOL
  echo "ns1 IN A ${CLUSTERIP}" >> "${ZONE_FILE}"
fi

echo "Starting DNS record synchronization for Kubernetes services with domain ${DOMAIN}"
echo "Zone file: ${ZONE_FILE}"
echo "Update interval: ${INTERVAL} seconds"

# Main loop
while true; do
  echo "Scanning for services with external-dns.alpha.kubernetes.io/hostname annotation..."
  
  # Get services with the hostname annotation that match our domain
  SERVICE_COUNT=0
  
  # Get current serial and increment it
  SERIAL=$(date +%Y%m%d%H)
  
  # Create a temporary file for the new zone file
  cat > "${TEMP_FILE}" << EOL
${DOMAIN}. 300 IN SOA ${DOMAIN}. hostmaster.${DOMAIN}. (
           ${SERIAL} ; serial
           300        ; refresh
           300        ; retry 
           300        ; expire
           300 )      ; minimum TTL
@ IN NS ns1.${DOMAIN}.
EOL
  echo "ns1 IN A ${CLUSTERIP}" >> "${TEMP_FILE}"
  
  # Debug: List all services with hostname annotation
  echo "DEBUG: Listing all services with hostname annotation"
  kubectl get services --all-namespaces -o json | jq -r '.items[] | select(.metadata.annotations["external-dns.alpha.kubernetes.io/hostname"]) | "Service: " + .metadata.name + ", Hostname: " + .metadata.annotations["external-dns.alpha.kubernetes.io/hostname"] + ", Has LoadBalancer IP: " + (if .status.loadBalancer.ingress then "yes" else "no" end)'
  
  # Get all services with hostname annotation and a LoadBalancer IP
  kubectl get services --all-namespaces -o json | jq -r '.items[] | select(.metadata.annotations["external-dns.alpha.kubernetes.io/hostname"]) | select(.status.loadBalancer.ingress != null) | .metadata.annotations["external-dns.alpha.kubernetes.io/hostname"] + " " + (.status.loadBalancer.ingress[0].ip // "")' | while read HOSTNAME IP; do
    echo "DEBUG: Processing service with hostname ${HOSTNAME} and IP ${IP}"
    
    # Convert k8s.local or k8s.home to k8s.internal
    if [ -n "${IP}" ]; then
      if echo "${HOSTNAME}" | grep -q "k8s.local"; then
        # Convert k8s.local to k8s.internal
        OLD_HOSTNAME="${HOSTNAME}"
        HOSTNAME=$(echo "${HOSTNAME}" | sed "s/k8s.local/k8s.internal/g")
        echo "Converted hostname from ${OLD_HOSTNAME} to ${HOSTNAME}"
      elif echo "${HOSTNAME}" | grep -q "k8s.home"; then
        # Convert k8s.home to k8s.internal
        OLD_HOSTNAME="${HOSTNAME}"
        HOSTNAME=$(echo "${HOSTNAME}" | sed "s/k8s.home/k8s.internal/g")
        echo "Converted hostname from ${OLD_HOSTNAME} to ${HOSTNAME}"
      fi
      
      echo "DEBUG: After potential conversion, hostname is ${HOSTNAME}, checking if it ends with .${DOMAIN}"
      
      if echo "${HOSTNAME}" | grep -q "\.${DOMAIN}$"; then
        echo "DEBUG: Hostname ${HOSTNAME} ends with .${DOMAIN}"
        # Extract just the hostname part (without the domain)
        SHORTNAME=$(echo "${HOSTNAME}" | sed "s/\.${DOMAIN}$//")
        
        echo "Found ${HOSTNAME} -> ${IP} (shortname: ${SHORTNAME})"
        echo "${SHORTNAME} IN A ${IP}" >> "${TEMP_FILE}"
        SERVICE_COUNT=$((SERVICE_COUNT + 1))
      else
        echo "DEBUG: Hostname ${HOSTNAME} does not end with .${DOMAIN}"
      fi
    else
      echo "DEBUG: Service has no IP address"
    fi
  done
  
  # Also get ingress resources with hostname annotation
  echo "DEBUG: Listing all ingresses with hostname annotation"
  kubectl get ingress --all-namespaces -o json | jq -r '.items[] | select(.metadata.annotations["external-dns.alpha.kubernetes.io/hostname"]) | "Ingress: " + .metadata.name + ", Hostname: " + .metadata.annotations["external-dns.alpha.kubernetes.io/hostname"] + ", Has LoadBalancer IP: " + (if .status.loadBalancer.ingress then "yes" else "no" end)'
  
  kubectl get ingress --all-namespaces -o json | jq -r '.items[] | select(.metadata.annotations["external-dns.alpha.kubernetes.io/hostname"]) | select(.status.loadBalancer.ingress != null) | .metadata.annotations["external-dns.alpha.kubernetes.io/hostname"] + " " + (.status.loadBalancer.ingress[0].ip // "")' | while read HOSTNAME IP; do
    echo "DEBUG: Processing ingress with hostname ${HOSTNAME} and IP ${IP}"
    
    # Convert k8s.local or k8s.home to k8s.internal
    if [ -n "${IP}" ]; then
      if echo "${HOSTNAME}" | grep -q "k8s.local"; then
        # Convert k8s.local to k8s.internal
        OLD_HOSTNAME="${HOSTNAME}"
        HOSTNAME=$(echo "${HOSTNAME}" | sed "s/k8s.local/k8s.internal/g")
        echo "Converted hostname from ${OLD_HOSTNAME} to ${HOSTNAME}"
      elif echo "${HOSTNAME}" | grep -q "k8s.home"; then
        # Convert k8s.home to k8s.internal
        OLD_HOSTNAME="${HOSTNAME}"
        HOSTNAME=$(echo "${HOSTNAME}" | sed "s/k8s.home/k8s.internal/g")
        echo "Converted hostname from ${OLD_HOSTNAME} to ${HOSTNAME}"
      fi
      
      echo "DEBUG: After potential conversion, hostname is ${HOSTNAME}, checking if it ends with .${DOMAIN}"
      
      if echo "${HOSTNAME}" | grep -q "\.${DOMAIN}$"; then
        echo "DEBUG: Hostname ${HOSTNAME} ends with .${DOMAIN}"
        # Extract just the hostname part (without the domain)
        SHORTNAME=$(echo "${HOSTNAME}" | sed "s/\.${DOMAIN}$//")
        
        echo "Found ingress ${HOSTNAME} -> ${IP} (shortname: ${SHORTNAME})"
        echo "${SHORTNAME} IN A ${IP}" >> "${TEMP_FILE}"
        SERVICE_COUNT=$((SERVICE_COUNT + 1))
      else
        echo "DEBUG: Hostname ${HOSTNAME} does not end with .${DOMAIN}"
      fi
    else
      echo "DEBUG: Ingress has no IP address"
    fi
  done
  
  echo "Found ${SERVICE_COUNT} services/ingresses with ${DOMAIN} hostnames"
  
  # Replace zone file if changed
  if ! diff -q "${ZONE_FILE}" "${TEMP_FILE}" > /dev/null 2>&1; then
    cp "${TEMP_FILE}" "${ZONE_FILE}"
    echo "Zone file updated at $(date)"
    echo "New zone file contents:"
    cat "${ZONE_FILE}"
  else
    echo "No changes to zone file needed"
  fi
  
  # Sleep for the specified interval
  echo "Sleeping for ${INTERVAL} seconds..."
  sleep ${INTERVAL}
done
