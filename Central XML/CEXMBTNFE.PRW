#Include "Totvs.ch"

/*/{Protheus.doc} User Function CEXMBTNFE
	Ponto entrada para incluir botão na Central XML  
	@type  Function
	@author Abel Babini Filho
	@since 11/02/2019
	@version version
	@history Chamado 045978 - Abel Babini Filho - 11/02/2019 - Botao que permita ao usuario marcar registros como recusados. Esta marcação terá efeito apenas no relatório de XML´s pendentes de escrituração / classificação fiscal.
	@history Chamado 058532 - Adriana Oliveira  - 15/06/2020 - Incluir botao para trocar XML de filial
	@history Chamado 058532 - Adriana Oliveira  - 18/06/2020 - Inclusao LOG ZBE ao trocar XML de filial
	/*/

User Function CEXMBTNFE()
	
	Local aRetorno	:= Array( 03 )
	//Chamado 058532 - Alterado por Adriana para incluir mais botoes em 15/06/2020
	aRetorno[1]	:= "ADORO"			//[01] - Descricao da Funcao (Sera exibida no menu lateral)
	aRetorno[2]	:= "TRMIMG32.PNG"	//[02] - Imagem (Precisa estar no repositorio)
	aRetorno[3]	:= "CEXNFEBT"	    //[03] - Funcao de Usuario (User Function)
	//Fim Chamado 058532- Alterado por Adriana em 15/06/2020

Return aRetorno                

/*/{Protheus.doc} User Function CEXNFEBT
	Cria tela com os botões customizados na Central XML - Chamado 058532
	@type  Static Function
	@author Adriana Oliveira
	@since 15/06/2020
	/*/

User Function CEXNFEBT()      

	Local oBtnCan	:= Nil
	Local oBtn01	:= Nil //Recusa XML
	Local oBtn02	:= Nil //Tranfere XML Filial

	Private oDlgAdr	:= Nil

	DEFINE MSDIALOG oDlgAdr TITLE "Customizações Adoro" FROM 000, 000  TO 165, 310 COLORS 0, 16777215 PIXEL style 128
	oDlgAdr:lEscClose     := .T. //Permite sair ao pressionar ESC
	
	@ 010, 010 SAY OemToAnsi("Selecione a opção desejada:") SIZE 150, 025 OF oDlgAdr COLORS 0, 16777215 PIXEL
	oBtn01 := TButton():New( 018, 010, "Recusa XML",oDlgAdr,{||U_CERECUSA()}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn02 := TButton():New( 018, 080, "Transfere XML Filial",oDlgAdr,{||U_CEXTRFIL()}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	DEFINE SBUTTON oBtnCan 	FROM 068, 130 TYPE 02 OF oDlgAdr ENABLE Action( oDlgAdr:End() )

	ACTIVATE MSDIALOG oDlgAdr CENTERED

Return 

/*/{Protheus.doc} User Function CERECUSA
	Recusa registro do XML selecionado / posicionado
	@type  Static Function
	@author Abel Babini
	@since 25/02/2019
	/*/

User Function CERECUSA()
	Local _aArea	:= getArea()
	Local cCodigo	:= ""
	Local cLoja		:= ""
	Local cMotivo	:= space(100)
	Local oMotivo
	Local cMsg1		:= "Digite o motivo pelo qual o XML selecionado está sendo recusado. Este bloqueio afeta APENAS"
	Local cMsg2		:= "o relatório de XML´s pendentes. (ADFIS027R.PRW) Utilize o relatório para listar os XML´s"
	Local cMsg3		:= "recusados."
	
	Private oDlg

	If Alltrim(RECNFXML->XML_KEYF1) == ""
	
		If RECNFXML->XML_CLIFOR = 'C' //nf cliente
			cCodigo := Posicione("SA1",3,xFilial("SA1")+RECNFXML->XML_EMIT,"A1_COD")
		    cLoja   := Posicione("SA1",3,xFilial("SA1")+RECNFXML->XML_EMIT,"A1_LOJA")
		Else					
			cCodigo := Posicione("SA2",3,xFilial("SA2")+RECNFXML->XML_EMIT,"A2_COD")
		    cLoja   := Posicione("SA2",3,xFilial("SA2")+RECNFXML->XML_EMIT,"A2_LOJA")
		EndIf
		
		dbSelectArea('ZCW')
		dbSetOrder(2)
		If ! ZCW->(dbSeek(xFilial('ZCW')+RECNFXML->XML_CHAVE))
				
			DEFINE MSDIALOG oDlg from 000,000 to 200,600 title "Motivo de Recusa do XML" pixel
			@ 005,005 Say OemToAnsi("Motivo: ") PIXEL COLORS CLR_HBLUE OF oDlg 
			@ 005,050 MsGet oMotivo VAR cMotivo SIZE 200,08  PIXEL OF oDlg Valid !empty(Alltrim(cMotivo))
			@ 030,150 BUTTON "Cancela"  OF oDlg SIZE 030,015 PIXEL ACTION DlgOk(.f.)
			@ 030,200 BUTTON "Confirma" OF oDlg SIZE 030,015 PIXEL ACTION DlgOk(.t.,cMotivo,cCodigo,cLoja)
	
			@ 065,005 Say OemToAnsi(cMsg1) PIXEL COLORS CLR_HRED OF oDlg                                                  
			@ 075,005 Say OemToAnsi(cMsg2) PIXEL COLORS CLR_HRED OF oDlg                                                  
			@ 085,005 Say OemToAnsi(cMsg3) PIXEL COLORS CLR_HRED OF oDlg                                                  
			
			ACTIVATE MSDIALOG oDlg CENTER
		Else
			IF MessageBox('XML já recusado. Deseja remover a recusa?','Exclusão Recusa XML',1)=1
				dbSelectArea('ZCW')
				dbSetOrder(2)
				If ZCW->(dbSeek(xFilial('ZCW')+RECNFXML->XML_CHAVE))
					RecLock("ZCW",.F.)
					ZCW->(dbDelete())
					ZCW->(MsUnlock())
					u_GrLogZBE (Date(),;
								TIME(),;
								cUserName,;
								"EXCLUSAO RECUSA DE XML","FISCAL","CEXMBTNFE",;
			                    "NF: "+substr(RECNFXML->XML_NUMNF,4,9)+" Serie: " +substr(RECNFXML->XML_NUMNF,1,3)+ " User: " +__cUserId,;
			                    ComputerName(),;
			                    LogUserName())		
				Endif			
			Else
				Alert("XML já recusado. Não é possível continuar.")
			Endif
			
		Endif
	Else
		Alert("Nota Fiscal já classificada. Impossível bloquear!")
	Endif
	ZCW->(dbCloseArea())
	RestArea(_aArea)
Return Nil

/*/{Protheus.doc} Static Function DlgOk
	Grava informações de recusa do XML na tabela ZCW
	@type  Static Function
	@author Abel Babini
	@since 25/02/2019
	/*/
	
static function DlgOk(lPar,cMotivo,cCodigo,cLoja)

	If lPar
		Reclock("ZCW",.T.)
		ZCW->ZCW_FILIAL	:= xFilial('ZCW')	
		ZCW->ZCW_DATA	:= dDatabase
		ZCW->ZCW_NFISCA	:= substr(RECNFXML->XML_NUMNF,4,9)
		ZCW->ZCW_SERIE	:= substr(RECNFXML->XML_NUMNF,1,3)
		ZCW->ZCW_CLIFOR	:= cCodigo
		ZCW->ZCW_LOJA	:= cLoja
		ZCW->ZCW_CHVNFE	:= RECNFXML->XML_CHAVE
		ZCW->ZCW_OBSERV	:= Alltrim(cMotivo)
		ZCW->(MsUnlock())
		
		u_GrLogZBE (Date(),;
					TIME(),;
					cUserName,;
					"INCLUSAO RECUSA DE XML","FISCAL","CEXMBTNFE",;
                    "NF: "+substr(RECNFXML->XML_NUMNF,4,9)+" Serie: " +substr(RECNFXML->XML_NUMNF,1,3)+" Motivo: "+ Alltrim(cMotivo) +" User: " +__cUserId,;
                    ComputerName(),;
                    LogUserName())		
	Else
		Alert('Operação Cancelada')
	Endif
oDlg:end()
Return

/*/{Protheus.doc} CEXTRFIL
	Troca destinatario do XML, para possibilitar gerar a NF na filial de entrega - Chamado 058532
	@type  Static Function
	@author Adriana Oliveira
	@since 15/06/2020
	/*/

User Function CEXTRFIL()
	
	If !Empty( RECNFXML->XML_KEYF1 )  
		Alert( "Nota Fiscal já classificada, impossível transferir XML!" )
	elseif !Alltrim(__CUSERID) $ GetMV("MV_#USUCTF")
		Alert( "Usuário sem permissão para transferir XML! Solicite autorização ao departamento Fiscal." )
	Else
		//Chamado 058532 - Alterado por Adriana para gerar log de alteracao em 18/06/2020
		u_GrLogZBE (Date(),;
			TIME(),;
			cUserName,;
			"TRANSFERENCIA XML DE FILIAL","FISCAL","CEXMBTNFE",;
			"NF: "+substr(RECNFXML->XML_NUMNF,4,9)+" Serie: " +substr(RECNFXML->XML_NUMNF,1,3)+ " User: " +__cUserId,;
			ComputerName(),;
			LogUserName())		
		U_CEXMTRDE()
	EndIf
	
Return Nil