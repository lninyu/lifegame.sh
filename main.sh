#!/usr/bin/env bash
declare -a moveKeys=( 'w' 'a' 's' 'd' )
declare    eventLoopInputBuffer

f_Move(){
	local    _T="${moveKeys[0]}${moveKeys[1]}${moveKeys[2]}${moveKeys[3]}"
	local    __T=${eventLoopInputBuffer//[!${_T}]/}

	while ((${#__T}));do
		case ${__T:0:1} in
			("${moveKeys[0]}") ((cursorPos[0] > 1))             && ((cursorPos[0]--));; # up
			("${moveKeys[1]}") ((cursorPos[1] > 1))             && ((cursorPos[1]--));; # left
			("${moveKeys[2]}") ((cursorPos[0] < screenSize[0])) && ((cursorPos[0]++));; # down
			("${moveKeys[3]}") ((cursorPos[1] < screenSize[1])) && ((cursorPos[1]++));; # right
		esac; __T=${__T:1}
	done; eventLoopInputBuffer="${eventLoopInputBuffer//[${_T}]/}"
}
f_EventLoopInput(){
	local _T __T
	for((_T=0;_T<4;_T++)){
		read -sr -n1 -t0.01 __T
		eventLoopInputBuffer+="${__T}"
	}
}
f_EventLoop(){
	for((;;)){
		f_EventLoopInput
	}
}
f_Main(){
	:
};f_Main "${@}"