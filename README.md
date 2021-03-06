# Deploy-NexusBannerlordMods

## Description

This [script](Deploy-NexusBannerlordMods.ps1) is meant to be used to deploy mods for the game "Mount and Blade 2: Bannerlord", which are managed by Nexus Mods [Vortex Mod Manager](https://www.nexusmods.com/site/mods/1?tab=files). It is written in powershell and borrows some functionality from [MergeXML](https://gallery.technet.microsoft.com/office/Merge-Two-XML-Files-using-a5010498).

## Synopsis

This script is meant to be an assist to vortex mod manager, which does a great job organizing mods and updating them, but at least for this newer game it struggles with deployment, for a couple of reasons.

1. In some cases where something has changed significantly in the file structure of the mod being updated, old or renamed files are left deployed and not removed on deployment. This can cause incompatabilities and crashes when playing the game.
2. Bannerlord mods often come with highly-configurable XML config files which are already popular for modders and users to tweak the mods to suit their tastes. This is fantastic for mods and players, but it makes updating a struggle. If you simply download a new version of a mod with nexus and deploy, poof - all of your tweaks are gone and replaced with default values. Probably a common mistake for a new mod user.
3. It does not back up your old configs, just blows them away. So I have done my best to make sure they get saved. After running this, you should find any config files backed up one directory above your mods directory (the -BannerlordsModPath parameter) in a new folder calls "Config Backups".
All of this said, there is a good chance the Vortex developers will solve these problems or some smarter soul will build a dedicated mod manager for Bannerlord. But this is a good workaround until then!

## Usage

Before going further, note that it is likely this will not work for you if you do not have local administration priviledges on your computer. It also will probably not work well outside of Windows 10.
Experienced powershell users can probably find creative ways to use the actual [script](Deploy-NexusBannerlordMods.ps1). For other users the easiest way to use this is to download the repo as a zip file (near the top of the page) and simply run the file "Run-Deploy-NexusBannerlordMods.ps1" - This will then prompt you to enter the input parameters, described below.

This will deploy any mod that is INSTALLED in Vortex. Enabled or disabled does not matter. If you don't want something deployed, make sure to "uninstall" it in Vortex!

-BannerlordPath : This is the path to the root of the game. The most common path I believe is  "C:\Program Files(x86)\steam\steamapps\common\Mount & Blade II Bannerlord\" but that is not mine so might be wrong. Wherever steam installed the game I guess.

-BannerlordModsPath : This is the path to where Vortex stores the mods. Usually in your profile folder appdata: "C:\Users\YourUserNameHere\AppData\Roaming\Vortex\mountandblade2bannerlord\mods\" - Easiest way to find the exact path is to right click a mod in Vortex, click "Open in file manager" and then press the up button in windows explorer to move up one directory. This is the right path to copy.

-MergeConfigs : Just a switch that takes no arguments. This is the real reason I did this, to auto merge configs. But it's also the thing that is most likely to break your deployment. If it does, I suggest doing another deploy without this flag and then manually restore your config files from the backup location.

Of course I recommend [making a shortcut](https://winaero.com/blog/create-shortcut-ps1-powershell-file-windows-10/) for this so you can click once each time, and power users can link the shortcut withing Vortex itself. Just never use both this and the vortex deploy! If you use this, then do not deploy with Vortex and visa versa.
