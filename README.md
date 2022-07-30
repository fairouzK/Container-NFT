# Container-NFT

#### Thesis Part-II

In the shipping process, every container is represented using an NFT.
This makes it easier in pwnership transfer and cargo history traceability,
easier cargo auctioning platform, and secure shipping documentaion.

Process flow steps:  <br>

1. Shipper places a shipment request using requestShipment() function.
2. Shipping agent approves the required documents and assigns a shipping container number to the request. This is done when the agent books a container pickup for the cargo approveShipmentRequest() function.
3. Using the assigned container number, the shipper mints a container nft to his address.
   The metadata of the NFT is created with the following format in json and stored in IPFS.
   

*Metadata Template <br>
{ <br>
&emsp; Shipping Container Number: <br>
&emsp; Shipment Owner: <br>
&emsp; Shipment Receiver: <br>
&emsp; Shipment Content: <br>
&emsp; Shipper Company: <br>
&emsp; Image: <br>
&emsp; Other related Documents link (if necessary) <br>
}*

4. The shipper approves the manager contract to manage the ownership transfers of the NFT using the approveOperator from ContainerNFT SC.
5. The shipping agent issues Bill of Lading, and stores it in IPFS using the issueBoL() function, while transferring the NFT ownership to the pickup truck's address at the same time.
6. The cargo is transported and the ownership transfer record is updated using the safeTransferFrom() function in ContainerNFT SC as the physical container is handed off from one transported to the next.

#### If the receiver decides to claim the Cargo

7. Upon reaching the destination, the receiver places a claim request providing the BoL link.
8. The documents required for cargo release are approved by a shipping agent and/or customs.
9. Then the cargo is released to the receiver by transferring the ownership to the receiver.

#### If the receiver decides to abandon/auction the Cargo

7. The receiver sends a notice to auction the cargo.
8. The last transporter approves the manager SC using the approveOperator() function in the ContainerNFT SC.
9. The shipping agent sets the starting bid amount, and auction duration and auctions the cargo.
10. After the auction ends, the cargo ownership is transferred to th ehighest bidder.
