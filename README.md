# Snake in AutoCAD

##Install
Installation of this snake game is really easy, it just requires a few steps

- Open 'Snake.dwg' in AutoCAD
- Manage Tab > Load Application
  - Locate Snake.lsp
  - Click 'Load' 
    - If prompted, click 'Always Load'

##How to Play
There are only 2 things you need to know to play Snake in AutoCAD
- Type 'Snake' in the command line
- Snake will follow your mouse

Disclaimers:
- Always keep your mouse moving for the game to keep moving
- The game gets pretty slow after a while
- This may have bugs but it works good enough

##Customization
You can customize the map size, but to be honest its kinda a pain in the ass
- Open Snake.lsp, and edit 'col' and 'row' to desired size (its on the first few lines)
  - Save and close + May need to reload program
- Delete the current 'grid' on the Snake.dwg file
- Type 'create' in command line
  - I've had mixed results with this, you can get it to work but for some reason it always asks for another parameter, but sometimes it works fine and does not.
  -IF it works, it will be kinda slow. Give it time.
-Make sure to move "GAME OVER" text from the "OVER" layer so that it is visisble from new grid
You can change things like speed of the snake and such
- Open Snake.lsp and change variables at your own discresion
