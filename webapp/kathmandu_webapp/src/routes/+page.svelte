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

    let kathmanduMainContract = "0xB63fc3C8BC59d31b35A027908F36751bB689e52c";
    let durbarName = "tETHtest";
    let tokenContract = "0x757d8f5c28e39339511874E77462a88EEcd1342B";
    let wrapperTokenContract = "0x7a8e2B4f4a98400934D40Bf1Cdb3B071a9D2FD49";
    let liqTokenContract = "0x980d1Bd1A2dF57199DAa2A1310f388B9BB3c0DDf";
    let feeRateToWrappers100 = 100;
    let feeRateToLPsIn100 = 100;
    let feeRateToDevIn100 = 100;

    let wrapAmount = 100;
    let unWrapAmount = 100;

    let stakeAmount = 10
    let unStakeAmount = 10

    onMount(async function () {
        await defaultEvmStores.setProvider();
    });

    async function wrapTokens() {
        var testTokenContract = new $web3.eth.Contract(
            testToken.abi,
            tokenContract,
            {
                from: $selectedAccount,
            },
        );

        await testTokenContract.methods
            .approve(
                kathmanduMainContract,
                $web3.utils.toWei(wrapAmount, "ether"),
            )
            .send({
                from: $selectedAccount,
            });

        var testKathmanduContract = new $web3.eth.Contract(
            kathmanduContract.abi,
            kathmanduMainContract,
            {
                from: $selectedAccount,
            },
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
            },
        );

        await wrapperTokenC.methods
            .approve(
                kathmanduMainContract,
                $web3.utils.toWei(unWrapAmount, "ether"),
            )
            .send({
                from: $selectedAccount,
            });

        var testKathmanduContract = new $web3.eth.Contract(
            kathmanduContract.abi,
            kathmanduMainContract,
            {
                from: $selectedAccount,
            },
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
            },
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
                true,
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
            },
        );

        await testLiquidityToken.methods
            .approve(
                kathmanduMainContract,
                $web3.utils.toWei(stakeAmount, "ether"),
            )
            .send({
                from: $selectedAccount,
            });

        var testKathmanduContract = new $web3.eth.Contract(
            kathmanduContract.abi,
            kathmanduMainContract,
            {
                from: $selectedAccount,
            },
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
            },
        );

        await testKathmanduContract.methods
            .unStakeLiq(durbarName, $web3.utils.toWei(unStakeAmount, "ether"))
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
