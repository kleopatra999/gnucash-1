;; -*-scheme-*-
;; transaction-report.scm
;; Report on all transactions in an account
;; Robert Merkel (rgmerk@mira.net)

(require 'sort)
(gnc:support "report/transaction-report.scm")
;hack alert - is this line necessary?
(gnc:depend "text-export.scm")
(gnc:depend "report-utilities.scm")
(gnc:depend "date-utilities.scm")
(gnc:depend "html-generator.scm")

;; hack alert - possibly unecessary globals
;; functions for manipulating total inflow and outflow counts.

(define gnc:total-inflow 0)
(define gnc:total-outflow 0)

(define (gnc:set-total-inflow! x)
    (set! gnc:total-inflow x))

(define (gnc:set-total-outflow! x)
    (set! gnc:total-outflow x))

(define (gnc:tr-report-initialize-inflow-and-outflow!)
  (set! gnc:total-inflow 0)
  (set! gnc:total-outflow 0))

;;returns a list contains elements of the-list for which predictate is
;; true
(define (gnc:filter-list the-list predicate)
  (cond ((not (list? the-list))
         (gnc:error "Attempted to filter a non-list object"))
        ((null? the-list) '())
        ((predicate (car the-list))
         (cons (car the-list)
               (gnc:filter-list (cdr the-list) predicate)))
        (else (gnc:filter-list (cdr the-list) predicate))))

;; like map, but restricted to one dimension, and
;; guaranteed to have inorder semantics.

(define (gnc:inorder-map the-list fn)
  (cond ((not (list? the-list))
	 (gnc:error "Attempted to map a non-list object"))
	((not (procedure? fn))
	 (gnc:error "Attempted to map a non-function object to a list"))
	((null? the-list) '())
	(else (cons (fn (car the-list))
		    (gnc:inorder-map (cdr the-list) fn)))))

;; extract fields out of the scheme split representation

(define (gnc:tr-report-get-memo split-scm)
  (vector-ref split-scm 0))

(define (gnc:tr-report-get-action split-scm)
  (vector-ref split-scm 1))

(define (gnc:tr-report-get-description split-scm)
  (vector-ref split-scm 2))

(define (gnc:tr-report-get-date split-scm)
  (vector-ref split-scm 3))

(define (gnc:tr-report-get-reconcile-state split-scm)
  (vector-ref split-scm 4))

(define (gnc:tr-report-get-reconcile-date split-scm)
  (vector-ref split-scm 5))

(define (gnc:tr-report-get-share-amount split-scm)
  (vector-ref split-scm 6))

(define (gnc:tr-report-get-share-price split-scm)
  (vector-ref split-scm 7))

(define (gnc:tr-report-get-value split-scm)
  (vector-ref split-scm 8))

(define (gnc:tr-report-get-num split-scm)
  (vector-ref split-scm 9))

(define (gnc:tr-report-get-other-splits split-scm)
  (vector-ref split-scm 10))

(define (gnc:tr-report-get-first-acc-name split-scm)
  (let ((other-splits (gnc:tr-report-get-other-splits split-scm)))
    (cond ((= (length other-splits) 0) "-")
	  (else  (caar other-splits)))))

;; get transactions date from split - needs to be done indirectly
;; as it's stored in the parent transaction

(define (gnc:split-get-transaction-date split)
  (gnc:transaction-get-date-posted (gnc:split-get-parent split)))

;; ditto descriptions
(define (gnc:split-get-description-from-parent split)
  (gnc:transaction-get-description (gnc:split-get-parent split)))

;; get the account name of a split
(define (gnc:split-get-account-name split)  
  (gnc:account-get-full-name (gnc:split-get-account split)))

;; builds a list of the account name and values for the other
;; splits in a transaction

(define (gnc:split-get-corresponding-account-name-and-values 
	 split split-filter) 
  (let* ((diff-list '())
         (parent-transaction (gnc:split-get-parent split))
         (num-splits (gnc:transaction-get-split-count parent-transaction)))
    (gnc:for-loop 
     (lambda (n) 
       (let* ((split-in-trans 
	       (gnc:transaction-get-split parent-transaction n))
	      (sub-split
	       (list 
		 (gnc:split-get-account-name split-in-trans)
		 (gnc:split-get-value split-in-trans))))
	 (if (split-filter sub-split)
	     (set! diff-list
		   (cons sub-split diff-list)))))
     0 num-splits 1)
    (reverse diff-list)))


;; takes a C split, extracts relevant data and converts to a scheme 
;; representation.  split-filter is a predicate that filters the splits.

(define (gnc:make-split-scheme-data split split-filter)
  (vector (gnc:split-get-memo split) 
	  (gnc:split-get-action split)
	  (gnc:split-get-description-from-parent split)
	  (gnc:split-get-transaction-date split)
	  (gnc:split-get-reconcile-state split)
	  (gnc:split-get-reconciled-date split)
	  (gnc:split-get-share-amount split)
	  (gnc:split-get-share-price split)
	  (gnc:split-get-value split)
	  (gnc:transaction-get-num (gnc:split-get-parent split))
	  (gnc:split-get-corresponding-account-name-and-values split
							       split-filter)))

;;;; Note: This can be turned into a lookup table which will
;;;; *massively* simplify it...

(define (gnc:sort-predicate-component component order)
  (let ((ascending-order-comparator
	(begin 
;	  (display (symbol->string component))
	(cond
	 ((eq? component 'date) 
	  (lambda (split-scm-a split-scm-b)
	    (- 
	     (car 
	      (gnc:timepair-canonical-day-time 
	       (gnc:tr-report-get-date split-scm-a)))
	     (car
	      (gnc:timepair-canonical-day-time
	       (gnc:tr-report-get-date split-scm-b))))))

	 ((eq? component 'time) 
	  (lambda (split-scm-a split-scm-b)
	    (-
	     (car (gnc:tr-report-get-date split-scm-a))
	     (car (gnc:tr-report-get-date split-scm-b)))))

	 ((eq? component 'amount) 
	  (lambda (split-scm-a split-scm-b)
	    (-
	     (gnc:tr-report-get-value split-scm-a)
	     (gnc:tr-report-get-value split-scm-b))))

	 ((eq? component 'description)
	  (lambda (split-scm-a split-scm-b)
	    (let ((description-a (gnc:tr-report-get-description split-scm-a))
		  (description-b (gnc:tr-report-get-description split-scm-b)))
	      (cond ((string<? description-a description-b) -1)
		    ((string=? description-a description-b) 0)
		    (else 1)))))
	 
	 ;; hack alert - should probably use something more sophisticated
	 ;; here - perhaps even making it user-definable
	 ((eq? component 'number)
	  (lambda (split-scm-a split-scm-b)
            (let ((num-a (gnc:tr-report-get-num split-scm-a))
                  (num-b (gnc:tr-report-get-num split-scm-b)))
              (cond ((string<? num-a num-b) -1)
                    ((string=? num-a num-b) 0)
                    (else 1)))))

	 ((eq? component 'corresponding-acc)
	  (lambda (split-scm-a split-scm-b)
	   (let ((corr-acc-a (gnc:tr-report-get-first-acc-name split-scm-a))
		 (corr-acc-b (gnc:tr-report-get-first-acc-name split-scm-b)))
	     (cond ((string<? corr-acc-a corr-acc-b) -1)
		   ((string=? corr-acc-a corr-acc-b) 0)
		   (else 1)))))

	 ((eq? component 'memo)
	   (lambda (split-scm-a split-scm-b)
	   (let ((memo-a (gnc:tr-report-get-memo split-scm-a))
		 (memo-b (gnc:tr-report-get-memo split-scm-b)))
	     (cond ((string<? memo-a memo-b) -1)
		   ((string=? memo-a memo-b) 0)
		   (else 1)))))
	 (else (gnc:error (sprintf "illegal sorting option %s- bug in transaction-report.scm" (symbol->string (component)) )))))))
	 (cond ((eq? order 'descend) 
		 (lambda (my-split-a my-split-b)
		   (- (ascending-order-comparator my-split-a my-split-b))))
		(else ascending-order-comparator))))


;; returns a predicate
(define (gnc:tr-report-make-sort-predicate primary-key-op primary-order-op
                                           secondary-key-op secondary-order-op)
  (let ((primary-comp (gnc:sort-predicate-component
		       (gnc:option-value primary-key-op)
		       (gnc:option-value primary-order-op)))
	  (secondary-comp (gnc:sort-predicate-component
			   (gnc:option-value secondary-key-op)
			   (gnc:option-value secondary-order-op))))
    (lambda (split-a split-b)  
      (let ((primary-comp-value (primary-comp split-a split-b)))
	(cond ((< primary-comp-value 0) #t)
	      ((> primary-comp-value 0) #f)
	      (else 
	       (let ((secondary-comp-value (secondary-comp split-a split-b)))
		 (cond ((< secondary-comp-value 0) #t)
		       (else #f)))))))))

;; returns a predicate that returns true only if a split-scm is
;; between early-date and late-date

(define (gnc:tr-report-make-filter-predicate early-date late-date)
  (lambda (split-scm)
    (let ((split-date (gnc:tr-report-get-date split-scm)))
      (and (gnc:timepair-later-or-eq-date split-date early-date)
           (gnc:timepair-earlier-or-eq-date split-date late-date)))))

;; applies 

;; makes a predicate that returns true only if a sub-split account
;; does not match one of the accounts
(define (gnc:tr-report-make-sub-split-filter-predicate accounts)
  (lambda (sub-split)
    (let loop
        ((list accounts))
      (if (null? list)
          #f
          (or (not (equal? (gnc:account-get-name (car list)) (car sub-split)))
              (loop (cdr list)))))))

;; converts a scheme split representation to a line of HTML,
;; updates the values of total-inflow and total-outflow based
;; on the split value
;; hack alert - no i8n on amount printing yet - must fix!

(define (gnc:tr-report-split-to-html split-scm 
                                     starting-balance)
  (let ((other-splits (gnc:tr-report-get-other-splits split-scm))
	(report-string ""))
    (cond ((> (gnc:tr-report-get-value split-scm) 0)
	   (gnc:set-total-inflow! (+ gnc:total-inflow
				     (gnc:tr-report-get-value split-scm))))
	  (else 
	   (gnc:set-total-outflow! (+ gnc:total-outflow
				      (- (gnc:tr-report-get-value 
					  split-scm))))))
    (for-each
     (lambda (split-sub first last)
       (set! report-string
	     (string-append 
	      report-string
	      "<TR><TD>"
	      (cond (first (gnc:timepair-to-datestring
			    (gnc:tr-report-get-date split-scm)))
		    (else ""))
	      "</TD><TD>"
	      (cond (first (gnc:tr-report-get-num split-scm))
		    (else ""))
	      "</TD><TD>"
	      (cond (first (gnc:tr-report-get-description split-scm))
		    (else ""))
	      "</TD><TD>"
	      (cond (first (gnc:tr-report-get-memo split-scm))
		    (else ""))
	      "</TD><TD>"
              (if (string? (car split-sub)) (car split-sub) "")
	      "</TD><TD>"
	      (cond ((< (cadr split-sub) 0)
		     (string-append
		      (sprintf #f "%.2f" (- (cadr split-sub)))
		      "</TD><TD>"))
		    (else
		     (string-append
		      "</TD><TD>"	
		      (sprintf #f "%.2f" (cadr split-sub)))))		
	      "</TD>"
	      (cond ((not last) "</TR>")
		    (else "")))))
     other-splits
     (if (null? other-splits)
         ()
         (append (list #t) (make-list (- (length other-splits) 1) #f)))
     (if (null? other-splits)
         ()
         (append (make-list (- (length other-splits) 1) #f) (list #t))))
    (string-append
     report-string
     "<TD>"
     (sprintf #f "%.2f" (- (+ starting-balance gnc:total-inflow)
			   gnc:total-outflow))
     "</TD></TR>")))

;; gets the balance for a list of splits before beginning-date
;; hack alert -
;; we are doing multiple passes over the list - if it becomes a performance
;; problem some code optimisation will become necessary

(define (gnc:tr-report-get-starting-balance scm-split-list beginning-date)
  (cond ((or 
	  (eq? scm-split-list '())
	  (gnc:timepair-later-date
	   (gnc:tr-report-get-date (car scm-split-list))
	   beginning-date))
	 0)
	(+ 
	 (gnc:tr-report-get-value 
	  (car scm-split-list))
	 (gnc:tr-report-get-starting-balance
	  (cdr scm-split-list) beginning-date))))


(gnc:define-report
 ;; version
 1
 ;; Name
 "Account Transactions"
 ;; Options
 trep-options-generator
 ;; renderer
 (lambda (options)
   (gnc:tr-report-initialize-inflow-and-outflow!)
   (let* ((begindate (gnc:lookup-option options "Report Options" "From"))
          (enddate (gnc:lookup-option options "Report Options" "To"))
          (tr-report-account-op (gnc:lookup-option options
                                                   "Report Options" "Account"))
          (tr-report-primary-key-op (gnc:lookup-option options
                                                       "Sorting"
                                                       "Primary Key"))
          (tr-report-primary-order-op (gnc:lookup-option options
                                                         "Sorting"
                                                         "Primary Sort Order"))
          (tr-report-secondary-key-op (gnc:lookup-option options
                                                         "Sorting"
                                                         "Secondary Key"))
          (tr-report-secondary-order-op
           (gnc:lookup-option options "Sorting" "Secondary Sort Order"))
          (prefix  (list "<HTML>" "<BODY bgcolor=#99ccff>" 
			 "<TABLE>"
	                 "<TH>Date</TH>"
                         "<TH>Num</TH>"
                         "<TH>Description</TH>"
                         "<TH>Memo</TH>"
                         "<TH>Category</TH>"
                         "<TH>Credit</TH>"
                         "<TH>Debit</TH>"
			 "<TH>Balance<TH>"))
	  (suffix  (list "</TABLE>" "</BODY>" "</HTML>"))
	  (balance-line '())
	  (inflow-outflow-line '())
	  (net-inflow-line '())
	  (report-lines '())
          (accounts (gnc:option-value tr-report-account-op))
	  (date-filter-pred (gnc:tr-report-make-filter-predicate
			     (gnc:option-value begindate) 
			     (gnc:option-value enddate)))
	  (sub-split-filter-pred (gnc:tr-report-make-sub-split-filter-predicate
                                  accounts))
	  (starting-balance 0))
     (if (null? accounts)
         (set! report-lines
               (list "<TR><TD>There are no accounts to report on.</TD></TR>"))
	 (begin
	   ; reporting on more than one account not yet supported
           (gnc:for-each-split-in-account
            (car accounts)
            (lambda (split)		
              (set! report-lines 
                    (append! report-lines 
                             (list (gnc:make-split-scheme-data 
				    split sub-split-filter-pred))))))
           (set! starting-balance
                 (gnc:tr-report-get-starting-balance
                  report-lines (gnc:option-value begindate)))	
           (set! report-lines (gnc:filter-list report-lines date-filter-pred))
	   (set! report-lines
                 (sort!
                  report-lines 
                  (gnc:tr-report-make-sort-predicate
                   tr-report-primary-key-op tr-report-primary-order-op
                   tr-report-secondary-key-op tr-report-secondary-order-op)))
	   (let ((html-mapper (lambda (split-scm) (display "in!") (newline)
                                (gnc:tr-report-split-to-html
						  split-scm
						  starting-balance)
                                (display "out!") (newline))))
	     (set! report-lines (gnc:inorder-map report-lines html-mapper)))
	   (set!
	    balance-line 
	    (list "<TR><TD><STRONG>"
		  (gnc:timepair-to-datestring (gnc:option-value begindate))
		  "</STRONG></TD>"
		  "<TD></TD>" 
		  "<TD></TD>"
		  "<TD></TD>"
		  "<TD></TD>"
		  "<TD></TD>"
		  "<TD></TD>"
		  "<TD><STRONG>"
		  (sprintf #f "%.2f" starting-balance)
		  "</STRONG></TD></TR>"))
	   (set!
	    inflow-outflow-line
	    (list "<TR><TD><STRONG>Totals:</STRONG></TD>"
		  "<TD></TD>" 
		  "<TD></TD>"
		  "<TD></TD>"
		  "<TD></TD>"
		  "<TD><STRONG>"
		  (sprintf #f "%.2f" gnc:total-inflow)
		  "</TD></STRONG>"
		  "<TD><STRONG>"
		  (sprintf #f "%.2f" gnc:total-outflow)
		  "</TD></STRONG>"
		  "<TD></TD></TR>"))
	   (set!
	    net-inflow-line
	    (list "<TR><TD><STRONG>Net Inflow</STRONG></TD>"
		  "<TD></TD>"
		  "<TD></TD>" 
		  "<TD></TD>" 
		  "<TD></TD>"
		  "<TD></TD>" 
		  "<TD></TD>"
		  "<TD><STRONG>"
		  (sprintf #f "%.2f" (- gnc:total-inflow gnc:total-outflow))
		  "</TD></STRONG></TR>"))))
     (append prefix balance-line report-lines
             inflow-outflow-line net-inflow-line suffix))))
