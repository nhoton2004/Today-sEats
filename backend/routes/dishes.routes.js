const express = require('express');
const router = express.Router();
const dishesController = require('../controllers/dishes.controller');
const { upload, handleUploadError } = require('../middleware/upload.middleware');
const { verifyToken, isAdmin } = require('../middleware/auth.middleware');

// Public routes
router.get('/', dishesController.getAllDishes);
router.get('/:id', dishesController.getDishById);

// Protected admin routes (require authentication + admin role)
router.post('/', verifyToken, isAdmin, dishesController.createDish);
router.put('/:id', verifyToken, isAdmin, dishesController.updateDish);
router.delete('/:id', verifyToken, isAdmin, dishesController.deleteDish);

// Upload image (admin only)
router.post(
  '/upload/image',
  verifyToken,
  isAdmin,
  upload.single('image'),
  handleUploadError,
  dishesController.uploadDishImage
);

module.exports = router;

