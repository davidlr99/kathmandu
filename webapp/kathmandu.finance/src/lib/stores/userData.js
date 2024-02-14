import { writable } from 'svelte/store';


export const userConnection = writable({
    connected: false,
    connectedToChainId: undefined,
    balances: {},
    defaultChain: 'Sepolia',
    userDataLoaded: false
});

export const userData = writable({
    balances: {}
});



