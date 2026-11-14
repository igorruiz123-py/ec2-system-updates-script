#! /bin/bash

source .env

LOG_FILE_PATH=""

HOSTNAME=""

OS=$(hostnamectl | grep "Operating System" | cut -d: -f2-)

JSON_MESSAGE=$(cat <<EOF

    {
        "alarm_id": "system_updates_alarm",
        "hostname": "$HOSTNAME",
        "OS": "$OS"
    }
EOF
)

if sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y ; then

    echo "[INFO] crontab executed: system updated successfully." >> $LOG_FILE_PATH

    if aws sns publish --topic-arn "$SNS_ARN" --message "$JSON_MESSAGE" ; then

        echo "[INFO] SNS published message to $SNS_ARN successfully." >> $LOG_FILE_PATH

    else

        echo "[ERROR] SNS failed to publish message to $SNS_ARN." >> $LOG_FILE_PATH

    fi

else

    echo "[ERROR] crontab executed: failed to update the system."

fi