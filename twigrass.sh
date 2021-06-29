#! /usr/bin/env bash

readonly twitter_user="${twitter_user_name}"
readonly pixela_user="${pixela_user_name}"
readonly pixela_graph_id="${graph_id}"
readonly pixela_token="${pixela_user_token}"

data="$(curl -s "https://twilog.org/${twitter_user}/stats")"

tweets=($(grep ^'ar_data\[1\]' <<<"${data}"|sed 's/^.*\[1\] = \[//;s/\]\;//;s/,/\n/g'|tac|head -n365))
dates=($(grep ^'ar_lbl\[1\]' <<<"${data}"|sed "s/^.*\[1\] = \[//;s/\]\;//;s/'//g;s/,/\n/g"|tac|head -n365))

for ((i=0; i<"${#tweets[@]}"; i++)); do
  if [[ "${i}" != "0" ]]; then
    echo ""
  fi
  echo https://pixe.la/v1/users/"${pixela_user}"/graphs/"${pixela_graph_id}"/20${dates[i]} { \"quantity\": \""${tweets[i]}"\"}
  curl -s -X PUT \
    -H "X-USER-TOKEN:${pixela_token}" \
    -d '{ "quantity": "'"${tweets[i]}"'"}' \
    "https://pixe.la/v1/users/${pixela_user}/graphs/${pixela_graph_id}/20${dates[i]}"
    sleep 2
done
