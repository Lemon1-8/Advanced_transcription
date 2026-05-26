import sys, json

data = json.load(sys.stdin)

cwd = data.get("workspace", {}).get("current_dir", "")
dir_name = cwd.split("/")[-1] or cwd.split("\\")[-1] or cwd

model = data.get("model", {}).get("display_name", "unknown")

remaining = data.get("context_window", {}).get("remaining_percentage", 0)
remaining = round(remaining)

print(f"{dir_name}  |  {model}  |  {remaining}%")
