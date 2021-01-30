********************************************************************************
* Revisamos la bbdd de innovación en la industria manufacturera y de servicios *
* Perú 2015, 2016 y 2017  													   *
********************************************************************************

clear 		all
set more	off

*def. ubicación bbdd
gl			a "E:\12-tesis\0-BBDD_secundarias\INEI2018\0-bbdd iniciales"
gl			b "E:\12-tesis\0-BBDD_secundarias\INEI2018\1-bbdd intermedias"
gl			c "E:\12-tesis\0-BBDD_secundarias\INEI2018\2-bbdd finales"


*abrimos bbdd intermedia convertida orig. de spss (.sav) a .dta
u			"$b\INNOVACION_2018_I.dta", clear


count
/*
n = 2084 observaciones

Caps.
1.-  Localización
2.-  Identificación
3.-  Actividades de innovación
4.-  Financiamiento
5.-  Cadenas productivas e innovación
6.-  Recursos humanos
7.-  Resultados de la innovación
8.-  Propiedad intelectual
9.-  Fuentes de información y vinculaciones
10.- Obstáculos
11.- Información económica básica de la empresa

--> vamos a revisar
1.-  Localización
2.-  Identificación
3.-  Actividades de innovación
7.-  Resultados de la innovación
11.- Información económica básica de la empresa
*/



** Revisamos cap.1 Localización
**¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

d			ID NCUEST NOMBREDD CCDD NOMBREPP CCPP NOMBREDI CCDI LATITUD ///
			LONGITUD SECTOR AREA ZONA MZA FRENTE TIPVIA NOMVIA PTANUM BLOCK ///
			INT PISO MZ LOTE KM REFERENC
			
codebook	ID NCUEST NOMBREDD CCDD NOMBREPP CCPP NOMBREDI CCDI LATITUD ///
			LONGITUD SECTOR AREA ZONA MZA FRENTE TIPVIA NOMVIA PTANUM BLOCK ///
			INT PISO MZ LOTE KM REFERENC
// [no vacías y relevantes: ID, NCUEST, NOMBREDD]

*drop variables vacías
drop		CCDD NOMBREPP CCPP NOMBREDI CCDI LATITUD ///
			LONGITUD SECTOR AREA ZONA MZA FRENTE TIPVIA NOMVIA PTANUM BLOCK ///
			INT PISO MZ LOTE KM REFERENC
			
*destring nombre de departamentos
tab1		NOMBREDD //encuesta mayoritariamente de Lima (considerar p/ depurar)
encode		NOMBREDD, generate(departamento)
order		departamento, after(NOMBREDD)
tab1		departamento, nol
drop		NOMBREDD
rename		ID id
rename		NCUEST ncuest




** Revisamos cap.2 Identificación
**¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

*revisamos variables en este capítulo
d			C2P2_1_1 C2P2_1_2 C2P2_1_3 C2P2_1_4 C2P2_1_5 C2P2_1_5_1 C2P2_1_6 ///
			C2P2_1_6_1 C2P2_1_7 C2P2_1_7_1 C2P2_1_8 C2P2_1_8_1 C2P2_1_9_D ///
			C2P2_1_9_COD C2P2_1_10 C2P2_1_10_7_O C2P2_2_A1 C2P2_2_A2 ///
			C2P2_2_A2_O C2P2_2_A3 C2P2_2_A3_1 C2P2_2_A4 C2P2_2_A4_1 ///
			C2P2_2_A5 C2P2_2_A5_1 C2P2_2_B1 C2P2_2_B2 C2P2_2_B2_O C2P2_2_B3 ///
			C2P2_2_B3_1 C2P2_2_B4 C2P2_2_B4_1 C2P2_2_B5 C2P2_2_B5_1 RESFIN
//variables relevantes: C2P2_1_4 C2P2_1_9_COD C2P2_1_10 C2P2_2_A2
// Año de inicio, CIIU, tipo de organización, cargo del encuestado

* mantenemos solo las variables anteriores
drop		C2P2_1_1 C2P2_1_2 C2P2_1_3 		 	C2P2_1_5 C2P2_1_5_1 C2P2_1_6 ///
			C2P2_1_6_1 C2P2_1_7 C2P2_1_7_1 C2P2_1_8 C2P2_1_8_1 C2P2_1_9_D ///
									C2P2_1_10_7_O C2P2_2_A1 		 ///
			C2P2_2_A2_O C2P2_2_A3 C2P2_2_A3_1 C2P2_2_A4 C2P2_2_A4_1 ///
			C2P2_2_A5 C2P2_2_A5_1 C2P2_2_B1 C2P2_2_B2 C2P2_2_B2_O C2P2_2_B3 ///
			C2P2_2_B3_1 C2P2_2_B4 C2P2_2_B4_1 C2P2_2_B5 C2P2_2_B5_1 RESFIN

*revisamos variables que quedan en capítulo
codebook	C2P2_1_4 C2P2_1_9_COD C2P2_1_10 C2P2_2_A2
*generamos variable de años de operación
gen			y_oper = 2018 - C2P2_1_4 +1
order		y_oper, after(C2P2_1_4)
label var	y_oper "años de operación hasta 2018"
tab1		y_oper //23 empresas operaron desde el 2015 al 2018 (considerar p/ depurar)
rename		C2P2_1_4 y_inic

*generamos variable de código CIIU
tab1		C2P2_1_9_COD
destring	C2P2_1_9_COD, generate(ciiu4d) //ciiu 4 dígitos
order		ciiu4d, after(C2P2_1_9_COD)
gen			ciiu2d = floor(ciiu4d / 100)
order		ciiu2d, after(ciiu4d)
tab1		ciiu2d //ciiu 2 dígitos
drop		C2P2_1_9_COD
label var	ciiu2d "CIIU dos dígitos"
*etiquetado de clasificaciones

#delimit ;
label def	ciiu2d 
				   10 "alimentos" 
				   11 "bebidas" 
				   12 "tabaco" 
				   13 "textiles" 
				   14 "confecciones" 
				   15 "cuero" 
				   16 "maderas" 
				   17 "papel" 
				   18 "imprenta" 
				   19 "petróleo" 
				   20 "químicos" 
				   21 "farmacéutica" 
				   22 "plásticos" 
				   23 "mineral no metal" 
				   24 "metales básicos" 
				   25 "prod. metales" 
				   26 "computadoras" 
				   27 "equipo eléctrico" 
				   28 "maquinaria y equipo" 
				   29 "vehículos" 
				   30 "otros equipos de transporte" 
				   31 "muebles" 
				   32 "otras manufacturas" 
				   33 "reparación" 
				   61 "telecomunicaciones" 
				   62 "programación"
				   69 "contabilidad y serv. legal" 
				   70 "consultoria de negocio" 
				   71 "ingeniería y arquitectura" 
				   72 "investigación y desarrollo científico" 
				   73 "Publicidad e investigación de mercado" 
				   74 "Otros servicios profesionales" ;
#delimit cr
				   
label val	ciiu2d ciiu2d


* generamos variable que distingue entre empresas de servicios y manufactura
* [fuente: ficha técnica de esta encuesta + página de UNSTAT: "https://web.archive.org/web/20100306024742/http://unstats.un.org/unsd/cr/registry/regcst.asp?Cl=27"]
* de 10 a 33 manufactura; de 58 a 63, de 69 a 75 servicios 
gen			sector = .
recode		sector (.=0) if ciiu2d < 61
recode		sector (.=1) if ciiu2d >=61
label def	sector	0 "Manufacturas" 1 "Servicios"
label val	sector sector
label var	sector "Indica si la empresa es de manufacturas o servicios"
order		sector, after(ciiu2d)
tab1		sector // 1463 manuf vs 621 servicios

*revisamos tipos de organización en la muestra
tab1		C2P2_1_10 // ok, 44 personas naturales (considerar p/ depurar)
rename		C2P2_1_10 tipo_org

*revisamos quién fue el que respondió
tab1		C2P2_2_A2 //ok 37 otro tipo de encuestado (considerar p/ depurar)
rename		C2P2_2_A2 encuestado




** Revisamos cap.3 Actividades de innovación
**¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

*revisamos quienes innovaron y quienes no
tabstat		C3P1_1 C3P1_2 C3P1_3 C3P1_4 C3P1_5 C3P1_6 C3P1_7 C3P1_8 C3P1_9 ///
			, c(s) s(n me min med max)
*cambio etiquetado de 1=sí/2=no -a> 1=sí/0=no
label def	dicot 1 "sí" 0 "no"
foreach		x in C3P1_1 C3P1_2 C3P1_3 C3P1_4 C3P1_5 C3P1_6 C3P1_7 C3P1_8 C3P1_9 {
recode		`x' (2=0)
label val	`x' dicot
}
tabstat		C3P1_1 - C3P1_9, c(s) s(n me min med max)
bysort		sector: tabstat		C3P1_1 - C3P1_9, c(s) s(n me min med max) 
bysort		ciiu2d: tabstat		C3P1_1 - C3P1_9, c(s) s(n me min med max)

*vamos a revisar cuantos innovaron
gen			innovo1=. 
label var	innovo1 "innovó en cualquier actividad"
recode		innovo1 (.=0) if C3P1_1==0 & C3P1_2==0 & C3P1_3==0 & C3P1_4==0 & ///
							 C3P1_5==0 & C3P1_6==0 & C3P1_7==0 & C3P1_8==0
recode		innovo1 (.=1) 
label val	innovo1 dicot

gen			innovo2=.
label var	innovo2 "exigente, innovó en algunas actividades"
recode		innovo2 (.=0) if C3P1_1==0 & C3P1_2==0 & C3P1_3==0 & C3P1_4==0 & ///
							 C3P1_5==0 & C3P1_6==0 & C3P1_7==0
recode		innovo2 (.=1)
label val	innovo2 dicot

order		innovo1, after(C3P1_9)
order		innovo2, after(innovo1)

tabstat		innovo1 innovo2, c(s) s(n me min med max)
bysort		sector: tabstat	innovo1 innovo2, c(s) s(n me min med max)

//la mitad de la muestra, irrespectivamente del sector, no innovó

rename		C3P1_1 idint
rename		C3P1_2 idext
rename		C3P1_3 ingdi
rename		C3P1_4 mktng
rename		C3P1_5 propi
rename		C3P1_6 capac
rename		C3P1_7 softw
rename		C3P1_8 capit
*drop variable de innovación sin montos por años
drop		C3P1_9

*revisamos causas para no innovar de la mitad de la muestra
tabstat		C3P2_1 C3P2_2 C3P2_3 C3P2_4 C3P2_5 C3P2_6 C3P2_7 C3P2_8 C3P2_9, ///
			c(s) s(n me min med max)
*mantener vars: más de la mitad de estos dicen que no hubo necesidad de innovar!
bysort		innovo2: tabstat	C3P2_1 C3P2_2 C3P2_3 C3P2_4 C3P2_5 C3P2_6 C3P2_7 C3P2_8 C3P2_9, ///
			c(s) s(n me min med max)
*drop otras razones
drop		C3P2_10 C3P2_10_O


*revisamos montos invertidos por años por categoría de innovación
tabstat		C3P1_1_A_E C3P1_1_B_E C3P1_1_C_E ///
			C3P1_2_A_E C3P1_2_B_E C3P1_2_C_E ///
			C3P1_3_A_E C3P1_3_B_E C3P1_3_C_E ///
			C3P1_4_A_E C3P1_4_B_E C3P1_4_C_E ///
			C3P1_5_A_E C3P1_5_B_E C3P1_5_C_E ///
			C3P1_6_A_E C3P1_6_B_E C3P1_6_C_E ///
			C3P1_7_A_E C3P1_7_B_E C3P1_7_C_E ///
			C3P1_8_A_E C3P1_8_B_E C3P1_8_C_E, c(s) ///
			s(n me min p10 p25 med p75 p90 max skew kurt)
*de acuerdo al diccionario de variables A:2015, B:2016 y C:2017

*>investigación y desarrollo interno
rename		C3P1_1_A_E idint15
rename		C3P1_1_B_E idint16
rename		C3P1_1_C_E idint17
order		idint17, after(idint)
order		idint16, after(idint17)
order		idint15, after(idint16)

*>investigación y desarrollo externa
rename 		C3P1_2_A_E idext15
rename 		C3P1_2_B_E idext16
rename 		C3P1_2_C_E idext17

order		idext17, after(idext)
order		idext16, after(idext17)
order		idext15, after(idext16)

*> ingenieria y diseño
rename 		C3P1_3_A_E ingdi15
rename 		C3P1_3_B_E ingdi16
rename 		C3P1_3_C_E ingdi17

order		ingdi17, after(ingdi)
order		ingdi16, after(ingdi17)
order		ingdi15, after(ingdi16)

*> marketing
rename 		C3P1_4_A_E mktng15
rename 		C3P1_4_B_E mktng16
rename 		C3P1_4_C_E mktng17

order		mktng17, after(mktng)
order		mktng16, after(mktng17)
order		mktng15, after(mktng16)

*> propiedad intelectual
rename 		C3P1_5_A_E propi15
rename 		C3P1_5_B_E propi16
rename 		C3P1_5_C_E propi17

order		propi17, after(propi)
order		propi16, after(propi17)
order		propi15, after(propi16)

*> capacitaciones
rename 		C3P1_6_A_E capac15
rename 		C3P1_6_B_E capac16
rename 		C3P1_6_C_E capac17

order		capac17, after(capac)
order		capac16, after(capac17)
order		capac15, after(capac16)

*>software
rename 		C3P1_7_A_E softw15
rename 		C3P1_7_B_E softw16
rename 		C3P1_7_C_E softw17

order		softw17, after(softw)
order		softw16, after(softw17)
order		softw15, after(softw16)

*capital
rename		C3P1_8_A_E capit15
rename		C3P1_8_B_E capit16
rename		C3P1_8_C_E capit17

order		capit17, after(capit)
order		capit16, after(capit17)
order		capit15, after(capit16)


*revisamos motivos para innovar
drop		C3P3_11 C3P3_11_O //drop otros
*cambiamos etiquetado de razones para innovar 1:sí/2:no -a> 1:sí/0:no
tabstat		C3P3_1 C3P3_2 C3P3_3 C3P3_4 C3P3_5 C3P3_6 C3P3_7 C3P3_8 ///
			C3P3_9 C3P3_10 , c(s) s(n me min med max)
foreach		x in C3P3_1 C3P3_2 C3P3_3 C3P3_4 C3P3_5 C3P3_6 C3P3_7 C3P3_8 C3P3_9 C3P3_10 {
recode		`x' (2=0)
label val	`x' dicot
}
tabstat		C3P3_1 C3P3_2 C3P3_3 C3P3_4 C3P3_5 C3P3_6 C3P3_7 C3P3_8 ///
			C3P3_9 C3P3_10 , c(s) s(n me min med max)
//al parecer la extrapolación positiva del objetivo es fuerte

*cambiamos etiquetas por facilidad
foreach 	x in 1 2 3 4 5 6 7 8 9 { 
rename		C3P2_`x' no_`x'
}
foreach		x in 1 2 3 4 5 6 7 8 9 10 {
rename		C3P3_`x' si_`x'
}




***
*** drop caps 4, 5, 6
drop		C4P1_1 - C6P3_5_A
***




** Revisamos cap.7 Resultados de la innovación
**¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

*drop variables irrelevantes por ahora
drop		C7P1_1_Q C7P1_1_D_1 C7P1_1_D_2 C7P1_1_D_3 C7P1_1_D_4 ///
			C7P1_2_Q C7P1_2_D_1 C7P1_2_D_2 C7P1_2_D_3 C7P1_2_D_4 ///
			C7P1_3_Q C7P1_3_D_1 C7P1_3_D_2 C7P1_3_D_3 C7P1_3_D_4 ///
			C7P1_4_Q C7P1_4_D_1 C7P1_4_D_2 C7P1_4_D_3 C7P1_4_D_4 ///
			C7P3_1_Q C7P3_1_D_1 C7P3_1_D_2 C7P3_1_D_3 C7P3_1_D_4 ///
			C7P3_2_Q C7P3_2_D_1 C7P3_2_D_2 C7P3_2_D_3 C7P3_2_D_4 ///
			C7P3_3_Q C7P3_3_D_1 C7P3_3_D_2 C7P3_3_D_3 C7P3_3_D_4 ///
			C7P3_4_Q C7P3_4_D_1 C7P3_4_D_2 C7P3_4_D_3 C7P3_4_D_4 ///
			C7P3_5_Q C7P3_5_D_1 C7P3_5_D_2 C7P3_5_D_3 C7P3_5_D_4 ///
			C7P3_6_Q C7P3_6_D_1 C7P3_6_D_2 C7P3_6_D_3 C7P3_6_D_4 ///
			C7P3_7_Q C7P3_7_D_1 C7P3_7_D_2 C7P3_7_D_3 C7P3_7_D_4 C7P4


****esta sección queda así porque por ahora no es relevante.


***
*** drop caps 8, 9, 10
drop		C8P1_1 - C10PA_4_CO_O
***



** Revisamos cap.11 Información económica básica de la empresa
**¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

*drop variables irrelevantes
drop 		C11P1_1 C11P1_2 C11P2_1 C11P2_2 C11P2_1_1 C11P2_1_1_D C11P2_1_2 ///
			C11P2_1_2_D C11P2_2_1_COD C11P2_2_1 C11P2_2_2_COD C11P2_2_2

*definimos nombre de variables según diccionario C:2015, B:2016, A:2017
*>ventas
rename		C11P3_1_C ventas15 
rename		C11P3_1_B ventas16
rename		C11P3_1_A ventas17
*>exportaciones
rename		C11P3_2_C export15 
rename		C11P3_2_B export16
rename		C11P3_2_A export17
*>inversión
rename		C11P3_3_C capita15 
rename		C11P3_3_B capita16
rename		C11P3_3_A capita17
*sueldos
rename		C11P3_4_C sueldo15 
rename		C11P3_4_B sueldo16
rename		C11P3_4_A sueldo17
*>porcentaje ingresos principal producto
rename		C11P3_5_C produc15 
rename		C11P3_5_B produc16
rename		C11P3_5_A produc17
*>uso capacidad instalada
rename		C11P3_6_C capins15 
rename		C11P3_6_B capins16
rename		C11P3_6_A capins17

tabstat		ventas15 - capins17, c(s) s(n me min p10 p25 p50 p75 p90 max skew)
// empresas sin sueldos, ventas, capital, % ventas de principal produc y capinst
count if	ventas15 ==0	



**comprimimos y guardamos
compress
save		"$b\bbdd2018_limpia.dta", replace

