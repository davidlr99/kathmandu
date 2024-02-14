<script>
    import * as icons from "@fortawesome/free-solid-svg-icons";
    import Fa from "svelte-fa";
    export let icon;
    export let title;
    export let value;
    export let undertitle;
</script>

<div
    class="h-30 bg-gradient-to-r from-slate-300 to-slate-400 rounded-md flex flex-row justify-start items-center gap-4 py-5 px-4 w-full"
>
    <Fa size="2x" class="ml-2" icon={icons[icon]} />
    <div class="flex flex-col items-start gap-1">
        <small class="text-sm font-manrope">{title}</small>
        <h2 class="text-3xl font-bold font-manrope">{value}</h2>
        <small class="text-xs font-manrope -mt-0.5">{undertitle}</small>
    </div>
</div>
