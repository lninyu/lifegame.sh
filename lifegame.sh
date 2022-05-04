#!/usr/bin/env bash
set -x
declare -a moveKey=( 'w' 'a' 's' 'd' )
declare    quitKey='Q'
declare    menuKey='m'
declare    cellKey=' '

declare -a cursorPos=( 1 1 )
declare -a screenSize=( "$(tput lines)" "$(($(tput cols)/2))" )
declare -a cells
declare -a cellArraySize=( 10 10 )
declare    eventLoopInputBuffer

f_CursorJumpToUpperLeft(){
	echo -en '\e[1;1H'
}
f_Clear(){
	echo -en '\e[2J'
}
f_Move(){
	local    _T="${moveKey[0]}${moveKey[1]}${moveKey[2]}${moveKey[3]}"
	local    __T="${eventLoopInputBuffer//[!${_T}]/}"

	while ((${#__T}));do
		case ${__T:0:1} in
			("${moveKey[0]}") ((cursorPos[0] > 1))             && ((cursorPos[0]-- ));; # up
			("${moveKey[1]}") ((cursorPos[1] > 1))             && ((cursorPos[1]-- ));; # left
			("${moveKey[2]}") ((cursorPos[0] < screenSize[0])) && ((cursorPos[0]++ ));; # down
			("${moveKey[3]}") ((cursorPos[1] < screenSize[1])) && ((cursorPos[1]++ ));; # right
		esac; __T=${__T:1}
	done
	eventLoopInputBuffer="${eventLoopInputBuffer//[${_T}]/}"
}
f_UpdateScreenSize(){
	shopt -s checkwinsize; (':';':')
	screenSize=(
		${LINES}
		${COLUMNS}
	)
}
f_EventLoopInput(){
	local _T __T
	for((_T=0;_T<4;_T++)){
		read -sr -n1 -t0.01 __T 2> /dev/null
		eventLoopInputBuffer+="${__T}"
	}
}
f_ResetCells(){
	local _Y _X
	cells=()
	for((_Y=0;_Y<cellArraySize[0];_Y++)){
		for((_X=0;_X<cellArraySize[1];_X++)){
			cells+=( 0 )
		}
	}
}
f_ToggleCell(){
	case "${cells[$((cellArraySize[1]*_Y+_X))]}" in
		(0) cells[$((cellArraySize[1]*_Y+_X))]=1 ;;
		(1) cells[$((cellArraySize[1]*_Y+_X))]=0 ;;
	esac
}
f_PrintCells(){
	local    _Y _X _T
	local -a _OUT

	for((_Y=0;_Y<cellArraySize[0];_Y++)){
		for((_X=0;_X<cellArraySize[1];_X++)){
			_OUT[_Y]+=${cells[$((cellArraySize[1]*cursorPos[0]+cursorPos[1]))]}
		}
	}

	printf '%s\n' "${_OUT[@]}" \
#		| sed \
#			-e 's/0/  /g' \
#			-e 's/1/##/g'
}
f_EventLoop(){
	trap 'f_UpdateScreenSize' SIGWINCH

	for((;;)){
		f_EventLoopInput
		f_Clear
		f_CursorJumpToUpperLeft

		case "${eventLoopInputBuffer:0:1}" in
			("${quitKey}") break ;;
			("${menuKey}") ;;
			("${cellKey}") f_ToggleCell ;;
			("${moveKey[0]}"\
			|"${moveKey[1]}"\
			|"${moveKey[2]}"\
			|"${moveKey[3]}") f_Move ;;
		esac

		f_PrintCells

		echo -en "\e[${cursorPos[0]};$((cursorPos[1]*2))H"
		eventLoopInputBuffer="${eventLoopInputBuffer:1}"
	}

	# unTrap
	trap - SIGWINCH
}
main(){
	trap 'echo -en "\e[2J\e[1;1H"' EXIT

	while(($#));do
		case "${1}" in
		(*) echo "opt'${1}' is not exists.";;
		esac
		shift
	done

	f_Clear
	f_ResetCells
	f_EventLoop
}