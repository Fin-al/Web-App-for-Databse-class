require('dotenv').config();
const express = require('express');
const mysql = require('mysql');

const app = express();
const port = 3000;

app.use(express.json());

const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    port: process.env.DB_PORT
});

db.connect(err => {
    if (err) {
        console.error(' Database connection failed: ' + err.stack);
        return;
    }
    console.log(' Database connected successfully!');
});

app.get('/api/assignments', (req, res) => {
    const query = `
        SELECT
            D.DeptName,
            C.ClassName,
            C.SectionNum,
            B.BldgName,
            R.RoomNumber,
            A.DayOfWeek,
            TIME_FORMAT(A.StartTime, '%h:%i %p') AS StartTime,
            TIME_FORMAT(A.EndTime, '%h:%i %p') AS EndTime
        FROM
            Assignment A
        JOIN
            Class C ON A.ClassID = C.ClassID
        JOIN
            Room R ON A.RoomID = R.RoomID
        JOIN
            Building B ON R.BldgID = B.BldgID
        JOIN
            Department D ON C.DeptID = D.DeptID
        ORDER BY
            D.DeptName, A.DayOfWeek, A.StartTime;
    `;

    db.query(query, (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ error: 'Database query failed' });
        }
        res.json(results);
    });
});

app.get('/api/departments', (req, res) => {
    const query = 'SELECT DeptID, DeptName FROM Department ORDER BY DeptName;';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching departments:', err);
            return res.status(500).json({ error: 'Database query failed' });
        }
        res.json(results);
    });
});

app.get('/api/rooms', (req, res) => {
    const query = `
        SELECT
            R.RoomID,
            R.RoomNumber,
            B.BldgName,
            R.Capacity,
            R.Equipment,
            R.RoomType
        FROM
            Room R
        JOIN
            Building B ON R.BldgID = B.BldgID
        ORDER BY
            B.BldgName, R.RoomNumber;
    `;
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching rooms:', err);
            return res.status(500).json({ error: 'Database query failed' });
        }
        res.json(results);
    });
});

app.get('/api/requests', (req, res) => {
    const query = `
        SELECT
            Req.RequestID,
            D.DeptName,
            C.ClassName,
            C.SectionNum,
            Req.PreferredTime,
            Req.EquipRequest,
            Req.Priority,
            Req.DateSubmitted
        FROM
            Request Req
        JOIN
            Class C ON Req.ClassID = C.ClassID
        JOIN
            Department D ON Req.DeptID = D.DeptID
        WHERE
            Req.RequestID NOT IN (SELECT RequestID FROM Assignment)
        ORDER BY
            Req.Priority DESC, Req.DateSubmitted ASC;
    `;
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching requests:', err);
            return res.status(500).json({ error: 'Database query failed' });
        }
        res.json(results);
    });
});

app.post('/api/assignments', (req, res) => {
    const { requestID, roomID, dayOfWeek, startTime, endTime } = req.body;

    const getClassIdQuery = 'SELECT ClassID FROM Request WHERE RequestID = ?';

    db.query(getClassIdQuery, [requestID], (err, results) => {
        if (err || results.length === 0) {
            console.error('Error fetching ClassID for request:', err || 'Request not found');
            return res.status(404).json({ error: 'Request not found or database error' });
        }
        
        const classID = results[0].ClassID;

        const insertAssignmentQuery = `
            INSERT INTO Assignment (ClassID, RoomID, DayOfWeek, StartTime, EndTime)
            VALUES (?, ?, ?, ?, ?)
        `;
        const assignmentValues = [classID, roomID, dayOfWeek, startTime, endTime];

        db.query(insertAssignmentQuery, assignmentValues, (insertErr, insertResult) => {
            if (insertErr) {
                console.error('Error creating assignment:', insertErr);
                if (insertErr.code === 'ER_DUP_ENTRY') {
                    return res.status(409).json({ error: 'Conflict: Room is already assigned during this time slot.' });
                }
                return res.status(500).json({ error: 'Failed to create assignment due to database error' });
            }
            res.status(201).json({ 
                message: 'Assignment created successfully', 
                assignmentId: insertResult.insertId 
            });
        });
    });
});

app.post('/api/requests', (req, res) => {
    const { classID, deptID, priority, equipRequest, preferredRoomID, preferredTime, cardBltID } = req.body;
    
    const query = `
        INSERT INTO Request (ClassID, DeptID, Priority, EquipRequest, PreferredRoomID, PreferredTime, DateSubmitted, CardBltID)
        VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)
    `;
    const values = [classID, deptID, priority, equipRequest, preferredRoomID, preferredTime, cardBltID];

    db.query(query, values, (err, results) => {
        if (err) {
            console.error('Error submitting request:', err);
            return res.status(500).json({ error: 'Failed to submit request due to database error' });
        }
        res.status(201).json({ 
            message: 'Request submitted successfully', 
            requestID: results.insertId 
        });
    });
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});