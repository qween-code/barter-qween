# 🌱 Firebase Database Seeding

## Prerequisites

1. Install dependencies:
```bash
npm install firebase-admin
```

2. Download service account key:
   - Go to Firebase Console > Project Settings > Service Accounts
   - Click "Generate New Private Key"
   - Save as `serviceAccountKey.json` in project root
   - **IMPORTANT:** Add to `.gitignore`

## Running the Seeder

```bash
node scripts/seed_test_items.js
```

## What It Creates

- **15 test items** (one for each category)
- All items have **specifications** based on category
- Items distributed across **3 test users**
- Random Turkish **cities** assigned
- Items marked with `isTestData: true` for easy cleanup

## Categories Covered

1. Electronics (2 items) - iPhone, MacBook
2. Fashion (2 items) - Nike shoes, Zara jacket
3. Books (1 item) - Turkish literature
4. Furniture (1 item) - IKEA bedroom set
5. Toys (1 item) - LEGO Star Wars
6. Sports (1 item) - Decathlon bike
7. Home & Garden (1 item) - Bosch washing machine
8. Beauty (1 item) - Chanel perfume
9. Automotive (1 item) - BMW parts
10. Collectibles (1 item) - Pokemon cards
11. Music & Instruments (1 item) - Fender guitar
12. Pet Supplies (1 item) - Dog food
13. Baby & Kids (1 item) - Chicco stroller
14. Office Supplies (1 item) - Herman Miller chair

## Cleaning Up Test Data

### Option 1: Firebase Console
Filter by `isTestData == true` and delete

### Option 2: Script
```javascript
const batch = db.batch();
const snapshot = await db.collection('items')
  .where('isTestData', '==', true)
  .get();

snapshot.docs.forEach(doc => {
  batch.delete(doc.ref);
});

await batch.commit();
```

### Option 3: CLI
```bash
firebase firestore:delete --all-collections --shallow items --force
```

## Notes

⚠️ **Important:**
- Test items auto-approved (moderationStatus: 'approved')
- Test users need to exist in authentication
- Images are placeholders
- Safe for production (marked as test data)

✅ **Safe to run multiple times** - creates new items each time
