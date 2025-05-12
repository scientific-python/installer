print("Running imports")
import faulthandler

faulthandler.enable()

from pathlib import Path

import matplotlib.pyplot as plt


this_path = Path(__file__).parent

# Matplotlib
print("Running matplotlib tests")
fig, _ = plt.subplots()
want = "QTAgg"
assert want in repr(fig.canvas), repr(fig.canvas)
plt.close("all")
