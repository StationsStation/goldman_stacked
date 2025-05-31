"""This module contains the main API for the controller."""

import logging

import yaml
import connexion
from flask_cors import CORS

import govHelper


log = logging.getLogger(__name__)


def get_agents() -> list[dict]:
    """Get all agents."""
    with open("agents.yaml", encoding="utf-8") as yaml_file:
        return yaml.safe_load(yaml_file)["agents"]



def get_agent(id: str) -> dict:
    """Get an agent by ID."""
    with open("agents.yaml", encoding="utf-8") as yaml_file:
        data = yaml.safe_load(yaml_file)

    filtered_agent = [agent for agent in data["agents"] if agent["id"] == id]
    return filtered_agent[0]


def post_agents(agent: dict) -> dict:
    """Create a new agent."""
    return agent


def get_proposals() -> list[dict]:
    """Get all proposals."""
    return govHelper.get_proposals()

    # To change output to json string, use json.dumps(data)


def post_proposals(proposal: dict) -> dict:
    """Create a new proposal."""
    return proposal


def get_proposal(id: str) -> dict:
    """Get a proposal by ID."""
    with open("proposals.yaml", encoding="utf-8") as yaml_file:
        data = yaml.safe_load(yaml_file)

    filtered_proposal = [proposal for proposal in data["proposals"] if proposal["proposalId"] == id]
    return filtered_proposal[0]


def post_proposal_vote(id: str, vote: dict) -> dict:
    """Submit a vote on a proposal."""
    log.info(f"Vote submitted for proposal {id}: {vote}")
    return vote


def get_proposal_vote(id: str, vote: dict) -> dict:
    """Get a vote on a proposal."""
    log.info(f"Vote retrieved for proposal {id}: {vote}")
    return vote

if __name__ == '__main__':
    app = connexion.FlaskApp(__name__, specification_dir="../specs/")
    flask_app = app.app  # access underlying Flask app
    CORS(flask_app, resources={r"/*": {"origins": "*"}})
    app.add_api("controller_spec.yaml", arguments={"title": "Controller API"})
    app.run()
