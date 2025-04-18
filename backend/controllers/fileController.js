// const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
exports.getImageById = (req, res) => {
    const imageId = req.params.imageId;
    const imagePath = path.join(__dirname, 'images', imageId);

    // Validate imageId to prevent directory traversal
    if (!/^[a-zA-Z0-9\-_]+\.(jpg|jpeg|png|gif)$/i.test(imageId)) {
        return res.status(400).send('Invalid image ID');
    }

    res.sendFile(imagePath, { headers: { 'Content-Type': 'image/*' } }, (err) => {
        if (err) {
            res.status(404).send('Image not found');
        }
    });
};

const cache = new Map();

exports.fileServing = (req, res) => {
    const  filename = req.params.filename;
    const width = parseInt(req.query.w) || 200; // Optional width parameter
    // Check cache first
    if (cache.has(`${filename}-${width}`)) {
        const { buffer, mtime } = cache.get(`${filename}-${width}`);
        res.set('Content-Type', 'image/jpeg');
        res.set('Last-Modified', mtime.toUTCString());
        console.log("image");
        return res.send(buffer);
    }

    const filePath = path.join(__dirname, '..','uploads', 'profiles', `${filename}`);
    console.log(filePath);

    fs.stat(filePath, (err, stats) => {
        if (err) return res.status(404).send();

        // Simple image processing (resize if needed)
        if (width !== 200) {
            const sharp = require('sharp');
            sharp(filePath)
                .resize(width)
                .jpeg({ quality: 80, mozjpeg: true })
                .toBuffer()
                .then(buffer => {
                    cache.set(`${filename}-${width}`, {
                        buffer,
                        mtime: stats.mtime
                    });
                    res.set('Content-Type', 'image/jpeg');
                    res.set('Cache-Control', 'public, max-age=86400'); // 1 day
                    res.send(buffer);
                });
        } else {
            fs.readFile(filePath, (err, data) => {
                if (err) return res.status(404).send();
                cache.set(`${filename}-${width}`, {
                    buffer: data,
                    mtime: stats.mtime
                });
                res.set('Content-Type', 'image/jpeg');
                res.set('Cache-Control', 'public, max-age=86400'); // 1 day
                res.send(data);
            });
        }
    });
};
