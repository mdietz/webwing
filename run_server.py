import sys
import werkzeug.serving
from gevent.pywsgi import WSGIServer
from webwing import create_app

@werkzeug.serving.run_with_reloader
def run_server():
  app = create_app()
  http_server = WSGIServer(('0.0.0.0',8000), app)
  sys.stderr.write("Now serving on port 8000...\n")
  sys.stderr.flush()
  http_server.serve_forever()

if __name__ == "__main__":
  run_server()
