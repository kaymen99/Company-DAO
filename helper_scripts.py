from web3.main import Web3
from brownie import ERC20Faucet, config, network, accounts, Contract, interface



LOCAL_BLOCKCHAINS = ["ganache-local", "development"]

FORKED_BLOCHCHAINS = ["mainnet-fork", "mainnet-fork-dev"]

ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"


def get_account(index=None):
    if (
        network.show_active() in LOCAL_BLOCKCHAINS
        or network.show_active() in FORKED_BLOCHCHAINS
    ):
        if index is not None:
            return accounts[index]
        else:
            return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def toWei(amount):
    return Web3.toWei(amount, "ether")


def fromWei(amount):
    return Web3.fromWei(amount, "ether")
 
def get_contract(_contract, contract_address):
    contract = Contract.from_abi(_contract._name, contract_address, _contract.abi)
    return contract

def approve_erc20(erc20_address, spender, amount, account):
    erc20 = interface.IERC20(erc20_address)
    approve_tx = erc20.approve(spender, amount, {"from": account})
    approve_tx.wait(1)

    print("----- Erc20 approved -----")

def get_erc20_balance(erc20_address, account):
    return interface.IERC20(erc20_address).balanceOf(account)


def mint_erc20(erc20_token, amount, account):

    uniswap_router_address = config["networks"][network.show_active()]["uniswap-router"]

    erc20_faucet = ERC20Faucet.deploy(uniswap_router_address, erc20_token, {"from": account})

    mint_erc20_tx = erc20_faucet.swapETHtoERC20({"from": account, "value": amount})
    mint_erc20_tx.wait(1)

    print(f"erc20 balance: {fromWei(get_erc20_balance(erc20_token, account))} erc20")