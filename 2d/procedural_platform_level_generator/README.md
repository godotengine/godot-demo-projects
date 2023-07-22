# Procedural Level Generation

[Click here to watch the gameplay video](https://www.youtube.com/watch?v=wVo9m_KsGlc)
[![Watch the gameplay video](https://img.youtube.com/vi/wVo9m_KsGlc/maxresdefault.jpg)](https://www.youtube.com/watch?v=wVo9m_KsGlc)

## Introduction

Welcome to Star Dodge, an endless arcade game that features dynamic level generation! In this exciting game, players take control of a star, dodging obstacles in a procedurally generated world. Creating endless and unpredictable levels that keep players engaged and challenged.


## Procedural Level Generation

In the realm of procedural level generation, there are several approaches to consider. I chose a grid-based (TileMap) approach, as it provided us with the flexibility and control we needed for generating our endless levels.

### Grid-Based Approach

The grid-based approach divides the game world into a grid of cells, with each cell representing a tile in our game. Tiles can be anything from lines to obstacles, and we place them on the grid to construct our level.

### Level Generation Algorithm

Our level-generation algorithm works as follows:

1. **Calculating Y-index**: To ensure that the level remains within the screen boundaries, we calculate a `y_index` based on the screen height, which defines the row where the tiles will be placed.

2. **Placing Tiles**: We place random lines first and then alternate with obstacles for diversity. Each generated tile is assigned to a specific cell on the grid using `(x, y_index)` coordinates.

3. **Infinite Progression**: To create the feeling of infinite gameplay, we continuously move the `x` coordinate of the tile position. As the player progresses, the grid seamlessly generates new tiles ahead, creating the illusion of an unending world.

### Managing Tile Pool

To ensure optimal performance and avoid excessive memory usage, we implemented a dynamic tile management system. We only generate and keep tiles that are close to the screen, and as the player moves forward, we remove tiles that are no longer visible.
![Dynamic_tile_generation](https://github.com/Ymanawat/Run-Across/assets/81252768/50f9f0e5-3449-4338-b3e5-5caf22766906)


### Embracing the Randomness

The true beauty of dynamic level generation lies in the element of surprise. No two gameplay sessions are alike, thanks to the randomness infused into the level-generation process. Players must adapt quickly to new challenges, making each playthrough an exciting and unique experience.

## Play

[Click here to play demo on itch.io](https://yogendram.itch.io/star-dodge)

## Conclusion

Star Dodge's power of procedural generation, we create an ever-changing world of obstacles and challenges for players to conquer. Embrace the unpredictability, test your reflexes, and embark on an infinite journey!
