#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} User Function nomeFunction
    Exporta para txt massa de dados relativos aos pedidos de compras/requisicoes por Centro de Custo.
    @type  Function
    @author Mauricio
    @since 01/06/2010
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
	@history chamado 050729  - FWNM         - 25/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
/*/
User Function EXPCC()  

    //Local _cRet := ""
    Private oGeraTxt
    Private _cPerg := "EXPCCU"
    Private _cArqTmp

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Exporta para txt massa de dados relativos aos pedidos de compras/requisicoes por Centro de Custo.')

    PutSx1(_cPerg,"01","Filial de           ?"    , "Filial de           ?"    , "Filial de           ?"    , "mv_ch1","C",2 ,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","")
    PutSx1(_cPerg,"02","Filial ate          ?"    , "Filial ate          ?"    , "Filial ate          ?"    , "mv_ch2","C",2 ,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","")
    PutSx1(_cPerg,"03","Da emissao          ?"    , "Da emissao          ?"    , "Da emissao          ?"    , "mv_ch3","D",8 ,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","")
    PutSx1(_cPerg,"04","Ate emissao         ?"    , "Ate emissao         ?"    , "Ate emissao         ?"    , "mv_ch4","D",8 ,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","")
    PutSx1(_cPerg,"05","Arquivo de saida    ?"    , "Arquivo de saida    ?"    , "Arquivo de saida    ?"    , "mv_ch5","C",50,0,0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")
    PutSx1(_cPerg,"06","C.Custos(Separar por , )?" , "C.Custos(Separar por , )?" , "C.Custos(Separar por , )?" , "mv_ch6","C",70,0,0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
    PutSx1(_cPerg,"07","C.Custos(Separar por , )?" , "C.Custos(Separar por , )?" , "C.Custos(Separar por , )?" , "mv_ch7","C",70,0,0,"G","","   ","","","mv_par07","","","","","","","","","","","","","","","","")
    PutSx1(_cPerg,"08","C.Custos(Separar por , )?" , "C.Custos(Separar por , )?" , "C.Custos(Separar por , )?" , "mv_ch8","C",70,0,0,"G","","   ","","","mv_par08","","","","","","","","","","","","","","","","")
    pergunte(_cPerg,.T.)

    dbSelectArea("SC7")
    dbSetOrder(1)

    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Montagem da tela de processamento.                                  Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

    @ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Geracao TXT de Projetos")
    @ 02,10 TO 080,190
    @ 10,018 Say " Este programa ira gerar um arquivo texto, conforme os parame- "
    @ 18,018 Say " tros definidos  pelo usuario,  com os registros referentes aos"
    @ 26,018 Say " movimentos por centro de custo(Pedidos de compras/Requisicoes)"

    @ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
    @ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)

    Activate Dialog oGeraTxt Centered

Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 25/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function OkGeraTxt

    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Cria o arquivo texto                                                Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

    Private nHdl    := fCreate(mv_par05)

    Private cEOL    := "CHR(13)+CHR(10)"
    If Empty(cEOL)
        cEOL := CHR(13)+CHR(10)
    Else
        cEOL := Trim(cEOL)
        cEOL := &cEOL
    Endif

    If nHdl == -1
        MsgAlert("O arquivo de nome "+mv_par05+" nao pode ser executado! Verifique os parametros.","Atencao!")
        Return
    Endif

    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Inicializa a regua de processamento                                 Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

    Processa({|| RunCont() },"Processando...") 

    // fecha arquivo temporario caso tenha sido criado
    If Select("PROJ") > 0
            DbSelectArea("PROJ")
            PROJ->(DbCloseArea())
            
            // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 25/06/2020
            If File(_cArqTmp+GetDBExtension()); fErase(_cArqTmp+GetDBExtension()); EndIf
            If File(_cArqTmp); fErase(_cArqTmp); EndIf
            /*
            If File(_cArqTmp+".DBF"); fErase(_cArqTmp+".DBF"); EndIf
            If File(_cArqTmp); fErase(_cArqTmp); EndIf
            */
    EndIf

Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 25/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunCont

    Local nTamLin, cLin, cCpo
    Local _cParcc := ALLTRIM(mv_par06)+ALLTRIM(mv_par07)+ALLTRIM(mv_par08)
    _aStr := {}

    AADD(_aStr,{'FILIAL'    ,"C",02})
    AADD(_aStr,{'PEDIDO'    ,"C",06})
    AADD(_aStr,{'REQUISICAO',"C",06})
    AADD(_aStr,{'NFISCAL'   ,"C",09})
    AADD(_aStr,{'SERIE'     ,"C",03})
    AADD(_aStr,{'DATAEMISS' ,"C",10})
    AADD(_aStr,{'ITEM'      ,"C",04})
    AADD(_aStr,{'CCUSTO'    ,"C",09})
    AADD(_aStr,{'CODFORNEC' ,"C",09})
    AADD(_aStr,{'NOME'      ,"C",40})
    AADD(_aStr,{'PRODUTO'   ,"C",15})
    AADD(_aStr,{'DESCRI'    ,"C",40})
    AADD(_aStr,{'QUANT'     ,"N",13,04})
    AADD(_aStr,{'UNIDA'     ,"C",02})
    AADD(_aStr,{'VALOR'     ,"N",17,02})
    AADD(_aStr,{'CONTA'     ,"C",20})
    AADD(_aStr,{'ENCERRADO' ,"C",01})
    AADD(_aStr,{'DTDIGNF'   ,"C",10})  &&Chamado 005696 - Mauricio.
    AADD(_aStr,{'APROV'     ,"C",01})
    AADD(_aStr,{'VALORNF'   ,"N",17,02}) &&Chamado 007139 - Mauricio.
    AADD(_aStr,{'NFDEVOL'   ,"C",09})  &&Chamado 007452 - Mauricio - inicio
    AADD(_aStr,{'SERDEV'    ,"C",03})  
    AADD(_aStr,{'VLRDEV'    ,"N",17,02})  
    AADD(_aStr,{'DTNFDEV'   ,"C",10})  &&Chamado 007452 - Mauricio - fim
    AADD(_aStr,{'OBSERV'    ,"C",30}) 
    AADD(_aStr,{'USUARIO'   ,"C",15})

    _cArqTmp :=CriaTrab(_aStr,.T.)
    DbUseArea(.T.,,_cArqTmp,"PROJ",.F.,.F.)
    _cIndex:="PEDIDO+ITEM"
    indRegua("PROJ",_cArqTmp,_cIndex,,,"Criando Indices...") 

    If Select ("PSD3") > 0
        DbSelectArea("PSD3")
        PSD3->(DbCloseArea())
    Endif

    _cQuery := "SELECT SD3.D3_FILIAL, SD3.D3_COD, SD3.D3_CONTA, SD3.D3_EMISSAO, SD3.D3_CC, SD3.D3_ESTORNO, SD3.D3_CUSTO1, SB1.B1_DESC, SD3.D3_DOC, SD3.D3_QUANT, SD3.D3_UM, SD3.D3_PROJETO, SD3.D3_USUARIO "
    _cQuery += "FROM "
    _cQuery += RetSqlName( "SD3" ) + " SD3, "
    _cQuery += RetSqlName( "SB1" ) + " SB1 "
    //_cQuery += "WHERE SD3.D3_PROJETO = '" + _cProjeto + "' "
    //_cQuery += "WHERE SD3.D3_PROJETO <> '         ' "
    _cQuery += "WHERE SD3.D3_CC IN ("+_cParcc+") "
    _cQuery += "AND SD3.D3_EMISSAO BETWEEN '" + DtoS( mv_par03 ) + "' AND '" + DtoS( mv_par04 ) + "' "
    _cQuery += "AND SD3.D3_FILIAL BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
    _cQuery += "AND SD3.D3_CF = 'RE0' "      && somente requisicoes.
    _cQuery += "AND SD3.D3_ESTORNO = ' ' "   &&somente nao estornados
    _cQuery += "AND SD3.D_E_L_E_T_ = '' "
    _cQuery += "AND SB1.B1_COD = SD3.D3_COD "
    //_cQuery += "AND SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' "
    _cQuery += "AND SB1.D_E_L_E_T_ = '' "
    _cQuery += "ORDER BY SD3.D3_EMISSAO "

    TcQuery _cQuery NEW ALIAS "PSD3"

    DbSelectArea("PSD3")
    DbGotop()
    While !EOF()
        RecLock("PROJ",.T.)
            PROJ->FILIAL     := PSD3->D3_FILIAL 
            PROJ->PEDIDO     := SPACE(06)
            PROJ->REQUISICAO := PSD3->D3_DOC
            PROJ->NFISCAL    := SPACE(09)
            PROJ->SERIE      := SPACE(03)
            PROJ->DATAEMISS  := substr(PSD3->D3_EMISSAO,7,2)+"/"+substr(PSD3->D3_EMISSAO,5,2)+"/"+substr(PSD3->D3_EMISSAO,1,4)
            PROJ->ITEM       := SPACE(04)
            PROJ->CCUSTO     := PSD3->D3_CC
            PROJ->CODFORNEC  := SPACE(09)
            PROJ->NOME       := SPACE(40)
            PROJ->PRODUTO    := PSD3->D3_COD
            PROJ->DESCRI     := SUBSTR(PSD3->B1_DESC,1,40)
            PROJ->QUANT      := PSD3->D3_QUANT
            PROJ->UNIDA      := PSD3->D3_UM
            PROJ->VALOR      := PSD3->D3_CUSTO1
            PROJ->CONTA      := PSD3->D3_CONTA
            PROJ->ENCERRADO  := "E"  //SPACE(01) Solicitado por fabiana vir sempre E - 15/01/10.
            PROJ->USUARIO    := SUBSTR(PSD3->D3_USUARIO,1,15)
            //PROJ->APROV      := " "  //NAO EXISTE APROVACAO PARA REQUISICOES.
        MsUnlock()
        DbSelectArea("PSD3")
        DbSkip()
    Enddo         
                
    If Select ("PSC7") > 0
        DbSelectArea("PSC7")
        PSC7->(DbCloseArea())
    Endif

    _cQuery1 := "SELECT SC7.C7_FILIAL, SC7.C7_PRODUTO, SC7.C7_EMISSAO, SC7.C7_CONTA, SC7.C7_ENCER, SC7.C7_CC, SC7.C7_QUJE, SC7.C7_QUANT, SC7.C7_TOTAL, "
    _cQuery1 += " SC7.C7_VALIPI, SC7.C7_NUM, SC7.C7_ITEM, SB1.B1_DESC, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NOME, SC7.C7_QUANT, SC7.C7_UM, SC7.C7_CONAPRO, "
    _cQuery1 += " SC7.C7_PROJETO, SC7.C7_OBS, SC7.C7_USER "
    _cQuery1 += "FROM "
    _cQuery1 += RetSqlName( "SC7" ) + " SC7, "
    _cQuery1 += RetSqlName( "SB1" ) + " SB1, "
    _cQuery1 += RetSqlName( "SA2" ) + " SA2 "
    //_cQuery1 += "WHERE SC7.C7_PROJETO <> '         ' "
    _cQuery1 += "WHERE SC7.C7_CC IN ("+_cParcc+") "
    _cQuery1 += "AND SC7.C7_EMISSAO BETWEEN '" + DtoS( mv_par03 ) + "' AND '" + DtoS( mv_par04 ) + "' "
    _cQuery1 += "AND SC7.C7_FILIAL BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
    _cQuery1 += "AND SC7.D_E_L_E_T_ = '' "
    _cQuery1 += "AND SB1.B1_COD = SC7.C7_PRODUTO "
    _cQuery1 += "AND SB1.D_E_L_E_T_ = '' "
    _cQuery1 += "AND SA2.A2_COD = SC7.C7_FORNECE "
    _cQuery1 += "AND SA2.A2_LOJA = SC7.C7_LOJA "
    _cQuery1 += "AND SA2.D_E_L_E_T_ = '' "
    _cQuery1 += "ORDER BY SC7.C7_NUM, SC7.C7_ITEM "

    TcQuery _cQuery1 NEW ALIAS "PSC7"

    DbSelectArea("PSC7")
    DbGotop()
    While !EOF()
        _cFIL    := PSC7->C7_FILIAL
        _cPEDIDO := PSC7->C7_NUM
        _cITEM   := PSC7->C7_ITEM
        
        If Select ("PSD1") > 0
            DbSelectArea("PSD1")
            PSD1->(DbCloseArea())
        Endif
        //_cQuery2 := "SELECT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_PEDIDO, SD1.D1_ITEMPC, SD1.D1_CUSTO, SD1.D1_DTDIGIT "
        _cQuery2 := "SELECT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_PEDIDO, SD1.D1_ITEMPC, SD1.D1_QUANT, SD1.D1_CUSTO, SD1.D1_DTDIGIT, SD1.D1_ITEM, SD1.D1_FORNECE, SD1.D1_LOJA "
        _cQuery2 += "FROM "
        _cQuery2 += RetSqlName( "SD1" ) + " SD1 "
        _cQuery2 += "WHERE SD1.D1_PEDIDO = '" + _cPEDIDO + "' "
        _cQuery2 += "AND SD1.D1_ITEMPC = '" + _cITEM + "' "
        _cQuery2 += "AND SD1.D1_FILIAL = '" + _cFIL + "' "
        _cQuery2 += "AND SD1.D_E_L_E_T_ = '' "
        
        TcQuery _cQuery2 NEW ALIAS "PSD1"
        
        DbSelectarea("PSD1")
        DBGOTOP()
        IF !EOF()
            While !EOF()
                _cNOTA := PSD1->D1_DOC
                _cSER  := PSD1->D1_SERIE
                _cDT   := PSD1->D1_DTDIGIT
                _nVlr  := PSD1->D1_CUSTO
                _cFOR  := PSD1->D1_FORNECE
                _cLOJ  := PSD1->D1_LOJA
                _cITE  := PSD1->D1_ITEM
                _nQTD  := PSD1->D1_QUANT
                
                &&Chamado 007452 - Mauricio.
                If Select ("PSD2") > 0
                    DbSelectArea("PSD2")
                    PSD2->(DbCloseArea())
                Endif
                
                _cQuery3 := "SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_QUANT, SD2.D2_TOTAL, SD2.D2_EMISSAO "
                _cQuery3 += "FROM "
                _cQuery3 += RetSqlName( "SD2" ) + " SD2 "
                _cQuery3 += "WHERE SD2.D2_NFORI = '" + _cNOTA + "' "
                _cQuery3 += "AND SD2.D2_SERIORI = '" + _cSER + "' "
                _cQuery3 += "AND SD2.D2_CLIENTE = '" + _cFOR + "' "
                _cQuery3 += "AND SD2.D2_LOJA = '" + _cLOJ + "' "
                _cQuery3 += "AND SD2.D2_ITEMORI = '" + _cITE + "' "
                _cQuery3 += "AND SD2.D_E_L_E_T_ = '' "
                
                TcQuery _cQuery3 NEW ALIAS "PSD2"
                
                DbSelectarea("PSD2")
                DBGOTOP()
                IF !EOF()
                    &&Tratamento para apurar valor proporcional para NF devolucao conforme acordado com Jair Sbaraini.
                    
                    _cNFDEV := PSD2->D2_DOC
                    _cSEDEV := PSD2->D2_SERIE
                    If _nQTD <> PSD2->D2_QUANT
                        _nVLDEV := Round((_nVlr/_nQTD)* PSD2->D2_QUANT,2)
                    Else
                        _nVLDEV := _nVlr
                    Endif
                    _dDTDEV := PSD2->D2_EMISSAO
                ELSE
                    _cNFDEV := SPACE(09)
                    _cSEDEV := SPACE(02)
                    _nVLDEV := 0.00
                    _dDTDEV := SPACE(10)
                ENDIF
                RecLock("PROJ",.T.)
                PROJ->FILIAL     := PSC7->C7_FILIAL
                PROJ->PEDIDO     := PSC7->C7_NUM
                PROJ->REQUISICAO := SPACE(06)
                PROJ->NFISCAL    := _cNOTA
                PROJ->SERIE      := _cSER
                PROJ->DATAEMISS  := substr(PSC7->C7_EMISSAO,7,2)+"/"+substr(PSC7->C7_EMISSAO,5,2)+"/"+substr(PSC7->C7_EMISSAO,1,4)
                PROJ->ITEM       := PSC7->C7_ITEM
                PROJ->CCUSTO     := PSC7->C7_CC
                PROJ->CODFORNEC  := PSC7->C7_FORNECE+"-"+PSC7->C7_LOJA
                PROJ->NOME       := SUBSTR(PSC7->A2_NOME,1,40)
                PROJ->PRODUTO    := PSC7->C7_PRODUTO
                PROJ->DESCRI     := SUBSTR(PSC7->B1_DESC,1,40)
                PROJ->QUANT      := PSC7->C7_QUANT
                PROJ->UNIDA      := PSC7->C7_UM
                PROJ->VALOR      := PSC7->C7_TOTAL + PSC7->C7_VALIPI
                PROJ->CONTA      := PSC7->C7_CONTA
                PROJ->ENCERRADO  := IIF(EMPTY(PSC7->C7_ENCER),IIF(PSC7->C7_QUJE > 0 .AND. PSC7->C7_QUJE < PSC7->C7_QUANT,"P","A"),PSC7->C7_ENCER)
                PROJ->DTDIGNF    := IIF(!EMPTY(_cDT),substr(_cDT,7,2)+"/"+substr(_cDT,5,2)+"/"+substr(_cDT,1,4),_cDT)
                PROJ->APROV      := PSC7->C7_CONAPRO
                PROJ->VALORNF    := _nVlr
                PROJ->NFDEVOL    := _cNFDEV
                PROJ->SERDEV     := _cSEDEV
                PROJ->VLRDEV     := _nVLDEV
                PROJ->DTNFDEV    := IIF(!EMPTY(_dDTDEV),substr(_dDTDEV,7,2)+"/"+substr(_dDTDEV,5,2)+"/"+substr(_dDTDEV,1,4),_dDTDEV)
                PROJ->OBSERV     := SUBSTR(PSC7->C7_OBS,1,30)
                PROJ->USUARIO    := SUBSTR(UsrRetName(PSC7->C7_USER),1,15)
                MsUnlock()
                DbSelectArea("PSD1")
                PSD1->(DbSkip())
            Enddo
        ELSE
            _cNOTA := SPACE(09)
            _cSER  := SPACE(03)
            _cDt   := SPACE(10)
            _nVlr  := 0
            _cNFDEV := SPACE(09)
            _cSEDEV := SPACE(02)
            _nVLDEV := 0.00
            _dDTDEV := SPACE(10)
            RecLock("PROJ",.T.)
            PROJ->FILIAL     := PSC7->C7_FILIAL
            PROJ->PEDIDO     := PSC7->C7_NUM
            PROJ->REQUISICAO := SPACE(06)
            PROJ->NFISCAL    := _cNOTA
            PROJ->SERIE      := _cSER
            PROJ->DATAEMISS  := substr(PSC7->C7_EMISSAO,7,2)+"/"+substr(PSC7->C7_EMISSAO,5,2)+"/"+substr(PSC7->C7_EMISSAO,1,4)
            PROJ->ITEM       := PSC7->C7_ITEM
            PROJ->CCUSTO     := PSC7->C7_CC
            PROJ->CODFORNEC  := PSC7->C7_FORNECE+"-"+PSC7->C7_LOJA
            PROJ->NOME       := SUBSTR(PSC7->A2_NOME,1,40)
            PROJ->PRODUTO    := PSC7->C7_PRODUTO
            PROJ->DESCRI     := SUBSTR(PSC7->B1_DESC,1,40)
            PROJ->QUANT      := PSC7->C7_QUANT
            PROJ->UNIDA      := PSC7->C7_UM
            PROJ->VALOR      := PSC7->C7_TOTAL + PSC7->C7_VALIPI
            PROJ->CONTA      := PSC7->C7_CONTA
            PROJ->ENCERRADO  := IIF(EMPTY(PSC7->C7_ENCER),IIF(PSC7->C7_QUJE > 0 .AND. PSC7->C7_QUJE < PSC7->C7_QUANT,"P","A"),PSC7->C7_ENCER)
            PROJ->DTDIGNF    := IIF(!EMPTY(_cDT),substr(_cDT,7,2)+"/"+substr(_cDT,5,2)+"/"+substr(_cDT,1,4),_cDT)
            PROJ->APROV      := PSC7->C7_CONAPRO
            PROJ->VALORNF    := _nVlr
            PROJ->NFDEVOL    := _cNFDEV
            PROJ->SERDEV     := _cSEDEV
            PROJ->VLRDEV     := _nVLDEV
            PROJ->DTNFDEV    := IIF(!EMPTY(_dDTDEV),substr(_dDTDEV,7,2)+"/"+substr(_dDTDEV,5,2)+"/"+substr(_dDTDEV,1,4),_dDTDEV)
            PROJ->OBSERV     := SUBSTR(PSC7->C7_OBS,1,30)
            PROJ->USUARIO    := SUBSTR(UsrRetName(PSC7->C7_USER),1,15)
            MsUnlock()
        ENDIF
        DbSelectArea("PSC7")
        DbSkip()
    Enddo

    dbSelectArea("PROJ")
    dbGoTop()

    ProcRegua(RecCount()) // Numero de registros a processar

    While !EOF()

        //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        //Ё Incrementa a regua                                                  Ё
        //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

        IncProc()

        //иммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩
        //╨ Lay-Out do arquivo Texto gerado:                                ╨
        //лммммммммммммммммяммммммммяммммммммммммммммммммммммммммммммммммммм╧
        //╨Campo           Ё Inicio Ё Tamanho                               ╨
        //гддддддддддддддддеддддддддеддддддддддддддддддддддддддддддддддддддд╤
        //╨ FILIAL         Ё 01     Ё 02                                    ╨
        //╨ PEDIDO         Ё 03     Ё 06                                    ╨
        //╨ REQUISICAO     Ё 09     Ё 06                                    ╨
        //╨ NOTA FISCAL    Ё 15     Ё 09                                    ╨
        //╨ SERIE          Ё 24     Ё 03                                    ╨
        //╨ EMISSAO        Ё 27     Ё 10                                    ╨
        //╨ ITEM           Ё 37     Ё 04                                    ╨
        //╨ CENTRO CUSTO   Ё 41     Ё 09                                    ╨
        //╨ COD FORNECEDOR Ё 50     Ё 09                                    ╨
        //╨ NOME FORNEC    Ё 59     Ё 40                                    ╨
        //╨ PRODUTO        Ё 99     Ё 15                                    ╨
        //╨ DESCRICAO PROD Ё 114    Ё 40
        //  QUANTIDADE       154      13
        //  UNIDADE MEDIDA   167      02                                    ╨
        //╨ VALOR          Ё 169    Ё 17                                    ╨
        //╨ CONTA          Ё 186    Ё 20                                    ╨
        //╨ ENCERRADO      Ё 206    Ё 01                                    ╨
        //╨ DTDIGNF        | 207    | 10									╨
        //  APROVADO         217      01
        //  VALORNF          218      17                                         
        //  NFDEVOL          235      09
        //  SERDEV           244      03  
        //  VLRDEV           247      17  
        //  DTNFDEV          264      10        
        //хммммммммммммммммоммммммммоммммммммммммммммммммммммммммммммммммммм╪
        
        nTamLin := 318 //273  //217
        cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao

        //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        //Ё Substitui nas respectivas posicioes na variavel cLin pelo conteudo  Ё
        //Ё dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     Ё
        //Ё string dentro de outra string.                                      Ё
        //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

        cCpo := PADR(PROJ->FILIAL,02)
        cLin := Stuff(cLin,01,02,cCpo)
        cCpo := PADR(PROJ->PEDIDO,06)
        cLin := Stuff(cLin,03,06,cCpo)
        cCpo := PADR(PROJ->REQUISICAO,06)
        cLin := Stuff(cLin,09,06,cCpo)
        cCpo := PROJ->NFISCAL
        cLin := Stuff(cLin,15,09,cCpo)
        cCpo := PROJ->SERIE
        cLin := Stuff(cLin,24,03,cCpo)        
        cCpo := PROJ->DATAEMISS
        cLin := Stuff(cLin,27,10,cCpo)            
        cCpo := PADR(PROJ->ITEM,04)
        cLin := Stuff(cLin,37,04,cCpo)
        cCpo := PADR(PROJ->CCUSTO,09)
        cLin := Stuff(cLin,41,09,cCpo)
        cCpo := PADR(PROJ->CODFORNEC,09)
        cLin := Stuff(cLin,50,09,cCpo)
        cCpo := PROJ->NOME
        cLin := Stuff(cLin,59,40,cCpo)                                                
        cCpo := PADR(PROJ->PRODUTO,15)
        cLin := Stuff(cLin,99,15,cCpo)
        cCpo := PROJ->DESCRI
        cLin := Stuff(cLin,114,40,cCpo)
        cCpo := Str(PROJ->QUANT,13,04)
                _ncount  := AT(".",cCpo)  &&Chamado 005342 - Mauricio HC Consys.
                _cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,4)
        cCpo := _cString
        cLin := Stuff(cLin,154,13,cCpo)        
        cCpo := PROJ->UNIDA
        cLin := Stuff(cLin,167,02,cCpo)                               
        cCpo := Str(PROJ->VALOR,17,02)
                _ncount  := AT(".",cCpo)  &&Chamado 005342 - Mauricio HC Consys.
                _cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
        cCpo := _cString    
        cLin := Stuff(cLin,169,17,cCpo)
        cCpo := PROJ->CONTA
        cLin := Stuff(cLin,186,20,cCpo)        
        cCpo := PROJ->ENCERRADO
        cLin := Stuff(cLin,206,01,cCpo)
        cCpo := PROJ->DTDIGNF
        cLin := Stuff(cLin,207,10,cCpo)
        cCpo := PROJ->APROV
        cLin := Stuff(cLin,217,01,cCpo)
        cCpo := Str(PROJ->VALORNF,17,02)  
                _ncount  := AT(".",cCpo)  
                _cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
        cCpo := _cString    
        cLin := Stuff(cLin,218,17,cCpo)    
        cCpo := PROJ->NFDEVOL
        cLin := Stuff(cLin,235,09,cCpo)
        cCpo := PROJ->SERDEV
        cLin := Stuff(cLin,244,03,cCpo)
        cCpo := Str(PROJ->VLRDEV,17,02)
                _ncount  := AT(".",cCpo)  
                _cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
        cCpo := _cString    
        cLin := Stuff(cLin,247,17,cCpo)            
        cCpo := PROJ->DTNFDEV    
        cLin := Stuff(cLin,264,10,cCpo)    
        cCpo := PROJ->OBSERV
        cLin := Stuff(cLin,274,30,cCpo)
        cCpo := PROJ->USUARIO
        cLin := Stuff(cLin,304,15,cCpo)        
        
        //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        //Ё Gravacao no arquivo texto. Testa por erros durante a gravacao da    Ё
        //Ё linha montada.                                                      Ё
        //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

        If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
                Exit
            Endif
        Endif
        DbSelectArea("PROJ")
        dbSkip()
    EndDo

    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё O arquivo texto deve ser fechado, bem como o dialogo criado na fun- Ё
    //Ё cao anterior.                                                       Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

    fClose(nHdl)
    Close(oGeraTxt) 

Return