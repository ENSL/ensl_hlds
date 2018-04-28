#!/usr/bin/env python3
import rHLDS, yaml, re, time, os, argparse
from datetime import datetime

from bokeh.plotting import figure, output_file, show
#from bokeh.charts import Area, show, output_file, defaults
#from bokeh.layouts import row

#defaults.width = 1024
#defaults.height = 1024

def write_data(filename):
	# Default port 27015
	srv = rHLDS.Console(host=os.environ['RCON_HOST'], port=os.environ['RCON_PORT'], password=os.environ['RCON_PASSWORD'])
	srv.connect()

	timestamp = time.time()
	file1 = open(filename, "a+")

	try:
		while True:
			data = srv.execute("stats")
			fps = re.search('(\d+.?\d*)(\d+.?\d*\s*)(\d+.?\d*\s*)(\d+.?\d*\s*)(\d+.?\d*\s*)(\d+.?\d*\s*)(\d+.?\d*\s*)', data).group(7)
			if fps:
				file1.write("%d,%s\n" % (time.time(), fps))
				print(fps + " ", end='')
			time.sleep(5)
	except:
		pass

	file1.close()
	srv.disconnect()

# Read data
def read_data(filename):
	file1 = open(filename, "r")
	fps_time = []
	fps_data = []

	while True:
		line = file1.readline()
		if not line: break
		time = re.search('(\d+),(\d+).(\d*)', line).group(1)
		fps = re.search('(\d+),(\d+)', line).group(2)
		if fps and time:
			print('time: ' + time)
			print('fps: ' + fps)
			fps_time.append(datetime.fromtimestamp(int(time)))
			fps_data.append(fps)

	# output to static HTML file
	output_file("%s.html" % filename)

	# create a new plot with a title and axis labels
	p = figure(title="hlds_linux stats", x_axis_label='time', y_axis_label='FPS', x_axis_type="datetime", width=1600)

	# add a line renderer with legend and line thickness
	p.line(fps_time, fps_data, legend="FPS", line_width=2)

	# show the results
	show(p)

filename = "data.%d" % time.time()

parser = argparse.ArgumentParser()
parser.add_argument("--file", help="Use the given file")
args = parser.parse_args()

if not args.file:
	write_data(filename)
else:
	filename = args.file 

read_data(filename)
