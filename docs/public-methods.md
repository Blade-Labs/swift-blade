# Public methods 📢

## Get SDK-instance info

### Parameters:

* `completion`: result with `InfoData` type

```swift
public func getInfo(completion: @escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getInfo");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(InfoResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.getInfo('\(completionKey)')")
}
```


## Get balances by Hedera id (address)

### Parameters:

* `id`: Hedera id (address), example: 0.0.112233
* `completion`: result with `BalanceData` type

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

## Method to execute Hbar transfers from current account to receiver

### Parameters:

* `accountId`: sender
* `accountPrivateKey`: sender's private key to sign transfer transaction
* `receiverId`: receiver
* `amount`: amount
* `memo`: memo (limited to 100 characters)
* `completion`: result with `TransferData` type

```swift
public func transferHbars(accountId: String, accountPrivateKey: String, receiverId: String, amount: Decimal, memo: String, completion: @escaping (_ result: TransferData?, _ error: BladeJSError?) -> Void) {
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
    executeJS("bladeSdk.transferHbars('\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(receiverId))', '\(amount)', '\(esc(memo))', '\(completionKey)')")
}
```

## Method to execute token transfers from current account to receiver

### Parameters:

* `tokenId`: token
* `accountId`: sender
* `accountPrivateKey`: sender's private key to sign transfer transaction
* `receiverId`: receiver
* `amount`: amount
* `memo`: memo (limited to 100 characters)
* `freeTransfer`: for tokens configured for this dAppCode on Blade backend
* `completion`: result with `TransferData` type

```swift
public func transferTokens(tokenId: String, accountId: String, accountPrivateKey: String, receiverId: String, amount: Decimal, memo: String, freeTransfer: Bool = true, completion: @escaping (_ result: TransferData?, _ error: BladeJSError?) -> Void) {
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
    executeJS("bladeSdk.transferTokens('\(esc(tokenId))', '\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(receiverId))', '\(amount)', '\(esc(memo))', \(freeTransfer), '\(completionKey)')")
}
```

## Method to create Hedera account

### Parameters

* `deviceId`: unique device id (advanced security feature, required only for some dApps)
* `completion`: result with `CreatedAccountData` type

```swift
public func createHederaAccount(deviceId: String, completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void) {
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
    executeJS("bladeSdk.createAccount('\(esc(deviceId))', '\(completionKey)')")
}
```

## Method to get pending Hedera account

### Parameters

* `transactionId`: can be received on createHederaAccount method, when busy network is busy, and account creation added to queue
* `seedPhrase`: returned from createHederaAccount method, required for updating keys and proper response &#x20;
* `completion`: result with `CreatedAccountData` type

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
    executeJS("bladeSdk.getPendingAccount('\(esc(transactionId))', '\(esc(seedPhrase))', '\(completionKey)')")
}
```

## Method to delete Hedera account

### Parameters:

* `deleteAccountId`: account to delete - id
* `deletePrivateKey`: account to delete - private key
* `transferAccountId`: The ID of the account to transfer the remaining funds to.
* `operatorAccountId`: operator account Id
* `operatorPrivateKey`: operator account private key
* `completion`: result with TransactionReceiptData type

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
    executeJS("bladeSdk.deleteAccount('\(esc(deleteAccountId))', '\(esc(deletePrivateKey))', '\(esc(transferAccountId))', '\(esc(operatorAccountId))', '\(esc(operatorPrivateKey))',  '\(completionKey)')")
}
```

## Get account evmAddress and calculated evmAddress from public key

### Parameters:

* `accountId`: accountId
* `completion`: result with AccountInfoData type

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
    executeJS("bladeSdk.getAccountInfo('\(esc(accountId))', '\(completionKey)')")
}
```

## Restore public and private key by seed phrase

### Parameters:

* `mnemonic`: seed phrase
* `lookupNames`: lookup for accounts
* `completion`: result with `PrivateKeyData` type

```swift
public func getKeysFromMnemonic (mnemonic: String, lookupNames: Bool = false, completion: @escaping (_ result: PrivateKeyData?, _ error: BladeJSError?) -> Void) {
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
    executeJS("bladeSdk.getKeysFromMnemonic('\(esc(mnemonic))', \(lookupNames), '\(completionKey)')")
}
```

## Sign message with private key

### Parameters:

* `messageString`: message in base64 string
* `privateKey`: private key string
* `completion`: result with `SignMessageData` type

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
    executeJS("bladeSdk.sign('\(esc(messageString))', '\(esc(privateKey))', '\(completionKey)')")
}
```

## Verify message signature with public key

### Parameters:

* `messageString`: message in base64 string
* `signature`: hex-encoded signature string
* `publicKey`: public key string
* `completion`: result with `SignVerifyMessageData` type

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
    executeJS("bladeSdk.signVerify('\(esc(messageString))', '\(esc(signature))', '\(esc(publicKey))', '\(completionKey)')")
}
```

## Method to create smart-contract function parameters (instance of ContractFunctionParameters)

```swift
public func createContractFunctionParameters() -> ContractFunctionParameters {
    return ContractFunctionParameters();
}
```

## Method to call smart-contract function

### Parameters:

* `contractId`: contract id
* `functionName`: contract function name
* `params`: function arguments (instance of ContractFunctionParameters)
* `accountId`: sender account id
* `accountPrivateKey`: sender's private key to sign transfer transaction
* `gas`: gas amount for transaction (default 100000)
* `bladePayFee`: blade pay fee, otherwise fee will be pay from sender accountId
* `completion`: result with TransactionReceiptData type

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
    executeJS("bladeSdk.contractCallFunction('\(esc(contractId))', '\(esc(functionName))', '\(paramsEncoded)', '\(esc(accountId))', '\(esc(accountPrivateKey))', \(gas), \(bladePayFee), '\(completionKey)')")
}
```

## Method to call smart-contract query

### Parameters:

* `contractId`: contract id
* `functionName`: contract function name
* `params`: function arguments (instance of ContractFunctionParameters)
* `accountId`: sender account id
* `accountPrivateKey`: sender's private key to sign transfer transaction
* `gas`: gas amount for transaction (default 100000)
* `bladePayFee`: blade pay fee, otherwise fee will be pay from sender accountId
* `returnTypes`: array of return types, e.g. ["string", "int32"]
* `completion`: result with ContractQueryData type

```swift
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
    executeJS("bladeSdk.contractCallQueryFunction('\(esc(contractId))', '\(esc(functionName))', '\(paramsEncoded)', '\(esc(accountId))', '\(esc(accountPrivateKey))', \(gas), \(bladePayFee), [\(returnTypes.map({"'\(esc($0))'"}).joined(separator: ","))], '\(completionKey)')")
}
```

## Sign message with private key (ethers lib)

### Parameters:

* `messageString`: message in base64 string
* `privateKey`: private key string
* `completion`: result with SignMessageData type

```swift
public func ethersSign(messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("ethersSign");
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
    executeJS("bladeSdk.ethersSign('\(esc(messageString))', '\(esc(privateKey))', '\(completionKey)')")
}
```

## Method to split signature into v-r-s

### Parameters:

* `signature`: signature string "0x21fbf0696......"
* `completion`: result with SplitSignatureData type

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
    executeJS("bladeSdk.splitSignature('\(esc(signature))', '\(completionKey)')")
}
```

## Get signature for contract params into v-r-s

### Parameters:

* `params`: function arguments (instance of ContractFunctionParameters)
* `accountPrivateKey`: account private key string
* `completion`: result with SplitSignatureData type

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
    executeJS("bladeSdk.getParamsSignature('\(paramsEncoded)', '\(esc(accountPrivateKey))', '\(completionKey)')")
}
```

## Method to get transactions history

### Parameters:
* `accountId`: accountId of history
* `transactionType`: filter by type of transaction 
* `nextPage`: link from response to load next page of history
* `transactionsLimit`: limit of transactions to load
* `completion`: result with TransactionsHistoryData type

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
    executeJS("bladeSdk.getTransactions('\(esc(accountId))', '\(esc(transactionType))', '\(esc(nextPage))', '\(transactionsLimit)', '\(completionKey)')")
}
```

## Method to get C14 url for payment

### Parameters:

* `asset`: USDC, HBAR, KARATE or C14 asset uuid
* `account`: receiver account id
* `amount`: amount to buy
* `completion`: result with IntegrationUrlData type

```swift
public func getC14url(asset: String, account: String, amount: String, completion: @escaping (_ result: IntegrationUrlData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getC14url");
    deferCompletion(forKey: completionKey) { (data, error) in
        if (error != nil) {
            return completion(nil, error)
        }
        do {
            let response = try JSONDecoder().decode(IntegrationUrlResponse.self, from: data!)
            completion(response.data, nil)
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
        }
    }
    executeJS("bladeSdk.getC14url('\(esc(asset))', '\(esc(account))', '\(esc(amount))', '\(completionKey)')")
}
```


## Method to get swap quotes from different services

### Parameters:

* `sourceCode`: name (HBAR, KARATE, other token code)
* `sourceAmount`: amount to swap, buy or sell
* `targetCode`: name (HBAR, KARATE, USDC, other token code)
* `strategy`: one of enum CryptoFlowServiceStrategy (Buy, Sell, Swap)
* `completion`: callback function, with result of SwapQuotesData or BladeJSError

```swift
public func exchangeGetQuotes(
    sourceCode: String,
    sourceAmount: Double,
    targetCode: String,
    strategy: CryptoFlowServiceStrategy,
    completion: @escaping (_ result: SwapQuotesData?, _ error: BladeJSError?) -> Void
) {
    let completionKey = getCompletionKey("exchangeGetQuotes");
    performRequest(
        completionKey: completionKey,
        js: "exchangeGetQuotes('\(esc(sourceCode))', \(sourceAmount), '\(esc(targetCode))', '\(esc(strategy.rawValue))', '\(completionKey)')",
        decodeType: SwapQuotesResponse.self,
        completion: completion
    )
}
```

## Method to get configured url to buy or sell tokens or fiat

### Parameters:

* `strategy`: Buy / Sell
* `accountId`: account id
* `sourceCode`: name (HBAR, KARATE, USDC, other token code)
* `sourceAmount`: amount to buy/sell
* `targetCode`: name (HBAR, KARATE, USDC, other token code)
* `slippage`: slippage in percents. Transaction will revert if the price changes unfavorably by more than this percentage.
* `serviceId`: service id to use for swap (saucerswap, onmeta, etc)
* `completion`: callback function, with result of IntegrationUrlData or BladeJSError

```swift
public func getTradeUrl(
    strategy: CryptoFlowServiceStrategy,
    accountId: String,
    sourceCode: String,
    sourceAmount: Double,
    targetCode: String,
    slippage: Double,
    serviceId: String,
    completion: @escaping (_ result: IntegrationUrlData?, _ error: BladeJSError?) -> Void
) {
    let completionKey = getCompletionKey("getTradeUrl");
    performRequest(
        completionKey: completionKey,
        js: "getTradeUrl('\(strategy.rawValue)', '\(esc(accountId))', '\(esc(sourceCode))', \(sourceAmount), '\(esc(targetCode))', \(slippage), '\(esc(serviceId))', '\(completionKey)')",
        decodeType: IntegrationUrlResponse.self,
        completion: completion
    )
}
```

## Method to swap tokens

### Parameters:

* `accountId`: account id
* `accountPrivateKey`: account private key
* `sourceCode`: name (HBAR, KARATE, other token code)
* `sourceAmount`: amount to swap
* `targetCode`: name (HBAR, KARATE, other token code)
* `slippage`: slippage in percents. Transaction will revert if the price changes unfavorably by more than this percentage.
* `serviceId`: service id to use for swap (saucerswap, etc)
* `completion`: callback function, with result of ResultData or BladeJSError

```swift
public func swapTokens(
    accountId: String,
    accountPrivateKey: String,
    sourceCode: String,
    sourceAmount: Double,
    targetCode: String,
    slippage: Double,
    serviceId: String,
    completion: @escaping (_ result: ResultData?, _ error: BladeJSError?) -> Void
) {
    let completionKey = getCompletionKey("swapTokens");
    performRequest(
        completionKey: completionKey,
        js: "swapTokens('\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(sourceCode))', \(sourceAmount), '\(esc(targetCode))', \(slippage), '\(esc(serviceId))', '\(completionKey)')",
        decodeType: ResultResponse.self,
        completion: completion
    )
}
```


## Method to clean-up webView

```swift
public func cleanup() {
    if (self.webView != nil) {
        self.webView!.configuration.userContentController.removeScriptMessageHandler(forName: "bladeMessageHandler")
        self.webView!.removeFromSuperview()
        self.webView!.navigationDelegate = nil
        self.webView!.uiDelegate = nil

        // Set webView to nil
        self.webView = nil
    }

    webViewInitialized = false
    deferCompletions = [:]
    initCompletion = nil
    apiKey = nil
    dAppCode = nil
}
```