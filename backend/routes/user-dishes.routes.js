const express = require('express');
const router = express.Router();
const Dish = require('../models/Dish.model');

// Get user's personal dishes + global dishes
router.get('/all', async (req, res) => {
    try {
        const userId = req.query.userId; // Get from query param

        // Get global dishes (no owner) + user's personal dishes
        const dishes = await Dish.find({
            $or: [
                { createdBy: null }, // Global dishes
                { createdBy: userId } // User's personal dishes
            ],
            status: 'active'
        }).sort({ createdAt: -1 });

        res.json(dishes);
    } catch (error) {
        console.error('Error fetching dishes:', error);
        res.status(500).json({ error: 'Failed to fetch dishes' });
    }
});

// Get only user's personal dishes
router.get('/my-dishes', async (req, res) => {
    try {
        const userId = req.query.userId;

        if (!userId) {
            return res.status(400).json({ error: 'userId required' });
        }

        const dishes = await Dish.find({
            createdBy: userId
        }).sort({ createdAt: -1 });

        res.json(dishes);
    } catch (error) {
        console.error('Error fetching user dishes:', error);
        res.status(500).json({ error: 'Failed to fetch user dishes' });
    }
});

// Create personal dish
router.post('/create', async (req, res) => {
    try {
        const { userId, name, description, category, mealType, tags, ingredients, cookingInstructions, servings, cookingTime } = req.body;

        if (!userId || !name) {
            return res.status(400).json({ error: 'userId and name required' });
        }

        const newDish = new Dish({
            name,
            description: description || '',
            category: category || 'Món chính',
            mealType: mealType || 'lunch',
            tags: tags || [],
            ingredients: ingredients || [],
            cookingInstructions: cookingInstructions || [],
            servings: servings || 2,
            cookingTime: cookingTime || 30,
            createdBy: userId,
            status: 'active' // Personal dishes are immediately active
        });

        await newDish.save();

        res.status(201).json({
            message: 'Dish created successfully',
            dish: newDish
        });
    } catch (error) {
        console.error('Error creating dish:', error);
        res.status(500).json({ error: 'Failed to create dish' });
    }
});

// Delete personal dish
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.query.userId;

        // Only allow deleting own dishes
        const dish = await Dish.findOne({
            _id: id,
            createdBy: userId
        });

        if (!dish) {
            return res.status(404).json({ error: 'Dish not found or not authorized' });
        }

        await Dish.deleteOne({ _id: id });

        res.json({ message: 'Dish deleted successfully' });
    } catch (error) {
        console.error('Error deleting dish:', error);
        res.status(500).json({ error: 'Failed to delete dish' });
    }
});

module.exports = router;
