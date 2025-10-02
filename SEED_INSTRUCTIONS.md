# 🌱 Firebase Seed Instructions

## Step 1: Download Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **bogazici-barter**
3. Click ⚙️ (Settings) → **Project settings**
4. Go to **Service accounts** tab
5. Click **Generate new private key**
6. Save the downloaded JSON file as `serviceAccountKey.json` in this folder

## Step 2: Run the Seed Script

```bash
# Make sure you're in the project directory
cd C:\Users\qw\Desktop\barter-qween\barter_qween

# Run the seed script
npm run seed
```

## What Will Be Created

### 👥 **5 Users**
1. **Alice Johnson** - alice.johnson@example.com
2. **Bob Smith** - bob.smith@example.com  
3. **Carol White** - carol.white@example.com
4. **David Brown** - david.brown@example.com
5. **Emma Davis** - emma.davis@example.com

**Password for all:** `Test123!`

### 📦 **10 Items**
1. iPhone 13 Pro - 256GB (Electronics)
2. Harry Potter Complete Book Set (Books)
3. Vintage Leather Jacket (Fashion)
4. Professional Road Bike (Sports)
5. Modern Coffee Table (Home)
6. Sony WH-1000XM4 Headphones (Electronics)
7. LEGO Architecture Set - Taj Mahal (Toys)
8. The Lord of the Rings Trilogy (Books)
9. Designer Handbag - Michael Kors (Fashion)
10. Yoga Mat & Block Set (Sports)

### 🤝 **5 Trade Offers**
1. Alice → Bob: iPhone for Harry Potter (Pending)
2. Carol → Alice: Leather Jacket for iPhone (Pending)
3. David → Emma: Road Bike for Coffee Table (Accepted)
4. Bob → Carol: LOTR Books for Handbag (Rejected)
5. Emma → David: Yoga Mat for Road Bike (Cancelled)

## After Seeding

You can login to the app with any of these users:

```
Email: alice.johnson@example.com
Password: Test123!
```

Or use any of the other test users!

## Troubleshooting

If you get an error:
1. Make sure `serviceAccountKey.json` exists
2. Check if Firebase project ID is correct
3. Ensure you have Firebase Admin permissions
4. Try running `npm install` again

---

**Note:** The seed script will skip users that already exist, so it's safe to run multiple times!
