const User = require('../models/User.model');

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
