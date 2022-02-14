#include "TOTVS.CH"

/*/{Protheus.doc} User Function ADEEC007
    Filtro de seleção dos status dos pedidos de exportação.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 24/03/2021
    @version 01
    @history Chamado 8465 - Leonardo P. Monteiro - 15/03/2021 - Desenvolvimento da consulta para gestão das exportações.
/*/

User Function ADEEC007P()
    Local cTitulo   :="Seleção de Status"
    Local MvPar     :=""
    Local MvParDef  :=""
    Local mvTemp    := ""
    Local nTam      := 53 
    Local nX        := 0
    Local nLen      := 0
    Local cEOL      := chr(13)+chr(10)
    Local nLegenda  := 0
    Private aLegenda:={}


    mvTemp  := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
    mvRet   := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

    aAdd(aLegenda,"0 - Cancelado                                        "+cEOL)
    aAdd(aLegenda,"1 - Aguardando Solicitacao de Credito                "+cEOL)
    aAdd(aLegenda,"2 - Aguardando Liberacao de Credito                  "+cEOL)
    aAdd(aLegenda,"3 - Credito Liberado                                 "+cEOL)
    aAdd(aLegenda,"4 - Aguardando Confeccao Documentos                  "+cEOL)
    aAdd(aLegenda,"5 - Aguardando Embarque                              "+cEOL)
    aAdd(aLegenda,"6 - Embarcado                                        "+cEOL)
    aAdd(aLegenda,"G - Embarcado - Em Transito                          "+cEOL)
    aAdd(aLegenda,"H - Embarcado - Estoque em Consignacao               "+cEOL)
    aAdd(aLegenda,"7 - Lancado na Fase de Embarque                      "+cEOL)
    aAdd(aLegenda,"E - Lanc.Parcial na Fase de Embarque                 "+cEOL)
    aAdd(aLegenda,"8 - Cambio a Contratar                               "+cEOL)
    aAdd(aLegenda,"9 - Cambio Parcial                                   "+cEOL)
    aAdd(aLegenda,"A - Cambio Contratado                                "+cEOL)
    aAdd(aLegenda,"B - Aguardando Faturamento                           "+cEOL)
    aAdd(aLegenda,"C - Faturado Parcialmente                            "+cEOL)
    aAdd(aLegenda,"D - Faturado                                         "+cEOL)
    aAdd(aLegenda,"F - Pedido especial para geracao de R.V. desvinculada"+cEOL)
    aAdd(aLegenda,"I - Wash-Out In                                      "+cEOL)
    aAdd(aLegenda,"J - Wash-Out Out                                     "+cEOL)
    aAdd(aLegenda,"K - Wash-Out Nothing                                 "+cEOL)
    aAdd(aLegenda,"L - Wash-Out de RV                                   "+cEOL)
    aAdd(aLegenda,"M - Wash-Out a definir                               "+cEOL)
    nLegenda    := Len(aLegenda)
    nTam        := Len(aLegenda[01])

    for nX := 1 to nLegenda
        if left(aLegenda[nX],1)$mvTemp
            mvPar += aLegenda[nX]+","
        else
            mvPar += space(nTam)+","
        endif
    next nX

            
    IF f_Opcoes(@MvPar,cTitulo,aLegenda,MvParDef,12,49,.F., nTam, Len(aLegenda))  // Chama funcao f_Opcoes

        mvpar   := StrTran(mvpar, "*", "")
        nLen    := Len(mvpar)-1
        mvTemp  := ""
        aMvPar  := Separa(mvpar,cEOL)
        nMvPar  := Len(aMvPar)

        For nX := 1 To nMvPar
            if !Empty(aMvPar[nX])
                mvTemp += Left(aMvPar[nX],1)+","
            endif
        Next nX
        
        _nTam := LEN(mvTemp)
        mvTemp := SUBSTR(Alltrim(mvTemp),1,_nTAM-1)
        
        &MvRet := mvTemp              // Devolve Resultado

    EndIF	
    if Type("oSTATUS") == "O"
        oSTATUS:Refresh()
    endif

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Filtro de seleção dos status dos pedidos de exportação')


Return .T.
