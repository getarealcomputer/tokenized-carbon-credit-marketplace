// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

import {SuperCarbonNFT} from "./SuperCarbonNFT.sol";
import {SuperCarbonNFTData} from "./SuperCarbonNFTData.sol";
import {SuperCarbonToken} from "./SuperCarbonToken.sol";
import {SuperCarbonNFTTradable} from "./SuperCarbonNFTTradable.sol";

contract SuperCarbonNFTMarketplace is SuperCarbonNFTTradable {
    using SafeMath for uint256;

    uint256 carbonCreditsUnitPrice = 1;

    address public SUPER_CARBON_NFT_MARKETPLACE;

    SuperCarbonNFTData public superCarbonNFTData;
    SuperCarbonToken public superCarbonToken;

    constructor(
        SuperCarbonNFTData _superCarbonNFTData,
        SuperCarbonToken _superCarbonToken
    ) public SuperCarbonNFTTradable(_superCarbonToken) {
        superCarbonNFTData = _superCarbonNFTData;
        superCarbonToken = _superCarbonToken;

        address payable SUPER_CARBON_NFT_MARKETPLACE = address(
            uint160(address(this))
        );
    }

    function buyCarbonCredits(
        SuperCarbonNFT _superCarbonNFT,
        uint256 amount
    ) public payable returns (bool) {
        address buyer = msg.sender;

        SuperCarbonNFT superCarbonNFT = _superCarbonNFT;
        uint256 buyableCarbonCredits = getBuyableCarbonCredits(superCarbonNFT);
        require(amount <= buyableCarbonCredits, "Supply is not sufficient!");

        SuperCarbonNFTData.SuperCarbonNFTMetadata
            memory superCarbonNFTMetadata = superCarbonNFTData
                .getSuperCarbonNFTMetadataByNFTAddress(superCarbonNFT);

        uint256 _projectId = superCarbonNFTData
            .getClaim(superCarbonNFTMetadata.claimId)
            ._projectId;
        address _seller = superCarbonNFTData
            .getProject(_projectId)
            .projectOwner;
        address payable seller = address(uint160(_seller));

        uint256 amountPurchased = getCarbonCreditsPurchasedAmount(
            superCarbonNFT,
            amount
        );
        require(
            amountPurchased == msg.value,
            "msg.value must be equal to purchased amount of carbon credits!"
        );

        seller.transfer(amountPurchased);

        superCarbonToken.transfer(buyer, amountPurchased);
    }

    function getBuyableCarbonCredits(SuperCarbonNFT _superCarbonNFT)
        public
        view
        returns (uint256 _buyableCarbonCredits)
    {
        SuperCarbonNFTData.SuperCarbonNFTEmissionData
            memory superCarbonNFTEmissionData = superCarbonNFTData
                .getSuperCarbonNFTEmissionDataByNFTAddress(_superCarbonNFT);
        return superCarbonNFTEmissionData.buyableCarbonCredits;
    }

    function getCarbonCreditsPurchasedAmount(
        SuperCarbonNFT _superCarbonNFT,
        uint256 amount
    ) public view returns (uint256 _amountPurchased) {
        uint256 amountPurchased = carbonCreditsUnitPrice * amount;

        return amountPurchased;
    }
}
