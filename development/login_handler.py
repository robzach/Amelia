from pythonosc import dispatcher
from pythonosc import osc_message_builder
from pythonosc import udp_client
import websocket
import _thread as thread
import time
from http.client import HTTPResponse
import json
import time
import signal
import sys

def signal_handler(sig, frame):
	print('You pressed Ctrl+C!')
	sys.exit(0)

client = udp_client.SimpleUDPClient("127.0.0.1", 12345)

def on_message(ws, message):
	resp = json.loads(message)
	print(message)
	#print(resp["username"])
	#print(resp["meta"]["first_name"])
	client.send_message("/login", [ resp["token"], resp["username"], resp["meta"]["first_name"], resp["meta"]["last_name"] ])

def on_error(ws, error):
    print(error)

def on_close(ws):
	print("### closed ###")
	time.sleep(2.0)
	print("### reconnecting . . . ###")
	makeSocket()

def makeSocket():
	ws = websocket.WebSocketApp("wss://staging.projectamelia.ai/pusherman/companions/login/websocket?app=tranquil",
                              on_message = on_message,
                              on_error = on_error,
                              on_close = on_close)
	ws.run_forever()

if __name__ == "__main__":
	signal.signal(signal.SIGINT, signal_handler)
	websocket.enableTrace(True)
	makeSocket()
    #ws.run_forever()
