# FR-27 STEAM Points Integration - Approval Handler

## ✅ What Was Integrated

### 1. **Resource Approval Handler** 
📄 `cmd/api/resourceReviewHandlers.go`

When a resource review decision is marked as **"Approved"**:

1. **Score Calculation** (FR-27)
   - Prepares resource with lesson content if it's a lesson plan
   - Calls `CalculateSteamPoints()` to compute points
   - Formulas applied:
     - Weight: 10 (lesson), 7 (video), 5 (slideshow), 3 (assessment)
     - Completeness: checks 5 instructional fields for lesson plans
     - Synergy: multiplier based on unique resource categories

2. **Points Award**
   - Updates fellow's accumulated `steam_points` via `UpdateSteamPoints()`
   - Non-blocking: errors are logged but don't fail the approval

3. **Audit Logging**
   - Logs points awarded to contributor with category and amount
   - Existing `logResourceStatusChange()` captures status transition

### 2. **Updated Interfaces**
📄 `internal/data/interfaces.go`

Added `UpdateSteamPoints(int64, float64) error` method to `FellowModelInterface`

### 3. **Helper Function**
📄 `cmd/api/helpers.go`

Added `derefString()` helper to safely handle pointer dereferencing

### 4. **Database Migration Applied**
✅ Version 23: `steam_points` column + index added to fellows table

---

## 🔍 How It Works

### Flow Diagram
```
Resource Review Approved
        ↓
[Check if decision == "Approved"]
        ↓
[Fetch lesson content if lesson plan]
        ↓
[Calculate STEAM Points]
        ↓
[UpdateSteamPoints(contributorID, points)]
        ↓
[Log result to audit trail]
        ↓
[Return response with updated resource]
```

### Example: Lesson Plan Approval

**Scenario**: Fellow submits a lesson plan with:
- ✓ Objectives (filled)
- ✓ Materials (filled)
- ✓ Instructional Content (filled)
- ✗ Assessment (empty)
- ✓ Differentiation (filled)

**Calculation**:
```
Weight (Lesson): 10
Completeness: 4/5 = 0.8
Base Score: 10 × 0.8 = 8.0
Synergy: 1 category = 1.0x
Final: 8.0 × 1.0 = 8.0 points ⭐
```

**Logs**:
```
INFO - STEAM Points awarded to contributor
  fellow_id: 42
  resource_id: 123
  category: "Lesson Plan"
  points: 8.0
```

**Database Update**:
```
UPDATE fellows SET steam_points = steam_points + 8.0 WHERE fellow_id = 42;
```

---

## 📊 Example Scenarios

### Example 1: Video Resource (Full)
```
Resource: Video
Category: "Video"
Base Weight: 7.0
Completeness: 1.0 (videos don't have field checks)
Synergy: 1 category = 1.0x
Result: 7.0 × 1.0 × 1.0 = 7.0 points
```

### Example 2: Multi-Category Bundle
Imagine a fellow submits 3 resources in one go:
```
1. Lesson Plan (complete):     10.0 × 1.0 = 10.0
2. Video (complete):            7.0 × 1.0 = 7.0
3. Slideshow (complete):        5.0 × 1.0 = 5.0

Base Score: 22.0
Unique Categories: 3
Synergy Multiplier: 1.5x
FINAL: 22.0 × 1.5 = 33.0 points 🚀
```

---

## 🔧 Integration Code Location

**Main Integration**: Lines 83-131 in `resourceReviewHandlers.go`

```go
// Calculate and award STEAM Points if resource is approved (FR-27)
if review.Decision == "Approved" {
    // Prepare resource with lesson content
    if strings.ToLower(resource.Category) == "lesson plan" {
        lessons, err := a.models.Lessons.GetByResource(resource.ID)
        // ... populate LessonContent
    }
    
    // Calculate STEAM Points
    points := services.CalculateSteamPoints([]data.Resource{*resource})
    
    // Award points to contributor
    if points > 0 {
        err := a.models.Fellows.UpdateSteamPoints(resource.ContributorID, points)
        if err != nil {
            a.logger.Error("Failed to update fellow steam points", ...)
        } else {
            a.logger.Info("STEAM Points awarded to contributor", ...)
        }
    }
}
```

---

## 📝 Audit Trail

The existing audit logging system captures:
1. **Status Change**: "Pending" → "Approved" (via `logResourceStatusChange`)
2. **Points Award**: Logged in application logs with full details

**Log Entry Example**:
```
timestamp=2026-03-17T14:32:15Z level=INFO msg="STEAM Points awarded to contributor" 
fellow_id=42 resource_id=123 category=Video points=7.0
```

---

## ⚠️ Error Handling

- If scoring fails: Error is logged, approval **still succeeds**
- If point update fails: Application logs the error, workflow continues
- Rationale: Scoring/points are enhancements; core workflow mustn't break

---

## ✅ Production Readiness

✓ Migration applied to database  
✓ Scoring function integrated into approval handler  
✓ Error handling follows existing patterns  
✓ Logging captures all critical events  
✓ Code compiles without errors  
✓ Non-blocking: won't prevent approvals  

**Status**: 🚀 **READY FOR TESTING**

---

## 🧪 Testing Checklist

- [ ] Approve a simple video resource → check logs for 7.0 points
- [ ] Approve a lesson plan with 3/5 fields → check points = 6.0
- [ ] Query `fellows.steam_points` to verify accumulation
- [ ] Check application logs for STEAM Points entries
- [ ] Test fellow profile/dashboard to display points
- [ ] Verify leaderboard queries work (index is available)

---

## 📊 Query to View Accumulated Points

```sql
SELECT fellow_id, first_name, last_name, steam_points
FROM fellows
WHERE profile_status = 'approved'
ORDER BY steam_points DESC
LIMIT 10;
```

---

**Next**: Can now test approval workflow and verify point accumulation! 🎯
