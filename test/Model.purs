module Test.Model where

import Prelude

import App.Events (Event(..), update)
import App.Geometry (Point(..), Stroke(..), unorderedEq)
import App.Graph (allEdges, edges, getEdgesForPt, points)
import App.State (Tool(..), init)
import Data.Foldable (foldl, foldr)
import Data.List (List(..), length, nubBy, sort, (:))
import Data.Map (keys)
import Data.Maybe (Maybe(..))
import Data.Monoid (mempty)
import Mouse (MouseData(..))
import Test.Spec (describe, describeOnly, it)
import Test.Spec.Assertions (shouldEqual)

spec = do
  describe "Integration" do
    describe "one circle" do
      let s = foldl (flip update) init [ Select ArcTool
                                       , Mouse $ MouseDown (Point 100.0 100.0)
                                       , Mouse $ MouseDown (Point 200.0 100.0)
                                       ]
      let arcs = edges s.drawing.graph

      it "has the right number of arcs" do
        (length $ arcs) `shouldEqual` 1
      it "has the right number of points" do
        (length $ points s.drawing.graph) `shouldEqual` 1
      it "has the right number of cycles" do
        (length $ keys s.drawing.cycles) `shouldEqual` 1

    describe "two circles" do
      let s = foldl (flip update) init [ Select ArcTool
                                       , Mouse $ MouseDown (Point 100.0 100.0)
                                       , Mouse $ MouseDown (Point 200.0 100.0)
                                       , Mouse $ MouseDown (Point 200.0 100.0)
                                       , Mouse $ MouseDown (Point 100.0 100.0)
                                       ]
      let arcs = edges s.drawing.graph

      it "has the right number of arcs" do
        (length $ arcs) `shouldEqual` 6

      it "has the right arcs" do
         (nubBy unorderedEq $ sort $ allEdges s.drawing.graph) `shouldEqual`
         (
           (Arc (Point 200.0 100.0) (Point 100.0 100.0) (Point 150.0 13.397459621556138) true) :
           (Arc (Point 200.0 100.0) (Point 100.0 100.0) (Point 150.0 186.60254037844385) false) :
           (Arc (Point 100.0 100.0) (Point 150.0 13.397459621556138) (Point 150.0 186.60254037844385) false) :
           (Arc (Point 200.0 100.0) (Point 150.0 13.397459621556138) (Point 150.0 186.60254037844385) true) :
           (Arc (Point 100.0 100.0) (Point 150.0 13.397459621556138) (Point 200.0 100.0) true) :
           (Arc (Point 100.0 100.0) (Point 150.0 186.60254037844385) (Point 200.0 100.0) false) :
           Nil
         )

      it "has the right number of points" do
        (length $ points s.drawing.graph) `shouldEqual` 4

      it "has the right number of cycles" do
        (length $ keys s.drawing.cycles) `shouldEqual` 4

    describe "three circles" do
      let s = foldl (flip update) init [ Select ArcTool
                                       , Mouse $ MouseDown (Point 100.0 100.0) -- c1
                                       , Mouse $ MouseDown (Point 200.0 100.0) -- c2
                                       , Mouse $ MouseDown (Point 200.0 100.0) -- c2
                                       , Mouse $ MouseDown (Point 100.0 100.0) -- c1
                                       , Mouse $ MouseDown (Point 150.0 186.6) -- c3
                                       , Mouse $ MouseDown (Point 100.0 100.0) -- c1
                                       ]
      let arcs = edges s.drawing.graph

      it "has the right number of arcs" do
        (length $ arcs) `shouldEqual` 12

      it "has the right arcs" do
         (nubBy unorderedEq $ sort $ allEdges s.drawing.graph) `shouldEqual` (
           (Arc (Point 100.0 100.0) (Point 50.0 186.6025403784439) (Point 150.0 13.397459621556138) true) :
           (Arc (Point 150.0 186.60254037844385) (Point 50.0 186.6025403784439) (Point 100.0 100.0) true) :
           (Arc (Point 100.0 100.0) (Point 50.0 186.6025403784439) (Point 150.0 186.60254037844385) false) :
           (Arc (Point 150.0 186.60254037844385) (Point 50.0 186.6025403784439) (Point 250.0 186.6025403784439) false) :
           (Arc (Point 200.0 100.0) (Point 100.0 100.0) (Point 150.0 13.397459621556138) true) :
           (Arc (Point 150.0 186.60254037844385) (Point 100.0 100.0) (Point 200.0 100.0) true) :
           (Arc (Point 200.0 100.0) (Point 100.0 100.0) (Point 150.0 186.60254037844385) false) :
           (Arc (Point 200.0 100.0) (Point 150.0 13.397459621556138) (Point 250.0 186.6025403784439) true) :
           (Arc (Point 100.0 100.0) (Point 150.0 13.397459621556138) (Point 200.0 100.0) true) :
           (Arc (Point 100.0 100.0) (Point 150.0 186.60254037844385) (Point 200.0 100.0) false) :
           (Arc (Point 200.0 100.0) (Point 150.0 186.60254037844385) (Point 250.0 186.6025403784439) false) :
           (Arc (Point 150.0 186.60254037844385) (Point 200.0 100.0) (Point 250.0 186.6025403784439) true) :
           Nil
         )

      it "has the right number of points" do
        (length $ points s.drawing.graph) `shouldEqual` 6

      it "has the right number of cycles" do
        (length $ keys s.drawing.cycles) `shouldEqual` 8

    describe "touching circles" do
      let s = foldl (flip update) init [ Select ArcTool
                                       , Mouse $ MouseDown (Point 100.0 0.0) -- c1
                                       , Mouse $ MouseDown (Point 0.0 0.0)
                                       , Mouse $ MouseDown (Point 200.0 0.0) -- c2
                                       , Mouse $ MouseDown (Point 0.0 0.0)
                                       , Mouse $ MouseDown (Point 400.0 0.0) -- c3
                                       , Mouse $ MouseDown (Point 0.0 0.0)
                                       , Mouse $ MouseDown (Point 800.0 0.0) -- c4
                                       , Mouse $ MouseDown (Point 0.0 0.0)
                                       , Select SegmentTool
                                       , Mouse $ MouseDown (Point 0.0 100.0) -- p1
                                       , Mouse $ MouseDown (Point 0.0 (-100.0)) -- p2
                                       ]
      let strokes = edges s.drawing.graph

      it "has the right number of strokes" do
        (length $ strokes) `shouldEqual` 6

      it "has the right strokes" do
         (nubBy unorderedEq $ sort $ allEdges s.drawing.graph) `shouldEqual` (
           (Line (Point 0.0 (-100.0)) (Point 0.0 0.0)) :
           (Arc (Point 800.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) true) :
           (Arc (Point 400.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) true) :
           (Arc (Point 200.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) true) :
           (Arc (Point 100.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) true) :
           (Line (Point 0.0 0.0) (Point 0.0 100.0)) :
           Nil
         )

      it "has the right ordering of strokes" do
         (getEdgesForPt (Point 0.0 0.0) s.drawing.graph) `shouldEqual` Just (
           (Arc (Point 100.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) false) :
           (Arc (Point 200.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) false) :
           (Arc (Point 400.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) false) :
           (Arc (Point 800.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) false) :
           (Line (Point 0.0 0.0) (Point 0.0 100.0)) :

           (Line (Point 0.0 0.0) (Point 0.0 (-100.0))) :
           (Arc (Point 800.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) true) :
           (Arc (Point 400.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) true) :
           (Arc (Point 200.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) true) :
           (Arc (Point 100.0 0.0) (Point 0.0 0.0) (Point 0.0 0.0) true) :

           Nil
         )

      it "has the right number of points" do
        (length $ points s.drawing.graph) `shouldEqual` 3

      it "has the right number of cycles" do
        (length $ keys s.drawing.cycles) `shouldEqual` 5
