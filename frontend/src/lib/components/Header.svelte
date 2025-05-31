<script>
  import { onMount } from 'svelte';
	// import { WC, disconnectWagmi} from 'svelte-wagmi';
  import { createPublicClient, http } from 'viem'
  import { mainnet } from 'viem/chains'

  let connected = false;
  let signer = null;
  let provider;
import { ethers } from 'ethers';



async function connectWallet() {

  try {
    if (!window.ethereum) {
      console.log("MetaMask not installed; using read-only provider");
      provider = ethers.getDefaultProvider();
      return { provider, signer: null };
    }

    provider = new ethers.BrowserProvider(window.ethereum);

    // Request account access if needed
    await window.ethereum.request({ method: 'eth_requestAccounts' });

    signer = await provider.getSigner();

    const address = await signer.getAddress();
    console.log("Connected address:", address);

    return { provider, signer };
  } catch (err) {
    console.error("Failed to connect wallet:", err);
    return { provider: null, signer: null };
  }
}


  function disconnectWallet() {
    // Replace with WalletConnect or viem logic
    disconnectWagmi();
    connected = false;
  }




</script>

<header class="w-full flex items-center justify-between px-6 py-4 bg-zinc-900 shadow-lg border-b border-zinc-700">
  <h1 class="text-2xl font-mono text-green-400 tracking-widest drop-shadow-md">
    Goldman Stacked
  </h1>

  {#if connected}
    <button class="px-4 py-2 text-green-400 border border-green-500 rounded hover:bg-green-500 hover:text-black transition"
      on:click={disconnectWallet}>
      Connected
    </button>
  {:else}
    <button
      class="px-4 py-2 text-zinc-100 bg-gradient-to-br from-green-600 to-emerald-700 rounded hover:brightness-125 transition"
      on:click={connectWallet}>
      Connect Wallet
    </button>
  {/if}
</header>
