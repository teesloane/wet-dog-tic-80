;; author: tees
;; desc:   Wet Dog.
;; script: fennel

;; notes
;; env = environment
;; lvl = level
;; PLR = player
;; DOG = Poor ol' pup

;; debug
(var DBG [])
(fn add-print [s]
  "add item to the debug list"
  (table.insert DBG s))

(fn ppp
  []
  (when (> (length DBG) 0)
    (each [i val (ipairs DBG)]
          (print val 5 (* 10 i) 3)))
  (set DBG []))

(var t 0)

;; -- &s: CONSTS --

(var JUMP-SEQ [-3 -3 -3 -3 -2 -2 -2 -2  -1 -1 0 0 0 0 0])
(var GRAVITY 1)
(var DISP-W 240)
(var DISP-H 136)
(var RAIN [])
(var CAM {:x 120 :y 68})
(var PLR {:jumping  false
          :x       10
          :y       30
          :vx       0
          :vy       0
          :rot      0
          :spr      256
          :grounded false
          :um-open  false
          :jump-idx 0})

(var LVL {:complete false
          :seg 0})
(fn slv [p v] (tset LVL p v))

(var DOG {:covered false
          :spr     352
          :spr-cnt 0
          :x       210
          :y       120})

;; -- &s: HELPERS --

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


;; -- &s: LVL --

(fn lvl-doall
  []
  (when LVL.complete
    (print "level complete" 25 25 3)))

;; -- &s: PLR --

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
    (spr PLR.spr x y 0 1 0 rot)))

(fn plr-doall
  []
  (plr-umbrella)
  (plr-render)
  (plr-move))


;; -- &s: DOG --
(fn dog-covered? []
  (and
   PLR.um-open
   (or
    (and (= (// (+ 2 PLR.x) 8) (// (+ 2 DOG.x) 8))
         (= (//  PLR.y 8) (// DOG.y 8)))

    (and (= (// (-  PLR.x 2) 8) (// (- DOG.x 2) 8))
         (= (//  PLR.y 8) (// DOG.y 8)))

    (and (= (// PLR.x 8) (// DOG.x 8))
         (= (// PLR.y 8) (// DOG.y 8))))))

(fn dog-render
  []
  "Draw the dog."
  (let [{ : x : y : rot } DOG
        dog-animation-speed 0.1
        dog-spr (if (% t 8))
        inc-spr (and (> (math.random 0 10) 7) (> DOG.spr-cnt 5))]
    (when inc-spr
      (tset DOG :spr (+ 1 DOG.spr))
      (tset DOG :spr-cnt 0)
      (when (= DOG.spr 362) (tset DOG :spr 352)))
    (tset DOG :spr-cnt (+ DOG.spr-cnt dog-animation-speed))
    (spr DOG.spr x y 0 1 0 rot)

    (when (dog-covered?) (slv :complete true))))

;; -- &s: ENV --

;; Rain --

(fn env-rain-new []
  (let [rnd-x-s (math.random 0 DISP-W)
        rnd-y-s (- (math.random 0 DISP-H) DISP-H)
        rnd-y-e (+ 3 (math.random 0 5) rnd-y-s)]
    {:x1 rnd-x-s :x2 rnd-x-s :y1 rnd-y-s :y2 rnd-y-e}))

(fn env-rain-touching-plr? [x y]
  "Check if vals at x and y are touching the player."
  (and
   (= (// x 8) (// (+ PLR.x 1) 8))
   (= (// y 8) (// PLR.y 8))))

(fn env-rain-init []
  "sets up rain before game loop."
  (set RAIN [])
  (for [i 1 800]
    (let [make-rain? (> (math.random 0 1) -1)
          rnd-y-s    (math.random 0 136)]
      (when make-rain?
        (table.insert RAIN (env-rain-new))))))

(fn env-rain-rndr []
  (for [i 1 (length RAIN)]
    (let [{: x1 : x2 : y1 : y2} (. RAIN i)]
      (line x1 y1 x2 y2 9))))

(fn env-rain-gen
  [x1 x2 y1 y2 new-y1 new-y2]
  "Checks if rain is colliding / needs to be regen'd"
  (if (> new-y2 DISP-H) ;; if rain goes past display height
    (env-rain-new 0)
    (if (or (is-solid? x2 (+ y2 1))
            (env-rain-touching-plr? x2 y2)) ;;
      (if (not (= y2 new-y1)) ;; top of drop hasn't caught up to bottom.
        {:x1 x1 :x2 x2 :y1 new-y1 :y2 y2}
        (env-rain-new 0))
      {:x1 x1 :x2 x2 :y1 new-y1 :y2 new-y2})))

(fn env-rain-update []
  (for [i 1 (length RAIN)]
    (let [{: x1 : x2 : y1 : y2} (. RAIN i)
          new-y1                (+ y1 1)
          new-y2                (+ y2 1)
          new-rain-data         (env-rain-gen x1 x2 y1 y2 new-y1 new-y2)]
      (tset RAIN i new-rain-data))))

(fn env-doall
  []
  (env-rain-rndr)
  (env-rain-update))

;; Tiles --

(fn lerp [a b t]
  (+ (* a (- 1 t))
     (* t b)))

(fn render-tile
  []
  ;; Attempt camea
  ;; (tset CAM :x
  ;;       (math.min 120 (lerp CAM.x (- 120 PLR.x) 0.05)))
  ;; (tset CAM :y
  ;;       (math.min 64 (lerp CAM.y (- 64 PLR.y) 0.05)))
  ;; (let [ccx (/ CAM.x (+ 8 1))
  ;;       ccy (/ CAM.y (+ 8 1))]
  ;;   (map (- 15 ccx) (- 8 ccy) (- (% CAM.x 8) 8) (- (% CAM.y 8) 8) 0))
  (map 0 0 30 17))

;; -- KICK IT OFF 👞 👢 👟

(env-rain-init)
(global TIC
        (fn tic []
          (cls 0)
          (render-tile)
          (lvl-doall)
          (env-doall) ; perf
          (dog-render)
          (plr-doall)
          (ppp)
          (set t (+ t 1))))
