import { ponder } from "ponder:registry";
import { proposal, vote } from "ponder:schema";

ponder.on("MyGovernor:ProposalCreated", async ({ event, context }) => {
    await context.db
        .insert(proposal)
        .values({
            proposalId: String(event.args.proposalId),
            description: event.args.description,
            status: "Pending",
            createdBy: event.args.proposer
        })    
});

ponder.on("MyGovernor:ProposalQueued", async ({ event, context}) => {
    await context.db
        .update(proposal, {proposalId: String(event.args.proposalId)})
        .set({status: "Queued"})
})

ponder.on("MyGovernor:VoteCast", async ({ event, context }) => {
    await context.db   
        .insert(vote)
        .values({
            voter: event.args.voter,
            proposalId: String(event.args.proposalId)
        })
})
