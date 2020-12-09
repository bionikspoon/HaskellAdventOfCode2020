module Day09.Solution (part1, part2, xmasCypher, encryptionWeakness, parseNumbers) where

import Advent.Utils (combinations, readInt)
import Data.Foldable (find)
import Data.Maybe (fromJust)

part1 :: String -> String
part1 = show . fromJust . xmasCypher 25

part2 :: String -> String
part2 = show . (encryptionWeakness <$> (fromJust . xmasCypher 25) <*> parseNumbers)

xmasCypher :: Int -> String -> Maybe Int
xmasCypher n = fmap snd . find (uncurry followsPreamble) . rollingChunks n . parseNumbers
  where
    followsPreamble :: [Int] -> Int -> Bool
    followsPreamble preamble target = not $ any ((== target) . sum) (combinations 2 preamble)

parseNumbers :: String -> [Int]
parseNumbers = map readInt . lines

rollingChunks :: Num b => Int -> [b] -> [([b], b)]
rollingChunks n xs =
  [ (take n chunkStart, chunkStart !! max 0 n)
    | i <- [1 .. (length xs - (n + 1))],
      let chunkStart = drop i xs
  ]

encryptionWeakness :: Int -> [Int] -> Int
encryptionWeakness target = go 1
  where
    go :: Int -> [Int] -> Int
    go end ns
      | sum contiguousRange < target = go (succ end) ns
      | sum contiguousRange == target = minimum contiguousRange + maximum contiguousRange
      | sum contiguousRange > target = go 1 (drop 1 ns)
      where
        contiguousRange = take end ns
