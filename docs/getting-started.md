# Getting Started

## Requirements

* **Swift v5.3+**
* **iOS 13+ (2019)**

## Install

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/Blade-Labs/swift-blade.git", from: "0.6.39")
]
```

```podfile
pod 'SwiftBlade', :git => 'git@github.com:Blade-Labs/swift-blade.git', :tag => '0.6.39'
```

{% hint style="info" %}
**Note:** See ["Adding Package Dependencies to Your App"](https://developer.apple.com/documentation/swift\_packages/adding\_package\_dependencies\_to\_your\_app) for help on adding a swift package to your project.
{% endhint %}

## Usage

During initialization, Swift Blade will fetch all required data from Blade servers, and will initialize the webView with all required data, including visitorId.

```swift
import SwiftBlade

SwiftBlade.shared.initialize(apiKey: "API_KEY", dAppCode: "dAppCode", network: .TESTNET, bladeEnv: .Prod) { (result, error) in
    print("init complete")
    print(result ?? error)
}

// Get balance by hedera id
SwiftBlade.shared.getBalance(addressTextField.text!) { (result, error) in
  print(result)
}
```
