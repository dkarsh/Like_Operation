The like operation - 

* user taps on heart of post to 'Like' or 'Unlike' the post 
* we instantly update the UI to reflect the state (animate to filled in heart)
* We Queue up an array of operations on VM (incase user press multiple times)
* VM take the first operation and pause all the rest until API respond is back. 
* VM then talks to service layer to start the api request 
* When API request call is done VM cancel all operations on queue BESIDES the last one.
* VM compares the last operation on queue and talks to service ONLY if it different then the call we sent previously (Unlike call if previouse was Like)


