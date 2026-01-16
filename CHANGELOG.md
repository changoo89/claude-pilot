# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **Agent name case-sensitivity**: Fixed researcher agent name inconsistency in `/00_plan` command documentation
  - Changed "Researcher Agent" to "researcher Agent" throughout `.claude/commands/00_plan.md`
  - Added case-sensitivity warning to `.claude/guides/parallel-execution.md`
  - Created test script `.claude/scripts/test-agent-names.sh` to verify lowercase agent names
  - Prevents silent failures when invoking agents with incorrect case

### Documentation
- Updated Agent Coordination table in `/00_plan` command to use lowercase "researcher"
- Updated Result Merge section to use lowercase "researcher"
- Updated checklist items to use lowercase "researcher"
- Added critical warning about case-sensitive agent names in parallel execution guide

---

## Previous Versions
