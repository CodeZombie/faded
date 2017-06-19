tagPlaylist = []



function nextSong(shuffle_) {
  if(tagPlaylist.length == 0) {
    return //no tags in the playlist, so theres nothing to do here.
  }
  if (shuffle_) {
    if(tagPlaylist.length > 2) {
      firstElement = tagPlaylist[0]
      tagPlaylist.splice(0, 1)
      tagPlaylist.splice(tagPlaylist.length, 0, firstElement)
      refreshTagPlaylist()
    }
  }
  retry = 0
  maxretries = 8

  requestSong = function(retries_) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        songInfo = JSON.parse(xhttp.responseText)
        if (songInfo.ErrorText == "no-error") {
          document.getElementById("artistTitle").innerHTML = songInfo.ArtistName
          document.getElementById("albumTitle").innerHTML = songInfo.AlbumName
          document.getElementById("albumTitle").href = songInfo.AlbumURL
          document.getElementById("songTitle").innerHTML = songInfo.SongName
          document.getElementById("albumArt").src = songInfo.AlbumArtURL
          mPlayer = document.getElementById("mediaPlayer");
          mPlayer.src = songInfo.Mp3URL
          mPlayer.load();

        }else{
          if(songInfo.ErrorText == "invalid-query") {
            console.log("Invalid search term")
          }

          if(retries_ < maxretries) {
            console.log("retrying search...")
            setTimeout(function(){requestSong(retries_ + 1)}, 2000);
            return
          }else {
            //utter failure. Remove this tag from the playlist because obviously it's not going to work.
            removeTagFromPlaylist(tagPlaylist[0])
            nextSong(true)
            return
          }
        }
      }
    }
    xhttp.open("GET", "/getsong?tag=" + tagPlaylist[0], true);
    xhttp.send();
  }
  requestSong()
}

function tagQuery(tag_) {
  if (tag_ == "") {
    return -1
  }

  //ajax query to grab tags.
  //if the ajax grabs tags, populate the taglist, including the tag_
  //if the ajax fails to get any tags, throw an error saying the tag is invalid.

  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        tags = JSON.parse(xhttp.responseText)
        if(tags.ErrorText == "no-error") {
          tags.RelatedTags.unshift(tag_)
          document.getElementById("relatedTagContainer").innerHTML = ""
          for (var i = 0; i < tags.RelatedTags.length; i++) {

            document.getElementById("relatedTagContainer").innerHTML += "<a class=\"smalltag\" href=\"javascript:addTagToPlaylist('" + tags.RelatedTags[i] + "')\" class=\"text\">" + tags.RelatedTags[i] + "</a>"
          }
        }else{
          document.getElementById("relatedTagContainer").innerHTML = "<p style=\"color:#ff3d00; font-style:italic; text-align:center;\">Invalid tag</p>"
        }
      }
  };
  xhttp.open("GET", "/gettags?tag=" + tag_, true);
  xhttp.send();
}

function addTagToPlaylist(tag_) {
  for (var i = 0; i < tagPlaylist.length; i++) {
    if (tagPlaylist[i] == tag_) { //if the tag is already in the tagPlaylist
      return
    }
  }
  tagPlaylist.push(tag_)
  refreshTagPlaylist()

  if(tagPlaylist.length == 1) {
    //if this is the first tag in the playlist, start playing...
    nextSong(true)
  }
}

function removeTagFromPlaylist(tag_) {
  index = tagPlaylist.indexOf(tag_)
  if(index > -1) {
    tagPlaylist.splice(index, 1)
  }
  refreshTagPlaylist()
  if(index == 0) {
    nextSong(false)
  }
}

function refreshTagPlaylist() {
  document.getElementById("tagPlaylistContainer").innerHTML = ""
  for (var i = 0; i < tagPlaylist.length; i++) {
    if(i == 0) {
      document.getElementById("tagPlaylistContainer").innerHTML += "<span class=\"tag active\"><a href=\"javascript:playTag('" + tagPlaylist[i] + "')\" class=\"text\">" + tagPlaylist[i] + "</a><a href=\"javascript:removeTagFromPlaylist('" + tagPlaylist[i] + "')\" class=\"button\">-</a></span>"
    }else {
      document.getElementById("tagPlaylistContainer").innerHTML += "<span class=\"tag\"><a href=\"javascript:playTag('" + tagPlaylist[i] + "')\" class=\"text\">" + tagPlaylist[i] + "</a><a href=\"javascript:removeTagFromPlaylist('" + tagPlaylist[i] + "')\" class=\"button\">-</a></span>"
    }
  }
}

function playTag(tag_) {
  if(tagPlaylist.indexOf(tag_) !== 0) {
    removeTagFromPlaylist(tag_) //cut the tag out of the playlist
    tagPlaylist.splice(0,0, tag_)//and paste it to the front of the playlist, pushing everything else back
    refreshTagPlaylist()
  }
  nextSong(false) //then play that song, not shuffling the playlist.
}
