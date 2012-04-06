all: sendMultiTouches testReceiver

sendMultiTouches: sendMultiTouches.mm
	g++ -F/System/Library/PrivateFrameworks -framework MultitouchSupport $^ -o $@
testReceiver: testReceiver.cpp
	g++ testReceiver.cpp -o testReceiver
clean:
	rm -f sendMultiTouches testReceiver
