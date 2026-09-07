"""Force (or restore) dev-mode config.json settings for dev-server.sh/.bat."""
import json
import os
import sys


def main():
    port_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    no_dev_mode = len(sys.argv) > 2 and sys.argv[2] == "1"

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    config_path = os.path.join(root, "config.json")

    with open(config_path, encoding="utf-8") as f:
        config = json.load(f)

    config["localhost"] = not no_dev_mode
    if port_arg:
        config["port"] = int(port_arg)

    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2)

    mode = "production config (--no-dev-mode)" if no_dev_mode else "dev mode (localhost=true)"
    print(f"config.json set to {mode}, port {config['port']}")


if __name__ == "__main__":
    main()
