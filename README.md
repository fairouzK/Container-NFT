# Container-NFT

This repo is part of my thesis and contains 3 smart contracts: Shipment Manager, ContainerNFT and AuctionNFT.

#### Thesis Part-II

In the shipping process, every container is represented using an NFT.
This makes it easier in ownership transfer and cargo history traceability,
easier cargo auctioning, and secure shipping documentaion.

Process flow steps: <br>

0. The contract addresses are set.
1. Shipper places a shipment request using requestShipment() function.
2. Shipping agent approves the required documents and assigns a shipping container number to the request. This is done when the agent books a container pickup for the cargo approveShipmentRequest() function.
3. Using the assigned container number, the shipper mints a container nft to his address.
   The metadata of the NFT is created with the following format in json and stored in IPFS.

&emsp;&emsp;_Metadata Template <br>
&emsp;&emsp;{ <br>
&emsp;&emsp;&emsp; shipping container Number: <br>
&emsp;&emsp;&emsp; shipment owner: <br>
&emsp;&emsp;&emsp; shipment receiver: <br>
&emsp;&emsp;&emsp; origin: <br>
&emsp;&emsp;&emsp; destination: <br>
&emsp;&emsp;&emsp; shipment content: <br>
&emsp;&emsp;&emsp; shipper company: <br>
&emsp;&emsp;&emsp; image: <br>
&emsp;&emsp;&emsp; other related Documents link (if necessary) <br>
&emsp;&emsp;&emsp; shipment traits: []<br>
&emsp;&emsp;}_


4. The shipper approves the manager contract to manage the ownership transfers of the NFT using the approveOperator from ContainerNFT SC.
5. The shipping agent issues Bill of Lading, and stores it in IPFS using the issueBoL() function, while transferring the NFT ownership to the pickup truck's address at the same time.
6. The cargo is transported and the ownership transfer record is updated using the safeTransferFrom() function in ContainerNFT SC as the physical container is handed off from one transported to the next.

#### If the receiver decides to claim the Cargo

7. Upon reaching the destination, the receiver places a claim request providing the BoL link using claimCargo().
8. The documents required for cargo release are approved by a shipping agent and/or customs using claimCargoDocumentsApproval().
9. Then the cargo is released to the receiver by transferring the ownership to the receiver (The last transporter -> receiver using safeTransfefrFrom()).

#### If the receiver decides to abandon/auction the Cargo

7. The receiver sends a notice to auction the cargo.
8. The last transporter approves the manager smart contract to manage the NFT using approveOperator() function from ContainerNFT SC.
9. The agent approves the auction while also transferring the NFT to the AuctionNFT SC using the approveAuction() function.
10. The agent can then invoke the start() function from the AuctionNFT SC to start the auction.
11. The shipping agent sets the starting bid amount, and auction duration and auctions the cargo.
12. After the auction ends, the cargo ownership is transferred to the highest bidder using the end() function from the AuctionNFT SC. <br>
NB. The auction sc is operated by the agent.

Final: The token can be burn using the ContainerNFT SC if the receiver or bidder deem it necessay.
