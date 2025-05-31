import { createConfig } from "ponder";

import { MyGovernor } from "./abis/MyGovernor";

export default createConfig({
  chains: { base: { id: 8453, rpc: "https://base.drpc.org" } },
  contracts: {
    MyGovernor: {
      abi: MyGovernor,
      address: "0xE5Da5F4d8644A271226161a859c1177C5214c54e",
      chain: "base",
      startBlock: 30956292,
    },
  },
});
