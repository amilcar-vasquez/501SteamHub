#!/usr/bin/env python3
import psycopg2
import sys

# Database connection details
conn_params = {
    'dbname': '501SteamHub',
    'user': '501SteamHub',
    'password': 'STEAMAdmin501',
    'host': 'localhost'
}

try:
    conn = psycopg2.connect(**conn_params)
    cursor = conn.cursor()
    
    # Update 3 Draft resources to Submitted
    cursor.execute("""
        UPDATE resources 
        SET status = 'Submitted'
        WHERE resource_id IN (
            SELECT resource_id FROM resources WHERE status = 'Draft' LIMIT 3
        )
    """)
    print(f"Updated {cursor.rowcount} Draft resources to Submitted")
    
    # Update 2 Approved resources to UnderReview
    cursor.execute("""
        UPDATE resources 
        SET status = 'UnderReview'
        WHERE resource_id IN (
            SELECT resource_id FROM resources WHERE status = 'Approved' LIMIT 2
        )
    """)
    print(f"Updated {cursor.rowcount} Approved resources to UnderReview")
    
    # Update 1 Draft resource to NeedsRevision
    cursor.execute("""
        UPDATE resources 
        SET status = 'NeedsRevision'
        WHERE resource_id IN (
            SELECT resource_id FROM resources WHERE status = 'Draft' LIMIT 1
        )
    """)
    print(f"Updated {cursor.rowcount} Draft resources to NeedsRevision")
    
    # Show final counts
    cursor.execute("SELECT COUNT(*), status FROM resources GROUP BY status ORDER BY status")
    print("\nFinal resource counts by status:")
    for count, status in cursor.fetchall():
        print(f"  {status}: {count}")
    
    conn.commit()
    cursor.close()
    conn.close()
    print("\nDatabase updated successfully!")
    
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
