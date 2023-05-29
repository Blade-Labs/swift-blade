import WebKit

// MARK: - JS wrapper response types
struct Response: Codable {
    var completionKey: String?
    var error: BladeJSError?
}

struct CreatedAccountResponse: Codable {
    var completionKey: String
    var data: CreatedAccountData
}

struct InfoResponse: Codable {
    var completionKey: String
    var data: InfoData
}

public struct InfoData: Codable {
    public var apiKey: String
    public var dAppCode: String
    public var network: String
    public var visitorId: String
    public var deviceUuid: String
    public var sdkEnvironment: String
    public var sdkVersion: String
    public var nonce: Int
}

struct BalanceResponse: Codable {
    var completionKey: String
    var data: BalanceData
}

struct PrivateKeyResponse: Codable {
    var completionKey: String
    var data: PrivateKeyData
}

struct TransferResponse: Codable {
    var completionKey: String
    var data: TransferData
}

struct AccountAPIResponse: Codable {
    var id: String
    var network: String
    var associationPresetTokenStatus: String
    var transactionBytes: String
}

struct SignMessageResponse: Codable {
    var completionKey: String
    var data: SignMessageData
}

struct SignVerifyMessageResponse: Codable {
    var completionKey: String
    var data: SignVerifyMessageData
}

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

struct AccountInfoResponse: Codable {
    var completionKey: String
    var data: AccountInfoData
}

public struct AccountInfoData: Codable {
    public var accountId: String
    public var evmAddress: String
    public var calculatedEvmAddress: String
}

public struct BalanceData: Codable {
    public var hbars: Double
    public var tokens: [BalanceDataToken]
}

public struct BalanceDataToken: Codable {
    public var balance: Double
    public var tokenId: String
}

public struct PrivateKeyData: Codable {
    public var privateKey: String
    public var publicKey: String
    public var accounts: [String]
    public var evmAddress: String
}

public struct TransferData: Codable {
    public var nodeId: String
    public var transactionHash: String
    public var transactionId: String
}

public struct SignMessageData: Codable {
    public var signedMessage: String
}

public struct SignVerifyMessageData: Codable {
    public var valid: Bool
}

struct TransactionReceiptResponse: Codable {
    var completionKey: String
    var data: TransactionReceiptData
}

struct ContractQueryResponse: Codable {
    var completionKey: String
    var data: ContractQueryData
}

public struct ContractQueryData: Codable {
    public var gasUsed: Int
    public var values: [ContractQueryRecord]
}

public struct ContractQueryRecord: Codable {
    public var type: String
    public var value: String
}

public struct TransactionReceiptData: Codable {
    public var status: String
    public var contractId: String?
    public var topicSequenceNumber: String?
    public var totalSupply: String?
    public var serials: [String]?
}

struct SplitSignatureResponse: Codable {
    var completionKey: String
    var data: SplitSignatureData
}

public struct SplitSignatureData: Codable {
    public var v: Int
    public var r: String
    public var s: String
}

struct TransactionsHistoryResponse: Codable {
    var completionKey: String
    var data: TransactionsHistoryData
}

public struct TransactionsHistoryData: Codable {
    public var nextPage: String?
    public var transactions: [TransactionHistoryDetail]
}

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

public struct TransactionHistoryPlainData: Codable {
    public var type: String
    public var token_id: String
    public var account: String
    public var amount: Decimal
}

public struct TransactionHistoryTransfer: Codable {
    public var account: String
    public var amount: Decimal
    public var is_approval: Bool
}

public struct TransactionHistoryNftTransfer: Codable {
    public var is_approval: Bool
    public var receiver_account_id: String
    public var sender_account_id: String
    public var serial_number: Int
    public var token_id: String
}

struct IntegrationUrlResponse: Codable {
    var completionKey: String
    var data: IntegrationUrlData
}

public struct IntegrationUrlData: Codable {
    public var url: String
}

public struct RemoteConfig: Codable {
    public var fpApiKey: String
}

// MARK: - SwiftBlade errors
public enum SwiftBladeError: Error {
    case unknownJsError(String)
    case apiError(String)
}

public struct BladeJSError: Error, Codable {
    public var name: String
    public var reason: String
}

extension BladeJSError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString("\(self.name): \(self.reason)", comment: self.reason);
    }
}

// MARK: - SwiftBlade enums
public enum HederaNetwork: String {
    case TESTNET
    case MAINNET
}

public enum BladeEnv: String {
    case Prod = "Prod"
    case CI = "CI"
}
