module Day19.Solution where

import Advent.Parser
import Advent.Utils
import Data.Either
import qualified Data.IntMap.Lazy as IntMap
import Text.Parsec

part1 :: String -> String
part1 = show . length . validMessages . fromRightOrShowError . parseDocument

part2 :: String -> String
part2 = show . length . validMessages . withNewRules . fromRightOrShowError . parseDocument

data Rule = Ref [[Int]] | Val Char deriving (Show, Eq)

type Rules = IntMap.IntMap Rule

data Document = Document {dRules :: Rules, dMessages :: [String]} deriving (Show, Eq)

parseDocument :: String -> Either ParseError Document
parseDocument = parse documentParser ""
  where
    documentParser :: Parsec String () Document
    documentParser = Document <$> rulesParser <*> (spaces *> messagesParser <* eof)

    messagesParser :: Parsec String () [String]
    messagesParser = many1 letter `sepEndBy` newline

    rulesParser :: Parsec String () Rules
    rulesParser = IntMap.fromList <$> (rulePairParser `endBy1` newline)

    rulePairParser :: Parsec String () (Int, Rule)
    rulePairParser = (,) <$> (intParser <* char ':' <* char ' ') <*> ruleParser

    ruleParser :: Parsec String () Rule
    ruleParser = valParser <|> refParser

    refParser :: Parsec String () Rule
    refParser = Ref <$> (subRuleParser `sepBy1` (char '|' <* char ' '))

    subRuleParser :: Parsec String () [Int]
    subRuleParser = intParser `sepEndBy1` char ' '

    valParser :: Parsec String () Rule
    valParser = Val <$> betweenDblQuotes letter

    betweenDblQuotes :: Parsec String () a -> Parsec String () a
    betweenDblQuotes = between (char '"') (char '"')

buildDynamicParser :: Rules -> String -> Either ParseError String
buildDynamicParser rules = parse (go 0 <* eof) ""
  where
    go :: Int -> Parsec String () String
    go i = rulesMap IntMap.! i

    rulesMap :: IntMap.IntMap (Parsec String () String)
    rulesMap = IntMap.map asParser rules

    asParser :: Rule -> Parsec String () String
    asParser (Val c) = string [c]
    asParser (Ref options) = choice . map (try . mconcat . map go) $ options

withNewRules :: Document -> Document
withNewRules document@Document {dRules = rules} = document {dRules = IntMap.union newRules rules}
  where
    newRules :: Rules
    newRules =
      IntMap.fromList
        [ (8, Ref [[42], [42, 8]]),
          (11, Ref [[42, 31], [42, 11, 31]])
        ]

validMessages :: Document -> [String]
validMessages (Document rules messages) = filter (isRight . parseDynamic) messages
  where
    parseDynamic = buildDynamicParser rules
