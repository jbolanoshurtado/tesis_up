************************************************************************
* 3er (de 4) do-file: Estimación modelo tesis (INEI: ENIIMESIC - 2018) *
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


*Resultados de la Tabla IV.1:

*	>columna (I.1):
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								|| ciiu2d: || id:
*	>>estadísticos postestimation: 
estimates 		store stripped
test 			divergventas_l2_#0.Iventas_l2_pos_ = ///
				divergventas_l2_#1.Iventas_l2_pos_
test 			divergexport_l2_#0.Iexport_l2_pos_ = ///
				divergexport_l2_#1.Iexport_l2_pos_

*	>columna (I.2):
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								|| ciiu2d: || id:
*	>>estadísticos postestimation:
estimates		store basic
lrtest			basic stripped 
test 			divergventas_l2_#0.Iventas_l2_pos_ = ///
				divergventas_l2_#1.Iventas_l2_pos_
test 			divergexport_l2_#0.Iexport_l2_pos_ = ///
				divergexport_l2_#1.Iexport_l2_pos_
test 			c.slack_capi#0.Iexport_l2_pos_ = ///
				c.slack_capi#1.Iexport_l2_pos_
test 			c.slack_prof#0.Iexport_l2_pos_ = ///
				c.slack_prof#1.Iexport_l2_pos_

*columna (I.3):
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:
*	>>estadísticos postestimation:
estimates		store control
lrtest			control basic 
test 			divergventas_l2_#0.Iventas_l2_pos_ = ///
				divergventas_l2_#1.Iventas_l2_pos_
test 			divergexport_l2_#0.Iexport_l2_pos_ = ///
				divergexport_l2_#1.Iexport_l2_pos_
test 			c.slack_capi#0.Iexport_l2_pos_ = ///
				c.slack_capi#1.Iexport_l2_pos_
test 			c.slack_prof#0.Iexport_l2_pos_ = ///
				c.slack_prof#1.Iexport_l2_pos_


*Resultados de la Tabla IV.2:
*	>columna (II.1):
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								|| ciiu2d: || id:
*	>>estadísticos postestimation:
estimates		store stripped
test 			divergsocventas#0.Isocventas_pos_ = ///
				divergsocventas#1.Isocventas_pos_
test 			divergsocexport#0.Isocexport_pos_ = ///
				divergsocexport#1.Isocexport_pos_

*	>columna (II.2):
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								|| ciiu2d: || id:
*	>>estadísticos postestimation:
estimates		store basic 
lrtest			basic stripped
test 			divergsocventas#0.Isocventas_pos_ = ///
				divergsocventas#1.Isocventas_pos_
test 			divergsocexport#0.Isocexport_pos_ = ///
				divergsocexport#1.Isocexport_pos_
test 			c.slack_capi#0.Isocexport_pos_ = ///
				c.slack_capi#1.Isocexport_pos_
test 			c.slack_prof#0.Isocexport_pos_ = ///
				c.slack_prof#1.Isocexport_pos_

*	>columna (II.3):
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:
*	>>estadísticos postestimation:
estimates		store control 
lrtest			control basic
test 			divergsocventas#0.Isocventas_pos_ = ///
				divergsocventas#1.Isocventas_pos_
test 			divergsocexport#0.Isocexport_pos_ = ///
				divergsocexport#1.Isocexport_pos_
test 			c.slack_capi#0.Isocexport_pos_ = ///
				c.slack_capi#1.Isocexport_pos_
test 			c.slack_prof#0.Isocexport_pos_ = ///
				c.slack_prof#1.Isocexport_pos_

*


*Resultados mediante máxima verosimilitud restringida: Tabla IV.3
* (Requiere STATA 16)

*		>columna (I.3.a)
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:						///
								, reml
*	>>estadísticos postestimation:
test 			divergventas_l2_#0.Iventas_l2_pos_ = ///
				divergventas_l2_#1.Iventas_l2_pos_
test 			divergexport_l2_#0.Iexport_l2_pos_ = ///
				divergexport_l2_#1.Iexport_l2_pos_
test 			c.slack_capi#0.Iexport_l2_pos_ = ///
				c.slack_capi#1.Iexport_l2_pos_
test 			c.slack_prof#0.Iexport_l2_pos_ = ///
				c.slack_prof#1.Iexport_l2_pos_

*Resultados mediante máxima verosimilitud restringida: Tabla IV.4
* (Requiere STATA 16)

*		>columna (II.3.a)
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:						///
								, reml
*	>>estadísticos postestimation:
test 			divergsocventas#0.Isocventas_pos_ = ///
				divergsocventas#1.Isocventas_pos_
test 			divergsocexport#0.Isocexport_pos_ = ///
				divergsocexport#1.Isocexport_pos_
test 			c.slack_capi#0.Isocexport_pos_ = ///
				c.slack_capi#1.Isocexport_pos_
test 			c.slack_prof#0.Isocexport_pos_ = ///
				c.slack_prof#1.Isocexport_pos_


*Resultados mediante método de Kenward-Roger: Tabla IV.3
* (Requiere STATA 16)

*		>columna (I.3.b)
mixed			rawsearch		c.divergventas_l2_#i.Iventas_l2_pos_ 	///
								c.divergexport_l2_#i.Iexport_l2_pos_	///
								c.slack_capi#i.Iexport_l2_pos_			///
								c.slack_prof#i.Iexport_l2_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)
*	>>estadísticos postestimation:
test 			divergventas_l2_#0.Iventas_l2_pos_ = ///
				divergventas_l2_#1.Iventas_l2_pos_
test 			divergexport_l2_#0.Iexport_l2_pos_ = ///
				divergexport_l2_#1.Iexport_l2_pos_
test 			c.slack_capi#0.Iexport_l2_pos_ = ///
				c.slack_capi#1.Iexport_l2_pos_
test 			c.slack_prof#0.Iexport_l2_pos_ = ///
				c.slack_prof#1.Iexport_l2_pos_


*Resultados mediante método de Kenward-Roger: Tabla IV.4
* (Requiere STATA 16)

*		>columna (II.3.b)
mixed			rawsearch		c.divergsocventas#i.Isocventas_pos_		///
								c.divergsocexport#i.Isocexport_pos_		///
								c.slack_capi#i.Isocexport_pos_			///
								c.slack_prof#i.Isocexport_pos_			///
								slack_wage capita produc y_oper			///
								|| ciiu2d: || id:						///
								, reml dfmethod(kroger)
*	>>estadísticos postestimation:
test 			divergsocventas#0.Isocventas_pos_ = ///
				divergsocventas#1.Isocventas_pos_
test 			divergsocexport#0.Isocexport_pos_ = ///
				divergsocexport#1.Isocexport_pos_
test 			c.slack_capi#0.Isocexport_pos_ = ///
				c.slack_capi#1.Isocexport_pos_
test 			c.slack_prof#0.Isocexport_pos_ = ///
				c.slack_prof#1.Isocexport_pos_


*Fin del 3er do-file: estimación del modelo - tesis*								
