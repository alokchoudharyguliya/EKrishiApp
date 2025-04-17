const express = require('express');
const admin = require('firebase-admin');
const WebSocket = require('ws');
const cors = require('cors');
const mongoose = require('mongoose');
const http = require('http');
const path = require('path');
const multer = require('multer');
const bodyParser = require('body-parser');
const session = require('express-session');
const User = require('./models/user.js');
const Event = require('./models/event.js');
const eventRoutes = require('./routes/eventRoute.js');
const userRoutes = require('./routes/userRoutes.js');
const CALENDAR_DB_URI = "mongodb://localhost:27017/calendarDB";

const MongoDBStore = require('connect-mongodb-session')(session);
// const MONGODB_URI = "mongodb+srv://root:a3vUyvFSnOPOad5o@cluster0.1pfthjz.mongodb.net/users";
const MONGODB_URI = "mongodb://localhost:27017/users";

const app = express();
const server = http.createServer(app);

const store = new MongoDBStore({
    uri: MONGODB_URI,
    collection: 'sessions',
});

const fileFilter = (req, file, cb) => {
    if (file.mimetype === 'image/png' || file.mimetype === 'image/jpeg' || file.mimetype === 'image/jpeg')
        cb(null, true);
    else
    cb(null, false);
}

app.use(express.json());
const fileStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'images');
    },
    filename: (req, file, cb) => {
        cb(null, file.filename + file.originalname);
    }
});
app.use(multer({ storage: fileStorage, fileFilter: fileFilter }).single('image'));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, 'public')));

const corsOptions = {
    origin: [
        'http://localhost:3000', // Your Node server
        'http://localhost:54520',
        'http://localhost:53589', // Common Flutter debug port
        'http://localhost:59458', // Another common Flutter debug port
        'http://127.0.0.1:3000',
        'http://127.0.0.1:53589',
        'http://127.0.0.1:59458',
        'http://10.0.2.2:3000', // Android emulator access to localhost
        "http://127.0.0.1:53638",
        "http://192.168.185.19:3000",
        "http://192.168.185.15:60918"
    ],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));
const serviceAccount = require('./newscalendar-ac03a-firebase-adminsdk-fbsvc-ceee853a90.json');


admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://newscalendar-ac03a.firebaseio.com'
});

const db = admin.firestore();

app.use(userRoutes);
app.use(eventRoutes);

const wss = new WebSocket.Server({ server });
const clients = new Set();

wss.on('connection', (ws) => {
    console.log('New client connected');
    clients.add(ws);

    // Send initial events to new client
    sendEventsToClient(ws);

    ws.on('message', async (message) => {
        console.log(`Received message: ${message}`);
        try {
            const data = JSON.parse(message);
            
            if (data.action === 'refresh') {
                sendEventsToClient(ws);
            } else if (data.action === 'createEvent') {
                await handleCreateEvent(data.event, data.token);
            }
        } catch (err) {
            console.error('Error processing message:', err);
        }
    });

    ws.on('close', () => {
        console.log('Client disconnected');
        clients.delete(ws);
    });
});

// Send events to specific client
async function sendEventsToClient(ws) {
    try {
        const events = await Event.find().sort({ start_date: 1 });
        ws.send(JSON.stringify({
            type: 'events',
            data: events.map(event => ({
                id: event._id,
                event: event.title,
                start_date: formatDate(event.start_date),
                end_date: event.end_date ? formatDate(event.end_date) : null,
                description: event.description
            }))
        }));
    } catch (err) {
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to fetch events'
        }));
    }
}

// Function to handle event creation
async function handleCreateEvent(eventData, token) {
    try {
        // Verify JWT token
        const decoded = jwt.verify(token, SECRET_KEY);
        const userId = decoded.userId;

        const newEvent = new Event({
            title: eventData.title,
            start_date: new Date(eventData.start_date),
            end_date: eventData.end_date ? new Date(eventData.end_date) : null,
            description: eventData.description,
            userId: userId
        });
        
        await newEvent.save();
        broadcastEvents();
    } catch (err) {
        console.error('Error creating event:', err);
    }
}


// Broadcast to all clients
async function broadcastEvents() {
    try {
        const events = await Event.find().sort({ start_date: 1 });
        const message = JSON.stringify({
            type: 'events',
            data: events.map(event => ({
                id: event._id,
                event: event.title,
                start_date: formatDate(event.start_date),
                end_date: event.end_date ? formatDate(event.end_date) : null,
                description: event.description
            }))
        });

        clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(message);
            }
        });
    } catch (err) {
        console.error('Error broadcasting events:', err);
    }
}




app.get('/', (req, res) => {
    res.send('Node.js Firestore API is running');
});

const PORT = process.env.PORT || 3000;
mongoose.connect(MONGODB_URI)
    .then(() => {
        console.log("Connected to users database");
        return mongoose.createConnection(CALENDAR_DB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true
        });
    })
    .then(calendarDb => {
        console.log("Connected to calendar database");
        const PORT = process.env.PORT || 3000;
        server.listen(PORT, '0.0.0.0', () => {
            console.log(`Server running on http://localhost:${PORT}`);
            console.log(`WebSocket server running on ws://localhost:${PORT}`);
            console.log(`Accessible from Flutter via:
        - http://localhost:${PORT} (iOS simulator)
        - http://10.0.2.2:${PORT} (Android emulator)
        - Your actual local IP for physical devices`);
        });
    })
    .catch(err => {
        console.log(err);
    });


// Utility function to format date (helper)
function formatDate(date) {
    return new Date(date).toISOString().split('T')[0];
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
                description: event.description
            }))
        }));
    } catch (err) {
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to fetch events'
        }));
    }
}