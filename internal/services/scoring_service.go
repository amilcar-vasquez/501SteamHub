// filename: internal/services/scoring_service.go

package services

import (
	"strings"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
)

// Constants for the Weighted Sum Model - implements FR-27 Contribution Valuation
const (
	WeightLesson              = 10.0
	WeightVideo               = 7.0
	WeightSlideshow           = 5.0
	WeightAssessment          = 3.0
	TotalLessonFields         = 5.0 // Objectives, Materials, InstructionalContent, Assessment, Differentiation
	SynergyMultiplier2Cat     = 1.2 // 2 unique categories
	SynergyMultiplier3Cat     = 1.5 // 3 unique categories
	SynergyMultiplier4PlusCat = 2.0 // 4+ unique categories
)

// CalculateSteamPoints implements FR-27 requirement for contribution valuation.
// It computes the STEAM Points score based on:
//  1. Weighted Base Score (w): Different weights for resource types (Lesson, Video, Slideshow, Assessment)
//  2. Completeness Factor (C): For Lesson Plans, evaluates the 5 instructional fields
//  3. Synergy Multiplier (M): Based on unique resource categories in the bundle
//
// Formula: Total Score = (Σ(w_i * C_i)) * M
//
// Returns the total floating-point score for the given slice of resources.
// Performance: O(n) where n is typically 1-5 resources, safe to call on every save.
func CalculateSteamPoints(resources []data.Resource) float64 {
	var totalBaseScore float64
	uniqueCategories := make(map[string]bool)

	for _, res := range resources {
		// 1. Determine Base Weight (w) based on resource category
		weight := determineWeight(res.Category)

		// 2. Calculate Completeness Factor (C)
		// Only Lesson Plans have the 5 specific instructional fields to check
		completeness := calculateCompleteness(res)

		totalBaseScore += (weight * completeness)
		uniqueCategories[strings.ToLower(res.Category)] = true
	}

	// 3. Apply Synergy Multiplier (M) based on unique categories
	multiplier := calculateSynergyMultiplier(len(uniqueCategories))

	return totalBaseScore * multiplier
}

// determineWeight returns the assigned weight for a given resource category.
// Falls back to 1.0 for unknown categories.
func determineWeight(category string) float64 {
	switch strings.ToLower(category) {
	case "lesson", "lesson plan":
		return WeightLesson
	case "video":
		return WeightVideo
	case "slideshow":
		return WeightSlideshow
	case "assessment":
		return WeightAssessment
	default:
		return 1.0
	}
}

// calculateCompleteness evaluates how complete a resource is.
// For Lesson Plans, checks if the 5 instructional fields are non-empty.
// For other resource types, returns 1.0 (fully complete by default).
func calculateCompleteness(res data.Resource) float64 {
	// Only Lesson Plans are evaluated for completeness
	if strings.ToLower(res.Category) != "lesson plan" && strings.ToLower(res.Category) != "lesson" {
		return 1.0
	}

	// If no lesson content, assign minimum completeness
	if res.LessonContent == nil {
		return 0.0
	}

	filledFields := 0.0
	lc := res.LessonContent

	// Check each of the 5 instructional fields
	if strings.TrimSpace(lc.Objectives) != "" {
		filledFields++
	}
	if strings.TrimSpace(lc.Materials) != "" {
		filledFields++
	}
	if strings.TrimSpace(lc.InstructionalContent) != "" {
		filledFields++
	}
	if strings.TrimSpace(lc.Assessment) != "" {
		filledFields++
	}
	if strings.TrimSpace(lc.Differentiation) != "" {
		filledFields++
	}

	// Return completeness as ratio of filled fields to total fields
	return filledFields / TotalLessonFields
}

// calculateSynergyMultiplier returns the multiplier based on unique resource categories.
// 2 categories = 1.2x, 3 = 1.5x, 4+ = 2.0x, otherwise 1.0x (no multiplier).
func calculateSynergyMultiplier(uniqueCategoryCount int) float64 {
	switch {
	case uniqueCategoryCount >= 4:
		return SynergyMultiplier4PlusCat
	case uniqueCategoryCount == 3:
		return SynergyMultiplier3Cat
	case uniqueCategoryCount == 2:
		return SynergyMultiplier2Cat
	default:
		return 1.0
	}
}
