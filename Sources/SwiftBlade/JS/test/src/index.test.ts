import {Client, ContractCallQuery, Hbar, Mnemonic} from "@hashgraph/sdk";
import {associateToken, checkResult, createToken, getTokenInfo, sleep} from "./helpers";
import {GET, getTransaction} from "../../src/ApiService";
import {Network} from "../../src/models/Networks";
import {isEqual} from "lodash";
import {Buffer} from "buffer";

const SDK = require("../../src");
require("dotenv").config();

global.fetch = require("node-fetch");

const {PrivateKey} = require("@hashgraph/sdk");
const {hethers} = require("@hashgraph/hethers");

const bladeSdk = window["bladeSdk"];
export const completionKey = "completionKey1";
const privateKey = process.env.PRIVATE_KEY; // ECDSA
const accountId = process.env.ACCOUNT_ID;

const privateKey2 = process.env.PRIVATE_KEY2; // ECDSA
const accountId2 = process.env.ACCOUNT_ID2;


test('bladeSdk defined', () => {
    expect(window["bladeSdk"]).toBeDefined()
});

test('bladeSdk.init', async () => {
    const result = await bladeSdk.init(process.env.API_KEY, process.env.NETWORK, process.env.DAPP_CODE, process.env.FINGERPRINT, completionKey);
    checkResult(result);
    expect(result.data.status).toEqual("success" );
});

test('bladeSdk.getBalance', async () => {
    let result = await bladeSdk.getBalance(accountId, completionKey);
    checkResult(result);

    expect(result.data).toHaveProperty("hbars");
    expect(result.data).toHaveProperty("tokens");
    expect(Array.isArray(result.data.tokens)).toEqual(true);

    // invalid accountId
    result = await bladeSdk.getBalance("0.0.0", completionKey);
    checkResult(result, false);
});

test('bladeSdk.transferHbars', async () => {
    let result = await bladeSdk.getBalance(accountId, completionKey);
    checkResult(result);
    const hbars = result.data.hbars;
    result = await bladeSdk.transferHbars(accountId, privateKey, accountId2, "1.5", completionKey);
    checkResult(result);

    expect(result.data).toHaveProperty("nodeId");
    expect(result.data).toHaveProperty("transactionHash");
    expect(result.data).toHaveProperty("transactionId");

    // wait for balance update
    await sleep(5_000);

    result = await bladeSdk.getBalance(accountId, completionKey);
    checkResult(result);
    expect(hbars).not.toEqual(result.data.hbars);

    // invalid signature
    result = await bladeSdk.transferHbars(accountId2, privateKey, accountId, "1.5", completionKey);
    checkResult(result, false);

    // parseFloat exception
    result = await bladeSdk.transferHbars(accountId, privateKey, accountId, "jhghjhgjghj", completionKey);
    checkResult(result, false);

}, 60_000);

test('bladeSdk.contractCallFunction', async () => {
    const contractId = process.env.CONTRACT_ID || "";
    expect(contractId).not.toEqual("");
    const client = Client.forTestnet();
    client.setOperator(accountId, privateKey);

    let result = await bladeSdk.init(process.env.API_KEY, process.env.NETWORK, process.env.DAPP_CODE, process.env.FINGERPRINT, completionKey);
    checkResult(result);

    let message = `Hello test ${Math.random()}`;
    let paramsEncoded = `[{"type":"string","value":["${message}"]}]`;
    result = await bladeSdk.contractCallFunction(contractId, "set_message", paramsEncoded, accountId, privateKey, 1000000, completionKey);
    checkResult(result);

    let contractCallQuery = new ContractCallQuery()
        .setContractId(contractId)
        .setGas(100000)
        .setFunction("get_message")
        .setQueryPayment(new Hbar(1));

    let contractCallQueryResult = await contractCallQuery.execute(client);
    expect(contractCallQueryResult.getString(0)).toEqual(message)


    message = `Sum test ${Math.random()}`;
    const num1 = 37;
    const num2 = 5;
    paramsEncoded = `[{"type":"string","value":["${message}"]},{"type":"tuple","value":["[{\\"type\\":\\"uint64\\",\\"value\\":[\\"${num1}\\"]},{\\"type\\":\\"uint64\\",\\"value\\":[\\"${num2}\\"]}]"]}]`;
    result = await bladeSdk.contractCallFunction(contractId, "set_numbers", paramsEncoded, accountId, privateKey, 1000000, completionKey);
    checkResult(result);


    contractCallQuery = new ContractCallQuery()
        .setContractId(contractId)
        .setGas(100000)
        .setFunction("get_sum")
        .setQueryPayment(new Hbar(1));

    contractCallQueryResult = await contractCallQuery.execute(client);
    expect(contractCallQueryResult.getString(0)).toEqual(message);
    expect(contractCallQueryResult.getUint64(1).toNumber()).toEqual(num1 + num2);


    // fail on wrong function params (CONTRACT_REVERT_EXECUTED)
    paramsEncoded = '[{"type":"string","value":["Sum test"]},{"type":"address","value":["0x65f17cac69fb3df1328a5c239761d32e8b346da0"]},{"type":"address[]","value":["0.0.49054496","0.0.49057744","0.0.48831080"]},{"type":"bytes32","value":["WzAsMSwyLDMsNCw1LDYsNyw4LDksMTAsMTEsMTIsMTMsMTQsMTUsMTYsMTcsMTgsMTksMjAsMjEsMjIsMjMsMjQsMjUsMjYsMjcsMjgsMjksMzAsMzFd"]},{"type":"uint8","value":["1"]},{"type":"int64","value":["64"]},{"type":"uint256","value":["256"]},{"type":"uint64[]","value":["1"]},{"type":"uint256[]","value":["1"]},{"type":"tuple","value":["[{\\"type\\":\\"string[]\\",\\"value\\":[\\"1\\"]}]"]},{"type":"tuple[]","value":["[{\\"type\\":\\"string[]\\",\\"value\\":[\\"1\\"]}]"]}]';
    result = await bladeSdk.contractCallFunction(contractId, "set_numbers", paramsEncoded, accountId, privateKey, 1000000, completionKey);
    checkResult(result, false);
    expect(result.error.reason.includes("CONTRACT_REVERT_EXECUTED")).toEqual(true);

    // fail on invalid json
    paramsEncoded = '[{"type":"string",""""""""]'
    result = await bladeSdk.contractCallFunction(contractId, "set_numbers", paramsEncoded, accountId, privateKey, 1000000, completionKey);
    checkResult(result, false);
    expect(result.error.reason.includes("Unexpected string in JSON")).toEqual(true);

    // fail on unknown param type
    paramsEncoded = `[{"type":"int1024[]","value":["${message}"]}]`;
    result = await bladeSdk.contractCallFunction(contractId, "set_numbers", paramsEncoded, accountId, privateKey, 1000000, completionKey);
    checkResult(result, false);
    expect(result.error.reason.includes('Type "int1024[]" not implemented on JS')).toEqual(true);

    //fail on low gas
    result = await bladeSdk.contractCallFunction(contractId, "set_message", paramsEncoded, accountId, privateKey, 1, completionKey);
    checkResult(result, false);
}, 120_000);

test('bladeSdk.transferTokens', async () => {
    const client = Client.forTestnet();
    client.setOperator(accountId, privateKey);

    const tokenName = "JEST Token Test";
    let result = await bladeSdk.getBalance(accountId, completionKey);
    checkResult(result);

    let tokenId = null;
    for (let i = 0; i < result.data.tokens.length; i++) {
        const tokenInfo = await getTokenInfo(result.data.tokens[i].tokenId);
        if (tokenInfo.name === tokenName) {
            tokenId = tokenInfo.token_id;
            break;
        }
    }

    if (!tokenId) {
        // Create token
        tokenId = await createToken(accountId, privateKey, tokenName);
    } else {
        // token exists
    }

    await associateToken(tokenId, accountId2, privateKey2);

    let account1Balance = await bladeSdk.getBalance(accountId, completionKey);
    checkResult(account1Balance);
    const account1TokenBalance = (account1Balance.data.tokens.find(token => token.tokenId === tokenId))?.balance || 0;
    let account2Balance = await bladeSdk.getBalance(accountId2, completionKey);
    checkResult(account2Balance);
    const account2TokenBalance = (account2Balance.data.tokens.find(token => token.tokenId === tokenId))?.balance || 0;

    const amount = 1;
    // invalid signature
    result = await bladeSdk.transferTokens(tokenId.toString(), accountId2, privateKey, accountId2, amount.toString(), completionKey);
    checkResult(result, false);

    // invalid tokenId
    result = await bladeSdk.transferTokens("invalid token id", accountId2, privateKey, accountId2, amount.toString(), completionKey);
    checkResult(result, false);

    result = await bladeSdk.transferTokens(tokenId.toString(), accountId, privateKey, accountId2, amount.toString(), completionKey);
    checkResult(result);
    expect(result.data).toHaveProperty("nodeId");
    expect(result.data).toHaveProperty("transactionHash");
    expect(result.data).toHaveProperty("transactionId");

    await sleep(5_000);

    account1Balance = await bladeSdk.getBalance(accountId, completionKey);
    checkResult(account1Balance);
    const account1TokenBalanceNew = (account1Balance.data.tokens.find(token => token.tokenId === tokenId))?.balance || 0;
    account2Balance = await bladeSdk.getBalance(accountId2, completionKey);
    checkResult(account2Balance);
    const account2TokenBalanceNew = (account2Balance.data.tokens.find(token => token.tokenId === tokenId))?.balance || 0;

    expect(account1TokenBalance).toEqual(account1TokenBalanceNew + amount);
    expect(account2TokenBalance).toEqual(account2TokenBalanceNew - amount);
}, 120_000);

test('bladeSdk.createAccount', async () => {
    let result = await bladeSdk.init(process.env.API_KEY, process.env.NETWORK, process.env.DAPP_CODE, process.env.FINGERPRINT, completionKey);
    checkResult(result);

    result = await bladeSdk.createAccount(completionKey);
    checkResult(result);

    expect(result.data).toHaveProperty("seedPhrase");
    expect(result.data).toHaveProperty("publicKey");
    expect(result.data).toHaveProperty("privateKey");
    expect(result.data).toHaveProperty("accountId");
    expect(result.data).toHaveProperty("evmAddress");

    await sleep(25_000);

    const accountInfo = await GET(Network.Testnet, `api/v1/accounts/${result.data.accountId}`);
    expect(result.data.evmAddress).toEqual(accountInfo.evm_address);

    result = await bladeSdk.init("wrong api key", process.env.NETWORK, process.env.DAPP_CODE, process.env.FINGERPRINT, completionKey);
    checkResult(result);

    result = await bladeSdk.createAccount(completionKey);
    checkResult(result, false);
}, 60_000);

test('bladeSdk.deleteAccount', async () => {
    let result = await bladeSdk.init(process.env.API_KEY, process.env.NETWORK, process.env.DAPP_CODE, process.env.FINGERPRINT, completionKey);
    checkResult(result);

    result = await bladeSdk.createAccount(completionKey);
    checkResult(result);
    const newAccountId = result.data.accountId;
    const newPrivateKey = result.data.privateKey;

    result = await bladeSdk.deleteAccount(newAccountId, newPrivateKey, accountId, accountId, privateKey, completionKey);
    checkResult(result);

    await sleep(15_000);
    result = await GET(Network.Testnet, `api/v1/accounts/${newAccountId}`);
    expect(result.deleted).toEqual(true);

    // invalid request (already deleted)
    result = await bladeSdk.deleteAccount(newAccountId, newPrivateKey, accountId, accountId, privateKey, completionKey);
    checkResult(result, false);
}, 60_000);

test('bladeSdk.getKeysFromMnemonic', async () => {
    const accountSample = {
        accountId: "0.0.49177063",
        privateKey: "3030020100300706052b8104000a0422042045224074f95b943a4ad8ce7f660db9593d1193d35b3808ecd2e7265caaa00a3d",
        publicKey: "302d300706052b8104000a03220002bdc4a7f2d365a0112867a79fa0acda12d59c00b115870b09e7e83c77a7728d95",
        seedPhrase: "service unable under gauge castle lawn orchard kitten chat produce anxiety top",
        evmAddress: "0x38e689ffa7ac5d9e5d2e3bd81eea564d4faf4921"
    }

    let result = await bladeSdk.getKeysFromMnemonic(accountSample.seedPhrase, false, completionKey);
    checkResult(result);

    expect(result.data).toHaveProperty("privateKey");
    expect(result.data).toHaveProperty("publicKey");
    expect(result.data).toHaveProperty("accounts");
    expect(result.data).toHaveProperty("evmAddress");
    expect(Array.isArray(result.data.accounts)).toEqual(true);
    expect(result.data.accounts.length).toEqual(0);

    expect(result.data.privateKey).toEqual(accountSample.privateKey);
    expect(result.data.publicKey).toEqual(accountSample.publicKey);
    expect(result.data.evmAddress).toEqual(accountSample.evmAddress);

    result = await bladeSdk.getKeysFromMnemonic(accountSample.seedPhrase, true, completionKey);
    checkResult(result);

    expect(result.data.accounts.length).toEqual(1);
    expect(result.data.accounts[0]).toEqual(accountSample.accountId);

    result = await bladeSdk.getKeysFromMnemonic("invalid seed phrase", true, completionKey);
    checkResult(result, false);

    result = await bladeSdk.getKeysFromMnemonic((await Mnemonic.generate12()).toString(), true, completionKey);
    checkResult(result);
    expect(result.data.accounts.length).toEqual(0);
}, 60_000);

test('bladeSdk.sign + signVerify', async () => {
    const message = "hello";
    const messageString = Buffer.from(message).toString("base64");

    const result = await bladeSdk.sign(messageString, privateKey, completionKey);
    checkResult(result);

    expect(result.data).toHaveProperty("signedMessage");
    expect(result.data.signedMessage).toEqual("bbc2f1c80fbbabb6e898c65d2e5a2a5ce3f3a04d4321b3d0095145019eedf99cf2e3a80fe88794f908cc95fdcdb0b8079de81bed6b053f7adcfe5a1c77560c50");

    const validationResult = bladeSdk.signVerify(messageString, result.data.signedMessage, PrivateKey.fromString(privateKey).publicKey.toStringRaw(), completionKey);
    checkResult(validationResult);
    expect(validationResult.data.valid).toEqual(true);

    expect(PrivateKey.fromString(privateKey).publicKey.verify(
        Buffer.from(message),
        Buffer.from(result.data.signedMessage, "hex")
    )).toEqual(true);

    //invalid private key
    let resultInvalid = await bladeSdk.sign(messageString, `privateKey`, completionKey);
    checkResult(resultInvalid, false);

    resultInvalid = bladeSdk.signVerify(messageString, "invalid signature", "invalid publicKey", completionKey);
    checkResult(resultInvalid, false);
});

test('bladeSdk.hethersSign', async () => {
    const message = "hello";
    const messageString = Buffer.from(message).toString("base64");

    let result = await bladeSdk.hethersSign(messageString, privateKey, completionKey);
    checkResult(result);

    expect(result.data).toHaveProperty("signedMessage");
    expect(result.data.signedMessage).toEqual("0x12509f194214661211b113c6a23029f4a8364fd4885918cc5943f2d784eb63661aded5c89825451fc1248b692e86479fa0dff50bf05caab20e56bb63e26559181c");

    const signerAddress = hethers.utils.verifyMessage(message, result.data.signedMessage);
    const wallet = new hethers.Wallet(privateKey);

    expect(signerAddress).toEqual(wallet.publicKey);

    // invalid calls
    result = await bladeSdk.hethersSign(messageString, "invalid privateKey", completionKey);
    checkResult(result, false);

    result = await bladeSdk.hethersSign(123, privateKey, completionKey);
    checkResult(result, false);
});

test('bladeSdk.splitSignature', async () => {
    const message = "hello";
    const messageString = Buffer.from(message).toString("base64");

    let result = await bladeSdk.hethersSign(messageString, privateKey, completionKey);
    checkResult(result);
    expect(result.data).toHaveProperty("signedMessage");
    const signature = result.data.signedMessage;

    result = await bladeSdk.splitSignature(result.data.signedMessage, completionKey);
    checkResult(result);

    const v: number = result.data.v;
    const r: string = result.data.r;
    const s: string = result.data.s;
    expect(signature).toEqual(hethers.utils.joinSignature({v, r, s}));

    // invalid signature
    result = await bladeSdk.splitSignature("invalid signature", completionKey);
    checkResult(result, false);
});

test('bladeSdk.getParamsSignature', async () => {
    let result = await bladeSdk.getParamsSignature('[{"type":"address","value":["0.0.48914498"]},{"type":"uint64[]","value":["300000","300000"]},{"type":"uint64[]","value":["6"]},{"type":"uint64[]","value":["2"]}]', privateKey, completionKey);
    checkResult(result);

    expect(result.data).toHaveProperty("v");
    expect(result.data).toHaveProperty("r");
    expect(result.data).toHaveProperty("s");

    expect(result.data.v).toEqual(28);
    expect(result.data.r).toEqual("0x9c46fd17727237e33e420b072e142a7dd0b4b1ffe2b983759c0e0db9bd0783b4");
    expect(result.data.s).toEqual("0x0706284b70f7d4228af3b356d6fa65120c2104af58a9b10b1a54a85356bd9e5c");

    // invalid paramsEncoded
    result = await bladeSdk.getParamsSignature('[{{{{{{{{{{{"]', privateKey, completionKey);
    checkResult(result, false);
});

test('bladeSdk.getTransactions', async () => {
    // make transaction
    let result = await bladeSdk.transferHbars(accountId, privateKey, accountId2, "1.5", completionKey);
    checkResult(result);

    expect(result.data).toHaveProperty("nodeId");
    expect(result.data).toHaveProperty("transactionHash");
    expect(result.data).toHaveProperty("transactionId");

    const transactionId = result.data.transactionId.replace("@", ".");
    await sleep(10_000);

    //get expected transaction
    result = await bladeSdk.getTransactions(accountId, "", "", completionKey);
    checkResult(result);

    expect(result.data).toHaveProperty("nextPage");
    expect(result.data).toHaveProperty("transactions");
    expect(Array.isArray(result.data.transactions)).toEqual(true);

    const txIdEqual = (txId1: string, txId2: string) => {
        return isEqual(
            txId1.split(".").map(num => parseInt(num, 10)),
            txId2.split(".").map(num => parseInt(num, 10))
        );
    };

    const nextPage = result.data.nextPage;
    const latestTransaction = result.data.transactions.find(tx => txIdEqual(transactionId, tx.transactionId.replaceAll("-", ".")));

    expect(latestTransaction !== null).toEqual(true);
    expect(latestTransaction).toHaveProperty("time");
    expect(latestTransaction).toHaveProperty("transfers");
    expect(Array.isArray(latestTransaction.transfers)).toEqual(true);
    expect(latestTransaction).toHaveProperty("nftTransfers");
    expect(latestTransaction).toHaveProperty("memo");
    expect(latestTransaction).toHaveProperty("transactionId");
    expect(txIdEqual(latestTransaction.transactionId.replaceAll("-", "."), transactionId)).toEqual(true);
    expect(latestTransaction).toHaveProperty("fee");
    expect(latestTransaction).toHaveProperty("type");
    expect(latestTransaction.type).toEqual("CRYPTOTRANSFER");


    //next page
    result = await bladeSdk.getTransactions(accountId, "", nextPage, completionKey);
    checkResult(result);

    // filter by transactionType
    result = await bladeSdk.getTransactions(accountId, "CRYPTOTRANSFER", "", completionKey);
    checkResult(result);

    // filter by transactionType and add custom plainData in response
    result = await bladeSdk.getTransactions(accountId, "CRYPTOTRANSFERTOKEN", "", completionKey);
    checkResult(result);

    if (result.data.transactions.length) {
        expect(result.data.transactions[0]).toHaveProperty("plainData");
        expect(result.data.transactions[0].plainData).toHaveProperty("type");
        expect(result.data.transactions[0].plainData).toHaveProperty("token_id");
        expect(result.data.transactions[0].plainData).toHaveProperty("account");
        expect(result.data.transactions[0].plainData).toHaveProperty("amount");
        console.log(result.data.transactions[0].plainData);
    }

    //invalid accountId
    result = await bladeSdk.getTransactions('0.dgsgsdgdsgdsgdsg', "", "", completionKey);
    checkResult(result, false);

    //invalid tx
    result = await getTransaction(Network.Testnet, "wrong tx id", accountId);
    expect(Array.isArray(result));
    expect(result.length).toEqual(0)

}, 30_000);
