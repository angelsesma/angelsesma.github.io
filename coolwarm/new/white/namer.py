from pathlib import Path

folder = Path(".")  # change to your folder if needed
print('", "'.join([p.name for p in folder.iterdir() if p.is_file()]))