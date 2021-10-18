pragma solidity 0.7.5;

import "./Ownable.sol";
import "./Selfdestruct.sol";

interface GovernmentInterface{
    function addTransaction(address _from, address _to, uint _amount) external payable;
}

contract Bank is Ownable,SelfDestruct{
    
    GovernmentInterface governmentInstance = GovernmentInterface(0xEc29164D68c4992cEdd1D386118A47143fdcF142);
    
    mapping (address=>uint) balance;
    
    event depositDone(uint,address);
    
    function deposit() public payable returns(uint){
        balance[msg.sender] += msg.value;
        emit depositDone(msg.value,msg.sender);
        return balance[msg.sender];
    }
    
    function getbalance() public view returns(uint){
        return balance[msg.sender];
    }
    
    function withdraw(uint amount) public onlyOwner returns(uint){
        require(balance[msg.sender] >= amount, "you do not have the required funds");
        msg.sender.transfer(amount);
        balance[msg.sender] -= amount;
        return balance[msg.sender];
    }
    
    function transfer(address recipient, uint amount) public{
        require(balance[msg.sender] >= amount, "Balance not sufficient");
        require(msg.sender != recipient, "Don't send money to yourself");
        
        uint previousSenderBalance = balance[msg.sender];
        
        _tranfer(msg.sender, recipient, amount);
        
        governmentInstance.addTransaction{value: 1 ether}(msg.sender, recipient, amount);
        
        assert(balance[msg.sender] == previousSenderBalance - amount);
        
    }
    
    function _tranfer(address from, address to, uint amount) public {
        balance[from] -= amount;
        balance[to] += amount; 
    }
}
