#Include "Protheus.ch"


/*/{Protheus.doc} User Function ADMNT016P
    Função para deixar alterar executante da O.S
    Chamado 18732.
    @type  Function
    @author Tiago Stocco
    @since 18/10/2021
    @version 01
/*/

User Function ADMNT016P(nRec)
Local nRegTQB := nRec
Local aRet    := {}
Local aParamBox := {} 
Private cCadastro := "Alterar Executante"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para deixar alterar executante da O.S')

dbSelectArea("TQB")
dbGoto(nRegTQB)
If !Empty(TQB->TQB_DTFECH)
    Aviso("Atencao","Nao é permitido alterar Executante de SS encerrada",{"OK"},1)
Else
    aAdd(aParamBox,{1,"Novo Exec",Space(25),"","","TQ4","",0,.T.}) 
    If ParamBox(aParamBox,"",@aRet)
        if alltrim(aRet[1]) == ""
            Aviso("Atencao","Nenhum Executante foi selecionado",{"OK"},1)   
        else
            DbSelectArea("TQ4")
            DbSetOrder(1)
            If DbSeek(xFilial("TQ4")+aRet[1])
                dbSelectArea("TQB")
                dbGoto(nRegTQB)
                Reclock("TQB",.F.)
                TQB->TQB_CDEXEC := aRet[1]
                MsUnlock()
                Aviso("Atencao","Executante alterado com sucesso!",{"OK"},1)
            Else
                Aviso("Atencao","Executante Selecionado nao existe!",{"OK"},1)   
            EndIf
        EndIf
    EndIf
EndIf
Return
