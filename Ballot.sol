pragma solidity ^0.4.16;
/**
*模拟投票的智能合约
*/
contract Ballot {
    /*
    * 投票人信息
    */
    struct Voter {
        uint weight;//票数，一般情况下每人一票
        bool voted;//是否已经投票
        address delegate;//委托人
        uint vote;//投给了哪个人，对应proposal的索引
    }
    /*
    * 候选人信息
    */
    struct Proposal {
        bytes32 name;//候选人名字
        uint voteCount;//得票数
    }
    /*
    * 投票发起人
    */
    address public chairPerson;
    /*
    * 投票人
    */
    mapping(address => Voter) public voters;
    /*
    * 候选人列表
    */
    Proposal[] public proposals;
    /*
    * 构造函数，构造时需要指定候选人信息
    */
    function Ballot(bytes32[] proposalNames) public {
        chairPerson = msg.sender;
        voters[chairPerson].weight = 1;
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name : proposalNames[i],
                voteCount : 0
                }));
        }
    }
    /*
    * 对指定的地址授予投票权
    */
    function giveRightToVote(address voter) public {
        require(chairPerson == msg.sender && !voters[voter].voted && voters[voter].weight == 0);
        voters[voter].weight = 1;
    }
    /*
    * 将投票权委托给其他人
    */
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted);
        require(to != msg.sender);
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender);
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate = voters[to];
        if (delegate.voted) {
            proposals[delegate.vote].voteCount += sender.weight;
        } else {
            delegate.weight += sender.weight;
        }
    }
    /*
    * 投票
    */
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted);
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }
    /*
    * 获取胜出的候选人，返回对应的数组索引
    */
    function winningProposal() public view returns (uint winningProposal){
        uint winningVoteCount = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposal = i;
            }
        }
    }
    /*
    * 获取胜出的候选人的名字
    */
    function winnerName() public view returns (bytes32 winnerName){
        winnerName = proposals[winningProposal()].name;
    }
}