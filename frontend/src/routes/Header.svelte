<script>
  import { onMount } from 'svelte';
  let connected = false;

  function connectWallet() {
    // Replace with WalletConnect or viem logic
    connected = true;
  }
</script>

<header class="w-full flex items-center justify-between px-6 py-4 bg-surface-888 shadow-md">
  <h1 class="text-xl font-bold text-primary">Goldman Stacked</h1>

  {#if connected}
    <button class="btn btn-outline text-success cursor-default">Connected</button>
  {:else}
    <button class="btn btn-primary" on:click={connectWallet}>Connect Wallet</button>
  {/if}
</header>
