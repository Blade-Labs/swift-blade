import WebKit
import os
import Alamofire
import BigInt

public class SwiftBlade: NSObject {
    public static let shared = SwiftBlade()

    private let webView = WKWebView()
    private var webViewInitialized = false
    private var deferCompletions: [String: (_ result: Data?, _ error: BladeJSError?) -> Void] = [:]
    private var initCompletion: (() -> Void)?
    private var completionId: Int = 0

    private var apiKey: String? = nil
    private let uuid = UUID().uuidString
    private var network: HederaNetwork = .TESTNET
    private var dAppCode: String?

    // MARK: - It's init time 🎬
    /// Initialization of Swift blade
    ///
    /// - Parameters:
    ///   - apiKey: api key given by Blade tea
    ///   - network: .TESTNET or .MAINNET
    ///   - completion: completion closure that will be executed after webview is fully loaded and rendered.
    public func initialize(apiKey: String, dAppCode: String, network: HederaNetwork , completion: @escaping () -> Void = { }) {
        guard !webViewInitialized else {
            print("Error while doing double init of SwiftBlade")
            fatalError()
        }
        // Setting up all required properties
        self.initCompletion = completion
        self.apiKey = apiKey
        self.dAppCode = dAppCode
        self.network = network

        // Setting up and loading webview
        self.webView.navigationDelegate = self
        if let url = Bundle.module.url(forResource: "index", withExtension: "html") {
            self.webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "bladeMessageHandler")
    }

    // MARK: - Public methods 📢
    /// Get balances by Hedera id (address)
    ///
    /// - Parameters:
    ///   - id: Hedera id (address), example: 0.0.112233
    ///   - completion: result with BalanceDataResponse type
    public func getBalance(_ id: String, completion: @escaping (_ result: BalanceDataResponse?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getBalance");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(BalanceResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.getBalance('\(id)', '\(completionKey)')")
    }

    /// Method to execure Hbar transfers from current account to receiver
    ///
    /// - Parameters:
    ///   - accountId: sender
    ///   - accountPrivateKey: sender's private key to sign transfer transaction
    ///   - receiverId: receiver
    ///   - amount: amount
    ///   - completion: result with TransferDataResponse type
    public func transferHbars(accountId: String, accountPrivateKey: String, receiverId: String, amount: Decimal, completion: @escaping (_ result: TransferDataResponse?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("transferHbars");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(TransferResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.transferHbars('\(accountId)', '\(accountPrivateKey)', '\(receiverId)', '\(amount)', '\(completionKey)')")
    }

    /// Method to execure token transfers from current account to receiver
    ///
    /// - Parameters:
    ///   - tokenId: token
    ///   - accountId: sender
    ///   - accountPrivateKey: sender's private key to sign transfer transaction
    ///   - receiverId: receiver
    ///   - amount: amount
    ///   - completion: result with TransferDataResponse type
    public func transferTokens(tokenId: String, accountId: String, accountPrivateKey: String, receiverId: String, amount: Decimal, completion: @escaping (_ result: TransferDataResponse?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("transferTokens");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(TransferResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.transferTokens('\(tokenId)', '\(accountId)', '\(accountPrivateKey)', '\(receiverId)', '\(amount)', '\(completionKey)')")
    }

    /// Method to create Hedera account
    ///
    /// - Parameter completion: result with CreatedAccountDataResponse type
    public func createHederaAccount(completion: @escaping (_ result: CreatedAccountDataResponse?, _ error: BladeJSError?) -> Void) {
        // Step 1. Generate mnemonice and public / private key
        let completionKey = getCompletionKey("createAccount");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(CreatedAccountResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.createAccount('\(completionKey)')")
    }

    /// Method to delete Hedera account
    ///
    /// - Parameters:
    ///   - deleteAccountId: account to delete - id
    ///   - deletePrivateKey: account to delete - private key
    ///   - transferAccountId: The ID of the account to transfer the remaining funds to.
    ///   - operatorAccountId: operator account Id
    ///   - operatorPrivateKey: operator account private key
    ///   - completion: result with TransactionReceipt type
    public func deleteHederaAccount(deleteAccountId: String, deletePrivateKey: String, transferAccountId: String, operatorAccountId: String, operatorPrivateKey: String, completion: @escaping (_ result: TransactionReceipt?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("deleteHederaAccount");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(TransactionReceiptResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.deleteAccount('\(deleteAccountId)', '\(deletePrivateKey)', '\(transferAccountId)', '\(operatorAccountId)', '\(operatorPrivateKey)',  '\(completionKey)')")
    }

    /// Restore public and private key by seed phrase
    ///
    /// - Parameters:
    ///   - menmonic: seed phrase
    ///   - lookupNames: lookup for accounts
    ///   - completion: result with PrivateKeyDataResponse type
    public func getKeysFromMnemonic (menmonic: String, lookupNames: Bool = false, completion: @escaping (_ result: PrivateKeyDataResponse?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getKeysFromMnemonic");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(PrivateKeyResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.getKeysFromMnemonic('\(menmonic)', \(lookupNames), '\(completionKey)')")
    }

    /// Sign message with private key
    ///
    /// - Parameters:
    ///   - messageString: message in base64 string
    ///   - privateKey: private key string
    ///   - completion: result with SignMessageDataResponse type
    public func sign (messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageDataResponse?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("sign");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(SignMessageResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.sign('\(messageString)', '\(privateKey)', '\(completionKey)')")
    }

    /// Verify message signature with public key
    ///
    /// - Parameters:
    ///   - messageString: message in base64 string
    ///   - signature: hex-encoded signature string
    ///   - publicKey: public key string
    ///   - completion: result with SignMessageDataResponse type
    public func signVerify(messageString: String, signature: String, publicKey: String, completion: @escaping (_ result: SignVerifyMessageDataResponse?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("signVerify");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(SignVerifyMessageResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.signVerify('\(messageString)', '\(signature)', '\(publicKey)', '\(completionKey)')")
    }


    public func createContractFunctionParameters() -> ContractFunctionParameters {
        return ContractFunctionParameters();
    }

    /// Method to call smart-contract function from current account
    ///
    /// - Parameters:
    ///   - contractId: contract
    ///   - functionName: function name
    ///   - params: function arguments
    ///   - accountId: sender
    ///   - accountPrivateKey: sender's private key to sign transfer transaction
    ///   - gas: gas amount for transaction (default 100000)
    ///   - completion: result with TransactionReceipt type
    public func contractCallFunction(contractId: String, functionName: String, params: ContractFunctionParameters, accountId: String, accountPrivateKey: String, gas: Int = 100000, completion: @escaping (_ result: TransactionReceipt?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("contractCallFunction");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(TransactionReceiptResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        let paramsEncoded = params.encode();
        executeJS("bladeSdk.contractCallFunction('\(contractId)', '\(functionName)', '\(paramsEncoded)', '\(accountId)', '\(accountPrivateKey)', \(gas), '\(completionKey)')")
    }

    /// Sign message with private key
    ///
    /// - Parameters:
    ///   - messageString: message in base64 string
    ///   - privateKey: private key string
    ///   - completion: result with SignMessageDataResponse type
    public func hethersSign(messageString: String, privateKey: String, completion: @escaping (_ result: SignMessageDataResponse?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("hethersSign");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(SignMessageResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.hethersSign('\(messageString)', '\(privateKey)', '\(completionKey)')")
    }

    /// Method to split signature into v-r-s
    ///
    /// - Parameters:
    ///   - signature: signature string "0x21fbf0696......"
    ///   - completion: result with SplitedSignature type
    public func splitSignature(signature: String, completion: @escaping (_ result: SplitedSignature?, _ error: BladeJSError?) -> Void ) {
        let completionKey = getCompletionKey("splitSignature");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(SplitedSignatureResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.splitSignature('\(signature)', '\(completionKey)')")
    }

    /// Method to split signature into v-r-s
    ///
    /// - Parameters:
    ///   - params: params generated with ContractFunctionParameters
    ///   - accountPrivateKey: account private key string
    ///   - completion: result with SplitedSignature type
    public func getParamsSignature(params: ContractFunctionParameters, accountPrivateKey: String, completion: @escaping (_ result: SplitedSignature?, _ error: BladeJSError?) -> Void ) {
        let completionKey = getCompletionKey("getParamsSignature");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(SplitedSignatureResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        let paramsEncoded = params.encode();
        executeJS("bladeSdk.getParamsSignature('\(paramsEncoded)', '\(accountPrivateKey)', '\(completionKey)')")
    }

    /// Method to get transactions history
    ///
    /// - Parameters:
    ///   - accountId: accountId of history
    ///   - nextPage: link from response to load next page of history
    ///   - completion: result with TransactionsHistory type
    public func getTransactions(accountId: String, transactionType: String, nextPage: String = "", completion: @escaping (_ result: TransactionsHistory?, _ error: BladeJSError?) -> Void) {
        let completionKey = getCompletionKey("getTransactions");
        deferCompletion(forKey: completionKey) { (data, error) in
            if (error != nil) {
                return completion(nil, error)
            }
            do {
                let response = try JSONDecoder().decode(TransactionsHistoryResponse.self, from: data!)
                completion(response.data, nil)
            } catch let error as NSError {
                print(error)
                completion(nil, BladeJSError(name: "Error", reason: "\(error)"))
            }
        }
        executeJS("bladeSdk.getTransactions('\(accountId)', '\(transactionType)', '\(nextPage)', '\(completionKey)')")
    }

    // MARK: - Private methods 🔒
    private func executeJS (_ script: String) {
        guard webViewInitialized else {
            print("Error while executing JS, webview not loaded")
            fatalError()
        }
        webView.evaluateJavaScript(script)
    }

    private func deferCompletion (forKey: String, completion: @escaping (_ result: Data?, _ error: BladeJSError?) -> Void) {
        deferCompletions.updateValue(completion, forKey: forKey)
    }

    private func initBladeSdkJS() throws {
        let completionKey = getCompletionKey("initBladeSdkJS");
        deferCompletion(forKey: completionKey) { (data, error) in
            self.initCompletion!()
        }
        executeJS("bladeSdk.init('\(apiKey!)', '\(network.rawValue.lowercased())', '\(dAppCode!)', '\(uuid)', '\(completionKey)')");
    }

    private func getCompletionKey(_ tag: String = "") -> String {
        completionId += 1;
        return tag + String(completionId);
    }
}

public class ContractFunctionParameters: NSObject {
    private var params: [ContractFunctionParameter] = []

    public func addAddress(value: String) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "address", value: [value]));
        return self;
    }

    public func addAddressArray(value: [String]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "address[]", value: value));
        return self;
    }

    public func addBytes32(value: [UInt8]) -> ContractFunctionParameters {
        do {
            let encodedValue = try JSONEncoder().encode(value).base64EncodedString();
            params.append(ContractFunctionParameter(type: "bytes32", value: [encodedValue]));
        } catch let error {
            print(error)
        }
        return self
    }

    public func addUInt8(value: UInt8) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint8", value: [String(value)]));
        return self
    }

    public func addUInt64(value: UInt64) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint64", value: [String(value)]));
        return self
    }

    public func addUInt64Array(value: [UInt64]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint64[]", value: value.map{ String($0)} ));
        return self
    }

    public func addInt64(value: Int64) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "int64", value: [String(value)]));
        return self
    }

    public func addUInt256(value: BigUInt) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint256", value: [String(value)]));
        return self;
    }

    public func addUInt256Array(value: [BigUInt]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint256[]", value: value.map{ String($0)} ));
        return self;
    }

    public func addTuple(value: ContractFunctionParameters) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "tuple", value: [value.encode()]));
        return self;
    }

    public func addTupleArray(value: [ContractFunctionParameters]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "tuple[]", value: value.map{$0.encode()}));
        return self;
    }

    public func addString(value: String) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "string", value: [value]));
        return self;
    }

    public func addStringArray(value: [String]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "string[]", value: value));
        return self;
    }

    public func encode() -> String {
        do {
            let jsonData = try JSONEncoder().encode(params)
            if let res = String(data: jsonData, encoding: .utf8)?.replacingOccurrences(of: "\\", with: "\\\\") {
                return res;
            }
        } catch let error {
            print(error)
        }
        return "";
    }
}

extension SwiftBlade: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let jsonString = message.body as? String {
            let data = Data(jsonString.utf8)
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                if (response.completionKey == nil) {
                    throw SwiftBladeError.unknownJsError("Received JS response without completionKey")
                }
                let deferedCompletion = deferCompletions[response.completionKey!]!

                // TODO: fix this hacky way of throwing error on data parse
                if (response.error != nil) {
                    deferedCompletion(Data("".utf8), response.error!)
                } else {
                    deferedCompletion(data, nil)
                }
            } catch let error {
                print(error)
                fatalError()
            }
        }
    }
}

extension SwiftBlade: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Web-view initialized
        webViewInitialized = true

        // Call initBladeSdkJS and initCompletion after that
        try? self.initBladeSdkJS()
    }
}

// MARK: - JS wrapper response types
struct Response: Codable {
    var completionKey: String?
    var error: BladeJSError?
}

struct CreatedAccountResponse: Codable {
    var completionKey: String
    var data: CreatedAccountDataResponse
}

struct BalanceResponse: Codable {
    var completionKey: String
    var data: BalanceDataResponse
}

struct PrivateKeyResponse: Codable {
    var completionKey: String
    var data: PrivateKeyDataResponse
}

struct TransferResponse: Codable {
    var completionKey: String
    var data: TransferDataResponse
}

struct AccountAPIResponse: Codable {
    var id: String
    var network: String
    var associationPresetTokenStatus: String
    var transactionBytes: String
}

struct SignMessageResponse: Codable {
    var completionKey: String
    var data: SignMessageDataResponse
}

struct SignVerifyMessageResponse: Codable {
    var completionKey: String
    var data: SignVerifyMessageDataResponse
}

public struct CreatedAccountDataResponse: Codable {
    public var seedPhrase: String
    public var publicKey: String
    public var privateKey: String
    public var accountId: String
    public var evmAddress: String
}

public struct BalanceDataResponse: Codable {
    public var hbars: Double
    public var tokens: [BalanceDataResponseToken]
}

public struct BalanceDataResponseToken: Codable {
    public var balance: Double
    public var tokenId: String
}

public struct PrivateKeyDataResponse: Codable {
    public var privateKey: String
    public var publicKey: String
    public var accounts: [String]
    public var evmAddress: String
}

public struct TransferDataResponse: Codable {
    public var nodeId: String
    public var transactionHash: String
    public var transactionId: String
}

public struct SignMessageDataResponse: Codable {
    public var signedMessage: String
}

public struct SignVerifyMessageDataResponse: Codable {
    public var valid: Bool
}

public struct ContractFunctionParameter: Encodable {
    public var type: String
    public var value: [String] = []
}

struct TransactionReceiptResponse: Codable {
    var completionKey: String
    var data: TransactionReceipt
}

public struct TransactionReceipt: Codable {
    public var status: String
    public var contractId: String?
    public var topicSequenceNumber: String?
    public var totalSupply: String?
    public var serials: [String]?
}

struct SplitedSignatureResponse: Codable {
    var completionKey: String
    var data: SplitedSignature
}

public struct SplitedSignature: Codable {
    public var v: Int
    public var r: String
    public var s: String
}

struct TransactionsHistoryResponse: Codable {
    var completionKey: String
    var data: TransactionsHistory
}

public struct TransactionsHistory: Codable {
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
