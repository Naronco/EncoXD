module Generated.MainMenu;

import Scenes.MainMenu;
import EncoGL3;
import EncoShared;

void generateMainMenu(MainMenu menu) {
	DynamicColorControl _dynamiccolorcontrol1 = new DynamicColorControl();
	_dynamiccolorcontrol1.x = (0);
	_dynamiccolorcontrol1.y = (0);
	_dynamiccolorcontrol1.width = (100);
	_dynamiccolorcontrol1.height = (30);
	_dynamiccolorcontrol1.alignment = (Alignment.MiddleCenter);
	_dynamiccolorcontrol1.color = (Color.fromRGB(0x3F51B5));
	menu.addChild(_dynamiccolorcontrol1);
	TextControl!GLTexture _textcontrol2 = new TextControl!GLTexture();
	_textcontrol2.font = (new Font("res/fonts/Roboto/Roboto-Regular.ttf", 16));
	_textcontrol2.alignment = (Alignment.MiddleCenter);
	_textcontrol2.text = ("Text");
	_dynamiccolorcontrol1.addChild(_textcontrol2);
}