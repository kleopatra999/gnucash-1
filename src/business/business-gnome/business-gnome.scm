(define-module (gnucash business-gnome))
(use-modules (g-wrapped gw-business-gnome))
(use-modules (gnucash gnc-module))

(gnc:module-load "gnucash/gnome-utils" 0)
(gnc:module-load "gnucash/business-core" 0)
(gnc:module-load "gnucash/gnome-search" 0)
(gnc:module-load "gnucash/business-core-file" 0)
(gnc:module-load "gnucash/dialog-tax-table" 0)

(gnc:module-load "gnucash/report/report-gnome" 0)
(use-modules (gnucash report business-reports))
(use-modules (gnucash main))		;for gnc:debug

(define main-window gnc:window-name-main)
(define top-level "_Business")
(define new-label "New")
(define find-label "Find")

(define gnc:*business-label* (N_ "Business"))
(define gnc:*company-name* (N_ "Company Name"))
(define gnc:*company-addy* (N_ "Company Address"))

(export gnc:*business-label* gnc:*company-name* gnc:*company-addy*)

(define (add-customer-items)
  (let ((last-cust (gnc:owner-create))
	(cust "Customers"))

    (define customer-menu
      (gnc:make-menu (N_ cust)
		     (list main-window top-level "")))

    (define new-customer-item
      (gnc:make-menu-item (N_ "New Customer")
			  (N_ "New Customer")
			  (list main-window top-level cust "")
			  (lambda ()
			    (gnc:customer-new (gnc:get-current-book)))))

    (define find-customer-item
      (gnc:make-menu-item (N_ "Find Customer")
			  (N_ "Find Customer")
			  (list main-window top-level cust "")
			  (lambda ()
			    (gnc:customer-search (gnc:owner-get-customer
						last-cust)
					       (gnc:get-current-book)))))

    (define new-invoice-item
      (gnc:make-menu-item (N_ "New Invoice")
			  (N_ "New Invoice")
			  (list main-window top-level cust "")
			  (lambda ()
			    (gnc:invoice-new last-cust
					     (gnc:get-current-book)))))

    (define find-invoice-item
      (gnc:make-menu-item (N_ "Find Invoice")
			  (N_ "Find Invoice")
			  (list main-window top-level cust "")
			  (lambda ()
			    (gnc:invoice-search #f last-cust
					      (gnc:get-current-book)))))

    (define new-job-item
      (gnc:make-menu-item (N_ "New Job")
			  (N_ "New Job")
			  (list main-window top-level cust "")
			  (lambda ()
			    (gnc:job-new last-cust
					 (gnc:get-current-book)))))

    (define find-job-item
      (gnc:make-menu-item (N_ "Find Job")
			  (N_ "Find Job")
			  (list main-window top-level cust "")
			  (lambda ()
			    (gnc:job-search #f last-cust
					  (gnc:get-current-book)))))

    (define payment-item
      (gnc:make-menu-item (N_ "Process Payment")
			  (N_ "Process Payment")
			  (list main-window top-level cust "")
			  (lambda ()
			    (gnc:payment-new last-cust
					     (gnc:get-current-book)))))


    (gnc:owner-init-customer last-cust #f)

    (gnc:add-extension customer-menu)
    (gnc:add-extension payment-item)
    (gnc:add-extension find-job-item)
    (gnc:add-extension new-job-item)
    (gnc:add-extension find-invoice-item)
    (gnc:add-extension new-invoice-item)
    (gnc:add-extension find-customer-item)
    (gnc:add-extension new-customer-item)
    ))

(define (add-vendor-items)
  (let ((last-vendor (gnc:owner-create))
	(vendor "Vendors"))

    (define vendor-menu
      (gnc:make-menu (N_ vendor)
		     (list main-window top-level "")))

    (define new-vendor-item
      (gnc:make-menu-item (N_ "New Vendor")
			  (N_ "New Vendor")
			  (list main-window top-level vendor "")
			  (lambda ()
			    (gnc:vendor-new (gnc:get-current-book)))))
  

    (define find-vendor-item
      (gnc:make-menu-item (N_ "Find Vendor")
			  (N_ "Find Vendor")
			  (list main-window top-level vendor "")
			  (lambda ()
			    (gnc:vendor-search (gnc:owner-get-vendor
					      last-vendor)
					     (gnc:get-current-book)))))

    (define new-invoice-item
      (gnc:make-menu-item (N_ "New Bill")
			  (N_ "New Bill")
			  (list main-window top-level vendor "")
			  (lambda ()
			    (gnc:invoice-new last-vendor
					     (gnc:get-current-book)))))

    (define find-invoice-item
      (gnc:make-menu-item (N_ "Find Bill")
			  (N_ "Find Bill")
			  (list main-window top-level vendor "")
			  (lambda ()
			    (gnc:invoice-search #f last-vendor
					      (gnc:get-current-book)))))

    (define new-job-item
      (gnc:make-menu-item (N_ "New Job")
			  (N_ "New Job")
			  (list main-window top-level vendor "")
			  (lambda ()
			    (gnc:job-new last-vendor
					 (gnc:get-current-book)))))

    (define find-job-item
      (gnc:make-menu-item (N_ "Find Job")
			  (N_ "Find Job")
			  (list main-window top-level vendor "")
			  (lambda ()
			    (gnc:job-search #f last-vendor
					  (gnc:get-current-book)))))


    (define payment-item
      (gnc:make-menu-item (N_ "Process Payment")
			  (N_ "Process Payment")
			  (list main-window top-level vendor "")
			  (lambda ()
			    (gnc:payment-new last-vendor
					     (gnc:get-current-book)))))

    (gnc:owner-init-vendor last-vendor #f)

    (gnc:add-extension vendor-menu)
    (gnc:add-extension payment-item)
    (gnc:add-extension find-job-item)
    (gnc:add-extension new-job-item)
    (gnc:add-extension find-invoice-item)
    (gnc:add-extension new-invoice-item)
    (gnc:add-extension find-vendor-item)
    (gnc:add-extension new-vendor-item)
    ))

(define (add-business-items)
  (define menu (gnc:make-menu top-level (list "Main" "_Actions")))
  ;;(define new (gnc:make-menu (N_ new-label) (list main-window top-level "")))
  ;;(define find (gnc:make-menu (N_ find-label) (list main-window top-level "")))

  (gnc:add-extension menu)

  ;;(gnc:add-extension find)
  ;;(gnc:add-extension new)

  (gnc:add-extension
   (gnc:make-menu-item (N_ "Billing Terms")
		       (N_ "View and Edit the available Billing Terms")
		       (list main-window top-level "")
		       (lambda ()
			 (gnc:billterms-new (gnc:get-current-book)))))

  (gnc:add-extension
   (gnc:make-menu-item (N_ "Tax Tables")
		       (N_ "View and Edit the available Tax Tables")
		       (list main-window top-level "")
		       (lambda ()
			 (gnc:tax-table-new (gnc:get-current-book)))))
  (add-vendor-items)
  (add-customer-items)

  (gnc:add-extension
    (gnc:make-menu-item (N_ "Properties")
			(N_ "View and edit the properties of this file.")
			(list "Main" "File" "Print")
			(lambda ()
			  (let* ((book (gnc:get-current-book))
				 (slots (gnc:book-get-slots book)))

			    (define (changed_cb)
			      (gnc:book-kvp-changed book))
			    
			    (gnc:kvp-option-dialog gnc:id-book
						   slots "Book Options"
						   changed_cb)))))
  (gnc:add-extension (gnc:make-separator (list "Main" "File" "Print")))

  )


(define (business-report-function)
  (gnc:add-extension
   (gnc:make-menu gnc:menuname-business-reports
		  (list "Main" gnc:menuname-reports gnc:menuname-income-expense))))



(define (add-employee-extensions)
  (let ((last-employee #f))

    (define employee-menu
      (gnc:make-menu (N_ "Employees")
		     (list "Extensions" "")))

    (define new-employee-item
      (gnc:make-menu-item (N_ "New Employee")
			  (N_ "New Employee")
			  (list "Extensions" "Employees" "")
			  (lambda ()
			    (gnc:employee-new (gnc:get-current-book)))))

    (define find-employee-item
      (gnc:make-menu-item (N_ "Find Employee")
			  (N_ "Find Employee")
			  (list "Extensions" "Employees" "")
			  (lambda ()
			    (gnc:employee-search last-employee
					       (gnc:get-current-book)))))

    (gnc:add-extension employee-menu)
    (gnc:add-extension find-employee-item)
    (gnc:add-extension new-employee-item)
    ))

(define (add-business-test)

  (define test-search
    (gnc:make-menu-item (N_ "Test Search Dialog")
			(N_ "Test Search Dialog")
			(list "Extensions" "")
			(lambda ()
			  (gnc:search-dialog-test))))


  (define reload-invoice
    (gnc:make-menu-item (N_ "Reload invoice report")
			(N_ "Reload invoice report scheme file")
			(list "Extensions" "")
			(lambda ()
			  (let ((m (current-module)))
			    (load-from-path "gnucash/report/invoice.scm")
			    (set-current-module m)))))

  (define reload-owner
    (gnc:make-menu-item (N_ "Reload owner report")
			(N_ "Reload owner report scheme file")
			(list "Extensions" "")
			(lambda ()
			  (let ((m (current-module)))
			    (load-from-path "gnucash/report/owner-report.scm")
			    (set-current-module m)))))

  (define reload-receivable
    (gnc:make-menu-item (N_ "Reload receivable report")
			(N_ "Reload receivable report scheme file")
			(list "Extensions" "")
			(lambda ()
			  (let ((m (current-module)))
			    (load-from-path "gnucash/report/aging.scm")
			    (set-current-module m)
			    (load-from-path "gnucash/report/receivables.scm")
			    (set-current-module m)))))

  (define init-data
    (gnc:make-menu-item (N_ "Initialize Test Data")
			(N_ "Initialize Test Data")
			(list "Extensions" "")
			(lambda ()
			  (let* ((book (gnc:get-current-book))
				 (customer (gnc:customer-create book))
				 (address (gnc:customer-get-addr customer))
				 (invoice (gnc:invoice-create book))
				 (owner (gnc:owner-create))
				 (job (gnc:job-create book))
				 (group (gnc:book-get-group book))
				 (inc-acct (gnc:malloc-account book))
				 (bank-acct (gnc:malloc-account book))
				 (tax-acct (gnc:malloc-account book))
				 (ar-acct (gnc:malloc-account book)))

			    ;; Create Customer
			    (gnc:customer-set-id customer "000001")
			    (gnc:customer-set-name customer "Test Customer")
			    (gnc:customer-set-commodity customer
							(gnc:default-currency))
			    (gnc:address-set-name address "Contact Person")
			    (gnc:address-set-addr1 address
						   "20 Customer Lane")
			    (gnc:address-set-addr2 address "Customer M/S")
			    (gnc:address-set-addr3 address "Addr3, XXX  12345")
			    
			    ;; Create the Owner
			    (gnc:owner-init-customer owner customer)
			    
			    ;; Create the Invoice
			    (gnc:invoice-set-id invoice "000012")
			    (gnc:invoice-set-owner invoice owner)
			    (gnc:invoice-set-date-opened
			     invoice (cons (current-time) 0))
			    (gnc:invoice-set-common-commodity
			     invoice (gnc:default-currency))

			    ;; Create the Job
			    (gnc:job-set-id job "000025")
			    (gnc:job-set-name job "Test Job")
			    (gnc:job-set-reference job "Customer's ref#")
			    (gnc:job-set-owner job owner)

			    ;; MODIFY THE OWNER
			    (gnc:owner-init-job owner job)

			    ;; Create the A/R account
			    (gnc:account-set-type ar-acct 'receivable)
			    (gnc:account-set-name ar-acct "A/R")
			    (gnc:account-set-commodity ar-acct
						       (gnc:default-currency))
			    (gnc:group-insert-account group ar-acct)

			    ;; Create the Income account
			    (gnc:account-set-type inc-acct 'income)
			    (gnc:account-set-name inc-acct "Income")
			    (gnc:account-set-commodity inc-acct
						       (gnc:default-currency))
			    (gnc:group-insert-account group inc-acct)

			    ;; Create the Bank account
			    (gnc:account-set-type bank-acct 'bank)
			    (gnc:account-set-name bank-acct "Bank")
			    (gnc:account-set-commodity bank-acct
						       (gnc:default-currency))
			    (gnc:group-insert-account group bank-acct)

			    ;; Create the Tax account
			    (gnc:account-set-type tax-acct 'liability)
			    (gnc:account-set-name tax-acct "Tax-Holding")
			    (gnc:account-set-commodity tax-acct
						       (gnc:default-currency))
			    (gnc:group-insert-account group tax-acct)

			    ;; Launch the invoice editor
			    (gnc:invoice-edit invoice)
			    ))))

  
  (gnc:add-extension init-data)
  (gnc:add-extension reload-receivable)
  (gnc:add-extension reload-invoice)
  (gnc:add-extension reload-owner)
  (gnc:add-extension test-search)

  (add-employee-extensions)
)

(gnc:hook-add-dangler gnc:*report-hook* business-report-function)
(gnc:hook-add-dangler gnc:*ui-startup-hook* add-business-items)
(gnc:hook-add-dangler gnc:*add-extension-hook* add-business-test)

(load-from-path "business-options.scm")
(load-from-path "business-prefs.scm")
