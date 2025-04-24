const express = require('express');
// const admin = require('firebase-admin');
const WebSocket = require('ws');
const cors = require('cors');
const mongoose = require('mongoose');
const http = require('http');
const path = require('path');
const multer = require('multer');
const bodyParser = require('body-parser');
const session = require('express-session');
const jwt = require('jsonwebtoken');
const User = require('./models/user.js');
const Event = require('./models/event.js');
const eventRoutes = require('./routes/eventRoute.js');
const userRoutes = require('./routes/userRoutes.js');
const fileRoutes = require('./routes/filesRoutes.js');
const MongoDBStore = require('connect-mongodb-session')(session);
const fs = require('fs');

const app = express();
const server = http.createServer(app);

// Session store
const store = new MongoDBStore({
    uri: process.env.MONGODB_URI,
    collection: 'sessions',
});

app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));


const { fileFilter } = require('./config/multerConfig.js');
const fileStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        const dir = '../uploads/profiles';
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname);
        const filename = `${Date.now()}_${file.fieldname}${ext}`;
        cb(null, filename);
    }
});

const upload = multer({
    storage: fileStorage,
    fileFilter: fileFilter,
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB max
});

const corsOptions = {
    origin: [
        'http://localhost:3000',
        'http://localhost:54520',
        'http://localhost:53589',
        'http://localhost:59458',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:53589',
        'http://127.0.0.1:59458',
        'http://10.0.2.2:3000',
        "http://127.0.0.1:53638",
        "http://192.168.185.19:3000",
        "http://192.168.185.15:60918"
    ],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));

const serviceAccount = require('./newscalendar-ac03a-firebase-adminsdk-fbsvc-ceee853a90.json');
// admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount),
//     databaseURL: process.env.FIREBASE_DATABASE_URL
// });
const admin = require('./config/firebase.js');
// Routes

app.use(userRoutes);
app.use(fileRoutes);
app.use(eventRoutes);

// WebSocket Server
const wss = new WebSocket.Server({ server });
const clients = new Map(); // Using Map to store client info with user IDs

// WebSocket connection handler
wss.on('connection', (ws, req) => {
    console.log('New client connected');
    let userId;

    try {
        // Extract token from query parameters
        const token = new URL(req.url, `http://${req.headers.host}`).searchParams.get('token');
        console.log('Token received:', token);

        if (!token) {
            console.log('No token provided');
            ws.close(1008, 'Authentication required');
            return;
        }

        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        console.log('Decoded token:', decoded);

        // Get user ID from token
        userId = decoded.id || decoded._id || decoded.userId;

        if (!userId) {
            throw new Error('No user ID in token');
        }

        // Store client connection
        clients.set(ws, { userId });
        console.log(`Authenticated user ${userId} connected`);

        // Send initial data
        sendEventsToClient(ws);

    } catch (err) {
        console.error('Authentication failed:', err.message);
        ws.send(JSON.stringify({
            type: 'auth_error',
            message: err.message
        }));
        ws.close(1008, 'Invalid token');
        return;
    }

    // Message handler
    ws.on('message', async (message) => {
        try {
            const data = JSON.parse(message);
            console.log(`Received message from ${userId}:`, data);

            // Verify user is still authenticated
            const clientData = clients.get(ws);
            if (!clientData || !clientData.userId) {
                ws.send(JSON.stringify({
                    type: 'auth_error',
                    message: 'Session expired'
                }));
                return ws.close();
            }

            switch (data.action) {
                case 'refresh':
                    await sendEventsToClient(ws);
                    break;

                case 'createEvent':
                    await handleCreateEvent(data.event, ws, userId);
                    break;

                case 'updateEvent':
                    await handleUpdateEvent(data.eventId, data.updates, ws, userId);
                    break;

                case 'deleteEvent':
                    await handleDeleteEvent(data.eventId, ws, userId);
                    break;

                default:
                    ws.send(JSON.stringify({
                        type: 'error',
                        message: 'Unknown action'
                    }));
            }
        } catch (err) {
            console.error('Error processing message:', err);
            ws.send(JSON.stringify({
                type: 'error',
                message: 'Error processing your request',
                error: err.message
            }));
        }
    });

    // Handle connection close
    ws.on('close', () => {
        clients.delete(ws);
        console.log(`User ${userId} disconnected`);
    });

    // Handle errors
    ws.on('error', (error) => {
        console.error('WebSocket error:', error);
        clients.delete(ws);
    });
});

// Event handlers
async function handleCreateEvent(eventData, ws, userId) {
    try {
        console.log(typeof (eventData.start_date));

        console.log(eventData.start_date);
        function parseDate(input) {
            // If already a Date object, return it
            if (input instanceof Date) return input;

            // Try ISO format (YYYY-MM-DD)
            const isoMatch = input.match(/^(\d{2})-(\d{2})-(\d{4})$/);
            if (isoMatch) {
                return new Date(Date.UTC(
                    parseInt(isoMatch[3], 10),
                    parseInt(isoMatch[2], 10) - 1, // Months are 0-indexed
                    parseInt(isoMatch[1], 10)
                ));
            }

            // Fallback to Date constructor
            const date = new Date(input);
            if (isNaN(date.getTime())) throw new Error(`Invalid date: ${input}`);
            return date;
        }

        const newEvent = new Event({
            title: eventData.title,
            start_date: parseDate(eventData.start_date),
            end_date: parseDate(eventData.end_date),
            description: eventData.description,
            userId: userId,
            createdBy: userId
        });
        const savedEvent = await newEvent.save();

        // Broadcast to all clients
        await broadcastEvents();

        // Send success response to the creator
        ws.send(JSON.stringify({
            type: 'eventCreated',
            success: true,
            event: {
                id: savedEvent._id,
                title: savedEvent.title,
                start_date: formatDate(savedEvent.start_date),
                end_date: savedEvent.end_date ? formatDate(savedEvent.end_date) : null,
                description: savedEvent.description,
                userId: savedEvent.userId
            }
        }));
    } catch (err) {
        console.error('Error creating event:', err);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to create event',
            error: err.message
        }));
    }
}

async function handleUpdateEvent(eventId, updates, ws, userId) {
    try {
        // Verify the user owns the event
        const event = await Event.findOne({ _id: eventId, userId: userId });
        if (!event) {
            throw new Error('Event not found or not authorized');
        }

        // Prepare updates
        const updateData = {
            updatedAt: new Date(),
            updatedBy: userId
        };

        if (updates.title) updateData.title = updates.title;
        if (updates.start_date) updateData.start_date = new Date(updates.start_date);
        if (updates.end_date) updateData.end_date = updates.end_date ? new Date(updates.end_date) : null;
        if (updates.description) updateData.description = updates.description;

        const updatedEvent = await Event.findByIdAndUpdate(
            eventId,
            { $set: updateData },
            { new: true }
        );

        // Broadcast to all clients
        await broadcastEvents();

        // Send success response to the updater
        ws.send(JSON.stringify({
            type: 'eventUpdated',
            success: true,
            event: {
                id: updatedEvent._id,
                title: updatedEvent.title,
                start_date: formatDate(updatedEvent.start_date),
                end_date: updatedEvent.end_date ? formatDate(updatedEvent.end_date) : null,
                description: updatedEvent.description,
                userId: updatedEvent.userId
            }
        }));
    } catch (err) {
        console.error('Error updating event:', err);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to update event',
            error: err.message
        }));
    }
}

async function handleDeleteEvent(eventId, ws, userId) {
    try {
        // Verify the user owns the event
        const event = await Event.findOne({ _id: eventId, userId: userId });
        if (!event) {
            throw new Error('Event not found or not authorized');
        }

        await Event.findByIdAndDelete(eventId);

        // Broadcast to all clients
        await broadcastEvents();

        // Send success response to the deleter
        ws.send(JSON.stringify({
            type: 'eventDeleted',
            success: true,
            eventId: eventId
        }));
    } catch (err) {
        console.error('Error deleting event:', err);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to delete event',
            error: err.message
        }));
    }
}


async function broadcastEvents() {
    try {
        const events = await Event.find().sort({ start_date: 1 });
        const message = JSON.stringify({
            type: 'events',
            data: events.map(event => ({
                id: event._id,
                title: event.title,
                start_date: formatDate(event.start_date),
                end_date: event.end_date ? formatDate(event.end_date) : null,
                description: event.description,
                userId: event.userId,
                createdBy: event.createdBy
            }))
        });

        clients.forEach((clientData, client) => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(message);
            }
        });
    } catch (err) {
        console.error('Error broadcasting events:', err);
    }
}

// Send events to a single client
async function sendEventsToClient(ws) {
    try {
        const events = await Event.find().sort({ start_date: 1 });
        ws.send(JSON.stringify({
            type: 'events',
            data: events.map(event => ({
                id: event._id,
                title: event.title,
                start_date: formatDate(event.start_date),
                end_date: event.end_date ? formatDate(event.end_date) : null,
                description: event.description,
                userId: event.userId,
                createdBy: event.createdBy
            }))
        }));
    } catch (err) {
        console.error('Error sending events to client:', err);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to fetch events',
            error: err.message
        }));
    }
}
// File upload endpoint (unchanged from your original)
app.post('/save-user', upload.single('image'), async (req, res) => {
    try {
        const { userId, name, email, phone, dob, role } = req.body;
        console.log('Request files:', req.file);
        if (!userId) {
            return res.status(400).json({
                success: false,
                message: "User ID is required."
            });
        }

        if (role && !['student', 'faculty', 'other', 'admin'].includes(role)) {
            return res.status(400).json({
                success: false,
                message: "Invalid role specified."
            });
        }

        const updateData = {
            name,
            email,
            phone,
            dob,
            role: role || 'student'
        };

        if (req.file) {
            const uploadDir = path.join(__dirname, 'uploads', 'profiles');
            if (!fs.existsSync(uploadDir)) {
                fs.mkdirSync(uploadDir, { recursive: true });
            }

            const fileExt = path.extname(req.file.originalname);
            const filename = `${userId}_${Date.now()}${fileExt}`;
            const filePath = path.join(uploadDir, filename);
            console.log(typeof (req.file.path));
            await fs.promises.rename(req.file.path, filePath);
            updateData.photoUrl = `${process.env.BASE_URL}/profile/${filename}`;

            const user = await User.findById(userId);
            if (user && user.photoUrl) {
                const oldFileUrl = user.photoUrl.replace(`${process.env.BASE_URL}/profile/`, '');
                const oldFilePath = path.join(uploadDir, oldFileUrl);
                if (fs.existsSync(oldFilePath)) {
                    try {
                        await fs.promises.unlink(oldFilePath);
                    } catch (err) {
                        console.error('Error deleting old image:', err);
                    }
                }
            }
        }

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { $set: updateData },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({
                success: false,
                message: "User not found."
            });
        }

        res.status(200).json({
            success: true,
            photoUrl: updatedUser.photoUrl || null,
            message: "Profile updated successfully"
        });

    } catch (err) {
        console.error(err);

        if (req.file && req.file.path) {
            try {
                await fs.promises.unlink(req.file.path);
            } catch (cleanupErr) {
                console.error('Error cleaning up uploaded file:', cleanupErr);
            }
        }

        res.status(500).json({
            success: false,
            message: "Server error: " + err.message
        });
    }
});

// Root endpoint
app.get('/', (req, res) => {
    res.send('Node.js Firestore API is running');
});

app.get('/ping', (req, res) => {
    // console.log('pong');
    res.status(200).send('pong');
});

// Database connection and server startup
mongoose.connect(process.env.MONGODB_URI).then(() => {
    console.log("Connected to users database");
    return mongoose.createConnection(process.env.MONGODB_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true
    });
}).then(calendarDb => {
    console.log("Connected to calendar database");
    const PORT = process.env.PORT || 3000;
    server.listen(PORT, '0.0.0.0', () => {
        console.log(`Server running on http://localhost:${PORT}`);
        console.log(`WebSocket server running on ws://localhost:${PORT}`);
        console.log(`Accessible from My Flutter via:
        - http://localhost:${PORT} (iOS simulator)
        - http://10.0.2.2:${PORT} (Android emulator)
        - Your actual local IP for physical devices`);
    });
}).catch(err => {
    console.log(err);
});

// Utility function to format date
function formatDate(date) {
    return new Date(date).toISOString().split('T')[0];
}