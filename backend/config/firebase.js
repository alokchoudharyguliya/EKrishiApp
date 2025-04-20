const admin = require('firebase-admin');
const serviceAccount = require('../newscalendar-ac03a-firebase-adminsdk-fbsvc-ceee853a90.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: process.env.FIREBASE_DATABASE_URL
});

module.exports = admin;