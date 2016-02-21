import base64
import json
import os
import requests
import StringIO
import shutil
from urllib import quote_plus
from zipfile import ZipFile

IGNORE_PATHS = ['.DS_Store', '.git', '.gitignore', 'app.py']

def merge_repos(event, context):
    ################################
    #### merge the contents of  ####
    #### one repo into another #####
    ################################


    #get dynamic properties from event
    src_org = event['source_org']
    src_repo = event['source_repo']
    src_branch = event['source_branch']
    target_org = event['target_org']
    target_repo = event['target_repo']
    token = event['token']
    msg = event['message']

    #make a callout to get the contents of the cumulus repository and extract it to temp
    url = 'https://api.github.com/repos/%s/%s/zipball/%s' % (src_org, src_repo, src_branch)
    headers = {'Authorization': 'token ' + token, 'Content-Type': 'application/json', 'Accept' : 'application/json'}
    resp = requests.get(url, headers=headers)    
    z = ZipFile(StringIO.StringIO(resp.content))

    #clean temp directory
    folder = '/tmp'
    for the_file in os.listdir(folder):
        file_path = os.path.join(folder, the_file)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path): shutil.rmtree(file_path)
        except Exception, e:
            print e

    #get the current state of the clean directory    
    x = os.listdir('/tmp')
    print "BEFORE UNPACK"
    print x

    z.extractall('/tmp')
    #get the list after retrieving the github repository
    y = os.listdir('/tmp')
    print "AFTER UNPACK"
    print y

    #get the additions to the directory
    diffs = list(set(y) - set(x))

    #get the repo directory
    repo_directory = ''
    if diffs is not None:
        print "SETTING REPO DIRECTORY"
        repo_directory = diffs[0]

    #walk the directory to get each file path
    circle_files = walk_path('/tmp')

    total_files = len(circle_files)
    files_added = 0

    #loop through the circle files
    for f in circle_files:
        file = open(f, 'r')

        #remove the unneeded part of the path
        f = f.replace("/tmp/" + repo_directory + "/", "")
        #encode the file
        file_content = base64.b64encode(file.read())
        #commit the file to github
        resp = commit_file(file_content, f, token, target_org, target_repo, msg)

        #if the status code is a 201 the add was successful and we inc. files added
        if resp.status_code == 201:
            files_added+=1

    #setup return
    status = ''

    if total_files == files_added:
        status = 'Success'
    elif files_added == 0:
        status = 'Failed'
    else:
        status = 'Partial Success'

    return {'status': status}

def walk_path(path):
    ################################
    #### find all file paths by ####
    ####walking dir recursively ####
    ################################

    files = []
    #loop through paths in directory
    for s in os.listdir(path):
        #check if file is a system file to be ignored
        if s not in IGNORE_PATHS:
            #if the path is a file, add it to list
            if os.path.isfile(path + '/' + s):
                files.append(path + '/' + s)
            #if path is a directory, call walk path recursively
            elif os.path.isdir(path + '/' + s):
                files = files + walk_path(path + '/' + s)
    return files

def commit_file(content, path, token, org, repo, msg):
    ################################
    #### call the github api to ####
    #### commit the file  ##########
    ################################

    #setup request body formatting with message and content
    body = '''{
        "message": "%s",
        "committer": {
            "name": "CodeAccelerator",
            "email": "codeaccelerator@codescience.com"
        },
        "content": "%s"
    }''' % (msg, content)

    headers = {'Authorization': 'token ' + token, 'Content-Type': 'application/json', 'Accept' : 'application/json'}
    #escape the path for the url
    esc_path = quote_plus(path)
    url = "https://api.github.com/repos/%s/%s/contents/%s" % (org, repo, esc_path)
    resp = requests.put(url, data=body, headers=headers)

    return resp                                                                                                                                   