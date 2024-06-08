/*
1. Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
2. Transferring tokens: Players should be able to transfer their tokens to others.
3. Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
4. Checking token balance: Players should be able to check their token balance at any time.
5. Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    event TokensRedeemed(address indexed redeemer, uint256 amount);
    event TokensBurned(address indexed burner, uint256 amount);
    event ItemAdded(uint256 itemId, string name, uint256 price);
    event ItemRemoved(uint256 itemId);

    struct StoreItem {
        string name;
        uint256 price;
      }

    mapping(uint256 => StoreItem) public storeItems;
    uint256 public totalItems;

    constructor(address initialOwner) ERC20("Degen", "DGN") Ownable(initialOwner) {
        totalItems = 0;
  }

    // Mint new tokens
    function mintTK(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
      }

    // Transfer tokens to another address
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address"); // Ensure recipient is not the zero address
        _transfer(_msgSender(), recipient, amount);
        return true;
 }

    // Redeem tokens for in-game items
    function redeemTokens(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "You do not have enough Degen Tokens"); // Check if sender has enough balance
        _burn(msg.sender, amount);
        emit TokensRedeemed(msg.sender, amount);
        // Implement logic for redeeming tokens for in-game items
       }

    // Burn tokens (destroy them irreversibly)
    function burn(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "You do not have enough Degen Tokens"); // Check if sender has enough balance
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);  
}

    // Check balance of the caller
    function getBalance() external view returns (uint256) {
        return balanceOf(msg.sender);
    }

    // Add an item to the store

    function addStoreItem(string memory name, uint256 price) external onlyOwner {
        totalItems++;
        storeItems[totalItems] = StoreItem(name, price);
        emit ItemAdded(totalItems, name, price);
}


    // Remove an item from the store
    function removeItemFromStore(uint256 itemId) external onlyOwner {
        require(itemId > 0 && itemId <= totalItems, "Invalid item ID"); // Ensure itemId is valid
        delete storeItems[itemId];
        emit ItemRemoved(itemId);
    }

    // Show available items in the store
    function showStoreItems() external view returns (string memory) {
        string memory itemList;
        for (uint256 i = 1; i <= totalItems; i++) {
            itemList = string(abi.encodePacked(itemList, uintToString(i), ". ", storeItems[i].name, " - ", uintToString(storeItems[i].price), " DGN\n"));
        }
        return itemList; }

    // Convert uint to string
    function uintToString(uint256 v) internal pure returns (string memory str) {
        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i); // i + 1 is inefficient, so -1 and +1 compensate
        for (uint256 j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; // to reverse the string
        }
        str = string(s); // memory isn't implicitly convertible to storage
    }
}
