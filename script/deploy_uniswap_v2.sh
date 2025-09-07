#!/usr/bin/env bash
set -e

# ------------------------
# 配置
# ------------------------
RPC_URL="http://127.0.0.1:8545"
PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
ACCOUNT="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

TOKEN_SUPPLY="1000000000000000000000000"  # 1e24
LIQUIDITY_AMOUNT="1000000000000000000000" # 1e21

# ------------------------
# 1️⃣ 部署 UniswapV2Factory
# ------------------------
echo "Deploying UniswapV2Factory..."
FACTORY_ADDRESS=$(forge create \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  lib/v2-core/contracts/UniswapV2Factory.sol:UniswapV2Factory \
  --constructor-args $ACCOUNT | grep "Deployed to:" | awk '{print $3}')
echo "Factory deployed at: $FACTORY_ADDRESS"

# ------------------------
# 2️⃣ 部署 WETH9
# ------------------------
echo "Deploying WETH9..."
WETH_ADDRESS=$(forge create \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  src/WETH9.sol:WETH9 | grep "Deployed to:" | awk '{print $3}')
echo "WETH deployed at: $WETH_ADDRESS"

# ------------------------
# 3️⃣ 部署 UniswapV2Router02
# ------------------------
echo "Deploying UniswapV2Router02..."
ROUTER_ADDRESS=$(forge create \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  lib/v2-periphery/contracts/UniswapV2Router02.sol:UniswapV2Router02 \
  --constructor-args $FACTORY_ADDRESS $WETH_ADDRESS | grep "Deployed to:" | awk '{print $3}')
echo "Router deployed at: $ROUTER_ADDRESS"


# ------------------------
# 4️⃣ 部署 Multicall
# ------------------------
echo "Deploying Multicall..."
MULTICALL_ADDRESS=$(forge create \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  src/Multicall3.sol:Multicall3 | grep "Deployed to:" | awk '{print $3}')
echo "Multicall deployed at: $MULTICALL_ADDRESS"

# ------------------------
# 4️⃣ 部署两个测试代币
# ------------------------
echo "Deploying TokenA..."
TOKENA_ADDRESS=$(forge create \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  src/MyToken.sol:MyToken \
  --constructor-args "Token A" "TKA" $TOKEN_SUPPLY | grep "Deployed to:" | awk '{print $3}')
echo "TokenA deployed at: $TOKENA_ADDRESS"

echo "Deploying TokenB..."
TOKENB_ADDRESS=$(forge create \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  src/MyToken.sol:MyToken \
  --constructor-args "Token B" "TKB" $TOKEN_SUPPLY | grep "Deployed to:" | awk '{print $3}')
echo "TokenB deployed at: $TOKENB_ADDRESS"

# ------------------------
# 5️⃣ 给 Router 授权代币
# ------------------------
echo "Approving tokens to Router..."
cast send $TOKENA_ADDRESS "approve(address,uint256)" $ROUTER_ADDRESS $LIQUIDITY_AMOUNT --private-key $PRIVATE_KEY --rpc-url $RPC_URL
cast send $TOKENB_ADDRESS "approve(address,uint256)" $ROUTER_ADDRESS $LIQUIDITY_AMOUNT --private-key $PRIVATE_KEY --rpc-url $RPC_URL

# ------------------------
# 6️⃣ 添加流动性
# ------------------------
echo "Adding liquidity..."
cast send $ROUTER_ADDRESS "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)" \
    $TOKENA_ADDRESS $TOKENB_ADDRESS $LIQUIDITY_AMOUNT $LIQUIDITY_AMOUNT 0 0 $ACCOUNT $(( $(date +%s) + 600 )) \
    --private-key $PRIVATE_KEY \
    --rpc-url $RPC_URL

echo "✅ Liquidity added!"

PAIR_ADDRESS=$(cast call $FACTORY_ADDRESS "getPair(address,address)(address)" $TOKENA_ADDRESS $TOKENB_ADDRESS --rpc-url $RPC_URL)
echo "Pair address: $PAIR_ADDRESS"

ALL_PAIRS_LENGTH=$(cast call $FACTORY_ADDRESS "allPairsLength()(uint256)" --rpc-url $RPC_URL)
echo "All pairs length: $ALL_PAIRS_LENGTH"

echo "✅ Uniswap V2 deployment and liquidity provision completed!"
echo "MULTICALL_ADDRESS: $MULTICALL_ADDRESS"
echo "Factory: $FACTORY_ADDRESS"
echo "Router : $ROUTER_ADDRESS"
echo "WETH   : $WETH_ADDRESS"
echo "TokenA : $TOKENA_ADDRESS"
echo "TokenB : $TOKENB_ADDRESS"
