# 🐛 Critical Bugs Tracker

**Last Updated:** 5 Ocak 2025 05:50  
**Branch:** feature/sprint-1-barter-conditions  
**Target:** Production Ready

---

## 🔴 CRITICAL BUGS (Must Fix)

### 1. Profile Page Crash ⚠️

**Status:** 🟢 **INVESTIGATING** - No diagnostics found  
**Priority:** CRITICAL  
**Impact:** Users cannot logout

#### Initial Analysis
```bash
✅ No IDE diagnostics in profile_page.dart
✅ ProfileBloc structure looks good
✅ ProfileState has copyWithStats method
✅ Logout function implementation looks safe
```

#### Files Checked
- ✅ `lib/presentation/pages/profile/profile_page.dart` - No errors
- ✅ `lib/presentation/blocs/profile/profile_bloc.dart` - Looks good
- ✅ `lib/presentation/blocs/profile/profile_state.dart` - Proper structure

#### Suspected Issues
- ⚠️ Potential issue: FutureBuilder<SharedPreferences> in _buildPreferencesCard()
- ⚠️ Possible race condition in didChangeDependencies()
- ⚠️ Multiple profile loads might cause state conflicts

#### Action Items
- [ ] Test profile page on actual device
- [ ] Add try-catch blocks around SharedPreferences
- [ ] Add error boundaries
- [ ] Check auth state transitions
- [ ] Test logout flow specifically

---

### 2. Favorites Not Working 🔴

**Status:** 🔴 **NOT STARTED**  
**Priority:** HIGH  
**Impact:** Core feature unavailable

#### Todo
- [ ] Locate FavoritesPage and FavoriteBloc
- [ ] Check Firestore queries
- [ ] Verify FavoriteBloc integration
- [ ] Test add/remove favorite
- [ ] Check state management

---

### 3. Search Functionality Broken 🔴

**Status:** 🔴 **NOT STARTED**  
**Priority:** CRITICAL  
**Impact:** Users cannot find items

#### Todo
- [ ] Check Home page search
- [ ] Check Explorer page search
- [ ] Verify search query implementation
- [ ] Test filtering logic
- [ ] Check Firestore indexes

---

### 4. Firestore Permission Errors 🟡

**Status:** 🟡 **NOT STARTED**  
**Priority:** HIGH  
**Impact:** Some write operations fail

#### Todo
- [ ] Review firestore.rules
- [ ] Test all CRUD operations
- [ ] Check permission errors in logs
- [ ] Update security rules if needed
- [ ] Deploy updated rules

---

## 📊 Progress Tracker

| Bug | Status | Progress | ETA |
|-----|--------|----------|-----|
| Profile Crash | 🟢 Investigating | 20% | 2 hours |
| Favorites | 🔴 Pending | 0% | 3 hours |
| Search | 🔴 Pending | 0% | 4 hours |
| Permissions | 🟡 Pending | 0% | 2 hours |

**Total:** 5% complete  
**Estimated Time:** 11 hours

---

## 🔍 Investigation Notes

### Profile Page Analysis (05:50)

**Findings:**
1. ✅ No compilation errors in ProfilePage
2. ✅ BLoC pattern properly implemented
3. ✅ State management looks correct
4. ⚠️ **Potential Issue:** FutureBuilder without proper error handling
5. ⚠️ **Potential Issue:** Multiple profile load calls in didChangeDependencies

**Code Locations:**
```dart
// Line 429: FutureBuilder<SharedPreferences>
Future.value(getIt<SharedPreferences>())

// Line 45-75: Multiple profile load triggers
_resetAndLoadProfile() called in:
- initState()
- didChangeDependencies()
- BlocListener<AuthBloc>
```

**Recommendation:**
- Add debouncing to profile loads
- Wrap SharedPreferences in try-catch
- Add loading state checks before reload

---

## 🎯 Next Steps

### Immediate (This Session)
1. ✅ Profile page initial analysis
2. ⏳ Test profile page on emulator
3. ⏳ Locate and analyze FavoritesPage
4. ⏳ Locate and analyze SearchPage

### Today
- Fix profile crash
- Fix favorites functionality
- Start search fix

### This Week
- Complete all critical bugs
- Add error monitoring
- Increase test coverage

---

## 📝 Testing Checklist

### Profile Page
- [ ] Can navigate to profile page
- [ ] Can view profile information
- [ ] Can edit profile
- [ ] Can upload avatar
- [ ] **Can logout successfully** ⚠️
- [ ] Stats load correctly
- [ ] Navigation to sub-pages works

### Favorites
- [ ] Can view favorites list
- [ ] Can add item to favorites
- [ ] Can remove item from favorites
- [ ] Favorites persist across sessions
- [ ] UI updates immediately

### Search
- [ ] Can search from Home page
- [ ] Can search from Explorer page
- [ ] Search results are accurate
- [ ] Filters work correctly
- [ ] Search is responsive (debounced)

---

## 🔧 Tools & Commands

### Debug Profile
```bash
# Run with verbose logging
flutter run --verbose

# Check profile-specific logs
adb logcat | grep -i "profile"

# Check for errors
flutter logs | grep -i "error"
```

### Test Favorites
```bash
# Check FavoriteBloc
flutter test test/blocs/favorite_bloc_test.dart

# Check Firestore queries
# (manual testing required)
```

### Test Search
```bash
# Check search implementation
rg "search" lib/presentation/pages/home/
rg "search" lib/presentation/pages/explore/
```

---

## 📚 Resources

- **Profile Implementation:** `lib/presentation/pages/profile/profile_page.dart`
- **BLoC Pattern:** Clean Architecture + flutter_bloc
- **State Management:** Equatable + BLoC events/states
- **Error Handling:** Either<Failure, Success> pattern

---

**Tracking Document:** Keep this updated as we progress through bug fixes.
