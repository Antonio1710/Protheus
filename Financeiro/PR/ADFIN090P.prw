#include "protheus.ch"
#include "topconn.ch"
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Painel Gerencial WS - Pedidos de Vendas com Adiantamentos"

/*/{Protheus.doc} User Function ADFIN090P
    Painel Gerencial em MVC - Bradesco WS
    @type  Function
    @author FWNM
    @since 29/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 059415 || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
    @history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO
    @history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Ajuste da legenda
    @history ticket 728 - Everson - 01/09/2020 - Tratamento para error log ao visualizar o pedido de venda.
    @history ticket 745 - FWNM - 17/09/2020 - Implementação título PR
    @history ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
    @history ticket 745 - FWNM - 06/10/2020 - TI
    @history ticket 7709 - LEONARDO P. MONTEIRO - 11/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
    @history ticket 71027 - Fernando Macieira    - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
/*/
User Function ADFIN090P(cNumPV)

    Local aArea       := GetArea()
    
    Local cFunBkp     := FunName()
    
    Local aBrowse     := {}
    Local aIndex      := {}
    //Local aStrut      := {}
    //Local aSeek       := {}

    Private oTempTable
    //ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
    //Private bMark           := {|| fMark() }
    //Private bLDblClick      := {|| fLDblCk() }
    //Private bHeaderClick    := {|| fHeaClk() }
    Private oBrowse

    Default cNumPV := ""

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),cTitulo)

    If Select("TABTMP") > 0
        TABTMP->( dbCloseArea() )
    EndIf
	
    //LPM - 08/01/2021 - Função para criação da estrutura.
    fMkStru()

    // Populando Tabela Temporária
    PopulaTMP(cNumPV)

    //LPM - 08/01/2021 - Função para popular a array de campos do markbrowser.
    aBrowse := fCmpBrw()

    SetFunName("ADFIN090P")
     
    aAdd(aIndex, "A1_NREDUZ" )
     
    //Criando o browse da temporária
    oBrowse := FWMarkBrowse():New()
    //oBrowse := FWMBrowse():New()
    //oBrowse:AddMarkColumns(bMark, bLDblClick, bHeaderClick)
    oBrowse:SetAlias("TABTMP")
    //oBrowse:SetQueryIndex(aIndex)
    oBrowse:SetTemporary(.T.)
    oBrowse:SetFields(aBrowse)
    //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
    oBrowse:SetFieldMark( 'TMP_OK' )
    //oBrowse:DisableDetails()
    oBrowse:SetDescription(cTitulo)

	// Definição da legenda 
    /*
    São possíveis os seguintes valores:
    GREEN – Para a cor Verde
    RED – Para a cor Vermelha
    YELLOW – Para a cor Amarela
    ORANGE – Para a cor Laranja
    BLUE – Para a cor Azul
    GRAY – Para a cor Cinza
    BROWN – Para a cor Marrom
    BLACK – Para a cor Preta
    PINK – Para a cor Rosa
    WHITE – Para a cor Branca
    */

    //@history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Ajuste da legenda
	//oBrowse:AddLegend( "AllTrim(C5_XWSPAGO)=='M' .and. Empty(C5_NOTA) .and. Empty(DEL_PV)"                                                                 , "GRAY"    , "PV Liberado MANUALMENTE para geração NF (sem gerar RA)" ) // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
	oBrowse:AddLegend(  "!Empty(AllTrim(C5_XWSPAGO)) .and. Empty(C5_NOTA) .and. Empty(DEL_PV)",; 
                        "GREEN",; 
                        "PV Liberado para geração NF (S = gerou RA no retorno do CNAB / M = Manual e não gerou RA)" )

	oBrowse:AddLegend(  "!Empty(AllTrim(C5_XWSPAGO)) .and. !Empty(C5_NOTA) .and. Empty(DEL_PV)",; 
                        "BLUE",; 
                        "Boleto/Depósito Recebido e PV Faturado" )

	oBrowse:AddLegend(  "Empty(AllTrim(C5_XWSPAGO)) .and. Empty(C5_NOTA) .and. Empty(DEL_PV) .and. Empty(E1_NUM) .and. AllTrim(F4_DUPLIC)<>'N'",;
                        "BLACK",;
                        "Boleto/Depósito não realizado" )

	oBrowse:AddLegend(  "!Empty(E1_NUM) .and. !Empty(AllTrim(E1_XWSBRAC)) .and. AllTrim(E1_XWSBRAC)<>'0' .and. AllTrim(E1_XWSBRAC)<>'69' .and. Empty(DEL_PV)",;
                        "YELLOW",;
                        "Boleto não registrado" )

	oBrowse:AddLegend(  "AllTrim(C5_BLQ)=='1' .and. Empty(DEL_PV)",;
                        "ORANGE",;
                        "Bloqueio Comercial" )

	oBrowse:AddLegend(  "!Empty(E1_NUM) .and. Empty(C5_XWSBOLG) .and. (AllTrim(E1_XWSBRAC)=='0' .or. AllTrim(E1_XWSBRAC)=='69') .and. Empty(DEL_PV)",;
                        "WHITE",;
                        "Boleto registrado e não enviado ao cliente/vendedor" )

	//oBrowse:AddLegend(  "Empty(E1_NUM) .and. (AllTrim(DEL_PV)<>'*' .and. AllTrim(DEL_RA)<>'*' .and. AllTrim(DEL_A1)<>'*')",; // @history ticket 71027 - Fernando Macieira    - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
    oBrowse:AddLegend(  "AllTrim(F4_DUPLIC)=='N'",;
                        "PINK",;
                        "PV com TES que não gera financeiro" )

	oBrowse:AddLegend(  "AllTrim(DEL_PV)=='*' ",;
                        "RED",;
                        "PV/RA/A1 Deletado" )
    
	
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    
    RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function Static Function fCmpBrw.
    Função responsável em popular a array de campos do browser.
    @type  Function
    @author Leonardo P. Monteiro
    @since 08/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fCmpBrw()

    Local aBrowse := {}
    
    //Definindo as colunas que serão usadas no browse
    aAdd(aBrowse, {"PV Del"         ,  "DEL_PV"      , "C"                    , 1                      , 0, "@!"})
    aAdd(aBrowse, {"PV Filial"      ,  "C5_FILIAL"   , TamSX3("C5_FILIAL")[3] , TamSX3("C5_FILIAL")[1] , 0, "@!"})
    aAdd(aBrowse, {"Pedido"         ,  "C5_NUM"      , TamSX3("C5_NUM")[3]    , TamSX3("C5_NUM")[1]    , 0, "@!"})
    aAdd(aBrowse, {"Valor NF"       ,  "C5_VALORNF"  , TamSX3("C5_VALORNF")[3], TamSX3("C5_VALORNF")[1], TamSX3("C5_VALORNF")[2], "@E 999,999,999.99"})
    aAdd(aBrowse, {"Cliente"        ,  "C5_CLIENTE"  , TamSX3("A1_NREDUZ")[3] , TamSX3("C5_CLIENTE")[1], 0, "@!"})
    aAdd(aBrowse, {"Loja"           ,  "C5_LOJAENT"  , TamSX3("C5_LOJAENT")[3], TamSX3("C5_LOJAENT")[1], 0, "@!"})
    aAdd(aBrowse, {"Cond Pagto"     ,  "C5_CONDPAG"  , TamSX3("C5_CONDPAG")[3], TamSX3("C5_LOJAENT")[1], 0, "@!"})
    aAdd(aBrowse, {"PV Bloq?"       ,  "C5_BLQ"      , TamSX3("C5_BLQ")[3]    , TamSX3("C5_BLQ")[1]    , 0, "@!"})
    aAdd(aBrowse, {"Boleto?"        ,  "C5_XWSBOLG"  , TamSX3("C5_XWSBOLG")[3], TamSX3("C5_XWSBOLG")[1], 0, "@!"})
    aAdd(aBrowse, {"Recebido?"      ,  "C5_XWSPAGO"  , TamSX3("C5_XWSPAGO")[3], TamSX3("C5_XWSPAGO")[1], 0, "@!"})
    aAdd(aBrowse, {"Dt Entrega"     ,  "C5_DTENTR"   , TamSX3("C5_DTENTR")[3] , TamSX3("C5_DTENTR")[1] , 0, "@D"})
    aAdd(aBrowse, {"Vendedor"       ,  "C5_VEND1"    , TamSX3("C5_VEND1")[3]  , TamSX3("C5_VEND1")[1]  , 0, "@!"})
    aAdd(aBrowse, {"Supervisor"     ,  "A3_SUPER"    , TamSX3("A3_SUPER")[3]  , TamSX3("A3_SUPER")[1]  , 0, "@!"})
    aAdd(aBrowse, {"Nome Vendedor"  ,  "A3_NOME"     , TamSX3("A3_NOME")[3]   , TamSX3("A3_NOME")[1]   , 0, "@!"})
    aAdd(aBrowse, {"Email Vendedor" ,  "A3_EMAIL"    , TamSX3("A3_EMAIL")[3]  , TamSX3("A3_EMAIL")[1]  , 0, "@!"})
    aAdd(aBrowse, {"Nota Fiscal"    ,  "C5_NOTA"     , TamSX3("C5_NOTA")[3]   , TamSX3("C5_NOTA")[1]   , 0, "@!"})
    
    aAdd(aBrowse, {"Tit Del"        ,  "DEL_RA"      , "C"                    , 1                      , 0, "@!"})
    aAdd(aBrowse, {"Tipo Tit"       ,  "E1_TIPO"     , TamSX3("E1_TIPO")[3]   , TamSX3("E1_TIPO")[1]   , 0, "@!"})
    aAdd(aBrowse, {"Titulo"         ,  "E1_NUM"      , TamSX3("E1_NUM")[3]    , TamSX3("E1_NUM")[1]    , 0, "@!"})
    aAdd(aBrowse, {"Portador"       ,  "E1_PORTADO"  , TamSX3("E1_PORTADO")[3], TamSX3("E1_PORTADO")[1], 0, "@!"})
    aAdd(aBrowse, {"Valor Titulo"   ,  "E1_VALOR"    , TamSX3("E1_VALOR")[3]  , TamSX3("E1_VALOR")[1]  , TamSX3("E1_VALOR")[1], "@E 999,999,999.99"})
    aAdd(aBrowse, {"Saldo Titulo"   ,  "E1_SALDO"    , TamSX3("E1_SALDO")[3]  , TamSX3("E1_SALDO")[1]  , TamSX3("E1_SALDO")[1], "@E 999,999,999.99"})
    aAdd(aBrowse, {"Dt Dispo"       ,  "E5_DTDISPO"  , TamSX3("E5_DTDISPO")[3], TamSX3("E5_DTDISPO")[1], 0, "@D"})
    aAdd(aBrowse, {"Cod Regist Bol" ,  "E1_XWSBRAC"  , TamSX3("E1_XWSBRAC")[3], TamSX3("E1_XWSBRAC")[1], 0, "@!"})
    aAdd(aBrowse, {"Registro Boleto",  "E1_XWSBRAD"  , TamSX3("E1_XWSBRAD")[3], TamSX3("E1_XWSBRAD")[1], 0, "@!"})

    aAdd(aBrowse, {"Cli Del"        ,  "DEL_A1"      , "C"                    , 1                      , 0, "@!"})
    aAdd(aBrowse, {"Razao Social"   ,  "A1_NOME"     , TamSX3("A1_NOME")[3]   , TamSX3("A1_NOME")[1]   , 0, "@!"})
    aAdd(aBrowse, {"Fantasia"       ,  "A1_NREDUZ"   , TamSX3("A1_NREDUZ")[3] , TamSX3("A1_NREDUZ")[1] , 0, "@!"})
    aAdd(aBrowse, {"Cli Banco"      ,  "A1_BCO1"     , TamSX3("A1_BCO1")[3]   , TamSX3("A1_BCO1")[1]   , 0, "@!"})
    aAdd(aBrowse, {"Cli Cond"       ,  "A1_COND"     , TamSX3("A1_COND")[3]   , TamSX3("A1_COND")[1]   , 0, "@!"})
    aAdd(aBrowse, {"Atividade 1"    ,  "A1_SATIV1"   , TamSX3("A1_SATIV1")[3] , TamSX3("A1_SATIV1")[1] , 0, "@!"})
    aAdd(aBrowse, {"Desc Ativid 1"  ,  "X5DESCRI_S"  , "C"                    , 55                     , 0, "@!"})
    aAdd(aBrowse, {"Atividade 2"    ,  "A1_SATIV2"   , TamSX3("A1_SATIV2")[3] , TamSX3("A1_SATIV2")[1] , 0, "@!"})
    aAdd(aBrowse, {"Desc Ativid 2"  ,  "X5DESCRI_T"  , "C"                    , 55                     , 0, "@!"})
    aAdd(aBrowse, {"Rede"           ,  "A1_REDE"     , TamSX3("A1_REDE")[3]   , TamSX3("A1_REDE")[1]   , 0, "@!"})
    aAdd(aBrowse, {"Email Cliente"  ,  "A1_EMAIL"    , TamSX3("A1_EMAIL")[3]  , TamSX3("A1_EMAIL")[1]  , 0, "@!"})

    aAdd(aBrowse, {"TES Gera Financeiro"  ,  "F4_DUPLIC"    , TamSX3("F4_DUPLIC")[3]  , TamSX3("F4_DUPLIC")[1]  , 0, "@!"}) // @history ticket 71027 - Fernando Macieira    - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem

return aBrowse

/*/{Protheus.doc} Static Function Static Function fMkStru.
    Função responsável pela criação da estrutura da tabela temporária.
    @type  Function
    @author Leonardo P. Monteiro
    @since 08/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fMkStru()

    Local aStrut    := {}
    
    // https://tdn.totvs.com.br/display/framework/FWTemporaryTable
	oTempTable := FWTemporaryTable():New("TABTMP")
	
    //Criando a estrutura que terá na tabela
    aAdd( aStrut, {"TMP_OK"    , "C", 02, 0} )
	aAdd( aStrut, {'DEL_PV'     ,"C"     ,1     , 0} )
	aAdd( aStrut, {'C5_FILIAL'  ,TamSX3("C5_FILIAL")[3]  ,TamSX3("C5_FILIAL")[1]  , 0} )
	aAdd( aStrut, {'C5_NUM'     ,TamSX3("C5_NUM")[3]     ,TamSX3("C5_NUM")[1]     , 0} )
	aAdd( aStrut, {'C5_VALORNF' ,TamSX3("C5_VALORNF")[3] ,TamSX3("C5_VALORNF")[1] , TamSX3("C5_VALORNF")[2]} )
	aAdd( aStrut, {'C5_CLIENTE' ,TamSX3("C5_CLIENTE")[3] ,TamSX3("C5_CLIENTE")[1] , 0} )
	aAdd( aStrut, {'C5_LOJAENT' ,TamSX3("C5_LOJAENT")[3] ,TamSX3("C5_LOJAENT")[1] , 0} )
	aAdd( aStrut, {'C5_CONDPAG' ,TamSX3("C5_CONDPAG")[3] ,TamSX3("C5_CONDPAG")[1] , 0} )
	aAdd( aStrut, {'C5_BLQ'     ,TamSX3("C5_BLQ")[3]     ,TamSX3("C5_BLQ")[1]     , 0} )
    aAdd( aStrut, {'C5_XWSBOLG' ,TamSX3("C5_XWSBOLG")[3] ,TamSX3("C5_XWSBOLG")[1] , 0} )
	aAdd( aStrut, {'C5_XWSPAGO' ,TamSX3("C5_XWSPAGO")[3] ,TamSX3("C5_XWSPAGO")[1] , 0} )
	aAdd( aStrut, {'C5_DTENTR'  ,TamSX3("C5_DTENTR")[3]  ,TamSX3("C5_DTENTR")[1]  , 0} )
	aAdd( aStrut, {'C5_VEND1'   ,TamSX3("C5_VEND1")[3]   ,TamSX3("C5_VEND1")[1]   , 0} )
	aAdd( aStrut, {'A3_SUPER'   ,TamSX3("A3_SUPER")[3]   ,TamSX3("A3_SUPER")[1]   , 0} )
	aAdd( aStrut, {'A3_NOME'    ,TamSX3("A3_NOME")[3]    ,TamSX3("A3_NOME")[1]    , 0} )
	aAdd( aStrut, {'A3_EMAIL'   ,TamSX3("A3_EMAIL")[3]   ,TamSX3("A3_EMAIL")[1]   , 0} )
	aAdd( aStrut, {'C5_NOTA'    ,TamSX3("C5_NOTA")[3]    ,TamSX3("C5_NOTA")[1]    , 0} )

	aAdd( aStrut, {'DEL_RA'     ,"C"     ,1     , 0} )
	aAdd( aStrut, {'E1_TIPO'    ,TamSX3("E1_TIPO")[3]    ,TamSX3("E1_TIPO")[1]    , 0} )
	aAdd( aStrut, {'E1_NUM'     ,TamSX3("E1_NUM")[3]     ,TamSX3("E1_NUM")[1]     , 0} )
	aAdd( aStrut, {'E1_PORTADO' ,TamSX3("E1_PORTADO")[3] ,TamSX3("E1_PORTADO")[1] , 0} )
	aAdd( aStrut, {'E1_VALOR'   ,TamSX3("E1_VALOR")[3]   ,TamSX3("E1_VALOR")[1]   , TamSX3("E1_VALOR")[2]} )
	aAdd( aStrut, {'E1_SALDO'   ,TamSX3("E1_SALDO")[3]   ,TamSX3("E1_SALDO")[1]   , TamSX3("E1_SALDO")[2]} )
	aAdd( aStrut, {'E5_DTDISPO' ,TamSX3("E5_DTDISPO")[3] ,TamSX3("E5_DTDISPO")[1] , 0} )
	aAdd( aStrut, {'E1_XWSBRAC' ,TamSX3("E1_XWSBRAC")[3] ,TamSX3("E1_XWSBRAC")[1] , 0} )
	aAdd( aStrut, {'E1_XWSBRAD' ,TamSX3("E1_XWSBRAD")[3] ,TamSX3("E1_XWSBRAD")[1] , 0} )

	aAdd( aStrut, {'DEL_A1'     ,"C"     ,1     , 0} )
	aAdd( aStrut, {'A1_NOME'    ,TamSX3("A1_NOME")[3]    ,TamSX3("A1_REDE")[1]    , 0} )
    aAdd( aStrut, {'A1_NREDUZ'  ,TamSX3("A1_NREDUZ")[3]  ,TamSX3("A1_NREDUZ")[1]  , 0} )
    aAdd( aStrut, {'A1_BCO1'    ,TamSX3("A1_BCO1")[3]    ,TamSX3("A1_BCO1")[1]    , 0} )
    aAdd( aStrut, {'A1_COND'    ,TamSX3("A1_COND")[3]    ,TamSX3("A1_COND")[1]    , 0} )
    aAdd( aStrut, {'A1_SATIV1'  ,TamSX3("A1_SATIV1")[3]  ,TamSX3("A1_SATIV1")[1]  , 0} )
    aAdd( aStrut, {'X5DESCRI_S' ,"C"                     ,55   , 0} )
    aAdd( aStrut, {'A1_SATIV2'  ,TamSX3("A1_SATIV2")[3]  ,TamSX3("A1_SATIV2")[1]  , 0} )
    aAdd( aStrut, {'X5DESCRI_T' ,"C"                     ,55   , 0} )
	aAdd( aStrut, {'A1_REDE'    ,TamSX3("A1_REDE")[3]    ,TamSX3("A1_REDE")[1]    , 0} )
	aAdd( aStrut, {'A1_EMAIL'   ,TamSX3("A1_EMAIL")[3]   ,TamSX3("A1_EMAIL")[1]   , 0} )

    aAdd( aStrut, {'F4_DUPLIC'  ,TamSX3("F4_DUPLIC")[3]  ,TamSX3("F4_DUPLIC")[1]   , 0} ) // history ticket 71027 - Fernando Macieira    - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem

	oTempTable:SetFields(aStrut)
	oTempTable:AddIndex("01", {"A1_NREDUZ","C5_XWSPAGO"} )
	oTempTable:Create()

return

/*/{Protheus.doc} Static Function fMark
    Função responsável pela validação do campo markbrowser.
    @type  Function
    @author Leonardo P. Monteiro
    @since 08/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fMark()

    Local lRet := .T.
    
    lRet := fVldChk()
    
return lRet

Static Function fVldChk()

    Local lRet := .T.
    
    if Empty(AllTrim(TABTMP->C5_XWSPAGO)) .and. Empty(TABTMP->C5_NOTA) .and. Empty(TABTMP->DEL_PV) .and. Empty(AllTrim(TABTMP->C5_BLQ)) .and. !Empty(TABTMP->E1_NUM)
        lRet := .T.
    else
        lRet := .F.
    endif

return lRet

/*/{Protheus.doc} Static Function fLDblCk
    Função responsável pelo tratamento do doubleclick no campo markbrowser.
    @type  Function
    @author Leonardo P. Monteiro
    @since 08/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fLDblCk()

    Local lRet := .T.
    
    lRet := fVldChk()
    
return lRet

/*/{Protheus.doc} Static Function fHeaClk
    Função responsável pelo tratamento do click no Header do campo markbrowser.
    @type  Function
    @author Leonardo P. Monteiro
    @since 08/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fHeaClk()

    Local lRet := .T.

    oBrowse:AllMark()
    //lRet := fVldChk()
    
return lRet

/*/{Protheus.doc} Static Function MENUDEF
    Criação do menu MVC
    @type  Function
    @author FWNM
    @since 29/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MenuDef()

    Local aRot := {}
     
    //Adicionando opções
    //ADD OPTION aRot TITLE 'Confirma Pagto PV depósito' ACTION 'u_AdPgtoWS()'      OPERATION MODEL_OPERATION_VIEW   ACCESS 7 //OPERATION 1 ticket 745 - FWNM - 17/09/2020 - Implementação título PR
    ADD OPTION aRot TITLE 'Libera PV Manual'           ACTION 'u_AdPgtoWS()'        OPERATION MODEL_OPERATION_UPDATE   ACCESS 4 //OPERATION 1 ticket 745 - FWNM - 17/09/2020 - Implementação título PR
    ADD OPTION aRot TITLE 'Imprime Boleto em PDF'      ACTION 'u_AdRunHCRFB()'    OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Registra Boleto'            ACTION 'u_AdBolBrad()'     OPERATION MODEL_OPERATION_VIEW   ACCESS 1 //OPERATION 1
    ADD OPTION aRot TITLE 'Posicao Titulo Receber'     ACTION 'u_AdFinc040()'     OPERATION MODEL_OPERATION_VIEW   ACCESS 2 //OPERATION 1
    ADD OPTION aRot TITLE 'Posicao Cliente'            ACTION 'u_AdFinc010()'     OPERATION MODEL_OPERATION_VIEW   ACCESS 3 //OPERATION 1
    ADD OPTION aRot TITLE 'Desvincular PV x PR/RA'     ACTION 'u_AdExcRAPV()'     OPERATION MODEL_OPERATION_VIEW   ACCESS 4 //OPERATION 1
    ADD OPTION aRot TITLE 'Visualiza PV'               ACTION 'u_AdA410Visual()'  OPERATION MODEL_OPERATION_VIEW   ACCESS 5 //OPERATION 1
    ADD OPTION aRot TITLE 'Visualiza NF'               ACTION 'u_AdMc090Visual()' OPERATION MODEL_OPERATION_VIEW   ACCESS 6 //OPERATION 1

    /*
    ADD OPTION aRot TITLE 'Visualizar'                 ACTION 'VIEWDEF.ADFIN090P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ADFIN090P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ADFIN090P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ADFIN090P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    */
 
Return aRot
 
/*/{Protheus.doc} Static Function MODELDEF
    Criação do modelo de dados MVC
    @type  Function
    @author FWNM
    @since 29/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStTMP := FWFormModelStruct():New()
     
    oStTMP:AddTable(TABTMP, {'DEL_PV', 'C5_FILIAL', 'C5_NUM', 'C5_VALORNF', 'C5_CLIENTE', 'C5_LOJAENT', 'C5_CONDPAG', 'C5_BLQ', 'C5_XWSBOLG', 'C5_XWSPAGO', 'C5_DTENTR', 'C5_VEND1', 'A3_SUPER', 'A3_NOME', 'A3_EMAIL', 'C5_NOTA', 'DEL_RA', 'E1_TIPO', 'E1_NUM', 'E1_PORTADO', 'E1_VALOR', 'E1_SALDO', 'E5_DTDISPO', 'E1_XWSBRAC', 'E1_XWSBRAD', 'DEL_A1', 'A1_NOME', 'A1_NREDUZ', 'A1_BCO1', 'A1_COND', 'A1_SATIV1', 'X5DESCRI_S', 'A1_SATIV2', 'X5DESCRI_T', 'A1_REDE', 'A1_EMAIL', 'F4_DUPLIC'}, cTitulo)
     
    //Adiciona os campos da estrutura
    oStTmp:AddField(;
        "PV Del",;                                                                                  // [01]  C   Titulo do campo
        "PV Del",;                                                                                  // [02]  C   ToolTip do campo
        "DEL_PV",;                                                                                  // [03]  C   Id do Field
        "C",;                                                                       // [04]  C   Tipo do campo
        1,;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->DEL_PV,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Filial PV",;                                                                                  // [01]  C   Titulo do campo
        "Filial PV",;                                                                                  // [02]  C   ToolTip do campo
        "C5_FILIAL",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_FILIAL")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_FILIAL")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_FILIAL,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Pedido",;                                                                                  // [01]  C   Titulo do campo
        "Pedido",;                                                                                  // [02]  C   ToolTip do campo
        "C5_NUM",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_NUM")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_NUM")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_NUM,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Valor NF",;                                                                                  // [01]  C   Titulo do campo
        "Valor NF",;                                                                                  // [02]  C   ToolTip do campo
        "C5_VALORNF",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_VALORNF")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_VALORNF")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("C5_VALORNF")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_VALORNF,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Cliente",;                                                                                  // [01]  C   Titulo do campo
        "Cliente",;                                                                                  // [02]  C   ToolTip do campo
        "C5_CLIENTE",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_CLIENTE")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_CLIENTE")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_CLIENTE,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Loja",;                                                                                  // [01]  C   Titulo do campo
        "Loja",;                                                                                  // [02]  C   ToolTip do campo
        "C5_LOJAENT",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_LOJAENT")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_LOJAENT")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_LOJAENT,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Cond Pag",;                                                                                  // [01]  C   Titulo do campo
        "Cond Pag",;                                                                                  // [02]  C   ToolTip do campo
        "C5_CONDPAG",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_CONDPAG")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_CONDPAG")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_CONDPAG,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "PV Bloq?",;                                                                                  // [01]  C   Titulo do campo
        "PV Bloq?",;                                                                                  // [02]  C   ToolTip do campo
        "C5_BLQ",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_BLQ")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_BLQ")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_BLQ,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Boleto?",;                                                                                  // [01]  C   Titulo do campo
        "Boleto?",;                                                                                  // [02]  C   ToolTip do campo
        "C5_XWSBOLG",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_XWSBOLG")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_XWSBOLG")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_XWSBOLG,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Recebido?",;                                                                                  // [01]  C   Titulo do campo
        "Recebido?",;                                                                                  // [02]  C   ToolTip do campo
        "C5_XWSPAGO",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_XWSPAGO")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_XWSPAGO")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_XWSPAGO,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Dt Entrega",;                                                                                    // [01]  C   Titulo do campo
        "Dt Entrega",;                                                                                    // [02]  C   ToolTip do campo
        "C5_DTENTR",;                                                                                 // [03]  C   Id do Field
        TamSX3("C5_DTENTR")[3],;                                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_DTENTR")[1],;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_DTENTR,'')" ),;         // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Vendedor",;                                                                                  // [01]  C   Titulo do campo
        "Vendedor",;                                                                                  // [02]  C   ToolTip do campo
        "C5_VEND1",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_VEND1")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_VEND1")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("C5_VEND1")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_VEND1,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Supervisor",;                                                                                  // [01]  C   Titulo do campo
        "Supervisor",;                                                                                  // [02]  C   ToolTip do campo
        "A3_SUPER",;                                                                                  // [03]  C   Id do Field
        TamSX3("A3_SUPER")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("A3_SUPER")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("A3_SUPER")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A3_SUPER,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Nome Vendedor",;                                                                                  // [01]  C   Titulo do campo
        "Nome Vendedor",;                                                                                  // [02]  C   ToolTip do campo
        "A3_NOME",;                                                                                  // [03]  C   Id do Field
        TamSX3("A3_NOME")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("A3_NOME")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("A3_NOME")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A3_NOME,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Email Vendedor",;                                                                                  // [01]  C   Titulo do campo
        "Email Vendedor",;                                                                                  // [02]  C   ToolTip do campo
        "A3_EMAIL",;                                                                                  // [03]  C   Id do Field
        TamSX3("A3_EMAIL")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("A3_EMAIL")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("A3_EMAIL")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A3_EMAIL,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

   oStTmp:AddField(;
        "NF",;                                                                                  // [01]  C   Titulo do campo
        "NF",;                                                                                  // [02]  C   ToolTip do campo
        "C5_NOTA",;                                                                                  // [03]  C   Id do Field
        TamSX3("C5_NOTA")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("C5_NOTA")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->C5_NOTA,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Titulo Del",;                                                                                  // [01]  C   Titulo do campo
        "Titulo Del",;                                                                                  // [02]  C   ToolTip do campo
        "DEL_RA",;                                                                                  // [03]  C   Id do Field
        "C",;                                                                       // [04]  C   Tipo do campo
        1,;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->DEL_RA,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Tipo Titulo",;                                                                                  // [01]  C   Titulo do campo
        "Tipo Titulo",;                                                                                  // [02]  C   ToolTip do campo
        "E1_TIPO",;                                                                                  // [03]  C   Id do Field
        TamSX3("E1_TIPO")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("E1_TIPO")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("E1_TIPO")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->E1_TIPO,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Titulo",;                                                                                  // [01]  C   Titulo do campo
        "Titulo",;                                                                                  // [02]  C   ToolTip do campo
        "E1_NUM",;                                                                                  // [03]  C   Id do Field
        TamSX3("E1_NUM")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("E1_NUM")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->E1_NUM,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Portador",;                                                                                  // [01]  C   Titulo do campo
        "Portador",;                                                                                  // [02]  C   ToolTip do campo
        "E1_PORTADO",;                                                                                  // [03]  C   Id do Field
        TamSX3("E1_PORTADO")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("E1_PORTADO")[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->E1_PORTADO,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Valor Titulo",;                                                                                  // [01]  C   Titulo do campo
        "Valor Titulo",;                                                                                  // [02]  C   ToolTip do campo
        "E1_VALOR",;                                                                                  // [03]  C   Id do Field
        TamSX3("E1_VALOR")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("E1_VALOR")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("E1_VALOR")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->E1_VALOR,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Saldo Titulo",;                                                                                  // [01]  C   Titulo do campo
        "Saldo Titulo",;                                                                                  // [02]  C   ToolTip do campo
        "E1_SALDO",;                                                                                  // [03]  C   Id do Field
        TamSX3("E1_SALDO")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("E1_SALDO")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("E1_SALDO")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->E1_SALDO,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Dt Dispo",;                                                                                    // [01]  C   Titulo do campo
        "Dt Dispo",;                                                                                    // [02]  C   ToolTip do campo
        "E5_DTDISPO",;                                                                                 // [03]  C   Id do Field
        TamSX3("E5_DTDISPO")[3],;                                                                                       // [04]  C   Tipo do campo
        TamSX3("E5_DTDISPO")[1],;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->E5_DTDISPO,'')" ),;         // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Código Registro Boleto",;                                                                                  // [01]  C   Titulo do campo
        "Código Registro Boleto",;                                                                                  // [02]  C   ToolTip do campo
        "E1_XWSBRAC",;                                                                                  // [03]  C   Id do Field
        TamSX3("E1_XWSBRAC")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("E1_XWSBRAC")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("E1_XWSBRAC")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->E1_XWSBRAC,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Registro Boleto",;                                                                                  // [01]  C   Titulo do campo
        "Registro Boleto",;                                                                                  // [02]  C   ToolTip do campo
        "E1_XWSBRAD",;                                                                                  // [03]  C   Id do Field
        TamSX3("E1_XWSBRAD")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("E1_XWSBRAD")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("E1_XWSBRAD")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->E1_XWSBRAD,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Cli Del ",;                                                                                  // [01]  C   Titulo do campo
        "Cli Del",;                                                                                  // [02]  C   ToolTip do campo
        "DEL_A1",;                                                                                  // [03]  C   Id do Field
        "C",;                                                                       // [04]  C   Tipo do campo
        1,;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->DEL_A1,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Razão Social",;                                                                                 // [01]  C   Titulo do campo
        "Razão Social",;                                                                                 // [02]  C   ToolTip do campo
        "A1_NOME",;                                                                               // [03]  C   Id do Field
        TamSX3("A1_NOME")[3],;                                                                    // [04]  C   Tipo do campo
        TamSX3("A1_NOME")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A1_NOME,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Fantasia",;                                                                                 // [01]  C   Titulo do campo
        "Fantasia",;                                                                                 // [02]  C   ToolTip do campo
        "A1_NREDUZ",;                                                                               // [03]  C   Id do Field
        TamSX3("A1_NREDUZ")[3],;                                                                    // [04]  C   Tipo do campo
        TamSX3("A1_NREDUZ")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A1_NREDUZ,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Bco Cli",;                                                                                 // [01]  C   Titulo do campo
        "Bco Cli",;                                                                                 // [02]  C   ToolTip do campo
        "A1_BCO1",;                                                                               // [03]  C   Id do Field
        TamSX3("A1_BCO1")[3],;                                                                    // [04]  C   Tipo do campo
        TamSX3("A1_BCO1")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A1_BCO1,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Cond Cli",;                                                                                 // [01]  C   Titulo do campo
        "Cond Cli",;                                                                                 // [02]  C   ToolTip do campo
        "A1_COND",;                                                                               // [03]  C   Id do Field
        TamSX3("A1_COND")[3],;                                                                    // [04]  C   Tipo do campo
        TamSX3("A1_COND")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A1_COND,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Atividade 1",;                                                                                 // [01]  C   Titulo do campo
        "Atividade 1",;                                                                                 // [02]  C   ToolTip do campo
        "A1_SATIV1",;                                                                               // [03]  C   Id do Field
        TamSX3("A1_SATIV1")[3],;                                                                    // [04]  C   Tipo do campo
        TamSX3("A1_SATIV1")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A1_SATIV1,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Desc Atividade 1",;                                                                                 // [01]  C   Titulo do campo
        "Desc Atividade 1",;                                                                                 // [02]  C   ToolTip do campo
        "X5DESCRI_S",;                                                                               // [03]  C   Id do Field
        "C",;                                                                    // [04]  C   Tipo do campo
        55,;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->X5DESCRI_S,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Atividade 2",;                                                                                 // [01]  C   Titulo do campo
        "Atividade 2",;                                                                                 // [02]  C   ToolTip do campo
        "A1_SATIV2",;                                                                               // [03]  C   Id do Field
        TamSX3("A1_SATIV2")[3],;                                                                    // [04]  C   Tipo do campo
        TamSX3("A1_SATIV2")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A1_SATIV2,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Desc Atividade 2",;                                                                                 // [01]  C   Titulo do campo
        "Desc Atividade 2",;                                                                                 // [02]  C   ToolTip do campo
        "X5DESCRI_T",;                                                                               // [03]  C   Id do Field
        "C",;                                                                    // [04]  C   Tipo do campo
        55,;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->X5DESCRI_T,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Rede",;                                                                                  // [01]  C   Titulo do campo
        "Rede",;                                                                                  // [02]  C   ToolTip do campo
        "A1_REDE",;                                                                                  // [03]  C   Id do Field
        TamSX3("A1_REDE")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("A1_REDE")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("A1_REDE")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A1_REDE,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Email Cliente",;                                                                                  // [01]  C   Titulo do campo
        "Email Cliente",;                                                                                  // [02]  C   ToolTip do campo
        "A1_EMAIL",;                                                                                  // [03]  C   Id do Field
        TamSX3("A1_EMAIL")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("A1_EMAIL")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("A1_EMAIL")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->A1_EMAIL,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "TES Gera Duplicata",;                                                                                  // [01]  C   Titulo do campo
        "TES Gera Duplicata",;                                                                                  // [02]  C   ToolTip do campo
        "F4_DUPLIC",;                                                                                  // [03]  C   Id do Field
        TamSX3("F4_DUPLIC")[3],;                                                                       // [04]  C   Tipo do campo
        TamSX3("F4_DUPLIC")[1],;                                                                       // [05]  N   Tamanho do campo
        TamSX3("F4_DUPLIC")[2],;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+TABTMP+"->F4_DUPLIC,'')" ),;          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("ADFIN090PM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMTMP",/*cOwner*/,oStTMP)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'C5_NUM'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription(cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMTMP"):SetDescription(cTitulo)

Return oModel
 
/*/{Protheus.doc} Static Function VIEWDEF
    Criação da visão MVC
    @type  Function
    @author FWNM
    @since 29/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()

    Local aStruTMP := TABTMP->( dbStruct() )
    Local oModel   := FWLoadModel("ADFIN090P")
    Local oStTMP   := FWFormViewStruct():New()
    Local oView    := Nil

    //Adicionando campos da estrutura
    oStTmp:AddField(;
        "DEL_PV",;                  // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "PV Del",;                  // [03]  C   Titulo do campo
        "PV Del",;                  // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_FILIAL",;               // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        "PV Filial",;               // [03]  C   Titulo do campo
        "PV Filial",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_FILIAL")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_NUM",;                  // [01]  C   Nome do Campo
        "03",;                      // [02]  C   Ordem
        "Pedido",;                  // [03]  C   Titulo do campo
        "Pedido",;                  // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_NUM")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_VALORNF",;              // [01]  C   Nome do Campo
        "04",;                      // [02]  C   Ordem
        "Valor NF",;                // [03]  C   Titulo do campo
        "Valor NF",;                // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_VALORNF")[3],;                       // [06]  C   Tipo do campo
        "@E 999,999,999.99",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_CLIENTE",;              // [01]  C   Nome do Campo
        "05",;                      // [02]  C   Ordem
        "Cliente",;                 // [03]  C   Titulo do campo
        "Cliente",;                 // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_CLIENTE")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_LOJAENT",;              // [01]  C   Nome do Campo
        "06",;                      // [02]  C   Ordem
        "Loja",;                    // [03]  C   Titulo do campo
        "Loja",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_LOJAENT")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_CONDPAG",;              // [01]  C   Nome do Campo
        "07",;                      // [02]  C   Ordem
        "Cond Pag",;                // [03]  C   Titulo do campo
        "Cond Pag",;                // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_CONDPAG")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_BLQ",;                  // [01]  C   Nome do Campo
        "08",;                      // [02]  C   Ordem
        "PV Bloq?",;                // [03]  C   Titulo do campo
        "PV Bloq?",;                // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_BLQ")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_XWSBOLG",;              // [01]  C   Nome do Campo
        "09",;                      // [02]  C   Ordem
        "Boleto?",;                 // [03]  C   Titulo do campo
        "Boleto?",;                 // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_XWSBOLG")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_XWSPAGO",;              // [01]  C   Nome do Campo
        "10",;                      // [02]  C   Ordem
        "Recebido?",;               // [03]  C   Titulo do campo
        "Recebido?",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_XWSPAGO")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_DTENTR",;               // [01]  C   Nome do Campo
        "11",;                      // [02]  C   Ordem
        "Dt Entrega",;              // [03]  C   Titulo do campo
        "Dt Entrega",;              // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_DTENTR")[3],;                       // [06]  C   Tipo do campo
        "@D",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_VEND1",;                // [01]  C   Nome do Campo
        "12",;                      // [02]  C   Ordem
        "Vendedor",;                // [03]  C   Titulo do campo
        "Vendedor",;                // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_VEND1")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "A3_SUPER",;                // [01]  C   Nome do Campo
        "13",;                      // [02]  C   Ordem
        "Supervisor",;              // [03]  C   Titulo do campo
        "Supervisor",;              // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A3_SUPER")[3],;     // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "A3_NOME",;                 // [01]  C   Nome do Campo
        "14",;                      // [02]  C   Ordem
        "Nome Vendedor",;                    // [03]  C   Titulo do campo
        "Nome Vendedor",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A3_NOME")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "A3_EMAIL",;                 // [01]  C   Nome do Campo
        "15",;                      // [02]  C   Ordem
        "Email Vendedor",;                    // [03]  C   Titulo do campo
        "Email Vendedor",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A3_EMAIL")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "C5_NOTA",;                 // [01]  C   Nome do Campo
        "16",;                      // [02]  C   Ordem
        "NF",;                    // [03]  C   Titulo do campo
        "NF",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("C5_NOTA")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "DEL_RA",;                 // [01]  C   Nome do Campo
        "17",;                      // [02]  C   Ordem
        "Tit Del",;                  // [03]  C   Titulo do campo
        "Tit Del",;                  // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "E1_TIPO",;                 // [01]  C   Nome do Campo
        "18",;                      // [02]  C   Ordem
        "Tipo Tit",;                    // [03]  C   Titulo do campo
        "Tipo Tit",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("E1_TIPO")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "E1_NUM",;                 // [01]  C   Nome do Campo
        "19",;                      // [02]  C   Ordem
        "Titulo",;                    // [03]  C   Titulo do campo
        "Titulo",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("E1_NUM")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "E1_PORTADO",;                 // [01]  C   Nome do Campo
        "20",;                      // [02]  C   Ordem
        "Portador",;                    // [03]  C   Titulo do campo
        "Portador",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("E1_PORTADO")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "E1_VALOR",;                 // [01]  C   Nome do Campo
        "21",;                      // [02]  C   Ordem
        "Valor Titulo",;                    // [03]  C   Titulo do campo
        "Valor Titulo",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("E1_VALOR")[3],;                       // [06]  C   Tipo do campo
        "@E 999,999,999.99",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "E1_SALDO",;                 // [01]  C   Nome do Campo
        "22",;                      // [02]  C   Ordem
        "Saldo Titulo",;                    // [03]  C   Titulo do campo
        "Saldo Titulo",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("E1_SALDO")[3],;                       // [06]  C   Tipo do campo
        "@E 999,999,999.99",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "E5_DTDISPO",;                 // [01]  C   Nome do Campo
        "23",;                      // [02]  C   Ordem
        "Dt Dispo",;                   // [03]  C   Titulo do campo
        "Dt Dispo",;                   // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("E5_DTDISPO")[3],;                       // [06]  C   Tipo do campo
        "@D",;         // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "E1_XWSBRAC",;                 // [01]  C   Nome do Campo
        "24",;                      // [02]  C   Ordem
        "Código Registro Boleto ",;                    // [03]  C   Titulo do campo
        "Código Registro Boleto",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("E1_XWSBRAC")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "E1_XWSBRAD",;                 // [01]  C   Nome do Campo
        "25",;                      // [02]  C   Ordem
        "Registro Boleto ",;                    // [03]  C   Titulo do campo
        "Registro Boleto",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("E1_XWSBRAD")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "DEL_A1",;                 // [01]  C   Nome do Campo
        "26",;                      // [02]  C   Ordem
        "Cli Del",;                  // [03]  C   Titulo do campo
        "Cli Del",;                  // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "A1_NOME",;                 // [01]  C   Nome do Campo
        "27",;                      // [02]  C   Ordem
        "Razão Social",;               // [03]  C   Titulo do campo
        "Razão Social",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A1_NOME")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "A1_NREDUZ",;                 // [01]  C   Nome do Campo
        "28",;                      // [02]  C   Ordem
        "Fantasia",;               // [03]  C   Titulo do campo
        "Fantasia",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A1_NREDUZ")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "A1_BCO1",;                 // [01]  C   Nome do Campo
        "29",;                      // [02]  C   Ordem
        "Cli Banco",;               // [03]  C   Titulo do campo
        "Cli Banco",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A1_BCO1")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "A1_COND",;                 // [01]  C   Nome do Campo
        "30",;                      // [02]  C   Ordem
        "Cli Cond",;               // [03]  C   Titulo do campo
        "Cli Cond",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A1_COND")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "A1_SATIV1",;                 // [01]  C   Nome do Campo
        "31",;                      // [02]  C   Ordem
        "Atividade 1",;               // [03]  C   Titulo do campo
        "Atividade 1",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A1_SATIV1")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "X5DESCRI_S",;                 // [01]  C   Nome do Campo
        "32",;                      // [02]  C   Ordem
        "Desc Atividade 1",;               // [03]  C   Titulo do campo
        "Desc Atividade 1",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "A1_SATIV2",;                 // [01]  C   Nome do Campo
        "33",;                      // [02]  C   Ordem
        "Atividade 2",;               // [03]  C   Titulo do campo
        "Atividade 2",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A1_SATIV2")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "X5DESCRI_T",;                 // [01]  C   Nome do Campo
        "34",;                      // [02]  C   Ordem
        "Desc Atividade 2",;               // [03]  C   Titulo do campo
        "Desc Atividade 2",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "Rede",;                 // [01]  C   Nome do Campo
        "35",;                      // [02]  C   Ordem
        "Rede",;                    // [03]  C   Titulo do campo
        "Rede",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A1_REDE")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "Email Cliente",;                 // [01]  C   Nome do Campo
        "36",;                      // [02]  C   Ordem
        "Email Cliente",;                    // [03]  C   Titulo do campo
        "Email Cliente",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("A1_EMAIL")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "TES Gera Financeiro",;                 // [01]  C   Nome do Campo
        "37",;                      // [02]  C   Ordem
        "TES Gera Financeiro",;                    // [03]  C   Titulo do campo
        "TES Gera Financeiro",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        TamSX3("F4_DUPLIC")[3],;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_TMP", oStTMP, "FORMTMP")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_TMP', cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_TMP","TELA")

Return oView

/*/{Protheus.doc} Static Function PopulaTMP
    Popula tabela temporária
    @type  Function
    @author FWNM
    @since 29/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function PopulaTMP(cNumPV)

	Local cDescBox	:= "Informe a data de entrega dos PVs de adiantamento"
	//Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
    Local dDataAPI1	:= dDatabase
	Local dDataAPI2	:= dDatabase + iif(DOW(dDatabase)==6, 3, 1)
    Local nFiltro   := 0

    //Local dDataAPI1	:= StoD("")    
	//Local dDataAPI2	:= StoD("")    
	Local aParamBox := {}   
	Local aRet 		:= {}   

    Default cNumPV  := ""

    If Empty(cNumPV)

        aAdd( aParamBox,{ 1, "Dt Entrega De:" , dDataAPI1	,"","","","",80, .T. } )
        aAdd( aParamBox,{ 1, "Dt Entrega Ate:", dDataAPI2	,"","","","",80, .T. } )
        aAdd( aParamBox,{ 3,"Filtro",1,{'PV Liberado para geração NF',;
                                        'Boleto/Depósito Recebido e PV Faturado',;
                                        'Boleto/Depósito não realizado',;
                                        'Boleto não registrado',;
                                        'Bloqueio Comercial',;
                                        'Boleto registrado e não enviado ao cliente/vendedor',;
                                        'PV com TES que não gera financeiro',;
                                        'Sem Filtro';
                        },100,"",.F.})

        //If ParamBox( aParamBox, cDescBox, @aRet ) // com opção salvar
        If ParamBox( aParamBox, cDescBox, @aRet, , , , , , , , .F., .F. ) // Sem opção salvar 
            dDataAPI1   := aRet[1]
            dDataAPI2   := aRet[2]
            nFiltro     := aRet[3]

            MsAguarde({|| u_RunTMP(dDataAPI1,dDataAPI2, nil,nFiltro) },"Aguarde","Buscando PVs de adiantamento")
        EndIf

    Else

        SC5->( dbSetOrder(1) )
        If SC5->( dbSeek(FWxFilial("SC5")+cNumPV) )
            dDataAPI1 := SC5->C5_DTENTR
            dDataAPI2 := SC5->C5_DTENTR
            MsAguarde({|| u_RunTMP(dDataAPI1,dDataAPI2,cNumPV, nFiltro) },"Aguarde","Buscando PVs de adiantamento")
        EndIf

    EndIf
    
Return Nil

/*/{Protheus.doc} User Function RunTMP
    Popula tabela temporária
    @type  Function
    @author FWNM
    @since 29/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function RunTMP(dDataAPI1,dDataAPI2,cNumPV, nFiltro)

    Local cQuery      := ""

    Local cA3_SUPER   := ""
    Local cA3_NOME    := ""
    Local cA3_EMAIL   := ""

    
    Local cE1_TIPO    := ""
    
    Local cE1_PORTADO := ""
    Local nE1_VALOR   := 0
    Local nE1_SALDO   := 0
    Local cE1XWSBRAD  := ""
    Local dE5_DTDISPO := CtoD("//")

    Local cA1_NOME    := ""
    Local cA1_NREDUZ  := ""
    Local cA1_BCO1    := ""
    Local cA1_COND    := ""
    Local cA1_SATIV1  := ""
    Local X5DESCRI_S  := ""
    Local cA1_SATIV2  := ""
    Local X5DESCRI_T  := ""
    Local cA1_REDE    := ""
    Local cA1_EMAIL   := ""
    
    Private cAllTESFin  := "" // @history ticket 71027 - Fernando Macieira    - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
    
    //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
    Private cE1_NUM     := ""
    Private cDel_RA     := ""
    Private cDel_A1     := ""
    Private cE1XWSBRAC  := ""

    Default cNumPV    := ""
    Default nFiltro   := 0

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    // PVs não deletados
    cQuery := " SELECT SC5.D_E_L_E_T_ DEL_PV, C5_FILIAL, C5_NUM, C5_VALORNF, C5_CLIENTE, C5_LOJAENT, C5_CONDPAG, C5_XWSBOLG, C5_XWSPAGO, C5_DTENTR, C5_VEND1, C5_BLQ, C5_NOTA
    cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK)
    cQuery += " INNER JOIN " + RetSqlName("SE4") + " SE4 (NOLOCK) ON E4_FILIAL='"+FWxFilial("SE4")+"' AND E4_CODIGO=C5_CONDPAG AND E4_CTRADT='1' AND SE4.D_E_L_E_T_=''
    cQuery += " WHERE C5_FILIAL='"+FWxFilial("SC5")+"' 
    If !Empty(cNumPV)
        cQuery += " AND C5_NUM='"+cNumPV+"'
    EndIf
    cQuery += " AND C5_DTENTR BETWEEN '"+DtoS(dDataAPI1)+"' AND '"+DtoS(dDataAPI2)+"'
    cQuery += " AND SC5.D_E_L_E_T_=''
    
    cQuery += " UNION ALL
    
    // PVs deletados
    cQuery += " SELECT SC5.D_E_L_E_T_ DEL_PV, C5_FILIAL, C5_NUM, C5_VALORNF, C5_CLIENTE, C5_LOJAENT, C5_CONDPAG, C5_XWSBOLG, C5_XWSPAGO, C5_DTENTR, C5_VEND1, C5_BLQ, C5_NOTA
    cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK)
    cQuery += " INNER JOIN " + RetSqlName("SE4") + " SE4 (NOLOCK) ON E4_FILIAL='"+FWxFilial("SE4")+"' AND E4_CODIGO=C5_CONDPAG AND E4_CTRADT='1' AND SE4.D_E_L_E_T_=''
    cQuery += " WHERE C5_FILIAL='"+FWxFilial("SC5")+"' 
    If !Empty(cNumPV)
        cQuery += " AND C5_NUM='"+cNumPV+"'
    EndIf
    cQuery += " AND C5_DTENTR BETWEEN '"+DtoS(dDataAPI1)+"' AND '"+DtoS(dDataAPI2)+"'
    cQuery += " AND SC5.D_E_L_E_T_='*'

    tcQuery cQuery new Alias "Work"

    aTamSX3	:= TamSX3("C5_VALORNF")
	tcSetField("Work", "C5_VALORNF", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    aTamSX3	:= TamSX3("C5_DTENTR")
	tcSetField("Work", "C5_DTENTR",	aTamSX3[3], aTamSX3[1], aTamSX3[2])

    Work->( dbGoTop() )

    Do While Work->( !EOF() )

        cA3_SUPER   := ""
        cA3_NOME    := ""
        cA3_EMAIL   := ""

        cDel_RA      := ""
        cE1_TIPO    := ""
        cE1_NUM     := ""
        cE1_PORTADO := ""
        nE1_VALOR   := 0
        nE1_SALDO   := 0
        cE1XWSBRAC  := ""
        cE1XWSBRAD  := ""
        dE5_DTDISPO := CtoD("//")

        cDel_A1      := ""
        cA1_NOME    := ""
        cA1_NREDUZ  := ""
        cA1_BCO1    := ""
        cA1_COND    := ""
        cA1_SATIV1  := ""
        X5DESCRI_S  := ""
        cA1_SATIV2  := ""
        X5DESCRI_T  := ""
        cA1_REDE    := ""
        cA1_EMAIL   := ""

        cAllTESFin := ChkTESPV(Work->C5_FILIAL, Work->C5_NUM) // @history ticket 71027 - Fernando Macieira    - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem

        SA3->( dbSetOrder(1) )
        If SA3->( dbSeek(FWxFilial("SA3")+Work->C5_VEND1) )
            cA3_NOME  := SA3->A3_NOME
            cA3_EMAIL := SA3->A3_EMAIL
            cA3_SUPER := SA3->A3_SUPER
        EndIf

        SA1->( dbSetOrder(1) )
        If SA1->( dbSeek(FWxFilial("SA1")+Work->C5_CLIENTE+Work->C5_LOJAENT) )
            
            cA1_NOME   := SA1->A1_NOME
            cA1_NREDUZ := SA1->A1_NREDUZ
            cA1_BCO1   := SA1->A1_BCO1
            cA1_COND   := SA1->A1_COND

            cA1_SATIV1 := SA1->A1_SATIV1
            X5DESCRI_S := Posicione("SX5",1,FWxFilial("SX5")+"_S"+cA1_SATIV1,"X5_DESCRI")

            cA1_SATIV2 := SA1->A1_SATIV2
            X5DESCRI_T  := Posicione("SX5",1,FWxFilial("SX5")+"_T"+cA1_SATIV1,"X5_DESCRI")

            cA1_REDE   := SA1->A1_REDE
            cA1_EMAIL  := SA1->A1_EMAIL
        
        Else

            // Busco cliente deletado
            If Select("WorkA1DEL") > 0
                WorkA1DEL->( dbCloseArea() )
            EndIf

            cQuery := " SELECT A1_NOME, A1_NREDUZ, A1_BCO1, A1_COND, A1_SATIV1, A1_SATIV2, A1_REDE, A1_EMAIL
            cQuery += " FROM " + RetSqlName("SA1") + " (NOLOCK)
            cQuery += " WHERE A1_FILIAL='"+FWxFilial("SA1")+"'
            cQuery += " AND A1_COD='"+Work->C5_CLIENTE+"'
            cQuery += " AND A1_LOJA='"+Work->C5_LOJAENT+"'
            cQuery += " AND D_E_L_E_T_='*'

            tcQuery cQuery New Alias "WorkA1DEL"

            WorkA1DEL->( dbGoTop() )

            If WorkA1DEL->( !EOF() )

                cDel_A1     := "*"
                cA1_NOME   := WorkA1DEL->A1_NOME
                cA1_NREDUZ := WorkA1DEL->A1_NREDUZ
                cA1_BCO1   := WorkA1DEL->A1_BCO1
                cA1_COND   := WorkA1DEL->A1_COND

                cA1_SATIV1 := WorkA1DEL->A1_SATIV1
                X5DESCRI_S := Posicione("SX5",1,FWxFilial("SX5")+"_S"+cA1_SATIV1,"X5_DESCRI")

                cA1_SATIV2 := WorkA1DEL->A1_SATIV2
                X5DESCRI_T  := Posicione("SX5",1,FWxFilial("SX5")+"_T"+cA1_SATIV1,"X5_DESCRI")

                cA1_REDE   := WorkA1DEL->A1_REDE
                cA1_EMAIL  := WorkA1DEL->A1_EMAIL

            EndIf

            If Select("WorkA1DEL") > 0
                WorkA1DEL->( dbCloseArea() )
            EndIf

        EndIf

        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(FWxFilial("FIE")+"R"+Work->C5_NUM) )

		    SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			If SE1->( dbSeek(FIE->(FIE_FILIAL+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

                cE1_NUM     := SE1->E1_NUM
                cE1_TIPO    := SE1->E1_TIPO
                cE1XWSBRAC  := SE1->E1_XWSBRAC
                cE1XWSBRAD  := SE1->E1_XWSBRAD
                nE1_SALDO   := SE1->E1_SALDO
                nE1_VALOR   := SE1->E1_VALOR

                SE5->( dbSetOrder(2) ) //E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_
                If SE5->( dbSeek(SE1->E1_FILIAL+AllTrim(SE1->E1_TIPO)+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+DtoS(SE1->E1_EMISSAO)+SE1->E1_CLIENTE+SE1->E1_LOJA) )

                    dE5_DTDISPO := SE5->E5_DTDISPO
                
                EndIf

            Else

                // Busco Título deletado
                If Select("WorkE1DEL") > 0
                    WorkE1DEL->( dbCloseArea() )
                EndIf

                cQuery := " SELECT E1_TIPO, E1_NUM, E1_PORTADO, E1_VALOR, E1_SALDO, E1_XWSBRAC, E1_XWSBRAD
                cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
                cQuery += " WHERE E1_FILIAL='"+FWxFilial("SE1")+"'
                cQuery += " AND E1_PREFIXO='"+FIE->FIE_PREFIX+"'
                cQuery += " AND E1_NUM='"+FIE->FIE_NUM+"'
                cQuery += " AND E1_PARCELA='"+FIE->FIE_PARCEL+"'
                cQuery += " AND E1_TIPO='"+FIE->FIE_TIPO+"'
                cQuery += " AND D_E_L_E_T_='*'

                tcQuery cQuery New Alias "WorkE1DEL"

                aTamSX3	:= TamSX3("E1_VALOR")
                tcSetField("WorkE1DEL", "E1_VALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

                aTamSX3	:= TamSX3("E1_SALDO")
                tcSetField("WorkE1DEL", "E1_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

                WorkE1DEL->( dbGoTop() )

                If WorkE1DEL->( !EOF() )

                    cDel_RA      := "*"
                    cE1_TIPO    := WorkE1DEL->E1_TIPO
                    cE1_NUM     := WorkE1DEL->E1_NUM
                    cE1_PORTADO := WorkE1DEL->E1_PORTADO
                    nE1_VALOR   := WorkE1DEL->E1_VALOR
                    nE1_SALDO   := WorkE1DEL->E1_SALDO
                    cE1XWSBRAC  := WorkE1DEL->E1_XWSBRAC
                    cE1XWSBRAD  := WorkE1DEL->E1_XWSBRAD

                EndIf

                If Select("WorkE1DEL") > 0
                    WorkE1DEL->( dbCloseArea() )
                EndIf            
            
            EndIf

        Else

            FR3->( dbSetOrder(4) ) // FR3_FILIAL, FR3_CART, FR3_PEDIDO, R_E_C_N_O_, D_E_L_E_T_
            If FR3->( dbSeek(FWxFilial("FR3")+"R"+Work->C5_NUM) )

                SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
                If SE1->( dbSeek(FR3->(FR3_FILIAL+FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO)) )

                    cE1_NUM     := SE1->E1_NUM
                    cE1_TIPO    := SE1->E1_TIPO
                    cE1XWSBRAD  := SE1->E1_XWSBRAC
                    cE1XWSBRAD  := SE1->E1_XWSBRAD
                    nE1_SALDO   := SE1->E1_SALDO
                    nE1_VALOR   := SE1->E1_VALOR

                    SE5->( dbSetOrder(2) ) //E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_
                    If SE5->( dbSeek(SE1->E1_FILIAL+AllTrim(SE1->E1_TIPO)+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+DtoS(SE1->E1_EMISSAO)+SE1->E1_CLIENTE+SE1->E1_LOJA) )

                        dE5_DTDISPO := SE5->E5_DTDISPO
                    
                    EndIf

                Else

                    // Busco Título deletado
                    If Select("WorkE1DEL") > 0
                        WorkE1DEL->( dbCloseArea() )
                    EndIf

                    cQuery := " SELECT E1_TIPO, E1_NUM, E1_PORTADO, E1_VALOR, E1_SALDO, E1_XWSBRAC, E1_XWSBRAD
                    cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
                    cQuery += " WHERE E1_FILIAL='"+FWxFilial("SE1")+"'
                    cQuery += " AND E1_PREFIXO='"+FR3->FR3_PREFIX+"'
                    cQuery += " AND E1_NUM='"+FR3->FR3_NUM+"'
                    cQuery += " AND E1_PARCELA='"+FR3->FR3_PARCEL+"'
                    cQuery += " AND E1_TIPO='"+FR3->FR3_TIPO+"'
                    cQuery += " AND D_E_L_E_T_='*'

                    tcQuery cQuery New Alias "WorkE1DEL"

                    aTamSX3	:= TamSX3("E1_VALOR")
                    tcSetField("WorkE1DEL", "E1_VALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

                    aTamSX3	:= TamSX3("E1_SALDO")
                    tcSetField("WorkE1DEL", "E1_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

                    WorkE1DEL->( dbGoTop() )

                    If WorkE1DEL->( !EOF() )

                        cDel_RA      := "*"
                        cE1_TIPO    := WorkE1DEL->E1_TIPO
                        cE1_NUM     := WorkE1DEL->E1_NUM
                        cE1_PORTADO := WorkE1DEL->E1_PORTADO
                        nE1_VALOR   := WorkE1DEL->E1_VALOR
                        nE1_SALDO   := WorkE1DEL->E1_SALDO
                        cE1XWSBRAC  := WorkE1DEL->E1_XWSBRAC
                        cE1XWSBRAD  := WorkE1DEL->E1_XWSBRAD

                    EndIf

                    If Select("WorkE1DEL") > 0
                        WorkE1DEL->( dbCloseArea() )
                    EndIf            
                
                EndIf

            EndIf
        
        EndIf

        if fGetFiltro(nFiltro)

            RecLock( "TABTMP", .t. )

                TABTMP->DEL_PV     := Work->DEL_PV
                TABTMP->C5_FILIAL  := Work->C5_FILIAL
                TABTMP->C5_NUM     := Work->C5_NUM
                TABTMP->C5_VALORNF := Work->C5_VALORNF
                TABTMP->C5_CLIENTE := Work->C5_CLIENTE
                TABTMP->C5_LOJAENT := Work->C5_LOJAENT
                TABTMP->C5_CONDPAG := Work->C5_CONDPAG
                TABTMP->C5_BLQ     := Work->C5_BLQ
                TABTMP->C5_XWSBOLG := Work->C5_XWSBOLG
                TABTMP->C5_XWSPAGO := Work->C5_XWSPAGO
                TABTMP->C5_DTENTR  := Work->C5_DTENTR
                TABTMP->C5_VEND1   := Work->C5_VEND1
                TABTMP->A3_SUPER   := cA3_SUPER
                TABTMP->A3_NOME    := cA3_NOME
                TABTMP->A3_EMAIL   := cA3_EMAIL
                TABTMP->C5_NOTA    := Work->C5_NOTA

                TABTMP->DEL_RA     := cDEL_RA
                TABTMP->E1_TIPO    := cE1_TIPO
                TABTMP->E1_NUM     := cE1_NUM
                TABTMP->E1_PORTADO := cE1_PORTADO
                TABTMP->E1_VALOR   := nE1_VALOR
                TABTMP->E1_SALDO   := nE1_SALDO
                TABTMP->E5_DTDISPO := dE5_DTDISPO
                TABTMP->E1_XWSBRAC := cE1XWSBRAC
                TABTMP->E1_XWSBRAD := cE1XWSBRAD

                TABTMP->DEL_A1     := cDEL_A1
                TABTMP->A1_NOME    := cA1_NOME
                TABTMP->A1_NREDUZ  := cA1_NREDUZ
                TABTMP->A1_BCO1    := cA1_BCO1
                TABTMP->A1_COND    := cA1_COND
                TABTMP->A1_SATIV1  := cA1_SATIV1
                TABTMP->X5DESCRI_S := X5DESCRI_S
                TABTMP->A1_SATIV2  := cA1_SATIV2
                TABTMP->X5DESCRI_T := X5DESCRI_T
                TABTMP->A1_REDE    := cA1_REDE
                TABTMP->A1_EMAIL   := cA1_EMAIL

                TABTMP->F4_DUPLIC  := cAllTESFin // @history ticket 71027 - Fernando Macieira    - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem

            TABTMP->( msUnLock() )

        endif

        Work->( dbSkip() )

    EndDo

Return Nil

Static Function fGetFiltro(nFiltro)

    Local lRet := .T.

    if nFiltro != 0
        //"!Empty(AllTrim(C5_XWSPAGO)) .and. Empty(C5_NOTA) .and. Empty(DEL_PV)"
        if nFiltro == 1
            if (!Empty(AllTrim(Work->C5_XWSPAGO)) .and. Empty(Work->C5_NOTA) .and. Empty(Work->DEL_PV)) .AND. AllTrim(Work->C5_BLQ)!='1'
                lRet := .T.
            else
                lRet := .F.
            endif
        // !Empty(AllTrim(C5_XWSPAGO)) .and. !Empty(C5_NOTA) .and. Empty(DEL_PV)
        elseif nFiltro == 2
            if (!Empty(AllTrim(Work->C5_XWSPAGO)) .and. !Empty(Work->C5_NOTA) .and. Empty(Work->DEL_PV))  .AND. AllTrim(Work->C5_BLQ)!='1'
                lRet := .T.
            else
                lRet := .F.
            endif
        //Empty(AllTrim(C5_XWSPAGO)) .and. Empty(C5_NOTA) .and. Empty(DEL_PV) .and. Empty(AllTrim(C5_BLQ)) .and. !Empty(E1_NUM)    
        elseif nFiltro == 3
            if Empty(AllTrim(Work->C5_XWSPAGO)) .and. Empty(Work->C5_NOTA) .and. Empty(Work->DEL_PV) .and. Empty(AllTrim(Work->C5_BLQ)) .and. !Empty(cE1_NUM)
                lRet := .T.
            else
                lRet := .F.
            endif
        //!Empty(AllTrim(E1_XWSBRAC)) .and. AllTrim(E1_XWSBRAC)<>'0' .and. AllTrim(E1_XWSBRAC)<>'69' .and. Empty(DEL_PV)
        elseif nFiltro == 4
            if (!Empty(AllTrim(cE1XWSBRAC)) .and. AllTrim(cE1XWSBRAC)<>'0' .and. AllTrim(cE1XWSBRAC)<>'69' .and. Empty(Work->DEL_PV)) .AND. AllTrim(Work->C5_BLQ)!='1'
                lRet := .T.
            else
                lRet := .F.
            endif
        //AllTrim(C5_BLQ)=='1' .and. Empty(DEL_PV)
        elseif nFiltro == 5
            if AllTrim(Work->C5_BLQ)=='1' .and. Empty(Work->DEL_PV)
                lRet := .T.
            else
                lRet := .F.
            endif
        //!Empty(E1_NUM) .and. Empty(C5_XWSBOLG) .and. (AllTrim(E1_XWSBRAC)=='0' .or. AllTrim(E1_XWSBRAC)=='69') .and. Empty(DEL_PV)
        elseif nFiltro == 6
            if (!Empty(cE1_NUM) .and. Empty(Work->C5_XWSBOLG) .and. (AllTrim(cE1XWSBRAC)=='0' .or. AllTrim(cE1XWSBRAC)=='69') .and. Empty(Work->DEL_PV)) .AND. AllTrim(Work->C5_BLQ)!='1'
                lRet := .T.
            else
                lRet := .F.
            endif
        //Empty(E1_NUM) .and. (AllTrim(DEL_PV)<>'*' .and. AllTrim(DEL_RA)<>'*' .and. AllTrim(DEL_A1)<>'*')
        elseif nFiltro == 7
            //if (Empty(cE1_NUM) .and. (AllTrim(Work->DEL_PV)<>'*' .and. AllTrim(cDEL_RA)<>'*' .and. AllTrim(cDEL_A1)<>'*')) .AND. AllTrim(Work->C5_BLQ)!='1'
            if AllTrim(cAllTESFin)=='N' // @history ticket 71027 - Fernando Macieira    - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
                lRet := .T.
            else
                lRet := .F.
            endif
        endif
    else
        lRet := .T.
    endif

return lRet

/*/{Protheus.doc} User Function AdFinc040
    Chama função Posição contas a receber
    @type  Function
    @author FWNM
    @since 30/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function AdFinc040()

    Local lRet     := .t.
    Local aAreaAtu := GetArea()
    Local aAreaSE1 := SE1->( GetArea() )
    Local cNumPV   := TABTMP->C5_NUM
    Local cFunBkp  := FunName()

    If Empty(TABTMP->E1_NUM)

        lRet := .f.
        Alert("Título não existente para este PV n. " + cNumPV)

    Else

        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(FWxFilial("FIE")+"R"+cNumPV) )

		    SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			If SE1->( dbSeek(FIE->(FIE_FILIAL+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

                FINC040()

            EndIf

        Else

            FR3->( dbSetOrder(4) ) // FR3_FILIAL, FR3_CART, FR3_PEDIDO, R_E_C_N_O_, D_E_L_E_T_
            If FR3->( dbSeek(FWxFilial("FR3")+"R"+cNumPV) )

                SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
                If SE1->( dbSeek(FR3->(FR3_FILIAL+FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO)) )

                    FINC040()

                EndIf

            EndIf
        
        EndIf

    EndIf

    SetFunName(cFunBkp)

    RestArea( aAreaAtu )
    RestArea( aAreaSE1 )
    
Return lRet

/*/{Protheus.doc} User Function AdFinc010
    Chama função Posição cliente
    @type  Function
    @author FWNM
    @since 30/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function AdFinc010()

    Local lRet     := .t.
    Local aAreaAtu := GetArea()
    Local aAreaSA1 := SA1->( GetArea() )
    Local cKeyCli  := TABTMP->C5_CLIENTE + TABTMP->C5_LOJAENT
    Local cNumPV   := TABTMP->C5_NUM
    Local cFunBkp  := FunName()

    SA1->( dbSetOrder(1) )
    If SA1->( dbSeek(FWxFilial("SA1")+cKeyCli) )
        FINC010()
    Else
        lRet := .f.
        Alert("Cliente deste PV n. " + cNumPV + " não localizado!")
    EndIf

    SetFunName(cFunBkp)

    RestArea( aAreaAtu )
    RestArea( aAreaSA1 )
    
Return lRet

/*/{Protheus.doc} User Function AdRunHCRFB
    Chama função que Imprime boleto bradesco em PDF
    @type  Function
    @author FWNM
    @since 30/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function AdRunHCRFB()

    Local lRet     := .t.
    Local aAreaAtu := GetArea()
    Local aAreaSE1 := SE1->( GetArea() )
    Local cNumPV   := TABTMP->C5_NUM
    Local cFunBkp  := FunName()

    If Empty(TABTMP->E1_NUM)

        lRet := .f.
        Alert("Título não existente para este PV n. " + cNumPV)

    Else

        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(FWxFilial("FIE")+"R"+cNumPV) )

		    SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			If SE1->( dbSeek(FIE->(FIE_FILIAL+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

                u_RunHCRFB()

            EndIf

        Else

            FR3->( dbSetOrder(4) ) // FR3_FILIAL, FR3_CART, FR3_PEDIDO, R_E_C_N_O_, D_E_L_E_T_
            If FR3->( dbSeek(FWxFilial("FR3")+"R"+cNumPV) )

                SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
                If SE1->( dbSeek(FR3->(FR3_FILIAL+FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO)) )

                    u_RunHCRFB()

                EndIf

            EndIf
        
        EndIf

    EndIf

    SetFunName(cFunBkp)

    RestArea( aAreaAtu )
    RestArea( aAreaSE1 )
    
Return lRet

/*/{Protheus.doc} User Function AdBolBrad
    Chama função que Registra boleto bradesco 
    @type  Function
    @author FWNM
    @since 30/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function AdBolBrad()

    Local lRet     := .t.
    Local aAreaAtu := GetArea()
    Local aAreaSE1 := SE1->( GetArea() )
    Local cNumPV   := TABTMP->C5_NUM
    Local cFunBkp  := FunName()

    If Empty(TABTMP->E1_NUM)

        lRet := .f.
        Alert("Título não existente para este PV n. " + cNumPV)

    Else

        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(FWxFilial("FIE")+"R"+cNumPV) )

		    SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			If SE1->( dbSeek(FIE->(FIE_FILIAL+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

                u_BolBrad()

            EndIf

        Else

            FR3->( dbSetOrder(4) ) // FR3_FILIAL, FR3_CART, FR3_PEDIDO, R_E_C_N_O_, D_E_L_E_T_
            If FR3->( dbSeek(FWxFilial("FR3")+"R"+cNumPV) )

                SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
                If SE1->( dbSeek(FR3->(FR3_FILIAL+FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO)) )

                    u_BolBrad()

                EndIf

            EndIf
        
        EndIf

    EndIf

    SetFunName(cFunBkp)

    RestArea( aAreaAtu )
    RestArea( aAreaSE1 )
    
Return lRet

/*/{Protheus.doc} User Function AdExcRAPV
    Chama função que Desvincula Boleto x PV
    @type  Function
    @author FWNM
    @since 30/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function AdExcRAPV()

    Local lRet     := .t.
    Local aAreaAtu := GetArea()
    Local aAreaSC5 := SC5->( GetArea() )
    Local aAreaSE1 := SE1->( GetArea() )
    Local cNumPV   := TABTMP->C5_NUM
    Local cFunBkp  := FunName()
    Local cUsrAut  := GetMV("MV_#WSAUTF",,"000000") // Usuarios autorizados

	// Logins autorizados
    If !(RetCodUsr() $ cUsrAut)
        lRet := .f.
        MsgStop("Login " + RetCodUsr() + " - " + AllTrim(cUserName) + " sem acesso para usar esta rotina!", "01 - Função ADEXCRAPV - ADFIN090P")
		Return lRet
	EndIf

    If Empty(TABTMP->E1_NUM)

        lRet := .f.
        Alert("Título não existente para este PV n. " + cNumPV)

    Else

        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(FWxFilial("FIE")+"R"+cNumPV) )

		    SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			If SE1->( dbSeek(FIE->(FIE_FILIAL+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

                SC5->( dbSetOrder(1) )
                If SC5->( dbSeek(FWxFilial("SC5")+cNumPV) )
                
                    u_ExcRAPV()

                EndIf

            EndIf
        
        EndIf

    EndIf

    SetFunName(cFunBkp)

    RestArea( aAreaAtu )
    RestArea( aAreaSE1 )
    RestArea( aAreaSC5 )
    
Return lRet

/*/{Protheus.doc} User Function AdPgtoWS
    Chama função que confirma pagamento do PV de adiantamento via depósito
    @type  Function
    @author FWNM
    @since 30/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
user Function AdPgtoWS()

    Local lRet     := .t.
    Local aAreaAtu := GetArea()
    Local aAreaSC5 := SC5->( GetArea() )
    Local aAreaSE1 := SE1->( GetArea() )
    Local cNumPV   := TABTMP->C5_NUM
    Local cFunBkp  := FunName()
    //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
    Local cMsgErro  := ""
    //Local nPosAt    := oBrowse:at()
    Local cMark     := oBrowse:Mark()
    Local nOk       := 0
    Local nNo       := 0
    Local nTotal    := 0
    
    TABTMP->(Dbgotop())
    //obrowse:GoTop()
    
    //SetFunName("ADFIN090P")

    While TABTMP->(!eof())

        IF TABTMP->TMP_OK == cMark

                cNumPV   := TABTMP->C5_NUM

                If !Empty(TABTMP->C5_NOTA)
                    nNo += 1
                    lRet := .f.
                    //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
                    //Alert("NF já foi gerada para o PV n. " + cNumPV)
                    cMsgErro += Chr(13)+Chr(10)+"NF já foi gerada para o PV n. " + cNumPV
                elseif  !Empty(TABTMP->DEL_PV)
                    nNo += 1
                    cMsgErro += Chr(13)+Chr(10)+"A linha selecionada do PV " + cNumPV +" foi deletado."
                Else
                    FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
                    If FIE->( dbSeek(FWxFilial("FIE")+"R"+cNumPV) )

                        SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
                        If SE1->( dbSeek(FIE->(FIE_FILIAL+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

                            SC5->( dbSetOrder(1) )
                            If SC5->( dbSeek(FWxFilial("SC5")+cNumPV) )
                            
                                //@history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO
                                If Empty(SC5->C5_XWSPAGO)
                                
                                    If u_PgtoWS(.T.)
                                        //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
                                        
                                        nOk += 1
                                    else
                                        nNo     += 1    
                                    EndIf

                                Else

                                    lRet    := .f.
                                    nNo     += 1
                                    //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
                                    cMsgErro += Chr(13)+Chr(10)+"Adiantamento/Boleto para o PV n. " + cNumPV + " já consta como recebido! Recebido/C5_XWSPAGO=S"
                                    //msgAlert("Adiantamento/Boleto para o PV n. " + cNumPV + " já consta como recebido! Recebido/C5_XWSPAGO=S")

                                EndIf
                                
                            Else
                                
                                lRet    := .f.
                                nNo     += 1
                                //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
                                cMsgErro += Chr(13)+Chr(10)+"PV n. " + cNumPV + " não encontrado! Verifique se o mesmo não foi excluído pelo Sales Force..."
                                //Alert("PV n. " + cNumPV + " não encontrado! Verifique se o mesmo não foi excluído pelo Sales Force...")
                            
                            EndIf

                        Else

                            lRet    := .f.
                            nNo     += 1
                            //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
                            cMsgErro += Chr(13)+Chr(10)+"Título no contas a receber de Adiantamento(RA)/Boleto(PR) não gerado para o PV n. " + cNumPV
                            //Alert("Título no contas a receber de Adiantamento(RA)/Boleto(PR) não gerado para o PV n. " + cNumPV)

                        EndIf
                    
                    Else

                        lRet := .f.
                        //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
                        nNo += 1
                        cMsgErro += Chr(13)+Chr(10)+"Amarração PV x PR/RA (Tabela FIE) não encontrado para o PV n. " + cNumPV
                        //Alert("Amarração PV x PR/RA (Tabela FIE) não encontrado para o PV n. " + cNumPV)
                    
                    EndIf

                EndIf

            nTotal += 1
        endif
        
        if reclock("TABTMP",.F.)
            TABTMP->TMP_OK := Space(2)
            TABTMP->(msunlock())
        endif

        TABTMP->(Dbskip())
    enddo

    if !Empty(cMsgErro)
        Alert("Alguns PVs não puderam ser processados, segue os itens: "+cMsgErro)
    endif

    SetFunName(cFunBkp)

    RestArea( aAreaAtu )
    RestArea( aAreaSE1 )
    RestArea( aAreaSC5 )
    
    MsgInfo("Rotina finalizada com sucesso, total de registros: "+chr(13)+chr(10)+;
            "Liberados: "+ Strzero(nOk,6)+ Chr(13)+chr(10)+;
            "Com Pendências (Erros): "+ Strzero(nNo,6) +Chr(13)+chr(10)+;
            "Total Selecionado: "+ Strzero(nTotal,6) )
    //Ticket 7709 - LEONARDO P. MONTEIRO - 08/01/2021 - Desenvolvimento de correções de tela e melhorias no processo de aprovação.
    //TABTMP->(Dbgotop())
    
    if nTotal > 0
        If msgYesNo("Deseja aplicar um novo filtro ou encerrar a aplicação?")
            oTempTable:Delete()
            fMkStru()
            PopulaTMP("")
            oBrowse:GoTop()
            TABTMP->(Dbgotop())
        Else
            oBrowse:DeActivate()
        ENDIF
    endif
    
    DbSelectArea("TABTMP")
    oBrowse:Refresh()    
Return lRet

/*/{Protheus.doc} User Function AdA410Visual
    Chama função que visualiza PV
    @type  Function
    @author FWNM
    @since 30/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function AdA410Visual()

    Local lRet     := .T.
    Local aAreaAtu := GetArea()
    Local aAreaSC5 := SC5->( GetArea() )
    Local cNumPV   := TABTMP->C5_NUM
    Local cFunBkp  := FunName()

    //Everson - 01/09/2020. Chamado 728.
	//Variáveis necessárias para função MatA410.
	Private Inclui    	:= .F.
	Private Altera    	:= .T.
	Private nOpca     	:= 1
	Private cCadastro 	:= "Pedido de Venda"
	Private aRotina 	:= {}
    
    //Everson - 01/09/2020. Chamado 728.
	//Busca o pedido na tabela SC5.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If ! SC5->(DbSeek(xFilial("SC5") + cNumPV))
		MsgStop("Não foi possível localizar o pedido " + cNumPV + " (SC5).","Função AdA410Visual(ADFIN090P)")
		RestArea(aArea)
		Return Nil	
	
	EndIf

	//
	SC5->(DbGoTo(Recno()))
	
	//Everson - 01/09/2020. Chamado 728.
	MatA410(Nil, Nil, Nil, Nil, "A410Visual")

	//
	SC5->(DbCloseArea())

    SetFunName(cFunBkp)

    RestArea( aAreaAtu )
    RestArea( aAreaSC5 )
    
Return lRet

/*/{Protheus.doc} User Function AdMc090Visual(cAlias,nReg,nOpc)
    Chama função que visualiza NF
    @type  Function
    @author FWNM
    @since 30/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function AdMc090Visual()

    Local lRet     := .t.
    Local aAreaAtu := GetArea()
    Local aAreaSC5 := SC5->( GetArea() )
    Local cNumPV   := TABTMP->C5_NUM
    Local cFunBkp  := FunName()

    If Empty(TABTMP->C5_NOTA)

        lRet := .f.
        Alert("NF não foi gerada para o PV n. " + cNumPV)

    Else

        SC5->( dbSetOrder(1) )
        If SC5->( dbSeek(FWxFilial("SC5")+cNumPV) )

            SF2->( dbSetOrder(1) ) // F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, R_E_C_N_O_, D_E_L_E_T_
            If SF2->( dbSeek(FWxFilial("SF2")+SC5->C5_NOTA+SC5->C5_SERIE+SC5->C5_CLIENTE+SC5->C5_LOJAENT) )
                    
                Mc090Visual("SF2",SF2->(Recno()),2)

            EndIf

        EndIf
    
    EndIf

    SetFunName(cFunBkp)

    RestArea( aAreaAtu )
    RestArea( aAreaSC5 )
    
Return lRet

/*/{Protheus.doc} Static Function ChkTESPV(SC5->C5_FILIAL, SC5->C5_NUM)
	Checa se todas as TES geram financeiro
	@type  Static Function
	@author FWNM
	@since 08/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    @history ticket 71027 - Fernando Macieira    - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
/*/
Static Function ChkTESPV(cC5_FILIAL, cC5_NUM)

	Local lRet   := .t.
    Local cRet   := "S"
	Local cQuery := ""

	If Select("WorkTES") > 0
		WorkTES->( dbCloseArea() )
	EndIf

	cQuery := " SELECT ISNULL(COUNT(DISTINCT C6_TES),0) TT_TES
	cQuery += " FROM " + RetSqlName("SC6") + " SC6 (NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON F4_FILIAL='"+FWxFilial("SF4")+"' AND F4_CODIGO=C6_TES AND F4_DUPLIC='N' AND SF4.D_E_L_E_T_=''
	cQuery += " WHERE C6_FILIAL='"+cC5_FILIAL+"'
	cQuery += " AND C6_NUM='"+cC5_NUM+"'
	cQuery += " AND SC6.D_E_L_E_T_=''

	tcQuery cQuery New Alias WorkTES

	// Se tiver TES que não gera financeiro 
	If WorkTES->TT_TES >= 1
		lRet := .f.
        cRet := "N"
	EndIf

	If Select("WorkTES") > 0
		WorkTES->( dbCloseArea() )
	EndIf

Return cRet
