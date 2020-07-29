(setq col 20 row 20)
(setq size 2)

(setq *time-flag* 0)

(vl-load-com)

(defun c:create()

  (setq topRight (strcat (rtos (* col size)) "," (rtos (* row size)) ))
  
  (setq i 0)
  (while (< i col)
	(setq j 0)
    	(while (< j row)
	  
	  (command "_.rectang" (strcat (rtos (* i size)) "," (rtos (* j size))) "_d" (rtos size) (rtos size) topRight "")
	  (command "_.hatch" "solid" (strcat (rtos ( + 0.1 (* i size))) "," (rtos (+ 0.1 (* j size)))) "")

	  (setq j (+ 1 j))
	)  
	(setq i (+ 1 i))
  )  

)


(defun Clear()

  ;Make canvas clear
  (setq canvas (ssget "_x" '((0 . "HATCH"))))
  (command "_.change" canvas "" "_p" "_la" "0" "")

)  



(defun c:Snake()

  ;Clear Board
  (Clear)

  ;Hide game Over
  (command "-layer" "off" "OVER" "")

  ;Init vars
  (setq speed 200)
  (setq mouse (cadr (grread T)))
  (setq timeSinceMoved 0)
  (setq gameover nil)

  (setq body (list '(2 4) '(3 4) '(3 5) '(3 6) ))
  (setq apple (GetApple body))

  ;Draw Initial Apple
  (DrawApple apple)
  
  
  ;Draw initial body
  (setq i 0)
  (while (< i (length body))

    	(setq cell (nth i body))

    	(setq x (car cell))
    	(setq y (cadr cell))

    	(setq loc (list (+ 1 (* size x)) (+ 1 (* size y))))
  	(setq locOffset (list (+ 0.1 (car loc)) (+ 0.1 (cadr loc)) ))
  	(setq cell (ssget "_C" loc locOffset '((0 . "HATCH"))))
  	(command "_.change" cell "" "_p" "_la" "P" "")

    	(setq i (+ 1 i))
  )

  ;Main Loop - while not on end button
  (while (= gameover nil)

    	(setq mouse (cadr (grread T)))
    	(setq headAsCoords (list (+ 1 (* size (car (last body)))) (+ 1 (* size (cadr (last body))))))
    
    	(setq direction (GetDirection headAsCoords mouse))
    	(setq dirX (car direction))
    	(setq dirY (cadr direction))

    	(setq timeSinceMoved (+ timeSinceMoved (timer)))

    	(cond ( (> timeSinceMoved speed)

	       	;Reset Time
		(setq timeSinceMoved 0)	
	
    		;Add new point
    		(setq body (append body (list (list (+ dirX (car (last body))) (+ dirY (cadr (last body))) ) )))

	       	;Draw New Point
    		(setq loc (list (+ 1 (* size (car (last body)))) (+ 1 (* size (cadr (last body))))))
  		(setq locOffset (list (+ 0.1 (car loc)) (+ 0.1 (cadr loc)) ))
  		(setq cell (ssget "_C" loc locOffset '((0 . "HATCH"))))
  		(command "_.change" cell "" "_p" "_la" "P" "")

	       	;If not eating
	       	(cond ( (not (and (= (car (last body)) (car apple)) (= (cadr (last body)) (cadr apple))))
	       
	       		;Draw tail white
			(setq loc (list (+ 1 (* size (car (car body)))) (+ 1 (* size (cadr (car body))))))
  			(setq locOffset (list (+ 0.1 (car loc)) (+ 0.1 (cadr loc)) ))
  			(setq cell (ssget "_C" loc locOffset '((0 . "HATCH"))))
  			(command "_.change" cell "" "_p" "_la" "0" "")
	       
	       		;Remove Tail
	       		(setq body (LM:RemoveNth 0 body))

		)

		;when eating
		( t

		 	;Get valid apple
		 	(setq apple (GetApple body))

  			;Draw apple
  			(DrawApple apple)
		
			
		)      

		)

	       	;End game if overlap or out of bounds
	       	(if (or (not (LM:Unique-p body))(> (car (last body)) (- col 1)) (> (cadr (last body)) (- row 1)) (< (car (last body)) 0) (< (cadr (last body)) 0)) (setq gameover t))
	       	
	   )
	)

    
  )


  ;Display Game Over
  (command "-layer" "on" "OVER" "")
  
)

(defun DrawApple(pos)

  	(setq loc (list (+ 1 (* size (car pos))) (+ 1 (* size (cadr pos)))))
  	(setq locOffset (list (+ 0.1 (car loc)) (+ 0.1 (cadr loc)) ))
  	(setq cell (ssget "_C" loc locOffset '((0 . "HATCH"))))
  	(command "_.change" cell "" "_p" "_la" "A" "")

)

(defun GetApple(body)

  	(setq validLoop nil)

  	(while (= validLoop nil)

	  	(setq validLoop t)
	  	(setq a (list (LM:randrange 0 (- col 1)) (LM:randrange 0 (- row 1))) )
	  
		(setq b 0)
  		(while (< b (length body))

	  		(cond
			(	(and (= (car a) (car (nth b body)) ) (= (cadr a) (cadr (nth b body)) ) )
			 	(setq validLoop nil))
			)

	  		(setq b (+ 1 b))
		)

	)

  	a
  
)  

(defun GetDirection(Ref Mouse)
  
  	(setq ang (RtD (atan (- (cadr Mouse) (cadr Ref))	(- (car Mouse) (car Ref))	)) )
  	
    	(cond
	((and (>= ang 45) (<= ang 135))		(list 0 1))  ;Up
	((and (>= ang -45) (<= ang 45))		(list 1 0))  ;Right
	((and (>= ang -135) (<= ang -45))	(list 0 -1)) ;Down
	((or (>= ang 135) (<= ang -135))	(list -1 0)) ; Left
	)  

)  

;;----------------------=={ Remove Nth }==--------------------;;
;;                                                            ;;
;;  Removes the item at the nth index in a supplied list      ;;
;;------------------------------------------------------------;;
;;  Author: Lee Mac, Copyright © 2011 - www.lee-mac.com       ;;
;;------------------------------------------------------------;;
;;  Arguments:                                                ;;
;;  n - index of item to remove (zero based)                  ;;
;;  l - list from which item is to be removed                 ;;
;;------------------------------------------------------------;;
;;  Returns:  List with item at index n removed               ;;
;;------------------------------------------------------------;;

(defun LM:RemoveNth ( n l )
    (if (and l (< 0 n))
        (cons (car l) (LM:RemoveNth (1- n) (cdr l)))
        (cdr l)
    )
)

;; Unique-p  -  Lee Mac
;; Returns T if the supplied list contains distinct items.

(defun LM:Unique-p ( l )
    (or (null l)
        (and (not (member (car l) (cdr l)))
             (LM:Unique-p (cdr l))
        )
    )
)

; Stores the current time when called, and then returns
; the time difference when called the next time. Time
; difference is returned in milliseconds.
; Usage: (timer)
(defun timer ( / dt)

      ; Calculates and returns the time difference
      (setq dt (- (getvar "MILLISECS") *time-flag*) *time-flag* (getvar "MILLISECS"))
      dt
    
  
)

;; Rand  -  Lee Mac
;; PRNG implementing a linear congruential generator with
;; parameters derived from the book 'Numerical Recipes'

(defun LM:rand ( / a c m )
    (setq m   4294967296.0
          a   1664525.0
          c   1013904223.0
          $xn (rem (+ c (* a (cond ($xn) ((getvar 'date))))) m)
    )
    (/ $xn m)
)

;; Random in Range  -  Lee Mac
;; Returns a pseudo-random integral number in a given range (inclusive)

(defun LM:randrange ( a b )
    (+ (min a b) (fix (* (LM:rand) (1+ (abs (- a b))))))
)



;Special Print func
(defun prin(content)

  (princ (strcat content "\n"))

)

;Angle Conversion
(defun RtD (r) (* 180.0 (/ r pi)))