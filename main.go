package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
)

func prepareInput(input string) string {
	fields := strings.Fields(input)
	output := ""
	for i := 0; i < len(fields); i++ {
		if fields[i] != "&" {
			output += fields[i]
			if i != len(fields)-1 {
				output += "-"
			}
		}
	}
	return output
}

func getTags(w http.ResponseWriter, r *http.Request) {
	generateAndSendJson := func(errorText string, tags []string) {
		sendText := []byte("")
		type RelatedTagGroup struct {
			ErrorText   string
			RelatedTags []string
		}

		tagGroup := RelatedTagGroup{
			ErrorText:   errorText,
			RelatedTags: tags,
		}

		sendText, err := json.Marshal(tagGroup)
		if err != nil {
			sendText = []byte("{\"ErrorText\":\"json-generation-failed\"}")
		}
		fmt.Fprintf(w, "%s", sendText)
	}

	tag := prepareInput(r.FormValue("tag"))
	//tag = strings.Replace(tag, " ", "-", -1)
	if tag == "" {
		generateAndSendJson("invalid-query", []string{})
		return
	}

	document, err := goquery.NewDocument("https://bandcamp.com/tag/" + tag)
	if err != nil {
		generateAndSendJson("failed-to-reach-bandcamp", []string{})
		return
	}

	var foundTags []string

	document.Find(".related_tag").Each(func(i int, s *goquery.Selection) {
		foundTags = append(foundTags, s.Text())
	})

	if len(foundTags) == 0 {
		generateAndSendJson("no-tags-found", []string{})
		return
	}

	//define the json structure
	generateAndSendJson("no-error", foundTags)
}

func getSong(w http.ResponseWriter, r *http.Request) {
	/*
		1. gets the "tags" GET header from the http request, and prepares it for the bandcamp request
		2. Requests a search page from bandcamp to find out how many pages of data there are for the given tag
		3. Chooses a random page number between 0 and <number of pages found>
		4. Grab the page to find out how many albums are listed on it
		5. Choose a random album on that page
		6. Grab that album's page data, as JSON
		7. Process this json, choose a random track, and return that data as formatted JSON
		If the request fails along the way, it can retry a few times, assuming bandcamp just went down for a moment
	*/
	generateAndSendJson := func(errorText string, artistName string, albumName string, songName string, albumURL string, albumArtURL string, mp3Url string) {
		type SongResponseGroup struct {
			ErrorText   string
			ArtistName  string
			AlbumName   string
			SongName    string
			AlbumURL    string
			AlbumArtURL string
			Mp3URL      string
		}
		songResponse := SongResponseGroup{
			ErrorText:   errorText,
			ArtistName:  artistName,
			AlbumName:   albumName,
			SongName:    songName,
			AlbumURL:    albumURL,
			AlbumArtURL: albumArtURL,
			Mp3URL:      mp3Url,
		}

		sendText := []byte("")

		sendText, err := json.Marshal(songResponse)
		if err != nil {
			sendText = []byte("{\"ErrorText\":\"json-generation-failed\", \"\", \"\", \"\", \"\", \"\", \"\"}")
		}

		fmt.Fprintf(w, "%s", sendText)
	}

	//get GET data and prepare it
	tag := prepareInput(r.FormValue("tag"))
	if tag == "" {
		generateAndSendJson("invalid-query", "", "", "", "", "", "")
		return
	}

	//Find out how many pages of data there are for this tag...
	document, err := goquery.NewDocument("https://bandcamp.com/tag/" + tag)
	if err != nil {
		generateAndSendJson("failed-to-reach-bandcamp", "", "", "", "", "", "")
		return
	}

	pageNumber := 0
	seededRand := rand.New(rand.NewSource(time.Now().UnixNano()))

	pageCount := document.Find(".pagenum").Length()

	//Now lets choose a random page number to grab the album we will eventually use:
	if pageCount > 0 {
		//Intn cannot handle 0 input, but bandcamp pages treats 0 as 1 anyway, so it doesnt matter
		pageNumber = seededRand.Intn(pageCount)
	}

	//request this page
	document, err = goquery.NewDocument("https://bandcamp.com/tag/" + tag + "?page=" + strconv.Itoa(pageNumber) + "&sort_field=date")
	if err != nil {
		generateAndSendJson("failed-to-reach-bandcamp", "", "", "", "", "", "")
		return
	}

	//find the number of albums on this page
	numberOfAlbums := document.Find(".item_list").Find(".item").Size()
	if numberOfAlbums == 0 {
		/******** THIS ERROR HAPPENS WHEN BANDCAMP GOES OFFLINE, WHICH IT DOES PERIODICALLY IN BETWEEN REQUEST FOR SPLIT SECONDS. */
		generateAndSendJson("no-albums-found", "", "", "", "", "", "")
		return
	}

	//grab the DOM data for the randomly chosen album we want
	albumSelection := document.Find(".item_list").Find(".item").Eq(seededRand.Intn(numberOfAlbums))

	//grab the url data from this data
	href, exists := albumSelection.Find("a").Attr("href")
	if exists == false {
		generateAndSendJson("could-not-find-href", "", "", "", "", "", "")
		return
	}

	//now load the album page
	document, err = goquery.NewDocument(href)
	if err != nil {
		generateAndSendJson("failed-to-reach-bandcamp", "", "", "", "", "", "")
		return
	}

	//grab trackdata from the album page
	substring := strings.Split(strings.Split(document.Text(), "trackinfo: ")[1], "}],")[0] + "}]"

	type FileField struct {
		Trackurl string `json:"mp3-128"`
	}
	type TrackInfo struct {
		TrackNumber int       `json:"track_num"`
		Title       string    `json:"title"`
		File        FileField `json:"file"`
	}

	//unmarshal the json into data structures
	var tracks []TrackInfo
	err = json.Unmarshal([]byte(substring), &tracks)
	if err != nil {
		generateAndSendJson("failed-to-decode-json", "", "", "", "", "", "")
		return
	}

	//removes any tracks that dont have a playable mp3
	iter := 0
	for _, val := range tracks {
		if val.File.Trackurl != "" {
			tracks[iter] = val
			iter++
		}
	}
	tracks = tracks[:iter]

	trackCount := len(tracks)

	if trackCount == 0 {
		generateAndSendJson("no-playable-tracks", "", "", "", "", "", "")
		return
	}

	chosenTrackNumber := seededRand.Intn(trackCount)
	albumArtURL, _ := document.Find(".middleColumn").Find("img").Attr("src")
	albumName := document.Find("#name-section").Find(".trackTitle").Text()

	generateAndSendJson("no-error", document.Find("#name-section").Find("a").Text(),
		albumName[13:len(albumName)-22],
		tracks[chosenTrackNumber].Title,
		href,
		albumArtURL,
		tracks[chosenTrackNumber].File.Trackurl)
}

func main() {
	fmt.Println("Starting BCRadio server...")
	http.Handle("/", http.FileServer(http.Dir("./static")))

	http.HandleFunc("/gettags", getTags)
	http.HandleFunc("/getsong", getSong)

	http.ListenAndServe(":8080", nil)
}
