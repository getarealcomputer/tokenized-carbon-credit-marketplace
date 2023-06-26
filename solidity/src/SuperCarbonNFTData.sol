// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SuperCarbonNFTDataCommons} from "./commons/SuperCarbonNFTDataCommons.sol";
import {SuperCarbonNFT} from "./SuperCarbonNFT.sol";

contract SuperCarbonNFTData is SuperCarbonNFTDataCommons {
    using SafeMath for uint256;

    uint256 currentProjectId;
    uint256 currentClaimId;
    uint256 currentSuperCarbonNFTMetadataId;

    /// Auditors
    address[] public auditors;

    /// All of SuperCarbonNFT addresses
    address[] public superCarbonNFTAddresses;

    constructor() {}

    function addAuditor(address auditor) public returns (bool) {
        auditors.push(auditor);
    }

    function saveProject(
        address _projectOwner,
        string memory _projectName,
        uint256 _co2Emissions
    ) public returns (bool) {
        currentProjectId++;
        Project memory project = Project({
            projectOwner: _projectOwner,
            projectName: _projectName,
            co2Emissions: _co2Emissions
        });

        projects.push(project);
    }

    /**
     * @notice - Save metadata of a SuperCarbonNFT
     */
    function saveSuperCarbonNFTMetadata(
        uint256 _projectId,
        uint256 _claimId,
        SuperCarbonNFT _superCarbonNFT,
        address _projectOwner,
        address _auditor,
        uint256 _startOfPeriod, /// e.g). 12:00 UTC, Jan 1, 2022
        uint256 _endOfPeriod, /// e.g). 12:00 UTC, Dec 31, 2024
        string memory _auditedReport
    ) public returns (bool) {
        currentSuperCarbonNFTMetadataId++;

        /// Save metadata of a SuperCarbonNFT
        SuperCarbonNFTMetadata
            memory superCarbonNFTMetadata = SuperCarbonNFTMetadata({
                projectId: _projectId,
                claimId: _claimId,
                superCarbonNFT: _superCarbonNFT,
                projectOwner: _projectOwner,
                auditor: _auditor,
                issuedDateTimestamp: block.timestamp,
                startOfPeriod: _startOfPeriod,
                endOfPeriod: _endOfPeriod,
                auditedReport: _auditedReport,
                superCarbonNFTStatus: SuperCarbonNFTStatus.Audited
            });
        superCarbonNFTMetadataArray.push(superCarbonNFTMetadata);

        /// Update SuperCarbonNFTs addresses
        superCarbonNFTAddresses.push(address(_superCarbonNFT));
    }

    /**
     * @notice - Save emission data of a SuperCarbonNFT
     */
    function saveSuperCarbonNFTEmissonData(
        uint256 _co2Emissions,
        uint256 _co2Reductions,
        uint256 _carbonCredits
    ) public returns (bool) {
        /// Save emission data of a SuperCarbonNFT
        SuperCarbonNFTEmissionData
            memory superCarbonNFTEmissonData = SuperCarbonNFTEmissionData({
                co2Emissions: _co2Emissions,
                co2Reductions: _co2Reductions,
                carbonCredits: _carbonCredits,
                buyableCarbonCredits: _carbonCredits /// [Note]: Initially, carbonCredits and buyableCarbonCredits are equal amount
            });
        superCarbonNFTEmissionDataArray.push(superCarbonNFTEmissonData);
    }

    /**
     * @notice - Update status ("Open" or "Cancelled")
     */
    function updateStatus(
        SuperCarbonNFT _superCarbonNFT,
        SuperCarbonNFTStatus _newStatus
    ) public returns (bool) {
        /// Identify green's index
        uint256 superCarbonNFTMetadataIndex = getSuperCarbonNFTMetadataIndex(
            _superCarbonNFT
        );

        /// Update metadata of a SuperCarbonNFT
        SuperCarbonNFTMetadata storage superCarbonNFTMetadata =
            superCarbonNFTMetadataArray[
            superCarbonNFTMetadataIndex
        ];
        superCarbonNFTMetadata.superCarbonNFTStatus = _newStatus;
    }

    ///-----------------
    /// Getter methods
    ///-----------------

    function getProject(uint256 projectId)
        public
        view
        returns (Project memory _projectId)
    {
        uint256 index = projectId.sub(1);
        Project memory project = projects[index];
        return project;
    }

    function getClaim(uint256 claimId)
        public
        view
        returns (Claim memory _claim)
    {
        uint256 index = claimId.sub(1);
        Claim memory claim = claims[index];
        return claim;
    }

    function getSuperCarbonNFTMetadata(uint256 superCarbonNFTMetadataId)
        public
        view
        returns (SuperCarbonNFTMetadata memory _superCarbonNFTMetadata)
    {
        uint256 index = superCarbonNFTMetadataId.sub(1);
        SuperCarbonNFTMetadata memory superCarbonNFTMetadata =
            superCarbonNFTMetadataArray[
            index
        ];
        return superCarbonNFTMetadata;
    }

    function getSuperCarbonNFTMetadataIndex(SuperCarbonNFT superCarbonNFT)
        public
        view
        returns (uint256 _superCarbonNFTMetadataIndex)
    {
        address SUPER_CARBON_NFT = address(superCarbonNFT);

        /// Identify member's index
        uint256 superCarbonNFTMetadataIndex;
        for (uint256 i = 0; i < superCarbonNFTAddresses.length; i++) {
            if (superCarbonNFTAddresses[i] == SUPER_CARBON_NFT) {
                superCarbonNFTMetadataIndex = i;
            }
        }

        return superCarbonNFTMetadataIndex;
    }

    function getSuperCarbonNFTMetadataByNFTAddress(SuperCarbonNFT superCarbonNFT)
        public
        view
        returns (SuperCarbonNFTMetadata memory _superCarbonNFTMetadata)
    {
        /// Identify member's index
        uint256 index = getSuperCarbonNFTMetadataIndex(superCarbonNFT);

        SuperCarbonNFTMetadata memory superCarbonNFTMetadata =
            superCarbonNFTMetadataArray[
            index
        ];
        return superCarbonNFTMetadata;
    }

    function getSuperCarbonNFTEmissionData(uint256 superCarbonNFTMetadataId)
        public
        view
        returns (SuperCarbonNFTEmissionData memory _superCarbonNFTEmissonData)
    {
        /// [Note]: The SuperCarbonNFTEmissonData and the SuperCarbonNFTMetadata has same superCarbonNFTMetadataId
        uint256 index = superCarbonNFTMetadataId.sub(1);
        SuperCarbonNFTEmissionData
            memory superCarbonNFTEmissonData = superCarbonNFTEmissionDataArray[index];
        return superCarbonNFTEmissonData;
    }

    function getSuperCarbonNFTEmissionDataIndex(SuperCarbonNFT superCarbonNFT)
        public
        view
        returns (uint256 _superCarbonNFTEmissonDataIndex)
    {
        address GREEN_NFT = address(superCarbonNFT);

        /// Identify member's index
        uint256 superCarbonNFTEmissonDataIndex;
        for (uint256 i = 0; i < superCarbonNFTAddresses.length; i++) {
            if (superCarbonNFTAddresses[i] == GREEN_NFT) {
                superCarbonNFTEmissonDataIndex = i;
            }
        }

        return superCarbonNFTEmissonDataIndex;
    }

    function getSuperCarbonNFTEmissionDataByNFTAddress(SuperCarbonNFT superCarbonNFT)
        public
        view
        returns (SuperCarbonNFTEmissionData memory _superCarbonNFTEmissonData)
    {
        /// Identify member's index
        uint256 index = getSuperCarbonNFTEmissionDataIndex(superCarbonNFT);

        SuperCarbonNFTEmissionData
            memory superCarbonNFTEmissonData = superCarbonNFTEmissionDataArray[index];
        return superCarbonNFTEmissonData;
    }

    function getSuperCarbonNFTMetadata()
        public
        view
        returns (SuperCarbonNFTMetadata[] memory _superCarbonNFTMetadatas)
    {
        return superCarbonNFTMetadataArray;
    }

    function getSuperCarbonNFTEmissionData()
        public
        view
        returns (SuperCarbonNFTEmissionData[] memory _superCarbonNFTEmissonDatas)
    {
        return superCarbonNFTEmissionDataArray;
    }

    function getAuditors() public view returns (address[] memory _auditors) {
        return auditors;
    }

    function getAuditor(uint256 index) public view returns (address _auditor) {
        return auditors[index];
    }
}
