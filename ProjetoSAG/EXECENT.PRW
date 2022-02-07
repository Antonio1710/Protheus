#Include "Protheus.ch"
#Include "ApWizard.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "TbIconn.ch"

User Function EXECAUTQEK() // U_EXECAUTQEK()

Local aCab := {}
Local nOpc := 3

Private lMsErroAuto := .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Abertura do ambiente
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ConOut(Repl("-",80))
ConOut(PadC(OemToAnsi("Teste de Inclusao QIEA200"),80))

aCab := {;
{'QEK_FILIAL', xFilial("QEK"),Nil},;
{'QEK_TIPONF',"N",Nil},;
{'QEK_FORNEC',PADR("025934",tamsx3("QEK_FORNEC")[1]),Nil},;
{'QEK_LOJFOR',PADR("01",tamsx3("QEK_LOJFOR")[1]),Nil},;
{'QEK_PRODUT',PADR("383369",tamsx3("QEK_PRODUT")[1]),Nil},;
{'QEK_DTENTR',Date(),Nil},;
{'QEK_LOTE',PADR("LT01",tamsx3("QEK_LOTE")[1]),Nil},;
{'QEK_HRENTR',"14:37",Nil},;
{'QEK_TAMLOT',"15",Nil},;
{'QEK_TAMAMO',"15",Nil},;
{'QEK_TIPDOC',"NF",Nil},;
{'QEK_TAMAMO',"15",Nil},;
{'QEK_DTNFIS',Date(),Nil},;
{'QEK_VERIFI',1,Nil}}


MSExecAuto({|x,y| QIEA200(x,y)},aCab,nOpc)

If !lMsErroAuto
Conout('Inserido/Alterado/Excluido com sucesso')
Else
Conout('Erro na Inclusão/Alteração/Exclusão')
MostraErro()
Endif

Return Nil