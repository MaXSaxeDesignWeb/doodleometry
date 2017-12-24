module Mouse where

import Prelude

import App.Geometry (Point(..))
import Control.Monad.Eff (Eff)
import Control.Monad.Except (runExcept)
import DOM (DOM)
import DOM.Event.EventTarget (addEventListener, eventListener)
import DOM.Event.MouseEvent (clientX, clientY, eventToMouseEvent)
import DOM.HTML.Event.EventTypes (mousedown, mousemove, mouseup)
import DOM.HTML.Types (Window, windowToEventTarget)
import Data.Either (Either(Right, Left))
import Data.Int (toNumber)
import Signal (Signal)
import Signal.Channel (CHANNEL, channel, send, subscribe)

data MouseData = MouseUp Point | MouseDown Point | MouseMove Point

-- | Returns a signal that fires off MouseData on window
sampleMouse :: forall eff. Window -> Eff (channel :: CHANNEL, dom :: DOM | eff) (Signal MouseData)
sampleMouse win = do
  chan <- channel $ MouseMove (Point 0.0 0.0)
  let listener constructor = eventListener \evt ->
       let res = do
            mouseEv <- runExcept $ eventToMouseEvent evt
            let x = toNumber $ clientX mouseEv
            let y = toNumber $ clientY mouseEv
            pure $ Point x y
       in case res of (Left _) -> pure unit
                      (Right pt) -> send chan (constructor pt)

  addEventListener mousedown (listener MouseDown) false (windowToEventTarget win)
  addEventListener mouseup (listener MouseUp) false (windowToEventTarget win)
  addEventListener mousemove (listener MouseMove) false (windowToEventTarget win)
  pure $ subscribe chan
