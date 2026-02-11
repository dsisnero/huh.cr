package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/charmbracelet/huh"
)

func main() {
	// Create testdata directory relative to project root
	testdataDir := "../../testdata/go"
	err := os.MkdirAll(testdataDir, 0755)
	if err != nil {
		panic(err)
	}

	fmt.Println("Generating golden files for huh library...")

	// Test 1: Basic Input field - initial state
	generateInputGolden(testdataDir)

	// Test 2: Input field with title and description
	generateInputWithTitleGolden(testdataDir)

	// Test 3: Select field
	generateSelectGolden(testdataDir)

	// Test 4: Confirm field
	generateConfirmGolden(testdataDir)

	fmt.Println("Golden file generation complete")
}

func generateInputGolden(testdataDir string) {
	fmt.Println("  Generating Input field golden files...")

	// Input field - initial state
	inputField := huh.NewInput()
	form := huh.NewForm(huh.NewGroup(inputField))

	// Initialize the form
	form.Update(form.Init())

	// Get the view
	view := form.View()

	// Write to file
	filename := filepath.Join(testdataDir, "input_initial.txt")
	err := os.WriteFile(filename, []byte(view), 0644)
	if err != nil {
		panic(err)
	}

	fmt.Printf("    Generated %s\n", filename)
}

func generateInputWithTitleGolden(testdataDir string) {
	// Input field with title and description
	inputField := huh.NewInput().
		Title("What's your name?").
		Description("Enter your full name").
		Placeholder("John Doe")

	form := huh.NewForm(huh.NewGroup(inputField))
	form.Update(form.Init())

	view := form.View()

	filename := filepath.Join(testdataDir, "input_with_title.txt")
	err := os.WriteFile(filename, []byte(view), 0644)
	if err != nil {
		panic(err)
	}

	fmt.Printf("    Generated %s\n", filename)
}

func generateSelectGolden(testdataDir string) {
	fmt.Println("  Generating Select field golden files...")

	// Select field
	var choice string
	selectField := huh.NewSelect[string]().
		Title("Choose a color").
		Options(
			huh.NewOption("Red", "red"),
			huh.NewOption("Green", "green"),
			huh.NewOption("Blue", "blue"),
		).
		Value(&choice)

	form := huh.NewForm(huh.NewGroup(selectField))
	form.Update(form.Init())

	view := form.View()

	filename := filepath.Join(testdataDir, "select_initial.txt")
	err := os.WriteFile(filename, []byte(view), 0644)
	if err != nil {
		panic(err)
	}

	fmt.Printf("    Generated %s\n", filename)
}

func generateConfirmGolden(testdataDir string) {
	fmt.Println("  Generating Confirm field golden files...")

	// Confirm field
	var confirmed bool
	confirmField := huh.NewConfirm().
		Title("Are you sure?").
		Affirmative("Yes").
		Negative("No").
		Value(&confirmed)

	form := huh.NewForm(huh.NewGroup(confirmField))
	form.Update(form.Init())

	view := form.View()

	filename := filepath.Join(testdataDir, "confirm_initial.txt")
	err := os.WriteFile(filename, []byte(view), 0644)
	if err != nil {
		panic(err)
	}

	fmt.Printf("    Generated %s\n", filename)
}
