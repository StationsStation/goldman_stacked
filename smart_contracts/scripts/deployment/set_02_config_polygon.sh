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
governorChainId=$(jq -r '.governorChainId' scripts/deployment/globals_polygon_mainnet.json)
governorRelayLZAddress=$(jq -r '.governorRelayLZAddress' scripts/deployment/globals_polygon_mainnet.json)
votingMachineLzReadAddress=$(jq -r '.votingMachineLzReadAddress' scripts/deployment/globals_polygon_mainnet.json)

# Get deployer on the private key
echo "Using PRIVATE_KEY: ${PRIVATE_KEY:0:6}..."
walletArgs="--private-key $PRIVATE_KEY"
deployer=$(cast wallet address $walletArgs)

# Deployment message
echo "Casting from: $deployer"

castHeader="cast send --rpc-url $networkURL$API_KEY $walletArgs"

# Base set peer
castArgs="$votingMachineLzReadAddress setPeer(uint32,bytes32) $governorChainId $governorRelayLZAddress"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Read channel set true
castArgs="$governorRelayLZAddress setReadChannel(uint32,bool) 4294967295 true"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Set send libraries
castArgs="$endpointV2Address setSendLibrary(address,uint32,address) $votingMachineLzReadAddress $governorChainId 0x6c26c61a97006888ea9E4FA36584c7df57Cd9dA3"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Set receive libraries
castArgs="$endpointV2Address setReceiveLibrary(address,uint32,address,uint256) $votingMachineLzReadAddress $governorChainId 0x1322871e4ab09Bc7f5717189434f97bBD9546e95 0"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Read channel libraries setup
castArgs="$endpointV2Address setSendLibrary(address,uint32,address) $votingMachineLzReadAddress 4294967295 0xc214d690031d3f873365f94d381d6d50c35aa7fa"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

castArgs="$endpointV2Address setReceiveLibrary(address,uint32,address,uint256) $votingMachineLzReadAddress 4294967295 0xc214d690031d3f873365f94d381d6d50c35aa7fa 0"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"
