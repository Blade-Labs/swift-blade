# SwiftBlade enums

In this case, `HederaNetwork` has two possible values: `TESTNET` and `MAINNET`. These values are of type `String` and are represented as cases of the enumeration using the `case` keyword.

The `public` keyword indicates that this enumeration can be accessed from outside the module where it is defined.

Overall, this code defines a way to represent the two different network options available for interacting with the Hedera Hashgraph platform: `TESTNET` for testing and development purposes, and `MAINNET` for production use.

```swift
public enum HederaNetwork: String {
    case TESTNET
    case MAINNET
}
```

BladeEnv has two possible values: `Prod` and `CI`. Indicating BladeApi environment. `Prod` for production use and `CI` for testing and development purposes.

```swift
public enum BladeEnv: String {
    case Prod = "Prod"
    case CI = "CI"
}
```