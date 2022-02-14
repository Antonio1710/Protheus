#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADFIS031R บ Autor ณ Abel Babini Filho  บ Data ณ27/05/2019   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGera relat๓rio dos fretes com erro de classificacao fiscal  บฑฑ
ฑฑบ          ณcomparando UF de origem com UF de destino e o CFOP          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 049314                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็ใo ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADFIS031R()
	Local aArea		:= GetArea()
	Local cDir		:= cGetFile("Arquivo xml.", "Selecione o diret๓rio para salvar o XML",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	Local cArq		:= cDir+"RelUFFrete"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".XML"
	Local oExcel     := FWMSEXCELEX():New()
	Local aPergs	:= {}
	Local aRet		:= {}
	Local _lPerg	:= .F.
	Local _lDir		:= .F.
	Local _cAlias	:= ""
	Local oMsExcel	:= NIL
	Local cWksTit	:= 'Rel_UFFrete'
	Local cTblNm	:= 'Relat๓rio Frete com erro de Lan็amento'
	Local aFilSlCP := {}
	Local cFilSel	:= ""
	Local cFilIn	:= ""

	aAdd( aPergs ,{1,"Data Digita็ใo De "     ,Ctod("01/"+Substr(dtos(dDatabase),5,2)+"/"+Substr(dtos(dDatabase),1,4)),"" ,'.T.',,'.T.',40,.T.})
    aAdd( aPergs ,{1,"Data Digita็ใo At้"     ,Ctod(space(8)),"" ,'.T.',,'.T.',40,.T.})

    //Executa as perguntas ao usuแrio e s๓ executa o relat๓rio caso o usuแrio confirme a tela de parโmetros;
    If ParamBox(aPergs ,"Parametros ",aRet,,,,,,,,.T.,.T.) //Abel Babini-25/02/19-CH:045978
    	_lPerg	:= .T.
    Else
    	Alert('Parโmetros nใo informados. Relat๓rio nใo serแ gerado!')
    Endif
    If !Empty(Alltrim(cValToChar(cDir)))
    	_lDir	:= .T.
    Else
    	Alert('ษ necessแrio selecionar o caminho para salvar o arquivo do relat๓rio (.csv)!')
    	cDir	:= cGetFile("Arquivo xml.", "Selecione o diret๓rio para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
    	If !Empty(Alltrim(cValToChar(cDir)))
    		_lDir	:= .T.
    	Endif
	EndIf
	If _lPerg .And. _lDir
		
	    aFilSlCP	:= AdmGetFil()
	    IF Len(aFilSlCP)==0
	    	AADD(aFilSlCP,cFilAnt)
	    Endif

	    For i:= 1 to Len(aFilSlCP)
	    	If i=1
	    		cFilSel := aFilSlCP[i]
	    	Else
	    		cFilSel += ','+ aFilSlCP[i]
	    	Endif
	    Next i
	    
	    cFilIn	:= '%'+FormatIn(cFilSel,',')+'%'
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Nao Existe Excel Instalado")
            Return Nil
        EndIF
        
		_cAlias	:= GetNextAlias()
		BeginSQL  Alias _cAlias
			column D1_EMISSAO as Date
			column D1_DTDIGIT as Date
			SELECT DISTINCT 
				SD1.D1_FILIAL, 
				SD1.D1_EMISSAO, 
				SD1.D1_DTDIGIT, 
				SF1.F1_DOC, 
				SF1.F1_SERIE, 
				SF1.F1_FORNECE, 
				SF1.F1_LOJA, 
				SA2.A2_NOME, 
				SD1.D1_CF, 
				SF1.F1_UFORITR, 
				SF1.F1_UFDESTR
			FROM %TABLE:SD1% SD1
			LEFT JOIN %TABLE:SF1% SF1 ON
				SF1.%notDel%
			AND SF1.F1_FILIAL = SD1.D1_FILIAL
			AND SF1.F1_FORNECE = SD1.D1_FORNECE
			AND SF1.F1_LOJA = SD1.D1_LOJA
			AND SF1.F1_DOC = SD1.D1_DOC
			AND SF1.F1_SERIE = SD1.D1_SERIE
			LEFT JOIN %TABLE:SA2% SA2 ON
				SA2.%notDel%
			AND SA2.A2_COD = SD1.D1_FORNECE
			AND SA2.A2_LOJA = SD1.D1_LOJA
			WHERE SD1.%notDel%
			AND SD1.D1_FILIAL IN %Exp:cFilIn%
			AND SD1.D1_DTDIGIT BETWEEN %Exp:DtoS(aRet[1])% AND %Exp:DtoS(aRet[2])%
			AND SF1.F1_ESPECIE IN ('CTE','CTEOS')
			AND ((SF1.F1_UFORITR=SF1.F1_UFDESTR AND SUBSTRING(SD1.D1_CF,1,1)<>'1') OR (SF1.F1_UFORITR<>SF1.F1_UFDESTR AND SUBSTRING(SD1.D1_CF,1,1)='1')  OR SF1.F1_UFDESTR = '' OR SF1.F1_UFORITR = '' )
			ORDER BY 
			SD1.D1_FILIAL, SD1.D1_DTDIGIT, SF1.F1_SERIE, SF1.F1_DOC, SF1.F1_FORNECE, SF1.F1_LOJA, SA2.A2_NOME, SD1.D1_EMISSAO, SD1.D1_CF, SF1.F1_UFORITR, SF1.F1_UFDESTR
			
		EndSQL

	    oExcel:AddworkSheet(cWksTit)
	    oExcel:AddTable (cWksTit,cTblNm)
		oExcel:AddColumn(cWksTit,cTblNm,"Filial"		,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Dt.Emissao"	,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Dt.Digita็ใo"	,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"S้rie"			,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Documento"		,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Cod.Forn."		,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Loja"			,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Nome"			,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"CFOP"			,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"UF Origem"		,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"UF Destino"	,1,1)

		DbSelectArea(_cAlias)
		(_cAlias)->(DbGoTop())
		While !(_cAlias)->(Eof())
			oExcel:AddRow(cWksTit,cTblNm,{;
						(_cAlias)->D1_FILIAL,;
						(_cAlias)->D1_EMISSAO,;
						(_cAlias)->D1_DTDIGIT,;
						(_cAlias)->F1_SERIE,;
						(_cAlias)->F1_DOC,;
						(_cAlias)->F1_FORNECE,;
						(_cAlias)->F1_LOJA,;
						(_cAlias)->A2_NOME,;
						(_cAlias)->D1_CF,;
						(_cAlias)->F1_UFORITR,;
						(_cAlias)->F1_UFDESTR;
						})						
						
			(_cAlias)->(dbSkip())
		EndDo

		oExcel:AddRow(cWksTit,cTblNm,{;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"";
					})
		
		oExcel:Activate()
		oExcel:GetXMLFile(cArq)

		oMsExcel := MsExcel():New()
		oMsExcel:WorkBooks:Open(cArq)
		oMsExcel:SetVisible( .T. )
		oMsExcel:Destroy()
		
	Endif

	RestArea(aArea)	

	//
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'relat๓rio dos fretes')

Return Nil	
