pragma solidity 0.7.5;
pragma abicoder v2;

contract Multisig {
    
    uint balance;
    address[] public owners;
    uint approvalsNeeded;
    
    struct Transfer {
        uint txId;
        address payable to;
        uint amount;
        uint approvals;
        bool hasBeenSent;
    }
    
    //event TransferRequestCreated(uint _id, uint _amount, address _initiator, address _receiver);
    //event ApprovalReceived(uint _id, uint _approvals, address _approver);
    //event TransferApproved(uint _id);
    
    Transfer[] transferRequests;
    
    mapping(address => mapping(uint => bool)) approvals;
    
    modifier onlyOwners(){
        bool owner = false;
        for(uint i=0; i<owners.length;i++){
            if(owners[i] == msg.sender){
                owner = true;
            }
        }
        require(owner == true);
        _;
    }
    
    constructor(address[] memory _owners, uint _approvalsNeeded ) {
        owners = _owners;
        approvalsNeeded = _approvalsNeeded;
    } 
    
    function deposit() public payable {
        balance += msg.value;
    }
    
    function getBalance() public view returns( uint ) {
        return balance;
    }
    
    function getTransferRequests() public view returns( Transfer[] memory ) {
        return transferRequests;
    }
    
    function transfer( address payable _to, uint _amount ) public onlyOwners returns( Transfer memory ) {
        require(balance >= _amount, "Balance not sufficient");
        //emit TransferRequestCreated(transferRequests.length, _amount, msg.sender, _to);
        Transfer memory transfer1;
        transfer1.txId = transferRequests.length;
        transfer1.to = _to;
        transfer1.amount = _amount;
        transfer1.approvals = 0;
        transfer1.hasBeenSent = false;
        transferRequests.push(transfer1);
        return transfer1;
    }
    
    function approveTransfer( uint _txId ) public onlyOwners returns( Transfer memory ) {
        require(balance >= transferRequests[_txId].amount, "Balance not sufficient");
        require(approvals[msg.sender][_txId] == false);
        require(transferRequests[_txId].hasBeenSent == false);
        
        approvals[msg.sender][_txId] = true;
        transferRequests[_txId].approvals++;
        
        //emit ApprovalReceived(_txId, transferRequests[_txId].approvals, msg.sender);
        
        if(transferRequests[_txId].approvals >= approvalsNeeded){
          transferRequests[_txId].hasBeenSent = true;
          transferRequests[_txId].to.transfer(transferRequests[_txId].amount);
          balance -= transferRequests[_txId].amount;
          //emit TransferApproved(_txId);
        }
        return transferRequests[_txId];
    }

}
