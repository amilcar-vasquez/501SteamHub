#!/usr/bin/env python3
"""Check database state and fix migration history"""

import psycopg2
from psycopg2 import sql

DB_DSN = "postgres://501SteamHub:STEAMAdmin501@localhost/501SteamHub?sslmode=disable"

try:
    conn = psycopg2.connect(DB_DSN)
    cursor = conn.cursor()
    
    # Check tables  
    cursor.execute("""
        SELECT table_name FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name IN ('subjects', 'grade_levels')
    """)
    existing = [row[0] for row in cursor.fetchall()]
    print(f"✓ Existing lookup tables: {existing if existing else 'NONE'}")
    
    # Check resource data
    cursor.execute("SELECT COUNT(*) FROM resources")
    resource_count = cursor.fetchone()[0]
    print(f"✓ Resources count: {resource_count}")
    
    # Check resource_subjects data
    cursor.execute("SELECT COUNT(*) FROM resource_subjects")
    rs_count = cursor.fetchone()[0]
    print(f"✓ Resource-subject mappings: {rs_count}")
    
    # Check migration history
    cursor.execute("SELECT version, dirty FROM schema_migrations ORDER BY version")
    migrations = cursor.fetchall()
    print(f"✓ Migration history: {migrations}")
    
    # Fix: Delete the dirty migration
    if migrations and migrations[0][0] == 27 and migrations[0][1]:
        print("\n! Found dirty migration 027, cleaning up...")
        cursor.execute("DELETE FROM schema_migrations WHERE version = 27 AND dirty = true")
        conn.commit()
        print("✓ Cleaned up migration 027")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"✗ Error: {e}")
