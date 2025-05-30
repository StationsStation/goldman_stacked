"""This module contains the main API for the controller."""

import logging

import connexion


log = logging.getLogger(__name__)


def get_agents() -> list[dict]:
    """Get all agents."""
    return [{"id": 1, "name": "Agent 1"}, {"id": 2, "name": "Agent 2"}]


def get_agent(id: int) -> dict:
    """Get an agent by ID."""
    return {"id": id, "name": "Agent 1"}


def post_agents(agent: dict) -> dict:
    """Create a new agent."""
    return agent


def get_proposals() -> list[dict]:
    """Get all proposals."""
    return [{"id": 1, "name": "Proposal 1"}, {"id": 2, "name": "Proposal 2"}]


def post_proposals(proposal: dict) -> dict:
    """Create a new proposal."""
    return proposal


def get_proposal(id: int) -> dict:
    """Get a proposal by ID."""
    return {"id": id, "name": "Proposal 1"}


def post_proposal_vote(id: int, vote: dict) -> dict:
    """Submit a vote on a proposal."""
    log.info(f"Vote submitted for proposal {id}: {vote}")
    return vote


def get_proposal_vote(id: int, vote: dict) -> dict:
    """Get a vote on a proposal."""
    log.info(f"Vote retrieved for proposal {id}: {vote}")
    return vote


app = connexion.FlaskApp(__name__, specification_dir="../specs/")
app.add_api("controller_spec.yaml", arguments={"title": "Controller API"})


app.run()
