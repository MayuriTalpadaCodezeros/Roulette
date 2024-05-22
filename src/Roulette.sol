// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Roulette {
    address public owner;
    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public totalPayout;
    uint256 public totalBets;
    uint256 private randomNumber;

    struct Bet {
        address bettor;
        uint256 amount;
        uint256 number;
    }

    Bet[] public bets;

    mapping (uint => bool) public betsMap;

    event BetPlaced(address indexed bettor, uint256 amount, uint256 number);
    event Payout(address indexed bettor, uint256 amount);
    event LogPayout(address indexed berrot, uint256 amount);

    constructor(uint256 _minimumBet) {
        owner = msg.sender;
        minimumBet = _minimumBet*10**18;
    }

    function placeBet(uint256 _number) public payable {
        uint value = msg.value ;
        require(value >= minimumBet, "Bet amount is too low");
        require(_number >= 0 && _number <= 36, "Invalid number");
        require(betsMap[_number] == false, "number is alredy bet");

        Bet memory newBet = Bet(msg.sender, msg.value, _number);
        bets.push(newBet);

        totalBet += value;
        totalBets++;
        betsMap[_number] = true;

        emit BetPlaced(msg.sender, value, _number);
    }

    function generateRandomNumber() public returns (uint) {
        randomNumber = (block.timestamp + block.difficulty) % 36;
        return randomNumber;
    }

    function payout() public returns(uint) {
        require(msg.sender == owner, "Only the owner can payout");
        require(bets.length > 0, "No bets to payout");

        uint256 winningNumber = generateRandomNumber();
        uint256 totalPayoutAmount = 0;

        for (uint256 i = 0; i < bets.length; i++) {
            Bet memory currentBet = bets[i];
            if (currentBet.number == winningNumber) {
                // uint256 payoutAmount = currentBet.amount * 2;
                uint256 payoutAmount = totalBet*90 / 100;
                totalPayoutAmount += payoutAmount;

                // Log the payout amount and winner's address
                emit LogPayout(currentBet.bettor, payoutAmount);

                // Transfer the payout amount to the winner
                (bool success, ) = currentBet.bettor.call{value: payoutAmount}("");
                require(success, "Transfer failed");
            }
        }

        // Update the total payout amount
        totalPayout += totalPayoutAmount;
        totalBet = 0;
        totalBets = 0;

        // Reset the bets array and mapping
        delete bets;
        for (uint256 i = 0; i <= 36; i++) {
            betsMap[i] = false;
        }
        return (winningNumber);
    }

    function withdraw() payable public {
        require(msg.sender == owner, "Only the owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
    
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}