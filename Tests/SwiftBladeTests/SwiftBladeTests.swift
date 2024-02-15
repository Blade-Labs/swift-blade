@testable import SwiftBlade
import XCTest

final class SwiftBladeTests: XCTestCase {
    var swiftBlade: SwiftBlade!
    var apiKey = "ygUgCzRrsvhWmb3dsLcDpGnJpSZ4tk8hACmZqg9WngpuQYKdnD5m8FjfPV3XVUeB"
    var apiKeyMainnet = "IYyE75dUez7fMxfXzIP8Hw4CvhTURhbte3QNVhFDTSbV97ycfq5NrqEGrzAThVeg"
    var dAppCode = "unitysdktest"
    var network = HederaNetwork.TESTNET
    var env = BladeEnv.CI
    var accountId = "0.0.1443"
    var accountIdEd25519 = "0.0.1430"
    var accountId2 = "0.0.1767"
    var contractId = "0.0.2215872"
    var tokenId = "0.0.2216053"
    var privateKeyHex = "3030020100300706052b8104000a04220420ebccecef769bb5597d0009123a0fd96d2cdbe041c2a2da937aaf8bdc8731799b"
    var privateKeyHexEd25519 = "302e020100300506032b6570042204201c1fc6ab4f5937bf9261cd3d1f1609cb5f30838d018207b476ff50d97ef8e2a5"
    var publicKeyHex = "302d300706052b8104000a032200029dc73991b0d9cdbb59b2cd0a97a0eaff6de801726cb39804ea9461df6be2dd30"
    let originalMessage = "hello"
    let tokenName = "Swift Token SDK"
    let tokenSymbol = "Arr!"

    override func setUp() {
        super.setUp()
        swiftBlade = SwiftBlade.shared

        // Create an expectation to wait for the initialization to complete.
        let initializationExpectation = XCTestExpectation(description: "Initialization should complete")

        // Call swiftBlade.initialize and fulfill the expectation in its completion handler.
        swiftBlade.initialize(apiKey: apiKey, dAppCode: dAppCode, network: network, bladeEnv: env, force: false) { result, error in
            XCTAssertNil(error, "Initialization should not produce an error")
            XCTAssertNotNil(result, "Initialization should produce a result")

            initializationExpectation.fulfill()
        }

        wait(for: [initializationExpectation], timeout: 10.0) // Adjust the timeout as needed
    }

    override func tearDown() {
        swiftBlade.cleanup()
        swiftBlade = nil
        super.tearDown()
    }

    func testGetInfo() {
        let expectation = XCTestExpectation(description: "GetInfo method should complete without error")
        swiftBlade.getInfo { result, error in
            XCTAssertNil(error, "GetInfo should not produce an error")
            XCTAssertNotNil(result, "GetInfo should produce a result")

            if let infoData = result as InfoData? {
                XCTAssertEqual(infoData.apiKey, self.apiKey, "InfoData should have the expected apiKey")
                XCTAssertEqual(infoData.dAppCode, self.dAppCode, "InfoData should have the expected dAppCode")
                XCTAssertEqual(infoData.network.uppercased(), self.network.rawValue, "InfoData should have the expected network")
                XCTAssertNotNil(infoData.visitorId, "InfoData should have visitorId")
                XCTAssertEqual(infoData.sdkEnvironment, self.env.rawValue, "InfoData should have the expected bladeEnv")
                XCTAssertEqual(infoData.sdkVersion, "Swift@0.6.16", "InfoData should have the expected sdkVersion")
            } else {
                XCTFail("Result should be of type InfoData")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetBalance() {
        let expectation = XCTestExpectation(description: "GetBalance should complete")

        swiftBlade.getBalance(accountId) { result, error in
            XCTAssertNil(error, "GetBalance should not produce an error")
            XCTAssertNotNil(result, "GetBalance should produce a result")

            if let balanceResponse = result as BalanceData? {
                XCTAssertGreaterThanOrEqual(balanceResponse.hbars, 1000.0, "Hbars balance should be greater than or equal to 0.0")
                XCTAssertNotNil(balanceResponse.tokens, "Tokens balance should not be nil")
                XCTAssertGreaterThanOrEqual(balanceResponse.tokens.count, 1, "some token balances")
            } else {
                XCTFail("Result should be of type BalanceResponse")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testGetCoinList() {
        let expectation = XCTestExpectation(description: "getCoinList should complete")

        swiftBlade.getCoinList { result, error in
            XCTAssertNil(error, "getCoinList should not produce an error")
            XCTAssertNotNil(result, "getCoinList should produce a result")

            if let coinListData = result {
                XCTAssertTrue(coinListData.coins.count > 0, "Coin list should not be empty")
                let coin = coinListData.coins[0]
                XCTAssertNotNil(coin.id, "Coin should have an id")
                XCTAssertNotNil(coin.symbol, "Coin should have a symbol")
                XCTAssertNotNil(coin.name, "Coin should have a name")
                XCTAssertTrue(coin.platforms.count >= 0, "Coin should have platforms")
            } else {
                XCTFail("Result should be of type YourResponseType")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testGetCoinPrice() {
        let expectation = XCTestExpectation(description: "getCoinPrice should complete")

        swiftBlade.getCoinPrice("Hbar") { result, error in
            XCTAssertNil(error, "getCoinPrice should not produce an error")
            XCTAssertNotNil(result, "getCoinPrice should produce a result")

            if let coinPriceData = result {
                XCTAssertNotNil(coinPriceData.priceUsd, "Coin price should have a USD value")
                XCTAssertNotNil(coinPriceData.coin, "Coin price should have a coin object")

                let coin = coinPriceData.coin
                XCTAssertEqual(coin.id, "hedera-hashgraph", "Coin id should match")
                XCTAssertEqual(coin.symbol, "hbar", "Coin symbol should match")
                XCTAssertEqual(coin.market_data.current_price["usd"], coinPriceData.priceUsd, "Coin market data should match")
            } else {
                XCTFail("Result should be of type YourResponseType")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testTransferHbars() {
        let expectation = XCTestExpectation(description: "TransferHbars should complete")

        let amount: Decimal = 7.0
        let memo = "transferHbars tests Swift"

        swiftBlade.transferHbars(
            accountId: accountId,
            accountPrivateKey: privateKeyHex,
            receiverId: accountId2,
            amount: amount,
            memo: memo
        ) { result, error in
            XCTAssertNil(error, "TransferHbars should not produce an error")
            XCTAssertNotNil(result, "TransferHbars should produce a result")

            if let transferData = result as TransactionReceiptData? {
                XCTAssertNotNil(transferData.status, "TransferData should have status")
                XCTAssertNil(transferData.contractId, "TransferData should have contractId")
                XCTAssertNotNil(transferData.topicSequenceNumber, "TransferData should have topicSequenceNumber")
                XCTAssertNotNil(transferData.totalSupply, "TransferData should have totalSupply")
                XCTAssertNotNil(transferData.serials, "TransferData should have serials")
            } else {
                XCTFail("Result should be of type TransferData")
            }

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testTransferTokens() {
        let expectationPaid = XCTestExpectation(description: "TransferTokens should complete (paid)")
        let expectationFree = XCTestExpectation(description: "TransferTokens should complete (free)")

        let amount: Decimal = 5.0

        swiftBlade.transferTokens(
            tokenId: tokenId,
            accountId: accountId,
            accountPrivateKey: privateKeyHex,
            receiverId: accountId2,
            amountOrSerial: amount,
            memo: "transferTokens tests Swift (paid)",
            freeTransfer: false
        ) { result, error in
            XCTAssertNil(error, "TransferTokens should not produce an error")
            XCTAssertNotNil(result, "TransferTokens should produce a result")

            if let transferData = result as TransactionReceiptData? {
                XCTAssertNotNil(transferData.status, "TransferData should have status")
                XCTAssertNil(transferData.contractId, "TransferData should have contractId")
                XCTAssertNotNil(transferData.topicSequenceNumber, "TransferData should have topicSequenceNumber")
                XCTAssertNotNil(transferData.totalSupply, "TransferData should have totalSupply")
                XCTAssertNotNil(transferData.serials, "TransferData should have serials")
            } else {
                XCTFail("Result should be of type TransferData")
            }

            expectationPaid.fulfill()
        }

        swiftBlade.transferTokens(
            tokenId: tokenId,
            accountId: accountId,
            accountPrivateKey: privateKeyHex,
            receiverId: accountId2,
            amountOrSerial: amount,
            memo: "transferTokens tests Swift (free)",
            freeTransfer: true
        ) { result, error in
            XCTAssertNil(error, "TransferTokens should not produce an error")
            XCTAssertNotNil(result, "TransferTokens should produce a result")
            expectationFree.fulfill()
        }
        wait(for: [expectationPaid, expectationFree], timeout: 20.0)
    }

    func testCreateHederaAccount() {
        let expectation = XCTestExpectation(description: "CreateHederaAccount should complete")
        let deviceId = ""
        swiftBlade.createHederaAccount(deviceId: deviceId) { result, error in
            XCTAssertNil(error, "CreateHederaAccount should not produce an error")
            XCTAssertNotNil(result, "CreateHederaAccount should produce a result")

            if let createdAccountData = result {
                XCTAssertNotNil(createdAccountData.seedPhrase, "Created account should have a seed phrase")
                XCTAssertNotNil(createdAccountData.publicKey, "Created account should have a publicKey")
                XCTAssertNotNil(createdAccountData.privateKey, "Created account should have a privateKey")
                XCTAssertNotNil(createdAccountData.accountId, "Created account should have a accountId")
                XCTAssertNotNil(createdAccountData.evmAddress, "Created account should have a evmAddress")
                XCTAssertNil(createdAccountData.transactionId, "Created account should not have a transactionId")
                XCTAssertEqual(createdAccountData.status, "SUCCESS", "Created account should have a 'SUCCESS' status")
                XCTAssertNotNil(createdAccountData.status, "Created account should have a status")
                XCTAssertNil(createdAccountData.queueNumber, "Created account should have not a queueNumber")
            } else {
                XCTFail("Result should be of type CreatedAccountData")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30.0)
    }

    func testDeleteHederaAccount() {
        let expectation = XCTestExpectation(description: "DeleteHederaAccount should complete")

        swiftBlade.createHederaAccount(deviceId: "") { result, error in
            XCTAssertNotNil(result, "CreateHederaAccount should produce a result")

            if let createdAccountData = result {
                self.swiftBlade.deleteHederaAccount(
                    deleteAccountId: createdAccountData.accountId!,
                    deletePrivateKey: createdAccountData.privateKey,
                    transferAccountId: self.accountId,
                    operatorAccountId: self.accountId,
                    operatorPrivateKey: self.privateKeyHex
                ) { result, error in
                    XCTAssertNil(error, "DeleteHederaAccount should not produce an error")
                    XCTAssertNotNil(result, "DeleteHederaAccount should produce a result")

                    if let transactionReceiptData = result {
                        XCTAssertEqual(transactionReceiptData.status, "SUCCESS", "TransactionReceiptData should have a 'SUCCESS' status")
                    } else {
                        XCTFail("Result should be a String (transaction ID)")
                    }

                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 40.0)
    }

    func testGetAccountInfo() {
        let expectation = XCTestExpectation(description: "GetAccountInfo should complete")

        swiftBlade.getAccountInfo(accountId: accountId) { result, error in
            XCTAssertNil(error, "GetAccountInfo should not produce an error")
            XCTAssertNotNil(result, "GetAccountInfo should produce a result")

            if let accountInfoData = result {
                XCTAssertEqual(accountInfoData.accountId, self.accountId, "Account ID should match")
                XCTAssertNotNil(accountInfoData.evmAddress, "Created account should have a evmAddress")
                XCTAssertNotNil(accountInfoData.calculatedEvmAddress, "Created account should have a calculatedEvmAddress")
                XCTAssertNotNil(accountInfoData.publicKey, "Created account should have a publicKey")
                XCTAssertNotNil(accountInfoData.stakingInfo, "Created account should have a stakingInfo")
                XCTAssertNotNil(accountInfoData.stakingInfo.pendingReward, "Created account stakingInfo should have a pendingReward")
            } else {
                XCTFail("Result should be of type AccountInfoData")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
    func testStakeAccount() {
        let expectationNodeList = XCTestExpectation(description: "GetNodeList should complete")
        let expectationStakeAccount = XCTestExpectation(description: "StakeAccount should complete")

        swiftBlade.getNodeList() { result, error in
            XCTAssertNil(error, "GetAccountInfo should not produce an error")
            XCTAssertNotNil(result, "GetAccountInfo should produce a result")
            
            if let nodeListData = result {
                XCTAssertNotNil(nodeListData.nodes, "NodeList should have a nodes")
                XCTAssertGreaterThan(nodeListData.nodes.count, 0, "NodeList should have some nodes")
                XCTAssertNotNil(nodeListData.nodes[0].description, "NodeInfo should have a description")
                XCTAssertNotNil(nodeListData.nodes[0].max_stake, "NodeInfo should have a max_stake")
                XCTAssertNotNil(nodeListData.nodes[0].min_stake, "NodeInfo should have a min_stake")
                XCTAssertNotNil(nodeListData.nodes[0].node_id, "NodeInfo should have a node_id")
            } else {
                XCTFail("Result should be of type NodesData")
            }

            expectationNodeList.fulfill()
            
            
            self.swiftBlade.stakeToNode(accountId: self.accountId, accountPrivateKey: self.privateKeyHex, nodeId: -1) { result, error in
                XCTAssertNil(error, "GetAccountInfo should not produce an error")
                XCTAssertNotNil(result, "GetAccountInfo should produce a result")

                if let transferData = result as TransactionReceiptData? {
                    XCTAssertNotNil(transferData.status, "TransferData should have status")
                    XCTAssertNil(transferData.contractId, "TransferData should have contractId")
                    XCTAssertNotNil(transferData.topicSequenceNumber, "TransferData should have topicSequenceNumber")
                    XCTAssertNotNil(transferData.totalSupply, "TransferData should have totalSupply")
                    XCTAssertNotNil(transferData.serials, "TransferData should have serials")
                } else {
                    XCTFail("Result should be of type TransferData")
                }

                expectationStakeAccount.fulfill()
            }
        }
        wait(for: [expectationNodeList, expectationStakeAccount], timeout: 30.0)
    }

    func testGetKeysFromMnemonic() {
        let expectation = XCTestExpectation(description: "GetKeysFromMnemonic should complete")

        let mnemonic = "limb claim next what faint place nut prevent fragile begin betray physical"

        swiftBlade.getKeysFromMnemonic(mnemonic: mnemonic, lookupNames: true) { result, error in
            XCTAssertNil(error, "GetKeysFromMnemonic should not produce an error")
            XCTAssertNotNil(result, "GetKeysFromMnemonic should produce a result")

            if let privateKeyData = result {
                XCTAssertEqual(privateKeyData.privateKey, "3030020100300706052b8104000a04220420cb76c87175f403d1d9b8e0b1a58724bd2cee0e2489826d771634da957799119b", "PrivateKeyData should have a valid private key")
                XCTAssertEqual(privateKeyData.publicKey, "302d300706052b8104000a0322000215aa00fb07e73439fc628cac2ba43694d6170e7444b9b121a58847ca57766f77", "PrivateKeyData should have a valid public key")
                XCTAssertEqual(privateKeyData.evmAddress, "0xb96be10ca97df55ec5d42929884f65b34520699a", "PrivateKeyData should have a valid evmAddress")
                XCTAssertEqual(privateKeyData.accounts.count, 1, "PrivateKeyData should have a valid number of accountIds")
                XCTAssertEqual(privateKeyData.accounts[0], "0.0.3419337", "PrivateKeyData should have a valid accountId")
            } else {
                XCTFail("Result should be of type PrivateKeyData")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testSign() {
        let expectation = XCTestExpectation(description: "Sign should complete")
        if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            swiftBlade.sign(messageString: base64encodedString, privateKey: privateKeyHex) { result, error in
                XCTAssertNil(error, "Sign should not produce an error")
                XCTAssertNotNil(result, "Sign should produce a result")

                if let signMessageData = result {
                    XCTAssertNotNil(signMessageData.signedMessage, "Signed message should not be nil")
                    XCTAssertEqual(signMessageData.signedMessage, "27cb9d51434cf1e76d7ac515b19442c619f641e6fccddbf4a3756b14466becb6992dc1d2a82268018147141fc8d66ff9ade43b7f78c176d070a66372d655f942", "Signed message should be valid signature")
                } else {
                    XCTFail("Result should be of type SignMessageData")
                }

                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }

    func testSignVerify() {
        let expectation = XCTestExpectation(description: "SignVerify should complete")

        if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            swiftBlade.sign(messageString: base64encodedString, privateKey: privateKeyHex) { signResult, signError in
                XCTAssertNil(signError, "Sign should not produce an error")
                XCTAssertNotNil(signResult, "Sign should produce a result")

                if let signMessageData = signResult {
                    let signedMessage = signMessageData.signedMessage
                    // Verify the signed message here
                    self.swiftBlade.signVerify(messageString: base64encodedString, signature: signedMessage, publicKey: self.publicKeyHex) { verifyResult, verifyError in
                        XCTAssertNil(verifyError, "Verify should not produce an error")
                        XCTAssertNotNil(verifyResult, "Verify should produce a result")

                        if let verifyMessageData = verifyResult {
                            XCTAssertTrue(verifyMessageData.valid, "Message should be valid after verification")
                        } else {
                            XCTFail("Verify result should be of type SignVerifyMessageData")
                        }
                        expectation.fulfill()
                    }
                } else {
                    XCTFail("Sign result should be of type SignMessageData")
                    expectation.fulfill()
                }
            }
            wait(for: [expectation], timeout: 20.0)
        }
    }

    func testCreateContractFunctionParameters() {
        let expectation = XCTestExpectation(description: "CreateContractFunctionParameters should complete")

        let tuple0 = SwiftBlade.shared.createContractFunctionParameters()
            .addInt64(value: 16)
            .addInt64(value: 32)

        let tuple1 = SwiftBlade.shared.createContractFunctionParameters()
            .addInt64(value: 5)
            .addInt64(value: 10)

        let tuple2 = SwiftBlade.shared.createContractFunctionParameters()
            .addInt64(value: 50)
            .addTupleArray(value: [tuple0, tuple1])

        let parameters = swiftBlade.createContractFunctionParameters()
            .addString(value: "Hello, Backend")
            .addBytes32(value: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F])
            .addAddressArray(value: ["0.0.48738539", "0.0.48738538", "0.0.48738537"])
            .addAddress(value: "0.0.48850466")
            .addAddress(value: "0.0.499326")
            .addAddress(value: "0.0.48801688")
            .addInt64(value: 1)
            .addUInt8(value: 123)
            .addUInt64Array(value: [1, 2, 3])
            .addUInt256Array(value: [1, 2, 3])
            .addTuple(value: tuple1)
            .addTuple(value: tuple2)
            .addTupleArray(value: [tuple0, tuple1])
            .addTupleArray(value: [tuple2, tuple2])
            .addAddress(value: "0.0.12345")
            .addUInt64(value: 56_784_645_645)
            .addUInt256(value: 12345)

        XCTAssertEqual(parameters.encode(), "W3sidHlwZSI6InN0cmluZyIsInZhbHVlIjpbIkhlbGxvLCBCYWNrZW5kIl19LHsidHlwZSI6ImJ5dGVzMzIiLCJ2YWx1ZSI6WyJXekFzTVN3eUxETXNOQ3cxTERZc055dzRMRGtzTVRBc01URXNNVElzTVRNc01UUXNNVFVzTVRZc01UY3NNVGdzTVRrc01qQXNNakVzTWpJc01qTXNNalFzTWpVc01qWXNNamNzTWpnc01qa3NNekFzTXpGZCJdfSx7InR5cGUiOiJhZGRyZXNzW10iLCJ2YWx1ZSI6WyIwLjAuNDg3Mzg1MzkiLCIwLjAuNDg3Mzg1MzgiLCIwLjAuNDg3Mzg1MzciXX0seyJ0eXBlIjoiYWRkcmVzcyIsInZhbHVlIjpbIjAuMC40ODg1MDQ2NiJdfSx7InR5cGUiOiJhZGRyZXNzIiwidmFsdWUiOlsiMC4wLjQ5OTMyNiJdfSx7InR5cGUiOiJhZGRyZXNzIiwidmFsdWUiOlsiMC4wLjQ4ODAxNjg4Il19LHsidHlwZSI6ImludDY0IiwidmFsdWUiOlsiMSJdfSx7InR5cGUiOiJ1aW50OCIsInZhbHVlIjpbIjEyMyJdfSx7InR5cGUiOiJ1aW50NjRbXSIsInZhbHVlIjpbIjEiLCIyIiwiMyJdfSx7InR5cGUiOiJ1aW50MjU2W10iLCJ2YWx1ZSI6WyIxIiwiMiIsIjMiXX0seyJ0eXBlIjoidHVwbGUiLCJ2YWx1ZSI6WyJXM3NpZEhsd1pTSTZJbWx1ZERZMElpd2lkbUZzZFdVaU9sc2lOU0pkZlN4N0luUjVjR1VpT2lKcGJuUTJOQ0lzSW5aaGJIVmxJanBiSWpFd0lsMTlYUT09Il19LHsidHlwZSI6InR1cGxlIiwidmFsdWUiOlsiVzNzaWRIbHdaU0k2SW1sdWREWTBJaXdpZG1Gc2RXVWlPbHNpTlRBaVhYMHNleUowZVhCbElqb2lkSFZ3YkdWYlhTSXNJblpoYkhWbElqcGJJbGN6YzJsa1NHeDNXbE5KTmtsdGJIVmtSRmt3U1dsM2FXUnRSbk5rVjFWcFQyeHphVTFVV1dsWVdEQnpaWGxLTUdWWVFteEphbTlwWVZjMU1FNXFVV2xNUTBveVdWZDRNVnBUU1RaWGVVbDZUV2xLWkdaV01EMGlMQ0pYTTNOcFpFaHNkMXBUU1RaSmJXeDFaRVJaTUVscGQybGtiVVp6WkZkVmFVOXNjMmxPVTBwa1psTjROMGx1VWpWalIxVnBUMmxLY0dKdVVUSk9RMGx6U1c1YWFHSklWbXhKYW5CaVNXcEZkMGxzTVRsWVVUMDlJbDE5WFE9PSJdfSx7InR5cGUiOiJ0dXBsZVtdIiwidmFsdWUiOlsiVzNzaWRIbHdaU0k2SW1sdWREWTBJaXdpZG1Gc2RXVWlPbHNpTVRZaVhYMHNleUowZVhCbElqb2lhVzUwTmpRaUxDSjJZV3gxWlNJNld5SXpNaUpkZlYwPSIsIlczc2lkSGx3WlNJNkltbHVkRFkwSWl3aWRtRnNkV1VpT2xzaU5TSmRmU3g3SW5SNWNHVWlPaUpwYm5RMk5DSXNJblpoYkhWbElqcGJJakV3SWwxOVhRPT0iXX0seyJ0eXBlIjoidHVwbGVbXSIsInZhbHVlIjpbIlczc2lkSGx3WlNJNkltbHVkRFkwSWl3aWRtRnNkV1VpT2xzaU5UQWlYWDBzZXlKMGVYQmxJam9pZEhWd2JHVmJYU0lzSW5aaGJIVmxJanBiSWxjemMybGtTR3gzV2xOSk5rbHRiSFZrUkZrd1NXbDNhV1J0Um5Oa1YxVnBUMnh6YVUxVVdXbFlXREJ6WlhsS01HVllRbXhKYW05cFlWYzFNRTVxVVdsTVEwb3lXVmQ0TVZwVFNUWlhlVWw2VFdsS1pHWldNRDBpTENKWE0zTnBaRWhzZDFwVFNUWkpiV3gxWkVSWk1FbHBkMmxrYlVaelpGZFZhVTlzYzJsT1UwcGtabE40TjBsdVVqVmpSMVZwVDJsS2NHSnVVVEpPUTBselNXNWFhR0pJVm14SmFuQmlTV3BGZDBsc01UbFlVVDA5SWwxOVhRPT0iLCJXM3NpZEhsd1pTSTZJbWx1ZERZMElpd2lkbUZzZFdVaU9sc2lOVEFpWFgwc2V5SjBlWEJsSWpvaWRIVndiR1ZiWFNJc0luWmhiSFZsSWpwYklsY3pjMmxrU0d4M1dsTkpOa2x0YkhWa1JGa3dTV2wzYVdSdFJuTmtWMVZwVDJ4emFVMVVXV2xZV0RCelpYbEtNR1ZZUW14SmFtOXBZVmMxTUU1cVVXbE1RMG95V1ZkNE1WcFRTVFpYZVVsNlRXbEtaR1pXTUQwaUxDSlhNM05wWkVoc2QxcFRTVFpKYld4MVpFUlpNRWxwZDJsa2JVWnpaRmRWYVU5c2MybE9VMHBrWmxONE4wbHVValZqUjFWcFQybEtjR0p1VVRKT1EwbHpTVzVhYUdKSVZteEphbkJpU1dwRmQwbHNNVGxZVVQwOUlsMTlYUT09Il19LHsidHlwZSI6ImFkZHJlc3MiLCJ2YWx1ZSI6WyIwLjAuMTIzNDUiXX0seyJ0eXBlIjoidWludDY0IiwidmFsdWUiOlsiNTY3ODQ2NDU2NDUiXX0seyJ0eXBlIjoidWludDI1NiIsInZhbHVlIjpbIjEyMzQ1Il19XQ==", "Encoded params should be equal this result")
        expectation.fulfill()
        wait(for: [expectation], timeout: 10.0)
    }

    func testContractCallFunction() {
        let expectation = XCTestExpectation(description: "ContractCallFunction should complete")

        let parameters = swiftBlade.createContractFunctionParameters().addString(value: "Hello Swift test")
        swiftBlade.contractCallFunction(
            contractId: contractId, functionName: "set_message", params: parameters, accountId: accountId, accountPrivateKey: privateKeyHex, gas: 1_000_000, bladePayFee: false
        ) { result, error in
            XCTAssertNil(error, "ContractCallFunction should not produce an error")
            XCTAssertNotNil(result, "ContractCallFunction should produce a result")

            if let transactionReceiptData = result {
                XCTAssertEqual(transactionReceiptData.status, "SUCCESS", "TransactionReceiptData should have a 'SUCCESS' status")
            } else {
                XCTFail("Result should be a String (transaction ID)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testContractCallQueryFunction() {
        let expectation = XCTestExpectation(description: "ContractCallQueryFunction should complete")

        swiftBlade.contractCallQueryFunction(
            contractId: contractId, functionName: "get_message", params: swiftBlade.createContractFunctionParameters(), accountId: accountId, accountPrivateKey: privateKeyHex, gas: 150_000, bladePayFee: false, returnTypes: ["string", "int32"]
        ) { result, error in
            XCTAssertNil(error, "ContractCallQueryFunction should not produce an error")
            XCTAssertNotNil(result, "ContractCallQueryFunction should produce a result")

            if let contractQueryData = result {
                XCTAssertGreaterThan(contractQueryData.gasUsed, 0, "Used gas should be grater than 0")
                XCTAssertEqual(contractQueryData.values.count, 2, "Should return 2 values")
                XCTAssertEqual(contractQueryData.values[0].type, "string", "Should equeal returnTypes")
                XCTAssertEqual(contractQueryData.values[0].value.count > 0, true, "Should be not empty string")
                XCTAssertEqual(contractQueryData.values[1].type, "int32", "Should equeal returnTypes")
            } else {
                XCTFail("Result should be a String (transaction ID)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testEthersSign() {
        let expectation = XCTestExpectation(description: "EthersSign should complete")

        if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            swiftBlade.ethersSign(messageString: base64encodedString, privateKey: privateKeyHex) { result, error in
                XCTAssertNil(error, "EthersSign should not produce an error")
                XCTAssertNotNil(result, "EthersSign should produce a result")

                if let signMessageData = result {
                    XCTAssertNotNil(signMessageData.signedMessage, "Signed message should not be nil")
                    XCTAssertEqual(signMessageData.signedMessage, "0x25de7c26ecfa4f28d8b96a95cf58ea7088a72a66b311c796090cb4c7d58c11217b4a7b174b4c31b90c3babb00958b2120274380404c4f1196abe3614df3741561b", "Signed message should be valid signature")
                } else {
                    XCTFail("Result should be of type SignMessageData")
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
        }
    }

    func testSplitSignature() {
        let expectation = XCTestExpectation(description: "SplitSignature should complete")

        if let base64encodedString = originalMessage.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            swiftBlade.ethersSign(messageString: base64encodedString, privateKey: privateKeyHex) { result, error in
                XCTAssertNil(error, "EthersSign should not produce an error")
                XCTAssertNotNil(result, "EthersSign should produce a result")

                if let signMessageData = result {
                    XCTAssertNotNil(signMessageData.signedMessage, "Signed message should not be nil")
                    XCTAssertEqual(signMessageData.signedMessage, "0x25de7c26ecfa4f28d8b96a95cf58ea7088a72a66b311c796090cb4c7d58c11217b4a7b174b4c31b90c3babb00958b2120274380404c4f1196abe3614df3741561b", "Signed message should be valid signature")

                    self.swiftBlade.splitSignature(signature: signMessageData.signedMessage) { result, error in
                        XCTAssertNil(error, "SplitSignature should not produce an error")
                        XCTAssertNotNil(result, "SplitSignature should produce a result")

                        if let splitSignatureData = result {
                            XCTAssertEqual(splitSignatureData.v, 27, "SplitSignatureData should be valid v")
                            XCTAssertEqual(splitSignatureData.r, "0x25de7c26ecfa4f28d8b96a95cf58ea7088a72a66b311c796090cb4c7d58c1121", "SplitSignatureData should be valid r")
                            XCTAssertEqual(splitSignatureData.s, "0x7b4a7b174b4c31b90c3babb00958b2120274380404c4f1196abe3614df374156", "SplitSignatureData should be valid s")
                        } else {
                            XCTFail("Result should be of type SignMessageData")
                        }

                        expectation.fulfill()
                    }

                } else {
                    XCTFail("Result should be of type SignMessageData")
                }
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }

    func testGetParamsSignature() {
        let expectation = XCTestExpectation(description: "GetParamsSignature should complete")

        let parameters = swiftBlade.createContractFunctionParameters()
            .addAddress(value: accountId)
            .addUInt64Array(value: [300_000, 300_000])
            .addUInt64Array(value: [6])
            .addUInt64Array(value: [2])

        swiftBlade.getParamsSignature(
            params: parameters, accountPrivateKey: privateKeyHex

        ) { result, error in
            XCTAssertNil(error, "GetParamsSignature should not produce an error")
            XCTAssertNotNil(result, "GetParamsSignature should produce a result")

            if let splitSignatureData = result {
                XCTAssertEqual(splitSignatureData.v, 27, "SplitSignatureData should be valid v")
                XCTAssertEqual(splitSignatureData.r, "0x0c6e8f0487709cfc1ebbc41e47ce56aee5cf5bc933a4cd6cb2695b098dbe4ee4", "SplitSignatureData should be valid r")
                XCTAssertEqual(splitSignatureData.s, "0x22d0b6351670c37eb112ebd80123452237cb5c893767510a9356214189f6fe86", "SplitSignatureData should be valid s")
            } else {
                XCTFail("Result should be of type SignMessageData")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testGetTransactions() {
        let expectation = XCTestExpectation(description: "GetTransactions should complete")

        swiftBlade.getTransactions(accountId: accountId, transactionType: "", nextPage: "", transactionsLimit: 5) { result, error in
            XCTAssertNil(error, "GetTransactions should not produce an error")
            XCTAssertNotNil(result, "GetTransactions should produce a result")

            if let transactionsHistoryData = result {
                XCTAssertNotNil(transactionsHistoryData.nextPage, "transactionsHistoryData nextPage should not be nil")
                XCTAssertEqual(transactionsHistoryData.transactions.count, 5, "transactionsHistoryData transactions count should be as in params")
            } else {
                XCTFail("Result should be of type transactionsHistoryData")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetC14url() {
        let expectation = XCTestExpectation(description: "GetC14url should complete")

        swiftBlade.getC14url(asset: "KARATE", account: accountId, amount: "1234") { result, error in
            XCTAssertNil(error, "GetC14url should not produce an error")
            XCTAssertNotNil(result, "GetC14url should produce a result")

            if let integrationUrlData = result {
                XCTAssertEqual(integrationUrlData.url, "https://pay.c14.money/?clientId=00ce2e0a-ee66-4971-a0e9-b9d627d106b0&targetAssetId=057d6b35-1af5-4827-bee2-c12842faa49e&targetAssetIdLock=true&sourceAmount=1234&quoteAmountLock=true&targetAddress=0.0.1443&targetAddressLock=true", "url should be like that")
            } else {
                XCTFail("Result should be of type transactionsHistoryData")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testExchangeGetQuotes() {
        let expectation1 = XCTestExpectation(description: "ExchangeGetQuotes BUY should complete")
        let expectation2 = XCTestExpectation(description: "ExchangeGetQuotes SELL should complete")
        let expectation3 = XCTestExpectation(description: "ExchangeGetQuotes SWAP should complete")

        swiftBlade.initialize(apiKey: apiKeyMainnet, dAppCode: dAppCode, network: HederaNetwork.MAINNET, bladeEnv: env, force: true) { [self] result, error in
            XCTAssertNil(error, "Initialization should not produce an error")
            XCTAssertNotNil(result, "Initialization should produce a result")

            swiftBlade.exchangeGetQuotes(
                sourceCode: "EUR",
                sourceAmount: 50,
                targetCode: "HBAR",
                strategy: CryptoFlowServiceStrategy.BUY
            ) { [self] result, error in
                XCTAssertNil(error, "ExchangeGetQuotes should not produce an error")
                XCTAssertNotNil(result, "ExchangeGetQuotes should produce a result")

                if let quotesData = result {
                    XCTAssertNotNil(quotesData.quotes, "quotesData.quotes should present")
                    XCTAssertGreaterThan(quotesData.quotes.count, 0, "quotesData.quotes should be not empty")
                } else {
                    XCTFail("no quotesData.quotes")
                }

                expectation1.fulfill()

                swiftBlade.exchangeGetQuotes(
                    sourceCode: "USDC",
                    sourceAmount: 30,
                    targetCode: "PHP",
                    strategy: CryptoFlowServiceStrategy.SELL
                ) { [self] result, error in
                    XCTAssertNil(error, "ExchangeGetQuotes should not produce an error")
                    XCTAssertNotNil(result, "ExchangeGetQuotes should produce a result")

                    if let quotesData = result {
                        XCTAssertNotNil(quotesData.quotes, "quotesData.quotes should present")
                        XCTAssertGreaterThan(quotesData.quotes.count, 0, "quotesData.quotes should be not empty")
                    } else {
                        XCTFail("no quotesData.quotes")
                    }

                    expectation2.fulfill()

                    swiftBlade.exchangeGetQuotes(
                        sourceCode: "HBAR",
                        sourceAmount: 5,
                        targetCode: "USDC",
                        strategy: CryptoFlowServiceStrategy.SWAP
                    ) { result, error in
                        XCTAssertNil(error, "ExchangeGetQuotes should not produce an error")
                        XCTAssertNotNil(result, "ExchangeGetQuotes should produce a result")

                        expectation3.fulfill()
                    }
                }
            }
        }

        wait(for: [expectation1, expectation2, expectation3], timeout: 30.0)
    }

    func testSwapTokens() {
        let expectation1 = XCTestExpectation(description: "SwapTokens should complete")
        let expectation2 = XCTestExpectation(description: "SwapTokens should fail")

        swiftBlade.swapTokens(
            accountId: accountIdEd25519,
            accountPrivateKey: privateKeyHexEd25519,
            sourceCode: "USDC",
            sourceAmount: 0.00001,
            targetCode: "HBAR",
            slippage: 0.5,
            serviceId: "saucerswap"
        ) { [self] result, error in
            XCTAssertNil(error, "SwapTokens should not produce an error")
            XCTAssertNotNil(result, "SwapTokens should produce a result")

            if let resultData = result {
                XCTAssertNotNil(resultData.success, "resultData.success should present")
                XCTAssertEqual(resultData.success, true, "resultData.success should be true")
            } else {
                XCTFail("no resultData.success")
            }

            expectation1.fulfill()

            swiftBlade.swapTokens(
                accountId: accountIdEd25519,
                accountPrivateKey: privateKeyHexEd25519,
                sourceCode: "USDC",
                sourceAmount: 0.00001,
                targetCode: "HBAR",
                slippage: 0.5,
                serviceId: "unknown-service"
            ) { result, error in
                XCTAssertNotNil(error, "SwapTokens should produce an error")
                XCTAssertNil(result, "SwapTokens should not produce a result")

                expectation2.fulfill()
            }
        }

        wait(for: [expectation1, expectation2], timeout: 30.0)
    }

    func testGetTradeUrl() {
        let expectation1 = XCTestExpectation(description: "GetTradeUrl should complete")
        let expectation2 = XCTestExpectation(description: "GetTradeUrl should complete")
        let expectation3 = XCTestExpectation(description: "GetTradeUrl should fail")

        swiftBlade.initialize(apiKey: apiKeyMainnet, dAppCode: dAppCode, network: HederaNetwork.MAINNET, bladeEnv: env, force: true) { [self] result, error in
            XCTAssertNil(error, "Initialization should not produce an error")
            XCTAssertNotNil(result, "Initialization should produce a result")

            swiftBlade.getTradeUrl(
                strategy: CryptoFlowServiceStrategy.BUY,
                accountId: accountId,
                sourceCode: "EUR",
                sourceAmount: 50,
                targetCode: "HBAR",
                slippage: 0.5,
                serviceId: "moonpay"
            ) { [self] result, error in
                XCTAssertNil(error, "GetTradeUrl should not produce an error")
                XCTAssertNotNil(result, "GetTradeUrl should produce a result")

                if let integrationUrlData = result {
                    XCTAssertNotNil(integrationUrlData.url, "integrationUrlData.url should present")
                    XCTAssertGreaterThanOrEqual(integrationUrlData.url.count, 1, "integrationUrlData.url should not be empty")
                    XCTAssertNotNil(integrationUrlData.url, "integrationUrlData.url should present")
                } else {
                    XCTFail("no integrationUrlData.url")
                }

                expectation1.fulfill()

                swiftBlade.getTradeUrl(
                    strategy: CryptoFlowServiceStrategy.SELL,
                    accountId: accountId,
                    sourceCode: "USDC",
                    sourceAmount: 50,
                    targetCode: "PHP",
                    slippage: 0.5,
                    serviceId: "onmeta"
                ) { [self] result, error in
                    XCTAssertNil(error, "GetTradeUrl should not produce an error")
                    XCTAssertNotNil(result, "GetTradeUrl should produce a result")

                    if let integrationUrlData = result {
                        XCTAssertNotNil(integrationUrlData.url, "integrationUrlData.url should present")
                        XCTAssertGreaterThanOrEqual(integrationUrlData.url.count, 1, "integrationUrlData.url should not be empty")
                        XCTAssertNotNil(integrationUrlData.url, "integrationUrlData.url should present")
                    } else {
                        XCTFail("no integrationUrlData.url")
                    }

                    // Add assertions for the result properties if needed
                    expectation2.fulfill()

                    swiftBlade.getTradeUrl(
                        strategy: CryptoFlowServiceStrategy.SELL,
                        accountId: accountId,
                        sourceCode: "EUR",
                        sourceAmount: 50,
                        targetCode: "HBAR",
                        slippage: 0.5,
                        serviceId: "unknown-service-id"
                    ) { result, error in
                        XCTAssertNotNil(error, "GetTradeUrl should produce an error")
                        XCTAssertNil(result, "GetTradeUrl should not produce a result")

                        // Add assertions for the result properties if needed
                        expectation3.fulfill()
                    }
                }
            }
        }

        wait(for: [expectation1, expectation2, expectation3], timeout: 30.0)
    }
    
    
    func testNFT() {
        let expectationCreateToken = XCTestExpectation(description: "testNFT should complete expectationCreateToken")
        let expectationAssociateToken = XCTestExpectation(description: "testNFT should complete expectationAssociateToken")
        let expectationMintToken = XCTestExpectation(description: "testNFT should complete expectationMintToken")
        let expectationTransferNFT = XCTestExpectation(description: "testNFT should complete expectationTransferNFT")

        swiftBlade.initialize(apiKey: apiKeyMainnet, dAppCode: dAppCode, network: HederaNetwork.TESTNET, bladeEnv: env, force: true) { [self] result, error in
            XCTAssertNil(error, "Initialization should not produce an error")
            XCTAssertNotNil(result, "Initialization should produce a result")

            let keys = [
                KeyRecord(privateKey: privateKeyHexEd25519, type: KeyType.admin)
            ]
            
            swiftBlade.createToken(
                treasuryAccountId: accountId, 
                supplyPrivateKey: privateKeyHex,
                tokenName: tokenName,
                tokenSymbol: tokenSymbol,
                isNft: true,
                keys: keys,
                decimals: 0,
                initialSupply: 0,
                maxSupply: 250
            ) { [self] result, error in
                XCTAssertNil(error, "createToken should not produce an error")
                XCTAssertNotNil(result, "createToken should produce a result")

                if let tokenData = result {
                    XCTAssertNotNil(tokenData.tokenId, "tokenData.tokenId should present")
                } else {
                    XCTFail("no tokenData.tokenId")
                }
                expectationCreateToken.fulfill()
                let tokenId = result!.tokenId

                swiftBlade.associateToken(
                    tokenId: tokenId,
                    accountId: accountIdEd25519,
                    accountPrivateKey: privateKeyHexEd25519
                ) { [self] result, error in
                    XCTAssertNil(error, "associateToken should not produce an error")
                    XCTAssertNotNil(result, "associateToken should produce a result")

                    if let tokenAssociateData = result {
                        XCTAssertNotNil(tokenAssociateData.status, "tokenAssociateData.status should present")
                        XCTAssertNil(tokenAssociateData.contractId, "tokenAssociateData.contractId should present")
                        XCTAssertNotNil(tokenAssociateData.topicSequenceNumber, "tokenAssociateData.topicSequenceNumber should present")
                        XCTAssertNotNil(tokenAssociateData.totalSupply, "tokenAssociateData.totalSupply should present")
                        XCTAssertNotNil(tokenAssociateData.serials, "tokenAssociateData.serials should present")
                    } else {
                        XCTFail("no tokenAssociateData")
                    }
                    
                    expectationAssociateToken.fulfill()
                    
                    swiftBlade.nftMint(
                        tokenId: tokenId,
                        supplyAccountId: accountId,
                        supplyPrivateKey: privateKeyHex,
                        file: "data:image/png;base64,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",
                        metadata: [
                            "name": "NFTitle",
                            "score": "10",
                            "power": "4",
                            "intelligence": "6",
                            "speed": "10"
                        ],
                        storageConfig: NFTStorageConfig(
                            provider: NFTStorageProvider.nftStorage,
                            apiKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDZFNzY0ZmM0ZkZFOEJhNjdCNjc1NDk1Q2NEREFiYjk0NTE4Njk0QjYiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTcwNDQ2NDUxODQ2MiwibmFtZSI6IkJsYWRlU0RLLXRlc3RrZXkifQ.t1wCiEuiTvcYOwssdZgiYaug4aF8ZrvMBdkTASojWGU"
                        )
                    ) { [self] result, error in
                        XCTAssertNil(error, "nftMint should not produce an error")
                        XCTAssertNotNil(result, "nftMint should produce a result")

                        if let tokenMintData = result {
                            XCTAssertNotNil(tokenMintData.status, "tokenMintData.status should present")
                            XCTAssertNil(tokenMintData.contractId, "tokenMintData.contractId should present")
                            XCTAssertNotNil(tokenMintData.topicSequenceNumber, "tokenMintData.topicSequenceNumber should present")
                            XCTAssertNotNil(tokenMintData.totalSupply, "tokenMintData.totalSupply should present")
                            XCTAssertNotNil(tokenMintData.serials, "tokenMintData.serials should present")
                        } else {
                            XCTFail("no tokenMintData")
                        }

                        // Add assertions for the result properties if needed
                        expectationMintToken.fulfill()

                        swiftBlade.transferTokens(
                            tokenId: tokenId,
                            accountId: accountId,
                            accountPrivateKey: privateKeyHex,
                            receiverId: accountIdEd25519,
                            amountOrSerial: 1,
                            memo: "transfer NFT in Test"
                        ) { result, error in
                            XCTAssertNil(error, "transferTokens should not produce an error")
                            XCTAssertNotNil(result, "GetTradeUrl should produce a result")

                            // Add assertions for the result properties if needed
                            expectationTransferNFT.fulfill()
                        }
                    }
                }
            }
        }
        
        wait(for: [expectationCreateToken, expectationAssociateToken, expectationMintToken, expectationTransferNFT], timeout: 120.0)
    }
}
