echo -n -e "${C2}${userName}:${C6} "
read prompt
echo ""
echo -e -n "${C2}Euria:${C6} "

raw_response=$(curl -k -sS "https://euria.infomaniak.com/api/1/accounts/${userId}/conversations" \
  -b "SASESSION=${sasessionToken}; EURIA-API-XSRF-TOKEN=${euriaApiToken}" \
  -H 'Origin: https://euria.infomaniak.com' \
  -H 'Referer: https://euria.infomaniak.com/' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  --data-raw "{\"content\":\"${prompt}\",\"file_ids\":[],\"tools\":[\"faq_search\",\"web_search\"],\"model\":\"${model}\"}")

json_response=$(echo "$raw_response" | grep -o 'data: {.*}' | sed 's/^data: //')
conversationsId=$(echo "$json_response" | jq -r 'select(.message.role=="user") | .message.parent_id' | head -1)
parentRespondId=$(echo "$json_response" | jq -r 'select(.message.role=="assistant") | .message.id' | head -1)
respons=$(echo "$json_response" | jq -r 'select(.choices != null) | .choices[0].delta.content // empty' | tr -d '\n')

echo -e "$respons"

echo "conversationsId : $conversationsId" > conections.dat
echo "prompt          : $prompt" >> conections.dat
echo "parentRespondId : $parentRespondId" >> conections.dat

echo $raw_response > respons.txt
read