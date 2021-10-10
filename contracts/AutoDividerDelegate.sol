// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Initializable.sol";
import "./AutoDividerStorage.sol";


contract AutoDividerDelegate is Initializable, AccessControl, AutoDividerStorage {
    event AddUser(address user, uint allocPoint);
    event SetUser(address user, uint allocPoint);

    function initialize(address admin) public payable initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function addAddress(address user, uint allocPoint) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        require(!users.contains(user), "user exist");
        users.add(user);
        userAllocs[user] = allocPoint;
        totalAllocPoint = totalAllocPoint.add(allocPoint);
        emit AddUser(user, allocPoint);
    }

    function setAddress(address user, uint allocPoint) public {
        removeAddress(user);
        addAddress(user, allocPoint);
    }

    function removeAddress(address user) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        require(users.contains(user), "user not exist");
        users.remove(user);
        totalAllocPoint = totalAllocPoint.sub(userAllocs[user]);
        userAllocs[user] = 0;
    }

    function getUsers() public view returns (address[] memory _users, uint[] memory _allocPoints) {
        uint length = users.length();
        _users = new address[](length);
        _allocPoints = new uint[](length);
        for (uint i=0; i<length; i++) {
            _users[i] = users.at(i);
            _allocPoints[i] = userAllocs[_users[i]];
        }
    }

    function redeem(address token) public {
        uint balance = IERC20(token).balanceOf(address(this));
        address[] memory _users;
        uint[] memory _allocPoints;
        uint _amount;
        address _user;

        require(balance > 0, "balance is zero");

        (_users, _allocPoints) = getUsers();

        for (uint i=0; i<_users.length; i++) {
            _amount = balance.mul(_allocPoints[i]).div(totalAllocPoint);
            _user = _users[i]; 
            IERC20(token).transfer(_user, _amount);
        }
    }
}
