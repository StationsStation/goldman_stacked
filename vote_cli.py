"""
Simple CLI for voting on proposals.
"""

import click
from web3 import Web3
from eth_account import Account

with open("controller_api/abi.json", encoding="utf-8") as file:
    ABI = file.read()

with open("ethereum_private_key.txt", encoding="utf-8") as file:
    PRIVATE_KEY = file.read()

account = Account.from_key(PRIVATE_KEY)

@click.command()
@click.option('--rpc', required=True, help='The RPC URL.')
@click.option('--address', required=True, help='The address of the governor contract.')
@click.option('--proposal-id', required=True, help='The ID of the proposal to act on.')
@click.option('--action', type=click.Choice(['vote', 'cancel'], case_sensitive=False), required=True, help='Action to take on the proposal.')
def vote(rpc, address, proposal_id, action):
    """Vote on a proposal."""
    click.echo(f"Voting to {action} proposal {proposal_id}")
    click.echo(f"Voting from {account.address}")

    w3 = Web3(Web3.HTTPProvider(rpc))
    contract = w3.eth.contract(address=address, abi=ABI)

    if action == 'vote':
        tx_hash = contract.functions.castVote(int(proposal_id), 1).transact({'from': account.address})
        print(f"Transaction sent: {tx_hash.hex()}")
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        print(f"Transaction receipt: {receipt}")


    elif action == 'cancel':
        tx_hash = contract.functions.cancel(int(proposal_id)).transact({'from': account.address})
        print(f"Transaction sent: {tx_hash.hex()}")
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        print(f"Transaction receipt: {receipt}")


if __name__ == '__main__':
    vote()
