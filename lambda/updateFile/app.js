var fs = require('fs');
var rp = require('request-promise');
var errors = require('request-promise/errors');
var error = new Error('root error');

exports.handler = function(event, context) {

	var test_payload = {
	  "options":  {
	        "authtoken":"4f3172ceaa6e801b3e69129ac754c6fb8dc2d949",
	        "source":{
	            "repo":"CodeScience/circle-start",
	            "branch":"ci-accelerator",
	            "path":"build/build.properties"
	        },
	        "target":{
	            "repo":"CodeScience/dodds-test1",
	            "branch":"integration",
	            "path":"build/build.INTEGRATION.properties"
	        },
	        "properties":[
	            ["SF_PACKAGE_NAME","testpackage"],
	            ["SF_NAMESPACE","testnamespace"]
	        ]
	    }
	}

	if(!event.options){
		event = test_payload;
	}	
	var url = 'raw.githubusercontent.com';
    var fileName = '/tmp/tempFile';
    var sha = '';

	var sourceOptions = {
        uri: 'https://raw.githubusercontent.com/'+event.options.source.repo+'/'+event.options.source.branch+'/'+event.options.source.path,
	    headers: {
	        'Authorization':'token '+event.options.authtoken,
            'Accept':'application/json'
	    },
	    json: false
	};

	var targetOptions = {
		method: 'PUT',
		uri: 'https://api.github.com/repos/'+event.options.target.repo+'/contents/'+event.options.target.path,
		headers: {
	        'Authorization':'token '+event.options.authtoken,
            'Accept':'application/json',
            'User-Agent':'Lambda'
	    },
		body: {
			message: 'Customed build.properties for '+event.options.target.branch.toUpperCase()+' branch',
			branch: event.options.target.branch
		},
		json: true
	};

	var checkFileOptions = {
		method: 'GET',
		uri: 'https://api.github.com/repos/'+event.options.target.repo+'/contents/'+event.options.target.path,
		headers: {
	        'Authorization':'token '+event.options.authtoken,
            'Accept':'application/json',
            'User-Agent':'Lambda'
	    },
		json: false,
		simple: false
	};

	var processFile = function(){
		console.log('Starting Process File');
		rp(sourceOptions)
		.then(function(response){
			var ammendedFile = replacePropertiesInFile(response);
			console.log('Updated file contents');
			return ammendedFile;
		})
		.then(function(fileData){
			// Write file data to target repo and file
			targetOptions.body.content = new Buffer(fileData).toString('base64');
			if(sha != ''){
				targetOptions.body.sha = sha;
				console.log('Appending SHA: '+targetOptions.body.sha);
			}
			rp(targetOptions)
			.then(function(response){
				console.log('Uploaded file to GitHub');
				return context.succeed(response);
			})
			.catch(function (err) {
				var responseError = {};
				if(err.error){
					responseError = err.error;
				}
				else {
					responseError = err
				}
		        return processError('GitHub Error : file update - '+responseError.message);
		    });
		})
		.catch(function (err) {
	        return processError('GitHub Error - '+err);
	    });
	};
	var writeToLog = function(logText){
		console.log(logText);
	};
	var processError = function(err){
		console.log('***********************');
		writeToLog(err);
		console.log('***********************');
        return context.fail('There was an issue completing this request');
        return err;
	};
	var replacePropertiesInFile = function(fileString){
		for(var i = 0; i < event.options.properties.length; i++){
			var entry = event.options.properties[i];
			console.log('Replacing '+entry[0]+' with '+entry[1]);
			fileString = fileString.replace(entry[0],entry[1]);
		}
		return fileString;
	};

	// Bootstrap function
	console.log('Starting GitHub File Create/Update File Process');
	rp(checkFileOptions)
	.then(function(response){
		console.log('Response from SHA check: '+response);
		// Get the SHA if the file already exists
		if(JSON.parse(response).sha){
			sha = JSON.parse(response).sha;
		}
	})
	.catch(errors.StatusCodeError, function (reason) {
        console.log('No file found on SHA check: '+reason);
    })
    .finally(function(){
    	// Update/Create the file
    	console.log('SHA check done.  Processing File');
    	return processFile();
    });
};
// Un-comment the line below to run the app locally in Node
// exports.handler({},{});