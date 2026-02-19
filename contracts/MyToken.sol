// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SchoolManagement {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    enum Level { L100, L200, L300, L400 }

    struct Student {
        uint id;
        string name;
        Level level;
        bool isRegistered;
        bool feePaid;
        uint amountPaid;
        uint paymentTimestamp;
    }

    struct Staff {
        uint id;
        string name;
        bool isRegistered;
        bool salaryPaid;
        uint salaryAmount;
        uint paymentTimestamp;
    }

    uint public studentCount;
    uint public staffCount;

    mapping(uint => Student) public students;
    mapping(uint => Staff) public staffs;

    // Level-based school fees
    function getSchoolFee(Level _level) public pure returns (uint) {
        if (_level == Level.L100) return 1 ether;
        if (_level == Level.L200) return 2 ether;
        if (_level == Level.L300) return 3 ether;
        if (_level == Level.L400) return 4 ether;
        revert("Invalid level");
    }

    // Register Student (must pay correct fee)
    function registerStudent(string memory _name, Level _level) public payable {
        uint requiredFee = getSchoolFee(_level);
        require(msg.value == requiredFee, "Incorrect fee amount");

        studentCount++;

        students[studentCount] = Student({
            id: studentCount,
            name: _name,
            level: _level,
            isRegistered: true,
            feePaid: true,
            amountPaid: msg.value,
            paymentTimestamp: block.timestamp
        });
    }

    // Get student details
    function getStudent(uint _id) public view returns (Student memory) {
        require(students[_id].isRegistered, "Student not found");
        return students[_id];
    }

    // Get all students (IDs only)
    function getAllStudentsCount() public view returns (uint) {
        return studentCount;
    }

    // Register Staff (no payment required)
    function registerStaff(string memory _name) public onlyOwner {
        staffCount++;

        staffs[staffCount] = Staff({
            id: staffCount,
            name: _name,
            isRegistered: true,
            salaryPaid: false,
            salaryAmount: 0,
            paymentTimestamp: 0
        });
    }

    // Pay Staff Salary
    function payStaff(uint _id) public payable onlyOwner {
        require(staffs[_id].isRegistered, "Staff not found");
        require(msg.value > 0, "Salary must be greater than 0");

        staffs[_id].salaryPaid = true;
        staffs[_id].salaryAmount = msg.value;
        staffs[_id].paymentTimestamp = block.timestamp;
    }

    // Get staff details
    function getStaff(uint _id) public view returns (Staff memory) {
        require(staffs[_id].isRegistered, "Staff not found");
        return staffs[_id];
    }

    // Withdraw contract balance (Owner only)
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
