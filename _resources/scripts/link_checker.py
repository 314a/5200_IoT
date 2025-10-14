#!/usr/bin/env python3

# Adapted from: http://howto.philippkeller.com/files/link_checker.py
# URL: http://howto.philippkeller.com/2018/01/26/How-to-check-for-broken-links-in-markdown-files/
# Usage: python3 link_checker.py path/to/md/files/ 
# 
# Intatiates a webserver and validates all urls/referenced files for existence
# python C:\..\link_checker.py "C:\..\Skript" 
########################################################################
import os, sys, re
import urllib.request
from http.server import HTTPServer, CGIHTTPRequestHandler
import threading
import time
########################################################################
# Functions
def check(url):
	"""
    Check Url and return Error Message
    """
	try:
		req = urllib.request.Request(url, method='HEAD', headers={'User-Agent' : "link-checker"})
		# https://stackoverflow.com/questions/24226781/changing-user-agent-in-python-3-for-urrlib-request-urlopen
		# set User-Agent header as a browser
		# Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.1 Safari/603.1.30
		req = urllib.request.Request(url, method='HEAD', headers={'User-Agent' : "Mozilla/5.0 (X11; U; Linux i686) Gecko/20071127 Firefox/2.0.0.11"})
		resp = urllib.request.urlopen(req, timeout=3)
		if resp.code >= 400:
			return "Got HTTP response code {}".format(resp.code)
	except Exception as e:
		return "Got exception {}".format(e)
	return None

def findUrl(string):
	"""
    regex for finding urls in strings:
	match md url [](www.pandoc.org) and matches html <a> urls e.g. <a href="pandoc.org">pandoc</a> and generig urls
    """
	regex = r"([\w]+:?//(([\d\w]|%[a-fA-f\d]{2,2})+(:([\d\w]|%[a-fA-f\d]{2,2})+)?@)?([\d\w][-\d\w]{0,253}[\d\w]\.)+[\w]{2,63}(:[\d]+)?(/([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)*(\?(&?([-+_~.\d\w]|%[a-fA-f\d]{2,2})=?)*)?(#([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)?)"
	urls = re.findall(regex,string)
	urls =[x[0] for x in urls]
	# match md url [](www.pandoc.org)
	urls += re.findall("""[^!]\[[^\]]+\]\(([^\)^"^']+)\)""", string) # match md url [](www.pandoc.org)
	# matches html <a> urls e.g. <a href="pandoc.org">pandoc</a>
	urls += re.findall('(?:href)\s*=\s*"\s*([^"]+)', string) 							
	return urls

def findFiles(string):
	"""
    regex for finding images / files in strings:
	match md images ![](figures/test.jpg) and matches img tags <img src:"test.jpg">
    """
	# find images / files
	imgs = re.findall("""!\[[^\]]+\]\(([^\)^"^']+)\)""", string) # match md images ![](figures/test.jpg)
	imgs += re.findall('(?:src)\s*=\s*"\s*([^"]+)', string) # matches img tags <img src:"test.jpg">
	return imgs

def checkFile(path,enc="utf-8"):
	"""
	Reads Textfiles and returns a log of url/resources if they are valid/exist
	TODO: return structured object
    """
	with open(path, encoding=enc) as f:	
		filename = os.path.basename(path)
		printed_filename = False
		content = f.read()
		urls = findUrl(content)
		imgs = findFiles(content)
		log = ""
		valid = True
		for url in urls:
			error = check(url)
			if error is not None:
				log += "- url error: "+ url+"\t"+ error+"\n"
				valid = False
			elif show_valid:
				log += "+ url valid: "+ url+"\n"
		for img in imgs:
			if not os.path.isfile(os.path.join(wd, img)):
				log += "- img error: "+ img+"\n"
				valid = False
			elif show_valid:
				log += "+ img valid: "+ img+"\n"
		if valid:
			logValid = " <- PASS"
		else:
			logValid = " <- FAIL"
		out = filename+logValid+"\n"
		if not silent:
			out +='-'*(len(filename)+8)+"\n"+str(len(urls))+" Urls, "+str(len(imgs))+" Images found\n"
		out +=log
		return out

def start_server(path, port=8000):
	'''Start a simple webserver serving path on port'''
	# Make sure the server is created at current directory
	os.chdir(path)
	# Create server object listening the port 80
	httpd = HTTPServer(('', port), CGIHTTPRequestHandler)
	# Start the web server	
	# print('Webserver started on: http://localhost:{}\n'.format(port))
	httpd.serve_forever()

########################################################################
silent = False
show_valid = True
port = 8000
path = sys.argv[1]
if len(sys.argv) == 3:
	silent = True
	show_valid = False

if not silent:
	print("------------------------------------------------")
	print("Markdown URL/Link Validator")
	print("Validates broken links in markdown files (*.md)")
	print("usage: python {} root_path".format(os.path.basename(sys.argv[0])))
	print("optional argument --silent")
	print("------------------------------------------------\n")
#print("usage: python {} root_path base_url".format(sys.argv[0]))
#print("i.e. {} source https://localhost:4000".format(sys.argv[0]))

if len(sys.argv) < 2:
	print("Missing arguments, exit programm")
	print("hint: use root_path without trailing /")
	sys.exit(1)

# get folder if search_dir is a file
wd = path
if os.path.isfile(path):
	wd = os.path.dirname(path)

# Start the server in a new thread
daemon = threading.Thread(name='daemon_server',target=start_server,args=(wd, port))
daemon.setDaemon(True) # Set as a daemon so it will be killed once the main thread is dead.
daemon.start()

# verify urls contained in .md files
try:
	if os.path.isfile(path):
		print(checkFile(path))
	elif os.path.isdir(path):
		for path, dirs, filenames in os.walk(path):
			for filename in [i for i in filenames if(i.endswith('.qmd') | i.endswith('.rmd') | i.endswith('.md'))]:
				print(checkFile(os.path.join(path, filename)))
	else:
		print("Invalid path: "+path)
except KeyboardInterrupt:
	pass

# print('OK')
# time.sleep(120)