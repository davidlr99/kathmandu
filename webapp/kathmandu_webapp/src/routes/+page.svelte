<script>
  import { onMount } from "svelte";
  import {
    connected,
    web3,
    selectedAccount,
    chainId,
    chainData,
    defaultEvmStores,
  } from "svelte-web3";
  import testToken from "$lib/contracts/TestToken.json";
  import wrapperToken from "$lib/contracts/WrapToken.json";
  import liquidityToken from "$lib/contracts/TestLiqToken.json";

  import kathmanduContract from "$lib/contracts/Kathmandu.json";

  let kathmanduMainContract = "0x483F125ac490d8347f5a2B1E7d3C7dC6D2B505e2";
  let durbarName = "wETH";
  let tokenContract = "0x4200000000000000000000000000000000000023";
  let wrapperTokenContract = "0x176dbd81A6aF124915F87e247b58e8D0094b4832";
  let liqTokenContract = "0x047B8065CD5fddfcD0920Aa4Ee7D1CDF2474A68f";
  let feeRateToWrappers100 = 100;
  let feeRateToLPsIn100 = 100;
  let feeRateToDevIn100 = 100;

  let wrapAmount = 100;
  let unWrapAmount = 100;

  let stakeAmount = 10;
  let unStakeAmount = 10;

  onMount(async function () {
    await defaultEvmStores.setProvider();
  });

  async function wrapTokens() {
    var testTokenContract = new $web3.eth.Contract(
      testToken.abi,
      tokenContract,
      {
        from: $selectedAccount,
      }
    );

    await testTokenContract.methods
      .approve(kathmanduMainContract, $web3.utils.toWei(wrapAmount, "ether"))
      .send({
        from: $selectedAccount,
      });

    var testKathmanduContract = new $web3.eth.Contract(
      kathmanduContract.abi,
      kathmanduMainContract,
      {
        from: $selectedAccount,
      }
    );

    await testKathmanduContract.methods
      .wrapDurbar(durbarName, $web3.utils.toWei(wrapAmount, "ether"))
      .send({
        from: $selectedAccount,
      });
  }

  async function unWrapTokens() {
    var wrapperTokenC = new $web3.eth.Contract(
      wrapperToken.abi,
      wrapperTokenContract,
      {
        from: $selectedAccount,
      }
    );

    await wrapperTokenC.methods
      .approve(kathmanduMainContract, $web3.utils.toWei(unWrapAmount, "ether"))
      .send({
        from: $selectedAccount,
      });

    var testKathmanduContract = new $web3.eth.Contract(
      kathmanduContract.abi,
      kathmanduMainContract,
      {
        from: $selectedAccount,
      }
    );

    await testKathmanduContract.methods
      .unwrapDurbar(durbarName, $web3.utils.toWei(unWrapAmount, "ether"))
      .send({
        from: $selectedAccount,
      });
  }

  async function addDurbar() {
    var testKathmanduContract = new $web3.eth.Contract(
      kathmanduContract.abi,
      kathmanduMainContract,
      {
        from: $selectedAccount,
      }
    );

    await testKathmanduContract.methods
      .addDurbar(
        durbarName,
        tokenContract,
        wrapperTokenContract,
        liqTokenContract,
        feeRateToDevIn100,
        feeRateToLPsIn100,
        feeRateToDevIn100,
        true
      )
      .send({
        from: $selectedAccount,
      });
  }

  async function stakeLiquidity() {
    var testLiquidityToken = new $web3.eth.Contract(
      liquidityToken.abi,
      liqTokenContract,
      {
        from: $selectedAccount,
      }
    );

    await testLiquidityToken.methods
      .approve(kathmanduMainContract, $web3.utils.toWei(stakeAmount, "ether"))
      .send({
        from: $selectedAccount,
      });

    var testKathmanduContract = new $web3.eth.Contract(
      kathmanduContract.abi,
      kathmanduMainContract,
      {
        from: $selectedAccount,
      }
    );

    await testKathmanduContract.methods
      .stakeLiq(durbarName, $web3.utils.toWei(stakeAmount, "ether"))
      .send({
        from: $selectedAccount,
      });
  }

  async function unStakeLiquidity() {
    var testKathmanduContract = new $web3.eth.Contract(
      kathmanduContract.abi,
      kathmanduMainContract,
      {
        from: $selectedAccount,
      }
    );

    await testKathmanduContract.methods
      .unStakeLiq(durbarName, $web3.utils.toWei(unStakeAmount, "ether"))
      .send({
        from: $selectedAccount,
      });
  }

  async function updateLiqToken() {
    var testKathmanduContract = new $web3.eth.Contract(
      kathmanduContract.abi,
      kathmanduMainContract,
      {
        from: $selectedAccount,
      }
    );
    await testKathmanduContract.methods
      .updateLiqToken(durbarName, liqTokenContract)
      .send({
        from: $selectedAccount,
      });
  }
</script>

{#if !$connected}
  <p>My application is not yet connected</p>
{:else}
  <p>Connected to chain with id {$chainId}, account {$selectedAccount}</p>
{/if}

<input bind:value={wrapAmount} placeholder="wrapAmount" />
<button on:click={wrapTokens}>Wrap Tokens</button>
<br />
<input bind:value={unWrapAmount} placeholder="unWrapAmount" />
<button on:click={unWrapTokens}>Unwrap Tokens</button>
<br />
<br />
<input bind:value={stakeAmount} placeholder="liqStakeAmount" />
<button on:click={stakeLiquidity}>Stake LP tokens</button>
<br />
<input bind:value={unStakeAmount} placeholder="liqUnStakeAmount" />
<button on:click={unStakeLiquidity}>Unstake LP tokens</button>
<br />

<input bind:value={kathmanduMainContract} placeholder="kathmanduMainContract" />
<input bind:value={durbarName} placeholder="durbarName" />
<input bind:value={tokenContract} placeholder="tokenContract" />
<input bind:value={wrapperTokenContract} placeholder="wrapperTokenContract" />
<input bind:value={liqTokenContract} placeholder="liqTokenContract" />
<input bind:value={feeRateToWrappers100} placeholder="feeRateToWrappers100" />
<input bind:value={feeRateToLPsIn100} placeholder="feeRateToLPsIn100" />
<input bind:value={feeRateToDevIn100} placeholder="feeRateToDevIn100" />

<button on:click={addDurbar}>Add Durbar</button>

<input bind:value={liqTokenContract} placeholder="liqTokenContract" />
<button on:click={updateLiqToken}>Update Liq Token</button>
