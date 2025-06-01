"""
Simple CLI for voting on proposals.
"""

import click

@click.command()
@click.option('--proposal-id', required=True, help='The ID of the proposal to act on.')
@click.option('--action', type=click.Choice(['approve', 'reject'], case_sensitive=False), required=True, help='Action to take on the proposal.')
def vote(proposal_id, action):
    """Vote on a proposal."""
    click.echo(f"Voting to {action} proposal {proposal_id}")

if __name__ == '__main__':
    vote()
