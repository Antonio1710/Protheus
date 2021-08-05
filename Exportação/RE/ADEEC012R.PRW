#Include "protheus.ch"
#Include "TopConn.ch"
#include "colors.ch"
#Include "Font.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} User Function ADEEC012R U_ADEEC012R()
    Impressão da Ordem de Carregamento Exportação.
    Chamado 8765
    @type  Function
    @author Leonardo P. Monteiro
    @since 25/05/2021
    @version 01
    @history Chamado 8465 - Leonardo P. Monteiro - 18/07/2021 - Desenvolvimento inicial.
    @history Chamado 8465 - Leonardo P. Monteiro - 01/08/2021 - Inclusão de novos recuros e rastreabilidades no relatório.
    
/*/
#Define IMP_SPOOL  2
#Define IMP_PDF    1
#Define DMPAPER_A4 9

User Function ADEEC012R()
    Private aRet        := {}
    Private aParamBox   := {}

    Aadd( aParamBox ,{1,"Ped. Exportação"           ,Space(20)  ,"" ,'.T.',"",'.T.',80,.F.})
	aAdd( aParamBox	,{3,"Imprime Dec. Exportação"   ,1,{'Sim','Não'},100,"",.F.})
	aAdd( aParamBox	,{3,"Imprime Imagens"           ,1,{'Sim','Não'},100,"",.F.})
    aAdd( aParamBox	,{3,"Imprime dados embarque"   ,1,{'Sim','Não'},100,"",.F.})
    aAdd( aParamBox	,{3,"Imprime dados embalagens" ,1,{'Sim','Não'},100,"",.F.})
    //aAdd( aParamBox	,{3,"Imprime Dec. Exportação"   ,1,{'Sim','Não'},100,"",.F.})

    if ParamBox(aParamBox,"Parâmetros",@aRet)
        MsAguarde({|| fProcessa() },"Gerando...","Gerando o relatório, aguarde...")
    else
        msginfo("Operação cancelada pelo operador!")
    endif

return

Static function fProcessa()

    Local titulo   				:= "RELATÓRIO DE RESPALDO PARA CERTIFICAÇÃO"
    Local cPerg					:= "ADEEC012R"
    Local cNomRel				:= "ADEEC012R"
    Local nItens                := 0

    Local lAdjustToLegacy 		:= .F. 
    Local lDisableSetup  		:= .T.
    Local cMensagem             := ""
    Private nTotReg             := 0

    Private cEOL				:= chr(13)+Chr(10)
    
    Private oFOARNO04	  		:= TFont():New("Arial",07,04,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 05
    Private oFOARNO05	  		:= TFont():New("Arial",07,05,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 05
    Private oFOARNO06	  		:= TFont():New("Arial",07,06,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 06
    Private oFOARNO07	  		:= TFont():New("Arial",07,07,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 07
    Private oFOARNO08	  		:= TFont():New("Arial",07,08,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 08
    Private oFOARNO09	  		:= TFont():New("Arial",07,09,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 08
    Private oFOARNO10	 		:= TFont():New("Arial",09,10,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 15
    Private oFOARNO15	 		:= TFont():New("Arial",09,15,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 15
    Private oFOARIT15	 		:= TFont():New("Arial",09,15,.T.,.F.,,,,,.T.) // Arial, Normal,  Tam. 15

    Private oFOARNE05	 		:= TFont():New("Arial",09,05,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 05
    Private oFOARNE06	 		:= TFont():New("Arial",09,06,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 06
    Private oFOARNE07	 		:= TFont():New("Arial",09,07,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 07
    Private oFOARNE08	 		:= TFont():New("Arial",09,08,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 08
    Private oFOARNE09	 		:= TFont():New("Arial",09,09,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 09
    Private oFOARNE10	 		:= TFont():New("Arial",09,10,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 10
    Private oFOARNE15	 		:= TFont():New("Arial",09,15,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 15
    Private oFOARNE20	 		:= TFont():New("Arial",09,20,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 20
    Private oFOARNE25	 		:= TFont():New("Arial",09,25,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 25
    Private oFOARNE30	 		:= TFont():New("Arial",09,30,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 30
    Private oFOARNE35	 		:= TFont():New("Arial",09,35,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 35
    Private oPrint
    PRivate oBrush              := TBrush():New2( , Rgb(217,217,217) )
    
    //Private cLogo				:= AllTrim(GetMV("MV_XLOGOGV")) //Imagem dentro do SYSTEM
    
    Private cRelImp				:= ""
    default cPathPDF			:= fMakeDir("c:\relato\"+__CUSERID+"\")
    default cFileName			:= ""
    default lViewPdf			:= .T.
    default lGeraPdfServidor	:= .F.
    
    Private nRight 				:= 0
    Private nBottom	 			:= 0
    Private nRow 				:= 0
    Private nCol	 			:= 0
    Private nLinha              := 0
    Private nLimite             := 0
    Private cDataEmi            := Dtoc(Date())+" "+Alltrim(Time())
    Private nA                  := 0
    
    Private nIniLinha           := 0
    Private nRowImg             := 0
    Private aTpCond             := {}
    Private aColunas            := {}
    Private aLinhas             := {}
    Private aColTmp             := {}
    Private aItens              := {}
    
    Private dDtICar            := Stod("")
    Private dDtTCar            := Stod("")
    
    Private cEmbHIni            := ""
    Private cEmbHTer            := ""
    Private dLacData            := Stod("")
    Private cLacHora            := ""
    Private cLimpInt            := ""
    Private cLimpExt            := ""
    Private cTempBau            := ""
    Private cBorrach            := ""
    Private cEquipFr            := ""
    Private cLacArma            := ""
    Private cLacOfic            := ""
    Private cContain            := ""
    Private cTermog             := ""
    Private nTarCon             := 0
    Private cMonQua             := ""
    Private nPageAct            := 0
    
    //cRelImp := __CUSERID+"_"+cNomRel+"_"+DtoS(dDatabase)+Replace(Time(),":","")
    cRelImp := __CUSERID+"_"+cNomRel
    
    if empty(cFileName) == .F.
        cRelImp := cFileName
    endIf

    // Instânciação do Objeto OPrint
    //oPrint := TMSPrinter():New()
    IF FErase( "c:\relato\"+__CUSERID+"\"+cRelImp+".pdf" ) == -1
    EndIf
    If FErase("\relato\"+__CUSERID+"\"+cRelImp+".pdf" ) == -1
    EndIf
    
    If lGeraPdfServidor
        oPrinter     := FWMSPrinter():New(cRelImp, 2,.F.,,.T.,.F.,,"PDF",.T., .T., .F.,.F.)
    Else
        oPrinter := FWMsPrinter():New(cRelImp,6, lAdjustToLegacy,fMakeDir("c:\relato\"+__CUSERID+"\"), lDisableSetup)
    EndIf

    //oPrinter:SetLandscape()
    oPrinter:setPortrait()
    oPrinter:setPaperSize(DMPAPER_A4)
    oPrinter:cPathPDF 	 := cPathPDF
    oPrinter:lViewPDF	 := lViewPdf

    //oPrinter:SetMargin(50,50,50,50)                                                     
    oPrinter:lServer := .T.
    //oPrinter:Setup()
    
    //nRow := 32
    nRow := 05
    nCol := 23

    nRight  := oPrinter:nHorzSize()-010
    nBottom := oPrinter:nVertSize()-060
    nLinha  := 0
    nLimite := nBottom*0.95
    
    // Consulta o cabeçalho do processo de exportação.
    fGetQuery()
    
    TRB->(dbgotop()) 

    nQuantReg   := 1
    
    If TRB->(!EOF())
    
        While TRB->(!Eof())
            
            // Obtêm informações dos registros retornados pelo App da Qualidade
            // para compor as informações do cabeçalho.
            fGetInfo()

            if cContain != ALLTRIM(TRB->EE7_CONTAI ) .or. cLacOfic != ALLTRIM(TRB->EE7_NLACR2 )
                cMensagem := "- Encontramos informações divergentes entre o embarque e o pedido de exportação listadas abaixo."+cEOL+cEOL
                
                if Empty(TRB->C5_NOTA)
                    cMensagem += "- Pedido de exportação ainda não faturado. A NFe/Serie não inclusa no relatório." +cEOL
                endif

                if cLacOfic != ALLTRIM(TRB->EE7_CONTAI )
                    cMensagem += "- Container: Exportação ("+ iif(Empty(TRB->EE7_CONTAI),"Vazio", ALLTRIM(TRB->EE7_CONTAI )) +") e Embarque ("+ iif(Empty(cContain),"Vazio", cContain) +") " +cEOL
                endif
                
                if cLacOfic != ALLTRIM(TRB->EE7_NLACR2 )
                    cMensagem += "- Lacre Oficial: Exportação ("+ iif(Empty(TRB->EE7_NLACR2),"Vazio", ALLTRIM(TRB->EE7_NLACR2 ) ) +") e Embarque ("+ iif(Empty(cLacOfic),"Vazio", cLacOfic) +") " +cEOL
                endif

                MsgAlert(cMensagem, "Alerta")
            endif

            //----------------------------------------------------------------------------------------
            // Impressão dos itens do pedido de exportação e 
            // também os dados de carregamento enviados pelo App da qualidade.
            //----------------------------------------------------------------------------------------
            aItens  := fSqlItem()
            nItens  := Len(aItens)
            //-----------------------------------------------------
            // Impressão da sessão da Declaração de Exportação.
            //-----------------------------------------------------
            if MV_PAR02 == 1
                
                //aItens  := fSqlItDe()
                //nItens  := Len(aItens)
                nLinha      := 0
                nQuantReg   := 1
                nLimite     := nBottom*0.95

                for nA := 1 to nItens
                    
                    nQuantReg := 1

                    if aItens[nA][01] == "05"
                        fImpCabec(3)
                        // Imprime as linhas dos produtos.
                        fImpDec()
                        
                        nQuantReg += 1
                    endif
                next nA

                //QITEM->(DbcloseArea())
            endif
            
            nLinha      := 0
            nQuantReg   := 1
            nLimite     := nBottom*0.95

            for nA := 1 to nItens
                
                if aItens[nA][01] == "01"
                    if nLinha >= nLimite .or. nLinha == 0                        
                        fImpCabec(1)
                    endif

                    // Imprime as linhas dos produtos.
                    if aItens[nA][01] == "01"
                        fImpItens()
                    // Imprime as linhas de rastreabilidade (App)
                    //elseif aItens[nA][01] == "02" .or. aItens[nA][01] == "03"
                        //fImpRast()
                    endif

                    nQuantReg += 1
                endif
            next nA

            //QITEM->(DbcloseArea())

            //-----------------------------------------------------
            // Impressão da sessão de imagens.
            //-----------------------------------------------------
            if MV_PAR03 == 1
                //aItens  := fSqlImg()
                //nItens  := Len(aItens)
                
                // Reinicia a página para a sessão de imagens.
                nLinha      := 0
                nQuantReg   := 1
                nLimite     := nBottom*0.80

                for nA := 1 to nItens
                    if aItens[nA][01] == "04"
                        //if nQuantReg > 9 .OR. nQuantReg == 1
                        if nLinha >= nLimite .or. nLinha == 0
                            fImpCabec(2)
                            nRowImg     := (nBottom-nLinha)
                        endif

                        fImpImg()

                        nQuantReg += 1
                    endif
                next nA

            endif

            //----------------------------------------------------------------------------------------
            // Impressão dos dados de embarque Ad'oro.
            //----------------------------------------------------------------------------------------
            if MV_PAR04 == 1
                nLinha      := 0
                nQuantReg   := 1
                nLimite     := nBottom*0.95
                
                for nA := 1 to nItens
                    if aItens[nA][01] == "01" .or. aItens[nA][01] == "02" .or. aItens[nA][01] == "03"
                        //if nQuantReg > 9 .OR. nQuantReg == 1
                        if nLinha >= nLimite .or. nLinha == 0
                            fImpCabec(4)
                        endif

                        // Imprime as linhas dos produtos.
                        if aItens[nA][01] == "01"
                            fImpItens()
                        // Imprime as linhas de rastreabilidade (App)
                        elseif aItens[nA][01] == "02" .or. aItens[nA][01] == "03"
                            fImpRast()
                        endif

                        nQuantReg += 1
                    endif
                next nA

            endif
            
            //----------------------------------------------------------------------------------------
            // Impressão dos itens de rastreabilidade Ad'oro.
            //----------------------------------------------------------------------------------------
            if MV_PAR05 == 1
                nLinha      := 0
                nQuantReg   := 1
                nLimite     := nBottom*0.95
                nPageAct    := oPrinter:nPagecount
                
                for nA := 1 to nItens
                    if aItens[nA][01] == "01" .or. aItens[nA][01] == "06" .or. aItens[nA][01] == "07"
                    
                        if nLinha >= nLimite .or. nLinha == 0
                            fImpCabec(5)
                        endif

                        // Imprime as linhas dos produtos.
                        if aItens[nA][01] == "01"
                            fImpItens()
                        // Imprime as linhas de rastreabilidade (App)
                        elseif aItens[nA][01] == "06" .or. aItens[nA][01] == "07"
                            fImpEmba()
                        endif
                        
                        nPageAct    := oPrinter:nPagecount
                        nQuantReg += 1
                    endif
                next nA

            endif
            
            TRB->(DbSkip())
        EndDo
        
        // INCLUÍDA TRATATIVA PARA GERAR VIA JOB
        if lGeraPdfServidor
            File2Printer(cPathPDF + cFileName, "PDF" )
        endIf
        
        oPrinter:EndPage()
        If !lGeraPdfServidor
            oPrinter:Preview()
        Else
            oPrinter:Print()
        EndIf
        FreeObj(oPrinter)
        oPrinter := Nil 
    EndIF


    TRB->(DbCloseArea())

    IF FErase( "c:\relato\"+__CUSERID+"\"+cRelImp+".rel" ) == -1
    EndIf
    IF FErase("\relato\"+__CUSERID+"\"+cRelImp+".rel" ) == -1
    EndIf
    IF FErase( "\SPOOL\"+cRelImp+".rel" ) == -1
    EndIf

Return

/* Impressão da sessão da declaração da importação. */
Static Function fImpDec()
    Local nColDis   := nRight-nCol
    Local nAltura   := 0
    Local cObserv   := ""
    Local nObserv   := ""
    Local cLin      := ""
    LOCAL nLineLen  := 90 
    Local nTabSize  := 3
    Local lWrap     := .T.
    
    nAltura := 12
    aPerc   := {nCol, nRight*0.6, nRight*0.8, nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Say(nLinha+08, aPerc[01]+010 , "Código formulário: FORM-VP-QUA-0419", oFOARNE09)
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    oPrinter:Say(nLinha+08, aPerc[02]+010 , "Data da revisão: 07/07/2021", oFOARNE09)
    oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
    oPrinter:Say(nLinha+08, aPerc[03]+010 , "Revisão: 04", oFOARNE09)
    nLinha += nAltura

    nLinha += 30
    
    oPrinter:Say( nLinha, (nRight+nCol)/2-080 , "DECLARAÇÃO DE EXPORTAÇÃO", oFOARNO15)
    
    nLinha += 030
    oPrinter:Say( nLinha, nCol+010  , "De: "+ AllTrim(TRB->ZE0_RAZAO), oFOARNO15)
    nLinha += 17
    oPrinter:Say( nLinha, nCol+010  , "Ao SIF "+ ALLTRIM(TRB->ZE0_REGIST) +" - Equipe de Auditores Fiscais Federais Agropecuários", oFOARNO15)
    nLinha += 23
    oPrinter:Say( nLinha, nCol+010  , "Prezados AFFAs,", oFOARNO15)
    nLinha += 30
    oPrinter:Say( nLinha, nCol+010  , "        A empresa AD´ORO S/A, inscrita no CNPJ/MF nº "+ TRANSFORM(TRB->ZE0_CNPJ,"@R 99.999.999/9999-99") +", estabelecida na Estrada", oFOARNO15)
    nLinha += 13
    oPrinter:Say( nLinha, nCol+010  , "de acesso SP 053/332, Km 04, s/n, bairro do Mursa,  Várzea Paulista/SP,  CEP 13.226-400, vem por", oFOARNO15)
    nLinha += 13
    oPrinter:Say( nLinha, nCol+010  , "meio deste, apresentar ao Serviço de Inspeção Federal encaminhando a documentação, onde afirm-", oFOARNO15)
    nLinha += 13
    oPrinter:Say( nLinha, nCol+010  , "amos o seguinte carregamento:", oFOARNO15)
    nLinha += 20
    nAltura := 155
    oPrinter:Box(nLinha, nCol, nLinha+nAltura, nRight)
    nLinha += 13
    oPrinter:Say( nLinha, nCol+010  , "IDENTIFICAÇÃO DO ESTABELECIMENTO: "+ alltrim( TRB->ZE0_RAZAO ) +" ", oFOARNE15)
    nLinha += 17
    oPrinter:Say( nLinha, nCol+010  , "NÚMERO DE REFERÊNCIA DA SOLICITAÇÃO: Invoice "+ ALLTRIM(TRB->EE7_PEDIDO)  , oFOARNE15)
    nLinha += 17
    oPrinter:Say( nLinha, nCol+010  , "NÚMERO DA NOTA FISCAL: "+ ALLTRIM(TRB->C5_NOTA) +" - SÉRIE "+ ALLTRIM(TRB->C5_SERIE) +"", oFOARNE15)
    nLinha += 17
    oPrinter:Say( nLinha, nCol+010  , "PAÍS/MERCADO DE DESTINO: "+ ALLTRIM(TRB->YA_DESCR) +" ", oFOARNE15) 
    nLinha += 17
    oPrinter:Say( nLinha, nCol+010  , "LINGUA DE CERTIFICADO: Português / Inglês", oFOARNE15) 
    nLinha += 17
    oPrinter:Say( nLinha, nCol+010  , "MODELO DE CERTIFICADO: "+ Alltrim(TRB->ZEL_DESCRI) +" ", oFOARNE15) 
    nLinha += 17
    
    oPrinter:Say( nLinha, nCol+010  , "PRODUTO: "+ Alltrim(IIF(Empty(aItens[na][06]),aItens[na][05],aItens[na][06])) +" ", oFOARNE15) 
    nLinha += 17
    oPrinter:Say( nLinha, nCol+010  , "VOLUME UNITÁRIO: "+ Alltrim(Transform(aItens[nA][07] ,"@E 99,999,999")) +" caixas", oFOARNE15)
    nLinha += 17
    oPrinter:Say( nLinha, nCol+010  , "VOLUME LÍQUIDO: "+ Alltrim(Transform(aItens[nA][08] ,"@E 99,999,999.999")) +" kg", oFOARNE15)

    nLinha += 30
    
    cObserv := alltrim(aItens[nA][10])

    if !Empty(cObserv)
        nObserv := mlcount(cObserv,nLineLen, nTabSize, lWrap )
    
        For i := 1 to nObserv
            cLin := alltrim(memoline(cObserv,90,i, nLineLen, lWrap))
            oPrinter:Say( nLinha, nCol+iif(Upper(Left(cLin,1))==Left(cLin,1),020, 010), cLin, oFOARIT15)
            nLinha += 17
        Next i
    endif
    
    //oPrinter:Say( nLinha, nCol+025  , "Declaramos a conformidade de nossos elementos de inspeção e programas de auto controle,", oFOARIT15)
    //nLinha += 17
    //oPrinter:Say( nLinha, nCol+010  , "sendo que a EMPRESA atende aos requisitos apresentados na Certificação Sanitária em questão.", oFOARIT15)
    //nLinha += 17
    //oPrinter:Say( nLinha, nCol+010  , "", oFOARIT15)
    
    nLinha += 30
    oPrinter:Say( nLinha, nCol+010  , "       Os produtos a serem exportados não estão envolvidos em nenhuma ocorrência que os", oFOARNO15)
    nLinha += 13
    oPrinter:Say( nLinha, nCol+010  , "desabilitasse para o destino pretendido.", oFOARNO15)
    
    nLinha += 100
    oPrinter:Line(nLinha, nCol+nColDis*0.05 ,nLinha,nCol+nColDis*0.49)
    oPrinter:Line(nLinha, nCol+nColDis*0.51 ,nLinha,nCol+nColDis*0.95)
    //nLinha += 13
    //oPrinter:Say( nLinha, nCol+nColDis*0.35  , "Aline Andrades Zen da Silva", oFOARNO15)
    //nLinha += 13
    //oPrinter:Say( nLinha, nCol+nColDis*0.30  , "Coordenadora da Garantia da Qualidade", oFOARNO15)
return

/* Impressão de cabeçalho */
Static Function fImpCabec(nModelo)
    Local aPerc     := {}

    if !oPrinter:isFirstPage
        oPrinter:endpage()
    endif
    oPrinter:StartPage() 
    
    
    oPrinter:Box(nRow, nCol, nBottom, nRight)

    nLinha  := nRow
    nAltura := 46
    
    //------------------------------------------
    // Sessão 00 - Cabeçalho
    //------------------------------------------
    
    aPerc   := {nCol, nRight*0.2, nRight*0.8, nRight}
    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])

    oPrinter:SayBitmap(nLinha+04, aPerc[01]+018,"\imagens\Logo001.png", 44,33)
    oPrinter:Say( nLinha+023, aPerc[02]+(aPerc[03]-aPerc[02])/2-15 , "AD'ORO S/A", oFOARNE10)
    //if nModelo == 3
        //oPrinter:Say( nLinha+033, aPerc[02]+(aPerc[03]-aPerc[02])/2-030 , "Declaração para Exportação", oFOARNO09)
    //else
        oPrinter:Say( nLinha+033, aPerc[02]+(aPerc[03]-aPerc[02])/2-080 , "RELATÓRIO DE RESPALDO PARA CERTIFICAÇÃO", oFOARNO09)
    //endif    
    oPrinter:Say( nLinha+010, aPerc[03]+015 , "Data de Emissão:", oFOARNE09)
    oPrinter:Say( nLinha+020, aPerc[03]+015 , cDataEmi, oFOARNO09)
    oPrinter:Say( nLinha+030, aPerc[03]+015 , "Página:", oFOARNE09)
    oPrinter:Say( nLinha+040, aPerc[03]+015 , StrZero(oPrinter:nPagecount,3) +"/"+StrZero(nTotReg,3) , oFOARNO09)

    nLinha += nAltura

    // Impressão da sessão de itens de exportação/dados da produção (App da Qualidade).
    if nModelo == 1
        fModelo01()
    // Impressão da sessão de imagens e fotos.
    elseif nModelo == 2
        fModelo02()
    // Impressão da sessão da declaração para exportação
    elseif nModelo == 3
    
    // Dados do carregamento
    elseif nModelo == 4
        fModelo04()
    // Rastreabilidade
    elseif nModelo == 5
        fModelo05()
    endif

Return

/*/{Protheus.doc} fModelo05
    (long_description)
    @type  Static Function
    @author user
    @since 14/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fModelo05()
    
    //------------------------------------------
    // Sessão 13 - 11.Rastreabilidade:
    //------------------------------------------
    if aItens[nA][01] == "01"
        nAltura := 12

        aPerc   := {nCol, nRight*0.3, nRight*0.6, nRight*0.8, nRight}
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[05])
        oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[05] }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[01]+010 , "13. Rastreabilidade", oFOARNE09)
        
        nLinha += nAltura
        
        aPerc   := {nCol, round(nRight*0.15,0), round(nRight*0.25,0), round(nRight*0.70,0), round(nRight*0.80,0), round(nRight*0.90,0), nRight}
        nAltura := 20
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
        oPrinter:Say(nLinha+007, aPerc[01]+002 , "Nº Registro", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[01]+002 , "Rótulo", oFOARNE09)
        
        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say(nLinha+007, aPerc[02]+002 , "Código", oFOARNE09)

        oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
        oPrinter:Say(nLinha+007, aPerc[03]+002 , "Nome Produto", oFOARNE09)

        oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
        oPrinter:Say(nLinha+007, aPerc[04]+002 , "Quantidade", oFOARNE09)

        oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aPerc[06])
        oPrinter:Say(nLinha+007, aPerc[05]+002 , "Líquido (KG)", oFOARNE09)

        oPrinter:Box(nLinha, aPerc[06], nLinha+nAltura, aPerc[07])
        oPrinter:Say(nLinha+007, aPerc[06]+002 , "Bruto (KG)", oFOARNE09)

        nLinha += nAltura
    endif

Return

/*/{Protheus.doc} fModelo04
    (long_description)
    @type  Static Function
    @author user
    @since 14/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fModelo04()
    
    //------------------------------------------
    // Sessão 12 - 12.Dados do Carregamento
    //------------------------------------------
    
    nAltura := 12

    aPerc   := {nCol, nRight*0.3, nRight*0.6, nRight*0.8, nRight}
    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[05])
    oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[05] }, oBrush )
    oPrinter:Say( nLinha+08, aPerc[01]+010 , "12. Dados do Embarque", oFOARNE09)
    
    nLinha += nAltura
    
    aPerc   := {nCol, round(nRight*0.15,0), round(nRight*0.25,0), round(nRight*0.70,0), round(nRight*0.80,0), round(nRight*0.90,0), nRight}
    nAltura := 20
    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Say(nLinha+007, aPerc[01]+002 , "Nº Registro", oFOARNE09)
    oPrinter:Say(nLinha+017, aPerc[01]+002 , "Rótulo", oFOARNE09)
    
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    oPrinter:Say(nLinha+007, aPerc[02]+002 , "Código", oFOARNE09)

    oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
    oPrinter:Say(nLinha+007, aPerc[03]+002 , "Nome Produto", oFOARNE09)

    oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
    oPrinter:Say(nLinha+007, aPerc[04]+002 , "Quantidade", oFOARNE09)

    oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aPerc[06])
    oPrinter:Say(nLinha+007, aPerc[05]+002 , "Líquido (KG)", oFOARNE09)

    oPrinter:Box(nLinha, aPerc[06], nLinha+nAltura, aPerc[07])
    oPrinter:Say(nLinha+007, aPerc[06]+002 , "Bruto (KG)", oFOARNE09)

    nLinha += nAltura    
    
Return

/*/{Protheus.doc} fModelo02
    (long_description)
    @type  Static Function
    @author user
    @since 14/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fModelo02()
    
    //------------------------------------------
    // Sessão 11 - 11.Fotos e Imagens:
    //------------------------------------------
    
    nAltura := 12

    aPerc   := {nCol, nRight*0.3, nRight*0.6, nRight*0.8, nRight}
    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[05])
    oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[05] }, oBrush )
    oPrinter:Say( nLinha+08, aPerc[01]+010 , "11. Imagens", oFOARNE09)

    nLinha += nAltura
    
    
Return


/*/{Protheus.doc} fModelo01
    (long_description)
    @type  Static Function
    @author user
    @since 14/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fModelo01()
    
    if nQuantReg == 1
        //------------------------------------------
        // Sessão 01 - 1.Informação de Embarque:
        //------------------------------------------
        
        nAltura := 12

        aPerc   := {nCol, nRight*0.2, nRight*0.4, nRight*0.6, nRight*0.8, nRight}

        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[06])
        oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[06] }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[01]+010 , "1. Informação de Embarque", oFOARNE09)

        nLinha += nAltura

        nAltura := 20
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
        oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
        oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aPerc[06])

        oPrinter:Say(nLinha+007, aPerc[01]+002 , "Nº Invoice", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[01]+010 , TRB->EE7_PEDIDO , oFOARNO09)

        oPrinter:Say(nLinha+007, aPerc[02]+002 , "Nº Ordem Coleta:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[02]+010 , IIF(EMPTY(TRB->EE7_XORDCO),"", TRB->EE7_XORDCO) , oFOARNO09)

        oPrinter:Say(nLinha+007, aPerc[03]+002 , "Térmografo no Carregamento:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[03]+010 , iif(TRB->EE7_XOPCTE=="S","Sim","Não") , oFOARNO09)
        
        oPrinter:Say(nLinha+007, aPerc[04]+002 , "Nº Termógrafo:", oFOARNE09)
        if Empty(cTermog) .and. Empty(TRB->EE7_XCODTE)
            oPrinter:Say(nLinha+017, aPerc[04]+010 , "não se aplica" , oFOARNO09)
        elseif !Empty(cTermog)
            oPrinter:Say(nLinha+017, aPerc[04]+010 , cTermog , oFOARNO09)
        else
            oPrinter:Say(nLinha+017, aPerc[04]+010 , TRB->EE7_XCODTE, oFOARNO09)
        endif
        
        oPrinter:Say(nLinha+007, aPerc[05]+002 , "Temp. Padrão:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[05]+010 , "-18 °C" , oFOARNO09)

        nLinha += nAltura

        //------------------------------------------
        // Sessão 02 - Identificação
        // Sessão 03 - Dados do Faturamento
        //------------------------------------------
        
        nAltura := 12
        
        aPerc   := {nCol, nRight*0.25, nRight*0.5, nRight*0.75, nRight}
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[03])
        oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[03] }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[01]+010 , "2. Identificação", oFOARNE09)
        //oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, nRight)
        oPrinter:fillRect( { nLinha, aPerc[03], nLinha+nAltura, nRight }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[03]+010 , "3. Dados do Faturamento", oFOARNE09)
        
        nLinha += nAltura

        nAltura := 20
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
        oPrinter:Say( nLinha+007, aPerc[01]+002 , "Nº Ordem Embarque (Invoice):", oFOARNE09)
        oPrinter:Say(nLinha+0017, aPerc[01]+010 , TRB->EE7_PEDIDO , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say( nLinha+007, aPerc[02]+002 , "Data de Estufagem:", oFOARNE09)
        oPrinter:Say(nLinha+0017, aPerc[02]+010 , DTOC(STOD(TRB->C5_DTENTR)) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
        oPrinter:Say( nLinha+007, aPerc[03]+002 , "Pedido:", oFOARNE09)
        oPrinter:Say(nLinha+0017, aPerc[03]+010 , Alltrim(TRB->EE7_PEDFAT) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
        oPrinter:Say( nLinha+007, aPerc[04]+002 , "Roteiro:", oFOARNE09)
        oPrinter:Say(nLinha+0017, aPerc[04]+010 , Alltrim(TRB->C5_ROTEIRO ) , oFOARNO09)

        nLinha += nAltura

        //------------------------------------------
        // Sessão 04 - Dados do Veículo
        //------------------------------------------
        
        nAltura := 12

        aPerc   := {nCol, nRight*0.7, nRight}
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[03])
        oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[03] }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[01]+010 , "4. Dados do Veículo", oFOARNE09)
        
        nLinha += nAltura

        nAltura := 20
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
        oPrinter:Say(nLinha+007, aPerc[01]+002 , "Transportadora:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[01]+010 , ALLTRIM(TRB->A4_NOME) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say(nLinha+007, aPerc[02]+002 , "Placa:", oFOARNE09)
        oPrinter:Say(nLinha+0017, aPerc[02]+010 , alltrim(TRB->C5_PLACA ) , oFOARNO09)

        nLinha += nAltura

        //------------------------------------------
        // Sessão 05 - Dados do Embarque
        //------------------------------------------
        
        nAltura := 12

        aPerc   := {nCol, nRight*0.4, nRight*0.6, nRight*0.8, nRight}
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[05])
        oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[05] }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[01]+010 , "5. Dados do Embarque", oFOARNE09)
        
        nLinha += nAltura

        nAltura := 20
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
        oPrinter:Say(nLinha+007, aPerc[01]+002 , "Navio/Transportador:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[01]+010 , ALLTRIM(TRB->EE7_XEMBAR ) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say(nLinha+007, aPerc[02]+002 , "Nº Container:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[02]+010 , IIF(Empty(cContain), ALLTRIM(TRB->EE7_CONTAI ), alltrim(cContain)) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
        oPrinter:Say(nLinha+007, aPerc[03]+002 , "Nº Lacre Oficial:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[03]+010 , ALLTRIM(IIF(empty(cLacOfic), TRB->EE7_NLACR2,alltrim(cLacOfic)) ) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
        oPrinter:Say(nLinha+007, aPerc[04]+002 , "Tara:", oFOARNE09)
        
        if nTarCon == 0 .and. TRB->EE7_XTARA == 0
            oPrinter:Say(nLinha+017, aPerc[04]+010 , "não se aplica" , oFOARNO09)
        elseif nTarCon > 0
            oPrinter:Say(nLinha+017, aPerc[04]+010 , TRANSFORM( nTarCon, "@E 999999") , oFOARNO09)
        else
            oPrinter:Say(nLinha+017, aPerc[04]+010 , TRANSFORM(TRB->EE7_XTARA, "@E 999999") , oFOARNO09)
        endif

        nLinha += nAltura

        //------------------------------------------
        // Sessão 06 - Destino
        //------------------------------------------
        
        nAltura := 12

        aPerc   := {nCol, nRight*0.20, round(nRight*0.50,0), nRight}
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, nRight)
        oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, nRight }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[01]+010 , "6. Destino", oFOARNE09)
        
        nLinha += nAltura

        nAltura := 40
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
        oPrinter:Say(nLinha+007, aPerc[01]+002 , "País:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[01]+010 , ALLTRIM(TRB->YA_DESCR ) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say(nLinha+007, aPerc[02]+002 , "Nome/Importador:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[02]+010 , ALLTRIM(TRB->CONSIG ) , oFOARNO08)
        
        oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
        //IF len(alltrim(TRB->A1_END)) > 60
            oPrinter:Say(nLinha+007, aPerc[03]+002 , "Endereço:", oFOARNE08)
            cEnd := Alltrim(TRB->EE7_MENSG)+Alltrim(TRB->EE7_MENSG2)+Alltrim(TRB->EE7_MENSG3)
            cEnd := Replace(cEnd,"IMPORTADOR: ","")
            if Len(cEnd) > 60
                oPrinter:Say(nLinha+017, aPerc[03]+010 , Left(cEnd,60) , oFOARNO07)
                oPrinter:Say(nLinha+027, aPerc[03]+010 , substr(cEnd,61, len(cEnd))  , oFOARNO07)
            else
                oPrinter:Say(nLinha+017, aPerc[03]+010 , cEnd , oFOARNO07)
            endif

            //oPrinter:Say(nLinha+017, aPerc[03]+010 , alltrim(TRB->A1_END) , oFOARNO07)
            //oPrinter:Say(nLinha+027, aPerc[03]+010 , alltrim(TRB->A1_COMPLEM)+"-"+Alltrim(TRB->YA_DESCR) , oFOARNO07)
        /*
        else
            oPrinter:Say(nLinha+007, aPerc[03]+002 , "Endereço:", oFOARNE09)
            oPrinter:Say(nLinha+017, aPerc[03]+010 , alltrim(TRB->A1_END) , oFOARNO09)
            oPrinter:Say(nLinha+027, aPerc[03]+010 , alltrim(TRB->A1_COMPLEM)+"-"+Alltrim(TRB->YA_DESCR) , oFOARNO09)
        endif
        */

        nLinha += nAltura

        //------------------------------------------
        // Sessão 07 - Dados do Cliente
        //------------------------------------------
        
        nAltura := 12

        aPerc   := {nCol, nRight*0.7, nRight}
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[03])
        oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[03] }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[01]+010 , "7. Dados do Cliente", oFOARNE09)
        
        nLinha += nAltura

        nAltura := 20
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
        oPrinter:Say(nLinha+007, aPerc[01]+002 , "Cliente/Consignee:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[01]+010 , ALLTRIM(TRB->A1_NOME ) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say(nLinha+007, aPerc[02]+002 , "Booking:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[02]+010 , ALLTRIM(TRB->EE7_XBOOKI ) , oFOARNO09)
        
        nLinha += nAltura

        //------------------------------------------
        // Sessão 08 - Dados dw Carregamento
        //------------------------------------------
        
        nAltura := 12

        aPerc   := {nCol, nRight*0.20, nRight*0.40, nRight*0.60, nRight}
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[05])
        oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[05] }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[01]+010 , "8. Dados de Carregamento", oFOARNE09)
        
        nLinha += nAltura
        
        nAltura := 20
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
        oPrinter:Say(nLinha+007, aPerc[01]+002 , "Início Carregamento:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[01]+010 , alltrim(dToc(dDtICar) +" "+ cEmbHIni) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say(nLinha+007, aPerc[02]+002 , "Hora término Carregamento:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[02]+010 , ALLTRIM(dToc(dDtTCar) +" "+ cEmbHTer) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
        oPrinter:Say(nLinha+007, aPerc[03]+002 , "Data/Hora lacre:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[03]+010 , ALLTRIM(dToc(dLacData) +" "+ cLacHora) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
        oPrinter:Say(nLinha+007, aPerc[04]+002 , "Monitor da Qualidade:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[04]+010 , ALLTRIM(cMonQua) , oFOARNO09)

        nLinha += nAltura

        //------------------------------------------
        // Sessão 09 - Condições do Veículo
        //------------------------------------------
        
        nAltura := 12

        aPerc   := {nCol, nRight*0.20, nRight*0.40, nRight*0.60, nRight*0.80, nRight}
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[06])
        oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, aPerc[06] }, oBrush )
        oPrinter:Say( nLinha+08, aPerc[01]+010 , "9. Condições do Veículo", oFOARNE09)
        
        nLinha += nAltura

        nAltura := 20
        oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
        oPrinter:Say(nLinha+007, aPerc[01]+002 , "Limpeza Interna:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[01]+010 , ALLTRIM(cLimpInt) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say(nLinha+007, aPerc[02]+002 , "Limpeza Externa:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[02]+010 , ALLTRIM(cLimpExt) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
        oPrinter:Say(nLinha+007, aPerc[03]+002 , "Temperatura do Baú:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[03]+010 , alltrim(cTempBau) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
        oPrinter:Say(nLinha+007, aPerc[04]+002 , "Borracha:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[04]+010 , ALLTRIM(cBorrach) , oFOARNO09)

        oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aPerc[06])
        oPrinter:Say(nLinha+007, aPerc[05]+002 , "Equipamento de frio adequado:", oFOARNE09)
        oPrinter:Say(nLinha+017, aPerc[05]+010 , ALLTRIM(cEquipFr) , oFOARNO09)

        nLinha += nAltura
    
    ENDIF

    //------------------------------------------
    // Sessão 10 - Identificação de carga
    //------------------------------------------
    
    nAltura := 12

    aPerc   := {nCol, round(nRight*0.15,0), round(nRight*0.25,0), round(nRight*0.70,0), round(nRight*0.80,0), round(nRight*0.90,0), nRight}
    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, nRight)
    oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, nRight }, oBrush )
    oPrinter:Say( nLinha+08, aPerc[01]+010 , "10. Identificação de carga", oFOARNE09)
    
    nLinha += nAltura
    
    nAltura := 20
    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Say(nLinha+007, aPerc[01]+002 , "Nº Registro", oFOARNE09)
    oPrinter:Say(nLinha+017, aPerc[01]+002 , "Rótulo", oFOARNE09)
    
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    oPrinter:Say(nLinha+007, aPerc[02]+002 , "Código", oFOARNE09)

    oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
    oPrinter:Say(nLinha+007, aPerc[03]+002 , "Nome Produto", oFOARNE09)

    oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
    oPrinter:Say(nLinha+007, aPerc[04]+002 , "Quantidade", oFOARNE09)

    oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aPerc[06])
    oPrinter:Say(nLinha+007, aPerc[05]+002 , "Líquido (KG)", oFOARNE09)

    oPrinter:Box(nLinha, aPerc[06], nLinha+nAltura, aPerc[07])
    oPrinter:Say(nLinha+007, aPerc[06]+002 , "Bruto (KG)", oFOARNE09)

    nLinha += nAltura

return

Static function fImpImg()
    Local nColDis   := nRight-nCol
    Local nWeid     := 0
    Local cLabel    := ""

    aPerc   := {nCol, round(nCol+nColDis*0.025,2), round((nColDis)*0.95,0), nRight}

    nLinha += 010

    if aItens[nA][06] == "LabelCamera"
        cLabel := "Etiqueta do produto - " + aItens[nA][04]
    elseif aItens[nA][06] == "ThermographCamera"
        cLabel := "Temperatura - " + aItens[nA][04]
    else
        cLabel := aItens[nA][04]
    endif
    oPrinter:Say(nLinha+002, aPerc[02]+002 , cLabel , oFOARNE07)
    
    nLinha += 010
    
    
    nAltura := nRowImg/2*0.90
    //nLinha += nAltura
    nWeid := nAltura*0.75/2

    if left(aItens[nA][04],3) != "Plt"
        oPrinter:SayBitmap(nLinha, ((aPerc[03]-aPerc[02])/2)-nWeid, aItens[nA][05], ((aPerc[03]-aPerc[02])/2)+nWeid, nAltura )
    else
        oPrinter:SayBitmap(nLinha, aPerc[02], aItens[nA][05], aPerc[03], nAltura )
    endif

    nLinha += nAltura
return


Static Function fImpItens()
    Local cDescri   := ""
    Local nQuebra   := 50

    nAltura := 17

    aPerc   := {nCol, round(nRight*0.15,0), round(nRight*0.25,0), round(nRight*0.70,0), round(nRight*0.80,0), round(nRight*0.90,0), nRight}

    // Nº registro rótulo
    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Say(nLinha+007, aPerc[01]+002 , aItens[nA][03] , oFOARNE07)
    
    // código
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    oPrinter:Say(nLinha+007, aPerc[02]+002 , aItens[nA][04] , oFOARNE07)
    
    // Nome do produto
    oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
    if Empty(aItens[nA][06])
        cDescri := aItens[nA][05]
    else
        cDescri := aItens[nA][06]
    endif

    if Len(cDescri) <= nQuebra
        oPrinter:Say(nLinha+007, aPerc[03]+002 , cDescri, oFOARNE07)
    else
        oPrinter:Say(nLinha+005, aPerc[03]+002 , Left(cDescri,nQuebra), oFOARNE06)
        oPrinter:Say(nLinha+015, aPerc[03]+002 , Substring(cDescri,nQuebra+1, Len(cDescri)), oFOARNE06)
    endif

    // Quantidade
    oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
    oPrinter:Say(nLinha+007, aPerc[04]+002 , Transform(aItens[nA][07] ,"@E 99,999,999.999"), oFOARNE07)

    // Líquido (KG)
    oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aPerc[06])
    oPrinter:Say(nLinha+007, aPerc[05]+002 , Transform(aItens[nA][08] ,"@E 99,999,999.999"), oFOARNE07)

    // Bruto (KG)
    oPrinter:Box(nLinha, aPerc[06], nLinha+nAltura, aPerc[07])
    oPrinter:Say(nLinha+007, aPerc[06]+002 , Transform(aItens[nA][09] ,"@E 99,999,999.999"), oFOARNE07)

    nLinha += nAltura
Return

/* Impressão dos itens de rastreabilidade */
Static Function fImpRast()
    Local cDescri   := ""
    Local nQuebra   := 50
    Local nColDis   := nRight-nCol


    aPerc   := {nCol,; 
                round(nCol+nColDis*0.025,2),; 
                round(nCol+nColDis*0.095,0),;
                round(nCol+nColDis*0.245,0),;
                round(nCol+nColDis*0.395,0),; 
                round(nCol+nColDis*0.485,0),;
                round(nCol+nColDis*0.655,0),;
                round(nCol+nColDis*0.805,0),;
                round(nCol+nColDis*0.975,0),; 
                nRight}

    if aItens[nA][02] == 1
            nAltura := 12

            oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, nRight)
            oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, nRight }, oBrush )
            oPrinter:Say(nLinha+008, aPerc[01]+015 , "12.1 Dados do Embarque - Itens " , oFOARNE07)
            
            nLinha += nAltura
            nAltura := 17
            nLinha += 5
            oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aperc[03])
            oPrinter:Say(nLinha+007, aPerc[02]+002 , ":.. Item" , oFOARNE07)

            oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aperc[04])
            oPrinter:Say(nLinha+007, aPerc[03]+002 , ":.. Data Fabricação " , oFOARNE07)
            
            oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aperc[05])
            oPrinter:Say(nLinha+007, aPerc[04]+002 , ":.. Data Validade " , oFOARNE07)
            
            oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aperc[06])
            oPrinter:Say(nLinha+007, aPerc[05]+002 , ":.. Lote/Turno " , oFOARNE07)

            oPrinter:Box(nLinha, aPerc[06], nLinha+nAltura, aperc[07])
            oPrinter:Say(nLinha+007, aPerc[06]+002 , ":.. Temperatura " , oFOARNE07)
            
            oPrinter:Box(nLinha, aPerc[07], nLinha+nAltura, aperc[08])
            oPrinter:Say(nLinha+007, aPerc[07]+002 , ":.. Qtd. Caixa " , oFOARNE07)
            
            oPrinter:Box(nLinha, aPerc[08], nLinha+nAltura, aperc[09])
            oPrinter:Say(nLinha+007, aPerc[08]+002 , ":.. Peso Venda " , oFOARNE07)

            nLinha += nAltura
    endif

    nAltura := 12

    // Impressão dos itens da rastreabilidade
    if aItens[nA][01] == "02"
        // Item
        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say(nLinha+008, aPerc[02]+008 , aItens[nA][03] , oFOARNE07)

        // Data de Fabricação
        oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
        oPrinter:Say(nLinha+008, aPerc[03]+022 , aItens[nA][04] , oFOARNE07)
        
        // Data de Validade
        oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
        oPrinter:Say(nLinha+008, aPerc[04]+022 , aItens[nA][05] , oFOARNE07)
        
        // Lote/Turno
        oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aPerc[06])
        oPrinter:Say(nLinha+008, aPerc[05]+020 , aItens[nA][06], oFOARNE07)

        // Temperatura
        oPrinter:Box(nLinha, aPerc[06], nLinha+nAltura, aPerc[07])
        if Len(Alltrim(aItens[nA][07])) > 9
            oPrinter:Say(nLinha+008, aPerc[06]+002 , Alltrim(aItens[nA][07]), oFOARNE06)
        else
            oPrinter:Say(nLinha+008, aPerc[06]+017 , Alltrim(aItens[nA][07]), oFOARNE07)
        endif

        // Qtd. Caixa
        oPrinter:Box(nLinha, aPerc[07], nLinha+nAltura, aPerc[08])
        oPrinter:Say(nLinha+008, aPerc[07]+037 , Transform(aItens[nA][08] ,"@E 99,999,999.9999"), oFOARNE07)

        // Peso venda
        oPrinter:Box(nLinha, aPerc[08], nLinha+nAltura, aPerc[09])
        oPrinter:Say(nLinha+008, aPerc[08]+037 , Transform(aItens[nA][09] ,"@E 99,999,999.9999"), oFOARNE07)
    elseif aItens[nA][01] == "03"
        // Total
        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[07])
        oPrinter:Say(nLinha+008, aPerc[02]+008 , alltrim(aItens[nA][03]) , oFOARNE07)

        // Qtd. Caixa
        oPrinter:Box(nLinha, aPerc[07], nLinha+nAltura, aPerc[08])
        oPrinter:Say(nLinha+008, aPerc[07]+037 , Transform(aItens[nA][04] ,"@E 99,999,999.9999"), oFOARNE07)

        // Peso venda
        oPrinter:Box(nLinha, aPerc[08], nLinha+nAltura, aPerc[09])
        oPrinter:Say(nLinha+008, aPerc[08]+037 , Transform(aItens[nA][05] ,"@E 99,999,999.9999"), oFOARNE07)
    endif

    nLinha += nAltura

return


/* Impressão dos itens de rastreabilidade - embalagens */
Static Function fImpEmba()
    Local cDescri   := ""
    Local nQuebra   := 50
    Local nColDis   := nRight-nCol


    aPerc   := {nCol,; 
                round(nCol+nColDis*0.025,2),; 
                round(nCol+nColDis*0.095,0),;
                round(nCol+nColDis*0.245,0),;
                round(nCol+nColDis*0.395,0),; 
                round(nCol+nColDis*0.525,0),;
                round(nCol+nColDis*0.655,0),;
                round(nCol+nColDis*0.805,0),;
                round(nCol+nColDis*0.975,0),; 
                nRight}

    //if aItens[nA][02] == 1
    if nPageAct != oPrinter:nPagecount .OR. aItens[nA][02] == 1
            nAltura := 12

            oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, nRight)
            oPrinter:fillRect( { nLinha, aPerc[01], nLinha+nAltura, nRight }, oBrush )
            oPrinter:Say(nLinha+008, aPerc[01]+015 , "13.1 Rastreabilidade - Itens " , oFOARNE07)
            
            nLinha += nAltura
            nAltura := 17
            nLinha += 5
            oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aperc[03])
            oPrinter:Say(nLinha+007, aPerc[02]+002 , ":.. Item" , oFOARNE07)

            oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aperc[04])
            oPrinter:Say(nLinha+007, aPerc[03]+002 , ":.. Identificação " , oFOARNE07)

            oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aperc[05])
            oPrinter:Say(nLinha+007, aPerc[04]+002 , ":.. Data Fabricação " , oFOARNE07)
            
            oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aperc[06])
            oPrinter:Say(nLinha+007, aPerc[05]+002 , ":.. Data Validade " , oFOARNE07)
            
            oPrinter:Box(nLinha, aPerc[06], nLinha+nAltura, aperc[07])
            oPrinter:Say(nLinha+007, aPerc[06]+002 , ":.. Lote/Turno " , oFOARNE07)

            oPrinter:Box(nLinha, aPerc[07], nLinha+nAltura, aperc[08])
            oPrinter:Say(nLinha+007, aPerc[07]+002 , ":.. Qtd. Caixa " , oFOARNE07)
            
            oPrinter:Box(nLinha, aPerc[08], nLinha+nAltura, aperc[09])
            oPrinter:Say(nLinha+007, aPerc[08]+002 , ":.. Peso Venda " , oFOARNE07)

            nLinha += nAltura
    endif

    nAltura := 12

    // Impressão dos itens da rastreabilidade
    if aItens[nA][01] == "06"
        
        // Item
        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
        oPrinter:Say(nLinha+008, aPerc[02]+008 , aItens[nA][03] , oFOARNE07)
        
        // Identificação
        oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
        oPrinter:Say(nLinha+008, aPerc[03]+005 , aItens[nA][04] , oFOARNE07)
        
        // Data de Fabricação
        oPrinter:Box(nLinha, aPerc[04], nLinha+nAltura, aPerc[05])
        oPrinter:Say(nLinha+008, aPerc[04]+022 , aItens[nA][05] , oFOARNE07)
        
        // Data de Validade
        oPrinter:Box(nLinha, aPerc[05], nLinha+nAltura, aPerc[06])
        oPrinter:Say(nLinha+008, aPerc[05]+022 , aItens[nA][06] , oFOARNE07)
        
        // Lote/Turno
        oPrinter:Box(nLinha, aPerc[06], nLinha+nAltura, aPerc[07])
        oPrinter:Say(nLinha+008, aPerc[06]+029 , aItens[nA][07], oFOARNE07)

        // Qtd. Caixa
        oPrinter:Box(nLinha, aPerc[07], nLinha+nAltura, aPerc[08])
        oPrinter:Say(nLinha+008, aPerc[07]+037 , Transform(aItens[nA][08] ,"@E 99,999,999.9999"), oFOARNE07)

        // Peso venda
        oPrinter:Box(nLinha, aPerc[08], nLinha+nAltura, aPerc[09])
        oPrinter:Say(nLinha+008, aPerc[08]+037 , Transform(aItens[nA][09] ,"@E 99,999,999.9999"), oFOARNE07)
    elseif aItens[nA][01] == "07"
        // Total
        oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[07])
        oPrinter:Say(nLinha+008, aPerc[02]+008 , alltrim(aItens[nA][03]) , oFOARNE07)

        // Qtd. Caixa
        oPrinter:Box(nLinha, aPerc[07], nLinha+nAltura, aPerc[08])
        oPrinter:Say(nLinha+008, aPerc[07]+037 , Transform(aItens[nA][04] ,"@E 99,999,999.9999"), oFOARNE07)

        // Peso venda
        oPrinter:Box(nLinha, aPerc[08], nLinha+nAltura, aPerc[09])
        oPrinter:Say(nLinha+008, aPerc[08]+037 , Transform(aItens[nA][05] ,"@E 99,999,999.9999"), oFOARNE07)
    endif

    nLinha += nAltura

return


/* fSqlItem - Consulta aos itens do processo de exportação e seus itens de rastreabilidade. */
Static function fSqlItem()
    Local cQuery    := ""
    Local aRet      := {}
    Local nA        := 0
    Local nCo1      := 1
    Local nCo2      := 1
    Local cEOL      := Chr(13)+chr(10)
    Local nTotCa    := 0
    Local nTotVe    := 0
    Local nReg01    := 0
    Local nReg02    := 0
    Local nReg03    := 0
    Local nReg04    := 0
    Local nReg05    := 0
    Local nReg06    := 0
    Local nReg07    := 0
 
    /* 01/02/03-Registros dos Itens de exportação e rastreabilidade do APP.
        01 - Itens do pedido de exportação.
        02 - Rastreabilidade por lote.
        03 - Total da rastreabilidade.
    */
    cQuery := " SELECT EE7.EE7_PEDIDO, EE7.EE7_PEDFAT, EE8.EE8_COD_I, B1.B1_DESC, EE8.EE8_QTDEM1, EE8.EE8_PSLQTO, EE8.EE8_PSBRTO, LTRIM(RTRIM(ISNULL(ZE1.ZE1_DENOMI,'')))+' '+ LTRIM(RTRIM(ISNULL(ZED.ZED_DESCAT,'')))	PGA_DESCRI, ZE1_REGIST "
	cQuery += " FROM "+ RetSqlName("EE7") +" (nolock) EE7 INNER JOIN "+ RetSqlName("EE8") +" (NOLOCK) EE8  ON EE7.D_E_L_E_T_='' AND EE8.D_E_L_E_T_='' AND EE7.EE7_PEDIDO=EE8.EE8_PEDIDO "+cEOL
 	cQuery += " 				 LEFT  JOIN "+ RetSqlName("SB1") +" (NOLOCK) B1  ON B1.D_E_L_E_T_='' AND B1.B1_COD=EE8.EE8_COD_I  "+cEOL
 	cQuery += " 				 LEFT  JOIN "+ RetSqlName("ZE1") +" (NOLOCK) ZE1 ON ZE1.D_E_L_E_T_='' AND B1.B1_XPGAMER=ZE1.ZE1_REGIST "+cEOL
	cQuery += " 				 LEFT  JOIN "+ RetSqlName("ZED") +" (NOLOCK) ZED ON ZED.D_E_L_E_T_='' AND B1.B1_XPGAMER=ZED.ZED_REGZE1 AND B1.B1_XPGACAT =ZED.ZED_CODCAT
    cQuery += " WHERE  EE8.D_E_L_E_T_='' AND EE8.EE8_FILIAL='' AND EE8.EE8_PEDIDO ='"+ TRB->EE7_PEDIDO +"' "+cEOL
    cQuery += " ORDER BY EE7.EE7_PEDIDO; "
	TCQUERY cQuery ALIAS "QITEM" NEW
    
    TCSETFIELD("QITEM","EE8_SLDINI"		,"N",10,03)
    TCSETFIELD("QITEM","EE8_PSLQTO"		,"N",10,03)
    TCSETFIELD("QITEM","EE8_PSBRTO"		,"N",10,03)

    QITEM->(dbgotop())

    nCo1 := 1
    while QITEM->(!EOF())
        AADD(aret, {"01",;
                    nCo1,;
                    alltrim(QITEM->ZE1_REGIST)+"/"+alltrim(TRB->ZE0_REGIST),;
                    alltrim(QITEM->EE8_COD_I),;
                    ALLTRIM(QITEM->B1_DESC),;
                    ALLTRIM(QITEM->PGA_DESCRI),;
                    QITEM->EE8_QTDEM1,;
                    QITEM->EE8_PSLQTO,;
                    QITEM->EE8_PSBRTO;
        })
        nReg01 +=1
        
        /* Dados do embarque resumido */
        cQuery := " SELECT ZEX_FILIAL, ZEX_NUMERO, ZEX_DTFABR, ZEX_DTVALD, ZEX_TURNO, SUM(ZEX_QUANTI) QTD_VENDA, SUM(ZEX_QTDSUM) QTD_CAIXA "+cEOL
        cQuery += " FROM "+ RetSqlName("ZEX") +" ZEX "+cEOL
        cQuery += " WHERE ZEX.D_E_L_E_T_='' AND ZEX.ZEX_FILIAL='"+ xfilial("ZEX") +"' AND ZEX.ZEX_NUMERO='"+ QITEM->EE7_PEDFAT +"' AND ZEX.ZEX_PRODUT='"+ Alltrim(QITEM->EE8_COD_I) +"' "+cEOL
        cQuery += " GROUP BY ZEX_FILIAL, ZEX_NUMERO,ZEX_DTFABR, ZEX_DTVALD, ZEX_TURNO "+cEOL
        cQuery += " ORDER BY ZEX_FILIAL, ZEX_NUMERO,ZEX_DTFABR, ZEX_DTVALD, ZEX_TURNO; "

        TCQUERY cQuery ALIAS "QZEX" NEW
        
        TCSETFIELD("QZEX","QTD_CAIXA"		,"N",10,03)
        TCSETFIELD("QZEX","QTD_VENDA"		,"N",10,03)
        TCSETFIELD("QZEX","QTD_TEMPER"		,"N",10,03)
        TCSETFIELD("QZEX","ZEX_DTFABR"		,"D",08,00)
        TCSETFIELD("QZEX","ZEX_DTVALD"		,"D",08,00)

        QZEX->(dbgotop())

        nCo2    := 1
        nTotCa  := 0
        nTotVe  := 0

        while QZEX->(!EOF())
            AADD(aret, {"02",;
                nCo2,;
                StrZero(nCo1,2)+"."+StrZero(nCo2,3),;
                DTOC(QZEX->ZEX_DTFABR),;
                DTOC(QZEX->ZEX_DTVALD),;
                ALLTRIM(Replace(QZEX->ZEX_TURNO," ","")),;
                fTemper(QITEM->EE7_PEDFAT, Alltrim(QITEM->EE8_COD_I), DTOs(QZEX->ZEX_DTFABR), DTOs(QZEX->ZEX_DTVALD)),;
                QZEX->QTD_CAIXA,;
                QZEX->QTD_VENDA;
            })
            nReg02 +=1

            nTotCa  += QZEX->QTD_CAIXA
            nTotVe  += QZEX->QTD_VENDA

            nCo2    += 1
            QZEX->(Dbskip())
        ENDDO

        AADD(aret, {"03",;
                0,;
                "Total do Produto ("+ alltrim(QITEM->EE8_COD_I) +")" ,;
                nTotCa,;
                ntotVe;
            })
        nReg03 +=1

        QZEX->(DbcloseArea())
        
        /* Rastreabilidade */

        cQuery := " SELECT ZGB_FILIAL, ZGB_NUMERO, ZGB_DTFABR, ZGB_DTVALD, ZGB_TURNO, ZGB_IDENTI, ZGB_QUANTI QTD_VENDA, ZGB_QTDSUM QTD_CAIXA "+cEOL
        cQuery += " FROM "+ RetSqlName("ZGB") +" ZGB "+cEOL
        cQuery += " WHERE ZGB.D_E_L_E_T_='' AND ZGB.ZGB_FILIAL='"+ xfilial("ZGB") +"' AND ZGB.ZGB_NUMERO='"+ QITEM->EE7_PEDFAT +"' AND ZGB.ZGB_PRODUT='"+ Alltrim(QITEM->EE8_COD_I) +"' "+cEOL
        cQuery += " ORDER BY ZGB_FILIAL, ZGB_NUMERO, ZGB_DTFABR, ZGB_DTVALD, ZGB_TURNO, ZGB_IDENTI; "

        TCQUERY cQuery ALIAS "QZGB" NEW
        
        TCSETFIELD("QZGB","QTD_CAIXA"		,"N",10,03)
        TCSETFIELD("QZGB","QTD_VENDA"		,"N",10,03)
        TCSETFIELD("QZGB","ZGB_DTFABR"		,"D",08,00)
        TCSETFIELD("QZGB","ZGB_DTVALD"		,"D",08,00)

        QZGB->(dbgotop())

        nCo2    := 1
        nTotCa  := 0
        nTotVe  := 0

        while QZGB->(!EOF())
            AADD(aret, {"06",;
                nCo2,;
                StrZero(nCo1,2)+"."+StrZero(nCo2,4),;
                ALLTRIM(QZGB->ZGB_IDENTI),;
                DTOC(QZGB->ZGB_DTFABR),;
                DTOC(QZGB->ZGB_DTVALD),;
                ALLTRIM(Replace(QZGB->ZGB_TURNO," ","")),;
                QZGB->QTD_CAIXA,;
                QZGB->QTD_VENDA;
            })
            nReg06 +=1

            nTotCa  += QZGB->QTD_CAIXA
            nTotVe  += QZGB->QTD_VENDA

            nCo2    += 1
            QZGB->(Dbskip())
        ENDDO

        AADD(aret, {"07",;
                0,;
                "Total do Produto ("+ alltrim(QITEM->EE8_COD_I) +")" ,;
                nTotCa,;
                ntotVe;
            })
        nReg07 +=1

        QZGB->(DbcloseArea())

        nCo1 += 1
        QITEM->(Dbskip())
    enddo

    QITEM->(DbcloseArea())

    /* 04-Registro de imagens. */

    cQuery := " SELECT * "+cEOL
	cQuery += " FROM "+ RetSqlName("ZEY") +" (nolock) ZEY  "+cEOL
    cQuery += " WHERE  ZEY.D_E_L_E_T_='' AND ZEY.ZEY_FILIAL='"+ xfilial("ZEY") +"' AND ZEY.ZEY_NUMERO ='"+ TRB->EE7_PEDFAT +"' "+cEOL
    cQuery += " ORDER BY ZEY.ZEY_NUMERO, ZEY.ZEY_PRODUT, ZEY.ZEY_DESCRI; "

	TCQUERY cQuery ALIAS "QZEY" NEW
    
    QZEY->(dbgotop())

    nCo3 := 1
    while QZEY->(!EOF())
        AADD(aret, {"04",;
                    nCo3,;
                    ALLTRIM(QZEY->ZEY_ID),;
                    ALLTRIM(QZEY->ZEY_DESCRI),;
                    ALLTRIM(QZEY->ZEY_ARQUIV),;
                    ALLTRIM(QZEY->ZEY_COMPON),;
                    0,;
                    0;
        })
        nReg04 +=1

        nCo3 += 1
        QZEY->(Dbskip())
    enddo

    QZEY->(DbcloseArea())

    /* 05-Registros para a declaração de exportação. */

    cQuery := " SELECT EE7.EE7_PEDIDO, EE7.EE7_PEDFAT, C5.C5_NOTA, C5.C5_SERIE, EE8.EE8_COD_I, B1.B1_DESC, EE8.EE8_QTDEM1, EE8.EE8_PSLQTO, EE8.EE8_PSBRTO, LTRIM(RTRIM(ISNULL(ZE1.ZE1_DENOMI,'')))+' '+ LTRIM(RTRIM(ISNULL(ZED.ZED_DESCAT,'')))	PGA_DESCRI, ZE1_REGIST, "+cEOL
	cQuery += " isnull(CAST(CAST(ZCO_OBSDEC AS varbinary(4000)) AS varchar(4000)),'') ZCO_OBSDEC "
    cQuery += " FROM "+ RetSqlName("EE7") +" (nolock) EE7 INNER JOIN "+ RetSqlName("EE8") +" (NOLOCK) EE8  ON EE7.D_E_L_E_T_='' AND EE8.D_E_L_E_T_='' AND EE7.EE7_PEDIDO=EE8.EE8_PEDIDO "+cEOL
 	cQuery += " 				 INNER JOIN "+ RetSqlName("SC5") +" (NOLOCK) C5  ON C5.D_E_L_E_T_=''  AND C5.C5_FILIAL='"+ XFILIAL("SC5") +"' AND C5.C5_NUM=EE7.EE7_PEDFAT  "+cEOL
    cQuery += " 				 LEFT  JOIN "+ RetSqlName("ZCO") +" (NOLOCK) ZCO ON ZCO.D_E_L_E_T_=''  AND ZCO.ZCO_CODIGO=EE7.EE7_XGRPIN  "+cEOL
    cQuery += " 				 LEFT  JOIN "+ RetSqlName("SB1") +" (NOLOCK) B1  ON B1.D_E_L_E_T_=''  AND B1.B1_COD=EE8.EE8_COD_I  "+cEOL
 	cQuery += " 				 LEFT  JOIN "+ RetSqlName("ZE1") +" (NOLOCK) ZE1 ON ZE1.D_E_L_E_T_='' AND B1.B1_XPGAMER=ZE1.ZE1_REGIST "+cEOL
	cQuery += " 				 LEFT  JOIN "+ RetSqlName("ZED") +" (NOLOCK) ZED ON ZED.D_E_L_E_T_='' AND B1.B1_XPGAMER=ZED.ZED_REGZE1 AND B1.B1_XPGACAT =ZED.ZED_CODCAT
    cQuery += " WHERE  EE8.D_E_L_E_T_='' AND EE8.EE8_FILIAL='' AND EE8.EE8_PEDIDO ='"+ TRB->EE7_PEDIDO +"' "+cEOL
    cQuery += " ORDER BY EE7.EE7_PEDIDO; "
	
    TCQUERY cQuery ALIAS "QITDE" NEW
    
    TCSETFIELD("QITDE","EE8_SLDINI"		,"N",10,03)
    TCSETFIELD("QITDE","EE8_PSLQTO"		,"N",10,03)
    TCSETFIELD("QITDE","EE8_PSBRTO"		,"N",10,03)

    QITDE->(dbgotop())

    nCo1 := 1
    while QITDE->(!EOF())
        AADD(aret, {"05",;
                    nCo1,;
                    alltrim(QITDE->ZE1_REGIST)+"/"+AllTrim(TRB->ZE0_REGIST ),;
                    alltrim(QITDE->EE8_COD_I),;
                    alltrim(QITDE->B1_DESC),;
                    alltrim(QITDE->PGA_DESCRI),;
                    QITDE->EE8_QTDEM1,;
                    QITDE->EE8_PSLQTO,;
                    QITDE->EE8_PSBRTO,;
                    QITDE->ZCO_OBSDEC;
        })
        nReg05 +=1

        nCo1 += 1
        QITDE->(Dbskip())
    enddo

    QITDE->(DbcloseArea())

    nTotReg := fGetTot(nReg01, nReg02, nReg03, nReg04, nReg05, nReg06, nReg07)

return aRet

Static function fGetTot(nReg01, nReg02, nReg03, nReg04, nReg05, nReg06, nReg07)
    Local nRet      := 0
    Local nTmp      := 0
    Local nRegPg    := 0

    //Itens da exportação.
    nRegPg := 28
    nTmp := (nReg01+14)/nRegPg
    nRet += int(nTmp)+iif( (nTmp)-int(nTmp) > 0,1,0)

    //detalhes do carregamento.
    nRegPg := 32
    nTmp := (nReg02+nReg03)/nRegPg
    nRet += int(nTmp)+iif( (nTmp)-int(nTmp) > 0,1,0)

    //Imagens.
    nRegPg := 2
    nTmp := (nReg04)/nRegPg
    nRet += int(nTmp)+iif( (nTmp)-int(nTmp) > 0,1,0)

    //Declaração de exportação.
    nRegPg := 1
    nTmp := (nReg05)/nRegPg
    nRet += int(nTmp)+iif( (nTmp)-int(nTmp) > 0,1,0)

    //detalhes do carregamento.
    nRegPg := 57
    nTmp := (nReg06+nReg07 - nReg01*2)/nRegPg
    nRet += int(nTmp)+iif( (nTmp)-int(nTmp) > 0,1,0)
    
return nRet

Static function fTemper(cPedVen, cProdut, cDtFab, cDtVld)
    Local cQuery    := ""
    //Local nCont     := 1
    Local cRet      := ""

    cQuery := " SELECT ZEX_PALLET, ZEX.ZEX_TEMPER "+cEOL
    cQuery += " FROM "+ RetSqlName("ZEX") +" ZEX "+cEOL
    cQuery += " WHERE ZEX.D_E_L_E_T_='' AND ZEX.ZEX_TEMPER != 0 AND ZEX.ZEX_FILIAL='"+ xfilial("ZEX") +"' AND ZEX.ZEX_NUMERO='"+ cPedVen +"' "
    cQuery += "         AND ZEX.ZEX_PRODUT='"+ cProdut +"' AND ZEX.ZEX_DTFABR ='"+ cDtFab +"' AND ZEX.ZEX_DTVALD = '"+ cDtVld +"' "+cEOL
    cQuery += " ORDER BY ZEX_PALLET; "

    TCQUERY cQuery ALIAS "QTMP" NEW
    
    TCSETFIELD("QTMP","ZEX_TEMPER"		,"N",10,02)
    
    QTMP->(dbgotop())

    while QTMP->(!EOF())
        cRet += iif(Empty(cRet),"",", ")+Alltrim(Transform(QTMP->ZEX_TEMPER ,"@E 999.99")) +" °C"
        //nCont += 1
        QTMP->(Dbskip())
    enddo

    QTMP->(Dbclosearea())

return cRet

/* Recupera as informações retornadas do aplicativo da qualidade que compôem as informações do cabeçalho. */
Static function fGetInfo()
    Local cQuery := ""
    Local cEOL      := Chr(13)+chr(10)

    cQuery := " SELECT DISTINCT ZEX_DTICAR, ZEX_DTTCAR, ZEX_HRICAR, ZEX_HRTCAR, ZEX_MONQUA, convert(varchar, getdate(),112) ZEX_DTLACR,left(convert(time, getdate()),8) ZEX_HRLACR, "+ cEOL
	cQuery += "  ZEX_CONTAI, ZEX_LACRE1, ZEX_LACRE2, ZEX_TERMOG, ZEX_TARCON, "+ cEOL
	cQuery += "  ZEX_LIMPIN, ZEX_LIMPEX, ZEX_TEMPBA, ZEX_BORRAC, ZEX_EQUIPF "+ cEOL
    cQuery += " FROM "+ RetSqlName("ZEX") +" ZEX "+ cEOL
    cQuery += " WHERE ZEX.D_E_L_E_T_='' AND ZEX.ZEX_FILIAL='"+ xFilial("ZEX") +"' AND ZEX.ZEX_NUMERO='"+ TRB->C5_NUM +"'; "

    Tcquery cQuery ALIAS "QINF" NEW

    TCSETFIELD("QINF","ZEX_DTICAR"		,"D",08,00)
    TCSETFIELD("QINF","ZEX_DTTCAR"		,"D",08,00)
    TCSETFIELD("QINF","ZEX_DTLACR"		,"D",08,00)
    
    if QINF->(!EOF())
        dDtICar     := QINF->ZEX_DTICAR
        dDtTCar     := QINF->ZEX_DTTCAR
        cEmbHIni    := QINF->ZEX_HRICAR
        cEmbHTer    := QINF->ZEX_HRTCAR
        cMonQua     := QINF->ZEX_MONQUA
        dLacData    := iif(Empty(QINF->ZEX_DTLACR), QINF->ZEX_DTICAR, QINF->ZEX_DTLACR)
        cLacHora    := iif(Empty(QINF->ZEX_DTLACR), QINF->ZEX_HRTCAR, QINF->ZEX_HRLACR)
        cLimpInt    := IIF(QINF->ZEX_LIMPIN == "S","Conforme","Não conforme")
        cLimpExt    := IIF(QINF->ZEX_LIMPEX == "S","Conforme","Não conforme")
        cTempBau    := IIF(QINF->ZEX_TEMPBA == "S","Conforme","Não conforme")
        cBorrach    := IIF(QINF->ZEX_BORRAC == "S","Conforme","Não conforme")
        cEquipFr    := IIF(QINF->ZEX_EQUIPF == "S","Conforme","Não conforme")

        cLacArma    := Alltrim(QINF->ZEX_LACRE1)
        cLacOfic    := Alltrim(QINF->ZEX_LACRE2)
        cContain    := Alltrim(QINF->ZEX_CONTAI)
        cTermog     := Alltrim(QINF->ZEX_TERMOG)
        nTarCon     := QINF->ZEX_TARCON


    endif

    QINF->(DbcloseArea())

return

/* fSqlItDe - Consulta aos itens da declaração da exportação. */
/*
Static function fSqlItDe()
    Local cQuery    := ""
    Local aRet      := {}
    Local nCo1      := 1
    
    Local cEOL      := Chr(13)+chr(10)
    
return aRet
*/

/* fGetQuery - Consulta geral para os pedidos de venda. */
Static function fGetQuery()
    Local cQuery    := ""
    Local cEOL      := Chr(13)+chr(10)

    cQuery := " SELECT EE7_PEDIDO, EE7.EE7_XORDCO, EE7.EE7_XOPCTE, EE7.EE7_XCODTE, EE7.EE7_XEMBAR, EE7.EE7_CONTAI, EE7.EE7_NLACR1, EE7.EE7_NLACR2, EE7.EE7_TEMPER, EE7_XBOOKI, EE7_PEDFAT,"+cEOL
	cQuery += " 	   EE7.EE7_XTARA, A1.A1_COD, A1.A1_LOJA, A1.A1_NOME, A1A.A1_NOME CONSIG, A1A.A1_END, A1A.A1_BAIRRO, A1A.A1_COMPLEM, YA.YA_DESCR, " +cEOL
    cQuery += "        EE6.EE6_NOME, C5.C5_NUM, C5.C5_ROTEIRO, C5.C5_DTENTR, C5.C5_PLACA, A4.A4_NOME, ZVC.ZVC_MOTORI, "+cEOL
    cQuery += "        C5.C5_NOTA, C5.C5_SERIE, ZEL.ZEL_DESCRI,   "+cEOL
    cQuery += "        ZE0.ZE0_REGIST, ZE0.ZE0_CNPJ, ZE0.ZE0_RAZAO,   "+cEOL
    cQuery += "        EE7_MENSG, EE7_MENSG2, EE7_MENSG3 "+cEOL
    cQuery += " FROM "+ RetSqlName("EE7") +" (nolock) EE7 INNER JOIN "+ RetSqlName("SC5") +" (NOLOCK) C5  ON C5.D_E_L_E_T_='' AND EE7.D_E_L_E_T_='' AND EE7.EE7_PEDFAT=C5.C5_NUM "+cEOL
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("SA1") +" (NOLOCK) A1  ON EE7.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND EE7.EE7_IMPORT=A1.A1_COD AND EE7.EE7_IMLOJA=A1.A1_LOJA "+cEOL
	cQuery += " 					 LEFT  JOIN "+ RetSqlName("SA1") +" (NOLOCK) A1A ON EE7.D_E_L_E_T_='' AND A1A.D_E_L_E_T_='' AND EE7.EE7_CONSIG=A1A.A1_COD AND EE7.EE7_COLOJA=A1A.A1_LOJA "+cEOL
	cQuery += " 					 LEFT  JOIN "+ RetSqlName("SYA") +" (NOLOCK) YA  ON YA.D_E_L_E_T_='' AND YA.YA_CODGI=EE7.EE7_PAISET "+cEOL
	cQuery += " 					 LEFT  JOIN "+ RetSqlName("EE6") +" (NOLOCK) EE6 ON EE6.D_E_L_E_T_='' AND EE6.EE6_COD=EE7.EE7_XEMBAR "+cEOL
    cQuery += "                      LEFT  JOIN "+ RetSqlName("SA4") +" (NOLOCK) A4  ON EE7.D_E_L_E_T_='' AND A4.D_E_L_E_T_='' AND C5.C5_TRANSP=A4.A4_COD "+cEOL
    cQuery += "                      LEFT  JOIN "+ RetSqlName("ZV4") +" (NOLOCK) ZV4 ON ZV4.D_E_L_E_T_='' AND ZV4.ZV4_PLACA=C5.C5_PLACA "+cEOL
    cQuery += "                      LEFT  JOIN "+ RetSqlName("ZVC") +" (NOLOCK) ZVC ON ZVC.D_E_L_E_T_='' AND ( (ZV4.ZV4_CPF=ZVC.ZVC_CPF AND ZV4.ZV4_CPF!='') OR (ZV4.ZV4_PASPO=ZVC.ZVC_PASPOR AND ZV4.ZV4_PASPO!='') )  "+cEOL
    cQuery += "                      LEFT  JOIN "+ RetSqlName("ZEL") +" (NOLOCK) ZEL ON ZEL.D_E_L_E_T_='' AND ZEL.ZEL_FILIAL='"+ xFilial("ZEL") +"' AND ZEL.ZEL_COD=EE7.EE7_XMODCS"
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("ZE0") +" (NOLOCK) ZE0  ON ZE0.D_E_L_E_T_='' AND ZE0.ZE0_FILIAL='"+ xFilial("ZE0") +"' "+cEOL
    cQuery += " WHERE  EE7.D_E_L_E_T_='' AND EE7.EE7_FILIAL='' AND C5.C5_FILIAL='"+ xFilial("SC5") +"' AND EE7.EE7_PEDIDO ='"+ MV_PAR01 +"' "+cEOL
    cQuery += " ORDER BY EE7.EE7_PEDIDO; "
	TCQUERY cQuery ALIAS "TRB" NEW
                
	//TCSETFIELD("TRB","ZV1_DTABAT"		,"D",08,00)
	
return

/* fMakeDir - Cria o diretório automaticamente. */
Static Function fMakeDir(cDirServer)
	Local cFolder	:= ""
	Local nA		:= 0
	cDirServer 		:= Alltrim(cDirServer)

    If !lIsDir(cDirServer)
        If ":"$cDirServer
            MakeDir(cDirServer)
        Else
            aFolders	:= Separa(cDirServer,"\",.F.)
            For Na := 1 TO Len(aFolders)
                cFolder		+= "\"+aFolders[nA]
                MakeDir(cFolder)
            Next nA
        EndIf
    EndIf

Return cDirServer
