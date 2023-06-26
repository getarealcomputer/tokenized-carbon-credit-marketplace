// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import {SuperCarbonNFT} from "./SuperCarbonNFT.sol";
import {SuperCarbonNFTData} from "./SuperCarbonNFTData.sol";
import {SuperCarbonToken} from "./SuperCarbonToken.sol";

import {SuperCarbonNFTDataCommons} from "./commons/SuperCarbonNFTDataCommons.sol";

contract SuperCarbonNFTTradable {
    SuperCarbonToken private superCarbonToken;

    constructor(SuperCarbonToken _superCarbonToken) {
        superCarbonToken = _superCarbonToken;
    }

    /**
     * @notice - Open to put on sale of carbon credits.
     * @notice - Caller is a projectOwner (Seller)
     */
    function openToPutOnSale(
        SuperCarbonNFTData _superCarbonData,
        SuperCarbonNFT superCarbon
    ) public {
        SuperCarbonNFTData superCarbonData = _superCarbonData;

        /// Update status
        superCarbonData.updateStatus(
            superCarbon,
            SuperCarbonNFTDataCommons.SuperCarbonNFTStatus.Sale
        );

        /// Get amount of carbon credits
        SuperCarbonNFTDataCommons.SuperCarbonNFTEmissionData
            memory superCarbonEmissionData = superCarbonData
                .getSuperCarbonNFTEmissionDataByNFTAddress(superCarbon);
        uint256 _carbonCredits = superCarbonEmissionData.carbonCredits;

        /// CarbonCreditTokens are locked on this smart contract
        address projectOwner = msg.sender;
        superCarbonToken.transferFrom(
            projectOwner,
            address(this),
            _carbonCredits
        );
    }

    /**
     * @notice - Cancel to put on sale of carbon credits.
     * @notice - Caller is a seller
     */
    function cancelToPutOnSale(
        SuperCarbonNFTData _superCarbonData,
        SuperCarbonNFT superCarbon
    ) public {
        SuperCarbonNFTData superCarbonData = _superCarbonData;

        /// Update status
        superCarbonData.updateStatus(
            superCarbon,
            SuperCarbonNFTDataCommons.SuperCarbonNFTStatus.NotForSale
        );

        /// Get amount of carbon credits
        SuperCarbonNFTDataCommons.SuperCarbonNFTEmissionData
            memory superCarbonEmissionData = superCarbonData
                .getSuperCarbonNFTEmissionDataByNFTAddress(superCarbon);
        uint256 _carbonCredits = superCarbonEmissionData.carbonCredits;

        /// CarbonCreditTokens locked are relesed from this smart contract and transferred into a projectOwner (seller)
        address projectOwner = msg.sender;
        superCarbonToken.transfer(projectOwner, _carbonCredits);
    }
}
