<script>
  import Fa from "svelte-fa";
  import { faArrowDown } from "@fortawesome/free-solid-svg-icons";
  import { userData, userConnection } from "$lib/stores/userData.js";

  import { kathmandu } from "$lib/stores/kathmandu.js";
  import { onMount } from "svelte";

  import kathmanduAbi from "$lib/abis/Kathmandu.json";
  import defaultErc20Abi from "$lib/abis/ERC20.json";

  import {
    defaultEvmStores,
    connected,
    selectedAccount,
    chainId,
    web3,
    contracts,
  } from "svelte-web3";

  export let durbarName = "";
  export let chain = "";

  var baseToken = "loading";
  var baseTokenLongName = "loading";
  var wrapToken = "loading";
  var baseTokenBalance = "0";
  var wrapTokenBalance = "0";
  var wrapRatio = "1.0";

  var wrapAPY = "0";
  var stakeAPY = "0";

  var userWrapUnwrapAmount;
  var userStakeUnstakeAmount;
  var userWrapUnwrapSelected;

  $: if ($kathmandu.finishedLoading) {
    baseToken = $kathmandu.associatedTokens[chain][durbarName].baseToken[1][0];
    baseTokenLongName =
      $kathmandu.associatedTokens[chain][durbarName].baseToken[1][1];

    wrapToken = $kathmandu.associatedTokens[chain][durbarName].wrapToken[1][0];
    wrapRatio = $kathmandu.wrappedRatios[chain][durbarName];

    wrapAPY = $kathmandu.apys[chain][durbarName].wrapAPY;
    stakeAPY = $kathmandu.apys[chain][durbarName].stakeAPY;

    if ($userConnection.connected && $userData.userDataLoaded) {
      baseTokenBalance = $userData.balances[chain][durbarName][baseToken];
      wrapTokenBalance = $userData.balances[chain][durbarName][wrapToken];
    }
  }

  function setMaxWrapUnwrap() {
    if (!$userConnection.connected || !$userData.userDataLoaded) {
      return;
    }
    if (userWrapUnwrapSelected == "Wrap") {
      userWrapUnwrapAmount = baseTokenBalance;
    }
    if (userWrapUnwrapSelected == "Unwrap") {
      userWrapUnwrapAmount = wrapTokenBalance;
    }
  }

  async function wrapOrUnwrapAction() {
    var amount = parseFloat(userWrapUnwrapAmount);
    if (
      amount <= 0 ||
      !$userConnection.connected ||
      !$userData.userDataLoaded
    ) {
      return;
    }
    console.log("Jo");

    if (userWrapUnwrapSelected == "Wrap") {
      await defaultEvmStores.attachContract(
        "myTempErc20",
        $kathmandu.associatedTokens[chain][durbarName].baseToken[0],
        defaultErc20Abi.abi
      );

      await $contracts.myTempErc20.methods
        .approve(
          $kathmandu.kathmanduContracts[chain],
          $web3.utils.toWei(amount, "ether")
        )
        .send({
          from: $selectedAccount,
        });
      await $contracts.myKathmandu.methods
        .wrapDurbar(durbarName, $web3.utils.toWei(amount, "ether"))
        .send({
          from: $selectedAccount,
        });
    }
  }
</script>

<div class="grid xl:grid-cols-3 sm:grid-cols-2 grid-cols-1 gap-5 w-full mt-5">
  <div
    class="flex flex-col items-start bg-gradient-to-r from-slate-400 to-slate-500 w-full p-5 border-1 rounded gap-3"
  >
    <div class="flex items-center justify-between w-full">
      <div class="flex flex-col">
        <div class="flex items-center flex-row items-start w-full gap-2">
          <img src="/images/eth_logo.png" class="h-5" />
          <div class="text-sm text-secondary-light">
            {baseToken}
          </div>
        </div>
        <div class="flex">
          <div class="text-secondary-light/75 text-xs">
            {baseTokenLongName}
            Durbar
          </div>
        </div>
      </div>
      <div class="flex flex-row items-center gap-2">
        <div
          class="flex flex-col items-center p-1 bg-slate-400 rounded-md text-white"
        >
          <div class="text-sm">{wrapAPY}%</div>
          <div class="text-xs">WRAP APR</div>
        </div>
        <div
          class="flex flex-col items-center p-1 bg-slate-400 rounded-md text-white"
        >
          <div class="text-sm">{stakeAPY}%</div>
          <div class="text-xs">LP APR</div>
        </div>
      </div>
    </div>
    <div class="flex flex-col items-start w-full py-2 px-3 gap-2">
      <div
        class="flex flex-col items-start w-full py-2 px-3 bg-slate-300 rounded-md"
      >
        <div class="flex items-center justify-between w-full text-sm p-1 gap-5">
          <div>
            Your {baseToken} balance
          </div>
          <div>
            {parseFloat(baseTokenBalance).toLocaleString()}
          </div>
        </div>
        <div class="flex items-center justify-between w-full text-sm p-1 gap-5">
          <div>Your {wrapToken} balance</div>
          <div>
            {parseFloat(wrapTokenBalance).toLocaleString()}
          </div>
        </div>
      </div>
      <div
        class="flex items-center justify-between w-full text-sm p-2 gap-5 mt-1"
      >
        <div class="text-xs">
          Wrap your {baseToken} into {wrapToken} to earn yield ({wrapAPY}% APR). {wrapToken}
          can also be aquired on Uniswap. Every {wrapToken} is always backed by {baseToken}
          and can be unwraped at all time. Yield is earned as collateral backing
          ratio goes up.
        </div>
      </div>

      <div
        class="flex flex-col items-start w-full py-2 px-3 bg-slate-300 rounded-md"
      >
        <div class="flex items-center justify-between w-full text-sm p-1 gap-5">
          <div>Collateral backing ratio</div>
          <div>1 {wrapToken} = {1.0 / parseFloat(wrapRatio)} {baseToken}</div>
        </div>
      </div>

      <div class="flex flex-row items-center w-full text-sm">
        <input
          type="text"
          name="price"
          id="price"
          class="w-full rounded-l-md p-2 outline-none bg-white"
          placeholder={"0 " + baseToken}
          bind:value={userWrapUnwrapAmount}
        />
        <div class="bg-white p-2">
          <button
            class="bg-grey bg-slate-300 rounded-md text-xs px-1"
            on:click={setMaxWrapUnwrap}>max.</button
          >
        </div>
        <select
          id="currency"
          name="currency"
          class="h-full p-2 outline-none bg-white"
          bind:value={userWrapUnwrapSelected}
        >
          <option>Wrap</option>
          <option>Unwrap</option>
        </select>
        <button
          on:click={wrapOrUnwrapAction}
          class="rounded-r-full bg-gradient-to-r from-white to-slate-300 text-black py-2 px-4 hover:bg-slate-100"
          >Approve</button
        >
      </div>
      <div class="flex flex-row w-full justify-center mt-3 mb-1">
        <Fa size="2x" icon={faArrowDown} />
      </div>
      <div class="flex items-center justify-between w-full text-sm p-2 gap-5">
        <div class="text-xs">
          Stake LP-tokens from the {baseToken}/{wrapToken} Uniswap pool to earn {stakeAPY}%
          additional yield. Unstake possible at all times. No stake or unstake
          fees. Yield can be claimed in {baseToken} here.
        </div>
      </div>
      <div
        class="flex flex-col items-start w-full py-2 px-3 bg-slate-300 rounded-md"
      >
        <div class="flex items-center justify-between w-full text-sm p-1 gap-5">
          <div>Your LP {baseToken} rewards</div>
          <div>0</div>
        </div>
      </div>
      <div class="flex flex-row items-center w-full text-sm">
        <input
          type="text"
          name="price"
          id="price"
          class="w-full rounded-l-md p-2 outline-none bg-white"
          placeholder="0 LP"
          bind:value={userStakeUnstakeAmount}
        />
        <div class="bg-white p-2">
          <button class="bg-grey bg-slate-300 rounded-md text-xs px-1"
            >max.</button
          >
        </div>
        <select
          id="currency"
          name="currency"
          class="h-full p-2 outline-none bg-white"
        >
          <option>Stake</option>
          <option>Unstake</option>
          <option>Claim yield</option>
        </select>
        <button
          class="rounded-r-full bg-gradient-to-r from-white to-slate-300 text-black py-2 px-4 hover:bg-slate-100"
          >Approve</button
        >
      </div>
    </div>
  </div>
</div>
