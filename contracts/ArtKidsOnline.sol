// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/** 
  ___       _     _   ___     _     
 / _ \     | |   | | / (_)   | |    
/ /_\ \_ __| |_  | |/ / _  __| |___ 
|  _  | '__| __| |    \| |/ _` / __|
| | | | |  | |_  | |\  \ | (_| \__ \
\_| |_/_|   \__| \_| \_/_|\__,_|___/
*/

contract ArtKidsOnline is ERC721Enumerable, Ownable {
  uint256 public constant MAX_NFT_SUPPLY = 10000;
  uint256 public constant BIDDING_END_TIME = 1625029200;
  uint256 public constant ART_KID_PRICE = 100000000000000000;

  uint256 public finalWinner;
  uint256 public totalVotes = 0;

  bool public saleStarted = false;
  bool public votingActive = true;


  event Vote(address indexed from, uint256 votedFor, uint256 votedWith);

  struct ArtKid {
    uint256 id;
    uint256 voteCount;
    address[] voters;
    bool hasVoted;
  }

  ArtKid[] public artKids;

  constructor() ERC721("Art Kids Online", "ART") {        
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return "https://api.artkids.online/";
  }

  function getTokenURI(uint256 tokenId) public view returns (string memory) {
    return tokenURI(tokenId);
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

    require(ART_KID_PRICE * amountToBack == msg.value, "Incorrect Ether value.");

    for (uint256 i = 0; i < amountToBack; i++) {
      uint256 mintIndex = totalSupply();
      _safeMint(msg.sender, mintIndex);
      artKids.push(ArtKid({
        id: mintIndex,
        voteCount: 0,
        hasVoted: false,
        voters: new address[](0)
      }));
    }
  }

  function hasVoted(uint256 artKidTokenIndex) public view returns (bool) {
    require(totalSupply() >= artKidTokenIndex, "Token does not exist.");
    return artKids[artKidTokenIndex].hasVoted;
  }

  function voteCount(uint artKidTokenIndex) public view returns (uint256) {
    require(totalSupply() >= artKidTokenIndex, "Token does not exist.");
    return artKids[artKidTokenIndex].voteCount;
  }

  function vote(uint256 myNftId, uint256 artKidToVoteForIndex) public returns (bool) {
    // Pay winner if bidding period has ended
    if (block.timestamp > BIDDING_END_TIME && votingActive == true) {
     payWinningArtKid(); 
     votingActive = false;
     return true;
    }

    // Require voting period to be active
    require(block.timestamp <= BIDDING_END_TIME, "Voting has ended.");
    // Require sale to be started
    require(saleStarted == true, "Sale has not started.");
    // Voter must own the token they're voting with
    require(ownerOf(myNftId) == msg.sender, "You cannot vote with the same token you are voting for.");
    // Voter cannot vote for a token that they own
    require(ownerOf(artKidToVoteForIndex) != msg.sender);
    // Token that's being voted with must not have voted before
    require(artKids[myNftId].hasVoted == false);

    // Token has been voted with
    artKids[myNftId].hasVoted = true;
    // Increase number of votes for token
    artKids[artKidToVoteForIndex].voteCount++;
    // Add address to voters
    artKids[artKidToVoteForIndex].voters.push(msg.sender);

    emit Vote(msg.sender, artKidToVoteForIndex, myNftId);

    // Increase amount of total votes
    totalVotes++;
    if (totalVotes == 10000) {
      payWinningArtKid(); 
      votingActive = false;
      return true;
    }

    return true;
  }

  function winningArtKid() public view returns (uint256 artKidId) {
    uint256 winningVoteCount = 0;
    for (uint256 i = 0; i < artKids.length; i++) {
      if (artKids[i].voteCount > winningVoteCount) {
        winningVoteCount = artKids[i].voteCount;
        artKidId = i;
      }
    }
  }

  function payWinningArtKid() internal returns (bool) {
    require(block.timestamp > BIDDING_END_TIME, "Voting is still active.");
    uint256 payoutAmount = address(this).balance / 2;
    uint256 winningArtKidId = winningArtKid();
    finalWinner = winningArtKidId;
    address winnerOwner = ownerOf(winningArtKidId);
    payable(winnerOwner).transfer(payoutAmount);
    return true;
  }

  function withdraw() public onlyOwner {
    // Require voting period to have ended
    require(block.timestamp > BIDDING_END_TIME, "Voting is still active.");
    require(payable(msg.sender).send(address(this).balance));
  }

  function startSale() public onlyOwner {
    saleStarted = true;
  }

  function pauseSale() public onlyOwner {
    saleStarted = false;
  }

  // If all voting has been completed before the end date,
  // allow owner to manually trigger payout
  function manuallyPayWinningArtist() public onlyOwner {
    // Require voting period to have ended
    require(block.timestamp > BIDDING_END_TIME, "Voting is still active.");
    votingActive = false;
    payWinningArtKid();
  }
}
