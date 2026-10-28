"""Source and bundled-page checks. These do not compile or run Servo."""
from html.parser import HTMLParser
from pathlib import Path
import subprocess

import tree_sitter
import tree_sitter_rust

ROOT = Path(__file__).resolve().parent.parent
ENGINE = ROOT / "engine"


class Page(HTMLParser):
    def __init__(self, text):
        super().__init__()
        self.tags = []
        self.feed(text)

    def handle_starttag(self, tag, attrs):
        self.tags.append((tag, dict(attrs)))


def check_page(name):
    page = Page((ROOT / name).read_text(encoding="utf-8"))
    metas = {attrs.get("name", attrs.get("http-equiv")): attrs.get("content")
             for tag, attrs in page.tags if tag == "meta"}
    assert "default-src 'none'" in metas["Content-Security-Policy"]
    assert metas["referrer"] == "no-referrer"
    for tag, attrs in page.tags:
        assert tag not in {"script", "iframe", "object", "embed"}, (name, tag)
        assert not any(key.startswith("on") for key in attrs), (name, tag)
        if tag in {"img", "link", "video", "audio", "source"}:
            source = attrs.get("src", attrs.get("href", ""))
            assert not source.startswith(("http:", "https:", "//")), source
            if source:
                assert (ROOT / source).is_file(), source
        if tag == "form":
            assert attrs["action"] == "https://search.brave.com/search"
            assert attrs.get("method", "get").lower() == "get"
            assert attrs["autocomplete"] == "off"
    print(f"PASS {name}: local resources, CSP, referrer policy, search destination")


def main():
    parser = tree_sitter.Parser(tree_sitter.Language(tree_sitter_rust.language()))
    changed = subprocess.check_output(
        ["git", "-C", str(ENGINE), "diff", "--name-only"], text=True
    ).splitlines()
    count = 0
    for name in changed:
        if name.endswith(".rs"):
            tree = parser.parse((ENGINE / name).read_bytes())
            assert not tree.root_node.has_error, f"Rust syntax error in {name}"
            count += 1
    assert count > 0, "The native engine patch has not been applied"
    print(f"PASS Rust grammar: {count} changed source files (not type checking)")
    subprocess.run(["git", "-C", str(ENGINE), "diff", "--check"], check=True)
    subprocess.run([
        "git", "-C", str(ENGINE), "apply", "--reverse", "--check",
        str(ROOT / "patches/obsidian.patch"),
    ], check=True)
    print("PASS patch matches the working source")
    check_page("start.html")
    check_page("about.html")
    bundled = ENGINE / "resources/resource_protocol"
    expected = (ROOT / "start.html").read_text(encoding="utf-8").replace(
        "img-src 'self'", "img-src resource:"
    ).replace("assets/logo.png", "resource:///obsidian.png")
    assert (bundled / "obsidian-newtab.html").read_text(encoding="utf-8") == expected
    assert (bundled / "obsidian-about.html").read_bytes() == (ROOT / "about.html").read_bytes()
    assert (bundled / "obsidian.png").read_bytes() == (ROOT / "assets/logo.png").read_bytes()
    print("PASS bundled internal pages and logo match project originals")
    print("These source checks do not compile or run the browser.")


if __name__ == "__main__":
    main()
