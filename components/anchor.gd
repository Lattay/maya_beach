extends Position2D

enum DisembarkSide {
    ON_LEFT,
    ON_RIGHT,
}

export(DisembarkSide) var disembark
var dock_index = 0
