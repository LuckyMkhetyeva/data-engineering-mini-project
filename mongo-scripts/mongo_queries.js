use('grocerydb');

// Reset and seed customer activity collection from mongo_seed.json
// Example import:
// mongoimport --db grocerydb --collection customer_activity --file mongo-scripts/mongo_seed.json --jsonArray

// Helpful validation and BI-ready queries

// 1) Total records
print('Total customer activity records: ' + db.customer_activity.countDocuments());

// 2) Activity distribution
print('\nActivity distribution:');
db.customer_activity.aggregate([
  { $group: { _id: '$activity', count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]).forEach(printjson);

// 3) Top products by activity count
print('\nTop products by activity count:');
db.customer_activity.aggregate([
  { $group: { _id: '$product', activity_count: { $sum: 1 } } },
  { $sort: { activity_count: -1 } },
  { $limit: 10 }
]).forEach(printjson);

// 4) Purchased events per customer
print('\nPurchased events per customer:');
db.customer_activity.aggregate([
  { $match: { activity: 'Purchased' } },
  { $group: { _id: '$customer_name', purchases: { $sum: 1 } } },
  { $sort: { purchases: -1, _id: 1 } }
]).forEach(printjson);

// 5) Basic field sanity check for ETL alignment
print('\nField sanity check (first 5 docs):');
db.customer_activity.find(
  {},
  { _id: 0, customer_name: 1, product: 1, category: 1, activity: 1, timestamp: 1, device_type: 1, session_id: 1 }
).limit(5).forEach(printjson);
