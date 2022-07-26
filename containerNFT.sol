// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ManageShipment {
    using Counters for Counters.Counter;

    Counters.Counter private _shipmentRequestID;

    enum ContainerDetails {
        requested,
        approved,
        idGenerated,
        bolIssued,
        departed,
        exportHauled,
        oceanHauled,
        importHauled,
        claimed,
        auctioned,
        destinationReached
    }
    ContainerDetails shipment;

    mapping(address => mapping(uint256 => ContainerDetails)) shipmentRequest;

    // Events
    event ShipmentRequested(address a, string origin, string destination);
    event ShipmentApprovedAndIDGenerated(address a, uint256 id, uint256 gid);

    // mapping(address => ContainerDetails) shipment;

    function requestShipment(
        string memory s_origin,
        string memory s_destination
    ) public {
        shipmentRequest[msg.sender][
            _shipmentRequestID.current()
        ] = ContainerDetails.requested;
        _shipmentRequestID.increment();
        emit ShipmentRequested(msg.sender, s_origin, s_destination);
    }

    // How are the documents approved? Physocally? in IPFS? //////////////////////////
    function approveDocuments(
        address requester,
        uint256 requestID,
        uint256 idGenerated
    ) public {
        shipmentRequest[requester][requestID] = ContainerDetails.approved;
        shipmentRequest[requester][requestID] = ContainerDetails.idGenerated;
        emit ShipmentApprovedAndIDGenerated(requester, requestID, idGenerated);
        // shipment = ContainerDetails.approved;
        // shipment = ContainerDetails.idGenerated;
        // assign the container a unique ID (cargo control number)
    }

    // mint the nft here
    function createNFT(
        address _nft,
        address to,
        uint256 requestID,
        uint256 idGenerated
    ) public {
        require(
            shipmentRequest[msg.sender][requestID] ==
                ContainerDetails.idGenerated,
            "Invalid Request. Cargo control number not assigned!"
        );
        ContainerNFT(_nft).safeMint(msg.sender, "uri");

        //###############################################################################################################
        // How to include the generated id in the nft
        // 1. The shipper can manually upload the metadata to IPFS
        // 2. See if theres a way to uppload from here
        // 3. Does the agent need to check the data?
    }
}

contract ContainerNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("ContainerNFT", "CNFT") {}

    event NFTmintedForContainer(uint256 id, address a);

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit NFTmintedForContainer(tokenId, to);
    }

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
