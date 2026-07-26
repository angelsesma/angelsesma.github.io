import shutil
from pathlib import Path
Path("white").mkdir(exist_ok=True)
Path("black").mkdir(exist_ok=True)
for f in Path(".").iterdir():
    if f.is_file():
        shutil.move(f, Path("white")/f.name if "_as_white_" in f.name else Path("black")/f.name)