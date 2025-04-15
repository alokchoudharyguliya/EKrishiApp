const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');

// Initialize Express app
const app = express();
app.use(cors());
app.use(express.json());

// Configure CORS for Flutter development
const corsOptions = {
    origin: [
        'http://localhost:3000', // Your Node server
        'http://localhost:53589', // Common Flutter debug port
        'http://localhost:59458', // Another common Flutter debug port
        'http://127.0.0.1:3000',
        'http://127.0.0.1:53589',
        'http://127.0.0.1:59458',
        'http://10.0.2.2:3000' // Android emulator access to localhost
    ],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));
app.use(express.json());

// Initialize Firebase Admin SDK
const serviceAccount = require('./newscalendar-ac03a-firebase-adminsdk-fbsvc-ceee853a90.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://newscalendar-ac03a.firebaseio.com'
});
const userRoute=require('./routes/userRoute.js');
const db = admin.firestore();
app.get('/', (req, res) => {
    res.send('Node.js Firestore API is running');
});
app.use(userRoute);
// Routes will be added here
// app.post('/events', async (req, res) => {
//     try {
//         const eventData = req.body;

//         // Validate required fields
//         if (!eventData.event || !eventData.start_date||!eventData.userId) {
//             return res.status(400).send('UserId, Event and start_date are required');
//         }

//         // Add createdAt timestamp
//         eventData.createdAt = admin.firestore.FieldValue.serverTimestamp();
//         eventData.updatedAt = admin.firestore.FieldValue.serverTimestamp();

//         const docRef = await db.collection('events').add(eventData);

//         res.status(201).send({
//             id: docRef.id,
//             message: 'Event created successfully'
//         });
//     } catch (error) {
//         console.error('Error creating event:', error);
//         res.status(500).send('Error creating event');
//     }
// });
// app.post('/events', async (req, res) => {
//     try {
//         const eventData = req.body;
//         const userId = req.body.userId; // Expect userId in request

//         if (!userId) {
//             return res.status(400).send('User ID is required');
//         }

//         // Create reference to the user document
//         const userRef = db.collection('users').doc(userId);

//         // Add user reference to event data
//         eventData.userRef = userRef;
//         eventData.userId = userId; // Also store userId as string for easier queries
//         eventData.createdAt = admin.firestore.FieldValue.serverTimestamp();
//         eventData.updatedAt = admin.firestore.FieldValue.serverTimestamp();

//         const docRef = await db.collection('events').add(eventData);

//         res.status(201).send({
//             id: docRef.id,
//             message: 'Event created successfully'
//         });
//     } catch (error) {
//         console.error('Error creating event:', error);
//         res.status(500).send('Error creating event');
//     }
// });
app.post('/events', async (req, res) => {
    try {
        const eventData = req.body;
        const userId = req.body.userId; // Expect userId in request

        if (!userId) {
            return res.status(400).send('User ID is required');
        }

        // Create reference to the user document
        const userRef = db.collection('users').doc(userId);

        // Add user reference to event data
        eventData.userRef = userRef;
        // eventData.userId = userId; // Also store userId as string for easier queries
        eventData.createdAt = admin.firestore.FieldValue.serverTimestamp();
        eventData.updatedAt = admin.firestore.FieldValue.serverTimestamp();

        const docRef = await db.collection('events').add(eventData);

        res.status(201).send({
            id: docRef.id,
            message: 'Event created successfully'
        });
    } catch (error) {
        console.error('Error creating event:', error);
        res.status(500).send('Error creating event');
    }
});


app.get('/events', async (req, res) => {
    try {
        const eventsSnapshot = await db.collection('events').get();
        const events = [];

        eventsSnapshot.forEach(doc => {
            events.push({
                id: doc.id,
                ...doc.data()
            });
        });

        res.status(200).send(events);
    } catch (error) {
        console.error('Error getting events:', error);
        res.status(500).send('Error getting events');
    }
});

/**
 * @route GET /events/:id
 * @desc Get a single event by ID
 */
app.get('/events/:id', async (req, res) => {
    try {
        const eventId = req.params.id;
        const eventDoc = await db.collection('events').doc(eventId).get();

        if (!eventDoc.exists) {
            return res.status(404).send('Event not found');
        }

        res.status(200).send({
            id: eventDoc.id,
            ...eventDoc.data()
        });
    } catch (error) {
        console.error('Error getting event:', error);
        res.status(500).send('Error getting event');
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://localhost:${PORT}`);
    console.log(`Accessible from Flutter via:
  - http://localhost:${PORT} (iOS simulator)
  - http://10.0.2.2:${PORT} (Android emulator)
  - Your actual local IP for physical devices`);
});