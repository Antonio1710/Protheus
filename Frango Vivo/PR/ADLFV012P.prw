#include "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} User Function ADLFV012P
	Funcao utilizada no X3_VLDUSER do campo ZV5_NUMNFS (Chamado 041138)
	NO CAMPO ZV5_NUMNFS NUMERO DA NOTA, VALIDAR
•	Nota existe, filial 03
•	Nota não esta cancelada
•	Nota ka fui usanda em outra controle de apanha. 
	@type  Function
	@author Fernando Macieira
	@since 30/05/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
/*/
User Function ADLFV012P()

	Local lRet   := .t.
	Local cQuery := "" 

	Local _ORDEM  := ZV1->ZV1_NUMOC
	Local _FORREC := ZV1->ZV1_FORREC
	Local _LOJREC := ZV1->ZV1_LOJREC

	Local cFilPV   := GetMV("MV_#LFVFIL",,"03")
	Local cSerNFFV := GetMV("MV_#LFVSER",,"01")
	Local cCliCod  := GetMV("MV_#LFVCLI",,"027601")
	Local cCliLoj  := GetMV("MV_#LFVLOJ",,"00")
	Local cProdPV  := GetMV("MV_#LFVPRD",,"300042")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao utilizada no X3_VLDUSER do campo ZV5_NUMNFS')

	If Empty(_FORREC) .or. Empty(_LOJREC)
	
		Aviso(	"ADLFV012P-01",;
		"Necessario preencher os dados do fornecedor Codigo+loja "  + chr(13) + chr(10) +;
		"" ,;
		{ "&OK" },3,;
		"LFV - Apanha - Nota não existente" )   
		Return .f.

	EndIf


	// Consisto se a nota fiscal existe
	SD2->( dbSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->( !dbSeek(cFilPV+M->ZV5_NUMNFS+PadR(cSerNFFV,TamSX3("D2_SERIE")[1])+cCliCod+cCliLoj+cProdPV) )

		lRet := .f.

		// Aviso ao usuario
		Aviso(	"ADLFV012P-02",;
		"Nota Fiscal informada não existe na origem! "  + chr(13) + chr(10) +;
		"Abaixo, dados da pesquisa utilizada: "  + chr(13) + chr(10) + chr(13) + chr(10) +;
		"Filial: " + cFilPV + chr(13) + chr(10) +;
		"NF: " + M->ZV5_NUMNFS + chr(13) + chr(10) +;
		"Série: " + cSerNFFV + chr(13) + chr(10) +;
		"Cliente: " + cCliCod + "/" + cCliLoj + " - " + AllTrim(Posicione("SA1",1,xFilial("SA1")+cCliCod+cCliLoj,"A1_NOME")) + chr(13) + chr(10) +;
		"Produto: " + AllTrim(cProdPV) + " - " + AllTrim(Posicione("SB1",1,xFilial("SB1")+cProdPV,"B1_DESC")) + chr(13) + chr(10) +;
		"" ,;
		{ "&OK" },3,;
		"LFV - Apanha - Nota não existente" )

	EndIf



	// Consisto se a nota fiscal já foi utilizada
	If lRet

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
		
		cQuery := " SELECT ZV5_NUMNFS, ZV5_NUMOC "
		cQuery += " FROM " + RetSqlName("ZV5") + " (NOLOCK) "
		cQuery += " WHERE ZV5_FILIAL='"+xFilial("ZV5")+"' "
		cQuery += " AND ZV5_NUMNFS='"+M->ZV5_NUMNFS+"' "
		cQuery += " AND D_E_L_E_T_='' "
		
		tcQuery cQuery new alias "Work"
		
		Work->( dbGoTop() )
		
		If Work->( !EOF() )
		
			If !Empty(Work->ZV5_NUMNFS) .AND. Work->ZV5_NUMOC  <> _ORDEM
		
				lRet := .f.
			
				// Aviso ao usuario
				Aviso(	"ADLFV012P-03",;
				"Nota Fiscal informada já utilizada! "  + chr(13) + chr(10)+;
				"Abaixo, dados da pesquisa utilizada: "  + chr(13) + chr(10) + chr(13) + chr(10)+;
				"OC n. : " + Work->ZV5_NUMOC + chr(13) + chr(10) +;
				"" ,;
				{ "&OK" },3,;
				"LFV - Apanha - Nota já utilizada" )
			
			EndIf
		
		EndIf
		
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
											
		//Verificar se a nota pesquisada ja existe incluida na ordem de carregamento 
		//Inicio: Fernando Sigoli 30/08/2018 
		_cQuery := " SELECT ZV1_NUMOC, ZV1_NUMNFS, ZV1_SERIE, ZV1_CODFOR, ZV1_LOJFOR "
		_cQuery += " FROM "+retsqlname("ZV1") +" (NOLOCK) 
		_cQuery += " WHERE ZV1_FILIAL='"+FWxFilial("ZV1") +"' AND " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
		_cQuery += " RTRIM(LTRIM(ZV1_NUMNFS)) = '"+RemvZero(ALLTRIM(M->ZV5_NUMNFS))+"' and "
		_cQuery += " ZV1_FORREC = '"+_FORREC+"' and ZV1_LOJREC = '"+_LOJREC+"' and "
		_cQuery += " D_E_L_E_T_ <> '*' ORDER BY ZV1_NUMOC"
		
		TcQuery _cQuery New Alias "VZV1"

		DbSelectArea("VZV1")
		VZV1->(dbGoTop())
		While !VZV1->(eof())
		If VZV1->ZV1_NUMOC <> _ORDEM      //&& Verifica se nao esta alterando uma OC.
		
				Aviso(	"ADLFV012P-04",;
				"Nota Fiscal informada já utilizada! "  + chr(13) + chr(10)+;
				"Abaixo, dados da pesquisa utilizada: "  + chr(13) + chr(10) + chr(13) + chr(10)+;
				"OC n. : " + VZV1->ZV1_NUMOC + chr(13) + chr(10) +;
				"" ,;
				{ "&OK" },3,;
				"LFV - Apanha - Nota já utilizada" )
			
			VZV1->(DbCloseArea())
			Return (.f.)
			Exit
		endif
		
		VZV1->(dbSkip())
		EndDo
		
		If Select("VZV1") > 0
			VZV1->(DbCloseArea())
		EndIf
	
		//Fim: Fernando Sigoli 30/08/2018 
		
		//verificar se a nota que esta sendo lançada nao esta cancelada.
		//Inicio: Fernando Sigoli 30/08/2018 
		cQryCAN :=  " SELECT COUNT(SF2.F2_DOC) AS RECNFCAN  "
		cQryCAN +=  " FROM "+retsqlname("SF2") +" SF2 WITH (NOLOCK) INNER JOIN "+retsqlname("C00") +" C00 WITH (NOLOCK) ON " 
		cQryCAN +=  " SF2.F2_CHVNFE = C00.C00_CHVNFE  "
		cQryCAN +=  " WHERE  "
		cQryCAN +=  " SF2.F2_FILIAL = '"+cFilPV+"'  "
		cQryCAN +=  " AND C00.C00_SITDOC = '3'  "
		cQryCAN +=  " AND SF2.D_E_L_E_T_ = '*' "
		cQryCAN +=  " AND C00.D_E_L_E_T_ = '' "
		cQryCAN +=  " AND SF2.F2_DOC = '"+PADL(M->ZV5_NUMNFS,9,"0")+"'"   
		cQryCAN +=  " GROUP BY F2_DOC "  
		
		If Select("VSF2") > 0
			VSF2->(DbCloseArea())
		EndIf
		
		TcQuery cQryCAN New Alias "VSF2" 
		
		DbSelectArea("VSF2")
		VSF2->(dbGoTop()) 
						
		If VSF2->RECNFCAN > 0
			MsgInfo ("Atenção. Nota Fiscal " +PADL(M->ZV5_NUMNFS,9,"0")+ " com situação Cancelada . Por favor, verificar") 
			
			Aviso(	"ADLFV012P-05",;
			"Nota Fiscal informada esta cancelada! "  + chr(13) + chr(10)+;
			"Abaixo, dados da pesquisa utilizada: "  + chr(13) + chr(10) + chr(13) + chr(10)+;
			"N.Fiscal. : " + PADL(M->ZV5_NUMNFS,9,"0") + chr(13) + chr(10) +;
			"" ,;
			{ "&OK" },3,;
			"LFV - Apanha; - Nota Cancelada" )
			
			
			VZV2->(DbCloseArea())
			Return (.f.)
		
		EndIF
		
		If Select("VSF2") > 0
			VSF2->(DbCloseArea())
		EndIf	
		
		//Fim: Fernando Sigoli 30/08/2018  
		
	EndIf

Return lRet

//função retira zero a esquerda
Static Function RemvZero(cTexto)

	Local aArea     := GetArea()
	Local cRetorno  := ""
	Local lContinua := .T.
	Default cTexto  := ""

		//Pegando o texto atual
		cRetorno := Alltrim(cTexto)

		//Enquanto existir zeros a esquerda
		While lContinua
			//Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
			If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
				lContinua := .f.
			EndIf

			//Se for continuar o processo, pega da próxima posição até o fim
			If lContinua
				cRetorno := Substr(cRetorno, 2, Len(cRetorno))
			EndIf
		EndDo

		RestArea(aArea)

Return cRetorno
