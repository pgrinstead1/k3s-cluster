# OPNsense Hostname Updater Service

This service automatically updates OPNsense with hostnames from your network devices.

## Components

- Python script for hostname detection and updates
- Systemd service configuration
- Virtual environment setup

## Installation

1. Create virtual environment:
```bash
python3 -m venv /home/pi/hostname-updater-env
source /home/pi/hostname-updater-env/bin/activate
pip install requests
```

2. Copy files to their locations:
```bash
sudo cp hostname-updater.py /usr/local/bin/
sudo cp hostname-updater.service /etc/systemd/system/
sudo chmod +x /usr/local/bin/hostname-updater.py
```

3. Configure the service:
Edit the service file to set your OPNsense credentials:
```bash
sudo systemctl edit hostname-updater
```

4. Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable hostname-updater
sudo systemctl start hostname-updater
```

## Configuration

Update the following variables in the service file:
- OPNSENSE_URL
- OPNSENSE_API_KEY
- OPNSENSE_API_SECRET

## Monitoring

```bash
# Check service status
sudo systemctl status hostname-updater

# View logs
sudo journalctl -u hostname-updater -f
```

## Files

- `hostname-updater.py`: Main Python script
- `hostname-updater.service`: Systemd service configuration
- `requirements.txt`: Python package dependencies
