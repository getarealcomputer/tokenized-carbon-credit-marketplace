// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SuperCarbonNFT} from "../SuperCarbonNFT.sol";

contract SuperCarbonNFTFactoryCommons {
    event ClaimAudited(
        uint256 projectId,
        uint256 claimId,
        uint256 co2Reductionsk,
        string referenceDocument
    );

    event SuperCarbonNFTCreated(
        uint256 projectId,
        uint256 claimId,
        SuperCarbonNFT SuperCarbonNFT,
        uint256 carbonCredits
    );
}
