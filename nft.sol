// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is Ownable {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool isActive;
    }

    mapping(uint256 => Listing) public listings;
    uint256 public listingId = 0;

    function listNFT(address nftContract, uint256 tokenId, uint256 price) external {
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        listings[listingId] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            isActive: true
        });
        listingId++;
    }

    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId]; // Fixed the variable name
        require(msg.sender == listing.seller, "Only the seller can cancel the listing");
        listing.isActive = false;
        IERC721(listing.nftContract).transferFrom(address(this), msg.sender, listing.tokenId);
    }

    function buyNFT(uint256 listingId) external payable {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing is no longer active");
        require(msg.value >= listing.price, "Insufficient funds");
        listing.isActive = false;
        payable(listing.seller).transfer(msg.value);
        IERC721(listing.nftContract).transferFrom(address(this), msg.sender, listing.tokenId);
    }
}
```

