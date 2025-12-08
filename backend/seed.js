// Script để seed dữ liệu mẫu vào MongoDB
const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Dish = require('./models/Dish.model');
const User = require('./models/User.model');

// Sample dishes data
const sampleDishes = [
  // Breakfast
  {
    name: 'Phở Bò',
    category: 'Món chính',
    description: 'Phở bò truyền thống Hà Nội với nước dùng thơm ngon',
    price: 45000,
    status: 'active',
    mealType: 'breakfast',
    rating: 4.8,
    tags: ['vietnamese', 'soup', 'beef'],
    nutrition: { calories: 350, protein: 20, carbs: 45, fat: 8 }
  },
  {
    name: 'Bánh Mì Thịt',
    category: 'Bánh/Bánh mì',
    description: 'Bánh mì giòn với thịt nguội, pate và rau sống',
    price: 25000,
    status: 'active',
    mealType: 'breakfast',
    rating: 4.6,
    tags: ['vietnamese', 'sandwich'],
    nutrition: { calories: 400, protein: 15, carbs: 50, fat: 15 }
  },
  {
    name: 'Xôi Xéo',
    category: 'Món chính',
    description: 'Xôi nếp vàng với đậu xanh và hành phi',
    price: 20000,
    status: 'active',
    mealType: 'breakfast',
    rating: 4.5,
    tags: ['vietnamese', 'sticky-rice'],
    nutrition: { calories: 300, protein: 8, carbs: 55, fat: 6 }
  },
  {
    name: 'Bún Bò Huế',
    category: 'Món chính',
    description: 'Bún bò cay đặc trưng miền Trung',
    price: 50000,
    status: 'active',
    mealType: 'breakfast',
    rating: 4.7,
    tags: ['vietnamese', 'spicy', 'noodles'],
    nutrition: { calories: 450, protein: 25, carbs: 50, fat: 15 }
  },

  // Lunch
  {
    name: 'Cơm Tấm Sườn Bì',
    category: 'Món chính',
    description: 'Cơm tấm với sườn nướng, bì và chả trứng',
    price: 40000,
    status: 'active',
    mealType: 'lunch',
    rating: 4.9,
    tags: ['vietnamese', 'rice', 'grilled'],
    nutrition: { calories: 650, protein: 30, carbs: 70, fat: 20 }
  },
  {
    name: 'Bún Chả Hà Nội',
    category: 'Món chính',
    description: 'Bún chả với thịt nướng và nước mắm chua ngọt',
    price: 45000,
    status: 'active',
    mealType: 'lunch',
    rating: 4.8,
    tags: ['vietnamese', 'grilled', 'noodles'],
    nutrition: { calories: 500, protein: 28, carbs: 55, fat: 18 }
  },
  {
    name: 'Cơm Gà Xối Mỡ',
    category: 'Món chính',
    description: 'Cơm gà Hội An với nước sốt đặc biệt',
    price: 50000,
    status: 'active',
    mealType: 'lunch',
    rating: 4.7,
    tags: ['vietnamese', 'chicken', 'rice'],
    nutrition: { calories: 600, protein: 35, carbs: 65, fat: 18 }
  },
  {
    name: 'Mì Quảng',
    category: 'Món chính',
    description: 'Mì Quảng với tôm, thịt và đậu phộng',
    price: 45000,
    status: 'active',
    mealType: 'lunch',
    rating: 4.6,
    tags: ['vietnamese', 'noodles', 'seafood'],
    nutrition: { calories: 550, protein: 30, carbs: 60, fat: 16 }
  },

  // Dinner
  {
    name: 'Lẩu Thái Hải Sản',
    category: 'Món chính',
    description: 'Lẩu Thái chua cay với hải sản tươi',
    price: 150000,
    status: 'active',
    mealType: 'dinner',
    rating: 4.9,
    tags: ['thai', 'hotpot', 'seafood', 'spicy'],
    nutrition: { calories: 400, protein: 40, carbs: 20, fat: 15 }
  },
  {
    name: 'Cá Kho Tộ',
    category: 'Món chính',
    description: 'Cá kho tộ kiểu miền Nam với nước màu đậm đà',
    price: 55000,
    status: 'active',
    mealType: 'dinner',
    rating: 4.7,
    tags: ['vietnamese', 'fish', 'braised'],
    nutrition: { calories: 350, protein: 30, carbs: 15, fat: 18 }
  },
  {
    name: 'Gà Kho Gừng',
    category: 'Món chính',
    description: 'Gà kho gừng thơm nồng, đậm đà',
    price: 60000,
    status: 'active',
    mealType: 'dinner',
    rating: 4.6,
    tags: ['vietnamese', 'chicken', 'braised'],
    nutrition: { calories: 450, protein: 35, carbs: 20, fat: 22 }
  },
  {
    name: 'Bò Lúc Lắc',
    category: 'Món chính',
    description: 'Bò lúc lắc với khoai tây chiên',
    price: 80000,
    status: 'active',
    mealType: 'dinner',
    rating: 4.8,
    tags: ['vietnamese', 'beef', 'stir-fry'],
    nutrition: { calories: 550, protein: 40, carbs: 30, fat: 25 }
  },

  // Snacks
  {
    name: 'Chả Giò',
    category: 'Món ăn vặt',
    description: 'Chả giò chiên giòn với rau sống',
    price: 35000,
    status: 'active',
    mealType: 'snack',
    rating: 4.7,
    tags: ['vietnamese', 'fried', 'spring-rolls'],
    nutrition: { calories: 300, protein: 12, carbs: 25, fat: 18 }
  },
  {
    name: 'Bánh Bột Lọc',
    category: 'Món ăn vặt',
    description: 'Bánh bột lọc trong suốt với tôm, thịt',
    price: 30000,
    status: 'active',
    mealType: 'snack',
    rating: 4.5,
    tags: ['vietnamese', 'dumpling'],
    nutrition: { calories: 200, protein: 10, carbs: 30, fat: 5 }
  },
  {
    name: 'Nem Chua Rán',
    category: 'Món ăn vặt',
    description: 'Nem chua Thanh Hóa chiên giòn',
    price: 40000,
    status: 'active',
    mealType: 'snack',
    rating: 4.8,
    tags: ['vietnamese', 'fried', 'fermented'],
    nutrition: { calories: 250, protein: 15, carbs: 20, fat: 12 }
  },

  // Desserts
  {
    name: 'Chè Bưởi',
    category: 'Tráng miệng',
    description: 'Chè bưởi mát lạnh với nước cốt dừa',
    price: 25000,
    status: 'active',
    mealType: 'snack',
    rating: 4.6,
    tags: ['vietnamese', 'dessert', 'sweet'],
    nutrition: { calories: 200, protein: 3, carbs: 40, fat: 5 }
  },
  {
    name: 'Sữa Chua Trái Cây',
    category: 'Tráng miệng',
    description: 'Sữa chua nha đam với trái cây tươi',
    price: 20000,
    status: 'active',
    mealType: 'snack',
    rating: 4.5,
    tags: ['vietnamese', 'dessert', 'yogurt'],
    nutrition: { calories: 150, protein: 5, carbs: 28, fat: 3 }
  },
  {
    name: 'Bánh Flan',
    category: 'Tráng miệng',
    description: 'Bánh flan caramen mềm mịn',
    price: 15000,
    status: 'active',
    mealType: 'snack',
    rating: 4.4,
    tags: ['vietnamese', 'dessert', 'custard'],
    nutrition: { calories: 180, protein: 6, carbs: 25, fat: 7 }
  },

  // Drinks
  {
    name: 'Trà Sữa Trân Châu',
    category: 'Đồ uống',
    description: 'Trà sữa Đài Loan với trân châu đường đen',
    price: 35000,
    status: 'active',
    mealType: 'snack',
    rating: 4.9,
    tags: ['taiwanese', 'bubble-tea', 'sweet'],
    nutrition: { calories: 350, protein: 5, carbs: 60, fat: 10 }
  },
  {
    name: 'Cà Phê Sữa Đá',
    category: 'Đồ uống',
    description: 'Cà phê phin Việt Nam đậm đà',
    price: 25000,
    status: 'active',
    mealType: 'breakfast',
    rating: 4.8,
    tags: ['vietnamese', 'coffee'],
    nutrition: { calories: 150, protein: 3, carbs: 20, fat: 6 }
  },
];

// Sample users
const sampleUsers = [
  {
    uid: 'test_user_1',
    email: 'user1@todayseats.com',
    displayName: 'Nguyễn Văn A',
    role: 'user',
    preferences: {
      favoriteCategories: ['main', 'dessert'],
      dietaryRestrictions: []
    }
  },
  {
    uid: 'test_user_2',
    email: 'user2@todayseats.com',
    displayName: 'Trần Thị B',
    role: 'user',
    preferences: {
      favoriteCategories: ['snack', 'drink'],
      dietaryRestrictions: ['vegetarian']
    }
  },
  {
    uid: 'admin_user',
    email: 'admin@todayseats.com',
    displayName: 'Admin',
    role: 'admin',
    preferences: {
      favoriteCategories: [],
      dietaryRestrictions: []
    }
  }
];

// Main seed function
async function seedDatabase() {
  try {
    console.log('🌱 Starting database seeding...');

    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing data
    console.log('🗑️  Clearing existing data...');
    await Dish.deleteMany({});
    await User.deleteMany({});
    console.log('✅ Cleared existing data');

    // Insert sample dishes
    console.log('📝 Inserting dishes...');
    const dishes = await Dish.insertMany(sampleDishes);
    console.log(`✅ Inserted ${dishes.length} dishes`);

    // Insert sample users
    console.log('👥 Inserting users...');
    const users = await User.insertMany(sampleUsers);
    console.log(`✅ Inserted ${users.length} users`);

    // Add some favorites
    console.log('❤️  Adding favorites...');
    if (users.length > 0 && dishes.length > 0) {
      const user = users[0];
      user.favorites = [dishes[0]._id, dishes[4]._id, dishes[8]._id];
      await user.save();
      console.log(`✅ Added ${user.favorites.length} favorites for ${user.displayName}`);
    }

    console.log('\n🎉 Database seeding completed successfully!');
    console.log('📊 Summary:');
    console.log(`   - Dishes: ${dishes.length}`);
    console.log(`   - Users: ${users.length}`);
    console.log(`   - Categories: ${[...new Set(dishes.map(d => d.category))].join(', ')}`);
    console.log(`   - Meal Types: ${[...new Set(dishes.map(d => d.mealType))].join(', ')}`);

  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
    process.exit(0);
  }
}

// Run the seed function
seedDatabase();
