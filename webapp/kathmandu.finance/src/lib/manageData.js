import BN from "bn.js";


import { userConnection, userData } from "$lib/stores/userData.js";
import { kathmandu } from "$lib/stores/kathmandu.js";

import kathmanduAbi from "$lib/abis/Kathmandu.json";
import defaultErc20Abi from "$lib/abis/ERC20.json";

import {
    defaultEvmStores,
    connected,
    selectedAccount,
    chainId,
    web3,
    contracts
} from "svelte-web3";


import { get } from 'svelte/store'


export function setRefreshHooks() {

    userConnection.subscribe(refreshData)

}

export async function refreshData() {

    var oldStorage = get(kathmandu)
    oldStorage.finishedLoading = false
    kathmandu.set(oldStorage)

    var defaultChain = get(userConnection).defaultChain
    if (get(userConnection).connected) {
        defaultChain = Object.keys(get(kathmandu).chainIds).find(k => get(kathmandu).chainIds[k] === get(userConnection).connectedToChainId);
    }
    console.log(defaultChain)

    await defaultEvmStores.attachContract('myKathmandu', get(kathmandu).kathmanduContracts[defaultChain], kathmanduAbi.abi)
    console.log("Jo")
    var availableDurbars = get(kathmandu).durbars[defaultChain]
    console.log("Jo2")

    for (var i in availableDurbars) {
        var durbarName = availableDurbars[i]

        if (get(kathmandu).associatedTokens[defaultChain] == undefined) {
            var associatedContracts = await get(contracts).myKathmandu.methods.getAssociatedTokensForDurbar(durbarName).call()


    

            var associatedTokens = {}

            for (var n in associatedContracts) {
                var contract = associatedContracts[n]

                await defaultEvmStores.attachContract('myTempErc20', contract, defaultErc20Abi.abi)
                var symbol = await get(contracts).myTempErc20.methods.symbol().call()
                var name = await get(contracts).myTempErc20.methods.name().call()

                var name;
                if(n == 0){
                    name = "baseToken"
                }else if(n == 1){
                    name = "wrapToken"
                }else{
                    name = "liqToken"
                }

                associatedTokens[name] = [contract, [symbol,name]]

            }
            var currentStorage = get(kathmandu)

            if(currentStorage.associatedTokens[defaultChain] == undefined){
                currentStorage.associatedTokens[defaultChain] = {}
            }
            
            currentStorage.associatedTokens[defaultChain][durbarName] = associatedTokens
            kathmandu.set(currentStorage)
        }



        if (get(selectedAccount) != undefined && get(userConnection).connected) {
            console.log("getting balances")
            for (var m in Object.keys(get(kathmandu).associatedTokens[defaultChain][durbarName])) {
                if (get(userData).balances[defaultChain] == undefined) {
                    get(userData).balances[defaultChain] = {}
                }
                var key = Object.keys(get(kathmandu).associatedTokens[defaultChain][durbarName])[m]
                console.log(get(kathmandu).associatedTokens[defaultChain][durbarName])

                var contract_addy = get(kathmandu).associatedTokens[defaultChain][durbarName][key][0]
                console.log(m)
                await defaultEvmStores.attachContract('myTempErc20', contract_addy, defaultErc20Abi.abi)
                var balance = await get(contracts).myTempErc20.methods.balanceOf(get(selectedAccount)).call()
                var oldStorage = get(userData)
                if (oldStorage.balances[defaultChain][durbarName] == undefined) {
                    oldStorage.balances[defaultChain][durbarName] = {}
                }

                if (balance != undefined) {
                    var bnBalance = new BN(balance)
                    oldStorage.balances[defaultChain][durbarName][get(kathmandu).associatedTokens[defaultChain][durbarName][key][1][0]] = get(web3).utils.fromWei(bnBalance, "ether")
                    oldStorage.userDataLoaded = true
                    userData.set(oldStorage)
                }

            }
            console.log(get(userData))
        }

        var wrapRatio = await get(contracts).myKathmandu.methods.getWrapTokenRatioForDurbar(durbarName).call()
        var baseTokenRatio = 1.0 / get(web3).utils.fromWei(new BN(wrapRatio), "ether")
        var oldStorage = get(kathmandu)
        if (oldStorage.wrappedRatios[defaultChain] == undefined) {
            oldStorage.wrappedRatios[defaultChain] = {}
        }
        oldStorage.wrappedRatios[defaultChain][durbarName] = baseTokenRatio
        kathmandu.set(oldStorage)


        //calculate APYs

        var oldStorage = get(kathmandu)
        if(oldStorage.apys[defaultChain] == undefined){
            oldStorage.apys[defaultChain] = {}
        }
        oldStorage.apys[defaultChain][durbarName] = {'wrapAPY': 69.0, 'stakeAPY':420.0}
        kathmandu.set(oldStorage)



    }

    var oldStorage = get(kathmandu)
    oldStorage.finishedLoading = true
    kathmandu.set(oldStorage)
}