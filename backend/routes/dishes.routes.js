const express = require('express');
const router = express.Router();
const dishesController = require('../controllers/dishes.controller');
const { upload, handleUploadError } = require('../middleware/upload.middleware');
const { verifyToken } = require('../middleware/auth.middleware');

// Public routes
router.get('/', dishesController.getAllDishes);
router.get('/:id', dishesController.getDishById);

// Protected routes (require authentication)
router.post('/', verifyToken, dishesController.createDish);
router.put('/:id', verifyToken, dishesController.updateDish);
router.delete('/:id', verifyToken, dishesController.deleteDish);

// Upload image
router.post(
  '/upload/image',
  upload.single('image'),
  handleUploadError,
  dishesController.uploadDishImage
);

module.exports = router;
