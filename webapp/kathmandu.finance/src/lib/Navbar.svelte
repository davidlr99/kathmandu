<script>
    import Fa from "svelte-fa";
    import { faXTwitter } from "@fortawesome/free-brands-svg-icons";
    import { faDiscord } from "@fortawesome/free-brands-svg-icons";
    import { userConnection } from "$lib/stores/userData.js";
    import { kathmandu } from "$lib/stores/kathmandu.js";

    import {
        defaultEvmStores,
        connected,
        selectedAccount,
        chainId,
        web3,
    } from "svelte-web3";
    import { Jazzicon } from "svelte-web3/components";

    import { browser } from "$app/environment";

    async function connectWallet() {
        await defaultEvmStores.setProvider();
        await checkChain($connected, $selectedAccount, $chainId, true)
    }

    $: checkChain($connected, $selectedAccount, $chainId, false)


    async function checkChain(connected, selectedAccount, chainId, userRequest) {

        if (
            connected &&
            selectedAccount != null &&
            Object.values($kathmandu.chainIds).includes(Number(chainId))
        ) {
            $userConnection.connected = true;
            $userConnection.connectedToChainId = Number(chainId);
        } else {
            $userConnection.connected = false;
            if ( userRequest && !Object.values($kathmandu.chainIds).includes(Number(chainId))) {
                if (browser) {
                    try {
                        await window.ethereum.request({
                            method: "wallet_switchEthereumChain",
                            params: [
                                {
                                    chainId: $web3.utils.toHex(
                                        $kathmandu.chainIds["Blast Sepolia"],
                                    ),
                                },
                            ],
                        });
                    } catch (err) {
                        // This error code indicates that the chain has not been added to MetaMask
                        if (err.code === 4902) {
                            await window.ethereum.request({
                                method: "wallet_addEthereumChain",
                                params: [
                                    {
                                        chainName: "Blast Sepolia",
                                        chainId: $web3.utils.toHex(
                                            $kathmandu.chainIds[
                                                "Blast Sepolia"
                                            ],
                                        ),
                                        nativeCurrency: {
                                            name: "ETH",
                                            decimals: 18,
                                            symbol: "ETH",
                                        },
                                        rpcUrls: ["https://sepolia.blast.io"],
                                    },
                                ],
                            });
                        }
                    }
                }
            }
        }
    }
</script>

<nav class="font-manrope bg-slate-100 fixed h-16 top-0 w-full z-20">
    <div
        class="flex items-center justify-between py-4 px-8 h-full w-full items-center"
    >
        <a href="/"
            ><div class="text-center font-bold">KATHMANDU.FINANCE</div></a
        >
        <div class="flex gap-5">
            <div class="flex flex-row gap-5 m-auto">
                <Fa icon={faXTwitter} />
                <Fa icon={faDiscord} />
            </div>

            {#if !$userConnection.connected}
                <button
                    on:click={connectWallet}
                    class="rounded-full bg-black text-white py-1 px-2"
                    >Connect Wallet</button
                >
            {:else}
                <div
                    class="flex flex-row bg-black rounded-full text-white py-1 px-2 gap-2 items-center text-sm"
                >
                    <div>
                        {$selectedAccount.substring(0, 5) +
                            "..." +
                            $selectedAccount.substring(
                                $selectedAccount.length - 5,
                                $selectedAccount.length,
                            )}
                    </div>
                    <Jazzicon size={16} address={$selectedAccount} />
                </div>
            {/if}
        </div>
    </div>
</nav>
