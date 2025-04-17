const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { getAuth, createUserWithEmailAndPassword } = require('firebase/auth');
const { initializeApp } = require('firebase/app');
const userController=require('../controllers/userControllers');
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

router.post('/signup',userController.postSignUp);
router.post('/login',userController.postLogIn);
router.post('/logout',userController.postLogOut);
module.exports = router;