# BC Radio
infinite stream of bandcamp content through your browser.

## How to build it
1. Install Go (https://golang.org/) 
2. Install the single dependency from the command line `go get github.com/PuerkitoBio/goquery`
3. run `go build main.go` from the bcradio folder
4. Start the resulting executable, and open your browser to `localhost:8080` 

## How to use it
Search for tags in the `tag` search bar. Click a search result and it will be added to the list of tags in rotation. The stream will begin playing music. Additional tags can be added to the stream using the same process. Clicking the subtract button next to a tag name will remove it from rotation. Clicking on a tag in rotation will bring it to the beginning of the list and begin playing that tag immediately.
