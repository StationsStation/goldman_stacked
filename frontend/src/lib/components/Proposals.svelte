
<script lang="ts">
  import { onMount } from 'svelte';
  import { ArrowLeft, ArrowRight } from 'lucide-svelte';

  import { DefaultService } from '$lib/api';
  import { OpenAPI } from '$lib/api/core/OpenAPI';

  import {Agent, Proposal} from '$lib/api'


    import { marked } from 'marked';

  let elemCarousel: HTMLDivElement;
  let elemCarouselLeft: HTMLButtonElement;
  let elemCarouselRight: HTMLButtonElement;
  let elemThumbnails: HTMLElement[] = [];
  let thumbEl: HTMLButtonElement;

  let proposals: Proposal[] = [];

  onMount(() => {
    OpenAPI.BASE = 'http://localhost:5000';

    console.log('Component is mounted in the browser!');
    DefaultService.mainGetProposals()
      .then((data) => {
        console.log('Fetched via DefaultService:', data);
        proposals = data;
      })
      .catch((err) => {
        console.error('API error:', err);
      });
  });


</script>

<style>
  .card {
    background-color: black;
    border-radius: 1rem;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
  }
</style>


<div class="w-full space-y-6">
  <div class="card p-4 grid grid-cols-[auto_1fr_auto] gap-4 items-center bg-grey">
    <h2 class="w-full p-4 text-center text-2xl font-mono text-green-400 tracking-wide uppercase mb-4">Proposals</h2>

    <div class="col-span-3 overflow-x-auto">
      <table class="w-full text-left table-auto">
        <thead>
          <tr>
            <th class="px-4 py-2">ID</th>
            <th class="px-4 py-2">Transaction Hash</th>
            <th class="px-4 py-2">Description</th>
            <th class="px-4 py-2">Status</th>
            <th class="px-4 py-2">Created By</th>
          </tr>
        </thead>
        <tbody>
          {#each proposals as proposal}
            <tr>
              <td class="px-4 py-2">{proposal.proposalId}</td>
              <td class="px-4 py-2">{proposal.transactionHash}</td>
              <td class="px-4 py-2">{proposal.description}</td>
              <td class="px-4 py-2">{proposal.status}</td>
              <td class="px-4 py-2">{proposal.createdBy}</td>
            </tr>
          {/each}
        </tbody>
      </table>
      </div>
  
  </div>  
  
</div>
