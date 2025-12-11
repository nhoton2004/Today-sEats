const mongoose = require('mongoose');
const Dish = require('./models/Dish.model');
require('dotenv').config();

const asianDishes = [
    // Japanese
    { name: 'Sushi', category: 'Món chính', description: 'Sushi Nhật Bản với cá hồi tươi, cơm giấm', mealType: 'lunch', tags: ['châu á', 'nhật bản', 'sushi'], status: 'active', preparationTime: 30, cookingTime: 10, servings: 1 },
    { name: 'Ramen', category: 'Món chính', description: 'Ramen Nhật với nước dùng đậm đà, mì dai', mealType: 'dinner', tags: ['châu á', 'nhật bản', 'ramen'], status: 'active', preparationTime: 15, cookingTime: 30, servings: 1 },
    { name: 'Tempura', category: 'Món phụ', description: 'Tempura chiên giòn với tôm, rau củ', mealType: 'lunch', tags: ['châu á', 'nhật bản', 'chiên'], status: 'active', preparationTime: 20, cookingTime: 15, servings: 2 },
    { name: 'Teriyaki Chicken', category: 'Món chính', description: 'Gà teriyaki với sốt ngọt đậm đà', mealType: 'dinner', tags: ['châu á', 'nhật bản', 'gà'], status: 'active', preparationTime: 15, cookingTime: 20, servings: 2 },

    // Korean
    { name: 'Bibimbap', category: 'Món chính', description: 'Cơm trộn Hàn Quốc với rau, thịt, trứng', mealType: 'lunch', tags: ['châu á', 'hàn quốc', 'cơm'], status: 'active', preparationTime: 25, cookingTime: 15, servings: 1 },
    { name: 'Kimchi Jjigae', category: 'Món chính', description: 'Lẩu kim chi Hàn Quốc cay nồng', mealType: 'dinner', tags: ['châu á', 'hàn quốc', 'lẩu'], status: 'active', preparationTime: 20, cookingTime: 30, servings: 2 },
    { name: 'Korean BBQ', category: 'Món chính', description: 'Thịt nướng Hàn Quốc với kimchi, rau sống', mealType: 'dinner', tags: ['châu á', 'hàn quốc', 'nướng'], status: 'active', preparationTime: 20, cookingTime: 15, servings: 2 },
    { name: 'Tteokbokki', category: 'Món ăn vặt', description: 'Bánh gạo cay Hàn Quốc với sốt đỏ', mealType: 'snack', tags: ['châu á', 'hàn quốc', 'cay'], status: 'active', preparationTime: 10, cookingTime: 15, servings: 2 },

    // Chinese
    { name: 'Dim Sum', category: 'Món phụ', description: 'Dim sum Hồng Kông với há cảo, sủi cảo', mealType: 'breakfast', tags: ['châu á', 'trung quốc', 'hấp'], status: 'active', preparationTime: 30, cookingTime: 20, servings: 1 },
    { name: 'Peking Duck', category: 'Món chính', description: 'Vịt quay Bắc Kinh với da giòn rụm', mealType: 'dinner', tags: ['châu á', 'trung quốc', 'vịt'], status: 'active', preparationTime: 60, cookingTime: 90, servings: 4 },
    { name: 'Kung Pao Chicken', category: 'Món chính', description: 'Gà Kung Pao cay với đậu phộng, ớt', mealType: 'dinner', tags: ['châu á', 'trung quốc', 'cay'], status: 'active', preparationTime: 20, cookingTime: 15, servings: 2 },
    { name: 'Mapo Tofu', category: 'Món chính', description: 'Đậu hũ sốt cay Tứ Xuyên', mealType: 'lunch', tags: ['châu á', 'trung quốc', 'cay'], status: 'active', preparationTime: 15, cookingTime: 20, servings: 2 },

    // Thai
    { name: 'Pad Thai', category: 'Món chính', description: 'Phở xào Thái Lan với tôm, đậu phộng', mealType: 'lunch', tags: ['châu á', 'thái lan', 'xào'], status: 'active', preparationTime: 20, cookingTime: 15, servings: 1 },
    { name: 'Tom Yum', category: 'Món chính', description: 'Súp tôm chua cay Thái Lan thơm lừng', mealType: 'dinner', tags: ['châu á', 'thái lan', 'cay'], status: 'active', preparationTime: 15, cookingTime: 25, servings: 2 },
    { name: 'Green Curry', category: 'Món chính', description: 'Cà ri xanh Thái với gà, rau củ', mealType: 'dinner', tags: ['châu á', 'thái lan', 'cà ri'], status: 'active', preparationTime: 20, cookingTime: 30, servings: 3 },
];

const westernDishes = [
    // American
    { name: 'Burger', category: 'Món chính', description: 'Burger bò với phô mai, rau sống, sốt', mealType: 'lunch', tags: ['âu mỹ', 'mỹ', 'burger'], status: 'active', preparationTime: 15, cookingTime: 15, servings: 1 },
    { name: 'Hot Dog', category: 'Món ăn vặt', description: 'Hot dog với xúc xích, sốt cà, mù tạt', mealType: 'snack', tags: ['âu mỹ', 'mỹ', 'nhanh'], status: 'active', preparationTime: 5, cookingTime: 10, servings: 1 },
    { name: 'Mac and Cheese', category: 'Món chính', description: 'Mì ống phô mai kiểu Mỹ béo ngậy', mealType: 'lunch', tags: ['âu mỹ', 'mỹ', 'phô mai'], status: 'active', preparationTime: 10, cookingTime: 20, servings: 2 },
    { name: 'BBQ Ribs', category: 'Món chính', description: 'Sườn nướng BBQ kiểu Mỹ với sốt đậm đà', mealType: 'dinner', tags: ['âu mỹ', 'mỹ', 'nướng'], status: 'active', preparationTime: 30, cookingTime: 120, servings: 3 },

    // Italian
    { name: 'Pizza Margherita', category: 'Món chính', description: 'Pizza Ý với phô mai mozzarella, cà chua', mealType: 'dinner', tags: ['âu mỹ', 'ý', 'pizza'], status: 'active', preparationTime: 30, cookingTime: 15, servings: 2 },
    { name: 'Spaghetti Carbonara', category: 'Món chính', description: 'Mì Ý Carbonara với thịt xông khói, kem', mealType: 'lunch', tags: ['âu mỹ', 'ý', 'mì'], status: 'active', preparationTime: 15, cookingTime: 20, servings: 2 },
    { name: 'Lasagna', category: 'Món chính', description: 'Lasagna nhiều lớp với sốt thịt, phô mai', mealType: 'dinner', tags: ['âu mỹ', 'ý', 'nướng'], status: 'active', preparationTime: 40, cookingTime: 60, servings: 4 },
    { name: 'Risotto', category: 'Món chính', description: 'Risotto Ý với nấm, phô mai Parmesan', mealType: 'dinner', tags: ['âu mỹ', 'ý', 'cơm'], status: 'active', preparationTime: 20, cookingTime: 30, servings: 2 },

    // French
    { name: 'Croissant', category: 'Bánh/Bánh mì', description: 'Bánh sừng bò Pháp bơ thơm, giòn tan', mealType: 'breakfast', tags: ['âu mỹ', 'pháp', 'bánh'], status: 'active', preparationTime: 120, cookingTime: 20, servings: 1 },
    { name: 'French Onion Soup', category: 'Món chính', description: 'Súp hành tây Pháp với phô mai nướng', mealType: 'dinner', tags: ['âu mỹ', 'pháp', 'súp'], status: 'active', preparationTime: 20, cookingTime: 40, servings: 2 },
    { name: 'Ratatouille', category: 'Món phụ', description: 'Ratatouille với rau củ nướng kiểu Pháp', mealType: 'lunch', tags: ['âu mỹ', 'pháp', 'rau'], status: 'active', preparationTime: 30, cookingTime: 45, servings: 3 },
    { name: 'Beef Steak', category: 'Món chính', description: 'Bít tết bò Âu với khoai tây nghiền', mealType: 'dinner', tags: ['âu mỹ', 'pháp', 'bò'], status: 'active', preparationTime: 15, cookingTime: 20, servings: 1 },

    // British
    { name: 'Fish and Chips', category: 'Món chính', description: 'Cá chiên giòn với khoai tây chiên', mealType: 'lunch', tags: ['âu mỹ', 'anh', 'chiên'], status: 'active', preparationTime: 20, cookingTime: 20, servings: 1 },
    { name: 'Shepherd\'s Pie', category: 'Món chính', description: 'Bánh thịt nướng Anh với khoai tây', mealType: 'dinner', tags: ['âu mỹ', 'anh', 'nướng'], status: 'active', preparationTime: 30, cookingTime: 45, servings: 4 },
    { name: 'English Breakfast', category: 'Món chính', description: 'Bữa sáng Anh với trứng, xúc xích, thịt', mealType: 'breakfast', tags: ['âu mỹ', 'anh', 'sáng'], status: 'active', preparationTime: 15, cookingTime: 20, servings: 1 },
];

async function seedCuisines() {
    try {
        const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/todayseats';
        await mongoose.connect(mongoURI);
        console.log('✅ Connected to MongoDB');

        // Seed Asian dishes
        const asianNames = asianDishes.map(d => d.name);
        const existingAsian = await Dish.countDocuments({ name: { $in: asianNames } });

        if (existingAsian > 0 && !process.env.FORCE_SEED) {
            console.log(`⚠️  Found ${existingAsian} existing Asian dishes. Skipping...`);
        } else {
            if (existingAsian > 0) {
                await Dish.deleteMany({ name: { $in: asianNames } });
            }
            const asianResult = await Dish.insertMany(asianDishes);
            console.log(`\n🍱 Seeded ${asianResult.length} Asian dishes!`);
        }

        // Seed Western dishes
        const westernNames = westernDishes.map(d => d.name);
        const existingWestern = await Dish.countDocuments({ name: { $in: westernNames } });

        if (existingWestern > 0 && !process.env.FORCE_SEED) {
            console.log(`⚠️  Found ${existingWestern} existing Western dishes. Skipping...`);
        } else {
            if (existingWestern > 0) {
                await Dish.deleteMany({ name: { $in: westernNames } });
            }
            const westernResult = await Dish.insertMany(westernDishes);
            console.log(`\n🍕 Seeded ${westernResult.length} Western dishes!`);
        }

        // Summary by cuisine
        const vietnameseCount = await Dish.countDocuments({ tags: { $in: ['việt nam'] } });
        const asianCount = await Dish.countDocuments({ tags: { $in: ['châu á'] } });
        const westernCount = await Dish.countDocuments({ tags: { $in: ['âu mỹ'] } });

        console.log('\n📊 Database Summary by Cuisine:');
        console.log(`   🇻🇳 Vietnamese: ${vietnameseCount} dishes`);
        console.log(`   🌏 Asian: ${asianCount} dishes`);
        console.log(`   🌍 Western: ${westernCount} dishes`);
        console.log(`   📦 Total: ${vietnameseCount + asianCount + westernCount} dishes`);

        console.log('\n✅ All cuisines seeded! Test the cuisine filters now!');

    } catch (error) {
        console.error('❌ Error:', error);
        process.exit(1);
    } finally {
        await mongoose.connection.close();
        console.log('\n👋 MongoDB connection closed');
    }
}

seedCuisines();
