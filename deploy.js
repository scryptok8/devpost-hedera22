require("dotenv").config();

const {
    Client,
    PrivateKey,
    ContractCreateTransaction,
    ContractExecuteTransaction,
    FileCreateTransaction,
    ContractFunctionParameters,
    Hbar,
    AccountId,
    AccountCreateTransaction,
    TokenCreateTransaction,
    TokenType,
    TransactionRecordQuery,
    AccountBalanceQuery
} = require("@hashgraph/sdk");

// Import the compiled contract
const launchpadFactoryContract = require("./smartcontract/LaunchpadFactory.json");

async function main() {
    //Grab your Hedera testnet account ID and private key from your .env file
    const accountIdTest = AccountId.fromString(process.env.MY_ACCOUNT_ID);
    const accountKeyTest = PrivateKey.fromStringED25519(process.env.MY_PRIVATE_KEY);
   
    // If we weren't able to grab it, we should throw a new error
    if (accountIdTest == null ||
        accountKeyTest == null ) {
        throw new Error("Environment variables myAccountId and myPrivateKey must be present");
    }

    const client = Client.forPreviewnet();
    client.setOperator(accountIdTest, accountKeyTest);

   //Get the contract bytecode
    const bytecode = launchpadFactoryContract.data.bytecode.object;

    //Treasury Key
    const treasuryKey = await PrivateKey.generateED25519();

    //Create token treasury account
    const treasuryAccount = new AccountCreateTransaction()
            .setKey(treasuryKey)
            .setInitialBalance(new Hbar(100))
            .setAccountMemo("treasury account");
    
    //Submit the transaction to a Hedera network
    const submitAccountCreateTx = await treasuryAccount.execute(client);
    
    //Get the receipt of the transaction
    const newAccountReceipt = await submitAccountCreateTx.getReceipt(client);

    //Get the account ID from the receipt
    const treasuryAccountId = newAccountReceipt.accountId;

    console.log("The new account ID is " +treasuryAccountId);

    //Create a token to interact with
    const createToken =  new TokenCreateTransaction()
            .setTokenName("HEDERA LAUNCHPAD")
            .setTokenSymbol("HPAD")
            .setTokenType(TokenType.FungibleCommon)
            .setTreasuryAccountId(treasuryAccountId)
            .setInitialSupply(1000000);
            
    //Sign with the treasury key
    const signTokenTx = await createToken.freezeWith(client).sign(treasuryKey)
    
    //Submit the transaction to a Hedera network
    const submitTokenTx = await signTokenTx.execute(client);

    //Get the token ID from the receipt
    const tokenId = await (await submitTokenTx.getReceipt(client)).tokenId;

    //Log the token ID
    console.log("The new HEDERA LAUNCHPAD TOKEN (HPAD) ID is " +tokenId);

    //Create a file on Hedera and store the hex-encoded bytecode
    const fileCreateTx = new FileCreateTransaction()
        .setContents(bytecode);

    //Submit the file to the Hedera test network signing with the transaction fee payer key specified with the client
    const submitTx = await fileCreateTx.execute(client);

    //Get the receipt of the file create transaction
    const fileReceipt = await submitTx.getReceipt(client);

    //Get the file ID from the receipt
    const bytecodeFileId = fileReceipt.fileId;

    //Log the file ID
    console.log("The smart contract byte code file ID is " +bytecodeFileId)

    //Deploy the contract instance
    const contractTx = await new ContractCreateTransaction()
        //The bytecode file ID
        .setBytecodeFileId(bytecodeFileId)
        //The max gas to reserve
        .setGas(2000000);

    //Submit the transaction to the Hedera test network
    const contractResponse = await contractTx.execute(client);

    //Get the receipt of the file create transaction
    const contractReceipt = await contractResponse.getReceipt(client);

    //Get the smart contract ID
    const newContractId = contractReceipt.contractId;

    //Log the smart contract ID
    console.log("The smart contract ID is " + newContractId);

    //Associate the token to an account using the HEDERA LAUNCHPAD contract
    const associateToken = new ContractExecuteTransaction()
        //The contract to call
        .setContractId(newContractId)
        //The gas for the transaction
        .setGas(2000000)
        //The contract function to call and parameters to pass
        .setFunction("tokenAssociate", new ContractFunctionParameters()
             //The account ID to associate the token to
             .addAddress(accountIdTest.toSolidityAddress())
             //The token ID to associate to the account
             .addAddress(tokenId.toSolidityAddress()));

    //Sign with the account key and submit to the Hedera network
    const signTx = await associateToken.freezeWith(client).sign(accountKeyTest);
    
    //Submit the transaction
    const submitAssociateTx = await signTx.execute(client);

    //Get the receipt
    const txReceipt = await submitAssociateTx.getReceipt(client);

    //Get transaction status
    const txStatus = txReceipt.status

    console.log("The associate transaction was " + txStatus.toString())

    //Get the token associate transaction record
    const childRecords = new TransactionRecordQuery()
        //Set children equal to true for child records
        .setIncludeChildren(true)
        //The parent transaction ID
        .setTransactionId(submitAssociateTx.transactionId)
        .setQueryPayment(new Hbar(10))
        .execute(client);
    
    console.log("The transaction record for the associate transaction" +JSON.stringify((await childRecords).children));

    //The balance of the account
    const accountBalance = new AccountBalanceQuery()
        .setAccountId(accountIdTest)
        .execute(client);

    console.log("The " + tokenId + " should now be associated to my account: " + (await accountBalance).tokens.toString());

    //Transfer the new token to the account
    //Contract function params need to be in the order of the parameters provided in the tokenTransfer contract function
    const tokenTransfer = new ContractExecuteTransaction()
            .setContractId(newContractId)
            .setGas(2000000)
            .setFunction("tokenTransfer", new ContractFunctionParameters()
                    //The ID of the token
                    .addAddress(tokenId.toSolidityAddress())
                    //The account to transfer the tokens from
                    .addAddress(treasuryAccountId.toSolidityAddress())
                    //The account to transfer the tokens to
                    .addAddress(accountIdTest.toSolidityAddress())
                    //The number of tokens to transfer
                    .addInt64(1000000));

    //Sign the token transfer transaction with the treasury account to authorize the transfer and submit
    const signTokenTransfer = await tokenTransfer.freezeWith(client).sign(treasuryKey);

    //Submit transfer transaction
    const submitTransfer = await signTokenTransfer.execute(client);

    //Get transaction status
    const transferTxStatus = await (await submitTransfer.getReceipt(client)).status;

    //Get the transaction status
    console.log("The transfer transaction status " +transferTxStatus.toString());

    //Verify your account received the 1000000 HPAD tokens
    const newAccountBalance = new AccountBalanceQuery()
            .setAccountId(accountIdTest)
            .execute(client);

    console.log("My new account balance is " +(await newAccountBalance).tokens.toString());
}

void main();