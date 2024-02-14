<script>
    import Button from "$lib/Button.svelte";

</script>

<div
    class="bg-cover bg-no-repeat bg-fixed bg-bottom w-full min-h-screen pt-16"
    style="background-position: center 64px; background-image: url('/images/hero3.png');"
>
    <div class="flex flex-col relative w-full px-20 items-center min-h-full">
        <div
            class="flex md:flex-row flex-col items-center justify-between w-full h-full sm:py-52 py-24 gap-10"
        >
            <div
                class="flex flex-col items-start sm:max-w-xl max-w-none font-manrope z-4 relative"
            >
                <h1 class="text-white text-lp-secondary text-5xl mb-5">
                    Earn real yield on any liquid asset powered by market
                    volatility
                </h1>
                <p class="text-base text-white/90">
                    Wrap any ERC-20 and get paid yield on wrapped tokens from
                    arbitrators. Wrapped tokens are always backed 1:1. Provide
                    liquidity on your wrapped tokens to stabilze the system and
                    earn even more yield.
                </p>

                <div
                    class="flex sm:flex-row flex-col sm:items-center items-start gap-5 mt-5"
                >
                    <a href="/app"><Button>Launch App</Button></a>
                    <Button>Read Docs</Button>
                </div>
            </div>
            <img src="/images/kathmandu.explainer.drawio.svg" class="h-72" />
        </div>
    </div>
</div>
