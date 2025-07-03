const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.refreshFreshnessIndex = functions.pubsub
  .schedule("every 60 minutes") // run every hour
  .onRun(async (context) => {
    const snapshot = await db.collection("food_inventory").get();
    const updates = [];

    snapshot.forEach(doc => {
      const data = doc.data();
      const storage = data.currentStorage;
      let rate = 0;

      if (storage === "room") {
        rate = data.deteriorationRateRoom;
      } else if (storage === "fridge") {
        rate = data.deteriorationRateFridge;
      } else if (storage === "freezer") {
        rate = data.deteriorationRateFreezer;
      }

      const currentFreshness = data.freshnessIndex || 1.0;
      const newFreshness = Math.max(0, currentFreshness - rate);

      updates.push(doc.ref.update({
        freshnessIndex: newFreshness
      }));
    });

    await Promise.all(updates);
    console.log(`✅ Updated ${updates.length} food items.`);
    return null;
  });
