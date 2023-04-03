# Public methods 📢

## Get balances by Hedera id (address)

* Parameters:
* `id`: Hedera id (address), example: 0.0.112233
* completion: result with `BalanceDataResponse` type

```swift
public func getBalance(_ id: String, completion: @escaping (_ result: BalanceData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getBalance");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(BalanceResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.getBalance('\(id)', '\(completionKey)')")
}
```

## Method to execure Hbar transfers from current account to receiver

* Parameters:
* accountId: sender
* `accountPrivateKey`: sender's private key to sign transfer transaction
* `receiverId`: receiver
* `amount`: amount
* completion: result with `TransferDataResponse` type

```swift
public func transferHbars(accountId: String, accountPrivateKey: String, receiverId: String, amount: Decimal, completion: @escaping (_ result: TransferData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("transferHbars");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(TransferResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.transferHbars('\(accountId)', '\(accountPrivateKey)', '\(receiverId)', '\(amount)', '\(completionKey)')")
}
```

## Method to execure token transfers from current account to receiver

* Parameters:
* `tokenId`: token
* `accountId`: sender
* `accountPrivateKey`: sender's private key to sign transfer transaction
* `receiverId`: receiver
* `amount`: amount
* `freeTransfer`: for tokens configured for this dAppCode on Blade backend
* completion: result with `TransferDataResponse` type

```swift
public func transferTokens(tokenId: String, accountId: String, accountPrivateKey: String, receiverId: String, amount: Decimal, freeTransfer: Bool = true, completion: @escaping (_ result: TransferData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("transferTokens");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(TransferResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.transferTokens('\(tokenId)', '\(accountId)', '\(accountPrivateKey)', '\(receiverId)', '\(amount)', \(freeTransfer), '\(completionKey)')")
}
```

## Method to create Hedera account

* Parameter completion: result with `CreatedAccountDataResponse` type

```swift
public func createHederaAccount(completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("createAccount");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(CreatedAccountResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.createAccount('\(completionKey)')")
}
```

## Method to get pending Hedera account

* `transactionId`: can be received on createHederaAccount method, when busy network is busy, and account creation added to queue
* `seedPhrase`: returned from createHederaAccount method, required for updating keys and proper response &#x20;
* Parameter `completion`: result with `CreatedAccountDataResponse` type

```swift
public func getPendingAccount(transactionId: String, seedPhrase: String, completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void) {

    let completionKey = getCompletionKey("getPendingAccount");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(CreatedAccountResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.getPendingAccount('\(transactionId)', '\(seedPhrase)', '\(completionKey)')")
}
```

## Method to delete Hedera account

* Parameters:
* `deleteAccountId`: account to delete - id
* `deletePrivateKey`: account to delete - private key
* `transferAccountId`: The ID of the account to transfer the remaining funds to.
* `operatorAccountId`: operator account Id
* `operatorPrivateKey`: operator account private key
* `completion`: result with TransactionReceipt type

```swift
public func deleteHederaAccount(deleteAccountId: String, deletePrivateKey: String, transferAccountId: String, operatorAccountId: String, operatorPrivateKey: String, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("deleteHederaAccount");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(TransactionReceiptResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.deleteAccount('\(deleteAccountId)', '\(deletePrivateKey)', '\(transferAccountId)', '\(operatorAccountId)', '\(operatorPrivateKey)',  '\(completionKey)')")
}
```

## Get acccont evmAddress and calculated evmAddress from public key

* Parameters:
* `accountId`: accountId
* `completion`: result with PrivateKeyDataResponse type

```swift
public func getAccountInfo (accountId: String, completion: @escaping (_ result: AccountInfoData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getAccountInfo");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(AccountInfoResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.getAccountInfo('\(accountId)', '\(completionKey)')")
}
```

## Restore public and private key by seed phrase

* Parameters:
* `menmonic`: seed phrase
* `lookupNames`: lookup for accounts
* `completion`: result with `PrivateKeyDataResponse` type

```swift
public func getKeysFromMnemonic (menmonic: String, lookupNames: Bool = false, completion: @escaping (_ result: PrivateKeyData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getKeysFromMnemonic");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(PrivateKeyResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.getKeysFromMnemonic('\(menmonic)', \(lookupNames), '\(completionKey)')")
}
```

## Sign message with private key

* Parameters:
* `messageString`: message in base64 string
* `privateKey`: private key string
* `completion`: result with `SignMessageDataResponse` type

```swift
public func sign (messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("sign");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(SignMessageResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.sign('\(messageString)', '\(privateKey)', '\(completionKey)')")
}
```

## Verify message signature with public key

* Parameters:
* `messageString`: message in base64 string
* `signature`: hex-encoded signature string
* `publicKey`: public key string
* `completion`: result with `SignMessageDataResponse` type

```swift
public func signVerify(messageString: String, signature: String, publicKey: String, completion: @escaping (_ result: SignVerifyMessageData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("signVerify");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(SignVerifyMessageResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.signVerify('\(messageString)', '\(signature)', '\(publicKey)', '\(completionKey)')")
}


public func createContractFunctionParameters() -> ContractFunctionParameters {
    return ContractFunctionParameters();
}
```

## Method to call smart-contract function from current account

* Parameters:
* `contractId`: contract
* `functionName`: function name
* `params`: function arguments
* `accountId`: sender
* `accountPrivateKey`: sender's private key to sign transfer transaction
* `gas`: gas amount for transaction (default 100000)
* `bladePayFee`: blade pay fee, otherwise fee will be payed from sender accountId
* `completion`: result with TransactionReceipt type

```swift
public func contractCallFunction(contractId: String, functionName: String, params: ContractFunctionParameters, accountId: String, accountPrivateKey: String, gas: Int = 100000, bladePayFee: Bool, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("contractCallFunction");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(TransactionReceiptResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    let paramsEncoded = params.encode();
    executeJS("bladeSdk.contractCallFunction('\(contractId)', '\(functionName)', '\(paramsEncoded)', '\(accountId)', '\(accountPrivateKey)', \(gas), \(bladePayFee), '\(completionKey)')")
}

public func contractCallQueryFunction(contractId: String, functionName: String, params: ContractFunctionParameters, accountId: String, accountPrivateKey: String, gas: Int = 100000, bladePayFee: Bool, returnTypes: [String], completion: @escaping (_ result: ContractQueryData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("contractCallQueryFunction");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(ContractQueryResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    let paramsEncoded = params.encode();
    executeJS("bladeSdk.contractCallQueryFunction('\(contractId)', '\(functionName)', '\(paramsEncoded)', '\(accountId)', '\(accountPrivateKey)', \(gas), \(bladePayFee), [\(returnTypes.map({"'\($0)'"}).joined(separator: ","))], '\(completionKey)')")
}
```

## Sign message with private key (hethers lib)

* Parameters:
* `messageString`: message in base64 string
* `privateKey`: private key string
* `completion`: result with SignMessageDataResponse type

```swift
public func hethersSign(messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("hethersSign");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(SignMessageResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.hethersSign('\(messageString)', '\(privateKey)', '\(completionKey)')")
}
```

## Method to split signature into v-r-s

* Parameters:
* `signature`: signature string "0x21fbf0696......"
* `completion`: result with SplitedSignature type

```swift
public func splitSignature(signature: String, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void ) {
    let completionKey = getCompletionKey("splitSignature");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(SplitSignatureResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.splitSignature('\(signature)', '\(completionKey)')")
}
```

## Get signature for contract params into v-r-s

* Parameters:
* `params`: params generated with ContractFunctionParameters
* `accountPrivateKey`: account private key string
* `completion`: result with SplitedSignature type

```swift
public func getParamsSignature(params: ContractFunctionParameters, accountPrivateKey: String, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void ) {
    let completionKey = getCompletionKey("getParamsSignature");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(SplitSignatureResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    let paramsEncoded = params.encode();
    executeJS("bladeSdk.getParamsSignature('\(paramsEncoded)', '\(accountPrivateKey)', '\(completionKey)')")
}
```

## Method to get transactions history

* Parameters:
* `accountId`: accountId of history
* `nextPage`: link from response to load next page of history
* `completion`: result with TransactionsHistory type

```swift
public func getTransactions(accountId: String, transactionType: String, nextPage: String = "", transactionsLimit: Int = 10, completion: @escaping (_ result: TransactionsHistoryData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getTransactions");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(TransactionsHistoryResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.getTransactions('\(accountId)', '\(transactionType)', '\(nextPage)', '\(transactionsLimit)', '\(completionKey)')")
}
```
