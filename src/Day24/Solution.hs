module Day24.Solution
  ( Coordinates (..),
    Neighbor (..),
    asCoordinates,
    asFlippedTileSet,
    livingArtDay,
    parseTilePaths,
    part1,
    part2,
  )
where

import Advent.Utils (fromRightOrShowError)
import Data.Char (toUpper)
import Data.Function ((&))
import Data.HashSet (HashSet)
import qualified Data.HashSet as Set
import Data.Hashable (Hashable (hashWithSalt))
import Data.IntMap.Strict (IntMap)
import qualified Data.IntMap.Strict as IntMap
import Text.Parsec
import Prelude hiding (lookup)

part1 :: String -> String
part1 = show . length . asFlippedTileSet . map asCoordinates . fromRightOrShowError . parseTilePaths

part2 :: String -> String
part2 = show . length . (IntMap.! 100) . livingArtDay 100 . asFlippedTileSet . map asCoordinates . fromRightOrShowError . parseTilePaths

data Neighbor = E | SE | SW | W | NW | NE deriving (Show, Eq, Read)

type TilePath = [Neighbor]

newtype Coordinates = Coordinates {getCoordinates :: (Int, Int, Int)} deriving (Show, Eq, Ord)

instance Semigroup Coordinates where
  (Coordinates (a, b, c)) <> (Coordinates (x, y, z)) = Coordinates (a + x, b + y, c + z)

instance Monoid Coordinates where
  mempty = Coordinates (0, 0, 0)

instance Hashable Coordinates where
  hashWithSalt n (Coordinates (a, b, c)) = hashWithSalt n (a, b, c)

parseTilePaths :: String -> Either ParseError [TilePath]
parseTilePaths = parse (tilePathParser `sepEndBy1` newline) ""
  where
    tilePathParser :: Parsec String () TilePath
    tilePathParser = many1 neighborParser

    neighborParser :: Parsec String () Neighbor
    neighborParser =
      read . map toUpper
        <$> choice
          [ try $ string "e",
            try $ string "se",
            try $ string "sw",
            try $ string "w",
            try $ string "nw",
            try $ string "ne"
          ]

asCoordinates :: TilePath -> Coordinates
asCoordinates = mconcat . map go
  where
    go :: Neighbor -> Coordinates
    go E = Coordinates (1, -1, 0)
    go SE = Coordinates (0, -1, 1)
    go SW = Coordinates (-1, 0, 1)
    go W = Coordinates (-1, 1, 0)
    go NW = Coordinates (0, 1, -1)
    go NE = Coordinates (1, 0, -1)

asFlippedTileSet :: [Coordinates] -> HashSet Coordinates
asFlippedTileSet = foldr toggle Set.empty

livingArtDay :: Int -> HashSet Coordinates -> IntMap (HashSet Coordinates)
livingArtDay = livingArtDay' IntMap.empty 0

livingArtDay' :: IntMap (HashSet Coordinates) -> Int -> Int -> HashSet Coordinates -> IntMap (HashSet Coordinates)
livingArtDay' history n d flippedTileSet
  | n < 0 = undefined
  | n > d = history
  | n == 0 = livingArtDay' (IntMap.insert n flippedTileSet history) (n + 1) d flippedTileSet
  | otherwise = livingArtDay' (IntMap.insert n nextFlippedTileSet history) (n + 1) d nextFlippedTileSet
  where
    nextFlippedTileSet :: HashSet Coordinates
    nextFlippedTileSet = foldr nextTileState flippedTileSet candidateTiles

    nextTileState :: Coordinates -> HashSet Coordinates -> HashSet Coordinates
    nextTileState point
      | isFlipped && (neighborTiles & length & ((||) <$> (0 ==) <*> (> 2))) = Set.delete point
      | isFlipped = Set.insert point
      | not isFlipped && (neighborTiles & length & (== 2)) = Set.insert point
      | not isFlipped = Set.delete point
      | otherwise = undefined
      where
        isFlipped :: Bool
        isFlipped = Set.member point flippedTileSet
        neighborTiles :: HashSet Coordinates
        neighborTiles = Set.filter (`Set.member` flippedTileSet) $ candidates point

    candidateTiles :: HashSet Coordinates
    candidateTiles = Set.union flippedTileSet . Set.unions . Set.toList . Set.map candidates $ flippedTileSet

toggle :: Coordinates -> HashSet Coordinates -> HashSet Coordinates
toggle point set
  | Set.member point set = Set.delete point set
  | otherwise = Set.insert point set

candidateOffsets :: HashSet Coordinates
candidateOffsets =
  Set.fromList
    [ Coordinates (x, y, z)
      | x <- [-1 .. 1],
        y <- [-1 .. 1],
        z <- [-1 .. 1],
        x + y + z == 0,
        (x, y, z) /= (0, 0, 0)
    ]

candidates :: Coordinates -> HashSet Coordinates
candidates coordinates = Set.map (<> coordinates) candidateOffsets
