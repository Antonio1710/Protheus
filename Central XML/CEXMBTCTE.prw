#Include "Totvs.ch"

/*/{Protheus.doc} CEXMBTCTE
@description 	Ponto de entrada na conversao do fator de CTE
@obs			Ele estando como �F� ele entra com pr� nota, o campo = �C� � frete de compra.
@author 		Fabrica de Software Fabritech
@since 			02/03/2018
@version		1.0
@return			Nil
@type 			Function
@history		Ticket 66275  - Abel Babini		-	07/06/2022 - Cria��o de bot�o para vincular CT-e a Documento de Origem quando CNPJ duplicado na base ou Fornecedor estrangeiro
/*/

//RECNFCTE->XML_TPFRET
//Ele estando como �F� ele entra com pr� nota, o campo = �C� � frete de compra.
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CEXMBTCTE �Autor  �Abel Babini Filho   � Data �  22/07/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Acrescenta botoes na Central XML CT-e                      ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
���Chamado   �                                                            ���
���n.049468  � Recusa Adoro CT-e - Abel Babini - 22/07/2019               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function CEXMBTCTE()
	
	Local aRetorno	:= Array( 03 )

	aRetorno[1]	:= "ADORO"		//[01] - Descri��o da Fun��o (Ser� exibida no menu lateral)
	aRetorno[2]	:= "TRMIMG32.PNG"	//[02] - Imagem (Precisa estar no repositorio)
	aRetorno[3]	:= "CEXCTEBT"		//[03] - Fun��o de Usu�rio (User Function)
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CENTRALXML- P.E para acrescenta botoes na Central XML CT-e ')
	
	
Return aRetorno
                    

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CEXCTEBT  �Autor  �Abel Babini Filho   � Data �  22/07/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria tela com os bot�es customizados na Central XML CT-e    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
//
User Function CEXCTEBT()      

	Local oBtnCan	:= Nil
	Local oBtn01	:= Nil //Altera Tipo CTe
	Local oBtn02	:= Nil //Recusa ADORO CT-e
	Local oBtn03	:= Nil //Relat�rio CT-e Pendente
	Local oBtn04	:= Nil //Ticket 66275  - Abel Babini		-	07/06/2022 - Cria��o de bot�o para vincular CT-e a Documento de Origem quando CNPJ duplicado na base ou Fornecedor estrangeiro

	Private oDlgAdr	:= Nil

	DEFINE MSDIALOG oDlgAdr TITLE "Customiza��es da Ad'oro" FROM 000, 000  TO 165, 310 COLORS 0, 16777215 PIXEL style 128
	oDlgAdr:lEscClose     := .T. //Permite sair ao se pressionar a tecla ESC.
	
	@ 010, 010 SAY OemToAnsi("Selecione a op��o desejada:") SIZE 150, 025 OF oDlgAdr COLORS 0, 16777215 PIXEL
	oBtn01 := TButton():New( 018, 010, "Alterar Tipo CT-e",oDlgAdr,{||U_CEXCTETP()}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn02 := TButton():New( 018, 080, "Recusa Ad�oro CT-e",oDlgAdr,{||U_CEXCTERC()}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn03 := TButton():New( 042, 080, "Relat�rio CT-e Pend.",oDlgAdr,{||U_ADFIS033R()}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn04 := TButton():New( 042, 010, "Vincula CT-e Doc. Orig.",oDlgAdr,{||U_CEXCTEDO()}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. ) //Ticket 66275  - Abel Babini		-	07/06/2022 - Cria��o de bot�o para vincular CT-e a Documento de Origem quando CNPJ duplicado na base ou Fornecedor estrangeiro
	
	DEFINE SBUTTON oBtnCan 	FROM 068, 130 TYPE 02 OF oDlgAdr ENABLE Action( oDlgAdr:End() )
	

	ACTIVATE MSDIALOG oDlgAdr CENTERED
	
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CEXCTETP  �Autor  �Abel Babini Filho   � Data �  22/07/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     �Altera o tipo do CTE. F=Pre-nota, C=Frete Compra            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
//
User Function CEXCTETP()      

	IF MSGNOYES("Deseja Alterar o Tipo de CTE ?")
                                          
		If RECNFCTE->XML_TPFRET = "F" // cte para gerar Pre nota                                
	
			RecLock("RECNFCTE",.F.)
			RECNFCTE->XML_TPFRET := "C"
			MsUnlock() 
		
			Alert('Altera��o realizada com sucesso')
		
		ElseIf RECNFCTE->XML_TPFRET = "C" // cte para gerar Pre nota                                
	
			RecLock("RECNFCTE",.F.)
			RECNFCTE->XML_TPFRET := "F"
			MsUnlock() 
			
			Alert('Altera��o realizada com sucesso')
	  	EndIf
	Else
    	Alert("Processo Cancelado")
	EndIF	
	
	oDlgAdr:End()
Return Nil


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CEXCTETP  �Autor  �Abel Babini Filho   � Data �  22/07/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     �Recusa registro do XML selecionado / posicionado            ���
�������������������������������������������������������������������������͹��
���Uso       �Adoro S/A                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
//
User Function CEXCTERC() 
	Local _aArea	:= getArea()
	Local cCodigo	:= ""
	Local cLoja		:= ""
	Local cMotivo	:= space(100)
	Local oMotivo
	Local cMsg1		:= "Digite o motivo pelo qual o CT-e XML selecionado est� sendo recusado. Este bloqueio afeta APENAS"
	Local cMsg2		:= "o relat�rio de CT-e XML�s pendentes. (ADFIS032R.PRW) Utilize o relat�rio para listar os XML�s"
	Local cMsg3		:= "recusados."

	Private oDlg

	If Alltrim(RECNFCTE->XML_KEYF1) == ""
	
		cCodigo := Posicione("SA2",3,xFilial("SA2")+RECNFCTE->XML_EMIT,"A2_COD")
	    cLoja   := Posicione("SA2",3,xFilial("SA2")+RECNFCTE->XML_EMIT,"A2_LOJA")
		
		dbSelectArea('ZCW')
		dbSetOrder(2)
		If ! ZCW->(dbSeek(xFilial('ZCW')+RECNFCTE->XML_CHAVE))
				
			DEFINE MSDIALOG oDlg from 000,000 to 200,600 title "Motivo de Recusa do CTe XML" pixel
			@ 005,005 Say OemToAnsi("Motivo: ") PIXEL COLORS CLR_HBLUE OF oDlg 
			@ 005,050 MsGet oMotivo VAR cMotivo SIZE 200,08  PIXEL OF oDlg Valid !empty(Alltrim(cMotivo))
			@ 030,150 BUTTON "Cancela"  OF oDlg SIZE 030,015 PIXEL ACTION DlgOk(.f.)
			@ 030,200 BUTTON "Confirma" OF oDlg SIZE 030,015 PIXEL ACTION DlgOk(.t.,cMotivo,cCodigo,cLoja)
	
			@ 065,005 Say OemToAnsi(cMsg1) PIXEL COLORS CLR_HRED OF oDlg                                                  
			@ 075,005 Say OemToAnsi(cMsg2) PIXEL COLORS CLR_HRED OF oDlg                                                  
			@ 085,005 Say OemToAnsi(cMsg3) PIXEL COLORS CLR_HRED OF oDlg                                                  
			
			ACTIVATE MSDIALOG oDlg CENTER
		Else
			IF MessageBox('CTe XML j� recusado. Deseja remover a recusa?','Exclus�o Recusa CTe XML',1)=1
				dbSelectArea('ZCW')
				dbSetOrder(2)
				If ZCW->(dbSeek(xFilial('ZCW')+RECNFCTE->XML_CHAVE))
					RecLock("ZCW",.F.)
					ZCW->(dbDelete())
					ZCW->(MsUnlock())
					u_GrLogZBE (Date(),;
								TIME(),;
								cUserName,;
								"EXCLUSAO RECUSA DE XML","FISCAL","CEXMBTCTE",;
			                    "NF: "+substr(RECNFCTE->XML_NUMNF,4,9)+" Serie: " +substr(RECNFCTE->XML_NUMNF,1,3)+ " User: " +__cUserId,;
			                    ComputerName(),;
			                    LogUserName())		
				Endif			
			Else
				Alert("XML j� recusado. N�o � poss�vel continuar.")
			Endif
			
		Endif
	Else
		Alert("Nota Fiscal j� classificada. Imposs�vel bloquear!")
	Endif
	ZCW->(dbCloseArea())	
	RestArea(_aArea)
	oDlgAdr:End()
Return Nil     

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  �DlgOk          �Autor  �Abel Babini         �Data  �  22/07/2019 ���
������������������������������������������������������������������������������͹��
���Desc.     �Grava informa��es de recusa do XML na tabela ZCW                 ���
������������������������������������������������������������������������������͹��
���Uso       �Adoro S/A                                                        ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
static function DlgOk(lPar,cMotivo,cCodigo,cLoja)

	If lPar
		Reclock("ZCW",.T.)
		ZCW->ZCW_FILIAL	:= xFilial('ZCW')	
		ZCW->ZCW_DATA	:= dDatabase
		ZCW->ZCW_NFISCA	:= substr(RECNFCTE->XML_NUMNF,4,9)
		ZCW->ZCW_SERIE	:= substr(RECNFCTE->XML_NUMNF,1,3)
		ZCW->ZCW_CLIFOR	:= cCodigo
		ZCW->ZCW_LOJA	:= cLoja
		ZCW->ZCW_CHVNFE	:= RECNFCTE->XML_CHAVE
		ZCW->ZCW_OBSERV	:= Alltrim(cMotivo)
		ZCW->(MsUnlock())
		
		u_GrLogZBE (Date(),;
					TIME(),;
					cUserName,;
					"INCLUSAO RECUSA DE CTe XML","FISCAL","CEXMBTCTE",;
                    "NF: "+substr(RECNFCTE->XML_NUMNF,4,9)+" Serie: " +substr(RECNFCTE->XML_NUMNF,1,3)+" Motivo: "+ Alltrim(cMotivo) +" User: " +__cUserId,;
                    ComputerName(),;
                    LogUserName())		
	Else
		Alert('Opera��o Cancelada')
	Endif
oDlg:end()

Return

/*/{Protheus.doc} User Function CEXCTEDO
	Vincula CT-e ao Documento de Origem preenchendo o campo XIT_KEYNFO
	@type  User Function
	@author Abel Babini
	@since 07/06/2022
	@history Ticket 66275  - Abel Babini		-	07/06/2022 - Cria��o de bot�o para vincular CT-e a Documento de Origem quando CNPJ duplicado na base ou Fornecedor estrangeiro
	/*/
User Function CEXCTEDO()
	Local oDlg	:= Nil
	Local nOpt	:= 0
	Local cNFOri	:= Space(FWTamSX3("F1_DOC")[1])
	Local cSerOri	:= Space(FWTamSX3("F1_SERIE")[1])
	Local cForOri	:= Space(FWTamSX3("F1_FORNECE")[1])
	Local cLojOri	:= Space(FWTamSX3("F1_LOJA")[1])

	IF RECNFCTE->XML_TPFRET == 'C' .AND. Empty(Alltrim(RECNFCTEITENS->XIT_KEYNFO))

		oDlg := MSDialog():New (0,0, 120,300, "Amarra��o Manual Doc. de Origem" ,,, .F.,,,,,, .T.,,, .T. )

    //**********************************************
    //ESTRUTURA DA JANELA  
    //**********************************************
    oDlg:lEscClose 	:= 	.T.
    oDlg:lMaximized := 	.F. 

		@ 005,005 Say OemToAnsi("Nota") PIXEL COLORS CLR_HBLUE OF oDlg 
		@ 014,005 MSGET cNFOri				SIZE 030,008	OF oDlg PIXEL PICTURE '@!' F3 "SF1"

		@ 005,050 Say OemToAnsi("S�rie") PIXEL COLORS CLR_HBLUE OF oDlg 
		@ 014,050 MSGET cSerOri				SIZE 015,008	OF oDlg PIXEL PICTURE '@!'

		@ 005,075 Say OemToAnsi("Fornecedor") PIXEL COLORS CLR_HBLUE OF oDlg 
		@ 014,075 MSGET cForOri				SIZE 030,008	OF oDlg PIXEL PICTURE '@!'

		@ 005,110 Say OemToAnsi("Loja") PIXEL COLORS CLR_HBLUE OF oDlg 
		@ 014,110 MSGET cLojOri				SIZE 015,008	OF oDlg PIXEL PICTURE '@!'

		@ 030,050 BUTTON "Cancela"  OF oDlg SIZE 030,015 PIXEL ACTION (oDlg:End())
		@ 030,080 BUTTON "Confirma" OF oDlg SIZE 030,015 PIXEL ACTION (nOpt:=1,oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTER

		If nOpt == 1
			If Empty(Alltrim(RECNFCTEITENS->XIT_KEYNFO)) .and. Empty(Alltrim(RECNFCTE->XML_STATF1)) .and. Empty(Alltrim(RECNFCTE->XML_KEYF1))
				cQuery := "UPDATE RECNFCTEITENS SET XIT_KEYNFO = '"+cNFOri+cSerOri+cForOri+cLojOri+"N' WHERE XIT_CHAVE = '"+RECNFCTE->XML_CHAVE+"'"
				If TcSqlExec(cQuery) < 0
					MsgStop("N�o foi poss�vel atualizar o registro." + CRLF + "TCSQLError() " + TCSQLError(),"Fun��o CEXMBTCTE - 01")
					Return
				EndIf
				MsgInfo("Processo Conclu�do!","Aten��o")
			else
				MsgStop("O registro j� possui v�nculo com documento de origem ou j� foi classificado","Fun��o CEXMBTCTE - 02")
			endif
			// RecLock("RECNFCTEITENS",.F.)
			// RECNFCTEITENS->XIT_KEYNFO := cNFOri+cSerOri+cForOri+cLojOri+'N'
			// MsUnlock() 		
		Endif
	ENDIF

Return 



