set -e

if [ "$#" -ne 7 ]; then
  echo "Usage: post_message.sh <SLACK_BOT_TOKEN> <CHANNEL_ID> <THREAD_TS> <BROADCAST> <TEXT> <BLOCKS> <UPDATE>"
  exit 1
fi

slackBotToken=$1
channel=$2
threadTs=$3
broadcastReply=$4
text=$5
blocks=$6
update=$7

ts_key="thread_ts"

if [ "$update" = "true" ]; then
  if [ "$threadTs" = "" ]; then
    echo "thread-ts is mandatory when update = true";
    exit 1;
  fi;
  url=https://slack.com/api/chat.update;
  ts_key="ts"
else
  url=https://slack.com/api/chat.postMessage;
fi;

function postMessage() {
  payload="{
    \"channel\": \"$channel\",
    \"text\": \"$text\",
    \"$ts_key\": \"$threadTs\",
    \"reply_broadcast\": $broadcastReply,
    \"blocks\": $blocks
  }"
  echo $payload | jq '.'

  result=$(\
    curl -X POST -H "Content-type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $slackBotToken" \
    -d "$payload" \
    $url\
  )
}

postMessage
echo $result | jq '.'

ts=$(echo $result | jq -r '.ts')
channel_id=$(echo $result | jq -r '.channel')
echo ::set-output name=ts::$ts
echo ::set-output name=channel::$channel_id

test "$(echo $result | jq -r '.ok')" == "true"
