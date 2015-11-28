# Reverse proxy + static file server

import sys

if len(sys.argv) < 2:
    print "Usage: python serve_app.py <relative path to static assets>"
    sys.exit()

from flask import Flask, request, send_from_directory, Response
import requests
import traceback

_STATIC_ASSET_PATH = sys.argv[1]
_BASE_URL = 'http://localhost:8090'

flask_app = Flask(__name__)

def build_proxy_request(method):
    if method == 'GET':
        return requests.get
    if method == 'POST':
        return requests.post
    if method == 'PUT':
        return requests.put
    if method == 'DELETE':
        return requests.delete
    if method == 'OPTIONS':
        return requests.options

@flask_app.route('/query/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
def reverse_proxy(path):
    try:
        # build request components
        method = request.method
        url = _BASE_URL + '/' + path
        headers = { each[0] : each[1] for each in request.headers }
        body = request.data
        query_params = { param : request.args.get(param) for param in request.args }

        # make request to service
        proxy_req = build_proxy_request(method)
        proxy_res = proxy_req(url, data=body, headers=headers, params=query_params)

        # parse service response
        status = proxy_res.status_code
        body = proxy_res.text
        headers = { param : proxy_res.headers.get(param) for param in proxy_res.headers }

        # form response to client
        res = Response(body)
        res.status_code = status
        res.headers = headers
        return res
    except Exception as e:
        print(traceback.format_exc())
        return str(e), 500

@flask_app.route('/<path:filename>')
def static_assets(filename):
    try:
        return send_from_directory(_STATIC_ASSET_PATH, filename)
    except Exception as e:
        print(traceback.format_exc())
        return str(e), 500

if __name__ == '__main__':
    flask_app.run(debug=True)