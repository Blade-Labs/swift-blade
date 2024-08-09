@testable import SwiftBlade
import XCTest

class SwiftBladeTestsHedera: XCTestCase {
    var swiftBlade: SwiftBlade!
    var apiKey = "ygUgCzRrsvhWmb3dsLcDpGnJpSZ4tk8hACmZqg9WngpuQYKdnD5m8FjfPV3XVUeB"
    var apiKeyMainnet = "IYyE75dUez7fMxfXzIP8Hw4CvhTURhbte3QNVhFDTSbV97ycfq5NrqEGrzAThVeg"
    var dAppCode = "unitysdktest"
    var chainId = KnownChainIds.HEDERA_TESTNET
    var bladeEnv = BladeEnv.CI
    var accountProvider = AccountProvider.PrivateKey
    var magicEmail = "the.gary.du+sdk2@gmail.com"
    let message = "hello"
    let tokenName = "Swift Token SDK"
    let tokenSymbol = "Arr!"
    let secretNonce = "unity_test"
    let associateOnDemandCampaignName = "drop1"

    let hederaAccountId1 = "0.0.1443"
    let hederaPrivateKey1 = "3030020100300706052b8104000a04220420ebccecef769bb5597d0009123a0fd96d2cdbe041c2a2da937aaf8bdc8731799b"
    let hederaPublicKey1 = "302d300706052b8104000a032200029dc73991b0d9cdbb59b2cd0a97a0eaff6de801726cb39804ea9461df6be2dd30"
    let hederaAccountId2 = "0.0.1767"
    let hederaPrivateKey2 = "302e020100300506032b657004220420c903827cacbaf81f105aa548db06a3ab8cbddd362f54be0a803430a4401f6b2c"
    let hederaMnemonic = "purity slab doctor swamp tackle rebuild summer bean craft toddler blouse switch"
    let hederaContractId = "0.0.4437600"
    let hederaTokenAddress = "0.0.2216053"
    let hederaTokenAddress2 = "0.0.5365"
    let hederaNftAddress = "0.0.4488252"
    
    let ethereumAddress = "0x11f8D856FF2aF6700CCda4999845B2ed4502d8fB"
    let ethereumPrivateKey = "ebccecef769bb5597d0009123a0fd96d2cdbe041c2a2da937aaf8bdc8731799b"
    let ethereumPublicKey = ""
    let ethereumAddress2 = "0x085946E373353Eb190794CA7EF4d7b9a60D0A4B0"
    let ethereumPrivateKey2 = ""
    let ethereumMnemonic = "boring slice orange recycle crew aunt fat meadow solid quality wasp visual"
    let ethereumContractAddress = "0xd36b5b8b408bad51009bd2748c3bc130c68948d2"
    let ethereumTokenAddress = "0xc72073559B3430ed97ecaCa7111B25d7CBa4E91A"
    let ethereumTokenAddress2 = "0xc72073559B3430ed97ecaCa7111B25d7CBa4E91A"
    let ethereumNftAddress = ""
    
    var accountAddress = ""
    var accountPrivateKey = ""
    var accountPublicKey = ""
    var accountAddress2 = ""
    var accountPrivateKey2 = ""
    var accountMnemonic = ""
    var contractAddress = ""
    var tokenAddress = ""
    var tokenAddress2 = ""
    var nftAddress = ""

    override func setUp() {
        super.setUp()
        swiftBlade = SwiftBlade.shared

        // Create an expectation to wait for the initialization to complete.
        let initializationExpectation = XCTestExpectation(description: "Initialization should complete")

        setTestDataByChainId(chainId: chainId);
        
        // Call swiftBlade.initialize and fulfill the expectation in its completion handler.
        swiftBlade.initialize(apiKey: apiKey, chainId: chainId, dAppCode: dAppCode, bladeEnv: bladeEnv, force: false) { result, error in
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
                XCTAssertEqual(infoData.chainId, self.chainId, "InfoData should have the expected chainId")
                XCTAssertNotNil(infoData.isTestnet, "InfoData should have isTestnet")
                XCTAssertNotNil(infoData.visitorId, "InfoData should have visitorId")
                XCTAssertEqual(infoData.sdkEnvironment, self.bladeEnv, "InfoData should have the expected bladeEnv")
                XCTAssertEqual(infoData.sdkVersion, "Swift@1.0.0", "InfoData should have the expected sdkVersion")
                XCTAssertNotNil(infoData.nonce, "InfoData should have nonce")
                XCTAssertNotNil(infoData.user, "InfoData should have user")
            } else {
                XCTFail("Result should be of type InfoData")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetBalance() {
        let expectation = XCTestExpectation(description: "GetBalance should complete")

        swiftBlade.getBalance(accountAddress) { result, error in
            XCTAssertNil(error, "GetBalance should not produce an error")
            XCTAssertNotNil(result, "GetBalance should produce a result")

            if let balanceResponse = result as BalanceData? {
                XCTAssertNotNil(balanceResponse.balance, "balance should not be nil")
                XCTAssertNotNil(balanceResponse.rawBalance, "rawBalance should not be nil")
                XCTAssertNotNil(balanceResponse.decimals, "decimals should not be nil")
                XCTAssertNotNil(balanceResponse.tokens, "Tokens balance should not be nil")
                XCTAssertGreaterThanOrEqual(balanceResponse.tokens.count, 1, "some token balances")
                let tokenBalance = balanceResponse.tokens[0]
                
                XCTAssertNotNil(tokenBalance.balance, "balance in balance.token[] should not be nil")
                XCTAssertNotNil(tokenBalance.decimals, "decimals in balance.token[] should not be nil")
                XCTAssertNotNil(tokenBalance.name, "name in balance.token[] should not be nil")
                XCTAssertNotNil(tokenBalance.symbol, "symbol in balance.token[] should not be nil")
                XCTAssertNotNil(tokenBalance.address, "address in balance.token[] should not be nil")
                XCTAssertNotNil(tokenBalance.rawBalance, "rawBalance in balance.token[] should not be nil")
                
                XCTAssertGreaterThan(Double(balanceResponse.balance) ?? 0, 0.0, "Account balance should be greater than 0.0")
            } else {
                XCTFail("Result should be of type BalanceResponse")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60.0)
    }

    func testGetCoinListCommon() {
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

    func testGetCoinPriceCommon() {
        let expectation = XCTestExpectation(description: "getCoinPrice should complete")

        swiftBlade.getCoinPrice("Hbar", "uah") { result, error in
            XCTAssertNil(error, "getCoinPrice should not produce an error")
            XCTAssertNotNil(result, "getCoinPrice should produce a result")

            if let coinPriceData = result {
                XCTAssertNotNil(coinPriceData.priceUsd, "Coin price should have a USD value")
                XCTAssertNotNil(coinPriceData.coin, "Coin price should have a coin object")
                XCTAssertNotNil(coinPriceData.price, "Coin price should have a price value")
                XCTAssertNotNil(coinPriceData.currency, "Coin price should have a currency value")
                XCTAssertEqual(coinPriceData.currency, "uah", "Currency should match")
                
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
    
    func testDropTokens() {
        if (isSkippingChain(.ETHEREUM_SEPOLIA, "Skipping dropTokens as it's hedera only")) {
            return
        }
        
        let expectation1 = XCTestExpectation(description: "createAccount should complete")
        let expectation2 = XCTestExpectation(description: "DropTokens should produce error as user not set")
        let expectation3 = XCTestExpectation(description: "setUser should produce result")
        let expectation4 = XCTestExpectation(description: "DropTokens should complete")
        let expectation5 = XCTestExpectation(description: "DropTokens should produce error as drop already done")

        swiftBlade.createAccount("", deviceId: "") { result, error in
            XCTAssertNil(error, "createAccount should not produce an error")
            XCTAssertNotNil(result, "createAccount should produce a result")

            if let createdAccountData = result {
                expectation1.fulfill()

                self.swiftBlade.dropTokens(
                    secretNonce: self.secretNonce
                ) { [self] result, error in
                    XCTAssertNotNil(error, "DropTokens should produce an error")
                    XCTAssertNil(result, "DropTokens should not produce a result")
                    expectation2.fulfill()

                    self.swiftBlade.setUser(accountProvider: AccountProvider.PrivateKey, accountIdOrEmail: createdAccountData.accountAddress, privateKey: createdAccountData.privateKey) { result, error in
                        XCTAssertNil(error, "setUser should not produce an error")
                        XCTAssertNotNil(result, "setUser should produce a result")
                        expectation3.fulfill()
                        
                        self.swiftBlade.dropTokens(
                            secretNonce: self.secretNonce
                        ) { result, error in
                            XCTAssertNil(error, "DropTokens should not produce an error")
                            XCTAssertNotNil(result, "DropTokens should produce a result")
                            expectation4.fulfill()
                            
                            self.swiftBlade.dropTokens(
                                secretNonce: self.secretNonce
                            ) { result, error in
                                XCTAssertNotNil(error, "DropTokens should produce an error")
                                XCTAssertNil(result, "DropTokens should not produce a result")
                                expectation5.fulfill()
                            }
                        }
                    }
                }
            } else {
                XCTFail("Result should be of type CreatedAccountData")
            }
        }
        wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5], timeout: 100.0)
    }
        
    func testTransferBalance() {
        let expectation1 = XCTestExpectation(description: "transferBalance should fail as user not set")
        let expectation2 = XCTestExpectation(description: "setUser should complete")
        let expectation3 = XCTestExpectation(description: "transferBalance should complete")

        let amount = "0.000007"
        let memo = "transferBalance tests Swift"

        swiftBlade.transferBalance(
            receiverAddress: accountAddress2,
            amount: amount,
            memo: memo
        ) { result, error in
            XCTAssertNotNil(error, "transferBalance should produce an error")
            XCTAssertNil(result, "transferBalance should not produce a result")
     
            self.swiftBlade.setUser(
                accountProvider: .PrivateKey,
                accountIdOrEmail: self.accountAddress,
                privateKey: self.accountPrivateKey
            ) { result, error in
                XCTAssertNil(error, "setUser should not produce an error")
                XCTAssertNotNil(result, "setUser should produce a result")

                    
                self.swiftBlade.transferBalance(
                    receiverAddress: self.accountAddress2,
                        amount: amount,
                        memo: memo
                    ) { result, error in
                        XCTAssertNil(error, "transferBalance should not produce an error")
                        XCTAssertNotNil(result, "transferBalance should produce a result")

                        if let transferData = result as TransactionResponseData? {
                            XCTAssertNotNil(transferData.transactionHash, "TransferData should have topicSequenceNumber")
                            XCTAssertNotNil(transferData.transactionId, "TransferData should have totalSupply")
                        } else {
                            XCTFail("Result should be of type TransferData")
                        }
                        expectation3.fulfill()
                    }
                    
                
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2, expectation3], timeout: 30.0)
    }

    func testTransferTokens() {
        let expectation1 = XCTestExpectation(description: "TransferTokens should fail as no user set")
        let expectation2 = XCTestExpectation(description: "setUser should complete")
        let expectation3 = XCTestExpectation(description: "TransferTokens should complete (paid)")
        let expectation4 = XCTestExpectation(description: "TransferTokens should complete (paymaster)")
        

        let amount = "1"

        swiftBlade.transferTokens(
            tokenAddress: tokenAddress,
            receiverAddress: accountAddress2,
            amountOrSerial: amount,
            memo: "transferTokens tests Swift (paid)",
            usePaymaster: false
        ) { result, error in
            XCTAssertNotNil(error, "TransferTokens should produce an error")
            XCTAssertNil(result, "TransferTokens should not produce a result")

            
            self.swiftBlade.setUser(
                accountProvider: .PrivateKey,
                accountIdOrEmail: self.accountAddress,
                privateKey: self.accountPrivateKey
            ) { result, error in
                XCTAssertNil(error, "TransferTokens should not produce an error")
                XCTAssertNotNil(result, "TransferTokens should produce a result")

                self.swiftBlade.transferTokens(
                    tokenAddress: self.tokenAddress,
                    receiverAddress: self.accountAddress2,
                    amountOrSerial: amount,
                    memo: "transferTokens tests Swift (paid)",
                    usePaymaster: false
                ) { result, error in
                    XCTAssertNil(error, "TransferTokens should not produce an error")
                    XCTAssertNotNil(result, "TransferTokens should produce a result")

                    if let transferResponse = result as TransactionResponseData? {
                        XCTAssertNotNil(transferResponse.transactionHash, "transferResponse should have transactionHash")
                        XCTAssertNotNil(transferResponse.transactionId, "transferResponse should have transactionId")
                    } else {
                        XCTFail("Result should be of type TransferResponseData")
                    }

                    expectation3.fulfill()
                    
                    if (self.isSkippingChain(.ETHEREUM_SEPOLIA, "Skipping transferTokens usePaymaster: true")) {
                        expectation4.fulfill()
                        return
                    }
                    
                    self.swiftBlade.transferTokens(
                        tokenAddress: self.tokenAddress,
                        receiverAddress: self.accountAddress2,
                        amountOrSerial: amount,
                        memo: "transferTokens tests Swift (paymaster)",
                        usePaymaster: true
                    ) { result, error in
                        XCTAssertNil(error, "TransferTokens should not produce an error")
                        XCTAssertNotNil(result, "TransferTokens should produce a result")

                        if let transferResponse = result as TransactionResponseData? {
                            XCTAssertNotNil(transferResponse.transactionHash, "transferResponse should have transactionHash")
                            XCTAssertNotNil(transferResponse.transactionId, "transferResponse should have transactionId")
                        } else {
                            XCTFail("Result should be of type TransferResponseData")
                        }

                        expectation4.fulfill()
                    }
                    
                }
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 60.0)
    }

    func testCreateAccount() {
        let expectation = XCTestExpectation(description: "CreateAccount should complete")
        let deviceId = ""
        swiftBlade.createAccount("", deviceId: deviceId) { result, error in
            XCTAssertNil(error, "CreateAccount should not produce an error")
            XCTAssertNotNil(result, "CreateAccount should produce a result")

            if let createdAccountData = result {
                XCTAssertNotNil(createdAccountData.seedPhrase, "Created account should have a seed phrase")
                XCTAssertNotNil(createdAccountData.publicKey, "Created account should have a publicKey")
                XCTAssertNotNil(createdAccountData.privateKey, "Created account should have a privateKey")
                XCTAssertNotNil(createdAccountData.accountAddress, "Created account should have a accountId")
                XCTAssertNotNil(createdAccountData.evmAddress, "Created account should have a evmAddress")
                XCTAssertNotNil(createdAccountData.status, "Created account should have a status")
                XCTAssertEqual(createdAccountData.status, "SUCCESS", "Created account should have a 'SUCCESS' status")
            } else {
                XCTFail("Result should be of type CreatedAccountData")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }

    func testGetAccountInfo() {
        let expectation = XCTestExpectation(description: "GetAccountInfo should complete")

        swiftBlade.getAccountInfo(accountAddress: accountAddress) { result, error in
            XCTAssertNil(error, "GetAccountInfo should not produce an error")
            XCTAssertNotNil(result, "GetAccountInfo should produce a result")

            if let accountInfoData = result {
                XCTAssertEqual(accountInfoData.accountAddress, self.accountAddress, "Account ID should match")
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
    
    func testDeleteAccount() {
        if (isSkippingChain(.ETHEREUM_SEPOLIA)) {
            return
        }
        
        let expectation1 = XCTestExpectation(description: "DeleteAccount should fail as user not set yet")
        let expectation2 = XCTestExpectation(description: "setUser should complete")
        let expectation3 = XCTestExpectation(description: "DeleteAccount should complete")

        swiftBlade.createAccount("", deviceId: "") { result, error in
            XCTAssertNotNil(result, "CreateAccount should produce a result")

            if let createdAccountData = result {
                self.swiftBlade.deleteAccount(
                    deleteAccountAddress: createdAccountData.accountAddress,
                    deletePrivateKey: createdAccountData.privateKey,
                    transferAccountAddress: self.accountAddress
                ) { result, error in
                    XCTAssertNotNil(error, "DeleteAccount should not produce an error")
                    XCTAssertNil(result, "DeleteAccount should produce a result")
                    expectation1.fulfill()
                    
                    self.swiftBlade.setUser(
                        accountProvider: .PrivateKey,
                        accountIdOrEmail: self.accountAddress,
                        privateKey: self.accountPrivateKey
                    ) { result, error in
                        XCTAssertNil(error, "setUser should not produce an error")
                        XCTAssertNotNil(result, "setUser should produce a result")

                        expectation2.fulfill()
                        
                        self.swiftBlade.deleteAccount(
                            deleteAccountAddress: createdAccountData.accountAddress,
                            deletePrivateKey: createdAccountData.privateKey,
                            transferAccountAddress: self.accountAddress
                        ) { result, error in
                            XCTAssertNil(error, "DeleteAccount should not produce an error")
                            XCTAssertNotNil(result, "DeleteAccount should produce a result")

                            if let transactionReceiptData = result {
                                XCTAssertEqual(transactionReceiptData.status, "SUCCESS", "TransactionReceiptData should have a 'SUCCESS' status")
                            } else {
                                XCTFail("Result should be a String (transaction ID)")
                            }

                            expectation3.fulfill()
                        }
                    }
                }
            }
        }
        wait(for: [expectation1, expectation2, expectation3], timeout: 80.0)
    }

    func testSearchAccounts() {
        let expectation = XCTestExpectation(description: "SearchAccounts should complete")

        swiftBlade.searchAccounts(accountMnemonic) { result, error in
            XCTAssertNil(error, "SearchAccounts should not produce an error")
            XCTAssertNotNil(result, "SearchAccounts should produce a result")
            if let account = result?.accounts[0] {
                self.swiftBlade.getAccountInfo(accountAddress: account.address) { result, error in
                    XCTAssertEqual(account.publicKey, result?.publicKey, "Key must match")
                }
                XCTAssertNotNil(account.privateKey, "AccountPrivateData should have a valid private key")
                XCTAssertNotNil(account.publicKey, "AccountPrivateData should have a valid public key")
                XCTAssertNotNil(account.evmAddress, "AccountPrivateData should have a valid evmAddress")
                XCTAssertNotNil(account.address, "AccountPrivateData should have a valid accountId")
                expectation.fulfill()
            } else {
                XCTFail("Result should be of type AccountPrivateData")
            }
        }
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testGetTransactions() {
        let expectation = XCTestExpectation(description: "GetTransactions should complete")

        swiftBlade.getTransactions(accountAddress: accountAddress, transactionType: "", nextPage: "", transactionsLimit: 5) { result, error in
            XCTAssertNil(error, "GetTransactions should not produce an error")
            XCTAssertNotNil(result, "GetTransactions should produce a result")

            if let transactionsHistoryData = result {
                XCTAssertNotNil(transactionsHistoryData.nextPage, "transactionsHistoryData nextPage should not be nil")
                XCTAssertEqual(transactionsHistoryData.transactions.count, 5, "transactionsHistoryData transactions count should be as in params")
                XCTAssertNotNil(transactionsHistoryData.transactions[0].transactionId, "transactions[].transactionId should not be nil")
                XCTAssertNotNil(transactionsHistoryData.transactions[0].type, "transactions[].type should not be nil")
                XCTAssertNotNil(transactionsHistoryData.transactions[0].time, "transactions[].time should not be nil")
                XCTAssertNotNil(transactionsHistoryData.transactions[0].transfers, "transactions[].transfers should not be nil")
                XCTAssertNotNil(transactionsHistoryData.transactions[0].nftTransfers, "transactions[].nftTransfers should not be nil")
//                XCTAssertNotNil(transactionsHistoryData.transactions[0].memo, "transactions[].memo should not be nil")
//                XCTAssertNotNil(transactionsHistoryData.transactions[0].fee, "transactions[].fee should not be nil")
                XCTAssertNotNil(transactionsHistoryData.transactions[0].consensusTimestamp, "transactions[].consensusTimestamp should not be nil")
            } else {
                XCTFail("Result should be of type transactionsHistoryData")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAssociateToken() {
        if (isSkippingChain(.ETHEREUM_SEPOLIA)) {
            return
        }
        
        let expectation1 = XCTestExpectation(description: "CreateAccount should complete")
        let expectation2 = XCTestExpectation(description: "setUser should complete")
        let expectation3 = XCTestExpectation(description: "transferBalance should complete")
        let expectation4 = XCTestExpectation(description: "setUser should complete")
        let expectation5 = XCTestExpectation(description: "associateToken should complete")
        let expectation6 = XCTestExpectation(description: "associateToken (on demand) should complete")
        
        swiftBlade.createAccount("", deviceId: "") { result, error in
            XCTAssertNil(error, "CreateAccount should not produce an error")
            XCTAssertNotNil(result, "CreateAccount should produce a result")

            if let createdAccountData = result {
                self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: self.accountAddress, privateKey: self.accountPrivateKey) { result, error in
                    XCTAssertNil(error, "setUser should not produce an error")
                    XCTAssertNotNil(result, "setUser should produce a result")
                    
                    self.swiftBlade.transferBalance(
                        receiverAddress: createdAccountData.accountAddress,
                        amount: "1",
                        memo: "for association test"
                    ) { result, error in
                        XCTAssertNil(error, "transferBalance should not produce an error")
                        XCTAssertNotNil(result, "transferBalance should produce a result")
                        
                        self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: createdAccountData.accountAddress, privateKey: createdAccountData.privateKey) { result, error in
                            XCTAssertNil(error, "setUser should not produce an error")
                            XCTAssertNotNil(result, "setUser should produce a result")
                            
                            self.swiftBlade.associateToken(
                                tokenIdOrCampaign: self.tokenAddress2
                            ) { [self] result, error in
                                XCTAssertNil(error, "associateToken should not produce an error")
                                XCTAssertNotNil(result, "associateToken should produce a result")
                                
                                if let tokenAssociateData = result {
                                    XCTAssertNotNil(tokenAssociateData.status, "tokenAssociateData.status should present")
                                    XCTAssertNil(tokenAssociateData.contractId, "tokenAssociateData.contractId should present")
                                    XCTAssertNotNil(tokenAssociateData.topicSequenceNumber, "tokenAssociateData.topicSequenceNumber should present")
                                    XCTAssertNotNil(tokenAssociateData.totalSupply, "tokenAssociateData.totalSupply should present")
                                    XCTAssertNotNil(tokenAssociateData.serials, "tokenAssociateData.serials should present")
                                    
                                    self.swiftBlade.associateToken(
                                        tokenIdOrCampaign: self.associateOnDemandCampaignName
                                    ) { result, error in
                                        XCTAssertNil(error, "associateToken should not produce an error")
                                        XCTAssertNotNil(result, "associateToken should produce a result")
                                        expectation6.fulfill()
                                    }
                                } else {
                                    XCTFail("no tokenAssociateData")
                                }
                                expectation5.fulfill()
                            }
                            expectation4.fulfill()
                        }
                        expectation3.fulfill()
                    }
                    expectation2.fulfill()
                }
            } else {
                XCTFail("Result should be of type CreatedAccountData")
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 60.0)
    }
    
    func testNFT() {
        let expectation1 = XCTestExpectation(description: "setUser1 should complete")
        let expectation2 = XCTestExpectation(description: "createToken should complete")
        let expectation3 = XCTestExpectation(description: "nftMint should complete")
        let expectation4 = XCTestExpectation(description: "setUser2 should complete")
        let expectation5 = XCTestExpectation(description: "associateToken should complete")
        let expectation6 = XCTestExpectation(description: "setUser1 should complete")
        let expectation7 = XCTestExpectation(description: "transferTokens should complete")

        swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: accountAddress, privateKey: accountPrivateKey) { [self] result, error in
            XCTAssertNil(error, "setUser should not produce an error")
            XCTAssertNotNil(result, "setUser should produce a result")

            let keys = [
                KeyRecord(privateKey: accountPrivateKey2, type: KeyType.admin)
            ]
            
            swiftBlade.createToken(
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
                    let tokenId = result!.tokenId
                    
                    swiftBlade.nftMint(
                        tokenAddress: tokenId,
                        file: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAMAAACahl6sAAAA4VBMVEUAAAAxMTFYWFhnZ2e5ubk1NTXm5ubl5eWtra0yMjJfX19LS0uamprT09NBQUE9PT1ERER/f3+Ghoa8vLzPz8+kpKRxcXHMzMzo6Og4ODhbW1vDw8NsbGy0tLTX19dTU1NiYmKPj4/b29uDg4OKiork5ORISEiSkpKfn59OTk6wsLDIyMhQUFB4eHje3t46OjpWVlbg4OBGRkZlZWXGxsbKysp6enqVlZWYmJioqKhzc3Pi4uKioqLAwMB1dXUxMTFISEhPT082NjY/Pz8zMzM7OzteXl5WVlZGRkZBQUF9fX0DZz0pAAAAP3RSTlMA6LakPeIFBU3mrcZkHNTY0Id9OSJXmCYD3rMxnkMXvKlzE4J4CMpuXsJIK8CQD9y4Dc2nLSiMamhSlQpbNZJbjNWmAAAIhklEQVR42uzabV8SQRQF8DPCpssizwmIAkKggpmiqWV2CvVXff8vlFmKWw4zs3Nt3+z/tase5t7jqCCTyWQymUwmk8lkMplMJiOpif+vC3mn1RH+u/WNFoQ1otwq/r8gB2ErPEMKZqoGUWeKn5CCPsMPEHSuyDpSUCPfTSFmEpIcIAWv52TlGEK670jOj5GC0zLJPoT0eKfwCmkokVRvIKKqeKeKVFR4J8hDwETxlyJS0ecvs0N4G7R5r45UVHnvBN42eceptMRr644awtOF4r35JVLRKfNe+RReGiF/22whHSX+VoCXAv84Q0rG/C3chYc9xT+KSEmff1QaSKxb5oM6UlLlgxwSe8tHA6Rkjw+C10gor/ggeAW9Ovy0sET9mg8OBkikdcRHPSwxhJ/RBHqrMz4aIpHXJG1Kq7EFP6+qq9CLSL99Hx2QtCmtmu/F+NXXOvQKXHibcMsW8tCbfVv1DHI7tKotstSEs8OIC2oArUboH6Q3glaRT3yGgeH5AHpDegf5Mb+CVv6aC+UpHB0f8Il96FX41TfIF9agdTn2OpI9PvURWushv/gG+cqVEbT2+US5ASejHp+6gFaNEkF4ZaitpMW1RlqWVkUmSM2utsjyOhy0CozRP9xUMkE2L+1qh3wDB3XGBK0lnSUT5KYDne1rPhXBwRZtn60IBeEOdLoRF9wuwc02YzaWTJZUkMIIOj3GFGBtl7QsrRqlgsw7lrXFdtN51c2lNRYLwh272lp8pFnnljGqq58suSCFVcvaYg+WdhgXLJksuSC3p9ra+sGY9jqstPq0La1IMAiH+v9fanbW4P13xm3pJ0sySKEFjSPG5dyuJ+blekPJINenlrXFd7Byxr9sQyMSDcJd29oKponKN9Tt1qmSDdKHxgXjbnatVuQL40L9ZMkGKU11tXWbZEkm/MsYGvvCQXiuK5XI3KPmc2ROO1nSQU6gscK4MixUSbtfAGqUC2KYrRPGtbvuV3jebOsmSzwIi5Yv7nwCs39KS5O+o+SDnFjetuY7MNu0vGnVKB+k0tTU1pxxZwmCVPC8smQQw2w19xmXcwhiOO4r9RJBcpbf1GaCIDX9Xx3kg8waeFaOcZF7kJu15794STSIabaGpiDm1grWn58svkyQnF1tHcHshDFt80s0bnkGifho1sVz8owruP9ADKf1/D+u1kpc6MFTxIXhNP+v97uM24DZBl19hKcDuqrCrEpX5/C0SUfzIsw+0VUent7SUdCAWWNGN6oLT7t0VIKNPt204Wu7zBihrdyhmy14i+gkXIONRoUuVB3eztwnS373yvCXb9NBaFuT6xU6qEFAz/VA5E9aNSBgLaC1cA+2BmPhVTc7eplZ3gtoqTSSfVusWVCHg7eKVtQEJsINExZf5PqzBSmXEa18hpvDMS30WjAT7cqVlvPnjRRNDo4haNqmiSocwl3BlGR/AFEfjDmqSGQYcpnbDmR1THt+gYS2e4p6N+eQtcVlVK7pc9oHilrlQ0iatJduRx1+iiv6KBsQdHxEraB/BX/vf7Z3r81pAlEYgN8VaQURr3i/x7smahObatKcTppmOv3/P6gzSUs2GQMuLBvT8nwVYQ7MHtjds9Cri99kxRXoFTXNykCOaiY5204s64tzsiSeDWk2OeJlU84Xy5pMtq2LNqJQIB7rQRaNeGyCiPXTxKv1Ice1Trw6Iuewgycq+o3kzLHGg3xhbDmpZKPtsemUeEYD0SsTz2hhr3bRaq6+Ee9Hp9lrZbDXDfFYGQpc2H7tvdq4bHZuaa+FNkhe4aWvy+cbQYkx8dgAz7WvzTvylOiVPIfS9BSUuFp5TKA0TtLkL3dTHOLJ2CCeCUVSjHhd7pcuowOZkw+v9ERyJahySjyWwqN5k5GAemN/+uhBDvGxSPvx3F7aJGb5eQgAM514KyhkMeKdACiajISlZ8DV4nl0SahUJ57eaJ8wCsIoV3b0TBlKtQzi/bglSdJtqJWnSOgTKNZPUxRMKOcwks/eQL1zkq+AN1CpkWyLId7CgCSrtfAmqiOSq4kDHfslyeNt5BnJxbQPUK9tMpJutIFqyRxFYXkNtQY6RUPPQ6Gzc0ZRMcwrqFKcUpQ+FaGGlaWX3mNDqZQNipp+eobQ5uYi4aFjkwq5hJfOqA9fW3oHbjPw5dA78D0O5MjEgRyb/yqQfyb9lsqmttf9d1Lt5/25tk83sUZg1cY9qfZrfoUnRz5I6uVuDPnKjNQzCpBseM5IPfkT1e0E8bJlzaBoGNOmThxmfkQw/uvJ2bQIWDZFodYDWmniTYeQ5ewTcfTdY3BdnWRjo9bD8Z733RZVSJIgTs7BH0nZodhu07ZqxNEgBz/pzOptPCl9MfXa7R1JcKdPB2dwVTr8QQuQocfIpQ/wUskZNA0KheXMvNP3GJDVrxHejN/hxH9qVFy2iH3GjFzLrwiropPr9ZU08ywFNiphv4IbiYQXx69z5GJjrwJ0Coat1l7fCnF1htJqitkJPJwlgsWhHfpYVEYYLXdPvnXpQ42RIP+dcvvMNuSsD2SnkhbP8AxLYHGnKSfzruBvIBjJcgY/6098ygwq85SLahXRoiF/dgP+tm5mD1GmsqO/WE/gGzgH6mRwiBtynYZv6VMcqGjTYZi5Fi56yTbC1mTpFzjUfEGexDtMjh7y6THJAj20ZUzyJN6FLYe6JPz/RxDR18hP7RICMiP6axfmyyPEWhCyviFv9jZoxXQuE6Y+YwRB1QIjD+li8De/90JUyLFrCBt7RLLahFi00gnxHv8sAkgtaT+2W0NYyaZH4mXzw6fcW0AQm9R+RQSxC5yBKz/dDPMRb6+YdW/NVQipWokcPWjiGHTpQe7cgbD5Zd0m0jc4BludyO5aJQRz0Vt1cRxONes4TmksFovFYrFYLBaLxWKxWCwWi70HvwGhTEhgIqn9ZQAAAABJRU5ErkJggg==",
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

                        swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: accountAddress2, privateKey: accountPrivateKey2) { [self] result, error in
                            XCTAssertNil(error, "setUser should not produce an error")
                            XCTAssertNotNil(result, "setUser should produce a result")
                            
                            swiftBlade.associateToken(
                                tokenIdOrCampaign: tokenId
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
                                
                                swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: accountAddress, privateKey: accountPrivateKey) { [self] result, error in
                                    XCTAssertNil(error, "setUser should not produce an error")
                                    XCTAssertNotNil(result, "setUser should produce a result")
                                    
                                    swiftBlade.transferTokens(
                                        tokenAddress: tokenId,
                                        receiverAddress: accountAddress2,
                                        amountOrSerial: "1",
                                        memo: "transfer NFT in Test"
                                    ) { result, error in
                                        XCTAssertNil(error, "transferTokens should not produce an error")
                                        XCTAssertNotNil(result, "GetTradeUrl should produce a result")

                                        expectation7.fulfill()
                                    }
                                    expectation6.fulfill()
                                }
                                expectation5.fulfill()
                            }
                            expectation4.fulfill()
                        }
                        expectation3.fulfill()
                    }
                    expectation2.fulfill()
                } else {
                    XCTFail("no tokenData.tokenId")
                }
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5, expectation6, expectation7], timeout: 120.0)
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
        let expectation1 = XCTestExpectation(description: "ContractCallFunction should fail as no user set")
        let expectation2 = XCTestExpectation(description: "setUser should complete")
        let expectation3 = XCTestExpectation(description: "ContractCallFunction should complete")

        var contractFunctionName = "set_message"
        if (chainId == .ETHEREUM_SEPOLIA) {
            contractFunctionName = "setMood"
        }
            
        let parameters = swiftBlade.createContractFunctionParameters().addString(value: "Hello Swift test")
        swiftBlade.contractCallFunction(
            contractAddress: contractAddress, functionName: contractFunctionName, params: parameters, gas: 1_000_000, usePaymaster: false
        ) { result, error in
            XCTAssertNotNil(error, "ContractCallFunction should produce an error")
            XCTAssertNil(result, "ContractCallFunction should not produce a result")

            self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: self.accountAddress, privateKey: self.accountPrivateKey) { result, error in
                XCTAssertNil(error, "setUser should not produce an error")
                XCTAssertNotNil(result, "setUser should produce a result")
        
                self.swiftBlade.contractCallFunction(
                    contractAddress: self.contractAddress, functionName: contractFunctionName, params: parameters, gas: 1_000_000, usePaymaster: false
                ) { result, error in
                    XCTAssertNil(error, "ContractCallFunction should not produce an error")
                    XCTAssertNotNil(result, "ContractCallFunction should produce a result")

                    
                    if let transactionReceiptData = result {
                        XCTAssertEqual(transactionReceiptData.status.lowercased(), "SUCCESS".lowercased(), "TransactionReceiptData should have a 'SUCCESS' status")
                    } else {
                        XCTFail("Result should be a String (transaction ID)")
                    }
                    expectation3.fulfill()
                }
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }

        wait(for: [expectation1, expectation2, expectation3], timeout: 60.0)
    }

    func testContractCallQueryFunction() {
        let expectation1 = XCTestExpectation(description: "ContractCallQueryFunction should not complete")
        let expectation2 = XCTestExpectation(description: "setUser should complete")
        let expectation3 = XCTestExpectation(description: "ContractCallFunction should complete")
        let expectation4 = XCTestExpectation(description: "ContractCallQueryFunction should complete")
        
        var contractFunctionName = "set_message"
        var contractQueryFunctionName = "get_message"
        if (chainId == .ETHEREUM_SEPOLIA) {
            contractFunctionName = "setMood"
            contractQueryFunctionName = "getMood"
        }
        
        let randString = randomString(length: 10)

        swiftBlade.contractCallQueryFunction(
            contractAddress: contractAddress, functionName: contractQueryFunctionName, params: swiftBlade.createContractFunctionParameters(), gas: 150_000, usePaymaster: false, returnTypes: ["string", "int32"]
        ) { result, error in
            XCTAssertNotNil(error, "ContractCallQueryFunction should produce an error")
            XCTAssertNil(result, "ContractCallQueryFunction should not produce a result")

            self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: self.accountAddress, privateKey: self.accountPrivateKey) { result, error in
                XCTAssertNil(error, "setUser should not produce an error")
                XCTAssertNotNil(result, "setUser should produce a result")
                
                let parameters = self.swiftBlade.createContractFunctionParameters().addString(value: randString)
                self.swiftBlade.contractCallFunction(
                    contractAddress: self.contractAddress, functionName: contractFunctionName, params: parameters, gas: 1_000_000, usePaymaster: false
                ) { result, error in
                    XCTAssertNil(error, "ContractCallFunction should not produce an error")
                    XCTAssertNotNil(result, "ContractCallFunction should produce a result")

                    if let transactionReceiptData = result {
                        XCTAssertEqual(transactionReceiptData.status.lowercased(), "SUCCESS".lowercased(), "TransactionReceiptData should have a 'SUCCESS' status")
                        
                        self.swiftBlade.contractCallQueryFunction(
                            contractAddress: self.contractAddress, functionName: contractQueryFunctionName, params: self.swiftBlade.createContractFunctionParameters(), gas: 150_000, usePaymaster: false, returnTypes: ["string", "int32"]
                        ) { result, error in
                            XCTAssertNil(error, "ContractCallQueryFunction should not produce an error")
                            XCTAssertNotNil(result, "ContractCallQueryFunction should produce a result")

                            if let contractQueryData = result {
//                                XCTAssertGreaterThan(contractQueryData.gasUsed, 0, "Used gas should be grater than 0")
                                XCTAssertEqual(contractQueryData.values.count, 2, "Should return 2 values")
                                XCTAssertEqual(contractQueryData.values[0].type, "string", "Should equeal returnTypes")
                                XCTAssertEqual(contractQueryData.values[0].value, randString, "Should be exact string what we set before")
                                XCTAssertEqual(contractQueryData.values[1].type, "int32", "Should equeal returnTypes")
                            } else {
                                XCTFail("Result should be a String (transaction ID)")
                            }
                            expectation4.fulfill()
                        }
                    } else {
                        XCTFail("Result should be a String (transaction ID)")
                    }
                    expectation3.fulfill()
                }
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 30.0)
    }
    
    func testSign() {
        let expectation1 = XCTestExpectation(description: "Sign should fail as user not set")
        let expectation2 = XCTestExpectation(description: "setUser should complete")
        let expectation3 = XCTestExpectation(description: "Sign should complete")
        let expectation4 = XCTestExpectation(description: "Sign should complete (likeEthers)")
        
        swiftBlade.sign(encodedMessage: message, encoding: .utf8, likeEthers: false) { result, error in
            XCTAssertNotNil(error, "Sign should produce an error")
            XCTAssertNil(result, "Sign should not produce a result")

            self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: self.accountAddress, privateKey: self.accountPrivateKey) { result, error in
                XCTAssertNil(error, "setUser should not produce an error")
                XCTAssertNotNil(result, "setUser should produce a result")

                self.swiftBlade.sign(encodedMessage: self.message, encoding: .utf8, likeEthers: true) { result, error in
                    XCTAssertNil(error, "Sign (likeEthers) should not produce an error")
                    XCTAssertNotNil(result, "Sign (likeEthers) should produce a result")

                    if let signMessageData = result {
                        XCTAssertNotNil(signMessageData.signedMessage, "Signed message should not be nil")
                        XCTAssertEqual(signMessageData.signedMessage, "25de7c26ecfa4f28d8b96a95cf58ea7088a72a66b311c796090cb4c7d58c11217b4a7b174b4c31b90c3babb00958b2120274380404c4f1196abe3614df3741561b", "Signed message should be valid signature")
                        
                    } else {
                        XCTFail("Result should be of type SignMessageData")
                    }
                    
                    if (!self.isSkippingChain(.ETHEREUM_SEPOLIA)) {
                        self.swiftBlade.sign(encodedMessage: self.message, encoding: .utf8, likeEthers: false) { result, error in
                            XCTAssertNil(error, "Sign should not produce an error")
                            XCTAssertNotNil(result, "Sign should produce a result")
            
                            if let signMessageData = result {
                                XCTAssertNotNil(signMessageData.signedMessage, "Signed message should not be nil")
                                XCTAssertEqual(signMessageData.signedMessage, "27cb9d51434cf1e76d7ac515b19442c619f641e6fccddbf4a3756b14466becb6992dc1d2a82268018147141fc8d66ff9ade43b7f78c176d070a66372d655f942", "Signed message should be valid signature")
                            } else {
                                XCTFail("Result should be of type SignMessageData")
                            }
                            expectation4.fulfill()
                        }
                    } else {
                        expectation4.fulfill()
                    }
                    expectation3.fulfill()
                }
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 20.0)
    }

    func testVerify() {
        let expectation1 = XCTestExpectation(description: "Sign should fail as user not set")
        let expectation2 = XCTestExpectation(description: "setUser should complete")
        let expectation3 = XCTestExpectation(description: "Sign should complete")
        let expectation4 = XCTestExpectation(description: "Sign should complete")
        
        swiftBlade.sign(encodedMessage: message, encoding: .utf8, likeEthers: false) { result, error in
            XCTAssertNotNil(error, "Sign should produce an error")
            XCTAssertNil(result, "Sign should not produce a result")

            self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: self.accountAddress, privateKey: self.accountPrivateKey) { result, error in
                XCTAssertNil(error, "setUser should not produce an error")
                XCTAssertNotNil(result, "setUser should produce a result")

                self.swiftBlade.sign(encodedMessage: self.message, encoding: .utf8, likeEthers: false) { result, error in
                    XCTAssertNil(error, "Sign should not produce an error")
                    XCTAssertNotNil(result, "Sign should produce a result")

                    if let signMessageData = result {
                        self.swiftBlade.verify(encodedMessage: self.message, encoding: .utf8, signature: signMessageData.signedMessage, addressOrPublicKey: self.accountPublicKey) { verifyResult, verifyError in
                            XCTAssertNil(verifyError, "Verify should not produce an error")
                            XCTAssertNotNil(verifyResult, "Verify should produce a result")

                            if let verifyMessageData = verifyResult {
                                XCTAssertTrue(verifyMessageData.valid, "Message should be valid after verification")
                            } else {
                                XCTFail("Verify result should be of type SignVerifyMessageData")
                            }
                            expectation4.fulfill()
                        }
                        
                        
                    } else {
                        XCTFail("Result should be of type SignMessageData")
                    }
                    expectation3.fulfill()
                }
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 20.0)
    }

    func testGetParamsSignature() {
        let expectation1 = XCTestExpectation(description: "searchAccounts should complete")
        let expectation2 = XCTestExpectation(description: "setUser should complete")
        let expectation3 = XCTestExpectation(description: "GetParamsSignature should complete")

        swiftBlade.searchAccounts(accountPrivateKey) { result, error in
            XCTAssertNil(error, "searchAccounts should not produce an error")
            XCTAssertNotNil(result, "searchAccounts should produce a result")
            
            if let account = result?.accounts[0] {
                let parameters = self.swiftBlade.createContractFunctionParameters()
                    .addAddress(value: account.evmAddress)
                    .addUInt64Array(value: [300_000, 300_000])
                    .addUInt64Array(value: [6])
                    .addUInt64Array(value: [2])
                
                self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: self.accountAddress, privateKey: self.accountPrivateKey) { result, error in
                    XCTAssertNil(error, "setUser should not produce an error")
                    XCTAssertNotNil(result, "setUser should produce a result")
                    
                    
                    self.swiftBlade.getParamsSignature(
                        params: parameters
                    ) { result, error in
                        XCTAssertNil(error, "GetParamsSignature should not produce an error")
                        XCTAssertNotNil(result, "GetParamsSignature should produce a result")
                        
                        if let splitSignatureData = result {
                            XCTAssertEqual(splitSignatureData.v, 27, "SplitSignatureData should be valid v")
                            XCTAssertEqual(splitSignatureData.r, "0x021d38b66ef6536312bd157def439681d0dcd73d3ee526a84f8966dec0195b71", "SplitSignatureData should be valid r")
                            XCTAssertEqual(splitSignatureData.s, "0x692a529988713c06b515710837e2b49735db1468224f463427bbdfceb5ce617f", "SplitSignatureData should be valid s")
                        } else {
                            XCTFail("Result should be of type SignMessageData")
                        }
                        
                        expectation3.fulfill()
                    }
                    expectation2.fulfill()
                }
                
                expectation1.fulfill()
            }
        }

        wait(for: [expectation1, expectation2, expectation3], timeout: 20.0)
    }

    func testSplitSignature() {
        let expectation1 = XCTestExpectation(description: "setUser should complete")
        let expectation2 = XCTestExpectation(description: "Sign should complete")
        let expectation3 = XCTestExpectation(description: "Sign should complete (likeEthers)")

        self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: self.accountAddress, privateKey: self.accountPrivateKey) { result, error in
            XCTAssertNil(error, "setUser should not produce an error")
            XCTAssertNotNil(result, "setUser should produce a result")

            self.swiftBlade.sign(encodedMessage: self.message, encoding: .utf8, likeEthers: true) { result, error in
                XCTAssertNil(error, "Sign should not produce an error")
                XCTAssertNotNil(result, "Sign should produce a result")

                if let signMessageData = result {
                    XCTAssertNotNil(signMessageData.signedMessage, "Signed message should not be nil")
                    XCTAssertEqual(signMessageData.signedMessage, "25de7c26ecfa4f28d8b96a95cf58ea7088a72a66b311c796090cb4c7d58c11217b4a7b174b4c31b90c3babb00958b2120274380404c4f1196abe3614df3741561b", "Signed message should be valid signature")
                    
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

                        expectation3.fulfill()
                    }
                } else {
                    XCTFail("Result should be of type SignMessageData")
                }
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2, expectation3], timeout: 20.0)
    }

    func testSchedule() {
        if (isSkippingChain(.ETHEREUM_MAINNET, "Scheduled transaction currently implemented for Hedera")) {
            return
        }
        
        let expectation1 = XCTestExpectation(description: "setUser should complete")
        let expectation2 = XCTestExpectation(description: "createScheduleTransaction should complete")
        let expectation3 = XCTestExpectation(description: "signScheduleId should complete")
        
        swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: self.accountAddress, privateKey: self.accountPrivateKey) { result, error in
            XCTAssertNil(error, "setUser should not produce an error")
            XCTAssertNotNil(result, "setUser should produce a result")
            
            self.swiftBlade.createScheduleTransaction(
                type: .TRANSFER,
                transfers: [
                    ScheduleTransactionTransferHbar(sender: self.accountAddress, receiver: self.accountAddress2, value: Int.random(in: 100000...1000000)),
                    ScheduleTransactionTransferToken(sender: self.accountAddress, receiver: self.accountAddress2, tokenId: self.tokenAddress, value: 3)
                ],
                usePaymaster: false
            ) { (result: CreateScheduleData?, error: BladeJSError?) in
                XCTAssertNil(error, "createScheduleTransaction should not produce an error")
                XCTAssertNotNil(result, "createScheduleTransaction should produce a result")
                
                if let resultData = result {
                    XCTAssertNotNil(resultData.scheduleId, "scheduleId should present")
                    
                    self.swiftBlade.signScheduleId(
                        scheduleId: resultData.scheduleId,
                        receiverAccountAddress: "",
                        usePaymaster: false
                    ) { result, error in
                        XCTAssertNotNil(error, "signScheduleId should produce an error")
                        XCTAssertNil(result, "signScheduleId should not produce a result")
                        expectation3.fulfill()
                    }
                } else {
                    XCTFail("no scheduleId")
                }
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2, expectation3], timeout: 30.0)
    }
    
    func testStakeAccount() { // hedera only
        if (isSkippingChain(.ETHEREUM_SEPOLIA, "Skipping because staking now only for Hedera")) {
            return
        }
        
        let expectation1 = XCTestExpectation(description: "GetNodeList should complete")
        let expectation2 = XCTestExpectation(description: "StakeAccount should fail as no user set")
        let expectation3 = XCTestExpectation(description: "setUser should complete")
        let expectation4 = XCTestExpectation(description: "StakeAccount should complete")

        swiftBlade.getNodeList() { result, error in
            XCTAssertNil(error, "getNodeList should not produce an error")
            XCTAssertNotNil(result, "getNodeList should produce a result")
            
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

            self.swiftBlade.stakeToNode(nodeId: -1) { result, error in
                XCTAssertNotNil(error, "stakeToNode should produce an error")
                XCTAssertNil(result, "stakeToNode should not produce a result")

                self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: self.accountAddress, privateKey: self.accountPrivateKey) { result, error in
                    XCTAssertNil(error, "setUser should not produce an error")
                    XCTAssertNotNil(result, "setUser should produce a result")

                    self.swiftBlade.stakeToNode(nodeId: -1) { result, error in
                        XCTAssertNil(error, "stakeToNode should not produce an error")
                        XCTAssertNotNil(result, "stakeToNode should produce a result")

                        if let transferData = result as TransactionReceiptData? {
                            XCTAssertNotNil(transferData.status, "TransferData should have status")
                            XCTAssertNil(transferData.contractId, "TransferData should have contractId")
                            XCTAssertNotNil(transferData.topicSequenceNumber, "TransferData should have topicSequenceNumber")
                            XCTAssertNotNil(transferData.totalSupply, "TransferData should have totalSupply")
                            XCTAssertNotNil(transferData.serials, "TransferData should have serials")
                        } else {
                            XCTFail("Result should be of type TransferData")
                        }

                        expectation4.fulfill()
                    }
                    expectation3.fulfill()
                }
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 30.0)
    }
    
    func testGetTokenInfo() {
        let expectation1 = XCTestExpectation(description: "GetTokenInfo (nft) should complete")
        let expectation2 = XCTestExpectation(description: "GetTokenInfo (ft) should complete")

        swiftBlade.getTokenInfo(tokenAddress: nftAddress, serial: "1") { result, error in
            XCTAssertNil(error, "getTokenInfo should not produce an error")
            XCTAssertNotNil(result, "getTokenInfo should produce a result")

            if let tokenInfoData = result {
                XCTAssertNotNil(tokenInfoData.token, "tokenInfoData token should not be nil")
                XCTAssertNotNil(tokenInfoData.nft, "tokenInfoData nft should not be nil")
                XCTAssertNotNil(tokenInfoData.metadata, "tokenInfoData metadata should not be nil")
                XCTAssertNotNil(tokenInfoData.nft?.token_id, "tokenInfoData.nft.token_id should not be nil")
                XCTAssertNotNil(tokenInfoData.nft?.serial_number, "tokenInfoData.nft.serial_number should not be nil")
                XCTAssertNotNil(tokenInfoData.metadata?.author, "tokenInfoData.metadata.author should not be nil")
                XCTAssertEqual(tokenInfoData.metadata?.author, "GaryDu", "tokenInfoData.metadata.author should match")
                
                self.swiftBlade.getTokenInfo(tokenAddress: self.tokenAddress, serial: "") { result, error in
                    XCTAssertNil(error, "getTokenInfo should not produce an error")
                    XCTAssertNotNil(result, "getTokenInfo should produce a result")

                    if let tokenInfoData = result {
                        XCTAssertNotNil(tokenInfoData.token, "tokenInfoData token should not be nil")
                        XCTAssertNil(tokenInfoData.nft, "tokenInfoData nft should not be nil")
                        XCTAssertNil(tokenInfoData.metadata, "tokenInfoData metadata should not be nil")
                        XCTAssertEqual(tokenInfoData.token.token_id, self.tokenAddress, "tokenInfoData.nft.token_id should not be nil")
                    } else {
                        XCTFail("Result should be of type tokenInfoData")
                    }
                    expectation2.fulfill()
                }
            } else {
                XCTFail("Result should be of type tokenInfoData")
            }
            expectation1.fulfill()
        }
        wait(for: [expectation1, expectation2], timeout: 20.0)
    }
    
    func testSwapTokens() {
        let expectation1 = XCTestExpectation(description: "setUser should complete")
        let expectation2 = XCTestExpectation(description: "SwapTokens should complete")
        let expectation3 = XCTestExpectation(description: "SwapTokens should fail")

        var accountIdOrEmail = ""
        var privateKey = ""
        var sourceCurrency = ""
        var targetCurrency = ""
        var amount: Double = 0
        var serviceId = ""
        
        if (self.chainId == .HEDERA_TESTNET) {
            accountIdOrEmail = self.accountAddress2;
            privateKey = self.accountPrivateKey2;
            sourceCurrency = "HBAR"
            targetCurrency = "SAUCE"
            amount = 0.01
            serviceId = "saucerswap"
        }
        if (self.chainId == .ETHEREUM_SEPOLIA) {
            accountIdOrEmail = self.accountAddress;
            privateKey = self.accountPrivateKey;
            sourceCurrency = "USDC"
            targetCurrency = "EURC"
            amount = 0.05
            serviceId = "uniswap"
        }
        
        
        self.swiftBlade.setUser(accountProvider: .PrivateKey, accountIdOrEmail: accountIdOrEmail, privateKey: privateKey) { result, error in
            XCTAssertNil(error, "setUser should not produce an error")
            XCTAssertNotNil(result, "setUser should produce a result")
            
            self.swiftBlade.swapTokens(
                sourceCode: sourceCurrency,
                sourceAmount: amount,
                targetCode: targetCurrency,
                slippage: 0.5,
                serviceId: serviceId
            ) { result, error in
                XCTAssertNil(error, "SwapTokens should not produce an error")
                XCTAssertNotNil(result, "SwapTokens should produce a result")

                if let resultData = result {
                    XCTAssertNotNil(resultData.success, "resultData.success should present")
                    XCTAssertEqual(resultData.success, true, "resultData.success should be true")
                } else {
                    XCTFail("no resultData.success")
                }

                self.swiftBlade.swapTokens(
                    sourceCode: "USDC",
                    sourceAmount: 0.00001,
                    targetCode: "HBAR",
                    slippage: 0.5,
                    serviceId: "unknown-service"
                ) { result, error in
                    XCTAssertNotNil(error, "SwapTokens should produce an error")
                    XCTAssertNil(result, "SwapTokens should not produce a result")

                    expectation3.fulfill()
                }
                expectation2.fulfill()
            }
            expectation1.fulfill()
        }

        wait(for: [expectation1, expectation2, expectation3], timeout: 30.0)
    }

    func testExchangeGetQuotes() {
        let expectation1 = XCTestExpectation(description: "ExchangeGetQuotes BUY should complete")
        let expectation2 = XCTestExpectation(description: "ExchangeGetQuotes SELL should complete")
        let expectation3 = XCTestExpectation(description: "ExchangeGetQuotes SWAP should complete")

        let mainnetChain: KnownChainIds = chainId == .HEDERA_TESTNET ? .HEDERA_MAINNET : .ETHEREUM_MAINNET
        
        swiftBlade.initialize(apiKey: apiKeyMainnet, chainId: mainnetChain, dAppCode: dAppCode, bladeEnv: bladeEnv, force: true) { [self] result, error in
            XCTAssertNil(error, "Initialization should not produce an error")
            XCTAssertNotNil(result, "Initialization should produce a result")

            swiftBlade.exchangeGetQuotes(
                sourceCode: "EUR",
                sourceAmount: 50,
                targetCode: "ETH",
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
                    sourceCode: "ETH",
                    sourceAmount: 2,
                    targetCode: "USD",
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

    func testGetTradeUrl() {
        let expectation1 = XCTestExpectation(description: "GetTradeUrl should complete")
        let expectation2 = XCTestExpectation(description: "GetTradeUrl should complete")
        let expectation3 = XCTestExpectation(description: "GetTradeUrl should fail")
        let expectation4 = XCTestExpectation(description: "GetTradeUrl (like deprecated getC14url) should complete")

        let mainnetChain: KnownChainIds = chainId == .HEDERA_TESTNET ? .HEDERA_MAINNET : .ETHEREUM_MAINNET
        let codeByChain = chainId == .HEDERA_TESTNET ? "HBAR" : "ETH"
        let amountByChain: Double = chainId == .HEDERA_TESTNET ? 2000 : 2
        
        
        swiftBlade.initialize(apiKey: apiKeyMainnet, chainId: mainnetChain, dAppCode: dAppCode, bladeEnv: bladeEnv, force: true) { [self] result, error in
            XCTAssertNil(error, "Initialization should not produce an error")
            XCTAssertNotNil(result, "Initialization should produce a result")
            let redirectUrl = "redirect-url-here"
            
            swiftBlade.getTradeUrl(
                strategy: CryptoFlowServiceStrategy.BUY,
                accountAddress: accountAddress,
                sourceCode: "EUR",
                sourceAmount: 50,
                targetCode: codeByChain,
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
                    accountAddress: accountAddress,
                    sourceCode: codeByChain,
                    sourceAmount: amountByChain,
                    targetCode: "USD",
                    slippage: 0.5,
                    serviceId: "transak",
                    redirectUrl
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
                        accountAddress: accountAddress,
                        sourceCode: "EUR",
                        sourceAmount: 50,
                        targetCode: codeByChain,
                        slippage: 0.5,
                        serviceId: "unknown-service-id"
                    ) { result, error in
                        XCTAssertNotNil(error, "GetTradeUrl should produce an error")
                        XCTAssertNil(result, "GetTradeUrl should not produce a result")

                        // Add assertions for the result properties if needed
                        expectation3.fulfill()
                        
                        if (!self.isSkippingChain(.ETHEREUM_SEPOLIA)) {
                            // buy like deprecated method getC14url
                            self.swiftBlade.getTradeUrl(
                                strategy: CryptoFlowServiceStrategy.BUY,
                                accountAddress: self.accountAddress,
                                sourceCode: "USD",
                                sourceAmount: 1234,
                                targetCode: "KARATE",
                                slippage: 1,
                                serviceId: "c14"
                            ) { result, error in
                                XCTAssertNil(error, "GetTradeUrl should not produce an error")
                                XCTAssertNotNil(result, "GetTradeUrl should produce a result")
                                
                                if let integrationUrlData = result {
                                    XCTAssertEqual(integrationUrlData.url, "https://pay.c14.money/?clientId=00ce2e0a-ee66-4971-a0e9-b9d627d106b0&targetAssetId=057d6b35-1af5-4827-bee2-c12842faa49e&targetAssetIdLock=false&sourceCurrencyCode=USD&sourceAmount=1234&quoteAmountLock=false&targetAddress=0.0.1443&targetAddressLock=false", "url should be like that")
                                } else {
                                    XCTFail("Result should be of type transactionsHistoryData")
                                }
                                expectation4.fulfill()
                            }
                        } else {
                            expectation4.fulfill()
                        }
                    }
                }
            }
        }

        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 40.0)
    }
    
    private func setTestDataByChainId(chainId: KnownChainIds) {
        self.chainId = chainId
        switch chainId {
            case KnownChainIds.ETHEREUM_SEPOLIA:
                accountAddress = ethereumAddress
                accountPrivateKey = ethereumPrivateKey
                accountPublicKey = ethereumPublicKey
                accountAddress2 = ethereumAddress2
                accountPrivateKey2 = ethereumPrivateKey2
                accountMnemonic = ethereumMnemonic
                contractAddress = ethereumContractAddress
                tokenAddress = ethereumTokenAddress
                tokenAddress2 = ethereumTokenAddress2
                nftAddress = ethereumNftAddress
            case KnownChainIds.HEDERA_TESTNET:
                accountAddress = hederaAccountId1
                accountPrivateKey = hederaPrivateKey1
                accountPublicKey = hederaPublicKey1
                accountAddress2 = hederaAccountId2
                accountPrivateKey2 = hederaPrivateKey2
                accountMnemonic = hederaMnemonic
                contractAddress = hederaContractId
                tokenAddress = hederaTokenAddress
                tokenAddress2 = hederaTokenAddress2
                nftAddress = hederaNftAddress
            default:
                accountAddress = ""
                accountPrivateKey = ""
                accountPublicKey = ""
                accountAddress2 = ""
                accountPrivateKey2 = ""
                accountMnemonic = ""
                contractAddress = ""
                tokenAddress = ""
                tokenAddress2 = ""
                nftAddress = ""
        }
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    private func isSkippingChain(_ restrictedChain: KnownChainIds, _ message: String = "") -> Bool {
        let result = (restrictedChain == .ETHEREUM_SEPOLIA || restrictedChain == .ETHEREUM_MAINNET) && (chainId == .ETHEREUM_SEPOLIA || chainId == .ETHEREUM_MAINNET)
                  || (restrictedChain == .HEDERA_TESTNET || restrictedChain == .HEDERA_MAINNET) && (chainId == .HEDERA_TESTNET || chainId == .HEDERA_MAINNET)

        if (result && message != "") {
            print("############### SwiftBladeTest warning: Chain \(chainId). Skipping test part. Reason: \(message) ###############")
        }
        return result
    }
}

final class SwiftBladeTestsEthereum: SwiftBladeTestsHedera {
    override func setUp() {
        chainId = .ETHEREUM_SEPOLIA
        super.setUp()
    }
}

