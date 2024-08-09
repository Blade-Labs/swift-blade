# Getting Started

## Requirements

* **Swift v5.3+**
* **iOS 13+ (2019)**

## Install

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/Blade-Labs/swift-blade.git", from: "1.0.0")
]
```

```podfile
pod 'SwiftBlade', :git => 'git@github.com:Blade-Labs/swift-blade.git', :tag => '1.0.0'
```

{% hint style="info" %}
**Note:** See ["Adding Package Dependencies to Your App"](https://developer.apple.com/documentation/swift\_packages/adding\_package\_dependencies\_to\_your\_app) for help on adding a swift package to your project.
{% endhint %}

## Usage

During initialization, Swift Blade will fetch all required data from Blade servers, and will initialize the webView with all required data, including visitorId.

```swift
import SwiftBlade

SwiftBlade.shared.initialize(apiKey: "API_KEY", chainId: .HEDERA_TESTNET, dAppCode: "dAppCode", bladeEnv: .Prod) { (result, error) in
    // ready to use SwiftBlade
    print(result ?? error)
}

// Get balance by hedera id
SwiftBlade.shared.getBalance("0.0.8235") { (result, error) in
    print(result)
}
```

