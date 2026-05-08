# Agent Instructions

## Pull Request Authoring

When creating or updating a pull request, write for reviewer throughput and future history.

- Keep the pull request focused on one purpose. If the work has unrelated parts, split it or call out the boundary clearly.
- Use a specific title that says what changed.
- Structure the description with `Summary`, `Why`, `Review Notes`, `Validation`, and `Risk` when the change is non-trivial.
- Explain both what changed and why it was needed. Include important tradeoffs that are not obvious from the diff.
- Give reviewers a map when multiple areas changed: where to start, what files matter most, and what deserves extra scrutiny.
- List concrete validation commands and manual checks. Say clearly when something was not tested.
- Link related issues, pull requests, design notes, or follow-up work when available.
- Do not add screenshots unless visual appearance is part of the review.
