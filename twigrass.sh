#! /usr/bin/env bash
#shellcheck disable=SC2153,SC2086,SC1083

readonly twitter_user="${TWITTER_USER_NAME}"
readonly pixela_user="${PIXELA_USER_NAME}"
readonly pixela_graph_id="${PIXELA_GRAPH_ID}"
readonly pixela_token="${PIXELA_USER_TOKEN}"

declare data
data="$(curl -s "https://twilog.org/${twitter_user}/stats")"

mapfile -t tweets < <(grep ^'ar_data\[1\]' <<<"${data}" | sed 's/^.*\[1\] = \[//;s/\]\;//;s/,/\n/g;s/\t//g' | tac 2>/dev/null)
mapfile -t dates < <(grep ^'ar_lbl\[1\]' <<<"${data}" | sed "s/^.*\[1\] = \[//;s/\]\;//;s/'//g;s/,/\n/g;s/\t//g" | tac 2>/dev/null)

if [[ ! -e ./dates_cache.txt ]]; then
  for ((i = 0; i < "${#dates[@]}"; i++)); do
    [[ "${i}" != "0" ]] && echo ""
    echo https://pixe.la/v1/users/"${pixela_user}"/graphs/"${pixela_graph_id}"/20${dates[i]} { \"quantity\": \""${tweets[i]}"\"} &&
      curl -s -X PUT \
        -H "X-USER-TOKEN:${pixela_token}" \
        -d '{ "quantity": "'"${tweets[i]}"'"}' \
        "https://pixe.la/v1/users/${pixela_user}/graphs/${pixela_graph_id}/20${dates[i]}" &&
      sleep 1
  done
else
  mapfile -t dates_cache < <(tr ' ' \\n <./dates_cache.txt)
  unset "dates_cache[0]"
  dates_cache=("${dates_cache[@]}")
  mapfile -t dates_diff < <({
    echo "${dates_cache[@]}"
    echo "${dates[@]}"
  } | tr ' ' \\n | sort | uniq -u | tac)
  for ((i = 0; i < "${#dates_diff[@]}"; i++)); do
    echo https://pixe.la/v1/users/"${pixela_user}"/graphs/"${pixela_graph_id}"/20${dates_diff[i]} { \"quantity\": \""${tweets[i]}"\"} &&
      curl -s -X PUT \
        -H "X-USER-TOKEN:${pixela_token}" \
        -d '{ "quantity": "'"${tweets[i]}"'"}' \
        "https://pixe.la/v1/users/${pixela_user}/graphs/${pixela_graph_id}/20${dates_diff[i]}" &&
      sleep 1
  done
fi

echo "${dates[@]}" >./dates_cache.txt
