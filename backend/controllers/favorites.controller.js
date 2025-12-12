const User = require('../models/User.model');
const Dish = require('../models/Dish.model');

// Get user's favorite dishes
exports.getUserFavorites = async (req, res) => {
    try {
        const { uid } = req.params;

        const user = await User.findOne({ uid });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Get full dish details for all favorites
        const favoriteDishes = await Dish.find({
            _id: { $in: user.favorites }
        }).sort({ createdAt: -1 });

        // Add isFavorite: true to all (since they're all favorites)
        const dishesWithFavorite = favoriteDishes.map(dish => {
            const dishObj = dish.toObject();
            dishObj.isFavorite = true;
            return dishObj;
        });

        console.log(`📋 User ${uid} has ${dishesWithFavorite.length} favorite dishes`);

        res.json({
            favorites: dishesWithFavorite,
            total: dishesWithFavorite.length,
        });
    } catch (error) {
        console.error('Error fetching user favorites:', error);
        res.status(500).json({ error: error.message });
    }
};

module.exports = exports;
