#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ADFIN114P
    Nova função para gerar a data e valor do maior acumulo - Chamada via ADLCRED2.PRW
    @type  Function
    @author Fernando Macieira
    @since 25/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 52317 - REVER CÁLCULO DE MAIOR ACÚMULO DA ROTINA
/*/
User Function ADFIN114P(cRede)

    Local cQuery := ""

    Default cRede := ""

	// Define lAuto
	nArea := Select()
	If nArea > 0
		lAuto := .f.
	Else
		lAuto := .t.
	EndIf
	
	// Inicializo ambiente
	If lAuto 
		rpcClearEnv()
		rpcSetType(3)
		If !rpcSetEnv("01", "02",,,,,{"SM0"})
			ConOut("Não foi possível inicializar o ambiente")
			Return
		EndIf
	EndIf

    conout("NEWVLACU - INICIO - " + TIME())

    // REDES
    If Select("WorkRED") > 0
        WorkRED->( dbCloseArea() )
    EndIf

    cQuery := " SELECT DISTINCT ZF_REDE
    cQuery += " FROM " + RetSqlName("SZF") + " SZF (NOLOCK)
    cQuery += " WHERE ZF_FILIAL='"+FWxFilial("SZF")+"' 
    If !Empty(cRede)
        cQuery += " AND ZF_REDE='"+cRede+"' 
    EndIf
    cQuery += " AND D_E_L_E_T_=''
    //cQuery += " AND ZF_REDE='DEMA' " // DEBUG - INIBIR
    
    tcQuery cQuery New Alias "WorkRED"

    WorkRED->( dbGoTop() )
    Do While WorkRED->( !EOF() )
        MsAguarde({|| fMaiorAcum(WorkRED->ZF_REDE) },"Maior Acumulo","Calculando... " + WorkRED->ZF_REDE )
        //fMaiorAcum(WorkRED->ZF_REDE)
        WorkRED->( dbSkip() )
    EndDo

    If Select("WorkRED") > 0
		WorkRED->( dbCloseArea() )
	EndIf

    conout("NEWVLACU - FIM - " + TIME())

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'função para gerar a data e valor do maior acumulo')

        
Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 21/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fMaiorAcum(cZF_REDE)

    Local cDtBase := DtoS((msDate() - 360))
    Local aCampos := {}
    Local nVlAcum := 0
    Local cDtAcum := ""
    Local vValor  := 0

    Default cZF_REDE := ""

    // Crio TRB para impressão
    If Select("TRB") > 0
        TRB->( dbCloseArea() )
    EndIf
        
    // https://tdn.totvs.com.br/display/framework/FWTemporaryTable
    oTempTable := FWTemporaryTable():New("TRB")
    
    // Arquivo TRB
    aAdd( aCampos, {'REDE'       ,"C"    ,TamSX3("ZF_REDE")[1]   , 0} )
    aAdd( aCampos, {'ORD'        ,"C"    ,1                      , 0} )
    aAdd( aCampos, {'TABELA'     ,"C"    ,3                      , 0} )
    aAdd( aCampos, {'FILIAL'     ,"C"    ,TamSX3("E1_FILIAL")[1] , 0} )
    aAdd( aCampos, {'PREFIXO'    ,"C"    ,TamSX3("E1_PREFIXO")[1], 0} )
    aAdd( aCampos, {'NUMERO'     ,"C"    ,TamSX3("E1_NUM")[1]    , 0} )
    aAdd( aCampos, {'PARCELA'    ,"C"    ,TamSX3("E1_PARCELA")[1], 0} )
    aAdd( aCampos, {'TIPO'       ,"C"    ,TamSX3("E1_TIPO")[1]   , 0} )
    aAdd( aCampos, {'CLIENTE'    ,"C"    ,TamSX3("E1_CLIENTE")[1], 0} )
    aAdd( aCampos, {'LOJA'       ,"C"    ,TamSX3("E1_LOJA")[1]   , 0} )
    aAdd( aCampos, {'DT'         ,"C"    ,8                      , 0} )
    aAdd( aCampos, {'TPMOV'      ,"C"    ,1                      , 0} )
    aAdd( aCampos, {'VALOR'      ,"N"    ,TamSX3("E1_VALOR")[1]  , TamSX3("E1_VALOR")[2]} )
    aAdd( aCampos, {'ACUMULADO'  ,"N"    ,TamSX3("E1_VALOR")[1]  , TamSX3("E1_VALOR")[2]} )

    oTempTable:SetFields(aCampos)
    oTempTable:AddIndex("01", {"REDE","DT","ORD"} )
    oTempTable:Create()

    // TITULOS DA REDE
    If Select("WorkTIT") > 0
        WorkTIT->( dbCloseArea() )
    EndIf
    
    cQuery := " SELECT 'TIT' AS TABELA, TIT.E1_FILIAL AS FILIAL, TIT.E1_PREFIXO AS PREFIXO, TIT.E1_NUM AS NUMERO, TIT.E1_PARCELA AS PARCELA, TIT.E1_TIPO AS TIPO, TIT.E1_CLIENTE AS CLIENTE, TIT.E1_LOJA AS LOJA, TIT.E1_NOMCLI AS NOME, TIT.E1_EMISSAO AS DATA, 'V' AS 'TPMOV', CASE WHEN TIT.E1_TIPO = 'AB-' THEN (TIT.E1_VALOR*-1) ELSE (TIT.E1_VALOR*1) END AS VALOR, RED.ZF_REDE
    cQuery += " FROM " + RetSqlName("SE1") + " TIT WITH (NOLOCK)
    cQuery += " INNER JOIN " + RetSqlName("SA1") + " CAD WITH (NOLOCK) ON (CAD.A1_COD = TIT.E1_CLIENTE) AND (CAD.A1_LOJA = TIT.E1_LOJA) AND CAD.D_E_L_E_T_ = ''
    cQuery += " LEFT JOIN " + RetSqlName("SZF") + " RED WITH (NOLOCK) ON (LEFT(CAD.A1_CGC,8) = RED.ZF_CGCMAT) AND RED.D_E_L_E_T_ = ''
    cQuery += " WHERE RED.ZF_REDE LIKE'%"+AllTrim(cZF_REDE)+"%' AND TIT.E1_PORTADO  NOT LIKE ('P%') AND TIT.D_E_L_E_T_ = '' AND TIT.E1_TIPO IN ('NF','AB-')
    cQuery += " AND TIT.E1_EMISSAO >= '"+cDtBase+"' 
    //cQuery += " AND TIT.E1_NUM='000697135' " // DEBUG - INIBIR

    tcQuery cQuery new Alias "WorkTIT"

    WorkTIT->( dbGoTop() )
    Do While WorkTIT->( !EOF() )

        RecLock("TRB", .T.)
            TRB->REDE    := cZF_REDE
            TRB->TABELA  := WorkTIT->TABELA
            TRB->FILIAL  := WorkTIT->FILIAL
            TRB->PREFIXO := WorkTIT->PREFIXO
            TRB->NUMERO  := WorkTIT->NUMERO
            TRB->PARCELA := WorkTIT->PARCELA
            TRB->TIPO    := WorkTIT->TIPO
            TRB->CLIENTE := WorkTIT->CLIENTE
            TRB->LOJA    := WorkTIT->LOJA
            TRB->DT      := WorkTIT->DATA
            TRB->TPMOV   := WorkTIT->TPMOV
            TRB->VALOR   := WorkTIT->VALOR
            TRB->ORD     := '1'
        TRB->( msUnLock() )
        
        // MOVIMENTOS DO TITULO DA REDE
        If Select("WorkSE5") > 0
            WorkSE5->( dbCloseArea() )
        EndIf

        cQuery := " SELECT DISTINCT(MOV.R_E_C_N_O_), 'MOV' AS TABELA, MOV.E5_FILIAL AS FILIAL, MOV.E5_PREFIXO AS PREFIXO, MOV.E5_NUMERO AS NUMERO, MOV.E5_PARCELA AS PARCELA, MOV.E5_TIPO AS TIPO, MOV.E5_CLIFOR AS CLIENTE, MOV.E5_LOJA AS LOJA, TIT.E1_NOMCLI AS NOME, MOV.E5_DATA AS DATA, MOV.E5_RECPAG AS 'TPMOV',
        cQuery += " CASE WHEN MOV.E5_TIPODOC = 'JR' THEN (MOV.E5_VALOR*1) ELSE (MOV.E5_VALOR*-1) END AS VALOR, RED.ZF_REDE
        cQuery += " FROM " + RetSqlName("SE5") + " MOV WITH (NOLOCK)
        cQuery += " INNER JOIN " + RetSqlName("SE1") + " TIT WITH (NOLOCK) ON (TIT.E1_FILIAL = MOV.E5_FILIAL) AND (TIT.E1_PREFIXO = MOV.E5_PREFIXO) AND (TIT.E1_NUM = MOV.E5_NUMERO) AND (TIT.E1_PARCELA = MOV.E5_PARCELA) AND (TIT.E1_CLIENTE = MOV.E5_CLIENTE) AND (TIT.E1_LOJA = MOV.E5_LOJA)
        cQuery += " INNER JOIN " + RetSqlName("SA1") + " CAD WITH (NOLOCK) ON (CAD.A1_COD = MOV.E5_CLIFOR) AND (CAD.A1_LOJA = MOV.E5_LOJA) AND MOV.D_E_L_E_T_ = ''
        cQuery += " LEFT JOIN " + RetSqlName("SZF") + " RED WITH (NOLOCK) ON (LEFT(CAD.A1_CGC,8) = RED.ZF_CGCMAT) AND RED.D_E_L_E_T_ = ''
        cQuery += " WHERE MOV.E5_FILIAL = '"+WorkTIT->FILIAL+"' AND MOV.E5_PREFIXO = '"+WorkTIT->PREFIXO+"' AND MOV.E5_TIPO = '"+WorkTIT->TIPO+"'
        cQuery += " AND MOV.E5_NUMERO = '"+WorkTIT->NUMERO+"' AND MOV.E5_PARCELA = '"+WorkTIT->PARCELA+"' AND MOV.E5_CLIFOR = '"+WorkTIT->CLIENTE+"' AND MOV.E5_LOJA = '"+WorkTIT->LOJA+"' AND MOV.D_E_L_E_T_ = '' AND MOV.E5_SITUACA <> 'C' AND MOV.E5_DTCANBX = ''
        cQuery += " AND MOV.E5_TIPODOC NOT IN ('ES')

        tcQuery cQuery New Alias "WorkSE5"

        Do While WorkSE5->( !EOF() )

            RecLock("TRB", .T.)
                TRB->REDE    := cZF_REDE
                TRB->TABELA  := WorkSE5->TABELA
                TRB->FILIAL  := WorkSE5->FILIAL
                TRB->PREFIXO := WorkSE5->PREFIXO
                TRB->NUMERO  := WorkSE5->NUMERO
                TRB->PARCELA := WorkSE5->PARCELA
                TRB->TIPO    := WorkSE5->TIPO
                TRB->CLIENTE := WorkSE5->CLIENTE
                TRB->LOJA    := WorkSE5->LOJA
                TRB->DT      := WorkSE5->DATA
                TRB->TPMOV   := WorkSE5->TPMOV
                TRB->VALOR   := WorkSE5->VALOR
                TRB->ORD     := '2'
            TRB->( msUnLock() )

            WorkSE5->( dbSkip() )

        EndDo

        WorkTIT->( dbSkip() )

    EndDo

    // Calcula maior acumulo
    TRB->( dbGoTop() )
    If TRB->( !EOF() )
        RecLock("TRB",.F.)
            TRB->ACUMULADO := TRB->VALOR
        TRB->( msUnLock() )
    EndIf

    TRB->( dbSkip() )
    Do While TRB->( !EOF() )

        TRB->( dbSkip(-1) )

        vValor := TRB->ACUMULADO

        TRB->( dbSkip() )

        RecLock("TRB",.F.)
            TRB->ACUMULADO := vValor+TRB->VALOR
        TRB->( msUnLock() )

        If TRB->DT >= cDtBase

            If (TRB->ACUMULADO > vValor) .and. (TRB->ACUMULADO > nVlAcum)
                cDtAcum := TRB->DT
                nVlAcum := TRB->ACUMULADO
            EndIf
        
        EndIf

        TRB->( dbSkip() )

    EndDo

    // Grava Rede
    SZF->( dbSetOrder(3) ) // ZF_FILIAL, ZF_REDE, R_E_C_N_O_, D_E_L_E_T_
    If SZF->( dbSeek(FWxFilial("SZF")+cZF_REDE) )

        Do While SZF->( !EOF() ) .and. SZF->ZF_FILIAL==FWxFilial("SZF") .and. SZF->ZF_REDE==cZF_REDE

            RecLock("SZF", .f.)
                SZF->ZF_VLACUMU := nVlAcum
                SZF->ZF_DTACUMU := StoD(cDtAcum)
            SZF->( msUnLock() )

            SZF->( dbSkip() )

        EndDo

    EndIf

    If Select("WorkTIT") > 0
		WorkTIT->( dbCloseArea() )
	EndIf

    If Select("WorkSE5") > 0
		WorkSE5->( dbCloseArea() )
	EndIf

	oTempTable:Delete()

Return
