# coding=utf-8

from flask import Blueprint, g, render_template, request, current_app
from webwing.views.assets import asset_url

frontend = Blueprint("frontend", __name__)

def read_template(template_name):
  with current_app.open_resource("templates/" + template_name) as template:
    return template.read().decode("utf-8")

def read_shader(shader_name):
  with current_app.open_resource("shaders/" + shader_name) as shader:
    return shader.read().decode("utf-8")

vendor_js_files = [
  "jquery-1.8.2.min.js",
  "three.min.js",
  "ShaderExtras.js",
  "loaders/MTLLoader.js",
  "loaders/OBJLoader.js",
  "loaders/OBJMTLLoader.js",
  "loaders/ColladaLoader.js",
  "Tween.js",
  "controls/TrackballControls.js",
  "Stats.js"
]

@frontend.route('/')
def index():
  mustache_templates = []
  for template in []:
    template_id = template.replace("_", "-") + "-template"
    template_content = read_template(template + ".mustache")
    mustache_templates.append((template_id, template_content))

  shaders = []
  for shader in ["perlin_noise"]:
    shader_content = read_shader(shader + ".shader")
    shaders.append((shader, shader_content))

  coffee_files = ["flight_controls", "util", "ship", "xwing", "tie_interceptor", "star_destroyer", "star-destroyer", "lambda_shuttle", "corvette"]

  stylus_files = []

  return render_template("index.htmljinja",
                         mustache_templates=mustache_templates,
                         shaders=shaders,
                         title=current_app.config["APP_NAME"],
                         debug=current_app.config["DEBUG"],
                         coffee_files=coffee_files,
                         stylus_files=stylus_files,
                         asset_url=asset_url,
                         vendor_js_files=vendor_js_files,
                         compiled_js=current_app.config["COMPILED_JS"],
                         compiled_css=current_app.config["COMPILED_CSS"],
                         compiled_vendor_js=current_app.config["COMPILED_VENDOR_JS"],
                        )
