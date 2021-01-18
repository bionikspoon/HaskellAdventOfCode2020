module Day25.Solution
  ( crack,
    findEncryptionKey,
    part1,
    transform,
  )
where

part1 :: String -> String
part1 = show . findEncryptionKey 7 1591838 . readPublicKeys

type LoopSize = Integer

type SubjectNumber = Integer

readPublicKeys :: String -> (Integer, Integer)
readPublicKeys = asPair . map read . lines
  where
    asPair (a : b : _) = (a, b)
    asPair _ = undefined

transform :: SubjectNumber -> LoopSize -> SubjectNumber
transform subjectNumber privateKey = (subjectNumber ^ privateKey) `mod` 20201227

crack :: LoopSize -> Integer -> SubjectNumber -> SubjectNumber
crack loopSize privateKey publicKey
  | transform loopSize privateKey == publicKey = privateKey
  | otherwise = undefined

findEncryptionKey :: LoopSize -> Integer -> (Integer, Integer) -> Integer
findEncryptionKey loopSize seed (a, b) = transform b (crack loopSize seed a)
