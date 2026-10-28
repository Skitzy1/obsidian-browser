# Contributing

Obsidian is early in development. Small changes that improve browser behavior,
privacy, compatibility, or maintainability are welcome.

## Working on the browser

1. Run the prepare script for your platform.
2. Make native changes under `engine/ports/servoshell/`.
3. Add new source files to the engine diff with `git -C engine add -N path/to/file`.
4. Export the engine diff with `scripts/export-patch.ps1` or `scripts/export-patch.sh`.
5. Run the relevant checks and describe their results in the pull request.

The root repository keeps the Servo revision and patch rather than copying the
entire engine. Do not commit build outputs, profiles, toolchains, downloaded
dependencies, or personal machine setup scripts. Bundled pages live in the root
and are copied into the engine by the prepare scripts.

## Checks

```sh
python -m pip install -r requirements-dev.txt
python scripts/check-source.py
cargo +1.99.1 test --locked --manifest-path checks/native/Cargo.toml
```

The native check crate compiles the actual bookmarks/settings module without
linking the whole engine. It does not replace building and testing the browser.
For native interface changes, build the application and check navigation,
keyboard focus, tabs, and the feature you changed on the affected platform.

## Code and comments

Follow the surrounding Rust style and run rustfmt on changed files. Keep names
specific. Add comments when they explain a constraint or a decision that would
otherwise be easy to miss. Preserve upstream copyright and license notices.

## Privacy changes

Describe any new network destination, data saved to disk, or requested
permission in the pull request. Keep remote services out of startup and the
address bar unless the user deliberately enables them. Submitted Bing searches
are an existing network destination and must remain clearly identified.

Use the process in [SECURITY.md](SECURITY.md) for vulnerabilities.
