const path = require('path');
const fs = require('fs');
const Equipment = require('../models/equipment');

function buildImageUrl(req, filename) {
  // Use BASE_URL from environment if available (most reliable)
  if (process.env.BASE_URL) {
    const baseUrl = process.env.BASE_URL.endsWith('/') 
      ? process.env.BASE_URL.slice(0, -1) 
      : process.env.BASE_URL;
    return `${baseUrl}/equipment/${filename}`;
  }
  
  // Fallback to request-based URL construction
  // Handle proxy headers (X-Forwarded-Host, X-Forwarded-Proto) if present
  const protocol = req.get('x-forwarded-proto') || req.protocol || 'http';
  const host = req.get('x-forwarded-host') || req.get('host') || (process.env.PORT ? `localhost:${process.env.PORT}` : 'localhost:3001');
  const imageUrl = `${protocol}://${host}/equipment/${filename}`;
  
  // Debug log to help diagnose URL issues
  if (process.env.NODE_ENV === 'development') {
    console.log(`[Equipment] Generated image URL: ${imageUrl}`);
    console.log(`[Equipment] Request host: ${req.get('host')}, protocol: ${req.protocol}`);
    console.log(`[Equipment] X-Forwarded-Host: ${req.get('x-forwarded-host')}, X-Forwarded-Proto: ${req.get('x-forwarded-proto')}`);
  }
  
  return imageUrl;
}

exports.createEquipment = async (req, res) => {
  try {
    const { name, description, price, contact, location, isAvailable } = req.body;

    // Validate name
    if (!name || typeof name !== 'string') {
      return res.status(400).json({ success: false, message: 'Name is required' });
    }
    const trimmedName = name.trim();
    if (trimmedName.length < 2) {
      return res.status(400).json({ success: false, message: 'Name must be at least 2 characters long' });
    }
    if (trimmedName.length > 120) {
      return res.status(400).json({ success: false, message: 'Name cannot exceed 120 characters' });
    }

    // Validate description
    if (description !== undefined && description !== null) {
      const descStr = String(description);
      if (descStr.length > 2000) {
        return res.status(400).json({ success: false, message: 'Description cannot exceed 2000 characters' });
      }
    }

    // Validate price
    if (price === undefined || price === null || price === '') {
      return res.status(400).json({ success: false, message: 'Price is required' });
    }
    const parsedPrice = Number(price);
    if (Number.isNaN(parsedPrice)) {
      return res.status(400).json({ success: false, message: 'Price must be a valid number' });
    }
    if (parsedPrice < 0) {
      return res.status(400).json({ success: false, message: 'Price must be a non-negative number (0 for free)' });
    }

    // Validate contact
    if (!contact) {
      return res.status(400).json({ success: false, message: 'Contact number is required' });
    }
    const contactStr = String(contact).trim();
    if (!/^\d+$/.test(contactStr)) {
      return res.status(400).json({ success: false, message: 'Contact number must contain only digits' });
    }
    if (contactStr.length < 10) {
      return res.status(400).json({ success: false, message: 'Contact number must be exactly 10 digits (e.g., 9876543210)' });
    }
    if (contactStr.length > 10) {
      return res.status(400).json({ success: false, message: 'Contact number must be exactly 10 digits' });
    }

    // Validate location
    if (location !== undefined && location !== null) {
      const locationStr = String(location);
      if (locationStr.length > 200) {
        return res.status(400).json({ success: false, message: 'Location cannot exceed 200 characters' });
      }
    }

    const owner = req.user && req.user.id ? req.user.id : null;
    if (!owner) return res.status(401).json({ success: false, message: 'Unauthorized' });

    let imageUrl = '';
    if (req.file) {
      imageUrl = buildImageUrl(req, req.file.filename);
    }

    const equipment = await Equipment.create({
      name: trimmedName,
      description: description ? String(description).trim() : '',
      price: parsedPrice,
      contact: contactStr,
      location: location ? String(location).trim() : '',
      isAvailable: String(isAvailable).toLowerCase() === 'true' || isAvailable === true,
      imageUrl,
      owner,
    });

    return res.status(201).json({ success: true, data: equipment });
  } catch (err) {
    console.error(err);
    // Handle mongoose validation errors
    if (err.name === 'ValidationError') {
      const errors = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({ success: false, message: errors.join(', ') });
    }
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

exports.listEquipment = async (req, res) => {
  try {
    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
    const skip = (page - 1) * limit;
    console.log("HEY");
    const [items, total] = await Promise.all([
      Equipment.find({}).sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
      Equipment.countDocuments({}),
    ]);

    return res.status(200).json({ success: true, data: items, page, limit, total });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

exports.getEquipmentById = async (req, res) => {
  try {
    const { id } = req.params;
    const item = await Equipment.findById(id);
    if (!item) return res.status(404).json({ success: false, message: 'Not found' });
    return res.status(200).json({ success: true, data: item });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

exports.updateEquipment = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, price, contact, location, isAvailable } = req.body;

    const existing = await Equipment.findById(id);
    if (!existing) return res.status(404).json({ success: false, message: 'Not found' });

    if (!req.user || String(existing.owner) !== String(req.user.id)) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }

    const update = {};

    // Validate and update name
    if (typeof name !== 'undefined') {
      if (!name || typeof name !== 'string') {
        return res.status(400).json({ success: false, message: 'Name is required' });
      }
      const trimmedName = name.trim();
      if (trimmedName.length < 2) {
        return res.status(400).json({ success: false, message: 'Name must be at least 2 characters long' });
      }
      if (trimmedName.length > 120) {
        return res.status(400).json({ success: false, message: 'Name cannot exceed 120 characters' });
      }
      update.name = trimmedName;
    }

    // Validate and update description
    if (typeof description !== 'undefined') {
      if (description !== null) {
        const descStr = String(description);
        if (descStr.length > 2000) {
          return res.status(400).json({ success: false, message: 'Description cannot exceed 2000 characters' });
        }
        update.description = descStr.trim();
      } else {
        update.description = '';
      }
    }

    // Validate and update price
    if (typeof price !== 'undefined') {
      const parsedPrice = Number(price);
      if (Number.isNaN(parsedPrice)) {
        return res.status(400).json({ success: false, message: 'Price must be a valid number' });
      }
      if (parsedPrice < 0) {
        return res.status(400).json({ success: false, message: 'Price must be a non-negative number (0 for free)' });
      }
      update.price = parsedPrice;
    }

    // Validate and update contact
    if (typeof contact !== 'undefined') {
      if (!contact) {
        return res.status(400).json({ success: false, message: 'Contact number is required' });
      }
      const contactStr = String(contact).trim();
      if (!/^\d+$/.test(contactStr)) {
        return res.status(400).json({ success: false, message: 'Contact number must contain only digits' });
      }
      if (contactStr.length < 10) {
        return res.status(400).json({ success: false, message: 'Contact number must be exactly 10 digits (e.g., 9876543210)' });
      }
      if (contactStr.length > 10) {
        return res.status(400).json({ success: false, message: 'Contact number must be exactly 10 digits' });
      }
      update.contact = contactStr;
    }

    // Validate and update location
    if (typeof location !== 'undefined') {
      if (location !== null) {
        const locationStr = String(location);
        if (locationStr.length > 200) {
          return res.status(400).json({ success: false, message: 'Location cannot exceed 200 characters' });
        }
        update.location = locationStr.trim();
      } else {
        update.location = '';
      }
    }

    // Update isAvailable
    if (typeof isAvailable !== 'undefined') {
      update.isAvailable = String(isAvailable).toLowerCase() === 'true' || isAvailable === true;
    }

    if (req.file) {
      // delete old file if existed and was a local path
      if (existing.imageUrl) {
        const filename = path.basename(existing.imageUrl);
        const filePath = path.join(__dirname, '..', 'uploads', 'equipment', filename);
        if (fs.existsSync(filePath)) {
          try { await fs.promises.unlink(filePath); } catch (_) {}
        }
      }
      update.imageUrl = buildImageUrl(req, req.file.filename);
    }

    const saved = await Equipment.findByIdAndUpdate(id, update, { new: true });
    return res.status(200).json({ success: true, data: saved });
  } catch (err) {
    console.error(err);
    // Handle mongoose validation errors
    if (err.name === 'ValidationError') {
      const errors = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({ success: false, message: errors.join(', ') });
    }
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

exports.deleteEquipment = async (req, res) => {
  try {
    const { id } = req.params;
    const existing = await Equipment.findById(id);
    if (!existing) return res.status(404).json({ success: false, message: 'Not found' });

    if (!req.user || String(existing.owner) !== String(req.user.id)) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }

    if (existing.imageUrl) {
      const filename = path.basename(existing.imageUrl);
      const filePath = path.join(__dirname, '..', 'uploads', 'equipment', filename);
      if (fs.existsSync(filePath)) {
        try { await fs.promises.unlink(filePath); } catch (_) {}
      }
    }

    await Equipment.findByIdAndDelete(id);
    return res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};




