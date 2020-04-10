;; author: game developer
;; desc:   short description
;; script: fennel

(var t 0)
(var x 96)
(var y 24)

(fn render-plr
  []
  (spr 256 x y))

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
  (render-tile)
  (print "soyorltlaabc")
  (spr 005 x y 3 1 0 2 2)
  (set t (+ t 1))))

