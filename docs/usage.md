# Contents

* [initialize](usage.md#initialize)
* [getInfo](usage.md#getinfo)
* [setUser](usage.md#setuser)
* [resetUser](usage.md#resetuser)
* [getBalance](usage.md#getbalance)
* [transferBalance](usage.md#transferbalance)
* [transferTokens](usage.md#transfertokens)
* [getCoinList](usage.md#getcoinlist)
* [getCoinPrice](usage.md#getcoinprice)
* [createContractFunctionParameters](usage.md#createcontractfunctionparameters)
* [contractCallFunction](usage.md#contractcallfunction)
* [contractCallQueryFunction](usage.md#contractcallqueryfunction)
* [createScheduleTransaction](usage.md#createscheduletransaction)
* [signScheduleId](usage.md#signscheduleid)
* [createAccount](usage.md#createaccount)
* [deleteAccount](usage.md#deleteaccount)
* [getAccountInfo](usage.md#getaccountinfo)
* [getNodeList](usage.md#getnodelist)
* [stakeToNode](usage.md#staketonode)
* [searchAccounts](usage.md#searchaccounts)
* [dropTokens](usage.md#droptokens)
* [sign](usage.md#sign)
* [verify](usage.md#verify)
* [splitSignature](usage.md#splitsignature)
* [getParamsSignature](usage.md#getparamssignature)
* [getTransactions](usage.md#gettransactions)
* [exchangeGetQuotes](usage.md#exchangegetquotes)
* [getTradeUrl](usage.md#gettradeurl)
* [swapTokens](usage.md#swaptokens)
* [createToken](usage.md#createtoken)
* [associateToken](usage.md#associatetoken)
* [nftMint](usage.md#nftmint)
* [getTokenInfo](usage.md#gettokeninfo)
* [cleanup](usage.md#cleanup)

# Methods

## initialize

Init instance of BladeSDK for correct work with Blade API and other endpoints.

`initialize(apiKey: String, chain: KnownChains, dAppCode: String, bladeEnv: BladeEnv = BladeEnv.Prod, force: Bool = false, completion: @escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `apiKey` | `String` | Unique key for API provided by Blade team. |
| `chain` | `KnownChains` | one of supported chains from KnownChains |
| `dAppCode` | `String` | your dAppCode - request specific one by contacting BladeLabs team |
| `bladeEnv` | `BladeEnv = BladeEnv.Prod` | environment to choose BladeAPI server (`.CI` or `.PROD`) field to set BladeAPI environment. Prod used by default. |
| `force` | `Bool = false` | optional field to force init. Will not crash if already initialized |
| `completion` | `@escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void` | completion closure that will be executed after webView is fully loaded and rendered, and result with `InfoData` type |

#### Returns

`InfoData` - with information about Blade instance, including visitorId

#### Example

```swift
SwiftBlade.shared.initialize(apiKey: apiKey, chain: .HEDERA_TESTNET, dAppCode: "dAppCode", bladeEnv: .Prod) { (result, error) in
    print(result ?? error)
}
```

## getInfo

Returns information about initialized instance of BladeSDK.

`getInfo(completion: @escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `completion` | `@escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void` | result with `InfoData` type |

#### Returns

`InfoData` - with information about Blade instance, including visitorId

#### Example

```swift
SwiftBlade.shared.getInfo() { (result, error) in
    print(result ?? error)
}
```

## setUser

Set active user for further operations.

`setUser(accountProvider: AccountProvider, accountIdOrEmail: String, privateKey: String, completion: @escaping (_ result: UserInfoData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountProvider` | `AccountProvider` | one of supported providers: PrivateKey or Magic |
| `accountIdOrEmail` | `String` | account id (0.0.xxxxx, 0xABCDEF..., EMAIL) or empty string for some chains |
| `privateKey` | `String` | private key for account (hex encoded privateKey with DER-prefix or 0xABCDEF...) In case of Magic provider - empty string |
| `completion` | `@escaping (_ result: UserInfoData?, _ error: BladeJSError?) -> Void` | result with `UserInfoData` type |

#### Returns

`UserInfoData` - with information about account

#### Example

```swift
// Set account for PrivateKey provider
SwiftBlade.shared.setUser(AccountProvider.PrivateKey, "0.0.45467464", "302e020100300506032b6570042204204323472EA5374E80B07346243234DEADBEEF25235235...") { (result, error) in
  print(result ?? error)
}
```

## resetUser

Clear active user from SDK instance.

`resetUser(completion: @escaping (_ result: UserInfoData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `completion` | `@escaping (_ result: UserInfoData?, _ error: BladeJSError?) -> Void` | result with `UserInfoData` type |

#### Returns

`UserInfoData` - with information about account

#### Example

```swift
SwiftBlade.shared.resetUser { result, error in
  print(result ?? error)
}
```

## getBalance

Get balance and token balances for specific account.

`getBalance(_ accountAddress: String, completion: @escaping (_ result: BalanceData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountAddress` | `String` | Hedera account id (0.0.xxxxx) or Ethereum address (0x...) or empty string to use current user account |
| `completion` | `@escaping (_ result: BalanceData?, _ error: BladeJSError?) -> Void` | result with BalanceData type |

#### Returns

`BalanceData` - with information about Hedera account balances (hbar and list of token balances)

#### Example

```swift
SwiftBlade.shared.getBalance("0.0.10001") { (result, error) in
    print(result ?? error)
}
```

## transferBalance

Send account balance (HBAR/ETH) to specific account.

`transferBalance(receiverAddress: String, amount: String, memo: String, completion: @escaping (_ result: TransactionResponseData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `receiverAddress` | `String` | receiver address (0.0.xxxxx, 0x123456789abcdef...) |
| `amount` | `String` | amount of currency to send, as a string representing a decimal number (e.g., "211.3424324") |
| `memo` | `String` | transaction memo (limited to 100 characters) |
| `completion` | `@escaping (_ result: TransactionResponseData?, _ error: BladeJSError?) -> Void` | result with `TransactionResponseData` type |

#### Returns

`TransactionResponseData` response

#### Example

```swift
let receiverAddress = "0.0.10002"
let amount = "7.2"
let memo = "transferBalance tests Swift"

SwiftBlade.shared.transferBalance(
    receiverAddress: receiverAddress,
    amount: amount,
    memo: memo
) { result, error in
    print(result ?? error)
}
```

## transferTokens

Send token to specific address

`transferTokens(tokenAddress: String, receiverAddress: String, amountOrSerial: String, memo: String, usePaymaster: Bool = true, completion: @escaping (_ result: TransactionResponseData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `tokenAddress` | `String` | token address to send (0.0.xxxxx or 0x123456789abcdef...) |
| `receiverAddress` | `String` | receiver account address (0.0.xxxxx or 0x123456789abcdef...) |
| `amountOrSerial` | `String` | amount of fungible tokens to send (with token-decimals correction) or NFT serial number. (e.g. amount "0.01337" when token decimals 8 will send 1337000 units of token) |
| `memo` | `String` | transaction memo (limited to 100 characters) |
| `usePaymaster` | `Bool = true` | if true, Paymaster account will pay fee transaction, for dApp configured fungible-token |
| `completion` | `@escaping (_ result: TransactionResponseData?, _ error: BladeJSError?) -> Void` | result with `TransactionResponseData` type |

#### Returns

`TransactionResponseData` response

#### Example

```swift
let tokenAddress = "0.0.1337"
let receiverAddress = "0.0.10002"
let amount = "5"

SwiftBlade.shared.transferTokens(
    tokenAddress: tokenAddress,
    receiverAddress: receiverAddress,
    amountOrSerial: amount,
    memo: "transferTokens tests Swift (paid)",
    usePaymaster: false
) { result, error in
    print(result ?? error)
}
```

## getCoinList

Get list of all available coins on CoinGecko.

`getCoinList(completion: @escaping (_ result: CoinListData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `completion` | `@escaping (_ result: CoinListData?, _ error: BladeJSError?) -> Void` | result with CoinListData type |

#### Returns

`CoinListData` - with list of coins described by name, alias, platforms

#### Example

```swift
SwiftBlade.shared.getCoinList { result, error in
    print(result ?? error)
}
```

## getCoinPrice

Get coin price and coin info from CoinGecko. Search can be coin id or address in one of the coin platforms.

In addition to the price in USD, the price in the currency you specified is returned

`getCoinPrice(_ search: String, _ currency: String = "usd", completion: @escaping (_ result: CoinInfoData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `search` | `String` | coinId (e.g. "hbar", "hedera-hashgraph"). You can get valid one using .getCoinList() method |
| `currency` | `String = "usd"` | currency to get price in (e.g. "uah", "pln", "usd") |
| `completion` | `@escaping (_ result: CoinInfoData?, _ error: BladeJSError?) -> Void` | result with CoinInfoData type |

#### Returns

`CoinInfoData`

#### Example

```swift
SwiftBlade.shared.getCoinPrice("Hbar", "uah") { result, error in
    print(result ?? error)
}
```

## createContractFunctionParameters

Method to create smart-contract function parameters (instance of ContractFunctionParameters)

`createContractFunctionParameters()`


#### Returns

`ContractFunctionParameters`

#### Example

```swift
let tuple = SwiftBlade.shared.createContractFunctionParameters()
    .addInt64(value: 16)
    .addInt64(value: 32)
```

## contractCallFunction

Call contract function. Directly or via BladeAPI using paymaster account (fee will be paid by Paymaster account), depending on your dApp configuration.

`contractCallFunction(contractAddress: String, functionName: String, params: ContractFunctionParameters, gas: Int = 100_000, usePaymaster: Bool, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `contractAddress` | `String` | contract address (0.0.xxxxx or 0x123456789abcdef...) |
| `functionName` | `String` | name of the contract function to call |
| `params` | `ContractFunctionParameters` | function argument. Can be generated with `createContractFunctionParameters()` method |
| `gas` | `Int = 100_000` | gas limit for transaction (default 100000) |
| `usePaymaster` | `Bool` | if true, fee will be paid by Paymaster account (note: msg.sender inside the contract will be Paymaster account) |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with TransactionReceiptData type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
let contractAddress = "0.0.123456"
let functionName = "set_message"
let parameters = SwiftBlade.shared.createContractFunctionParameters().addString(value: "Hello Swift test")
let gas = 155_000
let usePaymaster = false

SwiftBlade.shared.contractCallFunction(
    contractAddress: contractAddress, functionName: functionName, params: parameters, gas: gas, usePaymaster: usePaymaster
) { result, error in
    print(result ?? error)
}
```

## contractCallQueryFunction

Call query on contract function. Similar to  `contractCallFunction()` can be called directly or via BladeAPI using Paymaster account.

`contractCallQueryFunction(contractAddress: String, functionName: String, params: ContractFunctionParameters, gas: Int = 100_000, usePaymaster: Bool, returnTypes: [String], completion: @escaping (_ result: ContractCallQueryRecordsData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `contractAddress` | `String` |  |
| `functionName` | `String` |  |
| `params` | `ContractFunctionParameters` |  |
| `gas` | `Int = 100_000` |  |
| `usePaymaster` | `Bool` |  |
| `returnTypes` | `[String]` |  |
| `completion` | `@escaping (_ result: ContractCallQueryRecordsData?, _ error: BladeJSError?) -> Void` |  |

#### Returns

`ContractCallQueryRecordsData` contract query call result

#### Example

```swift
let contractAddress = "0.0.123456"
let functionName = "get_message"
let parameters = SwiftBlade.shared.createContractFunctionParameters()
let gas = 155_000
let usePaymaster = false
let returnTypes = ["string", "int32"]

SwiftBlade.shared.contractCallQueryFunction(
    contractAddress: contractAddress, functionName: functionName, params: SwiftBlade.shared.createContractFunctionParameters(), gas: gas, usePaymaster: usePaymaster, returnTypes: returnTypes
) { result, error in
    print(result ?? error)
}
```

## createScheduleTransaction

Create scheduled transaction

`createScheduleTransaction(
        type: ScheduleTransactionType,
        transfers: [ScheduleTransactionTransfer],
        usePaymaster: Bool = false,
        completion: @escaping (_ result: CreateScheduleData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `type` | `ScheduleTransactionType` | schedule transaction type (currently only TRANSFER supported) |
| `transfers` | `[ScheduleTransactionTransfer]` | array of transfers to schedule (HBAR, FT, NFT) |
| `usePaymaster` | `Bool = false` | if true, Paymaster account will pay transaction fee (also dApp had to be configured for free schedules) |
| `completion` | `@escaping (_ result: CreateScheduleData?, _ error: BladeJSError?) -> Void` | result with `CreateScheduleData` type |

#### Returns

`CreateScheduleData` scheduleId

#### Example

```swift
let receiverAddress = "0.0.10002"
let senderAddress = "0.0.10001"
let tokenId = "0.0.1337"

SwiftBlade.shared.createScheduleTransaction(
    type: .TRANSFER,
    transfers: [
        ScheduleTransactionTransferHbar(sender: senderAddress, receiver: receiverAddress, value: 10000000),
        ScheduleTransactionTransferToken(sender: senderAddress, receiver: receiverAddress, tokenId: tokenId, value: 3)
    ],
    false
) { result, error in
    print(result ?? error)
}
```

## signScheduleId

Method to sign scheduled transaction

`signScheduleId(
        scheduleId: String,
        receiverAccountAddress: String = "",
        usePaymaster: Bool = false,
        completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `scheduleId` | `String` | scheduled transaction id (0.0.xxxxx) |
| `receiverAccountAddress` | `String = ""` | account id of receiver for additional validation in case of dApp freeSchedule transactions configured |
| `usePaymaster` | `Bool = false` | if true, Paymaster account will pay transaction fee (also dApp had to be configured for free schedules) |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with `TransactionReceiptData` type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
let receiverAccountAddress = "0.0.10002"
let scheduleId = "0.0...." // result of createScheduleTransaction on receiver side

SwiftBlade.shared.signScheduleId(
    scheduleId: scheduleId,
    receiverAccountAddress: receiverAccountAddress,
    usePaymaster: false
) { result, error in
    print(result ?? error)
}
```

## createAccount

Create new account (ECDSA by default). Depending on dApp config Blade will create an account, associate tokens, etc.

`createAccount(_ privateKey: String = "", deviceId: String = "", completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `privateKey` | `String = ""` | optional field if you need specify account key (hex encoded privateKey with DER-prefix) |
| `deviceId` | `String = ""` | unique device id (advanced security feature, required only for some dApps) |
| `completion` | `@escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void` | result with CreatedAccountData type |

#### Returns

`CreatedAccountData` new account data, including private key and account id

#### Example

```swift
SwiftBlade.shared.createAccount() { result, error in
    print(result ?? error)
}
```

## deleteAccount

Delete hedera account

`deleteAccount(deleteAccountAddress: String, deletePrivateKey: String, transferAccountAddress: String, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `deleteAccountAddress` | `String` | account address to delete |
| `deletePrivateKey` | `String` | account to delete - private key |
| `transferAccountAddress` | `String` | if any funds left on account, they will be transferred to this account address |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with TransactionReceiptData type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
let deleteAccountAddress = "0.0.65468464"
let deletePrivateKey = "3030020100300706052b8104000a04220420ebc..."
let transferAccountAddress = "0.0.10001"

SwiftBlade.shared.deleteAccount(
    deleteAccountAddress: deleteAccountAddress,
    deletePrivateKey: deletePrivateKey,
    transferAccountAddress: transferAccountAddress,
) { result, error in
    print(result ?? error)
}
```

## getAccountInfo

Get account info.

EvmAddress is address of Hedera account if exists. Else accountId will be converted to solidity address.

CalculatedEvmAddress is calculated from account public key. May be different from evmAddress.

`getAccountInfo(accountAddress: String, completion: @escaping (_ result: AccountInfoData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountAddress` | `String` | Hedera account id (0.0.xxxxx) |
| `completion` | `@escaping (_ result: AccountInfoData?, _ error: BladeJSError?) -> Void` | result with AccountInfoData type |

#### Returns

`AccountInfoData`

#### Example

```swift
SwiftBlade.shared.getAccountInfo(accountAddress: "0.0.10001") { result, error in
    print(result ?? error)
}
```

## getNodeList

Get Hedera node list available for stake

`getNodeList(completion: @escaping (_ result: NodeListData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `completion` | `@escaping (_ result: NodeListData?, _ error: BladeJSError?) -> Void` | result with NodesData type |

#### Returns

`NodesData` node list

#### Example

```swift
SwiftBlade.shared.getNodeList { result, error in
    print(result ?? error)
}
```

## stakeToNode

Stake/unstake hedera account

`stakeToNode(nodeId: Int, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `nodeId` | `Int` | node id to stake to. If negative or null, account will be unstaked |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with TransactionReceiptData type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
SwiftBlade.shared.stakeToNode(nodeId: 5) { result, error in
    print(result ?? error)
}
```

## searchAccounts

Get accounts list and keys from private key or mnemonic

Supporting standard and legacy key derivation.

Every key with account will be returned. Returned keys with DER header.

`searchAccounts(_ keyOrMnemonic: String, completion: @escaping (_ result: AccountPrivateData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `keyOrMnemonic` | `String` | BIP39 mnemonic, private key with DER header |
| `completion` | `@escaping (_ result: AccountPrivateData?, _ error: BladeJSError?) -> Void` | result with AccountPrivateData type |

#### Returns

`AccountPrivateData` list of found accounts with private keys

#### Example

```swift
let mnemonic = "purity slab doctor swamp tackle rebuild summer bean craft toddler blouse switch"
SwiftBlade.shared.searchAccounts(mnemonic) { result, error in
    print(result ?? error)
}
```

## dropTokens

Bladelink drop to account

`dropTokens(secretNonce: String, completion: @escaping (_ result: TokenDropData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `secretNonce` | `String` | configured for dApp. Should be kept in secret |
| `completion` | `@escaping (_ result: TokenDropData?, _ error: BladeJSError?) -> Void` | result with TokenDropData type |

#### Returns

`TokenDropData` status

#### Example

```swift
let secretNonce = "[ CENSORED ]"

SwiftBlade.shared.dropTokens(
    secretNonce: secretNonce
) { result, error in
    print(result ?? error)
}
```

## sign

Sign encoded message with private key. Returns hex-encoded signature.

`sign(encodedMessage: String, encoding: SupportedEncoding, likeEthers: Bool, completion: @escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `encodedMessage` | `String` | encoded message to sign |
| `encoding` | `SupportedEncoding` | one of the supported encodings (hex/base64/utf8) |
| `likeEthers` | `Bool` | to get signature in ethers format. Works only for ECDSA keys. Ignored on chains other than Hedera |
| `completion` | `@escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void` | result with SignMessageData type |

#### Returns

`SignMessageData` signature

#### Example

```swift
let encodedMessage = "hello"
SwiftBlade.shared.sign(encodedMessage: encodedMessage, encoding: .uft8, likeEthers: false) { result, error in
    print(result ?? error)
}
```

## verify

Verify message signature with public key

`verify(encodedMessage: String, encoding: SupportedEncoding, signature: String, addressOrPublicKey: String, completion: @escaping (_ result: SignVerifyMessageData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `encodedMessage` | `String` | encoded message (same as provided to `sign()` method) |
| `encoding` | `SupportedEncoding` | one of the supported encodings (hex/base64/utf8) |
| `signature` | `String` | hex-encoded signature (result from `sign()` method) |
| `addressOrPublicKey` | `String` | EVM-address, publicKey, or Hedera address (0x11f8D856FF2aF6700CCda4999845B2ed4502d8fB, 0x0385a2fa81f8acbc47fcfbae4aeee6608c2d50ac2756ed88262d102f2a0a07f5b8, 0.0.1512, or empty for current account) |
| `completion` | `@escaping (_ result: SignVerifyMessageData?, _ error: BladeJSError?) -> Void` | result with SignVerifyMessageData type |

#### Returns

`SignVerifyMessageData` verification result

#### Example

```swift
let originalString = "hello"
let signedMessage = "27cb9d51434cf1e76d7ac515b19442c619f641e6fccddbf4a3756b14466becb6992dc1d2a82268018147141fc8d66ff9ade43b7f78c176d070a66372d655f942"
let addressOrPublicKey = "302d300706052b8104000a032200029dc73991b0d9cdbb59b2cd0a97a0eaff6de801726cb39804ea9461df6be2dd30"
SwiftBlade.shared.signVerify(encodedMessage: originalString, encoding: .utf8, signature: signedMessage, addressOrPublicKey: addressOrPublicKey) { result, error in
    print(result ?? error)
}
```

## splitSignature

Split signature to v-r-s format.

`splitSignature(signature: String, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `signature` | `String` | hex-encoded signature |
| `completion` | `@escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void` | result with SplitSignatureData type |

#### Returns

`SplitSignatureData` v-r-s signature

#### Example

```swift
let signedMessage = "0x27cb9d51434cf1e76d7ac515b19442c619f641e6fccddbf4a3756b14466becb6992dc1d2a82268018147141fc8d66ff9ade43b7f78c176d070a66372d655f942"
SwiftBlade.shared.splitSignature(signature: signMessageData.signedMessage) { result, error in
    print(result ?? error)
}
```

## getParamsSignature

Get v-r-s signature of contract function params

`getParamsSignature(params: ContractFunctionParameters, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `params` | `ContractFunctionParameters` | data to sign. (instance of ContractFunctionParameters. Can be generated with `createContractFunctionParameters()` method) |
| `completion` | `@escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void` | result with SplitSignatureData type |

#### Returns

`SplitSignatureData` v-r-s signature

#### Example

```swift
let parameters = SwiftBlade.shared.createContractFunctionParameters()
    .addAddress(value: accountId)
    .addUInt64Array(value: [300_000, 300_000])
    .addUInt64Array(value: [6])
    .addUInt64Array(value: [2])

SwiftBlade.shared.getParamsSignature(params: parameters) { result, error in
    print(result ?? error)
}
```

## getTransactions

Get transactions history for account. Can be filtered by transaction type.

Transaction requested from mirror node. Every transaction requested for child transactions. Result are flattened.

If transaction type is not provided, all transactions will be returned.

If transaction type is CRYPTOTRANSFERTOKEN records will additionally contain plainData field with decoded data.

`getTransactions(accountAddress: String, transactionType: String, nextPage: String = "", transactionsLimit: Int = 10, completion: @escaping (_ result: TransactionsHistoryData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountAddress` | `String` | account id to get transactions for (0.0.xxxxx) |
| `transactionType` | `String` | one of enum MirrorNodeTransactionType or "CRYPTOTRANSFERTOKEN" |
| `nextPage` | `String = ""` | link to next page of transactions from previous request |
| `transactionsLimit` | `Int = 10` | number of transactions to return. Speed of request depends on this value if transactionType is set. |
| `completion` | `@escaping (_ result: TransactionsHistoryData?, _ error: BladeJSError?) -> Void` | result with TransactionsHistoryData type |

#### Returns

`TransactionsHistoryData` transactions list

#### Example

```swift
SwiftBlade.shared.getTransactions(accountAddress: "0.0.10001", transactionType: "", nextPage: "", transactionsLimit: 5) { result, error in
    print(result ?? error)
}
```

## exchangeGetQuotes

Get quotes from different services for buy, sell or swap

`exchangeGetQuotes(
        sourceCode: String,
        sourceAmount: Double,
        targetCode: String,
        strategy: ExchangeStrategy,
        completion: @escaping (_ result: SwapQuotesData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `sourceCode` | `String` | name (HBAR, KARATE, other token code) |
| `sourceAmount` | `Double` | amount to swap, buy or sell |
| `targetCode` | `String` | name (HBAR, KARATE, USDC, other token code) |
| `strategy` | `ExchangeStrategy` | one of enum CryptoFlowServiceStrategy (Buy, Sell, Swap) |
| `completion` | `@escaping (_ result: SwapQuotesData?, _ error: BladeJSError?) -> Void` | result with SwapQuotesData type |

#### Returns

SwapQuotesData quotes from different providers

#### Example

```swift
SwiftBlade.shared.exchangeGetQuotes(
    sourceCode: "EUR",
    sourceAmount: 50,
    targetCode: "HBAR",
    strategy: CryptoFlowServiceStrategy.BUY
) { result, error in
    print(result ?? error)
}
```

## getTradeUrl

Get configured url to buy or sell tokens or fiat

`getTradeUrl(
        strategy: ExchangeStrategy,
        accountAddress: String,
        sourceCode: String,
        sourceAmount: Double,
        targetCode: String,
        slippage: Double,
        serviceId: String,
        _ redirectUrl: String = "",
        completion: @escaping (_ result: IntegrationUrlData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `strategy` | `ExchangeStrategy` | Buy / Sell |
| `accountAddress` | `String` | account id |
| `sourceCode` | `String` | name (HBAR, KARATE, USDC, other token code) |
| `sourceAmount` | `Double` | amount to buy/sell |
| `targetCode` | `String` | name (HBAR, KARATE, USDC, other token code) |
| `slippage` | `Double` | slippage in percents. Transaction will revert if the price changes unfavorably by more than this percentage. |
| `serviceId` | `String` | service id to use for swap (saucerswap, onmeta, etc) |
| `redirectUrl` | `String = ""` | url to redirect after final step |
| `completion` | `@escaping (_ result: IntegrationUrlData?, _ error: BladeJSError?) -> Void` | result with IntegrationUrlData type |

#### Returns

`IntegrationUrlData` url to open

#### Example

```swift
SwiftBlade.shared.getTradeUrl(
    strategy: CryptoFlowServiceStrategy.BUY,
    accountAddress: "0.0.10001",
    sourceCode: "EUR",
    sourceAmount: 50,
    targetCode: "HBAR",
    slippage: 0.5,
    serviceId: "moonpay"
) { [self] result, error in
    print(result ?? error)
}
```

## swapTokens

Swap tokens

`swapTokens(
        sourceCode: String,
        sourceAmount: Double,
        targetCode: String,
        slippage: Double,
        serviceId: String,
        completion: @escaping (_ result: ResultData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `sourceCode` | `String` | name (HBAR, KARATE, other token code) |
| `sourceAmount` | `Double` | amount to swap |
| `targetCode` | `String` | name (HBAR, KARATE, other token code) |
| `slippage` | `Double` | slippage in percents. Transaction will revert if the price changes unfavorably by more than this percentage. |
| `serviceId` | `String` | service id to use for swap (saucerswap, etc) |
| `completion` | `@escaping (_ result: ResultData?, _ error: BladeJSError?) -> Void` | result with ResultData type |

#### Returns

`ResultData` swap result

#### Example

```swift
let sourceCode = "USDC"
let targetCode = "KARATE"

SwiftBlade.shared.swapTokens(
    sourceCode: sourceCode,
    sourceAmount: 1,
    targetCode: targetCode,
    slippage: 0.5,
    serviceId: "saucerswap"
) { result, error in
    print(result ?? error)
}
```

## createToken

Create token (NFT or Fungible Token)

`createToken(
         tokenName: String,
         tokenSymbol: String,
         isNft: Bool,
         keys: [KeyRecord],
         decimals: Int,
         initialSupply: Int,
         maxSupply: Int,
         completion: @escaping (_ result: CreateTokenData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `tokenName` | `String` |  |
| `tokenSymbol` | `String` |  |
| `isNft` | `Bool` |  |
| `keys` | `[KeyRecord]` |  |
| `decimals` | `Int` |  |
| `initialSupply` | `Int` |  |
| `maxSupply` | `Int` |  |
| `completion` | `@escaping (_ result: CreateTokenData?, _ error: BladeJSError?) -> Void` |  |

#### Returns

`CreateTokenData` token id

#### Example

```swift
let keys = [
    KeyRecord(privateKey: adminPrivateKey, type: KeyType.admin)
]

SwiftBlade.shared.createToken(
    tokenName: "Blade Demo Token",
    tokenSymbol: "GD",
    isNft: true,
    keys: keys,
    decimals: 0,
    initialSupply: 0,
    maxSupply: 250
) { result, error in
    print(result ?? error)
}
```

## associateToken

Associate token to hedera account. Association fee will be covered by PayMaster, if tokenId configured in dApp

`associateToken(
        tokenIdOrCampaign: String,
         completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void
     )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `tokenIdOrCampaign` | `String` |  |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` |  |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
SwiftBlade.shared.associateToken(
    tokenIdOrCampaign: "0.0.1337"
) { result, error in
    print(result ?? error)
}
```

## nftMint

Mint one NFT

`nftMint(
        tokenAddress: String,
        file: String,
        metadata: [String: String],
        storageConfig: NFTStorageConfig,
        completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `tokenAddress` | `String` | token address to mint NFT |
| `file` | `String` | image to mint (base64 DataUrl image, eg.: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAA...) |
| `metadata` | `[String: String]` | NFT metadata |
| `storageConfig` | `NFTStorageConfig` | IPFS provider config |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | callback function, with result of CreateTokenData or BladeJSError |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
SwiftBlade.shared.nftMint(
    tokenAddress: "0.0.13377",
    file: "data:image/png;base64,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",
    metadata: [
        "name": "NFTitle",
        "score": "10",
        "power": "4",
        "intelligence": "6",
        "speed": "10"
    ],
    storageConfig: NFTStorageConfig(
        provider: NFTStorageProvider.nftStorage,
        apiKey: "eyJhbGciOiJIUzI1NiIsI.................cYOwssdZgiYaug4aF8ZrvMBdkTASojWGU"
    )
) { result, error in
    print(result ?? error)
}
```

## getTokenInfo

Get FT or NFT token info

`getTokenInfo(
        tokenAddress: String,
        serial: String,
        completion: @escaping (_ result: TokenInfoData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `tokenAddress` | `String` |  |
| `serial` | `String` |  |
| `completion` | `@escaping (_ result: TokenInfoData?, _ error: BladeJSError?) -> Void` |  |

#### Returns

`TokenInfoData` receipt

#### Example

```swift
SwiftBlade.shared.getTokenInfo(
    tokenAddress: "0.0.1337",
    serial: "1"
) { result, error in
    print(result ?? error)
}
```

## cleanup

Method to clean-up webView

`cleanup()`




