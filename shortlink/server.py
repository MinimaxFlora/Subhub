#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Kejizero 短链服务 (myurls 协议兼容)
- POST /short  (form: longUrl=base64, 可选 shortKey) -> {"Code":1,"ShortUrl":"https://s.kejizero.xyz/xxx"}
- GET  /<code> -> 302 跳转到原链接
- GET  /       -> 简单首页
SQLite 存储，无需外部依赖（Python3 标准库）。
"""
import base64
import binascii
import cgi
import hashlib
import http.server
import json
import os
import re
import sqlite3
import string
import urllib.parse

DB_PATH = os.environ.get("DB_PATH", "/opt/kejizero-short/urls.db")
BASE_URL = os.environ.get("BASE_URL", "https://short.example.com")  # 容器内由环境变量注入
HTTP_PORT = int(os.environ.get("HTTP_PORT", "7999"))

CHARS = string.ascii_letters + string.digits  # 62 字符集


def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        """CREATE TABLE IF NOT EXISTS urls (
            code TEXT PRIMARY KEY,
            long_url TEXT NOT NULL,
            created_at INTEGER NOT NULL
        )"""
    )
    conn.commit()
    conn.close()


def get_conn():
    return sqlite3.connect(DB_PATH)


def gen_code(seed):
    """基于 longUrl 生成 6 位短码，碰撞时加盐重试"""
    salt = 0
    while True:
        h = hashlib.sha1(f"{seed}|{salt}".encode()).digest()
        code = "".join(CHARS[b % len(CHARS)] for b in h[:6])
        conn = get_conn()
        exists = conn.execute("SELECT 1 FROM urls WHERE code=?", (code,)).fetchone()
        conn.close()
        if not exists:
            return code
        salt += 1


def create_short(long_url, custom_key=None):
    conn = get_conn()
    try:
        if custom_key:
            custom_key = custom_key.strip()
            if not re.fullmatch(r"[A-Za-z0-9_-]{1,32}", custom_key):
                return None, "shortKey 只能包含字母数字下划线横线，长度1-32"
            exists = conn.execute("SELECT 1 FROM urls WHERE code=?", (custom_key,)).fetchone()
            if exists:
                return None, "自定义短链已存在，请换一个"
            code = custom_key
        else:
            # 相同长链接直接复用已有短码
            row = conn.execute("SELECT code FROM urls WHERE long_url=?", (long_url,)).fetchone()
            if row:
                return row[0], None
            code = gen_code(long_url)
        conn.execute(
            "INSERT INTO urls (code, long_url, created_at) VALUES (?,?,?)",
            (code, long_url, int(__import__("time").time())),
        )
        conn.commit()
        return code, None
    finally:
        conn.close()


def get_long(code):
    conn = get_conn()
    try:
        row = conn.execute("SELECT long_url FROM urls WHERE code=?", (code,)).fetchone()
        return row[0] if row else None
    finally:
        conn.close()


class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass  # 静默日志

    def _send_json(self, obj, status=200):
        body = json.dumps(obj, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _send_text(self, text, status=200, ctype="text/html; charset=utf-8"):
        body = text.encode()
        self.send_response(status)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Content-Length", "0")
        self.end_headers()

    def _parse_form(self):
        """同时兼容 multipart/form-data 与 application/x-www-form-urlencoded"""
        content_type = self.headers.get("Content-Type", "") or ""
        length = int(self.headers.get("Content-Length", 0) or 0)
        raw = self.rfile.read(length) if length else b""
        params = {}
        try:
            if "multipart/form-data" in content_type:
                # 需要模拟 environ 才能用 cgi.FieldStorage 解析 multipart
                environ = {
                    "REQUEST_METHOD": "POST",
                    "CONTENT_TYPE": content_type,
                    "CONTENT_LENGTH": str(length),
                }
                fs = cgi.FieldStorage(
                    fp=__import__("io").BytesIO(raw),
                    environ=environ,
                    keep_blank_values=True,
                )
                for key in fs:
                    if fs[key].filename:
                        params[key] = fs[key].value.decode("utf-8", "ignore")
                    else:
                        params[key] = fs[key].value
            else:
                params = urllib.parse.parse_qs(raw.decode("utf-8", "ignore"))
                params = {k: v[0] if isinstance(v, list) else v for k, v in params.items()}
        except Exception:
            # 解析失败时退回简单解析
            try:
                params = urllib.parse.parse_qs(raw.decode("utf-8", "ignore"))
                params = {k: v[0] if isinstance(v, list) else v for k, v in params.items()}
            except Exception:
                params = {}
        return params

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path != "/short":
            self._send_json({"Code": 0, "Message": "Not Found"}, 404)
            return
        params = self._parse_form()
        b64 = params.get("longUrl", "")
        custom_key = params.get("shortKey", "")
        try:
            long_url = base64.b64decode(b64).decode("utf-8")
        except (binascii.Error, UnicodeDecodeError, TypeError):
            self._send_json({"Code": 0, "Message": "longUrl 解码失败"})
            return
        if not long_url:
            self._send_json({"Code": 0, "Message": "longUrl 为空"})
            return
        code, err = create_short(long_url, custom_key or None)
        if err:
            self._send_json({"Code": 0, "Message": err})
            return
        self._send_json({"Code": 1, "ShortUrl": f"{BASE_URL}/{code}"})

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path.strip("/")
        if path == "":
            self._send_text(
                "<html><head><title>Kejizero 短链服务</title></head>"
                "<body style='font-family:sans-serif;text-align:center;padding:80px'>"
                "<h2>Kejizero 短链服务运行中 🦞</h2>"
                "<p>POST /short 提交 longUrl(base64) 生成短链</p></body></html>"
            )
            return
        long_url = get_long(path)
        if not long_url:
            self._send_text("<h2>404 - 短链不存在</h2>", 404)
            return
        self.send_response(302)
        self.send_header("Location", long_url)
        self.send_header("Content-Length", "0")
        self.end_headers()


if __name__ == "__main__":
    import os
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    init_db()
    server = http.server.ThreadingHTTPServer(("0.0.0.0", HTTP_PORT), Handler)
    print(f"Kejizero short-link service listening on :{HTTP_PORT}")
    server.serve_forever()
