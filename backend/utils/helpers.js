const fs = require('fs');
const path = require('path');

exports.deleteFile = (filePath) => {
  const fullPath = path.join(__dirname, '../uploads', filePath);
  if (fs.existsSync(fullPath)) {
    fs.unlinkSync(fullPath);
    return true;
  }
  return false;
};

exports.formatDate = (date) => {
  return new Date(date).toISOString().split('T')[0];
};

exports.parseDate = (input) => {
  if (input instanceof Date) return input;
  if (!input) return new Date();

  // Try ISO format first
  const isoDate = new Date(input);
  if (!isNaN(isoDate.getTime())) return isoDate;

  // Handle custom formats if needed
  const parts = input.split('-');
  if (parts.length === 3) {
    return new Date(parts[2], parts[1] - 1, parts[0]);
  }

  return new Date();
};