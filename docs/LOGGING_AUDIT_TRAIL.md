# FR-27 Audit Logging - How It Works

## 🔄 Logging Flow When Resource is Approved

### Step 1: Resource Approval Initiated
```
User/Admin submits resource review with decision: "Approved"
↓
POST /v1/resource-reviews
└─ Body: {resource_id: 123, decision: "Approved", ...}
```

### Step 2: Status Transition Logged
```
Resource status changes: "Pending" → "Approved"
↓
logResourceStatusChange() called
↓
database.resource_status_history table updated with:
   - resource_id: 123
   - old_status: "Pending"
   - new_status: "Approved"
   - changed_by: 5 (reviewer ID)
   - changed_at: 2026-03-17 14:32:15.123456
```

### Step 3: STEAM Points Calculated & Awarded
```
CalculateSteamPoints() executes
↓
Result: 7.0 points returned
↓
fellows.UpdateSteamPoints(contributor_id, 7.0)
↓
database.fellows table updated:
   UPDATE fellows
   SET steam_points = steam_points + 7.0
   WHERE fellow_id = 42
↓
Application logs entry:
   INFO - STEAM Points awarded to contributor
   fellow_id: 42
   resource_id: 123
   category: "Video"
   points: 7.0
```

### Step 4: Response Sent to Client
```
HTTP 201 Created
{
  "review": {
    "review_id": 999,
    "resource_id": 123,
    "decision": "Approved",
    ...
  },
  "resource": {
    "resource_id": 123,
    "status": "Approved",
    ...
  }
}
```

---

## 📊 What Gets Logged Where

### Application Logs
**File**: Stdout/application logger

**Entry 1 - Status Change**:
```
INFO - Resource status changed successfully
  resource_id: 123
  old_status: Pending
  new_status: Approved
  changed_by: 5
```

**Entry 2 - STEAM Points**:
```
INFO - STEAM Points awarded to contributor
  fellow_id: 42
  resource_id: 123
  category: Video
  points: 7.0
```

**Entry 3 - Error (if UpdateSteamPoints fails)**:
```
ERROR - Failed to update fellow steam points
  fellow_id: 42
  resource_id: 123
  points: 7.0
  error: INSERT error details...
```

### Database Tables

#### 1. resource_status_history
```
history_id  | resource_id | old_status | new_status | changed_by | changed_at
─────────────────────────────────────────────────────────────────────────────
1001        | 123         | Pending    | Approved   | 5          | 2026-03-17 14:32:15
```

#### 2. fellows
```
fellow_id | user_id | steam_points | updated_at
─────────────────────────────────────────────
42        | 50      | 15.0         | 2026-03-17 14:32:15
```

---

## 🔍 Querying the Audit Trail

### Get all status changes for a resource:
```sql
SELECT history_id, old_status, new_status, changed_by, changed_at
FROM resource_status_history
WHERE resource_id = 123
ORDER BY changed_at DESC;
```

**Result**:
```
history_id | old_status | new_status | changed_by | changed_at
────────────────────────────────────────────────────────────
1001       | Pending    | Approved   | 5          | 2026-03-17 14:32:15
1000       | UnderReview| Pending    | 5          | 2026-03-17 14:15:00
999        | Draft      | UnderReview| 5          | 2026-03-17 13:45:30
```

### Get fellow's total STEAM Points:
```sql
SELECT fellow_id, first_name, last_name, steam_points
FROM fellows
WHERE fellow_id = 42;
```

### Get leaderboard (top 10):
```sql
SELECT fellow_id, first_name, last_name, steam_points
FROM fellows
WHERE profile_status = 'approved'
ORDER BY steam_points DESC
LIMIT 10;
```

### Track points awarded per resource:
```sql
SELECT r.resource_id, r.title, r.category, f.first_name, f.last_name
FROM resources r
JOIN fellows f ON f.fellow_id = r.contributor_id
ORDER BY r.created_at DESC;
-- Note: To correlate with points, use resource_status_history timestamps
```

---

## 📈 Points Accumulation Timeline Example

**Fellow: John Smith (ID: 42)**

| Date | Resource | Category | Points Awarded | Total Points | Event |
|---|---|---|---|---|---|
| 2026-03-15 10:00 | "Photosynthesis 101" | Lesson Plan | 8.0 | 8.0 | Approved |
| 2026-03-16 14:30 | "Mitochondria Video" | Video | 7.0 | 15.0 | Approved |
| 2026-03-16 15:45 | "Cell Assessment" | Assessment | 3.0 | 18.0 | Approved |
| 2026-03-17 09:20 | "Biology Bundle" | Video + Slideshow | 18.0 | 36.0 | Approved (synergy 2.0x) |

---

## 🚨 Error Scenarios & Logging

### Scenario 1: Resource Approved But Scoring Fails
```
INFO - Resource status changed successfully
  resource_id: 123, new_status: Approved

ERROR - Failed to update fellow steam points
  fellow_id: 42, resource_id: 123, points: 7.0
  error: Connection timeout

(Approval still succeeds; point award failed gracefully)
```

### Scenario 2: YouTube Upload & Scoring Both Trigger
```
INFO - STEAM Points awarded to contributor
  fellow_id: 42, resource_id: 123, category: Video, points: 7.0

INFO - Video queued for YouTube upload
  resource_id: 123, video_title: "Mitochondria 101"

INFO - Resource status changed successfully
  resource_id: 123, new_status: Approved
```

---

## 🔗 Log Correlation

To trace a resource approval end-to-end:

1. **Start**: Find resource ID (e.g., 123)
2. **status_history**: `SELECT * FROM resource_status_history WHERE resource_id = 123`
3. **Application logs**: Filter logs for `resource_id=123`
4. **Fellowship update**: `SELECT steam_points WHERE fellow_id = X`
5. **Leaderboard**: Position changed after approval

---

## ✅ Verification Steps

### 1. Check Status History
```bash
psql $DB_DSN -c \
  "SELECT history_id, resource_id, old_status, new_status, changed_at 
   FROM resource_status_history 
   WHERE resource_id = 123 
   ORDER BY changed_at DESC;"
```

### 2. Check Fellow Points
```bash
psql $DB_DSN -c \
  "SELECT fellow_id, first_name, steam_points 
   FROM fellows 
   WHERE fellow_id = 42;"
```

### 3. Check Application Logs
```bash
# In your log aggregation service (ELK, CloudWatch, etc.)
grep -i "steam points" application.log | tail -20
```

### 4. Verify Index Usage
```bash
psql $DB_DSN -c \
  "EXPLAIN QUERY PLAN 
   SELECT * FROM fellows 
   ORDER BY steam_points DESC LIMIT 10;"
```
Should show `Index Scan using idx_fellows_steam_points`

---

## 📝 Log Format Reference

All STEAM Points awards follow this pattern:

```
TIMESTAMP=2026-03-17T14:32:15.123456Z
LEVEL=INFO
MESSAGE="STEAM Points awarded to contributor"
fellow_id=42
resource_id=123
category="Video"
points=7.0
```

This makes it easy to:
- Grep for all points awarded: `grep "STEAM Points awarded"`
- Filter by fellow: `grep "fellow_id=42"`
- Calculate total points from logs: `grep "points" | awk '{sum+=$NF} END {print sum}'`

---

**Next**: Monitor these logs when approving resources & verify the leaderboard updates! 📊
