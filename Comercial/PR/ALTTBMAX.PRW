///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Função        : ALTTBMAX.prw                                                                              //
// Autor         : ALEX BORGES                                                                               //
// Data Criação  : 01/03/2012                                                                                //
// Descricao     : Altera parametro MV_TBPRMX                                                                //
// Pré-Requisito :                                                                                           //
// --------------------------------------------------------------------                                      //
// ALTERAÇÕES EFETUADAS                                                                                      //
// Nº | Data/Hora        | Programador         | Descrição                                                   //
//    |                  |                     |                                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

#INCLUDE "PROTHEUS.CH"
#Include "RwMake.ch"
#Include "FiveWin.ch"

User Function ALTTBMAX()
Private _cTab   := "   "
Private oDlg    := Nil
Private _cParF  := GetMV("MV_TBPRMX")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Altera parametro MV_TBPRMX')

cAlias:=Alias()
Index :=IndexOrd()
Rec   :=Recno()
            
@0,0 TO 220,500 DIALOG oDlg TITLE "Alteração Tabela preco maximo"

@10,5 SAY "Tabela preco maximo : "
@10,80 MSGET _cTab SIZE 30,10 PIXEL OF oDlg

@50,5 SAY "Conteudo Atual Parametro  : "
@50,140 SAY _cParF SIZE 30,10 PIXEL OF oDlg                          

@ 88,100 BUTTON "&Alterar" SIZE 33,14 PIXEL ACTION oCons()
@ 88,200 BUTTON "&Sair" SIZE 33,14 PIXEL ACTION oDlg:End()  

ACTIVATE DIALOG oDlg CENTER

RETURN

STATIC FUNCTION oCons()
IF !MSGBOX("Tem certeza?","CONFIRMACAO","YESNO")
	return
endif

_nMax := _cTab  
GetMV("MV_TBPRMX")
DbSelectArea("SX6")
While !MsRlock(); End
MsRlock()
    SX6->X6_CONTEUD:=_nMax
    SX6->X6_CONTENG:=_nMax
    SX6->X6_CONTSPA:=_nMax
MsRunlock()
        
dbSelectArea(cAlias)
dbSetOrder(Index)     
dbGoto(Rec)

Close(oDlg)

RETURN(.T.)

