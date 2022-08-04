#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} User Function ADFIN102P
	PROGRAMA PARA GERAR UM GRUPO DE TITULOS A RECEBER PARA SE REALIZAR A BAIXA INDIVIDUALMENTE.
	Essa funÃ§Ã£o gera a interface inicial pra realizacao dos processos
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
	@history Ticket 18035 - Leonardo P. Monteiro - 27/12/2021 - Ajustes na rotina e separação referente ao ponto de entrada F050ROT.
    @history Ticket 14558 - Fernando Macieira    - 18/04/2022 - Rotina para lançamentos de NDFs - Ajuste R$
    @history Ticket 76402 - Fernando Macieira    - 13/07/2022 - CSV - NDF
    @history Ticket 76402 - Fernando Macieira    - 03/08/2022 - CSV - NDF - Está trazendo a informação do campo C custo Crédito
/*/
User Function ADFIN117P()

	Local aArea 		:= GetArea()
	Private Arquivo 	:= Space(40)
	Private cTipo       := ""
    Private lMsErroAuto	:= .F.
	Private lContinua	:= .T.
	Private lExec		:= .T.
    Private nPosEmpres  := 1
    Private nPosFilial  := 2
    Private nPosPrefix  := 3
    Private nPosNumero  := 4
    Private nPosParcel  := 5
    Private nPosNature  := 6
    Private nPosForCod  := 7
    Private nPosForLoj  := 8
    Private nPosEmissa  := 9
    Private nPosVencim  := 10
    Private nPosConDeb  := 11
    Private nPosConCre  := 12
    Private nPosIteDeb  := 13
    Private nPosIteCre  := 14
    Private nPosCCusto  := 15
    Private nPosValor   := 16
    Private nPosHistor  := 17
    Private nPosCCSol   := 18 // @history Ticket 76402 - Fernando Macieira    - 13/07/2022 - CSV - NDF
    
	@ 200, 001 To 377, 380 Dialog oLeTxt Title OemToAnsi("Conversão de Lançamentos")
	@ 002, 004 To 040, 187 Title OemToAnsi("Comentário : ")
	//
	@ 009, 020 Say "Este programa tem como objetivo fazer a importação de um  "
	@ 019, 020 Say "arquivo texto, gerado em Planilha Excel (extensão .csv)   "
	@ 029, 020 Say "para importação automática de Titulo a Pagar"
	//
	@ 044, 004 To 060, 187
	@ 049, 010 Say "Arquivo : "
	@ 065, 004 To 085, 187 Title OemToAnsi("Opções : ")
	//
	@ 70, 065 BmpButton Type 14 Action SelecArq()
	@ 70, 105 BmpButton Type 01 Action Close(oLeTxt)
	@ 70, 145 BmpButton Type 02 Action (lExec := .F.,Close(oLeTxt))

    Activate Dialog oLeTxt Centered

    If !lExec
    return(.t.)
    Endif

    If MsgBox("Confirma a Importação da Planilha?", "Atenção !!!", "YESNO")
        Processa({|| Converte()}, "Inclusão da NDF´s (.csv)")
    Endif

    RestArea(aArea)

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'GERAR UM GRUPO DE TITULOS A RECEBER ')

Return

//========================
Static Function SelecArq()
//========================

	cTipo :=         "*.CSV           | *.CSV |   "
	cTipo := cTipo + "Todos os Arquivos *.* | *.* "

	Arquivo := cGetFile(cTipo, "Seleção de Arquivo")
	Arquivo := Alltrim(Arquivo)

	@ 048, 035 Get Arquivo When .F. Size 140, 10

Return (.T.)

//========================
Static Function Converte()
//========================

    Local _i
    Local nA
    Local _lErro	    := .F.
    Local aRet		    := {}
    Private nLinha      := 0
    Private nErroLog    := 0
    Private aLog	    := {}
    Private aErroLog    := {}

    If !Empty(Arquivo)
        cArqCSV := Alltrim(Arquivo)         // Arquivo Texto Selecionado
    EndIf

    If File(cArqCSV)
        
        FT_FUSE(cArqCSV)
        FT_FGOTO(1)
        aTitSE2 := {}

        While lContinua .And. !FT_FEOF()

            nLinha      += 1
            cLinha		:= FT_FREADLN()
            aLinha		:= StrTokArr2(cLinha, ";", .T.)
            
            //if len(aLinha) == 17 // @history Ticket 76402 - Fernando Macieira    - 13/07/2022 - CSV - NDF
            if len(aLinha) == 18 // @history Ticket 76402 - Fernando Macieira    - 13/07/2022 - CSV - NDF
                If !Empty(aLinha[02]) .And. Val(aLinha[11]) > 0 .And. Alltrim(aLinha[02]) <> "FILIAL" .and. nLinha <> 1

                    cE2_FILIAL	:= StrZero(Val(aLinha[nPosFilial]),2)
                    cE2_PREFIXO	:= aLinha[nPosPrefix]
                    cE2_NUM		:= Alltrim(PadR(aLinha[nPosNumero]	, TamSX3("E2_NUM")		[1]))
                    cE2_PARCELA	:= Alltrim(PadR(aLinha[nPosParcel]	, TamSX3("E2_PARCELA")	[1]))
                    cE2_TIPO	:= Alltrim( PadR("NDF"		, TamSX3("E2_TIPO")		[1]))
                    cE2_NATUREZ	:= Alltrim(PadR(aLinha[nPosNature]	, TamSX3("E2_NATUREZ")	[1]))
                    cE2_FORNECE	:= StrZero(Val(Alltrim(PadR(aLinha[nPosForCod]	, TamSX3("E2_FORNECE")	[1]))),6)
                    cE2_LOJA	:= StrZero(Val(Alltrim(PadR(aLinha[nPosForLoj]	, TamSX3("E2_LOJA")		[1]))),2)
                    dE2_EMISSAO := Ctod(aLinha[nPosEmissa])
                    dE2_VENCTO  := Ctod(aLinha[nPosVencim])
                    dE2_VENCREA	:= DataValida(dE2_VENCTO)
                    nE2_VALOR	:= StrTran(aLinha[nPosValor], "R$","") // @history Ticket 14558 - Fernando Macieira    - 18/04/2022 - Rotina para lançamentos de NDFs - Ajuste R$
                    nE2_VALOR	:= StrTran(nE2_VALOR, ".","")
                    nE2_VALOR	:= StrTran(nE2_VALOR, ",",".")
                    nE2_VALOR	:= Val(nE2_VALOR)
                    cE2_DEBITO  := Alltrim(PadR(aLinha[nPosConDeb]	, TamSX3("E2_DEBITO")		[1]))
                    cE2_CREDIT  := Alltrim(PadR(aLinha[nPosConCre]	, TamSX3("E2_CREDIT")		[1]))
                    cE2_ITEMD   := Alltrim(PadR(aLinha[nPosIteDeb]	, TamSX3("E2_ITEMD")		[1]))
                    cE2_ITEMC   := Alltrim(PadR(aLinha[nPosIteCre]	, TamSX3("E2_ITEMC")		[1]))
                    cE2_CCC     := Alltrim(PadR(aLinha[nPosCCusto]	, TamSX3("E2_CCC")		    [1]))
                    cE2_HIST	:= Alltrim(PadR(aLinha[nPosHistor]	, TamSX3("E2_HIST")		    [1]))
                    cE2_CCSOLIC := Alltrim(PadR(aLinha[nPosCCSol]	, TamSX3("E2_CCSOLIC")		[1])) // @history Ticket 76402 - Fernando Macieira    - 03/08/2022 - CSV - NDF - Está trazendo a informação do campo C custo Crédito
                    //cE2_CCSOLIC := Alltrim(PadR(aLinha[nPosCCusto]	, TamSX3("E2_CCSOLIC")		[1])) // @history Ticket 76402 - Fernando Macieira    - 13/07/2022 - CSV - NDF
                    
                    SE2->(DbSetOrder(1))
                    SED->(DbSetOrder(1))
                    CTT->( dbSetOrder(1) ) // @history Ticket 76402 - Fernando Macieira    - 13/07/2022 - CSV - NDF

                    If !SE2->( DbSeek(xFilial("SE2") + cE2_PREFIXO + cE2_NUM + cE2_PARCELA + cE2_TIPO + cE2_FORNECE + cE2_LOJA))
                        SA2->( DbSetOrder(1))
                        Do Case
                            Case dE2_VENCTO < ddatabase
                                _lErro := .T.
                                U_F050Log(" VENCIMENTO MENOR QUE DATABASE")
                            Case !SA2->( DbSeek(xFilial("SA2") + cE2_FORNECE + cE2_LOJA))
                                _lErro := .T.
                                U_F050Log("FORNECEDOR/LOJA INEXISTENTE")
                            Case !SED->( DbSeek(xFilial("SED") + cE2_NATUREZ))
                                _lErro := .T.
                                U_F050Log("NATUREZA FINANCEIRA INEXISTENTE")
                            Case !CTT->( DbSeek(FWxFilial("CTT") + cE2_CCSOLIC) ) // @history Ticket 76402 - Fernando Macieira    - 13/07/2022 - CSV - NDF
                                _lErro := .T.
                                U_F050Log("CCUSTO SOLICITANTE INEXISTENTE")
                            OTHERWISE
                                aVetor:={   {"E2_FILIAL"   	, cE2_FILIAL		,NIL},;
                                            {"E2_PREFIXO" 	, cE2_PREFIXO		,NIL},;	
                                            {"E2_NUM"     	, cE2_NUM			,NIL},;
                                            {"E2_PARCELA" 	, cE2_PARCELA 		,NIL},;
                                            {"E2_TIPO"    	, cE2_TIPO          ,NIL},;
                                            {"E2_NATUREZ" 	, cE2_NATUREZ		,NIL},;
                                            {"E2_FORNECE" 	, cE2_FORNECE		,NIL},;
                                            {"E2_LOJA"    	, cE2_LOJA			,NIL},;
                                            {"E2_EMISSAO" 	, dE2_EMISSAO		,NIL},;
                                            {"E2_VENCTO"  	, dE2_VENCTO		,NIL},;
                                            {"E2_VENCREA"  	, dE2_VENCREA		,NIL},;
                                            {"E2_VALOR"   	, nE2_VALOR 		,NIL},;
                                            {"E2_DEBITO"    , cE2_DEBITO 		,NIL},;
                                            {"E2_CREDIT"    , cE2_CREDIT 		,NIL},;
                                            {"E2_ITEMD"     , cE2_ITEMD 		,NIL},;
                                            {"E2_ITEMC"     , cE2_ITEMC 		,NIL},;
                                            {"E2_CCC"       , cE2_CCC 			,NIL},;
                                            {"E2_HIST"   	, cE2_HIST 			,NIL},;
                                            {"E2_CCSOLIC"   , cE2_CCSOLIC 		,NIL},;
                                            {"E2_FILORIG" 	, cE2_FILIAL		,NIL}}	  
                                Aadd(aTitSE2, aVetor)
                        EndCase
                    else
                        //_lErro := .T.
                        AAdd(aLog, 	"Linha: "+ StrZero(nLinha,6) + "-" +;
                                    SE2->E2_PREFIXO 	  + "-" +;
                                    SE2->E2_NUM 	 	  + "-" +;
                                    SE2->E2_PARCELA 	  + "-" +;
                                    SE2->E2_TIPO	 	  + "-" +;
                                    SE2->E2_NATUREZ 	  + "-" +;
                                    SE2->E2_FORNECE 	  + "-" +;
                                    SE2->E2_LOJA	 	  + "-" +;
                                    Dtoc(SE2->E2_EMISSAO) + "-" +;
                                    Dtoc(SE2->E2_VENCTO)  + "-" +;
                                    Transform(SE2->E2_VALOR, "@R 999,999,999.99")+ " - TITULO GERADO ANTERIORMENTE ")
                    Endif
                Endif
            else
                AAdd(aLog, "Linha: "+ StrZero(nLinha,6) + "- Layout do arquivo deve ter 13 colunas!")
            endif

            FT_FSKIP()
        EndDo
    Endif

    FT_FUSE()

    If _lErro
        MsgAlert("Houve erro na validação do arquivo selecionado. Analise o Relatório de Log ")
    Else
        For _i:=1 to Len(aTitSE2)
            cE2_NUM := aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_NUM'})][02]
            aVetor:={   {"E2_FILIAL"   	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_FILIAL'}) ][02], NIL},;
                        {"E2_PREFIXO" 	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_PREFIXO'})][02], NIL},;
                        {"E2_NUM"     	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_NUM'})	 ][02], NIL},;
                        {"E2_PARCELA" 	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_PARCELA'})][02], NIL},;
                        {"E2_TIPO"    	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_TIPO'})	 ][02], NIL},;
                        {"E2_NATUREZ" 	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_NATUREZ'})][02], NIL},;
                        {"E2_FORNECE" 	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_FORNECE'})][02], NIL},;
                        {"E2_LOJA"    	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_LOJA'})	 ][02], NIL},;
                        {"E2_EMISSAO" 	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_EMISSAO'})][02], NIL},;
                        {"E2_VENCTO"  	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_VENCTO'}) ][02], NIL},;
                        {"E2_VENCREA"  	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_VENCREA'})][02], NIL},;
                        {"E2_VALOR"   	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_VALOR'})	 ][02], NIL},;
                        {"E2_HIST"   	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_HIST'})   ][02], NIL},;
                        {"E2_DEBITO"   	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_DEBITO'}) ][02], NIL},;
                        {"E2_CREDIT"   	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_CREDIT'}) ][02], NIL},;
                        {"E2_ITEMD"   	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_ITEMD'})  ][02], NIL},;
                        {"E2_ITEMC"   	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_ITEMC'})  ][02], NIL},;
                        {"E2_CCC"   	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_CCC'})    ][02], NIL},;
                        {"E2_CCSOLIC"   , aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_CCSOLIC'})][02], NIL},;
                        {"E2_FILORIG" 	, aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_FILORIG'})][02], NIL}}	  
            lMsErroAuto := .F.
            LjMsgRun("Gerando Titulo a Pagar..: "+cE2_NUM,,{||MSExecAuto({|x,y| FINA050(x,y)},aVetor,3)})
            
            If lMsErroAuto
                MsgAlert("Houve erro na rotina de gereação automática. Contate area de TI")
                Mostraerro()
                aErroLog := GetAutoGrLog()
                nErroLog := Len(aErroLog)

                For nA := 1 to nErroLog
                    AAdd(aLog, 	"Linha: "+ StrZero(nLinha,6) + "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_PREFIXO'})		 ][02] 	+ "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_NUM'})	 		 ][02] 	+ "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_PARCELA'})	 	 ][02]  + "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_TIPO'})	 	 ][02]	+ "-" +;
                            " Erro:"+ Alltrim(aErroLog[nA]))
                Next nA
            Else
                
                AAdd(aLog, 	"Linha: "+ StrZero(nLinha,6) + "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_PREFIXO'})		 ][02] 	+ "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_NUM'})	 		 ][02] 	+ "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_PARCELA'})	 	 ][02]  + "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_TIPO'})	 	 ][02]	+ "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_NATUREZ'})	 	 ][02] 	+ "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_FORNECE'})	 	 ][02] 	+ "-" +;
                            aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_LOJA'})	 	 ][02]	+ "-" +;
                            Dtoc(aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_EMISSAO'}) ][02]) + "-" +;
                            Dtoc(aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_VENCTO'})	 ][02]) + "-" +;
                            Transform(aTitSE2[_i][aScan(aTitSE2[_i],{ |x| Alltrim(x[1]) == 'E2_VALOR'})	 ][02], "@R 999,999,999.99")+ " - TITULO GERADO")
                
                u_GrLogZBE (Date(),TIME(),cUserName,"INCLUSAO PAGAR - NDF","FINANCEIRO","F050ROT",;
                            "TITULO: "+cE2_NUM,ComputerName(),LogUserName())
            
            Endif
        Next _i
    Endif
    If Len(aLog) > 0
        fMakeLog(   { aLog }                                             ,;  //Array que contem os Detalhes de Ocorrencia de Log
                    { OemToAnsi( "Geracao de Titulos a Pagar. : Log arquivo CSV" ) }  ,;  //Array que contem os Titulos de Acordo com as Ocorrencias
                    NIL                                                ,;  //Pergunte a Ser Listado
                    .T.                                                ,;  //Se Havera "Display" de Tela
                    CriaTrab( NIL , .F. )                              ,;  //Nome Alternativo do Log
                    OemToAnsi( " Log de Importação" )                     ,;  //Titulo Alternativo do Log
                    "G"                                                ,;  //Tamanho Vertical do Relatorio de Log ("P","M","G")
                    "P"                                                ,;  //Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
                    NIL                                                ,;  //Array com a Mesma Estrutura do aReturn
                    .F.                                                ;  //Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
                )
    EndIf

return aRet

//============================
User Function F050Log(cMotivo)
//============================

AAdd(aLog, 	"Linha: "+ StrZero(nLinha,6) + "-" +;
            cE2_PREFIXO 	+ "-" +;
			cE2_NUM 	 	+ "-" +;
			cE2_PARCELA 	+ "-" +;
			cE2_TIPO	 	+ "-" +;
			cE2_NATUREZ 	+ "-" +;
			cE2_FORNECE 	+ "-" +;
			cE2_LOJA	 	+ "-" +;
			Dtoc(dE2_EMISSAO) + "-" +;
			Dtoc(dE2_VENCTO)  + "-" +;
			Transform(nE2_VALOR, "@R 999,999,999.99")+ " - "+cMotivo)
Return (.T.)
