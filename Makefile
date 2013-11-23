all: sendMultiTouches testReceiver

sendMultiTouches: src/sendMultiTouches.mm
	g++ -F/System/Library/PrivateFrameworks -framework MultitouchSupport -framework Foundation $^ -o $@
testReceiver: src/testReceiver.cpp
	g++ $^ -o $@
clean:
	rm -f sendMultiTouches testReceiver
