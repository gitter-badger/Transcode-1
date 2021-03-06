# Transcode
Tools to batch transcode and process videos

## About
Transcode is a set of tools to batch transcode Blu-ray Discs and DVDs into a smaller, more portable format while remaining high enough quality to be mistaken for the originals. Transcode is a wrapper that builds upon Don Melton’s exceptional video transcoding toolset.

* [About](#about)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Guide](#guide)
* [Workflows](#workflows)
* [History](#history)
* [Acknowledgements](#acknowledgements)

## Requirements
OS X 10.11 El Capitan or later.

Most of the tools in this package require other software to function properly.

Transcode Setup Assistant will install these command line programs:

* `aliasPath`
* `atomicparsely`
* `ffmpeg`
* `filebot`
* `handbrakecli`
* `Homebrew`
* `Java`
* `mkvtoolnix`
* `mplayer`
* `rsync`
* `ruby`
* `tag`
* `terminal-notifier`
* `transcode_video`
* `Xcode command-line tools`

In addition, a Blu-ray or DVD [reader](www.amazon.com/Samsung-External-Blu-ray-SE-506CB-RSBD/dp/B00JJGFRIQ/ref=pd_sim_147_4?ie=UTF8&dpID=21l0PtOb6GL&dpSrc=sims&preST=_AC_UL160_SR160,160_&refRID=02K1BF563A1RE2C79GV5) is recommended.

## Installation
To get started, download the [latest release](https://github.com/bmhayward/Transcode/releases) and install Transcode by running the Transcode Setup Assistant.

Launch Transcode Setup Assistant:
```
Select the location for the Transcode folder
```
One installer and the Terminal will launch:
```
1. Complete the installation of the Xcode command-line tools
2. Select the open Terminal window once Xcode has been installed
3. Press [Return]
4. Enter the local administrator password when prompted
5. Click OK once the Setup Assistant has completed
6. Close the open Terminal window
7. Safari has opened the download page for two additional tools you may find helpful, MakeMKV and VLC
```

## Usage
Drop `.mkv` files into:
```
/Transcode/Convert
```
to automatically batch convert video files.

Transcoding will start after all content has been copied to the Convert folder.

### Batch Transcoding

Transcode uses a batch queue mechanism to manage content for transcoding. As content is added to the Convert folder, a ```watchFolder``` LaunchAgent waits for the Convert folder size to stabilize.

Once the Convert folder has stabilized, ```watchFolder``` launches ```batch.command``` from the Transcode folder to begin transcoding.

Depending upon how content is being added to the Convert folder, `watchFolder` will wait:
```
a minimum of 20 seconds after folder stabilization to start transcoding
a maximum of 60 seconds after folder stabilization to start transcoding
```
If content is added while transcoding is active, `watchFolder` will create a new batch queue for the added content. The new batch queue will start once the active queue has completed.
This queueing process allows for content to be continuously streamed or copied to the Convert folder.

To stop the transcode process:
```
1. Select the transcode process Terminal window
2. Press command-period
```
To restart a transcode process:
```
Double-click batch.command in the Transcode folder
or
Drag files out of and back into the Convert folder
```
### Compression

The `transcode-video tool` configures the [x264 video encoder](www.videolan.org/developers/x264.html) within HandBrake to provide a [constrained variable bitrate (CVBR)](https://en.wikipedia.org/wiki/Variable_bitrate) mode. This automatically targets bitrates appropriate for different input resolutions.

Input resolution | Target video bitrate
--- | ---
1080p or Blu-ray video | 8000 Kbps
720p | 4000 Kbps
480i, 576p or DVD video | 2000 Kbps

When audio transcoding is required, it is done in an [AAC format](https://en.wikipedia.org/wiki/Advanced_Audio_Coding) and, if the original is [multi-channel surround sound](https://en.wikipedia.org/wiki/Surround_sound), in [Dolby Digital AC-3 format](https://en.wikipedia.org/wiki/Dolby_Digital).

Input channels | AAC track | AC-3 track
--- | --- | ---
Mono | 80 Kbps | none
Stereo | 160 Kbps | none
Surround | 160 Kbps | 640 Kbps with 5.1 channels

### Reducing output size

If reducing output size is more important than quality, change the Transcode output quality preference to `small`, in Transcode’s preferences. The video bitrate targets will be lowered 33-37 percent depending upon the video resolution of the input.

For additional details, see this discussion of [reducing output size](https://github.com/donmelton/video_transcoding#reducing-output-size).

### Improving performance

If increased video encoding speed is important, change the Transcode output quality preference to `quick`, in Transcode’s preferences. This will trade some precision for a 45-50 percent increase in video encoding speed. Note, output files are slightly larger when using the `quick` option, since the loss of precision is also a loss of efficiency.

For additional details, see this discussion of [improving performance](https://github.com/donmelton/video_transcoding#improving-performance).

### Auto-Cropping

Cropping provides faster transcoding and higher quality as there are fewer pixels to read and write.

Transcode uses the `detect-crop tool`, part of the `transcode-video` toolset, to determine the optimal video cropping bounds.
Transcode auto-crops all content.

For additional details, see this discussion of the [detect-crop tool](https://github.com/donmelton/video_transcoding#cropping).

### Audio

The `transcode-video` tool selects the first audio track in the input as the main audio track. This is the first track in the output and the default track for playback. The main audio track is transcoded in AAC format and, if the original is multi-channel surround sound, in Dolby Digital AC-3 format. Any additional audio tracks are only transcoded in AAC format.

For additional details, see this discussion about [understanding audio](https://github.com/donmelton/video_transcoding#understanding-audio).

### Auto-Renaming

Transcode auto-renames transcoded files based on matches from the [TheMovieDB](https://www.themoviedb.org) and the [TheTVDB](thetvdb.com). A transcoded files ‘title’ metadata tag is also set to the renamed movie or TV show.

Transcode auto-renames transcoded files using these formats:
```
Movies: Name (Year of Release).ext
TV Shows: Name - sXXeYY - Episode Name.ext
Multi-Episode TV Shows: Name - sXXeYY-eZZ.ext
```
Where for TV Shows:
 * `XX`  is the season number
 * `YY`  is the episode number
 * `ZZ`  is the last episode number

For example, if the original filename of a movie is:
```
WALL-E_t00.mkv
```
the transcoded movie filename is:
```
Wall-E (2008).m4v
```
Similarly, if the original filename of a TV show is:
```
ANIMANIACS_S2E11_t01.mkv
```
where season/episode are indicated by S2E11, the transcoded TV show filename is:
```
Animaniacs - s02e011 - Critical Condition.m4v
```
In the case of a multi-episode TV show, if the original filename is:
```
TWIN_PEAKS_S1E1E8_t00.mkv
```
where the season/episodes are indicated by S1E1E8, the transcoded multi-episode TV show filename is:
```
Twin Peaks - s01e01-e08.m4v
```

Auto-renaming can be modified via Transcode’s preferences. 

For additional details about filename formatting expressions, see this [discussion](www.filebot.net/naming.html).

### Finder Tags

Transcode applies Finder tags to both the original files (`.mkv`) and the transcoded files (`.mkv`, `.m4v` or `.mp4`). This makes it easy to locate any file touched by Transcode.

By default, the following Finder tags are applied:
```
Originals: Blue and Converted
Movies: Purple, Movie and VT
TV Shows: Orange, TV Show and VT
Extras/Specials: Yellow, Extra and VT
```
Finder tags and ‘title’ metadata tags can be set in bulk with the `Transcode • Update Finder Info` Finder Service. This provides individual or mass file tagging via the Finder’s Services menu.

Tag definitions can be added, edited or deleted in Transcode’s preferences.

### File Moving

#### Default transcode destination

Transcode will move files to default destinations once transcoding has completed:
```
Converted files are moved to /Transcode/Completed
.mkv files are moved to /Transcode/Originals
Log files are moved to /Transcode/Logs
```

#### Custom transcode destination

Transcoded content can be automatically moved to to a destination other than the Completed folder, e.g. 
`/Media/Plex`, `/iTunes Media`, etc.

To set a custom output destination, `control-click` the destination folder in the Finder and select `Transcode • Set Output Destination` from the Finder Services menu.

After setting the output destination, Transcode will automatically move content to the following custom destination:
```
Movies: /root/Movies/{Movie Title}
TV Shows: /root/TV Shows/{Show Title}/Season #
TV Show Specials: /root/TV Shows/{Show Title}/Season #/Specials
Extras: /root/Movies/{Movie Title}/{Extras Tag}
```
where the `Movies`, `TV Shows`, `Extras` or `Specials` folders and subfolders are created as needed.

Custom destinations will be ignored, if the renaming format for a movie or TV show differs from the default preference or the content name starts with `@` character.

#### Movie extras

It is possible to have transcoded “extras” moved to the appropriate collection in a custom destination e.g. `/Plex/Movies/Ice Age/Shorts/Gone Nutty.m4v`.

To place an “extra” in the appropriate collection, title the originating content using the following convention:
```
{title name}#{extras tag}-{descriptive name}
```
where the extras tag identifiers are:
```
Behind The Scenes
Deleted Scenes
Featurettes
Interviews
Scenes
Shorts
Trailers
```
For example, the White Christmas DVD contains the featurette, “A Look Back with Rosemary Clooney.” To add this to the White Christmas collection in Plex or iTunes, name the title:
```
WHITE_CHRISTMAS_(1954)#Featurettes-A Look Back with Rosemary Clooney.mkv
```

The transcoded title will be placed in:
```
/root/Movies/White Christmas (1954)/Featurettes/A Look Back with Rosemary Clooney.m4v 
```

#### TV specials

It is possible to have transcoded “specials” moved to the appropriate collection in a custom destination e.g. `/Plex/TV Shows/Futurama/Specials/Futurama s00e01 - Interview with Matt Groening.m4v`.

To place a “special” in the appropriate collection, title the originating content using the following convention:
```
{title name}_{specials tag}#{descriptive name}
```
where the specials tag identifier is `S00EYY`.

For example, the Futurama Season 1 DVD contains an interview with Matt Groening. To add this to the Futurama collection in Plex or iTunes, name the title:
```
FUTURAMA_S00E1#Interview with Matt Groening.mkv  
```

The transcoded title will be placed in:
```
/root/TV Shows/Futurama/Specials/Futurama s00e01 - Interview with Matt Groening.m4v 
```

#### Multi-volume ingest

Transcode can use separate volumes on the same system to ingest and transcode content.

To set an ingest folder on a secondary volume, `control-click` the ingest folder in the Finder and select `Transcode • Set Ingest Path` from the Finder Services menu.

#### Remote transcode

Transcode can accept transcoded content (`.mkv`, `.m4v` or `.mp4` files) from remote Transcode ingest sources. This allows off-loading or parallel transcoding of content. Transcode accomplishes this by connecting to the Transcode destination using `rsync` over `ssh`.

To setup trusted `auto-ssh` between a Transcode ingest source and a Transcode destination:
```
1. Double-click /Transcode/Extras/setupDestinationAutoConnect.command on the Transcode destination
2. Double-click /Transcode/Extras/setupIngestAutoConnect.command on the Transcode ingest source(s)
```

### Auto-Update

Transcode automatically maintains updates of all installed brew formulas, brew casks and Ruby gems. Transcode checks everyday at 3 a.m. and updates any brew or brew cask. If a gem update is found, an update dialog will be presented asking to proceed with the specific gem update.

To see a list of applied updates, open the Console and search for ‘brew.’ or ‘gem.’.

## Guide

### Preparing Media for Transcoding

Don Melton’s four rules for preparing media for transcoding:

1. Use [MakeMKV](www.makemkv.com/download/) to rip Blu-ray Discs and DVDs.
2. Rip each selected video as a single Matroska format `.mkv` file.
3. Look for forced subtitles and isolate them in their own track.
4. Convert lossless audio tracks to [FLAC format](https://en.wikipedia.org/wiki/FLAC).

For additional details, see this discussion of the [rationale](https://github.com/donmelton/video_transcoding#rationale) of video transcoding.

### Preferences

Transcode’s preferences can be modified to tailor your workflow. The preference file is a plain text file located in `/Transcode/Prefs.txt`.

The preference file contains the following:
```
Transcoded file extension, default: m4v can also be mkv or mp4
Delete original file, default: false or true to auto-delete
Movie Finder tags, comma separated, default: purple,Movie,VT
TV Show Finder tags, comma separated, default: orange,TV Show,VT
Original file Finder tags, comma separated, default: blue,Converted
Auto-rename files, default: auto or movie, tv, or off
Movie rename format, default: blank
TV Show rename format, default: {n} - {'s'+s.pad(2)}e{e.pad(2)} - {t}
Transcode completed move path, default: blank
ssh username, default: blank
Transcode remote folder path, default: blank
Transcode ingest folder path, default: blank
Extras Finder tags, comma separated, default: yellow,Extra,VT
Output quality, default: blank
```

### MakeMKV

MakeMKV is a free, try before you buy tool, that runs on most desktop computer platforms like OS X, Windows and Linux.

MakeMKV was designed to decrypt and extract a video track, usually the main feature of a disc and convert it into a single [Matroska](https://github.com/donmelton/video_transcoding#why-a-single-mkv-file) format `.mkv` file, which it does really, really well.

MakeMKV is not pretty and not particularly easy to use, but once you get the hang of it, you can rip video exactly the way you want.

#### MakeMKV tips

After inserting a disc:
```
Click the Open DVD disc icon to load a discs titles
```
To have MakeMKV automatically load a Blu-ray Disc or DVD:
```
Open System Preferences>CDs & DVDs
Select When you insert a video DVD: Open MakeMKV
```
Prior to transcoding a title, you can change a titles name by:
```
Selecting the titles Description in the main area
Select Properties>Name
Edit Name field in the Properties area
```
Title naming conventions:
```
Movies: HAPPY_GILMORE
TV Shows: FAMILY_GUY_S6E1
Multi-Episode TV Show: BETTER_CALL_SAUL_S1E1E10
Extras: INSIDE_OUT_(2015)#Shorts-Lava
Skip renaming & auto-move: @RATATOUILLE_EXTRAS
Force decomb filter: +ICE_AGE#Behind The Scenes-Making Of 
```
Verify a movie or TV show title:
```
Movies: go to TheMovieDB (https://www.themoviedb.org) website
TV Shows: go to TheTVDB (thetvdb.com) website
```
To FLAC encode audio:
```
Select MakeMKV>Profile>FLAC
```
Default to FLAC audio encode:
```
MakeMKV>Preferences>Advanced>FLAC
```
MakeMKV can have its output sent directly to the Convert folder for ingest by Transcode:
```
MakeMKV>Preferences>Video>Custom
```
MakeMKV language defaults can be used to narrow the auto-language selection of titles:
```
MakeMKV>Preferences>Language
```
MakeMKV default selection rules control how MakeMKV selects titles, audio, languages and subtitles:
```
MakeMKV>Preferences>Advanced>Default selection rule:
```
The default selection rules are a comma-separated list of tokens. Each token has a format of {action}:{condition} and are evaluated from left to right.

For example, this default selection rule:
```
-sel:all,+sel:audio&(eng),-sel:(havemulti),-sel:mvcvideo,-sel:subtitle,-sel:special,=100:all,-10:eng
```
invokes the following:
```
-sel:all            ->	deselect all tracks
+sel:audio&(eng)    ->	select all audio tracks in English
-sel:(havemulti)    ->	Deselect all mono/stereo tracks which a multi-channel track in same language
-sel:mvcvideo       ->	Deselect 3D multi-view videos
-sel:subtitle       ->	Deselect all subtitle tracks
-sel:special        ->	Deselect all special tracks (director’s comments etc.)
=100:all            ->	set output weight 100 to all tracks
-10:eng             ->	decrement the weight of all tracks in English language by 10 (to make them the first ones in  output)
```
The tokens and operators used by the default selection rule are:
```
  +sel      - select track
  -sel      - unselect track
  +N        - add decimal value N to track weight
  -N        - subtract decimal value N from track weight
  =N        - set track weight to decimal value N	

default selection tokens:
  all       - always matches
  xxx       - matches specific language (ISO 639-2B/T code - eng,fra,etc...)
  N         - matches if Nth (or bigger) track of the same type and language
  favlang   - matches favorite languages, always matches if no favorite language is set
  special   - matches if track is special (directors comments, childrens, etc)
  video     - matches if track is video
  audio     - matches if track is audio
  subtitle  - matches if track is subtitle

video tracks:
  mvcvideo  - matches if track is a 3D multi-view video
  
audio tracks, special tracks never match:
  mono          - matches if mono
  stereo        - matches if stereo
  multi         - matches if multi-channel
  havemulti     - matches if track is mono/stereo and there is a multi-channel track in same language
  lossy         - matches if non-lossless
  lossless      - matches if lossless
  havelossless  - matches if non-lossless track, but there is a lossless track in same language
  core          - matches if this track is core audio, logical part of hd track
  havecore      - matches if this track is hd track with core audio

subtitle tracks:
  forced  - matches if track is forced

operators:
  | 		- logical or
  & 		- logical and
  ! 		- logical not
  ~ 		- alias for "!", logical not
  * 		- alias for "&", logical and
```

## Workflows
### Out-of-Box

This scenario makes use of:
* default transcode destination `/Transcode/Completed` 
* default ingest location `/Transcode/Convert` 
* default FLAC audio encoding
* default rename formatting
* default Finder tagging

#### Setup

1. Open Transcode Setup Assistant to install Transcode
2. Download [MakeMKV](www.makemkv.com/download/)
3. Download [VLC](www.videolan.org/index.html)
4. Open MakeMKV
5. Select `MakeMKV>Preferences>Video>Custom` 
6. Click `Set output folder` 
7. Select `/Transcode/Convert`
8. Select `MakeMKV>Preferences>General`
9. Check `Expert mode` 
10. Select `MakeMKV>Preferences>Advanced` 
11. Select `Default profile: FLAC` 
12. Click Apply
13. Click OK

#### Use

1. Insert a Blu-ray or DVD disc
2. Open MakeMKV or have it open automatically
3. Click `Open DVD disc` icon 
4. Uncheck the title(s) **NOT** to rip
5. Provide a name for the checked title(s)
6. Click `Save selected titles` 
7. Goto Step 1

### Custom Destination

This scenario makes use of:
* Plex or iTunes as the transcode output destination
* default ingest location /Transcode/Convert 
* default FLAC audio encoding
* default rename formatting
* default Finder tagging

#### Setup

1. Open Transcode Setup Assistant to install Transcode
2. Download [MakeMKV](www.makemkv.com/download/)
3. Download [VLC](www.videolan.org/index.html)
4. Open MakeMKV
5. Select `MakeMKV>Preferences>Video>Custom` 
6. Click `Set output folder` 
7. Select `/Transcode/Convert`
8. Select `MakeMKV>Preferences>General`
9. Check `Expert mode` 
10. Select `MakeMKV>Preferences>Advanced` 
11. Select `Default profile: FLAC` 
12. Click Apply
13. Click OK
14. `Control-click` the transcode destination folder in the Finder and select `Transcode • Set Output Destination` from the Finder Services menu

#### Use

1. Insert a Blu-ray or DVD disc
2. Open MakeMKV or have it open automatically
3. Click `Open DVD disc` icon 
4. Uncheck the title(s) **NOT** to rip
5. Provide a name for the checked title(s)
6. Click `Save selected titles` 
7. Goto Step 1

### Multi-volume Ingest

This scenario makes use of:
* default transcode destination /Transcode/Completed 
* multi-volume ingest
* default FLAC audio encoding
* default rename formatting
* default Finder tagging

#### Setup

1. Open Transcode Setup Assistant to install Transcode
2. Create an ingest folder on the secondary volume
3. `Control-click` the ingest folder in the Finder and select `Transcode • Set Ingest Path` from the Finder Services menu
4. Download [MakeMKV](www.makemkv.com/download/)
5. Download [VLC](www.videolan.org/index.html)
6. Open MakeMKV
7. Select `MakeMKV>Preferences>General`
8. Check `Expert mode` 
9. Select `MakeMKV>Preferences>Advanced` 
10. Select `Default profile: FLAC` 
11. Click Apply
12. Click OK

#### Use

1. Insert a Blu-ray or DVD disc
2. Open MakeMKV or have it open automatically
3. Click `Open DVD disc` icon 
4. Uncheck the title(s) **NOT** to rip
5. Provide a name for the checked title(s)
6. Click `Save selected titles` 
7. Goto Step 1

### Remote Transcode

This scenario makes use of:
* remote transcode
* default ingest location `/Transcode/Convert`
* default FLAC audio encoding
* default rename formatting
* default Finder tagging

#### Setup

1. Open Transcode Setup Assistant to install Transcode on the destination
2. Double-click `setupDestinationAutoConnect.command` in `/Transcode/Extras` on the Transcode `destination`
3. Open Transcode Setup Assistant to install Transcode on the source
4. Double-click `setupSourceAutoConnect.command` in `/Transcode/Extras` on the Transcode `source`
5. Download [MakeMKV](www.makemkv.com/download/)
6. Download [VLC](www.videolan.org/index.html)
7. Open MakeMKV
8. Select `MakeMKV>Preferences>Video>Custom` 
9. Click `Set output folder` 
10. Select `/Transcode/Convert` on both the source and destination
11. Select `MakeMKV>Preferences>General` 
12. Check `Expert mode` 
13. Select `MakeMKV>Preferences>Advanced` 
14. Select `Default profile: FLAC` 
15. Click Apply
16. Click OK

#### Use

1. Insert a Blu-ray or DVD disc
2. Open MakeMKV or have it open automatically
3. Click `Open DVD disc` icon 
4. Uncheck the title(s) **NOT** to rip
5. Provide a name for the checked title(s)
6. Click `Save selected titles` 
7. Goto Step 1

### Extras

This scenario makes use of:
* ‘extras tag’ file naming
* default transcode destination /Transcode/Completed 
* default ingest location /Transcode/Convert 
* default FLAC audio encoding
* default rename formatting
* default Finder tagging

#### Setup

1. Open Transcode Setup Assistant to install Transcode
2. Download [MakeMKV](www.makemkv.com/download/)
3. Download [VLC](www.videolan.org/index.html)
4. Open MakeMKV
5. Select `MakeMKV>Preferences>Video>Custom` 
6. Click `Set output folder` 
7. Select `/Transcode/Convert`
8. Select `MakeMKV>Preferences>General`
9. Check `Expert mode` 
10. Select `MakeMKV>Preferences>Advanced` 
11. Select `Default profile: FLAC` 
12. Click Apply
13. Click OK

#### Use

1. Insert a Blu-ray or DVD disc
2. Open MakeMKV or have it open automatically
3. Click `Open DVD disc` icon 
4. Uncheck the title(s) **NOT** to rip
5. Provide a name for the checked title(s)
6. Click `Save selected titles` 
7. Goto Step 1

### The Whole Enchilada

This scenario makes use of:
* remote transcode
* multi-volume ingest
* Plex or iTunes as the transcode output destination
* default FLAC audio encoding
* English language pre-selection of titles
* no subtitles pre-selection
* default rename formatting
* default Finder tagging

#### Setup

1. Open Transcode Setup Assistant to install Transcode on the `destination`
2. Double-click `setupDestinationAutoConnect.command` in `/Transcode/Extras` on the Transcode destination
3. Open Transcode Setup Assistant to install Transcode on the `source`
4. Double-click `setupSourceAutoConnect.command` in `/Transcode/Extras` on the Transcode source
5. Create an ingest folder on the secondary volume of a Transcode source and/or destination. Both source and destination can be used for ingest.
6. `Control-click` the ingest folder in the Finder and select `Transcode • Set Ingest Path` from the Finder Services menu
7. Download [MakeMKV](www.makemkv.com/download/)
8. Download [VLC](www.videolan.org/index.html)
9. Open MakeMKV
10. Select `MakeMKV>Preferences>Language`
11. Select `Interface language: eng: English` 
12. Select `Preferred language: eng: English` 
13. Select `MakeMKV>Preferences>General` 
14. Check `Expert mode`
15. Select `MakeMKV>Preferences>Advanced`
16. Select `Default profile: FLAC`
17. Add `-sel:subtitle` to the Default selection rule. It should now look like: `sel:all,+sel:(favlang|nolang|single),-sel:(havemulti|havecore),-sel:mvcvideo,-sel:subtitle,=100:all,-10:favlang` 
18. Click Apply
19. Click OK
20. `Control-click` the destination folder, on the Transcode destination and in the Finder select `Transcode • Set Output Destination` from the Finder Services menu

#### Use

1. Insert a Blu-ray or DVD disc
2. Open MakeMKV or have it open automatically
3. Click `Open DVD disc` icon 
4. Uncheck the title(s) **NOT** to rip
5. Provide a name for the checked title(s)
6. Click `Save selected titles` 
7. Goto Step 1

## History


## Acknowledgements
A huge “thank you” to [Don Melton](@donmelton) and the developers of the other tools used by this package.
