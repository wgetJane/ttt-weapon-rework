## trouble in terrorist town weapon rework (tttwr)

this is an attempt at redesigning certain aspects of ttt's gameplay mechanics (mostly the weapons)

this has a different philosophy and perspective of how ttt should be as a social deduction party game comprised of around 8 players

this should lower the skill floor for gunplay, so that someone's aiming skill isn't too big of a factor for who wins a round

also, this is a work-in-progress, but it should be in a well playable state right now

## general gunplay changes

#### new weapons
the glock, pistol, mac10, m16, rifle, and shotgun have been replaced\
instead there are now various weapons for each weapon type: pistols, smgs, rifles, snipers, and shotguns

9mm ammo is renamed to "Pistol ammo", and its reserve size is increased to 120\
\- pistol ammo is used by pistols and smgs

SMG ammo is renamed to "Rifle ammo", and its reserve size is still 60\
\- rifle ammo is used by assault rifles

Rifle ammo is renamed to "Sniper ammo", and its reserve size is still 20\
\- sniper ammo is used by sniper rifles

Deagle ammo is renamed to "Magnum ammo", and its reserve size is still 36\
\- magnum ammo is used by deagle and revolver

information about new weapons is at the "new weapons" section below

#### longer gunfights
weapon damage has been tweaked so that players take a lot longer to kill

reasons why are mostly because:\
\- i think it's much less interesting if a gunfight is pretty much over just a second or two after it begins\
\- reaction time matters too much with low ttk, which is problematic when there's big ping differences\
\- giving players more opportunity to dodge shots and move around makes fights more fun\
\- higher ttk makes it harder for a player to confidently win a 1v2, which i think makes more sense for ttt

weapons also now have distance damage falloff (50% damage at 1024 units for most weapons)\
this is to encourage players to have much more personal engagements at close range instead of just picking each other off from a distance

#### interpolated recoil
recoil is smoothed over 0.067 seconds instead of instantly teleporting your crosshair upwards

this should prevent eyestrain with shooting guns so they feel a lot nicer to shoot

#### hitgroup priority
arms and legs will no longer block hits to the head or body

similar behaviour in csgo: https://youtu.be/CbftQTBHSlA

#### no lucky headshots
"lucky headshots" will no longer deal extra damage

a headshot is considered to be lucky if you weren't aiming for the head

set the cvar `ttt_noluckyheadshots` to 1 to enable or 0 to disable this feature

#### fixed shotgun spread pattern
shotguns now have a fixed spread pattern: 1 pellet at the centre, 7 pellets in a circle\
(each pellet will still have a bit of inaccuracy)

it's silly how a close-range shot can randomly deal 60 damage, or how a medium-range shot can randomly deal 120 damage

a fixed spread pattern gives shotguns a consistent reliable range, so it's no longer based on luck

<!--

#### shotguns no longer use hull traces
all of a shotgun's pellets now use line traces

in vanilla, half of the shotgun shots use 6x6x6 hull traces (very big bullets)\
and instead of player hitboxes, they hit player bounding boxes (very big targets)\
https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/shared/baseentity_shared.cpp#L1738

this change means you'd actually have to hit your target with the pellets, instead of just the air around them

-->

#### tracers
sniper rifles will always have a visible tracer for every shot instead of for every 4 shots\
silenced weapons will no longer fire visible tracers

#### sniper laser dot
while zoomed in, sniper rifles will cast a laser dot on where they're pointing at

this is similar to how tf2's sniper rifle casts a laser dot

the purpose of this change is to make snipers easier to avoid and react to

#### accurate fire rates
guns now have accurate fire rates, which means that they will shoot as fast as they should

without this change, a gun's fire rate can be slower depending on the server's framerate

for example, this is what 900 rpm will actually be on certain tickrates:\
100 tickrate = 857 rpm\
66.67 tickrate = 800 rpm\
33 tickrate = 660 rpm\
20 tickrate = 600 rpm\
16 tickrate = 480 rpm

this change fixes this issue, so that 900 rpm is actually 900 rpm

## weapon changes

#### crowbar
secondary fire delay is shortened to 0.5 seconds from 5 seconds

it just feels awkward how you can't use your crowbar for a long while after pushing

you need to be in point-blank range to use it anyway, so i doubt this even affects balance

#### magneto-stick
props now look partially transparent while you're holding them with the magneto-stick

the main point of this change is to make it easier to use props to block bullets without obscuring your vision too much

and the main point of that point is to make it easier to cross sniper sightlines when you know where the sniper is shooting from

clients can choose to disable this by setting the cvar `ttt_magnetotrans` from 1 to 0

#### huge-249
\- damage increased from 7 to 11\
\- rate of fire decreased from 1000 rpm to 666 rpm\
\- while ironsighted, accuracy and recoil is improved by sustained fire

the huge-249 is an absurdly bad weapon\
you need to be in very close range to hit most of your shots\
and its damage output is too low even if you hit your shots

because it has a relatively abysmal dps, shooting the huge-249 is practically just asking to be killed by return fire

to give the huge-249 a purpose, i've given it the ability to become like a lightning gun

while ironsighted, the gun's accuracy and recoil improves through sustained fire\
it starts with very poor accuracy and recoil on the 1st shot,\
and eventually gets very accurate with little recoil on the 10th shot

this gives it a role as a weapon for suppressive fire at the cost of mobility

#### radar + body armor
now costs 2 credits for traitors

in vanilla servers, traitors often just spend their first 2 credits on radar + body armour

by doubling their price, other traitor weapons become more attractive options so traitors don't just buy the same stuff every round

body armour gives traitors an effective health of 142.86, which is a huge advantage to be sold for just 1 credit

i believe that traitors shouldn't be able to easily win a head-on 1v1 fight,\
since they're supposed to use stealth, surprise, teamwork, and deception to take out innocents

the cost of armour and radar can be changed with the cvars `ttt_buycost_armor` and `ttt_buycost_radar`

#### decoy
\- you receive 8 decoys instead of 1\
\- decoy positions will always be visible to the owner, even without a radar\
\- a decoy's radar position will be the owner's position at the moment it was placed\
\- new decoy tab in the traitor menu\
\- in the decoy tab, you can toggle the radar signal of each decoy on or off\
\- in the decoy tab, you can select which decoy is faking your dna location or stop faking your dna location

nobody really buys the decoy because it's kinda underwhelming, so i'm buffing the hell out of it eightfold

i don't like how the detective can use the radar to know the number of living players,\
so the decoy is now a great way to make the radar unreliable for counting players

#### knife
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

#### flare gun
\- will now ignite players in a small radius\
\- model is now coloured red

the flare gun now ignites players within a small radius, so you can use it to cause a bit of chaos\
the burn duration drops off from 6 to 3 seconds based on the distance from where the shot landed\
and obviously, the shooter cannot be self-ignited

the model is now coloured red so it's more obvious when someone is holding a flare gun,\
since it looks like a generic pistol from a distance

#### newton launcher
\- alt-fire now pulls players\
\- will now properly credit prop-kills

the newton launcher's previous alt-fire is pretty pointless, since the primary fire is powerful enough

charging it up makes an already slow attack even slower, and just for barely any benefit

at the least amount of charge, the alt-fire had half the power of the primary fire\
while at the most amount of charge, it's only mildly and unnoticeably more powerful than the primary fire

instead of charging up a push attack, using alt-fire will now pull players towards you

this gives the newton launcher another angle to use it from\
for example, it can be used to pull players off of ledges

#### silenced pistol
\- now uses USP stats (see "new weapons" section), but has less recoil, better accuracy, and higher damage\
\- gives 2 clips of bonus ammo instead of 1 when bought, and will no longer exceed the reserve size

#### ump prototype
\- renamed to "TMP Prototype"\
\- uses the tmp model instead of the ump model\
\- silenced\
\- gives 1 clip of bonus ammo when bought\
\- the jolting of aim when hit is now interpolated (so it's less annoying)\
\- the random amount of jolt is now normally distributed (so it's higher on average)

#### health station
detectives can now carry health stations with the magneto-stick

## other changes

#### dropping ammo
the console command `ttt_dropammo` now drops ammo from your reserve instead of from your clip

this makes it significantly easier to transfer ammo to another weapon

a new console command `ttt_dropclip` is added for when you do want to drop ammo from your clip

#### crouch view offset
raised to 36 units from 28 units

the default crouch view offset is too low, since it's positioned at around the player's waist\
you'd often be completely unaware that your head and upper torso are sticking out from cover

i've considered also raising the player's bounding box height while crouching to better fit the player's model,\
but that might cause issues in places in maps with very low ceilings like vents

mappers shouldn't be making places with ridiculously low ceilings anyway:\
https://cdn.discordapp.com/attachments/538431794786336798/826401713295458304/unknown.png \
https://cdn.discordapp.com/attachments/538431794786336798/826398116063215656/unknown.png \
https://cdn.discordapp.com/attachments/538431794786336798/826399524447584286/unknown.png

#### detective credit rewards
detectives will only receive their credit reward for traitor deaths when the traitor's body is identified

#### traitor credit rewards
instead of rewarding traitors with credits based on the percent of dead innocents,\
they're rewarded with credits for killing "priority targets"

each traitor is assigned 2 priority targets (will never be detectives)\
as much as possible, the game will try to avoid assigning the same target to different traitors

this mechanic can be disabled by setting the cvar `ttt_prioritytargets` from 2 to 0

#### weapon sound distance attenuation
how weapon sounds drop off in volume by distance now makes a lot more sense

without this change:\
the five-seven is silent after ~1200 units (???)\
the scout is silent after ~600 units (??????)\
the crowbar is silent after ~2400 units (?????????)

#### dying shot
the experimental [dying shot](https://www.troubleinterroristtown.com/config/settings/#other-gameplay-settings) mechanic that's disabled by default is fixed and reworked

to trigger a dying shot, the following conditions must be met on a player's death:\
\- the killer must be a player\
\- the killer must not be behind the victim\
\- the killer's weapon must be a hitscan weapon\
\- the victim must be sighting their weapon\
\- the victim's weapon can be normally fired (has ammo, etc)

also, the shot is no longer very inaccurate

the dying shot mechanic is still disabled by default\
you can enable it by setting the cvar `ttt_dyingshot_enabled` to 1

## new weapons

these new weapons replace the vanilla weapons, so they'll get spawned in their place

weapons for each weapon type are supposed to be sidegrades of each other

the idea behind adding more weapons is to provide more "soft evidence" in the game\
since each gun has their own distinct sound and appearance\
and this makes it more useful to note the killer's weapon identified on a corpse

#### pistols
these are supposed to be sidearms that are weaker than primary weapons, but can be deployed faster

their damage drops off from 100% at 64 units to 50% at 1024 units

Five-Seven\
\- base dmg: 30, headshot dmg: 50, limb dmg: 20\
\- clip size: 20\
\- fire rate: 180 rpm\
\- deploy time: 0.75 secs\
\- reload time: 2.75 secs\
\- kills an unarmoured player in two headshots at point-blank range

Glock\
\- base dmg: 24, headshot dmg: 33.6, limb dmg: 16\
\- clip size: 20\
\- fire rate: 250 rpm\
\- deploy time: 0.75 secs\
\- reload time: 2.4 secs\
\- kills an unarmoured player in three headshots at point-blank range

USP\
\- base dmg: 32, headshot dmg: 53.33, limb dmg: 21.33\
\- clip size: 16\
\- fire rate: 180 rpm\
\- deploy time: 0.75 secs\
\- reload time: 2.5 secs\
\- higher recoil, slightly more accurate\
\- kills an unarmoured player in two headshots at close range

228 Compact\
\- base dmg: 32, headshot dmg: 53.33, limb dmg: 21.33\
\- clip size: 12\
\- fire rate: 200 rpm\
\- deploy time: 0.75 secs\
\- reload time: 2.5 secs\
\- higher recoil, slightly less accurate\
\- kills an unarmoured player in two headshots at close range

Dual Elites\
\- base dmg: 16, headshot dmg: 24, limb dmg: 10.67\
\- clip size: 30\
\- fire rate: 360 rpm\
\- deploy time: 1 secs\
\- reload time: 4 secs\
\- higher recoil, less accurate

#### smgs
these weapons have fast fire rates and low recoil but poor accuracy, making them suited for close-range

their damage drops off from 100% at 64 units to 50% at 1024 units

MAC-10\
\- base dmg: 12, headshot dmg: 16, limb dmg: 10\
\- clip size: 30\
\- fire rate: 600 rpm\
\- deploy time: 0.75 secs\
\- reload time: 2.75 secs

MP5\
\- base dmg: 12, headshot dmg: 16, limb dmg: 10\
\- clip size: 30\
\- fire rate: 570 rpm\
\- deploy time: 0.875 secs\
\- reload time: 2.75 secs\
\- slightly better recoil and accuracy

UMP\
\- base dmg: 13, headshot dmg: 17.33, limb dmg: 10.83\
\- clip size: 30\
\- fire rate: 500 rpm\
\- deploy time: 0.875 secs\
\- reload time: 2.75 secs\
\- distance damage falloff starts at 192 units instead of 64 units\
\- slightly higher recoil and accuracy

P90\
\- base dmg: 10, headshot dmg: 13.33, limb dmg: 8.33\
\- clip size: 50\
\- fire rate: 600 rpm\
\- deploy time: 1 sec\
\- reload time: 3 secs\
\- very low recoil

#### assault rifles
these are supposed to be generally decent primary weapons at mid range

their damage drops off from 100% at 384 units to 50% at 1280 units

M16\
\- base dmg: 15, headshot dmg: 25, limb dmg: 7.5\
\- clip size: 30\
\- fire rate: 400 rpm\
\- deploy time: 1 sec\
\- reload time: 3 secs

AK-47\
\- base dmg: 16, headshot dmg: 26.67, limb dmg: 8\
\- clip size: 30\
\- fire rate: 400 rpm\
\- deploy time: 1 sec\
\- reload time: 3 secs\
\- higher recoil, lower accuracy

FAMAS\
\- base dmg: 13, headshot dmg: 21.67, limb dmg: 6.5\
\- clip size: 25\
\- fire rate: 450 rpm\
\- deploy time: 1 sec\
\- reload time: 3.25 secs\
\- lower recoil and accuracy

Galil\
\- base dmg: 13, headshot dmg: 21.67, limb dmg: 6.5\
\- clip size: 35\
\- fire rate: 450 rpm\
\- deploy time: 0.875 secs\
\- reload time: 3 secs\
\- slightly higher recoil, lower accuracy

Aug\
\- base dmg: 15, headshot dmg: 25, limb dmg: 7.5\
\- clip size: 30\
\- fire rate: 400 rpm\
\- deploy time: 1 sec\
\- reload time: 3.25 secs\
\- slightly higher recoil, better accuracy

Krieg\
\- base dmg: 16, headshot dmg: 26.67, limb dmg: 8\
\- clip size: 30\
\- fire rate: 400 rpm\
\- deploy time: 1 sec\
\- reload time: 3 secs\
\- much higher recoil, slightly better accuracy

#### sniper rifles
these are scoped weapons with perfect accuracy but slow fire rates

they do not have distance damage falloff, making them the supreme weapons at long range

Scout\
\- base dmg: 40, headshot dmg: 80, limb dmg: 20\
\- clip size: 10\
\- fire rate: 60 rpm\
\- deploy time: 0.875 sec\
\- reload time: 3 secs\
\- kills an unarmoured player in 3 bodyshots or 1 headshot + 1 limb shot\
\- kills an armoured player in 2 headshots

AWP\
\- base dmg: 50, headshot dmg: 92.86, limb dmg: 25\
\- clip size: 10\
\- fire rate: 40 rpm\
\- deploy time: 1 sec\
\- reload time: 4 secs\
\- kills an unarmoured player in 2 bodyshots\
\- kills an armoured player in 1 headshot + 1 bodyshot

G3\
\- base dmg: 25, headshot dmg: 50, limb dmg: 12.5\
\- clip size: 20\
\- fire rate: 180 rpm\
\- deploy time: 1 sec\
\- reload time: 3.5 secs\
\- kills an unarmoured player in 2 headshots

SG 550\
\- base dmg: 32, headshot dmg: 64, limb dmg: 16\
\- clip size: 20\
\- fire rate: 160 rpm\
\- deploy time: 1 sec\
\- reload time: 3.5 secs\
\- kills an unarmoured player in 2 headshots

#### shotguns
great burst damage at close range, but becomes extremely weak outside of close range

it takes 0.5 seconds to begin reloading, 0.5 seconds to reload a shell, and 0.5 seconds to finish reloading\
this means reloading 8 shells takes 5 seconds (0.5 + 0.5 * 8 + 0.5 = 5)

all shotguns shoot 8 pellets in a fixed spread pattern

their damage drops off from 100% at 64 units to 50% at 768 units

headshot multiplier also drops off from 240% at 64 units to 100% at 192 units

M3\
\- base dmg: 7, headshot dmg: 16.8, limb dmg: 6.3\
\- clip size: 8\
\- fire rate: 72 rpm\
\- deploy time: 1 sec\
\- can kill an unarmoured player in one headshot at close range

XM\
\- base dmg: 4, headshot dmg: 9.6, limb dmg: 3.6\
\- clip size: 8\
\- fire rate: 250 rpm\
\- deploy time: 1 sec

SPAS-12\
\- base dmg: 6, headshot dmg: 14.4, limb dmg: 5.4\
\- clip size: 6\
\- fire rate: 90 rpm\
\- deploy time: 0.75 sec\
\- takes 0.4 secs to reload a shell instead of 0.5 secs\
\- can kill an unarmoured player in one headshot at point-blank range

#### deagle and revolver
the deagle is obviously not a new weapon, but a new weapon, the revolver, spawns with the same "weapon type" as the deagle

their damage drops off from 100% at 64 units to 50% at 1024 units

Deagle\
\- base dmg: 35, headshot dmg: 85, limb dmg: 23.33\
\- clip size: 8\
\- fire rate: 120 rpm\
\- deploy time: 0.875 sec\
\- reload time: 2.5 secs\
\- kills an unarmoured player in 1 headshot + 1 bodyshot at close range

the deagle really needed to be nerfed, since it's way too powerful for a pistol

in base ttt, it outperforms primary weapons in most situations (other than the sniper rifle in long range)

being able to kill full-health players in one headshot is simply busted, especially on a weapon that can do it every 0.6 seconds\
hand this weapon to a skilled player, and the game will just revolve around them, which ruins the non-shooting aspects of ttt

despite the nerf, the deagle is still a relatively more powerful secondary weapon that rewards headshots

Revolver\
\- base dmg: 35, headshot dmg: 85, limb dmg: 23.33\
\- clip size: 6\
\- fire rate: 120 rpm\
\- deploy time: 0.75 sec\
\- reloads each round one by one\
\- kills an unarmoured player in 1 headshot + 1 bodyshot at close range

the revolver has the same damage and fire rate as the deagle, but reloads each round one by one

it takes 1.5 seconds to reload the first round, 0.6 seconds to reload each following round, and 0.4 seconds to finish reloading\
this means reloading 6 rounds takes 4.9 seconds (1.5 + 0.6 * 5 + 0.4 = 4.9)

## bug fixes

these are bugs that exist in vanilla ttt that should be fixed by this mod

#### fov zoom glitch
fixed a glitch with fov zooming in slightly for a split second before returning to normal\
this was happening with zoomable weapons whenever they're reloaded, holstered, or dropped

also fixed a glitch with the weapon viewmodel being in the ironsighted position when picked up and deployed after being dropped while zoomed in

<!--

#### instant reload exploit
fixed an exploit that lets you reload instantly by dropping the gun while it's reloading:\
https://cdn.discordapp.com/attachments/383927930641842186/812515986674155531/simplescreenrecorder-2021-02-20_10.33.18.mp4

though the exploit should also be fixed by the next gmod update:\
https://reddit.com/comments/lo48v9//go7ybif \
https://github.com/Facepunch/garrysmod/commit/9d3ba42

-->

## compatibility

tttwr is intended for and balanced for a private mostly-vanilla server with ~8 players

this mod doesn't overwrite any files, so it should be compatible with future gmod and ttt updates\
though the ScalePlayerDamage, Move, and DoPlayerDeath gamemode functions are overwritten

weapons from other mods will not have changes like interpolated recoil, fixed spread pattern, sniper laser dot, etc

the deagle, huge-249, decoy, knife, flaregun, newton launcher, silenced pistol, ump prototype, magneto-stick, and dna scanner have gotten some of their functions heavily modified

tttwr uses the [EntityTakeDamage](https://wiki.facepunch.com/gmod/GM:EntityTakeDamage) hook to batch shotgun damage into a single damage event\
when an entity is hit by 8 pellets, 7 pellets will be ignored by returning `true`\
so this might interfere with mods that use the EntityTakeDamage hook incorrectly\
the EntityTakeDamage hook is for modifying or blocking damage events,\
while the [PostEntityTakeDamage](https://wiki.facepunch.com/gmod/GM:PostEntityTakeDamage) hook is for when damage events are successful

probably not compatible with [ttt2](https://github.com/TTT-2/TTT2/)\
tttwr *can* be made fully-compatible with ttt2, but i don't see why i should work on that right now, since i'm making this mod for a non-ttt2 server
