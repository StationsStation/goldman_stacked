# Goldman Stacked

## Description

This skill governs the proposal lifecycle in a cross-chain, AI-assisted DAO governance flow.

It listens for new proposals submitted on-chain by users (bots or humans), triggers internal council discussions via Telegram, runs voting rounds among agentic council members, and then publishes the outcomes for final human DAO voting. It also monitors on-chain votes and executes proposals upon final approval.

All actions are event-driven and follow a finite state machine that automates decision-making, discussion, notification, and execution workflows across distributed agents.

## Handlers

* `HttpHandler`: handles proposal execution by interacting with the appropriate on-chain endpoints once both agentic council and human DAO have approved.
* `TelegramHandler`: polls for and processes on-chain events, including new proposals, human vote outcomes, and execution triggers.
* `LlmChatCompletionHandler`: coordinates internal council deliberation by processing and responding to discussion in the shared Telegram thread.
