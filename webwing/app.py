from . import views
from .config import DefaultConfig
from flask import Flask, g, jsonify, request, render_template, redirect, url_for

DEFAULT_APP = "webwing"
DEFAULT_BLUEPRINTS = (
    (views.frontend, "/", None),
    (views.assets, "/assets", None),
    #(views.auth, "/auth", None),
)

def create_app(config=None, app_name=None, blueprints=None):
  if app_name is None:
    app_name = DEFAULT_APP
  if config is None:
    config = DefaultConfig()
  if blueprints is None:
    blueprints = DEFAULT_BLUEPRINTS

  app = Flask(app_name)
  app.config.from_object(config)

  configure_blueprints(app, blueprints)
  configure_before_handlers(app)
  configure_error_handlers(app)
  return app


def check_login():
  pass

def configure_blueprints(app, blueprints):
  for blueprint, url_prefix, login_required in blueprints:
    if login_required:
      blueprint.before_request(check_login)
    app.register_blueprint(blueprint, url_prefix=url_prefix)

def configure_before_handlers(app):
  @app.before_request
  def setup():
    pass

def configure_error_handlers(app):
  @app.errorhandler(404)
  def page_not_found(error):
    if request.is_xhr:
      return jsonify(error="Resource not found")
    return render_template("404.htmljinja", error=error), 404