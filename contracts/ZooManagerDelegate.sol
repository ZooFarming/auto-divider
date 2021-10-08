// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Initializable.sol";
import "./ZooManagerStorage.sol";


contract ZooManagerDelegate is Initializable, AccessControl, ZooManagerStorage {
    event AddUser(address user, string name);
    event SetUser(address user, string name);
    event Withdraw(address indexed user, string name, uint amount);

    function initialize(address admin) public payable initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function addAddress(address user, string memory name) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        require(!users.contains(user), "user exist");
        users.add(user);
        userNames[user] = name;
        emit AddUser(user, name);
    }

    function setAddress(address user, string memory name) public {
        removeAddress(user);
        addAddress(user, name);
    }

    function removeAddress(address user) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        require(users.contains(user), "user not exist");
        users.remove(user);
    }

    function getUsers() public view returns (address[] memory _users, string[] memory _names) {
        uint length = users.length();
        _users = new address[](length);
        _names = new string[](length);
        for (uint i=0; i<length; i++) {
            _users[i] = users.at(i);
            _names[i] = userNames[_users[i]];
        }
    }

    function withdraw(address token, uint amount) public {
        uint balance = IERC20(token).balanceOf(address(this));
        require(users.contains(msg.sender), "Not allowed user");
        require(balance > 0, "balance is zero");
        require(balance >= amount, "balance is not enough");
        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw(msg.sender, userNames[msg.sender], amount);
    }
}
