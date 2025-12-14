const Dish = require('../models/Dish.model');
const User = require('../models/User.model');

exports.getStats = async (req, res) => {
    try {
        // 1. Total Dishes
        const totalDishes = await Dish.countDocuments();

        // 2. Active Dishes (assuming active if not explicitly inactive/false)
        const activeDishes = await Dish.countDocuments({ status: { $ne: 'inactive' } });

        // 3. Total Users
        const totalUsers = await User.countDocuments();

        // 4. Timestamp
        const updatedAt = new Date().toISOString();

        res.json({
            totalDishes,
            activeDishes,
            totalUsers,
            updatedAt
        });
    } catch (error) {
        console.error('Error fetching admin stats:', error);
        res.status(500).json({ message: 'Lỗi khi lấy thống kê' });
    }
};
