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
    // Events
    event TokensRedeemed(address indexed redeemer, uint256 amount, uint256 itemId);
    event TokensBurned(address indexed burner, uint256 amount);
    event ItemAdded(uint256 indexed itemId, string name, uint256 price);
    event ItemRemoved(uint256 indexed itemId);

    // Struct for store items
    struct StoreItem {
        string name;
        uint256 price;
    }

    // Mapping and state variables
    mapping(uint256 => StoreItem) public storeItems;
    uint256 public totalItems;

    /**
     * @dev Constructor function to initialize the DegenToken contract.
     * @param initialOwner The address that will be set as the initial owner of the contract.
     */
    constructor(address initialOwner) ERC20("Degen", "DGN") Ownable(initialOwner) {
        totalItems = 0;
     }

    /**
     * @dev Function to mint new tokens.
     * @param account The address to which new tokens will be minted.
     * @param amount The amount of tokens to mint.
     * @return A boolean indicating whether the minting was successful or not.
     * @dev Only callable by the contract owner.
     */
    function mintTokens(address account, uint256 amount) external onlyOwner returns (bool) {
        _mint(account, amount);
        return true;
     }

    /**
     * @dev Function to transfer tokens to another address.
     * @param recipient The address to which tokens will be transferred.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "DegenToken: transfer to the zero address");
        _transfer(_msgSender(), recipient, amount);
        return true;
         }
        

    /**
     * @dev Function to redeem tokens for in-game items.
     * @param itemUniqueIdentifier The unique identifier of the item to redeem.
     * @dev Emits a TokensRedeemed event upon successful redemption.
     */
    function redeemTokens(uint256 itemUniqueIdentifier) external {
        // Check if the item identifier is valid
        require(storeItems[itemUniqueIdentifier].price > 0, "DegenToken: Invalid item identifier");
        
        // Check if the caller has enough tokens to redeem the item
        uint256 amount = storeItems[itemUniqueIdentifier].price;
        require(balanceOf(msg.sender) >= amount, "DegenToken: Insufficient tokens for redemption");

        // Burn tokens from the caller's balance
        _burn(msg.sender, amount);

        // Emit TokensRedeemed event
        emit TokensRedeemed(msg.sender, amount, itemUniqueIdentifier);

        // Deliver the redeemed item to the caller
        deliverItem(msg.sender, itemUniqueIdentifier);
        }

    /**
     * @dev Internal function to handle the delivery of redeemed items.
     * @param redeemer The address of the redeemer.
     * @param itemUniqueIdentifier The unique identifier of the item to deliver.
     * @dev Implement custom logic in this function to deliver the item.
     */
    function deliverItem(address redeemer, uint256 itemUniqueIdentifier) internal {
        // Example custom logic: Deliver the item to the player
        // This could involve calling another contract or performing specific actions
        
        // For demonstration, let's assume delivering the item means granting access or rights
        // This is a placeholder function and should be customized for your actual use case
       }

    /**
     * @dev Function to burn tokens irreversibly.
     * @param amount The amount of tokens to burn.
     * @dev Emits a TokensBurned event upon successful token burn.
     */
    function burnTokens(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "DegenToken: Insufficient tokens to burn");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);  }

    /**
     * @dev Function to get the balance of the caller.
     * @return The balance of tokens for the caller.
     */
    function getBalance() external view returns (uint256) {
        return balanceOf(msg.sender);
        }

    /**
     * @dev Function to add an item to the store.
     * @param itemName The name of the item to add.
     * @param itemPrice The price of the item to add.
     * @dev Only callable by the contract owner.
     * @dev Emits an ItemAdded event upon successful addition.
     */
    function addItemToStore(string memory itemName, uint256 itemPrice) external onlyOwner {
        totalItems++;
        storeItems[totalItems] = StoreItem(itemName, itemPrice);
        emit ItemAdded(totalItems, itemName, itemPrice);
      }

    /**
     * @dev Function to remove an item from the store.
     * @param itemUniqueIdentifier The unique identifier of the item to remove.
     * @dev Only callable by the contract owner.
     * @dev Emits an ItemRemoved event upon successful removal.
     */
    function removeItemFromStore(uint256 itemUniqueIdentifier) external onlyOwner {
        require(itemUniqueIdentifier > 0 && itemUniqueIdentifier <= totalItems, "DegenToken: Invalid item identifier");
        delete storeItems[itemUniqueIdentifier];
        emit ItemRemoved(itemUniqueIdentifier);
    }

    /**
     * @dev Function to show available items in the store.
     * @return itemList A string containing the list of available items.
     */
    function showStoreItems() external view returns (string memory itemList) {
        for (uint256 i = 1; i <= totalItems; i++) {
            itemList = string(abi.encodePacked(itemList, uintToString(i), ". ", storeItems[i].name, " - ", uintToString(storeItems[i].price), " DGN\n"));
        }
      }

    /**
     * @dev Internal function to convert uint to string.
     * @param v The uint value to convert.
     * @return str The string representation of the uint value.
     */
    function uintToString(uint256 v) internal pure returns (string memory str) {
        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint256 j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1];
        }
        str = string(s);
    }
}


   


