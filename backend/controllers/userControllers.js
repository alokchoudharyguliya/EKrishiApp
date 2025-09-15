const User = require('../models/user');
const dotenv = require("dotenv");
const jwt=require('jsonwebtoken');
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
      { id: user._id, email },
      process.env.JWT_SECRET
    );
    console.log('Signed Up successful');
    await user.save();
    return res.status(201).json({ message: "Sign Up Successful", token: token, user: user });
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
      return res.status(200).json({ message: "Log In Successful", token: token, user: user });
    }
    return res.status(422).json({ message: "Invalid Password" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "An error occurred during login" });
  }
};
exports.postLogOut = async (req, res, next) => {
  try {
    res.status(200).json({ message: "Logout successful" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "An error occurred during logout" });
  }
};
exports.userData = async (req, res, next) => {
  const { userId } = req.body;
  try {

    if (!userId) {
      return res.status(400).json({ message: "User ID is required." });
    }

    await User.find({ _id: userId }).then(userData => {
      res.status(200).json({ success: true, userData: userData });

    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
}
exports.getProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId)
      .select('-password -__v')
      .lean();

    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: "User not found" 
      });
    }

    res.status(200).json({ 
      success: true, 
      user 
    });

  } catch (err) {
    console.error('Get profile error:', err);
    res.status(500).json({ 
      success: false, 
      message: "Failed to fetch profile",
      error: err.message 
    });
  }
};

exports.uploadProfilePhoto = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        message: "No file uploaded" 
      });
    }

    const fileUrl = `${process.env.BASE_URL}/uploads/${req.file.filename}`;
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { photoUrl: fileUrl },
      { new: true, select: '-password -__v' }
    );

    res.status(200).json({ 
      success: true,
      photoUrl: fileUrl,
      user: updatedUser
    });

  } catch (err) {
    console.error('Upload photo error:', err);
    if (req.file) {
      const fs = require('fs');
      const path = require('path');
      const filePath = path.join(__dirname, '../uploads', req.file.filename);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    res.status(500).json({ 
      success: false, 
      message: "Failed to upload photo",
      error: err.message 
    });
  }
};

exports.verifyToken = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ 
        success: false, 
        message: "No token provided" 
      });
    }
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id)
      .select('-password -__v');

    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: "User not found" 
      });
    }

    res.status(200).json({ 
      success: true,
      user,
      token
    });

  } catch (err) {
    console.error('Token verification error:', err);
    
    let message = "Invalid token";
    if (err.name === 'TokenExpiredError') {
      message = "Token expired";
    } else if (err.name === 'JsonWebTokenError') {
      message = "Malformed token";
    }

    res.status(401).json({ 
      success: false, 
      message,
      error: err.message 
    });
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const updates = req.body;
    delete updates.password;
    delete updates.email;
    delete updates._id;

    if (req.file) {
      updates.photoUrl = `${process.env.BASE_URL}/uploads/${req.file.filename}`;
      const oldUser = await User.findById(userId);
      if (oldUser.photoUrl) {
        const fs = require('fs');
        const path = require('path');
        const oldFilename = oldUser.photoUrl.split('/').pop();
        const oldPath = path.join(__dirname, '../uploads', oldFilename);
        if (fs.existsSync(oldPath)) {
          fs.unlinkSync(oldPath);
        }
      }
    }

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      updates,
      { new: true, select: '-password -__v' }
    );

    if (!updatedUser) {
      return res.status(404).json({ 
        success: false, 
        message: "User not found" 
      });
    }

    res.status(200).json({ 
      success: true,
      user: updatedUser
    });

  } catch (err) {
    console.error('Update profile error:', err);
    
    if (req.file) {
      const fs = require('fs');
      const path = require('path');
      const filePath = path.join(__dirname, '../uploads', req.file.filename);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    res.status(500).json({ 
      success: false, 
      message: "Failed to update profile",
      error: err.message 
    });
  }
};

exports.saveUserData = async (req, res, next) => {
  try {
    const userId = req.body.id;
    const { name, dob, phone, role } = req.body;

    if (role && !['student', 'faculty', 'other', 'admin'].includes(role)) {
      return res.status(400).json({ 
        success: false, 
        message: "Invalid role specified" 
      });
    }

    const updates = {
      name,
      dob,
      phone,
      ...(role && { role }) 
    };

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      updates,
      { new: true, select: '-password -__v' }
    );

    res.status(200).json({ 
      success: true,
      user: updatedUser
    });

  } catch (err) {
    console.error('Save user data error:', err);
    res.status(500).json({ 
      success: false, 
      message: "Failed to save user data",
      error: err.message 
    });
  }
};