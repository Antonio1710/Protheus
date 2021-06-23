#Include "Protheus.ch"
/*/{Protheus.doc} User Function ADCOM036P
    Valida o armazém selecionado. Chamado 057152.
    Utilizado em validação de usuário (campo).
    @type  Function
    @author Everson
    @since 14/04/2020
    @version 01
    /*/
User Function ADCOM036P(cCodArm)
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                           //
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    Local aArea     := GetArea()
    Local lVldArmz  := GetMv("MV_#VLARMZ",,.F.)
    Default cCodArm := ""

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Valida armazém selecionado (NNR).')
 
    //
    If !lVldArmz .Or. Empty(cCodArm)
        RestArea(aArea)
        Return .T.

    EndIf

    //
    DbSelectArea("NNR")
    NNR->(DbSetOrder(1))
    NNR->(DbGoTop())
    If ! NNR->( DbSeek( FWxFilial("NNR") + cCodArm ) )
        Aviso("Função ADCOM036P","Armazém " + cCodArm + " inválido.", {"Fechar"}, 1)
        RestArea(aArea)
        Return .F.

    Else
 
        //
        If Alltrim(cValToChar(NNR->NNR_MSBLQL)) <> "2"
            Aviso("Função ADCOM036P","Armazém " + cCodArm + " não liberado.", {"Fechar"}, 1)
            RestArea(aArea)
            Return .F.

        EndIf

    EndIf

    //
    RestArea(aArea)

Return .T.