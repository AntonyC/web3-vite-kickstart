//SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

contract SmartContractWallet {

    // The wallet has one owner
    address payable public owner;

    // It is possible for the owner to spend funds on any kind of address
    // It should be possible to allow certain people to spend up to a certain amount of funds
    mapping(address => uint) public allowance;
    mapping(address => bool) public isAllowedToSend;

    // It should be possible to set the owner to a different address
    mapping(address => bool) public guardian;
    address payable nextOwner;
    uint guardiansResetCount;
    uint public constant confirmationsFromGuardiansForReset = 3;

    constructor() {
        owner = payable(msg.sender);
    }

    function setGardian(address _guardian, bool _isGuardian) public {
        require(owner == msg.sender, "You are not the owner, aborting");
        guardian[_guardian] = _isGuardian;
    }

    function proposeNewOwner(address payable newOwner) public {
        require(guardian[msg.sender], "You are no guardian, aborting");
        if(nextOwner != newOwner) {
            nextOwner = newOwner;
            guardiansResetCount = 0;
        }

        guardiansResetCount++;

        if(guardiansResetCount >= confirmationsFromGuardiansForReset) {
            owner = nextOwner;
            nextOwner = payable(address(0));
        }
    }

    function setAllowance(address _from, uint _amount) public {
        require(msg.sender == owner, "You are not the owner, aborting!");
        allowance[_from] = _amount;
        isAllowedToSend[_from] = true;
    }

    function denySending(address _from) public {
        require(msg.sender == owner, "You are not the owner, aborting!");
        isAllowedToSend[_from] = false;
    }

    function transfer(address payable _to, uint _amount, bytes memory payload) public returns (bytes memory) {
        require(_amount <= address(this).balance, "Can't send more than the contract owns, aborting.");
        if(msg.sender != owner) {
            require(isAllowedToSend[msg.sender], "You are not allowed to send any transactions, aborting");
            require(allowance[msg.sender] >= _amount, "You are trying to send more than you are allowed to, aborting");
            allowance[msg.sender] -= _amount;
        }

        (bool success, bytes memory returnData) = _to.call{value: _amount}(payload);
        require(success, "Transaction failed, aborting");
        return returnData;
    }

    receive() external payable {}
}

contract consumer {

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function deposit() public payable {}
}
