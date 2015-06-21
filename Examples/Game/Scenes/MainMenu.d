module Scenes.MainMenu;

static import Generated.MainMenu;

import EncoShared;

class MainMenu : Scene
{
	private ContentManager content;

	public this(ContentManager content)
	{
		this.content = content;
	}

	override public void init()
	{
		Generated.MainMenu.generateMainMenu(this, content);
	}
}
