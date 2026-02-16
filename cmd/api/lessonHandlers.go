// Filename: cmd/api/lessonHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
	"github.com/lib/pq"
)

// createLessonHandler creates a new lesson for a resource
func (a *app) createLessonHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ResourceID      int64    `json:"resource_id"`
		LessonNumber    int      `json:"lesson_number"`
		Title           string   `json:"title"`
		DurationMinutes *int     `json:"duration_minutes"`
		Objectives      []string `json:"objectives"`
		Materials       []string `json:"materials"`
		Content         string   `json:"content"`
		Assessment      *string  `json:"assessment"`
		Differentiation *string  `json:"differentiation"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	lesson := &data.Lesson{
		ResourceID:      input.ResourceID,
		LessonNumber:    input.LessonNumber,
		Title:           input.Title,
		DurationMinutes: input.DurationMinutes,
		Objectives:      pq.StringArray(input.Objectives),
		Materials:       pq.StringArray(input.Materials),
		Content:         input.Content,
		Assessment:      input.Assessment,
		Differentiation: input.Differentiation,
	}

	v := validator.New()
	v.Check(lesson.ResourceID > 0, "resource_id", "must be provided")
	v.Check(lesson.LessonNumber > 0, "lesson_number", "must be provided")
	v.Check(lesson.Title != "", "title", "must be provided")
	v.Check(lesson.Content != "", "content", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Lessons.Insert(lesson)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"lesson": lesson,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getLessonHandler retrieves a specific lesson by ID
func (a *app) getLessonHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	lesson, err := a.models.Lessons.Get(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	response := envelope{
		"lesson": lesson,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getResourceLessonsHandler retrieves all lessons for a resource
func (a *app) getResourceLessonsHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	lessons, err := a.models.Lessons.GetByResource(id)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"lessons": lessons,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// updateLessonHandler updates an existing lesson
func (a *app) updateLessonHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	lesson, err := a.models.Lessons.Get(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	var input struct {
		Title           *string  `json:"title"`
		DurationMinutes *int     `json:"duration_minutes"`
		Objectives      []string `json:"objectives"`
		Materials       []string `json:"materials"`
		Content         *string  `json:"content"`
		Assessment      *string  `json:"assessment"`
		Differentiation *string  `json:"differentiation"`
	}

	err = a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.Title != nil {
		lesson.Title = *input.Title
	}
	if input.DurationMinutes != nil {
		lesson.DurationMinutes = input.DurationMinutes
	}
	if input.Objectives != nil {
		lesson.Objectives = pq.StringArray(input.Objectives)
	}
	if input.Materials != nil {
		lesson.Materials = pq.StringArray(input.Materials)
	}
	if input.Content != nil {
		lesson.Content = *input.Content
	}
	if input.Assessment != nil {
		lesson.Assessment = input.Assessment
	}
	if input.Differentiation != nil {
		lesson.Differentiation = input.Differentiation
	}

	v := validator.New()
	v.Check(lesson.Title != "", "title", "must be provided")
	v.Check(lesson.Content != "", "content", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Lessons.Update(lesson)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"lesson": lesson,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteLessonHandler deletes a lesson
func (a *app) deleteLessonHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.Lessons.Delete(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	response := envelope{
		"message": "lesson successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
