********************************************************
* Mixed effects models for performance feedback theory *
*  			- INEI - ENIIM 2018 database -             *
********************************************************

clear			all
set more		off, perm
set type		double, perm

*def. ubicación bbdd
gl			a "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\0-bbdd iniciales"
gl			b "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\1-bbdd intermedias"
gl			c "\\fileserv\alumnos\j.bolanoshurtado\Documents\0- Local UP Workstation\12-tesis\Database Analyses\mixed"

*abrimos bbdd final .dta
u			"$c\long_ddbb_eniim2018.dta", clear


* Seguimos lo siguiente:
*>>> Estimation Table & Estimation Specification 
* para estimar modelos.

/*
			-Estimation Table-
			
1. 			Main Specification

1.1.		Historic Divergence
1.1.1.		 Rawsearch 		vs 	DivergExport
1.1.1.1.	  Var_Rawsearch vs 	DivergExport
1.1.2. 		 Intsearch 		vs 	DivergExport
1.1.2.1.	  Var_Intsearch vs 	DivergExport
1.1.3.		 Rawsearch 		vs 	DivergIntexp
1.1.3.1.	  Var_Rawsearch vs 	DivergIntexp
1.1.4. 		 Intsearch 		vs 	Divergintexp
1.1.4.1.	  Var_Intsearch vs 	Divergintexp

1.2.		Social Divergence
1.2.1.		 Rawsearch 		vs 	DivergSocExport
1.2.1.1.	  Var_Rawsearch vs 	DivergSocExport
1.2.2.		 Intsearch 		vs 	DivergSocExport
1.2.2.1.	  Var_Intsearch vs 	DivergSocExport
1.2.3.		 Rawsearch 		vs 	DivergSocIntexp
1.2.3.1.	  Var_Rawsearch vs 	DivergSocIntexp
1.2.4.		 Intsearch 		vs 	DivergSocIntexp
1.2.4.1.	  Var_Intsearch vs 	DivergSocIntexp
*/

/*
			-Estimation Specification-

A.			Maximum Likelihood Estimation

A.1.		Only Maximum Likelihood
A.1.1.		Only ML with covariance(unstructured)
A.1.2.		Only ML with residuals(independent, by(ciiu2d))
A.1.3.		Only ML with covariance(unst..) + residuals(independent, by(ciiu2d))

A.2.1.		ML with Robust SE by cluster level: ciiu2d
A.2.2.		ML with Robust SE and covariance(unstructured)
A.2.3.		ML with Robust SE and residuals(independent, by(ciiu2d))
A.2.4.		ML with Robust SE + cov(unst...) + residuals(indep..., by(ciiu2d))

A.3 - A.5 	********* REQUIRES STATA16 *************

A.3.		ML with pwscale(size)
A.4.		ML with pwscale(effective)
A.5.		ML with pwscale(gk)

A.3.1.		ML with pwscale(size) + covariance(unstructured)
A.3.2.		ML with pwscale(size) + residuals(independent, by(ciiu2d))
A.3.3.		ML with pwscale(size) + cov(unst...) + res(indep..., by(ciiu2d))

A.4.1.		ML with pwscale(effective) + covariance(unstructured)
A.4.2.		ML with pwscale(effective) + residuals(independent, by(ciiu2d))
A.4.3.		ML with pwscale(effective) + cov(unst...) + res(indep..., by(ciiu2d))

A.5.1.		ML with pwscale(gk) + covariance(unstructured)
A.5.2.		ML with pwscale(gk) + residuals(independent, by(ciiu2d))
A.5.3.		ML with pwscale(gk) + cov(unst...) + res(indep..., by(ciiu2d))


B.			Restricted Maximum Likelihood Estimation

B.1.		Only REML estimation
B.2.		REML + dfmethod(kroger)
B.3.		REML + dfmethod(satterthwaite)

B.1.1.		Only REML + covariance(unstructured)
B.1.2.		Only REML + residuals(independent, by(ciiu2d))
B.1.3.		Only REML + cov(unst...) + res(indep..., by(ciiu2d))

B.2.1.		REML + dfmethod(kroger) + covariance(unstructured)
B.2.2.		REML + dfmethod(kroger) + residuals(independent, by(ciiu2d))
B.2.3.		REML + dfmethod(kroger) + cov(unst...) + res(indep..., by(ciiu2d))

B.3.1.		REML + dfmethod(kroger) + covariance(unstructured)
B.3.2.		REML + dfmethod(kroger) + residuals(independent, by(ciiu2d))
B.3.3.		REML + dfmethod(kroger) + cov(unst...) + res(indep..., by(ciiu2d))
*/



/*Begin

*1.1.1		OK
mixed		rawsearch || ciiu2d: || id:
mixed		rawsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
						c.divergexport_l2_#i.Iexport_l2_pos_ 	///
						slack_capi slack_wage slack_prof 		///
						|| ciiu2d: || id:
*
mixed		rawsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
						c.divergexport_l2_#i.Iexport_l2_pos_ 	///
						slack_capi slack_wage slack_prof 		///
						|| ciiu2d: || id: 						///
						, reml

*1.1.1.1.	OK	
mixed		var_rawsearch 	|| ciiu2d: || id:
mixed		var_rawsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
							c.divergexport_l2_#i.Iexport_l2_pos_ 	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d: || id:
*
mixed		var_rawsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
							c.divergexport_l2_#i.Iexport_l2_pos_ 	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d: || id: 						///
							, reml
						
*1.1.2. 	NADA
mixed		intsearch || ciiu2d: || id:
mixed		intsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
						c.divergexport_l2_#i.Iexport_l2_pos_ 	///
						slack_capi slack_wage slack_prof 		///
						|| ciiu2d: || id:
*
mixed		intsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
						c.divergexport_l2_#i.Iexport_l2_pos_ 	///
						slack_capi slack_wage slack_prof 		///
						|| ciiu2d: || id: 						///
						, reml
*1.1.2.1.	NADA
mixed		var_intsearch 	|| ciiu2d: || id:
mixed		var_intsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
							c.divergexport_l2_#i.Iexport_l2_pos_ 	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d: || id:
*
mixed		var_intsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
							c.divergexport_l2_#i.Iexport_l2_pos_ 	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d: || id: 						///
							, reml

		


*1.1.3.		NADA
mixed		rawsearch || ciiu2d: || id:
mixed		rawsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
						c.divergintexp_l2_#i.Iintexp_l2_pos_ 	///
						slack_capi slack_wage slack_prof 		///
						|| ciiu2d: || id:
*
mixed		rawsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
						c.divergintexp_l2_#i.Iintexp_l2_pos_ 	///
						slack_capi slack_wage slack_prof 		///
						|| ciiu2d: || id: 						///
						, reml

*1.1.3.1.	NADA
mixed		var_rawsearch 	|| ciiu2d: || id:
mixed		var_rawsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
							c.divergintexp_l2_#i.Iintexp_l2_pos_ 	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d: || id:
*
mixed		var_rawsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
							c.divergintexp_l2_#i.Iintexp_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d: || id: 						///
							, reml
						
*1.1.4. 	NADA
mixed		intsearch || ciiu2d: || id:
mixed		intsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
						c.divergintexp_l2_#i.Iintexp_l2_pos_ 	///
						slack_capi slack_wage slack_prof 		///
						|| ciiu2d: || id:
*
mixed		intsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
						c.divergintexp_l2_#i.Iintexp_l2_pos_	///
						slack_capi slack_wage slack_prof 		///
						|| ciiu2d: || id: 						///
						, reml
*1.1.4.1.	NADA
mixed		var_intsearch 	|| ciiu2d: || id:
mixed		var_intsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
							c.divergintexp_l2_#i.Iintexp_l2_pos_ 	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d: || id:
*
mixed		var_intsearch 	c.divergventas_l2_#i.Iventas_l2_pos_ 	///
							c.divergintexp_l2_#i.Iintexp_l2_pos_ 	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d: || id: 						///
							, reml

*1.2.1.		OK
mixed		rawsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:
*
mixed		rawsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
*1.2.1.1	MASO
mixed		var_rawsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:
*
mixed		var_rawsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
*1.2.2.		NADA				
mixed		intsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:
*
mixed		intsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
*1.2.2.1	NADA
mixed		var_intsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:
*
mixed		var_intsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
*1.2.3.		NADA
mixed		rawsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocintexp#i.Isocintexp_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:
*
mixed		rawsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocintexp#i.Isocintexp_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
*1.2.3.1		NADA
mixed		var_rawsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocintexp#i.Isocintexp_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:
*
mixed		var_rawsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocintexp#i.Isocintexp_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
*1.2.4.		NADA
mixed		intsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocintexp#i.Isocintexp_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:
*
mixed		intsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocintexp#i.Isocintexp_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
*1.2.4.1		NADA
mixed		var_intsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocintexp#i.Isocintexp_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:
*
mixed		var_intsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocintexp#i.Isocintexp_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml




* Quedan solo Rawsearch y Var_Rawsearch contra DivergExport
** Ahora en STATA16 probamos el pwscale y el dfmethod

*ROBUST STANDARD ERRORS make precision worse!
* Recall unbalanced dataset!

*1.1.1.
mixed		rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d:					
mixed		rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d:						///
							[pw=FACTOR_FINAL], pwscale(size)
mixed		rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d:						///
							[pw=FACTOR_FINAL], pwscale(effective)
mixed		rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d:						///
							[pw=FACTOR_FINAL], pwscale(gk)

*1.1.1.1.
mixed		var_rawsearch	c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d:					
mixed		var_rawsearch	c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d:	|| id:			
							
mixed		var_rawsearch	c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d:						///
							[pw=FACTOR_FINAL], pwscale(size)
mixed		var_rawsearch	c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d:						///
							[pw=FACTOR_FINAL], pwscale(effective)
mixed		var_rawsearch	c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof 		///
							|| ciiu2d:						///
							[pw=FACTOR_FINAL], pwscale(gk)


* SO:
* We have the maximum likelihood estimation as is +
* NOW let's try REML + dfmethod adjustment

*1.1.1.		HISTÓRICO
mixed		rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
mixed		rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml dfmethod(satterthwaite)
mixed		rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml dfmethod(kroger)
*1.1.1.1.	HISTÓRICO
mixed		var_rawsearch	c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
mixed		var_rawsearch	c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml dfmethod(satterthwaite)
mixed		var_rawsearch	c.divergventas_l2_#i.Iventas_l2_pos_	///
							c.divergexport_l2_#i.Iexport_l2_pos_	///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml dfmethod(kroger)

*1.2.1.		SOCIAL
mixed		rawsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
mixed		rawsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml dfmethod(satterthwaite)
mixed		rawsearch		c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml dfmethod(kroger)

*1.2.1.1.	SOCIAL
mixed		var_rawsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml
mixed		var_rawsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml dfmethod(satterthwaite)
mixed		var_rawsearch	c.divergsocventas#i.Isocventas_pos_		///
							c.divergsocexport#i.Isocexport_pos_		///
							slack_capi slack_wage slack_prof		///
							|| ciiu2d: || id:						///
							, reml dfmethod(kroger)
							
*/



*******************************************
*										  *
*    STATA 16 NEEDED FOR THE NEXT PART!!  *
*										  *
*******************************************

*******************************
* LETS SUMMARISE OUR FINDINGS **************************************************
*******************************


*	Stripped Histórico 
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								|| ciiu2d: || id:
estimates 		store stripped
test divergventas_l2_#0.Iventas_l2_pos_ = divergventas_l2_#1.Iventas_l2_pos_
test divergexport_l2_#0.Iexport_l2_pos_ = divergexport_l2_#1.Iexport_l2_pos_

*	Histórico
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								|| ciiu2d: || id:

estimates		store basic
lrtest			basic stripped 
test divergventas_l2_#0.Iventas_l2_pos_ = divergventas_l2_#1.Iventas_l2_pos_
test divergexport_l2_#0.Iexport_l2_pos_ = divergexport_l2_#1.Iexport_l2_pos_
test c.slack_capi#0.Iexport_l2_pos_ = c.slack_capi#1.Iexport_l2_pos_
test c.slack_prof#0.Iexport_l2_pos_ = c.slack_prof#1.Iexport_l2_pos_


* Histórico with controls
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:
estimates		store control

lrtest			control basic 

test divergventas_l2_#0.Iventas_l2_pos_ = divergventas_l2_#1.Iventas_l2_pos_
test divergexport_l2_#0.Iexport_l2_pos_ = divergexport_l2_#1.Iexport_l2_pos_
test c.slack_capi#0.Iexport_l2_pos_ = c.slack_capi#1.Iexport_l2_pos_
test c.slack_prof#0.Iexport_l2_pos_ = c.slack_prof#1.Iexport_l2_pos_


*	Social stripped
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								|| ciiu2d: || id:
estimates		store stripped
test divergsocventas#0.Isocventas_pos_ = divergsocventas#1.Isocventas_pos_
test divergsocexport#0.Isocexport_pos_ = divergsocexport#1.Isocexport_pos_


*	Social
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								|| ciiu2d: || id:
estimates		store basic 
test divergsocventas#0.Isocventas_pos_ = divergsocventas#1.Isocventas_pos_
test divergsocexport#0.Isocexport_pos_ = divergsocexport#1.Isocexport_pos_
test c.slack_capi#0.Isocexport_pos_ = c.slack_capi#1.Isocexport_pos_
test c.slack_prof#0.Isocexport_pos_ = c.slack_prof#1.Isocexport_pos_



lrtest			basic stripped
*	Social with controls
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:
estimates		store control 

lrtest			control basic

test divergsocventas#0.Isocventas_pos_ = divergsocventas#1.Isocventas_pos_
test divergsocexport#0.Isocexport_pos_ = divergsocexport#1.Isocexport_pos_
test c.slack_capi#0.Isocexport_pos_ = c.slack_capi#1.Isocexport_pos_
test c.slack_prof#0.Isocexport_pos_ = c.slack_prof#1.Isocexport_pos_


*


* 2nd findings with restricted maximum likelihood
*	Histórico stripped
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								|| ciiu2d: || id:						///
								, reml
*estimates		store stripped
*	Histórico 
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								|| ciiu2d: || id:						///
								, reml
*estimates 		store basic

*lrtest			basic stripped
* 	Histórico with controls
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:						///
								, reml
*estimates 		store control
test divergventas_l2_#0.Iventas_l2_pos_ = divergventas_l2_#1.Iventas_l2_pos_
test divergexport_l2_#0.Iexport_l2_pos_ = divergexport_l2_#1.Iexport_l2_pos_
test c.slack_capi#0.Iexport_l2_pos_ = c.slack_capi#1.Iexport_l2_pos_
test c.slack_prof#0.Iexport_l2_pos_ = c.slack_prof#1.Iexport_l2_pos_

*lrtest			control basic


*	Social stripped
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								|| ciiu2d: || id:						///
								, reml
*estimates		store stripped
*	Social basic
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								|| ciiu2d: || id:						///
								, reml
*estimates 		store basic

*lrtest			basic stripped
*	Social with controls
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:						///
								, reml
*estimates		store control
test divergsocventas#0.Isocventas_pos_ = divergsocventas#1.Isocventas_pos_
test divergsocexport#0.Isocexport_pos_ = divergsocexport#1.Isocexport_pos_
test c.slack_capi#0.Isocexport_pos_ = c.slack_capi#1.Isocexport_pos_
test c.slack_prof#0.Isocexport_pos_ = c.slack_prof#1.Isocexport_pos_

*lrtest			control basic

* 3rd findings with restricted maximum likelihood and adjusted SE w/ kroger df
*	Histórico stripped
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)
*estimates		store stripped
*	Histórico 
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)
*estimates		store basic

*lrtest			basic stripped
* 	Histórico with controls
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)
*estimates		store control 
test divergventas_l2_#0.Iventas_l2_pos_ = divergventas_l2_#1.Iventas_l2_pos_
test divergexport_l2_#0.Iexport_l2_pos_ = divergexport_l2_#1.Iexport_l2_pos_
test c.slack_capi#0.Iexport_l2_pos_ = c.slack_capi#1.Iexport_l2_pos_
test c.slack_prof#0.Iexport_l2_pos_ = c.slack_prof#1.Iexport_l2_pos_

*lrtest			control basic								


* 	Social stripped
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)
*estimates		store stripped

								
*	Social basic
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)
*estimates		store basic

*lrtest			basic stripped
*	Social with controls
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)
*estimates		store control 
*lrtest			control basic
test divergsocventas#0.Isocventas_pos_ = divergsocventas#1.Isocventas_pos_
test divergsocexport#0.Isocexport_pos_ = divergsocexport#1.Isocexport_pos_
test c.slack_capi#0.Isocexport_pos_ = c.slack_capi#1.Isocexport_pos_
test c.slack_prof#0.Isocexport_pos_ = c.slack_prof#1.Isocexport_pos_


								
								
								
								
								
								
								
								
								
								
/*			POR AHORA HASTA AQUÍ EL ANÁLISIS
								
								
								
								
								
								
								
********************************************************************************
*Robustness based on the lambas (l1 y l3) and the robust social group mean (_r)
********************************************************************************

*1st robust result - ML
*	Histórico LAMBDA 1
mixed			rawsearch		c.divergventas_l1_#i.Iventas_l1_pos_ 	///
								c.divergexport_l1_#i.Iexport_l1_pos_	///
								slack_capi slack_wage slack_prof		///
								|| ciiu2d: || id:
*	Histórico LAMBDA 3
mixed			rawsearch		c.divergventas_l3_#i.Iventas_l3_pos_ 	///
								c.divergexport_l3_#i.Iexport_l3_pos_	///
								slack_capi slack_wage slack_prof		///
								|| ciiu2d: || id:

* 2nd findings with restricted maximum likelihood
*	Histórico LAMBDA 1
mixed			rawsearch		c.divergventas_l1_#i.Iventas_l1_pos_ 	///
								c.divergexport_l1_#i.Iexport_l1_pos_	///
								slack_capi slack_wage slack_prof		///
								|| ciiu2d: || id:						///
								, reml
*	Histórico LAMBDA 3
mixed			rawsearch		c.divergventas_l3_#i.Iventas_l3_pos_ 	///
								c.divergexport_l3_#i.Iexport_l3_pos_	///
								slack_capi slack_wage slack_prof		///
								|| ciiu2d: || id:						///
								, reml

* 3rd findings with restricted maximum likelihood and adjusted SE w/ kroger df
*	Histórico LAMBDA 1
mixed			rawsearch		c.divergventas_l1_#i.Iventas_l1_pos_ 	///
								c.divergexport_l1_#i.Iexport_l1_pos_	///
								slack_capi slack_wage slack_prof		///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)
*	Histórico LAMBDA 3
mixed			rawsearch		c.divergventas_l3_#i.Iventas_l3_pos_ 	///
								c.divergexport_l3_#i.Iexport_l3_pos_	///
								slack_capi slack_wage slack_prof		///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)

 
***
*1ro Social + Robustness
*		Social
mixed			rawsearch		c.divergsocventas_r_#i.Isocventas_r_pos_	///
								c.divergsocexport_r_#i.Isocexport_r_pos_	///
								slack_capi slack_wage slack_prof 			///
								|| ciiu2d: || id:


*2do Social + Robustness + REML
*		Social
mixed			rawsearch		c.divergsocventas_r_#i.Isocventas_r_pos_	///
								c.divergsocexport_r_#i.Isocexport_r_pos_	///
								slack_capi slack_wage slack_prof 			///
								|| ciiu2d: || id:							///
								, reml


*3ro Social + Robustness + REML + KROGER SE
*		Social
mixed			rawsearch		c.divergsocventas_r_#i.Isocventas_r_pos_	///
								c.divergsocexport_r_#i.Isocexport_r_pos_	///
								slack_capi slack_wage slack_prof 			///
								|| ciiu2d: || id:							///
								, reml  dfmethod(kroger)





*******************************************************************
*Robustness based on the distributional assumption of the model:  *
* USE of the IHS to normalise data empirical distribution 		  *
*******************************************************************

**** TEST 1: lambda 1, lambda 2, and lambda 3 against ML, REML, and REML-KROGER

**>> ML

*L1
mixed			ihs_rawsearch	c.ihs_divergventas_l1_#i.Iventas_l1_pos_ 	///
								c.ihs_divergexport_l1_#i.Iexport_l1_pos_	///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							

*L2
mixed			ihs_rawsearch	c.ihs_divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.ihs_divergexport_l2_#i.Iexport_l2_pos_	///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							
*L3
mixed			ihs_rawsearch	c.ihs_divergventas_l3_#i.Iventas_l3_pos_ 	///
								c.ihs_divergexport_l3_#i.Iexport_l3_pos_	///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							

**>> REML

*L1
mixed			ihs_rawsearch	c.ihs_divergventas_l1_#i.Iventas_l1_pos_ 	///
								c.ihs_divergexport_l1_#i.Iexport_l1_pos_	///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							///
								, reml 

*L2
mixed			ihs_rawsearch	c.ihs_divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.ihs_divergexport_l2_#i.Iexport_l2_pos_	///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							///
								, reml
*L3
mixed			ihs_rawsearch	c.ihs_divergventas_l3_#i.Iventas_l3_pos_ 	///
								c.ihs_divergexport_l3_#i.Iexport_l3_pos_	///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							///
								, reml 




**>> REML + KROGER
*L1
mixed			ihs_rawsearch	c.ihs_divergventas_l1_#i.Iventas_l1_pos_ 	///
								c.ihs_divergexport_l1_#i.Iexport_l1_pos_	///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							///
								, reml dfmethod(kroger)

*L2
mixed			ihs_rawsearch	c.ihs_divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.ihs_divergexport_l2_#i.Iexport_l2_pos_	///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							///
								, reml dfmethod(kroger)
*L3
mixed			ihs_rawsearch	c.ihs_divergventas_l3_#i.Iventas_l3_pos_ 	///
								c.ihs_divergexport_l3_#i.Iexport_l3_pos_	///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							///
								, reml dfmethod(kroger)



**** TEST 2: normal & robust social divergence against ML, REML and REML-KROGER

**>> ML

*Social prom
mixed			ihs_rawsearch	c.ihs_divergsocventas#i.Isocventas_pos_ 	///
								c.ihs_divergsocexport#i.Isocexport_pos_		///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:
*Social robusto
mixed			ihs_rawsearch	c.ihs_divergsocventas_r_#i.Isocventas_r_pos_ ///
								c.ihs_divergsocexport_r_#i.Isocexport_r_pos_ ///
								slack_capi ihs_slack_wage ihs_slack_prof	 ///
								|| ciiu2d: || id:

**>> REML

*Social prom
mixed			ihs_rawsearch	c.ihs_divergsocventas#i.Isocventas_pos_ 	///
								c.ihs_divergsocexport#i.Isocexport_pos_		///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							///
								, reml
*Social robusto
mixed			ihs_rawsearch	c.ihs_divergsocventas_r_#i.Isocventas_r_pos_ ///
								c.ihs_divergsocexport_r_#i.Isocexport_r_pos_ ///
								slack_capi ihs_slack_wage ihs_slack_prof	 ///
								|| ciiu2d: || id:							 ///
								, reml


*Social prom
mixed			ihs_rawsearch	c.ihs_divergsocventas#i.Isocventas_pos_ 	///
								c.ihs_divergsocexport#i.Isocexport_pos_		///
								slack_capi ihs_slack_wage ihs_slack_prof	///
								|| ciiu2d: || id:							///
								, reml dfmethod(kroger)

*Social robusto
mixed			ihs_rawsearch	c.ihs_divergsocventas_r_#i.Isocventas_r_pos_ ///
								c.ihs_divergsocexport_r_#i.Isocexport_r_pos_ ///
								slack_capi ihs_slack_wage ihs_slack_prof	 ///
								|| ciiu2d: || id:							 ///
								, reml dfmethod(kroger)
							