#Include 'Protheus.ch'

/*/{Protheus.doc} User Function MNTA435I
    Rotina para gravar o custo do Salario do Funcionario da Manutenção no retorno modelo 2 mesmo o parametro de integração de estoque estiver habilitado.
    @type  Function
    @author Tiago H. Stocco - Obify
    @since 27/05/2020
    @version 01
    @history chamado: 10893 - 12/03/2021 - Leonardo P. Monteiro - Correção no error.log gerado por chave duplicada na tabela STJ.
/*/

User Function MNTA435I()
    //@history chamado: 10893 - 12/03/2021 - Leonardo P. Monteiro - Correção no error.log gerado por chave duplicada na tabela STJ.
    Local aArea     := GetArea()
    Local aAreaSTJ  := STJ->(GetArea())
    Local cPROD     := STL->TL_CODIGO
    Local cOrdem    := STL->TL_ORDEM

    WHILE STL->TL_FILIAL+STL->TL_ORDEM == xFilial("STL")+cOrdem

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

        STL->(DBSKIP())

    ENDDO

    //@history chamado: 10893 - 12/03/2021 - Leonardo P. Monteiro - Correção no error.log gerado por chave duplicada na tabela STJ.
    RestArea(aArea)
    RestArea(aAreaSTJ)
Return .T.
