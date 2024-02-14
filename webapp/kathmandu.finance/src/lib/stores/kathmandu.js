import { writable } from 'svelte/store';


export const kathmandu = writable({
    chainIds: {"Blast Sepolia": 168587773,"Sepolia": 11155111},
    kathmanduContracts: {"Blast Sepolia":'', "Sepolia":'0xB63fc3C8BC59d31b35A027908F36751bB689e52c'},
    durbars: {"Blast Sepolia":[], "Sepolia":['tETHtest']},

    //filled dynamically
    associatedTokens: {},
    wrappedRatios: {},
    apys: {},
    finishedLoading: false
});