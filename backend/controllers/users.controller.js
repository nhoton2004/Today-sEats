const User = require('../models/User.model');
const Dish = require('../models/Dish.model');
const s3Service = require('../services/s3.service');

// Upload user avatar
exports.uploadUserAvatar = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    // Ensure user is authenticated (middleware should handle this, but double check)
    const uid = req.user ? req.user.uid : req.body.uid;
    if (!uid) {
      return res.status(401).json({ error: 'Unauthorized', message: 'User ID not found in request' });
    }

    // Check S3 config
    if (!s3Service.isConfigured()) {
      return res.status(503).json({
        error: 'S3 not configured',
        message: 'AWS S3 credentials not set up'
      });
    }

    // Upload to S3
    const uploadResult = await s3Service.uploadFile(req.file, 'user_avatars');
    const photoURL = uploadResult.url;

    // Update MongoDB User Document
    const updatedUser = await User.findOneAndUpdate(
      { uid: uid },
      { photoURL: photoURL, updatedAt: Date.now() },
      { new: true }
    );

    if (!updatedUser) {
      // If user not found in MongoDB but exists in Firebase (edge case), create/log it?
      // For now, return success with URL but warn.
      console.warn(`User ${uid} uploaded avatar but was not found in MongoDB.`);
      return res.json({
        success: true,
        message: 'Uploaded to S3 but User not found in DB',
        url: photoURL
      });
    }

    res.json({
      success: true,
      message: 'Avatar uploaded and profile updated',
      url: photoURL,
      user: updatedUser
    });

  } catch (error) {
    console.error('Error uploading avatar:', error);
    res.status(500).json({ error: error.message });
  }
};


// Get user statistics
exports.getUserStats = async (req, res) => {
  try {
    const { uid } = req.params;

    const user = await User.findOne({ uid });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Count dishes created by user
    const dishesCreated = await Dish.countDocuments({ createdBy: uid });

    // Count favorites
    const favoritesCount = user.favorites.length;

    // Count cooked dishes (not implemented yet, return 0)
    const cookedCount = 0;

    res.json({
      dishesCreated,
      favoritesCount,
      cookedCount,
    });
  } catch (error) {
    console.error('Error fetching user stats:', error);
    res.status(500).json({ error: error.message });
  }
};

// Get all users
exports.getAllUsers = async (req, res) => {
  try {
    const { role, isActive, page = 1, limit = 20 } = req.query;

    const query = {};
    if (role) query.role = role;
    if (isActive !== undefined) query.isActive = isActive === 'true';

    const users = await User.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .select('-__v')
      .exec();

    const count = await User.countDocuments(query);

    res.json({
      users,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count,
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: error.message });
  }
};

// Get user by UID
exports.getUserByUid = async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.params.uid })
      .populate('favorites', 'name imageUrl category rating');

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: error.message });
  }
};

// Create or update user
exports.createOrUpdateUser = async (req, res) => {
  try {
    const { uid, email, displayName, photoURL } = req.body;

    if (!uid || !email) {
      return res.status(400).json({ error: 'UID and email are required' });
    }

    let user = await User.findOne({ uid });

    if (user) {
      // Update existing user
      user.displayName = displayName || user.displayName;
      user.photoURL = photoURL || user.photoURL;
      user.lastLoginAt = Date.now();
      await user.save();
    } else {
      // Create new user
      user = new User({
        uid,
        email,
        displayName: displayName || 'User',
        photoURL: photoURL || '',
        role: 'user',
      });
      await user.save();
    }

    res.json(user);
  } catch (error) {
    console.error('Error creating/updating user:', error);
    res.status(500).json({ error: error.message });
  }
};

// Update user profile
exports.updateUserProfile = async (req, res) => {
  try {
    const user = await User.findOneAndUpdate(
      { uid: req.params.uid },
      { ...req.body, updatedAt: Date.now() },
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ error: error.message });
  }
};

// Toggle favorite dish
exports.toggleFavorite = async (req, res) => {
  try {
    const { uid } = req.params;
    const { dishId } = req.body;

    const user = await User.findOne({ uid });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const favoriteIndex = user.favorites.indexOf(dishId);

    if (favoriteIndex > -1) {
      // Remove from favorites
      user.favorites.splice(favoriteIndex, 1);
    } else {
      // Add to favorites
      user.favorites.push(dishId);
    }

    await user.save();

    res.json({
      success: true,
      isFavorite: favoriteIndex === -1,
      favorites: user.favorites,
    });
  } catch (error) {
    console.error('Error toggling favorite:', error);
    res.status(500).json({ error: error.message });
  }
};

// Delete user
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findOneAndDelete({ uid: req.params.uid });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ success: true, message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ error: error.message });
  }
};
