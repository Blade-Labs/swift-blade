import XCTest
@testable import SwiftBlade

final class SwiftBladeTests: XCTestCase {
    var swiftBlade: SwiftBlade!
    var apiKey = "C3RHdwKh5qNxNwks7S6UJrzCF3N2pUbDdj5BMeS2uFL9TzGDNhXVF3pGwcyVmrGQ"
    var dAppCode = "karatecombattestnodidcheck"
    var network = HederaNetwork.TESTNET
    var env = BladeEnv.CI
    var accountId = "0.0.346533";
    var accountId2 = "0.0.346530";
    var contractId = "0.0.416245";
    var tokenId = "0.0.433870";
    var privateKeyHex = "3030020100300706052b8104000a04220420ebccecef769bb5597d0009123a0fd96d2cdbe041c2a2da937aaf8bdc8731799b";
    var publicKeyHex = "302d300706052b8104000a032200029dc73991b0d9cdbb59b2cd0a97a0eaff6de801726cb39804ea9461df6be2dd30";
            
    
    override func setUp() {
        super.setUp()
        swiftBlade = SwiftBlade.shared

        // Create an expectation to wait for the initialization to complete.
        let initializationExpectation = XCTestExpectation(description: "Initialization should complete")
        
        // Call swiftBlade.initialize and fulfill the expectation in its completion handler.
        swiftBlade.initialize(apiKey: apiKey, dAppCode: dAppCode, network: network, bladeEnv: env) { result, error in
            XCTAssertNil(error, "Initialization should not produce an error")
            XCTAssertNotNil(result, "Initialization should produce a result")
            
            // Fulfill the expectation to indicate that initialization has completed.
            initializationExpectation.fulfill()
        }
        
        // Wait for the initialization expectation to be fulfilled before continuing.
        wait(for: [initializationExpectation], timeout: 10.0) // Adjust the timeout as needed
 
    }
    
    override func tearDown() {
        swiftBlade = nil
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
                XCTAssertEqual(infoData.sdkVersion, "Swift@0.6.5", "InfoData should have the expected sdkVersion")
            } else {
                XCTFail("Result should be of type InfoData")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testTransferHbars() {
        let expectation = XCTestExpectation(description: "TransferHbars should complete")

        let amount: Decimal = 5.0
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
    
    
    
    
}
