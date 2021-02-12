************************************************************************
* 4to (de 4) do-file: Sensibilidad estimaciones(INEI: ENIIMESIC -2018) *
************************************************************************

/*
Autor: 		Jean Pierre Bolaños, Universidad del Pacífico (Lima)
Parte de: 	Tesis de Licenciatura para optar por el título profesional 
			 en Negocios Internacionales
Año: 		2021
*/

clear 			all
set more		off, perm
set type		double, perm

*Dirección de carpetas de trabajo para 
* 1) base de datos original del INEI
gl				a "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\0-bbdd iniciales"
* 2) trabajo sobre la base de datos
gl				b "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\1-bbdd intermedias"
* 3) base de datos final para estimar el modelo
gl				c "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\2-bbdd finales"

*abrimos bbdd resultante del 2do do-file (long-shaped ddbb) .dta
u			"$c\long_ddbb_eniim2018.dta", clear


********************************************************************************
* Nota: estimación mediante máxima verosimilitud y máxima verosimilitud 
*			restringida puede ser ejecutado en versiones previas a STATA 16 SE
* Nota: estimar con el método de ajuste SE y df/ddf por tamaño pequeño de
*			muestra via método de Kenward-Roger solo es posible 
*				en STATA 16 SE versiones superiores
********************************************************************************


*Resultados Tabla IV.5
*	>columna (I.3):
mixed			rawsearch		c.divergventas_l1_#i.Iventas_l1_pos_ 	///
								c.divergexport_l1_#i.Iexport_l1_pos_	///
								c.slack_capi#i.Iexport_l1_pos_			///
								c.slack_prof#i.Iexport_l1_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:
*	>>postestimation stats
test 			divergventas_l1_#0.Iventas_l1_pos_ = 	///
				divergventas_l1_#1.Iventas_l1_pos_
test 			divergexport_l1_#0.Iexport_l1_pos_ = 	///
				divergexport_l1_#1.Iexport_l1_pos_
test 			c.slack_capi#0.Iexport_l1_pos_ = 		///
				c.slack_capi#1.Iexport_l1_pos_
test 			c.slack_prof#0.Iexport_l1_pos_ = 		///
				c.slack_prof#1.Iexport_l1_pos_

*	>columna (I.3.a):
mixed			rawsearch		c.divergventas_l1_#i.Iventas_l1_pos_ 	///
								c.divergexport_l1_#i.Iexport_l1_pos_	///
								c.slack_capi#i.Iexport_l1_pos_			///
								c.slack_prof#i.Iexport_l1_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:, reml
*	>>postestimation stats
test 			divergventas_l1_#0.Iventas_l1_pos_ = 	///
				divergventas_l1_#1.Iventas_l1_pos_
test 			divergexport_l1_#0.Iexport_l1_pos_ = 	///
				divergexport_l1_#1.Iexport_l1_pos_
test 			c.slack_capi#0.Iexport_l1_pos_ = 		///
				c.slack_capi#1.Iexport_l1_pos_
test 			c.slack_prof#0.Iexport_l1_pos_ = 		///
				c.slack_prof#1.Iexport_l1_pos_

*	>columna (I.3.b):
mixed			rawsearch		c.divergventas_l1_#i.Iventas_l1_pos_ 	///
								c.divergexport_l1_#i.Iexport_l1_pos_	///
								c.slack_capi#i.Iexport_l1_pos_			///
								c.slack_prof#i.Iexport_l1_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:, reml dfmethod(kroger)
*	>>postestimation stats
test 			divergventas_l1_#0.Iventas_l1_pos_ = 	///
				divergventas_l1_#1.Iventas_l1_pos_
test 			divergexport_l1_#0.Iexport_l1_pos_ = 	///
				divergexport_l1_#1.Iexport_l1_pos_
test 			c.slack_capi#0.Iexport_l1_pos_ =		///
				c.slack_capi#1.Iexport_l1_pos_
test 			c.slack_prof#0.Iexport_l1_pos_ = 		///
				c.slack_prof#1.Iexport_l1_pos_



*Resultados Tabla IV.6
*	>columna (I.3):
mixed			rawsearch		c.divergventas_l3_#i.Iventas_l3_pos_ 	///
								c.divergexport_l3_#i.Iexport_l3_pos_	///
								c.slack_capi#i.Iexport_l3_pos_			///
								c.slack_prof#i.Iexport_l3_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:
*	>>postestimation stats
test 			divergventas_l3_#0.Iventas_l3_pos_ = 	///
				divergventas_l3_#1.Iventas_l3_pos_
test 			divergexport_l3_#0.Iexport_l3_pos_ = 	///
				divergexport_l3_#1.Iexport_l3_pos_
test 			c.slack_capi#0.Iexport_l3_pos_ = 		///
				c.slack_capi#1.Iexport_l3_pos_
test 			c.slack_prof#0.Iexport_l3_pos_ = 		///
				c.slack_prof#1.Iexport_l3_pos_

*	>columna (I.3.a):
mixed			rawsearch		c.divergventas_l3_#i.Iventas_l3_pos_ 	///
								c.divergexport_l3_#i.Iexport_l3_pos_	///
								c.slack_capi#i.Iexport_l3_pos_			///
								c.slack_prof#i.Iexport_l3_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:, reml
*	>>postestimation stats
test 			divergventas_l3_#0.Iventas_l3_pos_ = 	///
				divergventas_l3_#1.Iventas_l3_pos_
test 			divergexport_l3_#0.Iexport_l3_pos_ = 	///
				divergexport_l3_#1.Iexport_l3_pos_
test 			c.slack_capi#0.Iexport_l3_pos_ = 		///
				c.slack_capi#1.Iexport_l3_pos_
test 			c.slack_prof#0.Iexport_l3_pos_ = 		///
				c.slack_prof#1.Iexport_l3_pos_

*	>columna (I.3.b):
mixed			rawsearch		c.divergventas_l3_#i.Iventas_l3_pos_ 	///
								c.divergexport_l3_#i.Iexport_l3_pos_	///
								c.slack_capi#i.Iexport_l3_pos_			///
								c.slack_prof#i.Iexport_l3_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:, reml dfmethod(kroger)
*	>>postestimation stats
test 			divergventas_l3_#0.Iventas_l3_pos_ = 	///
				divergventas_l3_#1.Iventas_l3_pos_
test 			divergexport_l3_#0.Iexport_l3_pos_ = 	///
				divergexport_l3_#1.Iexport_l3_pos_
test 			c.slack_capi#0.Iexport_l3_pos_ = 		///
				c.slack_capi#1.Iexport_l3_pos_
test 			c.slack_prof#0.Iexport_l3_pos_ = 		///
				c.slack_prof#1.Iexport_l3_pos_


				
*Resultados Taba IV.7
*	>columna (II.3):
mixed			rawsearch		c.divergsocventas_r_#i.Isocventas_r_pos_		///
								c.divergsocexport_r_#i.Isocexport_r_pos_		///
								c.slack_capi#i.Isocexport_r_pos_			///
								c.slack_prof#i.Isocexport_r_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:
*	>>postestimation stats
test 			divergsocventas_r_#0.Isocventas_r_pos_ = 	///
				divergsocventas_r_#1.Isocventas_r_pos_
test 			divergsocexport_r_#0.Isocexport_r_pos_ = 	///
				divergsocexport_r_#1.Isocexport_r_pos_
test 			c.slack_capi#0.Isocexport_r_pos_ = 			///
				c.slack_capi#1.Isocexport_r_pos_
test 			c.slack_prof#0.Isocexport_r_pos_ = 			///
				c.slack_prof#1.Isocexport_r_pos_

*	>columna (II.3.a):
mixed			rawsearch		c.divergsocventas_r_#i.Isocventas_r_pos_		///
								c.divergsocexport_r_#i.Isocexport_r_pos_		///
								c.slack_capi#i.Isocexport_r_pos_			///
								c.slack_prof#i.Isocexport_r_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:, reml
*	>>postestimation stats								
test 			divergsocventas_r_#0.Isocventas_r_pos_ = 	///
				divergsocventas_r_#1.Isocventas_r_pos_
test 			divergsocexport_r_#0.Isocexport_r_pos_ = 	///
				divergsocexport_r_#1.Isocexport_r_pos_
test 			c.slack_capi#0.Isocexport_r_pos_ = 			///
				c.slack_capi#1.Isocexport_r_pos_
test 			c.slack_prof#0.Isocexport_r_pos_ = 			///
				c.slack_prof#1.Isocexport_r_pos_

*	>columna (II.3.b):
mixed			rawsearch		c.divergsocventas_r_#i.Isocventas_r_pos_		///
								c.divergsocexport_r_#i.Isocexport_r_pos_		///
								c.slack_capi#i.Isocexport_r_pos_			///
								c.slack_prof#i.Isocexport_r_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:, reml dfmethod(kroger)
*	>>postestimation stats	
test 			divergsocventas_r_#0.Isocventas_r_pos_ = 	///
				divergsocventas_r_#1.Isocventas_r_pos_
test 			divergsocexport_r_#0.Isocexport_r_pos_ = 	///
				divergsocexport_r_#1.Isocexport_r_pos_
test 			c.slack_capi#0.Isocexport_r_pos_ = 			///
				c.slack_capi#1.Isocexport_r_pos_
test 			c.slack_prof#0.Isocexport_r_pos_ = 			///
				c.slack_prof#1.Isocexport_r_pos_

