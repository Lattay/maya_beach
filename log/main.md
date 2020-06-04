# DevLog

## Day 1

I got the concept pretty quickly after typing the theme on Google.
"The Beach" leads to the movie, the movie leads to the actual beach.
It was crowded with tourists and now it is closed.
I wondered what I could do with that, thought about a bot arriving,
then though about a good old flash game, Diner Dash, which was pretty good.
I want to try to reproduce this fealing of permanent rush you have when playing Diner Dash.
I just hope the project is not too ambitious for the time I got.
I won't be able to work on this a lot during the week, so I'll have to do as
much as possible during the weekend.

For today I spend some time building the basic blocks in godot, assembling quick mockup of the arts.

I used a lot of Position2D to create drivers for diverse movements.
I'll also try to generate random walk for the tourists.
I have to think about how the boat arrives, how long should be the visit and how it should evolve.

## Day 2

I had not enough time today either unfortunatly.
I tried to design the boat and dock mecanisms, hopefully I can get at least that to work tommorow.
I should also start working on the tourist IA.

## Day 3

Boat is docking, on a free anchor. Boat spawn is limited.
Started to refactor input into a central click.gd script to allow drag and drop mecanisms
People are disembarking and chilling around.

## Day 4

Got almost everything boat related working, I should start working on the tourists satisfaction mecanism
with a time of visit indicator. I should also start working on the dashboard soon to get the play cycle buy boat-build dock-set visit price.
Also the HUD should contain an indication of reservations, daily net revenue and current wealth.

## Day 5 and 6
I set up a time indicator that allow me to hint the player about the satisfaction of the tourists.
I also decided to use a daily update system for income, popularity, reservations etc, using a day-night cycle animation for the player to keep track.
