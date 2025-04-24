#!/usr/bin/env bash
set -e
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

readonly DIR

ERRORS=()

# find all executables and run `shellcheck`
for f in $(find "${DIR}/../" -type f -not -path '*.git*' -not -name "Taskfile.yaml" | sort -u); do
	if file "$f" | grep --quiet shell; then
		{
			shellcheck "$f" && echo "[OK]: successfully linted $f"
		} || {
			# add to errors
			ERRORS+=("$f")
		}
	fi
done

if [ ${#ERRORS[@]} -eq 0 ]; then
	echo "No errors, hooray!🎉"
else
	echo "These files failed shellcheck: ${ERRORS[*]}"
	exit 1
fi
