import { Client, AccountBalanceQuery, TransferTransaction, Mnemonic, PrivateKey } from "@hashgraph/sdk";

export class SDK {

    static NETWORK = 'testnet'

    /**
     * 
     * @param {string} network 
     */
    static setNetwork(network){
        SDK.NETWORK = network
    }

    /**
     * 
     * @param {string} accountId 
     */
    static getBalance(accountId, completionKey) {
        const client = SDK.#getClient();
        
        new AccountBalanceQuery()
            .setAccountId(accountId)
            .execute(client).then(data => {
                SDK.#sendMessageToNative(completionKey, data)
            }).catch(error => {
                SDK.#sendMessageToNative(completionKey, null, error)
            })
    }

    /**
     * 
     * @param {string} accountId 
     * @param {string} accountPrivateKey 
     * @param {string} receiverID 
     * @param {number} amount 
     */
    static transferHbars(accountId, accountPrivateKey, receiverID, amount, completionKey) {
        const client = SDK.#getClient();
        client.setOperator(accountId, accountPrivateKey)
    
        new TransferTransaction()
            .addHbarTransfer(receiverID, amount)
            .addHbarTransfer(accountId, -1 * amount)
            .execute(client).then(data => {
                SDK.#sendMessageToNative(completionKey, data)
            }).catch(error => {
                SDK.#sendMessageToNative(completionKey, null, error)
            })
    }
    
    /**
     * 
     * @param {string} completionKey 
     */
    static generateKeys(completionKey) {
        Mnemonic.generate12().then(seedPhrase => {
            //TODO check which type of keys to be used
            seedPhrase.toEd25519PrivateKey().then(privateKey => {
                var publicKey = privateKey.publicKey;
                SDK.#sendMessageToNative(completionKey, {
                    seedPhrase: seedPhrase.toString(),
                    publicKey: publicKey.toStringRaw(),
                    privateKey: privateKey.toStringRaw()
                })
            }).catch(error => {
                SDK.#sendMessageToNative(completionKey, null, error)
            })
        });
    }

    /**
     * 
     * @param {string} mnemonic 
     * @param {string} completionKey 
     */
    static getPrivateKeyStringFromMnemonic(mnemonic, completionKey) {
        Mnemonic.fromString(mnemonic).then(function (mnemonicObj) {
            //TODO check which type of keys to be used
            mnemonicObj.toEd25519PrivateKey().then(function (privateKey) {
                SDK.#sendMessageToNative(completionKey, {
                    privateKey: privateKey.toStringRaw()
                })
            }).catch((error) => {
                SDK.#sendMessageToNative(completionKey, null, error)    
            })
        }).catch((error) => {
            SDK.#sendMessageToNative(completionKey, null, error)
        })
    }

    /**
     * 
     * @returns {string}
     */
    static #getClient() {
        return SDK.NETWORK == "testnet" ? Client.forTestnet() : Client.forMainnet()
    }

    /**
     * 
     * @param {string} completionKey 
     * @param {*} data 
     * @param {Error} error 
     */
    static #sendMessageToNative(completionKey, data, error) {
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.bladeMessageHandler) {
            window.webkit.messageHandlers.bladeMessageHandler.postMessage(JSON.stringify({
                completionKey: completionKey,
                data: data,
                error: {
                    name: error.name,
                    reason: error.reason
                }               
            }));
        }
    }
};
