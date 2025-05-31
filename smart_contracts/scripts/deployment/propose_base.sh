#!/bin/bash

# Read variables using jq
networkURL=$(jq -r '.networkURL' scripts/deployment/globals_base_mainnet.json)

votingTokenAddress=$(jq -r '.votingTokenAddress' scripts/deployment/globals_base_mainnet.json)
myGovernorAddress=$(jq -r '.myGovernorAddress' scripts/deployment/globals_base_mainnet.json)
governanceExecutorAddress=$(jq -r '.governanceExecutorAddress' scripts/deployment/globals_base_mainnet.json)

# Get deployer on the private key
echo "Using PRIVATE_KEY: ${PRIVATE_KEY:0:6}..."
walletArgs="--private-key $PRIVATE_KEY"
deployer=$(cast wallet address $walletArgs)

# Deployment message
echo "Casting from: $deployer"

castHeader="cast send --rpc-url $networkURL$API_KEY $walletArgs"

# Propose
makerAsset=$votingTokenAddress
takerAsset=$votingTokenAddress
makingAmount=100
takingAmount=100
predicate="0x1111"
permit="0x1111"
interaction="0x1111"
limitOrderPayload=$(cast abi-encode "execute(address,address,uint256,uint256,bytes,bytes,bytes)" $makerAsset $takerAsset $makingAmount $takingAmount $predicate $permit $interaction)
echo $limitOrderPayload

castArgs="$myGovernorAddress propose(address[],uint256[],bytes[],string) [$governanceExecutorAddress] [0] [$limitOrderPayload] 'Limit order'"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"
