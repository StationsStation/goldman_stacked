# Base
forge script scripts/SetReceiveConfigBaseLz.s.sol:SetReceiveConfigBaseLz --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY --broadcast

# Base to Hedera Send
forge script scripts/SetSendConfigBaseHedera.s.sol:SetSendConfigBaseHedera --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY --broadcast

# Hedera to Base Receive
forge script scripts/SetReceiveConfigHederaBase.s.sol:SetReceiveConfigHederaBase --rpc-url https://mainnet.hashio.io/api --private-key $PRIVATE_KEY --broadcast

# Hedera to Base Send
forge script scripts/SetSendConfigHederaBase.s.sol:SetSendConfigHederaBase --rpc-url https://mainnet.hashio.io/api --private-key $PRIVATE_KEY --broadcast

# Polygon lzRead
#forge script scripts/SetSendConfigPolygonLz.s.sol:SetSendConfigPolygonLz --rpc-url https://polygon-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY_MATIC --private-key $PRIVATE_KEY --broadcast
forge script scripts/SetReceiveConfigPolygonLz.s.sol:SetReceiveConfigPolygonLz --rpc-url https://polygon-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY_MATIC --private-key $PRIVATE_KEY --broadcast

# Arbitrum lzRead
forge script scripts/SetReceiveConfigArbitrumLz.s.sol:SetReceiveConfigArbitrumLz --rpc-url https://arb1.arbitrum.io/rpc --private-key $PRIVATE_KEY --broadcast


# Propose on Base
forge script scripts/CallProposeBase.s.sol:CallProposeBase --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY --broadcast

# Cast vote on Polygon
forge script scripts/LzReadVotePolygon.s.sol:LzReadVotePolygon --rpc-url https://polygon-mainnet.g.alchemy.com/v2/$ALCHEMY_API_KEY_MATIC  --private-key $PRIVATE_KEY --broadcast

# Cast vote on Arbitrum
forge script scripts/LzReadVoteArbitrum.s.sol:LzReadVoteArbitrum --rpc-url https://arb1.arbitrum.io/rpc  --private-key $PRIVATE_KEY --broadcast

# Finalize on Base
forge script scripts/LzReruceFinalizeVotesBase.s.sol:LzReruceFinalizeVotesBase --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY --broadcast