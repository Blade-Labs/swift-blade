# SwiftBlade errors

```swift
public enum SwiftBladeError: Error {
    case unknownJsError(String)
    case apiError(String)
}
```

In this case, `SwiftBladeError` has two possible cases, both of which conform to the `Error` protocol, indicating that they represent errors that can be thrown during the execution of a program.

The first case, `unknownJsError`, takes a `String` parameter and is used to represent an error that occurred while executing JavaScript code. The associated `String` value provides additional information about the error.

The second case, `apiError`, also takes a `String` parameter and is used to represent an error that occurred while interacting with an API. Again, the associated `String` value provides additional information about the error.

By defining these cases as part of an enumeration, code that interacts with the `SwiftBladeError` type can use Swift's pattern matching syntax to handle errors in a structured way.

```swift
public struct BladeJSError: Error, Codable {
    public var name: String
    public var reason: String
}
```

In this case, `BladeJSError` has two properties, both of which are of type `String`. The `name` property represents the name of the JavaScript error that occurred, while the `reason` property provides additional information about the error.

The struct also conforms to two protocols: `Error` and `Codable`. By conforming to `Error`, this struct indicates that it represents an error that can be thrown during the execution of a program. By conforming to `Codable`, it indicates that it can be encoded and decoded to and from JSON format.

<pre class="language-swift"><code class="lang-swift"><strong>extension BladeJSError: LocalizedError {
</strong>    public var errorDescription: String? {
        return NSLocalizedString("\(self.name): \(self.reason)", comment: self.reason);
    }
}
</code></pre>

The implementation of `errorDescription` constructs a localized `String` using the `NSLocalizedString` function. The localized `String` consists of the `name` and `reason` properties of the `BladeJSError` instance, separated by a colon and a space.

The `comment` parameter of the `NSLocalizedString` function is set to the `reason` property of the `BladeJSError` instance. This parameter provides additional context about the error message for localization purposes.

By conforming to `LocalizedError` and implementing `errorDescription`, this extension allows Swift programs to provide localized descriptions of errors that occur while interacting with JavaScript code via the `BladeJSError` struct.
