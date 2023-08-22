# Initialization

It's init time 🎬 Initialization of Swift blade
During initialization, Swift Blade will fetch all required data from Blade servers, and will initialize the webView with all required data, including visitorId.

### Parameters:

* `apiKey`: api key given by Blade team
* `dAppCode`: dAppCode given by Blade team
* `network`: `.TESTNET` or `.MAINNET`
* `bladeEnv`: `.CI` or `.PROD`
* `force`: if true, will force initialization of webView even if it was already initialized
* `completion`: completion closure that will be executed after webView is fully loaded and rendered, and result with `InfoData` type

```swift
public func initialize(apiKey: String, dAppCode: String, network: HederaNetwork, bladeEnv: BladeEnv, force: Bool = false, completion: @escaping (_ result: InfoData?, _ error: BladeJSError?) -> Void) {
    guard !webViewInitialized || force else {
        print("Error while doing double init of SwiftBlade")
        fatalError()
    }
    // Setting up all required properties
    self.initCompletion = completion
    self.apiKey = apiKey
    self.dAppCode = dAppCode
    self.network = network
    self.bladeEnv = bladeEnv

    Task {
        do {
            self.remoteConfig = try await getRemoteConfig(network: network, dAppCode: dAppCode, sdkVersion: self.sdkVersion, bladeEnv: bladeEnv)
            self.visitorId = try await getVisitorId(fingerPrintApiKey: remoteConfig!.fpApiKey)
            DispatchQueue.main.async {
                self.initWebView()
            }
        } catch {
            completion(nil, BladeJSError.init(name: "Init failed", reason: "\(error)"));
        }
    }
}
```
