#!/usr/bin/env python

import argparse
import sys
import shutil
import os.path
import json
import urllib2
import urllib
import os
import unicodedata
import codecs

name = ""
version = ""
licType = ""
readme = ""
copying = ""
authorName = ""
missingList = ""
oldEntries = []
packages = {}

default_MIT_license = "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE"
default_ISC_license = "Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies. THE SOFTWARE IS PROVIDED \"AS IS\" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE."
missing_info_warinig = "% If a license type for a package is missing you have to:\n%    1) Add the information in the manifest file under the LICENSE label.\n%    2) Move the corresponding sources located in Source_release/_TO_MOVE_ to corresponding directory Source_release/<license_type>.\n%\n% If a copying text for a package is missing you have to:\n%    1) Add the information in the manifest file under the COPYING label, in a single line.\n%    2) Copy the text also in Licensing/licenses/<package_name>/LICENSE file.\n%\n% Delete this file when you are done.\n%\n% Remeber that jmuExtractor collects licenses only for node.js packages. All other licenses should be added manually.\n%\n"

# Manage user arguments
parser = argparse.ArgumentParser(description='Merge license directories.', usage='Usage: ./jmuExtractor -s <source_folder>  [-d <destination]')
parser.add_argument('-s', required=True, help='JmuConfig sources directory.')
parser.add_argument('-d', default='./licExtractor', help='Destination folder.')
parser.add_argument('-p', action='store_true', help='Skip packages with incomplete information.')
args = parser.parse_args()

sourceDir = args.s
destDir = args.d
skip = args.p
manifDir = destDir + "/Licensing/manifests/jmuconfig"
relDir = destDir + "/Source_release"
licDir = destDir + "/Licensing/licenses"

# Check if a jmuconfig-toComplete dir or a TODO file exist. This could mean that there are still missing informations. In this case the program exits
if os.path.exists(destDir + "../jmuconfig-toComplete"):
	print "jmuExtractor: A dir named \"jmuconfig-toComplete\" has been found. Please add the missing informations if any and rename the dir to \"jmuconfig\". Nothing will be done."
	os.exit()

if os.path.isfile(destDir + "../TODO"):
	print "jmuExtractor: A TODO file has been found in the destination dir. Please add the missing informations if any and delete the file. Nothing will be done."
        os.exit()

# Check if sourceDir exists
if not os.path.exists(sourceDir):
	print "Source directory does not exist: " + sourceDir
	os.exit()

if not os.path.exists(destDir): os.makedirs(destDir)
if not os.path.exists(destDir  + "/Licensing"): os.makedirs(destDir + "/Licensing")
if not os.path.exists(relDir): os.makedirs(relDir)
if not os.path.exists(licDir): os.makedirs(licDir)
if not os.path.exists(destDir + "/Licensing/manifests"): os.makedirs(destDir + "/Licensing/manifests")
if not os.path.exists(manifDir): os.makedirs(manifDir)

print

# Check for an existing manifest file in the destination dir
if os.path.isfile(manifDir + "/license.manifest"):
	print "Found jmuconfig manifest in destination directory. Importing entries..."
	impPackage_name = ""
	impPackage_version = ""
        # Imoprt entries already stored
	with open(manifDir + "/license.manifest") as impManif:
		for line in impManif:
			if not line.strip():
				if impPackage_name: oldEntries.append((impPackage_name, impPackage_version))
				impPackage_name = ""
				impPackage_version = ""
				continue
			
			lineElem = line.split(':', 1)
			tagName = lineElem[0].strip()
			tagValue = lineElem[1].strip()
			if tagName == "PACKAGE NAME":
				impPackage_name = tagValue	
			elif tagName == "PACKAGE VERSION":
				impPackage_version = tagValue
                # Put those entris in a list
		if impPackage_name: oldEntries.append((impPackage_name, impPackage_version))

# Look for package.json files
for src_dir, dirs, files in os.walk(sourceDir):
	if not "package.json" in files: continue
        # Get as much informations as possible from package.json file
	authorName = ""
	copying = ""
	json_data=open(src_dir + "/package.json")
	data = json.load(json_data)
	name = data.get("name", "" )
	version = data.get("version", "" )
        # If the entry has been already processed skip
	if (name, version) in packages: continue
	if (name, version) in oldEntries: continue

	licType = data.get("license", "" )
	readme = data.get("readme", "" )
	homepage = data.get("homepage", "" )
	author = data.get("author", "" )
	if author:
		try: 
			authorName = author.get("name", "" )
		except AttributeError:
			authorName = author

	# If there is no license type entry. It may be found in list of licenses. Get it
	if not licType: licType = data.get("licenses", "" )
	if type(licType) is type([]): licType = licType[0]
	if type(licType) is type({}):
		copyingUrl = licType.get("url", "")
		licType = licType.get("type", "")
       
	# If there is a hompage try to download license. Assuming the homepage is hosted by github license can be usually found in a LICENSE file 
	if not(copying) and homepage:
		try:
			response = urllib.urlopen(homepage + "/raw/master/LICENSE")
			if response.getcode() == 200:
				copying = response.read().decode('utf-8')
		except IOError:
			copying = ""

        # If there is still no license type look inside the COPYING
	if not(licType) and copying:
		if "MIT" in copying: licType = "MIT"
		if "ISC" in copying: licType = "ISC"
		if "BSD" in copying: licType = "BSD"
	
	if not(licType) and readme:
		if "MIT" in readme: licType = "MIT"
		if "ISC" in readme: licType = "ISC"
		if "BSD" in readme: licType = "BSD"
	
        # If there is still no license type look inside the homepage
	if not(licType) and homepage:
		try:
			response = urllib.urlopen(homepage)
			if response.getcode() == 200:
				page = response.read().decode('utf-8')
				if "MIT" in page: licType = "MIT"
				if "ISC" in page: licType = "ISC"
				if "BSD" in page: licType = "BSD"
		except IOError:		
			licType = ""

	# If license type is known and a COPYING has not been found use the default one
	if ("MIT" in licType) and not(copying):
		copying = "Copyright (C) " + authorName + " " + default_MIT_license
	
	if licType == "ISC" and not(copying):
		copying = "Copyright (C) " + authorName + " " + default_ISC_license
	
        # Track missing informations
	missing = ""
	if not licType: missing += "LICENSE "
	if not copying: missing += "COPYING "
	
	# Keep a log of the missing informations
	if missing:
		if skip: continue
                missingList += "Package " + name + " " + version + ". Missing informations: " + missing + ".\n"
                missingList += "Package location in sources: " + src_dir + "\n\n"
	
	copying = copying.replace("\n", " ")	
	
	packages[(name, version)] = [licType, copying]
	fullName = (name + "-" + version).lower()
	lDir = licType
        # If the license type is missing sources can't be places correctly. In this case put them in a "_TO_MOVE_" directory
	if not lDir: lDir = "_TO_MOVE_"
	if not os.path.exists(relDir + "/" + lDir): os.makedirs(relDir + "/" + lDir)
	if not os.path.exists(relDir + "/" + lDir + "/" + fullName): os.makedirs(relDir + "/" + lDir + "/" + fullName)
	os.system("tar -zcvf '" + relDir + "/" + lDir + "/" + fullName + "/" + fullName + ".tar.gz' -C '" + src_dir + "' . >> /dev/null") 
	
	# Write the COPYING
	if not os.path.exists(licDir + "/" + fullName): os.makedirs(licDir + "/" + fullName)
	with codecs.open(licDir + "/" + fullName + "/LICENSE", "w+", encoding="utf-8") as licText:
		licText.write(copying)
	
# Write the manifest. Appends to existing file
with codecs.open(manifDir + "/license.manifest", "a+", encoding="utf-8") as manifest:
	manifest.write("\n")
	for fname, fversion in packages:
		manifest.write("PACKAGE NAME: " + fname + "\n")
		manifest.write("PACKAGE VERSION: " + fversion + "\n")
		manifest.write("LICENSE: " + packages[(fname, fversion)][0] + "\n")
		manifest.write("COPYING: " + packages[(fname, fversion)][1] + "\n")
		manifest.write("\n")

# If some informations are missing write a log to a "TODO" file and rename the destination dir to "jmuconfig-toComplete"
if missingList:
	with codecs.open(destDir + "/TODO", "a+", encoding="utf-8") as todo:
        	todo.write(missing_info_warinig + "\n" + missingList)
        os.rename(destDir, destDir + "/../jmuconfig-toComplete")

		
