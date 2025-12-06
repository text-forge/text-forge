# GdUnit generated TestSuite
class_name ChangelogValidationTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite for validating CHANGELOG.md structure and content
const __source = 'res://CHANGELOG.md'
const CHANGELOG_PATH = "res://CHANGELOG.md"

var changelog_content: String

func before_test() -> void:
	# Load changelog content
	var file = FileAccess.open(CHANGELOG_PATH, FileAccess.READ)
	if file:
		changelog_content = file.get_as_text()
		file.close()
	else:
		changelog_content = ""

# ===== FILE EXISTENCE AND READABILITY TESTS =====

func test_changelog_file_exists() -> void:
	assert_bool(FileAccess.file_exists(CHANGELOG_PATH)).is_true()

func test_changelog_is_readable() -> void:
	var file = FileAccess.open(CHANGELOG_PATH, FileAccess.READ)
	assert_object(file).is_not_null()
	if file:
		file.close()

func test_changelog_not_empty() -> void:
	assert_str(changelog_content).is_not_empty()

func test_changelog_has_minimum_length() -> void:
	# Changelog should have at least 500 characters
	assert_int(changelog_content.length()).is_greater_equal(500)

# ===== HEADER AND STRUCTURE TESTS =====

func test_changelog_has_title() -> void:
	assert_bool(changelog_content.contains("# Changelog")).is_true()

func test_changelog_references_keep_a_changelog() -> void:
	assert_bool(changelog_content.contains("Keep a Changelog")).is_true()

func test_changelog_references_semantic_versioning() -> void:
	assert_bool(changelog_content.contains("Semantic Versioning")).is_true()

func test_changelog_has_unreleased_section() -> void:
	assert_bool(changelog_content.contains("## [unreleased]")).is_true()

func test_changelog_sections_properly_formatted() -> void:
	# Check for standard section headers
	var sections = ["### Added", "### Changed", "### Removed", "### Fixed"]
	for section in sections:
		if changelog_content.contains(section):
			# If section exists, verify it's properly formatted
			var lines = changelog_content.split("\n")
			var found_proper_format = false
			for line in lines:
				if line.strip_edges() == section:
					found_proper_format = true
					break
			assert_bool(found_proper_format).is_true() \
				.append_failure_message("Section '" + section + "' not properly formatted")

# ===== VERSION FORMAT TESTS =====

func test_version_headers_follow_semver_format() -> void:
	# Version headers should be in format: ## [vX.Y.Z] or ## [vX.Y-rcN] or ## [vX.Y-betaN]
	var regex = RegEx.new()
	regex.compile("^## \\[v\\d+\\.\\d+(-[a-z]+\\d*)?\\]")
	var lines = changelog_content.split("\n")

	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		if line.begins_with("## [v"):
			var matches = regex.search(line)
			assert_object(matches).is_not_null() \
				.append_failure_message("Invalid version format at line " + str(i + 1) + ": " + line)

func test_unreleased_section_at_top() -> void:
	# [unreleased] should appear before any version sections
	var unreleased_pos = changelog_content.find("## [unreleased]")
	var first_version_regex = RegEx.new()
	first_version_regex.compile("## \\[v\\d+")
	var first_version_match = first_version_regex.search(changelog_content)

	if first_version_match:
		var first_version_pos = first_version_match.get_start()
		assert_int(unreleased_pos).is_less(first_version_pos) \
			.append_failure_message("[unreleased] section should appear before version sections")

# ===== PR REFERENCE TESTS =====

func test_pr_references_properly_formatted() -> void:
	# PR references should be in format: ([#XXX](https://github.com/text-forge/text-forge/pull/XXX))
	var regex = RegEx.new()
	regex.compile("\\(\\[#(\\d+)\\]\\(https://github\\.com/text-forge/text-forge/pull/(\\d+)\\)\\)")
	var matches = regex.search_all(changelog_content)

	for match in matches:
		var pr_number_1 = match.get_string(1)
		var pr_number_2 = match.get_string(2)
		# Both PR numbers should match
		assert_str(pr_number_1).is_equal(pr_number_2) \
			.append_failure_message("PR reference mismatch: #" + pr_number_1 + " vs pull/" + pr_number_2)

func test_pr_references_exist() -> void:
	# Changelog should contain at least some PR references
	var regex = RegEx.new()
	regex.compile("\\[#\\d+\\]")
	var matches = regex.search_all(changelog_content)
	assert_int(matches.size()).is_greater(0) \
		.append_failure_message("No PR references found in changelog")

func test_pr_reference_format_consistency() -> void:
	# All PR references should follow the same format
	var lines = changelog_content.split("\n")
	var pr_reference_regex = RegEx.new()
	pr_reference_regex.compile("\\[#\\d+\\]")

	for i in range(lines.size()):
		var line = lines[i]
		if pr_reference_regex.search(line):
			# If line contains PR reference, it should be properly formatted
			var full_format_regex = RegEx.new()
			full_format_regex.compile("\\[#\\d+\\]\\(https://github\\.com/text-forge/text-forge/pull/\\d+\\)")
			var matches = full_format_regex.search_all(line)
			assert_int(matches.size()).is_greater_equal(1) \
				.append_failure_message("Improperly formatted PR reference at line " + str(i + 1))

# ===== CONTENT STRUCTURE TESTS =====

func test_bullet_points_use_hyphens() -> void:
	# Bullet points should use hyphens (-) not asterisks (*)
	var lines = changelog_content.split("\n")
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		# Check if this looks like a bullet point
		if line.length() > 0 and (line[0] == '-' or line[0] == '*'):
			# Skip section headers (###)
			if not line.begins_with("###"):
				# If it's a bullet, ensure it uses hyphen
				assert_bool(line[0] == '-').is_true() \
					.append_failure_message("Line " + str(i + 1) + " uses asterisk instead of hyphen for bullet")

func test_no_trailing_whitespace_in_lines() -> void:
	var lines = changelog_content.split("\n")
	for i in range(lines.size()):
		var line = lines[i]
		if line.length() > 0:
			# Check if line ends with whitespace (excluding newline)
			var last_char = line[line.length() - 1]
			assert_bool(last_char != ' ' and last_char != '\t').is_true() \
				.append_failure_message("Line " + str(i + 1) + " has trailing whitespace")

func test_consistent_indentation() -> void:
	# Indentation should be consistent (2 or 4 spaces, not mixed)
	var lines = changelog_content.split("\n")
	var indentation_sizes = {}

	for line in lines:
		if line.length() > 0 and (line[0] == ' ' or line[0] == '\t'):
			var indent_count = 0
			for c in line:
				if c == ' ':
					indent_count += 1
				elif c == '\t':
					# Tabs are inconsistent, fail immediately
					assert_bool(false).is_true() \
						.append_failure_message("Tab character found in indentation")
					return
				else:
					break

			if indent_count > 0:
				indentation_sizes[indent_count] = true

	# If we have indentation, check it's consistent (multiples of 2 or 4)
	for indent_size in indentation_sizes.keys():
		var is_valid = indent_size % 2 == 0
		assert_bool(is_valid).is_true() \
			.append_failure_message("Inconsistent indentation size: " + str(indent_size))

# ===== LINK VALIDATION TESTS =====

func test_github_links_use_https() -> void:
	# All GitHub links should use HTTPS
	assert_bool(not changelog_content.contains("http://github.com")).is_true() \
		.append_failure_message("Found HTTP GitHub link, should be HTTPS")

func test_github_links_point_to_correct_repo() -> void:
	# All GitHub links should point to text-forge/text-forge
	var github_regex = RegEx.new()
	github_regex.compile("https://github\\.com/([^/]+)/([^/]+)")
	var matches = github_regex.search_all(changelog_content)

	for match in matches:
		var org = match.get_string(1)
		var repo = match.get_string(2)
		assert_str(org).is_equal("text-forge") \
			.append_failure_message("GitHub link points to wrong organization: " + org)
		assert_str(repo).is_equal("text-forge") \
			.append_failure_message("GitHub link points to wrong repository: " + repo)

# ===== DATE FORMAT TESTS =====

func test_version_dates_properly_formatted() -> void:
	# Dates should be in format: YYYY-MM-DD or YYYY-M-D
	var date_regex = RegEx.new()
	date_regex.compile("## \\[v[^\\]]+\\] - (\\d{4}-\\d{1,2}-\\d{1,2})")
	var matches = date_regex.search_all(changelog_content)

	for match in matches:
		var date_str = match.get_string(1)
		var parts = date_str.split("-")
		assert_int(parts.size()).is_equal(3) \
			.append_failure_message("Invalid date format: " + date_str)

		# Validate year, month, day ranges
		var year = int(parts[0])
		var month = int(parts[1])
		var day = int(parts[2])

		assert_int(year).is_greater_equal(2020) \
			.append_failure_message("Suspicious year in date: " + date_str)
		assert_int(month).is_greater_equal(1).is_less_equal(12) \
			.append_failure_message("Invalid month in date: " + date_str)
		assert_int(day).is_greater_equal(1).is_less_equal(31) \
			.append_failure_message("Invalid day in date: " + date_str)

# ===== MARKDOWN SYNTAX TESTS =====

func test_no_broken_markdown_links() -> void:
	# Check for common broken markdown link patterns
	assert_bool(not changelog_content.contains("](]")).is_true() \
		.append_failure_message("Found broken markdown link: ](]")
	assert_bool(not changelog_content.contains("[](")).is_true() \
		.append_failure_message("Found empty markdown link: []()")

func test_code_blocks_properly_delimited() -> void:
	# Check that backticks are balanced
	var backtick_count = 0
	for c in changelog_content:
		if c == '`':
			backtick_count += 1

	# Should be even number (opening and closing)
	assert_int(backtick_count % 2).is_equal(0) \
		.append_failure_message("Unbalanced backticks in changelog")

func test_no_duplicate_headers() -> void:
	# Check for duplicate section headers within the same version
	var lines = changelog_content.split("\n")
	var current_version_sections = []

	for line in lines:
		var trimmed = line.strip_edges()
		if trimmed.begins_with("## ["):
			# New version section, reset
			current_version_sections = []
		elif trimmed.begins_with("### "):
			# Section header
			assert_bool(not (trimmed in current_version_sections)).is_true() \
				.append_failure_message("Duplicate section header: " + trimmed)
			current_version_sections.append(trimmed)

# ===== REGRESSION TESTS =====

func test_maintains_chronological_order() -> void:
	# Versions should be in reverse chronological order (newest first)
	var version_regex = RegEx.new()
	version_regex.compile("## \\[v(\\d+)\\.(\\d+)(-[a-z]+\\d*)?\\]")
	var matches = version_regex.search_all(changelog_content)

	if matches.size() > 1:
		for i in range(matches.size() - 1):
			var current_major = int(matches[i].get_string(1))
			var current_minor = int(matches[i].get_string(2))
			var next_major = int(matches[i + 1].get_string(1))
			var next_minor = int(matches[i + 1].get_string(2))

			# Current version should be >= next version
			var current_version_num = current_major * 100 + current_minor
			var next_version_num = next_major * 100 + next_minor

			assert_int(current_version_num).is_greater_equal(next_version_num) \
				.append_failure_message("Versions not in chronological order")

# ===== CONTENT QUALITY TESTS =====

func test_entries_have_descriptions() -> void:
	# Each bullet point should have descriptive text, not just PR references
	var lines = changelog_content.split("\n")
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		if line.begins_with("- "):
			# Extract text before PR reference
			var pr_pos = line.find("([#")
			if pr_pos > 0:
				var description = line.substr(2, pr_pos - 2).strip_edges()
				assert_int(description.length()).is_greater(5) \
					.append_failure_message("Line " + str(i + 1) + " has insufficient description")

func test_api_changes_properly_marked() -> void:
	# API changes should be marked with **API:** prefix
	var lines = changelog_content.split("\n")
	for line in lines:
		if line.contains("API:") or line.contains("api:"):
			# Should use bold markdown
			assert_bool(line.contains("**API:**")).is_true() \
				.append_failure_message("API marker should be bold: **API:**")

func test_action_script_changes_properly_marked() -> void:
	# Action Script changes should be marked with **Action Script:** prefix
	var lines = changelog_content.split("\n")
	for line in lines:
		if line.contains("Action Script:") and not line.contains("**Action Script:**"):
			assert_bool(line.contains("**Action Script:**")).is_true() \
				.append_failure_message("Action Script marker should be bold: **Action Script:**")
