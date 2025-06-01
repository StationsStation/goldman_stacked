#!/bin/bash

# Read variables using jq
chainId=$(jq -r '.chainId' scripts/deployment/globals_base_mainnet.json)
networkURL=$(jq -r '.networkURL' scripts/deployment/globals_base_mainnet.json)

# Check for Polygon keys only since on other networks those are not needed
if [ $chainId == 137 ]; then
  API_KEY=$ALCHEMY_API_KEY_MATIC
  if [ "$API_KEY" == "" ]; then
      echo "set ALCHEMY_API_KEY_MATIC env variable"
      exit 0
  fi
elif [ $chainId == 80002 ]; then
    API_KEY=$ALCHEMY_API_KEY_AMOY
    if [ "$API_KEY" == "" ]; then
        echo "set ALCHEMY_API_KEY_AMOY env variable"
        exit 0
    fi
fi

timelockAddress=$(jq -r '.timelockAddress' scripts/deployment/globals_base_mainnet.json)

contractPath="smart_contracts/src/GovernanceExecutor.sol:GovernanceExecutor"
constructorArgs="$timelockAddress"
contractArgs="$contractPath --constructor-args $constructorArgs"

# Get deployer on the private key
echo "Using PRIVATE_KEY: ${PRIVATE_KEY:0:6}..."
walletArgs="--private-key $PRIVATE_KEY"
deployer=$(cast wallet address $walletArgs)

# Deployment message
echo "Deploying from: $deployer"
echo "Deployment of: $contractArgs"

# Deploy the contract and capture the address
execCmd="forge create --broadcast --rpc-url $networkURL$API_KEY $walletArgs $contractArgs"
deploymentOutput=$($execCmd)
governanceExecutorAddress=$(echo "$deploymentOutput" | grep 'Deployed to:' | awk '{print $3}')

# Get output length
outputLength=${#governanceExecutorAddress}

# Check for the deployed address
if [ $outputLength != 42 ]; then
  echo "!!! The contract was not deployed, aborting..."
  exit 0
fi

# Write new deployed contract back into JSON
echo "$(jq '. += {"governanceExecutorAddress":"'$governanceExecutorAddress'"}' scripts/deployment/globals_base_mainnet.json)" > scripts/deployment/globals_base_mainnet.json

  echo "Verifying contract..."
  forge verify-contract \
    --chain-id "$chainId" \
    --etherscan-api-key "$ETHERSCAN_API_KEY" \
    "$governanceExecutorAddress" \
    "$contractPath" \
    --constructor-args $(cast abi-encode "constructor(address)" $constructorArgs)

echo "Contract deployed at: $governanceExecutorAddress"