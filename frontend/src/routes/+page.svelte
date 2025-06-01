
<script lang="ts">
    import Council from '$lib/components/Council.svelte';
    import Proposals from '$lib/components/Proposals.svelte';
</script>

<div class="grid grid-rows-[auto_1fr_auto]">
  <div class="container mx-auto grid grid-cols-1 xl:grid-cols-[200px_minmax(0px,_1fr)_200px]">
    <aside class="sticky top-0 col-span-1 hidden p-4 xl:block"></aside>
    <main class="col-span-1 space-y-4 bg-grey-900 p-4">

      <Council />
      <Proposals />
    </main>
    <!-- Sidebar (Right) -->
    <!-- NOTE: hidden in smaller screen sizes -->
    <aside class="sticky top-0 col-span-1 hidden h-screen p-4 xl:block"></aside>
  </div>
  <!-- Footer -->
  <!-- <footer class="bg-blue-500 p-4">(footer)</footer> -->
</div>

