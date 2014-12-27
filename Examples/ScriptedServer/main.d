import EncoShared;

import std.socket;
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

		Socket client = new TcpSocket();
		scope(exit) client.close();
		assert(client.isAlive);
		client.blocking = true;
		client.connect(new InternetAddress("127.0.0.1", 4578));

		Logger.writeln("Connected");

		void[] buf = new void[512];

		while(true)
		{
			int i = client.receive(buf);

			if(i > 1)
			{
				
				Logger.writeln(cast(char[])buf[0 .. i]);
			}

			buf = new void[512];
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

		Socket listener = new TcpSocket();
		assert(listener.isAlive);
		scope(exit) listener.close();
		listener.blocking = true;
		listener.bind(new InternetAddress(port));
		listener.listen(5);
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
					client.send(msg);
				}

				string receive(int len)
				{
					void[] msg = new void[len];
					client.receive(msg);
					return cast(string)((cast(char[])msg).idup);
				}

				void sleep(int ms)
				{
					Thread.sleep(dur!("msecs")(ms));
				}

				EncoContext.instance.luaEmit("join", &send, &receive, &sleep);
				client.send("\0");
				client.close();
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
		new Server(to!u16(args[1])).start();
	else
		new Client().start();

	while(true) {}
}
