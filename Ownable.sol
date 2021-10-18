contract Ownable{
    
    address payable internal owner;
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
        
    constructor(){
        owner = msg.sender;
    }
    
}
