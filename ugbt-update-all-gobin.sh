#!/usr/bin/env bash

set -eEuo pipefail

binaries_to_skip=( )

# extract the gobin for verification
dir=${searchdir:-$(go env GOBIN)}
if ! [[ -d "${dir}" ]]; then
	echo "GOBIN is incorrectly set, verify it point to a valid directory"
	exit 1
fi

# FORCE variable for auto updating
FORCE=${FORCE:-}

# section to make sure required binaries exist
reuqired_binaries=(
  go
  ugbt
)
missing_binaries=()
## first pass on binaries (so if a bunch of them are missing it'll update once
for required_binary in "${reuqired_binaries[@]}" ; do
  if ! which "${required_binary}" >/dev/null 2>&1; then
    missing_binaries+=( "$required_binary" ) 
  fi
done

## send bulk message on missing binaires
if [[ "${#missing_binaries[@]}" -ne 0 ]]; then 
	echo "binaries required for operation missing, please install: '${missing_binaries[*]}'"
	exit 1
fi

while IFS= read -r -d '' binary_to_check
do
  # if file is in 'binaies_to_skip; skip it
  if [[ "${binaries_to_skip[*]}" =~ "$(basename "${binary_to_check}")" ]]; then
    echo "skipping $(basename "${binary_to_check}")"
    continue
  fi
  echo -n "$(basename "${binary_to_check}"): "
  ugbt update "${binary_to_check}"
done < <(find "${dir}" -type f -print0)
