#INCLUDE 'PROTHEUS.CH'
/*/{Protheus.doc} nomeFunction
    Rotina para gravar o custo do Salario do Funcionario da Manutenção no retorno da OS mesmo o parametro de integração de estoque estiver habilitado.
    @type  Function
    @author Tiago H. Stocco - Obify
    @since 27/05/2020
    @version 01
    
/*/

User Function NG400INS

    Local aArea := GetArea()
    Local cPROD := STL->TL_CODIGO
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'gravar o custo do Salario do Funcionario da Manutenção')


    If STL->TL_TIPOREG == "M"

        DbSelectArea("ST1")
        DbSetOrder(1)
        DbSeek(xFilial("ST1")+cPROD)

        RecLock('STL',.F.)

            STL->TL_CUSTO  := STL->TL_QUANTID * ST1->T1_SALARIO

        MsUnLock("STL")

        DbSelectArea("SD3")
        DbSetOrder(4)//NUMSEQ

        If DbSeek(xFilial("SD3")+STL->TL_NUMSEQ)

            RecLock('SD3',.F.)

                SD3->D3_CUSTO1  := STL->TL_CUSTO
                
            MsUnLock("SD3")

        ENDIF
    EndIf
    RestArea(aArea)

RETURN