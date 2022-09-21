import WebKit
import os
import Alamofire

public class SwiftBlade: NSObject {
    private let API_BASE_URL = ""
    
    public static let shared = SwiftBlade()
    
    private let webView = WKWebView()
    private var webViewInitialized = false    
    private var deferCompletions: [String: (_ result: Data) -> Void] = [:]
    private var initCompletion: (() -> Void)?

    private var apiKey: String? = nil
    private let uuid = UUID().uuidString
        
    private override init () {
        super.init()
    }
    
    // MARK: - It's init time 🎬
    public func initialize(_ apiKey: String, completion: @escaping () -> Void) {
        guard !webViewInitialized else {
            print("Error while doing double init of SwiftBlade")
            fatalError()
        }
        // Setting up API ket and completion handler
        self.apiKey = apiKey
        self.initCompletion = completion
        
        // Setting up and loading webview
        self.webView.navigationDelegate = self
        if let url = Bundle.module.url(forResource: "index", withExtension: "html") {
            self.webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "bladeMessageHandler")
    }
    
    // MARK: - Public methods 📢
    public func setNetwork(_ network: String) throws {
        try? executeJS("JSWrapper.SDK.setNetwork('\(network)')")
    }
    
    public func getBalance(_ id: String, completion: @escaping (_ result: BalanceDataResponse) -> Void) throws {
        let completionKey = "getBalance"
        deferCompletion(key: completionKey) { data in
            do {
                let response = try JSONDecoder().decode(BalanceResponse.self, from: data)
                completion(response.data)
            } catch let error as NSError {
                print(error)
                fatalError("ERROR")
            }
        }
        
        let script = "JSWrapper.SDK.getBalance('\(id)', '\(completionKey)')"
        try? executeJS(script)
    }
    
    public func transferHbars(accountId: String, accountPrivateKey: String, receiverId: String, amount: Int, completion: @escaping (_ result: TransferDataResponse) -> Void) throws {
        let completionKey = "transferHbars"
        deferCompletion(key: completionKey) { data in
            do {
                let response = try JSONDecoder().decode(TransferResponse.self, from: data)
                completion(response.data)
            } catch let error as NSError {
                print(error)
                fatalError("ERROR")
            }
        }
        
        let script = "JSWrapper.SDK.transferHbars('\(accountId)', '\(accountPrivateKey)', '\(receiverId)', '\(amount)', '\(completionKey)')"
        try? executeJS(script)
    }
    
    public func createHederaAccount(completion: @escaping (_ result: String) -> Void) throws {
        // Step 1. Generate mnemonice and public / private key
        let completionKey = "generateKeys"
        deferCompletion(key: completionKey) { (result) in
            // Step 2. Confirm with server side
//            let params: Parameters = [
//                "publicKey": result["publicKey"]!,
//            ]
            
            // TODO: implementation of API calls TBD
//            completion("yo")

            //            AF.request(self.API_BASE_URL + "url", method: .post, parameters: params).responseData { response in
//                // Step 3. Receive confirmation send all the keys back
//
//                //TODO
//                completion(result)
//            }
        }
        let script = "JSWrapper.SDK.generateKeys('\(completionKey)')"
        try? executeJS(script)
    }
    
    public func getPrivateKeyStringFromMnemonic (menmonic: String, completion: @escaping (_ result: PrivateKeyDataResponse) -> Void) throws {
        let completionKey = "getPrivateKeyStringFromMnemonic"
        deferCompletion(key: completionKey) { data in
            do {
                let response = try JSONDecoder().decode(PrivateKeyResponse.self, from: data)
                completion(response.data)
            } catch let error as NSError {
                print(error)
                fatalError("ERROR")
            }
        }
        
        let script = "JSWrapper.SDK.getPrivateKeyStringFromMnemonic('\(menmonic)', '\(completionKey)')"
        try? executeJS(script)
    }
    
    // MARK: - Private methods 🔒
    private func executeJS (_ script: String) throws {
        guard webViewInitialized else {
            print("Error while executing JS, webview not loaded")
            fatalError()
        }
        webView.evaluateJavaScript(script)
    }
    
    private func deferCompletion (key: String, completion: @escaping (_ result: Data) -> Void) {
        deferCompletions.updateValue(completion, forKey: key)
    }
}

extension SwiftBlade: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let jsonString = message.body as? String {
            // TODO: remove json debug logger
            print(jsonString)
            let data = Data(jsonString.utf8)
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                if (response.completionKey == nil) {
                    throw SwiftBladeError.unknownJsError("Received JS response without completionKey")
                }
                if (response.error != nil) {
                    throw SwiftBladeError.jsResponseError("Received error from JS: \(response.error)")
                }
                let deferedCompletion = deferCompletions[response.completionKey!]!
                deferedCompletion(data)
            } catch let error as NSError {
                print(error)
                
            }
        }
    }
}

extension SwiftBlade: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Web-view initialized
        webViewInitialized = true
        
        // Call completion after webview is loaded
        self.initCompletion?()
    }
}

// MARK: - JS wrapper response types
struct Response: Codable {
    var completionKey: String?
    var error: [String: String]?
}

struct CreatedAccountResponse: Codable {
    var completionKey: String
    var data: CreatedAccountDataResponse
    var error: [String: String]?
}

struct BalanceResponse: Codable {
    var completionKey: String
    var data: BalanceDataResponse
    var error: [String: String]?
}

struct PrivateKeyResponse: Codable {
    var completionKey: String
    var data: PrivateKeyDataResponse
    var error: [String: String]?
}

struct TransferResponse: Codable {
    var completionKey: String
    var data: TransferDataResponse
    var error: [String: String]?
}

public struct CreatedAccountDataResponse: Codable {
    public var seedPhrase: String
    public var publicKey: String
    public var privateKey: String
    public var accountId: String
}

public struct BalanceDataResponse: Codable {
    public var hbars: String
    public var tokens: [BalanceDataResponseToken]
}

public struct BalanceDataResponseToken: Codable {
    public var balance: String
    public var decimals: Int
    public var tokenId: String
}

public struct PrivateKeyDataResponse: Codable {
    public var privateKey: String
}

public struct TransferDataResponse: Codable {
    public var nodeId: String
    public var transactionHash: String
    public var transactionId: String
}

// MARK: - SwiftBladeError
public enum SwiftBladeError: Error {
    case jsResponseError(String)
    case unknownJsError(String)
}
