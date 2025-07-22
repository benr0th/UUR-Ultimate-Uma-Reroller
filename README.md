# UUR (Ultimate Uma Reroller)

This is an AHK (AutoHotkey) script that automates the rerolling process for Uma Musume Pretty Derby Steam Global version. Currently, it only supports rolling on the Kitasan Black banner.

## Disclaimer
This script is not affiliated with or endorsed by Cygames, Inc. or any of its subsidiaries. Use this script at your own risk. The author is not responsible for any issues that may arise from using this script, including but not limited to account bans or data loss. (Realistically, you won't get banned for using this script as it doesn't modify the game files, but better safe than sorry.)

## Pre-requisites

- **You must have the tutorial completed already.**
- AutoHotkey v1 (https://www.autohotkey.com/download/1.1/AutoHotkey_1.1.37.02_setup.exe) must be installed on your system.
- The game must be running in Fullscreen mode.
- The game must be running in English.
- The game must be running from the Steam client.
- Your Steam screenshot hotkey must be set to `F12` (default).
- Only works on Windows.

## How to Use

1. Download the .exe file from the [latest release](https://github.com/benr0th/UUR-Ultimate-Uma-Reroller/releases/latest).
2. Extract to a folder somewhere and open the UUR_Ultimate_Uma_Reroller.exe. (The program creates a folder so putting it in its own folder is preferred)
3. Fill out some configuration options in the window that appears, then the rerolls will commence. You can press `Shift + Escape` to stop the script at any time.
4. Refrain from using the mouse or keyboard (aside from the hotkey just mentioned of course) while the script is running, as it will interfere with the automation process.

## Features

- Rerolls with the following process:
  - Deletes the current account (there is an option to Data Link the current account first if you're logged in already)
  - Makes a new account and skips through everything, grabbing the free carats from the gift box
  - Rolls on Kitasan Black banner until out of carats
  - Takes a screenshot (using Steam) of the List view of the Support Cards
  - Sets up Data Link and takes a screenshot of the Trainer ID
  - Restarts the process until the script is stopped

## Future Plans

- Track the number of LBs gotten of a target card (or any SSR)
- Add ability to roll on any banner
- Add ability to set how many rerolls to do (e.g. stop after target LB)
- Track stats (number of SSRs, number of rerolls done, etc.)
- Refactor the code so it's actually good

## Known Issues
- If a connection error popup occurs in the game, the script will be unable to continue and needs to be manually restarted.

## FAQ

- **Q: Why does the script not work?**
  - A: Ensure that you have the correct version of AutoHotkey installed.
- **Q: It's not clicking anything correctly!**
  - A: This was only tested on my machine, so it may not work as well on others. It **should** work on any resolution, but it was tested on 1440p. Please make a GitHub issue if you're having a specific and consistent problem.
- **Q: Where are my screenshots?**
  - A: The script uses Steam to take screenshots, so they will be in your Steam screenshots folder, you can easily view them by looking at the game in your Steam library.
- **Q: How do I know how many LBs I got?**
  - A: Right now it doesn't check for this. You'll have to check the screenshots and see which account looks decent enough, log in and see if you got any LBs. Hoping to add this in the future. I've added the option to take a screenshot of each x10 roll in the meantime.
- **Q: Help! It keeps clicking on the wrong thing and I can't stop it!**
  - A: Press `Shift + Escape` to stop the script.
- **Q: Why did you make this?**
  - A: I didn't get any Kitasan on my main account and wanted to reroll for her, making a macro was too inconsistent so I made a more consistent script. Also it seemed fun to make.
- **Q: How does it work?**
  - A: It uses image recognition to click parts of the game that inconsistently load by waiting for the images to appear on the screen.
- **Q: How long did this take to make?**
  - A: Longer than I'd like to admit. I'm just going to borrow an MLB Kitasan (unless the reroller hits big).
- **Q: Will you make a mobile version?**
  - A: No, this took way too much trial and error. That's why I made this open source, so you can see the general idea and maybe someone can make a mobile version. I apologize for the code quality in advance, I just wanted to get it working while the banner is still relatively new.

## Credits
- [Pulover's Macro Creator](https://www.macrocreator.com/) for easy script creation. (It starts to freak out when it gets this long though)
- [AutoGUI](https://sourceforge.net/projects/autogui/files/2.5.8/AutoGUI-2.5.8.7z/download) for help creating the configuration GUI
- [AutoHotkey](https://www.autohotkey.com/) for being a dope scripting language
- [Uma Musume Pretty Derby](https://umamusume.jp/) for being a fun game
