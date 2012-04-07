#define OSCPKT_OSTREAM_OUTPUT
#include "oscpkt/oscpkt.hh"
#include "oscpkt/udp.hh"

using std::cout;
using std::cerr;

using namespace oscpkt;

const int PORT_NUM = 9109;

void runServer() {
	UdpSocket sock; 
	sock.bindTo(PORT_NUM);
	if (!sock.isOk()) {
		cerr << "Error opening port " << PORT_NUM << ": " << sock.errorMessage() << "\n";
	} else {
		cout << "Server started, will listen to packets on port " << PORT_NUM << std::endl;
		PacketReader pr;
		//PacketWriter pw;
		while (sock.isOk()) {			
			if (sock.receiveNextPacket(30 /* timeout, in ms */)) {
				pr.init(sock.packetData(), sock.packetSize());
				oscpkt::Message *msg;
				while (pr.isOk() && (msg = pr.popMessage()) != 0) {
					int iarg;
					cout << "Server: received " << *msg << "\n";
					/*
					if (msg->match("/ping").popInt32(iarg).isOkNoMoreArgs()) {
						cout << "Server: received /ping " << iarg << " from " << sock.packetOrigin() << "\n";
						Message repl; repl.init("/pong").pushInt32(iarg+1);
						pw.init().addMessage(repl);
						sock.sendPacketTo(pw.packetData(), pw.packetSize(), sock.packetOrigin());
					} else {
						cout << "Server: unhandled message: " << *msg << "\n";
					}
					*/
				}
			}
		}
	}
}

void runClient() {
	UdpSocket sock;
	sock.connectTo("localhost", PORT_NUM);
	if (!sock.isOk()) {
		cerr << "Error connection to port " << PORT_NUM << ": " << sock.errorMessage() << "\n";
	} else {
		cout << "Client started, will send packets to port " << PORT_NUM << std::endl;
		int iping = 1;
		while (sock.isOk()) {
			Message msg("/ping"); msg.pushInt32(iping);
			PacketWriter pw;
			pw.startBundle().startBundle().addMessage(msg).endBundle().endBundle();
			bool ok = sock.sendPacket(pw.packetData(), pw.packetSize());
			cout << "Client: sent /ping " << iping++ << ", ok=" << ok << "\n";
			// wait for a reply ?
			if (sock.receiveNextPacket(30 /* timeout, in ms */)) {
				PacketReader pr(sock.packetData(), sock.packetSize());
				Message *incoming_msg;
				while (pr.isOk() && (incoming_msg = pr.popMessage()) != 0) {
					cout << "Client: received " << *incoming_msg << "\n";
				}
			}
		}
		cout << "sock error: " << sock.errorMessage() << " -- is the server running?\n";
	}
}

int main(int argc, char **argv) {
	/*
	if (argc > 1 && strcmp(argv[1], "--cli") == 0) {
		runClient();
	} else if (argc > 1 && strcmp(argv[1], "--serv") == 0) {
	*/
		runServer();
	/*} else {
		cout << "syntax: --serv to run as server, --cli to run as client\n";
	}*/
}
