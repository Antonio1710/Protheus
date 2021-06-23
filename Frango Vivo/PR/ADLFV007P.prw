#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TOTVS.ch"
#Include "Topconn.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ADLFV007P � Autor � Fernando Sigoli    � Data �  10/04/17   ���
�������������������������������������������������������������������������͹��
���Descricao � Tipos de Ocorrencias de Frete [ABATIDO/VIVO]               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������͹��
���Altera��o � Everson-07/03/2019. Chamado 044314. Valida�l�o na exclus�o ���
���          � /altear��o do registro. Alterada rotina para MVC.          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function ADLFV007P()

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�vies.                                            |
	//�����������������������������������������������������������������������
	Local oBrowse	 := Nil
    Private aRotina := AdMnDef()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tipos de Ocorrencias de Frete [ABATIDO/VIVO]')

    //
	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("ZF7")
		oBrowse:SetDescription("Cadastro de Tipos de Ocorr�ncias de Frete")
	oBrowse:Activate()
	
Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ADLFVP01  � Autor � Everson            � Data � 07/03/2019  ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina.                                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chamado 044314.                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AdMnDef()

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�vies.                                            |
	//�����������������������������������������������������������������������
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" Action "VIEWDEF.ADLFV007P" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    Action "VIEWDEF.ADLFV007P" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    Action "VIEWDEF.ADLFV007P" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    Action "VIEWDEF.ADLFV007P" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Imp. CSV"   Action "U_ADLFVP02()"      OPERATION 6 ACCESS 0

Return aRotina
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ADLFVP01  � Autor � Everson            � Data � 07/03/2019  ���
�������������������������������������������������������������������������͹��
���Descricao � Model.                                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chamado 044314.                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ModelDef()

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�vies.                                            |
	//�����������������������������������������������������������������������
	Local oModel
	Local oStruZF7	:= FWFormStruct( 1, "ZF7", /*bAvalCampo*/, /*lViewUsado*/ )
	Local bPosVal	:= {|oModel| ADLFVP01(oModel)} //Everson - 07/03/2019. Chamado 044314.
	
	//
	oModel := MPFormModel():New("ModelDef_MVC", /*bPreVld*/ , bPosVal, /**/, /*bCancel*/ )
	oModel:SetDescription("Manuten��o de Tipos de Ocorr�ncia")
	oModel:AddFields("ZF7MASTER", /*cOwner*/, oStruZF7, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"ZF7_FILIAL","ZF7_CODIGO" } )
	
Return oModel
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ADLFVP01  � Autor � Everson            � Data � 07/03/2019  ���
�������������������������������������������������������������������������͹��
���Descricao � View.                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chamado 044314.                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ViewDef()

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�vies.                                            |
	//�����������������������������������������������������������������������
	Local oView
	Local oModel   := ModelDef()
	Local oStruZF7 := FWFormStruct( 2, "ZF7" )
	
	//
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField("VIEW_ZF7", oStruZF7, "ZF7MASTER" )
	oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetCloseOnOk( { || .T. } )
    
Return oView
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ADLFVP01  � Autor � Everson            � Data � 07/03/2019  ���
�������������������������������������������������������������������������͹��
���Descricao � P�s valida��o.                                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chamado 044314.                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ADLFVP01(oModel)
	
	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������    
    Local aArea			:= GetArea()
    Local lRet 			:= .T.
    Local nOperation 	:= oModel:GetOperation()
    Local cOperacao		:= ""
    Local cCodigo 		:= oModel:GetValue("ZF7MASTER","ZF7_CODIGO")
    Local cTpLanc 		:= oModel:GetValue("ZF7MASTER","ZF7_AUTOM")
 
    //Valida��o de exclus�o.
    If nOperation == 5
    
    	//Verifica se o tipo de ocorr�ncia j� foi utilizado nos lan�amentos de frete.
    	DbSelectArea("ZFA")
    	ZFA->(DbSetOrder(3))
    	ZFA->(DbGoTop())
    	If ZFA->(DbSeek( FwFilial("ZFA") + cCodigo ))
	    	lRet := .F.   
	        Help( ,, "A��o n�o Permitida",, "Tipo de ocorr�ncia de frete j� utilizada nos lan�amentos de frete.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
	        
        EndIf
        
        //Valida a exclus�o de lan�amento autom�tico.
        If cTpLanc == "S" .And. ! FwIsAdmin()
        	lRet := .F.   
        	Help( ,, "A��o n�o Permitida",, "Lan�amento autom�tico n�o pode ser alterado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""}) 
        	       
        EndIf
        
        cOperacao := "Exclus�o"
	           
    ElseIf nOPeration == 4 
    
    	If cTpLanc == "S" .And. ! FwIsAdmin() //Valida a altera��o de lan�amento autom�tico.
	    	lRet := .F.   
		    Help( ,, "A��o n�o Permitida",, "Lan�amento autom�tico n�o pode ser alterado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		    
		EndIf
		
		cOperacao := "Altera��o"
 
	ElseIf nOPeration == 3
		
		cOperacao := "Inclus�o"
	                
    EndIf
    
    //
	If lRet .And. ! Empty(cOperacao)
		logZBE( cOperacao + " de tipo de ocorr�ncia de frete","Ocorr�ncia " + cValToChar(cCodigo) )
    
    EndIf
    
    //
    RestArea(aArea)
    
Return lRet
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ADLFVP02  � Autor � Everson            � Data � 07/03/2019  ���
�������������������������������������������������������������������������͹��
���Descricao � Importa CSV com tipos de ocorr�ncia.                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chamado 044314.                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function ADLFVP02()

	U_ADINF009P('ADLFV007P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tipos de Ocorrencias de Frete [ABATIDO/VIVO]')

	Processa({||  ADLFVP03() },"Importando tipos de ocorr�ncias de frete...")

Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ADLFVP03  � Autor � Everson            � Data � 07/03/2019  ���
�������������������������������������������������������������������������͹��
���Descricao �Processa importa��o de CSV de tipos de ocorr�ncias de frete.���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chamado 044314.                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ADLFVP03()
	
	//���������������������������������������������������������������������������Ŀ
	//�Declara��o de vari�veis.                                                   �
	//�����������������������������������������������������������������������������
	Local aArea		:= GetArea()
	Local i			:= 0
	Local cMsg		:= ""
	Local cBuffer	:= ""
	Local aDados	:= {}
	
	Local cDesc		:= ""
	Local nValor	:= 0
	Local cDB		:= ""
	Local cAbast	:= ""
	Local nPerc		:= 0
	
	Private cArq	:= ""
	Private nHdl	:= 0

	//Obt�m arquivo.
	cMsg := ""
	cArq := cGetFile('Arquivo CSV|*.*|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

	//Valida arquivo.  
	If Empty(cArq)
		MsgStop( "N�o foi poss�vel obter o arquivo.","ADLFVP03(ADLFV007P)")
		Return Nil

	Endif
	
	//Abre o arquivo.
	nHdl := FT_FUse(cArq)

	//Valida abertura do arquivo.
	If nHdl == -1
		MsgStop("N�o foi poss�vel abrir o arquivo " + Chr(13) + Chr(13) + cArq,"ADLFVP03(ADLFV007P)")
		Return Nil

	Endif

	FT_FGoTop()

	//Obt�m a quantidade de linhas.
	nTotLinhas := FT_FLastRec()

	//Atribui o tamanho da r�gua.
	ProcRegua(nTotLinhas)

	FT_FGoTop()
	FT_FGoto(1)

	//Percorre arquivo.
	While ! FT_FEof()
		
		i++
		cBuffer  := Alltrim(cValToChar(DecodeUTF8(FT_FReadln())))

		If ! Empty(cBuffer)

			aDados	 := StrToKarr(cBuffer,";")
			
			If Len(aDados) <> 5
				MsgStop("O arquivo CSV deve ser composto de Descri��o; Valor Padr�o; D�bito ou Cr�dito;Percentual; Abastecimento .","ADLFVP03(ADLFV007P)")
				Return Nil
				
			EndIf
			
			//
			cDesc	:= Alltrim(cValToChar(aDados[1]))
			cDB		:= Alltrim(cValToChar(aDados[2]))
			nValor	:= Val(cValToChar(aDados[3]))
			nPerc	:= Val(cValToChar(aDados[4]))
			cAbast	:= Alltrim(cValToChar(aDados[5]))
			
			//
			If Empty(cDesc)
				MsgStop("Linha " + cValToChar(i) + ": n�o possui descri��o ","ADLFVP03(ADLFV007P)")
				Loop
				
			ElseIf !( cDB $("D|C") )
				MsgStop("Linha " + cValToChar(i) + ": necess�rio informar se a ocorr�ncia � cr�dito (C) o d�bito (D). ","ADLFVP03(ADLFV007P)")
				FT_FSkip()
				Loop
				
			ElseIf nValor > 0 .And. nPerc
				MsgStop("Linha " + cValToChar(i) + ": somente informe o valor ou o percentual maior que 0, n�o os dois. ","ADLFVP03(ADLFV007P)")
				FT_FSkip()
				Loop
				
			ElseIf !( cAbast $("S|N") )
				MsgStop("Linha " + cValToChar(i) + ": informe S ou N para o abastecimento. ","ADLFVP03(ADLFV007P)")
				FT_FSkip()
				Loop
											
			EndIf
			
			//
			If RecLock("ZF7",.T.)
					cCodigo := GetSxeNum("ZF7","ZF7_CODIGO")
					ZF7->ZF7_CODIGO := cCodigo
					ZF7->ZF7_DESC	:= cDesc
					ZF7->ZF7_VALOR	:= nValor
					ZF7->ZF7_AUTOM	:= "N"
					ZF7->ZF7_DBCD	:= cDB
					ZF7->ZF7_ABAST	:= cAbast
					ZF7->ZF7_TOTCOD	:= ""
					ZF7->ZF7_PERDSC	:= nPerc
				ZF7->(MsUnlock())
				
				ConfirmSX8()
				
				logZBE("Inclus�o de tipo de ocorr�ncia de frete","Ocorr�ncia " + cValToChar(cCodigo) )
			
			EndIf
					
			//Incrementa regua de processamento.
			IncProc("Importando " + cDesc)

		EndIf

		FT_FSkip()

	EndDo
	
	//
	RestArea(aArea)
	
Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |logZBE    � Autor � Everson            � Data � 07/03/2019  ���
�������������������������������������������������������������������������͹��
���Descricao � P�s valida��o.                                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chamado 044314.                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function logZBE(cLog,cParam)

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������	
	Local aArea	:= GetArea()

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With dDataBase
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cLog
		Replace ZBE->ZBE_PARAME With cParam
		Replace ZBE_MODULO	    With "LOGISTICA"
		Replace ZBE_ROTINA	    With "ADLFV007P" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil