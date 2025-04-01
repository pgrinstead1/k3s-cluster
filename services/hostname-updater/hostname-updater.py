#!/usr/bin/env python3
import requests
import json
import time
import logging
import subprocess
import os
from datetime import datetime

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/hostname-updater.log'),
        logging.StreamHandler()
    ]
)

# Configuration - Load from environment or use defaults
OPNSENSE_URL = os.getenv('OPNSENSE_URL', "https://192.168.1.1")
API_KEY = os.getenv('OPNSENSE_API_KEY', "your_api_key")
API_SECRET = os.getenv('OPNSENSE_API_SECRET', "your_api_secret")
CHECK_INTERVAL = int(os.getenv('CHECK_INTERVAL', "300"))  # 5 minutes in seconds

def get_current_hostnames():
    try:
        # Using the same command as in your original script
        cmd = "ip neigh show | awk '$4 == \"lladdr\" {print $5, $1}'"
        result = subprocess.check_output(cmd, shell=True, text=True)
        
        # Process the output into a list of dictionaries
        hostnames = []
        for line in result.splitlines():
            if line.strip():
                mac, ip = line.split()
                hostnames.append({
                    "mac": mac.upper(),
                    "ip": ip
                })
        
        logging.info(f"Found {len(hostnames)} devices")
        return hostnames
    except Exception as e:
        logging.error(f"Error getting hostnames: {e}")
        return None

def update_opnsense(hostnames):
    if not hostnames:
        return False
    
    try:
        headers = {
            'Content-Type': 'application/json',
            'X-API-Key': API_KEY,
            'X-API-Secret': API_SECRET
        }
        
        # Using your existing endpoint structure
        payload = {"devices": hostnames}
        
        response = requests.post(
            f"{OPNSENSE_URL}/api/unbound/settings/updateHostOverride",
            headers=headers,
            json=payload,
            verify=False  # Only if using self-signed cert
        )
        
        if response.status_code == 200:
            logging.info(f"Successfully updated OPNsense with {len(hostnames)} devices")
            return True
        else:
            logging.error(f"Failed to update OPNsense: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        logging.error(f"Error updating OPNsense: {e}")
        return False

def main():
    logging.info("Hostname updater service started")
    while True:
        try:
            hostnames = get_current_hostnames()
            if hostnames:
                update_opnsense(hostnames)
            time.sleep(CHECK_INTERVAL)
        except Exception as e:
            logging.error(f"Main loop error: {e}")
            time.sleep(60)  # Wait a minute before retrying on error

if __name__ == "__main__":
    main()
