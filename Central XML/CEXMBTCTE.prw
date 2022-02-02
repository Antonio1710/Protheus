#Include "Totvs.ch"

/*/{Protheus.doc} CEXMBTCTE
@description 	Ponto de entrada na conversao do fator de CTE
@obs			Ele estando como “F” ele entra com pré nota, o campo = “C” é frete de compra.
@author 		Fabrica de Software Fabritech
@since 			02/03/2018
@version		1.0
@return			Nil
@type 			Function
/*/

//RECNFCTE->XML_TPFRET
//Ele estando como “F” ele entra com pré nota, o campo = “C” é frete de compra.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CEXMBTCTE ºAutor  ³Abel Babini Filho   º Data ³  22/07/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Acrescenta botoes na Central XML CT-e                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ºChamado   ³                                                            º±±
±±ºn.049468  ³ Recusa Adoro CT-e - Abel Babini - 22/07/2019               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CEXMBTCTE()
	
	Local aRetorno	:= Array( 03 )

	aRetorno[1]	:= "ADORO"		//[01] - Descrição da Função (Será exibida no menu lateral)
	aRetorno[2]	:= "TRMIMG32.PNG"	//[02] - Imagem (Precisa estar no repositorio)
	aRetorno[3]	:= "CEXCTEBT"		//[03] - Função de Usuário (User Function)
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CENTRALXML- P.E para acrescenta botoes na Central XML CT-e ')
	
	
Return aRetorno
                    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CEXCTEBT  ºAutor  ³Abel Babini Filho   º Data ³  22/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria tela com os botões customizados na Central XML CT-e    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//
User Function CEXCTEBT()      

	Local oBtnCan	:= Nil
	Local oBtn01	:= Nil //Altera Tipo CTe
	Local oBtn02	:= Nil //Recusa ADORO CT-e
	Local oBtn03	:= Nil //Relatório CT-e Pendente

	Private oDlgAdr	:= Nil

	DEFINE MSDIALOG oDlgAdr TITLE "Customizações da Ad'oro" FROM 000, 000  TO 165, 310 COLORS 0, 16777215 PIXEL style 128
	oDlgAdr:lEscClose     := .T. //Permite sair ao se pressionar a tecla ESC.
	
	@ 010, 010 SAY OemToAnsi("Selecione a opção desejada:") SIZE 150, 025 OF oDlgAdr COLORS 0, 16777215 PIXEL
	oBtn01 := TButton():New( 018, 010, "Alterar Tipo CT-e",oDlgAdr,{||U_CEXCTETP()}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn02 := TButton():New( 018, 080, "Recusa Ad´oro CT-e",oDlgAdr,{||U_CEXCTERC()}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn03 := TButton():New( 042, 080, "Relatório CT-e Pend.",oDlgAdr,{||U_ADFIS033R()}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	DEFINE SBUTTON oBtnCan 	FROM 068, 130 TYPE 02 OF oDlgAdr ENABLE Action( oDlgAdr:End() )
	

	ACTIVATE MSDIALOG oDlgAdr CENTERED
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CEXCTETP  ºAutor  ³Abel Babini Filho   º Data ³  22/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera o tipo do CTE. F=Pre-nota, C=Frete Compra            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//
User Function CEXCTETP()      

	IF MSGNOYES("Deseja Alterar o Tipo de CTE ?")
                                          
		If RECNFCTE->XML_TPFRET = "F" // cte para gerar Pre nota                                
	
			RecLock("RECNFCTE",.F.)
			RECNFCTE->XML_TPFRET := "C"
			MsUnlock() 
		
			Alert('Alteração realizada com sucesso')
		
		ElseIf RECNFCTE->XML_TPFRET = "C" // cte para gerar Pre nota                                
	
			RecLock("RECNFCTE",.F.)
			RECNFCTE->XML_TPFRET := "F"
			MsUnlock() 
			
			Alert('Alteração realizada com sucesso')
	  	EndIf
	Else
    	Alert("Processo Cancelado")
	EndIF	
	
	oDlgAdr:End()
Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CEXCTETP  ºAutor  ³Abel Babini Filho   º Data ³  22/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recusa registro do XML selecionado / posicionado            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro S/A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//
User Function CEXCTERC() 
	Local _aArea	:= getArea()
	Local cCodigo	:= ""
	Local cLoja		:= ""
	Local cMotivo	:= space(100)
	Local oMotivo
	Local cMsg1		:= "Digite o motivo pelo qual o CT-e XML selecionado está sendo recusado. Este bloqueio afeta APENAS"
	Local cMsg2		:= "o relatório de CT-e XML´s pendentes. (ADFIS032R.PRW) Utilize o relatório para listar os XML´s"
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
			IF MessageBox('CTe XML já recusado. Deseja remover a recusa?','Exclusão Recusa CTe XML',1)=1
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
				Alert("XML já recusado. Não é possível continuar.")
			Endif
			
		Endif
	Else
		Alert("Nota Fiscal já classificada. Impossível bloquear!")
	Endif
	ZCW->(dbCloseArea())	
	RestArea(_aArea)
	oDlgAdr:End()
Return Nil     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DlgOk          ºAutor  ³Abel Babini         ºData  ³  22/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava informações de recusa do XML na tabela ZCW                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro S/A                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
		Alert('Operação Cancelada')
	Endif
oDlg:end()

Return