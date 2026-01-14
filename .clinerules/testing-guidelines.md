# Testing Guidelines

## Brief overview

Testing rules for DevContainer features. Focus on positive testing and avoid unreliable negative assertions.

## Rules

- DO NOT write tests that check absence of packages (`! command -v package`)
- Test only what SHOULD be present, not what should be absent
- Use environment variables to make tests conditional based on configuration
- Negative checks are unreliable and may fail unexpectedly
- For cargo extensions use `cargo <command> --version` instead of `command -v cargo-<command>`
- For cargo extensions use `PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH" cargo <command> --version`
- For global crates use `test -f "${CARGO_HOME:-$HOME/.cargo}/bin/<binary>"` instead of `command -v <binary>`
