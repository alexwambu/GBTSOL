from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import os

app = FastAPI()

CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS", "0x0000000000000000000000000000000000000000")

@app.get("/", response_class=HTMLResponse)
def home():
    return f"""
    <html>
    <head>
        <title>GBT Contract Address</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                background-color: #111;
                color: gold;
                text-align: center;
                padding-top: 50px;
            }}
            h1 {{
                font-size: 28px;
            }}
            .address {{
                font-size: 22px;
                border: 2px solid gold;
                padding: 10px;
                display: inline-block;
                margin-top: 20px;
                border-radius: 8px;
            }}
        </style>
    </head>
    <body>
        <h1>GoldBarTether Contract Address</h1>
        <div class="address">{CONTRACT_ADDRESS}</div>
    </body>
    </html>
    """

@app.get("/address")
def get_address():
    return {"contract_address": CONTRACT_ADDRESS}
