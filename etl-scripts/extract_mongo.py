from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from bson import ObjectId
from pymongo import MongoClient
from pymongo.errors import PyMongoError

MONGO_URI = "mongodb://localhost:27017/"
DATABASE_NAME = "grocerydb"
COLLECTION_NAME = "customer_activity"
PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_JSON_PATH = PROJECT_ROOT / "data" / "raw" / "mongo_activity_raw.json"


def connect_mongo() -> Any:
    """Create and validate a MongoDB client connection."""
    client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
    client.admin.command("ping")
    print("[INFO] Successfully connected to MongoDB.")
    return client


def extract_data(collection: Any) -> list[dict[str, Any]]:
    """Extract all documents from the target MongoDB collection."""
    documents: list[dict[str, Any]] = list(collection.find({}))
    print(f"[INFO] Extracted {len(documents)} documents from MongoDB.")
    if not documents:
        print(
            "[WARN] No documents were extracted from MongoDB. "
            "Check that the database was seeded correctly."
        )
    return documents


def convert_object_ids(documents: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Convert ObjectId values to strings for JSON serialization."""
    for document in documents:
        for key, value in list(document.items()):
            if isinstance(value, ObjectId):
                document[key] = str(value)
    return documents


def save_to_json(documents: list[dict[str, Any]], output_path: Path) -> None:
    """Persist extracted documents to the raw JSON output file."""
    output_path.parent.mkdir(parents=True, exist_ok=True)

    relative_output = output_path.relative_to(PROJECT_ROOT)
    if output_path.exists():
        print(f"[INFO] Existing file found. Overwriting: {relative_output}")

    with output_path.open("w", encoding="utf-8") as file:
        json.dump(documents, file, indent=2, ensure_ascii=False)

    print(f"[INFO] Raw MongoDB extract saved to: {relative_output}")


def main() -> None:
    """Run MongoDB extract and write raw snapshot JSON."""
    client: Any = None
    try:
        client = connect_mongo()
        database = client[DATABASE_NAME]
        collection = database[COLLECTION_NAME]

        documents = extract_data(collection)
        serializable_documents = convert_object_ids(documents)
        save_to_json(serializable_documents, OUTPUT_JSON_PATH)

    except PyMongoError as error:
        print(f"[ERROR] {error}")
    except (OSError, TypeError, ValueError) as error:
        print(f"[ERROR] {error}")
    finally:
        if client is not None:
            client.close()
            print("[INFO] MongoDB connection closed.")


if __name__ == "__main__":
    main()
