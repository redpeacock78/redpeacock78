#! /usr/bin/env bash
#shellcheck disable=SC2153,SC2086

readonly twitter_user="${TWITTER_USER_NAME}"
readonly pixela_user="${PIXELA_USER_NAME}"
readonly pixela_graph_id="${PIXELA_GRAPH_ID}"
readonly pixela_token="${PIXELA_USER_TOKEN}"

declare data
data="$(curl -s "https://twilog.org/${twitter_user}/stats")"

mapfile -t tweets < <(grep ^'ar_data\[1\]' <<<"${data}" | sed 's/^.*\[1\] = \[//;s/\]\;//;s/,/\n/g' | tac 2>/dev/null | head -n365)
mapfile -t dates < <(grep ^'ar_lbl\[1\]' <<<"${data}" | sed "s/^.*\[1\] = \[//;s/\]\;//;s/'//g;s/,/\n/g" | tac 2>/dev/null | head -n365)

for ((i = 0; i < "${#tweets[@]}"; i++)); do
  [[ "${i}" != "0" ]] && echo ""
  echo https://pixe.la/v1/users/"${pixela_user}"/graphs/"${pixela_graph_id}"/20${dates[i]} { \"quantity\": \""${tweets[i]}"\"}
  curl -s -X PUT \
    -H "X-USER-TOKEN:${pixela_token}" \
    -d '{ "quantity": "'"${tweets[i]}"'"}' \
    "https://pixe.la/v1/users/${pixela_user}/graphs/${pixela_graph_id}/20${dates[i]}" &&
    sleep 2
done
