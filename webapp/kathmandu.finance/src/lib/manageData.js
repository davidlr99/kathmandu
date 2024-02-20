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
    if(defaultChain == undefined){
        return
    }

    await defaultEvmStores.attachContract('myKathmandu', get(kathmandu).kathmanduContracts[defaultChain], kathmanduAbi.abi)

    var availableDurbars = get(kathmandu).durbars[defaultChain]
    console.log(availableDurbars +" at chain: "+defaultChain)

    for (var i in availableDurbars) {
        var durbarName = availableDurbars[i]

        if (get(kathmandu).associatedTokens[defaultChain] == undefined) {
            var associatedContracts = await get(contracts).myKathmandu.methods.getAssociatedTokensForDurbar(durbarName).call()


    

            var associatedTokens = {}

            for (var n in associatedContracts) {
                var contract = associatedContracts[n]

                await defaultEvmStores.attachContract('myTempErc20', contract, defaultErc20Abi.abi)
                var symbol = await get(contracts).myTempErc20.methods.symbol().call()
                var longname = await get(contracts).myTempErc20.methods.name().call()

                var name;
                if(n == 0){
                    name = "baseToken"
                }else if(n == 1){
                    name = "wrapToken"
                }else{
                    name = "liqToken"
                }

                associatedTokens[name] = [contract, [symbol,longname]]

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

            var reward = await get(contracts).myKathmandu.methods.getStakedLPandRewardInfoForUser(durbarName,get(selectedAccount)).call()
            console.log("Reward: "+reward)
            var bnReward = new BN(reward[1])
            var bnLPStaked = new BN(reward[0])
            oldStorage.balances[defaultChain][durbarName]["staked-lp"] = get(web3).utils.fromWei(bnLPStaked, "ether") 

            var oldStorage = get(userData)
            if (oldStorage.lprewards[defaultChain] == undefined) {
                oldStorage.lprewards[defaultChain] = {}
            }

            oldStorage.lprewards[defaultChain][durbarName] = get(web3).utils.fromWei(bnReward, "ether")
            userData.set(oldStorage)


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
        console.log("Set "+defaultChain+" apy structure")
        oldStorage.apys[defaultChain][durbarName] = {'wrapAPY': 69.0, 'stakeAPY':420.0}
        kathmandu.set(oldStorage)



    }

    console.log("Setting finished loading...")

    var oldStorage = get(kathmandu)
    oldStorage.finishedLoading = true
    kathmandu.set(oldStorage)
}