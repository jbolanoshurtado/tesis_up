****************************************************************
* 1ro (de 4) do-file: revisión bbdd (INEI: ENIIMESIC - 2018)   *
****************************************************************

/*
Autor: 		Jean Pierre Bolaños, Universidad del Pacífico (Lima)
Parte de: 	Tesis de Licenciatura para optar por el título profesional 
			 en Negocios Internacionales
Año: 		2021
*/

clear 			all
set more		off

*Dirección de carpetas de trabajo para 
* 1) base de datos original del INEI
gl				a "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\0-bbdd iniciales"
* 2) trabajo sobre la base de datos
gl				b "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\1-bbdd intermedias"
* 3) base de datos final para estimar el modelo
gl				c "C:\Users\Jean Pierre\Documents\0-Local Workstation\12-tesis\0-BBDD_secundarias\INEI2018\2-bbdd finales"

*Abrimos BBDD convertida sin modificaciones del formato original .sav (SPSS) 
* a .dta (STATA)
u				"$b\INNOVACION_2018_I.dta", clear
count			// n=2084 empresas

*eliminamos variables sin información
drop			CCDD NOMBREPP CCPP NOMBREDI CCDI LATITUD LONGITUD SECTOR 	///
				AREA ZONA MZA FRENTE TIPVIA NOMVIA PTANUM BLOCK INT PISO MZ ///
				LOTE KM REFERENC
			
*destring nombre de departamentos
encode			NOMBREDD, generate(departamento)
order			departamento, after(NOMBREDD)
drop			NOMBREDD
rename			ID id
rename			NCUEST ncuest

*mantenemos info relevante (año inicio, CIIU, tipo org, cargo del encuestad)
drop			C2P2_1_1 C2P2_1_2 C2P2_1_3 C2P2_1_5 C2P2_1_5_1 C2P2_1_6 	///
				C2P2_1_6_1 C2P2_1_7 C2P2_1_7_1 C2P2_1_8 C2P2_1_8_1 			///
				C2P2_1_9_D C2P2_1_10_7_O C2P2_2_A1 C2P2_2_A2_O C2P2_2_A3 	///
				C2P2_2_A3_1 C2P2_2_A4 C2P2_2_A4_1 C2P2_2_A5 C2P2_2_A5_1 	///
				C2P2_2_B1 C2P2_2_B2 C2P2_2_B2_O C2P2_2_B3 C2P2_2_B3_1 		///
				C2P2_2_B4 C2P2_2_B4_1 C2P2_2_B5 C2P2_2_B5_1 RESFIN

*creamos variable de años de operación
gen				y_oper = 2018 - C2P2_1_4 +1 // encuesta tomada en 2018 
order			y_oper, after(C2P2_1_4)
label var		y_oper "años de operación hasta 2018"
rename			C2P2_1_4 y_inic

*creamos variable de código CIIU (a 4 y 2 dígitos)
destring		C2P2_1_9_COD, generate(ciiu4d)
order			ciiu4d, after(C2P2_1_9_COD)
gen				ciiu2d = floor(ciiu4d / 100)
order			ciiu2d, after(ciiu4d)
drop			C2P2_1_9_COD
label var		ciiu2d "CIIU dos dígitos"

*creamos etiquetas para cada industria en CIIU a 2 dígitos
*(Fuente de las etiquetas: Ficha técnica INEI, Guía CIIU UNSTAT)
#delimit ;
label def		ciiu2d 
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
label val		ciiu2d ciiu2d

*creamos variable que distingue entre empresas de servicios y manufactura
*(Fuente: Ficha técnica INEI, Guía CIIU UNSTAT)
gen				sector = .
recode			sector (.=0) if ciiu2d < 61
recode			sector (.=1) if ciiu2d >=61
label def		sector	0 "Manufacturas" 1 "Servicios"
label val		sector sector
label var		sector "Indica si la empresa es de manufacturas o servicios"
order			sector, after(ciiu2d)

*renombramos variable que indica tipos de organización
rename			C2P2_1_10 tipo_org

*renombramos variable que indica el cargo del encuestado
rename			C2P2_2_A2 encuestado

*cambiamos etiquetado de actividades de innovación de (1=sí,2=no) a (1=sí,0=no)
*(Fuente: diccionario de variables de la encuesta, INEI)
label def		dicot 1 "sí" 0 "no"
foreach			x in C3P1_1 C3P1_2 C3P1_3 C3P1_4 C3P1_5 C3P1_6 C3P1_7 C3P1_8 C3P1_9 {
recode			`x' (2=0)
label val		`x' dicot
}

*Creamos variables que indican, de forma general, si la empresa innovó
gen				innovo1=. 
label var		innovo1 "innovó en cualquier actividad"
recode			innovo1 (.=0) if 	C3P1_1==0 & C3P1_2==0 & C3P1_3==0 & ///
									C3P1_4==0 & C3P1_5==0 & C3P1_6==0 & ///
									C3P1_7==0 & C3P1_8==0
recode			innovo1 (.=1) 
label val		innovo1 dicot
gen				innovo2=.
label var		innovo2 "exigente, innovó en algunas actividades"
recode			innovo2 (.=0) if 	C3P1_1==0 & C3P1_2==0 & C3P1_3==0 & ///
									C3P1_4==0 & C3P1_5==0 & C3P1_6==0 & ///
									C3P1_7==0
recode			innovo2 (.=1)
label val		innovo2 dicot
order			innovo1, after(C3P1_9)
order			innovo2, after(innovo1)

*renombramos variables de actividades de innovación
rename			C3P1_1 idint
rename			C3P1_2 idext
rename			C3P1_3 ingdi
rename			C3P1_4 mktng
rename			C3P1_5 propi
rename			C3P1_6 capac
rename			C3P1_7 softw
rename			C3P1_8 capit

*eliminamos variable no anual de actividades de innovación
drop			C3P1_9

*drop otras razones para no innovar (respuesta abierta=string)
drop			C3P2_10 C3P2_10_O

*renombramos variables de montos anuales de gasto en innovación
*(A:2015, B:2016 y C:2017)
*	>investigación y desarrollo interno
rename			C3P1_1_A_E idint15
rename			C3P1_1_B_E idint16
rename			C3P1_1_C_E idint17
order			idint17, after(idint)
order			idint16, after(idint17)
order			idint15, after(idint16)
*	>investigación y desarrollo externa
rename 			C3P1_2_A_E idext15
rename 			C3P1_2_B_E idext16
rename 			C3P1_2_C_E idext17
order			idext17, after(idext)
order			idext16, after(idext17)
order			idext15, after(idext16)
*	>ingenieria y diseño
rename 			C3P1_3_A_E ingdi15
rename 			C3P1_3_B_E ingdi16
rename 			C3P1_3_C_E ingdi17
order			ingdi17, after(ingdi)
order			ingdi16, after(ingdi17)
order			ingdi15, after(ingdi16)
*	>marketing
rename 			C3P1_4_A_E mktng15
rename 			C3P1_4_B_E mktng16
rename 			C3P1_4_C_E mktng17
order			mktng17, after(mktng)
order			mktng16, after(mktng17)
order			mktng15, after(mktng16)
*	>propiedad intelectual
rename 			C3P1_5_A_E propi15
rename 			C3P1_5_B_E propi16
rename 			C3P1_5_C_E propi17
order			propi17, after(propi)
order			propi16, after(propi17)
order			propi15, after(propi16)
*	>capacitaciones
rename 			C3P1_6_A_E capac15
rename 			C3P1_6_B_E capac16
rename 			C3P1_6_C_E capac17
order			capac17, after(capac)
order			capac16, after(capac17)
order			capac15, after(capac16)
*	>software
rename 			C3P1_7_A_E softw15
rename 			C3P1_7_B_E softw16
rename 			C3P1_7_C_E softw17
order			softw17, after(softw)
order			softw16, after(softw17)
order			softw15, after(softw16)
*	>capital
rename			C3P1_8_A_E capit15
rename			C3P1_8_B_E capit16
rename			C3P1_8_C_E capit17
order			capit17, after(capit)
order			capit16, after(capit17)
order			capit15, after(capit16)

*eliminamos otros motivos para innovar (respuesta abierta=string)
drop			C3P3_11 C3P3_11_O

*cambiamos etiquetado de razones para innovar de (1=sí,2=no) a (1=sí,0=no)
foreach			x in C3P3_1 C3P3_2 C3P3_3 C3P3_4 C3P3_5 C3P3_6 C3P3_7 C3P3_8 C3P3_9 C3P3_10 {
recode			`x' (2=0)
label val		`x' dicot
}

*cambiamos nombre de los items de razones para NO y SÍ innovar por facilidad
foreach 		x in 1 2 3 4 5 6 7 8 9 { 
rename			C3P2_`x' no_`x'
}
foreach			x in 1 2 3 4 5 6 7 8 9 10 {
rename			C3P3_`x' si_`x'
}

*eliminamos variables de los capítulos 4, 5 y 6 (no relacinadas con el objetivo)
drop			C4P1_1 - C6P3_5_A

*eliminamos variables del cap. 7 no relacinadas con el objetivo de la tesis
drop			C7P1_1_Q C7P1_1_D_1 C7P1_1_D_2 C7P1_1_D_3 C7P1_1_D_4 ///
				C7P1_2_Q C7P1_2_D_1 C7P1_2_D_2 C7P1_2_D_3 C7P1_2_D_4 ///
				C7P1_3_Q C7P1_3_D_1 C7P1_3_D_2 C7P1_3_D_3 C7P1_3_D_4 ///
				C7P1_4_Q C7P1_4_D_1 C7P1_4_D_2 C7P1_4_D_3 C7P1_4_D_4 ///
				C7P3_1_Q C7P3_1_D_1 C7P3_1_D_2 C7P3_1_D_3 C7P3_1_D_4 ///
				C7P3_2_Q C7P3_2_D_1 C7P3_2_D_2 C7P3_2_D_3 C7P3_2_D_4 ///
				C7P3_3_Q C7P3_3_D_1 C7P3_3_D_2 C7P3_3_D_3 C7P3_3_D_4 ///
				C7P3_4_Q C7P3_4_D_1 C7P3_4_D_2 C7P3_4_D_3 C7P3_4_D_4 ///
				C7P3_5_Q C7P3_5_D_1 C7P3_5_D_2 C7P3_5_D_3 C7P3_5_D_4 ///
				C7P3_6_Q C7P3_6_D_1 C7P3_6_D_2 C7P3_6_D_3 C7P3_6_D_4 ///
				C7P3_7_Q C7P3_7_D_1 C7P3_7_D_2 C7P3_7_D_3 C7P3_7_D_4 ///
				C7P4

*eliminamos variables de los capítulos 8, 9 y 10 (no relacionadas c/ objetivo)
drop			C8P1_1 - C10PA_4_CO_O

*eliminamos algunas variables no relevantes del cap. de info básica empresa
drop 			C11P1_1 C11P1_2 C11P2_1 C11P2_2 C11P2_1_1 C11P2_1_1_D 	///
				C11P2_1_2 C11P2_1_2_D C11P2_2_1_COD C11P2_2_1 			///
				C11P2_2_2_COD C11P2_2_2

*renombramos variables relevantes según diccionario 
*(C:2015, B:2016, A:2017)
*	>ventas
rename			C11P3_1_C ventas15 
rename			C11P3_1_B ventas16
rename			C11P3_1_A ventas17
*	>exportaciones
rename			C11P3_2_C export15 
rename			C11P3_2_B export16
rename			C11P3_2_A export17
*	>capital
rename			C11P3_3_C capita15 
rename			C11P3_3_B capita16
rename			C11P3_3_A capita17
*	>sueldos
rename			C11P3_4_C sueldo15 
rename			C11P3_4_B sueldo16
rename			C11P3_4_A sueldo17
*	>porcentaje ingresos principal producto
rename			C11P3_5_C produc15 
rename			C11P3_5_B produc16
rename			C11P3_5_A produc17
*	>uso capacidad instalada
rename			C11P3_6_C capins15 
rename			C11P3_6_B capins16
rename			C11P3_6_A capins17

*Guardamos bbdd con variables relevantes renombradas y etiquetadas
compress
save		"$b\bbdd2018_limpia.dta", replace
