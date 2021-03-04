// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";

contract AutoDivider is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint public totalAllocPoint;

    EnumerableSet.AddressSet private users;

    mapping(address => uint) public userAllocs;

    event AddUser(address user, uint allocPoint);

    event SetUser(address user, uint allocPoint);

    function addAddress(address user, uint allocPoint) public onlyOwner {
        users.add(user);
        userAllocs[user] = allocPoint;
        totalAllocPoint = totalAllocPoint.add(allocPoint);

        emit AddUser(user, allocPoint);
    }

    function setAddress(address user, uint allocPoint) public onlyOwner {
        if (users.contains(user)) {
            users.remove(user);
            totalAllocPoint = totalAllocPoint.sub(userAllocs[user]);
        }

        users.add(user);

        userAllocs[user] = allocPoint;
        totalAllocPoint = totalAllocPoint.add(allocPoint);

        emit SetUser(user, allocPoint);
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
