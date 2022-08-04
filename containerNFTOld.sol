// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ManageShipment {
    // ContainerNFT contNFT = ContainerNFT(0xd9145CCE52D386f254917e481eB44e9943F39138);

    using Counters for Counters.Counter;

    Counters.Counter private _shipmentRequestID;

    enum ShipmentState {
        Requested,
        ContainerIdAssigned,
        BoLIssued,
        Departed,
        ExportHauled,
        OceanHauled,
        ImportHauled,
        Claimed,
        Auctioned,
        DestinationReached
    }
    // ContainerStates shipment;
    // mapping (string => string) documents; // Map document name with its ipfs link

    struct ShipmentDetails {
        uint256 NFTId;
        uint256 containerId;
        string metadataLink;
        ShipmentState sStatus;
        mapping(string => string) relatedDocuments; // Map document name with its ipfs link
    }
    // you can whitelist accounts that can mint!
    // Authorize the agent and pause all transfers

    mapping(address => mapping(uint256 => ShipmentDetails)) shipmentRequest;

    // Events
    event ShipmentRequested(
        uint256 requestId,
        address requester,
        string origin,
        string destination
    );
    event ShipmentApprovedAndContainerIDAssigned(
        address a,
        uint256 id,
        uint256 containerId
    );

    // Modifiers
    modifier onlyAgent() {
        require(msg.sender == 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        _;
    }

    // mapping(address => ShipmentState) shipment;

    constructor() {
        // address Agent = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        // _grantRole(DEFAULT_ADMIN_ROLE, Agent);
    }

    address minterContract;

    function setMinterContractAddr(address addr) public {
        minterContract = addr;
    }

    function requestShipment(
        string memory s_origin,
        string memory s_destination
    ) public {
        uint256 requestId = _shipmentRequestID.current();
        shipmentRequest[msg.sender][requestId].sStatus = ShipmentState
            .Requested;

        emit ShipmentRequested(requestId, msg.sender, s_origin, s_destination);

        _shipmentRequestID.increment();
    }

    // How are the documents approved? Physically? in IPFS? //////////////////////////
    function approveDocuments(
        address requester,
        uint256 requestID,
        uint256 containerid
    ) public {
        // shipmentRequest[requester][requestID].sStatus  = ShipmentState.Approved;
        shipmentRequest[requester][requestID].sStatus = ShipmentState
            .ContainerIdAssigned;
        shipmentRequest[requester][requestID].containerId = containerid;
        emit ShipmentApprovedAndContainerIDAssigned(
            requester,
            requestID,
            containerid
        );
    }

    /*
        approveDocuments and createNFT can be combined. We don't need the hustle of 
        updating the container state when documents are approved and all
    */

    // Authorize the agent to manage the container nft according to the shipping process
    // ask the shipper for permission

    // The agent mints the nft when bill of lading is issued, (minted to the shipper)
    function createNFT(address to, uint256 requestID) public onlyAgent {
        require(
            shipmentRequest[to][requestID].sStatus ==
                ShipmentState.ContainerIdAssigned,
            "Invalid Request. Container number not assigned!"
        );

        ContainerNFT(minterContract).safeMint(to, "uri");
    }

    // To check the current owner of the NFT
    function checkOwner(uint256 tokenId) public view returns (address) {
        return (ContainerNFT(minterContract).checkOwnerOf(tokenId));
    }

    // The owner of the cargo transfers the NFT ownership to the transporter
    function transferContainerNFT(address to, uint256 tokenId) public {
        require(checkOwner(tokenId) == msg.sender, "Caller not owner!");
        ContainerNFT(minterContract).safeTransferFrom(msg.sender, to, tokenId);
    }
}

contract ContainerNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // Events
    event NFTmintedForContainer(uint256 id, address b);

    address managerContract;

    modifier onlyManagerContract() {
        require(msg.sender == managerContract);
        _;
    }

    constructor() ERC721("ContainerNFT", "CNFT") {}

    function setManagerContractAddr(address addr) public onlyOwner {
        managerContract = addr;
    }

    function safeMint(address to, string memory uri)
        public
        onlyManagerContract
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit NFTmintedForContainer(tokenId, to);
    }

    function checkOwnerOf(uint256 id) public view returns (address) {
        return (ownerOf(id));
    }

    // function transferNFTOwnership(address to, uint256 nftId) public {

    // }
    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}

/*
    Metadata Template
    {
        Container Number:  
        Ownership transfer point?
        Shipment Owner:
        Shipment Receiver:
        Shipment Content: 
        Image:
        Bill Of Lading:          
    }
*/

/*
Questions:
Will the transfer need to be locked until the last approval?

*/
