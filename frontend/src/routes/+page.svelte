
<script lang="ts">
  // This is a placeholder script block. You can add your TypeScript code here if needed.
   //   We import the Counvil component from the library

    import Council from '$lib/components/Council.svelte';
    

</script>

<!-- Skelingto card -->



<div class="grid grid-rows-[auto_1fr_auto]">
  <div class="container mx-auto grid grid-cols-1 xl:grid-cols-[200px_minmax(0px,_1fr)_200px]">
    <!-- Sidebar (Left) -->
    <!-- NOTE: hidden in smaller screen sizes -->
    <aside class="sticky top-0 col-span-1 hidden p-4 xl:block"></aside>
    <!-- Main -->
    <main class="col-span-1 space-y-4 bg-green-500 p-4">

      <Council />
      <p class="h-[512px] bg-purple-500 p-4">Paragraph 1</p>
      <p class="h-[512px] bg-purple-500 p-4">Paragraph 2</p>
      <p class="h-[512px] bg-purple-500 p-4">Paragraph 3</p>
    </main>
    <!-- Sidebar (Right) -->
    <!-- NOTE: hidden in smaller screen sizes -->
    <aside class="sticky top-0 col-span-1 hidden h-screen p-4 xl:block"></aside>
  </div>
  <!-- Footer -->
  <footer class="bg-blue-500 p-4">(footer)</footer>
</div>

