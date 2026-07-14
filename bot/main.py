import os
from flask import Flask, request

app = Flask(__name__)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/webhook")
def webhook():
    return {"received": True}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8081")))
