# Contents

* [initialize](usage.md#initialize)
* [getInfo](usage.md#getinfo)
* [getBalance](usage.md#getbalance)
* [getCoinList](usage.md#getcoinlist)
* [getCoinPrice](usage.md#getcoinprice)
* [transferHbars](usage.md#transferhbars)
* [transferTokens](usage.md#transfertokens)
* [createScheduleTransaction](usage.md#createscheduletransaction)
* [signScheduleId](usage.md#signscheduleid)
* [createHederaAccount](usage.md#createhederaaccount)
* [getPendingAccount](usage.md#getpendingaccount)
* [deleteHederaAccount](usage.md#deletehederaaccount)
* [getAccountInfo](usage.md#getaccountinfo)
* [getNodeList](usage.md#getnodelist)
* [stakeToNode](usage.md#staketonode)
* [getKeysFromMnemonic](usage.md#getkeysfrommnemonic)
* [searchAccounts](usage.md#searchaccounts)
* [dropTokens](usage.md#droptokens)
* [sign](usage.md#sign)
* [signVerify](usage.md#signverify)
* [createContractFunctionParameters](usage.md#createcontractfunctionparameters)
* [contractCallFunction](usage.md#contractcallfunction)
* [contractCallQueryFunction](usage.md#contractcallqueryfunction)
* [ethersSign](usage.md#etherssign)
* [splitSignature](usage.md#splitsignature)
* [getParamsSignature](usage.md#getparamssignature)
* [getTransactions](usage.md#gettransactions)
* [getC14url](usage.md#getc14url)
* [exchangeGetQuotes](usage.md#exchangegetquotes)
* [getTradeUrl](usage.md#gettradeurl)
* [swapTokens](usage.md#swaptokens)
* [createToken](usage.md#createtoken)
* [associateToken](usage.md#associatetoken)
* [nftMint](usage.md#nftmint)
* [cleanup](usage.md#cleanup)

# Methods

## initialize

Init instance of SwiftBlade for correct work with Blade API and Hedera network.

`initialize(apiKey: String, dAppCode: String, network: HederaNetwork, bladeEnv: BladeEnv = BladeEnv.Prod, force: Bool = false, completion: @escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `apiKey` | `String` | Unique key for API provided by Blade team. |
| `dAppCode` | `String` | your dAppCode - request specific one by contacting Bladelabs team |
| `network` | `HederaNetwork` | `.TESTNET` or `.MAINNET` of Hedera network |
| `bladeEnv` | `BladeEnv = BladeEnv.Prod` | `.CI` or `.PROD` field to set BladeAPI environment. Prod used by default. |
| `force` | `Bool = false` | optional field to force init. Will not crash if already initialized |
| `completion` | `@escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void` | completion closure that will be executed after webView is fully loaded and rendered, and result with `InfoData` type |

#### Returns

`InfoData` - with information about Blade instance, including visitorId

#### Example

```swift
SwiftBlade.shared.initialize(apiKey: apiKey, dAppCode: apiKey, network: .TESTNET, bladeEnv: .Prod) { (result, error) in
    print(result ?? error)
}
```

## getInfo

Get SDK info and check if SDK initialized

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

## getBalance

Get balances by Hedera account id (address)

`getBalance(_ id: String, completion: @escaping (_ result: BalanceData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `id` | `String` | Hedera id (address), example: 0.0.112233 |
| `completion` | `@escaping (_ result: BalanceData?, _ error: BladeJSError?) -> Void` | result with BalanceData type |

#### Returns

`BalanceData` - with information about Hedera account balances (hbar and list of token balances)

#### Example

```swift
SwiftBlade.shared.getBalance("0.0.10001") { (result, error) in
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
| `search` | `String` | CoinGecko coinId, or address in one of the coin platforms or `hbar` (default, alias for `hedera-hashgraph`) |
| `currency` | `String = "usd"` | result currency for price field |
| `completion` | `@escaping (_ result: CoinInfoData?, _ error: BladeJSError?) -> Void` | result with CoinInfoData type |

#### Returns

`CoinInfoData`

#### Example

```swift
SwiftBlade.shared.getCoinPrice("Hbar", "uah") { result, error in
    print(result ?? error)
}
```

## transferHbars

Method to execute Hbar transfers from current account to receiver

`transferHbars(accountId: String, accountPrivateKey: String, receiverId: String, amount: Decimal, memo: String, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountId` | `String` | sender account id |
| `accountPrivateKey` | `String` | sender's private key to sign transfer transaction |
| `receiverId` | `String` | receiver |
| `amount` | `Decimal` | amount |
| `memo` | `String` | memo (limited to 100 characters) |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with `TransactionReceiptData` type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
let accountId = "0.0.10001"
let privateKeyHex = "302d300706052b8104000a032200029dc73991b0d9cd..."
let receiverId = "0.0.10002"
let amount: Decimal = 7.0
let memo = "transferHbars tests Swift"

SwiftBlade.shared.transferHbars(
    accountId: accountId,
    accountPrivateKey: privateKeyHex,
    receiverId: receiverId,
    amount: amount,
    memo: memo
) { result, error in
    print(result ?? error)
}
```

## transferTokens

Method to execute token transfers from current account to receiver

`transferTokens(tokenId: String, accountId: String, accountPrivateKey: String, receiverId: String, amountOrSerial: Decimal, memo: String, usePaymaster: Bool = true, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `tokenId` | `String` | token id to send (0.0.xxxxx) |
| `accountId` | `String` | sender account id (0.0.xxxxx) |
| `accountPrivateKey` | `String` | sender's hex-encoded private key with DER-header (302e020100300506032b657004220420...). ECDSA or Ed25519 |
| `receiverId` | `String` | receiver account id (0.0.xxxxx) |
| `amountOrSerial` | `Decimal` | amount of fungible tokens to send (with token-decimals correction) on NFT serial number |
| `memo` | `String` | memo (limited to 100 characters) |
| `usePaymaster` | `Bool = true` | if true, Paymaster account will pay fee transaction. Only for single dApp configured fungible-token. In that case tokenId not used |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with `TransactionReceiptData` type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
let tokenId = "0.0.1337"
let senderId = "0.0.10001"
let senderKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
let receiverId = "0.0.10002"
let amount: Decimal = 5.0

SwiftBlade.shared.transferTokens(
    tokenId: tokenId,
    accountId: senderId,
    accountPrivateKey: senderKey,
    receiverId: receiverId,
    amountOrSerial: amount,
    memo: "transferTokens tests Swift (paid)",
    usePaymaster: false
) { result, error in
    print(result ?? error)
}
```

## createScheduleTransaction

Create scheduled transaction

`createScheduleTransaction(
        accountId: String,
        accountPrivateKey: String,
        type: ScheduleTransactionType,
        transfers: [ScheduleTransactionTransfer],
        _ usePaymaster: Bool = false,
        completion: @escaping (_ result: CreateScheduleData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountId` | `String` | account id (0.0.xxxxx) |
| `accountPrivateKey` | `String` | account key (hex encoded privateKey with DER-prefix) |
| `type` | `ScheduleTransactionType` | schedule transaction type (currently only TRANSFER supported) |
| `transfers` | `[ScheduleTransactionTransfer]` | array of transfers to schedule (HBAR, FT, NFT) |
| `usePaymaster` | `Bool = false` | if true, Paymaster account will pay transaction fee (also dApp had to be configured for free schedules) |
| `completion` | `@escaping (_ result: CreateScheduleData?, _ error: BladeJSError?) -> Void` | result with `CreateScheduleData` type |

#### Returns

`CreateScheduleData` scheduleId

#### Example

```swift
let receiverId = "0.0.10002"
let receiverKey = "302d300706052b8104000a032200029dc73991b00002..."
let senderId = "0.0.10001"
let tokenId = "0.0.1337"

SwiftBlade.shared.createScheduleTransaction(
    accountId: receiverId,
    accountPrivateKey: receiverKey,
    type: .TRANSFER,
    transfers: [
        ScheduleTransactionTransferHbar(sender: senderId, receiver: receiverId, value: 10000000),
        ScheduleTransactionTransferToken(sender: senderId, receiver: receiverId, tokenId: tokenId, value: 3)
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
        accountId: String,
        accountPrivateKey: String,
        receiverAccountId: String = "",
        usePaymaster: Bool = false,
        completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `scheduleId` | `String` | scheduled transaction id (0.0.xxxxx) |
| `accountId` | `String` | account id (0.0.xxxxx) |
| `accountPrivateKey` | `String` | hex encoded privateKey with DER-prefix |
| `receiverAccountId` | `String = ""` | account id of receiver for additional validation in case of dApp freeSchedule transactions configured |
| `usePaymaster` | `Bool = false` | if true, Paymaster account will pay transaction fee (also dApp had to be configured for free schedules) |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with `TransactionReceiptData` type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
let senderId = "0.0.10001"
let senderKey = "302d300706052b8104000a032200029dc73991b00001..."
let receiverId = "0.0.10002"
let scheduleId = "0.0...." // result of createScheduleTransaction on receiver side

SwiftBlade.shared.signScheduleId(
    scheduleId: scheduleId,
    accountId: senderId,
    accountPrivateKey: senderKey,
    receiverAccountId: receiverId,
    usePaymaster: false
) { result, error in
    print(result ?? error)
}
```

## createHederaAccount

Create new Hedera account (ECDSA). Only for configured dApps. Depending on dApp config Blade create account, associate tokens, etc.

In case of not using pre-created accounts pool and network high load, this method can return transactionId and no accountId.

In that case account creation added to queue, and you should wait some time and call `getPendingAccount()` method.

`createHederaAccount(_ privateKey: String = "", deviceId: String = "", completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void)`

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
SwiftBlade.shared.createHederaAccount() { result, error in
    print(result ?? error)
}
```

## getPendingAccount

Get account from queue (read more at `createAccount()`).

If account already created, return account data.

If account not created yet, response will be same as in `createHederaAccount()` method if account in queue.

`getPendingAccount(transactionId: String, seedPhrase: String, completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `transactionId` | `String` | can be received on createHederaAccount method, when busy network is busy, and account creation added to queue |
| `seedPhrase` | `String` | returned from createHederaAccount method, required for updating keys and proper response |
| `completion` | `@escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void` | result with `CreatedAccountData` type |

#### Returns

`CreatedAccountData` new account data


## deleteHederaAccount

Delete Hedera account. This method requires account private key and operator private key. Operator is the one who paying fees

`deleteHederaAccount(deleteAccountId: String, deletePrivateKey: String, transferAccountId: String, operatorAccountId: String, operatorPrivateKey: String, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `deleteAccountId` | `String` | account to delete - id |
| `deletePrivateKey` | `String` | account to delete - private key |
| `transferAccountId` | `String` | The ID of the account to transfer the remaining funds to. |
| `operatorAccountId` | `String` | operator account Id |
| `operatorPrivateKey` | `String` | operator account private key |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with TransactionReceiptData type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
let deleteAccountId = "0.0.65468464"
let deletePrivateKey = "3030020100300706052b8104000a04220420ebc..."
let transferAccountId = "0.0.10001"
let operatorAccountId = "0.0.10002"
let operatorPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."

SwiftBlade.shared.deleteHederaAccount(
    deleteAccountId: deleteAccountId,
    deletePrivateKey: deletePrivateKey,
    transferAccountId: transferAccountId,
    operatorAccountId: operatorAccountId,
    operatorPrivateKey: operatorPrivateKey
) { result, error in
    print(result ?? error)
}
```

## getAccountInfo

Get account info.

EvmAddress is address of Hedera account if exists. Else accountId will be converted to solidity address.

CalculatedEvmAddress is calculated from account public key. May be different from evmAddress.

`getAccountInfo(accountId: String, completion: @escaping (_ result: AccountInfoData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountId` | `String` | Hedera account id (0.0.xxxxx) |
| `completion` | `@escaping (_ result: AccountInfoData?, _ error: BladeJSError?) -> Void` | result with AccountInfoData type |

#### Returns

`AccountInfoData`

#### Example

```swift
SwiftBlade.shared.getAccountInfo(accountId: "0.0.10001") { result, error in
    print(result ?? error)
}
```

## getNodeList

Get Node list and use it for choosing account stacking node

`getNodeList(completion: @escaping (_ result: NodesData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `completion` | `@escaping (_ result: NodesData?, _ error: BladeJSError?) -> Void` | result with NodesData type |

#### Returns

`NodesData` node list

#### Example

```swift
SwiftBlade.shared.getNodeList() { result, error in
    print(result ?? error)
}
```

## stakeToNode

Stake/unstake account

`stakeToNode(accountId: String, accountPrivateKey: String, nodeId: Int, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountId` | `String` | Hedera account id (0.0.xxxxx) |
| `accountPrivateKey` | `String` | account private key (DER encoded hex string) |
| `nodeId` | `Int` | node id to stake to. If negative or null, account will be unstaked |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with TransactionReceiptData type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
SwiftBlade.shared.stakeToNode(accountId: "0.0.10002", accountPrivateKey: "302d300706052b8104000a032200029dc73991b0d9cd...", nodeId: 5) { result, error in
    print(result ?? error)
}
```

## getKeysFromMnemonic

Get private key and accountId from mnemonic. Supported standard and legacy key derivation.

If account not found, standard ECDSA key will be returned.

Keys returned with DER header. EvmAddress computed from Public key.

`getKeysFromMnemonic(mnemonic: String, lookupNames: Bool = false, completion: @escaping (_ result: PrivateKeyData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `mnemonic` | `String` | seed phrase (BIP39 mnemonic) |
| `lookupNames` | `Bool = false` | lookup for accounts (not used anymore, account search is mandatory) |
| `completion` | `@escaping (_ result: PrivateKeyData?, _ error: BladeJSError?) -> Void` | result with PrivateKeyData type |

#### Returns

`PrivateKeyData` private key derived from mnemonic and account id

#### Example

```swift
let mnemonic = "purity slab doctor swamp tackle rebuild summer bean craft toddler blouse switch"
SwiftBlade.shared.getKeysFromMnemonic(mnemonic: mnemonic, lookupNames: true) { result, error in
    print(result ?? error)
}
```

## searchAccounts

Get accounts list and keys from private key or mnemonic

Supporting standard and legacy key derivation.

Every key with account will be returned.

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

`dropTokens(accountId: String, accountPrivateKey: String, secretNonce: String, completion: @escaping (_ result: TokenDropData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountId` | `String` | Hedera account id (0.0.xxxxx) |
| `accountPrivateKey` | `String` | account private key (DER encoded hex string) |
| `secretNonce` | `String` | configured for dApp. Should be kept in secret |
| `completion` | `@escaping (_ result: TokenDropData?, _ error: BladeJSError?) -> Void` | result with TokenDropData type |

#### Returns

`TokenDropData` status

#### Example

```swift
let accountId = "0.0.10002"
let accountPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
let secretNonce = "[ CENSORED ]"

SwiftBlade.shared.dropTokens(
    accountId: accountId,
    accountPrivateKey: accountPrivateKey,
    secretNonce: secretNonce
) { result, error in
    print(result ?? error)
}
```

## sign

Sign base64-encoded message with private key. Returns hex-encoded signature.

`sign(messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `messageString` | `String` | base64-encoded message to sign |
| `privateKey` | `String` | hex-encoded private key with DER header |
| `completion` | `@escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void` | result with SignMessageData type |

#### Returns

`SignMessageData` signature

#### Example

```swift
let originalMessage = "hello"
let privateKeyHex = "302d300706052b8104000a032200029dc73991b0d9cd..."
if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
    SwiftBlade.shared.sign(messageString: base64encodedString, privateKey: privateKeyHex) { result, error in
        print(result ?? error)
    }
}
```

## signVerify

Verify message signature with public key

`signVerify(messageString: String, signature: String, publicKey: String, completion: @escaping (_ result: SignVerifyMessageData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `messageString` | `String` | base64-encoded message (same as provided to `sign()` method) |
| `signature` | `String` | hex-encoded signature (result from `sign()` method) |
| `publicKey` | `String` | hex-encoded public key with DER header |
| `completion` | `@escaping (_ result: SignVerifyMessageData?, _ error: BladeJSError?) -> Void` | result with SignVerifyMessageData type |

#### Returns

`SignVerifyMessageData` verification result

#### Example

```swift
let originalString = "hello"
let signedMessage = "27cb9d51434cf1e76d7ac515b19442c619f641e6fccddbf4a3756b14466becb6992dc1d2a82268018147141fc8d66ff9ade43b7f78c176d070a66372d655f942"
let publicKey = "302d300706052b8104000a032200029dc73991b0d9cdbb59b2cd0a97a0eaff6de801726cb39804ea9461df6be2dd30"
if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
    SwiftBlade.shared.signVerify(messageString: base64encodedString, signature: signedMessage, publicKey: publicKey) { result, error in
        print(result ?? error)
    }
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

`contractCallFunction(contractId: String, functionName: String, params: ContractFunctionParameters, accountId: String, accountPrivateKey: String, gas: Int = 100_000, usePaymaster: Bool, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `contractId` | `String` | contract id (0.0.xxxxx) |
| `functionName` | `String` | name of the contract function to call |
| `params` | `ContractFunctionParameters` | function argument. Can be generated with `createContractFunctionParameters()` method |
| `accountId` | `String` | operator account id (0.0.xxxxx) |
| `accountPrivateKey` | `String` | operator's hex-encoded private key with DER-header, ECDSA or Ed25519 |
| `gas` | `Int = 100_000` | gas limit for transaction (default 100000) |
| `usePaymaster` | `Bool` | if true, fee will be paid by Paymaster account (note: msg.sender inside the contract will be Paymaster account) |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | result with TransactionReceiptData type |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
let contractId = "0.0.123456"
let functionName = "set_message"
let parameters = SwiftBlade.shared.createContractFunctionParameters().addString(value: "Hello Swift test")
let accountId = "0.0.10002"
let accountPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
let gas = 155_000
let usePaymaster = false

SwiftBlade.shared.contractCallFunction(
    contractId: contractId, functionName: functionName, params: parameters, accountId: accountId, accountPrivateKey: accountPrivateKey, gas: gas, usePaymaster: usePaymaster
) { result, error in
    print(result ?? error)
}
```

## contractCallQueryFunction

Call query on contract function. Similar to  `contractCallFunction()` can be called directly or via BladeAPI using Paymaster account.

`contractCallQueryFunction(contractId: String, functionName: String, params: ContractFunctionParameters, accountId: String, accountPrivateKey: String, gas: Int = 100_000, usePaymaster: Bool, returnTypes: [String], completion: @escaping (_ result: ContractQueryData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `contractId` | `String` |  |
| `functionName` | `String` |  |
| `params` | `ContractFunctionParameters` |  |
| `accountId` | `String` |  |
| `accountPrivateKey` | `String` |  |
| `gas` | `Int = 100_000` |  |
| `usePaymaster` | `Bool` |  |
| `returnTypes` | `[String]` |  |
| `completion` | `@escaping (_ result: ContractQueryData?, _ error: BladeJSError?) -> Void` |  |

#### Returns

`ContractQueryData` contract query call result

#### Example

```swift
let contractId = "0.0.123456"
let functionName = "get_message"
let parameters = SwiftBlade.shared.createContractFunctionParameters()
let accountId = "0.0.10002"
let accountPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
let gas = 155_000
let usePaymaster = false
let returnTypes = ["string", "int32"]

SwiftBlade.shared.contractCallQueryFunction(
    contractId: contractId, functionName: functionName, params: SwiftBlade.shared.createContractFunctionParameters(), accountId: accountId, accountPrivateKey: accountPrivateKey, gas: gas, usePaymaster: usePaymaster, returnTypes: returnTypes
) { result, error in
    print(result ?? error)
}
```

## ethersSign

Sign base64-encoded message with private key using ethers lib. Returns hex-encoded signature.

`ethersSign(messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `messageString` | `String` | base64-encoded message to sign |
| `privateKey` | `String` | hex-encoded private key with DER header |
| `completion` | `@escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void` | result with SignMessageData type |

#### Returns

`SignMessageData` signature

#### Example

```swift
let originalMessage = "hello"
let privateKeyHex = "302d300706052b8104000a032200029dc73991b0d9cd..."
if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
    SwiftBlade.shared.ethersSign(messageString: base64encodedString, privateKey: privateKeyHex) { result, error in
        print(result ?? error)
    }
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

`getParamsSignature(params: ContractFunctionParameters, accountPrivateKey: String, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `params` | `ContractFunctionParameters` | data to sign. (instance of ContractFunctionParameters. Can be generated with `createContractFunctionParameters()` method) |
| `accountPrivateKey` | `String` | signer private key (hex-encoded with DER header) |
| `completion` | `@escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void` | result with SplitSignatureData type |

#### Returns

`SplitSignatureData` v-r-s signature

#### Example

```swift
let privateKeyHex = "302d300706052b8104000a032200029dc73991b0d9cd..."
let parameters = SwiftBlade.shared.createContractFunctionParameters()
    .addAddress(value: accountId)
    .addUInt64Array(value: [300_000, 300_000])
    .addUInt64Array(value: [6])
    .addUInt64Array(value: [2])

SwiftBlade.shared.getParamsSignature(params: parameters, accountPrivateKey: privateKeyHex) { result, error in
    print(result ?? error)
}
```

## getTransactions

Get transactions history for account. Can be filtered by transaction type.

Transaction requested from mirror node. Every transaction requested for child transactions. Result are flattened.

If transaction type is not provided, all transactions will be returned.

If transaction type is CRYPTOTRANSFERTOKEN records will additionally contain plainData field with decoded data.

`getTransactions(accountId: String, transactionType: String, nextPage: String = "", transactionsLimit: Int = 10, completion: @escaping (_ result: TransactionsHistoryData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `accountId` | `String` | account id to get transactions for (0.0.xxxxx) |
| `transactionType` | `String` | one of enum MirrorNodeTransactionType or "CRYPTOTRANSFERTOKEN" |
| `nextPage` | `String = ""` | link to next page of transactions from previous request |
| `transactionsLimit` | `Int = 10` | number of transactions to return. Speed of request depends on this value if transactionType is set. |
| `completion` | `@escaping (_ result: TransactionsHistoryData?, _ error: BladeJSError?) -> Void` | result with TransactionsHistoryData type |

#### Returns

`TransactionsHistoryData` transactions list

#### Example

```swift
SwiftBlade.shared.getTransactions(accountId: "0.0.10001", transactionType: "", nextPage: "", transactionsLimit: 5) { result, error in
    print(result ?? error)
}
```

## getC14url

Get configured url for C14 integration (iframe or popup)

Deprecated now. Please use `exchangeGetQuotes` and `getTradeUrl` methods. Results aggregated on many providers, including C14

`getC14url(asset: String, account: String, amount: String, completion: @escaping (_ result: IntegrationUrlData?, _ error: BladeJSError?) -> Void)`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `asset` | `String` | USDC, HBAR, KARATE or C14 asset uuid |
| `account` | `String` | receiver account id (0.0.xxxxx) |
| `amount` | `String` | preset amount. May be overwritten if out of range (min/max) |
| `completion` | `@escaping (_ result: IntegrationUrlData?, _ error: BladeJSError?) -> Void` | result with IntegrationUrlData type |

#### Returns

`IntegrationUrlData` url to open

#### Example

```swift
SwiftBlade.shared.getC14url(asset: "KARATE", account: "0.0.10001", amount: "1234") { result, error in
    print(result ?? error)
}
```

## exchangeGetQuotes

Get quotes from different services for buy, sell or swap

`exchangeGetQuotes(
        sourceCode: String,
        sourceAmount: Double,
        targetCode: String,
        strategy: CryptoFlowServiceStrategy,
        completion: @escaping (_ result: SwapQuotesData?, _ error: BladeJSError?) -> Void
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `sourceCode` | `String` | name (HBAR, KARATE, other token code) |
| `sourceAmount` | `Double` | amount to swap, buy or sell |
| `targetCode` | `String` | name (HBAR, KARATE, USDC, other token code) |
| `strategy` | `CryptoFlowServiceStrategy` | one of enum CryptoFlowServiceStrategy (Buy, Sell, Swap) |
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
        strategy: CryptoFlowServiceStrategy,
        accountId: String,
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
| `strategy` | `CryptoFlowServiceStrategy` | Buy / Sell |
| `accountId` | `String` | account id |
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
    accountId: "0.0.10001",
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
        accountId: String,
        accountPrivateKey: String,
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
| `accountId` | `String` | account id |
| `accountPrivateKey` | `String` | account private key |
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
let accountId = "0.0.10001"
let accountPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
let sourceCode = "USDC"
let targetCode = "KARATE"

SwiftBlade.shared.swapTokens(
    accountId: accountId,
    accountPrivateKey: accountPrivateKey,
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
    )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `treasuryAccountId` | `String` | treasury account id |
| `supplyPrivateKey` | `String` |  |
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
    treasuryAccountId: accountId,
    supplyPrivateKey: privateKey,
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

Associate token to account. Association fee will be covered by PayMaster, if tokenId configured in dApp

`associateToken(
         tokenId: String,
         accountId: String,
         accountPrivateKey: String,
         completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void
     )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `tokenId` | `String` |  |
| `accountId` | `String` |  |
| `accountPrivateKey` | `String` |  |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` |  |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
SwiftBlade.shared.associateToken(
    tokenId: "0.0.1337",
    accountId: "0.0.10001",
    accountPrivateKey: "302d300706052b8104000a032200029dc73991b0d9cd..."
) { result, error in
    print(result ?? error)
}
```

## nftMint

Mint one NFT

`nftMint(
         tokenId: String,
         supplyAccountId: String,
         supplyPrivateKey: String,
         file: String,
         metadata: [String: String],
         storageConfig: IPFSProviderConfig,
         completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void
     )`

#### Parameters

| Name | Type | Description |
|------|------| ----------- |
| `tokenId` | `String` | token id to mint NFT |
| `supplyAccountId` | `String` | token supply account id |
| `supplyPrivateKey` | `String` | token supply private key |
| `file` | `String` | image to mint (base64 DataUrl image, eg.: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAA...) |
| `metadata` | `[String: String]` | NFT metadata |
| `storageConfig` | `IPFSProviderConfig` | IPFS provider config |
| `completion` | `@escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void` | callback function, with result of CreateTokenData or BladeJSError |

#### Returns

`TransactionReceiptData` receipt

#### Example

```swift
SwiftBlade.shared.nftMint(
    tokenId: "0.0.13377",
    supplyAccountId: "0.0.10001",
    supplyPrivateKey: "302d300706052b8104000a032200029dc73991b0d9cd...",
    file: "data:image/png;base64,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",
    metadata: [
        "name": "NFTitle",
        "score": "10",
        "power": "4",
        "intelligence": "6",
        "speed": "10"
    ],
    storageConfig: IPFSProviderConfig(
        provider: IPFSProvider.pinata,
        token: "eyJhbGciOiJIUzI1NiIsI.................cYOwssdZgiYaug4aF8ZrvMBdkTASojWGU"
    )
) { result, error in
    print(result ?? error)
}
```

## cleanup

Method to clean-up webView

`cleanup()`




