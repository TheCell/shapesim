Grundlegende Bestandteile:
Zivilisations-Sim
Newsticker

Zivilisations-Sim
Ein zentraler Zeit-ticker
Jede Zivilisation hat einen "hub"
Der Hub platziert Gebäude (Warriors hut / Science / Watchtower)
Ziv hat Grundparameter, die durch Science buildings verbessert werden (z.B. movement speed, warrior damage, unit health, building deterioration speed, watchtower)
Zivilisation hat hostility zu den anderen zivilisationen (je höher desto aggressiver)

Society goals:
Zivilisation wählt alle X ticks ein society goal:
waaargh: moar warriors
science: moar science
defense: moar defense

Hostility zu einer zivilisation wird beeinflusst durch:
eine unit wird von der anderen zivilisation getötet -> + hostility
gebäude werden angegriffen -> + hostility
andere zivilisation ist mindestens X levels höher als alle anderen -> + hostility
ratio der ausgesendeten Warriors wird durch ratio der hostility zu allen zivilisationen bestimmt

Warriors hut
spawnt warrior alle X ticks
warriors suchen sich ein Ziel basierend auf den hostility stats der zivilisation aus und bewegen sich auf den hub der anderen zivilisation zu. Wenn sie auf einen Warrior / ein Gebäude treffen, greifen sie an.

Science
verbessert alle X ticks einen stat

Watchtower
greift enemy units in range an

Terrain
grid-based
Jedes Tile hat einen state
mögliche states:
Passable:
dirt -> kein effekt
steppe -> minus health all X ticks
diverses (schneller, langsamer, etc.)

Tiles haben Health -> health bestimmt state
z.B.
0: void
1: rock
2: steppe
3: gras

Impassable:
rock
void -> nach X ticks: become a random tile
 
God Abilities
Hat einen Radius / eine Form, in der der Effekt angewendet wird -> an der Position der Maus
grid based

mögliche Effekte:
time speed up & slow down
meteor -> alle X ticks big explosion -> damage tiles
push & pull -> gebäude & units
heal -> heal tiles, buildings & units

Blitz -> damages units & gebäude (maybe baby)
duplication -> duplicates unity & gebäude (maybe baby)

Newsticker (waiter waiter more features please)
reagiert auf events auf der map

Bestimmte threshold:
z.B. 100 units von ziv blau gestorben
ziv grün reached level 5
etc.

Texte werden basierend auf events generiert

wenn god abilites bei einem major event intervenieren -> text wird durchgestrichen à la "nevermind, god threw a meteor at it, everybody's dead"