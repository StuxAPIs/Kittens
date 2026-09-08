import os
import re
import sys
import json
import random
import secrets
import datetime

import markdown as markdown_lib
from collections import namedtuple
from quart import Quart, jsonify, send_from_directory, send_file, render_template, redirect, abort

LEGAL_PAGES = ("privacy", "terms", "cookies", "imprint", "disclaimer", "opt-out")

with open("VERSION.md", encoding="utf-8") as f:
    VERSION = f.read().strip()

# Checking if you have config.json on your API
try:
    with open("config.json", encoding='utf-8') as data:
        config = json.load(data, object_hook=lambda d: namedtuple('X', d.keys())(*d.values()))
        domain = config.domain
        if config.localhost:
            domain = "http://127.0.0.1:" + str(config.port) + "/"
except FileNotFoundError:
    print("You need to make a config file to be able to run this API")
    sys.exit()


app = Quart(__name__)

# Cache all images
cache_images = [img for img in os.listdir(config.imagefolder)]


def randomize(dir, checker):
    """ Scout the images folder and giving token names to files missing """
    for file in os.listdir(dir):
        name = file.split(".")
        if not name[0].endswith(checker):
            os.rename(f"{dir}/{file}", f"{dir}/{secrets.token_urlsafe(8)}{checker}.{name[-1]}")


@app.route("/")
async def index():
    return await render_template(
        'index.html', config=config,
        background=random.choice(cache_images), images=len(cache_images),
        version=VERSION, year=datetime.date.today().year
    )


@app.route("/changelog")
async def changelog():
    with open("CHANGELOG.md", encoding="utf-8") as f:
        raw = f.read()

    # Drop the leading "# Changelog" title and intro prose - the page
    # already has its own header, and the version/date headings are what
    # actually matter here.
    body = re.sub(r"^# Changelog\n.*?(?=\n## )", "", raw, flags=re.DOTALL)
    changelog_html = markdown_lib.markdown(body, extensions=["fenced_code"])

    return await render_template(
        "changelog.html", config=config, domain=domain,
        changelog_html=changelog_html
    )


@app.route("/legal")
async def legal():
    return await render_template("legal/index.html", config=config, domain=domain)


@app.route("/legal/<slug>")
async def legal_page(slug):
    if slug not in LEGAL_PAGES:
        abort(404)
    return await render_template(f"legal/{slug}.html", config=config, domain=domain)


# This is just for the memes, the holy 418 error \o/
@app.route("/pup")
@app.route("/puppie")
@app.route("/puppy")
@app.route("/dog")
@app.route("/doggo")
@app.route("/doggie")
@app.route("/doggy")
@app.route("/418")
async def pup():
    return await render_template("418.html"), 418


@app.route("/<filename>")
async def kitten(filename):
    return await send_from_directory(config.imagefolder, filename)


@app.route("/assets/<path:filename>")
async def template_images(filename):
    return await send_from_directory("templates/assets", filename)

@app.route("/random")
async def randomkitten():
    return redirect (domain + random.choice(cache_images))

@app.route("/randomfile")
async def randomfilekitten():
    return await send_from_directory(config.imagefolder, random.choice(cache_images))

@app.route("/randomaf")
async def randomafkitten():
    choose_random = random.choice(cache_images)
    name = choose_random.split(".")

    return await send_file(
        f"{config.imagefolder}/{choose_random}",
        mimetype=f"image/{name[-1] if name[-1] != 'jpg' else 'jpeg'}",
        attachment_filename=choose_random
    )


@app.route("/random.json")
async def randomkittenJSON():
    return jsonify({
        "file": domain + random.choice(cache_images)
    })


randomize(config.imagefolder, config.suffix)
app.run(port=config.port, debug=config.debug)
