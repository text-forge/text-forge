# GdUnit generated TestSuite
class_name TextForgeTranslatorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/translation_manager.gd'

var text_forge_translator: TextForgeTranslator

func before() -> void:
	text_forge_translator = TextForgeTranslator.new()
	add_child(text_forge_translator)

func test_get_text_from_string_source() -> void:
	assert_str(text_forge_translator.get_text_from_string_source("test", "key,en\ntest,This is test!")).is_equal("This is test!")

func test_get_text_from_string_source_fallback() -> void:
	text_forge_translator.language = "fa"
	assert_str(text_forge_translator.get_text_from_string_source("test", "key,en\ntest,This is test!")).is_equal("This is test!")
	text_forge_translator.language = "en"

func test_get_text_from_string_source_invalid_key() -> void:
	assert_str(text_forge_translator.get_text_from_string_source("invalid", "key,en\ntest,This is test!")).is_equal("invalid")

func test_get_text_from_string_source_invalid_lang() -> void:
	assert_str(text_forge_translator.get_text_from_string_source("test", "key,en_cap\ntest,THIS IS TEST!")).is_equal("test")

func test_get_text_invalid_file() -> void:
	assert_str(text_forge_translator.get_text("test", "res://invalid.csv")).is_equal("test")

func test_set_language_restore_default() -> void:
	text_forge_translator.language = "fa"
	text_forge_translator.fallback = "fa"
	text_forge_translator.set_language()
	assert_str(text_forge_translator.language).is_equal("en")
	assert_str(text_forge_translator.fallback).is_equal("en")

func test_set_language_change() -> void:
	text_forge_translator.set_language("test")
	assert_str(text_forge_translator.language).is_equal("test")


func after() -> void:
	text_forge_translator.set_language("en", "en")
