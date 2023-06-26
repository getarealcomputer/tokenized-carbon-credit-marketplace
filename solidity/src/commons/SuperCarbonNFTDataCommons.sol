// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SuperCarbonNFT} from "../SuperCarbonNFT.sol";

contract SuperCarbonNFTDataCommons {
    Project[] public projects;

    Claim[] public claims;

    SuperCarbonNFTMetadata[] public superCarbonNFTMetadataArray;

    SuperCarbonNFTEmissionData[] public superCarbonNFTEmissionDataArray;

    enum SuperCarbonNFTStatus {
        Audited,
        Sale,
        NotForSale
    }

    struct Project {
        address projectOwner;
        string projectName;
        uint256 co2Emissions;
    }

    struct Claim {
        uint256 projectId;
        uint256 co2Reductions;
        uint256 startOfPeriod;
        uint256 endOfPeriod;
        string referenceDocument; //IPFS hash
    }

    struct SuperCarbonNFTMetadata {
        uint256 projectId;
        uint256 claimId;
        SuperCarbonNFT superCarbonNFT;
        address projectOwner;
        address auditor;
        uint256 issuedDateTimestamp;
        uint256 startOfPeriod;
        uint256 endOfPeriod;
        string auditedReport;
        SuperCarbonNFTStatus superCarbonNFTStatus;
    }

    struct SuperCarbonNFTEmissionData {
        uint256 co2Emissions;
        uint256 co2Reductions;
        uint256 carbonCredits;
        uint256 buyableCarbonCredits;
    }
}
