#!/bin/bash

# Read variables using jq
chainId=$(jq -r '.chainId' scripts/deployment/globals_hedera_mainnet.json)
networkURL=$(jq -r '.networkURL' scripts/deployment/globals_hedera_mainnet.json)

endpointV2Address=$(jq -r '.endpointV2Address' scripts/deployment/globals_hedera_mainnet.json)
governorChainId=$(jq -r '.governorChainId' scripts/deployment/globals_hedera_mainnet.json)
governorRelayLZAddress=$(jq -r '.governorRelayLZAddress' scripts/deployment/globals_hedera_mainnet.json)
votingMachineLzReadAddress=$(jq -r '.votingMachineLzReadAddress' scripts/deployment/globals_hedera_mainnet.json)

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

# Set send libraries
castArgs="$endpointV2Address setSendLibrary(address,uint32,address) $votingMachineLzReadAddress $governorChainId 0x2367325334447C5E1E0f1b3a6fB947b262F58312"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Set receive libraries
castArgs="$endpointV2Address setReceiveLibrary(address,uint32,address,uint256) $votingMachineLzReadAddress $governorChainId 0xc1B621b18187F74c8F6D52a6F709Dd2780C09821 0"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"
