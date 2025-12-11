require('dotenv').config();
const express = require('express');
const mysql = require('mysql');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors({
    origin: 'http://localhost:5173'
}));
app.use(express.json());

const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: "class_manager_db",
    port: process.env.DB_PORT || 3306,
    timezone: 'Z'
});

db.connect(err => {
    if (err) {
        console.error('Database connection failed:', err.stack);
        return;
    }
    console.log('Database connected successfully!');
});

app.post('/api/login', (req, res) => {
    const { username, password } = req.body;

    if (username === 'admin' && password === 'admin123') {
        return res.json({ ok: true, role: 'admin', message: 'Admin logged in successfully.' });
    }
    if (username === 'secretary' && password === 'secret123') {
        return res.json({ ok: true, role: 'secretary', message: 'Secretary logged in successfully.' });
    }

    return res.status(401).json({ ok: false, error: 'Invalid username or password.' });
});

app.get('/api/assignments', (req, res) => {
    const query = `
        SELECT 
            A.DayOfWeek, A.StartTime, A.EndTime, 
            R.RoomNumber, B.BldgName,
            C.ClassName, C.SectionNum,
            D.DeptName
        FROM Assignment A
        JOIN Room R ON A.RoomID = R.RoomID
        JOIN Building B ON R.BldgID = B.BldgID
        JOIN Class C ON A.ClassID = C.ClassID 
        JOIN Department D ON C.DeptID = D.DeptID
        ORDER BY A.DayOfWeek, A.StartTime, B.BldgName, R.RoomNumber;
    `;
    db.query(query, (err, results) => {
        if (err) {
            console.error('SQL QUERY ERROR (assignments):', err);
            return res.status(500).json({ error: err.message });
        }
        res.json(results);
    });
});

app.get('/api/requests', (req, res) => {
    const query = `
        SELECT 
            Req.RequestID, Req.Priority, Req.PreferredTime, Req.EquipRequest,
            C.ClassName, C.SectionNum,
            D.DeptName
        FROM Request Req
        JOIN Class C ON Req.ClassID = C.ClassID 
        JOIN Department D ON C.DeptID = D.DeptID
        WHERE Req.ReqStatus = 'Pending' 
        ORDER BY Req.Priority DESC, Req.RequestID ASC;
    `;
    db.query(query, (err, results) => {
        if (err) {
            console.error('SQL QUERY ERROR (requests):', err);
            return res.status(500).json({ error: err.message });
        }
        res.json(results);
    });
});

app.get('/api/departments', (req, res) => {
    db.query('SELECT DeptID, DeptName FROM Department', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/rooms', (req, res) => {
    const query = `
        SELECT 
            R.RoomID, R.RoomNumber, B.BldgName, R.Capacity 
        FROM Room R
        JOIN Building B ON R.BldgID = B.BldgID;
    `;
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.post('/api/requests', (req, res) => {
    const { classID, deptID, priority, equipRequest, preferredRoomID, preferredTime, cardBltID } = req.body;
    
    if (!classID || !deptID || !preferredTime) {
        return res.status(400).json({ error: 'Class ID, Department ID, and Preferred Time are required.' });
    }

    const query = `
        INSERT INTO Request (ClassID, DeptID, Priority, EquipRequest, PreferredRoomID, PreferredTime, CardBltID, DateSubmitted, ReqStatus) 
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), 'Pending')
    `;
    const values = [classID, deptID, priority, equipRequest || null, preferredRoomID || null, preferredTime, cardBltID || null];

    db.query(query, values, (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Database insertion failed.' });
        }
        res.status(201).json({ message: 'Request submitted successfully.', requestID: result.insertId });
    });
});

app.post('/api/blackouts', (req, res) => {
    const { roomID, dayOfWeek, startTime, endTime, reason } = req.body;

    if (!roomID || !dayOfWeek || !startTime || !endTime || !reason) {
        return res.status(400).json({ error: 'All blackout fields are required.' });
    }

    const query = `
        INSERT INTO Blackout (RoomID, StartTime, EndTime, Reason) 
        VALUES (?, CONCAT(CURDATE(), ' ', ?), CONCAT(CURDATE(), ' ', ?), ?)
    `;
    const values = [roomID, startTime, endTime, reason];

    db.query(query, values, (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Database insertion failed.' });
        }
        res.status(201).json({ message: 'Blackout created successfully.', blackoutID: result.insertId });
    });
});

app.post('/api/assignments', (req, res) => {
    const { requestID, roomID, dayOfWeek, startTime, endTime } = req.body;

    if (!requestID || !roomID || !dayOfWeek || !startTime || !endTime) {
        return res.status(400).json({ error: 'All assignment fields are required.' });
    }

    const conflictCheckQuery = `
        SELECT 
            (SELECT COUNT(*) FROM Assignment A 
             WHERE A.RoomID = ? AND A.DayOfWeek = ? AND 
             (A.StartTime < ? AND A.EndTime > ?)) AS assignmentConflict,
            (SELECT COUNT(*) FROM Blackout B
             WHERE B.RoomID = ? AND 
             (B.StartTime < CONCAT(CURDATE(), ' ', ?) AND B.EndTime > CONCAT(CURDATE(), ' ', ?))) AS blackoutConflict
    `;
    
    const conflictValues = [
        roomID, dayOfWeek, endTime, startTime,
        roomID, endTime, startTime
    ];

    db.query(conflictCheckQuery, conflictValues, (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Conflict check failed.' });
        }

        const { assignmentConflict, blackoutConflict } = results[0];

        if (assignmentConflict > 0) {
            return res.status(409).json({ error: 'Conflict: Room is already assigned to a class at that time.' });
        }
        if (blackoutConflict > 0) {
            return res.status(409).json({ error: 'Conflict: Room is blacked out for maintenance or an event at that time.' });
        }
        
        const getClassIdQuery = 'SELECT ClassID FROM Request WHERE RequestID = ?';
        db.query(getClassIdQuery, [requestID], (err, reqResults) => {
            if (err || reqResults.length === 0) {
                console.error('Error fetching ClassID:', err);
                return res.status(500).json({ error: 'Invalid RequestID or database error.' });
            }
            const classID = reqResults[0].ClassID;

            const assignmentQuery = `
                INSERT INTO Assignment (ClassID, RoomID, DayOfWeek, StartTime, EndTime, AssignmentDate) 
                VALUES (?, ?, ?, ?, ?, NOW())
            `;
            const assignmentValues = [classID, roomID, dayOfWeek, startTime, endTime];

            db.query(assignmentQuery, assignmentValues, (err, result) => {
                if (err) {
                    console.error(err);
                    return res.status(500).json({ error: 'Assignment insertion failed.' });
                }

                const updateRequestQuery = `
                    UPDATE Request 
                    SET ReqStatus = 'Accepted' 
                    WHERE RequestID = ?
                `;
                
                db.query(updateRequestQuery, [requestID], (updateErr) => {
                    if (updateErr) {
                        console.error('Error updating request status:', updateErr);
                    }
                    
                    res.status(201).json({ message: 'Assignment created successfully and request accepted.', assignmentID: result.insertId });
                });
            });
        });
    });
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
}); //made by Kian S.

// Kian remember TRUNCATE TABLE "table's name" deletes the data 
