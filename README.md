# Neptunium

A native desktop browser project for Windows and Linux, using Servo to render websites and Bing for search. Tabs, navigation, bookmarks, and settings are native Rust/egui controls. HTML is used only for bundled new-tab and about pages.

This is an experimental browser. Windows release builds compile successfully, but renderer startup and runtime compatibility still need work. It is not ready for everyday or sensitive browsing.

## Current source features

- Neptunium window branding, supplied crystal icon, dark purple appearance.
- Scrollable tabs above the address bar, new tabs and windows, close-tab controls.
- Back, forward, reload, Home, address bar, and connection information.
- Bing search with encoded query text; no remote address suggestions.
- Local bookmarks, add/remove controls, bookmarks bar, and native manager.
- Native settings for light/dark appearance and bookmarks-bar visibility.
- Per-tab zoom controls and reset.
- Bundled `neptunium:newtab` and `neptunium:about` pages with no remote resources.
- Separate local profile, respecting the engine's `--config-dir` option.
- No added telemetry, account system, cloud sync, or browsing-history database.

Shortcuts include Ctrl+L (address), Ctrl+T (new tab), Ctrl+W (close tab), Ctrl+D (bookmark), Ctrl+R (reload), Alt+Left/Right, and Ctrl+1…9 (tab selection). Runtime verification remains required.

## Prepare source

Servo is pinned to `471f5decafec4c2cbf7d3004db4ea10823548d8d`. The `engine/` upstream checkout is excluded from project Git tracking. All native modifications, including new Rust modules, are preserved in `patches/neptunium.patch`. Prepare scripts copy the bundled pages and supplied logo. Upstream license notices remain in place.

Windows:

```powershell
.\scripts\prepare.ps1
```

Linux:

```sh
sh scripts/prepare.sh
```

The scripts recognize an already-patched checkout and refuse conflicting edits or a different engine revision. The large upstream tests directory is omitted by sparse checkout. Enable it before running Servo's full suites with `git -C engine sparse-checkout disable`.

## Build and launch

Follow [Servo's build requirements](https://book.servo.org/building/building.html) and the pinned engine's README. Windows needs rustup, uv, Visual Studio C++ tools, ATL, a supported Windows SDK, LLVM, and other platform dependencies. Allow substantial free space for toolchains and build output.

Windows:

```powershell
cd engine
.\mach.ps1 bootstrap
.\mach.ps1 build --release
cd ..
.\scripts\launch.ps1
```

Linux:

```sh
cd engine
./mach bootstrap
./mach build --release
cd ..
sh scripts/launch.sh
```

Both launchers request multiprocess rendering. The Linux launcher also requests Servo's sandbox and fails if the platform cannot provide it. This Servo revision does **not** implement a Windows renderer sandbox; process separation alone does not replace one.

## Verification

Windows release builds have compiled with both the dummy and GStreamer media backends. The native bookmarks/settings module passes four tests. The first multiprocess runtime test failed to start a renderer; startup changes are included but still need runtime verification. Linux and GitHub Actions have not yet been tested.

Source checks:

```powershell
python -m pip install -r requirements-dev.txt
python scripts/check-source.py
cargo +1.99.1 test --locked --manifest-path checks/native/Cargo.toml
```

These verify Rust grammar, patch reproducibility, local-page resource policy, search destinations, and bundled assets. They do not type-check Rust or prove that the application runs. PowerShell scripts also passed syntax parsing. Additional Rust regression tests cover search encoding and domain recognition. The full browser test suite and runtime checks remain outstanding.

## Privacy boundaries

Microsoft Bing receives submitted queries, your IP address, and ordinary request metadata. Result pages and other websites may set cookies or collect data. Bookmarks intentionally store URLs you save. Bookmarks and appearance settings stay in the selected local profile.

Built-in pages contain no JavaScript or remote resources and use a restrictive content security policy. The new internal protocol exposes only fixed bundled pages, without privileged engine API access. The complete engine still needs an audit for background connections and storage behavior.

Tracker blocking, fingerprinting defenses, signed automatic updates, downloads management, extension support, and a complete security review are not provided by this version. Use it for development rather than sensitive browsing. Any future IDE integration must stay outside web content's permissions.

## License

Original project code: MIT. Modified Servo files retain upstream licenses, including MPL-2.0 where indicated. The supplied logo is excluded from the MIT license until its ownership and redistribution permission are established.
