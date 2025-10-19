const admin = require('firebase-admin');
const path = require('path');

const serviceAccountPath = path.join(__dirname, '..', 'serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(require(serviceAccountPath)),
});

const db = admin.firestore();

async function inspect() {
  const usersSnap = await db.collection('users').get();
  console.log('USERS:', usersSnap.size);
  usersSnap.forEach((doc) => {
    const data = doc.data();
    console.log(` - ${data.email} @ ${data.location} (${data.latitude}, ${data.longitude})`);
  });

  const itemsSnap = await db.collection('items').get();
  console.log('\nITEMS:', itemsSnap.size);
  itemsSnap.forEach((doc) => {
    const data = doc.data();
    console.log(` - ${data.title} -> ${data.ownerName} (${data.ownerId}) ${data.city}`);
  });

  const tradesSnap = await db.collection('tradeOffers').get();
  console.log('\nTRADES:', tradesSnap.size);
  tradesSnap.forEach((doc) => {
    const data = doc.data();
    console.log(` - ${data.fromUserName} → ${data.toUserName} (${data.status}) ${data.offeredItemTitle} ⇄ ${data.requestedItemTitle}`);
  });

  const convSnap = await db.collection('conversations').get();
  console.log('\nCONVERSATIONS:', convSnap.size);
  convSnap.forEach((doc) => {
    const data = doc.data();
    console.log(` - ${doc.id} participants: ${data.participants.join(', ')} last: ${data.lastMessage}`);
  });

  const msgSnap = await db.collection('messages').get();
  console.log('\nMESSAGES:', msgSnap.size);
  msgSnap.forEach((doc) => {
    const data = doc.data();
    console.log(` - ${data.conversationId} ${data.senderName}: ${data.text}`);
  });
}

inspect().finally(() => admin.app().delete());
