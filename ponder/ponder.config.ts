import { createConfig } from "ponder";

import { MyGovernor } from "./abis/MyGovernor";

export default createConfig({
  chains: { base: { id: 8453, rpc: "https://base.drpc.org" } },
  contracts: {
    MyGovernor: {
      abi: MyGovernor,
      address: "0xb1ae1ab21f872bcd17f706ee73327fb58e9a0da6",
      chain: "base",
      startBlock: 30956292,
    },
  },
});
