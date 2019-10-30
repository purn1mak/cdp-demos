#!/usr/bin/env bash

set -eu

CDP_CLI_BUILD_URL="https://build.service-delivery.cloudera.com/view/CDPCP/job/cdpcp-cli-external-dev-build"
CDP_CLI_LATEST_BUILD_URL="$CDP_CLI_BUILD_URL/lastSuccessfulBuild/artifact/$(curl -s "$CDP_CLI_BUILD_URL/lastSuccessfulBuild/api/json" | python -c "import json,sys;print([artifact['relativePath'] for artifact in json.load(sys.stdin)['artifacts'] if artifact['fileName'].endswith('.tar.gz')][0])")"

rm -rf cdpclienv
virtualenv -p python3 cdpclienv
source cdpclienv/bin/activate
pip install "$CDP_CLI_LATEST_BUILD_URL"

echo "cdp cli $(./cdpclienv/bin/cdp --version) installed to ./cdpclienv/bin/cdp"#!/usr/bin/env bash