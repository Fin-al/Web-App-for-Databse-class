-- Drop tables in reverse order of foreign key dependencies to allow clean re-creation
DROP TABLE IF EXISTS Assignment;
DROP TABLE IF EXISTS Request;
DROP TABLE IF EXISTS Blackout;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Building;
DROP TABLE IF EXISTS Class;
DROP TABLE IF EXISTS Secretary;
DROP TABLE IF EXISTS Faculty;
DROP TABLE IF EXISTS Administrator;
DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Department;


-- 1. DEPARTMENT Table
-- Manages departments that submit requests and offer classes.
CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL UNIQUE,
    DeptContactInfo VARCHAR(255)
);

-- 2. USER Table (Parent table for Faculty, Secretary, Administrator)
-- Manages general user login and identification.
CREATE TABLE User (
    UserID INT PRIMARY KEY,
    UserName VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL, -- Store salted and hashed passwords!
    Email VARCHAR(100) UNIQUE,
    UserType VARCHAR(20) NOT NULL -- 'Faculty', 'Secretary', 'Administrator' [cite: 23]
);

-- 3. SECRETARY Table (1:1 with User, 1:1 with Department)
-- Manages users with the right to submit and change class requests[cite: 25, 29].
CREATE TABLE Secretary (
    SecretaryID INT PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    DeptID INT NOT NULL UNIQUE,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- 4. FACULTY Table (1:1 with User)
-- Simple extension for future faculty-specific features.
CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

-- 5. ADMINISTRATOR Table (1:1 with User)
-- Manages users with authority to change any system information[cite: 27, 32].
CREATE TABLE Administrator (
    AdminID INT PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);


-- 6. BUILDING Table (1:N relationship with Department, 1:N with Room)
-- Tracks building information and which department primarily resides in it (via FK).
CREATE TABLE Building (
    BldgID INT PRIMARY KEY,
    BldgName VARCHAR(100) NOT NULL UNIQUE,
    BldgContactInfo VARCHAR(255),
    DeptID INT, -- The department that 'Belongs' to this building (as per diagram)
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);


-- 7. ROOM Table (1:N with Building, 1:N with Blackout)
-- Stores physical classroom data.
CREATE TABLE Room (
    RoomID INT PRIMARY KEY,
    BldgID INT NOT NULL,
    RoomNumber VARCHAR(10) NOT NULL,
    Capacity INT NOT NULL,
    Equipment VARCHAR(255), -- List of available equipment
    ReservedStatus BOOLEAN DEFAULT FALSE,
    RoomType VARCHAR(50), -- e.g., 'Lecture Hall', 'Lab', 'Seminar'
    FOREIGN KEY (BldgID) REFERENCES Building(BldgID),
    UNIQUE KEY (BldgID, RoomNumber) -- Room number must be unique within a building
);

-- 8. BLACKOUT Table (1:N with Room)
-- Stores times when a room is unavailable for assignment[cite: 18, 36].
CREATE TABLE Blackout (
    BlackoutID INT PRIMARY KEY,
    RoomID INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    Reason VARCHAR(255),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);


-- 9. CLASS Table (1:N with Department via Offers relationship)
-- Represents a course that needs a room assignment.
CREATE TABLE Class (
    ClassID INT PRIMARY KEY,
    DeptID INT NOT NULL, -- Department that 'Offers' this class (MajorID in diagram)
    ClassName VARCHAR(100) NOT NULL,
    SectionNum VARCHAR(10) NOT NULL, -- Section number is mandatory [cite: 31]
    Semester VARCHAR(20) NOT NULL,
    Year INT NOT NULL,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
    UNIQUE KEY (ClassName, SectionNum, Semester, Year) -- A class section is unique per semester/year
);

-- 10. REQUEST Table (N:1 with Class, N:1 with Department, 1:1 with Room)
-- Stores the class requests submitted by the Department Secretary.
CREATE TABLE Request (
    RequestID INT PRIMARY KEY,
    ClassID INT NOT NULL UNIQUE, -- 1:1 relationship with Class in diagram
    DeptID INT NOT NULL, -- Department that submitted the request
    Priority INT,
    EquipRequest VARCHAR(255), -- Preferred equipment is optional [cite: 31]
    PreferredRoomID INT, -- Preferred classroom is optional [cite: 31]
    PreferredTime VARCHAR(100), -- Preferred time is optional [cite: 31]
    DateSubmitted DATETIME NOT NULL,
    CardBltID VARCHAR(50), -- Placeholder for CardBltID from diagram
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
    FOREIGN KEY (PreferredRoomID) REFERENCES Room(RoomID)
);


-- 11. ASSIGNMENT Table
-- Stores the final, non-conflicting room assignments.
CREATE TABLE Assignment (
    AssignmentID INT PRIMARY KEY,
    ClassID INT NOT NULL UNIQUE, -- Only one assignment per class section
    RoomID INT NOT NULL,
    DayOfWeek VARCHAR(10) NOT NULL, -- e.g., 'MW', 'TTH', 'F'
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    AssignmentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    -- Constraint to prevent double-booking: A room cannot be used for two different classes at the same time
    UNIQUE KEY (RoomID, DayOfWeek, StartTime, EndTime)
);