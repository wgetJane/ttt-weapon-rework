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

#### sighting is visible in third-person
you can now tell if another player is using their weapon's sights

pistols will be held with both hands, rifles will be held up to the shoulder, etc

this is particularly important for knowing if a sniper is scoped in or not

#### tracers
sniper rifles will always have a visible tracer for every shot instead of for every 4 shots\
silenced weapons will no longer fire visible tracers

<!--

#### sniper laser dot
while zoomed in, sniper rifles will cast a laser dot on where they're pointing at

this is similar to how tf2's sniper rifle casts a laser dot

the purpose of this change is to make snipers easier to avoid and react to

-->

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

also, props carried by the magneto-stick are now lag-compensated\
set the cvar `ttt_magneto_lagcomp` from 1 to 0 if you want to disable this for some reason

#### huge-249
\- damage increased from 7 to 13\
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

#### body armor
now costs 2 credits for traitors

in vanilla servers, traitors often just spend their first 2 credits on radar + armour

by doubling the price of armour, other traitor weapons become more attractive options so traitors don't just buy the same stuff every round

body armour gives traitors an effective health of 142.86, which is a huge advantage to be sold for just 1 credit

i believe that traitors shouldn't be able to easily win a head-on 1v1 fight,\
since they're supposed to use stealth, surprise, teamwork, and deception to take out innocents

the cost of armour, radar, and disguise can be changed with the cvars `ttt_buycost_armor`, `ttt_buycost_radar`, `ttt_buycost_disguise`

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
\- both primary and alt-fire can be charged up to 2 secs for up to 2 times force\
\- target's velocity is overriden\
\- will now properly credit prop-kills

the newton launcher's alt-fire will now pull players towards you

this gives the newton launcher another angle to use it from\
for example, it can be used to pull players off of ledges

both push and pull attacks can be held down to be charged\
and it now takes 2 seconds to gradually charge up to 200% force

it previously took 1.25 secs to fully charge but this was inconsistent based on server tick rate\
it took 1.5 secs to charge on 66.67 tickrate or 3.125 secs to charge on 16 tickrate

also previously, charging only increased force by up to 116.67% at full charge,\
so it was never even worth it to use the alt-fire

hitting someone with the newton launcher now overrides their former velocity,\
since it was silly that the push force can be entirely cancelled out by simply walking in the opposite direction

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

the cvar `ttt_magneto_hpstation` controls who can carry health stations\
0 means that nobody can carry them\
1 means that only detectives can carry them (default)\
2 means that everybody can carry them

## other changes

#### dropping ammo
the console command `ttt_dropammo` now drops ammo from your reserve instead of from your clip

this makes it significantly easier to transfer ammo to another weapon

a new console command `ttt_dropclip` is added for when you do want to drop ammo from your clip

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

#### adjustable gunshot sound volume
i've added client-side options to adjust the sound volume of gunshot sounds so you can protect your hearing

the cvar `ttt_volume_guns_self` adjusts the sound volume of your own gunshots (default value is 0.5)\
the cvar `ttt_volume_guns_other` adjusts the sound volume of other players' gunshots (default value is 1.0)

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

#### stomp damage
the cvar `ttt_stomp_mult` adjusts the damage received by the victim (default value is 1.0)\
the cvar `ttt_stomp_cushion` adjusts the damage received by the attacker (default value is 0.33)

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

#### tweaked jump animations
player jump animations have been made less erratic so it's easier to hit players that are jumping around

this can be disabled by setting the cvar `ttt_jumpanimtweak` from 1 to 0

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
\- base dmg: 25, headshot dmg: 35, limb dmg: 16.67\
\- clip size: 20\
\- fire rate: 240 rpm\
\- deploy time: 0.75 secs\
\- reload time: 2.75 secs\
\- kills an unarmoured player in three headshots at close range

Glock\
\- base dmg: 20, headshot dmg: 27, limb dmg: 13.33\
\- clip size: 20\
\- fire rate: 300 rpm\
\- deploy time: 0.75 secs\
\- reload time: 2.4 secs\
\- lower recoil\
\- kills an unarmoured player in four headshots at close range

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

#### smgs
these weapons have fast fire rates and low recoil but poor accuracy, making them suited for close-range

their damage drops off from 100% at 64 units to 50% at 1024 units

MP5\
\- base dmg: 12, headshot dmg: 16, limb dmg: 10\
\- clip size: 30\
\- fire rate: 600 rpm\
\- deploy time: 0.875 secs\
\- reload time: 2.75 secs

MAC-10\
\- base dmg: 12, headshot dmg: 16, limb dmg: 10\
\- clip size: 30\
\- fire rate: 800 rpm\
\- deploy time: 0.75 secs\
\- reload time: 2.75 secs\
\- distance damage falloff ends at 512 units instead of 1024 units\
\- slightly higher recoil, very poor accuracy

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
\- fire rate: 666 rpm\
\- deploy time: 1 sec\
\- reload time: 3 secs\
\- very low recoil\
\- recoil multiplier while sighted is 20% instead of 60%\
\- inaccuracy multiplier while sighted is 33% instead of 85%

#### assault rifles
these are supposed to be generally decent primary weapons at mid range

their damage drops off from 100% at 384 units to 50% at 1280 units

their recoil multiplier while sighted is 40% instead of 60%\
and inaccuracy multiplier while sighted is 75% instead of 85%

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
\- reload time: 2.75 secs\
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
\- fire rate: 375 rpm\
\- deploy time: 1 sec\
\- reload time: 3.25 secs\
\- higher recoil, poor accuracy\
\- recoil multiplier while sighted is 20% instead of 40%\
\- inaccuracy multiplier while sighted is 40% instead of 75%

SG 552\
\- base dmg: 16, headshot dmg: 26.67, limb dmg: 8\
\- clip size: 30\
\- fire rate: 375 rpm\
\- deploy time: 1 sec\
\- reload time: 3 secs\
\- much higher recoil, poor accuracy\
\- recoil multiplier while sighted is 20% instead of 40%\
\- inaccuracy multiplier while sighted is 40% instead of 75%

#### sniper rifles
these are scoped weapons with perfect accuracy but slow fire rates

they do not have distance damage falloff, making them the supreme weapons at long range

the scout and awp can be charged by holding down primary fire to deal a lot more damage,\
but a laser beam will be visible while charging which gives away the user's position

the auto-snipers cannot be charged, but can be fired automatically with a much faster rate of fire

Scout\
\- base dmg: 36, headshot dmg: 72, limb dmg: 18\
\- charged dmg: 54, headshot dmg: 108, limb dmg: 27\
\- clip size: 10\
\- fire rate: 60 rpm\
\- deploy time: 0.875 secs\
\- reload time: 3 secs\
\- charge time: 1 sec\
\- kills an unarmored player in:\
&nbsp; &nbsp; &nbsp; &nbsp; \- 1 charged headshot\
&nbsp; &nbsp; &nbsp; &nbsp; \- 1 uncharged headshot + 1 uncharged bodyshot\
&nbsp; &nbsp; &nbsp; &nbsp; \- 2 charged bodyshots\
\- kills an armored player in:\
&nbsp; &nbsp; &nbsp; &nbsp; \- 2 uncharged headshots\
&nbsp; &nbsp; &nbsp; &nbsp; \- 1 charged headshot + 1 uncharged bodyshot

AWP\
\- base dmg: 50, headshot dmg: 75, limb dmg: 25\
\- charged dmg: 75, headshot dmg: 112.5, limb dmg: 37.5\
\- clip size: 10\
\- fire rate: 40 rpm\
\- deploy time: 1 sec\
\- reload time: 4 secs\
\- charge time: 1.5 secs\
\- kills an unarmored player in:\
&nbsp; &nbsp; &nbsp; &nbsp; \- 1 charged headshot\
&nbsp; &nbsp; &nbsp; &nbsp; \- 2 uncharged bodyshots\
\- kills an armored player in:\
&nbsp; &nbsp; &nbsp; &nbsp; \- 2 uncharged headshots\
&nbsp; &nbsp; &nbsp; &nbsp; \- 1 uncharged headshot + 1 charged bodyshot\
&nbsp; &nbsp; &nbsp; &nbsp; \- 2 charged bodyshots

G3\
\- base dmg: 25, headshot dmg: 50, limb dmg: 12.5\
\- clip size: 20\
\- fire rate: 200 rpm\
\- deploy time: 1 sec\
\- reload time: 3.5 secs\
\- kills an unarmoured player in 2 headshots

Krieg\
\- base dmg: 40, headshot dmg: 50, limb dmg: 30\
\- clip size: 20\
\- fire rate: 133 rpm\
\- deploy time: 1 sec\
\- reload time: 3.5 secs\
\- kills an unarmoured player in 1 bodyshot + 2 limbshots

#### shotguns
great burst damage at close range, but becomes extremely weak outside of close range

it takes 0.5 seconds to begin reloading, 0.5 seconds to reload a shell, and 0.5 seconds to finish reloading\
this means reloading 8 shells takes 5 seconds (0.5 + 0.5 * 8 + 0.5 = 5)

all shotguns shoot 8 pellets in a fixed spread pattern

their damage drops off from 100% at 64 units to 50% at 768 units

headshot multiplier also drops off from 240% at 64 units to 100% at 192 units

M3\
\- base dmg: 10, headshot dmg: 24, limb dmg: 9\
\- clip size: 8\
\- fire rate: 64 rpm\
\- deploy time: 1 sec\
\- can kill an armoured player in one headshot at close range

XM\
\- base dmg: 4, headshot dmg: 9.6, limb dmg: 3.6\
\- clip size: 8\
\- fire rate: 250 rpm\
\- deploy time: 1 sec

SPAS-12\
\- base dmg: 7, headshot dmg: 16.8, limb dmg: 6.3\
\- clip size: 6\
\- fire rate: 90 rpm\
\- deploy time: 0.75 sec\
\- takes 0.4 secs to reload a shell instead of 0.5 secs\
\- can kill an unarmoured player in one headshot at close range

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

#### buy menu weapons

the Silenced M16 is a traitor weapon that costs 2 credits\
it is basically an assault rifle alternative to the silenced pistol

enabled by default, set the cvar `ttt_buyable_sim16` from 1 to 0 to disable

Silenced M16\
\- base dmg: 16, headshot dmg: 28.33, limb dmg: 8.5\
\- clip size: 30\
\- fire rate: 400 rpm\
\- deploy time: 1 sec\
\- reload time: 2.75 secs\
\- better recoil and accuracy

the Dual Elites is a traitor weapon that costs 1 credit\
it has very generous auto-aim (45 degree cone) and can attack two players simultaneously\
damage output is doubled when attacking two targets

disabled by default, set the cvar `ttt_buyable_elites` from 0 to 1 to enable

Dual Elites\
\- base dmg: 15, headshot dmg: 15, limb dmg: 10\
\- clip size: 30\
\- fire rate: 360 rpm\
\- deploy time: 1 secs\
\- reload time: 4 secs

the Penetrator is a detective weapon that costs 1 credit\
it's a version of the deagle that can shoot through walls\
this is meant to keep traitors from just camping inside traitor rooms (an annoying feature in many maps)

experimental, disabled by default, set the cvar `ttt_buyable_penetrator` from 0 to 1 to enable

The Penetrator\
\- base dmg: 35, headshot dmg: 85, limb dmg: 23.33\
\- clip size: 8\
\- fire rate: 150 rpm\
\- deploy time: 0.75 sec\
\- reload time: 2.5 secs\
\- kills an unarmoured player in 1 headshot + 1 bodyshot at close range

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

tttwr is compatible with [ttt2](https://github.com/TTT-2/TTT2/)\
however, a few features will be unavailable:\
\- decoy buff\
\- detectives receiving credit rewards only when identifying traitor corpses\
\- priority targets for traitors\
\- buycost cvars for traitor shop (ttt2 already has a shop editor)
