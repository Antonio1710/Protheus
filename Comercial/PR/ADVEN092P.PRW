#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOTVS.CH"

// ##############################################################################################################
// Projeto: Projeto WorkFlow
// Modulo : SIGAFAT
// Fonte  : ADVEN092P
// ---------+-------------------+-----------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                       | Chamado
// ---------+-------------------+-----------------------------------------------------------------+---------------
// 09/05/18 | Ricardo Lima      | Rotina para alterar determinados campos no pedido de venda      |
// ---------+-------------------+-----------------------------------------------------------------+---------------
// ###############################################################################################################
User Function ADVEN092P()

	Local aArea	   	:= GetArea()
	Local oTelMenu	:= Nil
	Local oDeP		:= Nil
	Local oAtP		:= Nil
	Local oDev		:= Nil
	Local oAtV		:= Nil
	Local oCanc  	:= Nil
	Local oOk		:= Nil
	Local cDeC      := SC5->C5_CONDPAG
	Local cAteC     := SC5->C5_CONDPAG
	Local cDeT      := Space(3)
	Local cAteT     := Space(3)
	Local cUserPer  := SuperGetMv( "MV_#ADVE92" , .F. , "" ,  )

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para alterar determinados campos no pedido de venda')
	
	IF !__cUserID $ cUserPer
		ApMsgInfo('Usuario sem Permissão para Alterar a Condição de Pagamento!','Altera Condição Pagamento do Pedido') 
		Return Nil
	EndIf

	IF ( EMPTY(SC5->C5_PLACA) .OR. EMPTY(SC5->C5_NOTA) )
	
		oTelMenu		   := MsDialog():Create()
		oTelMenu:cName     := "oTelMenu"
		oTelMenu:cCaption  := "Altera Condição Pagamento do Pedido"
		oTelMenu:nLeft     := 34
		oTelMenu:nTop      := 222
		oTelMenu:nWidth    := 250
		oTelMenu:nHeight   := 320
		oTelMenu:lShowHint := .F.
		oTelMenu:lCentered := .T.

		oDeP:= TGet():New(010,010,{|u|If(PCount() == 0,cDeC,cDeC := u)}  ,oTelMenu,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F. ,'SE4',"cDeC",,,,.T.,,,"Da Condição Pag.:",1)		
		oAtP:= TGet():New(010,065,{|u|If(PCount() == 0,cAteC,cAteC := u)},oTelMenu,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,'SE4',"cAteC",,,,.T.,,,"Para Condição Pag:",1)		
				
		oOk     := TButton():New(126,010,"Confirma",oTelMenu,{|| ADVE092C(cDec,cAteC,cDeT,cAteT), oTelMenu:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		oCanc   := TButton():New(126,075,"Cancelar",oTelMenu,{|| oTelMenu:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )	
		
		oTelMenu:Activate(,,,.T.,{||.T.},,{||  })
	
	ELSE
		ApMsgInfo('Pedido com Placa Informada ou Já Faturado não pode ser alterado!','Altera Condição Pagamento do Pedido') 
	EndIf
	
	
	RestArea(aArea)
		
Return Nil

// ##############################################################################################################
// Projeto: Projeto WorkFlow
// Modulo : SIGAFAT
// Fonte  : ADVE092C
// ---------+-------------------+-----------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                       | Chamado
// ---------+-------------------+-----------------------------------------------------------------+---------------
// 09/05/18 | Ricardo Lima      | Rotina para alterar determinados campos no pedido de venda      |
// ---------+-------------------+-----------------------------------------------------------------+---------------
// ###############################################################################################################
Static Function ADVE092C(cDec,cAteC,cDeT,cAteT)

	If  RecLock("SC5",.F.)
			SC5->C5_CONDPAG := cAteC
		MsUnlock()
        u_GrLogZBE( Date(),TIME(),cUserName,"ALTERACAO PEDIDO DE VENDA - C5_CONDPAG","COMERCIAL","ADVEN092P","PEDIDO: "+SC5->C5_NUM,ComputerName(),LogUserName() )
	EndIf

Return Nil