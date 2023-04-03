# Initialization

It's init time 🎬 Initialization of Swift blade

* Parameters:
* `apiKey`: api key given by Blade team
* `dAppCode`: dAppCode given by Blade team
* network: `.TESTNET` or `.MAINNET`
* completion: completion closure that will be executed after webView is fully loaded and rendered.

```swift
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
```
