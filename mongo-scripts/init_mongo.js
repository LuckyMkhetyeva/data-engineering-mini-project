/**
 * MongoDB Initialization Script
 * -------------------------------------------
 * This script runs automatically when the MongoDB container starts.
 *
 * Purpose:
 * - Switches to the 'grocerydb' database
 * - Reads seed data from mongo_seed.json
 * - Parses the JSON dataset
 * - Drops the existing 'customer_activity' collection (if it exists)
 * - Inserts fresh customer activity data into MongoDB
 *
 * This ensures that the MongoDB OLTP system is pre-populated with
 * consistent grocery retail behavioural data for the ETL pipeline.
 */

const fs = require('fs');

db = db.getSiblingDB('grocerydb');

const file = fs.readFileSync('/docker-entrypoint-initdb.d/mongo_seed.json');
const data = JSON.parse(file);

if (db.getCollectionNames().includes('customer_activity')) {
  db.customer_activity.drop();
}

db.customer_activity.insertMany(data);