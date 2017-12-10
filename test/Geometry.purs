module Test.Geometry where

import App.Geometry
import Prelude

import Data.List (List(..), sort, (:))
import Math (atan2, pi)
import Test.Spec (describe, describeOnly, it, itOnly)
import Test.Spec.Assertions (shouldEqual)

spec = do
  describe "App.Geometry" do
    describe "sweep" do
      it "should produce a sweep of 2pi for same start/end point" do
        sweep (Arc (Point 10.0 10.0) (Point 20.0 10.0) (Point 20.0 10.0) true) `shouldEqual` (2.0 * pi)
        sweep (Arc (Point 10.0 10.0) (Point 20.0 10.0) (Point 20.0 10.0) false) `shouldEqual` (- 2.0 * pi)

      it "should produce a different sweep depending on ccw flag" do
        sweep (Arc (Point 10.0 10.0) (Point 20.0 10.0) (Point 10.0 20.0) true) `shouldEqual` (pi / 2.0)
        sweep (Arc (Point 10.0 10.0) (Point 20.0 10.0) (Point 10.0 20.0) false) `shouldEqual` -(3.0 * pi / 2.0)

      it "should work across the 0 boundary" do
        sweep (Arc (Point 10.0 10.0) (Point 10.0 0.0) (Point 10.0 20.0) true) `shouldEqual` pi
        sweep (Arc (Point 10.0 10.0) (Point 10.0 0.0) (Point 10.0 20.0) false) `shouldEqual` (-pi)
        sweep (Arc (Point 10.0 10.0) (Point 10.0 20.0) (Point 10.0 0.0) true) `shouldEqual` pi
        sweep (Arc (Point 10.0 10.0) (Point 10.0 20.0) (Point 10.0 0.0) false) `shouldEqual` (-pi)

    describe "outboundAngle" do
      it "should produce correct angles for arcs" do
        outboundAngle (Arc (Point 10.0 10.0) (Point 20.0 10.0) (Point 20.0 10.0) true) `shouldEqual` (pi/2.0)
        outboundAngle (Arc (Point 10.0 10.0) (Point 20.0 10.0) (Point 20.0 10.0) false) `shouldEqual` (-pi/2.0)
        outboundAngle (Arc (Point 10.0 10.0) (Point 10.0 20.0) (Point 20.0 10.0) true) `shouldEqual` pi
        outboundAngle (Arc (Point 10.0 10.0) (Point 10.0 20.0) (Point 20.0 10.0) false) `shouldEqual` 0.0

    describe "strokeOrd" do
      it "should sort strokes by 'traverseLeftWall' order" do
        let l1 = Line (Point 10.0 10.0) (Point 20.0 10.0) -- this has a different outboundAngle so should go last
            l2 = Line (Point 10.0 10.0) (Point 20.0 20.0) -- this has curvature 0 so should be between cw and ccw arcs
            a1 = Arc (Point 10.0 20.0) (Point 10.0 10.0) (Point 10.0 10.0) true -- curves away so should be last arc
            a2 = Arc (Point 10.0 0.0) (Point 10.0 10.0) (Point 10.0 10.0) false
            a3 = Arc (Point 10.0 5.0) (Point 10.0 10.0) (Point 10.0 10.0) false -- shorter radius so should be first

        sort ( l2 : l1 : a1 : a2 : a3 : Nil) `shouldEqual` (a3 : a2 : l1 : a1 : l2 : Nil)

    describe "split" do
      it "should split a line, in order" do
        split (Line (Point 0.0 0.0) (Point 1.0 1.0)) ((Point 0.2 0.2) : (Point 0.7 0.7) : (Point 0.5 0.5) : Nil)
          `shouldEqual`
          ( (Line (Point 0.0 0.0) (Point 0.2 0.2))
          : (Line (Point 0.2 0.2) (Point 0.5 0.5))
          : (Line (Point 0.5 0.5) (Point 0.7 0.7))
          : (Line (Point 0.7 0.7) (Point 1.0 1.0))
          : Nil)

      it "should split an arc, in clockwise order" do
        let c = (Point 10.0 10.0)
            p = (Point 20.0 10.0)
            q = (Point 20.0 10.0)
            i1 = (Point 10.0 20.0)
            i2 = (Point 0.0 10.0)
            i3 = (Point 10.0 0.0)

        split (Arc c p q true) (i1 : i2 : i3 : Nil)
          `shouldEqual`
          ( (Arc c p i1 true)
          : (Arc c i1 i2 true)
          : (Arc c i2 i3 true)
          : (Arc c i3 q true)
          : Nil)

    describe "withinBounds" do
       it "90 degree arc point in arc" do
        (withinBounds (Arc (Point 0.0 0.0) (Point 10.0 0.0) (Point 0.0 10.0) true) (Point 5.0 5.0)) `shouldEqual` true
       it "90 degree arc point out of arc" do
        (withinBounds (Arc (Point 0.0 0.0) (Point 10.0 0.0) (Point 0.0 10.0) true) (Point (-5.0) 5.0)) `shouldEqual` false
       it "270 degree arc point out of arc" do
        (withinBounds (Arc (Point 0.0 0.0) (Point 10.0 0.0) (Point 0.0 10.0) false) (Point 5.0 5.0)) `shouldEqual` false
       it "270 degree arc point in arc" do
        (withinBounds (Arc (Point 0.0 0.0) (Point 10.0 0.0) (Point 0.0 10.0) false) (Point (-5.0) 5.0)) `shouldEqual` true
