pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract WrapToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    constructor(address initialOwner,string memory description, string memory name)
        ERC20(description, name)
        Ownable(initialOwner)
        ERC20Permit(description)
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}