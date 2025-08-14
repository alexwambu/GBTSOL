import time
import os
from web3 import Web3

RPC_URL = os.getenv("RPC_URL", "https://gbtnetwork-render.onrender.com")
PRIVATE_KEY = os.getenv("PRIVATE_KEY")
ACCOUNT = os.getenv("ACCOUNT")
CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS")

web3 = Web3(Web3.HTTPProvider(RPC_URL))
if not web3.is_connected():
    print("❌ Cannot connect to RPC")
    exit()

print(f"✅ Connected to GBTNetwork RPC at {RPC_URL}")
print(f"💳 Using account: {ACCOUNT}")
print(f"📜 Mining to contract: {CONTRACT_ADDRESS}")

while True:
    try:
        tx = {
            "from": ACCOUNT,
            "to": CONTRACT_ADDRESS,
            "value": 0,
            "gas": 21000,
            "gasPrice": web3.to_wei("0.001", "ether"),
            "nonce": web3.eth.get_transaction_count(ACCOUNT)
        }
        signed_tx = web3.eth.account.sign_transaction(tx, PRIVATE_KEY)
        tx_hash = web3.eth.send_raw_transaction(signed_tx.rawTransaction)
        print(f"⛏️ Mining transaction sent: {web3.to_hex(tx_hash)}")
        time.sleep(10)
    except Exception as e:
        print(f"⚠️ Mining error: {e}")
        time.sleep(5)
