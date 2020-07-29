#!/usr/bin/env bash
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
conf_file="${dir}/.conf"

function conf_prop {
  prop=$1
  cat $conf_file | grep -i "$prop=" | cut -d"=" -f2
}

function get_repo_urls {
  local tmp=`mktemp`

  local type=$1
  local name=$2
  local cred=$3
  
  local clone_from="clone_url"

  local url_base="https://api.github.com"
  local url_tail="repos?per_page=100"
  local url="${url_base}/${type}/${name}/${url_tail}"

  local curl_args="-s"

  if [[ -n "$cred" ]]
  then
    curl_args="$curl_args -u $cred"

    if [[ "$type" == "users" ]]
    then
      clone_from="ssh_url"
      url="${url_base}/user/${url_tail}"
    fi
  fi

  while [ -n "$url" ]; do
    curl $curl_args --dump-header "$tmp" "$url"
    url="`< "$tmp" grep Link | grep -oE "[a-zA-Z0-9:/?=.&_]*>; rel=.next" | cut -d'>' -f1`"
  done | grep "$clone_from" | cut -d'"' -f4 | while read url;
  do
    echo $url
  done
}

function mirror_repos {
  local repos=$@
  for repo in $repos
  do
    project=`basename "$repo"`
    echo "Mirroring $project"
    if [ -d "$project" ]; 
    then
      cd "$project"
      git fetch --prune
      cd ..
    else
      git clone --mirror "$repo" "$project"
    fi
  done
}

if [[ ! -e "$conf_file" ]]
then
  echo "No configuration exists."
  echo "Please create a file named '.conf' in $dir."
  echo "Here is an example of the format used by the file:"
  echo "- - - - - "
  echo "TYPE=orgs|users"
  echo "NAME=orgname|username"
  echo "CRED=username:apikey"
  echo "- - - - - "
  echo ""
  echo "Aborting."
  exit 1
fi

NAME=`conf_prop NAME`
TYPE=`conf_prop TYPE`
CRED=`conf_prop CRED`

if [[ -z "$NAME" || -z "$TYPE" ]]
then
   echo "NAME or TYPE is empty, need both to continue."
   echo "Aborting."
   exit 1
fi

repos=`get_repo_urls "$TYPE" "$NAME" "$CRED"`
mirror_repos $repos
