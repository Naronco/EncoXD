import EncoShared;

import std.conv;
import core.thread;

class Client : Thread
{
	this()
	{
		super(&run);
	}

	void run()
	{
		Thread.sleep(dur!("seconds")(1));

		Logger.writeln("Connecting");

		auto client = new TcpSocket();
		scope(exit) client.disconnect();

		client.bind("127.0.0.1", 4578);
		client.connect();

		Logger.writeln("Connected");

		while(true)
		{
			auto s = new StringPacket();
			client.recv(s);
			Logger.writeln(s.text);
		}
	}
}

class Server : Thread
{
	ushort port;

	this(ushort port)
	{
		super(&run);
		this.port = port;
	}

	void run()
	{
		EncoContext.create();
		scope(exit) EncoContext.instance.stop();

		Thread.sleep(dur!("seconds")(1));

		auto listener = new TcpSocket();
		scope(exit) listener.disconnect();
		assert(listener.bind(port));
		assert(listener.connect());

		Logger.writeln("Listening on 127.0.0.1:", port);


		auto serverInstance = EncoContext.instance.createLuaState();
		serverInstance.loadString(import("network-test.lua")).call();

		while(true)
		{
			try
			{
				auto client = listener.accept();

				void send(string msg)
				{
					client.send(new StringPacket(msg));
				}

				string receive(int len)
				{
					StringPacket p = new StringPacket();
					client.recv(p);
					return p.text;
				}

				void sleep(int ms)
				{
					Thread.sleep(dur!("msecs")(ms));
				}

				EncoContext.instance.luaEmit("join", &send, &receive, &sleep);
				client.disconnect();
			}
			catch(Exception e)
			{
				Logger.errln(e);
			}
		}
	}
}

void main(string[] args)
{
	if(args.length >= 2)
		new Server(parse!u16(args[1])).start();
	else
		new Client().start();

	while(true) {}
}
