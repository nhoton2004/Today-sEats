const Dish = require('../models/Dish.model');
const s3Service = require('../services/s3.service');

// Get all dishes
exports.getAllDishes = async (req, res) => {
  try {
    const { category, status, search, page = 1, limit = 20 } = req.query;
    
    const query = {};
    
    if (category) query.category = category;
    if (status) query.status = status;
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    const dishes = await Dish.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const count = await Dish.countDocuments(query);

    res.json({
      dishes,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count,
    });
  } catch (error) {
    console.error('Error fetching dishes:', error);
    res.status(500).json({ error: error.message });
  }
};

// Get single dish
exports.getDishById = async (req, res) => {
  try {
    const dish = await Dish.findById(req.params.id);
    
    if (!dish) {
      return res.status(404).json({ error: 'Dish not found' });
    }

    res.json(dish);
  } catch (error) {
    console.error('Error fetching dish:', error);
    res.status(500).json({ error: error.message });
  }
};

// Create dish
exports.createDish = async (req, res) => {
  try {
    const dishData = {
      ...req.body,
      createdBy: req.user?.uid,
    };

    const dish = new Dish(dishData);
    await dish.save();

    res.status(201).json(dish);
  } catch (error) {
    console.error('Error creating dish:', error);
    res.status(500).json({ error: error.message });
  }
};

// Update dish
exports.updateDish = async (req, res) => {
  try {
    const dish = await Dish.findByIdAndUpdate(
      req.params.id,
      { ...req.body, updatedAt: Date.now() },
      { new: true, runValidators: true }
    );

    if (!dish) {
      return res.status(404).json({ error: 'Dish not found' });
    }

    res.json(dish);
  } catch (error) {
    console.error('Error updating dish:', error);
    res.status(500).json({ error: error.message });
  }
};

// Delete dish
exports.deleteDish = async (req, res) => {
  try {
    const dish = await Dish.findById(req.params.id);

    if (!dish) {
      return res.status(404).json({ error: 'Dish not found' });
    }

    // Delete image from S3 if exists
    if (dish.imageKey && s3Service.isConfigured()) {
      try {
        await s3Service.deleteFile(dish.imageKey);
      } catch (error) {
        console.error('Error deleting S3 image:', error);
      }
    }

    await Dish.findByIdAndDelete(req.params.id);

    res.json({ success: true, message: 'Dish deleted successfully' });
  } catch (error) {
    console.error('Error deleting dish:', error);
    res.status(500).json({ error: error.message });
  }
};

// Upload dish image
exports.uploadDishImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    if (!s3Service.isConfigured()) {
      return res.status(503).json({ 
        error: 'S3 not configured',
        message: 'AWS S3 credentials not set up'
      });
    }

    const result = await s3Service.uploadFile(req.file);

    res.json(result);
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({ error: error.message });
  }
};
