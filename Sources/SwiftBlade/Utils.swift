import FingerprintPro
import Foundation

func getRemoteConfig(dAppCode: String, sdkVersion: String, bladeEnv: BladeEnv) async throws -> RemoteConfig {
    var url: URL? = nil
    var fallbackConfig = RemoteConfig(
        fpApiKey: "",
        fpSubdomain: "https://identity.bladewallet.io"
    )
    switch bladeEnv {
    case .Prod:
        url = URL(string: "https://dapi.prod.bladewallet.io/dapi/public/v8/sdk/config")!
        fallbackConfig.fpApiKey = "Li4RsMbgPldpOVfWjnaF"
        throw SwiftBladeError.initError("Prod env not available for v1.0.0 now")
    case .CI:
        url = URL(string: "https://dapi.bld-dev.bladewallet.io/dapi/public/v8/sdk/config")!
        fallbackConfig.fpApiKey = "0fScXqpS7MzpCl9HgEsI"
    }

    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.setValue(dAppCode, forHTTPHeaderField: "X-DAPP-CODE")
    request.setValue(sdkVersion, forHTTPHeaderField: "X-SDK-VERSION")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, _) = try await URLSession.shared.data(for: request)
    do {
        return try JSONDecoder().decode(RemoteConfig.self, from: data)
    } catch {
        print(error)
        return fallbackConfig
    }
}

func getVisitorId(_ remoteConfig: RemoteConfig) async throws -> String {
    do {
        let customDomain: Region = .custom(domain: remoteConfig.fpSubdomain)
        let configuration = Configuration(apiKey: remoteConfig.fpApiKey, region: customDomain)
        let client = FingerprintProFactory.getInstance(configuration)
        let visitorId = try await client.getVisitorId()
        return visitorId
    } catch {
        let configuration = Configuration(apiKey: remoteConfig.fpApiKey)
        let client = FingerprintProFactory.getInstance(configuration)
        let visitorId = try await client.getVisitorId()
        return visitorId
    }
}
