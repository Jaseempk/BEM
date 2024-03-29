-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_KEY := fbf992b0e25ad29c85aae3d69fcb7f09240dd2588ecee449a4934b9e499102cc

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install Cyfrin/foundry-devops@0.0.11 --no-commit --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install openzeppelin/openzeppelin-contracts@v4.8.3 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url https://eth-sepolia.g.alchemy.com/v2/fWr3m1Bq4Mqxz0n-WoE86aq24VsXTsrq --private-key $(DEFAULT_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(ALCHEMY_RPC_URL) --private-key $(METAMASK_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployBemToken.s.sol:DeployBemToken $(NETWORK_ARGS)
	@forge script script/DeployBemPresale.s.sol:DeployBemPresale $(NETWORK_ARGS)
	@forge script script/DeployBemVesting.s.sol:DeployBemVesting $(NETWORK_ARGS)
	@forge script script/DeployBemStaking.s.sol:DeployBemStaking $(NETWORK_ARGS)

# cast abi-encode "constructor(uint256)" 1000000000000000000000000 -> 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000
# Update with your contract address, constructor arguments and anything else
verify:
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch --etherscan-api-key $(ETHERSCAN_API_KEY) --compiler-version 0.8.21+commit.d9974bed 0x38bf30a1F7B528A3f1261f41B2843451CD8574D9 src/Bem.sol:BemToken
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch --constructor-args 0x0000000000000000000000000000000000000000000000008ac7230489e800000000000000000000000000000000000000000000000000000001c6bf52634000000000000000000000000000000000000000000000000000001ff973cafa800000000000000000000000000038bf30a1f7b528a3f1261f41b2843451cd8574d93a66ce04bfa0fac12c5b24f150c3b7b16f81a7ddae4778862490612445a7c5ae --etherscan-api-key $(ETHERSCAN_API_KEY) --compiler-version 0.8.21+commit.d9974bed 0xCB20B79194d3dEeB88df2Dc236adbC93aEf8622a src/BemPresale.sol:BemPresale
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch --constructor-args 0x00000000000000000000000038bf30a1f7b528a3f1261f41b2843451cd8574d9876ae3d088f6a906995a595a1fafcded051dc6ab0aad53df87e9c8543b7a32ee --etherscan-api-key $(ETHERSCAN_API_KEY) --compiler-version 0.8.21+commit.d9974bed 0xfDd00E9377e8121F72A4fe760Bb77f05d838EbF0 src/BemTokenVesting.sol:PresaleTokenVesting
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch --constructor-args 0x00000000000000000000000038bf30a1f7b528a3f1261f41b2843451cd8574d9000000000000000000000000e6f3889c8ebb361fa914ee78fa4e55b1bbed3a96000000000000000000000000000000000000000000000000000000000000000a --etherscan-api-key $(ETHERSCAN_API_KEY) --compiler-version 0.8.21+commit.d9974bed 0xC1D69935301b96A5159BD0c88987f1C93aFB7F28 src/BemStaking.sol:BemStaking


#https://sepolia.etherscan.io/address/0x63ab7157810af3386491b4efbff79bed0aae41da