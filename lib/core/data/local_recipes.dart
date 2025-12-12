
class Recipe {
  final String name;
  final List<String> requiredIngredients; // Must have (or highly weighted)
  final List<String> optionalIngredients; // Bonus match
  final int cookingTime; // minutes
  final int servings;
  final List<Map<String, dynamic>> cookingInstructions;
  final List<String> additionalIngredients; // Display only (condiments, etc)

  const Recipe({
    required this.name,
    required this.requiredIngredients,
    this.optionalIngredients = const [],
    required this.cookingTime,
    required this.servings,
    required this.cookingInstructions,
    this.additionalIngredients = const [],
  });
}

// Helper to standardizing ingredients for easier matching
// We will simple strings for keys.
final List<Recipe> kLocalRecipes = [
  // 1. Trứng chiên hành
  const Recipe(
    name: 'Trứng chiên hành',
    requiredIngredients: ['trứng', 'hành lá'],
    optionalIngredients: ['nước mắm', 'tiêu', 'dầu ăn'],
    cookingTime: 10,
    servings: 2,
    additionalIngredients: ['Nước mắm', 'Gia vị cơ bản'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Đập trứng ra bát, cắt nhỏ hành lá, nêm chút nước mắm và tiêu.', 'duration': 2},
      {'step': 2, 'instruction': 'Đánh đều trứng.', 'duration': 1},
      {'step': 3, 'instruction': 'Làm nóng chảo dầu, đổ trứng vào chiên vàng đều 2 mặt.', 'duration': 5},
    ],
  ),
  // 2. Canh cà chua trứng
  const Recipe(
    name: 'Canh cà chua trứng',
    requiredIngredients: ['trứng', 'cà chua', 'hành lá'],
    optionalIngredients: ['ngò rí', 'hành tím'],
    cookingTime: 15,
    servings: 3,
    additionalIngredients: ['Dầu ăn', 'Muối', 'Hạt nêm'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Cà chua thái múi cau. Trứng đánh tan.', 'duration': 3},
      {'step': 2, 'instruction': 'Phi thơm đầu hành, xào cà chua cho mềm.', 'duration': 3},
      {'step': 3, 'instruction': 'Thêm nước sôi, nêm nếm gia vị.', 'duration': 5},
      {'step': 4, 'instruction': 'Đổ từ từ trứng vào, khuấy nhẹ tạo vân. Rắc hành lá tắt bếp.', 'duration': 2},
    ],
  ),
  // 3. Rau muống xào tỏi
  const Recipe(
    name: 'Rau muống xào tỏi',
    requiredIngredients: ['rau muống', 'tỏi'],
    optionalIngredients: ['chanh', 'ớt'],
    cookingTime: 10,
    servings: 2,
    additionalIngredients: ['Dầu ăn', 'Nước mắm', 'Đường'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Rau muống nhặt sạch, luộc sơ qua nước sôi rồi ngâm nước đá.', 'duration': 5},
      {'step': 2, 'instruction': 'Phi thơm nhiều tỏi đập dập.', 'duration': 1},
      {'step': 3, 'instruction': 'Cho rau vào xào lửa lớn nhanh tay, nêm gia vị vừa ăn.', 'duration': 3},
    ],
  ),
  // 4. Thịt kho tàu
  const Recipe(
    name: 'Thịt kho tàu',
    requiredIngredients: ['thịt ba chỉ', 'trứng'],
    optionalIngredients: ['nước dừa'],
    cookingTime: 60,
    servings: 4,
    additionalIngredients: ['Nước mắm', 'Đường', 'Hành tím', 'Tỏi'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Thịt cắt miếng to, ướp hành tỏi, nước mắm, đường.', 'duration': 15},
      {'step': 2, 'instruction': 'Luộc trứng, bóc vỏ.', 'duration': 10},
      {'step': 3, 'instruction': 'Thắng nước màu, xào săn thịt.', 'duration': 5},
      {'step': 4, 'instruction': 'Đổ nước dừa ngập thịt, kho lửa nhỏ đến khi mềm. Thêm trứng vào kho cùng.', 'duration': 40},
    ],
  ),
  // 5. Đậu phụ sốt cà chua
  const Recipe(
    name: 'Đậu phụ sốt cà chua',
    requiredIngredients: ['đậu phụ', 'cà chua', 'hành lá'],
    optionalIngredients: ['hành tím'],
    cookingTime: 20,
    servings: 3,
    additionalIngredients: ['Dầu ăn', 'Nước mắm'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Đậu phụ cắt khối vuông, chiên vàng.', 'duration': 10},
      {'step': 2, 'instruction': 'Cà chua thái hạt lựu, xào mềm thành sốt.', 'duration': 5},
      {'step': 3, 'instruction': 'Cho đậu vào sốt, rim nhỏ lửa 5 phút. Rắc hành lá.', 'duration': 5},
    ],
  ),
  // 6. Gà kho gừng
  const Recipe(
    name: 'Gà kho gừng',
    requiredIngredients: ['thịt gà', 'gừng'],
    optionalIngredients: ['hành tím', 'tỏi', 'ớt'],
    cookingTime: 30,
    servings: 4,
    additionalIngredients: ['Nước mắm', 'Đường', 'Dầu ăn'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Gà chặt miếng, ướp gừng thái sợi và gia vị.', 'duration': 15},
      {'step': 2, 'instruction': 'Xào săn gà với chút dầu và đường thắng màu.', 'duration': 5},
      {'step': 3, 'instruction': 'Thêm xíu nước, kho lửa nhỏ đến khi keo lại.', 'duration': 20},
    ],
  ),
  // 7. Canh bầu nấu tôm
  const Recipe(
    name: 'Canh bầu nấu tôm',
    requiredIngredients: ['bầu', 'tôm'],
    optionalIngredients: ['hành lá', 'ngò'],
    cookingTime: 15,
    servings: 4,
    additionalIngredients: ['Gia vị'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Bầu gọt vỏ, thái sợi hoặc miếng. Tôm băm nhỏ hoặc giã dập.', 'duration': 5},
      {'step': 2, 'instruction': 'Xào sơ tôm, thêm nước đun sôi.', 'duration': 5},
      {'step': 3, 'instruction': 'Thả bầu vào, sôi lại thì tắt bếp ngay để bầu giòn.', 'duration': 3},
    ],
  ),
  // 8. Mực xào cần tỏi
  const Recipe(
    name: 'Mực xào cần tỏi',
    requiredIngredients: ['mực', 'cần tây', 'tỏi tây', 'hành tây'],
    optionalIngredients: ['cà chua', 'dứa'],
    cookingTime: 15,
    servings: 3,
    additionalIngredients: ['Tiêu', 'Gia vị'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Mực làm sạch, khía vảy rồng, trần sơ.', 'duration': 5},
      {'step': 2, 'instruction': 'Các loại rau rửa sạch cắt khúc.', 'duration': 3},
      {'step': 3, 'instruction': 'Xào mực lửa lớn, để riêng. Xào rau chín tới rồi trộn chung.', 'duration': 5},
    ],
  ),
  // 9. Bò xào thiên lý
  const Recipe(
    name: 'Bò xào thiên lý',
    requiredIngredients: ['thịt bò', 'hoa thiên lý'],
    optionalIngredients: ['tỏi'],
    cookingTime: 15,
    servings: 3,
    additionalIngredients: ['Dầu hào', 'Tiêu'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Bò thái mỏng, ướp dầu hào, tỏi, tiêu.', 'duration': 10},
      {'step': 2, 'instruction': 'Xào bò tái, trút ra đĩa.', 'duration': 3},
      {'step': 3, 'instruction': 'Xào hoa thiên lý chín tới, đổ bò vào đảo nhanh.', 'duration': 2},
    ],
  ),
  // 10. Nem rán (Chả giò)
  const Recipe(
    name: 'Nem rán (Chả giò)',
    requiredIngredients: ['thịt lợn xay', 'trứng', 'miến', 'mộc nhĩ', 'bánh đa nem'],
    optionalIngredients: ['cà rốt', 'hành tây', 'giá đỗ'],
    cookingTime: 45,
    servings: 4,
    additionalIngredients: ['Dầu ăn', 'Gia vị'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Ngâm nở miến, mộc nhĩ rồi thái nhỏ. Trộn đều tất cả nguyên liệu làm nhân.', 'duration': 15},
      {'step': 2, 'instruction': 'Cuốn nem đều tay.', 'duration': 15},
      {'step': 3, 'instruction': 'Chiên ngập dầu lửa vừa đến khi vàng giòn.', 'duration': 15},
    ],
  ),
  // 11. Sườn xào chua ngọt
  const Recipe(
    name: 'Sườn xào chua ngọt',
    requiredIngredients: ['sườn non', 'cà chua', 'hành tây'],
    optionalIngredients: ['ớt chuông', 'dứa'],
    cookingTime: 40,
    servings: 3,
    additionalIngredients: ['Giấm/Chanh', 'Đường', 'Tương ớt'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Sườn chặt nhỏ, luộc sơ, rán vàng.', 'duration': 15},
      {'step': 2, 'instruction': 'Pha sốt chua ngọt (mắm, đường, giấm, tương ớt).', 'duration': 5},
      {'step': 3, 'instruction': 'Phi thơm hành, đổ sốt và sườn vào rim đến khi sệt.', 'duration': 15},
    ],
  ),
  // 12. Cá kho tộ
  const Recipe(
    name: 'Cá kho tộ',
    requiredIngredients: ['cá (lóc/trê/basa)', 'thịt ba chỉ', 'hành tím'],
    optionalIngredients: ['ớt', 'tiêu xanh'],
    cookingTime: 45,
    servings: 4,
    additionalIngredients: ['Nước màu', 'Nước mắm'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Cá làm sạch, ướp mắm, tiêu, hành tím 30p.', 'duration': 30},
      {'step': 2, 'instruction': 'Lót thịt ba chỉ dưới đáy nồi, xếp cá lên.', 'duration': 5},
      {'step': 3, 'instruction': 'Kho lửa riu riu, thêm nước màu, đến khi nước keo lại.', 'duration': 30},
    ],
  ),
   // 13. Canh cua rau đay
  const Recipe(
    name: 'Canh cua rau đay',
    requiredIngredients: ['cua đồng', 'rau đay', 'mùng tơi'],
    optionalIngredients: ['mướp'],
    cookingTime: 30,
    servings: 4,
    additionalIngredients: ['Mắm tôm (tuỳ chọn)'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Cua giã/xay nhỏ, lọc lấy nước cốt. Gạch cua khều riêng.', 'duration': 15},
      {'step': 2, 'instruction': 'Đun nước cua lửa nhỏ để đóng tảng, vớt thịt cua ra.', 'duration': 10},
      {'step': 3, 'instruction': 'Cho rau thái nhỏ vào nước canh, sôi bùng thì tắt bếp.', 'duration': 5},
    ],
  ),
  // 14. Thịt luộc cà pháo
  const Recipe(
    name: 'Thịt luộc cà pháo',
    requiredIngredients: ['thịt ba chỉ', 'cà pháo'],
    optionalIngredients: ['rau sống', 'dưa chuột'],
    cookingTime: 20,
    servings: 3,
    additionalIngredients: ['Mắm tôm', 'Chanh'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Thịt rửa sạch, buộc dây (nếu muốn tròn), luộc chín với xíu muối.', 'duration': 20},
      {'step': 2, 'instruction': 'Thái mỏng thịt.', 'duration': 5},
      {'step': 3, 'instruction': 'Pha mắm tôm chanh ớt, ăn kèm cà pháo.', 'duration': 5},
    ],
  ),
  // 15. Bún chả (Tại gia)
  const Recipe(
    name: 'Bún chả (Đơn giản)',
    requiredIngredients: ['thịt ba chỉ', 'thịt băm', 'bún'],
    optionalIngredients: ['đu đủ xanh', 'cà rốt', 'rau sống'],
    cookingTime: 45,
    servings: 4,
    additionalIngredients: ['Nước mắm', 'Đường', 'Giấm'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Ướp thịt với mắm, đường, hành khô, nước hàng.', 'duration': 20},
      {'step': 2, 'instruction': 'Nướng thịt bằng nồi chiên không dầu hoặc than hoa.', 'duration': 15},
      {'step': 3, 'instruction': 'Pha nước chấm chua ngọt, thả dưa góp vào.', 'duration': 10},
    ],
  ),
  // 16. Salad ức gà
  const Recipe(
    name: 'Salad ức gà',
    requiredIngredients: ['ức gà', 'xà lách', 'cà chua bi'],
    optionalIngredients: ['dưa chuột', 'ngô ngọt'],
    cookingTime: 15,
    servings: 1,
    additionalIngredients: ['Sốt mè rang', 'Dầu oliu'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Ức gà luộc hoặc áp chảo, xé nhỏ hoặc thái miếng.', 'duration': 10},
      {'step': 2, 'instruction': 'Rau củ rửa sạch, thái vừa ăn.', 'duration': 5},
      {'step': 3, 'instruction': 'Trộn đều với sốt mè rang.', 'duration': 2},
    ],
  ),
  // 17. Cháo gà
  const Recipe(
    name: 'Cháo gà',
    requiredIngredients: ['gạo', 'thịt gà'],
    optionalIngredients: ['hành lá', 'tía tô', 'hành phi'],
    cookingTime: 45,
    servings: 4,
    additionalIngredients: ['Tiêu', 'Gia vị'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Gạo rang sơ hoặc vo sạch. Gà luộc lấy nước dùng.', 'duration': 10},
      {'step': 2, 'instruction': 'Nấu cháo bằng nước luộc gà cho nhừ. Thịt gà xé phay.', 'duration': 30},
      {'step': 3, 'instruction': 'Múc cháo, rắc thịt gà và rau thơm lên.', 'duration': 5},
    ],
  ),
  // 18. Mướp đắng xào trứng
  const Recipe(
    name: 'Mướp đắng (Khổ qua) xào trứng',
    requiredIngredients: ['mướp đắng', 'trứng'],
    optionalIngredients: ['hành tím'],
    cookingTime: 15,
    servings: 2,
    additionalIngredients: ['Dầu ăn', 'Gia vị'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Mướp đắng bỏ ruột, thái lát mỏng, ngâm nước muối 5p.', 'duration': 5},
      {'step': 2, 'instruction': 'Xào mướp đắng chín tới.', 'duration': 5},
      {'step': 3, 'instruction': 'Đổ trứng đánh tan vào đảo đều cho bám quanh mướp.', 'duration': 3},
    ],
  ),
  // 19. Canh kim chi thịt lợn
  const Recipe(
    name: 'Canh kim chi',
    requiredIngredients: ['kim chi', 'thịt ba chỉ', 'đậu phụ'],
    optionalIngredients: ['hành boaro', 'nấm kim châm'],
    cookingTime: 20,
    servings: 3,
    additionalIngredients: ['Tương ớt Hàn Quốc', 'Dầu ăn'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Xào săn thịt ba chỉ và kim chi.', 'duration': 5},
      {'step': 2, 'instruction': 'Thêm nước, đun sôi 10p cho kim chi mềm.', 'duration': 10},
      {'step': 3, 'instruction': 'Thả đậu phụ, nấm, hành vào đun thêm 2p.', 'duration': 2},
    ],
  ),
   // 20. Bò kho
  const Recipe(
    name: 'Bò kho',
    requiredIngredients: ['thịt bò (nạm/gân)', 'cà rốt'],
    optionalIngredients: ['sả', 'hoa hồi', 'quế'],
    cookingTime: 90,
    servings: 4,
    additionalIngredients: ['Bột bò kho', 'Bánh mì/Hủ tiếu'],
    cookingInstructions: [
      {'step': 1, 'instruction': 'Bò ướp gói gia vị bò kho, sả băm.', 'duration': 20},
      {'step': 2, 'instruction': 'Xào thịt săn, đổ nước ngập hầm mềm (khoảng 1 tiếng).', 'duration': 60},
      {'step': 3, 'instruction': 'Thêm cà rốt vào nấu thêm 15p.', 'duration': 15},
    ],
  ),
];
