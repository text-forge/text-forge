# GdUnit generated TestSuite
class_name ShaderValidationTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite for validating main.gdshader
const __shader_source = 'res://core/main.gdshader'

func test_shader_file_exists() -> void:
	assert_bool(FileAccess.file_exists(__shader_source)).is_true()

func test_shader_loads_successfully() -> void:
	var shader = load(__shader_source)
	assert_object(shader).is_not_null()
	assert_object(shader).is_instanceof(Shader)

func test_shader_has_required_uniforms() -> void:
	var shader = load(__shader_source) as Shader
	var code = shader.code

	# Check for required uniform declarations
	assert_bool(code.contains("uniform float hue_shift")).is_true()
	assert_bool(code.contains("uniform float saturation")).is_true()
	assert_bool(code.contains("uniform float brightness")).is_true()
	assert_bool(code.contains("uniform sampler2D SCREEN_TEXTURE")).is_true()

func test_shader_has_hsv_conversion_functions() -> void:
	var shader = load(__shader_source) as Shader
	var code = shader.code

	# Check for RGB to HSV conversion function
	assert_bool(code.contains("vec3 rgb2hsv(vec3 c)")).is_true()
	# Check for HSV to RGB conversion function
	assert_bool(code.contains("vec3 hsv2rgb(vec3 c)")).is_true()

func test_shader_has_fragment_function() -> void:
	var shader = load(__shader_source) as Shader
	var code = shader.code

	assert_bool(code.contains("void fragment()")).is_true()

func test_shader_type_is_canvas_item() -> void:
	var shader = load(__shader_source) as Shader
	var code = shader.code

	assert_bool(code.contains("shader_type canvas_item")).is_true()

func test_shader_material_can_be_created() -> void:
	var shader = load(__shader_source) as Shader
	var material = ShaderMaterial.new()
	material.shader = shader

	assert_object(material).is_not_null()
	assert_object(material.shader).is_equal(shader)

func test_shader_default_uniform_values() -> void:
	var shader = load(__shader_source) as Shader
	var material = ShaderMaterial.new()
	material.shader = shader

	# Set default values and verify they can be retrieved
	material.set_shader_parameter("hue_shift", 0.0)
	material.set_shader_parameter("saturation", 1.0)
	material.set_shader_parameter("brightness", 1.0)

	assert_float(material.get_shader_parameter("hue_shift")).is_equal(0.0)
	assert_float(material.get_shader_parameter("saturation")).is_equal(1.0)
	assert_float(material.get_shader_parameter("brightness")).is_equal(1.0)

func test_shader_hue_shift_parameter() -> void:
	var shader = load(__shader_source) as Shader
	var material = ShaderMaterial.new()
	material.shader = shader

	# Test various hue shift values
	material.set_shader_parameter("hue_shift", 0.5)
	assert_float(material.get_shader_parameter("hue_shift")).is_equal(0.5)

	material.set_shader_parameter("hue_shift", -0.5)
	assert_float(material.get_shader_parameter("hue_shift")).is_equal(-0.5)

	material.set_shader_parameter("hue_shift", 1.0)
	assert_float(material.get_shader_parameter("hue_shift")).is_equal(1.0)

func test_shader_saturation_parameter() -> void:
	var shader = load(__shader_source) as Shader
	var material = ShaderMaterial.new()
	material.shader = shader

	material.set_shader_parameter("saturation", 0.0)
	assert_float(material.get_shader_parameter("saturation")).is_equal(0.0)

	material.set_shader_parameter("saturation", 2.0)
	assert_float(material.get_shader_parameter("saturation")).is_equal(2.0)

func test_shader_brightness_parameter() -> void:
	var shader = load(__shader_source) as Shader
	var material = ShaderMaterial.new()
	material.shader = shader

	material.set_shader_parameter("brightness", 0.0)
	assert_float(material.get_shader_parameter("brightness")).is_equal(0.0)

	material.set_shader_parameter("brightness", 2.0)
	assert_float(material.get_shader_parameter("brightness")).is_equal(2.0)

func test_shader_uid_file_exists() -> void:
	assert_bool(FileAccess.file_exists("res://core/main.gdshader.uid")).is_true()

func test_shader_uid_format() -> void:
	var uid_content = FileAccess.get_file_as_string("res://core/main.gdshader.uid").strip_edges()
	assert_bool(uid_content.begins_with("uid://")).is_true()

func test_color_rect_with_shader_material() -> void:
	# Test that a ColorRect can use this shader
	var rect = auto_free(ColorRect.new())
	var material = ShaderMaterial.new()
	material.shader = load(__shader_source)
	rect.material = material

	assert_object(rect.material).is_not_null()
	assert_object(rect.material).is_instanceof(ShaderMaterial)

func test_shader_all_parameters_together() -> void:
	var shader = load(__shader_source) as Shader
	var material = ShaderMaterial.new()
	material.shader = shader

	# Set all parameters to non-default values
	material.set_shader_parameter("hue_shift", 0.25)
	material.set_shader_parameter("saturation", 1.5)
	material.set_shader_parameter("brightness", 0.8)

	# Verify all can coexist
	assert_float(material.get_shader_parameter("hue_shift")).is_equal(0.25)
	assert_float(material.get_shader_parameter("saturation")).is_equal(1.5)
	assert_float(material.get_shader_parameter("brightness")).is_equal(0.8)
