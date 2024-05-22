// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Roulette} from "../src/Roulette.sol";

contract CounterTest is Test {
    Roulette public roulette;
    address public buyer = address(12342);

    function setUp() public {
        roulette = new Roulette(5);
    }

    receive() external payable {}

    function testPlaceBet() public  {
        vm.prank(buyer);
        vm.deal(buyer, 10 ether);

        uint256 number = 6;
        uint256 amount = 6 ether ;

        uint256 initialBalance = address(roulette).balance;

        roulette.placeBet{value : amount}(number);

        assertEq(roulette.totalBets(), 1);
        assertEq(roulette.totalBet(), amount);
        assertEq(roulette.betsMap(number), true);

        assertEq(address(roulette).balance, initialBalance + amount ) ;
    }

    function test_PayOut() public {
        vm.prank(buyer);
        vm.deal(buyer, 10 ether);

        uint256 number = 6;
        uint256 amount = 6 ether;

        roulette.placeBet{value : amount}(number);
        vm.prank(address(roulette.owner()));
        roulette.payout();
    }

    function testPayOut_NonAdmin() public {
        vm.prank(address(0x2));
        vm.deal(address(0x2), 10 ether);
        uint256 number = 6;
        uint256 amount = 6 ether;

        roulette.placeBet{value : amount}(number);
        vm.prank(buyer);
        vm.expectRevert("Only the owner can payout");               
        roulette.payout();
    }

    function testPlaceBet_SameNumber() public {
        vm.deal(address(0x2), 10 ether);
        uint256 number = 6;
        uint256 amount = 6 ether;
        roulette.placeBet{value : amount}(number);

        vm.deal(address(0x23), 10 ether);
        uint256 number1 = 6;
        uint256 amount1 = 5 ether;
        vm.expectRevert("number is alredy bet");  
        roulette.placeBet{value : amount1}(number1);
    }

    function testPlaceBet_withLessFees() public {
        console.log(roulette.minimumBet());
        vm.deal(address(0x2), 10 ether);
        uint256 number = 6;
        uint256 amount = 3 ether;   
        vm.expectRevert("Bet amount is too low");
        roulette.placeBet{value : amount}(number);
    }

    function testWithdraw() public {
        vm.prank(address(roulette.owner()));
        roulette.withdraw();
    }

    function testWithdraw_NoOwner() public {
        vm.prank(address(0x11));
        vm.expectRevert("Only the owner can withdraw");
        roulette.withdraw();

    }

}
