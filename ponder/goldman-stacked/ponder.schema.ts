import { onchainTable } from "ponder";

export const proposal = onchainTable("proposal", (t) => ({
  proposalId: t.text().primaryKey(),
  description: t.text(),
  status: t.text(),
  createdBy: t.text(),
  createdAt: t.text(),
}));
