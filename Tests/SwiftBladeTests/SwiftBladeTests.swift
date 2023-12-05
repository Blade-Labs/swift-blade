import XCTest
@testable import SwiftBlade

final class SwiftBladeTests: XCTestCase {
    var swiftBlade: SwiftBlade!
    var apiKey = "ygUgCzRrsvhWmb3dsLcDpGnJpSZ4tk8hACmZqg9WngpuQYKdnD5m8FjfPV3XVUeB"
    var dAppCode = "unitysdktest"
    var network = HederaNetwork.TESTNET
    var env = BladeEnv.CI
    var accountId = "0.0.346533";
    var accountId2 = "0.0.346530";
    var contractId = "0.0.416245";
    var tokenId = "0.0.433870";
    var privateKeyHex = "3030020100300706052b8104000a04220420ebccecef769bb5597d0009123a0fd96d2cdbe041c2a2da937aaf8bdc8731799b";
    var publicKeyHex = "302d300706052b8104000a032200029dc73991b0d9cdbb59b2cd0a97a0eaff6de801726cb39804ea9461df6be2dd30";
    let originalMessage = "hello"
    
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
        swiftBlade.cleanup();
        swiftBlade = nil;
        super.tearDown()
    }

    func testGetInfo() {
        let expectation = XCTestExpectation(description: "GetInfo method should complete without error")
        swiftBlade.getInfo { (result, error) in
            XCTAssertNil(error, "GetInfo should not produce an error")
            XCTAssertNotNil(result, "GetInfo should produce a result")
            
            if let infoData = result as InfoData? {
                XCTAssertEqual(infoData.apiKey, self.apiKey, "InfoData should have the expected apiKey")
                XCTAssertEqual(infoData.dAppCode, self.dAppCode, "InfoData should have the expected dAppCode")
                XCTAssertEqual(infoData.network.uppercased(), self.network.rawValue, "InfoData should have the expected network")
                XCTAssertNotNil(infoData.visitorId, "InfoData should have visitorId")
                XCTAssertEqual(infoData.sdkEnvironment, self.env.rawValue, "InfoData should have the expected bladeEnv")
                XCTAssertEqual(infoData.sdkVersion, "Swift@0.6.9", "InfoData should have the expected sdkVersion")
            } else {
                XCTFail("Result should be of type InfoData")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetBalance() {
        let expectation = XCTestExpectation(description: "GetBalance should complete")

        swiftBlade.getBalance(self.accountId) { result, error in
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

            if let transferData = result as TransferData? {
                XCTAssertNotNil(transferData.nodeId, "TransferData should have nodeId")
                XCTAssertNotNil(transferData.transactionId, "TransferData should have transactionId")
                XCTAssertNotNil(transferData.transactionHash, "TransferData should have transactionHash")
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
            amount: amount,
            memo: "transferTokens tests Swift (paid)",
            freeTransfer: false
        ) { result, error in
            XCTAssertNil(error, "TransferTokens should not produce an error")
            XCTAssertNotNil(result, "TransferTokens should produce a result")

            if let transferData = result as TransferData? {
                XCTAssertNotNil(transferData.nodeId, "TransferData should have nodeId")
                XCTAssertNotNil(transferData.transactionId, "TransferData should have transactionId")
                XCTAssertNotNil(transferData.transactionHash, "TransferData should have transactionHash")
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
            amount: amount,
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

            if let createdAccountData = result as? CreatedAccountData {
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
            
            if let createdAccountData = result as? CreatedAccountData {
                
                self.swiftBlade.deleteHederaAccount(
                    deleteAccountId: createdAccountData.accountId!,
                    deletePrivateKey: createdAccountData.privateKey,
                    transferAccountId: self.accountId,
                    operatorAccountId: self.accountId,
                    operatorPrivateKey: self.privateKeyHex
                ) { result, error in
                    XCTAssertNil(error, "DeleteHederaAccount should not produce an error")
                    XCTAssertNotNil(result, "DeleteHederaAccount should produce a result")

                    if let transactionReceiptData = result as? TransactionReceiptData {
                        XCTAssertEqual(transactionReceiptData.status, "SUCCESS", "TransactionReceiptData should have a 'SUCCESS' status")
                    } else {
                        XCTFail("Result should be a String (transaction ID)")
                    }

                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testGetAccountInfo() {
        let expectation = XCTestExpectation(description: "GetAccountInfo should complete")

        swiftBlade.getAccountInfo(accountId: self.accountId) { result, error in
            XCTAssertNil(error, "GetAccountInfo should not produce an error")
            XCTAssertNotNil(result, "GetAccountInfo should produce a result")

            if let accountInfoData = result as? AccountInfoData {
                XCTAssertEqual(accountInfoData.accountId, self.accountId, "Account ID should match")
                XCTAssertNotNil(accountInfoData.evmAddress, "Created account should have a evmAddress")
                XCTAssertNotNil(accountInfoData.calculatedEvmAddress, "Created account should have a calculatedEvmAddress")
            } else {
                XCTFail("Result should be of type AccountInfoData")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testGetKeysFromMnemonic() {
        let expectation = XCTestExpectation(description: "GetKeysFromMnemonic should complete")

        let mnemonic = "best soccer little verify love ladder else kick depth mesh silly desert"

        swiftBlade.getKeysFromMnemonic(mnemonic: mnemonic, lookupNames: true) { result, error in
            XCTAssertNil(error, "GetKeysFromMnemonic should not produce an error")
            XCTAssertNotNil(result, "GetKeysFromMnemonic should produce a result")

            if let privateKeyData = result as? PrivateKeyData {
                XCTAssertEqual(privateKeyData.privateKey, "3030020100300706052b8104000a04220420a7e529d9c0ea996ff62f9e41d5be81fd67489e28b62ce22420be130626d0ef40", "PrivateKeyData should have a valid private key")
                XCTAssertEqual(privateKeyData.publicKey, "302d300706052b8104000a0322000283529a9f1353613201042305827fb38110e94c3fd559e3cf9b5645dbe0e38368", "PrivateKeyData should have a valid public key")
                XCTAssertEqual(privateKeyData.evmAddress, "0x73226de11bb3705db2bb404a5c1a5533bb0aebb5", "PrivateKeyData should have a valid evmAddress")
                XCTAssertEqual(privateKeyData.accounts.count, 1, "PrivateKeyData should have a valid number of accountIds")
                XCTAssertEqual(privateKeyData.accounts[0], "0.0.2018696", "PrivateKeyData should have a valid accountId")
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

                    if let signMessageData = result as? SignMessageData {
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

                if let signMessageData = signResult as? SignMessageData {
                    let signedMessage = signMessageData.signedMessage
                    // Verify the signed message here
                    self.swiftBlade.signVerify(messageString: base64encodedString, signature: signedMessage, publicKey: self.publicKeyHex) { verifyResult, verifyError in
                        XCTAssertNil(verifyError, "Verify should not produce an error")
                        XCTAssertNotNil(verifyResult, "Verify should produce a result")

                        if let verifyMessageData = verifyResult as? SignVerifyMessageData {
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
            ;

        let tuple1 = SwiftBlade.shared.createContractFunctionParameters()
            .addInt64(value: 5)
            .addInt64(value: 10)
            ;

        let tuple2 = SwiftBlade.shared.createContractFunctionParameters()
            .addInt64(value: 50)
            .addTupleArray(value: [tuple0, tuple1])
            ;
        
        let parameters = swiftBlade.createContractFunctionParameters();
        parameters
            .addString(value: "Hello, Backend")

            .addBytes32(value: [
                0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F])
            .addAddressArray(value: ["0.0.48738539", "0.0.48738538", "0.0.48738537"])
            .addAddress(value: "0.0.48850466")
            .addAddress(value: "0.0.499326")
            .addAddress(value: "0.0.48801688")
            .addInt64(value: 1)

            .addUInt8(value: 123)
            .addUInt64Array(value: [1,2,3])
            .addUInt256Array(value: [1,2,3])
            .addTuple(value: tuple1)
            .addTuple(value: tuple2)
            .addTupleArray(value: [tuple0, tuple1])
            .addTupleArray(value: [tuple2, tuple2])
            .addAddress(value: "0.0.12345")
            .addUInt64(value: 56784645645)
            .addUInt256(value: 12345)
        ;
        
        XCTAssertEqual(parameters.encode(), "W3sidHlwZSI6InN0cmluZyIsInZhbHVlIjpbIkhlbGxvLCBCYWNrZW5kIl19LHsidHlwZSI6ImJ5dGVzMzIiLCJ2YWx1ZSI6WyJXekFzTVN3eUxETXNOQ3cxTERZc055dzRMRGtzTVRBc01URXNNVElzTVRNc01UUXNNVFVzTVRZc01UY3NNVGdzTVRrc01qQXNNakVzTWpJc01qTXNNalFzTWpVc01qWXNNamNzTWpnc01qa3NNekFzTXpGZCJdfSx7InR5cGUiOiJhZGRyZXNzW10iLCJ2YWx1ZSI6WyIwLjAuNDg3Mzg1MzkiLCIwLjAuNDg3Mzg1MzgiLCIwLjAuNDg3Mzg1MzciXX0seyJ0eXBlIjoiYWRkcmVzcyIsInZhbHVlIjpbIjAuMC40ODg1MDQ2NiJdfSx7InR5cGUiOiJhZGRyZXNzIiwidmFsdWUiOlsiMC4wLjQ5OTMyNiJdfSx7InR5cGUiOiJhZGRyZXNzIiwidmFsdWUiOlsiMC4wLjQ4ODAxNjg4Il19LHsidHlwZSI6ImludDY0IiwidmFsdWUiOlsiMSJdfSx7InR5cGUiOiJ1aW50OCIsInZhbHVlIjpbIjEyMyJdfSx7InR5cGUiOiJ1aW50NjRbXSIsInZhbHVlIjpbIjEiLCIyIiwiMyJdfSx7InR5cGUiOiJ1aW50MjU2W10iLCJ2YWx1ZSI6WyIxIiwiMiIsIjMiXX0seyJ0eXBlIjoidHVwbGUiLCJ2YWx1ZSI6WyJXM3NpZEhsd1pTSTZJbWx1ZERZMElpd2lkbUZzZFdVaU9sc2lOU0pkZlN4N0luUjVjR1VpT2lKcGJuUTJOQ0lzSW5aaGJIVmxJanBiSWpFd0lsMTlYUT09Il19LHsidHlwZSI6InR1cGxlIiwidmFsdWUiOlsiVzNzaWRIbHdaU0k2SW1sdWREWTBJaXdpZG1Gc2RXVWlPbHNpTlRBaVhYMHNleUowZVhCbElqb2lkSFZ3YkdWYlhTSXNJblpoYkhWbElqcGJJbGN6YzJsa1NHeDNXbE5KTmtsdGJIVmtSRmt3U1dsM2FXUnRSbk5rVjFWcFQyeHphVTFVV1dsWVdEQnpaWGxLTUdWWVFteEphbTlwWVZjMU1FNXFVV2xNUTBveVdWZDRNVnBUU1RaWGVVbDZUV2xLWkdaV01EMGlMQ0pYTTNOcFpFaHNkMXBUU1RaSmJXeDFaRVJaTUVscGQybGtiVVp6WkZkVmFVOXNjMmxPVTBwa1psTjROMGx1VWpWalIxVnBUMmxLY0dKdVVUSk9RMGx6U1c1YWFHSklWbXhKYW5CaVNXcEZkMGxzTVRsWVVUMDlJbDE5WFE9PSJdfSx7InR5cGUiOiJ0dXBsZVtdIiwidmFsdWUiOlsiVzNzaWRIbHdaU0k2SW1sdWREWTBJaXdpZG1Gc2RXVWlPbHNpTVRZaVhYMHNleUowZVhCbElqb2lhVzUwTmpRaUxDSjJZV3gxWlNJNld5SXpNaUpkZlYwPSIsIlczc2lkSGx3WlNJNkltbHVkRFkwSWl3aWRtRnNkV1VpT2xzaU5TSmRmU3g3SW5SNWNHVWlPaUpwYm5RMk5DSXNJblpoYkhWbElqcGJJakV3SWwxOVhRPT0iXX0seyJ0eXBlIjoidHVwbGVbXSIsInZhbHVlIjpbIlczc2lkSGx3WlNJNkltbHVkRFkwSWl3aWRtRnNkV1VpT2xzaU5UQWlYWDBzZXlKMGVYQmxJam9pZEhWd2JHVmJYU0lzSW5aaGJIVmxJanBiSWxjemMybGtTR3gzV2xOSk5rbHRiSFZrUkZrd1NXbDNhV1J0Um5Oa1YxVnBUMnh6YVUxVVdXbFlXREJ6WlhsS01HVllRbXhKYW05cFlWYzFNRTVxVVdsTVEwb3lXVmQ0TVZwVFNUWlhlVWw2VFdsS1pHWldNRDBpTENKWE0zTnBaRWhzZDFwVFNUWkpiV3gxWkVSWk1FbHBkMmxrYlVaelpGZFZhVTlzYzJsT1UwcGtabE40TjBsdVVqVmpSMVZwVDJsS2NHSnVVVEpPUTBselNXNWFhR0pJVm14SmFuQmlTV3BGZDBsc01UbFlVVDA5SWwxOVhRPT0iLCJXM3NpZEhsd1pTSTZJbWx1ZERZMElpd2lkbUZzZFdVaU9sc2lOVEFpWFgwc2V5SjBlWEJsSWpvaWRIVndiR1ZiWFNJc0luWmhiSFZsSWpwYklsY3pjMmxrU0d4M1dsTkpOa2x0YkhWa1JGa3dTV2wzYVdSdFJuTmtWMVZwVDJ4emFVMVVXV2xZV0RCelpYbEtNR1ZZUW14SmFtOXBZVmMxTUU1cVVXbE1RMG95V1ZkNE1WcFRTVFpYZVVsNlRXbEtaR1pXTUQwaUxDSlhNM05wWkVoc2QxcFRTVFpKYld4MVpFUlpNRWxwZDJsa2JVWnpaRmRWYVU5c2MybE9VMHBrWmxONE4wbHVValZqUjFWcFQybEtjR0p1VVRKT1EwbHpTVzVhYUdKSVZteEphbkJpU1dwRmQwbHNNVGxZVVQwOUlsMTlYUT09Il19LHsidHlwZSI6ImFkZHJlc3MiLCJ2YWx1ZSI6WyIwLjAuMTIzNDUiXX0seyJ0eXBlIjoidWludDY0IiwidmFsdWUiOlsiNTY3ODQ2NDU2NDUiXX0seyJ0eXBlIjoidWludDI1NiIsInZhbHVlIjpbIjEyMzQ1Il19XQ==", "Encoded params should be equal this result")
        expectation.fulfill()
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testContractCallFunction() {
        let expectation = XCTestExpectation(description: "ContractCallFunction should complete")

        let parameters = swiftBlade.createContractFunctionParameters().addString(value: "Hello Swift test");
        swiftBlade.contractCallFunction(
            contractId: self.contractId, functionName: "set_message", params: parameters, accountId: self.accountId, accountPrivateKey: self.privateKeyHex, gas: 1000000, bladePayFee: false
        ) { result, error in
            XCTAssertNil(error, "ContractCallFunction should not produce an error")
            XCTAssertNotNil(result, "ContractCallFunction should produce a result")

            if let transactionReceiptData = result as? TransactionReceiptData {
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
            contractId: self.contractId, functionName: "get_message", params: swiftBlade.createContractFunctionParameters(), accountId: self.accountId, accountPrivateKey: self.privateKeyHex, gas: 150000, bladePayFee: false, returnTypes: ["string", "int32"]
        ) { result, error in
            XCTAssertNil(error, "ContractCallQueryFunction should not produce an error")
            XCTAssertNotNil(result, "ContractCallQueryFunction should produce a result")

            if let contractQueryData = result as? ContractQueryData {
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
            swiftBlade.ethersSign(messageString: base64encodedString, privateKey: self.privateKeyHex) { result, error in
                XCTAssertNil(error, "EthersSign should not produce an error")
                XCTAssertNotNil(result, "EthersSign should produce a result")
                
                if let signMessageData = result as? SignMessageData {
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
            swiftBlade.ethersSign(messageString: base64encodedString, privateKey: self.privateKeyHex) { result, error in
                XCTAssertNil(error, "EthersSign should not produce an error")
                XCTAssertNotNil(result, "EthersSign should produce a result")
                
                if let signMessageData = result as? SignMessageData {
                    XCTAssertNotNil(signMessageData.signedMessage, "Signed message should not be nil")
                    XCTAssertEqual(signMessageData.signedMessage, "0x25de7c26ecfa4f28d8b96a95cf58ea7088a72a66b311c796090cb4c7d58c11217b4a7b174b4c31b90c3babb00958b2120274380404c4f1196abe3614df3741561b", "Signed message should be valid signature")
                    
                    
                    self.swiftBlade.splitSignature(signature: signMessageData.signedMessage) { result, error in
                        XCTAssertNil(error, "SplitSignature should not produce an error")
                        XCTAssertNotNil(result, "SplitSignature should produce a result")

                        if let splitSignatureData = result as? SplitSignatureData {
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
            .addAddress(value: self.accountId)
            .addUInt64Array(value: [300000, 300000])
            .addUInt64Array(value: [6])
            .addUInt64Array(value: [2])
        ;

        swiftBlade.getParamsSignature(
            params: parameters, accountPrivateKey: self.privateKeyHex
            
        ) { result, error in
            XCTAssertNil(error, "GetParamsSignature should not produce an error")
            XCTAssertNotNil(result, "GetParamsSignature should produce a result")

            if let splitSignatureData = result as? SplitSignatureData {
                XCTAssertEqual(splitSignatureData.v, 28, "SplitSignatureData should be valid v")
                XCTAssertEqual(splitSignatureData.r, "0xe5e662d0564828fd18b2b5b228ade288ad063fadca76812f7902f56cae3e678e", "SplitSignatureData should be valid r")
                XCTAssertEqual(splitSignatureData.s, "0x61b7ceb82dc6695872289b697a1bca73b81c494288abda29fa022bb7b80c84b5", "SplitSignatureData should be valid s")
            } else {
                XCTFail("Result should be of type SignMessageData")
            }
            
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
    
    
    func testGetTransactions() {
        let expectation = XCTestExpectation(description: "GetTransactions should complete")

        swiftBlade.getTransactions(accountId: self.accountId, transactionType: "", nextPage: "", transactionsLimit: 5) { result, error in
            XCTAssertNil(error, "GetTransactions should not produce an error")
            XCTAssertNotNil(result, "GetTransactions should produce a result")

            if let transactionsHistoryData = result as? TransactionsHistoryData {
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

        swiftBlade.getC14url(asset: "KARATE", account: self.accountId, amount: "1234") { result, error in
            XCTAssertNil(error, "GetC14url should not produce an error")
            XCTAssertNotNil(result, "GetC14url should produce a result")

            if let integrationUrlData = result as? IntegrationUrlData {
                XCTAssertEqual(integrationUrlData.url, "https://pay.c14.money/?clientId=00ce2e0a-ee66-4971-a0e9-b9d627d106b0&targetAssetId=057d6b35-1af5-4827-bee2-c12842faa49e&targetAssetIdLock=true&sourceAmount=1234&quoteAmountLock=true&targetAddress=0.0.346533&targetAddressLock=true", "url should be like that")
            } else {
                XCTFail("Result should be of type transactionsHistoryData")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
    
    
    
}
