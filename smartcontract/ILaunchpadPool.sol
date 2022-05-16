// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


/** 
 * @title ILaunchpadPool
 * @dev LaunchpadPool interface
 */
interface ILaunchpadPool {

    /**
     * @dev Initialize the pool
     * @param owner funder of the pool
     * @param name name of the pool
     * @param poolToken address of the pool token
     * @param quoteToken address of the quote token
     * @param price price of an unit of pool token in quote token
     * @param initialSupply initial amount of pool token initially vested by investors
     * @param totalSupply final amount of pool token vested at the end of vesting process
     */
    function initialize(
        address owner, 
        string calldata name,
        address poolToken,
        address quoteToken,
        int64 price,
        int64 initialSupply,
        int64 totalSupply
    ) external returns (bool);


    /**
     * @dev Fund the pool with pool token
     * @param amount amount of pool token funded to the pool by its owner
     */
    function fund(int64 amount) external returns(bool);


    /**
     * @dev Withdraw from the pool
     * @param amount amount of quote token withdrawn from the pool by its owner
     */
    function withdraw(int64 amount) external returns(bool);

    /**
     * @dev Register to the pool
     * @param allocation amount of pool token allocated to the subscriber
     */
    function register(int64 allocation) external returns(bool);

    /**
     * @dev Buy amount of pool token
     * @param amount amount of pool token to buy from the pool
     */
    function buy(int64 amount) external returns(bool);

    /**
     * @dev Claim amount of pool token
     * @param amount amount of pool token to claim from the pool
     */
    function claim(int64 amount) external returns(bool);
}