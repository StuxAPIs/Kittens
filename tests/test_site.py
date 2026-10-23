"""Run with: python -m unittest discover -s tests -v   (from the repo root)

Covers the Discord embed, the favicon set, and the changelog renderer's handling of
Date Version headings. index.py starts the server on import, so the parts of it under
test are pulled out with ast instead of importing the module.
"""
import ast
import json
import os
import re
import struct
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)

import discord_embed as de  # noqa: E402

ALLOWED_TYPES = {1, 2, 9, 10, 11, 12, 14, 17}
BUTTON_KEYS = {"id", "type", "url", "style", "label", "emoji", "disabled"}
DOMAIN = "https://kittens.example.com/"


def walk(components):
    for c in components:
        yield c
        yield from walk(c.get("components", []))
        if "accessory" in c:
            yield from walk([c["accessory"]])


def all_embeds():
    nasty = "*Bold* _it_ ~~s~~ `c` |sp| [l](x) \ </script><b>"
    yield de.home_embed(DOMAIN, "Kittens", "An API that provides random images of kittens", 42)
    yield de.home_embed(DOMAIN, nasty, nasty, 1)
    for path in ("about", "changelog", "legal", "legal/privacy", "legal/opt-out"):
        yield de.page_embed(DOMAIN, "Page", "Description", path)
    yield de.page_embed(DOMAIN, nasty, "# heading\n> quote\n- list " + nasty, "legal/x")


def parse(tag):
    m = re.fullmatch(r'<script id="discord:component-embed" type="application/json">(.*)</script>', tag, re.S)
    assert m, tag[:80]
    return json.loads(m.group(1)), m.group(1)


class DiscordEmbedTest(unittest.TestCase):
    def test_every_page_type_is_valid_and_small(self):
        for tag in all_embeds():
            data, raw = parse(tag)
            self.assertLessEqual(len(raw.encode("utf-8")), 3000)
            root = data["component"]
            self.assertEqual(root["type"], 17)
            inner = list(walk(root["components"]))
            self.assertNotIn(17, [c["type"] for c in inner])
            self.assertLessEqual(len(inner) + 1, 40)
            for c in inner:
                self.assertIn(c["type"], ALLOWED_TYPES)
                if c["type"] == 2:
                    self.assertEqual(c["style"], 5)
                    self.assertTrue(set(c) <= BUTTON_KEYS)
                    self.assertRegex(c["url"], r"^https?://")

    def test_markdown_is_escaped_not_literal_dollar_one(self):
        self.assertEqual(de.md("a*b_c"), "a\*b\_c")
        self.assertEqual(de.md("# x"), "\# x")
        for tag in all_embeds():
            self.assertNotIn("$1", tag)

    def test_script_cannot_close_early(self):
        for tag in all_embeds():
            self.assertEqual(tag.count("</script>"), 1)
            self.assertTrue(tag.endswith("</script>"))

    def test_over_limit_is_left_out(self):
        tag = de.page_embed(DOMAIN, "x", "y" * 4000, "about")
        self.assertTrue(tag.startswith("<!-- discord:component-embed left out"))


class FaviconTest(unittest.TestCase):
    def path(self, name):
        return os.path.join(ROOT, "public", name)

    def test_ico_has_png_16_32_48(self):
        d = open(self.path("favicon.ico"), "rb").read()
        n = struct.unpack("<H", d[4:6])[0]
        sizes = sorted(d[6 + 16 * i] for i in range(n))
        self.assertEqual(sizes, [16, 32, 48])
        self.assertIn(b"\x89PNG", d)

    def test_manifest(self):
        m = json.load(open(self.path("site.webmanifest"), encoding="utf-8"))
        self.assertEqual(m["start_url"], "/")
        self.assertEqual(m["display"], "browser")
        by = {(i["sizes"], i.get("purpose")) for i in m["icons"]}
        self.assertTrue({("192x192", None), ("512x512", None), ("512x512", "maskable")} <= by)
        for i in m["icons"]:
            self.assertTrue(os.path.exists(self.path(i["src"].lstrip("/"))))

    def test_root_files_are_routed(self):
        src = open(os.path.join(ROOT, "index.py"), encoding="utf-8").read()
        for name in ("favicon.ico", "apple-touch-icon.png", "site.webmanifest"):
            self.assertIn('"%s"' % name, src)
        self.assertIn("application/manifest+json", src)

    def test_every_head_includes_the_icon_tags(self):
        for base, _, files in os.walk(os.path.join(ROOT, "templates")):
            for f in files:
                text = open(os.path.join(base, f), encoding="utf-8").read()
                if "<head" in text:
                    self.assertIn('{% include "_head_extra.html" %}', text, f)


def changelog_funcs():
    tree = ast.parse(open(os.path.join(ROOT, "index.py"), encoding="utf-8").read())
    keep = [n for n in tree.body if (isinstance(n, ast.FunctionDef) and n.name == "sort_changelog_sections")
            or (isinstance(n, ast.Assign) and getattr(n.targets[0], "id", "") == "CHANGELOG_ORDER")]
    ns = {"re": re}
    exec(compile(ast.Module(keep, []), "index.py", "exec"), ns)
    return ns


class ChangelogTest(unittest.TestCase):
    def test_date_version_headings_keep_and_sort_sections(self):
        ns = changelog_funcs()
        md = ("## v26.10.23-1\n\n### Deprecated\n\n- d\n\n### Fixed\n\n- f\n\n### Added\n\n- a\n\n"
              "## v26.10.23\n\n### Security\n\n- s\n\n### Mystery\n\n- m\n\n### Changed\n\n- c\n")
        out = ns["sort_changelog_sections"](md)
        self.assertEqual(re.findall(r"^## (v\S+)", out, re.M), ["v26.10.23-1", "v26.10.23"])
        self.assertEqual(re.findall(r"^### (\w+)", out, re.M),
                         ["Added", "Fixed", "Deprecated", "Changed", "Security", "Mystery"])

    def test_real_changelog_leads_with_a_date_version(self):
        first = re.search(r"^## v(\S+)", open(os.path.join(ROOT, "CHANGELOG.md"), encoding="utf-8").read(), re.M)
        self.assertRegex(first.group(1), r"^\d{2}\.\d{2}\.\d{2}(-\d+)?$")


if __name__ == "__main__":
    unittest.main()
