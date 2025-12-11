# Luồng Offline/Cache - Today's Eats ✅

**Ngày implement:** 11/12/2025  
**Trạng thái:** ✅ **ĐÃ HOÀN THÀNH**

---

## 📊 Flowchart (Theo sơ đồ của bạn)

```
Mở app → vào màn cần dữ liệu (vd: Home / Favorites / Dishes)
  ↓
Kiểm tra trạng thái mạng trên app
  ├─ Có Internet
  │     ↓
  │     Gửi request lên Backend để lấy dữ liệu mới
  │     ↓
  │     Nhận dữ liệu từ Backend (MongoDB)
  │     ↓
  │     Lưu dữ liệu vào cache local (SharedPreferences)
  │     ↓
  │     Hiển thị dữ liệu lên UI
  │
  └─ Không có Internet
        ↓
        Kiểm tra cache local
        ├─ Có dữ liệu cache
        │     ↓
        │     Load từ cache → Hiển thị lên UI
        │     ↓
        │     Kèm thông báo: "Đang xem dữ liệu offline"
        │
        └─ Không có cache
              ↓
              Hiển thị thông báo:
              "Không có dữ liệu để hiển thị. Vui lòng kết nối Internet để tải dữ liệu."
```

---

## 🎯 Tại sao cần Offline/Cache?

✅ **UX tốt hơn:**
- App vẫn hoạt động khi mất mạng
- Load dữ liệu nhanh hơn (từ cache)
- Tiết kiệm băng thông

✅ **Giáo viên thường hỏi:**
- "App có hoạt động offline không?"
- "Dữ liệu được lưu ở đâu khi offline?"
- "Làm sao biết dữ liệu offline hay online?"

---

## 🔧 Implementation

### 1. ConnectivityService - Check network status
**File:** [`lib/core/services/connectivity_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/connectivity_service.dart)

**Features:**
- ✅ `hasInternetConnection()` - Check có mạng không
- ✅ `onConnectivityChanged` - Stream theo dõi thay đổi
- ✅ `getCurrentConnectivity()` - Trạng thái hiện tại
- ✅ `isConnectedVia()` - Check loại kết nối (WiFi/Mobile)

**Usage:**
```dart
final connectivityService = ConnectivityService();

// Check connection
final hasInternet = await connectivityService.hasInternetConnection();
if (hasInternet) {
  print('✅ Có kết nối Internet');
} else {
  print('❌ Không có kết nối');
}

// Listen to changes
connectivityService.onConnectivityChanged.listen((results) {
  if (results.contains(ConnectivityResult.mobile) || 
      results.contains(ConnectivityResult.wifi)) {
    print('✅ Connected to Internet');
  } else {
    print('❌ Lost connection');
  }
});
```

---

### 2. CacheService - Local data storage
**File:** [`lib/core/services/cache_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/cache_service.dart)

**Features:**
- ✅ `saveDishesCache()` - Lưu danh sách món
- ✅ `getCachedDishes()` - Lấy món từ cache
- ✅ `saveFavoritesCache()` - Lưu favorites
- ✅ `getCachedFavorites()` - Lấy favorites từ cache
- ✅ `saveUserStatsCache()` - Lưu thống kê user
- ✅ `getCachedUserStats()` - Lấy thống kê từ cache
- ✅ `isCacheStale()` - Check cache cũ (> 24h)
- ✅ `clearAllCache()` - Xóa toàn bộ cache
- ✅ `getCacheInfo()` - Thông tin cache

**Usage:**
```dart
final cacheService = CacheService();

// Save to cache
await cacheService.saveDishesCache(dishes);
print('✅ Cached ${dishes.length} dishes');

// Load from cache
final cachedDishes = await cacheService.getCachedDishes();
if (cachedDishes != null) {
  print('📦 Loaded ${cachedDishes.length} dishes from cache');
} else {
  print('📭 No cache available');
}

// Check if stale
final isStale = await cacheService.isCacheStale();
if (isStale) {
  print('⏰ Cache is old, should refresh');
}
```

---

## 🔄 Data Flow with Cache

### **Online Flow (Có Internet)**

```dart
Future<void> _loadDishes() async {
  final connectivityService = ConnectivityService();
  final cacheService = CacheService();

  // 1. Check network
  final hasInternet = await connectivityService.hasInternetConnection();

  if (hasInternet) {
    // 2. Load from API
    try {
      setState(() => _isLoading = true);
      
      final dishes = await _apiService.getDishes();
      
      // 3. Save to cache
      await cacheService.saveDishesCache(dishes);
      
      // 4. Update UI
      setState(() {
        _dishes = dishes;
        _isLoading = false;
      });
      
      print('✅ Loaded ${dishes.length} dishes from server');
      
    } catch (e) {
      setState(() => _isLoading = false);
      ErrorHandler.showError(context, error: e);
    }
  } else {
    // No internet → fallback to cache
    await _loadFromCache();
  }
}
```

---

### **Offline Flow (Không có Internet)**

```dart
Future<void> _loadFromCache() async {
  final cacheService = CacheService();

  setState(() => _isLoading = true);

  // 1. Try to load from cache
  final cachedDishes = await cacheService.getCachedDishes();

  if (cachedDishes != null && cachedDishes.isNotEmpty) {
    // 2. Cache available → show it
    setState(() {
      _dishes = cachedDishes;
      _isLoading = false;
    });

    // 3. Show offline indicator
    ErrorHandler.showWarning(
      context,
      message: '📡 Đang xem dữ liệu offline',
    );

    print('📦 Loaded ${cachedDishes.length} dishes from cache');
    
  } else {
    // 4. No cache → show empty state
    setState(() => _isLoading = false);

    ErrorHandler.showError(
      context,
      error: Exception('No cache'),
      customMessage: 'Không có dữ liệu để hiển thị. Vui lòng kết nối Internet để tải dữ liệu.',
    );
  }
}
```

---

### **Smart Load (Online-first với fallback)**

```dart
Future<void> _smartLoadDishes() async {
  final connectivityService = ConnectivityService();
  final cacheService = CacheService();

  setState(() => _isLoading = true);

  final hasInternet = await connectivityService.hasInternetConnection();

  if (hasInternet) {
    // Try online first
    try {
      final dishes = await _apiService.getDishes();
      await cacheService.saveDishesCache(dishes);
      
      setState(() {
        _dishes = dishes;
        _isLoading = false;
      });
      
    } catch (e) {
      // API failed → fallback to cache
      print('⚠️ API failed, loading from cache...');
      await _loadFromCache();
    }
  } else {
    // No internet → load cache immediately
    await _loadFromCache();
  }
}
```

---

## 🎨 UI Updates

### Offline Indicator

```dart
// At top of screen
if (!_hasInternet) {
  Container(
    color: Colors.orange,
    padding: EdgeInsets.all(8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text(
          '📡 Đang xem dữ liệu offline',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    ),
  )
}
```

### Pull-to-Refresh (only when online)

```dart
RefreshIndicator(
  onRefresh: () async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      await _loadDishes();  // Load from API
    } else {
      ErrorHandler.showWarning(
        context,
        message: 'Không có kết nối Internet để làm mới',
      );
    }
  },
  child: ListView(...),
)
```

### Cache Age Indicator

```dart
FutureBuilder<DateTime?>(
  future: _cacheService.getLastUpdateTime(),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      final age = DateTime.now().difference(snapshot.data!);
      final hours = age.inHours;
      
      return Text(
        'Cập nhật ${hours}h trước',
        style: TextStyle(fontSize: 10, color: Colors.grey),
      );
    }
    return SizedBox.shrink();
  },
)
```

---

## 📊 Cache Strategy

### Cache Duration

| Data Type | Cache Duration | Update Strategy |
|-----------|---------------|-----------------|
| **Dishes** | 24 hours | Online-first |
| **Favorites** | 12 hours | Online-first |
| **User Stats** | 6 hours | Online-first |

### When to Refresh

```dart
Future<bool> shouldRefreshCache() async {
  // 1. Check if online
  final hasInternet = await _connectivityService.hasInternetConnection();
  if (!hasInternet) return false;

  // 2. Check cache age
  final isStale = await _cacheService.isCacheStale(
    maxAge: Duration(hours: 24),
  );

  return isStale;
}
```

---

## 🔄 Complete Example: DishesScreen with Cache

```dart
class DishesScreen extends StatefulWidget {
  const DishesScreen({super.key});

  @override
  State<DishesScreen> createState() => _DishesScreenState();
}

class _DishesScreenState extends State<DishesScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final CacheService _cacheService = CacheService();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _dishes = [];
  bool _isLoading = false;
  bool _hasInternet = true;
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _loadDishes();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivityService.onConnectivityChanged.listen((results) {
      final hasConnection = results.contains(ConnectivityResult.mobile) ||
                           results.contains(ConnectivityResult.wifi);
      
      if (hasConnection != _hasInternet) {
        setState(() => _hasInternet = hasConnection);
        
        if (hasConnection) {
          // Reconnected → refresh data
          ErrorHandler.showSuccess(
            context,
            message: '✅ Đã kết nối Internet',
          );
          _loadDishes();
        }
      }
    });
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);

    final hasInternet = await _connectivityService.hasInternetConnection();
    setState(() => _hasInternet = hasInternet);

    if (hasInternet) {
      // Online → load from API
      try {
        final dishes = await _apiService.getDishes();
        await _cacheService.saveDishesCache(dishes);
        
        setState(() {
          _dishes = dishes;
          _isOfflineMode = false;
          _isLoading = false;
        });
        
      } catch (e) {
        // API failed → fallback to cache
        await _loadFromCache();
      }
    } else {
      // Offline → load from cache
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    final cachedDishes = await _cacheService.getCachedDishes();

    if (cachedDishes != null && cachedDishes.isNotEmpty) {
      setState(() {
        _dishes = cachedDishes;
        _isOfflineMode = true;
        _isLoading = false;
      });

      ErrorHandler.showWarning(
        context,
        message: '📡 Đang xem dữ liệu offline',
      );
    } else {
      setState(() => _isLoading = false);

      ErrorHandler.showError(
        context,
        error: Exception('No cache'),
        customMessage: 'Không có dữ liệu. Vui lòng kết nối Internet.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Món Ăn'),
        actions: [
          if (_isOfflineMode)
            Chip(
              label: Text('Offline', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.orange,
              padding: EdgeInsets.zero,
            ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          if (!_hasInternet)
            Container(
              color: Colors.orange.shade700,
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Không có kết nối Internet',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          
          // Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadDishes,
                    child: ListView.builder(
                      itemCount: _dishes.length,
                      itemBuilder: (context, index) {
                        return DishCard(dish: _dishes[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ Checklist

- [x] ConnectivityService created
- [x] CacheService created
- [x] `connectivity_plus` package added
- [x] Online flow implementation
- [x] Offline flow implementation
- [x] Cache save/load for dishes
- [x] Cache save/load for favorites
- [x] Cache save/load for user stats
- [x] Cache staleness check
- [x] Offline indicator UI
- [x] Pull-to-refresh with connectivity check
- [x] Auto-reload when reconnected

---

## 📝 Notes

**Cache Storage:**
- ✅ Uses `SharedPreferences` (simple key-value)
- ✅ JSON encoding for complex data
- ✅ Automatic expiry (24 hours default)

**Network Detection:**
- ✅ `connectivity_plus` package
- ✅ Realtime connectivity changes
- ✅ Multiple connection types (WiFi, Mobile, Ethernet)

**UX Considerations:**
- ✅ Offline banner at top
- ✅ Warning message when viewing cached data
- ✅ Clear error when no cache available
- ✅ Auto-refresh when reconnected

**Future Enhancements:**
- [ ] SQLite for larger datasets
- [ ] Background sync when connected
- [ ] Sync indicator (pending uploads)
- [ ] Conflict resolution for offline edits

**App hoạt động offline với cached data!** ✅
