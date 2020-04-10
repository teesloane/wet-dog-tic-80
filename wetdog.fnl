;; author: game developer
;; desc:   short description
;; script: fennel

(var t 0)
(var x 96)
(var y 24)

(fn render-plr
  []
  (let [rot 0]
    (spr 256 x y -1 1 0 rot)))

(fn render-tile
  []
  (map 0 0 30 17))

(global TIC
 (fn tic []
  (when (btn 0) (set y (- y 1)))
  (when (btn 1) (set y (+ y 1)))
  (when (btn 2) (set x (- x 1)))
  (when (btn 3) (set x (+ x 1)))
  (cls 0)
  ;; background renders
  ;; (render-tile)
  (render-plr)
  ;; rendering sprite.
  (set t (+ t 1))))
