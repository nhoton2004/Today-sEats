const express = require('express');
const router = express.Router();
const usersController = require('../controllers/users.controller');
const { upload, handleUploadError } = require('../middleware/upload.middleware');
const { verifyToken } = require('../middleware/auth.middleware');

// Upload avatar
router.post(
    '/upload/avatar',
    verifyToken,
    upload.single('image'),
    handleUploadError,
    usersController.uploadUserAvatar
);

// Get all users
router.get('/', usersController.getAllUsers);

// Get user stats (must be before /:uid to avoid route conflict)
router.get('/:uid/stats', usersController.getUserStats);

// Get user's favorite dishes (must be before /:uid)
router.get('/:uid/favorites/dishes', require('../controllers/favorites.controller').getUserFavorites);

// Toggle favorite (must be before /:uid)
router.post('/:uid/favorites', usersController.toggleFavorite);

// Get user by UID (catch-all, must be last among GET /:uid routes)
router.get('/:uid', usersController.getUserByUid);

// Create or update user
router.post('/', usersController.createOrUpdateUser);

// Update user profile
router.put('/:uid', usersController.updateUserProfile);

// Delete user
router.delete('/:uid', usersController.deleteUser);

module.exports = router;
