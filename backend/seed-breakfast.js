const mongoose = require('mongoose');
const Dish = require('./models/Dish.model');
require('dotenv').config();

const vietnameseBreakfastDishes = [
    {
        name: 'Phở Bò',
        category: 'Món chính',
        description: 'Món phở truyền thống với nước dùng thơm ngon, bánh phở mềm, thịt bò tươi',
        mealType: 'breakfast',
        tags: ['việt nam', 'phở', 'sáng', 'nước'],
        status: 'active',
        preparationTime: 30,
        cookingTime: 45,
        servings: 1,
    },
    {
        name: 'Bánh Mì',
        category: 'Món chính',
        description: 'Bánh mì Việt Nam với nhân thịt, pate, rau sống, dưa chua',
        mealType: 'breakfast',
        tags: ['việt nam', 'bánh mì', 'sáng', 'nhanh'],
        status: 'active',
        preparationTime: 10,
        cookingTime: 5,
        servings: 1,
    },
    {
        name: 'Cơm Tấm',
        category: 'Món chính',
        description: 'Cơm tấm sườn nướng thơm phức, bì, chả trứng',
        mealType: 'breakfast',
        tags: ['việt nam', 'cơm', 'sáng', 'miền nam'],
        status: 'active',
        preparationTime: 20,
        cookingTime: 30,
        servings: 1,
    },
    {
        name: 'Bún Bò Huế',
        category: 'Món chính',
        description: 'Bún bò Huế với nước dùng cay nồng, thịt bò, chả, giò heo',
        mealType: 'breakfast',
        tags: ['việt nam', 'bún', 'sáng', 'huế', 'cay'],
        status: 'active',
        preparationTime: 40,
        cookingTime: 60,
        servings: 1,
    },
    {
        name: 'Hủ Tiếu Nam Vang',
        category: 'Món chính',
        description: 'Hủ tiếu Nam Vang với nước dùng ngọt thanh, tôm, thịt',
        mealType: 'breakfast',
        tags: ['việt nam', 'hủ tiếu', 'sáng', 'miền nam'],
        status: 'active',
        preparationTime: 25,
        cookingTime: 35,
        servings: 1,
    },
    {
        name: 'Bánh Cuốn',
        category: 'Món chính',
        description: 'Bánh cuốn nóng hổi với nhân thịt, mộc nhĩ, hành phi',
        mealType: 'breakfast',
        tags: ['việt nam', 'bánh', 'sáng', 'miền bắc'],
        status: 'active',
        preparationTime: 30,
        cookingTime: 20,
        servings: 1,
    },
    {
        name: 'Xôi Xéo',
        category: 'Món chính',
        description: 'Xôi xéo với đậu xanh, hành phi, thịt gà xé',
        mealType: 'breakfast',
        tags: ['việt nam', 'xôi', 'sáng', 'nếp'],
        status: 'active',
        preparationTime: 15,
        cookingTime: 30,
        servings: 1,
    },
    {
        name: 'Bún Riêu Cua',
        category: 'Món chính',
        description: 'Bún riêu cua với nước dùng cà chua, riêu cua thơm ngon',
        mealType: 'breakfast',
        tags: ['việt nam', 'bún', 'sáng', 'cua'],
        status: 'active',
        preparationTime: 35,
        cookingTime: 40,
        servings: 1,
    },
    {
        name: 'Bánh Canh Cua',
        category: 'Món chính',
        description: 'Bánh canh cua với sợi bánh canh dai, nước dùng đậm đà',
        mealType: 'breakfast',
        tags: ['việt nam', 'bánh canh', 'sáng', 'cua'],
        status: 'active',
        preparationTime: 30,
        cookingTime: 35,
        servings: 1,
    },
    {
        name: 'Mì Quảng',
        category: 'Món chính',
        description: 'Mì Quảng đặc trưng Quảng Nam với tôm, thịt, bánh đa',
        mealType: 'breakfast',
        tags: ['việt nam', 'mì', 'sáng', 'quảng nam'],
        status: 'active',
        preparationTime: 30,
        cookingTime: 40,
        servings: 1,
    },
    {
        name: 'Bò Kho',
        category: 'Món chính',
        description: 'Bò kho với nước sốt cà chua, thơm nồng gia vị',
        mealType: 'breakfast',
        tags: ['việt nam', 'bò', 'sáng', 'kho'],
        status: 'active',
        preparationTime: 20,
        cookingTime: 90,
        servings: 2,
    },
    {
        name: 'Bún Mọc',
        category: 'Món chính',
        description: 'Bún mọc với viên thịt mềm, nước dùng trong vắt',
        mealType: 'breakfast',
        tags: ['việt nam', 'bún', 'sáng', 'thịt'],
        status: 'active',
        preparationTime: 25,
        cookingTime: 30,
        servings: 1,
    },
    {
        name: 'Xôi Mặn (Xôi Thập Cẩm)',
        category: 'Món chính',
        description: 'Xôi mặn với nhiều topping: thịt, trứng, lạp xưởng, ruốc',
        mealType: 'breakfast',
        tags: ['việt nam', 'xôi', 'sáng', 'mặn'],
        status: 'active',
        preparationTime: 20,
        cookingTime: 35,
        servings: 1,
    },
    {
        name: 'Bánh Giò',
        category: 'Món chính',
        description: 'Bánh giò nóng hổi với nhân thịt, mộc nhĩ, trứng cút',
        mealType: 'breakfast',
        tags: ['việt nam', 'bánh', 'sáng', 'hấp'],
        status: 'active',
        preparationTime: 30,
        cookingTime: 45,
        servings: 1,
    },
    {
        name: 'Cháo Lòng',
        category: 'Món chính',
        description: 'Cháo lòng nóng hổi với lòng heo, rau thơm',
        mealType: 'breakfast',
        tags: ['việt nam', 'cháo', 'sáng', 'lòng'],
        status: 'active',
        preparationTime: 20,
        cookingTime: 40,
        servings: 1,
    },
    {
        name: 'Bún Cá',
        category: 'Món chính',
        description: 'Bún cá với nước dùng cà chua, cá thác lác chiên giòn',
        mealType: 'breakfast',
        tags: ['việt nam', 'bún', 'sáng', 'cá'],
        status: 'active',
        preparationTime: 25,
        cookingTime: 35,
        servings: 1,
    },
    {
        name: 'Miến Lươn',
        category: 'Món chính',
        description: 'Miến lươn thơm ngon với lươn xào giòn, miến dai',
        mealType: 'breakfast',
        tags: ['việt nam', 'miến', 'sáng', 'lươn'],
        status: 'active',
        preparationTime: 30,
        cookingTime: 25,
        servings: 1,
    },
    {
        name: 'Bánh Bao',
        category: 'Món chính',
        description: 'Bánh bao nhân thịt, trứng, xúc xích, nóng hổi',
        mealType: 'breakfast',
        tags: ['việt nam', 'bánh', 'sáng', 'hấp'],
        status: 'active',
        preparationTime: 40,
        cookingTime: 25,
        servings: 1,
    },
    {
        name: 'Cháo Sườn',
        category: 'Món chính',
        description: 'Cháo sườn nấu kỹ, thịt sườn mềm, cháo mịn',
        mealType: 'breakfast',
        tags: ['việt nam', 'cháo', 'sáng', 'sườn'],
        status: 'active',
        preparationTime: 15,
        cookingTime: 45,
        servings: 1,
    },
    {
        name: 'Bánh Bèo',
        category: 'Món phụ',
        description: 'Bánh bèo miền Trung với tôm, mỡ hành, nước mắm chua ngọt',
        mealType: 'breakfast',
        tags: ['việt nam', 'bánh', 'sáng', 'miền trung'],
        status: 'active',
        preparationTime: 30,
        cookingTime: 20,
        servings: 1,
    },
];

async function seedBreakfastDishes() {
    try {
        // Connect to MongoDB
        const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/todayseats';
        await mongoose.connect(mongoURI);
        console.log('✅ Connected to MongoDB');

        // Check if dishes already exist
        const existingCount = await Dish.countDocuments({
            name: { $in: vietnameseBreakfastDishes.map(d => d.name) }
        });

        if (existingCount > 0) {
            console.log(`⚠️  Found ${existingCount} existing breakfast dishes.`);
            console.log('Do you want to:');
            console.log('  1. Skip seeding (keep existing)');
            console.log('  2. Delete and re-seed');
            console.log('\nTo delete and re-seed, run: FORCE_SEED=true node seed-breakfast.js');

            if (!process.env.FORCE_SEED) {
                console.log('\n✋ Skipping seed. Existing dishes kept.');
                process.exit(0);
            }

            // Delete existing dishes
            await Dish.deleteMany({
                name: { $in: vietnameseBreakfastDishes.map(d => d.name) }
            });
            console.log(`🗑️  Deleted ${existingCount} existing dishes`);
        }

        // Insert new dishes
        const result = await Dish.insertMany(vietnameseBreakfastDishes);
        console.log(`\n🎉 Successfully seeded ${result.length} Vietnamese breakfast dishes!`);

        console.log('\n📋 Seeded dishes:');
        result.forEach((dish, index) => {
            console.log(`   ${index + 1}. ${dish.name} (${dish.category})`);
        });

        console.log('\n✅ Seed completed! You can now:');
        console.log('   1. Restart your Flutter app');
        console.log('   2. Select "Sáng" filter');
        console.log('   3. Spin the wheel with 20 Vietnamese breakfast dishes!');

    } catch (error) {
        console.error('❌ Error seeding dishes:', error);
        process.exit(1);
    } finally {
        await mongoose.connection.close();
        console.log('\n👋 MongoDB connection closed');
    }
}

// Run seed
seedBreakfastDishes();
