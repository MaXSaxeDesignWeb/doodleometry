module App.Events where

import App.Background (Background)
import App.Cycle (Cycle, findCycles)
import App.Geometry (Point, Stroke(Line, Arc))
import App.Graph (applyIntersections, edges, findIntersections, removeMultiple)
import App.Snap (snapToPoint)
import App.State (State, Tool(LineTool, ArcTool, EraserTool))
import CSS.Color (Color)
import Data.Function (($))
import Data.List (List(..), singleton)
import Data.Map (keys, lookup)
import Data.Map (update) as Map
import Data.Maybe (Maybe(..))
import KeyDown (KeyData)
import Network.HTTP.Affjax (AJAX)
import Prelude ((==))
import Pux (EffModel, noEffects)

data Event
  = Draw Point
  | EraserDown Point
  | EraserMove Point
  | EraserUp Point
  | Move Point
  | Select Tool
  | SelectCycle Cycle
  | ApplyColor Cycle Color
  | WindowResize Int Int
  | ChangeBackground Background
  | Key KeyData
  | NoOp

type AppEffects fx = (ajax :: AJAX | fx)

foldp :: forall fx. Event -> State -> EffModel State Event (AppEffects fx)
foldp evt st = noEffects $ update evt st

update :: Event -> State -> State
update (Draw p) s =
  let newPt = case snapToPoint p s.background (edges s.graph) of
                   Just sp -> sp
                   _ -> p
   in case s.click of
       Nothing -> s { click = Just newPt }
       Just c ->
         case newStroke s newPt of
              Nothing -> s
              Just stroke -> (updateForStroke s stroke) { click = Nothing
                                                        , currentStroke = Nothing
                                                        , hover = Nothing
                                                        , snapPoint = Nothing
                                                        }

update (Move p) s =
  let sp = snapToPoint p s.background (edges s.graph)
      newPt = case sp of Just sp' -> sp'
                         _ -> p
   in s { hover = Just p
        , currentStroke = newStroke s newPt
        , snapPoint = sp
        }

update (Select tool) s
  = s { tool = tool
      , click = Nothing
      , hover = Nothing
      , snapPoint = Nothing
      , currentStroke = Nothing
      , selection = Nil
      }

update (ApplyColor cycle color) s =
  s {cycles = Map.update (\c -> (Just color)) cycle s.cycles}

update (EraserDown pt) s =
  let eraserPt = if s.tool == EraserTool then Just pt else Nothing
   in s {lastEraserPoint = eraserPt}

update (EraserUp pt) s = s {lastEraserPoint = Nothing}

update (EraserMove pt) s =
  case s.lastEraserPoint of Nothing -> s
                            Just eraserPt -> eraseLine s eraserPt pt

update (WindowResize w h) s =
  s {windowWidth = w, windowHeight = h}

update (ChangeBackground b) s =
  s {background = b, snapPoint = Nothing}

update (Key k) s = s

update (SelectCycle cycle) state = state {selection = singleton cycle}

update NoOp s = s

newStroke :: State -> Point -> Maybe Stroke
newStroke s p =
  case s.click of
       Just c ->
          case s.tool of
               ArcTool -> Just $ (Arc c p p true)
               LineTool -> Just $ Line c p
               _ -> Nothing

       Nothing -> Nothing

eraseLine :: State -> Point -> Point -> State
eraseLine s ptFrom ptTo =
  s { graph = newGraph
    , cycles = newCycles
    , lastEraserPoint = Just ptTo
    }
  where
    intersections = findIntersections (Line ptFrom ptTo) s.graph
    newGraph = removeMultiple (keys intersections) s.graph
    newCycles = findCycles newGraph

updateForStroke :: State -> Stroke -> State
updateForStroke s stroke
  = s { graph = newGraph
      , cycles = newCycles
      }
  where
    intersections = findIntersections stroke s.graph
    splitStroke = case lookup stroke intersections of
                       Just ss -> ss
                       _ -> singleton stroke
    newGraph = applyIntersections intersections s.graph
    newCycles = findCycles newGraph
