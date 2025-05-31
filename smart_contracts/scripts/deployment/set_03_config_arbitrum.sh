#!/bin/bash

# Read variables using jq
chainId=$(jq -r '.chainId' scripts/deployment/globals_arbitrum_mainnet.json)
networkURL=$(jq -r '.networkURL' scripts/deployment/globals_arbitrum_mainnet.json)

endpointV2Address=$(jq -r '.endpointV2Address' scripts/deployment/globals_arbitrum_mainnet.json)
governorChainId=$(jq -r '.governorChainId' scripts/deployment/globals_arbitrum_mainnet.json)
governorRelayLZAddress=$(jq -r '.governorRelayLZAddress' scripts/deployment/globals_arbitrum_mainnet.json)
votingMachineLzReadAddress=$(jq -r '.votingMachineLzReadAddress' scripts/deployment/globals_arbitrum_mainnet.json)

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
castArgs="$endpointV2Address setSendLibrary(address,uint32,address) $votingMachineLzReadAddress $governorChainId 0x975bcD720be66659e3EB3C0e4F1866a3020E493A"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Set receive libraries
castArgs="$endpointV2Address setReceiveLibrary(address,uint32,address,uint256) $votingMachineLzReadAddress $governorChainId 0x7B9E184e07a6EE1aC23eAe0fe8D6Be2f663f05e6 0"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Read channel libraries setup
castArgs="$endpointV2Address setSendLibrary(address,uint32,address) $votingMachineLzReadAddress 4294967295 0xbcd4CADCac3F767C57c4F402932C4705DF62BEFf"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

castArgs="$endpointV2Address setReceiveLibrary(address,uint32,address,uint256) $votingMachineLzReadAddress 4294967295 0xbcd4CADCac3F767C57c4F402932C4705DF62BEFf 0"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"
