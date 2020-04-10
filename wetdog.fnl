;; author: tees
;; desc:   Wet Dog.
;; script: fennel

(var t 0)
(var x 96)
(var y 24)

(fn plr-move
  []
  (when (btn 0) (set y (- y 1)))
  (when (btn 1) (set y (+ y 1)))
  (when (btn 2) (set x (- x 1)))
  (when (btn 3) (set x (+ x 1))))


(fn plr-render
  []
  (let [rot 0]
    (spr 256 x y -1 1 0 rot)))

(fn render-tile
  []
  (map 0 0 30 17))

(global TIC
 (fn tic []
  (plr-move)
  (cls 0)
  (render-tile)
  ;; rendering sprite.
  (plr-render)
  (set t (+ t 1))))
