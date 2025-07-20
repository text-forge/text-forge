# GdUnit generated TestSuite
class_name NodeFactoryTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/factory.gd'

const confirmation_dialog_parameters := [
	["Anything", "Anything", "Anything", "Anything", Callable(), Callable(), true],
	["Anything", "Anything", "Anything", "Anything", Callable(), Callable(), false],
]
const menu_button_parameters := [
	[false, "Test"],
	[true, ""],
]
const single_line_input_parameters := [
	["", "", Callable(), true],
	["", "", Callable(), false],
]

var factory: NodeFactory

func before() -> void:
	factory = NodeFactory.new()
	add_child(factory)


func test_confirmation_dialog(
		text := "", ok_text := "OK", cancel_text := "Cancel", title := "Please Confirm",
		canceled := Callable(), confirmed := Callable(), show := true, test_parameters := confirmation_dialog_parameters
) -> void:
	assert_error(add_child.bind(factory.confirmation_dialog(text, ok_text, cancel_text, title, canceled, confirmed, show))).is_success()
	assert_bool(get_child(-1).visible).is_equal(show)


func test_menu_button(switch_on_hover := false, text := "", test_parameters := menu_button_parameters) -> void:
	assert_error(add_child.bind(factory.menu_button(switch_on_hover, text))).is_success()


func test_signle_line_input(
		placeholder := "", button_text := "OK", output := Callable(), show := true, test_parameters := single_line_input_parameters
) -> void:
	assert_error(add_child.bind(factory.signle_line_input(placeholder, button_text, output, show))).is_success()
	assert_bool(get_child(-1).visible).is_equal(show)
	assert_error(get_child(-1).hide).is_success()
