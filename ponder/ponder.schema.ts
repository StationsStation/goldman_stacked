import { onchainTable, primaryKey } from "ponder";

export const proposal = onchainTable("proposal", (t) => ({
  proposalId: t.text().primaryKey(),
  description: t.text(),
  status: t.text(),
  createdBy: t.text(),
  transactionHash: t.text(),
}));

export const vote = onchainTable("vote", (t) => ({
  voter: t.text(),
  proposalId: t.text(),
  weight: t.bigint(),
}), (table) => ({
  pk: primaryKey({ columns: [table.proposalId, table.voter] })
}))
