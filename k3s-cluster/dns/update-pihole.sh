cat <<EOF > update-pihole.sh
#!/bin/bash

PIHOLE_SERVER="http://192.168.1.24"
SESSION_TOKEN=\$(curl -s -k --request POST -d '{"password":"NevadaMaybe11"}' \${PIHOLE_SERVER}/api/auth | jq -r '.session.sid')

function add_dns_record() {
    local DOMAIN=\$1
    local IP=\$2

    curl -s -k --request POST \
        -H "Authorization: Bearer \$SESSION_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"action\": \"add\", \"recordType\": \"A\", \"domain\": \"\${DOMAIN}\", \"ip\": \"\${IP}\"}" \
        \${PIHOLE_SERVER}/admin/api.php
}

# Read service updates from External-DNS logs
while read LINE; do
    DOMAIN=\$(echo \$LINE | awk '{print \$1}')
    IP=\$(echo \$LINE | awk '{print \$2}')
    add_dns_record \$DOMAIN \$IP
done
EOF
