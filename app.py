from flask import Flask, jsonify, request
import pandas as pd
import math
import statistics
from datetime import datetime

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.fftpack import fft
from scipy.interpolate import interp1d
import seaborn

app = Flask(__name__)


@app.route('/', methods=["POST"])
def get_data():
    data = request.data
    # print(data)
    data_raw = pd.read_json(data)
    # Get the median interval time for this data (i.e. typical interval)
    intervals = [data_raw.index[i] - data_raw.index[i - 1] for
                 i in range(1, len(data_raw.index))]
    interval = statistics.median(intervals)

    # Convert to unix epoch timestamp for easier math.
    ts_raw = [t for t in data_raw.time]

    # Set up interpolation for total gForce.
    gf_raw = list(data_raw.total)
    interpolate = interp1d(ts_raw, gf_raw)

    # Create uniform timepoints, derive interpolated gForce values.
    ts_uniform = np.linspace(ts_raw[0], ts_raw[-1], len(ts_raw))
    avg_delta = (ts_raw[-1] - ts_raw[0]) / len(ts_raw)
    gf_uniform = interpolate(ts_uniform)

    gf_fft_all = np.fft.fft(gf_uniform)
    freqs_all = np.fft.fftfreq(len(ts_uniform), d=avg_delta)

    # discard complex conjugate
    target_len = int(len(freqs_all) / 2)
    freqs = freqs_all[1:target_len]
    gf_fft = gf_fft_all[1:target_len]

    plt.figure()
    plt.plot(freqs, gf_fft)

    # Get the maximum value, report the frequency and magintude.
    peak_index = np.argmax(gf_fft)
    peak_freq = freqs[peak_index]
    peak_magnitude = abs(gf_fft[peak_index])

    print("Peak frequency: {} Hz".format(peak_freq))
    print("Peak magnitude: {}".format(peak_magnitude))
    timestamp = datetime.fromtimestamp(data_raw.time[0])

    json_file = {}
    json_file['timestamp'] = timestamp
    json_file['frequency'] = peak_freq
    json_file['magnitude'] = peak_magnitude
    return jsonify(json_file)


if __name__ == '__main__':
    app.run()
