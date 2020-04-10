;; author: tees
;; desc:   Wet Dog.
;; script: fennel

(var t 0)
(var x 96)
(var y 24)

;; -- STATE: - game and player.

(var GAME {})


(var PLR {:jumping false
          :x       96
          :y       24
          :rot     0})


;; -- FUNCS: - game and player

(fn plr-move
  []
  (let [{:x prev-x :y prev-y :rot prev-rot} PLR]
    (when (btn 0) (tset PLR :y (- prev-y 1)))
    (when (btn 1) (tset PLR :y (+ prev-y 1)))
    (when (btn 2) (tset PLR :x (- prev-x 1)))
    (when (btn 3) (tset PLR :x (+ prev-x 1)))))


(fn plr-render
  []
  (let [{ : x : y : rot } PLR]
    (spr 256 x y -1 1 0 rot)))


(fn render-tile
  []
  (map 0 0 30 17))


;; -- MISC.


;; -- KICK IT OFF 👞 👢 👟

(global TIC
 (fn tic []
  (cls 0)
  (render-tile)
  ;; rendering sprite.
  (plr-render)
  (plr-move)
  (set t (+ t 1))))
