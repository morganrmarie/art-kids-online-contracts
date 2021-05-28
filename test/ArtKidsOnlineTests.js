const ArtKidsOnline = artifacts.require("ArtKidsOnline")

contract("ArtKidsOnline", (accounts) => {
  let artKidsOnlineToken
  const name = "Art Kids Online"
  const symbol = "ART"
  const totalSupply = 0

  beforeEach(async () => {
    artKidsOnlineToken = await ArtKidsOnline.deployed()
  })

  it("has metadata", async () => {
    expect(await artKidsOnlineToken.name()).to.be.equal(name)
    expect(await artKidsOnlineToken.symbol()).to.be.equal(symbol)
  })

  it("should have a total supply of 0", async () => {
    expect(Number(await artKidsOnlineToken.totalSupply())).to.be.equal(
      totalSupply
    )
  })

  it("should have a max supply of 10000", async () => {
    expect(Number(await artKidsOnlineToken.MAX_NFT_SUPPLY.call())).to.be.equal(
      10000
    )
  })
})
