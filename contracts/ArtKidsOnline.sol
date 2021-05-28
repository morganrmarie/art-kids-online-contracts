// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtKidsOnline is ERC721Enumerable, Ownable {
  uint256 public tokenIndex;
  uint256 public constant MAX_NFT_SUPPLY = 10000;
  bool public saleStarted = false;

  constructor() ERC721("Art Kids Online", "ART") {        
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return "https://api.artkids.online/";
  }

  function getTokenURI(uint256 tokenId) public view returns (string memory) {
    return tokenURI(tokenId);
  }

  function getPrice() public view returns (uint256) {
    require(saleStarted == true, "This sale has not started.");
    require(totalSupply() < MAX_NFT_SUPPLY, "Sale has ended.");
    return 100000000000000000;
  }

  function backArtKid(uint256 amountToBack) public payable {
    require(saleStarted == true, "This sale has not started.");
    require(totalSupply() < MAX_NFT_SUPPLY, "The sale has ended.");
    require(amountToBack > 0, "You must back at least one Art Kid.");
    require(
      amountToBack <= 100,
      "You can only back up to 100 Art Kids at a time."
    );
    require(
      totalSupply() + amountToBack <= MAX_NFT_SUPPLY,
      "The amount of Art Kids you are trying to back exceeds the MAX_NFT_SUPPLY."
    );
    require(getPrice() * amountToBack == msg.value, "Incorrect Ether value.");

    for (uint256 i = 0; i < amountToBack; i++) {
      uint256 mintIndex = totalSupply();
      _safeMint(msg.sender, mintIndex);
    }
  }

  function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

   function startSale() public onlyOwner {
    saleStarted = true;
  }

  function pauseSale() public onlyOwner {
    saleStarted = false;
  }
}
