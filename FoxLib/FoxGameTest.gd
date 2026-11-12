#class_name FoxGameTest
#public_api

var name
var isRegistryTest

func _init():
	name = "ERROR"
	isRegistryTest = false

# All your test cases.
func getTestCases():
	return [""]

# All your test variants, if one variant fails, the others variants are skipped for that test case
func getTestVariants():
	return [""]

# Your update display method should always be as safe as possible, and is ran before the test is executed.
# It is important to apply display changes here, as if applyTest somehow crashes the game, the info won't be visible
func updateDisplay(_display, _testCase, _variant):
	pass

# Execute before your test is ran, usueful to allocate object that persist across test cases
func beforeTest():
	pass

# Apply test, if the test crash the game, any display change made durring this test will not be displayed to the end user.
func applyTest(_display, _testCase, _variant):
	return false

# Execute after your test is ran, usueful to allocate object that persist across test cases
func afterTest():
	pass

