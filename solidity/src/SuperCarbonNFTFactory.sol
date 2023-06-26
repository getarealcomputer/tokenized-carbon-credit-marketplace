// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Strings} from "./libraries/Strings.sol";

import {SuperCarbonNFTFactoryCommons} from "./commons/SuperCarbonNFTFactoryCommons.sol";
import {SuperCarbonNFT} from "./SuperCarbonNFT.sol";
import {SuperCarbonNFTData} from "./SuperCarbonNFTData.sol";
import {SuperCarbonNFTMarketplace} from "./SuperCarbonNFTMarketplace.sol";
import {SuperCarbonToken} from "./SuperCarbonToken.sol";

contract SuperCarbonNFTFactory is Ownable, SuperCarbonNFTFactoryCommons {
    using SafeMath for uint256;
    using Strings for string;

    address SUPER_CARBON_NFT_MARKETPLACE;

    SuperCarbonNFTMarketplace public superCarbonNFTMarketplace;
    SuperCarbonNFTData public superCarbonNFTData;
    SuperCarbonToken public superCarbonToken;

    constructor(
        SuperCarbonNFTMarketplace _superCarbonNFTMarketplace,
        SuperCarbonNFTData _superCarbonNFTData,
        SuperCarbonToken _superCarbonToken
    ) public {
        superCarbonNFTMarketplace = _superCarbonNFTMarketplace;
        superCarbonNFTData = _superCarbonNFTData;
        superCarbonToken = _superCarbonToken;

        SUPER_CARBON_NFT_MARKETPLACE = address(superCarbonNFTMarketplace);
    }

    modifier onlyAuditor() {
        address auditor;
        address[] auditors = superCarbonNFTData.getAuditors();
        for (uint256 i = 0; i < auditors.length; i++) {
            auditor = auditors[i];
        }

        require(msg.sender == auditor, "Caller should be the Auditor");
        _;
    }

    function registerAuditor(address auditor) public onlyOwner returns (bool) {
        superCarbonData.addAuditor(auditor);
    }

    function registerProject(string memory projectName, uint256 co2Emissions)
        public
        returns (bool)
    {
        address projectOwner = msg.sender;
        superCarbonNFTData.saveProject(projectOwner, projectName, co2Emissions);
    }

    function claimCO2Reductions(
        uint256 projectId,
        uint256 co2Reductions,
        uint256 startOfPeriod,
        uint256 endOfPeriod,
        string memory referenceDocument
    ) public returns (bool) {
        SuperCarbonNFTData.Project memory project = superCarbonNFTData
            .getProject(projectId);
        address _projectOwner = project.projectOwner;
        require(msg.sender == _projectOwner, "Caller must be Project Owner");

        superCarbonNFTData.saveClaim(
            projectId,
            co2Reductions,
            startOfPeriod,
            endOfPeriod,
            referenceDocument
        );
    }

    function auditClaim(uint256 claimId, string memory auditedReport)
        public
        onlyAuditor
        returns (bool)
    {
        address auditor;
        address[] memory auditors = superCarbonNFTData.getAuditors();
        for (uint256 i = 0; i < auditors.length; i++) {
            if (msg.sender == superCarbonNFTData.getAuditor(i)) {
                auditor = superCarbonNFTData.getAuditor(i);
            }
        }
        require(msg.sender == auditor, "Caller must be Auditor");

        SuperCarbonNFTData.Claim memory claim = superCarbonNFTData.getClaim(
            claimId
        );
        uint256 _projectId = claim.projectId;
        uint256 _co2Reductions = claim.co2Reductions;
        string memory _referenceDocument = claim.referenceDocument;
        emit ClaimAudited(
            _projectId,
            claimId,
            _co2Reductions,
            _referenceDocument
        );

        _createNewSuperCarbonNFT(
            _projectId,
            claimId,
            _co2Reductions,
            auditedReport
        );
    }

    function _createSuperCarbonNFT(
        uint256 projectId,
        uint256 claimId,
        uint256 co2Reductions,
        string memory auditedReport
    ) internal returns (bool) {
        SuperCarbonNFTData.Project memory project = superCarbonNFTData
            .getProject(projectId);
        address _projectOwner = project.projectOwner;
        string memory _projectName = project.projectName;
        string memory projectSymbol = "SUPER_CARBON_NFT";
        string memory tokenURI = getTokenURI(auditedReport);

        SuperCarbonNFT superCarbonNFT = new SuperCarbonNFT(
            _projectOwner,
            _projectName,
            projectSymbol,
            tokenURI
        );

        uint256 carbonCredits = co2Reductions;

        emit SuperCarbonNFTCreated(
            projectId,
            claimId,
            superCarbonNFT,
            carbonCredits
        );

        superCarbonToken.transfer(_projectOwner, carbonCredits);
    }

    function saveSuperCarbonNFTData(
        uint256 claimId,
        SuperCarbonNFT superCarbonNFT,
        address auditor,
        uint256 carbonCredits,
        string memory auditedReport
    ) public returns (bool) {
        SuperCarbonNFTData.Project memory project = superCarbonNFTData
            .getProject(_projectId);

        _saveSuperCarbonNFTMetadata(
            _projectId,
            claimId,
            superCarbonNFT,
            projectOwner,
            auditor,
            _startOfPeriod,
            _endOfPeriod,
            auditedReport
        );
        _saveSuperCarbonNFTEmissionData(
            project.co2Emissions,
            _co2Reductions,
            carbonCredits
        );
    }

    function _saveSuperCarbonNFTMetadata(
        uint256 projectId,
        uint256 claimId,
        SuperCarbonNFT superCarbonNFT,
        address _projectOwner,
        address auditor,
        uint256 startOfPeriod,
        uint256 endOfPeriod,
        string memory auditedReport
    ) public returns (bool) {
        superCarbonNFTData.saveSuperCarbonNFTMetadata(
            projectId,
            claimId,
            superCarbonNFT,
            _projectOwner,
            auditor,
            startOfPeriod,
            endOfPeriod,
            auditedReport
        );
    }

    function _saveSuperCarbonNFTEmissionData(
        uint256 co2Emissions,
        uint256 co2Reductions,
        uint256 carbonCredits
    ) public returns (bool) {
        superCarbonNFTData.saveSuperCarbonNFTEmissionData(
            co2Emissions,
            co2Reductions,
            carbonCredits
        );
    }

    function baseTokenURI() public pure returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function getTokenURI(string memory _auditedReport)
        public
        view
        returns (string memory)
    {
        return Strings.strConcat(baseTokenURI(), _auditedReport);
    }
}
