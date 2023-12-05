# JS wrapper response types

```swift
struct Response: Codable {
    var completionKey: String?
    var error: BladeJSError?
}
```

```swift
struct CreatedAccountResponse: Codable {
    var completionKey: String
    var data: CreatedAccountData
}
```

```swift
struct InfoResponse: Codable {
    var completionKey: String
    var data: InfoData
}
```

```swift
public struct InfoData: Codable {
    public var apiKey: String
    public var dAppCode: String
    public var network: String
    public var visitorId: String
    public var sdkEnvironment: String
    public var sdkVersion: String
    public var nonce: Int
}
```

```swift
struct BalanceResponse: Codable {
    var completionKey: String
    var data: BalanceData
}
```

```swift
struct PrivateKeyResponse: Codable {
    var completionKey: String
    var data: PrivateKeyData
}
```

```swift
struct TransferResponse: Codable {
    var completionKey: String
    var data: TransferData
}
```

```swift
struct AccountAPIResponse: Codable {
    var id: String
    var network: String
    var associationPresetTokenStatus: String
    var transactionBytes: String
}
```

```swift
struct SignMessageResponse: Codable {
    var completionKey: String
    var data: SignMessageData
}
```

```swift
struct SignVerifyMessageResponse: Codable {
    var completionKey: String
    var data: SignVerifyMessageData
}
```

```swift
public struct CreatedAccountData: Codable {
    public var seedPhrase: String
    public var publicKey: String
    public var privateKey: String
    public var accountId: String?
    public var evmAddress: String
    public var transactionId: String?
    public var status: String
    public var queueNumber: Int?
}
```

```swift
struct AccountInfoResponse: Codable {
    var completionKey: String
    var data: AccountInfoData
}
```

```swift
public struct AccountInfoData: Codable {
    public var accountId: String
    public var evmAddress: String
    public var calculatedEvmAddress: String
}
```

```swift
public struct BalanceData: Codable {
    public var hbars: Double
    public var tokens: [BalanceDataToken]
}
```

```swift
public struct BalanceDataToken: Codable {
    public var balance: Double
    public var tokenId: String
}
```

```swift
public struct PrivateKeyData: Codable {
    public var privateKey: String
    public var publicKey: String
    public var accounts: [String]
    public var evmAddress: String
}
```

```swift
public struct TransferData: Codable {
    public var nodeId: String
    public var transactionHash: String
    public var transactionId: String
}
```

```swift
public struct SignMessageData: Codable {
    public var signedMessage: String
}
```

```swift
public struct SignVerifyMessageData: Codable {
    public var valid: Bool
}
```

```swift
struct TransactionReceiptResponse: Codable {
    var completionKey: String
    var data: TransactionReceiptData
}
```

```swift
struct ContractQueryResponse: Codable {
    var completionKey: String
    var data: ContractQueryData
}
```

```swift
public struct ContractQueryData: Codable {
    public var gasUsed: Int
    public var values: [ContractQueryRecord]
}
```

```swift
public struct ContractQueryRecord: Codable {
    public var type: String
    public var value: String
}
```

```swift
public struct TransactionReceiptData: Codable {
    public var status: String
    public var contractId: String?
    public var topicSequenceNumber: String?
    public var totalSupply: String?
    public var serials: [String]?
}
```

```swift
struct SplitSignatureResponse: Codable {
    var completionKey: String
    var data: SplitSignatureData
}
```

```swift
public struct SplitSignatureData: Codable {
    public var v: Int
    public var r: String
    public var s: String
}
```

```swift
struct TransactionsHistoryResponse: Codable {
    var completionKey: String
    var data: TransactionsHistoryData
}
```

```swift
public struct TransactionsHistoryData: Codable {
    public var nextPage: String?
    public var transactions: [TransactionHistoryDetail]
}
```

```swift
public struct TransactionHistoryDetail: Codable {
    public var fee: Int
    public var memo: String
    public var nftTransfers: [TransactionHistoryNftTransfer]?
    public var time: String
    public var transactionId: String
    public var transfers: [TransactionHistoryTransfer]
    public var type: String
    public var plainData: TransactionHistoryPlainData?
    public var consensusTimestamp: String
}
```

```swift
public struct TransactionHistoryPlainData: Codable {
    public var type: String
    public var token_id: String
    public var amount: Decimal
    public var senders: [String]
    public var receivers: [String]
}
```

```swift
public struct TransactionHistoryTransfer: Codable {
    public var account: String
    public var amount: Decimal
    public var is_approval: Bool
}
```

```swift
public struct TransactionHistoryNftTransfer: Codable {
    public var is_approval: Bool
    public var receiver_account_id: String
    public var sender_account_id: String
    public var serial_number: Int
    public var token_id: String
}
```

```swift
struct IntegrationUrlResponse: Codable {
    var completionKey: String
    var data: IntegrationUrlData
}
```

```swift
public struct IntegrationUrlData: Codable {
    public var url: String
}
```

```swift
public struct RemoteConfig: Codable {
    public var fpApiKey: String
}
```

```swift
struct CoinListResponse: Response, Codable {
    var data: CoinListData
}
```

```swift
public struct CoinListData: Codable {
    public var coins: [CoinItem]
}
```

```swift
public struct CoinItem: Codable {
    public var id: String
    public var symbol: String
    public var name: String
    public var platforms: [CoinGeckoPlatform]
}
```

```swift
public struct CoinGeckoPlatform: Codable {
    public var name: String
    public var address: String
}
```

```swift
struct CoinInfoResponse: Response, Codable {
    var data: CoinInfoData
}
```

```swift
public struct CoinInfoData: Codable {
    public var coin: CoinData
    public var priceUsd: Double
}
```

```swift
public struct CoinData: Codable {
    public var id: String
    public var symbol: String
    public var name: String
    public var web_slug: String
    public var description: CoinDataDescription
    public var image: CoinDataImage
    public var market_data: CoinDataMarket
    public var platforms: [CoinGeckoPlatform]
}
```

```swift
public struct CoinDataDescription: Codable {
    public var en: String
}
```

```swift
public struct CoinDataImage: Codable {
    public var thumb: String
    public var small: String
    public var large: String
}
```

```swift
public struct CoinDataMarket: Codable {
    public var current_price: [String: Double]
}
```

```swift
public enum SwiftBladeError: Error {
    case unknownJsError(String)
    case apiError(String)
}
```

```swift
public struct BladeJSError: Error, Codable {
    public var name: String
    public var reason: String
}
```
