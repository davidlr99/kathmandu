import { writable } from 'svelte/store';


export const kathmandu = writable({
    chainIds: {"Blast Sepolia": 168587773,"Sepolia": 11155111},
    kathmanduContracts: {"Blast Sepolia":'0x483F125ac490d8347f5a2B1E7d3C7dC6D2B505e2', "Sepolia":'0xB63fc3C8BC59d31b35A027908F36751bB689e52c'},
    durbars: {"Blast Sepolia":['wETH'], "Sepolia":['tETHtest']},
    durbarDetails: {"Blast Sepolia":{'wETH':{image:'/images/eth.svg'}} ,"Sepolia":{'tETHtest':{image:'/images/eth.svg'}}},
    //filled dynamically
    associatedTokens: {},
    wrappedRatios: {},
    apys: {},
    finishedLoading: false
});