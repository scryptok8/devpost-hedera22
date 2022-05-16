// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./ILaunchpadFactory.sol";
import "./ILaunchpadPool.sol";
import "./LaunchpadPool.sol";

/**
 * @title Launchpad Factory
 * @dev Manage project pools
 */
contract LaunchpadFactory is ILaunchpadFactory {    
    bytes32 public constant INIT_CODE_POOL_HASH = keccak256(abi.encodePacked(type(LaunchpadPool).creationCode));

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPool;
    address[] public allPools;
    
    event PoolCreated(address indexed poolToken, address indexed quoteToken, address pool, uint);

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPoolsLength() external view returns (uint) {
        return allPools.length;
    }

    function createPool(
        string calldata name, 
        address poolToken, 
        address quoteToken, 
        int64 price, 
        int64 initialSupply, 
        int64 totalSupply
    ) override external returns(address pool) {
        require(poolToken != quoteToken, 'Launchpad: IDENTICAL_ADDRESSES');
        require(poolToken != address(0), 'Launchpad: ZERO_ADDRESS');
        require(quoteToken != address(0), 'Launchpad: ZERO_ADDRESS');
        require(getPool[poolToken][quoteToken] == address(0), 'Launchpad: POOL_EXISTS'); 
        bytes memory bytecode = type(LaunchpadPool).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(poolToken, quoteToken));

        assembly {
            pool := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        bool success = ILaunchpadPool(pool).initialize(
            msg.sender, 
            name,
            poolToken,
            quoteToken,
            price,
            initialSupply,
            totalSupply
        );

        if(success) {
            getPool[poolToken][quoteToken] = pool;
            allPools.push(pool);

            emit PoolCreated(poolToken, quoteToken, pool, allPools.length);
        }
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Launchpad: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Launchpad: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}