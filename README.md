# HEDERA PAD
A launchpad for Hedera blockchain. 

## DEPLOY THE PAD 
 
### Set up the .env file
Set up the .env.to.fill :
- file the env vars with my account id and my private key
- rename the file to .env

### Install the lib
Run the following command to install the required libs 
```npm install````

### Deploy the smart contract
Run the following command to deploy the Hedera Launchpad factory and mint an initial supply of Hedera Launchpad token to your account
```npm run-script deploy```

## IDO PHASES
An IDO can be described as a succession of 8 phases 

### 1.CREATION 
A user ( Project creator ) can create an IDO ( or Pool ).

- 1 : Choose IDO schedule 
Project creator can choose a sale schedule ( depending on the availibilities )

- 2 : Configure IDO ( or Pool )
The project creator define the IDO settings : 
    - name
    - token ( the project token )
    - total supply ( total supply of project token at the end of the vesting process )
    - initial supply ( initial supply of token vested at the token listing )
    - quote token ( token used to buy the project token )
    - price ( amount of quote token used to buy an unit of project token )
    - registration time start ( by default the registration time is of a whole week starting at the registration time )
    - sale time start ( by default the sale duration is of 3 hours starting at sale start )
    - token listing
    - vesting 

- 3 : Create IDO ( or Pool )
Project creator must pay for the creation fee

### 2.REGISTRATION
Investors can register for the IDO during the registration period

### 3.SALE START
Purchase are allowed, investors can buy their token allocation during the sale period. Invested tokens are locked into the IDO escrow

### 4.SALE FCFS
Investors can buy remaining tokens without allocation limit ( last 30 minutes of the IDO if funded project tokens are still remaining in the pool )

### 5.SALE END
No more purchase is allowed

### 6.FUNDING
Project creator must fund the IDO pool with the full amount of sold token

### 7.WITHDRAWING
Project creator can withdraw the raised funds

### 8.CLAIMING
Investors can claim the project token allocation their bought during the sale ( according to the token vesting rule )


## SMART CONTRACTS
Two main smart contracts are involved into the Hedera Launchpad :
- A Launchpad Factory deployed at the launchpad creation. It is the core contract, it handles all of the further IDO initializations.
- A Launchpad Pool deployed at each IDO creation. A Launchpad Pool handles all of the operations related to a specific IDO. 


### INTERFACE DEFINITIONS
- LaunchpadFactory
    - createPool(name string, token address, initialSupply uint, totalSupply uint, quoteToken address, price uint256, registrationStart timestamp, registrationEnd timestamp, saleStart timestamp, saleEnd timestamp, listing timestamp)

- LaunchpadPool
    - pad address                                       # address of the pad the pool belongs to
    - mapping(address => uint256) public allocations    # mapping of the investors allocations
    - register(allocation uint256)                      # the investor register to the pool for a given allocation
    - buy(amount uint256)                               # the investor buy an amount or project tokens
    - claim(amount uint256)                             # the investor claim an amount of project tokens
    - fill()                                            # the owner fill the pool with project tokens