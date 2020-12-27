module Day20.SolutionSpec (spec) where

import qualified Data.Map.Strict as Map
import Data.Sequence
import Day20.Solution
import Test.Hspec

spec :: Spec
spec = parallel $ do
  it "solves Part 1" $ do
    input <- readFile "./test/Day20/input.txt"
    part1 input `shouldBe` "21599955909991"
  xit "solves Part 2" $ do
    input <- readFile "./test/Day20/input.txt"
    part2 input `shouldBe` "hello_santa"

  let exampleTiles =
        fromList
          [ Tile {tId = 2311, tContent = ["..##.#..#.", "##..#.....", "#...##..#.", "####.#...#", "##.##.###.", "##...#.###", ".#.#.#..##", "..#....#..", "###...#.#.", "..###..###"]},
            Tile {tId = 1951, tContent = ["#.##...##.", "#.####...#", ".....#..##", "#...######", ".##.#....#", ".###.#####", "###.##.##.", ".###....#.", "..#.#..#.#", "#...##.#.."]},
            Tile {tId = 1171, tContent = ["####...##.", "#..##.#..#", "##.#..#.#.", ".###.####.", "..###.####", ".##....##.", ".#...####.", "#.##.####.", "####..#...", ".....##..."]},
            Tile {tId = 1427, tContent = ["###.##.#..", ".#..#.##..", ".#.##.#..#", "#.#.#.##.#", "....#...##", "...##..##.", "...#.#####", ".#.####.#.", "..#..###.#", "..##.#..#."]},
            Tile {tId = 1489, tContent = ["##.#.#....", "..##...#..", ".##..##...", "..#...#...", "#####...#.", "#..#.#.#.#", "...#.#.#..", "##.#...##.", "..##.##.##", "###.##.#.."]},
            Tile {tId = 2473, tContent = ["#....####.", "#..#.##...", "#.##..#...", "######.#.#", ".#...#.#.#", ".#########", ".###.#..#.", "########.#", "##...##.#.", "..###.#.#."]},
            Tile {tId = 2971, tContent = ["..#.#....#", "#...###...", "#.#.###...", "##.##..#..", ".#####..##", ".#..####.#", "#..#.#..#.", "..####.###", "..#.#.###.", "...#.#.#.#"]},
            Tile {tId = 2729, tContent = ["...#.#.#.#", "####.#....", "..#.#.....", "....#..#.#", ".##..##.#.", ".#.####...", "####.#.#..", "##.####...", "##..#.##..", "#.##...##."]},
            Tile {tId = 3079, tContent = ["#.#.#####.", ".#..######", "..#.......", "######....", "####.#..#.", ".#...#.##.", "#.#####.##", "..#.###...", "..#.......", "..#.###..."]}
          ]

  describe "parseTiles" $ do
    it "parses the input into tiles" $ do
      input <- readFile "./test/Day20/example.txt"

      parseTiles input `shouldBe` Right exampleTiles

  let exampleGrid =
        Map.fromList
          [ ((0, -1), Tile {tId = 1951, tContent = ["#.##...##.", "#.####...#", ".....#..##", "#...######", ".##.#....#", ".###.#####", "###.##.##.", ".###....#.", "..#.#..#.#", "#...##.#.."]}),
            ((0, 0), Tile {tId = 2311, tContent = ["..##.#..#.", "##..#.....", "#...##..#.", "####.#...#", "##.##.###.", "##...#.###", ".#.#.#..##", "..#....#..", "###...#.#.", "..###..###"]}),
            ((0, 1), Tile {tId = 3079, tContent = ["..#.###...", "..#.......", "..#.###...", "#.#####.##", ".#...#.##.", "####.#..#.", "######....", "..#.......", ".#..######", "#.#.#####."]}),
            ((1, -1), Tile {tId = 2729, tContent = ["...#.#.#.#", "####.#....", "..#.#.....", "....#..#.#", ".##..##.#.", ".#.####...", "####.#.#..", "##.####...", "##..#.##..", "#.##...##."]}),
            ((1, 0), Tile {tId = 1427, tContent = ["###.##.#..", ".#..#.##..", ".#.##.#..#", "#.#.#.##.#", "....#...##", "...##..##.", "...#.#####", ".#.####.#.", "..#..###.#", "..##.#..#."]}),
            ((1, 1), Tile {tId = 2473, tContent = [".##...####", ".######...", "#.###.##..", "#.###.###.", "#.#.#.#...", ".######.##", "###.#..###", "..#.###..#", "##.##....#", "..#.###..."]}),
            ((2, -1), Tile {tId = 2971, tContent = ["..#.#....#", "#...###...", "#.#.###...", "##.##..#..", ".#####..##", ".#..####.#", "#..#.#..#.", "..####.###", "..#.#.###.", "...#.#.#.#"]}),
            ((2, 0), Tile {tId = 1489, tContent = ["##.#.#....", "..##...#..", ".##..##...", "..#...#...", "#####...#.", "#..#.#.#.#", "...#.#.#..", "##.#...##.", "..##.##.##", "###.##.#.."]}),
            ((2, 1), Tile {tId = 1171, tContent = ["...##.....", "...#..####", ".####.##.#", ".####...#.", ".##....##.", "####.###..", ".####.###.", ".#.#..#.##", "#..#.##..#", ".##...####"]})
          ]
  describe "buildGrid" $ do
    it "places all the pieces" $ do
      buildGrid exampleTiles `shouldBe` exampleGrid

  describe "boundingBox" $ do
    context "given a grid" $ do
      it "is the 4 corners of the box" $ do
        boundingBox exampleGrid `shouldBe` [(0, -1), (0, 1), (2, -1), (2, 1)]

  describe "cornerIds" $ do
    context "given a grid" $ do
      it "is the ids of 4 corners" $ do
        cornerIds exampleGrid `shouldBe` [1951, 3079, 2971, 1171]
  describe "tileFit" $ do
    it "finds a position and orientation for a tile" $ do
      let grid = Map.fromList [((0, 0), Tile {tId = 2311, tContent = ["..##.#..#.", "##..#.....", "#...##..#.", "####.#...#", "##.##.###.", "##...#.###", ".#.#.#..##", "..#....#..", "###...#.#.", "..###..###"]})] :: Grid
      let tile = Tile {tId = 1427, tContent = ["###.##.#..", ".#..#.##..", ".#.##.#..#", "#.#.#.##.#", "....#...##", "...##..##.", "...#.#####", ".#.####.#.", "..#..###.#", "..##.#..#."]}
      let point = (1, 0) :: Point
      tileFit grid point tile `shouldBe` Just tile

  describe "orientations" $ do
    it "is all the orientations of a 2x2 grid" $ do
      let grid =
            [ ['a', 'b', 'c', 'd'],
              ['e', 'f', 'g', 'h'],
              ['i', 'j', 'k', 'l'],
              ['m', 'n', 'o', 'o']
            ]

      orientations grid
        `shouldBe` [ [ "abcd",
                       "efgh",
                       "ijkl",
                       "mnoo"
                     ],
                     [ "miea",
                       "njfb",
                       "okgc",
                       "olhd"
                     ],
                     [ "oonm",
                       "lkji",
                       "hgfe",
                       "dcba"
                     ],
                     [ "dhlo",
                       "cgko",
                       "bfjn",
                       "aeim"
                     ],
                     [ "dcba",
                       "hgfe",
                       "lkji",
                       "oonm"
                     ],
                     [ "olhd",
                       "okgc",
                       "njfb",
                       "miea"
                     ],
                     [ "mnoo",
                       "ijkl",
                       "efgh",
                       "abcd"
                     ],
                     [ "aeim",
                       "bfjn",
                       "cgko",
                       "dhlo"
                     ]
                   ]
