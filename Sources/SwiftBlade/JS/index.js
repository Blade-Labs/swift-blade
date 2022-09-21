import { Client, AccountBalanceQuery, TransferTransaction, Mnemonic, PrivateKey } from "@hashgraph/sdk";

export class SDK {

    static NETWORK = 'testnet'

    /**
     * 
     * @param {string} network 
     */
    static setNetwork(network, completionKey){
        SDK.NETWORK = network
        SDK.#sendMessageToNative(completionKey, {status: "success"})
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
            seedPhrase.toEcdsaPrivateKey().then(privateKey => {
                var publicKey = privateKey.publicKey;
                SDK.#sendMessageToNative(completionKey, {
                    seedPhrase: seedPhrase.toString(),
                    publicKey: publicKey.toStringDer(),
                    privateKey: privateKey.toStringDer()
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
            mnemonicObj.toEcdsaPrivateKey().then(function (privateKey) {
                SDK.#sendMessageToNative(completionKey, {
                    privateKey: privateKey.toStringDer()
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
            var responseObject = {
                completionKey: completionKey,
                data: data              
            }
            if (error) {
                responseObject["error"] = {
                    name: error.name,
                    reason: error.reason
                } 
            }
            window.webkit.messageHandlers.bladeMessageHandler.postMessage(JSON.stringify(responseObject));
        }
    }
};
