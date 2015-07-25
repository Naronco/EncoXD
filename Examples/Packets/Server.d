module Server;

import std.socket;
import std.bitmanip;
import std.algorithm;

import core.thread;

import EncoShared;

class Server
{
private:
	int _id = 0;

public:
	this(ushort port)
	{
		this.port = port;
	}

	void connection(Object sender, AsyncTCPSocket client)
	{
		int id = _id++;
		std.stdio.writeln("Incoming connection from Socket #", id, " (", client.remoteAddress.toAddrString(), ")");
		client.onData += (c, data)
		{
			ushort packetID = data.read!ushort();

			if(packetID != 65500)
			{
				std.stdio.writeln("Invalid packet from Socket #", id);
				client.shutdown(SocketShutdown.BOTH);
				client.close();
				return;
			}
			std.stdio.writefln("Received packet #%s from Socket #%s", packetID, id);

			StringPacket strPacket = new StringPacket();
			strPacket.deserialize(data);
			std.stdio.writeln(strPacket.text);

			if(strPacket.text == "password")
			{
				client.send(nativeToBigEndian(StringPacket.PACKET_ID) ~ new StringPacket("Password Accepted!").serialize());
			}
		};
		client.receiveAsync();
	}

	void listen()
	{
		mutex = new Mutex;
		socket = new AsyncTCPSocket();
		socket.bind(new InternetAddress(port));

		socket.onError += (sender, e)
		{
			Logger.writeln("Error!");
			throw e;
		};
		socket.onConnection += &connection;

		socket.listenAsync(0);
		
		while(true)
		{
			Thread.sleep(50.msecs);
		}
	}

	void stop()
	{
		socket.shutdown(SocketShutdown.BOTH);
		socket.close();
	}

	ushort port;
	AsyncTCPSocket socket;
}