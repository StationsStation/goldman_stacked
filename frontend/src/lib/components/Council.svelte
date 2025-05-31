
<script lang="ts">
  import { onMount } from 'svelte';
  import { ArrowLeft, ArrowRight } from 'lucide-svelte';

  let elemCarousel: HTMLDivElement;
  let elemCarouselLeft: HTMLButtonElement;
  let elemCarouselRight: HTMLButtonElement;
  let elemThumbnails: HTMLElement[] = [];
  let thumbEl: HTMLButtonElement;

  const generatedArray = Array.from({ length: 6 });

  function carouselLeft() {
    if (!elemCarousel) return;
    const x =
      elemCarousel.scrollLeft === 0
        ? elemCarousel.clientWidth * elemCarousel.childElementCount
        : elemCarousel.scrollLeft - elemCarousel.clientWidth;
    elemCarousel.scrollTo({ left: x, behavior: 'smooth' });
  }

  function carouselRight() {
    if (!elemCarousel) return;
    const x =
      elemCarousel.scrollLeft === elemCarousel.scrollWidth - elemCarousel.clientWidth
        ? 0
        : elemCarousel.scrollLeft + elemCarousel.clientWidth;
    elemCarousel.scrollTo({ left: x, behavior: 'smooth' });
  }

  function carouselThumbnail(index: number) {
    if (elemCarousel) {
      elemCarousel.scrollTo({ left: elemCarousel.clientWidth * index, behavior: 'smooth' });
    }
  }
</script>

<style>
  .btn-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.5rem;
    border-radius: 0.375rem;
    background-color: #f3f4f6;
  }

  .preset-filled {
    background-color: #e5e7eb;
    transition: background-color 0.2s;
  }

  .preset-filled:hover {
    background-color: #d1d5db;
  }

  .rounded-container {
    border-radius: 0.75rem;
  }

  .card {
    background-color: white;
    border-radius: 1rem;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
  }
</style>

<div class="w-full space-y-6">
  <!-- Carousel -->
  <div class="card p-4 grid grid-cols-[auto_1fr_auto] gap-4 items-center">
    <!-- Button: Left -->
    <button bind:this={elemCarouselLeft} type="button" class="btn-icon preset-filled" on:click={carouselLeft}>
      <ArrowLeft size={16} />
    </button>

    <!-- Full Images -->
    <div
      bind:this={elemCarousel}
      class="snap-x snap-mandatory scroll-smooth flex overflow-x-auto"
    >
      {#each generatedArray as _, i}
        <!-- Single Carousel Slide -->
        <div class="snap-center flex-shrink-0 w-[1024px] flex gap-6 items-center p-4">
          <!-- Image -->
          <img
            class="rounded-container w-1/2 object-cover h-full"
            src={`https://picsum.photos/seed/${i + 1}/1024/768`}
            alt={`full-${i}`}
            loading="lazy"
          />

          <!-- Card Description -->
          <div class="card w-1/2 p-6 h-full">
            <h2 class="text-xl font-bold mb-2">Image {i + 1}</h2>
            <p class="text-gray-600">This is a description for image {i + 1}.</p>
          </div>
        </div>
      {/each}
    </div>

    <!-- Button: Right -->
    <button bind:this={elemCarouselRight} type="button" class="btn-icon preset-filled" on:click={carouselRight}>
      <ArrowRight size={16} />
    </button>
  </div>

  <!-- Thumbnails -->
  <div class="card p-4 grid grid-cols-6 gap-4">
    {#each generatedArray as _, i}
      <button
        bind:this={thumbEl}
        type="button"
        on:click={() => carouselThumbnail(i)}
      >
        <img
          class="rounded-container hover:brightness-125"
          src={`https://picsum.photos/seed/${i + 1}/256`}
          alt={`thumb-${i}`}
          loading="lazy"
        />
      </button>
    {/each}
  </div>
</div>
