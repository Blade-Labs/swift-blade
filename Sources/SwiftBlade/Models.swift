import WebKit

// MARK: - JS wrapper response types
struct ResultRaw: Codable {
    var completionKey: String?
    var error: BladeJSError?
}

protocol Response: Codable {
    associatedtype DataType
    var data: DataType { get }
}

struct InfoResponse: Response, Codable {
    var data: InfoData
}

public struct InfoData: Codable {
    public var apiKey: String
    public var dAppCode: String
    public var network: String
    public var visitorId: String
    public var sdkEnvironment: String
    public var sdkVersion: String
    public var nonce: Int
}

struct BalanceResponse: Response, Codable {
    var data: BalanceData
}

public struct BalanceData: Codable {
    public var hbars: Double
    public var tokens: [BalanceDataToken]
}

public struct BalanceDataToken: Codable {
    public var balance: Double
    public var tokenId: String
}

struct PrivateKeyResponse: Response, Codable {
    var data: PrivateKeyData
}

public struct PrivateKeyData: Codable {
    public var privateKey: String
    public var publicKey: String
    public var accounts: [String]
    public var evmAddress: String
}


struct TransferResponse: Response, Codable {
    var data: TransferData
}

public struct TransferData: Codable {
    public var nodeId: String
    public var transactionHash: String
    public var transactionId: String
}

struct AccountAPIResponse: Codable {
    var id: String
    var network: String
    var associationPresetTokenStatus: String
    var transactionBytes: String
}

struct SignMessageResponse: Response, Codable {
    var data: SignMessageData
}

public struct SignMessageData: Codable {
    public var signedMessage: String
}

struct SignVerifyMessageResponse: Response, Codable {
    var data: SignVerifyMessageData
}

public struct SignVerifyMessageData: Codable {
    public var valid: Bool
}

struct CreatedAccountResponse: Response, Codable {
    var data: CreatedAccountData
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

struct AccountInfoResponse: Response, Codable {
    var data: AccountInfoData
}

public struct AccountInfoData: Codable {
    public var accountId: String
    public var evmAddress: String
    public var calculatedEvmAddress: String
}

struct TransactionReceiptResponse: Response, Codable {
    var data: TransactionReceiptData
}

public struct TransactionReceiptData: Codable {
    public var status: String
    public var contractId: String?
    public var topicSequenceNumber: String?
    public var totalSupply: String?
    public var serials: [String]?
}


struct ContractQueryResponse: Response, Codable {
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


struct SplitSignatureResponse: Response, Codable {
    var data: SplitSignatureData
}

public struct SplitSignatureData: Codable {
    public var v: Int
    public var r: String
    public var s: String
}

struct TransactionsHistoryResponse: Response, Codable {
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
    public var amount: Decimal
    public var senders: [String]
    public var receivers: [String]
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

struct IntegrationUrlResponse: Response, Codable {
    var data: IntegrationUrlData
}

public struct IntegrationUrlData: Codable {
    public var url: String
}

struct SwapQuotesResponse: Response, Codable {
    var data: SwapQuotesData
}

public struct SwapQuotesData: Codable {
    public var quotes: [ICryptoFlowQuote]
}

public struct ICryptoFlowQuote: Codable {
    public struct Service: Codable {
        public var id: String
        public var name: String
        public var logo: String
        public var description: String?
    }
    
    public var service: Service
    public var source: IAssetQuote
    public var target: IAssetQuote
    public var rate: Double?
    public var widgetUrl: String?
    public var paymentMethods: [String]?
}

public struct IAssetQuote: Codable {
    public var asset: ICryptoFlowAsset
    public var amountExpected: Double
    public var totalFee: Double?
}

public struct ICryptoFlowAsset: Codable {
    public var name: String
    public var code: String
    public var type: String
    // crypto only
    public var address: String?
    public var chainId: Int?
    public var decimals: Int?
    public var minAmount: Double?
    public var maxAmount: Double?
    // fiat only
    public var symbol: String?
    // both
    public var imageUrl: String?
}

struct ResultResponse: Response, Codable {
    var data: ResultData
}

public struct ResultData: Codable {
    public var success: Bool
}

public struct RemoteConfig: Codable {
    public var fpApiKey: String
}

// MARK: - SwiftBlade errors
public enum SwiftBladeError: Error {
    case unknownJsError(String)
    case apiError(String)
    case initError(String)
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

public enum CryptoFlowServiceStrategy: String {
    case BUY = "Buy"
    case SELL = "Sell"
    case SWAP = "Swap"
}
