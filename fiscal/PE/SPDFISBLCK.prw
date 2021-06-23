#INCLUDE "PROTHEUS.CH"
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SPDFISBLCK³ Autor ³ ADRIANA OLIVEIRA      ³ Data ³ 26/01/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³PE executado na geracao do sped fiscal para gerar bloco K   ³±±
±±³          ³especifico Adoro, tendo como base tabela ZBL (ADFIS013P)    ³±±
±±³          ³Utilizado apenas para gerar K200                            ³±±
±±³          ³MODELO PE PADRAO TOTVS-ATENCAO AO ALTERAR                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºALTERAÇÃO ³Adriana Oliveira-20/02/2019-047392, AJUSTE PARA NOVO LEIAUTEº±±
±±º          ³013 CONFORME DOCUMENTACAO NO TDN                            º±±
±±º          ³tdn.totvs.com/pages/releaseview.action?pageId=203761344013  º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SPDFISBLCK() 

	Local aRet      := {} 
	Local dDataIni := PARAMIXB[1] 
	Local dDataFin := PARAMIXB[2] 
	Local cAlias0210 := '' 
	Local cAliasK200 := '' 
	Local cAliasK220 := '' 
	Local cAliasK230 := '' 
	Local cAliasK235 := '' 
	Local cAliasK250 := '' 
	Local cAliasK255 := '' 
	Local cAliasK210 := '' 
	Local cAliasK215 := ''
	Local cAliasK260 := '' 
	Local cAliasK265 := ''
	Local cAliasK270 := ''
	Local cAliasK275 := '' 
	Local cAliasK280 :='' 
	//por Adriana em 20/02/2019 - chamado 047392
	Local cAliasK290 :='' 
	Local cAliasK291 :='' 
	Local cAliasK292 :='' 
	Local cAliasK300 :='' 
	Local cAliasK301 :='' 
	Local cAliasK302 :='' 
	//
	
	memowrite("\LOGRDM\"+ALLTRIM(PROCNAME())+".LOG",Dtoc(date()) + " - " + time() + " - " +alltrim(cusername)) // Everson - 17/07/2017. Chamado 036032.
	
	//----------------------------------------------------------------- 
	//Cria alias e tabelas temporárias do bloco K 
	//----------------------------------------------------------------- 
	//por Adriana em 20/02/2019 - chamado 047392 
	u_TmpBlcK(@cAlias0210,@cAliasK200,@cAliasK220,@cAliasK230,@cAliasK235,@cAliasK250,@cAliasK255,@cAliasK210, @cAliasK215, @cAliasK260, @cAliasK265, @cAliasK270,@cAliasK275,@cAliasK280,@cAliasK290,@cAliasK291,@cAliasK292,@cAliasK300,@cAliasK301,@cAliasK302 ) 
	
	//---------------------------------------------------------------- 
	//Adicionando informações no arquivo temporário para registro 0210 
	//---------------------------------------------------------------- 
	/*
	RecLock (cAlias0210, .T.) 
	(cAlias0210)->FILIAL := 'D MG 01 '        // Exemplo de filial , devera informar a filial de seu ambiente que devera gerar o arquivo
	(cAlias0210)->REG := '0210' 
	(cAlias0210)->COD_ITEM := '500'      //Exemplo de código de produto , devera ser informado um código valido em seu ambiente.
	(cAlias0210)->COD_I_COMP := '600' 
	(cAlias0210)->QTD_COMP := 4 
	(cAlias0210)->PERDA := 0 
	MsUnLock () 
	*/
	
	//---------------------------------------------------------------- 
	//Adicionando informações no arquivo temporário para registro K200 
	//---------------------------------------------------------------- 
	//Adoro
	DbSelectArea("ZBL")
	DbSetOrder(1)	
	If DbSeek(xFilial("ZBL")+cFilant+DtoS(dDataFin))
			
		While ZBL->(!Eof()) .and. ZBL->ZBL_UNIDAD = cFilAnt .and. ZBL->ZBL_DT_EST = dDataFin
	
			RecLock (cAliasK200, .T.) 
			(cAliasK200)->FILIAL 	:= ZBL->ZBL_UNIDAD
			(cAliasK200)->REG 		:= 'K200' 
			(cAliasK200)->DT_EST 	:= ZBL->ZBL_DT_EST
			(cAliasK200)->COD_ITEM 	:= ZBL->ZBL_COD_IT
			(cAliasK200)->QTD 		:= ZBL->ZBL_QTD  
			(cAliasK200)->IND_EST 	:= ZBL->ZBL_IND_ES
			(cAliasK200)->COD_PART 	:= ZBL->ZBL_COD_PA        //"SA2021041"
			MsUnLock () 
	
			DbSelectArea("ZBL")
			ZBL->(Dbskip())
			
		End
		
	Endif	
	//Fim Adoro
	
	/*
	//---------------------------------------------------------------- 
	//Adicionando informações no arquivo temporário para registro K200 
	//---------------------------------------------------------------- 
	RecLock (cAliasK200, .T.) 
	(cAliasK200)->FILIAL := 'D MG 01 ' 
	(cAliasK200)->REG := 'K200' 
	(cAliasK200)->DT_EST := CtoD("31/01/2016") 
	(cAliasK200)->COD_ITEM := '500' 
	(cAliasK200)->QTD := 1 
	(cAliasK200)->IND_EST := '0' 
	(cAliasK200)->COD_PART := '' 
	MsUnLock () 
	
	RecLock (cAliasK200, .T.) 
	(cAliasK200)->FILIAL := 'D MG 01 ' 
	(cAliasK200)->REG := 'K200' 
	(cAliasK200)->DT_EST := CtoD("31/01/2016") 
	(cAliasK200)->COD_ITEM := '600' 
	(cAliasK200)->QTD := 2 
	(cAliasK200)->IND_EST := '0' 
	(cAliasK200)->COD_PART := '' 
	MsUnLock () 
	*/
	
	//---------------------------------------------------------------- 
	//Adicionando informações no arquivo temporário para registro K230 
	//---------------------------------------------------------------- 
	/*
	RecLock (cAliasK230, .T.) 
	(cAliasK230)->FILIAL := 'D MG 01 ' 
	(cAliasK230)->REG := 'K230' 
	(cAliasK230)->DT_INI_OP := CtoD("01/01/2016") 
	(cAliasK230)->DT_FIN_OP := "04012016" 
	(cAliasK230)->COD_DOC_OP := '00005001001' 
	(cAliasK230)->COD_ITEM := '500' 
	(cAliasK230)->QTD_ENC := 2 
	MsUnLock () 
	*/
	
	//---------------------------------------------------------------- 
	//Adicionando informações no arquivo temporário para registro K235 
	//---------------------------------------------------------------- 
	/*
	RecLock (cAliasK235, .T.) 
	(cAliasK230)->FILIAL := 'D MG 01 ' 
	(cAliasK235)->REG := 'K235' 
	(cAliasK235)->DT_SAIDA := CtoD("01/01/2016") 
	(cAliasK235)->COD_ITEM := '600' 
	(cAliasK235)->QTD := 8 
	(cAliasK235)->COD_INS_SU := '' 
	(cAliasK235)->COD_DOC_OP := '00005001001' 
	MsUnLock ()
	*/ 
	
	//Adiciona alias das tabelas temporárias criadas 
	aAdd(aRet,cAlias0210) 
	aAdd(aRet,cAliasK200) 
	aAdd(aRet,cAliasK220) 
	aAdd(aRet,cAliasK230) 
	aAdd(aRet,cAliasK235) 
	aAdd(aRet,cAliasK250) 
	aAdd(aRet,cAliasK255) 
	aAdd(aRet,cAliasK210)
	aAdd(aRet,cAliasK215)
	aAdd(aRet,cAliasK260)
	aAdd(aRet,cAliasK265)
	aAdd(aRet,cAliasK270)
	aAdd(aRet,cAliasK275)
	aAdd(aRet,cAliasK280) 
	//por Adriana em 20/02/2019 - chamado 047392
	aAdd(aRet,cAliasK290) 
	aAdd(aRet,cAliasK291) 
	aAdd(aRet,cAliasK292)
	aAdd(aRet,cAliasK300) 
	aAdd(aRet,cAliasK301) 
	aAdd(aRet,cAliasK302)
	//

Return aRet 

//------------------------------------------------------------------- 
/*/{Protheus.doc} TmpBlcK 
Função para criação das tabelas temporárias para geração do bloco K 
/*/ 
//------------------------------------------------------------------- 
//User Function TmpBlcK(cAlias0210,cAliasK200,cAliasK220,cAliasK230,cAliasK235,cAliasK250,cAliasK255,cAliasK210, cAliasK215, cAliasK260, cAliasK265, cAliasK270,cAliasK275,cAliasK280 ) 
User Function TmpBlcK(cAlias0210,cAliasK200,cAliasK220,cAliasK230,cAliasK235,cAliasK250,cAliasK255,cAliasK210, cAliasK215, cAliasK260, cAliasK265, cAliasK270,cAliasK275,cAliasK280,cAliasK290,cAliasK291,cAliasK292,cAliasK300,cAliasK301,cAliasK302 ) 

	Local aCampos := {} 
	Local nTamFil := TamSX3("D1_FILIAL")[1] 
	Local nTamDt := TamSX3("D1_DTDIGIT")[1] 
	Local aTamQtd := TamSX3("B2_QATU") 
	Local nTamOP := TamSX3("D3_OP")[1] 
	Local nTamCod := TamSX3("B1_COD")[1] 
	Local nTamChave := TamSX3("D1_COD")[1] + TamSX3("D1_SERIE")[1] + TamSX3("D1_FORNECE")[1] + TamSX3("D1_LOJA")[1]
	Local nTamPar := TamSX3("A1_COD")[1] 
	Local nTamReg := 4 
	Local cArq0210 := '' 
	Local cArqK200 := '' 
	Local cArqK220 := '' 
	Local cArqK230 := '' 
	Local cArqK235 := '' 
	Local cArqK250 := '' 
	Local cArqK255 := '' 
	Local cArqK210 := '' 
	Local cArqK215 := ''
	Local cArqK260 := '' 
	Local cArqK265 := ''
	Local cArqK270 := ''
	Local cArqK280 :=''
	//por Adriana em 20/02/2019 - chamado 047392  
	Local cArqK290 :=''
	Local cArqK291 :=''
	Local cArqK292 :=''
	Local cArqK300 :=''
	Local cArqK301 :=''
	Local cArqK302 :=''
	//
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO 0210 
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro 0210
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //***Código do produto que fará o relacionamento com registro pai 0200
	AADD(aCampos,{"COD_I_COMP" ,"C",nTamCod ,0}) //Campo 02 do registro 0210 
	AADD(aCampos,{"QTD_COMP" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 03 do registro 0210
	AADD(aCampos,{"PERDA" ,"N",5 ,2}) //Campo 04 do registro 0210 
	
	cAlias0210 := '0210' 
	cArq0210 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArq0210, cAlias0210, .T. ) 
	DbSelectArea(cAlias0210)                               
	IndRegua(cAlias0210,cArq0210,"FILIAL+COD_ITEM+COD_I_COMP") 
	DbSetOrder(1) 
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K200 
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K200 
	AADD(aCampos,{"DT_EST" ,"D",nTamDt ,0}) //Campo 02 do registro K200 
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 03 do registro K200 
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 04 do registro K200 
	AADD(aCampos,{"IND_EST" ,"C",1 ,0}) //Campo 05 do registro K200 
	AADD(aCampos,{"COD_PART" ,"C",11,0})//nTamPar,0}) //Campo 06 do registro K200      //Alterado por Adriana em 15/03/2017  layout TABELA+CODIGO+LOJA Ex.: SA200004535
	
	cAliasK200 := 'K200' 
	cArqK200 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK200, cAliasK200, .F., .F. ) 
	IndRegua(cAliasK200,cArqK200,"FILIAL+DTOS(DT_EST)+COD_ITEM") 
	DbSelectArea(cAliasK200) 
	DbSetOrder(1) 
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K220 
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K220 
	AADD(aCampos,{"DT_MOV" ,"D",nTamDt ,0}) //Campo 02 do registro K220 
	AADD(aCampos,{"COD_ITEM_O" ,"C",nTamCod ,0}) //Campo 03 do registro K220 
	AADD(aCampos,{"COD_ITEM_D" ,"C",nTamCod ,0}) //Campo 04 do registro K220 
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 05 do registro K220 
	
	cAliasK220 := 'K220' 
	cArqK220 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK220, cAliasK220, .F., .F. ) 
	IndRegua(cAliasK220,cArqK220,"FILIAL") 
	DbSelectArea(cAliasK220) 
	DbSetOrder(1) 
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K230 
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K230 
	AADD(aCampos,{"DT_INI_OP" ,"D",nTamDt ,0}) //Campo 02 do registro K230 
	AADD(aCampos,{"DT_FIN_OP" ,"C",nTamDt ,0}) //Campo 03 do registro K230 
	AADD(aCampos,{"COD_DOC_OP" ,"C",nTamOP ,0}) //***Campo 04 do registro K230. Campo utilizado para fazer relacionamento com registro filho K230 
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 05 do registro K230 
	AADD(aCampos,{"QTD_ENC" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 06 do registro K230 
	
	cAliasK230 := 'K230' 
	cArqK230 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK230, cAliasK230, .F., .F. ) 
	IndRegua(cAliasK230,cArqK230,"FILIAL+COD_DOC_OP") 
	DbSelectArea(cAliasK230) 
	DbSetOrder(1) 
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K235 
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K235 
	AADD(aCampos,{"DT_SAIDA" ,"D",nTamDt ,0}) //Campo 02 do registro K235 
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 03 do registro K235 
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 04 do registro K235 
	AADD(aCampos,{"COD_INS_SU" ,"C",nTamCod ,0}) //Campo 05 do registro K235 
	AADD(aCampos,{"COD_DOC_OP" ,"C",nTamOP ,0}) //***Campo de ligação com registro K230, o relacionamento de K230 e K235 será feito por este campo 
	
	cAliasK235 := 'K235' 
	cArqK235 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArqK235, cAliasK235, .F., .F. ) 
	IndRegua(cAliasK235,cArqK235,"FILIAL+COD_DOC_OP") 
	DbSelectArea(cAliasK235) 
	DbSetOrder(1) 
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K250 
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K250 
	AADD(aCampos,{"CHAVE" ,"C",nTamChave ,0}) //***Campo de ligação com registros filho K255 
	AADD(aCampos,{"DT_PROD" ,"D",nTamDt ,0}) //Campo 02 do registro K250 
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 03 do registro K250 
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 04 do registro K250 
	
	cAliasK250 := 'K250' 
	cArqK250 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArqK250, cAliasK250, .F., .F. ) 
	IndRegua(cAliasK250,cArqK250,"FILIAL+DTOS(DT_PROD)+COD_ITEM") 
	DbSelectArea(cAliasK250) 
	DbSetOrder(1) 
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K255 
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K255 
	AADD(aCampos,{"CHAVE" ,"C",nTamChave ,0}) //***Campo de ligação com registros pai K250 
	AADD(aCampos,{"DT_CONS" ,"D",nTamDt ,0}) //Campo 02 do registro K255 
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 03 do registro K255 
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 04 do registro K255 
	AADD(aCampos,{"COD_INS_SU" ,"C",nTamCod ,0}) //Campo 05 do registro K250 
	
	cAliasK255 := 'K255' 
	cArqK255 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArqK255, cAliasK255, .F., .F. ) 
	IndRegua(cAliasK255,cArqK255,"FILIAL+CHAVE") 
	DbSelectArea(cAliasK255) 
	DbSetOrder(1)
	 
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K210
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"DT_INI_OS" ,"C",nTamReg ,0}) //Campo 01 do Registro K210
	AADD(aCampos,{"DT_FIN_OS" ,"C",nTamChave ,0}) //Campo 02 do Registro K210 
	AADD(aCampos,{"COD_DOC_OS" ,"D",nTamDt ,0}) //Campo 03 do Registro K210
	AADD(aCampos,{"COD_ITEM_O" ,"C",nTamCod ,0}) //Campo 04 do Registro K210 
	AADD(aCampos,{"QTD_ORI" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 05 do Registro K210
	
	cAliasK210 := 'K210'
	cArqK210 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArqK210, cAliasK210, .F., .F. ) 
	IndRegua(cAliasK210,cArqK210,"FILIAL+COD_ITEM_O") 
	DbSelectArea(cAliasK210) 
	DbSetOrder(1)
	 
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K215
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do Registro K215
	AADD(aCampos,{"COD_DOC_OS" ,"C",nTamChave ,0}) // Campo chave de ligação com o registro pai K210
	AADD(aCampos,{"COD_ITEM_D" ,"D",nTamDt ,0}) //Campo 02 do Registro K215
	AADD(aCampos,{"QTD_DES" ,"C",nTamCod ,0}) //Campo 03 do Registro K215 
	
	cAliasK215 := 'K215'
	cArqK215 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArqK215, cAliasK215, .F., .F. ) 
	IndRegua(cAliasK215,cArqK215,"FILIAL+COD_DOC_OS") 
	DbSelectArea(cAliasK215) 
	DbSetOrder(1)
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K260
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K260" 
	AADD(aCampos,{"COD_OP_OS" ,"C",nTamChave ,0}) // Código de identificação da ordem de produção, no reprocessamento, ou da ordem de serviço, no reparo
	AADD(aCampos,{"COD_ITEM" ,"D",nTamDt ,0}) //Código do produto/insumo a ser reprocessado/reparado ou já reprocessado/reparado
	AADD(aCampos,{"DT_SAIDA" ,"C",nTamCod ,0}) //Data de saída do estoque
	aADD(aCampos,{"QTD_SAIDA" ,"C",nTamCod ,0}) //Quantidade de saída do estoque
	aADD(aCampos,{"DT_RET" ,"C",nTamCod ,0}) //Data de retorno ao estoque (entrada) 
	aADD(aCampos,{"QTD_RET" ,"C",nTamCod ,0}) //Quantidade de retorno ao estoque (entrada)
	 
	cAliasK260 := 'K260''
	cArqK260 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArqK260, cAliasK260, .F., .F. ) 
	IndRegua(cAliasK260,cArqK260,"FILIAL+COD_OP_OS") 
	DbSelectArea(cAliasK260) 
	DbSetOrder(1)
	 
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K265
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K265" 
	AADD(aCampos,{"COD_OP_OS" ,"C",nTamChave ,0}) // Campo chave que liga ao registro Pai K260
	AADD(aCampos,{"COD_ITEM" ,"D",nTamDt ,0}) //Código da mercadoria (campo 02 do Registro 0200) 
	AADD(aCampos,{"QTD_CONS" ,"C",nTamCod ,0}) //Quantidade consumida – saída do estoque
	aADD(aCampos,{"QTD_RET" ,"C",nTamCod ,0}) //Quantidade retornada – entrada em estoque 
	
	cAliasK265 := 'K265''
	cArqK265 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArqK265, cAliasK265, .F., .F. ) 
	IndRegua(cAliasK265,cArqK265,"FILIAL+COD_OP_OS") 
	DbSelectArea(cAliasK265) 
	DbSetOrder(1)
	 
	 
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K270
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K270" 
	AADD(aCampos,{"DT_INI_AP" ,"C",nTamChave ,0}) // Data inicial do período de apuração em que ocorreu o apontamento que está sendo corrigido
	AADD(aCampos,{"DT_FIN_AP" ,"D",nTamDt ,0}) //Data final do período de apuração em que ocorreu o apontamento que está sendo corrigido
	AADD(aCampos,{"COD_OP_OS" ,"C",nTamCod ,0}) //Código de identificação da ordem de produção ou da ordem de serviço que está sendo corrigida
	aADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Código da mercadoria que está sendo corrigido (campo 02 do Registro 0200)
	aADD(aCampos,{"QTD_COR_P" ,"C",nTamCod ,0}) //Quantidade de correção positiva de apontamento ocorrido em período de apuração anterior
	aADD(aCampos,{"QTD_COR_N" ,"C",nTamCod ,0}) //Quantidade de correção negativa de apontamento ocorrido em período de apuração anterior
	aADD(aCampos,{"ORIGEM " ,"C",nTamCod ,0}) //Origem da correção, conforme manual do Sped
	 
	cAliasK270 := 'K270''
	cArqK270 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArqK270, cAliasK270, .F., .F. ) 
	IndRegua(cAliasK270,cArqK270,"FILIAL+COD_OP_OS") 
	DbSelectArea(cAliasK270) 
	DbSetOrder(1)
	 
	 
	 
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K275
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K275" 
	AADD(aCampos,{"COD_OP_OS" ,"C",nTamChave ,0}) // Campo chave que liga ao registro Pai K270
	AADD(aCampos,{"COD_ITEM" ,"D",nTamDt ,0}) //Código da mercadoria (campo 02 do Registro 0200) 
	AADD(aCampos,{"QTD_COR_P" ,"C",nTamCod ,0}) //Quantidade de correção positiva de apontamento ocorrido em período de apuração anterior
	aADD(aCampos,{"QTD_COR_N" ,"C",nTamCod ,0}) //Quantidade de correção negativa de apontamento ocorrido em período de apuração anterior
	aADD(aCampos,{"COD_INS_SU" ,"C",nTamCod ,0}) //Código do insumo que foi substituído, caso ocorra a substituição, relativo aos Registros K235/K255
	
	cAliasK275 := 'K275''
	cArqK275 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver, cArqK275, cAliasK275, .F., .F. ) 
	IndRegua(cAliasK275,cArqK275,"FILIAL+COD_OP_OS") 
	DbSelectArea(cAliasK275) 
	DbSetOrder(1)
	 
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K280
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K280"
	AADD(aCampos,{"DT_EST" ,"D",nTamDt ,0}) //Data do estoque final escriturado que está sendo corrigido 
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Código do item (campo 02 do Registro 0200) 
	AADD(aCampos,{"QTD_COR_P" ,"C",nTamCod ,0}) //Quantidade de correção positiva de apontamento ocorrido em período de apuração anterior
	AADD(aCampos,{"QTD_COR_N" ,"N",aTamQtd[1],aTamQtd[2]}) //Quantidade de correção negativa de apontamento ocorrido em período de apuração anterior 
	AADD(aCampos,{"IND_EST" ,"N",aTamQtd[1],aTamQtd[2]}) //Indicador do tipo de estoque 
	AADD(aCampos,{"COD_PART" ,"N",nTamPar ,0 }) //Código do participante  
	 
	cAliasK280 := 'K280' 
	cArqK280 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK280, cAliasK280, .F., .F. ) 
	IndRegua(cAliasK280,cArqK280,"FILIAL") 
	DbSelectArea(cAliasK280) 
	DbSetOrder(1)
	
	
	//por Adriana em 20/02/2019 - chamado 047392 (inicio)
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K290
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K290"
	AADD(aCampos,{"DT_INI_OP" ,"D",nTamDt ,0}) //Data de inÃ­cio da ordem de produÃ§Ã£o
	AADD(aCampos,{"DT_FIN_OP" ,"D",nTamDt ,0}) //Data de conclusÃ£o da ordem de produÃ§Ã£o
	AADD(aCampos,{"COD_DOC_OP" ,"C",nTamOP ,0}) //CÃ³digo de identificaÃ§Ã£o da ordem de produÃ§Ã£o
	
	
	cAliasK290 := 'K290' 
	cArqK290 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK290, cAliasK290, .F., .F. ) 
	IndRegua(cAliasK290,cArqK290,"FILIAL+COD_DOC_OP") 
	DbSelectArea(cAliasK290) 
	DbSetOrder(1)
	
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K291
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K291"
	AADD(aCampos,{"COD_DOC_OP","C",nTamOP,0}) // CÃ³digo de identificaÃ§Ã£o da ordem de produÃ§Ã£o
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //CÃ³digo do item produzido (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2] ,0}) //Quantidade de produÃ§Ã£o acabada 
	
	
	cAliasK291 := 'K291' 
	cArqK291 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK291, cAliasK291, .F., .F. ) 
	IndRegua(cAliasK291,cArqK291,"FILIAL+COD_DOC_OP+COD_ITEM") 
	DbSelectArea(cAliasK291) 
	DbSetOrder(1)
	
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K292
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K292"
	AADD(aCampos,{"COD_DOC_OP","C",nTamOP,0}) // CÃ³digo de identificaÃ§Ã£o da ordem de produÃ§Ã£o
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //CÃ³digo do item produzido (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2] ,0}) //Quantidade de produÃ§Ã£o acabada 
	
	
	cAliasK292 := 'K292' 
	cArqK292 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK292, cAliasK292, .F., .F. ) 
	IndRegua(cAliasK292,cArqK292,"FILIAL+COD_DOC_OP+COD_ITEM") 
	DbSelectArea(cAliasK292) 
	DbSetOrder(1)
	
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K300
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"CHAVE" ,"C",nTamChave ,0}) //Campo de ligaÃ§Ã£o com registros K301 e K302
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K300"
	AADD(aCampos,{"DT_PROD" ,"D",nTamDt ,0}) //Data do reconhecimento da produÃ§Ã£o ocorrida no terceiro
	
	
	cAliasK300 := 'K300' 
	cArqK300 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK300, cAliasK300, .F., .F. ) 
	IndRegua(cAliasK300,cArqK300,"FILIAL+CHAVE") 
	DbSelectArea(cAliasK300) 
	DbSetOrder(1)
	
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K301
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K301"
	AADD(aCampos,{"CHAVE" ,"C",nTamChave,0}) // Campo de ligaÃ§Ã£o com registro K300
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //CÃ³digo do item produzido (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2] ,0}) //Quantidade produzida
	
	cAliasK301 := 'K301' 
	cArqK301 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK301, cAliasK301, .F., .F. ) 
	IndRegua(cAliasK301,cArqK301,"FILIAL+CHAVE") 
	DbSelectArea(cAliasK301) 
	DbSetOrder(1)
	
	//-------------------------------------------- 
	//Criacao do Arquivo de Trabalho - BLOCO K302
	//-------------------------------------------- 
	aCampos := {} 
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) 
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K302"
	AADD(aCampos,{"CHAVE" ,"C",nTamChave,0}) // Campo de ligaÃ§Ã£o com registro K300
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //CÃ³digo do item produzido (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2] ,0}) //Quantidade consumida
	
	cAliasK302 := 'K302' 
	cArqK302 := CriaTrab(aCampos) 
	dbUseArea(.T.,__LocalDriver,cArqK302, cAliasK302, .F., .F. ) 
	IndRegua(cAliasK302,cArqK302,"FILIAL+CHAVE") 
	DbSelectArea(cAliasK302) 
	DbSetOrder(1)
	
	//por Adriana em 20/02/2019 - chamado 047392 (fim)

Return
 
/*
Este exemplo irá gerar o bloco K da seguinte maneira:
 
|K001|0|
|K100|01012016|31012016|
|K200|31012016|500|1,000|0||
|K200|31012016|600|2,000|0||
|K230|01012016|04012016|00005001001|500|2,000|
|K235|01012016|600|8,000||
|K990|7|
Neste exemplo o registro 0210 fica da seguinte maneira:
0210	600	4,000000	
0
*/