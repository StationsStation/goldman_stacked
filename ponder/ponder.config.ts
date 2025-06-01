import { createConfig } from "ponder";

import { MyGovernor } from "./abis/MyGovernor";

const rawAddress = process.env.GOVERNOR_CONTRACT_ADDRESS;
const governorAddress: `0x${string}` = rawAddress?.startsWith("0x")
  ? (rawAddress as `0x${string}`)
  : "0xE5Da5F4d8644A271226161a859c1177C5214c54e";

export default createConfig({
  chains: { base: { id: 8453, rpc: "https://base.drpc.org" } },
  contracts: {
    MyGovernor: {
      abi: MyGovernor,
      address: governorAddress,
      chain: "base",
      startBlock: 30956292,
    },
  },
});
