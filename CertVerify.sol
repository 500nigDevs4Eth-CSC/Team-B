pragma solidity >=0.5.0 < 0.6.0;

import "./Ownable.sol";

contract CertVerify is Ownable {
    
    uint public maxAdmins = 2;
    uint public adminIndex = 0;
    uint public studentIndex = 0;
    
    enum assignmentStatus { 
        Inactive,
        Pending,
        Completed
    }
    
    enum grades { 
        Good, 
        Great, 
        Outstanding, 
        Epic, 
        Legendary
    }
    
    struct Admin {
        bool authorized;
        uint Id;
    }
    
    struct Assignment {
        string link;
        bytes32 assignmentStatus;
    }
    
    struct Student {
        bytes32 firstName;
        bytes32 lastName;
        bytes32 commendation;
        bytes32 grades;
        uint16 assignmentIndex;
        bool active;
        string email;
        uint16 assignments;
    }
    
    mapping(address => Admin) public admins;
    mapping(uint => address) public adminsReverseMapping;
    mapping(uint => Student) public students;
    mapping(string => uint) public studentsReverseMapping;
    
    modifier onlyAdmins() {
        require(admins[msg.sender].authorized = true, "Only admins allowed");
        _;
    }
    
    modifier onlyNonOwnerAdmins(address _addr) {
        require(_addr != owner(), "only none-owner admin");
        _;
    }
    
    modifier onlyPermissibleAdminLimit() {
        require(adminIndex <= 1, "Maximum admins already");
        _;
    }
    
    modifier onlyNonExistentStudents(string memory _email) {
        require(keccak256(abi.encodePacked(students[studentsReverseMapping[_email]].email)) 
        != keccak256(abi.encodePacked(_email)), "Email already exist");
        _;
    }
   
    modifier onlyValidStudents(string memory _email)  {
        require(keccak256(abi.encodePacked(students[studentsReverseMapping[_email]].email)) 
        == keccak256(abi.encodePacked(_email)), "Email already exist");
        _;
   }
    
    constructor() public {
        maxAdmins = 2;
        _addAdmin(msg.sender);
    }
    
    function addAdmin(address _newAdmin) public onlyOwner onlyPermissibleAdminLimit {
        _addAdmin(_newAdmin);
    } 
    
    function _addAdmin(address _newAdmin) internal returns(string memory){
        Admin memory admin = admins[_newAdmin];
        require(admins[_newAdmin].authorized = false, "Already an admin");
        admins[_newAdmin] = admin;
        adminsReverseMapping[adminIndex] = _newAdmin;
        adminIndex++;                                                                                             //safemath
        //emit AdminAdded(address _newAdmin);
    }
    
    function removeAdmin(address _admin) public onlyOwner {
        require(_admin != owner(), "Cannot remove owner");
        _removeAdmin(_admin);
    } 
    
    function _removeAdmin(address _admin) internal returns (string memory) {
        require(_admin != owner(), "Cannot remove owner");
        require(adminIndex > 1, "Cannot operate without admin");
        require(admins[_admin].authorized = true, "Not an admin");
        delete admins[_admin].Id;
        adminIndex--;                                                                                               //safemath
    }
    
    //Create the Student struct on the current studentIndex, pass assignment index as 0 and set the student as active
    
    function addStudent(bytes32 _firstName, bytes32 _lastName, bytes32 _commendation, grades _grades, string memory _email) public onlyAdmins onlyNonExistentStudents(_email) returns(bool) {
        
            Student memory student = students[studentIndex];
            student.firstName = _firstName;
            student.lastName = _lastName;
            student.commendation = _commendation;
            //student.grades = _grades;                                                                             //check how to include enums
            student.email = _email;
            student.assignmentIndex = 0;
            student.active = true;
            studentsReverseMapping[_email] = studentIndex;
            return true;
            studentIndex++;                                                                                         //safemath
            //emit StudentAdded
    }
    
    function removeStudent(string memory _email) public onlyAdmins onlyValidStudents(_email) returns(bool) {
        Student memory student = students[studentIndex];
        studentsReverseMapping[_email] = studentIndex;
        student.active = false;
        studentIndex--;                                                                                             //safemath
        return true;
        //emit studentRemoved
    }
    
    function changeAdminLimit(uint _newAdminLimit) public {
        require(_newAdminLimit > 1 && adminIndex, "Cannot have lesser admins");
        maxAdmins += _newAdminLimit;                                                                                //safemath
        //event AdminLimitChanged
    }
}