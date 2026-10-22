"""Render templates/error.html into self-contained pages in errors/ for nginx to serve.

When Kittens itself is down or restarting, nginx answers with 502/503/504 and can't ask the app
to render anything; it also rejects some requests (400, 413) before they reach the app. These
static copies keep those errors on-brand. The CSS is inlined because /assets is served by the app.

Run after changing templates/error.html, ERROR_PAGES in index.py or assets/css/kittens.css:
    python bin/build_static_errors.py
"""
import ast
import json
import os
from types import SimpleNamespace

from jinja2 import Environment, FileSystemLoader

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATIC_CODES = (400, 413, 502, 503, 504)


def error_pages():
    """ERROR_PAGES from index.py, read without importing it (importing starts the server)."""
    tree = ast.parse(open(os.path.join(ROOT, "index.py"), encoding="utf-8").read())
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(getattr(t, "id", None) == "ERROR_PAGES" for t in node.targets):
            return ast.literal_eval(node.value)
    raise SystemExit("ERROR_PAGES not found in index.py")


def main():
    config_file = "config.json" if os.path.exists(os.path.join(ROOT, "config.json")) else "config.json.example"
    config = json.load(open(os.path.join(ROOT, config_file), encoding="utf-8"))
    domain = config["domain"]
    version = open(os.path.join(ROOT, "VERSION.md"), encoding="utf-8").read().strip()
    css = open(os.path.join(ROOT, "assets", "css", "kittens.css"), encoding="utf-8").read()
    css = css.replace("{{ version }}", version).replace("url('../fonts/", f"url('{domain}assets/fonts/")

    env = Environment(loader=FileSystemLoader(os.path.join(ROOT, "templates")), autoescape=True)
    template = env.get_template("error.html")
    pages = error_pages()
    os.makedirs(os.path.join(ROOT, "errors"), exist_ok=True)
    for code in STATIC_CODES:
        title, message = pages[code]
        html = template.render(config=SimpleNamespace(title=config["title"]), domain=domain, version=version,
                               code=code, title=title, message=message, inline_css=css)
        with open(os.path.join(ROOT, "errors", f"{code}.html"), "w", encoding="utf-8", newline="\n") as f:
            f.write(html)
        print(f"errors/{code}.html  {title}")


if __name__ == "__main__":
    main()
