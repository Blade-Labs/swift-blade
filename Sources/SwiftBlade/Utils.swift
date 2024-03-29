import FingerprintPro
import Foundation

func getRemoteConfig(network: HederaNetwork, dAppCode: String, sdkVersion: String, bladeEnv: BladeEnv) async throws -> RemoteConfig {
    var url: URL? = nil
    var fallbackConfig = RemoteConfig(fpApiKey: "")
    switch bladeEnv {
    case .Prod:
        url = URL(string: "https://rest.prod.bladewallet.io/openapi/v7/sdk/config")!
        fallbackConfig.fpApiKey = "Li4RsMbgPldpOVfWjnaF"
    case .CI:
        url = URL(string: "https://api.bld-dev.bladewallet.io/openapi/v7/sdk/config")!
        fallbackConfig.fpApiKey = "0fScXqpS7MzpCl9HgEsI"
    }

    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.setValue(network.rawValue.uppercased(), forHTTPHeaderField: "X-NETWORK")
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

func getVisitorId(fingerPrintApiKey: String) async throws -> String {
    do {
        let customDomain: Region = .custom(domain: "https://identity.bladewallet.io")
        let configuration = Configuration(apiKey: fingerPrintApiKey, region: customDomain)
        let client = FingerprintProFactory.getInstance(configuration)
        let visitorId = try await client.getVisitorId()
        return visitorId
    } catch {
        throw error
    }
}
