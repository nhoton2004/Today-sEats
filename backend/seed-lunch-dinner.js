const mongoose = require('mongoose');
const Dish = require('./models/Dish.model');
require('dotenv').config();

const vietnameseLunchDishes = [
    { name: 'Cơm Gà Hải Nam', category: 'Món chính', description: 'Cơm gà Hải Nam với thịt gà luộc mềm, cơm thơm bơ', mealType: 'lunch', tags: ['việt nam', 'cơm', 'trưa', 'gà'], status: 'active', preparationTime: 20, cookingTime: 40, servings: 1 },
    { name: 'Cơm Chiên Dương Châu', category: 'Món chính', description: 'Cơm chiên với tôm, xúc xích, trứng, rau củ', mealType: 'lunch', tags: ['việt nam', 'cơm', 'trưa', 'chiên'], status: 'active', preparationTime: 15, cookingTime: 15, servings: 1 },
    { name: 'Bún Chả Hà Nội', category: 'Món chính', description: 'Bún chả với thịt nướng thơm, nước mắm chua ngọt', mealType: 'lunch', tags: ['việt nam', 'bún', 'trưa', 'nướng'], status: 'active', preparationTime: 30, cookingTime: 20, servings: 1 },
    { name: 'Mỳ Xào Giòn', category: 'Món chính', description: 'Mỳ xào giòn với thập cẩm hải sản, rau củ', mealType: 'lunch', tags: ['việt nam', 'mỳ', 'trưa', 'xào'], status: 'active', preparationTime: 15, cookingTime: 15, servings: 1 },
    { name: 'Canh Chua Cá', category: 'Món chính', description: 'Canh chua cá lóc với dứa, cà chua, rau thơm', mealType: 'lunch', tags: ['việt nam', 'canh', 'trưa', 'cá'], status: 'active', preparationTime: 20, cookingTime: 25, servings: 2 },
    { name: 'Gỏi Cuốn', category: 'Món phụ', description: 'Gỏi cuốn tươi với tôm, thịt, rau sống, bún', mealType: 'lunch', tags: ['việt nam', 'cuốn', 'trưa', 'nhẹ'], status: 'active', preparationTime: 25, cookingTime: 5, servings: 1 },
    { name: 'Bánh Xèo', category: 'Món chính', description: 'Bánh xèo giòn rụm với tôm, thịt, giá đỗ', mealType: 'lunch', tags: ['việt nam', 'bánh', 'trưa', 'miền nam'], status: 'active', preparationTime: 20, cookingTime: 15, servings: 1 },
    { name: 'Cá Kho Tộ', category: 'Món chính', description: 'Cá kho tộ đậm đà với nước dừa, tiêu', mealType: 'lunch', tags: ['việt nam', 'cá', 'trưa', 'kho'], status: 'active', preparationTime: 15, cookingTime: 35, servings: 2 },
    { name: 'Thịt Kho Tàu', category: 'Món chính', description: 'Thịt kho tàu với trứng, nước dừa thơm béo', mealType: 'lunch', tags: ['việt nam', 'thịt', 'trưa', 'kho'], status: 'active', preparationTime: 15, cookingTime: 40, servings: 2 },
    { name: 'Bún Thịt Nướng', category: 'Món chính', description: 'Bún thịt nướng với chả giò, rau sống', mealType: 'lunch', tags: ['việt nam', 'bún', 'trưa', 'nướng'], status: 'active', preparationTime: 25, cookingTime: 20, servings: 1 },
    { name: 'Cơm Sườn Bì Chả', category: 'Món chính', description: 'Cơm với sườn nướng, bì, chả trứng hấp', mealType: 'lunch', tags: ['việt nam', 'cơm', 'trưa', 'miền nam'], status: 'active', preparationTime: 25, cookingTime: 30, servings: 1 },
    { name: 'Lẩu Thái', category: 'Món chính', description: 'Lẩu Thái chua cay với hải sản, rau củ', mealType: 'lunch', tags: ['việt nam', 'lẩu', 'trưa', 'thái'], status: 'active', preparationTime: 30, cookingTime: 20, servings: 3 },
    { name: 'Bò Lúc Lắc', category: 'Món chính', description: 'Bò lúc lắc với khoai tây chiên, sốt tiêu đen', mealType: 'lunch', tags: ['việt nam', 'bò', 'trưa', 'xào'], status: 'active', preparationTime: 20, cookingTime: 15, servings: 2 },
    { name: 'Gà Rán', category: 'Món chính', description: 'Gà rán giòn rụm, thơm phức gia vị', mealType: 'lunch', tags: ['việt nam', 'gà', 'trưa', 'rán'], status: 'active', preparationTime: 30, cookingTime: 20, servings: 2 },
    { name: 'Cơm Rang Thập Cẩm', category: 'Món chính', description: 'Cơm rang với tôm, thịt, trứng, rau củ', mealType: 'lunch', tags: ['việt nam', 'cơm', 'trưa', 'rang'], status: 'active', preparationTime: 15, cookingTime: 15, servings: 1 },
];

const vietnameseDinnerDishes = [
    { name: 'Lẩu Hải Sản', category: 'Món chính', description: 'Lẩu hải sản tươi ngon với tôm, mực, cá', mealType: 'dinner', tags: ['việt nam', 'lẩu', 'tối', 'hải sản'], status: 'active', preparationTime: 30, cookingTime: 20, servings: 4 },
    { name: 'Bò Nướng Lá Lốt', category: 'Món chính', description: 'Bò cuộn lá lốt nướng thơm lừng', mealType: 'dinner', tags: ['việt nam', 'bò', 'tối', 'nướng'], status: 'active', preparationTime: 25, cookingTime: 15, servings: 2 },
    { name: 'Gà Kho Gừng', category: 'Món chính', description: 'Gà kho gừng đậm đà, thơm cay nồng', mealType: 'dinner', tags: ['việt nam', 'gà', 'tối', 'kho'], status: 'active', preparationTime: 20, cookingTime: 35, servings: 3 },
    { name: 'Cá Thu Kho', category: 'Món chính', description: 'Cá thu kho tiêu với nước dừa, thơm béo', mealType: 'dinner', tags: ['việt nam', 'cá', 'tối', 'kho'], status: 'active', preparationTime: 15, cookingTime: 30, servings: 2 },
    { name: 'Tôm Rang Muối', category: 'Món chính', description: 'Tôm rang muối ớt giòn tan, thơm nức', mealType: 'dinner', tags: ['việt nam', 'tôm', 'tối', 'rang'], status: 'active', preparationTime: 15, cookingTime: 10, servings: 2 },
    { name: 'Sườn Nướng BBQ', category: 'Món chính', description: 'Sườn nướng BBQ kiểu Mỹ, sốt đậm đà', mealType: 'dinner', tags: ['việt nam', 'sườn', 'tối', 'nướng'], status: 'active', preparationTime: 30, cookingTime: 25, servings: 2 },
    { name: 'Canh Bí Đỏ', category: 'Món phụ', description: 'Canh bí đỏ nấu với tôm, thanh mát', mealType: 'dinner', tags: ['việt nam', 'canh', 'tối', 'nhẹ'], status: 'active', preparationTime: 15, cookingTime: 20, servings: 3 },
    { name: 'Thịt Rim Mắm', category: 'Món chính', description: 'Thịt rim mắm với nước dừa, thơm đậm đà', mealType: 'dinner', tags: ['việt nam', 'thịt', 'tối', 'rim'], status: 'active', preparationTime: 20, cookingTime: 45, servings: 2 },
    { name: 'Cá Chiên Sốt Cà', category: 'Món chính', description: 'Cá chiên giòn với sốt cà chua chua ngọt', mealType: 'dinner', tags: ['việt nam', 'cá', 'tối', 'chiên'], status: 'active', preparationTime: 15, cookingTime: 20, servings: 2 },
    { name: 'Rau Muống Xào Tỏi', category: 'Món phụ', description: 'Rau muống xào tỏi giòn ngon, đơn giản', mealType: 'dinner', tags: ['việt nam', 'rau', 'tối', 'xào'], status: 'active', preparationTime: 5, cookingTime: 5, servings: 2 },
    { name: 'Đậu Hũ Sốt Cà', category: 'Món chính', description: 'Đậu hũ chiên sốt cà chua, chay ngon', mealType: 'dinner', tags: ['việt nam', 'đậu', 'tối', 'chay'], status: 'active', preparationTime: 15, cookingTime: 15, servings: 2 },
    { name: 'Gà Xào Sả Ớt', category: 'Món chính', description: 'Gà xào sả ớt thơm cay, hấp dẫn', mealType: 'dinner', tags: ['việt nam', 'gà', 'tối', 'xào'], status: 'active', preparationTime: 20, cookingTime: 15, servings: 2 },
    { name: 'Bò Xào Rau Củ', category: 'Món chính', description: 'Bò xào với các loại rau củ tươi ngon', mealType: 'dinner', tags: ['việt nam', 'bò', 'tối', 'xào'], status: 'active', preparationTime: 20, cookingTime: 15, servings: 2 },
    { name: 'Mực Xào Sa Tế', category: 'Món chính', description: 'Mực xào sa tế cay nồng, thơm lừng', mealType: 'dinner', tags: ['việt nam', 'mực', 'tối', 'xào'], status: 'active', preparationTime: 15, cookingTime: 10, servings: 2 },
    { name: 'Cơm Niêu Sài Gòn', category: 'Món chính', description: 'Cơm niêu với lạp xưởng, tôm khô thơm bùi', mealType: 'dinner', tags: ['việt nam', 'cơm', 'tối', 'niêu'], status: 'active', preparationTime: 20, cookingTime: 30, servings: 2 },
];

async function seedAllMeals() {
    try {
        const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/todayseats';
        await mongoose.connect(mongoURI);
        console.log('✅ Connected to MongoDB');

        // Seed lunch dishes
        const lunchNames = vietnameseLunchDishes.map(d => d.name);
        const existingLunch = await Dish.countDocuments({ name: { $in: lunchNames } });

        if (existingLunch > 0 && !process.env.FORCE_SEED) {
            console.log(`⚠️  Found ${existingLunch} existing lunch dishes. Skipping...`);
        } else {
            if (existingLunch > 0) {
                await Dish.deleteMany({ name: { $in: lunchNames } });
            }
            const lunchResult = await Dish.insertMany(vietnameseLunchDishes);
            console.log(`\n🍱 Seeded ${lunchResult.length} lunch dishes!`);
        }

        // Seed dinner dishes
        const dinnerNames = vietnameseDinnerDishes.map(d => d.name);
        const existingDinner = await Dish.countDocuments({ name: { $in: dinnerNames } });

        if (existingDinner > 0 && !process.env.FORCE_SEED) {
            console.log(`⚠️  Found ${existingDinner} existing dinner dishes. Skipping...`);
        } else {
            if (existingDinner > 0) {
                await Dish.deleteMany({ name: { $in: dinnerNames } });
            }
            const dinnerResult = await Dish.insertMany(vietnameseDinnerDishes);
            console.log(`\n🌙 Seeded ${dinnerResult.length} dinner dishes!`);
        }

        // Summary
        const totalBreakfast = await Dish.countDocuments({ mealType: 'breakfast' });
        const totalLunch = await Dish.countDocuments({ mealType: 'lunch' });
        const totalDinner = await Dish.countDocuments({ mealType: 'dinner' });

        console.log('\n📊 Database Summary:');
        console.log(`   ☀️  Breakfast (Sáng): ${totalBreakfast} dishes`);
        console.log(`   🌤️  Lunch (Trưa): ${totalLunch} dishes`);
        console.log(`   🌙 Dinner (Tối): ${totalDinner} dishes`);
        console.log(`   📦 Total: ${totalBreakfast + totalLunch + totalDinner} dishes`);

        console.log('\n✅ All meals seeded! Test the filters now!');

    } catch (error) {
        console.error('❌ Error:', error);
        process.exit(1);
    } finally {
        await mongoose.connection.close();
        console.log('\n👋 MongoDB connection closed');
    }
}

seedAllMeals();
