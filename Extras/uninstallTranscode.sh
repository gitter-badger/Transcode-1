#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin export PATH

# set -xv; exec 1>>/private/tmp/uninstallTranscodeTraceLog 2>&1

#-----------------------------------------------------------------------------------------------------------------------------------																		
#	uninstall
#	Copyright (c) 2016 Brent Hayward		
#	
#	
#	This script uninstalls Transcode's infrastructure. It does not remove the Transcode folder, as there may be items 
#	still in the directory that a user needs or wants
#


#----------------------------------------------------------FUNCTIONS----------------------------------------------------------------

function define_Constants () {
                                                     							# define version number
	local versStamp="Version 1.0.3, 05-07-2017"
	readonly scriptVers="${versStamp:8:${#versStamp}-20}"
																				# get the paths
	readonly libDir="${HOME}/Library"
}

function echo_Msg () {
	# ${1}: message to echo
	# ${2}: flag to suppress echo
	
	if [ $# -eq 1 ]; then
		echo "${1}"											# echo to the Terminal
	fi
    echo "${1}" 2>&1 | logger -t transcode.uninstall		# echo to syslog
}

function if_Error () {
	# ${1}: last line of error occurence
	# ${2}: error code of last command
	
	local lastLine="${1}"
	local lastErr="${2}"
																		# if lastErr > 0 then echo error msg and log
	if [[ ${lastErr} -eq 0 ]]; then
		echo_Msg ""
		echo_Msg "Something went awry :-("
		echo_Msg "Script error encountered $(date) in ${scriptName}.sh: line ${lastLine}: exit status of last command: ${lastErr}"
		echo_Msg "Exiting..."
		
		exit 1
	fi
}

function uninstall_Confirm () {
	echo_Msg ""
	echo_Msg "========================================================================="
	echo_Msg "Uninstall Transcode"
	
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [Yn]} " response
    case ${response} in
        [Y][E][S]|[Y] )
			# just continue
			echo_Msg ""
            echo_Msg "Uninstalling Transcode..."
			echo_Msg ""
            ;;

        * )
			# bail out
            exit 1
            ;;
    esac
}

function uninstall_scriptSupport () {
	declare -a removeThis
	
	# remove script support
	removeThis[0]="${libDir}/Application Scripts/com.videotranscode.transcode"
	removeThis[1]="${libDir}/Application Support/Transcode"
	removeThis[2]="/usr/local/bin/aliasPath"
	
	# remove preferences
	for i in "${removeThis[@]}"; do
		if [ -d "${i}" ]; then
			echo_Msg "Removing ${i}"
				
			rm -rf "${i}"
		elif [ -e "${i}" ]; then
			echo_Msg "Removing ${i}"
					
			rm -f "${i}"
		fi
	done
}

function uninstall_launchDaemons () {
	local captureOutput=""
	
	declare -a removeThis
	
	removeThis[0]="${libDir}/LaunchAgents/com.videotranscode.brewautoupdate.plist"
	removeThis[1]="${libDir}/LaunchAgents/com.videotranscode.watchfolder.plist"
	removeThis[2]="${libDir}/LaunchAgents/com.videotranscode.rsync.watchfolder.plist"
	removeThis[3]="${libDir}/LaunchAgents/com.videotranscode.ingest.watchfolder.plist"
	
	# remove LaunchAgents
	for i in "${removeThis[@]}"; do
		echo_Msg "Unloading LaunchAgent and removing ${i}"
		
		capturedOutput=$(launchctl unload "${i}")
		if [[ "${capturedOutput}" != *"No such file or directory"* ]]; then
			rm -f "${i}"
		fi
	done 
}

function uninstall_preferenceFiles () {
	declare -a removeThis
	
	removeThis[0]="${libDir}/Preferences/com.videotranscode.batch.waiting.plist"
	removeThis[1]="${libDir}/Preferences/com.videotranscode.batch.onhold.plist"
	removeThis[2]="${libDir}/Preferences/com.videotranscode.batch.working.plist"
	removeThis[3]="${libDir}/Preferences/com.videotranscode.rsync.batch.waiting.plist"
	removeThis[4]="${libDir}/Preferences/com.videotranscode.rsync.batch.onhold.plist"
	removeThis[5]="${libDir}/Preferences/com.videotranscode.rsync.batch.working.plist"
	removeThis[6]="${libDir}/Preferences/com.videotranscode.ingest.batch.waiting.plist"
	removeThis[7]="${libDir}/Preferences/com.videotranscode.ingest.batch.onhold.plist"
	removeThis[8]="${libDir}/Preferences/com.videotranscode.ingest.batch.working.plist"
	
	# remove preferences
	for i in "${removeThis[@]}"; do
		if [ -e "${i}" ]; then
			echo_Msg "Removing ${i}"
	
			rm -f "${i}"
		fi
	done
}

function uninstall_finderServices () {
	declare -a removeThis
	
	removeThis[0]="${libDir}/Services/Transcode • Update Finder Info.workflow"
	removeThis[1]="${libDir}/Services/Transcode • Set Ingest Path.workflow"
	removeThis[2]="${libDir}/Services/Transcode • Set Output Destination.workflow"
	
	# remove the Finder Services
	for i in "${removeThis[@]}"; do
		if [ -e "${i}" ]; then
			echo_Msg "Removing Finder Service ${i}"
	
			rm -rf "${i}"
		fi
	done
}

function uninstall_brewPkgs () {
	declare -a removeThis
	
	removeThis[0]="atomicparsley"
	removeThis[1]="ffmpeg"
	removeThis[2]="mkvtoolnix"
	removeThis[3]="mp4v2"
	removeThis[4]="mplayer"
	removeThis[5]="rsync"
	removeThis[6]="tag"
	
	# brew, remove if in place
	for i in "${removeThis[@]}"; do
		if [[ ${installedBrews} = *"${i}"* ]]; then
			echo_Msg "Removing brew ${i}"
			
			brew uninstall ${i}
		fi
	done
}

function uninstall_brewCasks (){
	declare -a removeThis
	
	removeThis[0]="filebot"
	removeThis[1]="handbrakecli"
	removeThis[2]="java"
	
	installedCasks=$(brew cask list)
	
	# brew, remove caskroom/cask/brew-cask if in place
	for i in "${removeThis[@]}"; do
		if [[ ${installedCasks} = *"${i}"* ]]; then
			echo_Msg "Removing brew-cask ${i}"
			
			brew cask uninstall ${i}
		fi
	done
}

function uninstall_rubyGems () {
	declare -a removeThis
	
	removeThis[0]="video_transcoding"
	removeThis[1]="terminal-notifier"
	
	# ruby, remove gems if in place
	installedGems=$(gem list)
	
	for i in "${removeThis[@]}"; do
		if [[ ${installedGems} = *"${i}"* ]]; then
			echo_Msg "Removing gem ${i}"
			
			sudo gem uninstall ${i}
		fi
	done
	
	if [[ ${installedBrews} = *"ruby"* ]]; then
		echo_Msg "Removing brew ruby"
		
		brew rm ruby
	fi
}

function uninstall_commandLineTools () {
	local removeThis="/Library/Developer/CommandLineTools"
	
	if [ -d "${removeThis}" ]; then
		echo_Msg "${removeThis}"
		
		rm -rf "${removeThis}"
	fi
}

function clean_Up () {
	echo
	echo $'\e[92mThis window can now be closed.\e[0m'
	echo
}

function __main__ () {
	uninstall_Confirm
	uninstall_scriptSupport
	uninstall_launchDaemons
	uninstall_preferenceFiles
	uninstall_finderServices
	uninstall_brewCasks
	
	installedBrews=$(brew list)
	
	uninstall_brewPkgs
	uninstall_rubyGems
	
	uninstall_commandLineTools
	
	echo
	echo_Msg "Transcode infrastructure was succesfully uninstalled.\nThe Transcode folder has been left in place."
}


#-------------------------------------------------------------MAIN-------------------------------------------------------------------
																							# execute
trap clean_Up INT TERM EXIT																	# always run clean_Up regardless of how the script terminates
trap "exit" INT																				# trap user cancelling
trap 'if_Error ${LINENO} $?' ERR															# trap errors
printf '\e[8;24;130t'																		# set the Terminal window size to 148x24

define_Constants

__main__

exit 0