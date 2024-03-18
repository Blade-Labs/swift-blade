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
    private let sdkVersion: String = "Swift@0.6.17"

    // MARK: - It's init time 🎬

    /// Initialization of Swift blade
    ///
    /// - Parameters:
    ///   - apiKey: api key given by Blade team
    ///   - dAppCode: dAppCode given by Blade team
    ///   - network: `.TESTNET` or `.MAINNET`
    ///   - bladeEnv: `.CI` or `.PROD`
    ///   - force: if true, will force initialization of webView even if it was already initialized
    ///   - completion: completion closure that will be executed after webView is fully loaded and rendered, and result with `InfoData` type
    public func initialize(apiKey: String, dAppCode: String, network: HederaNetwork, bladeEnv: BladeEnv, force: Bool = false, completion: @escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void) {
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
                self.visitorId = UserDefaults.standard.string(forKey: "visitorId") ?? ""
                if self.visitorId == "" {
                    self.remoteConfig = try await getRemoteConfig(network: network, dAppCode: dAppCode, sdkVersion: self.sdkVersion, bladeEnv: bladeEnv)
                    self.visitorId = try await getVisitorId(fingerPrintApiKey: remoteConfig!.fpApiKey)
                    UserDefaults.standard.set(self.visitorId, forKey: "visitorId")
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

    /// Get SDK info
    ///
    /// - Parameters:
    ///   - completion: result with `InfoData` type
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
    ///
    /// - Parameters:
    ///   - search: CoinGecko coinId, or address in one of the coin platforms or `hbar` (default, alias for `hedera-hashgraph`)
    ///   - completion: result with CoinInfoData type
    public func getCoinPrice(_ search: String, completion: @escaping (_ result: CoinInfoData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getCoinPrice")
        performRequest(
            completionKey: completionKey,
            js: "getCoinPrice('\(esc(search))', '\(completionKey)')",
            decodeType: CoinInfoResponse.self,
            completion: completion
        )
    }

    /// Method to execute Hbar transfers from current account to receiver
    ///
    /// - Parameters:
    ///   - accountId: sender
    ///   - accountPrivateKey: sender's private key to sign transfer transaction
    ///   - receiverId: receiver
    ///   - amount: amount
    ///   - memo: memo (limited to 100 characters)
    ///   - completion: result with `TransactionReceiptData` type
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
    ///   - tokenId: token
    ///   - accountId: sender
    ///   - accountPrivateKey: sender's private key to sign transfer transaction
    ///   - receiverId: receiver
    ///   - amountOrSerial: amount of fungible tokens to send (with token-decimals correction) on NFT serial number
    ///   - memo: memo (limited to 100 characters)
    ///   - freeTransfer: for tokens configured for this dAppCode on Blade backend
    ///   - completion: result with `TransactionReceiptData` type
    public func transferTokens(tokenId: String, accountId: String, accountPrivateKey: String, receiverId: String, amountOrSerial: Decimal, memo: String, freeTransfer: Bool = true, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("transferTokens")
        performRequest(
            completionKey: completionKey,
            js: "transferTokens('\(esc(tokenId))', '\(esc(accountId))', '\(esc(accountPrivateKey))', '\(esc(receiverId))', '\(amountOrSerial)', '\(esc(memo))', \(freeTransfer), '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }

    /// Method to create Hedera account
    ///
    /// - Parameters:
    ///   - privateKey: optional field if you need specify account key (hex encoded privateKey with DER-prefix)
    ///   - deviceId: unique device id (advanced security feature, required only for some dApps)
    ///   - completion: result with CreatedAccountData type
    public func createHederaAccount(privateKey: String, deviceId: String, completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("createAccount")
        performRequest(
            completionKey: completionKey,
            js: "createAccount('\(esc(privateKey))', '\(esc(deviceId))', '\(completionKey)')",
            decodeType: CreatedAccountResponse.self,
            completion: completion
        )
    }

    /// Method to get pending Hedera account
    ///
    /// - Parameters
    ///   - transactionId: can be received on createHederaAccount method, when busy network is busy, and account creation added to queue
    ///   - seedPhrase: returned from createHederaAccount method, required for updating keys and proper response &#x20;
    ///   - completion: result with `CreatedAccountData` type

    public func getPendingAccount(transactionId: String, seedPhrase: String, completion: @escaping (_ result: CreatedAccountData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getPendingAccount")
        performRequest(
            completionKey: completionKey,
            js: "getPendingAccount('\(esc(transactionId))', '\(esc(seedPhrase))', '\(completionKey)')",
            decodeType: CreatedAccountResponse.self,
            completion: completion
        )
    }

    /// Method to delete Hedera account
    ///
    /// - Parameters:
    ///   - deleteAccountId: account to delete - id
    ///   - deletePrivateKey: account to delete - private key
    ///   - transferAccountId: The ID of the account to transfer the remaining funds to.
    ///   - operatorAccountId: operator account Id
    ///   - operatorPrivateKey: operator account private key
    ///   - completion: result with TransactionReceiptData type
    public func deleteHederaAccount(deleteAccountId: String, deletePrivateKey: String, transferAccountId: String, operatorAccountId: String, operatorPrivateKey: String, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("deleteHederaAccount")
        performRequest(
            completionKey: completionKey,
            js: "deleteAccount('\(esc(deleteAccountId))', '\(esc(deletePrivateKey))', '\(esc(transferAccountId))', '\(esc(operatorAccountId))', '\(esc(operatorPrivateKey))',  '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }

    /// Get account evmAddress and calculated evmAddress from public key
    ///
    /// - Parameters:
    ///   - accountId: accountId
    ///   - completion: result with AccountInfoData type
    public func getAccountInfo(accountId: String, completion: @escaping (_ result: AccountInfoData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getAccountInfo")
        performRequest(
            completionKey: completionKey,
            js: "getAccountInfo('\(esc(accountId))', '\(completionKey)')",
            decodeType: AccountInfoResponse.self,
            completion: completion
        )
    }

    /// Get Node list
    ///
    /// - Parameters:
    ///   - completion: result with NodesData type
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
    ///   - accountId: Hedera account id
    ///   - accountPrivateKey account private key (DER encoded hex string)
    ///   - nodeId node id to stake to. If negative or null, account will be unstaked
    ///   - completion: result with TransactionReceiptData type
    public func stakeToNode(accountId: String, accountPrivateKey: String, nodeId: Int, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("stakeToNode")
        performRequest(
            completionKey: completionKey,
            js: "stakeToNode('\(esc(accountId))', '\(esc(accountPrivateKey))', \(nodeId), '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }
    
    /// Restore public and private key by seed phrase
    ///
    /// - Parameters:
    ///   - mnemonic: seed phrase
    ///   - lookupNames: lookup for accounts
    ///   - completion: result with PrivateKeyData type
    public func getKeysFromMnemonic(mnemonic: String, lookupNames: Bool = false, completion: @escaping (_ result: PrivateKeyData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getKeysFromMnemonic")
        performRequest(
            completionKey: completionKey,
            js: "getKeysFromMnemonic('\(esc(mnemonic))', \(lookupNames), '\(completionKey)')",
            decodeType: PrivateKeyResponse.self,
            completion: completion
        )
    }

    /// Sign message with private key
    ///
    /// - Parameters:
    ///   - messageString: message in base64 string
    ///   - privateKey: private key string
    ///   - completion: result with SignMessageData type
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
    ///   - messageString: message in base64 string
    ///   - signature: hex-encoded signature string
    ///   - publicKey: public key string
    ///   - completion: result with SignVerifyMessageData type
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
    public func createContractFunctionParameters() -> ContractFunctionParameters {
        return ContractFunctionParameters()
    }

    /// Method to call smart-contract function
    ///
    /// - Parameters:
    ///   - contractId: contract id
    ///   - functionName: contract function name
    ///   - params: function arguments (instance of ContractFunctionParameters)
    ///   - accountId: sender account id
    ///   - accountPrivateKey: sender's private key to sign transfer transaction
    ///   - gas: gas amount for transaction (default 100000)
    ///   - bladePayFee: blade pay fee, otherwise fee will be payed from sender accountId
    ///   - completion: result with TransactionReceiptData type
    public func contractCallFunction(contractId: String, functionName: String, params: ContractFunctionParameters, accountId: String, accountPrivateKey: String, gas: Int = 100_000, bladePayFee: Bool, completion: @escaping (_ result: TransactionReceiptData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("contractCallFunction")
        performRequest(
            completionKey: completionKey,
            js: "contractCallFunction('\(esc(contractId))', '\(esc(functionName))', '\(params.encode())', '\(esc(accountId))', '\(esc(accountPrivateKey))', \(gas), \(bladePayFee), '\(completionKey)')",
            decodeType: TransactionReceiptResponse.self,
            completion: completion
        )
    }

    /// Method to call smart-contract query
    ///
    /// - Parameters:
    ///   -  contractId: contract id
    ///   -  functionName: contract function name
    ///   -  params: function arguments (instance of ContractFunctionParameters)
    ///   -  accountId: sender account id
    ///   -  accountPrivateKey: sender's private key to sign transfer transaction
    ///   -  gas: gas amount for transaction (default 100000)
    ///   -  bladePayFee: blade pay fee, otherwise fee will be pay from sender accountId
    ///   -  returnTypes: array of return types, e.g. ["string", "int32"]
    ///   -  completion: result with ContractQueryData type
    public func contractCallQueryFunction(contractId: String, functionName: String, params: ContractFunctionParameters, accountId: String, accountPrivateKey: String, gas: Int = 100_000, bladePayFee: Bool, returnTypes: [String], completion: @escaping (_ result: ContractQueryData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("contractCallQueryFunction")
        performRequest(
            completionKey: completionKey,
            js: "contractCallQueryFunction('\(esc(contractId))', '\(esc(functionName))', '\(params.encode())', '\(esc(accountId))', '\(esc(accountPrivateKey))', \(gas), \(bladePayFee), [\(returnTypes.map { "'\(esc($0))'" }.joined(separator: ","))], '\(completionKey)')",
            decodeType: ContractQueryResponse.self,
            completion: completion
        )
    }

    /// Sign message with private key (ethers lib)
    ///
    /// - Parameters:
    ///   - messageString: message in base64 string
    ///   - privateKey: private key string
    ///   - completion: result with SignMessageData type
    public func ethersSign(messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("ethersSign")
        performRequest(
            completionKey: completionKey,
            js: "ethersSign('\(esc(messageString))', '\(esc(privateKey))', '\(completionKey)')",
            decodeType: SignMessageResponse.self,
            completion: completion
        )
    }

    /// Method to split signature into v-r-s
    ///
    /// - Parameters:
    ///   - signature: signature string "0x21fbf0696......"
    ///   - completion: result with SplitSignatureData type
    public func splitSignature(signature: String, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("splitSignature")
        performRequest(
            completionKey: completionKey,
            js: "splitSignature('\(esc(signature))', '\(completionKey)')",
            decodeType: SplitSignatureResponse.self,
            completion: completion
        )
    }

    /// Method to split signature into v-r-s
    ///
    /// - Parameters:
    ///   - params: function arguments (instance of ContractFunctionParameters)
    ///   - accountPrivateKey: account private key string
    ///   - completion: result with SplitSignatureData type
    public func getParamsSignature(params: ContractFunctionParameters, accountPrivateKey: String, completion: @escaping (_ result: SplitSignatureData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getParamsSignature")
        performRequest(
            completionKey: completionKey,
            js: "getParamsSignature('\(params.encode())', '\(esc(accountPrivateKey))', '\(completionKey)')",
            decodeType: SplitSignatureResponse.self,
            completion: completion
        )
    }

    /// Method to get transactions history
    ///
    /// - Parameters:
    ///   - accountId: accountId of history
    ///   - transactionType: filter by type of transaction
    ///   - nextPage: link from response to load next page of history
    ///   - transactionsLimit: limit of transactions to load
    ///   - completion: result with TransactionsHistoryData type
    public func getTransactions(accountId: String, transactionType: String, nextPage: String = "", transactionsLimit: Int = 10, completion: @escaping (_ result: TransactionsHistoryData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getTransactions")
        performRequest(
            completionKey: completionKey,
            js: "getTransactions('\(esc(accountId))', '\(esc(transactionType))', '\(esc(nextPage))', '\(transactionsLimit)', '\(completionKey)')",
            decodeType: TransactionsHistoryResponse.self,
            completion: completion
        )
    }

    /// Method to get C14 url for payment
    ///
    /// - Parameters:
    ///   - asset: USDC, HBAR, KARATE or C14 asset uuid
    ///   - account: receiver account id
    ///   - amount: amount to buy
    ///   - completion: result with IntegrationUrlData type
    public func getC14url(asset: String, account: String, amount: String, completion: @escaping (_ result: IntegrationUrlData?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getC14url")
        performRequest(
            completionKey: completionKey,
            js: "getC14url('\(esc(asset))', '\(esc(account))', '\(esc(amount))', '\(completionKey)')",
            decodeType: IntegrationUrlResponse.self,
            completion: completion
        )
    }

    /// Get swap quotes from different services
    ///
    /// - Parameters:
    ///   - sourceCode: name (HBAR, KARATE, other token code)
    ///   - sourceAmount: amount to swap, buy or sell
    ///   - targetCode: name (HBAR, KARATE, USDC, other token code)
    ///   - strategy: one of enum CryptoFlowServiceStrategy (Buy, Sell, Swap)
    ///   - completion: result with SwapQuotesData type
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
    ///   - completion: result with IntegrationUrlData type
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
        let completionKey = getCompletionKey("getTradeUrl")
        performRequest(
            completionKey: completionKey,
            js: "getTradeUrl('\(strategy.rawValue)', '\(esc(accountId))', '\(esc(sourceCode))', \(sourceAmount), '\(esc(targetCode))', \(slippage), '\(esc(serviceId))', '\(completionKey)')",
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
   
    
    /// Associate token to account
    ///
    /// - Parameters:
    ///   -  tokenId: token id
    ///   -   accountId: account id to associate token
    ///   -   accountPrivateKey: account private key
    ///   -  completion: callback function, with result of TransactionReceiptData or BladeJSError

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
        
        
        do {
            print(Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "JS"))
        } catch {
            print(error)
        }
        
        if let mainBundleURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) {
            for url in mainBundleURLs {
                print(url.lastPathComponent)
            }
        }
        
//        if let url = Bundle.module.url(forResource: "index", withExtension: "html") {
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView!.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            print("bundle url \(url)")
        } else {
            print("NO bundle url")
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
