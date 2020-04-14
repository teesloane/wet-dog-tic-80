;; author: tees
;; desc:   Wet Dog.
;; script: fennel

;; debug
(var DBG [])
(fn pp [s]
  "add item to the debug list"
  (table.insert DBG s))

(fn ppp
  []
  (when (> (length DBG) 0)
    (each [i val (ipairs DBG)]
          (print val 0 (* 10 i))))
  (set DBG []))


;; CONSTS

(var JUMP-SEQ [-3 -3 -3 -3 -2 -2 -2 -2  -1 -1 0 0 0 0 0])
(var GRAVITY 1)
(var PLR {:jumping  false
          :x        79
          :y        85
          :vx       0
          :vy       0
          :rot      0
          :spr      256
          :grounded false
          :um-open  false
          :jump-idx 0})


;; Helpers
(fn get-flag
  [spr-id flag]
  "Inlines lua to fetch if a flag is on for a sprite HACK HACK HACK"
  (let [lam (lua "print('')" "function (sprID, bit) return peek(0x14400+sprID)>>bit&1==1 end")]
    (lam spr-id flag)))

(fn spr-solid? [spr-id]
  (get-flag spr-id 0))

(fn is-solid? [x y]
  "Takes an entity with an x/y position and checks if the things around it are solid."
  (let [map-item  (mget (// x 8) (// y 8))]
    (spr-solid? map-item)))

(fn map-check [x y]
  (mset (// x 8) (// y 8) 4))

;; -- Player Fns.

(fn spv [p v]
  "Sets a players velocity for prop p with val v"
  (tset PLR p v))

(fn set-plr-pos []
  (tset PLR :x (+ PLR.x PLR.vx))
  (tset PLR :y (+ PLR.y PLR.vy)))

(fn plr-umbrella []
  "Toggles umbrella / gravity"
  (when (btnp 5)
    (if PLR.um-open
      (do
        (spv :um-open false)
        (set GRAVITY 1)
        (spv :spr 256))
      (do
        (spv :um-open true)
        (set GRAVITY 0.25)
        (spv :spr 257)))))


(fn plr-jump []
  "move player through JUMP-DY seq, if they can move."
  (when (or (btn 0))
    (spv :grounded false)
    (let [incd-j-idx    (+ 1 PLR.jump-idx)
          next-jump-val (. JUMP-SEQ incd-j-idx)] ; could be nil.
      (when (not (= nil next-jump-val))
        (spv :jump-idx incd-j-idx)
        (spv :vy next-jump-val)))))

(fn plr-move
  []
  "Handles movement, collision and jumping."
  (let [{: x : y : rot } PLR]
    ;; General movement.
    (when (btn 1) (spv :vy 1))
    (when (btn 2) (spv :vx -1))
    (when (btn 3) (spv :vx 1))

    ;; X collisions.
    (when (or (is-solid? (+ x PLR.vx)   (+ y PLR.vy))
              (is-solid? (+ x 7 PLR.vx) (+ y PLR.vy))
              (is-solid? (+ x 8 PLR.vx) (+ y PLR.vy))
              (is-solid? (+ x PLR.vx)   (+ y 7 PLR.vy))
              (is-solid? (+ x 7 PLR.vx) (+ y 7 PLR.vy)))
      (spv :vx 0))

    ;; Y collisions
    (when (or (is-solid? (+ x PLR.vx) (+ y PLR.vy 8))
              (is-solid? (+ x 8) y)
              (is-solid? (+ x PLR.vx 7) (+ y 8 PLR.vy)))

      (spv :grounded true)
      (spv :jump-idx 0)
      (spv :vy 0))

    ;; Gravity
    (if (or (is-solid? (+ x PLR.vx) (+ y 8 PLR.vy))
            (is-solid? (+ x 7 PLR.vx) (+ y 8 PLR.vy)))
      (spv :vy 0)
      (spv :vy (+ PLR.vy GRAVITY)))

    ;; Jumping
    (plr-jump)
    ;; set the pos, and then reset the velocity.
    (set-plr-pos)
    (spv :vx 0) (spv :vy 0)))

(fn plr-render
  []
  "Responsible for actually painting the player to screen"
  (let [{ : x : y : rot } PLR]
    (spr PLR.spr x y -1 1 0 rot)))

(fn plr-doall
  []
  (plr-umbrella)
  (plr-render)
  (plr-move))

(fn render-tile
  []
  (map 0 0 30 17))

;; -- KICK IT OFF 👞 👢 👟

(global TIC
 (fn tic []
  (cls 0)
  (render-tile)
  (plr-doall)
  (ppp)))
  ;; (set t (+ t 1))))
