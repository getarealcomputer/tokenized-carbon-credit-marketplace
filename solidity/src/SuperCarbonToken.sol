// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SuperCarbonToken is ERC20, Ownable {
    constructor() ERC20("Super Carbon Token", "SCT") {
        uint256 initSupply = 1e8 * 1 * 18; // 1 million
        address initReceiver = msg.sender;
        _mint(initReceiver, initSupply);
    }

    function mint(address receiver, uint256 amount)
        public
        onlyOwner
    {
        _mint(receiver, amount);
    }
}
