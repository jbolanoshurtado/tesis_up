********************************************************************************
* Uso de la la bbdd de innovaci�n en la industria manufacturera y de servicios *
* Per� 2015, 2016 y 2017  													   *
********************************************************************************

clear 		all

set more	off, perm
set type	double, perm
*def. ubicaci�n bbdd
gl			a "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\0-bbdd iniciales"
gl			b "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\1-bbdd intermedias"
gl			c "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\2-bbdd finales"


*abrimos bbdd intermedia convertida orig. de spss (.sav) a .dta
u			"$b\bbdd2018_limpia.dta", clear


*necesitamos limpiar la variable independiente: divergencia
recode		produc17 (999=99) if produc17==999
tabstat 	ventas15 - capins17, c(s) s(n me min p10 med p90 max)
bysort		sector: tabstat ventas15 - capins17, c(s) s(n me min p10 med p90 max)

tab1		ciiu2d
tab1		ciiu2d if tipo_org==1

*** todas las inconsistencias encontradas ***
/*
1.  Mucha concentraci�n en Lima ca.1700 empresas de ca.2000
2.  Divisi�n entre manufacturas [n: 1463] y servicios [n: 621]
3.  23 empresas recien empezaron a operar en el tiempo que comprende el estudio
4.  44 empresas son personas naturales, 127 eirls
5.  37 encuestas fueron respondidas por otras personas no responsables
6.  industrias raras: reparaciones, petroleo, qu�micos, farmacetica
7.  la mitad de la muestra no innov� hay que sacarlas
8.  1 empresa que no tienen ventas entre el 2015 y 2017
9.  604 empresas sin inversi�n en activo fijo
10. 152 empresas pagan menos de 50mil soles en sueldo y 31 no pagan sueldos
11. 20 empresas no usan su capacidad instalada (literal 0%)
*/


***


*1) Fijamos dummmies para Lima y provincias (Lima + Callao) [-325 obs]

tab1		departamento  //keep Lima y Callao
gen			i=0
recode		i (0=1) if departamento == 13 | departamento == 6 //325 obs out
*keep if 	departamento == 13 | departamento == 6 //325 obs out
tab1		departamento if i==1  //1759 obs Lima y Callao


*2) Notamos cantidad de manufactura y servicios [-0 obs]

recode		sector (0=1) (1=0)
label val	sector dicot
rename		sector manufactura
label var	manufactura "Sector manufactura"
tab1		manufactura //1198 manuf 561 servicios


*3) Revisamos empresas que reci�n empiezan a operar [-19 obs]

tab1		y_oper // 19 empresas con justo 4 a�os (tres de estudio +1 encuesta)
//no estoy interesado en incluir el efecto del struggle inicial
//de las empresas al empezar actividades o lo que acarree esto

recode		i (1=0) if y_oper==4 //19 out por reci�n empezar a operar
*drop		if y_oper==4 //19 out por reci�n empezar a operar


*4) Revisamos el tipo de empresa (no persona natural) [-28 obs]

tab1		tipo_org
tab1		tipo_org, nol

recode		i (1=0) if tipo_org == 1
*drop		if tipo_org == 1


*5) Revisamos qui�n respondi� la encuesta [-0obs]
tab1		encuestado
tab1		encuestado, nol


*6) Revisamos industrias

tab1		ciiu2d


*7) Empresas que no buscan mediante la investigaci�n y desarrollo [-744 y -3]

tab1		innovo1 innovo2 
 /* 
 aprox la mitad de la muestra s� innov� en
 alguna actividad de las desarrolladas pero el corte no es igual, 
 hay al parecer como 7% que solo innovaron al aumentar el capital
 la pregunta es si incluirlas, al final, no importa si el monto es mucho, 
 lo que importa es si en total, la tendencia de la misma empresa cambio, 
 y por eso creo que s� deber�amos mantener a todas las variables de 
 innovaci�n
 */
* control de da�os, veamos quienes se van, a ver si es maso equilibrado
tab1		ciiu2d
bysort		innovo1:	tab1	ciiu2d 


********** OJO INCONSISTENCIA, ELIMINACION DE OBS POR NO GASTAR Y DECIR QUE S�**

gen			contraste = 0
recode		contraste (0=1) if idint==1 | idext==1 | ingdi==1 | mktng==1 | ///
							   propi==1 | capac==1 | softw==1 | capit==1
*
tab2		innovo1 contraste //ok

foreach 	x in 15 16 17 {
egen		gasto_rd_20`x' = rowtotal(idint`x' idext`x' ingdi`x' mktng`x' ///
									  propi`x' capac`x' softw`x' capit`x')
label var	gasto_rd_20`x' "Gasto total en I+D en 20`x'"
}
*

recode		contraste (1=0) if gasto_rd_2015==0 & gasto_rd_2016==0 & ///
							   gasto_rd_2017==0
*
tab2		innovo1 contraste // 3 empresas dicen que s� innovaron pero no $$$

*br			if innovo1==1 & contraste==0 // no sirven, no tienen data

recode		i (1=0) if innovo1==1 & contraste==0 //-3 obs quedan 1709
*drop if 	innovo1==1 & contraste==0 //-3 obs quedan 1709


recode		i (1=0) if contraste==0
*keep if 	contraste==1 //731 obs out, quedan 978.



*8) Empresas sin ventas en el periodo de estudio [-1 obs]

tab1		ciiu2d if ventas15 ==0 | ventas16==0 | ventas17==0
recode		i (1=0) if ventas15 ==0 | ventas16==0 | ventas17==0 // 1 empresa sin ventas
*drop if ventas15 ==0 | ventas16==0 | ventas17==0 // 1 empresa sin ventas


*9. Revisar 604 empresas sin inversi�n en activo fijo

tabstat		ventas* export* capita* sueldo* produc* capins* if i==1 ///
			, c(s) s(n min p10 p25 med me p75 p90 max) 
/*
ventas son hiperasim�tricas a la derecha

Algunas no tienen bienes de capital:
	Seg�n el MEF: https://www.mef.gob.pe/contenidos/conta_publ/documentac/VERSION_MODIFICADA_PCG_EMPRESARIAL.pdf
		la cuenta 72 de capital es:
			72 	Producci�n de activo inmovilizado
				721	Inversiones inmobiliarias 
					7211	edificaciones
				722 Inmuebles, maquinaria y equipo
					7221	Edificaciones
					7222	Maquinaria y otros equipos de explotaci�n
					7223	Equipo de transporte
					7224	Muebles y enseres
					7225	Equipos diversos
				723	Intangibles
					7231	Programas de computadora (software)
					7232	Costos de exploraci�n y desarrollo
					7233	F�rmulas, dise�os y prototipos
				724	Activos biol�gicos
					7241	Activos biol�gicos en desarrollo de origen animal
					7242	Activos biol�gicos en desarrollo de origen vegetal
				725	Costos de financiaci�n capitalizados
					7251	Costos de financiaci�n -- Inversiones inmobiliarias
							72511	Edificaciones
					7252	Costos de financiaci�n -- Inmuebles, maq. equipo
							72521	Edificaciones
							72522	Maquinaria y otros equipos de explotaci�n
					7253	Costos de financiaci�n -- Intangibles
					7254	Costos de financiaci�n -- Activos bio. en desarrollo
							72541	Activos biol�gicos de origen animal
							72542	Activos biol�gicos de origen vegetal
.
168 empresas no reportan en al menos uno de los tres a�os capital en la cta. 72
de las PCGA
							*/

*Revisamos de qu� industria son esas empresas si montos en capital inmov.
tab1		ciiu2d if capita15 == 0 | capita16 == 0 | capita17 == 0
//No veo que sea un problema, porque puede ser que esos montos est�n en otra 
//partida por la forma en que esas empresas llevan su contabilidad

*Revisamos de qu� industria vienen las empresas que no pagan sueldos
tab1		ciiu2d if sueldo15 == 0 | sueldo16 == 0 | sueldo17 == 0
tab1		ventas15 if sueldo15 == 0
tab1		ventas16 if sueldo16 == 0
tab1		ventas17 if sueldo17 == 0 //:)
*br			if sueldo15 == 0 | sueldo16 == 0 | sueldo17 == 0
// todo ok, es espor�dico e igual tienen actividad en otros montos



* Fin de la revisi�n. - queda 977 obs



*I) Nos quedamos solo con las exportadoras

*para generar coeficiente de exportaci�n revisamos numerador y denominador

tabstat		ventas* export*, c(s) s(n me min p10 med p90 max skew) // all nominal


*generamos apertura comercial
foreach		x in 15 16 17{
gen			coef_exp_20`x' = export`x'/ventas`x' 
label var	coef_exp_20`x' "coeficiente de exportaci�n"
}
tabstat		coef_* if i==1, c(s) s(n me p10 q p90 max)

*problema = m�s de 100%
*br if 		coef_exp_2015 > 1
replace		ventas15 = export15 if coef_exp_2015 > 1 & i ==1
replace		coef_exp_2015 = 1 if coef_exp_2015 > 1 & i==1 // exportaci�n mayor a venta


*cuantos exportadores hay en la muestra?

count		if coef_exp_2015>0 & i==1 // 434 obs de 977
count		if coef_exp_2016>0 & i==1 // 447 obs de 977
count		if coef_exp_2017>0 & i==1 // 448 obs de 977

count		if coef_exp_2015>0 & coef_exp_2016>0 & coef_exp_2017>0 & i==1 
// 407 de 977

*keep Observaciones que son exportadores [-570 obs]

recode		i (1=2) if coef_exp_2015>0 & coef_exp_2016>0 & coef_exp_2017>0 
label def	i 0 "no cumplen" 1 "s� cumplen no export" 2 "si cumple si export"
label val	i i
*keep		if coef_exp_2015>0 & coef_exp_2016>0 & coef_exp_2017>0 //570 out

tab1		i
label var	i "cat. indica si la empresa cumple con el criterio"

*quedan		407 exporters and 1221 data points

*revisamos los coeficientes de exportaci�n
tabstat		export15 coef_exp_2015 ///
			export16 coef_exp_2016 ///
			export17 coef_exp_2017 if i==2, c(s) s(n me min p10 q p90 max skew)

*hay algunas empresas que tienen montos de exportaci�n que parecen muestras
count if	export15 < 10000 & i==2 // 4 empresas
count if	export16 < 10000 & i==2 // 2 empresas
count if	export17 < 10000 & i==2 // 6 empresas

count if 	(export15 < 10000 | export16 < 10000 | export17 < 10000) & i==2 //10 empresas		
count if	(export15 < 10000 & export16 < 10000 & export17 < 10000) & i==2 // 0 empresas

*br if 		export15 < 10000 | export16 < 10000 | export17 < 10000 

*=>quedan

*revisamos quienes son los que quedan
tab1 		ciiu2d if i==2
tab1		ciiu2d  if i==2, nol
tab1 		manufactura  if i==2


*drop obs con 3 o menos datos [-13 obs, quedan 394]

recode		i (2=0) if ciiu2d==16 | ciiu2d==30 | ciiu2d== 33 | ciiu2d==70 
*drop		if ciiu2d==16 | ciiu2d==30 | ciiu2d== 33 | ciiu2d==70 
gen			j = 0
recode		j (0=1) if i==2
label def	j 0 "no cumple" 1 "s� cumple"
label var	j "la empresa gasta en innovaci�n y exporta"
label val	j j







****************************************************************************
* j es la variable de subpoblaci�n de empresas exportadoras que s� innovan *
****************************************************************************


svyset 		id [pweight=FACTOR_FINAL], strata(ciiu2d) vce(linearized) singleunit(missing)
mean		ventas17
svy:		mean ventas17
tab1		j
mean		ventas17 if i==1
svy, 		subpop(j): mean ventas17		

*>>>>>>2017 ventas
regress		gasto_rd_2017 ventas17 if j==1
regress		gasto_rd_2017 ventas17 if j==1, robust
svy,		subpop(j): regress	gasto_rd_2017 ventas17
*>>>>>>2016 ventas
regress		gasto_rd_2016 ventas16 if j==1
regress		gasto_rd_2016 ventas16 if j==1, robust
svy,		subpop(j): regress	gasto_rd_2017 ventas17
*>>>>>>2015 ventas
regress		gasto_rd_2015 ventas15 if j==1
regress		gasto_rd_2015 ventas15 if j==1, robust
svy,		subpop(j): regress	gasto_rd_2015 ventas15

*>>>>>>2017 export
regress		gasto_rd_2017 export17 if j==1
regress		gasto_rd_2017 export17 if j==1, robust
svy,		subpop(j): regress	gasto_rd_2017 export17
*>>>>>>2016 export
regress		gasto_rd_2016 export16 if j==1
regress		gasto_rd_2016 export16 if j==1, robust
svy,		subpop(j): regress	gasto_rd_2017 export16
*>>>>>>2015 export
regress		gasto_rd_2015 export15 if j==1
regress		gasto_rd_2015 export15 if j==1, robust
svy,		subpop(j): regress	gasto_rd_2015 export15



tabstat		gasto_rd* ventas* export* if j==1 ///
			, c(s) s(n min p10 q p90 max skew kurt)

			
			
			
			
			

*****
**********
* Aqu� me qued� 05/10/2020
**********
*****

*retomando 08/11/2020


*crear variables
*correr regresiones por a�os
*reportar hallazgos
*correr tambi�n para el 2012, 2013, 2014
*ver si es posible 2011 2010 2009



*>>> Vamos a crear las tablas para la tesis.

tab1		manufactura
svy 		linearized : tabulate manufactura
tab1 		ciiu2d if manufactura==1
svy 		linearized : tabulate ciiu2d if manufactura==1

tab1		manufactura if j==1
tab1		ciiu2d if manufactura==1 & j==1

tabstat export15 export16 export17 if j==1, c(s) s(n min me max)


***** para el caso de solo las exportadoras
tab1		manufactura if j==1
svy,		subpop(j):  tabulate manufactura 
tab1		ciiu2d if manufactura == 1 & j==1
svy,		subpop(j): tabulate ciiu2d if manufactura==1





** Generamos desempe�o observado para cada a�o:

*** Desempe�o ventas 2015,16,17

foreach 	x in 15 16 17 {
gen			desventas`x' = .
label var	desventas`x' "Desempe�o en ventas 20`x'"
replace		desventas`x' = ventas`x'
}

*Objetivo de ventas 2016 (Aspiraci�n natural)
gen			objdesventas16 = .
label var	objdesventas16 "Objetivo de desempe�o en ventas 2016"
replace		objdesventas16 = desventas15 //natural aspiration indicate

*Divergencia en desempe�o de ventas 2016 (Aspiraci�n natural)
gen			divergventas16 = .
label var	divergventas16 "Divergencia desempe�o ventas - objetivo ventas 2016"
replace		divergventas16 = desventas16 - objdesventas16

*Spline indicators de desempe�o satisfactorio/insatisfactorio (Iij)
gen			Iventas16_pos = .
label var	Iventas16_pos "La divergencia de ventas es satisfactoria en 2016"
recode		Iventas16_pos (.=1) if divergventas16 > 0
recode		Iventas16_pos (.=0) //resto de insatisfactorias
label def	Iventas16_pos 1 "satisfactorio" 0 "insatisfactorio"
label val	Iventas16_pos Iventas16_pos

gen			Iventas16_neg =.
label var	Iventas16_neg "La divergencia de ventas es insatisfactoria en 2016"
recode		Iventas16_neg (.=1) if divergventas16<=0
recode		Iventas16_neg (.=0) //resto de satisfactorias
label def	Iventas16_neg 1 "insatisfactorio" 0 "satisfactorio"
label val	Iventas16_neg Iventas16_neg

*cross-check
pwcorr		Iventas16_pos Iventas16_neg //debe ser -1 exactamente (es inversa)


*Objetivo de ventas 2017 (Hist�rico (reci�n))
** tres lambdas para probar qu� ajuste es mejor
*--> l1 = 0.25 : faster update
*--> l2 = 0.50 : medium update
*--> l3 = 0.75 : slower update
gen			objdesventas17_l1=.
gen			objdesventas17_l2=.
gen			objdesventas17_l3=.
label var	objdesventas17_l1 "Objetivo de desempe�o en ventas 2017 (fast)"
label var	objdesventas17_l2 "Objetivo de desempe�o en ventas 2017 (avg)"
label var	objdesventas17_l3 "Objetivo de desempe�o en ventas 2017 (slow)"
replace		objdesventas17_l1 = 0.25*objdesventas16 + 0.75*desventas16
replace		objdesventas17_l2 = 0.50*objdesventas16 + 0.50*desventas16
replace		objdesventas17_l3 = 0.75*objdesventas16 + 0.25*desventas16

*Divergencia de ventas 2017 (Hist�rico) tres lambdas
gen			divergventas17_l1 =.
gen			divergventas17_l2 =.
gen			divergventas17_l3 =.
label var	divergventas17_l1 "Divergencia desempe�o ventas - objetivo ventas 2017 (fast)"
label var	divergventas17_l2 "Divergencia desempe�o ventas - objetivo ventas 2017 (avg)"
label var	divergventas17_l3 "Divergencia desempe�o ventas - objetivo ventas 2017 (slow)"
replace		divergventas17_l1 = desventas17 - objdesventas17_l1
replace		divergventas17_l2 = desventas17 - objdesventas17_l2
replace		divergventas17_l3 = desventas17 - objdesventas17_l3

*Spline indicators de desempe�o satisfactorio/insatisfactorio para tres lambdas
* (Iij) by l1 (fast update), l2 (avg update), & l3 (slow update)

**>>> Para l1: 0.25 (fast updating of objectives)
gen			Iventas17_l1_pos = .
label var	Iventas17_l1_pos "Para l1: la divergencia de ventas es satisfactoria 2017"
recode		Iventas17_l1_pos (.=1) if divergventas17_l1 > 0
recode		Iventas17_l1_pos (.=0) //resto de insatisfactorias
label def	Iventas17_l1_pos 1 "satisfactorio" 0 "insatisfactorio"
label val	Iventas17_l1_pos Iventas17_l1_pos

gen			Iventas17_l1_neg =.
label var	Iventas17_l1_neg "Para l1: la divergencia de ventas es insatisfactoria 2017"
recode		Iventas17_l1_neg (.=1) if divergventas17_l1<=0
recode		Iventas17_l1_neg (.=0) //resto de satisfactorias
label def	Iventas17_l1_neg 1 "insatisfactorio" 0 "satisfactorio"
label val	Iventas17_l1_neg Iventas17_l1_neg

*cross-check
pwcorr		Iventas17_l1_pos Iventas17_l1_neg //debe ser -1 exactamente (es inversa)




**>>> Para l2: 0.50 (avg updating of objectives)
gen			Iventas17_l2_pos = .
label var	Iventas17_l2_pos "Para l2: la divergencia de ventas es satisfactoria 2017"
recode		Iventas17_l2_pos (.=1) if divergventas17_l2 > 0
recode		Iventas17_l2_pos (.=0) //resto de insatisfactorias
label def	Iventas17_l2_pos 1 "satisfactorio" 0 "insatisfactorio"
label val	Iventas17_l2_pos Iventas17_l2_pos

gen			Iventas17_l2_neg =.
label var	Iventas17_l2_neg "Para l2: la divergencia de ventas es insatisfactoria 2017"
recode		Iventas17_l2_neg (.=1) if divergventas17_l2<=0
recode		Iventas17_l2_neg (.=0) //resto de satisfactorias
label def	Iventas17_l2_neg 1 "insatisfactorio" 0 "satisfactorio"
label val	Iventas17_l2_neg Iventas17_l2_neg

*cross-check
pwcorr		Iventas17_l2_pos Iventas17_l2_neg //debe ser -1 exactamente (es inversa)



**>>> Para l3: 0.75 (slow updating of objetives)
gen			Iventas17_l3_pos = .
label var	Iventas17_l3_pos "Para l3: la divergencia de ventas es satisfactoria 2017"
recode		Iventas17_l3_pos (.=1) if divergventas17_l3 > 0
recode		Iventas17_l3_pos (.=0) //resto de insatisfactorias
label def	Iventas17_l3_pos 1 "satisfactorio" 0 "insatisfactorio"
label val	Iventas17_l3_pos Iventas17_l3_pos

gen			Iventas17_l3_neg =.
label var	Iventas17_l3_neg "Para l3: la divergencia de ventas es insatisfactoria 2017"
recode		Iventas17_l3_neg (.=1) if divergventas17_l3<=0
recode		Iventas17_l3_neg (.=0) //resto de satisfactorias
label def	Iventas17_l3_neg 1 "insatisfactorio" 0 "satisfactorio"
label val	Iventas17_l3_neg Iventas17_l3_neg

*cross-check
pwcorr		Iventas17_l3_pos Iventas17_l3_neg //debe ser -1 exactamente (es inversa)


** Objetivo de desempe�o de ventas social (2015,16,17)
*Generamos promedios de ventas por cada industria por a�o
foreach 	x in 15 16 17{
bysort 		ciiu2d:	egen 	objsocventas`x' = mean(desventas`x')
label var	objsocventas`x' "Objetivo social de desempe�o en ventas 20`x' x ind"
}
*Generamos medianas de ventas por cada industria por a�o (robusto contra outliers)
foreach		x in 15 16 17{
bysort		ciiu2d: egen	objsocventas`x'_r = median(desventas`x')
label var	objsocventas`x'_r "Robusto: Obj social de desempe�o en ventas 20`x' x ind"
}



** Divergencia de desempe�o social x a�os x empresa
*Medici�n NORMAL
foreach		x in 15 16 17{
gen			divergsocventas`x' =.
replace		divergsocventas`x' = desventas`x' - objsocventas`x' 
label var	divergsocventas`x' "Divergencia desempe�o social ventas 20`x'"
}

*Medici�n ROBUSTA
foreach		x in 15 16 17{
gen			divergsocventas`x'_r =.
replace		divergsocventas`x'_r = desventas`x' - objsocventas`x'_r 
label var	divergsocventas`x'_r "ROBUSTO: Divergencia desempe�o social ventas 20`x'"
}


** Indicador de divergencia de desempe�o social como satisfactorio o insatisfactorio
*NORMAL (promedios)
foreach		x in 15 16 17{
gen			Isocventas`x'_pos =.
label var	Isocventas`x'_pos "Divergencia social satisfactoria en ventas 20`x'"
recode		Isocventas`x'_pos (.=1) if divergsocventas`x'>0
recode		Isocventas`x'_pos (.=0) // insatisfactorias sociales x a�o
label def	Isocventas`x'_pos 1 "satisfactorio" 0 "insatisfactorio"
label val	Isocventas`x'_pos Isocventas`x'_pos

gen			Isocventas`x'_neg =.
label var	Isocventas`x'_neg "Divergencia social insatisfacotria en ventas 20`x'"
recode		Isocventas`x'_neg (.=1) if divergsocventas`x' <=0
recode		Isocventas`x'_neg (.=0) //satisfactorias
label def	Isocventas`x'_neg 1 "insatisfactorias" 0 "satisfactorias"
label val	Isocventas`x'_neg Isocventas`x'_neg


*cross-check
pwcorr		Isocventas`x'_pos Isocventas`x'_neg //debe ser -1 exactamente (es inversa)
}

*ROBUSTO (medianas)
foreach		x in 15 16 17{
gen			Isocventas`x'_r_pos =.
label var	Isocventas`x'_r_pos "Robust: divergencia social satisfactoria en ventas 20`x'"
recode		Isocventas`x'_r_pos (.=1) if divergsocventas`x'_r>0
recode		Isocventas`x'_r_pos (.=0) // insatisfactorias sociales x a�o
label def	Isocventas`x'_r_pos 1 "satisfactorio" 0 "insatisfactorio"
label val	Isocventas`x'_r_pos Isocventas`x'_r_pos

gen			Isocventas`x'_r_neg =.
label var	Isocventas`x'_r_neg "Robust: divergencia social insatisfacotria en ventas 20`x'"
recode		Isocventas`x'_r_neg (.=1) if divergsocventas`x'_r <=0
recode		Isocventas`x'_r_neg (.=0) //satisfactorias
label def	Isocventas`x'_r_neg 1 "insatisfactorias" 0 "satisfactorias"
label val	Isocventas`x'_r_neg Isocventas`x'_r_neg


*cross-check
pwcorr		Isocventas`x'_r_pos Isocventas`x'_r_neg //debe ser -1 exactamente (es inversa)
}

****************************************************************
* Inventario de qu� variables independientes clave he generado *
****************************************************************

/*
divergventas16		:	Divergencia de desempe�o en 2016
Iventas16_pos		:	Indica desempe�o satisfactorio en 2016
Iventas16_neg		:	Indica desempe�o insatisfactorio en 2016
*
divergventas17_l1	:	Divergencia de desempe�o en 2017 (fast update)
Iventas17_l1_pos	:	Indica desempe�o satisfactorio en 2017 (fast update)
Iventas17_l1_neg	:	Indica desempe�o insatisfactorio en 2017 (fast update)
*
divergventas17_l2	:	Divergencia de desempe�o en 2017 (avg update)
Iventas17_l2_pos	:	Indica desempe�o satisfactorio en 2017 (avg update)
Iventas17_l2_neg	:	Indica desempe�o insatisfactorio en 2017 (avg update)
*
divergventas17_l3	:	Divergencia de desempe�o en 2017 (slow update)
Iventas17_l3_pos	:	Indica desempe�o satisfactorio en 2017 (slow update)
Iventas17_l3_neg	:	Indica desempe�o insatisfactorio en 2017 (slow update)
*
divergsocventas15	:	Divergencia de desempe�o social en 2015
Isocventas15_pos	:	Indica desempe�o social satisfactorio en 2015
Isocventas15_neg	:	Indica desempe�o social insatisfactorio en 2015
*
divergsocventas15_r	:	Divergencia ROBUSTA de desempe�o social en 2015
Isocventas15_r_pos	:	Robusto: Indica desempe�o social satisfactorio en 2015
Isocventas15_r_neg	:	Robusto: Indica desemoe�o social insatisfactorio en 2015
*
divergsocventas16	:	Divergencia de desempe�o social en 2016
Isocventas16_pos	:	Indica desempe�o social satisfactorio en 2016
Isocventas16_neg	:	Indica desempe�o social insatisfactorio en 2016
*
divergsocventas16_r	:	Divergencia ROBUSTA de desempe�o social en 2016
Isocventas16_r_pos	:	Robusto: Indica desempe�o social satisfactorio en 2016
Isocventas16_r_neg	:	Robusto: Indica desempe�o social insatisfactorio en 2016
*
divergsocventas17	:	Divergencia de desempe�o social en 2017
Isocventas17_pos	:	Indica desempe�o social satisfactorio en 2017
Isocventas17_neg	:	Indica desempe�o social insatisfactorio en 2017
*
divergsocventas17_r	:	Divergencia ROBUSTA de desempe�o social en 2017
Isocventas17_r_pos	:	Robusto: Indica desempe�o social satisfactorio en 2017
Isocventas17_r_neg	:	Robusto: Indica desempe�o social insatisfactorio en 2017
*/



*** Desempe�o exportaciones 2015,16,17
*revisamos si normal podemos hallar todo lo anterior para el subcaso
*del desempe�o de las exportaciones

tab1 		ciiu2d if j==1 & manufactura==1

*subgrupo m�s grande: 71 obs (alimentos), subgrupo m�s peque�o: 4 obs (muebles)
*algunos grupos tendr�n mas ruido que otros... so be it.

* Revisar rango de exportaciones por sector para generar:
** a) aspiraci�n natural en el 2016
** b) objetivo hist�rico 2017 bajo tres lambdas
** c) objetivo social del 2015 al 2017 de forma promedio y robusta
** d) ADICIONAL: intensidad exportadora (ver si sale tmb)

foreach 	x in 10 11 13 14 15 17 18 19 20 21 22 23 24 25 27 28 29 31 32{
display		`x'
tabstat		export*  if ciiu2d==`x' & j==1 , c(s) s(n me min p10 med p90 max)
}
* (\uparrow) valor de exportaciones por a�o por industria manufacturera.
	*todo ok, normal los valores, todos son altos (>10000 d�lares salvo pocos casos*
	

*** Generamos desempe�o observado de las exportaciones por a�os
*** Desempe�o nominal
foreach		x in 15 16 17{
gen			desexport`x' =.
replace		desexport`x' = export`x' if j==1 & manufactura==1 //solo la subpoblaci�n
label var	desexport`x' "Desempe�o en exportaciones 20`x'"
}
*** Desempe�o en intensidad exportadora
foreach		x in 15 16 17{
gen			desintexp`x' =.
replace		desintexp`x' = desexport`x' / desventas`x' if j==1 & manufactura==1
label var	desintexp`x' "Desempe�o en intensidad exportadora 20`x'"
}

*a) aspiraci�n natural 2016 exportaciones e intensidad exportadora
* exportaciones
gen			objdesexport16 =.
label var	objdesexport16 "Objetivo de desempe�o de exportaciones 2016"
replace		objdesexport16 = desexport15 if j==1 & manufactura==1 //aspiraci�n nat
* intensidad exportadora
gen			objdesintexp16=.
label var	objdesintexp16 "Objetivo de desempe�o de intensidad exportadora 2016"
replace		objdesintexp16 = desintexp15 if j==1 & manufactura==1 //aspiraci�n nat


*Divergencias en desempe�o de exportaciones (asp. nat.)
gen			divergexport16=.
label var	divergexport16 "Divergencia desempe�o export-objetivo export 2016"
replace		divergexport16 = desexport16 - objdesexport16 if j==1 & manufactura==1

*Divergencias en intensidad exportadora (asp. nat.)
gen			divergintexp16=.
label var	divergintexp16 "Divergencia intens export - objetivo int exp 2016"
replace		divergintexp16 = desintexp16 - objdesintexp16 if j==1 & manufactura==1


*Spline indicators solo para desempe�o (in)satisfactorio de exportaciones 2016
gen 		Iexport16_pos=.
label var	Iexport16_pos "La divergencia de export es satisfactoria en 2016"
recode		Iexport16_pos (.=1) if divergexport16 > 0 & divergexport16 !=.
recode		Iexport16_pos (.=0) if divergexport16 <= 0 & divergexport16 !=. //resto
label def	Iexport16_pos 1 "satisfactorio" 0 "insatisfactorio"
label val	Iexport16_pos Iexport16_pos 


gen			Iexport16_neg=.
label var	Iexport16_neg "La divergencia de export es insatisfactoria en 2016"
recode		Iexport16_neg (.=1) if divergexport16 <=0 & divergexport16!=.
recode		Iexport16_neg (.=0) if divergexport16 > 0 & divergexport16!=.
label def	Iexport16_neg  1 "insatisfactorio" 0 "satisfactorio"
label val	Iexport16_neg Iexport16_neg 

*>> cross-check
pwcorr		Iexport16_pos Iexport16_neg 

*Spline indicators solo para desempe�o (in)satisfactorio de intensidad export 2016
gen			Iintexp16_pos=.
label var	Iintexp16_pos "La divergencia de int. export. es satisfactoria en 2016"
recode		Iintexp16_pos (.=1) if divergintexp16 >0 & divergintexp16!=.
recode		Iintexp16_pos (.=0) if divergintexp16 <=0 & divergintexp16!=.
label def	Iintexp16_pos 1 "satisfactorio" 0 "insatisfactorio"
label val	Iintexp16_pos Iintexp16_pos

gen			Iintexp16_neg=.
label var	Iintexp16_neg "La divergencia de int.exp. es insatisfactoria en 2016"
recode		Iintexp16_neg (.=1) if divergintexp16<=0 & divergintexp16!=.
recode		Iintexp16_neg (.=0) if divergintexp16>0 & divergintexp16!=.
label def	Iintexp16_neg 1 "insatisfactorio" 0 "satisfactorio"
label val	Iintexp16_neg Iintexp16_neg

*>> cross-check
pwcorr		Iintexp16_pos Iintexp16_neg



**********************************************************
**  generamos tres objetivos hist�ricos para cada uno de *
**  los dos desempe�os de exportaci�n                    *
**********************************************************

*b1) objetivo hist�rico de exportaci�n 2017 (tres lambdas)
*--> l1=0.25 : fast update
*--> l2=0.50 : avg  update
*--> l3=0.75 : slow update
gen			objdesexport17_l1 =.
gen			objdesexport17_l2 =.
gen			objdesexport17_l3 =.
label var	objdesexport17_l1 "Objetivo de desempe�o en export 2017 (fast)"
label var	objdesexport17_l2 "Objetivo de desempe�o en export 2017 (avg)"
label var	objdesexport17_l3 "Objetivo de desempe�o en export 2017 (slow)"
replace		objdesexport17_l1 = 0.25*objdesexport16 + 0.75*desexport16 ///
				if j==1 & manufactura==1
replace		objdesexport17_l2 = 0.50*objdesexport16 + 0.50*desexport16 ///
				if j==1 & manufactura==1
replace		objdesexport17_l3 = 0.75*objdesexport16 + 0.25*desexport16 ///
				if j==1 & manufactura==1


*b2) objetivo hist�rico de intensidad exportadora 2017 (tres lambdas)
*--> l1=0.25 : fast update
*--> l2=0.50 : avg  update
*--> l3=0.75 : slow update
gen			objdesintexp17_l1 =.
gen			objdesintexp17_l2 =.
gen			objdesintexp17_l3 =.
label var	objdesintexp17_l1 "Objetivo de desempe�o en int.exp. 2017 (fast)"
label var	objdesintexp17_l2 "Objetivo de desempe�o en int.exp. 2017 (avg)"
label var	objdesintexp17_l3 "Objetivo de desempe�o en int.exp. 2017 (slow)"
replace		objdesintexp17_l1 = 0.25*objdesintexp16 + 0.75*desintexp16 ///
				if j==1 & manufactura==1
replace		objdesintexp17_l2 = 0.50*objdesintexp16 + 0.50*desintexp16 ///
				if j==1 & manufactura==1
replace		objdesintexp17_l3 = 0.75*objdesintexp16 + 0.25*desintexp16 ///
				if j==1 & manufactura==1
				

*Divergencia en exportaciones (hist�rico) tres lambdas
gen			divergexport17_l1=.
gen			divergexport17_l2=.
gen			divergexport17_l3=.
label var	divergexport17_l1 "Divergencia desemp export - obj export 2017 (fast)"
label var	divergexport17_l2 "Divergencia desemp export - obj export 2017 (avg)"
label var	divergexport17_l3 "Divergencia desemp export - obj export 2017 (slow)"
replace		divergexport17_l1 = desexport17 - objdesexport17_l1 ///
				if j==1 & manufactura==1
replace		divergexport17_l2 = desexport17 - objdesexport17_l2 ///
				if j==1 & manufactura==1
replace		divergexport17_l3 = desexport17 - objdesexport17_l3 ///
				if j==1 & manufactura==1

*Divergencia en intensidad exportadora (hist�rico) tres lambdas
gen			divergintexp17_l1=.
gen			divergintexp17_l2=.
gen			divergintexp17_l3=.
label var	divergintexp17_l1 "Divergencia desemp export - obj export 2017 (fast)"
label var	divergintexp17_l2 "Divergencia desemp export - obj export 2017 (avg)"
label var	divergintexp17_l3 "Divergencia desemp export - obj export 2017 (slow)"
replace		divergintexp17_l1 = desintexp17 - objdesintexp17_l1  ///
				if j==1 & manufactura==1
replace		divergintexp17_l2 = desintexp17 - objdesintexp17_l2  ///
				if j==1 & manufactura==1
replace		divergintexp17_l3 = desintexp17 - objdesintexp17_l3  ///
				if j==1 & manufactura==1

				
*def label for satisfactory and unsatisfactory
label def	lbl_satis 1 "Satisfactorio" 0 "Insatisfactorio"
label def	lbl_unsat 1 "Insatisfactorio" 0 "Satisfactorio"

*Spline specification (1 of 6) export l1 (fast)
gen			Iexport17_l1_pos =.
label var	Iexport17_l1_pos "Para l1: la divergencia de exportaciones es satisfactoria en 2017"
recode		Iexport17_l1_pos (.=1) if divergexport17_l1 > 0 & j==1 & manufactura==1
recode		Iexport17_l1_pos (.=0) if divergexport17_l1 <=0 & j==1 & manufactura==1
label val	Iexport17_l1_pos lbl_satis

gen			Iexport17_l1_neg =.
label var	Iexport17_l1_neg "Para l1: la divergencia de exportaciones insatisfactoria en 2017"
recode		Iexport17_l1_neg (.=1) if divergexport17_l1 <=0 & j==1 & manufactura==1
recode		Iexport17_l1_neg (.=0) if divergexport17_l1 > 0 & j==1 & manufactura==1
label val	Iexport17_l1_neg lbl_unsat

*>> crosscheck
pwcorr		Iexport17_l1_pos Iexport17_l1_neg //must be exactly -1

*Spline specification (2 of 6) export l2 (avg)
gen			Iexport17_l2_pos =.
label var	Iexport17_l2_pos "Para l2: la divergencia de exportaciones es satisfactoria en 2017"
recode		Iexport17_l2_pos (.=1) if divergexport17_l2 > 0 & j==1 & manufactura==1
recode		Iexport17_l2_pos (.=0) if divergexport17_l2 <=0 & j==1 & manufactura==1
label val	Iexport17_l2_pos lbl_satis

gen			Iexport17_l2_neg =.
label var	Iexport17_l2_neg "Para l2: la divergencia de exportaciones insatisfactoria en 2017"
recode		Iexport17_l2_neg (.=1) if divergexport17_l2 <=0 & j==1 & manufactura==1
recode		Iexport17_l2_neg (.=0) if divergexport17_l2 > 0 & j==1 & manufactura==1
label val	Iexport17_l2_neg lbl_unsat

*>> crosscheck
pwcorr		Iexport17_l2_pos Iexport17_l2_neg //must be exactly -1

*Spline specification (3 of 6) export l3 (slow)
gen			Iexport17_l3_pos =.
label var	Iexport17_l3_pos "Para l3: la divergencia de exportaciones es satisfactoria en 2017"
recode		Iexport17_l3_pos (.=1) if divergexport17_l3 > 0 & j==1 & manufactura==1
recode		Iexport17_l3_pos (.=0) if divergexport17_l3 <=0 & j==1 & manufactura==1
label val	Iexport17_l3_pos lbl_satis

gen			Iexport17_l3_neg =.
label var	Iexport17_l3_neg "Para l3: la divergencia de exportaciones insatisfactoria en 2017"
recode		Iexport17_l3_neg (.=1) if divergexport17_l3 <=0 & j==1 & manufactura==1
recode		Iexport17_l3_neg (.=0) if divergexport17_l3 > 0 & j==1 & manufactura==1
label val	Iexport17_l3_neg lbl_unsat

*>> crosscheck
pwcorr		Iexport17_l3_pos Iexport17_l3_neg //must be exactly -1



*Spline specification (4 of 6) intexp l1 (fast)
gen			Iintexp17_l1_pos =.
label var	Iintexp17_l1_pos "Para l1: la divergencia de int. export. es satisfactoria en 2017"
recode		Iintexp17_l1_pos (.=1) if divergintexp17_l1 > 0 & j==1 & manufactura==1
recode		Iintexp17_l1_pos (.=0) if divergintexp17_l1 <=0 & j==1 & manufactura==1
label val	Iintexp17_l1_pos lbl_satis

gen			Iintexp17_l1_neg =.
label var	Iintexp17_l1_neg "Para l1: la divergencia de int. export. es insatisfactoria en 2017"
recode		Iintexp17_l1_neg (.=1) if divergintexp17_l1 <=0 & j==1 & manufactura==1
recode		Iintexp17_l1_neg (.=0) if divergintexp17_l1 > 0 & j==1 & manufactura==1
label val	Iintexp17_l1_neg lbl_unsat

*>> crosscheck
pwcorr		Iintexp17_l1_pos Iintexp17_l1_neg //must be exactly -1


*Spline specification (5 of 6) intexp l2 (avg)
gen			Iintexp17_l2_pos =.
label var	Iintexp17_l2_pos "Para l2: la divergencia de int. export. es satisfactoria en 2017"
recode		Iintexp17_l2_pos (.=1) if divergintexp17_l2 > 0 & j==1 & manufactura==1
recode		Iintexp17_l2_pos (.=0) if divergintexp17_l2 <=0 & j==1 & manufactura==1
label val	Iintexp17_l2_pos lbl_satis

gen			Iintexp17_l2_neg =.
label var	Iintexp17_l2_neg "Para l2: la divergencia de int. export. es insatisfactoria en 2017"
recode		Iintexp17_l2_neg (.=1) if divergintexp17_l2 <=0 & j==1 & manufactura==1
recode		Iintexp17_l2_neg (.=0) if divergintexp17_l2 > 0 & j==1 & manufactura==1
label val	Iintexp17_l2_neg lbl_unsat

*>> crosscheck
pwcorr		Iintexp17_l2_pos Iintexp17_l2_neg //must be exactly -1


*Spline specification (6 of 6) intexp l3 (slow)
gen			Iintexp17_l3_pos =.
label var	Iintexp17_l3_pos "Para l3: la divergencia de int. export. es satisfactoria en 2017"
recode		Iintexp17_l3_pos (.=1) if divergintexp17_l3 > 0 & j==1 & manufactura==1
recode		Iintexp17_l3_pos (.=0) if divergintexp17_l3 <=0 & j==1 & manufactura==1
label val	Iintexp17_l3_pos lbl_satis

gen			Iintexp17_l3_neg =.
label var	Iintexp17_l3_neg "Para l3: la divergencia de int. export. es insatisfactoria en 2017"
recode		Iintexp17_l3_neg (.=1) if divergintexp17_l3 <=0 & j==1 & manufactura==1
recode		Iintexp17_l3_neg (.=0) if divergintexp17_l3 > 0 & j==1 & manufactura==1
label val	Iintexp17_l3_neg lbl_unsat

*>> crosscheck
pwcorr		Iintexp17_l3_pos Iintexp17_l3_neg //must be exactly -1





*c) Objetivo de exportaci�n e intensidad exportadora social 2015, 2016 y 2017
** Generamos promedios de exportaci�n por industria
foreach		x in 15 16 17{
bysort		ciiu2d: egen		countexp`x' = count(desexport`x')
bysort		ciiu2d: egen		totalexp`x' = total(desexport`x')
gen			objsocexport`x' = totalexp`x' / countexp`x'
replace		objsocexport`x'=. if j!=1 | manufactura!=1
label var	objsocexport`x' "Objetivo social de exportaci�n por industria en 20`x'"
drop		countexp`x' totalexp`x'
}
tab1		ciiu2d if j==1 & manufactura==1
bysort		ciiu2d: tabstat		objsocexport* , c(s) s(n me min med max)

** Generamos promedios robustos (medianas) de exportaci�n x ind.
foreach		x in 15 16 17{
bysort		ciiu2d: egen		objsocexport`x'_r = median(desexport`x')
replace		objsocexport`x'_r =. if j!=1 | manufactura!=1
label var	objsocexport`x'_r "Robusto: objetivo social de exportaci�n x ind. en 20`x'"
}
tab1		ciiu2d if j==1 & manufactura==1
bysort		ciiu2d: tabstat objsocexport*_r, c(s) s(n me min max)

** Generamos promedios de objetivo social de intensidad exportadora x industria
foreach		x in 15 16 17{
bysort		ciiu2d: egen countint`x' = count(desintexp`x')
bysort		ciiu2d: egen totalint`x' = total(desintexp`x')
gen			objsocintexp`x' = totalint`x' / countint`x'
replace		objsocintexp`x' =. if j!=1 | manufactura !=1
label var	objsocintexp`x' "Objetivo social de intensidad export x ind en 20`x'"
drop		countint`x' totalint`x'
}
tab1		ciiu2d if j==1 & manufactura==1
bysort		ciiu2d: tabstat objsocintexp*, c(s) s(n me min max)

** Generamos promedios robustos (medianas) de obj soc de int exp x industria
foreach		x in 15 16 17{
bysort		ciiu2d: egen objsocintexp`x'_r = median(desintexp`x')
replace		objsocintexp`x'_r =. if j!=1 | manufactura!=1
label var	objsocintexp`x'_r "Robusto: objetivo social de int exp x ind en 20`x'"
}
bysort		ciiu2d: tabstat		objsocintexp*_r, c(s) s(n me min max)

**** ALL OK

* C�lculo de divergencias x a�o x empresa (1 of 4): export normal 
foreach		x in 15 16 17{
gen			divergsocexport`x' =.
replace		divergsocexport`x' = desexport`x' - objsocexport`x'
label var	divergsocexport`x' "Divergencia desempe�o social export 20`x'"
}
* C�lculo de divergencias x a�o x empresa (2 of 4): export robusto
foreach		x in 15 16 17{
gen			divergsocexport`x'_r =.
replace		divergsocexport`x'_r = desexport`x' - objsocexport`x'_r
label var	divergsocexport`x'_r "Robusto: divergencia desempe�o social export 20`x'"
}
* C�lculo de divergencias x a�o x empresa (3 of 4): intexp normal
foreach		x in 15 16 17{
gen			divergsocintexp`x' =.
replace		divergsocintexp`x' = desintexp`x' - objsocintexp`x'
label var	divergsocintexp`x' "Divergencia desempe�o social int export 20`x'"
}
* C�lculo de divergencias x a�o x empresa (4 of 4): intexp robusto
foreach		x in 15 16 17{
gen			divergsocintexp`x'_r =.
replace		divergsocintexp`x'_r = desintexp`x' - objsocintexp`x'_r
label var	divergsocintexp`x'_r "Robusto: divergencia desempe�o social int export 20`x'"
}

*Indicadores de desempe�o en exportaciones satisfactorio/insatisfactorio
*>>1 of 4: exportaci�n normal (satis + insatis)
foreach		x in 15 16 17{
gen			Isocexport`x'_pos=.
gen			Isocexport`x'_neg=.
label var	Isocexport`x'_pos "Divergencia social satisfactoria en exports 20`x'"
label var	Isocexport`x'_neg "Divergencia social insatisfactoria en exports 20`x'"
recode		Isocexport`x'_pos (.=1) if divergsocexport`x'>0 & ///
										j==1 & manufactura==1
recode		Isocexport`x'_pos (.=0) if divergsocexport`x'<=0 & ///
										j==1 & manufactura==1
recode		Isocexport`x'_neg (.=1) if divergsocexport`x'<=0 & ///
										j==1 & manufactura==1
recode		Isocexport`x'_neg (.=0) if divergsocexport`x'>0 & ///
										j==1 & manufactura==1
label val	Isocexport`x'_pos lbl_satis
label val	Isocexport`x'_neg lbl_unsat

*cross-check
pwcorr		Isocexport`x'_pos Isocexport`x'_neg //must be -1
}


*>>2 of 4: exportaci�n robusta (satis + insatis)
foreach		x in 15 16 17{
gen			Isocexport`x'_r_pos=.
gen			Isocexport`x'_r_neg=.
label var	Isocexport`x'_r_pos "Robusto: divergencia social satisfactoria en exports 20`x'"
label var	Isocexport`x'_r_neg "Robusto: divergencia social insatisfactoria en exports 20`x'"
recode		Isocexport`x'_r_pos (.=1) if divergsocexport`x'_r>0 & ///
										j==1 & manufactura==1
recode		Isocexport`x'_r_pos (.=0) if divergsocexport`x'_r<=0 & ///
										j==1 & manufactura==1
recode		Isocexport`x'_r_neg (.=1) if divergsocexport`x'_r<=0 & ///
										j==1 & manufactura==1
recode		Isocexport`x'_r_neg (.=0) if divergsocexport`x'_r>0 & ///
										j==1 & manufactura==1
label val	Isocexport`x'_r_pos lbl_satis
label val	Isocexport`x'_r_neg lbl_unsat

*cross-check
pwcorr		Isocexport`x'_r_pos Isocexport`x'_r_neg //must be -1
}

*>>3 of 4: intensidad export normal (satis + insatis)
foreach		x in 15 16 17{
gen			Isocintexp`x'_pos=.
gen			Isocintexp`x'_neg=.
label var	Isocintexp`x'_pos "Divergencia social satisfactoria en int. exp. 20`x'"
label var	Isocintexp`x'_neg "Divergencia social insatisfactoria en int.exp. 20`x'"
recode		Isocintexp`x'_pos (.=1) if divergsocintexp`x'>0 & ///
									j==1 & manufactura==1
recode		Isocintexp`x'_pos (.=0) if divergsocintexp`x'<=0 & ///
									j==1 & manufactura==1
recode		Isocintexp`x'_neg (.=1) if divergsocintexp`x'<=0 & ///
									j==1 & manufactura==1
recode		Isocintexp`x'_neg (.=0) if divergsocintexp`x'>0 & ///
									j==1 & manufactura==1
label val	Isocintexp`x'_pos lbl_satis
label val	Isocintexp`x'_neg lbl_unsat
*>>cross-check
pwcorr		Isocintexp`x'_pos Isocintexp`x'_neg
}
*

*>>4 of 4: intensidad export robusta (satis + insatis)
foreach		x in 15 16 17{
gen			Isocintexp`x'_r_pos=.
gen			Isocintexp`x'_r_neg=.
label var	Isocintexp`x'_r_pos "Robusto: divergencia social satisfactoria en int. exp. 20`x'"
label var	Isocintexp`x'_r_neg "Robusto: divergencia social insatisfactoria en int.exp. 20`x'"
recode		Isocintexp`x'_r_pos (.=1) if divergsocintexp`x'_r>0 & ///
									j==1 & manufactura==1
recode		Isocintexp`x'_r_pos (.=0) if divergsocintexp`x'_r<=0 & ///
									j==1 & manufactura==1
recode		Isocintexp`x'_r_neg (.=1) if divergsocintexp`x'_r<=0 & ///
									j==1 & manufactura==1
recode		Isocintexp`x'_r_neg (.=0) if divergsocintexp`x'_r>0 & ///
									j==1 & manufactura==1
label val	Isocintexp`x'_r_pos lbl_satis
label val	Isocintexp`x'_r_neg lbl_unsat
*>>cross-check
pwcorr		Isocintexp`x'_r_pos Isocintexp`x'_r_neg
}

*

************************************************************************
* Generamos las versiones ihs de las variables de performance feedback *
************************************************************************
*> ihs: inverse hyperbolic sine transformation (similar to log trans w/ negs)
**generamos variable de subpoblaci�n:
tab2		j manufactura
gen			k = j
label var	k "la empresa innova, exporta y es de manufacturas"
recode		k (1=0) if manufactura==0
tab2		k manufactura // ahora 
tab2		j k
*subpopulation variable now is k instead of j.



* Para ventas *
*> Hist�rico
gen			ihs_divergventas16 		 = divergventas16 / 1000 if k==1
replace		ihs_divergventas16		 = log(ihs_divergventas16 + sqrt(1 + ihs_divergventas16^2 )) if k==1
gen			ihs_divergventas17_l1	 = divergventas17_l1 / 1000 if k==1
replace		ihs_divergventas17_l1	 = log(ihs_divergventas17_l1 + sqrt(1 + ihs_divergventas17_l1^2 )) if k==1
gen			ihs_divergventas17_l2	 = divergventas17_l2 / 1000 if k==1
replace		ihs_divergventas17_l2	 = log(ihs_divergventas17_l2 + sqrt(1 + ihs_divergventas17_l2^2 )) if k==1
gen			ihs_divergventas17_l3	 = divergventas17_l3 / 1000 if k==1
replace		ihs_divergventas17_l3	 = log(ihs_divergventas17_l3 + sqrt(1 + ihs_divergventas17_l3^2 )) if k==1
*> Social
foreach		x in 15 16 17{
gen			ihs_divergsocventas`x'	 = divergsocventas`x' / 1000 if k==1
replace		ihs_divergsocventas`x'	 = log(ihs_divergsocventas`x' + sqrt(1 + ihs_divergsocventas`x'^2 )) if k==1
gen			ihs_divergsocventas`x'_r = divergsocventas`x'_r / 1000 if k==1
replace		ihs_divergsocventas`x'_r = log(ihs_divergsocventas`x'_r + sqrt(1 + ihs_divergsocventas`x'_r^2 )) if k==1
}

* Para exports *
*> Hist�rico
gen			ihs_divergexport16		 = divergexport16 / 1000 if k==1
replace		ihs_divergexport16		 = log(ihs_divergexport16 + sqrt(1 + ihs_divergexport16^2 )) if k==1
gen			ihs_divergexport17_l1	 = divergexport17_l1 / 1000 if k==1
replace		ihs_divergexport17_l1	 = log(ihs_divergexport17_l1 + sqrt(1 + ihs_divergexport17_l1^2 )) if k==1
gen			ihs_divergexport17_l2	 = divergexport17_l2 / 1000 if k==1
replace		ihs_divergexport17_l2	 = log(ihs_divergexport17_l2 + sqrt(1 + ihs_divergexport17_l2^2 )) if k==1
gen			ihs_divergexport17_l3	 = divergexport17_l3 / 1000 if k==1
replace		ihs_divergexport17_l3	 = log(ihs_divergexport17_l3 + sqrt(1 + ihs_divergexport17_l3^2 )) if k==1
*> Social
foreach		x in 15 16 17{
gen			ihs_divergsocexport`x'	 = divergsocexport`x' / 1000 if k==1
replace		ihs_divergsocexport`x'	 = log(ihs_divergsocexport`x' + sqrt(1 + ihs_divergsocexport`x'^2 )) if k==1
gen			ihs_divergsocexport`x'_r = divergsocexport`x'_r / 1000 if k==1
replace		ihs_divergsocexport`x'_r = log(ihs_divergsocexport`x'_r + sqrt(1 + ihs_divergsocexport`x'_r^2 )) if k==1
}

* Para intensidad exportadora * (no precision problems w/ this one)
*> Hist�rico
gen			ihs_divergintexp16		 = log(divergintexp16 + sqrt(1 + divergintexp16^2 )) if k==1
gen			ihs_divergintexp17_l1	 = log(divergintexp17_l1 + sqrt(1 + divergintexp17_l1^2 )) if k==1
gen			ihs_divergintexp17_l2	 = log(divergintexp17_l2 + sqrt(1 + divergintexp17_l2^2 )) if k==1
gen			ihs_divergintexp17_l3	 = log(divergintexp17_l3 + sqrt(1 + divergintexp17_l3^2 )) if k==1
*> Social
foreach		x in 15 16 17{
gen			ihs_divergsocintexp`x'	 = log(divergsocintexp`x' + sqrt(1 + divergsocintexp`x'^2 )) if k==1
gen			ihs_divergsocintexp`x'_r = log(divergsocintexp`x'_r + sqrt(1 + divergsocintexp`x'_r^2 )) if k==1
}
*

*revisamos que la falta de cambios no sean errores, sino solo ceros!
**** ventas *
count 		if ihs_divergventas16==0 // 2 de 2
count 		if ihs_divergventas17_l1==0 // 1 de 1 
count 		if ihs_divergventas17_l2==0 // 1 de 1 
count 		if ihs_divergventas17_l3==0 // 1 de 1
count 		if ihs_divergsocventas15_r==0 // 1 de 1
count 		if ihs_divergsocventas16_r==0 // 2 de 2
count 		if ihs_divergsocventas17_r==0 // 1 de 1
**** exports *
count 		if ihs_divergexport16==0 // 2 de 2
count 		if ihs_divergexport17_l1==0 // 2 de 2
count 		if ihs_divergexport17_l2==0 // 2 de 2
count 		if ihs_divergexport17_l3==0 // 2 de 2
count 		if ihs_divergsocexport15_r==0 // 9 de 9
count 		if ihs_divergsocexport16_r==0 // 9 de 9
count 		if ihs_divergsocexport17_r==0 // 9 de 9
**** ****

* OK ahora copiamos las etiquetas de las variables anteriores
*VENTAS
local		u divergventas16 divergventas17_l1 divergventas17_l2 divergventas17_l3 divergsocventas15 divergsocventas15_r divergsocventas16 divergsocventas16_r divergsocventas17 divergsocventas17_r
foreach		x of local u {
*_crcslbl	ihs_`x' `x' 
local 		lbl : variable label `x'
label var	ihs_`x' `"ihs (miles S/): `lbl' "'
}
*EXPORT
local		u divergexport16 divergexport17_l1 divergexport17_l2 divergexport17_l3 divergsocexport15 divergsocexport15_r divergsocexport16 divergsocexport16_r divergsocexport17 divergsocexport17_r
foreach		x of local u {
*_crcslbl	ihs_`x' `x' 
local 		lbl : variable label `x'
label var	ihs_`x' `"ihs (miles S/): `lbl' "'
}
*Intensidad Exportadora
local		u divergintexp16 divergintexp17_l1 divergintexp17_l2 divergintexp17_l3 divergsocintexp15 divergsocintexp15_r divergsocintexp16 divergsocintexp16_r divergsocintexp17 divergsocintexp17_r
foreach		x of local u {
*_crcslbl	ihs_`x' `x' 
local 		lbl : variable label `x'
label var	ihs_`x' `"ihs: `lbl' "'
}
*OK ahora tenemos ihs de la divergencia disponible




****
* arreglamos manualmente los problemas de precision m�s all� de lo siguiente
* seg�n \url{https://blog.stata.com/2012/04/02/the-penultimate-guide-to-precision/#section5}
/*

5.2 The smallest value of epsilon such that 1+epsilon \neq 1 is

     Storage
     type      epsilon       epsilon in %21x        epsilon in base 10
     -----------------------------------------------------------------
     float      �2^-23     �1.0000000000000X-017    �1.19209289551e-07
     double     �2^-52     �1.0000000000000X-034    �2.22044604925e-16
     -----------------------------------------------------------------
	 
	 0.0000000000000002
	 0.0000000000000400
	 
	 
Epsilon is the distance from 1 to the next number on the floating-point number
line. The corresponding unit roundoff error is u = �epsilon/2. The unit 
roundoff error is the maximum relative roundoff error that is introduced by 
the floating-point number storage scheme.

The smallest value of epsilon such that x+epsilon \neq x is approximately 
|x|*epsilon, and the corresponding unit roundoff error is �|x|*epsilon/2
*/


/*         ESTO ES LO QUE ESTABA ANTES, CON PROBLEMAS DE PRECISI�N
* Para ventas
gen			ihs_divergventas16 		 = log(divergventas16 + sqrt(1 + divergventas16^2 )) if k==1
gen			ihs_divergventas17_l1	 = log(divergventas17_l1 + sqrt(1 + divergventas17_l1^2 )) if k==1
gen			ihs_divergventas17_l2	 = log(divergventas17_l2 + sqrt(1 + divergventas17_l2^2 )) if k==1
gen			ihs_divergventas17_l3	 = log(divergventas17_l3 + sqrt(1 + divergventas17_l3^2 )) if k==1
foreach		x in 15 16 17{
gen			ihs_divergsocventas`x'	 = log(divergsocventas`x' + sqrt(1 + divergsocventas`x'^2 )) if k==1
gen			ihs_divergsocventas`x'_r = log(divergsocventas`x'_r + sqrt(1 + divergsocventas`x'_r^2 )) if k==1
}
* Para exports
gen			ihs_divergexport16		 = log(divergexport16 + sqrt(1 + divergexport16^2 )) if k==1
gen			ihs_divergexport17_l1	 = log(divergexport17_l1 + sqrt(1 + divergexport17_l1^2 )) if k==1
gen			ihs_divergexport17_l2	 = log(divergexport17_l2 + sqrt(1 + divergexport17_l2^2 )) if k==1
gen			ihs_divergexport17_l3	 = log(divergexport17_l3 + sqrt(1 + divergexport17_l3^2 )) if k==1
foreach		x in 15 16 17{
gen			ihs_divergsocexport`x'	 = log(divergsocexport`x' + sqrt(1 + divergsocexport`x'^2 )) if k==1
gen			ihs_divergsocexport`x'_r = log(divergsocexport`x'_r + sqrt(1 + divergsocexport`x'_r^2 )) if k==1
}
* Para intensidad exportadora
gen			ihs_divergintexp16		 = log(divergintexp16 + sqrt(1 + divergintexp16^2 )) if k==1
gen			ihs_divergintexp17_l1	 = log(divergintexp17_l1 + sqrt(1 + divergintexp17_l1^2 )) if k==1
gen			ihs_divergintexp17_l2	 = log(divergintexp17_l2 + sqrt(1 + divergintexp17_l2^2 )) if k==1
gen			ihs_divergintexp17_l3	 = log(divergintexp17_l3 + sqrt(1 + divergintexp17_l3^2 )) if k==1
foreach		x in 15 16 17{
gen			ihs_divergsocintexp`x'	 = log(divergsocintexp`x' + sqrt(1 + divergsocintexp`x'^2 )) if k==1
gen			ihs_divergsocintexp`x'_r = log(divergsocintexp`x'_r + sqrt(1 + divergsocintexp`x'_r^2 )) if k==1
}
*
*/

/* YA NO
* imputamos a mano los valores del ihs para los casos donde STATA pierde precisi�n
/*
divergventas16 : 9 casos
divergventas17_l1 : 3 casos
divergventas17_l2 : 3 casos
divergventas17_l3 : 3 casos
divergsocventas15 : 51 casos
divergsocventas15_r : 0 casos
divergsocventas16 : 57 casos
divergsocventas16_r : 0 casos
divergsocventas17 : 59 casos
divergsocventas17_r : 0 casos

divergexport16 : 5 casos
divergexport17_l1 : 1 caso
divergexport17_l2 : 2 casos
divergexport17_l3 : 2 casos
diversocexport15 : 38 casos
divergsocexport15_r : 0 casos
divergsocexport16 : 32 casos
divergsocexport16_r : 5 casos
divergsocexport17 : 49 casos
divergsocexport17_r : 4 casos

no hay casos de imprecisi�n para la intensidad exportadora
*/

*begin
*> imprecisi�n en ihs_divergventas16
count 		if ihs_divergventas16==. & k==1 // cases
format		%12.0f divergventas16
list 		id divergventas16 ihs_divergventas16 if k==1 & ihs_divergventas16==.
br			id divergventas16 ihs_divergventas16 if k==1 & ihs_divergventas16==.
*/






/*
Por calcular:
14. Observar la data a ver c�mo se comporta por industria... a ver c�mo modelamos
>> Variables que contienen montos de innovaci�n
   idint idint17 idint16 idint15 
>   idext idext17 idext16 idext15 
>   ingdi ingdi17 ingdi16 ingdi15 
>   mktng mktng17 mktng16 mktng15 
>   propi propi17 propi16 propi15 
>   capac capac17 capac16 capac15 
>   softw softw17 softw16 softw15 
>   capit capit17 capit16 capit15
*/

**creamos las variables de totales de montos de I+D
foreach		x in 15 16 17{
egen		busqueda`x' = rowtotal( idint`x' idext`x' mktng`x' propi`x' capac`x' softw`x' capit`x')
label var	busqueda`x' "Monto total gastado en I+D en 20`x'"
replace		busqueda`x' =. if j!=1 | manufactura!=1
}
 
 
**********************************************************
* Generamos mediciones para la intensidad en la b�squeda *
*    de nuevas alternativas en 2015-2017 por empresa	 *
**********************************************************


*Idea 1: Raw amounts of I+D: investment by year
*>> (normal amounts)
foreach		x in 15 16 17{
gen			rawsearch`x' = busqueda`x'
label var	rawsearch`x' "Monto total de I+D en 20`x'"
}

*Idea 1.1: IHS(x) transformation of Idea 1:
*>> ihs(z) = log[z + \sqrt{(1 + z^2)}]
foreach		x in 15 16 17{
gen			sq_rawsearch`x' = rawsearch`x' * rawsearch`x'
gen			ihs_rawsearch`x' = log(rawsearch`x' + (1 + sq_rawsearch`x')^(0.5))
label var	ihs_rawsearch`x' "Inv. hyperb. sine: Monto total de I+D en 20`x'"
drop		sq_rawsearch`x' // drop variable de ayuda para el c�lculo de ihs
}


*Idea 2: Raw amounts of I+D: difference between previous and current year
*>> (simple substraction, 2015 data lost)
*For 2016:

gen			var_rawsearch16 = rawsearch16 - rawsearch15
label var	var_rawsearch16 "Variaci�n: monto total de I+D en 2016 menos 2015"

*For 2017:
gen			var_rawsearch17 = rawsearch17 - rawsearch16
label var	var_rawsearch17 "Variaci�n: monto total del I+D 2017 menos 2016"


*Idea 2.1: IHS(x) of Idea 2:
*For 2016 y 2017:
foreach		x in 16 17{
gen			sq_var_rawsearch`x' = var_rawsearch`x' * var_rawsearch`x'
gen			ihs_var_rawsearch`x' = log(var_rawsearch`x' + ///
									(1 + sq_var_rawsearch`x')^(0.5))
label var	ihs_var_rawsearch`x' "Inv. hyperb. sine: Variaci�n monto I+D en 20`x'"
drop		sq_var_rawsearch`x' //drop variable de ayuda para el c�lc de ihs
}


*Idea 3: % of I+D over total sales: by year
*>> (normal amounts)
foreach		x in 15 16 17{
gen			intsearch`x' = rawsearch`x' / desventas`x'
label var	intsearch`x' "Intensidad de la b�squeda mediante I+D en 20`x'"
}

*Idea 4: % of I+D over total sales: difference between previous and current year
*>> (simple substraction, 2015 data lost)
*For 2016:
gen			var_intsearch16 = intsearch16 - intsearch15
label var	var_intsearch16 "Variaci�n: intensidad b�squeda via I+D en 2016 menos 2015"

*For 2017:
gen			var_intsearch17 = intsearch17 - intsearch16
label var	var_intsearch17 "Variaci�n: intensidad b�squeda via I+D en 2017 menos 2016"



*Idea 5: Following Jiang and Holburn (2018): dichotimise Ideas 2 and Idea 4:
*	>> when negative or zero = 0 meaning they stopped searching
*	>> when positive = 1 meaning they increased searching

*<> Variaci�n en monto invertido 2016 vs 2015
gen			dic_var_rawsearch16 =.
recode		dic_var_rawsearch16 (.=1) if var_rawsearch16>0 & var_rawsearch16!=.
recode		dic_var_rawsearch16 (.=0) if var_rawsearch16<=0 & var_rawsearch16!=.
label def	dic_var_rawsearch16 1 "Aument� en 2016" 0 "Disminuy� en 2016"
label val	dic_var_rawsearch16 dic_var_rawsearch16
label var	dic_var_rawsearch16 "Dicot: indica si monto de I+D aument� en 2016"

*<> Variaci�n en monto invertido 2017 vs 2016
gen			dic_var_rawsearch17=.
recode		dic_var_rawsearch17 (.=1) if var_rawsearch17>0 & var_rawsearch17!=.
recode		dic_var_rawsearch17 (.=0) if var_rawsearch17<=0 & var_rawsearch17!=.
label def	dic_var_rawsearch17 1 "Aument� en 2017" 0 "Disminuy� en 2017"
label val	dic_var_rawsearch17 dic_var_rawsearch17
label var	dic_var_rawsearch17 "Dicot: indica si monto de I+D aument� en 2017"

*<> Variaci�n en intensidad de b�squeda via I+D 2016 vs 2015
gen			dic_var_intsearch16=.
recode		dic_var_intsearch16 (.=1) if var_intsearch16>0 & var_intsearch16!=.
recode		dic_var_intsearch16 (.=0) if var_intsearch16<=0 & var_intsearch16!=.
label def	dic_var_intsearch16 1 "Aument� en 2016" 0 "Disminuy� en 2016"
label val	dic_var_intsearch16 dic_var_intsearch16
label var	dic_var_intsearch16 "Dicot: indica si int. I+D aument� en 2016"

*<> Variaci�n en intensidad de b�squeda via I+D 2017 vs 2016
gen			dic_var_intsearch17 =.
recode		dic_var_intsearch17 (.=1) if var_intsearch17 >0 & var_intsearch17!=.
recode		dic_var_intsearch17 (.=0) if var_intsearch17<=0 & var_intsearch17!=.
label def	dic_var_intsearch17 1 "Aument� en 2017" 0 "Disminuy� en 2017"
label val	dic_var_intsearch17 dic_var_intsearch17 
label var	dic_var_intsearch17 "Dicot: indica si int. I+D aument� en 2017"


*Idea 6: Crear las variables de SLACK por a�o

*> Slack idea 1: capacidad no utilizada y disponible

tabstat		capins15 capins16 capins17, c(s) s(n me sd min p10 p25 med p75 p90 max)
tabstat		capins15 capins16 capins17 if k==1, c(s) ///
										s(n me sd min p10 p25 med p75 p90 max)
										
foreach		x in 15 16 17{
gen			double slack_capi`x' = 100 - capins`x' if k==1
label var	slack_capi`x' "Slack: Capacidad de producci�n disponible 20`x'"
}

tabstat		slack_capi*, c(s) s(n me min p10 p25 med p75 p90 max)
*kdensity	slack_ci15
*kdensity	slack_ci16
*kdensity	slack_ci17
*pwcorr		slack_ci*

*> Slack idea 2: overhead available
tabstat		sueldo*, c(s) s(n me min p10 p25 med p75 p90 max)
tabstat		sueldo* if k==1, c(s) s(n me min p10 p25 med p75 p90 max)

foreach		x in 15 16 17{
gen			double slack_wage`x' = sueldo`x' / 1000 if k==1
label var	slack_wage`x' "(miles S/) overhead in 20`x'"
}
tabstat		slack_wage*, c(s) s(n me min p10 p25 med p75 p90 max)
*pwcorr		slack*

*>>>> IHS transform of slack_wage
foreach		x in 15 16 17{
gen			double ihs_slack_wage`x' = log( slack_wage`x' + ///
											sqrt(1 + slack_wage`x'^2))
local		lbl : variable label slack_wage`x'
label var	ihs_slack_wage`x' `"ihs: `lbl'"'
}
*

*> Slack idea 3: profit margin
foreach		x in 15 16 17{
gen			double slack_prof`x' = ventas`x' - sueldo`x' if k==1
label var	slack_prof`x' "(miles S/.) Slack: margen simple de utilidad en 20`x'"
}
tabstat		slack_prof*, c(s) s(n me min p10 p25 med p75 p90 max)
*comment: slack_prof* est� muy cerca del borde de precisi�n de STATA e+16
* convirtiendolo a miles de S/
foreach		x in 15 16 17{
replace		slack_prof`x' = slack_prof`x' / 1000 if k==1
}

*>>>>>>> IHS transform of slack_prof
foreach		x in 15 16 17{
gen			double ihs_slack_prof`x' = log( slack_prof`x' + ///
											sqrt(1 + slack_prof`x'^2))
local		lbl : variable label slack_prof`x'
label var	ihs_slack_prof`x' `"ihs: `lbl'"'
}
*




*Idea 7: Reshape database!

*> generamos las variables de a�o de observaci�n y a�os de operaci�n
foreach		x in 15 16 17{
gen			y_`x' = `x'
label var	y_`x' "A�o de la observaci�n: 20`x'"
}

foreach		x in 15 16 17{
gen			y_oper`x' = y_oper - (17 - `x')
label var	y_oper`x' "A�os de operaci�n en 20`x'"
}

* a

/*
Notes: 
1. current data is wide. Each line is an observation, and vars express
values of data for each year
2. ddbb must be transformed from wide to long. In long data format, each
line represent the value of a variable for a specific year, multiple
lines correspond to a single observation, and a single variables houses
the value of said variables across multiple years.

--> From WIDE to LONG
*/

keep		id departamento tipo_org ciiu2d k y_oper15 y_oper16 y_oper17 ///
			y_15 y_16 y_17 FACTOR_FINAL idint-capit15  ventas15-capins17 ///
			divergventas17_l1	divergventas17_l2	divergventas17_l3	divergsocventas17	divergsocventas17_r	ihs_divergventas17_l1	ihs_divergventas17_l2	ihs_divergventas17_l3	ihs_divergsocventas17	ihs_divergsocventas17_r	Iventas17_l1_pos	Iventas17_l2_pos	Iventas17_l3_pos	Isocventas17_pos	Isocventas17_r_pos	divergexport17_l1	divergexport17_l2	divergexport17_l3	divergsocexport17	divergsocexport17_r	ihs_divergexport17_l1	ihs_divergexport17_l2	ihs_divergexport17_l3	ihs_divergsocexport17	ihs_divergsocexport17_r	Iexport17_l1_pos	Iexport17_l2_pos	Iexport17_l3_pos	Isocexport17_pos	Isocexport17_r_pos	divergintexp17_l1	divergintexp17_l2	divergintexp17_l3	divergsocintexp17	divergsocintexp17_r	ihs_divergintexp17_l1	ihs_divergintexp17_l2	ihs_divergintexp17_l3	ihs_divergsocintexp17	ihs_divergsocintexp17_r	Iintexp17_l1_pos	Iintexp17_l2_pos	Iintexp17_l3_pos	Isocintexp17_pos	Isocintexp17_r_pos	slack_capi17	slack_wage17	ihs_slack_wage17	slack_prof17	ihs_slack_prof17	rawsearch17	ihs_rawsearch17	var_rawsearch17	ihs_var_rawsearch17	dic_var_rawsearch17	intsearch17	var_intsearch17	dic_var_intsearch17 ///
			divergventas16	divergsocventas16	divergsocventas16_r	ihs_divergventas16	ihs_divergsocventas16	ihs_divergsocventas16_r	Iventas16_pos	Isocventas16_pos	Isocventas16_r_pos	divergexport16	divergsocexport16	divergsocexport16_r	ihs_divergexport16	ihs_divergsocexport16	ihs_divergsocexport16_r	Iexport16_pos	Isocexport16_pos	Isocexport16_r_pos	divergintexp16	divergsocintexp16	divergsocintexp16_r	ihs_divergintexp16	ihs_divergsocintexp16	ihs_divergsocintexp16_r	Iintexp16_pos	Isocintexp16_pos	Isocintexp16_r_pos	slack_capi16	slack_wage16	ihs_slack_wage16	slack_prof16	ihs_slack_prof16	rawsearch16	ihs_rawsearch16	var_rawsearch16	ihs_var_rawsearch16	dic_var_rawsearch16	intsearch16	var_intsearch16	dic_var_intsearch16 ///
			divergsocventas15	divergsocventas15_r	ihs_divergsocventas15	ihs_divergsocventas15_r	Isocventas15_pos	Isocventas15_r_pos	divergsocexport15	divergsocexport15_r	ihs_divergsocexport15	ihs_divergsocexport15_r	Isocexport15_pos	Isocexport15_r_pos	divergsocintexp15	divergsocintexp15_r	ihs_divergsocintexp15	ihs_divergsocintexp15_r	Isocintexp15_pos	Isocintexp15_r_pos	slack_capi15	slack_wage15	ihs_slack_wage15	slack_prof15	ihs_slack_prof15	rawsearch15	ihs_rawsearch15	intsearch15

drop		idint idext ingdi mktng propi capac softw capit		






*rename, reorder and create missing variable values		
foreach		x in FACTOR_FINAL tipo_org departamento ciiu2d k{
order		`x', after(id)
}
*
foreach		x in idint idext ingdi mktng propi capac softw capit{
order		`x'16, after(`x'15)
order		`x'17, after(`x'16)
}
*

foreach		x in  y_oper y_ {
order		`x'15, after(FACTOR_FINAL)
order		`x'16, after(`x'15)
order		`x'17, after(`x'16)
}
*

gen			divergventas16_l1=divergventas16
_crcslbl	divergventas16_l1 divergventas16
order		divergventas16_l1, before(divergventas17_l1)
gen			divergventas16_l2=divergventas16
_crcslbl	divergventas16_l2 divergventas16
order		divergventas16_l2, before(divergventas17_l2)
gen			divergventas16_l3=divergventas16
_crcslbl	divergventas16_l3 divergventas16
order		divergventas16_l3, before(divergventas17_l3)
drop		divergventas16

foreach		x in 1 2 3{
gen			divergventas15_l`x'=.
order		divergventas15_l`x', before(divergventas16_l`x')
}

rename		divergventas15_l1 divergventas_l1_15
rename		divergventas16_l1 divergventas_l1_16
rename		divergventas17_l1 divergventas_l1_17
rename		divergventas15_l2 divergventas_l2_15
rename		divergventas16_l2 divergventas_l2_16
rename		divergventas17_l2 divergventas_l2_17
rename		divergventas15_l3 divergventas_l3_15
rename		divergventas16_l3 divergventas_l3_16
rename		divergventas17_l3 divergventas_l3_17

foreach		x in 1 2 3{
gen			Iventas15_l`x'_pos=.
order		Iventas15_l`x'_pos, before(Iventas17_l`x'_pos)
gen			Iventas16_l`x'_pos=Iventas16_pos
label val	Iventas16_l`x'_pos Iventas16_pos
_crcslbl	Iventas16_l`x'_pos Iventas16_pos
order		Iventas16_l`x'_pos, before(Iventas17_l`x'_pos)
} 
* 
drop		Iventas16_pos


order		divergsocventas15 - divergsocventas17_r, after(divergventas_l3_17)

rename		divergsocventas15_r divergsocventas_r_15
rename		divergsocventas16_r divergsocventas_r_16
rename		divergsocventas17_r divergsocventas_r_17


order		ihs_divergventas16 - ihs_divergsocventas17_r, ///
				after(divergsocventas_r_17)

foreach		x in 1 2 3{
gen			ihs_divergventas_l`x'_15=.
gen			ihs_divergventas_l`x'_16 = ihs_divergventas16
_crcslbl	ihs_divergventas_l`x'_16 ihs_divergventas16
order		ihs_divergventas_l`x'_15, before(ihs_divergventas17_l`x')
order		ihs_divergventas_l`x'_16, before(ihs_divergventas17_l`x')
}
drop		ihs_divergventas16
rename		ihs_divergventas17_l1 ihs_divergventas_l1_17
rename		ihs_divergventas17_l2 ihs_divergventas_l2_17
rename		ihs_divergventas17_l3 ihs_divergventas_l3_17


order		ihs_divergsocventas16, after(ihs_divergsocventas15)
order		ihs_divergsocventas17, after(ihs_divergsocventas16)

order		ihs_divergsocventas16_r, after(ihs_divergsocventas15_r)
order		ihs_divergsocventas17_r, after(ihs_divergsocventas16_r)

rename		ihs_divergsocventas15_r ihs_divergsocventas_r_15
rename		ihs_divergsocventas16_r ihs_divergsocventas_r_16
rename		ihs_divergsocventas17_r ihs_divergsocventas_r_17

rename 		Iventas15_l1_pos   Iventas_l1_pos_15
rename 		Iventas16_l1_pos   Iventas_l1_pos_16
rename 		Iventas17_l1_pos   Iventas_l1_pos_17
rename 		Iventas15_l2_pos   Iventas_l2_pos_15
rename 		Iventas16_l2_pos   Iventas_l2_pos_16
rename 		Iventas17_l2_pos   Iventas_l2_pos_17
rename 		Iventas15_l3_pos   Iventas_l3_pos_15
rename 		Iventas16_l3_pos   Iventas_l3_pos_16
rename 		Iventas17_l3_pos   Iventas_l3_pos_17
rename 		Isocventas15_pos   Isocventas_pos_15   
rename 		Isocventas16_pos   Isocventas_pos_16   
rename 		Isocventas17_pos   Isocventas_pos_17   
rename 		Isocventas15_r_pos   Isocventas_r_pos_15   
rename 		Isocventas16_r_pos   Isocventas_r_pos_16   
rename 		Isocventas17_r_pos   Isocventas_r_pos_17   


foreach		x in 1 2 3{
gen			divergexport15_l`x'=.
order		divergexport15_l`x', before(divergexport16)
gen			divergexport16_l`x'=divergexport16
order		divergexport16_l`x', after(divergexport15_l`x')
_crcslbl	divergexport16_l`x' divergexport16
order		divergexport17_l`x', after(divergexport16_l`x')
}
drop		divergexport16

rename 		divergexport15_l1 divergexport_l1_15
rename 		divergexport16_l1 divergexport_l1_16
rename 		divergexport17_l1 divergexport_l1_17
rename 		divergexport15_l2 divergexport_l2_15
rename 		divergexport16_l2 divergexport_l2_16
rename 		divergexport17_l2 divergexport_l2_17
rename 		divergexport15_l3 divergexport_l3_15
rename 		divergexport16_l3 divergexport_l3_16
rename 		divergexport17_l3 divergexport_l3_17

order		divergsocexport15 - divergsocexport17_r, after(divergexport_l3_17)

rename		divergsocexport15_r divergsocexport_r_15
rename		divergsocexport16_r divergsocexport_r_16
rename		divergsocexport17_r divergsocexport_r_17

order			ihs_divergexport16 - ihs_divergsocexport17_r, after(divergsocexport_r_17)
foreach			x in 1 2 3{
	gen			ihs_divergexport_l`x'_15=.
	order		ihs_divergexport_l`x'_15, before(ihs_divergexport17_l`x')
	gen			ihs_divergexport_l`x'_16=ihs_divergexport16
	_crcslbl 	ihs_divergexport_l`x'_16 ihs_divergexport16
	order		ihs_divergexport_l`x'_16, before(ihs_divergexport17_l`x')
}
drop			ihs_divergexport16
rename			ihs_divergexport17_l1 ihs_divergexport_l1_17
rename			ihs_divergexport17_l2 ihs_divergexport_l2_17
rename			ihs_divergexport17_l3 ihs_divergexport_l3_17

order			ihs_divergsocexport16, after(ihs_divergsocexport15)
order			ihs_divergsocexport17, after(ihs_divergsocexport16)
order			ihs_divergsocexport16_r, after(ihs_divergsocexport15_r)
order			ihs_divergsocexport17_r, after(ihs_divergsocexport16_r)
rename			ihs_divergsocexport15_r ihs_divergsocexport_r_15
rename			ihs_divergsocexport16_r ihs_divergsocexport_r_16
rename			ihs_divergsocexport17_r ihs_divergsocexport_r_17

foreach			i in 1 2 3{
	gen			Iexport_l`i'_pos_15=.
	order		Iexport_l`i'_pos_15, before(Iexport17_l`i'_pos)
	gen			Iexport_l`i'_pos_16 = Iexport16_pos
	_crcslbl	Iexport_l`i'_pos_16 Iexport16_pos
	order		Iexport_l`i'_pos_16, before(Iexport17_l`i'_pos)
	rename		Iexport17_l`i'_pos Iexport_l`i'_pos_17
}
drop			Iexport16_pos

order			Isocexport15_pos-Isocexport17_r_pos, after(Iexport_l3_pos_17)

rename 		Isocexport15_pos Isocexport_pos_15
rename 		Isocexport16_pos Isocexport_pos_16
rename 		Isocexport17_pos Isocexport_pos_17
rename 		Isocexport15_r_pos Isocexport_r_pos_15
rename 		Isocexport16_r_pos Isocexport_r_pos_16
rename 		Isocexport17_r_pos Isocexport_r_pos_17

order		Iexport_l1_pos_15 - Isocexport_r_pos_17, ///
				after(ihs_divergsocexport_r_17)
*
order		divergintexp16 divergintexp17_l1 divergintexp17_l2 divergintexp17_l3 divergsocintexp15 divergsocintexp16 divergsocintexp17 divergsocintexp15_r divergsocintexp16_r divergsocintexp17_r ihs_divergintexp16 ihs_divergintexp17_l1 ihs_divergintexp17_l2 ihs_divergintexp17_l3 ihs_divergsocintexp15 ihs_divergsocintexp15_r ihs_divergsocintexp16 ihs_divergsocintexp16_r ihs_divergsocintexp17 ihs_divergsocintexp17_r, after(Isocexport_r_pos_17)


foreach			x in 1 2 3{
	gen			divergintexp_l`x'_15=.
	order		divergintexp_l`x'_15, before(divergintexp17_l`x')
	gen			divergintexp_l`x'_16 = divergintexp16
	_crcslbl	divergintexp_l`x'_16 divergintexp16
	order		divergintexp_l`x'_16, before(divergintexp17_l`x')
	rename		divergintexp17_l`x' divergintexp_l`x'_17
}
drop			divergintexp16


rename			divergsocintexp15_r divergsocintexp_r_15
rename			divergsocintexp16_r divergsocintexp_r_16
rename			divergsocintexp17_r divergsocintexp_r_17

foreach			x in 1 2 3{
	gen			ihs_divergintexp_l`x'_15=.
	order		ihs_divergintexp_l`x'_15, before(ihs_divergintexp17_l`x')
	gen			ihs_divergintexp_l`x'_16 = ihs_divergintexp16
	_crcslbl	ihs_divergintexp_l`x'_16 ihs_divergintexp16
	order		ihs_divergintexp_l`x'_16, before(ihs_divergintexp17_l`x')
	rename		ihs_divergintexp17_l`x' ihs_divergintexp_l`x'_17
}
drop			ihs_divergintexp16


order			ihs_divergsocintexp15_r, after(ihs_divergsocintexp17)
order			ihs_divergsocintexp16_r, after(ihs_divergsocintexp15_r)
rename			ihs_divergsocintexp15_r ihs_divergsocintexp_r_15
rename			ihs_divergsocintexp16_r ihs_divergsocintexp_r_16
rename			ihs_divergsocintexp17_r ihs_divergsocintexp_r_17


foreach			x in 1 2 3{
	gen			Iintexp_l`x'_pos_15=.
	order		Iintexp_l`x'_pos_15, before(Iintexp17_l`x'_pos)
	gen			Iintexp_l`x'_pos_16 = Iintexp16_pos
	_crcslbl	Iintexp_l`x'_pos_16 Iintexp16_pos
	order		Iintexp_l`x'_pos_16, before(Iintexp17_l`x'_pos)
	rename		Iintexp17_l`x'_pos Iintexp_l`x'_pos_17
}
drop			Iintexp16_pos

rename			Isocintexp15_r_pos Isocintexp_r_pos_15
rename			Isocintexp16_r_pos Isocintexp_r_pos_16
rename			Isocintexp17_r_pos Isocintexp_r_pos_17


order			slack_capi15 slack_capi16 slack_capi17 slack_wage15 slack_wage16 slack_wage17 ihs_slack_wage15 ihs_slack_wage16 ihs_slack_wage17 slack_prof15 slack_prof16 slack_prof17 ihs_slack_prof15 ihs_slack_prof16 ihs_slack_prof17 ///
				, after(Isocintexp_r_pos_17)

gen			var_rawsearch15=.
order		var_rawsearch15, before(var_rawsearch16)
gen			ihs_var_rawsearch15=.
order		ihs_var_rawsearch15, before(ihs_var_rawsearch16)
gen			var_intsearch15=.
order		var_intsearch15, before(var_intsearch16)
gen			dic_var_rawsearch15=.
order		dic_var_rawsearch15, before(dic_var_rawsearch16)
gen			dic_var_intsearch15=.
order		dic_var_intsearch15, before(dic_var_intsearch16)

order		dic_var_rawsearch15 , before(intsearch15)
order		dic_var_rawsearch16 , before(intsearch15)
order		dic_var_rawsearch17 , before(intsearch15)


foreach		x in 15 16 17{
rename		Isocintexp`x'_pos Isocintexp_pos_`x'
}


reshape		long y_ y_oper idint idext ingdi mktng propi capac softw capit ///
			ventas export capita sueldo produc capins ///
			divergventas_l1_ divergventas_l2_ divergventas_l3_ ///
			divergsocventas divergsocventas_r_   ///
			ihs_divergventas_l1_ ihs_divergventas_l2_ ihs_divergventas_l3_ ///
			ihs_divergsocventas ihs_divergsocventas_r_ ///
			Iventas_l1_pos_ Iventas_l2_pos_ Iventas_l3_pos_ ///
			Isocventas_pos_ Isocventas_r_pos_ ///
			divergexport_l1_ divergexport_l2_ divergexport_l3_ ///
			divergsocexport divergsocexport_r_ ///
			ihs_divergexport_l1_ ihs_divergexport_l2_ ihs_divergexport_l3_ ///
			ihs_divergsocexport ihs_divergsocexport_r_ ///
			Iexport_l1_pos_ Iexport_l2_pos_ Iexport_l3_pos_ ///
			Isocexport_pos_ Isocexport_r_pos_ ///
			divergintexp_l1_ divergintexp_l2_ divergintexp_l3_ ///
			divergsocintexp divergsocintexp_r_ ///
			ihs_divergintexp_l1_ ihs_divergintexp_l2_ ihs_divergintexp_l3_ ///
			ihs_divergsocintexp ihs_divergsocintexp_r_ ///
			Iintexp_l1_pos_ Iintexp_l2_pos_ Iintexp_l3_pos_ ///
			Isocintexp_pos_ Isocintexp_r_pos_ ///
			slack_capi slack_wage ihs_slack_wage slack_prof ihs_slack_prof ///
			rawsearch ihs_rawsearch var_rawsearch ihs_var_rawsearch ///
			dic_var_rawsearch intsearch var_intsearch dic_var_intsearch ///
			, i(id) j(year)

// all is ok, no reshape error!


save		"$c/long_ddbb_eniim2018.dta", replace

svyset		
/*
      pweight: FACTOR_FINAL
          VCE: linearized
  Single unit: missing
     Strata 1: ciiu2d
         SU 1: id
        FPC 1: <zero>
*/


mixed		ventas sueldo || ciiu2d: || id:
mixed		ventas sueldo || ciiu2d: || id:, reml
mixed		ventas sueldo || id:

mixed		rawsearch c.divergsocventas#i.Isocventas_pos_ ///
					  || ciiu2d: || id: if k==1
mixed		intsearch c.divergsocventas#i.Isocventas_pos_ ///
					  || ciiu2d: || id: if k==1, reml

mixed		rawsearch c.divergsocventas#i.Isocventas_pos_ ///
					  c.divergsocexport#i.Isocexport_pos_ ///
					  || ciiu2d: || id: if k==1
*



***********
*    *    *
*   *!*   *
*  * ! *  *
* *  !  * *
**   !   **
***********

*CHECK THIS ONE:					  
mixed		rawsearch c.divergsocventas#i.Isocventas_pos_ ///
					  c.divergsocexport#i.Isocexport_pos_ ///
					  || ciiu2d: || id: if k==1, reml
*CHECK THIS ONEEEEEEEEEEEEEEEEE:
mixed		rawsearch c.divergsocventas#i.Isocventas_pos_ ///
					  c.divergsocexport#i.Isocexport_pos_ ///
					  slack_capi slack_wage slack_prof ///
					  || ciiu2d: || id: if k==1, reml

*************************************************
* FALTA PROBAR CON EL ROBUST SOCIAL PERFORMANCE *
*************************************************




*Test 
mixed		rawsearch c.divergventas_l1_#i.Iventas_l1_pos ///
					  || ciiu2d: || id:
mixed		rawsearch c.divergventas_l2_#i.Iventas_l2_pos ///
					  || ciiu2d: || id:					  
mixed		rawsearch c.divergventas_l3_#i.Iventas_l3_pos ///
					  || ciiu2d: || id:
*




***********
*    *    *
*   *!*   *
*  * ! *  *
* *  !  * *
**   !   **
***********

* CHECK THIS TOO, looks too good!
mixed		rawsearch c.divergventas_l1_#i.Iventas_l1_pos ///
					  c.divergexport_l1_#i.Iexport_l1_pos ///
					  || ciiu2d: || id:
mixed		rawsearch c.divergventas_l2_#i.Iventas_l2_pos ///
					  c.divergexport_l2_#i.Iventas_l2_pos ///
					  || ciiu2d: || id:					  
mixed		rawsearch c.divergventas_l3_#i.Iventas_l3_pos ///
					  c.divergexport_l3_#i.Iventas_l3_pos ///
					  || ciiu2d: || id:

* WITH SLACK VARIABLES:
mixed		rawsearch c.divergventas_l1_#i.Iventas_l1_pos ///
					  c.divergexport_l1_#i.Iexport_l1_pos ///
					  slack_capi slack_wage slack_prof ///
					  || ciiu2d: || id:
mixed		rawsearch c.divergventas_l2_#i.Iventas_l2_pos ///
					  c.divergexport_l2_#i.Iventas_l2_pos ///
					  slack_capi slack_wage slack_prof ///
					  || ciiu2d: || id:					  
mixed		rawsearch c.divergventas_l3_#i.Iventas_l3_pos ///
					  c.divergexport_l3_#i.Iventas_l3_pos ///
					  slack_capi slack_wage slack_prof ///
					  || ciiu2d: || id:


					  
					  
					  
					  
					  
** UNSUCCESSFUL
mixed		rawsearch c.divergventas#i.Iventas_pos_ ///
					  c.divergexport#i.Iexport_pos_ ///
					  slack_capi slack_wage slack_prof ///
					  || ciiu2d: || id: if k==1, reml

mixed		rawsearch c.divergsocventas#i.Isocventas_pos_ ///
					  c.divergsocintexp#i.Isocintexp_pos_ ///
					  slack_capi slack_wage slack_prof ///
					  || ciiu2d: || id: if k==1, reml

					  
s
s
s
** Sobre el inventario de relaciones para \delta Ventas
*******************************************************

*1) Divergencia hist�rica en ventas 2016 vs variables de b�squeda

*1.1- divergventas16

tabstat		divergventas16 rawsearch16 ihs_rawsearch16 var_rawsearch16 ///
			ihs_rawsearch16 dic_var_rawsearch16 intsearch16 var_intsearch16 ///
			dic_var_intsearch16, c(s) s(n me min p10 med p90 max skew)

**************************
* Industrias disponibles: 
* alimentos: 	10 
* bebidas: 		11 
* textiles:		13
* confecciones:	14 
* cuero:		15
* papel:		17
* imprenta:		18
* petr�leo:		19 
* qu�micos:		20
* farmac�utica:	21 
* pl�sticos:	22 
* mineral n/met	23
* metales b�s:	24
* prod metal:	25 
* eqp elect:	27 
* maq. & eqpo:	28 
* veh�culos:	29
* muebles:		31 
* ot. manuf:	32
**************************
 
*1.1.a- 
scatter		rawsearch16 divergventas16 
lowess		rawsearch16 divergventas16
regress		rawsearch16 c.divergventas16#i.Iventas16_pos
regress		rawsearch16 c.divergventas16#i.Iventas16_pos, robust

*1.1.b-
scatter 	ihs_rawsearch16 divergventas16
lowess		ihs_rawsearch16 divergventas16
lowess		ihs_rawsearch16 divergventas16 if ihs_rawsearch16!=0

regress		ihs_rawsearch16 c.divergventas16#i.Iventas16_pos
regress		ihs_rawsearch16 c.divergventas16#i.Iventas16_pos, robust
regress		ihs_rawsearch16 c.divergventas16#i.Iventas16_pos if ihs_rawsearch16!=0

*1.1.c-
scatter		var_rawsearch16 divergventas16
lowess		var_rawsearch16 divergventas16

regress		var_rawsearch16 c.divergventas16#i.Iventas16_pos
regress		var_rawsearch16 c.divergventas16#i.Iventas16_pos, robust

*1.1.d-
scatter		ihs_var_rawsearch16 divergventas16
lowess		ihs_var_rawsearch16 divergventas16

regress		ihs_var_rawsearch16 c.divergventas16#i.Iventas16_pos
regress		ihs_var_rawsearch16 c.divergventas16#i.Iventas16_pos, robust

*1.1.e-
scatter		dic_var_rawsearch16 divergventas16

logit		dic_var_rawsearch16 c.divergventas16#i.Iventas16_pos

*1.1.f-
scatter		intsearch16 divergventas16
lowess		intsearch16 divergventas16

regress		intsearch16 c.divergventas16#i.Iventas16_pos
tobit		intsearch16 c.divergventas16#i.Iventas16_pos, ll(0) ul(1)

*1.1.g-		
scatter		var_intsearch16 divergventas16
lowess		var_intsearch16 divergventas16

regress		var_intsearch16 c.divergventas16#i.Iventas16_pos
regress		var_intsearch16 c.divergventas16#i.Iventas16_pos, robust

*1.1.h-
scatter		dic_var_intsearch16 divergventas16
lowess		dic_var_intsearch16 divergventas16

logit		dic_var_intsearch16 c.divergventas16#i.Iventas16_pos



*2) Divergecia hist�rica en objetivo de ventas 2017
*2.1- Divergencia con lambda:0.25 (quick update)
*2.1.a-
scatter		rawsearch17 divergventas17_l1 
lowess		rawsearch17 divergventas17_l1

regress		rawsearch17 c.divergventas17_l1#i.Iventas17_l1_pos
regress		rawsearch17 c.divergventas17_l1#i.Iventas17_l1_pos, robust

*2.1.b-
scatter		ihs_rawsearch17 divergventas17_l1
lowess		ihs_rawsearch17 divergventas17_l1

regress		ihs_rawsearch17 c.divergventas17_l1#i.Iventas17_l1_pos
regress		ihs_rawsearch17 c.divergventas17_l1#i.Iventas17_l1_pos, robust

*2.1.c-		
scatter		var_rawsearch17 divergventas17_l1
lowess		var_rawsearch17 divergventas17_l1

regress		var_rawsearch17 c.divergventas17_l1#i.Iventas17_l1_pos
regress		var_rawsearch17 c.divergventas17_l1#i.Iventas17_l1_pos, robust

*2.1.d-
scatter		ihs_var_rawsearch17 divergventas17_l1
lowess		ihs_var_rawsearch17 divergventas17_l1

regress		ihs_var_rawsearch17 c.divergventas17_l1#i.Iventas17_l1_pos

*2.1.e-		
scatter		dic_var_rawsearch17 divergventas17_l1

logit		dic_var_rawsearch17 c.divergventas17_l1#i.Iventas17_l1_pos

*2.1.f-
scatter		intsearch17 divergventas17_l1
lowess		intsearch17 divergventas17_l1

regress		intsearch17 c.divergventas17_l1#i.Iventas17_l1_pos
regress		intsearch17 c.divergventas17_l1#i.Iventas17_l1_pos, robust




scatter		rawsearch17 divergventas17_l2
lowess		rawsearch17 divergventas17_l2

regress		rawsearch17 c.divergventas17_l2#i.Iventas17_l2_pos
regress		ihs_rawsearch17 c.divergventas17_l2#i.Iventas17_l2_pos




scatter		rawsearch17 divergventas17_l3
lowess		rawsearch17 divergventas17_l3

regress		rawsearch17 c.divergventas17_l3#i.Iventas17_l3_pos
regress		ihs_rawsearch17 c.divergventas17_l3#i.Iventas17_l3_pos













 /*

foreach

scatter		gasto_rd_2017 ventas17
scatter		gasto_rd_2016 ventas16


Variables para el an�lisis:







*II) Revisamos variables de inter�s: cambio en I+D

gen			change17_16 = gasto_rd_2017 - gasto_rd_2016
label var	change17_16 "cambio en el gasto en rd del 2016 al 2017"

gen			change16_15 = gasto_rd_2016 - gasto_rd_2015
label var	change16_15 "cambio en el gasto en rd del 2015 al 2016"
 

tabstat		change17_16 change16_15, c(s) s(n me min p10 q p90 max skew)
*kdensity	change17_16 
*br if 		change17_16 > 3000000 | change17_16 < -3000000


*III) Revisamos variables de inter�s: cambio en aspiraci�n

*IIIa) desempe�o crudo en ventas

foreach		x in 15 16 17 {
gen			desempe�o_20`x' = ventas`x' - sueldo`x'
label var	desempe�o_20`x' "Ventas menos sueldos en 20`x'"
}
tabstat		desempe�o*, c(s) s(n me min p10 q p90 max skew)

*aspiraci�n en margen
gen			dif_perf_16_15 = desempe�o_2016 - desempe�o_2015 
label var	dif_perf_16_15 "Diferencia de desempe�o 2016 vs 2015"
gen			dif_perf_17_16 = desempe�o_2017 - desempe�o_2016
label var	dif_perf_17_16 "Diferencia de desempe�o 2017 vs 2016"
tabstat		dif_perf_16_15 dif_perf_17_16, c(s) s(n me min p10 q p90 max skew)


*aspiraci�n en exportaci�n
gen			dif_expo_16_15 = export16 - export15
label var	dif_expo_16_15 "Diferencia de exportaci�n 2016 vs 2015"
gen			dif_expo_17_16 = export17 - export16
label var	dif_expo_17_16 "Diferencia de exportaci�n 2017 vs 2016"
tabstat		dif_expo_16_15 dif_expo_17_16, c(s) s(n me min p10 q p90 max skew)



scatter		change17_16 dif_perf_17_16
scatter		change17_16 dif_expo_17_16

scatter		change16_15 dif_perf_16_15
scatter		change16_15 dif_expo_16_15


s

/*
*generamos dicot�mica de desempe�o
gen			I_perf = 0
recode		I_perf (0=1) if dif_perf_16_15>0
label var	I_perf "indica si dif_perf_16_15 > 0"
label def	I_perf 0 "perf2016 < perf2015" 1 "perf2016 > perf2015"
label val	I_perf I_perf

*generamos dicot�mica de exportaci�n
gen			I_expo = 0
recode		I_expo (0=1) if dif_expo_16_15 > 0
label var	I_expo "indica si dif_expo_16_15 > 0"
label def	I_expo 0 "expo2016 < expo2015" 1 "expo2016 > expo2015"
label val	I_expo I_expo




gen





s

svyset 		id [pweight=FACTOR_FINAL], strata(ciiu2d) vce(linearized) singleunit(missing)

mixed		change17_16 i.I_perf#c.dif_perf_16_15 i.I_expo#c.dif_expo_16_15 ///
			|| ciiu2d: 
			
mixed		change17_16 i.I_expo#c.dif_expo_16_15 ///
			|| ciiu2d: 


			
			
			
/*
*Intentamos con intensidad en R+D

foreach		x in 15 16 17 {
gen			intensidad_rd`x' = gasto_rd_20`x' / ventas`x'
label var	intensidad_rd`x' "intensidad del gasto de ID en 20`x'"
}
tabstat		intensidad_rd*, c(s) s(n me min p10 q p90 max)


kdensity 	intensidad_rd15
kdensity	intensidad_rd16
kdensity	intensidad_rd17


scatter		intensidad_rd17 dif_perf_16_15
scatter		intensidad_rd17 dif_expo_16_15

/*
gen			profits = I_perf*dif_perf_16_15
gen			xperf = I_expo*dif_expo_16_15
*/

gen			perflower = 0
recode		perflower (0=1) if I_perf==0
gen			perfhigher = 0
recode		perfhigher (0=1) if I_perf==1

gen			exportlower = 0
recode		exportlower (0=1) if I_expo==0
gen			exporthigher = 0
recode		exporthigher (0=1) if I_expo==1


gen			profitslower = dif_perf_16_15 * perflower
gen			profitshigher = dif_perf_16_15 * perfhigher
gen			exportslower = dif_expo_16_15 * exportlower
gen			exportshigher = dif_expo_16_15 * exporthigher

gen			profitslower2 = profitslower*profitslower
gen			profitshigher2 = profitshigher*profitshigher
gen			exportslower2 = exportslower*exportslower
gen			exportshigher2 = exportshigher*exportshigher




regress		intensidad_rd17 profitslower2 profitshigher2 exportslower2 ///
							exportshigher2
s
nl 			intensidad_rd17 profits xperf

mixed		intensidad_rd17 i.I_perf#c.dif_perf_16_15 i.I_expo#c.dif_expo_16_15 ///
			|| ciiu2d: 


			
			
			
*survey set:
*svyset 		id [pweight=FACTOR_FINAL], strata(ciiu2d) vce(linearized) singleunit(missing)





/*
tabstat		gasto_rd_20*, c(s) s(n me min p10 q p90 max)
tabstat		gasto_rd_20*, c(s) s(skew kurt)





























