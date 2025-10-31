const express = require('express');
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const authMiddleware = require('../utils/auth');
const controller = require('../controllers/equipmentController');

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, '..', 'uploads', 'equipment');
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const filename = `${Date.now()}_${file.fieldname}${ext}`;
    cb(null, filename);
  },
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype && file.mimetype.startsWith('image/')) return cb(null, true);
  return cb(new Error('Only image files are allowed'));
};

const upload = multer({ storage, fileFilter, limits: { fileSize: 10 * 1024 * 1024 } });

// Public
router.get('/', controller.listEquipment);
router.get('/:id', controller.getEquipmentById);

// Protected
router.post('/', authMiddleware, upload.single('image'), controller.createEquipment);
router.put('/:id', authMiddleware, upload.single('image'), controller.updateEquipment);
router.delete('/:id', authMiddleware, controller.deleteEquipment);

module.exports = router;




