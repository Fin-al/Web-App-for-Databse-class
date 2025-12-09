INSERT INTO Department (DeptID, DeptName, DeptContactInfo) VALUES
(100, 'Computer Science', 'cs@university.edu'),
(200, 'Mathematics', 'math@university.edu'),
(300, 'Biology', 'bio@university.edu');

INSERT INTO `User` (UserID, UserName, PasswordHash, Email, UserType) VALUES
(1, 'admin_sys', 'hashed_admin_password', 'admin@school.edu', 'Administrator'),
(101, 'sec_cs', 'hashed_cssec_password', 'cs_sec@school.edu', 'Secretary'),
(201, 'sec_math', 'hashed_mathsec_password', 'math_sec@school.edu', 'Secretary');


INSERT INTO Administrator (AdminID, UserID) VALUES (1, 1);

INSERT INTO Secretary (SecretaryID, UserID, DeptID) VALUES
(10, 101, 100),
(20, 201, 200);

-- No Faculty inserts here

INSERT INTO Building (BldgID, BldgName, BldgContactInfo, DeptID) VALUES
(1, 'Science Center (SC)', 'Ext 4500', 100),
(2, 'Humanities Hall (HH)', 'Ext 4600', 200);

INSERT INTO Room (RoomID, BldgID, RoomNumber, Capacity, Equipment, ReservedStatus, RoomType) VALUES
(1001, 1, '101', 50, 'Projector, Whiteboard, 20 Desktops', FALSE, 'Computer Lab'),
(1002, 1, '105', 100, 'Projector, Lecture Podium', FALSE, 'Lecture Hall'),
(2001, 2, '210', 30, 'Projector, Flexible Seating', FALSE, 'Seminar Room'),
(2002, 2, '212', 45, 'Projector, Whiteboard', FALSE, 'Classroom');

INSERT INTO Blackout (BlackoutID, RoomID, StartTime, EndTime, Reason) VALUES
(1, 1001, '2025-12-15 17:00:00', '2025-12-15 19:00:00', 'Maintenance');

INSERT INTO Class (ClassID, DeptID, ClassName, SectionNum, Semester, Year) VALUES
(440, 100, 'Database Design', '001', 'Fall', 2025),
(450, 100, 'Software Engineering', '002', 'Fall', 2025),
(200, 200, 'Calculus III', '001', 'Fall', 2025);

INSERT INTO Request (RequestID, ClassID, DeptID, Priority, EquipRequest, PreferredRoomID, PreferredTime, DateSubmitted, CardBltID) VALUES
(1, 440, 100, 1, 'Projector, Desktops', 1001, 'MW 10:00-11:30', NOW(), 'CS440_R1'),
(2, 450, 100, 2, 'Lecture Podium', NULL, 'TTH 13:00-14:30', NOW(), 'CS450_R2'),
(3, 200, 200, 1, 'Projector', 2002, 'MW 14:00-15:00', NOW(), 'MATH200_R1');

INSERT INTO Assignment (AssignmentID, ClassID, RoomID, DayOfWeek, StartTime, EndTime) VALUES
(1, 440, 1002, 'MW', '10:00:00', '11:30:00');

INSERT INTO Assignment (AssignmentID, ClassID, RoomID, DayOfWeek, StartTime, EndTime) VALUES
(2, 200, 2001, 'MW', '14:00:00', '15:00:00');