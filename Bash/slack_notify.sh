#!/bin/bash

HOST=$(hostname)
EMOJIICON=":godmode:"
webhook="***"

while getopts "t:b:s:c:h" opt; do
  case ${opt} in
    t) msgTitle="$OPTARG"
    ;;
    b) msgBody="$OPTARG"
    ;;
    c) channelName="$OPTARG"
    ;;
    s) state="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [[ ! "${msgTitle}" ||  ! "${msgBody}" || ! "${channelName}" ]]; then
        echo "all arguments are required"
        echo -e "-t title\n-b body text\n-c channel\n-s status"
        exit 1
fi

color="danger"
if [ "${state}" != "DOWN" ]; then
        color="good"
fi

read -d '' payLoad << EOF
{
        "channel": "#${channelName}",
        "username": "$(hostname)",
        "icon_emoji": "${emojiicon}",
        "attachments": [
            {
                "fallback": "${msgTitle}",
                "color": "${color}",
                "title": "${msgTitle}",
                "fields": [{
                    "value": "${msgBody}",
                    "short": false
                }]
            }
        ]
    }
EOF


statusCode=$(curl \
        --write-out %{http_code} \
        --silent \
        --output /dev/null \
        -X POST \
        -H 'Content-type: application/json' \
        --data "${payLoad}" ${webhook})

#echo ${statusCode}

exit 0;
