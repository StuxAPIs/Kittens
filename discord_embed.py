"""Discord component embed: a custom link preview in <head>.

Discord reads <script id="discord:component-embed" type="application/json"> and shows
it instead of the Open Graph card (which stays in the page as the fallback). Kept in its
own module so tests and templates can use it without starting the app (index.py runs the
server on import).
"""
import json
import re

ACCENT = "#d35400"
ICON_URL = "https://global.media.stuxapis.net/kittens/icon.png"
MAX_BYTES = 3000


def md(text):
    """Escapes Discord markdown so data (names, descriptions) shows as plain text."""
    # Inline formatting, link brackets and backslashes anywhere; headings, quotes and lists only at a line start.
    text = re.sub(r"([\*_~`|\[\]])", lambda m: "\\" + m.group(1), str(text))
    return re.sub(r"(?m)^([#>-])", lambda m: "\\" + m.group(1), text)


def text(markdown):
    return {"type": 10, "content": markdown}


def buttons(links):
    """A row of link buttons: [(label, absolute URL)]. Buttons only carry these keys."""
    return {"type": 1, "components": [
        {"type": 2, "style": 5, "label": label[:80], "url": url} for label, url in links
    ]}


def section(markdown):
    """Text with the Kittens icon beside it."""
    return {"type": 9, "components": [text(markdown)],
            "accessory": {"type": 11, "media": {"url": ICON_URL}}}


def payload(components, accent=ACCENT):
    """Encoded payload, or None when over Discord's 3,000-byte limit."""
    data = {"component": {"type": 17, "accent_color": int(accent.lstrip("#"), 16), "components": components}}
    raw = json.dumps(data, ensure_ascii=False, separators=(",", ":"))
    raw = raw.replace("</", "<\/")  # can't close the <script> early
    return None if len(raw.encode("utf-8")) > MAX_BYTES else raw


def embed(components, accent=ACCENT):
    """The <script> tag, or a comment when over the limit (Discord then shows the Open Graph preview)."""
    raw = payload(components, accent)
    if raw is None:
        return "<!-- discord:component-embed left out: over %d bytes -->" % MAX_BYTES
    return '<script id="discord:component-embed" type="application/json">' + raw + "</script>"


def _site(domain):
    return "-# [Kittens](" + domain + ")\n"


def home_embed(domain, title, description, images):
    return embed([
        section("# [" + md(title) + "](" + domain + ")\n**" + md(description) + "**\n"
                + str(images) + (" kitten image" if images == 1 else " kitten images") + ", free to use. Ask for one and you get one, no key needed."),
        {"type": 14},
        text("### Endpoints\n`/random` redirect · `/random.json` JSON · `/randomfile` direct · `/randomaf` download"),
        buttons([("Random Kitten", domain + "random"), ("JSON", domain + "random.json"),
                 ("About", domain + "about")]),
    ])


def page_embed(domain, title, description, path):
    """Any other page: its name and what it is, with a way to a kitten."""
    url = domain + path.lstrip("/")
    return embed([
        section(_site(domain) + "## [" + md(title) + "](" + url + ")\n" + md(description)),
        buttons([("Open", url), ("Random Kitten", domain + "random")]),
    ])
