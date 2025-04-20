const express = require('express');
const router = express.Router();
const fileController=require('../controllers/fileController');
router.get('/profile/:filename',fileController.fileServing);
module.exports = router;