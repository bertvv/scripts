#!/bin/bash
#
# Created:  Mon 11 Aug 2008 01:56:27 PM CEST
# Modified: Mon 11 Aug 2008 02:11:35 PM CEST
# Author:   Bert Van Vreckem <Bert.Van.Vreckem@gmail.com>
#

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# URL of the book information page containing links to MP3 files
index_url=${1}

# Temporary file to hold the book information page
index_file=$(mktemp)

# Base URL of links to MP3 files
base_url='http://www.podiobooks.com/sample/'

#------------------------------------------------------------------------------
# Script proper
#------------------------------------------------------------------------------

# First, get the index page
wget -O ${index_file} ${index_url}

# Find MP3 URLS in the file and download them
grep ${base_url} ${index_file} | sed 's/.*\(http:\/\/.*\.mp3\).*/\1/' | xargs wget

# Fix filenames
rename 's/\?.*//' *.mp3\?*

# Clean up
rm $index_file
