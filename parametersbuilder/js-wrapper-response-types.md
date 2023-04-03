# JS wrapper response types

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
    public var account: String
    public var amount: Decimal
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
public struct TransactionHistoryNftTransfer: Codable {
    public var is_approval: Bool
    public var receiver_account_id: String
    public var sender_account_id: String
    public var serial_number: Int
    public var token_id: String
}
```
