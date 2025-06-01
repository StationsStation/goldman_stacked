#!/bin/bash

# Read variables using jq
networkURL=$(jq -r '.networkURL' scripts/deployment/globals_base_mainnet.json)


myGovernorAddress=$(jq -r '.myGovernorAddress' scripts/deployment/globals_base_mainnet.json)
governorRelayLZAddress=$(jq -r '.governorRelayLZAddress' scripts/deployment/globals_base_mainnet.json)
votingMachineLzReadPolygonAddress=$(jq -r '.votingMachineLzReadPolygonAddress' scripts/deployment/globals_base_mainnet.json)
votingMachineLzReadArbitrumAddress=$(jq -r '.votingMachineLzReadArbitrumAddress' scripts/deployment/globals_base_mainnet.json)
votingMachineLzReadHederaAddress=$(jq -r '.votingMachineLzReadHederaAddress' scripts/deployment/globals_base_mainnet.json)

# Get deployer on the private key
echo "Using PRIVATE_KEY: ${PRIVATE_KEY:0:6}..."
walletArgs="--private-key $PRIVATE_KEY"
deployer=$(cast wallet address $walletArgs)

# Deployment message
echo "Casting from: $deployer"

castHeader="cast send --rpc-url $networkURL$API_KEY $walletArgs"

# Change governor
castArgs="$governorRelayLZAddress changeGovernor(address) $myGovernorAddress"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Change voting machines
castArgs="$governorRelayLZAddress changeVotingMachines(address[]) [0x${votingMachineLzReadArbitrumAddress:26:55},0x${votingMachineLzReadPolygonAddress:26:55},0x${votingMachineLzReadHederaAddress:26:55}]"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"
