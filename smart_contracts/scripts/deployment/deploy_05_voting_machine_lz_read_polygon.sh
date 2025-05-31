#!/bin/bash

# Read variables using jq
chainId=$(jq -r '.chainId' scripts/deployment/globals_polygon_mainnet.json)
networkURL=$(jq -r '.networkURL' scripts/deployment/globals_polygon_mainnet.json)

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

endpointV2Address=$(jq -r '.endpointV2Address' scripts/deployment/globals_polygon_mainnet.json)
votingTokenAddress=$(jq -r '.votingTokenAddress' scripts/deployment/globals_polygon_mainnet.json)
governorChainId=$(jq -r '.governorChainId' scripts/deployment/globals_polygon_mainnet.json)

contractPath="smart_contracts/src/VotingMachineLzRead.sol:VotingMachineLzRead"
constructorArgs="$endpointV2Address $votingTokenAddress $governorChainId"
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
votingMachineLzReadAddress=$(echo "$deploymentOutput" | grep 'Deployed to:' | awk '{print $3}')

# Get output length
outputLength=${#votingMachineLzReadAddress}

# Check for the deployed address
if [ $outputLength != 42 ]; then
  echo "!!! The contract was not deployed, aborting..."
  exit 0
fi

# Write new deployed contract back into JSON
echo "$(jq '. += {"votingMachineLzReadAddress":"'$votingMachineLzReadAddress'"}' scripts/deployment/globals_polygon_mainnet.json)" > scripts/deployment/globals_polygon_mainnet.json

  echo "Verifying contract..."
  forge verify-contract \
    --chain-id "$chainId" \
    --etherscan-api-key "$ETHERSCAN_API_KEY" \
    "$votingMachineLzReadAddress" \
    "$contractPath" \
    --constructor-args $(cast abi-encode "constructor(address,address,uint256)" $constructorArgs)

echo "Contract deployed at: $votingMachineLzReadAddress"