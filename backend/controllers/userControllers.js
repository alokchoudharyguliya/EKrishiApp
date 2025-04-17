const mongoose = require('mongoose');
const User = require('../models/user');
const bcrypt = require('bcryptjs');
const jwt=require('jsonwebtoken');
const dotenv=require("dotenv");
dotenv.config();
exports.postSignUp = async (req, res, next) => {
  const email = req.body.email;
  const password = req.body.password;
  const name = req.body.name;

  try {
    const existingUser = await User.findOne({ email: email });
    if (existingUser) {
      return res.status(409).json({ message: "User already exists" });
    }
    const user = new User({
      name: name,
      email: email,
      password: password
    });
    const token = jwt.sign(
      { id: user._id, email},
      process.env.JWT_SECRET
  );
    console.log('Signed Up successful');
    await user.save();
    res.status(201).json({ message: "Sign Up Successful",token:token });
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "An error occurred during sign up" });
  }
};

exports.postLogIn = async (req, res, next) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email: email });

    if (!user) {
      return res.status(422).json({ message: "Invalid Email" });
    }
    const token = jwt.sign(
      { id: user._id, email },
      process.env.JWT_SECRET
  );
    if (password === user.password) {
      return res.status(200).json({ message: "Log In Successful",token:token,userId:user._id });
    }
    return res.status(422).json({ message: "Invalid Password" ,token:token,userId:user._id});

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "An error occurred during login" });
  }
}
// Add this to your auth controller
exports.postLogOut = async (req, res, next) => {
  try {
    // Option 1: Simple acknowledgment (client handles token deletion)
    res.status(200).json({ message: "Logout successful" });

    // Option 2: If you want server-side token invalidation
    /*
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ message: "No token provided" });
    }
    
    // Add token to blacklist (you'll need this model)
    await TokenBlacklist.create({ 
      token, 
      expiresAt: new Date(Date.now() + 3600000) // 1 hour expiration
    });
    
    res.status(200).json({ message: "Logout successful" });
    */
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "An error occurred during logout" });
  }
};