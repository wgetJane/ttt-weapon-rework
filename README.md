## trouble in terrorist town weapon rework (tttwr)

this is an attempt at redesigning certain aspects of ttt's gameplay mechanics (mostly the weapons)

this has a different philosophy and perspective of how ttt should be as a social deduction party game comprised of around 8 players

this should lower the skill floor for gunplay, so that someone's aiming skill isn't too big of a factor for who wins a round

also, this is a work-in-progress, but it should be in a well playable state right now

## general gunplay changes

**new weapons**:\
the glock, pistol, mac10, m16, rifle, and shotgun have been replaced\
instead there are now instead various weapons for each weapon type: pistols, smgs, rifles, snipers, and shotguns

9mm ammo is renamed to "Pistol ammo", and its reserve size is increased to 120\
\- pistol ammo is used by pistols and smgs

SMG ammo is renamed to "Rifle ammo", and its reserve size is still 60\
\- rifle ammo is used by assault rifles

Rifle ammo is renamed to "Sniper ammo", and its reserve is still 20\
\- sniper ammo is used by sniper rifles

information about new weapons is at the "new weapons" section below

**interpolated recoil**:\
recoil is smoothed over 0.067 seconds instead of instantly teleporting your crosshair upwards

this should prevent eyestrain with shooting guns so they feel a lot nicer to shoot

**hitgroup priority**:\
arms and legs will no longer block hits to the head or body

similar behaviour in csgo: https://youtu.be/CbftQTBHSlA

**fixed shotgun spread pattern**:\
shotguns now have a fixed spread pattern: 1 pellet at the centre, 7 pellets in a circle\
(each pellet will still have a bit of inaccuracy)

it's silly how a close-range shot can randomly deal 60 damage, or how a medium-range shot can randomly deal 120 damage

a fixed spread pattern gives shotguns a consistent reliable range, so it's no longer based on luck

**shotguns no longer use hull traces**:\
all of a shotgun's pellets now use line traces

in vanilla, half of the shotgun shots use 6x6x6 hull traces (very big bullets)\
and instead of player hitboxes, they hit player bounding boxes (very big targets)\
https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/shared/baseentity_shared.cpp#L1738

this change means you'd actually have to hit your target with the pellets, instead of just the air around them

**tracers**:\
sniper rifles will always have a visible tracer for every shot instead of for every 4 shots\
silenced weapons will no longer fire visible tracers

**sniper laser dot**:\
while zoomed in, sniper rifles will cast a laser dot on where they're pointing at

this is similar to how tf2's sniper rifle casts a laser dot

the purpose of this change is to make snipers easier to avoid and react to

**more accurate fire rates**:\
guns will now attempt to shoot at a more accurate fire rate

without this change, a gun's fire rate can be slower depending on the server's framerate

for example, this is what 900 rpm will actually be on certain tickrates:\
100 tickrate = 857 rpm\
66.67 tickrate = 800 rpm\
33 tickrate = 660 rpm\
20 tickrate = 600 rpm\
16 tickrate = 480 rpm

this change fixes this issue, so that 900 rpm is actually 900 rpm on average

## weapon changes

**crowbar**:\
secondary fire delay is shortened to 0.5 seconds from 5 seconds

it just feels awkward how you can't use your crowbar for a long while after pushing

you need to be in point-blank range to use it anyway, so i doubt this even affects balance

**magneto-stick**:\
props now look partially transparent while you're holding them with the magneto-stick

the main point of this change is to make it easier to use props to block bullets without obscuring your vision too much

and the main point of that point is to make it easier to cross sniper sightlines when you know where the sniper is shooting from

**deagle**:\
\- increased fire rate to 150 rpm from 100 rpm\
\- accuracy and headshot damage becomes very low immediately after shooting, but eventually recovers in 1.5 seconds\
\- base damage: 33\
\- minimum headshot damage (<0.83 secs): 50\
\- headshot damage at >1.33 secs: 100\
\- maximum headshot damage (>1.5 secs): 150

the deagle is way too powerful for a handgun, and most wielders treat it like a primary weapon

it outperforms primary weapons in most situations (other than the sniper rifle in long-range engagements)

this is because of its ability to instakill with a headshot combined with its disproportionately fast fire rate for how much damage it can deal

while aiming skill should be rewarded in fps games, ttt is not solely an fps game so rewarding aim this much gets problematic

but the deagle's main identity is the one-hit-kill headshots, so i can't just remove that since it won't really be the deagle anymore

lowering the fire rate can also be considered, but at that point, it's no longer a handgun but a sniper rifle without a scope

so my solution is to make it feel like you're shooting a big pistol: massive accuracy loss after firing, like your aim is thrown off by the heavy recoil

to prevent people from just spamming shots to get a lucky headshot, the headshot multiplier is also heavily reduced after firing

these changes should hopefully still have it handle like a pistol without always having the power of a sniper rifle

**huge-249**:\
\- ammo capacity increased to 200 from 150\
\- while ironsighted, accuracy and recoil is improved by sustained fire

the huge-249 is an absurdly bad weapon\
you need to be in very close range to hit most of your shots\
and its damage output is too low even if you hit your shots

because it has a relatively abysmal dps, shooting the huge-249 is practically just asking to be killed by return fire

to give the huge-249 a purpose, i've given it the ability to become like a lightning gun

while ironsighted, the gun's accuracy and recoil improves through sustained fire\
it starts with very poor accuracy and recoil on the 1st shot,\
and eventually gets extremely accurate with little recoil on the 20th shot

this gives it a role as a weapon for suppressive fire at the cost of mobility

**radar + body armor**:\
now costs 2 credits for traitors

in vanilla servers, traitors often just spend their first 2 credits on radar + body armour

by doubling their price, other traitor weapons become more attractive options so traitors don't just buy the same stuff every round

body armour gives traitors an effective health of 142.86, which is a huge advantage to be sold for just 1 credit

i believe that traitors shouldn't be able to easily win a head-on 1v1 fight,\
since they're supposed to use stealth, surprise, teamwork, and deception to take out innocents

**decoy**:\
\- you receive 8 decoys instead of 1\
\- decoy positions will always be visible to the owner, even without a radar\
\- a decoy's radar position will be the owner's position at the moment it was placed\
\- new decoy tab in the traitor menu\
\- in the decoy tab, you can toggle the radar signal of each decoy on or off\
\- in the decoy tab, you can select which decoy is faking your dna location or stop faking your dna location

nobody really buys the decoy because it's kinda underwhelming, so i'm buffing the hell out of it eightfold

i don't like how the detective can use the radar to know the number of living players,\
so the decoy is now a great way to make the radar unreliable for counting players

**knife**:\
\-can now instakill on a backstab\
\-decreased front-stab damage to 40 from 50\
\-increased thrown knife minimum damage to 60 from 50

performing melee kills with the knife is pretty pointless because of how slow it is\
it's much faster to just shoot someone in the back with a gun

i've given the knife a backstab instakill so it has a more stealthy role\
also, players just intuitively expect to be able backstab with a knife

the "INSTANT KILL" text will appear when you can backstab somebody

uses similar backstab detection mechanics from tf2: https://youtu.be/gh5Fg5d_uBU

the knife will also now play deploy and attack sounds but only on the client\
this is merely for better feedback, so the knife is still completely silent for other players

also, i've improved how the game looks for where to stick the knife in a ragdoll,\
so you're gonna see a lot less floating knives in the air

**flare gun**:\
\- will now ignite players in a small radius\
\- model is now coloured red

the flare gun now ignites players within a small radius, so you can use it to cause a bit of chaos\
the burn duration drops off from 6 to 3 seconds based on the distance from where the shot landed\
and obviously, the shooter cannot be self-ignited

the model is now coloured red so it's more obvious when someone is holding a flare gun,\
since it looks like a generic pistol from a distance

**newton launcher**:\
\- alt-fire now pulls players\
\- will now properly credit prop-kills

the newton launcher's previous alt-fire is pretty pointless, since the primary fire is powerful enough

charging it up makes an already slow attack even slower, and just for barely any benefit

at the least amount of charge, the alt-fire had half the power of the primary fire\
while at the most amount of charge, it's only mildly and unnoticeably more powerful than the primary fire

instead of charging up a push attack, using alt-fire will now pull players towards you

this gives the newton launcher another angle to use it from\
for example, it can be used to pull players off of ledges

**silenced pistol**:\
\- now uses USP stats (see "new weapons" section), but has less recoil, better accuracy, and higher damage\
\- gives 2 clips of bonus ammo instead of 1 when bought, and will no longer exceed the reserve size

**ump prototype**:\
\- renamed to "TMP Prototype"\
\- uses the tmp model instead of the ump model\
\- silenced\
\- gives 1 clip of bonus ammo when bought\
\- the jolting of aim when hit is now interpolated (so it's less annoying)\
\- the random amount of jolt is now normally distributed (so it's higher on average)

**health station**:\
detectives can now carry health stations with the magneto-stick

## other changes

**dropping ammo**:\
the console command `ttt_dropammo` now drops ammo from your reserve instead of from your clip

this makes it significantly easier to transfer ammo to another weapon

a new console command `ttt_dropclip` is added for when you do want to drop ammo from your clip

**crouch view offset**:\
raised to 36 units from 28 units

the default crouch view offset is too low, since it's positioned at around the player's waist\
you'd often be completely unaware that your head and upper torso are sticking out from cover

i've considered also raising the player's bounding box height while crouching to better fit the player's model,\
but that might cause issues in places in maps with very low ceilings like vents

mappers shouldn't be making places with ridiculously low ceilings anyway:\
https://cdn.discordapp.com/attachments/538431794786336798/826401713295458304/unknown.png \
https://cdn.discordapp.com/attachments/538431794786336798/826398116063215656/unknown.png \
https://cdn.discordapp.com/attachments/538431794786336798/826399524447584286/unknown.png

**detective credit rewards**:\
detectives will only receive their credit reward for traitor deaths when the traitor's body is identified

**traitor credit rewards**:\
instead of rewarding traitors with credits based on the percent of dead innocents,\
they're rewarded with credits for killing "priority targets"

each traitor is assigned 2 priority targets (will never be detectives)\
as much as possible, the game will try to avoid assigning the same target to different traitors

this mechanic can be disabled by setting the cvar `ttt_prioritytargets` from 2 to 0

## new weapons

these new weapons replace the vanilla weapons, so they'll get spawned in their place

weapons for each weapon type are supposed to be sidegrades of each other

the idea behind adding more weapons is to provide more "soft evidence" in the game\
since each gun has their own distinct sound and appearance\
and this makes it more useful to note the killer's weapon identified on a corpse

**pistols**:\
these are supposed to be sidearms that are weaker than primary weapons, but can be deployed much faster

they typically have a deploy time of 0.4 seconds and a reload time of 2.5 seconds

Five-Seven\
25 dmg, 60 hs dmg, 20-round clip, 200 rpm, average accuracy, average recoil, 2.75-sec reload time

Glock\
20 dmg, 44 hs dmg, 20-round clip, 300 rpm, average accuracy, low recoil, 2.4-sec reload time

USP\
26 dmg, 62.4 hs dmg, 16-round clip, 300 rpm, better accuracy, higher recoil

228 Compact\
30 dmg, 72 hs dmg, 12-round clip, 230 rpm, bad accuracy, high recoil

Dual Elites\
19 dmg, 38 hs dmg, 30-round clip, 360 rpm, bad accuracy, average recoil, 0.7-sec deploy time, 4-sec reload time

**smgs**:\
these weapons have fast fire rates and low recoil, shredding targets at close-range, but they have low base damage and poor accuracy

they have a headshot multiplier of 320% which quickly drops off to 170% from 150 units to 350 units

they typically have a deploy time of 0.6 seconds and a reload time of 2.75 seconds

MAC-10\
12 dmg, 38.4 - 20.4 hs dmg, 30-round clip, 900 rpm, average accuracy, average recoil, 0.5-sec deploy time

MP5\
12 dmg, 38.4 - 20.4 hs dmg, 30-round clip, 750 rpm, better accuracy, lower recoil

UMP\
16 dmg, 51.2 - 27.2 hs dmg, 25-round clip, 600 rpm, better accuracy, higher recoil

P90\
10 dmg, 32 - 17 hs dmg, 50-round clip, 857 rpm, average accuracy, very low recoil, 0.7-sec deploy time, 3-sec reload time

**assault rifles**:\
these are supposed to be generally decent primary weapons for most ranges\
assault rifles are slightly more accurate when tap-fired

they typically have a deploy time of 0.75 seconds and a reload time of 3 seconds

M16\
23 dmg, 57.5 hs dmg, 30-round clip, 400 rpm, average accuracy, average recoil

AK-47\
25 dmg, 62.5 hs dmg, 30-round clip, 375 rpm, average accuracy, average recoil, 2.75-sec reload time

FAMAS\
20 dmg, 50 hs dmg, 25-round clip, 470 rpm, lower accuracy, lower recoil, 3.25-sec reload time

Galil\
22 dmg, 55 hs dmg, 35-round clip, 450 rpm, lower accuracy, higher recoil

Aug\
21 dmg, 52.5 hs dmg, 30-round clip, 425 rpm, average accuracy, average recoil, 3.25-sec reload time

Krieg\
24 dmg, 60 hs dmg, 30-round clip, 400 rpm, better accuracy, higher recoil

**sniper rifles**:\
these are long-range scoped weapons with very high accuracy but slow fire rates

they all have a deploy time of 0.75 seconds

Scout\
50 dmg, 150 hs dmg, 10-round clip, 40 rpm, 3-sec reload time

AWP\
75 dmg, 200 hs dmg, 5-round clip, 30 rpm, 4-sec reload time

G3\
45 dmg, 90 hs dmg, 10-round clip, 100 rpm, 3.5-sec reload time

SG\
29 dmg, 72.5 hs dmg, 20-round clip, 160 rpm, 3.5-sec reload time

**shotguns**:\
great burst damage at close-range, but becomes completely useless outside of close-range

these have a headshot multiplier of 310% which rapidly drops off to 100% from 140 units to 402 units

they all have a deploy time of 0.75 seconds

it takes 0.5 seconds to begin reloading, 0.6 seconds to reload a shell, and 0.5 seconds to finish reloading\
this means reloading 8 shells takes 5.8 seconds (0.5 + 0.6 * 8 + 0.5 = 5.8)

all shotguns shoot 8 pellets in a fixed spread pattern

M3 (Pump Shotgun)\
1 pellet: 11 dmg, 34.1 max hs dmg\
8 pellets: 88 dmg, 180 max hs dmg\
70 rpm, 8-round clip

XM (Auto Shotgun)\
1 pellet: 6 dmg, 18.6 max hs dmg\
8 pellets: 48 dmg, 98.4 max hs dmg\
240 rpm, 8-round clip

## bug fixes

these are bugs that exist in vanilla ttt that should be fixed by this mod

**fov zoom glitch**:\
fixed a glitch with fov zooming in slightly for a split second before returning to normal\
this was happening with zoomable weapons whenever they're reloaded, holstered, or dropped

also fixed a glitch with the weapon viewmodel being in the ironsighted position when picked up and deployed after being dropped while zoomed in

**instant reload exploit**:\
fixed an exploit that lets you reload instantly by dropping the gun while it's reloading:\
https://cdn.discordapp.com/attachments/383927930641842186/812515986674155531/simplescreenrecorder-2021-02-20_10.33.18.mp4

though the exploit should also be fixed by the next gmod update:\
https://reddit.com/comments/lo48v9//go7ybif \
https://github.com/Facepunch/garrysmod/commit/9d3ba42

## compatibility

tttwr is intended for and balanced for a private mostly-vanilla server with ~8 players

this mod doesn't overwrite any files, so it should be compatible with future gmod and ttt updates\
though the ScalePlayerDamage, Move, and DoPlayerDeath gamemode functions are overwritten

weapons from other mods will not have changes like interpolated recoil,  fixed spread pattern, sniper laser dot, etc

the deagle, huge-249, decoy, knife, flaregun, newton launcher, silenced pistol, ump prototype, magneto-stick, and dna scanner have gotten some of their functions heavily modified

tttwr uses the [EntityTakeDamage](https://wiki.facepunch.com/gmod/GM:EntityTakeDamage) hook to batch shotgun damage into a single damage event\
when an entity is hit by 8 pellets, 7 pellets will be ignored by returning `true`\
so this might interfere with mods that use the EntityTakeDamage hook incorrectly\
the EntityTakeDamage hook is for modifying or blocking damage events,\
while the [PostEntityTakeDamage](https://wiki.facepunch.com/gmod/GM:PostEntityTakeDamage) hook is for when damage events are successful

probably not compatible with [ttt2](https://github.com/TTT-2/TTT2/)\
tttwr *can* be made fully-compatible with ttt2, but i don't see why i should work on that right now, since i'm making this mod for a non-ttt2 server
