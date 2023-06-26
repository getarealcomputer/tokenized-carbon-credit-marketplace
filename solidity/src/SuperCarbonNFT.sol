// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SuperCarbonNFT is ERC721URIStorage {
    using SafeMath for uint256;

    uint256 public currentTokenId;

    constructor(
        address _projectOwner,
        string memory _projectName,
        string memory _projectSymbol,
        string memory _tokenURI
    ) ERC721(_projectName, _projectSymbol) {
        mint(_projectOwner, _tokenURI);
    }

    function mint(address receiver, string memory tokenURI)
        public
    {
        uint256 newTokenId = getNextTokenId();
        currentTokenId++;
        _mint(receiver, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
    }

    function getNextTokenId() private view returns (uint256 _nextTokenId) {
        return currentTokenId.add(1);
    }
}
