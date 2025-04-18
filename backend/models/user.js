const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const userSchema = new Schema({
  email: {
    type: String,
    required: true
  },
  password: {
    type: String,
    required: true
  },
  photoUrl: {
    type: String
  },
  name: {
    type: String
  },
  dob: {
    type: String
  },
  phone: {
    type: String
  },
  role: {
    type: String,
    enum: ['student', 'faculty', 'other', 'admin'],
    default: 'student'
},
});
module.exports = mongoose.model('User', userSchema);