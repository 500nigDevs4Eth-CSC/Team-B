pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./SafeMath.sol";

contract CertVerify is Ownable {
    using SafeMath for uint256;

    uint256 public maxAdmins = 2;
    uint256 public adminIndex = 0;
    uint256 public studentIndex = 0;

    enum assignmentStatus {Inactive, Pending, Completed}

    enum grades {Good, Great, Outstanding, Epic, Legendary}

    struct Admin {
        bool authorized;
        uint256 Id;
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
    mapping(uint256 => address) public adminsReverseMapping;
    mapping(uint256 => Student) public students;
    mapping(string => uint256) public studentsReverseMapping;

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
        require(
            keccak256(
                abi.encodePacked(students[studentsReverseMapping[_email]].email)
            ) !=
                keccak256(abi.encodePacked(_email)),
            "Email already exist"
        );
        _;
    }

    modifier onlyValidStudents(string memory _email) {
        require(
            keccak256(
                abi.encodePacked(students[studentsReverseMapping[_email]].email)
            ) ==
                keccak256(abi.encodePacked(_email)),
            "Email does not exist"
        );
        _;
    }

    constructor() public {
        maxAdmins = 2;
        _addAdmin(msg.sender);
    }

    function addAdmin(address _newAdmin)
        public
        onlyOwner
        onlyPermissibleAdminLimit
    {
        _addAdmin(_newAdmin);
    }

    function _addAdmin(address _newAdmin) internal returns (string memory) {
        Admin memory admin = admins[_newAdmin];
        require(admins[_newAdmin].authorized = false, "Already an admin");
        admins[_newAdmin] = admin;
        adminsReverseMapping[adminIndex] = _newAdmin;
        adminIndex = adminIndex.add(1);
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
        adminIndex = adminIndex.sub(1);
    }

    function addStudent(
        bytes32 _firstName,
        bytes32 _lastName,
        bytes32 _commendation,
        bytes32 _grades,
        string memory _email
    ) public onlyAdmins onlyNonExistentStudents(_email) {
        Student memory student = students[studentIndex];
        student.firstName = _firstName;
        student.lastName = _lastName;
        student.commendation = _commendation;
        student.grades = _grades;
        student.email = _email;
        student.assignmentIndex = 0;
        student.active = true;
        studentsReverseMapping[_email] = studentIndex;
        studentIndex = studentIndex.add(1);
        //emit StudentAdded
    }

    function removeStudent(string memory _email)
        public
        onlyAdmins
        onlyValidStudents(_email)
    {
        Student memory student = students[studentIndex];
        studentsReverseMapping[_email] = studentIndex;
        student.active = false;
        studentIndex = studentIndex.sub(1);
        //emit studentRemoved
    }

    function changeAdminLimit(uint256 _newAdminLimit) public {
        require(
            _newAdminLimit > 1 && _newAdminLimit > adminIndex,
            "Cannot have lesser admins"
        );
        maxAdmins = maxAdmins.add(_newAdminLimit);
        //event AdminLimitChanged
    }

    function changeStudentName(
        bytes32 _firstName,
        bytes32 _lastName,
        string memory _email
    ) public onlyAdmins onlyValidStudents(_email) {
        Student memory student = students[studentIndex];
        studentsReverseMapping[_email] = studentIndex;
        student.firstName = _firstName;
        student.lastName = _lastName;
        //emit
    }

    function changeStudentCommendation(
        bytes32 _commendation,
        string memory _email
    ) public onlyAdmins onlyValidStudents(_email) {
        Student memory student = students[studentIndex];
        studentsReverseMapping[_email] = studentIndex;
        student.commendation = _commendation;
        //emit
    }

    //function changeStudentGrade(bytes32 _grades, string memory _email) public onlyAdmins onlyValidStudents(_email) {
    //    Student memory student = students[studentIndex];
    //    studentsReverseMapping[_email] = studentIndex;
    //    Grades = grades._grades;
    //    emit
    //}

    function changeStudentEmail(string memory _email)
        public
        onlyAdmins
        onlyValidStudents(_email)
    {
        Student memory student = students[studentIndex];
        studentsReverseMapping[_email] = studentIndex;
        student.email = _email;
        //emit
    }

    //function _calcAndFetchAssignmentIndex

    //Passes Student struct as storage and indicator boolean (isFinalProject) to tell if the project is final project or just an assignment
    //Calculates and returns the index of the assignment for that particular student based on the following conditions
    //If it is the final project then as per requirements assignmentIndex 0 is reserved for it and hence that is returned
    //Else, it is a new assignment which means that we pull the assignmentIndex of the particular student, increment it using SafeMath and then return that value
    //Since the value returned can either be 0 or the new assignment index, it is recommended to return a memory uint (though do store the new assignment index in the student struct)
    //}

}
