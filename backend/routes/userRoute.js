const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { getAuth, createUserWithEmailAndPassword } = require('firebase/auth');
const { initializeApp } = require('firebase/app');

// Initialize Firebase Admin (for Firestore)
const serviceAccount = require('../newscalendar-ac03a-firebase-adminsdk-fbsvc-ceee853a90.json');
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
//   databaseURL: 'https://newscalendar-ac03a.firebaseio.com'
// });

const firebaseConfig = {
  apiKey: "AIzaSyC67IATmJxlP959YHVK6M0TLybXCRxWSyg",
  authDomain: "newscalendar-ac03a.firebaseapp.com",
  databaseURL: "https://newscalendar-ac03a-default-rtdb.firebaseio.com",
  projectId: "newscalendar-ac03a",
  storageBucket: "newscalendar-ac03a.firebasestorage.app",
  messagingSenderId: "130840150982",
  appId: "1:130840150982:web:4673c65b7a64c372e2a8c7",
  measurementId: "G-SLWHJLKPG2"
};

const firebaseApp = initializeApp(firebaseConfig);
const auth = getAuth(firebaseApp);

router.post('/signup', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    // 1. Create Firebase Auth user
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const userId = userCredential.user.uid;

    // 2. Create user in Firestore
    await admin.firestore().collection('users').doc(userId).set({
      email,
      name,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    res.status(200).json({ message: 'User created successfully' });
  } catch (error) {
    console.error('Error creating user:', error);
    
    let errorMessage = 'Signup failed';
    if (error.code === 'auth/email-already-in-use') {
      errorMessage = 'Email already in use';
    } else if (error.code === 'auth/weak-password') {
      errorMessage = 'Password is too weak';
    }

    res.status(400).json({ message: errorMessage });
  }
});

module.exports = router;