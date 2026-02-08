"""Test spec-driven-workflow/SKILL.md line count compliance."""
import os

def test_spec_driven_workflow_skill_line_count():
    """Verify spec-driven-workflow/SKILL.md is ≤200 lines."""
    skill_file = ".claude/skills/spec-driven-workflow/SKILL.md"

    assert os.path.exists(skill_file), f"File not found: {skill_file}"

    with open(skill_file, 'r') as f:
        lines = f.readlines()

    line_count = len(lines)

    # Must be ≤200 lines (Vibe Coding standard)
    assert line_count <= 200, f"SKILL.md has {line_count} lines, must be ≤200"

    print(f"✓ spec-driven-workflow/SKILL.md: {line_count} lines (≤200)")
