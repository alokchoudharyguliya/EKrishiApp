const express = require('express');
// const admin = require('firebase-admin');
const WebSocket = require('ws');
const cors = require('cors');
const mongoose = require('mongoose');
const http = require('http');
// const socketIo = require('socket.io');
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
const aiRoutes = require('./routes/aiRoutes.js');
const irrigationRoutes = require('./routes/irrigationRoutes.js');
const equipmentRoutes = require('./routes/equipmentRoutes.js');
const chatbotRoutes = require('./routes/chatbotRoutes.js');
const notificationRoutes = require('./routes/notificationRoutes.js');

const webrtcRoutes = require('./routes/webrtc');
const MongoDBStore = require('connect-mongodb-session')(session);
const fs = require('fs');

const app = express();
const server = http.createServer(app);
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
    limits: { fileSize: 10 * 1024 * 1024 }
});

const corsOptions = {
    origin: function (origin, callback) {
        // Allow requests with no origin (like mobile apps, Postman, curl)
        if (!origin) return callback(null, true);
        
        const allowedOrigins = [
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
            "http://192.168.185.15:60918",
            "http://172.31.37.15:3001"
        ];
        
        // Allow any origin from 172.31.37.15 (for Flutter app on different ports)
        if (origin.startsWith('http://172.31.37.15:') || origin.startsWith('https://172.31.37.15:')) {
            return callback(null, true);
        }
        
        if (allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            callback(null, true); // Allow all for development - change to callback(new Error('Not allowed')) for production
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true
};

app.use(cors(corsOptions));

// const serviceAccount = require('./newscalendar-ac03a-firebase-adminsdk-fbsvc-ceee853a90.json');
// admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount),
//     databaseURL: process.env.FIREBASE_DATABASE_URL
// });
// const admin = require('./config/firebase.js');

// Static serving for equipment images - MUST be before other routes to avoid conflicts
const equipmentStaticPath = path.join(__dirname, 'uploads', 'equipment');
console.log('[Equipment Static] Serving files from:', equipmentStaticPath);

// Handle CORS for equipment static files
app.use('/equipment', (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Serve static files
app.use('/equipment', express.static(equipmentStaticPath, {
  setHeaders: (res, filePath) => {
    res.setHeader('Cache-Control', 'public, max-age=31536000');
    res.setHeader('Access-Control-Allow-Origin', '*');
  },
  dotfiles: 'ignore',
  index: false
}));

// Routes (mounted after static files to avoid conflicts)
app.use('/api/equipment', equipmentRoutes);
app.use(userRoutes);
app.use(fileRoutes);
app.use(eventRoutes);
app.use('/api/webrtc', webrtcRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/irrigation', irrigationRoutes);
app.use('/api/chatbot', chatbotRoutes);
app.use('/api/notifications', notificationRoutes);
// const io = socketIo(server, {
//     cors: {
//         origin: "*",
//         methods: ["GET", "POST"]
//     }
// });
// WebSocket Server
// const wsServer = http.createServer();
const wss = new WebSocket.Server({ server });
// wsServer.listen(3002);

const clients = new Map(); // Using Map to store client info with user IDs
const streams = new Map(); // <-- Add this line

// Socket.io for WebRTC signaling
// io.on('connection', (socket) => {
//     console.log('User connected:', socket.id);
//     console.log('User connected');
//     socket.on('join-stream', (streamId) => {
//         socket.join(streamId);
//         console.log(`User ${socket.id} joined stream ${streamId}`);
//     });

//     socket.on('offer', (data) => {
//         socket.to(data.streamId).emit('offer', {
//             offer: data.offer,
//             socketId: socket.id
//         });
//     });

//     socket.on('answer', (data) => {
//         socket.to(data.streamId).emit('answer', {
//             answer: data.answer,
//             socketId: socket.id
//         });
//     });

//     socket.on('ice-candidate', (data) => {
//         socket.to(data.streamId).emit('ice-candidate', {
//             candidate: data.candidate,
//             socketId: socket.id
//         });
//     });

//     socket.on('disconnect', () => {
//         console.log('User disconnected:', socket.id);
//     });
// });

// WebSocket connection handler
wss.on('connection', (ws, req) => {
    console.log('New client connected');
    let userId;

    try {
        const token = req.headers['authorization'].replace('Bearer ', '');
        // const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MzQ1ZGRhMTM4Yzc3NWNmMDNkMDNjOSIsImVtYWlsIjoiYWJjZEBnbWFpbC5jb20iLCJpYXQiOjE3NDgyNjIzNjJ9.dCsFsUN4xV8Nr2E8frR4cMlqiCkAQ_R-Zc2ekivjKYw";
        if (!token) {
            console.log('No token provided');
            ws.close(1008, 'Authentication required');
            return;
        }
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        console.log('Decoded token:', decoded);
        userId = decoded.id || decoded._id || decoded.userId;

        if (!userId) {
            throw new Error('No user ID in token');
        }
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

            if (data.action === 'join-stream') {
                ws.streamId = data.streamId;
                if (!streams.has(data.streamId)) streams.set(data.streamId, []);
                streams.get(data.streamId).push(ws);
                console.log(`Client joined stream ${data.streamId}`);
            }
            if (data.action === 'offer') {
                // Forward offer to all viewers except sender
                (streams.get(data.streamId) || []).forEach(client => {
                    if (client !== ws && client.readyState === WebSocket.OPEN) {
                        client.send(JSON.stringify({ action: 'offer', offer: data.offer }));
                    }
                });
            }
            if (data.action === 'answer') {
                // Forward answer to all publishers except sender
                (streams.get(data.streamId) || []).forEach(client => {
                    if (client !== ws && client.readyState === WebSocket.OPEN) {
                        client.send(JSON.stringify({ action: 'answer', answer: data.answer }));
                    }
                });
            }
            if (data.action === 'ice-candidate') {
                // Forward ICE candidate to all peers in the stream except sender
                (streams.get(data.streamId) || []).forEach(client => {
                    if (client !== ws && client.readyState === WebSocket.OPEN) {
                        client.send(JSON.stringify({ action: 'ice-candidate', candidate: data.candidate }));
                    }
                });
            }

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
        console.log('Creating event with data:', eventData);

        function parseDate(input) {
            // If already a Date object, return it
            if (input instanceof Date) return input;
            if (!input) return null;

            // Try ISO format
            const date = new Date(input);
            if (isNaN(date.getTime())) throw new Error(`Invalid date: ${input}`);
            return date;
        }

        const newEvent = new Event({
            title: eventData.title,
            start_date: parseDate(eventData.start_date),
            end_date: eventData.end_date ? parseDate(eventData.end_date) : null,
            description: eventData.description,
            userId: userId,
            createdBy: userId,
            eventMode: eventData.eventMode || 'all-day',
            startTime: eventData.startTime ? parseDate(eventData.startTime) : null,
            endTime: eventData.endTime ? parseDate(eventData.endTime) : null,
            cropType: eventData.cropType,
            cropVariety: eventData.cropVariety,
            activityType: eventData.activityType,
            fieldLocation: eventData.fieldLocation,
            equipmentNeeded: eventData.equipmentNeeded || [],
            reminders: eventData.reminders || [],
            reminderSettings: eventData.reminderSettings,
        });
        const savedEvent = await newEvent.save();

        // Broadcast to all clients
        await broadcastEvents();

        // Send success response to the creator with all fields
        ws.send(JSON.stringify({
            type: 'eventCreated',
            success: true,
            event: formatEventForClient(savedEvent)
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

        function parseDate(input) {
            if (input instanceof Date) return input;
            if (!input) return null;
            const date = new Date(input);
            if (isNaN(date.getTime())) throw new Error(`Invalid date: ${input}`);
            return date;
        }

        // Prepare updates with all fields
        const updateData = {
            updatedAt: new Date(),
        };

        if (updates.title !== undefined) updateData.title = updates.title;
        if (updates.start_date !== undefined) updateData.start_date = parseDate(updates.start_date);
        if (updates.end_date !== undefined) updateData.end_date = updates.end_date ? parseDate(updates.end_date) : null;
        if (updates.description !== undefined) updateData.description = updates.description;
        if (updates.eventMode !== undefined) updateData.eventMode = updates.eventMode;
        if (updates.startTime !== undefined) updateData.startTime = updates.startTime ? parseDate(updates.startTime) : null;
        if (updates.endTime !== undefined) updateData.endTime = updates.endTime ? parseDate(updates.endTime) : null;
        if (updates.cropType !== undefined) updateData.cropType = updates.cropType;
        if (updates.cropVariety !== undefined) updateData.cropVariety = updates.cropVariety;
        if (updates.activityType !== undefined) updateData.activityType = updates.activityType;
        if (updates.fieldLocation !== undefined) updateData.fieldLocation = updates.fieldLocation;
        if (updates.equipmentNeeded !== undefined) updateData.equipmentNeeded = updates.equipmentNeeded;
        if (updates.reminders !== undefined) updateData.reminders = updates.reminders;
        if (updates.reminderSettings !== undefined) updateData.reminderSettings = updates.reminderSettings;

        const updatedEvent = await Event.findByIdAndUpdate(
            eventId,
            { $set: updateData },
            { new: true }
        );

        // Broadcast to all clients
        await broadcastEvents();

        // Send success response to the updater with all fields
        ws.send(JSON.stringify({
            type: 'eventUpdated',
            success: true,
            event: formatEventForClient(updatedEvent)
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


// Helper function to format event for client with all fields
function formatDateISO(date) {
    if (!date) return null;
    return new Date(date).toISOString();
}

function formatEventForClient(event) {
    return {
        id: event._id.toString(),
        title: event.title,
        start_date: formatDateISO(event.start_date),
        end_date: event.end_date ? formatDateISO(event.end_date) : null,
        description: event.description,
        userId: event.userId ? event.userId.toString() : null,
        createdBy: event.createdBy ? event.createdBy.toString() : null,
        eventMode: event.eventMode || 'all-day',
        startTime: event.startTime ? formatDateISO(event.startTime) : null,
        endTime: event.endTime ? formatDateISO(event.endTime) : null,
        cropType: event.cropType,
        cropVariety: event.cropVariety,
        activityType: event.activityType,
        fieldLocation: event.fieldLocation,
        equipmentNeeded: event.equipmentNeeded || [],
        reminders: (event.reminders || []).map(reminder => ({
            reminderTime: formatDateISO(reminder.reminderTime),
            reminderType: reminder.reminderType,
            reminderValue: reminder.reminderValue,
            isNotified: reminder.isNotified || false,
            notificationId: reminder.notificationId || null
        })),
        reminderSettings: event.reminderSettings || null,
        createdAt: event.createdAt ? formatDateISO(event.createdAt) : null,
        updatedAt: event.updatedAt ? formatDateISO(event.updatedAt) : null,
        isDeleted: event.isDeleted || false,
    };
}

async function broadcastEvents() {
    try {
        const events = await Event.find({ isDeleted: { $ne: true } }).sort({ start_date: 1 });
        const message = JSON.stringify({
            type: 'events',
            data: events.map(event => formatEventForClient(event))
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
        const events = await Event.find({ isDeleted: { $ne: true } }).sort({ start_date: 1 });
        ws.send(JSON.stringify({
            type: 'events',
            data: events.map(event => formatEventForClient(event))
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
    // Initialize irrigation scheduler service
    const irrigationSchedulerService = require('./services/irrigationSchedulerService');
    
    // Start cron job to check scheduled irrigations every minute
    setInterval(async () => {
        try {
            await irrigationSchedulerService.checkScheduledIrrigations();
        } catch (error) {
            console.error('[IrrigationScheduler] Cron job error:', error);
        }
    }, 60000); // Check every 60 seconds (1 minute)
    console.log('✅ Irrigation scheduler started (checking every minute)');

    const PORT = process.env.PORT || 3000;
    server.listen(PORT, '0.0.0.0', async () => {
        console.log(`Server running on http://localhost:${PORT}`);
        console.log(`WebSocket server running on ws://localhost:${PORT}`);
        
        // Initialize camera detection on server start
        try {
            const cameraDetectionService = require('./services/cameraDetectionService');
            const cameras = await cameraDetectionService.detectCameras();
            console.log(`\n📷 Camera Detection: Found ${cameras.length} USB camera(s)`);
            if (cameras.length > 0) {
                cameras.forEach((cam, idx) => {
                    console.log(`   ${idx + 1}. ${cam.name} (ID: ${cam.id})`);
                });
            } else {
                console.log('   No cameras detected. Make sure cameras are connected and FFmpeg is installed.');
            }
        } catch (error) {
            console.log(`\n⚠️  Camera Detection: ${error.message}`);
            console.log('   Camera features will not be available until FFmpeg is installed.');
        }
    });
}).catch(err => {
    console.log(err);
});

// Utility function to format date
function formatDate(date) {
    return new Date(date).toISOString().split('T')[0];
}