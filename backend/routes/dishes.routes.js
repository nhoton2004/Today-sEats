const express = require('express');
const router = express.Router();
const dishesController = require('../controllers/dishes.controller');
const { upload, handleUploadError } = require('../middleware/upload.middleware');

// Public routes
router.get('/', dishesController.getAllDishes);
router.get('/:id', dishesController.getDishById);

// Protected routes (require authentication in production)
router.post('/', dishesController.createDish);
router.put('/:id', dishesController.updateDish);
router.delete('/:id', dishesController.deleteDish);

// Upload image
router.post(
  '/upload/image',
  upload.single('image'),
  handleUploadError,
  dishesController.uploadDishImage
);

module.exports = router;
