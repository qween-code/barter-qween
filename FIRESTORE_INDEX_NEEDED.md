# 🔥 FIRESTORE INDEX REQUIRED

**Priority**: HIGH  
**Created**: 2025-01-07  
**Status**: ⏳ PENDING USER ACTION

---

## 📋 ISSUE

The app needs a composite index for the "featured items" query to work properly.

### Error Message
```
Query requires an index. You can create it here:
https://console.firebase.google.com/v1/r/project/bogazici-barter/firestore/indexes?create_composite=...
```

### Query Details
- **Collection**: `items`
- **Filters**:
  - `status == 'active'`
  - `isFeatured == true`
- **Order By**: `createdAt DESC`

---

## ✅ SOLUTION

### Step 1: Click the Auto-Generated Link
When you run the app and try to load featured items, Firebase will log an error with a direct link to create the index. 

**The link looks like:**
```
https://console.firebase.google.com/v1/r/project/bogazici-barter/firestore/indexes?create_composite=...
```

### Step 2: Create Index in Firebase Console
1. Click the link in the error message (or app logs)
2. Firebase Console will open with pre-filled index configuration
3. Click **"Create Index"** button
4. Wait 5-10 minutes for index deployment

### Step 3: Verify Index
1. Go to Firebase Console → Firestore Database → Indexes tab
2. Check that the new index shows **"Enabled"** status
3. Restart the app
4. Featured items should now load correctly

---

## 🔍 ALTERNATIVE: Manual Index Creation

If the auto-link doesn't work, create the index manually:

1. Go to: https://console.firebase.google.com/project/bogazici-barter/firestore/indexes
2. Click **"Create Index"**
3. Fill in:
   - **Collection ID**: `items`
   - **Fields to index**:
     - `status` → Ascending
     - `isFeatured` → Ascending  
     - `createdAt` → Descending
   - **Query scope**: Collection
4. Click **"Create"**
5. Wait for deployment (5-10 min)

---

## 📝 VERIFICATION CHECKLIST

After index is created:

- [ ] Index shows "Enabled" in Firebase Console
- [ ] App runs without Firestore index errors
- [ ] Featured items section loads on home page
- [ ] No performance warnings in logs

---

## 🎯 NEXT STEPS

**After creating the index:**
1. ✅ Mark this task complete in PRODUCTION_CHECKLIST.md
2. ✅ Update DAILY_TESTING_LOG.md with completion time
3. ✅ Continue to Phase 1: Auth Module testing

---

**Last Updated**: 2025-01-07 17:02:00  
**Est. Time to Fix**: 10-15 minutes (mostly waiting for index deployment)
