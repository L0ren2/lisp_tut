; Du kommst einfach nicht dahinter, wie LISP funktioniert aber du interessierst dich aus irgendeinem Grund dafür?
; Hier gibts einige kleine Goodies, die dich in die Lage versetzen, lisp besser zu lernen. Unten gibt es ein paar gute Lernquellen.
; Die restliche Datei ist einfach dazu da, Anfängern ein bisschen unter die Arme zu greifen.
; Viel Spaß.


;;; Falls nicht schon bekannt, LISP steht für "List processing language" weil die häufigste Datenstruktur die Liste ist.
(list 1 2 3)
;(1 2 3)

; Zahlen evaluieren zu sich selbst.
4
;4

; Brüche werden gekürzt aber nicht als Dezimalbruch dargestellt.
(/ 4 6); Präfixnotation, keine Infixnotation (also (/ 2 3) statt  (2 / 3))
;2/3

2 / 3 ; bei Brüchen klappt auch Infix 
;2/3

;;; Processing von listen: von links nach rechts, das 0-te Element wird aber als letztes evaluiert
(+ 1 2 3) ; Erst evaluiert die 1 zu sich selbst, dann die 2, dann die 3 und dann wird die + funktion mit 1,2 und 3 als Argumente aufgerufen.
;6

#|
  Dies ist ein mehrzeiliger Kommentar.
  #|
    Mehrzeiliger Kommentar kann genestet werden, KP wofür das gut sein soll, aber there you go.
  |#
  ; Kombination mit einzeiligen Kommentaren ist möglich.
|#


;;; Es gibt viele verschiedene Wege, Variablen anzulegen. Wir erstellen eine dummy Funktion, damit die Variablen nicht das globale scope zumüllen:
(defun dummy-vars ()
  (defconstant my-const 42) ; Erstellt eine Konstante; Konstanten können nicht geändert werden.

  (defvar my-var 69) ; Bindet die Variable my-var an den Wert 69.
  (defparameter my-var2 420) ; Bindet den "Parameter" an den Wert 420.

  (setq my-var3 3.14) ; Bindet die Variable my-var3 an den Wert 3.14.
  (setf my-var4 42) ; Bindet ... whatever you get it

  (let ((a 1337)) ; let ist interessant: es erstellt ein Scope, in dem a gültig ist.
    (+ a 1) ; Hier kommt 1338 raus.
  ) ; Ab hier ist a nicht mehr zugrifbar.

  (let ((a 1) (b 2)) ; Mit let lassen sich Variablen auch weniger anstrengend erstellen: es sind mehrere möglich.
    (+ a b)
  )

  (let* ((a 1) (b 2) (c (+ a b))) ; Mit let* (Ja die haben das echt so genannt :p) ist es möglich, in der Zuweisungsliste die definierten Variablen
    (+ a b c)                     ; zum definieren anderer Variablen zu nutzen. MIT let GEHT DAS NICHT.
  ) ; hier wird 6 evaluiert        ; außerdem machen die Klammern das ganze recht schnell unschön. Am besten einfach Klammern beim lesen weitestgehend ignorieren.


  ;;; defvar und defparameter haben kleine unterschiede:
  (defvar a 10) ; defvar erzeugt hier eine Variable.
  ;A
  a
  ;10
  (defvar a 42) ; defvar kann eine Variable nicht überschreiben.
  ;A
  a
  ;10

  (defparameter b 10) ; defparameter weist 10 zu b.
  ;B
  b
  ;10
  (defparameter b 20) ; defparameter weist 20 zu b.
  ;B
  b
  ;20

  ;;; setq und setf haben auch kleine Unterschiede. Welche das sind, kann hier
  ;;; https://stackoverflow.com/questions/869529/difference-between-set-setq-and-setf-in-common-lisp
  ;;; nachgelesen werden. Prinzipiell kann immer setf verwendet werden, vergiss also einfach, dass es setq gibt, wenn du selber lisp programmierst.
)


#|
  Wenn du das liest, solltest du eine Pause machen, das war jetzt schon recht viel Zeug. 
  Am besten liest du das alles nochmal nach, wenn es dir zu viel auf einmal war.


  Bis jetzt haben wir uns nicht an Konventionen gehalten. Das ist schlecht. Wir ändern das nun:

  Globale Variablen haben spezielle Namen, damit man direkt sieht, dass sie global sind:
  *globale-var*: die * zeigen, dass das Ding echt special ist, globale vars haben ein großes fuck-up potential.

  Konstanten haben eine ähnliche form: +const-var+

  Klammern werden nicht wie bisher organisiert (nicht so wie in anderen Sprachen normalerweise, mehr im nächsten bsp)
|#

;;; Klammern Organisation
(defun some-function (param-A param-B)
  (let ((c 4))
    (+ param-A param-B c)))
; Ende der Funktion
; Die schließenden Klammern werden hinten angestaut, die interessieren eh niemand. Die Funktionen werden dann entsprechend eingerückt, wie in Python.
; Nur dass es nicht verpflichtend ist...    lisp ist eigentlich Python nur mit Klammern xD.

;;; Das wars auch schon mit Konventionen. Machen wir weiter mit call-by-value:

;;; Es gibt nur Call-By-Value.
(defvar *a* 42)
;*a*
*a*
;42
(defun ch (a) 
  (defvar a 69))
;CH
(ch *a*)
;69
*a*
;42


;;; Let überschreibt nur innerhalb der Funktion (man nennt das überdecken oder overshadowing)
*a*
;42
(defun fun () ; Anstatt einer leeren Parameterliste kann auch nil geschrieben werden.
  (let ((*a* 69) (b 42)) 
    (+ *a* b)))
;111
*a*
;42


;;; setf kann defvar-deklarierte und defparameter-deklarierte variablen überschreiben, das ist aber nur von dauer, wenn in globalem scope
(setf *a* 69)
;69
*a*
;69
(setf *a* 42)
;42
*a*
;42


;;; quote verhindert die evaluierung eines symbols, einer liste, etc
(quote *a*)
;*a*
*a*
;42
(quote (list a b c))
;(LIST A B C)


;;; quote braucht man so oft, dass es eine einfachere syntax gibt: '*a* , es sind keine klammern nötig
'*a*
;*a*

;;; sei vorsichtig: quote verletzt die standardevaluierungsregeln von lisp: die eval regeln sind wie weiter oben genannt:
;;; von links nach rechts, das 0-te element aber als letztes
(quote *a*) ;kann mit den normalen regeln nie zu *a* auswerten, da *a* selbst ja zuerst mal zu 42 evaluiert werden würde.
;;; wenn dann die quote funktion darauf angewandt würde, würde das ja das gleiche sein wie '42, da kommt aber 42 raus.
;;; quote ist eine sogenannte "special-form", d.h. es ist quasi eine funktion aber sie darf von den standard regeln abweichen.


#|
  kommen wir nun zu brauchbaren teilen der sprache bzw. der programmierung.
  da du nun die meisten regeln kennst, können wir jetzt den richtig krassen shit machen.
|#

; mit defun kannst du funktionen definieren. die verhalten sich so wie die funktionen in den meisten anderen programmiersprachen.
(defun fun-2 nil nil)

; lisp hat etwa 800 vordefinierte funktionen, viele davon sind sehr nützlich, alle kannst du selber implementieren.
; viele der bereits definierten lisp funktionen werden aber schneller sein, als deine eigenen, da diese schon gut optimiert sind.

; eine der wichtigen funktionen ist map. in lisp heißt map mapcar. mapcar nimmt als parameter eine funktion und eine liste 
; und returned eine neue liste, in der alle elemente der alten liste drin sind, aber die funktion wurde auf jedes der parameter angewandt.

(defun quadriere (x) (* x x)) ; das hier sollte mittlerweile sinn machen :)
(mapcar (function quadriere) (quote (1 2 3)))
;(1 4 9)

; mit function kannst du eine funktion als parameter übergeben. function ist ähnlich wie quote, 
; es gibt die tatsächliche funktion mit rein, ohne die funktion selbst auszuwerten. 

; weil es immer so anstrengend ist, function zu schreiben, gibt es auch hier eine short version: #'
; man kann mapcar also auch so aufrufen:
(mapcar #'quadriere '(1 2 3))
;(1 4 9)

#|
  an dieser stelle kannst du wieder eine pause einlegen, du solltest aber unbedingt "mapcar", "function", "#'", "quote" und "'" verstanden haben.
  wenn das alles noch nicht so wirklich sinn macht, lies dir einfach den letzten abschnitt hier nochmal durch.
|#

;;; "warum heißt mapcar nicht einfach map" könntest du dich fragen. schließlich müsstest du nur die hälfte der buchstaben tippen, wenn es nur map hieße.
; es hat tatsächlich einen grund, dass es nicht nur map heißt. listen sind aus sogenannten cons-zellen aufgebaut. zu cons zellen gibts gratis ne funktion dazu.
; diese funktion heißt cons. mit cons kannst du eine cons-zelle bilden. als parameter gibst du der cons funktion einfach 2 dinge: den "car" und den "cdr" (wird cudar gesprochen)
; car bezeichnet das erste element der cons zelle , cdr den rest (nicht das 2. element sondern den rest :O)
; mit cons zellen kannst du listen bilden.
;
; cons zelle     cons zelle 2    nil
; +----+----+    +----+----+
; | 69 |  ------>| 42 |  -------> nil
; +----+----+    +----+----+
;  car  cdr       car  cdr
;
; dafür kennst du schon eine kurzschreibweise:
(list 69 42)
;(69 42)
;
; du kannst list immer auch durch cons ersetzen:
(cons 69 (cons 42 nil))
;(69 42)
;
; car und cdr heißen aus historischen gründen so. ich gehe nicht weiter darauf ein.
; wenn der cdr einer cons zelle nicht auf den car einer anderen cons zelle oder auf nil zeigt, sondern z.b. auf eine weitere zahl, dann sieht das so aus:
; cons zelle  
; +----+----+ 
; | 69 | 42 |
; +----+----+ 
;  car  cdr
; um das exakt darzustellen, hat lisp nochmal eine extra syntax:
(cons 69 42)
;(69 . 42) ; wird dottet-pair genannt
;
; um wieder auf den anfang des blocks zurückzukommen, mapcar heißt mapcar, weil es map ist und aus der liste alle cars nimmt.
;
; du bist nicht gezwungen, car und cdr zu nutzen, es gibt die deutlich modernere schreibweise first und rest.
#|
  du kennst nun:
  - syntax von lisp
  - funktionen
  - listen und cons-zellen
  - mapcar (eine funktion höherer ordnung)
|#

;;; wir machen an dieser stelle weiter mit mehr funktionen höherer ordnung und warum die dinger höherer ordnung sind.
(reduce #'+ '(1 2 3 4))
;10
;fällt dir auf, was diese funktion macht? versuch erst zu erraten was hier geschieht.








































;;; die funktion reduce nimmt wieder eine funktion und eine liste und wendet dann die funktion auf alle elemente der liste an. also im prinzip wie mapcar.
; der unterschied ist aber dass mapcar mit sogenannten unären funktionen arbeitet und reduce mit binären, d.h. die funktion die du mapcar füttern kannst, muss auf
; einem einzelnen element operieren, während reduce auch mit + klar kommt. + braucht mindestens 2 args, sonst macht es keinen sinn.
; was reduce intern macht ist: es hat eine variable intern. dann nimmt es das erste car aus der liste und benutzt die funktion die du reduce gegeben hast.
; als argumente für die funktion nimmt reduce einfach die interne variable und das car und das ergebnis wird in der internen variablen gespeichert.
; als nächstes nimmt reduce das 2. car aus der liste und nutzt wieder die funktion etc.
; somit wird aus (reduce #'+ '(1 2 3 4)) dann 1 + 2 + 3 + 4 = 10

; map und reduce sind sehr häufig nutzbare konzepte, die du in vielen algorithmen anwenden kannst.
; so kannst du etwa 70% der algorithmen der standard library in c++ (Stand 2020) mit reduce implementieren. das ist kein scherz.
;
; aber warum heißten map und reduce funktionen höherer ordnung?
; weil sie funktionen als parameter nehmen und sich die eigene funktionalität je nach gegebener funktion massiv unterscheidet.
#|
  du weißt nun auch, was genau funktionen höherer ordnung sind.
  und wie man sie verwendet.
  als nächstes kannst du versuchen, dir einige eigene funktionen höherer ordnung selbst auszudenken.
  das ist eine super übung.
|#


; Bleiben wir noch mal eben bei Funktionen. Hier hast du eine typische Funktion, welche ein gutes Beispiel für die Optimierungen von Compilern
; bietet. Die Funktion ist die Fakultätsfunktion, die Fakultät von 5 ist 5 * 4 * 3 * 2 * 1 = 120. Die Fakultät von 4 ist 4*3*2*1=24
; Fakultätsrechnen ist in vielen Bereichen der Mathematik gar nicht wegzudenken. Die typische Schreibweise ist 5!.
; Kommt dir bekannt vor? Hier ist die Funktion:
(defun fakulty (n)
	(if (< n 2)
	  	1
		(* n (fakulty (- n 1))))) 

; Der Nachteil dieser Implentierung ist, dass das Programm immer n Stackframes benötigt, da sich die Funktion immer n-mal selbst aufruft.
; Bei großen Zahlen für n stürzt so das Programm ab, denn die Größe des Stacks ist begrenzt. Du kannst mal ausprobieren, wie groß der Stack
; bei deinem Computer ist, bei mir stürzt das programm ab, wenn ich für n 996 einsetze.

; Hier ist eine bessere Version der fakulty methode:
(defun fakulty (n &optional (old_n 1))
	(if (< n 2)
		old_n
		(fakulty (- n 1) (* old_n n))))

; Das sieht jetzt schon viel komplizierter aus, aber es ist (fast) das gleiche Programm. 
; Die Änderungen sind: wir haben jetzt einen optionalen Parameter (old_n). Dieser wird auf 1 gesetzt, wenn wir ihn nicht angeben.
; Anstatt am ende n * fakulty (n - 1) zu schreiben, haben wir die multiplikation in das old_n des nächsten Funktionsaufrufs ausgelagert. 
; Bei n < 2 geben wir nicht 1 zurück, sondern old_n, welches das Endergebnis beinhaltet.
; Die MASSIVEN Vorteile die wir dabei jetzt haben, sind vor allem unsere Compileroptimierungen (ja LISP hat einen compiler).
; Dazu können wir mit (compile 'fakulty) die Funktion compilieren, wir bekommen dann eine Version der Funktion fakulty, welche 
; den Stack viel besser nutzt als die alte Version. Sie braucht nur ein einziges Stackframe.
; Das funktioniert, indem der Compiler merkt, dass wir einen sogenannten Akkumulator verwenden (old_n).
; Der Compiler merkt hier, dass wir die alten Stackframes nicht brauchen, und entfernt diese für uns.
; Die short und takeaway-lesson dabei ist folgende: Benutze einen Akkumulator (für Rekursive Funktionen), wann immer du kannst.


;;; als nächstes großes thema stehen noch makros auf dem plan.
; makros sind funktionen, die funktionen generieren. das hört sich spoopy an aber ist relativ ez.
; lisp hat keine while schleife. es hat sowas ähnliches, ist aber ziemlich wonky das zu nutzen.
; was wir haben, ist das hier:
(setf x 0)
(loop while (< x 10) do
  (format t "~d " x)
  (setf x (+ x 1)))
;0 1 2 3 4 5 6 7 8 9 
;nil

; was wir viel lieber hätten ist aber das hier:
#|
(setf x 0)
(while (< x 10)
  (format "~d " x)
  (setf x (+ x 1)))
|#
; das loop und das do sind so oldfashioned, wir neumodischen programmierer finden das doof und man kann ja viel syntax sparen und so...
; und lisp lässt uns nicht hängen: es gibt zum glück makros, die uns genau das ermöglichen.
; makros schreibt man fast wie funktionen:
(defmacro while (test &body body)
     #| hier kommt der eigentliche code hin |#
)
; sieht so weit schon stark aus wie eine funktion, nicht wahr?
; &body ist ähnlich wie &optional (das hatten wir schon weiter oben), aber anstatt optionale parameter zu markieren, ist es einfach der rest in der parameterliste.
; unsere gewünschte while funktion hat auch 3 parameter: einmal den test, dann die funktion format, dann die funktion setf. wir können so beliebig viele parameter reinwerfen.
#|
(defmacro while (test &body body)
  (list 'loop 'while test 'do body))
|#
; sowas in der art wollen wir ja, das wird aber leider noch nicht funktionieren, da body noch als liste gesehen wird. in unserem fall ist body gleich wie
; ((format t "~d " x) (setf x (+ x 1)))
; was wir brauchen ist das hier als body:
; (progn (format t "~d " x) (setf x (+ x 1)))
; progn macht einfach dass alles in dem block als separates statement ausgeführt wird.
; irgendwie müssen wir also das progn vor das format in die liste rein kriegen. fällt dir was ein?
; hier ist die lösung: wir können cons dafür benutzen:
(defmacro while (test &body body)
  (list 'loop 'while test 'do (cons 'progn body)))
; damit sollten wir jetzt endlich unsere while schleife benutzen können, so wie wir wollen.
#|
(setf y 0)
(while (< y 10)
  (format "~d " y)
  (setf y (+ y 1)))
|#
; probier am besten selbst aus, ob das so klappt (ich hab das natürlich selbst schon getestet und es funktioniert ^^).

; wenn das alles für dich nachvollziehbar war, dann herzlichen glühstrumpf, du bist fertig mit dem tutorial. wenn du lisp komisch aber iwie cool findest, dann gehts dir
; genau wie allen anderen, die beschlossen haben, mit lisp weiter zu machen. ab hier kommst du recht gut alleine zurecht.
; solltest du probleme haben, einfach nochmal lesen, so wie immer. du kannst mir auch auf discord fragen stellen. Den Kontakt findest du ganz unten.
; das tut soll dich im prinzip auch nur soweit bringen, dass du einigermaßen zurecht kommst. es ist auch nicht schlimm, wenn du sagst, bah lisp ist ja eklig.
; dann ist es einfach nix für dich. aber du solltest trotzdem respektieren, dass lisp die älteste programmiersprache ist, die immer noch ernsthaft genutzt wird.
; außerdem kamen aus lisp sehr viele konzepte, die später wieder verwendet wurden:
; erstmals in lisp wurden eingeführt:
#|
  dynamische typisierung
  garbage collection
  rekursion
  makros in dieser art
|#
; durch das makro system ist lisp in der lage, sich der aufgabe anzupassen, was es theoretisch zu der besten sprache macht, die man gut können kann. 
; Leider ist lisp aber nicht weit genug verbreitet, dass es sich wirklich lohnt, die gesamte sprache zu erlernen.

; Mehr infos zu lisp findest du auf 
; https://lisp-lang.org/
; http://www.gigamonkeys.com/book/
; https://github.com/norvig/paip-lisp
; das sind zumindest die ressourcen, die ich verwendet habe. wenn ich was vergessen haben sollte, sag mir einfach bescheid. Kontakt ist gaaaanz unten
;
; hilfe kannst du immer hier bekommen:
; https://stackoverflow.com/



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kontakt: L0ren22#7274 (Discord)
; cheers :)
