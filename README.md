
# Contract-Features




ERC-721 Compliance Compatible

## Users are      
Whitelisted user

Platform user

Public user
## NFT  Minting Limits
Total Minting Limit         
Whitelisted users Minting         
Public users Minting         
Platform Minting (admin)
         
## Minting   
1: Whitelist User Minting: 
Only whitelist users allow to mint the NFT.
If the Whitelist User's Minting limit is reached then whitelist users cannot mint the NFTs.

2: Public Minting:
Public Minting is only available when public sales are active.
If the public minting limit is reached then users cannot mint the NFTs.
   
3: Platform Minting: 
Platform minting is for admin addresses. 
If the platform limit is reached admin cannot mint more NFTs.

## Contract deliveries:
NFTs are reserved with respect to limit i.e. 1 address can mint up to 5 NFTs.

Contract  also have whitelist admins that can be only add or remove by the owner of the contract.

All contract functions can be paused by contract owner.
   
Default Base URI is set or update by whitelist admins.

Contract  have a pause/un-pause minting feature. Minting status can be changed by the owner of the contract.

Token Ids is not  managed within the contract. It is be pass as a parameter in the minting function.
   
Whitelist addresses can be mint as public when public sale is active.

 A limit is define for each user that  include whitelist and public minting.

Whitelist admins cannot mint NFTs if the minting status is paused.

Public users cannot mint NFTs if public sales are not active.  

We have reserved a limit for each Admin, Whitelist user, and public.

Let's say we have a total minting limit is 100. In which you reserved 10 for admins and 50 for whitelist users. The remaining limit is 40. So 40 limit is reserved for public sales. If whitelist users only mint 40 NFTs out of 50 remaining 10 NFTs are added to the public limit if we  activate the public sales. Furthermore, when we activate the public sale then whitelist users cannot mint the NFTs.   



## Minted NFTs
[opensea/collection/ZahoorKhan](https://testnets.opensea.io/assets?search[query]=ZahoorKhan_Token)
