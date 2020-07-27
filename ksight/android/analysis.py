#!/usr/bin/env python3
import re
import math

class Cluster: #cluster is a group of multi-cpus with same frequency and performance
	def __init__(self, cpus):
		self.cpus = cpus
		self.prev_time = 0
		self.num_util = 0;
		self.num_util_low = 0;
		self.num_util_medium = 0;
		self.num_util_high = 0;

	def report(self):
		print(f'cpu={self.cpus}, num_util={self.num_util}, num_util_low={self.num_util_low}, num_util_medium={self.num_util_medium}, num_util_high={self.num_util_high}')

class GSight:
	def __init__(self, clusters):
		self.clusters = clusters
		self.start = 0
		self.scale = 1000 * 1000

	def getCluster(self, cpu):
		for c in self.clusters:
			if cpu in c.cpus:
				return c
		return None #TODO: raise an excpetion is better?

	def report(self):
		for c in self.clusters:
			c.report()

class SVG:
	def __init__(self, f, x, y, w, h):
		self.f = f
		self.x = x
		self.y = y
		self.w = w
		self.h = h
		f.write(f'<svg width="{w}" height="{h}" version="1.1" xmlns="http://www.w3.org/2000/svg">\n')
		self.draw(0, 0, self.w-self.x, 0, "orange")
		self.draw(0, 0, 0, self.h-self.y, "orange")

	def draw(self, x1, y1, x2, y2, c):
		_x1 = self.x + x1;
		_y1 = self.h - self.y - y1
		_x2 = self.x + x2;
		_y2 = self.h - self.y - y2;
		self.f.write(f'<line x1="{_x1}" y1="{_y1}" x2="{_x2}" y2="{_y2}" stroke="{c}" fill="transparent" stroke-width="1"/>\n')

	def wrapUp(self):
		self.f.write('</svg>\n')

def util_handler(time, content, gsight, ln):
	d = dict(re.findall('(?P<key>\S*)=(?P<value>\d*)', content))
	cpu = int(d['cpu'])
	cluster = gsight.getCluster(cpu)
	sentinel = False
	if cpu == cluster.cpus[0]:
		sentinel = True
	if cluster:
		if sentinel:
			t = round(float(time) * gsight.scale)
			t = t - gsight.start
			if t - cluster.prev_time <= 1:
				print(f"line: {ln}, cpu : {cpu} prev_time: {cluster.prev_time}, t: {t}")
			cluster.prev_time = t
		else:
			t = cluster.prev_time
		gsight.svg.draw(t, 0, t, int(d['util']), 'pink')

def forecast_handler(time, content, gsight, ln):
	d = dict(re.findall('(?P<key>\S*)=(?P<value>\d*)', content))
	cpu = int(d['cpu'])
	cluster = gsight.getCluster(cpu)
	cluster.num_util = cluster.num_util + 1
	u = int(d['util']) * 100 / int(d['max'])
	if u <= 70:
		cluster.num_util_low = cluster.num_util_low + 1
	elif u < 90:
		cluster.num_util_medium = cluster.num_util_medium + 1
	else:
		cluster.num_util_high = cluster.num_util_high + 1

handlers = (
	("sugov_util_update", util_handler),
	("sugov_next_freq_lcj", forecast_handler),
)

def line_handler(l, gsight, ln):
	if l[0] == '#':
		return
	m = re.match('.{36}(?P<time>.*?): (?P<trace>.*?): (?P<content>.*)\n$', l)
	if gsight.start == 0:
		gsight.start = math.floor(float(m['time'])) * gsight.scale
	for name, callback in handlers:
		if name == m['trace']:
			callback(m['time'], m['content'], gsight, ln)
			break

def main():
	gsight = GSight([Cluster(range(0, 6)), Cluster([6]), Cluster([7])])

	with open('cpu.log', 'r') as f, open('usage.svg', 'w') as o:
		gsight.svg = SVG(o, 20, 20, 10*gsight.scale, 1080)
		ln = 0;
		for l in f:
			ln = ln + 1;
			line_handler(l, gsight, ln)
		gsight.svg.wrapUp()

	gsight.report()

main()
