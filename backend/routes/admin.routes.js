const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');

// GET /api/admin/stats
router.get('/stats', adminController.getStats);

module.exports = router;
