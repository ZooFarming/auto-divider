// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Initializable.sol";

contract VaultManager is AccessControl, Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct VaultRole {
        string roleName;
        uint256 allocPoint;
        bytes32 roleHash;
        uint256 paid;
    }

    VaultRole[] public vaultRoles;

    uint256 public totalAllocPoint;

    uint256 public totalPaid;

    address public asset;

    mapping(address => string) public addressNames;

    uint public constant LIMIT = 100;

    event Withdraw(uint indexed vid, address indexed user, uint amount);

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "not admin");
        _;
    }

    function initialize(address admin, address _asset) public payable initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        asset = _asset;
    }

    function roleLength() external view returns (uint256) {
        return vaultRoles.length;
    }

    function addRole(string calldata _roleName, uint256 _allocPoint) external onlyAdmin {
        vaultRoles.push(VaultRole({
            roleName: _roleName,
            allocPoint: _allocPoint,
            roleHash: keccak256(_roleName),
            debt: 0
        }));

        totalAllocPoint = totalAllocPoint.add(_allocPoint);
    }

    function removeRole(uint vid) external onlyAdmin {
        vaultRoles[vid] = vaultRoles[vaultRoles.length - 1];
        vaultRoles.pop();
    }

    function addRoleMember(uint vid, address _member, string calldata name) external onlyAdmin {
        grantRole(vaultRoles[vid].roleHash, _member);
        addressNames[_member] = name;
    }

    function removeRoleMember(uint vid, address _member) external onlyAdmin {
        revokeRole(vaultRoles[vid].roleHash, _member);
        delete addressNames[_member];
    }

    function getAsset(uint vid) public view returns (uint256) {
        uint balance = IERC20(asset).balanceOf(address(this));
        uint _asset = balance.add(totalPaid).mul(vaultRoles[vid].allocPoint).div(totalAllocPoint);
        if (_asset > vaultRoles[vid].paid) {
            return _asset.sub(vaultRoles[vid].paid);
        }
        return 0;
    }

    function withdraw(uint vid, uint amount) public {
        require(hasRole(vaultRoles[vid].roleHash, msg.sender), "not in allowed role group");
        uint balance = IERC20(asset).balanceOf(address(this));
        uint availableAsset = getAsset(vid);
        require(amount <= availableAsset, "amount too large");
        require(amount <= balance, "balance is not enough");
        vaultRoles[vid].paid = vaultRoles[vid].paid.add(amount);
        totalPaid = totalPaid.add(amount);
        IERC20(asset).safeTransfer(msg.sender, amount);
        emit Withdraw(vid, msg.sender, amount);
    }

    function multiSender(uint vid, address payable[] calldata _contributors, uint256[] calldata _balances) public {
        require(hasRole(vaultRoles[vid].roleHash, msg.sender), "not in allowed role group");
        uint balance = IERC20(asset).balanceOf(address(this));
        uint availableAsset = getAsset(vid);

        uint256 total = 0;
        require(_contributors.length <= LIMIT, "too more users");
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            vaultRoles[vid].paid = vaultRoles[vid].paid.add(_balances[i]);
            totalPaid = totalPaid.add(_balances[i]);
            total = total.add(_balances[i]);
            IERC20(asset).safeTransfer(_contributors[i], _balances[i]);
        }
        require(total <= availableAsset, "amount too large");
    }
}
