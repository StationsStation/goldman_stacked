#!/bin/bash

# Read variables using jq
chainId=$(jq -r '.chainId' scripts/deployment/globals_base_mainnet.json)
networkURL=$(jq -r '.networkURL' scripts/deployment/globals_base_mainnet.json)

endpointV2Address=$(jq -r '.endpointV2Address' scripts/deployment/globals_base_mainnet.json)
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

# Polygon set peer
castArgs="$governorRelayLZAddress setPeer(uint32,bytes32) 30109 $votingMachineLzReadPolygonAddress"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Arbitrum set peer
castArgs="$governorRelayLZAddress setPeer(uint32,bytes32) 30110 $votingMachineLzReadArbitrumAddress"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Hedera set peer
castArgs="$governorRelayLZAddress setPeer(uint32,bytes32) 30316 $votingMachineLzReadHederaAddress"
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
castArgs="$endpointV2Address setSendLibrary(address,uint32,address) $governorRelayLZAddress 30109 0xB5320B0B3a13cC860893E2Bd79FCd7e13484Dda2"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

castArgs="$endpointV2Address setSendLibrary(address,uint32,address) $governorRelayLZAddress 30110 0xB5320B0B3a13cC860893E2Bd79FCd7e13484Dda2"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

castArgs="$endpointV2Address setSendLibrary(address,uint32,address) $governorRelayLZAddress 30316 0xB5320B0B3a13cC860893E2Bd79FCd7e13484Dda2"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Set receive libraries
castArgs="$endpointV2Address setReceiveLibrary(address,uint32,address,uint256) $governorRelayLZAddress 30109 0xc70AB6f32772f59fBfc23889Caf4Ba3376C84bAf 0"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

castArgs="$endpointV2Address setReceiveLibrary(address,uint32,address,uint256) $governorRelayLZAddress 30110 0xc70AB6f32772f59fBfc23889Caf4Ba3376C84bAf 0"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

castArgs="$endpointV2Address setReceiveLibrary(address,uint32,address,uint256) $governorRelayLZAddress 30316 0xc70AB6f32772f59fBfc23889Caf4Ba3376C84bAf 0"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

# Read channel libraries setup
castArgs="$endpointV2Address setSendLibrary(address,uint32,address) $governorRelayLZAddress 4294967295 0x1273141a3f7923AA2d9edDfA402440cE075ed8Ff"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"

castArgs="$endpointV2Address setReceiveLibrary(address,uint32,address,uint256) $governorRelayLZAddress 4294967295 0x1273141a3f7923AA2d9edDfA402440cE075ed8Ff 0"
castCmd="$castHeader $castArgs"
result=$($castCmd)
echo $castArgs
echo "$result" | grep "status" | awk "{print $1}"
