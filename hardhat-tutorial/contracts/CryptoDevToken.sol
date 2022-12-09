// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";
import "hardhat/console.sol";
contract CryptoDevToken is ERC20, Ownable {
    // price of crypto dev token
    uint256 public constant tokenPrice = 0.001 ether;

    // Each NFT would give the user 10 token [coins]
    //It need to be represented as 10 * ( 10 ** 18 ) as ERC20 tokens are represente by smallest denomination possible for the token
    uint256 public constant tokensPerNFT = 10 * 10**18;

    // the max total supply is 10000 for Crypto dev token
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    // CryptoDevs contract instance
    //first we need to declare a variable (here it is "CryptoDevsNFT") which is of the type ICryptoDevs
    ICryptoDevs CryptoDevsNFT;

    //Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContractAddress)
        ERC20("Crypto Dev Token", "DRU")
    {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContractAddress);
    }

    // this function will mint token for General public
    // " mint " function will mint " amount " number of CrtptoDevToken
    function mint(uint256 amount) public payable {
        // the value of ether that should be equal or greater than tokenPrice * amount;
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, " Ether sent is incorrect");

        // total tokens + amount <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply available."
        );

        // call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    // this function will mint token for NFT holders public
    function claim() public {
        address sender = msg.sender;

        // Get the number of CryptoDev NFT's held by a given sender address
        // means ke aa sender pase CryptoDev contract mathi ketli nft che ( 1,2,3 vagere )
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
            console.log(balance,'balance of sender...');
        // If the balance is zero, revert the transaction
        require(balance > 0, "You dont own any Crypto devs NFT's");

        //amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;
        
        //loop over the balance and get the token ID owned by `sender` at a given `index` of its token list.
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            console.log(tokenId,'token id...');
            //if the tokenId has not been claimed, increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        // If all the token Ids have been claimed, revert the transaction;
        require(amount > 0, "You have already claimed all the tokens");

        // Mint (amount * 10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "nothing to withdraw , contract balance is empaty");

        address _owner = owner();
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to sent Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
