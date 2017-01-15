module Test.Geometry where

import Prelude
import App.Geometry
import Data.List (List(..), (:))
import Math (pi)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)

spec = do
  describe "App.Geometry" do
    describe "Arc" do
      it "should be constructed correctly" do
        (constructArc (Point 1.0 1.0) (Point 2.0 1.0)) `shouldEqual` Arc (Point 1.0 1.0) 1.0 0.0 (2.0 * pi)
        (constructArc (Point 1.0 1.0) (Point 1.0 2.0)) `shouldEqual` Arc (Point 1.0 1.0) 1.0 (pi / 2.0) (2.0 * pi)

      it "should report back firstPoint correctly" do
        firstPoint (Arc (Point 1.0 1.0) 1.0 0.0 (2.0 * pi)) `shouldEqual` Point 2.0 1.0
        firstPoint (Arc (Point 1.0 1.0) 1.0 (pi / 2.0) (2.0 * pi)) `shouldEqual` Point 1.0 2.0
        firstPoint (Arc (Point 1.0 1.0) 1.0 (-pi / 2.0) (2.0 * pi)) `shouldEqual` Point 1.0 0.0
        firstPoint (Arc (Point 1.0 1.0) 1.0 pi (2.0 * pi)) `shouldEqual` Point 0.0 1.0

        (firstPoint $ constructArc (Point 10.0 10.0) (Point 20.0 20.0))
          `shouldEqual` Point 20.0 20.0

      it "should report back secondPoint correctly" do
        (secondPoint $ constructArc (Point 10.0 10.0) (Point 20.0 20.0))
          `shouldEqual` Point 20.0 20.0

        secondPoint (Arc (Point 1.0 1.0) 1.0 pi pi) `shouldEqual` Point 2.0 1.0

    describe "intersect" do
      it "should find an intersection point" do
        intersect (Line (Point 0.0 0.0) (Point 1.0 1.0)) (Line (Point 0.0 1.0) (Point 1.0 0.0))
          `shouldEqual` ((Point 0.5 0.5) : Nil)

      it "should not find an intersection point for parallel lines" do
        intersect (Line (Point 0.0 0.0) (Point 0.0 1.0)) (Line (Point 1.0 0.0) (Point 1.0 1.0))
          `shouldEqual` Nil

    describe "split" do
      it "should split a line, in order" do
        split (Line (Point 0.0 0.0) (Point 1.0 1.0)) ((Point 0.2 0.2) : (Point 0.7 0.7) : (Point 0.5 0.5) : Nil)
          `shouldEqual`
          ( (Line (Point 0.0 0.0) (Point 0.2 0.2))
          : (Line (Point 0.2 0.2) (Point 0.5 0.5))
          : (Line (Point 0.5 0.5) (Point 0.7 0.7))
          : (Line (Point 0.7 0.7) (Point 1.0 1.0))
          : Nil)
