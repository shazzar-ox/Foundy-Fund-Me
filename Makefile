-include .env
build:; forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --broadcast --private-key $(SEPOLIA_PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_KEY) -vvvv 