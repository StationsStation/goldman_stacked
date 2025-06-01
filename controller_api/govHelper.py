"""Module to get data from governance contract and subgraph."""

import os

import requests
from web3 import Web3
from dotenv import load_dotenv


load_dotenv()

RPC = "https://base.drpc.org"
with open("abi.json", encoding="utf-8") as file:
    ABI = file.read()

ADDRESS = "0xE5Da5F4d8644A271226161a859c1177C5214c54e"


BASE_URL = os.environ.get("PONDER_API_URL", "http://localhost:42069")

PONDER_URL = f"{BASE_URL}/graphql"
HEADERS = {"Content-Type": "application/json"}

w3 = Web3(Web3.HTTPProvider(RPC))
governor_contract = w3.eth.contract(address=ADDRESS, abi=ABI)


def get_proposals() -> list[dict]:
    """Get all proposals."""
    query = """
    {
        proposals(orderBy:"proposalId", orderDirection: "desc") {
            items {
                proposalId
                description
                status
                createdBy
            }
        }
    }
    """

    response = requests.post(PONDER_URL, json={"query": query}, headers=HEADERS, timeout=60)

    proposals = response.json()["data"]["proposals"]["items"]
    for proposal in proposals:
        try:
            status = governor_contract.functions.state(int(proposal["proposalId"])).call()
            proposal["status"] = status
        except Exception as e:
            error_message = str(e.args[0])  # Get the error message
            if 'Proposal voting has ended, but was not finalized yet' in error_message:
                proposal["status"] = "Ended"
            else:
                proposal["status"] = "unknown"
        votes = get_votes(proposal["proposalId"])
        proposal["votes"] = votes

    return proposals


def get_votes(proposal_id: str) -> list[dict]:
    """Get votes for proposal_id."""
    query = f"""
    {{
        votes(where:{{proposalId: "{proposal_id}"}}, orderBy:"voter", orderDirection: "desc") {{
            items {{
                voter
                weight
            }}
        }}
    }}
    """

    response = requests.post(PONDER_URL, json={"query": query}, headers=HEADERS, timeout=60)
    return response.json()["data"]["votes"]["items"]
