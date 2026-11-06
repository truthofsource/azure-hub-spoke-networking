"""Loopback-only source topology viewer; no Azure calls."""
from http.server import BaseHTTPRequestHandler,HTTPServer
from pathlib import Path
import json,sys,argparse
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT))
from lab.topology import load,checks
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path=='/':data=(ROOT/'preview/index.html').read_bytes();kind='text/html; charset=utf-8'
        elif self.path=='/data.json':
            t=load();data=json.dumps({'topology':t,'checks':checks(t)}).encode();kind='application/json'
        else:self.send_error(404);return
        self.send_response(200);self.send_header('Content-Type',kind);self.send_header('Cache-Control','no-store');self.end_headers();self.wfile.write(data)
    def log_message(self,*args):pass
if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--port',type=int,default=8137);args=parser.parse_args()
    print(f'Local reference: http://127.0.0.1:{args.port}',flush=True);HTTPServer(('127.0.0.1',args.port),Handler).serve_forever()
