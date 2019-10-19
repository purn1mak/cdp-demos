# cdp-demos
CDP Demos

# Setup

## Setup aws cli
Follow instructions given at: https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html

```
pip3 --version
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
pip3 install awscli --upgrade --user
```

To upgrade to the latest version
```
pip3 install awscli --upgrade --user
```

## Install cdp cli
This is required to interact with the "public" APIs of CDP.

```
./install_cdp_cli.sh # installs most recent cdp cli build

# Generate API keys from UI - https://cloudera.dps.mow-dev.cloudera.com"
./cdpclienv/bin/cdp configure

# Ensure that for the mow-dev profile to set the correct api endpoints
vi ~/.cdp/config
# Add the following under [default]
endpoint_url = https://%sapi.thunderhead-dev.cloudera.com/
cdp_endpoint_url = https://console.dps.mow-dev.cloudera.com/

# Check that cdp cli is working
./cdpclienv/bin/cdp iam get-user
```

## Usage

* `git clone --recursive https://https://github.com/purn1mak/cdp-demos`
* `cd cdp-demos`
* `./install_cdp_cli.sh`
* `./create_role.sh `
* `./cleanup.sh`
