# Public methods 📢

## Get SDK-instance info

### Parameters:

* `completion`: result with `InfoData` type

```swift
public func getInfo(completion: @escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getInfo");
    performRequest(
        completionKey: completionKey,
        js: "getInfo('\(completionKey)')",
        decodeType: InfoResponse.self,
        completion: completion
    )
}
```

## Get balances by Hedera id (address)

### Parameters:

* `id`: Hedera id (address), example: 0.0.112233
* `completion`: result with `BalanceData` type

```swift
public func getBalance(_ id: String, completion: @escaping (_ result: BalanceData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getBalance");
    performRequest(
        completionKey: completionKey,
        js: "getBalance('\(esc(id))', '\(completionKey)')",
        decodeType: BalanceResponse.self,
        completion: completion
    )
}
```

## Get list of all available coins on CoinGecko

### Parameters:

* `completion`: result with `CoinListData` type

```swift
public func getCoinList(completion: @escaping (_ result: CoinListData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getCoinList");
    performRequest(
        completionKey: completionKey,
        js: "getCoinList('\(completionKey)')",
        decodeType: CoinListResponse.self,
        completion: completion
    )
}
```

## Get coin price and coin info from CoinGecko. Search can be coin id or address in one of the coin platforms.

### Parameters:

* `search`: CoinGecko coinId, or address in one of the coin platforms or `hbar` (default, alias for `hedera-hashgraph`)
* `completion`: result with `CoinInfoData` type

```swift
public func getCoinPrice(_ search: String, completion: @escaping (_ result: CoinInfoData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getCoinPrice");
    performRequest(
        completionKey: completionKey,
        js: "getCoinPrice('\(esc(search))', '\(completionKey)')",
        decodeType: CoinInfoResponse.self,
        completion: completion
    )
}
```

## Method to execute Hbar transfers from current account to receiver

### Parameters:

* `accountId`: sender
* `accountPrivateKey`: sender's private key to sign transfer transaction
* `receiverId`: receiver
* `amount`: amount
* `memo`: memo (limited to 100 characters)
* `completion`: result with `TransactionReceiptData` type

```swift
public func transferHbars(accountId: String, accountPrivateKey: String, receiverId: String, amount: Decimal, memo: String, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("transferHbars")
    performRequest(
        completionKey: completionKey,
        js: "transferHbars('\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(receiverId))', '\(amount)', '\(esc(memo))', '\(completionKey)')",
        decodeType: TransactionReceiptResponse.self,
        completion: completion
    )
}
```

## Method to execute token transfers from current account to receiver

### Parameters:

* `tokenId`: token
* `accountId`: sender
* `accountPrivateKey`: sender's private key to sign transfer transaction
* `receiverId`: receiver
* `amountOrSerial`: amount of fungible tokens to send (with token-decimals correction) on NFT serial number
* `memo`: memo (limited to 100 characters)
* `freeTransfer`: for tokens configured for this dAppCode on Blade backend
* `completion`: result with `TransactionReceiptData` type

```swift
public func transferTokens(tokenId: String, accountId: String, accountPrivateKey: String, receiverId: String, amountOrSerial: Decimal, memo: String, freeTransfer: Bool = true, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("transferTokens")
    performRequest(
        completionKey: completionKey,
        js: "transferTokens('\(esc(tokenId))', '\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(receiverId))', '\(amountOrSerial)', '\(esc(memo))', \(freeTransfer), '\(completionKey)')",
        decodeType: TransactionReceiptResponse.self,
        completion: completion
    )
}
```

## Method to create Hedera account

### Parameters

* `deviceId`: unique device id (advanced security feature, required only for some dApps)
* `completion`: result with `CreatedAccountData` type

```swift
public func createHederaAccount(deviceId: String, completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("createAccount");
    performRequest(
        completionKey: completionKey,
        js: "createAccount('\(esc(deviceId))', '\(completionKey)')",
        decodeType: CreatedAccountResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "getPendingAccount('\(esc(transactionId))', '\(esc(seedPhrase))', '\(completionKey)')",
        decodeType: CreatedAccountResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "deleteAccount('\(esc(deleteAccountId))', '\(esc(deletePrivateKey))', '\(esc(transferAccountId))', '\(esc(operatorAccountId))', '\(esc(operatorPrivateKey))',  '\(completionKey)')",
        decodeType: TransactionReceiptResponse.self,
        completion: completion
    )
}
```

## Get account evmAddress and calculated evmAddress from public key

### Parameters:

* `accountId`: accountId
* `completion`: result with AccountInfoData type

```swift
public func getAccountInfo (accountId: String, completion: @escaping (_ result: AccountInfoData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getAccountInfo");
    performRequest(
        completionKey: completionKey,
        js: "getAccountInfo('\(esc(accountId))', '\(completionKey)')",
        decodeType: AccountInfoResponse.self,
        completion: completion
    )
}
```

## Get Node list

### Parameters:

* `completion`: result with NodesData type

```swift
public func getNodeList(completion: @escaping (_ result: NodesData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("getNodeList")
    performRequest(
        completionKey: completionKey,
        js: "getNodeList('\(completionKey)')",
        decodeType: NodesResponse.self,
        completion: completion
    )
}
```

## Stake/unstake account

### Parameters:

* `accountId`: accountId
* `accountPrivateKey` account private key (DER encoded hex string)
* `nodeId` node id to stake to. If negative or null, account will be unstaked
* `completion`: result with TransactionReceiptData type


```swift
public func stakeToNode(accountId: String, accountPrivateKey: String, nodeId: Int, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
    let completionKey = getCompletionKey("stakeToNode")
    performRequest(
        completionKey: completionKey,
        js: "stakeToNode('\(esc(accountId))', '\(esc(accountPrivateKey))', \(nodeId), '\(completionKey)')",
        decodeType: TransactionReceiptResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "getKeysFromMnemonic('\(esc(mnemonic))', \(lookupNames), '\(completionKey)')",
        decodeType: PrivateKeyResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "sign('\(esc(messageString))', '\(esc(privateKey))', '\(completionKey)')",
        decodeType: SignMessageResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "signVerify('\(esc(messageString))', '\(esc(signature))', '\(esc(publicKey))', '\(completionKey)')",
        decodeType: SignVerifyMessageResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "contractCallFunction('\(esc(contractId))', '\(esc(functionName))', '\(params.encode())', '\(esc(accountId))', '\(esc(accountPrivateKey))', \(gas), \(bladePayFee), '\(completionKey)')",
        decodeType: TransactionReceiptResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "contractCallQueryFunction('\(esc(contractId))', '\(esc(functionName))', '\(params.encode())', '\(esc(accountId))', '\(esc(accountPrivateKey))', \(gas), \(bladePayFee), [\(returnTypes.map({"'\(esc($0))'"}).joined(separator: ","))], '\(completionKey)')",
        decodeType: ContractQueryResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "ethersSign('\(esc(messageString))', '\(esc(privateKey))', '\(completionKey)')",
        decodeType: SignMessageResponse.self,
        completion: completion
    )
}
```

## Method to split signature into v-r-s

### Parameters:

* `signature`: signature string "0x21fbf0696......"
* `completion`: result with SplitSignatureData type

```swift
public func splitSignature(signature: String, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void ) {
    let completionKey = getCompletionKey("splitSignature");
    performRequest(
        completionKey: completionKey,
        js: "splitSignature('\(esc(signature))', '\(completionKey)')",
        decodeType: SplitSignatureResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "getParamsSignature('\(params.encode())', '\(esc(accountPrivateKey))', '\(completionKey)')",
        decodeType: SplitSignatureResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "getTransactions('\(esc(accountId))', '\(esc(transactionType))', '\(esc(nextPage))', '\(transactionsLimit)', '\(completionKey)')",
        decodeType: TransactionsHistoryResponse.self,
        completion: completion
    )
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
    performRequest(
        completionKey: completionKey,
        js: "getC14url('\(esc(asset))', '\(esc(account))', '\(esc(amount))', '\(completionKey)')",
        decodeType: IntegrationUrlResponse.self,
        completion: completion
    )
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



## Create token (NFT or Fungible Token)

### Parameters:
 
* `treasuryAccountId`: treasury account id
* `supplyPrivateKey`: supply account private key
* `tokenName`: token name (string up to 100 bytes)
* `tokenSymbol`: token symbol (string up to 100 bytes)
* `isNft`: set token type NFT
* `keys`: token keys
* `decimals`: token decimals (0 for nft)
* `initialSupply`: token initial supply (0 for nft)
* `maxSupply`: token max supply
* `completion`: callback function, with result of CreateTokenData or BladeJSError

```swift
public func createToken(
     treasuryAccountId: String,
     supplyPrivateKey: String,
     tokenName: String,
     tokenSymbol: String,
     isNft: Bool,
     keys: [KeyRecord],
     decimals: Int,
     initialSupply: Int,
     maxSupply: Int,
     completion: @escaping (_ result: CreateTokenData?, _ error: BladeJSError?) -> Void
) {
    let completionKey = getCompletionKey("createToken")
    let keysJson = keys.map { try? JSONEncoder().encode($0) }
                          .compactMap { $0 }
                          .map { String(data: $0, encoding: .utf8)! }
                          .joined(separator: ",")
    performRequest(
        completionKey: completionKey,
        js: "createToken('\(esc(treasuryAccountId))', '\(esc(supplyPrivateKey))', '\(esc(tokenName))', '\(esc(tokenSymbol))', \(isNft),  [\(keysJson)], \(decimals), \(initialSupply), \(maxSupply), '\(completionKey)')",
        decodeType: CreateTokenResponse.self,
        completion: completion
    )
}
```

## Associate token to account. Association fee will be covered by Blade, if tokenId configured in dApp

### Parameters:

* `tokenId`: token id to associate. Empty to associate all tokens configured in dApp
* `accountId`: account id to associate token
* `accountPrivateKey`: account private key
* `completion`: callback function, with result of TransactionReceiptData or BladeJSError

```swift
public func associateToken(
    tokenId: String,
    accountId: String,
    accountPrivateKey: String,
    completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void
) {
    let completionKey = getCompletionKey("associateToken")
    performRequest(
        completionKey: completionKey,
        js: "associateToken('\(esc(tokenId))', '\(esc(accountId))', '\(esc(accountPrivateKey))', '\(completionKey)')",
        decodeType: TransactionReceiptResponse.self,
        completion: completion
    )
}
```

## Mint one NFT

### Parameters:

* `tokenId`: token id to mint NFT
* `supplyAccountId`: token supply account id
* `supplyPrivateKey`: token supply private key
* `file`: image to mint (base64 DataUrl image, eg.: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAA...)
* `metadata`: NFT metadata
* `storageConfig`: IPFS provider config
* `completion`: callback function, with result of CreateTokenData or BladeJSError

```swift
public func createToken(
     treasuryAccountId: String,
     supplyPrivateKey: String,
     tokenName: String,
     tokenSymbol: String,
     isNft: Bool,
     keys: [KeyRecord],
     decimals: Int,
     initialSupply: Int,
     maxSupply: Int,
     completion: @escaping (_ result: CreateTokenData?, _ error: BladeJSError?) -> Void
) {
    let completionKey = getCompletionKey("createToken")
    let keysJson = keys.map { try? JSONEncoder().encode($0) }
                          .compactMap { $0 }
                          .map { String(data: $0, encoding: .utf8)! }
                          .joined(separator: ",")
    performRequest(
        completionKey: completionKey,
        js: "createToken('\(esc(treasuryAccountId))', '\(esc(supplyPrivateKey))', '\(esc(tokenName))', '\(esc(tokenSymbol))', \(isNft),  [\(keysJson)], \(decimals), \(initialSupply), \(maxSupply), '\(completionKey)')",
        decodeType: CreateTokenResponse.self,
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