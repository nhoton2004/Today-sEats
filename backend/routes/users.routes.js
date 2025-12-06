const express = require('express');
const router = express.Router();
const usersController = require('../controllers/users.controller');

// Get all users
router.get('/', usersController.getAllUsers);

// Get user by UID
router.get('/:uid', usersController.getUserByUid);

// Create or update user
router.post('/', usersController.createOrUpdateUser);

// Update user profile
router.put('/:uid', usersController.updateUserProfile);

// Toggle favorite
router.post('/:uid/favorites', usersController.toggleFavorite);

// Delete user
router.delete('/:uid', usersController.deleteUser);

module.exports = router;
