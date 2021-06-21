The like operation - 

1 User taps on heart of post to 'Like' or 'Unlike' the post 
2 We instantly update the UI to reflect the state
3 We queue up an array of operations on VM (incase user taps multiple times)
4 VM takes the first operation and pauses all the rest.
5 VM then talks to service layer to start the API request.
6 When API response is back VM cancel all operations on queue BESIDES the last one.
7 VM compares the last operation on queue and talks to service API ONLY if it different then the call we sent previously (Unlike call if previouse was Like)
8 If last operation is different (goto line number 4)


