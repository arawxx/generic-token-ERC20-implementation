// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title Generic token contract
 * @author Arash Hajian nezhad (Vandalious)
 * @notice An ERC-20 Token implemented for generic use-cases
 * @dev No need for SafeMath as arithmetic overflow/underflow
 * is already done at language level since solidity 0.8+
*/
contract Generic {
    /* DATA STRUCTURES */
    string public _name = "Generic";
    string public _symbol = "GRC";
    uint8 public _decimals = 4;

    uint256 public _totalSupply = 1000000;

    address public owner;

    /* MAPPINGS */
    // accounts balances
    mapping (address => uint256) balances;
    // internal address, is the address that is
    // allowed to withdraw `uint256` amount of tokens
    // from the external address (in other words,
    // internal addresses are the brokers/wallets/etc...)
    mapping (address => mapping(address => uint256)) allowed;

    /* EVENTS */
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed middleman, uint256 amount);

    /* ERRORS */
    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientAllowance(uint256 allowed, uint256 required);

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) public view returns (uint256) {
        return balances[_address];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        if (balances[msg.sender] < _amount)
            revert InsufficientBalance({available: balances[msg.sender], required: _amount});
        
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        if (balances[_from] < _amount)
            revert InsufficientBalance({available: balances[_from], required: _amount});
        
        if (allowed[_from][msg.sender] < _amount)
            revert InsufficientAllowance({allowed: allowed[_from][msg.sender], required: _amount});
        
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);

        return true;
    }

    function approve(address _middleman, uint256 _amount) public returns (bool) {
        allowed[msg.sender][_middleman] = _amount;
        emit Approval(msg.sender, _middleman, _amount);

        return true;
    }

    function allowance(address _address, address _middleman) public view returns (uint256) {
        return allowed[_address][_middleman];
    }
}