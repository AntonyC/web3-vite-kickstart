//SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface IERC20 {
    function transfer(address to, uint amount) external;
    function decimals() external view returns(uint);
    function getInputValuee(string memory value) external view returns(string memory);
}

contract TokenSale {
    uint tokenPriceInWei = 1 ether;

    IERC20 token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function purchase() public payable {
        require(msg.value >= tokenPriceInWei, "Not enough money sent");
        uint tokensToTransfer = msg.value / tokenPriceInWei;
        uint remainder = msg.value - tokensToTransfer * tokenPriceInWei;
        token.transfer(msg.sender, tokensToTransfer * 10 ** token.decimals());
        payable(msg.sender).transfer(remainder); //send the rest back

    }

    function getInputValue(string memory value) public view returns(string memory)  {
        return token.getInputValuee(value);
    }
}
