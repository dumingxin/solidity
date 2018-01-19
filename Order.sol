pragma solidity ^0.4.0;

contract Order {
    struct Member {
        bool joined;
        bool payment;
        bool happened;
    }

    mapping(address => Member) public members;

    function Order(){

    }

    function join() public {
        require(!members[msg.sender].joined);
        members[msg.sender].joined = true;
    }
    function leave() public {
        members[msg.sender].joined = false;
    }

}
