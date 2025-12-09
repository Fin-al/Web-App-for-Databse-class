DROP TABLE IF EXISTS Assignment;
DROP TABLE IF EXISTS Request;
DROP TABLE IF EXISTS Blackout;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Building;
DROP TABLE IF EXISTS Class;
DROP TABLE IF EXISTS Secretary;
DROP TABLE IF EXISTS Administrator;
DROP TABLE IF EXISTS Faculty;
DROP TABLE IF EXISTS `User`;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL,
    DeptContactInfo VARCHAR(255),
    CONSTRAINT UC_DeptName UNIQUE (DeptName)
);

CREATE TABLE `User` (
    UserID INT PRIMARY KEY,
    UserName VARCHAR(50) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Email VARCHAR(100),
    UserType VARCHAR(20) NOT NULL,
    CONSTRAINT UC_UserName UNIQUE (UserName),
    CONSTRAINT UC_UserEmail UNIQUE (Email)
);

CREATE TABLE Secretary (
    SecretaryID INT PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    DeptID INT NOT NULL UNIQUE,
    FOREIGN KEY (UserID) REFERENCES `User`(UserID),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

CREATE TABLE Administrator (
    AdminID INT PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    FOREIGN KEY (UserID) REFERENCES `User`(UserID)
);

CREATE TABLE Building (
    BldgID INT PRIMARY KEY,
    BldgName VARCHAR(100) NOT NULL,
    BldgContactInfo VARCHAR(255),
    DeptID INT,
    CONSTRAINT UC_BldgName UNIQUE (BldgName),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

CREATE TABLE Room (
    RoomID INT PRIMARY KEY,
    BldgID INT NOT NULL,
    RoomNumber VARCHAR(10) NOT NULL,
    Capacity INT NOT NULL,
    Equipment VARCHAR(255),
    ReservedStatus BOOLEAN DEFAULT FALSE,
    RoomType VARCHAR(50),
    FOREIGN KEY (BldgID) REFERENCES Building(BldgID),
    CONSTRAINT UC_RoomLocation UNIQUE (BldgID, RoomNumber)
);

CREATE TABLE Blackout (
    BlackoutID INT PRIMARY KEY,
    RoomID INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    Reason VARCHAR(255),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);

CREATE TABLE Class (
    ClassID INT PRIMARY KEY,
    DeptID INT NOT NULL,
    ClassName VARCHAR(100) NOT NULL,
    SectionNum VARCHAR(10) NOT NULL,
    Semester VARCHAR(20) NOT NULL,
    Year INT NOT NULL,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
    CONSTRAINT UC_ClassSection UNIQUE (ClassName, SectionNum, Semester, Year)
);

CREATE TABLE Request (
    RequestID INT PRIMARY KEY,
    ClassID INT NOT NULL UNIQUE,
    DeptID INT NOT NULL,
    Priority INT,
    EquipRequest VARCHAR(255),
    PreferredRoomID INT,
    PreferredTime VARCHAR(100),
    DateSubmitted DATETIME NOT NULL,
    CardBltID VARCHAR(50),
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
    FOREIGN KEY (PreferredRoomID) REFERENCES Room(RoomID)
);

CREATE TABLE Assignment (
    AssignmentID INT PRIMARY KEY,
    ClassID INT NOT NULL UNIQUE,
    RoomID INT NOT NULL,
    DayOfWeek VARCHAR(10) NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    AssignmentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT UC_RoomTimeSlot UNIQUE (RoomID, DayOfWeek, StartTime, EndTime)
);