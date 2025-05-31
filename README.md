<img src="goldman_stacked_logo.png" width="1000">

> **Powered by:**
> - [Open-Autonomy](https://docs.olas.network/open-autonomy/)
> - [Autonomy Dev](https://8ball030.github.io/auto_dev/)

---

You’re part of a DAO, but your vote may never matter. Many token holders avoid participating; voter apathy sets in when:
- **Perceived low impact:** One on-chain vote feels insignificant against large token holders.
- **Complexity & friction:** Tracking multiple governance contracts, bridging tokens, and gas fees across chains is overwhelming.
- **Whale dominance:** Single‐chain liquidity concentration allows “whales” to push through malicious or self‐serving proposals.

Meanwhile, protocols increasingly operate **cross-chain**: liquidity, applications, and governance span Ethereum, Hedera, Polygon, Base, and beyond. That creates opportunities, **but only if stakeholders can coordinate cross-chain capital and votes effectively**. For humans, this is cumbersome; bridging assets, calculating weighted votes, and submitting on-chain transactions on multiple networks is error-prone and time-consuming.

Enter **Goldman Stacked**: an autonomous, AI-driven council that:
1. **Vet every incoming proposal before** it goes on-chain.
2. **Holds cross-chain assets** to establish eligibility and voting weight.
3. **Computes quadratic voting weights** across multiple chains using LayerZero.
4. **Publishes or blocks** proposals automatically, and notifies human DAO members when a proposal is ready for final, on-chain votes.


### **Agent Asylum**: A next-gen meta-programming tool
In ETHDenver 2025, we built **Agent Asylum**, a proof‐of‐concept that uses coordinated swarms of AI agents to **ideate**, **scaffold**, and **bootstrap** new hackathon projects end to end. Agent Asylum **generates project templates**, **creates Git repos**, **writes boilerplate code**, and even **opens PRs** autonomously based on "digital doppelgänger" personas of real‐world developers. In this hackathon, we use this "meta-programming on steroids" tooling to **kickstart** our new project, leveraging its rapid generation capabilities to scaffold **Goldman Stacked**.


---

## **Table of Contents**

1. [How It Works](#how-it-works)
   - [1. Persona Construction & Cache](#1-persona-construction--cache)
   - [2. Telegram-Based Queue Polling](#2-telegram-based-queue-polling)
   - [3. Proposal Vetting & Voting](#3-proposal-vetting--voting)
   - [4. Compute Cross-Chain Weights](#4-compute-cross-chain-weights)
   - [5. On-Chain Proposal Creation](#5-on-chain-proposal-creation)
   - [6. User Notifications](#6-user-notifications)
   - [7. Error Handling](#7-error-handling)
2. [Why This Matters](#why-this-matters)
   - [Voter Apathy Explained](#voter-apathy-explained)
   - [Cross‐Chain Liquidity & Governance](#cross-chain-liquidity--governance)
   - [Capture‐Resistant Governance & Anticapture](#capture-resistant-governance--anticapture)
   - [Derolas Case Study](#derolas-case-study)
   - [Our Unique Selling Points](#our-unique-selling-points)
3. [The Future of AI‐Driven DAO Governance](#the-future-of-ai-driven-dao-governance)

---

## **How It Works**

### **1. Persona Construction & Cache**
At startup, each **council agent** builds a _persona_ by fetching publically available data to create AI agents that are digital representatives of DAO participants and / or Web3 thought leaders. This process assembles:
- **Governance style preferences** (e.g., risk‐averse vs. risk‐tolerant).
- **Historical voting patterns** to simulate realistic debate.
- **Expertise areas** (e.g., DeFi, NFTs, layer‐2 scaling).

Once constructed, **Personas are saved locally** in a cache file (`.persona_cache.json`). On subsequent runs, agents read from that cache instead of re‐fetching data, ensuring fast startup and reproducible behavior.

### **2. Telegram‐Based Queue Polling**
Council agents connect to a dedicated Telegram bot and continuously poll a _proposals_ chat room. Any DAO member (modeled as a Proposer Agent or human) can submit a plaintext proposal or a formatted governance thread.
- **No new proposals / timeout →** loop back to **CheckPersonaCache** after a short wait.
- **New proposal detected →** transition to **PreProposalRound**.

### **3. Proposal Vetting & Voting**
In the **PreProposalRound**, council agents discuss the incoming proposal via Telegram:
1. Each agent’s persona speaks in the group chat, raising concerns or commentary.
2. After a timed discussion window, agents cast a **binary poll**: "Approve" or "Reject".
   - **Approve →** move to **ComputeCrossChainWeights**.
   - **Reject →** move to **NotifyUsersProposalRejected**.

### **4. Compute Cross‐Chain Weights**
Once a proposal is approved by the AI council:
1. **Fetch token balances** for each council agent wallet on all configured chains (e.g., Ethereum, Hedera, Polygon, Base, etc.) via LayerZero message queries.
2. **Compute quadratic voting weight**: apply a square‐root function to each balance, yielding an individual vote weight.
3. **Aggregate these weights** across all agents to determine total council voting power.
4. **Error handling:** If any LayerZero call fails (e.g., network timeout, RPC error), transition to **WaitBeforeRetryRound**.

### **5. On‐Chain Proposal Creation**
With computed voting weights, **CreateOnChainProposal** packages the proposal payload, metadata (title, description, discussion link), and a “virtual council vote” into transactions for each supported governance contract.
- Relay these transactions **simultaneously via LayerZero**, so that every target chain’s DAO module receives and queues the proposal at the same block height.
- **Success →** transition to **NotifyUsersProposalCreated**.
- **Failure →** transition to **WaitBeforeRetryRound**.

### **6. User Notifications**
- **NotifyUsersProposalCreated:** Broadcast a Telegram message tagging all human DAO members:
  > "The AI council has approved **Proposal #XYZ**. On‐chain voting is now open on Ethereum, Polygon, and Base visit [link] to vote".
  Then return to **CheckPersonaCache** and await new proposals.
- **NotifyUsersProposalRejected:** Broadcast a Telegram message to the proposer and DAO channel:
    "**Proposal #XYZ** was rejected by the AI council. Rationale: [brief summary from council discussion]".
  Then return to **CheckPersonaCache**.

### **7. Error Handling**
A unified **WaitBeforeRetryRound** serves as a catch‐all error state. Any failure in:
- Persona fetch or cache read/write
- Telegram API calls (polling or sending messages)
- LayerZero cross-chain queries or transactions

leads to a transition labeled “error” into **WaitBeforeRetryRound**, where agents wait a configured delay (e.g., 30 seconds) before returning to **CheckPersonaCache**.

---

## **Why This Matters**

### **Voter Apathy Explained**
- **Low Perceived Impact:** Many token holders feel that their single on‐chain vote can’t sway outcomes if large holders control a majority of tokens on any one chain.
- **High Friction:** Tracking proposal details, bridging tokens, approving transactions, and paying gas fees across multiple networks is tedious.
- **Lack of Guidance:** Without clear, aggregated signals, voters hesitate, worrying that voting against a whale might be pointless.
- **Out‐of‐Sync Timing:** Different chains have staggered governance cycles, causing confusion and missed votes.

### **Cross‐Chain Liquidity & Governance**
Modern DeFi and Web3 protocols span **multiple blockchains** to maximize capital efficiency, reduce fees, and tap into diverse user bases. Examples include:
- **Multi‐chain DEX aggregators** like 1inch or Curve’s cross-chain pools.
- **Layer‐2 scaling solutions** plugging into Ethereum for rollups.
- **Bridge networks** moving assets between EVM‐compatible chains.

While cross‐chain liquidity boosts TVL (Total Value Locked) and yields, it **complicates governance**:
1. **Fragmented Token Holdings:** A DAO member may hold tokens on Ethereum, Polygon, and Base, each balance alone might not meet a proposal threshold, but combined they do.
2. **Transaction Burden:** To vote "yes", a member must interact with multiple governance contracts, pay multiple gas fees, and track multiple proposal deadlines.
3. **Coordination Delays:** Chains have different block times and governance cycle lengths, resulting in asynchronous proposal windows.
4. **Vulnerability to Capture:** A whale can accumulate tokens on one network, propose a malicious upgrade, and push it through before smaller stakeholders can coordinate.

**Goldman Stacked** automates cross‐chain vote aggregation and submission, reducing friction for smaller stakeholders and raising the bar for malicious actors.

### [**Capture‐Resistant Governance & Anticapture**](https://knowledge.superbenefit.org/links/Anticapture/)
The **Anticapture** framework, published less than two weeks ago, formalizes **capture-resistant governance** by:
- Defining **"capture"** as when a coordinated few gain enough voting power to dictate outcomes.
- Outlining a **taxonomy** of capture‐risk factors (e.g., token concentration, delegation patterns).
- Providing **monitoring tools** and **dashboards** to assess capture exposure and propose mitigations.

However, Anticapture remains an **analytical framework**: it offers metrics, risk‐assessment dashboards, and theoretical guidelines, **but does not implement an AI‐powered system to automatically veto or publish proposals**. That’s where **Goldman Stacked** differentiates itself by providing an **active, autonomous council** that:
1. **Pre‐approves or blocks proposals** before they hit on‐chain governance modules.
2. **Aggregates cross‐chain vote weights** via LayerZero and computes **quadratic voting power**.
3. **Submits on‐chain transactions** across all target chains in parallel, thwarting single‐chain whales.
4. **Broadcasts real‐time notifications** to human DAO members, reducing voter apathy by lowering friction.

### [**Derolas Case Study**](https://medium.com/@8ball030/mergers-and-acquisitions-m-as-in-the-wild-west-of-web3-e8d5f0d6d30b)
On April 3, 2025, a "hostile takeover" proposal appeared on Derive Exchange’s governance forum. Synthetix, an otherwise respected protocol, submitted a **malicious bid** to acquire Derive, without forewarning the community .
- **Blindsided Community:** Derive’s founders were historically supportive but lacked current decision-making authority. Token holders scrambled to organize a defense, diverting resources for over a week.
- **Human Rally:** Only **manual, on‐chain voting**, after frantic Discord calls and Telegram threads, ultimately prevailed, forcing Synthetix to withdraw its offer just before the deadline.
- **Learned Lessons:** An AI‐driven council like **Goldman Stacked** would have:
  1. **Vetted the takeover proposal** immediately upon submission.
  2. **Blocked it automatically** if it detected conflicting interests or insufficient community consensus.
  3. **Notified Derive token holders** in real time, preventing wasted human hours and market uncertainty.

### **Our Unique Selling Points**
- **Meta‐Scaffolded by Agent Asylum:** We used **Agent Asylum** to rapidly generate the initial project template, saving weeks of boilerplate coding. But **we are not continuing Agent Asylum itself**; Goldman Stacked is its own, standalone application.
- **End-to-End Automation:** From persona cache to Telegram polling, cross-chain weight computation, and on-chain proposal creation: no manual intervention until final human voting.
- **Quadratic Voting Across Chains:** Normalize tokens across multiple chains into a single, unified voting power metric, thwarting "one chain, one vote" attacks.
- **Active Veto & Publish:** The AI council **vets**, **vetoes**, or **publishes** proposals. Humans only see a council‐approved list.
- **Seamless UX with Telegram:** Lower barriers to participation by delivering real-time updates, reducing voter apathy and confusion.
- **Modular, Extensible Design:** Built on the same Open-Autonomy stack as Agent Asylum, you can easily add new chains, tweak quadratic formulas, or extend persona profiles without rearchitecting the core FSM.

---

## **The Future of AI‐Driven DAO Governance**

We began with **Agent Asylum**, a proof-of-concept demonstrating that swarms of AI agents can plan, discuss, vote, code, review, and ship entire projects autonomously. **Goldman Stacked** takes that paradigm and focuses it on **secure, cross-chain DAO governance**:
- **Today**, it’s a Telegram-based AI council that pre-approves proposals, computes cross-chain voting weights, and posts on-chain transactions.
- **Tomorrow**, it could become the **default governance layer** for multiple DAOs, autonomously vetting proposals across dozens of protocols, or even serve as a **meta-governance body** that ensures ecosystem-wide capture resistance.

As decentralized protocols proliferate across chains, the **complexity** and **attack surface** grow exponentially. By embedding an **autonomous AI council** that can preemptively block malicious schemes and aggregate “small” votes into a unified cross-chain voice, **Goldman Stacked** reduces governance risk, slashes voter apathy, and empowers DAOs to govern with confidence. Human autonomy is not replaced; it’s **amplified**.

---

## Getting Started

### Installation and Setup for Development

If you're looking to contribute or develop with `goldman_stacked`, get the source code and set up the environment:

```shell
git clone https://github.com/StationsStation/goldman_stacked --recurse-submodules
cd goldman_stacked
make install
```

## Commands

Here are common commands you might need while working with the project:

### Formatting

```shell
make fmt
```

### Linting

```shell
make lint
```

### Testing

```shell
make test
```

### Locking

```shell
make hashes
```

### all

```shell
make all
```

## License

This project is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
