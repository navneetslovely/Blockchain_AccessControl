pragma solidity 0.4.25;


contract Judge {
    uint public base;
    uint public interval;
    address public owner;

    event IsCalled (address _from, uint _time, uint _penalty);

    struct Misbehaviour {
        address subject;

    }
}
