*******************************************************************
* 2do (de 4) do-file: revisión variables (INEI: ENIIMESIC - 2018) *
*******************************************************************

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

*usamos bbdd resultante del 1er do-file
u				"$b\bbdd2018_limpia.dta", clear

*corregimos codificación errónea de missing value:
recode			produc17 (999=99) if produc17==999

*creamos var. dicot. para subpoblación de empresas exportadoras manufactureras
gen				i=1
label var		i "subpoblación: empresa exportadora manufacturera"
label def		i 1 "Sí" 0 "No" 
label val		i i

*Cambio la variable sector a variable dicot. que indique directamente si la 
* empresa es manufacturera o no (1: manufactura, 0: servicios)
recode			sector (0=1) (1=0) // antes-> 0: manufactura y 1: servicios
label val		sector dicot
rename			sector manufactura
label var		manufactura "Sector manufactura"

*restamos empresas cuyo año inicial de operación es 2015
recode			i (1=0) if y_oper==4 // -23 que recien empiezan operaciones

*restamos a las "personas naturales"
recode			i (1=0) if tipo_org == 1 // -42 "personas naturales"

*corrección: empresas indican que sí innovan pero no gastan en innovación
gen				contraste = 0
recode			contraste (0=1) if	idint==1 | idext==1 | ingdi==1 | ///
									mktng==1 | propi==1 | capac==1 | ///
									softw==1 | capit==1
tab2			innovo1 contraste //ok
foreach 		x in 15 16 17 {
egen			gasto_rd_20`x' = rowtotal(idint`x' idext`x' ingdi`x' ///
										  mktng`x' propi`x' capac`x' ///
										  softw`x' capit`x')
label var		gasto_rd_20`x' "Gasto total en I+D en 20`x'"
}
recode			contraste (1=0) if 	gasto_rd_2015==0 & gasto_rd_2016==0 & ///
									gasto_rd_2017==0
tab2			innovo1 contraste // 3 empresas inconsistentes
recode			i (1=0) if innovo1==1 & contraste==0 // -3 empresas
recode			i (1=0) if contraste==0 // 903 empresas no búscan via innovación

*restamos empresas sin ventas
recode			i (1=0) if ventas15 ==0 | ventas16==0 | ventas17==0 // -2 obs

*genero coeficiente de exportación para id. emp. exportadoras
foreach			x in 15 16 17{
gen				coef_exp_20`x' = export`x'/ventas`x' 
label var		coef_exp_20`x' "coeficiente de exportación"
}
tabstat			coef_* if i==1, c(s) s(n me p10 q p90 max)
replace			ventas15 = export15 if coef_exp_2015 > 1 & i ==1
replace			coef_exp_2015 = 1 if coef_exp_2015 > 1 & i==1
replace			ventas16 = export16 if coef_exp_2016 > 1 & i==1
replace			coef_exp_2016 = 1 if coef_exp_2016 > 1 & i==1 

*número de exportadores
count			if coef_exp_2015>0 & i==1 // 434 obs de 1111
count			if coef_exp_2016>0 & i==1 // 447 obs de 1111
count			if coef_exp_2017>0 & i==1 // 448 obs de 1111
count			if coef_exp_2015>0 & coef_exp_2016>0 & coef_exp_2017>0 & i==1 
// -> 455 exportadores continuos

*definimos subpoblación con exportadores continuos
recode			i (1=2) if 	coef_exp_2015>0 & coef_exp_2016>0 & coef_exp_2017>0 
label drop		i
label def		i 0 "no cumple" 1 "sí cumple no export" 2 "si cumple si export"
label val		i i
label var		i "cat. indica si la empresa cumple con el criterio"

*revisamos quienes son los que quedan
tab1 			ciiu2d if i==2
tab1			ciiu2d  if i==2, nol
tab1 			manufactura  if i==2

*drop industrias con 3 o menos observaciones
recode			i (2=0) if ciiu2d==30 | ciiu2d== 33 | ciiu2d==72  // -6 empresas

*generamos variable directa dicotómica que indica la subpoblación de interés
gen				j = 0
recode			j (0=1) if i==2
label def		j 0 "no cumple" 1 "sí cumple"
label var		j "la empresa gasta en innovación y exporta"
label val		j j

*declaramos diseño estratificado de la muestra
svyset 			id [pweight=FACTOR_FINAL], 	strata(ciiu2d) vce(linearized) ///
											singleunit(missing)

*generamos tablas para la redacción de la tesis
*	TABLA III.1:
tab1			manufactura
svy 			linearized : tabulate manufactura
tab1 			ciiu2d if manufactura==1
svy 			linearized : tabulate ciiu2d if manufactura==1
*	Tabla III.2
tab1			manufactura if j==1
svy,			subpop(j):  tabulate manufactura 
tab1			ciiu2d if manufactura==1 & j==1
svy,			subpop(j): tabulate ciiu2d if manufactura==1

*generamos variables del mecanismo comportamental por año:
*	>desempeño ventas 2015, 2016, 2017
foreach 		x in 15 16 17 {
gen				desventas`x' = .
label var		desventas`x' "Desempeño en ventas 20`x'"
replace			desventas`x' = ventas`x'
}
*	>objetivo de ventas 2016 (Aspiración natural)
gen				objdesventas16 = .
label var		objdesventas16 "Objetivo de desempeño en ventas 2016"
replace			objdesventas16 = desventas15
*	>divergencia en desempeño de ventas 2016 (Aspiración natural)
gen				divergventas16 = .
label var		divergventas16 "Divergencia desempeño ventas - objetivo ventas 2016"
replace			divergventas16 = desventas16 - objdesventas16
*	>spline indicators de desempeño satisfactorio/insatisfactorio (Iij)
gen				Iventas16_pos = .
label var		Iventas16_pos "La divergencia de ventas es satisfactoria en 2016"
recode			Iventas16_pos (.=1) if divergventas16 > 0
recode			Iventas16_pos (.=0) 
label def		Iventas16_pos 1 "satisfactorio" 0 "insatisfactorio"
label val		Iventas16_pos Iventas16_pos
gen				Iventas16_neg =.
label var		Iventas16_neg "La divergencia de ventas es insatisfactoria en 2016"
recode			Iventas16_neg (.=1) if divergventas16<=0
recode			Iventas16_neg (.=0) //resto de satisfactorias
label def		Iventas16_neg 1 "insatisfactorio" 0 "satisfactorio"
label val		Iventas16_neg Iventas16_neg
*cross-check
pwcorr		Iventas16_pos Iventas16_neg //debe ser -1 exactamente (es inversa)

*	>Objetivo de ventas 2017 (Histórico)
*		Tres lambdas:
*			--> l1 = 0.25 : faster update
*			--> l2 = 0.50 : medium update
*			--> l3 = 0.75 : slower update
gen				objdesventas17_l1=.
gen				objdesventas17_l2=.
gen				objdesventas17_l3=.
label var		objdesventas17_l1 "Objetivo de desempeño en ventas 2017 (fast)"
label var		objdesventas17_l2 "Objetivo de desempeño en ventas 2017 (avg)"
label var		objdesventas17_l3 "Objetivo de desempeño en ventas 2017 (slow)"
replace			objdesventas17_l1 = 0.25*objdesventas16 + 0.75*desventas16
replace			objdesventas17_l2 = 0.50*objdesventas16 + 0.50*desventas16
replace			objdesventas17_l3 = 0.75*objdesventas16 + 0.25*desventas16
*	>Divergencia de ventas 2017 (Histórico)
*		Tres lambdas.
gen				divergventas17_l1 =.
gen				divergventas17_l2 =.
gen				divergventas17_l3 =.
label var		divergventas17_l1 "Divergencia desempeño ventas - objetivo ventas 2017 (fast)"
label var		divergventas17_l2 "Divergencia desempeño ventas - objetivo ventas 2017 (avg)"
label var		divergventas17_l3 "Divergencia desempeño ventas - objetivo ventas 2017 (slow)"
replace			divergventas17_l1 = desventas17 - objdesventas17_l1
replace			divergventas17_l2 = desventas17 - objdesventas17_l2
replace			divergventas17_l3 = desventas17 - objdesventas17_l3
*Spline indicators de desempeño satisfactorio/insatisfactorio para tres lambdas
*	(Iij) by l1 (fast update), l2 (avg update), & l3 (slow update)
*		>>> Para l1: 0.25 (fast updating of objectives)
gen				Iventas17_l1_pos = .
label var		Iventas17_l1_pos "Para l1: la divergencia de ventas es satisfactoria 2017"
recode			Iventas17_l1_pos (.=1) if divergventas17_l1 > 0
recode			Iventas17_l1_pos (.=0) //resto de insatisfactorias
label def		Iventas17_l1_pos 1 "satisfactorio" 0 "insatisfactorio"
label val		Iventas17_l1_pos Iventas17_l1_pos
gen				Iventas17_l1_neg =.
label var		Iventas17_l1_neg "Para l1: la divergencia de ventas es insatisfactoria 2017"
recode			Iventas17_l1_neg (.=1) if divergventas17_l1<=0
recode			Iventas17_l1_neg (.=0) //resto de satisfactorias
label def		Iventas17_l1_neg 1 "insatisfactorio" 0 "satisfactorio"
label val		Iventas17_l1_neg Iventas17_l1_neg
*cross-check
pwcorr			Iventas17_l1_pos Iventas17_l1_neg //debe ser -1 exactamente (es inversa)

*		>>> Para l2: 0.50 (avg updating of objectives)
gen				Iventas17_l2_pos = .
label var		Iventas17_l2_pos "Para l2: la divergencia de ventas es satisfactoria 2017"
recode			Iventas17_l2_pos (.=1) if divergventas17_l2 > 0
recode			Iventas17_l2_pos (.=0) //resto de insatisfactorias
label def		Iventas17_l2_pos 1 "satisfactorio" 0 "insatisfactorio"
label val		Iventas17_l2_pos Iventas17_l2_pos
gen				Iventas17_l2_neg =.
label var		Iventas17_l2_neg "Para l2: la divergencia de ventas es insatisfactoria 2017"
recode			Iventas17_l2_neg (.=1) if divergventas17_l2<=0
recode			Iventas17_l2_neg (.=0) //resto de satisfactorias
label def		Iventas17_l2_neg 1 "insatisfactorio" 0 "satisfactorio"
label val		Iventas17_l2_neg Iventas17_l2_neg
*cross-check
pwcorr		Iventas17_l2_pos Iventas17_l2_neg //debe ser -1 exactamente (es inversa)

*		>>> Para l3: 0.75 (slow updating of objetives)
gen				Iventas17_l3_pos = .
label var		Iventas17_l3_pos "Para l3: la divergencia de ventas es satisfactoria 2017"
recode			Iventas17_l3_pos (.=1) if divergventas17_l3 > 0
recode			Iventas17_l3_pos (.=0) //resto de insatisfactorias
label def		Iventas17_l3_pos 1 "satisfactorio" 0 "insatisfactorio"
label val		Iventas17_l3_pos Iventas17_l3_pos
gen				Iventas17_l3_neg =.
label var		Iventas17_l3_neg "Para l3: la divergencia de ventas es insatisfactoria 2017"
recode			Iventas17_l3_neg (.=1) if divergventas17_l3<=0
recode			Iventas17_l3_neg (.=0) //resto de satisfactorias
label def		Iventas17_l3_neg 1 "insatisfactorio" 0 "satisfactorio"
label val		Iventas17_l3_neg Iventas17_l3_neg
*cross-check
pwcorr		Iventas17_l3_pos Iventas17_l3_neg //debe ser -1 exactamente (es inversa)

*generamos objetivo de desempeño de ventas social (2015,16,17)
*Generamos promedios de ventas por cada industria por año
foreach 		x in 15 16 17{
bysort 			ciiu2d:	egen 	objsocventas`x' = mean(desventas`x')
label var		objsocventas`x' "Objetivo social de desempeño en ventas 20`x' x ind"
}
*Generamos medianas de ventas por cada industria por año (robusto contra outliers)
foreach			x in 15 16 17{
bysort			ciiu2d: egen	objsocventas`x'_r = median(desventas`x')
label var		objsocventas`x'_r "Robusto: Obj social de desempeño en ventas 20`x' x ind"
}
*generamos divergencia de desempeño social x años x empresa
*Medición normal
foreach			x in 15 16 17{
gen				divergsocventas`x' =.
replace			divergsocventas`x' = desventas`x' - objsocventas`x' 
label var		divergsocventas`x' "Divergencia desempeño social ventas 20`x'"
}
*Medición robusta
foreach			x in 15 16 17{
gen				divergsocventas`x'_r =.
replace			divergsocventas`x'_r = desventas`x' - objsocventas`x'_r 
label var		divergsocventas`x'_r "ROBUSTO: Divergencia desempeño social ventas 20`x'"
}

*indicador de divergencia de desempeño social como satisfactorio o insatisfactorio
*Normal(promedios)
foreach			x in 15 16 17{
gen				Isocventas`x'_pos =.
label var		Isocventas`x'_pos "Divergencia social satisfactoria en ventas 20`x'"
recode			Isocventas`x'_pos (.=1) if divergsocventas`x'>0
recode			Isocventas`x'_pos (.=0) // insatisfactorias sociales x año
label def		Isocventas`x'_pos 1 "satisfactorio" 0 "insatisfactorio"
label val		Isocventas`x'_pos Isocventas`x'_pos
gen				Isocventas`x'_neg =.
label var		Isocventas`x'_neg "Divergencia social insatisfacotria en ventas 20`x'"
recode			Isocventas`x'_neg (.=1) if divergsocventas`x' <=0
recode			Isocventas`x'_neg (.=0) //satisfactorias
label def		Isocventas`x'_neg 1 "insatisfactorias" 0 "satisfactorias"
label val		Isocventas`x'_neg Isocventas`x'_neg
*cross-check
pwcorr		Isocventas`x'_pos Isocventas`x'_neg //debe ser -1 exactamente (es inversa)
}
*Robusto (medianas)
foreach			x in 15 16 17{
gen				Isocventas`x'_r_pos =.
label var		Isocventas`x'_r_pos "Robust: divergencia social satisfactoria en ventas 20`x'"
recode			Isocventas`x'_r_pos (.=1) if divergsocventas`x'_r>0
recode			Isocventas`x'_r_pos (.=0) // insatisfactorias sociales x año
label def		Isocventas`x'_r_pos 1 "satisfactorio" 0 "insatisfactorio"
label val		Isocventas`x'_r_pos Isocventas`x'_r_pos
gen				Isocventas`x'_r_neg =.
label var		Isocventas`x'_r_neg "Robust: divergencia social insatisfacotria en ventas 20`x'"
recode			Isocventas`x'_r_neg (.=1) if divergsocventas`x'_r <=0
recode			Isocventas`x'_r_neg (.=0) //satisfactorias
label def		Isocventas`x'_r_neg 1 "insatisfactorias" 0 "satisfactorias"
label val		Isocventas`x'_r_neg Isocventas`x'_r_neg
*cross-check
pwcorr			Isocventas`x'_r_pos Isocventas`x'_r_neg //debe ser -1 exactamente (es inversa)
}

*generamos desempeño observado de las exportaciones por años
*	>Desempeño nominal
foreach			x in 15 16 17{
gen				desexport`x' =.
replace			desexport`x' = export`x' if j==1 & manufactura==1 //solo la subpoblación
label var		desexport`x' "Desempeño en exportaciones 20`x'"
}

*aspiración natural 2016 exportaciones 
gen				objdesexport16 =.
label var		objdesexport16 "Objetivo de desempeño de exportaciones 2016"
replace			objdesexport16 = desexport15 if j==1 & manufactura==1 //aspiración nat

*divergencias en desempeño de exportaciones (asp. nat.)
gen				divergexport16=.
label var		divergexport16 "Divergencia desempeño export-objetivo export 2016"
replace			divergexport16 = desexport16 - objdesexport16 if j==1 & manufactura==1

*Spline indicators para desempeño (in)satisfactorio de exportaciones 2016
gen 			Iexport16_pos=.
label var		Iexport16_pos "La divergencia de export es satisfactoria en 2016"
recode			Iexport16_pos (.=1) if divergexport16 > 0 & divergexport16 !=.
recode			Iexport16_pos (.=0) if divergexport16 <= 0 & divergexport16 !=. //resto
label def		Iexport16_pos 1 "satisfactorio" 0 "insatisfactorio"
label val		Iexport16_pos Iexport16_pos 
gen				Iexport16_neg=.
label var		Iexport16_neg "La divergencia de export es insatisfactoria en 2016"
recode			Iexport16_neg (.=1) if divergexport16 <=0 & divergexport16!=.
recode			Iexport16_neg (.=0) if divergexport16 > 0 & divergexport16!=.
label def		Iexport16_neg  1 "insatisfactorio" 0 "satisfactorio"
label val		Iexport16_neg Iexport16_neg 
*>> cross-check
pwcorr			Iexport16_pos Iexport16_neg 

*generamos objetivo histórico de exportación 2017 (tres lambdas)
*	tres lambdas
*		--> l1=0.25 : fast update
*		--> l2=0.50 : avg  update
*		--> l3=0.75 : slow update
gen				objdesexport17_l1 =.
gen				objdesexport17_l2 =.
gen				objdesexport17_l3 =.
label var		objdesexport17_l1 "Objetivo de desempeño en export 2017 (fast)"
label var		objdesexport17_l2 "Objetivo de desempeño en export 2017 (avg)"
label var		objdesexport17_l3 "Objetivo de desempeño en export 2017 (slow)"
replace			objdesexport17_l1 = 0.25*objdesexport16 + 0.75*desexport16 ///
					if j==1 & manufactura==1
replace			objdesexport17_l2 = 0.50*objdesexport16 + 0.50*desexport16 ///
					if j==1 & manufactura==1
replace			objdesexport17_l3 = 0.75*objdesexport16 + 0.25*desexport16 ///
					if j==1 & manufactura==1

*Divergencia en exportaciones (histórico)
*		tres lambdas
gen				divergexport17_l1=.
gen				divergexport17_l2=.
gen				divergexport17_l3=.
label var		divergexport17_l1 "Divergencia desemp export - obj export 2017 (fast)"
label var		divergexport17_l2 "Divergencia desemp export - obj export 2017 (avg)"
label var		divergexport17_l3 "Divergencia desemp export - obj export 2017 (slow)"
replace			divergexport17_l1 = desexport17 - objdesexport17_l1 ///
					if j==1 & manufactura==1
replace			divergexport17_l2 = desexport17 - objdesexport17_l2 ///
					if j==1 & manufactura==1
replace			divergexport17_l3 = desexport17 - objdesexport17_l3 ///
					if j==1 & manufactura==1
				
*def etiqueta p/ satisfactorio e insatisfactorio
label def		lbl_satis 1 "Satisfactorio" 0 "Insatisfactorio"
label def		lbl_unsat 1 "Insatisfactorio" 0 "Satisfactorio"

*Spline specification (lambda 1 de 3) export l1 (fast)
gen				Iexport17_l1_pos =.
label var		Iexport17_l1_pos "Para l1: la divergencia de exportaciones es satisfactoria en 2017"
recode			Iexport17_l1_pos (.=1) if divergexport17_l1 > 0 & j==1 & manufactura==1
recode			Iexport17_l1_pos (.=0) if divergexport17_l1 <=0 & j==1 & manufactura==1
label val		Iexport17_l1_pos lbl_satis
gen				Iexport17_l1_neg =.
label var		Iexport17_l1_neg "Para l1: la divergencia de exportaciones insatisfactoria en 2017"
recode			Iexport17_l1_neg (.=1) if divergexport17_l1 <=0 & j==1 & manufactura==1
recode			Iexport17_l1_neg (.=0) if divergexport17_l1 > 0 & j==1 & manufactura==1
label val		Iexport17_l1_neg lbl_unsat
*>> crosscheck
pwcorr			Iexport17_l1_pos Iexport17_l1_neg // debe ser -1

*Spline specification (lambda 2 de 3) export l2 (avg)
gen				Iexport17_l2_pos =.
label var		Iexport17_l2_pos "Para l2: la divergencia de exportaciones es satisfactoria en 2017"
recode			Iexport17_l2_pos (.=1) if divergexport17_l2 > 0 & j==1 & manufactura==1
recode			Iexport17_l2_pos (.=0) if divergexport17_l2 <=0 & j==1 & manufactura==1
label val		Iexport17_l2_pos lbl_satis
gen				Iexport17_l2_neg =.
label var		Iexport17_l2_neg "Para l2: la divergencia de exportaciones insatisfactoria en 2017"
recode			Iexport17_l2_neg (.=1) if divergexport17_l2 <=0 & j==1 & manufactura==1
recode			Iexport17_l2_neg (.=0) if divergexport17_l2 > 0 & j==1 & manufactura==1
label val		Iexport17_l2_neg lbl_unsat
*>> crosscheck
pwcorr			Iexport17_l2_pos Iexport17_l2_neg // debe ser -1

*Spline specification (lambda 3 of 3) export l3 (slow)
gen				Iexport17_l3_pos =.
label var		Iexport17_l3_pos "Para l3: la divergencia de exportaciones es satisfactoria en 2017"
recode			Iexport17_l3_pos (.=1) if divergexport17_l3 > 0 & j==1 & manufactura==1
recode			Iexport17_l3_pos (.=0) if divergexport17_l3 <=0 & j==1 & manufactura==1
label val		Iexport17_l3_pos lbl_satis
gen				Iexport17_l3_neg =.
label var		Iexport17_l3_neg "Para l3: la divergencia de exportaciones insatisfactoria en 2017"
recode			Iexport17_l3_neg (.=1) if divergexport17_l3 <=0 & j==1 & manufactura==1
recode			Iexport17_l3_neg (.=0) if divergexport17_l3 > 0 & j==1 & manufactura==1
label val		Iexport17_l3_neg lbl_unsat

*>> crosscheck
pwcorr			Iexport17_l3_pos Iexport17_l3_neg // debe ser -1







*generamos objetivo de exportación social 2015, 2016 y 2017
*	>generamos promedios de exportación por industria
foreach			x in 15 16 17{
bysort			ciiu2d: egen		countexp`x' = count(desexport`x')
bysort			ciiu2d: egen		totalexp`x' = total(desexport`x')
gen				objsocexport`x' = totalexp`x' / countexp`x'
replace			objsocexport`x'=. if j!=1 | manufactura!=1
label var		objsocexport`x' "Objetivo social de exportación por industria en 20`x'"
drop			countexp`x' totalexp`x'
}

*	>generamos promedios robustos (medianas) de exportación x ind.
foreach			x in 15 16 17{
bysort			ciiu2d: egen		objsocexport`x'_r = median(desexport`x')
replace			objsocexport`x'_r =. if j!=1 | manufactura!=1
label var		objsocexport`x'_r "Robusto: objetivo social de exportación x ind. en 20`x'"
}

*	>generamos divergencias x año x empresa (1 of 2): export normal 
foreach			x in 15 16 17{
gen				divergsocexport`x' =.
replace			divergsocexport`x' = desexport`x' - objsocexport`x'
label var		divergsocexport`x' "Divergencia desempeño social export 20`x'"
}
* Cálculo de divergencias x año x empresa (2 of 2): export robusto
foreach			x in 15 16 17{
gen				divergsocexport`x'_r =.
replace			divergsocexport`x'_r = desexport`x' - objsocexport`x'_r
label var		divergsocexport`x'_r "Robusto: divergencia desempeño social export 20`x'"
}

*Indicadores de desempeño en exportaciones satisfactorio/insatisfactorio
*>>1 of 2: exportación normal (satis + insatis)
foreach			x in 15 16 17{
gen				Isocexport`x'_pos=.
gen				Isocexport`x'_neg=.
label var		Isocexport`x'_pos "Divergencia social satisfactoria en exports 20`x'"
label var		Isocexport`x'_neg "Divergencia social insatisfactoria en exports 20`x'"
recode			Isocexport`x'_pos (.=1) if divergsocexport`x'>0 & ///
										j==1 & manufactura==1
recode			Isocexport`x'_pos (.=0) if divergsocexport`x'<=0 & ///
										j==1 & manufactura==1
recode			Isocexport`x'_neg (.=1) if divergsocexport`x'<=0 & ///
										j==1 & manufactura==1
recode			Isocexport`x'_neg (.=0) if divergsocexport`x'>0 & ///
										j==1 & manufactura==1
label val		Isocexport`x'_pos lbl_satis
label val		Isocexport`x'_neg lbl_unsat
*cross-check
pwcorr			Isocexport`x'_pos Isocexport`x'_neg //must be -1
}

*>>2 of 2: exportación robusta (satis + insatis)
foreach			x in 15 16 17{
gen				Isocexport`x'_r_pos=.
gen				Isocexport`x'_r_neg=.
label var		Isocexport`x'_r_pos "Robusto: divergencia social satisfactoria en exports 20`x'"
label var		Isocexport`x'_r_neg "Robusto: divergencia social insatisfactoria en exports 20`x'"
recode			Isocexport`x'_r_pos (.=1) if divergsocexport`x'_r>0 & ///
										j==1 & manufactura==1
recode			Isocexport`x'_r_pos (.=0) if divergsocexport`x'_r<=0 & ///
										j==1 & manufactura==1
recode			Isocexport`x'_r_neg (.=1) if divergsocexport`x'_r<=0 & ///
										j==1 & manufactura==1
recode			Isocexport`x'_r_neg (.=0) if divergsocexport`x'_r>0 & ///
										j==1 & manufactura==1
label val		Isocexport`x'_r_pos lbl_satis
label val		Isocexport`x'_r_neg lbl_unsat
*cross-check
pwcorr			Isocexport`x'_r_pos Isocexport`x'_r_neg //must be -1
}

*subpopulation variable now is k instead of j.
tab2			j manufactura
gen				k = j
label var		k "la empresa innova, exporta y es de manufacturas"
recode			k (1=0) if manufactura==0
label val		k dicot
tab2			k manufactura // ahora 
tab2			j k

*creamos las variables de totales de montos de I+D
foreach			x in 15 16 17{
egen			busqueda`x' = rowtotal( idint`x' idext`x' mktng`x' propi`x' capac`x' softw`x' capit`x')
label var		busqueda`x' "Monto total gastado en I+D en 20`x'"
replace			busqueda`x' =. if j!=1 | manufactura!=1
}

*generamos variable dependiente: búsqueda de nuevas alternativas por año
foreach			x in 15 16 17{
gen				rawsearch`x' = busqueda`x'
label var		rawsearch`x' "Monto total de I+D en 20`x'"
}

*generamos variables de slack organizacional
*	> Slack 1: capacidad no utilizada y disponible
foreach			x in 15 16 17{
gen				double slack_capi`x' = 100 - capins`x' if k==1
label var		slack_capi`x' "Slack: Capacidad de producción disponible 20`x'"
}
*	> Slack 2: overhead available
foreach			x in 15 16 17{
gen				double slack_wage`x' = sueldo`x' / 1000 if k==1
label var		slack_wage`x' "(miles S/) overhead in 20`x'"
}

*	> Slack 3: gross profit margin
foreach			x in 15 16 17{
gen				double slack_prof`x' = ventas`x' - sueldo`x' if k==1
label var		slack_prof`x' "(miles S/.) Slack: margen simple de utilidad en 20`x'"
}
//comment: slack_prof* está muy cerca del borde de precisión de STATA e+16
// convirtiendolo a miles de S/
foreach			x in 15 16 17{
replace			slack_prof`x' = slack_prof`x' / 1000 if k==1
}

*Reshape database: de wide a long:
*	>generamos las variables de año de observación y años de operación
foreach			x in 15 16 17{
gen				y_`x' = `x'
label var		y_`x' "Año de la observación: 20`x'"
}
foreach			x in 15 16 17{
gen				y_oper`x' = y_oper - (17 - `x')
label var		y_oper`x' "Años de operación en 20`x'"
}

*	> mantemenos variables que van en el modelo
keep			id departamento tipo_org ciiu2d k y_oper15 y_oper16 y_oper17 ///
				y_15 y_16 y_17 FACTOR_FINAL idint-capit15  ventas15-capins17 ///
				divergventas17_l1 divergventas17_l2 divergventas17_l3		 ///
				divergsocventas17 divergsocventas17_r						 ///
				Iventas17_l1_pos Iventas17_l2_pos Iventas17_l3_pos 			 ///
				Isocventas17_pos Isocventas17_r_pos							 ///
				divergexport17_l1 divergexport17_l2 divergexport17_l3		 ///
				divergsocexport17 divergsocexport17_r						 ///
				Iexport17_l1_pos Iexport17_l2_pos Iexport17_l3_pos 			 ///
				Isocexport17_pos Isocexport17_r_pos							 ///
				slack_capi17 slack_wage17 slack_prof17 rawsearch17			 ///
				divergventas16 divergsocventas16 divergsocventas16_r 		 ///
				Iventas16_pos Isocventas16_pos Isocventas16_r_pos			 ///
				divergexport16 divergsocexport16 divergsocexport16_r		 ///
				Iexport16_pos Isocexport16_pos Isocexport16_r_pos			 ///
				slack_capi16 slack_wage16 slack_prof16 rawsearch16 			 ///
				divergsocventas15 divergsocventas15_r						 ///
				Isocventas15_pos Isocventas15_r_pos							 ///
				divergsocexport15 divergsocexport15_r						 ///
				Isocexport15_pos Isocexport15_r_pos							 ///
				slack_capi15 slack_wage15 slack_prof15 rawsearch15
drop			idint idext ingdi mktng propi capac softw capit		

*Ordenando bbbdd para reshape (completar missings, renombrar, etc)
foreach			x in FACTOR_FINAL tipo_org departamento ciiu2d k{
order			`x', after(id)
}
*
foreach			x in idint idext ingdi mktng propi capac softw capit{
order			`x'16, after(`x'15)
order			`x'17, after(`x'16)
}
*
foreach			x in  y_oper y_ {
order			`x'15, after(FACTOR_FINAL)
order			`x'16, after(`x'15)
order			`x'17, after(`x'16)
}
*
gen				divergventas16_l1=divergventas16
_crcslbl		divergventas16_l1 divergventas16
order			divergventas16_l1, before(divergventas17_l1)
gen				divergventas16_l2=divergventas16
_crcslbl		divergventas16_l2 divergventas16
order			divergventas16_l2, before(divergventas17_l2)
gen				divergventas16_l3=divergventas16
_crcslbl		divergventas16_l3 divergventas16
order			divergventas16_l3, before(divergventas17_l3)
drop			divergventas16
*
foreach			x in 1 2 3{
gen				divergventas15_l`x'=.
order			divergventas15_l`x', before(divergventas16_l`x')
}
*
rename			divergventas15_l1 divergventas_l1_15
rename			divergventas16_l1 divergventas_l1_16
rename			divergventas17_l1 divergventas_l1_17
rename			divergventas15_l2 divergventas_l2_15
rename			divergventas16_l2 divergventas_l2_16
rename			divergventas17_l2 divergventas_l2_17
rename			divergventas15_l3 divergventas_l3_15
rename			divergventas16_l3 divergventas_l3_16
rename			divergventas17_l3 divergventas_l3_17
*
foreach			x in 1 2 3{
gen				Iventas15_l`x'_pos=.
order			Iventas15_l`x'_pos, before(Iventas17_l`x'_pos)
gen				Iventas16_l`x'_pos=Iventas16_pos
label val		Iventas16_l`x'_pos Iventas16_pos
_crcslbl		Iventas16_l`x'_pos Iventas16_pos
order			Iventas16_l`x'_pos, before(Iventas17_l`x'_pos)
} 
* 
drop			Iventas16_pos
*
order			divergsocventas15 - divergsocventas17_r, after(divergventas_l3_17)
*
rename			divergsocventas15_r divergsocventas_r_15
rename			divergsocventas16_r divergsocventas_r_16
rename			divergsocventas17_r divergsocventas_r_17
*
rename 			Iventas15_l1_pos   Iventas_l1_pos_15
rename 			Iventas16_l1_pos   Iventas_l1_pos_16
rename 			Iventas17_l1_pos   Iventas_l1_pos_17
rename 			Iventas15_l2_pos   Iventas_l2_pos_15
rename 			Iventas16_l2_pos   Iventas_l2_pos_16
rename 			Iventas17_l2_pos   Iventas_l2_pos_17
rename 			Iventas15_l3_pos   Iventas_l3_pos_15
rename 			Iventas16_l3_pos   Iventas_l3_pos_16
rename 			Iventas17_l3_pos   Iventas_l3_pos_17
rename 			Isocventas15_pos   Isocventas_pos_15   
rename 			Isocventas16_pos   Isocventas_pos_16   
rename 			Isocventas17_pos   Isocventas_pos_17   
rename 			Isocventas15_r_pos   Isocventas_r_pos_15   
rename 			Isocventas16_r_pos   Isocventas_r_pos_16   
rename 			Isocventas17_r_pos   Isocventas_r_pos_17   
*
foreach			x in 1 2 3{
gen				divergexport15_l`x'=.
order			divergexport15_l`x', before(divergexport16)
gen				divergexport16_l`x'=divergexport16
order			divergexport16_l`x', after(divergexport15_l`x')
_crcslbl		divergexport16_l`x' divergexport16
order			divergexport17_l`x', after(divergexport16_l`x')
}
drop			divergexport16
*
rename 			divergexport15_l1 divergexport_l1_15
rename 			divergexport16_l1 divergexport_l1_16
rename 			divergexport17_l1 divergexport_l1_17
rename 			divergexport15_l2 divergexport_l2_15
rename 			divergexport16_l2 divergexport_l2_16
rename 			divergexport17_l2 divergexport_l2_17
rename 			divergexport15_l3 divergexport_l3_15
rename 			divergexport16_l3 divergexport_l3_16
rename 			divergexport17_l3 divergexport_l3_17
*
order			divergsocexport15 - divergsocexport17_r, after(divergexport_l3_17)
*
rename			divergsocexport15_r divergsocexport_r_15
rename			divergsocexport16_r divergsocexport_r_16
rename			divergsocexport17_r divergsocexport_r_17
*
foreach			i in 1 2 3{
gen				Iexport_l`i'_pos_15=.
order			Iexport_l`i'_pos_15, before(Iexport17_l`i'_pos)
gen				Iexport_l`i'_pos_16 = Iexport16_pos
_crcslbl		Iexport_l`i'_pos_16 Iexport16_pos
order			Iexport_l`i'_pos_16, before(Iexport17_l`i'_pos)
rename			Iexport17_l`i'_pos Iexport_l`i'_pos_17
}
drop			Iexport16_pos
*
order			Isocexport15_pos-Isocexport17_r_pos, after(Iexport_l3_pos_17)
*
rename 			Isocexport15_pos Isocexport_pos_15
rename 			Isocexport16_pos Isocexport_pos_16
rename 			Isocexport17_pos Isocexport_pos_17
rename 			Isocexport15_r_pos Isocexport_r_pos_15
rename 			Isocexport16_r_pos Isocexport_r_pos_16
rename 			Isocexport17_r_pos Isocexport_r_pos_17
*
order			slack_capi15 slack_capi16 slack_capi17 ///
				slack_wage15 slack_wage16 slack_wage17 ///
				slack_prof15 slack_prof16 slack_prof17 ///
				, after(Isocexport_r_pos_17)

*DATABASE RESHAPE BY YEAR
reshape			long y_ y_oper idint idext ingdi mktng propi capac softw capit ///
				ventas export capita sueldo produc capins ///
				divergventas_l1_ divergventas_l2_ divergventas_l3_ ///
				divergsocventas divergsocventas_r_   ///
				Iventas_l1_pos_ Iventas_l2_pos_ Iventas_l3_pos_ ///
				Isocventas_pos_ Isocventas_r_pos_ ///
				divergexport_l1_ divergexport_l2_ divergexport_l3_ ///
				divergsocexport divergsocexport_r_ ///
				Iexport_l1_pos_ Iexport_l2_pos_ Iexport_l3_pos_ ///
				Isocexport_pos_ Isocexport_r_pos_ ///
				slack_capi slack_wage slack_prof ///
				rawsearch , i(id) j(year)
//--> no hay error en reshape

*definimos los montos de las variables en miles
local			eta 	rawsearch ///
						divergventas_l1_ divergventas_l2_ divergventas_l3_ 	///
						divergexport_l1_ divergexport_l2_ divergexport_l3_ 	///
						divergsocventas divergsocventas_r_ 					///
						divergsocexport divergsocexport_r_ 					///
						capita
foreach 		x of local eta {
replace			`x' = `x' / 1000
}


*guardamos la base de datos para estimar el modelo en el siguiente do-file
save		"$c/long_ddbb_eniim2018.dta", replace
