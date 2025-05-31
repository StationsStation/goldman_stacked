"""Module to get data from governance contract and subgraph."""

import requests
from web3 import Web3
from dotenv import load_dotenv
import json

load_dotenv()

RPC = "https://base.drpc.org"
with open("abi.json", encoding="utf-8") as file:
    ABI = file.read()

ADDRESS = "0xb1ae1Ab21f872bCD17f706Ee73327fB58e9A0Da6"

PONDER_URL = "http://localhost:42069/graphql"
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
                createdAt
            }
        }
    }
    """

    response = requests.post(PONDER_URL, json={"query": query}, headers=HEADERS, timeout=60)

    proposals = response.json()["data"]["proposals"]["items"]
    for proposal in proposals:
        status = governor_contract.functions.state(proposal["proposalId"]).call()
        proposal["status"] = status
        votes = get_votes(proposal["proposalId"])
        proposal["votes"] = votes

    return proposals


def get_votes(proposal_id: str) -> list[dict]:
    """Get votes for proposal_id."""
    query = f"""
    {{
        votes(where:{{proposalId: {proposal_id}}}, orderBy:"voter", orderDirection: "desc") {{
            items {{
                voter
                weight
            }}
        }}
    }}
    """

    response = requests.post(PONDER_URL, json={"query": query}, headers=HEADERS, timeout=60)
    return response.json()["data"]["votes"]["items"]
