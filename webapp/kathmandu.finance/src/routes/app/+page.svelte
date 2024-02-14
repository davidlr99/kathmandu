<script>
  import StatsTile from "$lib/StatsTile.svelte";
  import Durbar from "$lib/Durbar.svelte";
  import { kathmandu } from "$lib/stores/kathmandu.js";
  import { userConnection } from "$lib/stores/userData.js";

  var defaultChain;

  $: {
    defaultChain = $userConnection.defaultChain;
    if ($userConnection.connected) {
      defaultChain = Object.keys($kathmandu.chainIds).find(
        (k) => $kathmandu.chainIds[k] === $userConnection.connectedToChainId
      );
    }


  }

  var averageWrapApy = "..."
  var averageStakeApy = "..."
  var durbarsC = "..."
  $: if ($kathmandu.finishedLoading) {

    let durbarsCount = Object.keys($kathmandu.apys[defaultChain]).length
    durbarsC = durbarsCount
    averageWrapApy = 0
    averageStakeApy = 0
    for(let i in $kathmandu.apys[defaultChain]){
      averageWrapApy += $kathmandu.apys[defaultChain][i].wrapAPY
      averageStakeApy += $kathmandu.apys[defaultChain][i].stakeAPY
    }

    averageWrapApy = (averageWrapApy/durbarsCount).toFixed(1)
    averageStakeApy = (averageStakeApy/durbarsCount).toFixed(1)

  }
</script>

<div class="w-full min-h-screen pt-16 bg-slate-200">
  <div class="w-full px-3 md:px-20 py-10 lg:py-10">
    <h1 class="font-bold text-lg">Overview</h1>
    <div
      class="grid xl:grid-cols-4 md:grid-cols-2 sm:grid-cols-2 grid-cols-1 gap-2 md:gap-5 w-full h-full mt-5"
    >
      <StatsTile
        icon={"faHandHoldingDollar"}
        title={"Average Wrap APR"}
        value={averageWrapApy+"%"}
        undertitle={"Earned by wrappers"}
      />
      <StatsTile
        icon={"faUser"}
        title={"Avarage LP-Stake APR"}
        value={averageStakeApy+"%"}
        undertitle={"Earned by LP stakers"}
      />
      <StatsTile
        icon={"faCoins"}
        title={"Total Durbars"}
        value={durbarsC}
        undertitle={"Active"}
      />
      <StatsTile
        icon={"faArrowTrendUp"}
        title={"Best performing Durbar"}
        value={"wETH"}
        undertitle={"Highest APR"}
      />
    </div>
    <h1 class="mt-5 font-bold text-lg">Durbars</h1>
    {#each $kathmandu.durbars[defaultChain] as durbar, index}
      <Durbar durbarName={durbar} chain={defaultChain}></Durbar>
    {/each}
  </div>
</div>
