import WebKit

public class SwiftBlade: NSObject {
    public static let shared = SwiftBlade()

    private var webView: WKWebView?
    private var webViewInitialized = false
    private var deferCompletions: [String: (_ result: Data?, _ error: BladeJSError?) -> Void] = [:]
    private var initCompletion: ((_ result: InfoData?, _ error: BladeJSError?) -> Void)?
    private var completionId: Int = 0
    private var remoteConfig: RemoteConfig? = nil

    private var apiKey: String? = nil
    private var visitorId: String = ""
    private var network: HederaNetwork = .TESTNET
    private var bladeEnv: BladeEnv = .Prod
    private var dAppCode: String?
    private let sdkVersion: String = "Swift@0.6.25"

    // MARK: - It's init time 🎬

    /// Init instance of SwiftBlade for correct work with Blade API and Hedera network.
    ///
    /// - Parameters:
    ///   - apiKey: Unique key for API provided by Blade team.
    ///   - dAppCode: your dAppCode - request specific one by contacting Bladelabs team
    ///   - network: `.TESTNET` or `.MAINNET` of Hedera network
    ///   - bladeEnv: `.CI` or `.PROD` field to set BladeAPI environment. Prod used by default.
    ///   - force: optional field to force init. Will not crash if already initialized
    ///   - completion: completion closure that will be executed after webView is fully loaded and rendered, and result with `InfoData` type
    ///
    /// ```
    /// SwiftBlade.shared.initialize(apiKey: apiKey, dAppCode: apiKey, network: .TESTNET, bladeEnv: .Prod) { (result, error) in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns `InfoData` - with information about Blade instance, including visitorId
    public func initialize(apiKey: String, dAppCode: String, network: HederaNetwork, bladeEnv: BladeEnv = BladeEnv.Prod, force: Bool = false, completion: @escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void) {
        guard !webViewInitialized || force else {
            print("Error while doing double init of SwiftBlade")
            return completion(nil, BladeJSError(name: "Error", reason: "Error while doing double init of SwiftBlade"))
        }
        // Setting up all required properties
        initCompletion = completion
        self.apiKey = apiKey
        self.dAppCode = dAppCode
        self.network = network
        self.bladeEnv = bladeEnv

        Task {
            do {
                if (
                    (UserDefaults.standard.string(forKey: "visitorIdEnv") ?? "") == self.bladeEnv.rawValue
                    && Int(Date().timeIntervalSince1970) - UserDefaults.standard.integer(forKey: "visitorIdTimestamp") < 3600 * 24 * 30
                ) {
                    self.visitorId = UserDefaults.standard.string(forKey: "visitorId") ?? ""
                }
   
                if self.visitorId == "" {
                    self.remoteConfig = try await getRemoteConfig(network: network, dAppCode: dAppCode, sdkVersion: self.sdkVersion, bladeEnv: bladeEnv)
                    self.visitorId = try await getVisitorId(fingerPrintApiKey: remoteConfig!.fpApiKey)
                    UserDefaults.standard.set(self.visitorId, forKey: "visitorId")
                    UserDefaults.standard.set(self.bladeEnv.rawValue, forKey: "visitorIdEnv")
                    UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: "visitorIdTimestamp")
                }
                DispatchQueue.main.async {
                    self.initWebView()
                }
            } catch {
                completion(nil, BladeJSError(name: "Init failed", reason: "\(error)"))
            }
        }
    }

    // MARK: - Public methods 📢

    /// Get SDK info and check if SDK initialized
    ///
    /// - Parameters:
    ///   - completion: result with `InfoData` type
    ///
    /// ```
    /// SwiftBlade.shared.getInfo() { (result, error) in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `InfoData` - with information about Blade instance, including visitorId
    public func getInfo(completion: @escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getInfo")
        performRequest(
            completionKey: completionKey,
            js: "getInfo('\(completionKey)')",
            decodeType: InfoResponse.self,
            completion: completion
        )
    }

    /// Get balances by Hedera account id (address)
    ///
    /// - Parameters:
    ///   - id: Hedera id (address), example: 0.0.112233
    ///   - completion: result with BalanceData type
    ///
    /// ```
    /// SwiftBlade.shared.getBalance("0.0.10001") { (result, error) in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `BalanceData` - with information about Hedera account balances (hbar and list of token balances)
    public func getBalance(_ id: String, completion: @escaping (_ result: BalanceData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getBalance")
        performRequest(
            completionKey: completionKey,
            js: "getBalance('\(esc(id))', '\(completionKey)')",
            decodeType: BalanceResponse.self,
            completion: completion
        )
    }

    /// Get list of all available coins on CoinGecko.
    ///
    /// - Parameters:
    ///   - completion: result with CoinListData type
    ///
    /// ```
    /// SwiftBlade.shared.getCoinList { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `CoinListData` - with list of coins described by name, alias, platforms
    public func getCoinList(completion: @escaping (_ result: CoinListData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getCoinList")
        performRequest(
            completionKey: completionKey,
            js: "getCoinList('\(completionKey)')",
            decodeType: CoinListResponse.self,
            completion: completion
        )
    }

    /// Get coin price and coin info from CoinGecko. Search can be coin id or address in one of the coin platforms.
    /// In addition to the price in USD, the price in the currency you specified is returned
    ///
    /// - Parameters:
    ///   - search: CoinGecko coinId, or address in one of the coin platforms or `hbar` (default, alias for `hedera-hashgraph`)
    ///   - currency: result currency for price field
    ///   - completion: result with CoinInfoData type
    ///
    /// ```
    /// SwiftBlade.shared.getCoinPrice("Hbar", "uah") { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `CoinInfoData`
    public func getCoinPrice(_ search: String, _ currency: String = "usd", completion: @escaping (_ result: CoinInfoData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getCoinPrice")
        performRequest(
            completionKey: completionKey,
            js: "getCoinPrice('\(esc(search))', '\(esc(currency))', '\(completionKey)')",
            decodeType: CoinInfoResponse.self,
            completion: completion
        )
    }

    /// Method to execute Hbar transfers from current account to receiver
    ///
    /// - Parameters:
    ///   - accountId: sender account id
    ///   - accountPrivateKey: sender's private key to sign transfer transaction
    ///   - receiverId: receiver
    ///   - amount: amount
    ///   - memo: memo (limited to 100 characters)
    ///   - completion: result with `TransactionReceiptData` type
    ///
    /// ```
    /// let accountId = "0.0.10001"
    /// let privateKeyHex = "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// let receiverId = "0.0.10002"
    /// let amount: Decimal = 7.0
    /// let memo = "transferHbars tests Swift"
    ///
    /// SwiftBlade.shared.transferHbars(
    ///     accountId: accountId,
    ///     accountPrivateKey: privateKeyHex,
    ///     receiverId: receiverId,
    ///     amount: amount,
    ///     memo: memo
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TransactionReceiptData` receipt
    public func transferHbars(accountId: String, accountPrivateKey: String, receiverId: String, amount: Decimal, memo: String, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("transferHbars")
        performRequest(
            completionKey: completionKey,
            js: "transferHbars('\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(receiverId))', '\(amount)', '\(esc(memo))', '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }

    /// Method to execute token transfers from current account to receiver
    ///
    /// - Parameters:
    ///   - tokenId: token id to send (0.0.xxxxx)
    ///   - accountId: sender account id (0.0.xxxxx)
    ///   - accountPrivateKey: sender's hex-encoded private key with DER-header (302e020100300506032b657004220420...). ECDSA or Ed25519
    ///   - receiverId: receiver account id (0.0.xxxxx)
    ///   - amountOrSerial: amount of fungible tokens to send (with token-decimals correction) on NFT serial number
    ///   - memo: memo (limited to 100 characters)
    ///   - usePaymaster: if true, Paymaster account will pay fee transaction. Only for single dApp configured fungible-token. In that case tokenId not used
    ///   - completion: result with `TransactionReceiptData` type
    ///
    /// ```
    /// let tokenId = "0.0.1337"
    /// let senderId = "0.0.10001"
    /// let senderKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// let receiverId = "0.0.10002"
    /// let amount: Decimal = 5.0
    ///
    /// SwiftBlade.shared.transferTokens(
    ///     tokenId: tokenId,
    ///     accountId: senderId,
    ///     accountPrivateKey: senderKey,
    ///     receiverId: receiverId,
    ///     amountOrSerial: amount,
    ///     memo: "transferTokens tests Swift (paid)",
    ///     usePaymaster: false
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TransactionReceiptData` receipt
    public func transferTokens(tokenId: String, accountId: String, accountPrivateKey: String, receiverId: String, amountOrSerial: Decimal, memo: String, usePaymaster: Bool = true, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("transferTokens")
        performRequest(
            completionKey: completionKey,
            js: "transferTokens('\(esc(tokenId))', '\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(receiverId))', '\(amountOrSerial)', '\(esc(memo))', \(usePaymaster), '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }
    
    /// Create scheduled transaction
    ///
    /// - Parameters:
    ///   - accountId: account id (0.0.xxxxx)
    ///   - accountPrivateKey: account key (hex encoded privateKey with DER-prefix)
    ///   - type: schedule transaction type (currently only TRANSFER supported)
    ///   - transfers: array of transfers to schedule (HBAR, FT, NFT)
    ///   - usePaymaster: if true, Paymaster account will pay transaction fee (also dApp had to be configured for free schedules)
    ///   - completion: result with `CreateScheduleData` type
    ///
    /// ```
    /// let receiverId = "0.0.10002"
    /// let receiverKey = "302d300706052b8104000a032200029dc73991b00002..."
    /// let senderId = "0.0.10001"
    /// let tokenId = "0.0.1337"
    ///
    /// SwiftBlade.shared.createScheduleTransaction(
    ///     accountId: receiverId,
    ///     accountPrivateKey: receiverKey,
    ///     type: .TRANSFER,
    ///     transfers: [
    ///         ScheduleTransactionTransferHbar(sender: senderId, receiver: receiverId, value: 10000000),
    ///         ScheduleTransactionTransferToken(sender: senderId, receiver: receiverId, tokenId: tokenId, value: 3)
    ///     ],
    ///     false
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `CreateScheduleData` scheduleId
    public func createScheduleTransaction(
        accountId: String,
        accountPrivateKey: String,
        type: ScheduleTransactionType,
        transfers: [ScheduleTransactionTransfer],
        _ usePaymaster: Bool = false,
        completion: @escaping (_ result: CreateScheduleData?, _ error: BladeJSError?) -> Void
    ) {
        let completionKey = getCompletionKey("createScheduleTransaction")

        let transfersEncoded = transfers.map { try? JSONEncoder().encode($0) }
                              .compactMap { $0 }
                              .map { String(data: $0, encoding: .utf8)! }
                              .joined(separator: ",")

        performRequest(
            completionKey: completionKey,
            js: "createScheduleTransaction('\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(type.rawValue))', [\(transfersEncoded)], \(usePaymaster), '\(completionKey)')",
            decodeType: CreateScheduleResponse.self,
            completion: completion
        )
    }


    /// Method to sign scheduled transaction
    ///
    /// - Parameters:
    ///   - scheduleId: scheduled transaction id (0.0.xxxxx)
    ///   - accountId: account id (0.0.xxxxx)
    ///   - accountPrivateKey: hex encoded privateKey with DER-prefix
    ///   - receiverAccountId account id of receiver for additional validation in case of dApp freeSchedule transactions configured
    ///   - usePaymaster if true, Paymaster account will pay transaction fee (also dApp had to be configured for free schedules)
    ///   - completion: result with `TransactionReceiptData` type
    /// 
    /// ```
    /// let senderId = "0.0.10001"
    /// let senderKey = "302d300706052b8104000a032200029dc73991b00001..."
    /// let receiverId = "0.0.10002"
    /// let scheduleId = "0.0...." // result of createScheduleTransaction on receiver side
    ///
    /// SwiftBlade.shared.signScheduleId(
    ///     scheduleId: scheduleId,
    ///     accountId: senderId,
    ///     accountPrivateKey: senderKey,
    ///     receiverAccountId: receiverId,
    ///     usePaymaster: false
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TransactionReceiptData` receipt
    public func signScheduleId(
        scheduleId: String,
        accountId: String,
        accountPrivateKey: String,
        receiverAccountId: String = "",
        usePaymaster: Bool = false,
        completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void
    ) {
        let completionKey = getCompletionKey("signScheduleId")
        performRequest(
            completionKey: completionKey,
            js: "signScheduleId('\(esc(scheduleId))', '\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(receiverAccountId))', \(usePaymaster), '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }

    
    /// Create new Hedera account (ECDSA). Only for configured dApps. Depending on dApp config Blade create account, associate tokens, etc.
    /// In case of not using pre-created accounts pool and network high load, this method can return transactionId and no accountId.
    /// In that case account creation added to queue, and you should wait some time and call `getPendingAccount()` method.
    ///
    /// - Parameters:
    ///   - privateKey: optional field if you need specify account key (hex encoded privateKey with DER-prefix)
    ///   - deviceId: unique device id (advanced security feature, required only for some dApps)
    ///   - completion: result with CreatedAccountData type
    ///
    /// ```
    /// SwiftBlade.shared.createHederaAccount() { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `CreatedAccountData` new account data, including private key and account id
    public func createHederaAccount(_ privateKey: String = "", deviceId: String = "", completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("createAccount")
        performRequest(
            completionKey: completionKey,
            js: "createAccount('\(esc(privateKey))', '\(esc(deviceId))', '\(completionKey)')",
            decodeType: CreatedAccountResponse.self,
            completion: completion
        )
    }

    /// Get account from queue (read more at `createAccount()`).
    /// If account already created, return account data.
    /// If account not created yet, response will be same as in `createHederaAccount()` method if account in queue.
    ///
    /// - Parameters:
    ///   - transactionId: can be received on createHederaAccount method, when busy network is busy, and account creation added to queue
    ///   - seedPhrase: returned from createHederaAccount method, required for updating keys and proper response
    ///   - completion: result with `CreatedAccountData` type
    ///
    /// - Returns: `CreatedAccountData` new account data
    public func getPendingAccount(transactionId: String, seedPhrase: String, completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getPendingAccount")
        performRequest(
            completionKey: completionKey,
            js: "getPendingAccount('\(esc(transactionId))', '\(esc(seedPhrase))', '\(completionKey)')",
            decodeType: CreatedAccountResponse.self,
            completion: completion
        )
    }

    /// Delete Hedera account. This method requires account private key and operator private key. Operator is the one who paying fees
    ///
    /// - Parameters:
    ///   - deleteAccountId: account to delete - id
    ///   - deletePrivateKey: account to delete - private key
    ///   - transferAccountId: The ID of the account to transfer the remaining funds to.
    ///   - operatorAccountId: operator account Id
    ///   - operatorPrivateKey: operator account private key
    ///   - completion: result with TransactionReceiptData type
    ///
    /// ```
    /// let deleteAccountId = "0.0.65468464"
    /// let deletePrivateKey = "3030020100300706052b8104000a04220420ebc..."
    /// let transferAccountId = "0.0.10001"
    /// let operatorAccountId = "0.0.10002"
    /// let operatorPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
    ///
    /// SwiftBlade.shared.deleteHederaAccount(
    ///     deleteAccountId: deleteAccountId,
    ///     deletePrivateKey: deletePrivateKey,
    ///     transferAccountId: transferAccountId,
    ///     operatorAccountId: operatorAccountId,
    ///     operatorPrivateKey: operatorPrivateKey
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TransactionReceiptData` receipt
    public func deleteHederaAccount(deleteAccountId: String, deletePrivateKey: String, transferAccountId: String, operatorAccountId: String, operatorPrivateKey: String, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("deleteHederaAccount")
        performRequest(
            completionKey: completionKey,
            js: "deleteAccount('\(esc(deleteAccountId))', '\(esc(deletePrivateKey))', '\(esc(transferAccountId))', '\(esc(operatorAccountId))', '\(esc(operatorPrivateKey))',  '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }

    /// Get account info.
    /// EvmAddress is address of Hedera account if exists. Else accountId will be converted to solidity address.
    /// CalculatedEvmAddress is calculated from account public key. May be different from evmAddress.
    ///
    /// - Parameters:
    ///   - accountId: Hedera account id (0.0.xxxxx)
    ///   - completion: result with AccountInfoData type
    ///
    /// ```
    /// SwiftBlade.shared.getAccountInfo(accountId: "0.0.10001") { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `AccountInfoData`
    public func getAccountInfo(accountId: String, completion: @escaping (_ result: AccountInfoData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getAccountInfo")
        performRequest(
            completionKey: completionKey,
            js: "getAccountInfo('\(esc(accountId))', '\(completionKey)')",
            decodeType: AccountInfoResponse.self,
            completion: completion
        )
    }

    /// Get Node list and use it for choosing account stacking node
    ///
    /// - Parameters:
    ///   - completion: result with NodesData type
    ///
    /// ```
    /// SwiftBlade.shared.getNodeList() { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `NodesData` node list
    public func getNodeList(completion: @escaping (_ result: NodesData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getNodeList")
        performRequest(
            completionKey: completionKey,
            js: "getNodeList('\(completionKey)')",
            decodeType: NodesResponse.self,
            completion: completion
        )
    }
  
    /// Stake/unstake account
    ///
    /// - Parameters:
    ///   - accountId: Hedera account id (0.0.xxxxx)
    ///   - accountPrivateKey account private key (DER encoded hex string)
    ///   - nodeId node id to stake to. If negative or null, account will be unstaked
    ///   - completion: result with TransactionReceiptData type
    ///
    /// ```
    /// SwiftBlade.shared.stakeToNode(accountId: "0.0.10002", accountPrivateKey: "302d300706052b8104000a032200029dc73991b0d9cd...", nodeId: 5) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TransactionReceiptData` receipt
    public func stakeToNode(accountId: String, accountPrivateKey: String, nodeId: Int, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("stakeToNode")
        performRequest(
            completionKey: completionKey,
            js: "stakeToNode('\(esc(accountId))', '\(esc(accountPrivateKey))', \(nodeId), '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }
    
    /// Get private key and accountId from mnemonic. Supported standard and legacy key derivation.
    /// If account not found, standard ECDSA key will be returned.
    /// Keys returned with DER header. EvmAddress computed from Public key.
    ///
    /// - Parameters:
    ///   - mnemonic: seed phrase (BIP39 mnemonic)
    ///   - lookupNames: lookup for accounts (not used anymore, account search is mandatory)
    ///   - completion: result with PrivateKeyData type
    ///
    /// ```
    /// let mnemonic = "purity slab doctor swamp tackle rebuild summer bean craft toddler blouse switch"
    /// SwiftBlade.shared.getKeysFromMnemonic(mnemonic: mnemonic, lookupNames: true) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `PrivateKeyData` private key derived from mnemonic and account id
    @available(*, deprecated, message: "This method is deprecated. Please use [searchAccounts] instead.")
    public func getKeysFromMnemonic(mnemonic: String, lookupNames: Bool = false, completion: @escaping (_ result: PrivateKeyData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getKeysFromMnemonic")
        performRequest(
            completionKey: completionKey,
            js: "getKeysFromMnemonic('\(esc(mnemonic))', \(lookupNames), '\(completionKey)')",
            decodeType: PrivateKeyResponse.self,
            completion: completion
        )
    }
    
    /// Get accounts list and keys from private key or mnemonic
    /// Supporting standard and legacy key derivation.
    /// Every key with account will be returned.
    ///
    /// - Parameters:
    ///   - keyOrMnemonic: BIP39 mnemonic, private key with DER header
    ///   - completion: result with AccountPrivateData type
    ///
    /// ```
    /// let mnemonic = "purity slab doctor swamp tackle rebuild summer bean craft toddler blouse switch"
    /// SwiftBlade.shared.searchAccounts(mnemonic) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `AccountPrivateData` list of found accounts with private keys
    public func searchAccounts(_ keyOrMnemonic: String, completion: @escaping (_ result: AccountPrivateData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("searchAccounts")
        performRequest(
            completionKey: completionKey,
            js: "searchAccounts('\(esc(keyOrMnemonic))', '\(completionKey)')",
            decodeType: AccountPrivateResponse.self,
            completion: completion
        )
    }

    /// Bladelink drop to account
    ///
    /// - Parameters:
    ///   - accountId: Hedera account id (0.0.xxxxx)
    ///   - accountPrivateKey: account private key (DER encoded hex string)
    ///   - secretNonce: configured for dApp. Should be kept in secret
    ///   - completion: result with TokenDropData type
    ///
    /// ```
    /// let accountId = "0.0.10002"
    /// let accountPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// let secretNonce = "[ CENSORED ]"
    ///
    /// SwiftBlade.shared.dropTokens(
    ///     accountId: accountId,
    ///     accountPrivateKey: accountPrivateKey,
    ///     secretNonce: secretNonce
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TokenDropData` status
    public func dropTokens(accountId: String, accountPrivateKey: String, secretNonce: String, completion: @escaping (_ result: TokenDropData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("dropTokens")
        performRequest(
            completionKey: completionKey,
            js: "dropTokens('\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(secretNonce))', '\(completionKey)')",
            decodeType: TokenDropResponse.self,
            completion: completion
        )
    }

    /// Sign base64-encoded message with private key. Returns hex-encoded signature.
    ///
    /// - Parameters:
    ///   - messageString: base64-encoded message to sign
    ///   - privateKey: hex-encoded private key with DER header
    ///   - completion: result with SignMessageData type
    ///
    /// ```
    /// let originalMessage = "hello"
    /// let privateKeyHex = "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
    ///     SwiftBlade.shared.sign(messageString: base64encodedString, privateKey: privateKeyHex) { result, error in
    ///         print(result ?? error)
    ///     }
    /// }
    /// ```
    ///
    /// - Returns: `SignMessageData` signature
    public func sign(messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("sign")
        performRequest(
            completionKey: completionKey,
            js: "sign('\(esc(messageString))', '\(esc(privateKey))', '\(completionKey)')",
            decodeType: SignMessageResponse.self,
            completion: completion
        )
    }

    /// Verify message signature with public key
    ///
    /// - Parameters:
    ///   - messageString: base64-encoded message (same as provided to `sign()` method)
    ///   - signature: hex-encoded signature (result from `sign()` method)
    ///   - publicKey: hex-encoded public key with DER header
    ///   - completion: result with SignVerifyMessageData type
    ///
    /// ```
    /// let originalString = "hello"
    /// let signedMessage = "27cb9d51434cf1e76d7ac515b19442c619f641e6fccddbf4a3756b14466becb6992dc1d2a82268018147141fc8d66ff9ade43b7f78c176d070a66372d655f942"
    /// let publicKey = "302d300706052b8104000a032200029dc73991b0d9cdbb59b2cd0a97a0eaff6de801726cb39804ea9461df6be2dd30"
    /// if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
    ///     SwiftBlade.shared.signVerify(messageString: base64encodedString, signature: signedMessage, publicKey: publicKey) { result, error in
    ///         print(result ?? error)
    ///     }
    /// }
    /// ```
    ///
    /// - Returns: `SignVerifyMessageData` verification result
    public func signVerify(messageString: String, signature: String, publicKey: String, completion: @escaping (_ result: SignVerifyMessageData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("signVerify")
        performRequest(
            completionKey: completionKey,
            js: "signVerify('\(esc(messageString))', '\(esc(signature))', '\(esc(publicKey))', '\(completionKey)')",
            decodeType: SignVerifyMessageResponse.self,
            completion: completion
        )
    }

    /// Method to create smart-contract function parameters (instance of ContractFunctionParameters)
    ///
    /// ```
    /// let tuple = SwiftBlade.shared.createContractFunctionParameters()
    ///     .addInt64(value: 16)
    ///     .addInt64(value: 32)
    /// ```
    ///
    /// - Returns: `ContractFunctionParameters`
    public func createContractFunctionParameters() -> ContractFunctionParameters {
        return ContractFunctionParameters()
    }

    /// Call contract function. Directly or via BladeAPI using paymaster account (fee will be paid by Paymaster account), depending on your dApp configuration.
    ///
    /// - Parameters:
    ///   - contractId: contract id (0.0.xxxxx)
    ///   - functionName: name of the contract function to call
    ///   - params: function argument. Can be generated with `createContractFunctionParameters()` method
    ///   - accountId: operator account id (0.0.xxxxx)
    ///   - accountPrivateKey: operator's hex-encoded private key with DER-header, ECDSA or Ed25519
    ///   - gas: gas limit for transaction (default 100000)
    ///   - usePaymaster: if true, fee will be paid by Paymaster account (note: msg.sender inside the contract will be Paymaster account)
    ///   - completion: result with TransactionReceiptData type
    ///
    /// ```
    /// let contractId = "0.0.123456"
    /// let functionName = "set_message"
    /// let parameters = SwiftBlade.shared.createContractFunctionParameters().addString(value: "Hello Swift test")
    /// let accountId = "0.0.10002"
    /// let accountPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// let gas = 155_000
    /// let usePaymaster = false
    ///
    /// SwiftBlade.shared.contractCallFunction(
    ///     contractId: contractId, functionName: functionName, params: parameters, accountId: accountId, accountPrivateKey: accountPrivateKey, gas: gas, usePaymaster: usePaymaster
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TransactionReceiptData` receipt
    public func contractCallFunction(contractId: String, functionName: String, params: ContractFunctionParameters, accountId: String, accountPrivateKey: String, gas: Int = 100_000, usePaymaster: Bool, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("contractCallFunction")
        performRequest(
            completionKey: completionKey,
            js: "contractCallFunction('\(esc(contractId))', '\(esc(functionName))', '\(params.encode())', '\(esc(accountId))', '\(esc(accountPrivateKey))', \(gas), \(usePaymaster), '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }

    /// Call query on contract function. Similar to  `contractCallFunction()` can be called directly or via BladeAPI using Paymaster account.
    ///
    /// - Parameters:
    ///   -  contractId: contract id (0.0.xxxxx)
    ///   -  functionName: name of the contract function to call
    ///   -  params: function argument. Can be generated with `createContractFunctionParameters()` method
    ///   -  accountId: operator account id (0.0.xxxxx)
    ///   -  accountPrivateKey: operator's hex-encoded private key with DER-header, ECDSA or Ed25519
    ///   -  gas: gas limit for the transaction
    ///   -  usePaymaster: if true, the fee will be paid by paymaster account (note: msg.sender inside the contract will be Paymaster account)
    ///   -  returnTypes: list of return types, e.g. ["string", "int32"]
    ///   -  completion: result with ContractQueryData type
    ///
    /// ```
    /// let contractId = "0.0.123456"
    /// let functionName = "get_message"
    /// let parameters = SwiftBlade.shared.createContractFunctionParameters()
    /// let accountId = "0.0.10002"
    /// let accountPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// let gas = 155_000
    /// let usePaymaster = false
    /// let returnTypes = ["string", "int32"]
    ///
    /// SwiftBlade.shared.contractCallQueryFunction(
    ///     contractId: contractId, functionName: functionName, params: SwiftBlade.shared.createContractFunctionParameters(), accountId: accountId, accountPrivateKey: accountPrivateKey, gas: gas, usePaymaster: usePaymaster, returnTypes: returnTypes
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `ContractQueryData` contract query call result
    public func contractCallQueryFunction(contractId: String, functionName: String, params: ContractFunctionParameters, accountId: String, accountPrivateKey: String, gas: Int = 100_000, usePaymaster: Bool, returnTypes: [String], completion: @escaping (_ result: ContractQueryData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("contractCallQueryFunction")
        performRequest(
            completionKey: completionKey,
            js: "contractCallQueryFunction('\(esc(contractId))', '\(esc(functionName))', '\(params.encode())', '\(esc(accountId))', '\(esc(accountPrivateKey))', \(gas), \(usePaymaster), [\(returnTypes.map { "'\(esc($0))'" }.joined(separator: ","))], '\(completionKey)')",
            decodeType: ContractQueryResponse.self,
            completion: completion
        )
    }

    /// Sign base64-encoded message with private key using ethers lib. Returns hex-encoded signature.
    ///
    /// - Parameters:
    ///   - messageString: base64-encoded message to sign
    ///   - privateKey: hex-encoded private key with DER header
    ///   - completion: result with SignMessageData type
    ///
    /// ```
    /// let originalMessage = "hello"
    /// let privateKeyHex = "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
    ///     SwiftBlade.shared.ethersSign(messageString: base64encodedString, privateKey: privateKeyHex) { result, error in
    ///         print(result ?? error)
    ///     }
    /// }
    /// ```
    ///
    /// - Returns: `SignMessageData` signature
    public func ethersSign(messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("ethersSign")
        performRequest(
            completionKey: completionKey,
            js: "ethersSign('\(esc(messageString))', '\(esc(privateKey))', '\(completionKey)')",
            decodeType: SignMessageResponse.self,
            completion: completion
        )
    }

    /// Split signature to v-r-s format.
    ///
    /// - Parameters:
    ///   - signature: hex-encoded signature
    ///   - completion: result with SplitSignatureData type
    ///
    /// ```
    /// let signedMessage = "0x27cb9d51434cf1e76d7ac515b19442c619f641e6fccddbf4a3756b14466becb6992dc1d2a82268018147141fc8d66ff9ade43b7f78c176d070a66372d655f942"
    /// SwiftBlade.shared.splitSignature(signature: signMessageData.signedMessage) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `SplitSignatureData` v-r-s signature
    public func splitSignature(signature: String, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("splitSignature")
        performRequest(
            completionKey: completionKey,
            js: "splitSignature('\(esc(signature))', '\(completionKey)')",
            decodeType: SplitSignatureResponse.self,
            completion: completion
        )
    }

    /// Get v-r-s signature of contract function params
    ///
    /// - Parameters:
    ///   - params: data to sign. (instance of ContractFunctionParameters. Can be generated with `createContractFunctionParameters()` method)
    ///   - accountPrivateKey: signer private key (hex-encoded with DER header)
    ///   - completion: result with SplitSignatureData type
    ///
    /// ```
    /// let privateKeyHex = "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// let parameters = SwiftBlade.shared.createContractFunctionParameters()
    ///     .addAddress(value: accountId)
    ///     .addUInt64Array(value: [300_000, 300_000])
    ///     .addUInt64Array(value: [6])
    ///     .addUInt64Array(value: [2])
    ///
    /// SwiftBlade.shared.getParamsSignature(params: parameters, accountPrivateKey: privateKeyHex) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `SplitSignatureData` v-r-s signature
    public func getParamsSignature(params: ContractFunctionParameters, accountPrivateKey: String, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getParamsSignature")
        performRequest(
            completionKey: completionKey,
            js: "getParamsSignature('\(params.encode())', '\(esc(accountPrivateKey))', '\(completionKey)')",
            decodeType: SplitSignatureResponse.self,
            completion: completion
        )
    }

    /// Get transactions history for account. Can be filtered by transaction type.
    /// Transaction requested from mirror node. Every transaction requested for child transactions. Result are flattened.
    /// If transaction type is not provided, all transactions will be returned.
    /// If transaction type is CRYPTOTRANSFERTOKEN records will additionally contain plainData field with decoded data.
    ///
    /// - Parameters:
    ///   - accountId: account id to get transactions for (0.0.xxxxx)
    ///   - transactionType: one of enum MirrorNodeTransactionType or "CRYPTOTRANSFERTOKEN"
    ///   - nextPage: link to next page of transactions from previous request
    ///   - transactionsLimit: number of transactions to return. Speed of request depends on this value if transactionType is set.
    ///   - completion: result with TransactionsHistoryData type
    ///
    /// ```
    /// SwiftBlade.shared.getTransactions(accountId: "0.0.10001", transactionType: "", nextPage: "", transactionsLimit: 5) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TransactionsHistoryData` transactions list
    public func getTransactions(accountId: String, transactionType: String, nextPage: String = "", transactionsLimit: Int = 10, completion: @escaping (_ result: TransactionsHistoryData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getTransactions")
        performRequest(
            completionKey: completionKey,
            js: "getTransactions('\(esc(accountId))', '\(esc(transactionType))', '\(esc(nextPage))', '\(transactionsLimit)', '\(completionKey)')",
            decodeType: TransactionsHistoryResponse.self,
            completion: completion
        )
    }

    /// Get configured url for C14 integration (iframe or popup)
    /// Deprecated now. Please use `exchangeGetQuotes` and `getTradeUrl` methods. Results aggregated on many providers, including C14
    ///
    /// - Parameters:
    ///   - asset: USDC, HBAR, KARATE or C14 asset uuid
    ///   - account: receiver account id (0.0.xxxxx)
    ///   - amount: preset amount. May be overwritten if out of range (min/max)
    ///   - completion: result with IntegrationUrlData type
    ///
    /// ```
    /// SwiftBlade.shared.getC14url(asset: "KARATE", account: "0.0.10001", amount: "1234") { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `IntegrationUrlData` url to open
    @available(*, deprecated, message: "This method is deprecated. Please use [exchangeGetQuotes] and [getTradeUrl] methods. Results aggregated on many providers, including C14.")
    public func getC14url(asset: String, account: String, amount: String, completion: @escaping (_ result: IntegrationUrlData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getC14url")
        performRequest(
            completionKey: completionKey,
            js: "getC14url('\(esc(asset))', '\(esc(account))', '\(esc(amount))', '\(completionKey)')",
            decodeType: IntegrationUrlResponse.self,
            completion: completion
        )
    }

    /// Get quotes from different services for buy, sell or swap
    ///
    /// - Parameters:
    ///   - sourceCode: name (HBAR, KARATE, other token code)
    ///   - sourceAmount: amount to swap, buy or sell
    ///   - targetCode: name (HBAR, KARATE, USDC, other token code)
    ///   - strategy: one of enum CryptoFlowServiceStrategy (Buy, Sell, Swap)
    ///   - completion: result with SwapQuotesData type
    ///
    /// ```
    /// SwiftBlade.shared.exchangeGetQuotes(
    ///     sourceCode: "EUR",
    ///     sourceAmount: 50,
    ///     targetCode: "HBAR",
    ///     strategy: CryptoFlowServiceStrategy.BUY
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: SwapQuotesData quotes from different providers
    public func exchangeGetQuotes(
        sourceCode: String,
        sourceAmount: Double,
        targetCode: String,
        strategy: CryptoFlowServiceStrategy,
        completion: @escaping (_ result: SwapQuotesData?, _ error: BladeJSError?) -> Void
    ) {
        let completionKey = getCompletionKey("exchangeGetQuotes")
        performRequest(
            completionKey: completionKey,
            js: "exchangeGetQuotes('\(esc(sourceCode))', \(sourceAmount), '\(esc(targetCode))', '\(esc(strategy.rawValue))', '\(completionKey)')",
            decodeType: SwapQuotesResponse.self,
            completion: completion
        )
    }

    /// Get configured url to buy or sell tokens or fiat
    ///
    /// - Parameters:
    ///   - strategy: Buy / Sell
    ///   - accountId: account id
    ///   - sourceCode: name (HBAR, KARATE, USDC, other token code)
    ///   - sourceAmount: amount to buy/sell
    ///   - targetCode: name (HBAR, KARATE, USDC, other token code)
    ///   - slippage: slippage in percents. Transaction will revert if the price changes unfavorably by more than this percentage.
    ///   - serviceId: service id to use for swap (saucerswap, onmeta, etc)
    ///   - redirectUrl: url to redirect after final step
    ///   - completion: result with IntegrationUrlData type
    ///
    /// ```
    /// SwiftBlade.shared.getTradeUrl(
    ///     strategy: CryptoFlowServiceStrategy.BUY,
    ///     accountId: "0.0.10001",
    ///     sourceCode: "EUR",
    ///     sourceAmount: 50,
    ///     targetCode: "HBAR",
    ///     slippage: 0.5,
    ///     serviceId: "moonpay"
    /// ) { [self] result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `IntegrationUrlData` url to open
    public func getTradeUrl(
        strategy: CryptoFlowServiceStrategy,
        accountId: String,
        sourceCode: String,
        sourceAmount: Double,
        targetCode: String,
        slippage: Double,
        serviceId: String,
        _ redirectUrl: String = "",
        completion: @escaping (_ result: IntegrationUrlData?, _ error: BladeJSError?) -> Void
    ) {
        let completionKey = getCompletionKey("getTradeUrl")
        performRequest(
            completionKey: completionKey,
            js: "getTradeUrl('\(strategy.rawValue)', '\(esc(accountId))', '\(esc(sourceCode))', \(sourceAmount), '\(esc(targetCode))', \(slippage), '\(esc(serviceId))', '\(esc(redirectUrl))', '\(completionKey)')",
            decodeType: IntegrationUrlResponse.self,
            completion: completion
        )
    }

    /// Swap tokens
    ///
    /// - Parameters:
    ///   - accountId: account id
    ///   - accountPrivateKey: account private key
    ///   - sourceCode: name (HBAR, KARATE, other token code)
    ///   - sourceAmount: amount to swap
    ///   - targetCode: name (HBAR, KARATE, other token code)
    ///   - slippage: slippage in percents. Transaction will revert if the price changes unfavorably by more than this percentage.
    ///   - serviceId: service id to use for swap (saucerswap, etc)
    ///   - completion: result with ResultData type
    ///
    /// ```
    /// let accountId = "0.0.10001"
    /// let accountPrivateKey = "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// let sourceCode = "USDC"
    /// let targetCode = "KARATE"
    ///
    /// SwiftBlade.shared.swapTokens(
    ///     accountId: accountId,
    ///     accountPrivateKey: accountPrivateKey,
    ///     sourceCode: sourceCode,
    ///     sourceAmount: 1,
    ///     targetCode: targetCode,
    ///     slippage: 0.5,
    ///     serviceId: "saucerswap"
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `ResultData` swap result
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
        let completionKey = getCompletionKey("swapTokens")
        performRequest(
            completionKey: completionKey,
            js: "swapTokens('\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(sourceCode))', \(sourceAmount), '\(esc(targetCode))', \(slippage), '\(esc(serviceId))', '\(completionKey)')",
            decodeType: ResultResponse.self,
            completion: completion
        )
    }
     
    /// Create token (NFT or Fungible Token)
    ///
    /// - Parameters:
    ///   - treasuryAccountId: treasury account id
    ///   -  supplyPrivateKey: supply account private key
    ///   -  tokenName: token name (string up to 100 bytes)
    ///   -  tokenSymbol: token symbol (string up to 100 bytes)
    ///   -  isNft: set token type NFT
    ///   -  keys: token keys
    ///   -  decimals: token decimals (0 for nft)
    ///   -  initialSupply: token initial supply (0 for nft)
    ///   -  maxSupply: token max supply
    ///   -  completion: callback function, with result of CreateTokenData or BladeJSError
    ///
    /// ```
    /// let keys = [
    ///     KeyRecord(privateKey: adminPrivateKey, type: KeyType.admin)
    /// ]
    ///
    /// SwiftBlade.shared.createToken(
    ///     treasuryAccountId: accountId,
    ///     supplyPrivateKey: privateKey,
    ///     tokenName: "Blade Demo Token",
    ///     tokenSymbol: "GD",
    ///     isNft: true,
    ///     keys: keys,
    ///     decimals: 0,
    ///     initialSupply: 0,
    ///     maxSupply: 250
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `CreateTokenData` token id
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
   
    
    /// Associate token to account. Association fee will be covered by PayMaster, if tokenId configured in dApp
    ///
    /// - Parameters:
    ///   -  tokenId: token id to associate. Empty to associate all tokens configured in dApp
    ///   -   accountId: account id to associate token
    ///   -   accountPrivateKey: account private key
    ///   -  completion: callback function, with result of TransactionReceiptData or BladeJSError
    ///
    /// ```
    /// SwiftBlade.shared.associateToken(
    ///     tokenId: "0.0.1337",
    ///     accountId: "0.0.10001",
    ///     accountPrivateKey: "302d300706052b8104000a032200029dc73991b0d9cd..."
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TransactionReceiptData` receipt
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

    /// Mint one NFT
    ///
    /// - Parameters:
    ///   - tokenId: token id to mint NFT
    ///   - supplyAccountId: token supply account id
    ///   - supplyPrivateKey: token supply private key
    ///   - file: image to mint (base64 DataUrl image, eg.: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAA...)
    ///   - metadata: NFT metadata
    ///   - storageConfig: IPFS provider config
    ///   - completion: callback function, with result of CreateTokenData or BladeJSError
    ///
    /// ```
    /// SwiftBlade.shared.nftMint(
    ///     tokenId: "0.0.13377",
    ///     supplyAccountId: "0.0.10001",
    ///     supplyPrivateKey: "302d300706052b8104000a032200029dc73991b0d9cd...",
    ///     file: "data:image/png;base64,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",
    ///     metadata: [
    ///         "name": "NFTitle",
    ///         "score": "10",
    ///         "power": "4",
    ///         "intelligence": "6",
    ///         "speed": "10"
    ///     ],
    ///     storageConfig: NFTStorageConfig(
    ///         provider: NFTStorageProvider.nftStorage,
    ///         apiKey: "eyJhbGciOiJIUzI1NiIsI.................cYOwssdZgiYaug4aF8ZrvMBdkTASojWGU"
    ///     )
    /// ) { result, error in
    ///     print(result ?? error)
    /// }
    /// ```
    ///
    /// - Returns: `TransactionReceiptData` receipt
    public func nftMint(
         tokenId: String,
         supplyAccountId: String,
         supplyPrivateKey: String,
         file: String,
         metadata: [String: String],
         storageConfig: NFTStorageConfig,
         completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void
     ) {
         let completionKey = getCompletionKey("nftMint")
         var metadataJson = "{}"
         var storageConfigJson = "{}"
         let encoder = JSONEncoder()
         do {
             let metadataJsonData = try encoder.encode(metadata)
             metadataJson = String(data: metadataJsonData, encoding: .utf8) ?? "{}"
             
             let storageConfigJsonData = try encoder.encode(storageConfig)
             storageConfigJson = String(data: storageConfigJsonData, encoding: .utf8) ?? "{}"
         } catch {
             print("Error encoding storageConfig to JSON: \(error)")
         }

         performRequest(
             completionKey: completionKey,
             js: "nftMint('\(esc(tokenId))', '\(esc(supplyAccountId))', '\(esc(supplyPrivateKey))', '\(esc(file))', \(metadataJson), \(storageConfigJson), '\(completionKey)')",
             decodeType: TransactionReceiptResponse.self,
             completion: completion
         )
     }

    /// Method to clean-up webView
    public func cleanup() {
        if webView != nil {
            webView!.configuration.userContentController.removeScriptMessageHandler(forName: "bladeMessageHandler")
            webView!.removeFromSuperview()
            webView!.navigationDelegate = nil
            webView!.uiDelegate = nil

            // Set webView to nil
            webView = nil
        }

        webViewInitialized = false
        deferCompletions = [:]
        initCompletion = nil
        apiKey = nil
        dAppCode = nil
    }

    // MARK: - Private methods 🔒

    private func performRequest<T>(
        completionKey: String,
        js: String,
        decodeType: T.Type,
        completion: @escaping (T.DataType?, BladeJSError?) -> Void
    ) where T: Response, T.DataType: Decodable {
        deferCompletion(forKey: completionKey) { data, error in
            if error != nil {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(decodeType, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        do {
            try executeJS("bladeSdk.\(js)")
        } catch let error as NSError {
            print(error)
            completion(nil, BladeJSError(name: "Blade executeJS error", reason: error.description))
        }
    }

    private func executeJS(_ script: String) throws {
        guard webViewInitialized else {
            print("Error while executing JS, webview not loaded")
            throw SwiftBladeError.initError("Error while executing JS, webview not loaded")
        }
        webView!.evaluateJavaScript(script)
    }

    private func deferCompletion(forKey: String, completion: @escaping (_ result: Data?, _ error: BladeJSError?) -> Void) {
        deferCompletions.updateValue(completion, forKey: forKey)
    }

    // method to escape single quotes. Shortname for inline use and readability
    private func esc(_ string: String) -> String {
        return string.replacingOccurrences(of: "'", with: "\\'")
    }

    private func initWebView() {
        // removing old webView if exist
        if webView != nil {
            webView!.configuration.userContentController.removeScriptMessageHandler(forName: "bladeMessageHandler")
            webView!.removeFromSuperview()
            webView!.navigationDelegate = nil
            webView!.uiDelegate = nil

            // Set webView to nil
            webView = nil
        }

        // Setting up and loading webview
        webView = WKWebView()

        if bladeEnv == .CI && network == .TESTNET {
            if #available(iOS 16.4, *) {
                // self.webView!.isInspectable = true
            }
        }
        webView!.navigationDelegate = self
        
        
        guard let resourceBundleURL = Bundle(for: SwiftBlade.self).url(forResource: "SwiftBlade_SwiftBlade", withExtension: "bundle")
            else { fatalError("SwiftBlade_SwiftBlade.bundle not found!") }

        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access SwiftBlade_SwiftBlade.bundle!") }
        
        if let url = resourceBundle.url(forResource: "index", withExtension: "html") {
            webView!.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        webView!.configuration.userContentController.add(self, name: "bladeMessageHandler")
    }

    private func initBladeSdkJS() throws {
        let completionKey = getCompletionKey("initBladeSdkJS")
        performRequest(
            completionKey: completionKey,
            js: "init('\(esc(apiKey!))', '\(esc(network.rawValue.lowercased()))', '\(esc(dAppCode!))',  '\(visitorId)', '\(bladeEnv)', '\(esc(sdkVersion))', '\(completionKey)')",
            decodeType: InfoResponse.self,
            completion: initCompletion!
        )
    }

    private func getCompletionKey(_ tag: String = "") -> String {
        completionId += 1
        return tag + String(completionId)
    }
}

extension SwiftBlade: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let jsonString = message.body as? String {
            let data = Data(jsonString.utf8)
            do {
                let response = try JSONDecoder().decode(ResultRaw.self, from: data)
                if response.completionKey == nil {
                    throw SwiftBladeError.unknownJsError("Received JS response without completionKey")
                }
                let deferedCompletion = deferCompletions[response.completionKey!]!

                // TODO: fix this hacky way of throwing error on data parse
                if response.error != nil {
                    deferedCompletion(Data("".utf8), response.error!)
                } else {
                    deferedCompletion(data, nil)
                }
            } catch {
                print(error)
                // throw error
            }
        }
    }
}

extension SwiftBlade: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Web-view initialized
        webViewInitialized = true

        // Call initBladeSdkJS and initCompletion after that
        try? initBladeSdkJS()
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // if webview process killed - reload it. Init triggers at WKNavigationDelegate{webView}. Nice 👌
        webView.reload()
        initWebView()
        // to test on simulator run in cli: kill child process of simulator with 'com.apple.WebKit.WebContent' in title
        // `kill $(pgrep -P $(pgrep launchd_sim) 'com.apple.WebKit.WebContent')`
    }
}
