<script>
  import "../app.css";
  import Navbar from "$lib/Navbar.svelte";
  import { onMount } from "svelte";
  import { defaultEvmStores } from "svelte-web3";

  import { setRefreshHooks } from "$lib/manageData.js";

  onMount(async () => {
    await defaultEvmStores.setProvider(
      "https://ethereum-sepolia.publicnode.com"
    );

    setRefreshHooks();
  });
</script>

<Navbar></Navbar>

<slot />
