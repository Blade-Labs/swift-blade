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

struct AccountPrivateResponse: Response, Codable {
    var data: AccountPrivateData
}

public struct AccountPrivateData: Codable {
    public var accounts: [AccountPrivateRecord]
}

public struct AccountPrivateRecord: Codable {
    public var privateKey: String
    public var publicKey: String
    public var evmAddress: String
    public var address: String
    public var path: String
    public var keyType: CryptoKeyType
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
    public var publicKey: String
    public var stakingInfo: StakingInfo
}

public struct StakingInfo: Codable {
    public var pendingReward: Int64
    public var stakedNodeId: Int64?
    public var stakePeriodStart: String?
}

struct NodesResponse: Response, Codable {
    var data: NodesData
}

public struct NodesData: Codable {
    public var nodes: [NodeInfo]
}

public struct NodeInfo: Codable {
    public var description: String
    public var max_stake: Int64
    public var min_stake: Int64
    public var node_id: Int
    public var node_account_id: String
    public var stake: Int64
    public var stake_not_rewarded: Int64
    public var stake_rewarded: Int64
}


struct TransactionReceiptResponse: Response, Codable {
    var data: TransactionReceiptData
}

public struct TransactionReceiptData: Codable {
    public var status: String
    public var contractId: String?
    public var topicSequenceNumber: String?
    public var totalSupply: String?
    public var serials: [String]
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
    public var fee: Double
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
    public var token_id: String?
}

public struct TransactionHistoryNftTransfer: Codable {
    public var is_approval: Bool
    public var receiver_account_id: String
    public var sender_account_id: String?
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

struct CreateTokenResponse: Response, Codable {
    var data: CreateTokenData
}

public struct CreateTokenData: Codable {
    public var tokenId: String
}

public struct RemoteConfig: Codable {
    public var fpApiKey: String
    public var fpSubdomain: String
}

struct CoinListResponse: Response, Codable {
    var data: CoinListData
}

public struct CoinListData: Codable {
    public var coins: [CoinItem]
}

public struct CoinItem: Codable {
    public var id: String
    public var symbol: String
    public var name: String
    public var platforms: [CoinGeckoPlatform]
}

public struct CoinGeckoPlatform: Codable {
    public var name: String
    public var address: String
}

struct CoinInfoResponse: Response, Codable {
    var data: CoinInfoData
}

public struct CoinInfoData: Codable {
    public var coin: CoinData
    public var priceUsd: Double
    public var price: Double?
    public var currency: String
}

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

public struct CoinDataDescription: Codable {
    public var en: String
}

public struct CoinDataImage: Codable {
    public var thumb: String
    public var small: String
    public var large: String
}

public struct CoinDataMarket: Codable {
    public var current_price: [String: Double]
}

public struct KeyRecord: Codable {
    public var privateKey: String
    public var type: KeyType
    
    public init(privateKey: String, type: KeyType) {
        self.privateKey = privateKey
        self.type = type
    }
}

public struct NFTStorageConfig: Encodable {
    public var provider: NFTStorageProvider
    public var apiKey: String
    
    public init(provider: NFTStorageProvider, apiKey: String) {
        self.provider = provider
        self.apiKey = apiKey
    }
}

struct TokenDropResponse: Response, Codable {
    var data: TokenDropData
}

public struct TokenDropData: Codable {
    public var status: String
    public var statusCode: Int
    public var timestamp: String
    public var executionStatus: String
    public var requestId: String
    public var accountId: String
    public var redirectUrl: String
}

struct CreateScheduleResponse: Response, Codable {
    var data: CreateScheduleData
}

public struct CreateScheduleData: Codable {
    public var scheduleId: String
}

public protocol ScheduleTransactionTransfer: Codable {
    var type: ScheduleTransferType { get }
    var sender: String { get }
    var receiver: String { get }
    var value: Int { get }
    var tokenId: String { get set }
    var serial: Int { get }
}

public class ScheduleTransactionTransferHbar: ScheduleTransactionTransfer {
    public required init(sender: String, receiver: String, value: Int) {
        self.sender = sender
        self.receiver = receiver
        self.value = value
    }
    
    public var type: ScheduleTransferType = .HBAR
    public let sender: String
    public let receiver: String
    public let value: Int
    public var tokenId: String = ""
    public var serial: Int = 0
}

public class ScheduleTransactionTransferToken: ScheduleTransactionTransfer {
    public required init(sender: String, receiver: String, tokenId: String, value: Int) {
        self.sender = sender
        self.receiver = receiver
        self.tokenId = tokenId
        self.value = value
    }
    
    public var type: ScheduleTransferType = .FT
    public let sender: String
    public let receiver: String
    public let value: Int
    public var tokenId: String
    public var serial: Int = 0
}

public class ScheduleTransactionTransferNFT: ScheduleTransactionTransfer {
    public required init(sender: String, receiver: String, tokenId: String, serial: Int) {
        self.sender = sender
        self.receiver = receiver
        self.tokenId = tokenId
        self.serial = serial
    }
    
    public var type: ScheduleTransferType = .NFT
    public let sender: String
    public let receiver: String
    public var value: Int = 0
    public var tokenId: String
    public var serial: Int
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
        NSLocalizedString("\(name): \(reason)", comment: reason)
    }
}

// MARK: - SwiftBlade enums

public enum HederaNetwork: String {
    case TESTNET
    case MAINNET
}

public enum BladeEnv: String {
    case Prod
    case CI
}

public enum CryptoFlowServiceStrategy: String {
    case BUY = "Buy"
    case SELL = "Sell"
    case SWAP = "Swap"
}

public enum CryptoKeyType: String, Codable {
    case ECDSA_SECP256K1 = "ECDSA_SECP256K1"
    case ED25519 = "ED25519"
}

public enum KeyType: String, Codable {
    case admin = "admin"
    case kyc = "kyc"
    case freeze = "freeze"
    case wipe = "wipe"
    case pause = "pause"
    case feeSchedule = "feeSchedule"
}

public enum NFTStorageProvider: String, Encodable {
    case nftStorage = "nftStorage"
}

public enum ScheduleTransactionType: String, Codable {
    case TRANSFER = "TRANSFER"
    // case SUBMIT_MESSAGE = "SUBMIT_MESSAGE"
    // case APPROVE_ALLOWANCE = "APPROVE_ALLOWANCE"
    // case TOKEN_MINT = "TOKEN_MINT"
    // case TOKEN_BURN = "TOKEN_BURN"
}

public enum ScheduleTransferType: String, Codable {
    case HBAR = "HBAR"
    case FT = "FT"
    case NFT = "NFT"
}
