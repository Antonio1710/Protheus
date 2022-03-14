#INCLUDE "totvs.ch"
#INCLUDE "TOPCONN.CH"
#Include "Colors.ch"

/*/{Protheus.doc} User Function ADGPE086R()
  Relatório de Demanda de Uniformes por departamento/seção.
  @type tkt -  16833
  @author Leonardo P. Monteiro
  @since 03/02/2022
  @history Ticket 16833 - Leonardo P. Monteiro - 03/02/2022 - Desenvolvimento.
  @history Chamado 16833 - Leonardo P. Monteiro - 08/03/2022- Ajustes e adequações nos fontes conforme novas regras propostas e inconsistências encontradas.
/*/

User Function ADGPE086R()
	local cTitulo         	:= "RELATÓRIO DE DEMANDA DE UNIFORMES POR DEPARTAMENTO/SEÇÃO"

	Private oReport
	private cPerg         	:= "ADGPE086R"
	private cConcilDe     	:= ""
	private cConcilAte		:= ""
	private dDataDe       	:= ctod("")
	private dDataAte      	:= ctod("")
	Private cAlias    		:= ""
	Private _nOrdem     	:= 2 //Ordem
	Private lAuto			:= .F.
	Private nLin			:= 0
	
	Private oFont10n 		:= TFont():New("Times New Roman",10,10,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont12n 		:= TFont():New("Times New Roman",12,12,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont14n 		:= TFont():New("Times New Roman",14,14,.T.,.F.,5,.T.,5,.T.,.F.)


	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RELATÓRIO DE DEMANDA DE UNIFORMES POR DEPARTAMENTO/SEÇÃO')
	
	oFont10n:Bold := .f.
	oFont12n:Bold := .f.
	oFont14n:Bold := .f.

	lPerguntas := Pergunte("ADGPE086R")

	if lPerguntas

		cAlias := GetNextAlias()

		oReport := TReport():New(cPerg,cTitulo,{|| Pergunte("ADGPE086R") },{|oReport| PrintReport(oReport) })
		oReport:SetTitle(cTitulo)

		oReport:SetLandScape(.T.)

		//Define as seções do relatório
		ReportDef(oReport)

		//Dialogo do TReport
		oReport:PrintDialog()
	endif
Return

/*/{Protheus.doc} ReportDef
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function ReportDef(oReport)

	oSection1 := TRSection():New(oReport,"Departamentos x Uniformes")
	TRCell():New(oSection1,"ZI5_CODIGO"    			,cAlias,"Cód. Depto" 	,"@!"               	,030,  ,,"LEFT",,"LEFT",,,,,,,) //01
	TRCell():New(oSection1,"ZI5_DESCRI"    			,cAlias,"Departamento" 	,"@!"               	,035,  ,,"LEFT",,"LEFT",,,,,,,) //02
	TRCell():New(oSection1,"ZI6_CODIGO"            	,cAlias,"Cód. Hora"    	,"@!"               	,004,  ,,"CENTER",,"CENTER",,,,,,,) //03
	TRCell():New(oSection1,"ZI6_DESCRI"            	,cAlias,"Horário"    	,"@!"               	,025,  ,,"LEFT",,"LEFT",,,,,,,) //04
	TRCell():New(oSection1,"ZHH_CODIGO"            	,cAlias,"Cód. Unif"    	,"@!"               	,004,  ,,"CENTER",,"CENTER",,,,,,,) //03
	TRCell():New(oSection1,"ZHH_DESCRI"            	,cAlias,"Uniformes"    	,"@!"               	,025,  ,,"LEFT",,"LEFT",,,,,,,) //04
	TRCell():New(oSection1,"ZHI_UM"   	            ,cAlias,"Tamanho"      	,"@!"               	,008,  ,,"CENTER",,"CENTER",,,,,,,) //05
	TRCell():New(oSection1,"ZI5_QTDUNF"            	,cAlias,"Qtd. Dia"    	,"@E 99,999,999"       	,008,  ,,"RIGHT",,"RIGHT",,,,,,,) //06
	TRCell():New(oSection1,"QTD_FUNC"  	            ,cAlias,"Qtd. Func."   	,"@E 99,999,999"        ,010,  ,,"RIGHT",,"RIGHT",,,,,,,) //07
	TRCell():New(oSection1,"QTD_TOTAL" 	    		,cAlias,"QTD Total"   	,"@E 99,999,999" 		,015,  ,,"RIGHT",,"RIGHT",,,,,,,) //08
	
	if MV_PAR09 == 2
		oSection2 := TRSection():New(oReport,"Colaboradores")
		TRCell():New(oSection2,"ZI1_MAT"   	            ,cAlias,"Matrícula"    	,"@!"               	,010,  ,,"CENTER",,"CENTER",,,,,,,) //01
		TRCell():New(oSection2,"ZI1_NOME"   	        ,cAlias,"Nome"        	,"@!"               	,150,  ,,"LEFT",,"LEFT",,,,,,,) //02
	ENDIF

	oBreak1 := TRBreak():New(oSection1,{|| },"Total Geral",.F.)
	
	TRFunction():New(oSection1:Cell("ZI5_QTDUNF"),/*cId*/,"SUM",oBreak1,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("QTD_FUNC")  ,/*cId*/,"SUM",oBreak1,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("QTD_TOTAL") ,/*cId*/,"SUM",oBreak1,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

Return

/*/{Protheus.doc} PrintReport
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function PrintReport(oReport)
	local oSection1 := NIL
	local oSection2 := NIL

	oSection1 := oReport:Section(1)
	
	IF mv_par09 == 2
		oSection2 := oReport:Section(2)
	ENDIF

	cQuery := getDadosRel()

	TcQuery cQuery ALIAS "QREL" NEW

	Count To nRegs
	
	QREL->(Dbgotop())

	oReport:SetMeter(nRegs)
	oSection1:Init()

	while QREL->(!EOF())

		oReport:IncMeter()
		//  SELECT ZI5.ZI5_CODIGO, ZI5.ZI5_DESCRI, ZHH.ZHH_CODIGO, ZHH.ZHH_DESCRI, ZHH.ZHH_TIPO, ZHI.ZHI_CODIGO, ZHI.ZHI_ORDEM, ZHI.ZHI_UM, ZI5.ZI5_QTDUNF, FUNC.QTD_FUNC, (ZI5.ZI5_QTDUNF*FUNC.QTD_FUNC) QTD_TOTAL


		oSection1:Cell("ZI5_CODIGO"   	):SetValue(QREL->ZI5_CODIGO) // 01
		oSection1:Cell("ZI5_DESCRI"   	):SetValue(QREL->ZI5_DESCRI) // 02
		oSection1:Cell("ZHH_CODIGO" 	):SetValue(QREL->ZHH_CODIGO) // 03
		oSection1:Cell("ZHH_DESCRI" 	):SetValue(QREL->ZHH_DESCRI) // 04
		oSection1:Cell("ZI6_CODIGO" 	):SetValue(QREL->ZI6_CODIGO) // 05
		oSection1:Cell("ZI6_DESCRI" 	):SetValue(QREL->ZI6_DESCRI) // 06
		oSection1:Cell("ZHI_UM"     	):SetValue(QREL->ZHI_UM)	 // 07
		oSection1:Cell("ZI5_QTDUNF"    	):SetValue(QREL->ZI5_QTDUNF) // 08
		oSection1:Cell("QTD_FUNC"   	):SetValue(QREL->QTD_FUNC)	 // 09
		oSection1:Cell("QTD_TOTAL" 		):SetValue(QREL->QTD_TOTAL)  // 10
			
		oSection1:PrintLine()
		
		if MV_PAR09 == 2
			cQuery := getDadosDet(QREL->ZI5_CODIGO, QREL->ZHH_CODIGO, QREL->ZHH_TIPO, QREL->ZI6_CODIGO, QREL->ZHI_UM)

			TcQuery cQuery ALIAS "QDET" NEW

			if QDET->(!Eof())
				
				oSection2:Init()

				while QDET->(!eof())
					oSection2:Cell("ZI1_MAT"   	):SetValue(QDET->ZI1_MAT) 	// 01
					oSection2:Cell("ZI1_NOME"  	):SetValue(QDET->ZI1_NOME) 	// 02

					oSection2:Printline()
					QDET->(Dbskip())
				ENDDO

				QDET->(DBCLOSEAREA())

				oSection2:Finish()

			endif

		endif

		oReport:IncMeter()

		QREL->(Dbskip())	
	enddo

	oSection1:Finish()

	QREL->(DBCLOSEAREA())
Return

Static Function getDadosDet(cDepto, cUnifCod, cUnifTipo, cCodHor, cUM)
	local cQuery  	:= ""
	local CEOL		:= Chr(13)+chr(10)

	cQuery := " SELECT ZI1.ZI1_MAT, ZI1.ZI1_NOME  "+CEOL
	cQuery += " FROM  "+ retsqlname("ZI1") +" ZI1 "
	cQuery += "		INNER JOIN "+ retsqlname("ZI5") +" ZI5 ON ZI1.D_E_L_E_T_='' AND ZI5.D_E_L_E_T_='' AND ZI1.ZI1_SECAO=ZI5.ZI5_CODIGO "
	cQuery += "		INNER JOIN "+ retsqlname("ZHK") +" ZHK ON ZI5.D_E_L_E_T_='' AND ZHK.D_E_L_E_T_='' AND ZI5.ZI5_FILIAL=ZHK.ZHK_FILIAL AND ZI5.ZI5_CODIGO=ZHK.ZHK_CODZI5 "+CEOL
	cQuery += " 	INNER JOIN "+ retsqlname("ZHH") +" ZHH ON ZHH.D_E_L_E_T_='' AND ZHK.ZHK_FILIAL=ZHH.ZHH_FILIAL AND ZHK.ZHK_CODZHH=ZHH.ZHH_CODIGO "+CEOL
	cQuery += " WHERE ZI5.D_E_L_E_T_='' "+CEOL
	cQuery += " 	AND ZI1.ZI1_SECAO  = '"+ alltrim(cDepto) +"' "+CEOL
	cQuery += " 	AND ZI1.ZI1_CODHOR  = '"+ alltrim(cCodHor) +"' "+CEOL
	cQuery += " 	AND ZHH.ZHH_CODIGO = '"+ ALLTRIM(cUnifCod) +"' "+CEOL
	

	IF cUnifTipo == "01"
		cQuery += " AND ZI1.ZI1_TCAMPA ='"+ Alltrim(cUM) +"' "
	ElseIF cUnifTipo == "02"
		cQuery += " AND ZI1.ZI1_TBLUTE ='"+ Alltrim(cUM) +"' "
	ElseIF cUnifTipo == "03"
		cQuery += " AND ZI1.ZI1_TCALPA ='"+ Alltrim(cUM) +"' "
	ElseIF cUnifTipo == "04"
		cQuery += " AND ZI1.ZI1_TCALTE ='"+ Alltrim(cUM) +"' "
	ElseIF cUnifTipo == "05"
		cQuery += " AND ZI1.ZI1_TCALCA ='"+ Alltrim(cUM) +"' "
	ElseIF cUnifTipo == "06"
		cQuery += " AND ZI1.ZI1_TMEIAS ='"+ Alltrim(cUM) +"' "
	ENDIF

return cQuery


/*/{Protheus.doc} queryRel
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function getDadosRel()
	local cQuery  	:= ""
	local CEOL		:= Chr(13)+chr(10)

	cQuery := " SELECT * "+CEOL
	cQuery += " FROM ( "+CEOL
	cQuery += " SELECT ZI5.ZI5_CODIGO, ZI5.ZI5_DESCRI, ZHH.ZHH_CODIGO, ZHH.ZHH_DESCRI, ZHH.ZHH_TIPO, ZHI.ZHI_CODIGO, ZHI.ZHI_ORDEM,  "+CEOL
	cQuery += " 		FUNC.ZI6_CODIGO, FUNC.ZI6_DESCRI,  "+CEOL
	cQuery += " 		ZHI.ZHI_UM, ZI5.ZI5_QTDUNF, FUNC.QTD_FUNC, (ZI5.ZI5_QTDUNF*FUNC.QTD_FUNC) QTD_TOTAL "+CEOL
	cQuery += " FROM  "+ retsqlname("ZI5") +" ZI5 INNER JOIN "+ retsqlname("ZHK") +" ZHK ON ZI5.D_E_L_E_T_='' AND ZHK.D_E_L_E_T_='' AND ZI5.ZI5_FILIAL=ZHK.ZHK_FILIAL AND ZI5.ZI5_CODIGO=ZHK.ZHK_CODZI5 "+CEOL
	cQuery += " 	INNER JOIN "+ retsqlname("ZHH") +" ZHH ON ZHH.D_E_L_E_T_='' AND ZHK.ZHK_FILIAL=ZHH.ZHH_FILIAL AND ZHK.ZHK_CODZHH=ZHH.ZHH_CODIGO "+CEOL
	cQuery += " 	INNER JOIN "+ retsqlname("ZHI") +" ZHI ON ZHI.D_E_L_E_T_='' AND ZHI.ZHI_FILIAL=ZHH.ZHH_FILIAL AND ZHH.ZHH_CODIGO=ZHI.ZHI_CODIGO "+CEOL
	cQuery += " 	INNER JOIN (SELECT ZI1.ZI1_FILIAL, ZI1.ZI1_SECAO, ZI6.ZI6_CODIGO, ZI6.ZI6_DESCRI, ZHJ.ZHJ_TIPO, ZHJ.ZHJ_UM, COUNT(*) QTD_FUNC "+CEOL
	cQuery += " 				FROM "+ retsqlname("ZI1") +" ZI1 INNER JOIN "+ retsqlname("ZI6") +" ZI6 ON ZI1.D_E_L_E_T_='' AND ZI6.D_E_L_E_T_='' AND ZI1.ZI1_CODHOR=ZI6.ZI6_CODIGO "+CEOL
	cQuery += "													 INNER JOIN "+ retsqlname("ZHJ") +" ZHJ ON ZI1.D_E_L_E_T_='' AND ZHJ.D_E_L_E_T_='' AND  "+CEOL
	cQuery += " 								(ZHJ.ZHJ_TIPO='01' AND ZI1.ZI1_TCAMPA=ZHJ.ZHJ_UM "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='02' AND ZI1.ZI1_TBLUTE=ZHJ.ZHJ_UM "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='03' AND ZI1.ZI1_TCALPA=ZHJ.ZHJ_UM "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='04' AND ZI1.ZI1_TCALTE=ZHJ.ZHJ_UM "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='05' AND ZI1.ZI1_TCALCA=ZHJ.ZHJ_UM "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='06' AND ZI1.ZI1_TMEIAS=ZHJ.ZHJ_UM) "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='07' AND ZI1.ZI1_TJALEC=ZHJ.ZHJ_UM) "+CEOL
	cQuery += " 				WHERE ZI1.D_E_L_E_T_='' AND ZI1.ZI1_DEMISS ='' "+CEOL
	cQuery += " 						AND ZI1.ZI1_CODHOR BETWEEN '"+ ALLTRIM(MV_PAR03) +"' AND '"+ ALLTRIM(MV_PAR04) +"' "+CEOL
	cQuery += " 				GROUP BY ZI1.ZI1_FILIAL, ZI1.ZI1_SECAO, ZI6.ZI6_CODIGO, ZI6.ZI6_DESCRI, ZHJ.ZHJ_TIPO, ZHJ.ZHJ_UM) FUNC "+CEOL
	cQuery += " 			ON FUNC.ZI1_SECAO=ZI5.ZI5_CODIGO AND FUNC.ZHJ_TIPO=ZHH.ZHH_TIPO AND FUNC.ZHJ_UM=ZHI.ZHI_UM "+CEOL
	cQuery += " WHERE ZI5.D_E_L_E_T_='' "+CEOL
	cQuery += " 	AND ZI5.ZI5_CODIGO BETWEEN '"+ ALLTRIM(MV_PAR01) +"' AND '"+ ALLTRIM(MV_PAR02) +"' "+CEOL
	cQuery += " 	AND ZHH.ZHH_CODIGO BETWEEN '"+ ALLTRIM(MV_PAR05) +"' AND '"+ ALLTRIM(MV_PAR06) +"' "+CEOL
	cQuery += " 	AND ZHI.ZHI_UM 	   BETWEEN '"+ ALLTRIM(MV_PAR07) +"' AND '"+ ALLTRIM(MV_PAR08) +"' "+CEOL
	cQuery += " UNION ALL "+CEOL
	cQuery += " SELECT ZI5.ZI5_CODIGO, ZI5.ZI5_DESCRI, ZHH.ZHH_CODIGO, ZHH.ZHH_DESCRI, ZHH.ZHH_TIPO, 'ZZ' ZHI_CODIGO, 'ZZ' ZHI_ORDEM, "+CEOL
	cQuery += " 		FUNC.ZI6_CODIGO, FUNC.ZI6_DESCRI,  "+CEOL
	cQuery += " 	' ' ZHI_UM, ZI5.ZI5_QTDUNF, FUNC.QTD_FUNC, (ZI5.ZI5_QTDUNF*FUNC.QTD_FUNC) QTD_TOTAL "+CEOL
	cQuery += " FROM  "+ retsqlname("ZI5") +" ZI5 INNER JOIN "+ retsqlname("ZHK") +" ZHK ON ZI5.D_E_L_E_T_='' AND ZHK.D_E_L_E_T_='' AND ZI5.ZI5_FILIAL=ZHK.ZHK_FILIAL AND ZI5.ZI5_CODIGO=ZHK.ZHK_CODZI5 "+CEOL
	cQuery += " 	INNER JOIN "+ retsqlname("ZHH") +" ZHH ON ZHH.D_E_L_E_T_='' AND ZHK.ZHK_FILIAL=ZHH.ZHH_FILIAL AND ZHK.ZHK_CODZHH=ZHH.ZHH_CODIGO "+CEOL
	cQuery += " 	INNER JOIN (SELECT ZI1.ZI1_FILIAL, ZI1.ZI1_SECAO, ZI6.ZI6_CODIGO, ZI6.ZI6_DESCRI, ZHJ.ZHJ_TIPO, '' ZHJ_UM, COUNT(*) QTD_FUNC "+CEOL
	cQuery += " 				FROM "+ retsqlname("ZI1") +" ZI1 INNER JOIN "+ retsqlname("ZI6") +" ZI6 ON ZI1.D_E_L_E_T_='' AND ZI6.D_E_L_E_T_='' AND ZI1.ZI1_CODHOR=ZI6.ZI6_CODIGO "+CEOL
	cQuery += " 												 INNER JOIN (SELECT '01' ZHJ_TIPO UNION ALL "+CEOL
	cQuery += " 											SELECT '02' ZHJ_TIPO UNION ALL "+CEOL
	cQuery += " 											SELECT '03' ZHJ_TIPO UNION ALL "+CEOL
	cQuery += " 											SELECT '04' ZHJ_TIPO UNION ALL "+CEOL
	cQuery += " 											SELECT '05' ZHJ_TIPO UNION ALL "+CEOL
	cQuery += " 											SELECT '06' ZHJ_TIPO UNION ALL "+CEOL
	cQuery += " 											SELECT '07' ZHJ_TIPO) ZHJ ON ZI1.D_E_L_E_T_='' AND  "+CEOL
	cQuery += " 								(ZHJ.ZHJ_TIPO='01' AND ZI1.ZI1_TCAMPA='' "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='02' AND ZI1.ZI1_TBLUTE='' "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='03' AND ZI1.ZI1_TCALPA='' "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='04' AND ZI1.ZI1_TCALTE='' "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='05' AND ZI1.ZI1_TCALCA='' "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='06' AND ZI1.ZI1_TMEIAS='' "+CEOL
	cQuery += " 								OR ZHJ.ZHJ_TIPO='07' AND ZI1.ZI1_TJALEC='') "+CEOL
	cQuery += " 				WHERE ZI1.D_E_L_E_T_='' AND ZI1.ZI1_DEMISS ='' "+CEOL
	cQuery += " 						AND ZI1.ZI1_CODHOR BETWEEN '"+ ALLTRIM(MV_PAR03) +"' AND '"+ ALLTRIM(MV_PAR04) +"' "+CEOL
	cQuery += " 				GROUP BY ZI1.ZI1_FILIAL, ZI1.ZI1_SECAO, ZI6.ZI6_CODIGO, ZI6.ZI6_DESCRI, ZHJ.ZHJ_TIPO) FUNC "+CEOL
	cQuery += " 			ON FUNC.ZI1_SECAO=ZI5.ZI5_CODIGO AND FUNC.ZHJ_TIPO=ZHH.ZHH_TIPO "+CEOL
	cQuery += " WHERE ZI5.D_E_L_E_T_='' "+CEOL
	cQuery += " 	AND ZI5.ZI5_CODIGO BETWEEN '"+ ALLTRIM(MV_PAR01) +"' AND '"+ ALLTRIM(MV_PAR02) +"' "+CEOL
	cQuery += " 	AND ZHH.ZHH_CODIGO BETWEEN '"+ ALLTRIM(MV_PAR05) +"' AND '"+ ALLTRIM(MV_PAR06) +"' "+CEOL
	cQuery += " 	AND '' 	   		   BETWEEN '"+ ALLTRIM(MV_PAR07) +"' AND '"+ ALLTRIM(MV_PAR08) +"' "+CEOL
	cQuery += "  ) UNI "+CEOL
	cQuery += " ORDER BY UNI.ZI5_CODIGO, UNI.ZHH_CODIGO, UNI.ZHI_ORDEM "

Return cQuery


