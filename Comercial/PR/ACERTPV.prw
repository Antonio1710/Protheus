///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Função        : ACERTPV.prw                                                                              //
// Autor         : ALEX BORGES                                                                               //
// Data Criação  : 11/06/2012                                                                                //
// Descricao     : Acerta aprovadores pedidos de venda pendente - REDE                                       //
// Pré-Requisito :                                                                                           //
// --------------------------------------------------------------------                                      //
// ALTERAÇÕES EFETUADAS                                                                                      //
// Nº | Data/Hora        | Programador         | Descrição                                                   //
//    |                  |                     |                                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

#INCLUDE "PROTHEUS.CH"
#Include "RwMake.ch"
#Include "FiveWin.ch"

User Function ACERTPV()
Private _cPedido:= "      "
Private oDlg    := Nil

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Acerta aprovadores pedidos de venda pendente - REDE')

            
@0,0 TO 120,280 DIALOG oDlg TITLE "Acerta aprovadores do pedido de venda"

@10,5 SAY "Pedido de venda : "
@10,50 MSGET oPed Var _cPedido SIZE 30,10 PIXEL OF oDlg
/*
@50,5 SAY "Conteudo Atual Parametro  : "
@50,140 SAY _cParF SIZE 30,10 PIXEL OF oDlg      */                    

@ 30,10 BUTTON "&OK" SIZE 33,14 PIXEL ACTION oCons()
@ 30,50 BUTTON "&Sair" SIZE 33,14 PIXEL ACTION oDlg:End()  

ACTIVATE DIALOG oDlg CENTER

RETURN

STATIC FUNCTION oCons()
IF !MSGBOX("Tem certeza?","CONFIRMACAO","YESNO")
	return
endif

_cQuery := "UPDATE "+RetSqlName("ZZN")+ "  WITH(UPDLOCK) SET "
_cQuery += "       ZZN_APROV1 = C5_APROV1,  "
_cQuery += "       ZZN_APROV2 = C5_APROV2,  "
_cQuery += "       ZZN_APROV3 = C5_APROV3,   "
_cQuery += "       ZZN_AVALIA = '' "
_cQuery += "  FROM "+RetSqlName("ZZN")+ " ZZN, "
_cQuery += "       "+RetSqlName("SC5")+ " SC5  "
_cQuery += " WHERE C5_FILIAL = '" + xFilial("SC5") + "' "
_cQuery += "   AND C5_NUM  = '"+_cPedido+"' "
_cQuery += "   AND C5_LIBEROK = '' "
_cQuery += "   AND ZZN_FILIAL = C5_FILIAL "
_cQuery += "   AND ZZN_CHAVE  = C5_CHAVE "
_cQuery += "   AND ZZN.D_E_L_E_T_ = '' "
_cQuery += "   AND SC5.D_E_L_E_T_ = '' "

If TCSQLExec(_cQuery) != 0
	Aviso(FunDesc(),TCSQLERROR(),{"OK"})
Else
    MsgInfo("Processo Concluído!","Atenção")
EndIf


Close(oDlg)

RETURN(.T.)

