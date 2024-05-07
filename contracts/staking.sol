// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.0 and less than 0.9.0
pragma solidity ^0.8.17;


import "./erc20.sol";

contract StakingContract {
  ERC20TOKEN tokenContract;

  
  uint256 penaltyPercentage=3;
  uint256 fixedInterestRate=6;
  uint256 UnfixedInterestRate=3;
  uint256 expiryTime=block.timestamp+60;
  uint256 Interest;

    struct Staking {
        uint256 amount;
        uint256 Time;
        string staking_type;
         bool staked;
      }
    event fixedStaking(address user, uint256 amount , uint256 duration);
    event Unfixed_stake(address user, uint256 amount);
    event unstaking(address user);
    mapping(address => Staking) public staking_detail;
    
         constructor(ERC20TOKEN _tokenContract){
                tokenContract=_tokenContract;
         }



     function staking(uint256 _amount, uint256 _duration , string memory _staking_type, bool _staked) public{
     require(tokenContract.balanceOf(msg.sender) >= _amount, "balance is <= token");
          if (keccak256(abi.encodePacked(_staking_type))==keccak256(abi.encodePacked("fixed_stake"))){
               require(_amount > 0, "token is <= 0");
               staking_detail[msg.sender].amount = _amount;
               staking_detail[msg.sender].staking_type= _staking_type;
               staking_detail[msg.sender].Time = block.timestamp+_duration;
               staking_detail[msg.sender].staked=_staked;
            tokenContract.transfer(msg.sender, address(this) , _amount);
            emit fixedStaking(msg.sender, _amount, _duration);
          }  
          else if (keccak256(abi.encodePacked(_staking_type))==keccak256(abi.encodePacked("Unfixed_stake"))){
              require(_amount > 0, "token is <= 0");
              staking_detail[msg.sender].amount = _amount;
              staking_detail[msg.sender].staking_type= _staking_type;
              staking_detail[msg.sender].staked=_staked;
              tokenContract.transfer(msg.sender, address(this),_amount);
              emit Unfixed_stake(msg.sender, _amount);
        }
  }
      function UnStaking(address user) public{
       // require(staking_detail[msg.sender] == user,"invalid user");

          if(staking_detail[user].staked==true){
            if(staking_detail[user].Time>block.timestamp){
             
             Interest=(staking_detail[user].amount*fixedInterestRate)/100;
             uint256 penaltyAmount=(staking_detail[user].amount*penaltyPercentage)/100;
             staking_detail[user].amount=staking_detail[user].amount+Interest-penaltyAmount;
              tokenContract.transfer(address(this), user,  staking_detail[user].amount);
              delete staking_detail[user];

            }
            else if(staking_detail[user].Time<=block.timestamp){
              Interest=(staking_detail[user].amount*fixedInterestRate)/100;
              staking_detail[user].amount=staking_detail[user].amount+Interest;
              tokenContract.transfer(address(this), user,  staking_detail[user].amount);
               delete staking_detail[user];

            }
          }
          else if(staking_detail[user].staked==false){
             Interest=(staking_detail[user].amount*UnfixedInterestRate)/100;
             staking_detail[user].amount=staking_detail[user].amount+Interest;
             tokenContract.transfer(address(this), user,  staking_detail[user].amount);
              delete staking_detail[user];

          }
      }
        function claimedRewards(address _address) public view returns (uint256) {
         if (staking_detail[_address].staked == true) {
          if (block.timestamp > staking_detail[_address].Time) {
            return staking_detail[_address].amount + Interest;
        } else {
            return staking_detail[_address].amount;
        }
    } else {
        return staking_detail[_address].amount + Interest;
    }
}
   function unclaimedRewards(address _address) public view returns (uint256) {
         if (staking_detail[_address].staked == true) {
         if (block.timestamp > staking_detail[_address].Time) {
            return 0;
        } else {
            return Interest;
        }
      } else {
        return Interest;
    }
  }
}
