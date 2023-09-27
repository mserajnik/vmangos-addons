BeneCast version 3.0 for TurtleWoW
______________
|INTRODUCTION|
--------------
BeneCast is a tool to help the player cast beneficial spells on themselves, 
their party members, and friendly targets. It does so by allowing the player to 
pick and choose what spells they want to show up as clickable buttons from the 
BeneCast interface. The interface can be accessed by clicking on the BeneCast 
button on the Minimap frame, it should look like a little book in a circle.

Who can use Benecast? Everyone!
_______
|SETUP|
-------
To use BeneCast, simply place BeneCast folder into 
C:\Program Files\World of Warcraft\Interface\AddOns.
Replace C:\Program Files\ to the directory you have your World of Warcraft
installed if it is different. There is no need to configure any of the files.
Be sure that within the AddOns directory all the files are in a BeneCast
directory.
_______
|USAGE|
-------
Open up the BeneCast interface by clicking the BeneCast button on the Minimap
frame. You can also specify a key binding for the toggling of the interface.
There you can check what spells you wish to show as BeneCast buttons for
the Player and class frames. Each tab at the side of the BeneCast interface
corresponds to a different class, spells configured for that class will appear
for that class. The first tab is the player tab, which will have your name in the
tooltip. If you want, under the player tab you can specify to have changes in the
configuration of the player to apply to all classes. Note, this changes the
settings for everyone for fast basic party configuration!

Party Notification options are located in the Notification tab. Only one channel
can be selected at a time. The self channel only gives feedback to the player.
Check what you wish to allow to show in the Notification channel.

There are a number of other options in the Setup tab. You can determine what each
option does by reading the tooltips that appear when you mouse over them.

BeneCastPanel frames can be moved. They are locked into place, but can be
unlocked by right-clicking on the BeneCastPanel(not the buttons) and clicking on
the locked option in the dropdown menu. Note, that the name of the associated
member is also shown, to help you keep track of whose buttons you're moving.
After the frame is unlocked you can left-click and drag the frame where you like.
To lock the frame right-click on the frame and click on the locked option in the
dropdown menu. The BeneCastFrame can also be moved, but it does not lock into
place. You can also move the MiniMap button if you unlock frames in the Setup
options.

Heal spells always show up on the frames you specify, save for group heals.
Group heals will only show under the player frame, unless the healer is a Shaman,
in which case they can choose who to cast Chain Heal on. Heal over time spells
flash when the associated heal effect is on the member. (Note, this only occurs
if the default buff/debuff icons of the player are NOT hidden)

If you happen to have Nature's Swiftness, holding down the alt key will cast
Nature's Swiftness before casting the heal. It will automatically try to cast
the strongest heal it can when doing this.

Buff spells will only show when the associated member of your party or target do 
not have the effects of that buff on them. It does not take into account the 
strength of the buff. If you can cast a better buff on the target it will not
show the button, I leave this out for now because tooltips of a buff icon will 
not take talents into account.

Cure spells will only show when the associated member of your party or target 
has an effect on them which you can cure.

A maximum of 10 buttons are shown at once. The precedence in which they are shown are:
Heals
Buffs:
   Buffs
   Party Only Buffs
   Self Only Buffs
Cures
	
Mousing over the spell buttons show the tooltips for the highest rank spell you can 
cast with the mana you had when you moused over. The lower your mana, the lower the
spell rank of the spell in the tooltip.

To cast the spell you want, simply click on the BeneCast button which has the 
texture of the spell you wish to cast.

Strength of a spell is based on various things:
The default strength of the heal spells is the maximum strength you can cast at your
current mana. Holding down the shift key while clicking causes the strength of the heal
to be based on the current health of the target you wish to cast it on. The shift
functionality can be switched under the settings tab in the BeneCastFrame by checking
the Damage Based Heals button. There is also a lower bound on all heal over time spells,
making the target unable to receive a heal with a spell level greater than their level
+ 10. In addition there is a overhealing option which allows you to add ranks to the
spell that would normally be cast. This is done by holding down the control key. If
the Overhealing option is checked in the options then it will automatically overheal
and holding down the control key will cause it to cast without overhealing. The
number of ranks to overheal is set by the overheal slider.

The strength of a cure spell is always the highest possible strength. Since the mana
cost of all cures have been made the same there is no reason to cast a weaker cure.

The strength of a buff is always the highest strength possible for the target. 
This also has a lower bound based on level. The target cannot receive a buff 
with a spell level greater than their level + 10.

____________
|INTENTIONS|
------------
Goals in keeping BeneCast up to date are (not in that order):
- fix bugs
- add features needed due to patches (like new spells)
- add features that are aligned the intention of BeneCast
  That means: No directly offensive spells.
  For instance: while 'Rapid Fire' or 'Rockbiter Weapon' improve your fighting abilities
  they do not directly damage anything. You still have to do that yourself.
______
|TODO|
------
Paladin spell lists are be too large for the Options.
The interface art needs to be updated to allow for the Paladin spell list
as well as the Greater Blessing names.

After Mend Pet and Health Funnel, more pet spells. Bestial Wrath comes to mind.

Raid buttons still seem to have a few interesting properties. As
described in the quirks section. I'll try working them out. Details or
ideas on these things would be greatly appreciated, since I don't raid yet (too low level).

Along with the current flashing of HoT-buttons when the HoT is active on the target
an estimate for how long it's gonna last. Useful for upkeeping HoT's on tanks with the
least possible overlapping. Might use CT_RA's channel to communicate castings to other healers.

Selection of preferred target to execute bindings. Now uses a 'Smart mode'.
If target = friendly, heal target
If no target, or not friendly heal self

For pallies: Set a blessing as preferred for a specific person/pet. Say, you have a friend
druid named Wintrow :p. Wintrow likes to go Cat Form for some nice damage or Bear Form for tanking.
Wintrow is Resto-specced and likes to heal as well. Therefore both Blessing of Might AND
Blessing of Wisdom are useful to him. If you group with him and he's main healer set BoW as
his 'preferred blessing'. This way, BoM will be hidden as long as BoW is his preferred blessing.
This will require a sub-categorizing of the Blessings of course so BoP is not disabled while BoW is
active. Also, YOU define what is preferred, so Blessing of Salvation is possible as well.

Range detection on spells, so that they can be shaded when out of range.

Shade buttons based on current mana.
________
|QUIRKS|
--------
The Standard UI raid Pullout frames act a bit strange if there the same
raid member is represented multiple times. The BeneCast buttons will
always appear on the newest pullout frame with that raid member.

Healing those outside of your party/raid does not have accurate healing as
the WoW API does not allow one to know their exact health, rather you only
know their health percentage.

The spell name to select a spell line often does is not the strongest
spell in the spell line. For instance Purify will show instead of Cleanse.
Selecting a spell in a line will allow you to cast any spell in the line,
allowing Cleanse to be cast from the cure spell line in Paladins and Greater
Heal to be cast in the Priests Heal spell line.

It seems BeneCast responds to events before CT_RaidAssist. This causes
BeneCast to move around buttons and CT_RA frames before CT_RA handles it's
frames. You can fix this by rechecking a raid option button in the BeneCast
Raid tab.

Changing the layout of buttons for raid members can cause some interesting
layout problems. Raid member frames will move/hide based on the buttons
for the raid member before them. I recommend that the preferred raid snapto
be selected before entering a raid.

Sometimes a raid member's buttons "switch" with another raid member.
Clicking on a button for member A will cast on B and clicking a button on
member B will cast on member A. Are the buttons just attached to the wrong
spot? I don't know, I've never seen it. If you right click on the border
around the buttons it should have the name of the person those buttons will
cast on. So, is the name on displayed in the right click menu the name of
the person the buttons are attaching to or the person it's casting on?

Binding casts can also make use of the shift, control, and alt modifiers.
But in order to do so, there must not be anything bound to a key modifier +
the binding you set for the binding cast. So if you have a binding cast to
'Q' if there is a binding for SHIFT+'Q' then BeneCast will not see the 'Q'
binding and make the desired action.

People are getting random crashes (WoW exiting to the desktop). Mostly it's
about some 'memory cannot be written'. I am stumped why this happens.
Especially since it only affects a certain group of players and then not
every time...
The most recurring one is:
A priest groups with someone else and then crashes
As far as I know it's when a table-variable is being written to on an index = 0.
_____________________
|ADDON SUPPORT LISTS|
---------------------
Unit Frame AddOn Support list:
Nymbia's Perl 1.2.3b 
Perl Classic .30
MiniGroup vK0.4b
MiniGroup2 (Ace) 2-34
Nurfed Unit Frames v10.14.2005
Discord Unit Frames v2.3
Noctambul Unit Frames 1.2pre7
WatchDog Unit Frames 1.15
SAE_PartyFrame

Raid AddOn Support list:
CT_RaidAssist 1.45

___________________________________________________
|ADDING SUPPORT FOR YOUR FAVORITE UNIT FRAME ADDON|
---------------------------------------------------
Open up BeneCastSnapTo.lua in your favorite text editor and get cracking!

First we must make a table entry for the AddOn. You can just copy one of
the existing tables and use it for your AddOn. Change the name of the
entry to BeneCast_SnapTo.<ADDON> and you've got your own table entry.

Next you need to determine the AddOn name. This is the same name as the
name of the directory(folder) of the AddOn. Make the AddOn part in your
table = to the name of the AddOn. For example: AddOn = 'BeneCast',

The final part is the most tricky. You need to open up the various XML
files in the AddOn and find out what the names of the unit frames are.
We only want the names of the frames you want BeneCast to attach to.
Usually the player frame, party member frames, and target frame.

The name will be declared in the angle brackets of an XML frame object.
Example: <name='PlayerFrame'> There may be other stuff in the angle
brackets, but that's ok. All we want is the name. Often there are
comments in the XML to identify the frame. Comments start with <!-- and
end with -->

Once you have the frame name just find set the BeneCastPanel in your
table entry so that the frame = the frame name. Example:
-- Player Frame
BeneCastPanel1 = { yadda yadda yadda, frame = 'PlayerFrame', yadda yadda yadda},
The point is the attachment point of the BeneCast Panel, and the
relativePoint is the point on the frame where the Panel will attach. You
can offset this by changing the x and y values.
________
|THANKS|
--------
To Skurel for founding the project.
To Wintrow for caretaking the project.

Thank you also to:
danboo, Urlik!,Tyndral, Effren, Hiroko of Argent Dawn(EU). and Auric Goldfinger.