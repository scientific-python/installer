print("Running imports")
import faulthandler
from platform import system

faulthandler.enable()

from pathlib import Path

import matplotlib.pyplot as plt

plat2backend = {
    'Darwin': 'NSView',
    'Windows': 'TkAgg',
    'Linux': 'TkAgg'
}

this_path = Path(__file__).parent

# Matplotlib
print("Running matplotlib tests")
fig, _ = plt.subplots()
want = plat2backend[system()]
assert want in repr(fig.canvas), repr(fig.canvas)
plt.close("all")
