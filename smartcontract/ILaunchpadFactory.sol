// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./ILaunchpadPool.sol";

/** 
 * @title IPad
 * @dev Pad interface
 */
interface ILaunchpadFactory {
    /**
     * @dev Create a new pool
     * @param name name of the pool
     * @param poolToken address of pool token
     * @param quoteToken address of the invested token
     * @param price amount of quoteToken per unity of pool token
     * @param initialSupply initial available supply amount of pool token at the token listing time ( TGE vesting )
     * @param totalSupply total available supply of pool token at the end of the vesting process
     */
    function createPool(
        string calldata name, 
        address poolToken, 
        address quoteToken, 
        int64 price, 
        int64 initialSupply, 
        int64 totalSupply
    ) external returns(address);
}