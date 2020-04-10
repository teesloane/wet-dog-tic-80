;; author: tees
;; desc:   Wet Dog.
;; script: fennel

(fn get-flag
  [spr-id flag]
  "Inlines lua to fetch if a flag is on for a sprite"
  (let [lam (lua "print('')" "function (sprID, bit) return peek(0x14400+sprID)>>bit&1==1 end")]
    (lam spr-id flag)))


(var PLR {:jumping false
          :x       120
          :y       10
          :rot     0})


;; -- FUNCS: - game and player

(fn plr-move
  []
  (let [{:x prev-x :y prev-y :rot prev-rot} PLR]
    (when (btn 0) (tset PLR :y (- prev-y 1)))
    (when (btn 1) (tset PLR :y (+ prev-y 1)))
    (when (btn 2) (tset PLR :x (- prev-x 1)))
    (when (btn 3) (tset PLR :x (+ prev-x 1)))))

(fn can-move [x y cr]
  "Determines if a thing can move."
  (let [x1 (+ x cr.x)
        y1 (+ y cr.y)
        x2 (+ x1 (- cr.w 1))
        y2 (+ y1 (- cr.y 1))]
    nil))


(fn can-move-naive
  []
  (print (get-flag 1 7))
  (let [{: y} PLR]
    (tset PLR :y (+ y 1))))


(fn plr-render
  []
  (let [{ : x : y : rot } PLR]
    (spr 256 x y -1 1 0 rot)))

(fn plr-doall
  []
  (can-move 10 20 {"x" 3 "y" 1 "w" 20 "h" 20})
  (can-move-naive)
  (plr-render)
  (plr-move))

(fn render-tile
  []
  (map 0 0 30 17))


;; -- MISC.


;; -- KICK IT OFF 👞 👢 👟

(global TIC
 (fn tic []
  (cls 0)
  (render-tile)
  (plr-doall)))
  ;; (set t (+ t 1))))
