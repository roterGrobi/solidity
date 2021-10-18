import "./Ownable.sol";

contract SelfDestruct is Ownable{
    function close() public onlyOwner{ 
        selfdestruct(owner); 
    }
}
