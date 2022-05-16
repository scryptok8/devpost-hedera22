// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./ILaunchpadPool.sol";
import "./HederaTokenService.sol";

/**
 * @title LaunchpadPool
 * @dev Project pools
 */
contract LaunchpadPool is ILaunchpadPool, HederaTokenService  {
    address factory;
    address owner;
    string name;
    address poolToken;
    address quoteToken;
    int64 price;
    int64 initialSupply;
    int64 totalSupply;
    mapping(address => int64) allocations;
    mapping(address => int64) funds;
    mapping(address => int64) claims;

    constructor() { 
        factory = msg.sender;
    }

    function initialize (
        address _owner, 
        string calldata _name, 
        address _poolToken, 
        address _quoteToken,
        int64 _price, 
        int64 _initialSupply, 
        int64 _totalSupply
    ) override public returns (bool success) {
        owner = _owner;
        name = _name;
        poolToken = _poolToken;
        quoteToken = _quoteToken;
        price = _price;
        initialSupply = _initialSupply;
        totalSupply = _totalSupply;

        success = true;
    }
    
    /**
     * @dev Fund pool token to the pool
     */
    function fund(int64 amount) override external returns(bool) { 
        require(msg.sender == owner, "forbidden");
        
        // TODO: require fund conditions

        // transfer tokens to pool
        HederaTokenService.transferToken(poolToken, address(this), msg.sender, amount);

        return true;
    }

    /**
     * @dev Withdraw quote token from the pool
     */
    function withdraw(int64 amount) override external returns(bool) { 
        require(msg.sender == owner, "forbidden");

        // TODO: require withdraw conditions

        // transfer tokens to pool
        HederaTokenService.transferToken(poolToken, address(this), msg.sender, amount);

        return true;
    }

    /**
     * @dev Register to the pool
     * @param allocation amount of pool token allocated to the subscriber
     */
    function register(int64 allocation) override external returns(bool) { 
        allocations[msg.sender] = allocation;

        return true;
    }

    /**
     * @dev Buy amount of pool token
     * @param amount amount of pool token to buy from the pool
     */
    function buy(int64 amount) override external returns(bool) { 
        require(allocations[msg.sender] != 0, "no allocation for sender");
        require(amount <= allocations[msg.sender] - funds[msg.sender], "buy amount is too high for sender allocation");
        
        // update total bought amount
        funds[msg.sender] += amount;

        // transfer tokens to sender
        int response = HederaTokenService.transferToken(quoteToken, msg.sender, address(this), amount);

        if (response != HederaResponseCodes.SUCCESS) {
            revert ("Transfer Failed");
        }

        return true;
    }

    /**
     * @dev Claim amount of pool token from the pool
     * @param amount amount of pool token to claim from the pool
     */
    function claim(int64 amount) override external returns(bool) { 
        require(allocations[msg.sender] != 0, "no allocation for sender");

        int64 totalClaimable = funds[msg.sender] / price;
        int64 claimable = totalClaimable - claims[msg.sender]; 

        require(amount <= claimable, "claimed amount is too high for sender allocation");

        // update total claimed amount
        claims[msg.sender] += amount;

        // transfer tokens to sender
        int response = HederaTokenService.transferToken(poolToken, msg.sender, address(this), amount);

        if (response != HederaResponseCodes.SUCCESS) {
            revert ("Transfer Failed");
        }

        return true;
    }
}