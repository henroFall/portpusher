from flask import Flask, request, render_template, Response
import os, socket

app = Flask(__name__, static_folder='static')
CONFIG_FILE = "/root/tcp_forward.conf"

# Function to read config
def read_config():
    data = {"IN_PORT": "8080", "OUT_PORT": "9090", "DEST_HOST": "example.com"}
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            for line in f:
                key, value = line.strip().split("=")
                data[key] = value
    return data

# Function to write config
def write_config(data):
    with open(CONFIG_FILE, "w") as f:
        f.write(f"IN_PORT={data['IN_PORT']}\n")
        f.write(f"OUT_PORT={data['OUT_PORT']}\n")
        f.write(f"DEST_HOST={data['DEST_HOST']}\n")
    os.system("systemctl restart tcp_forward")

# Get the correct local IP address
def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

@app.route("/", methods=["GET", "POST"])
def index():
    config = read_config()
    if request.method == "POST":
        config["IN_PORT"] = request.form["in_port"]
        config["OUT_PORT"] = request.form["out_port"]
        config["DEST_HOST"] = request.form["dest_host"]
        write_config(config)
    device_ip = get_local_ip()
    return render_template("index.html", config=config, device_ip=device_ip)

@app.route("/get_ip")
def get_ip():
    return get_local_ip()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
  
