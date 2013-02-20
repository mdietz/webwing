# coding=utf-8

class DefaultConfig(object):
  """Default configuration for webwing app"""
  DEBUG = True

  APP_NAME = u"webwing"

  COMPILED_ASSET_PATH = "assets"

  # in production, we concatenate our assets and minify them
  COMPILED_JS = False
  COMPILED_CSS = False
  COMPILED_VENDOR_JS = False
