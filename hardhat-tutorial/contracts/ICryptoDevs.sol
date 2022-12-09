// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICryptoDevs{

        // Returns a token ID owned by `owner` at a given `index` of its token list.
        
        //aa function return karse ke
        //jo dhruv pase 3 NFT che and total 20 NFT che, to aa 20 mathi kai 3 NFT dhruv pase che, ae return karse
        function tokenOfOwnerByIndex (address owner , uint256 index) external view returns (uint256 tokenId);
            
        // "CryptoDev contract" ma ketli NFT hold kare che te return karse (1 ,2 3..etc)
        // Returns the number of tokens in ``owner``'s account.
        function balanceOf (address owner) external view returns (uint256 balance);

}