// *****************************************************************************
// *+-------------------------------------------------------------------------+*
// *|Funcao      | LeXml    | Autor | (HCConSys)                              |*
// *+------------+------------------------------------------------------------+*
// *|Data		 | 21.12.2006	    										  |*
// *+------------+------------------------------------------------------------+*
// *|Descricao   | 														      |*
// *+------------+------------------------------------------------------------+*
// *|Solicitante | 														      |*
// *+------------+------------------------------------------------------------+*
// *|Arquivos	 |   														  |*
// *+------------+------------------------------------------------------------+*
// *|			   ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL 		  |*
// *+-------------------------------------------------------------------------+*
// *| Programador		 |	 Data	| Motivo da alteracao					  |*
// *+-------------------+----------+------------------------------------------+*
// *|Heverson  		 |28/03/08	|Alterado para tratar nf de devolucao	      |*
// *+-------------------+----------+------------------------------------------+*
// ****************************************************************************

#Include "RwMake.ch"
#Include "XMLXFUN.CH"
#Define _LF   Chr(10)
#Define CRLF  Chr(13)+Chr(10)

// *-------------------*
User Function LeXml()
// *-------------------* 

Local _cRet := ""

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'LeXml')

Private oProcess
Private lExcJob := IsBlind()
Private _ddataaux      := dDataBase//Incluido 31/01/11 Ana - Pois estava alterando a data base do sistema apos execucao da rotina, depois de executa-la deve retornar ao valor original						

If !lExcJob 
 // COLOCAR O MSGYESNO AQUI, ou melhor colocar a pergunta 
	oProcess:=MsNewProcess():New({||fLeXml()},"Processando","Processando XML...",.T.)
	oProcess:Activate()
Else
	fLeXml()
EndIf 

dDataBase := _ddataaux //Incluido 31/01/11 Ana - Pois estava alterando a data base do sistema apos execucao da rotina, depois de executa-la deve retornar ao valor original						

Return

*----------------------*
Static Function fLeXml()
*----------------------*
Local   nArqXml        := 0
Local   cErro          := ""
Local   cAviso         := ""
Local   cArqXml        := ""
Local   cNewXml        := ""
Local   aFiles         := {}
Private cEmpPad        := If(lExcJob,"01",cEmpAnt)
Private cFilPad        := If(lExcJob,"01",cFilAnt)
Private lOk            := .T.
Private cAssunto       := ""
Private cBody          := ""
Private lAutoErrNoFile := .T.   

If lExcJob
	RpcSetType(3)
	RpcSetEnv( cEmpPad , cFilPad , , , , "LE_XML" )
EndIf

Private cLocFile := Trim(GetMv("MV_XXXML",.F.,"\XML\"))
Private cFrom    := GetMv("MV_RELFROM")
Private cMailTo  := GetMv("MV_XXMAIL",.F.,"eduardo@adoro.com.br") 

If lExcJob
	RpcClearEnv()
EndIf

aFiles := Directory(cLocFile+"*.xml")

If !lExcJob
	oProcess:SetRegua1( Len(aFiles) )
EndIf

For nArqXml := 1 To Len(aFiles)
	
	lOk        := .T.
	cArqXml    := Lower(cLocFile+aFiles[nArqXml][1])
	
	If !lExcJob
		oProcess:IncRegua1("Processando Aquivo: "+cArqXml)
	EndIf
	
	cAssunto   := "Processamento Aquivo: "+cArqXml+" em "+DToC(Date())+" - "+Time()
	cBody      := "<Htm><br>"+CRLF
	
	cErro      := ""
	
	ConOut( FunName()+" - Inicio processamento Aquivo: "+cArqXml+" em "+DToC(Date())+" - "+Time() )
	
	cBody      += "Processamento Arquivo : "+cArqXml+"<br>"+CRLF
	cBody      += "<br>"+CRLF
	
	cAliasXml  := Left(aFiles[nArqXml][1],At(".",aFiles[nArqXml][1])-1)
	
	oXML       := XMLParserFile( cArqXml , "_",@cErro,@cAviso)
	
	If !( Empty(cErro) .And. Empty(cAviso) .And. oXml <> Nil)
		cNewXml := StrTran(cArqXml,".XML",".ERR")
		cBody   += "O Arquivo : " + cArqXml + " / Alias : " + cAliasXml + " foi renomeado para " + cNewXml + "<br>"+CRLF
		cBody   += "Arquivo com Erro : " + cErro + "<br>"+CRLF
		cBody   += cAviso + "<br>"+CRLF
		cBody   += "<br>"+CRLF
		ConOut( FunName()+" - Atencao Erro: " + cErro )
		ConOut( FunName()+" - O Arquivo " + cArqXml + " foi renomeado para " + cNewXml )
		FRename(cArqXml,cNewXml)
	Else
		lOk := fProcXml(oXml,cAliasXml,@lOk)
		
		cNewXml := StrTran(cArqXml,".XML",If(lOk,".OK",".PRC"))
		cBody   += "O Arquivo : " + cArqXml + " / Alias : " + cAliasXml + " foi processado com sucesso <br>"+CRLF
		cBody   += "O Arquivo : " + cArqXml + " / Alias : " + cAliasXml + " foi renomeado para " + cNewXml + "<br>"+CRLF
		cBody   += "<br>"+CRLF
		ConOut( FunName()+" - O Arquivo " + cArqXml + " Foi processado com sucesso" )
		ConOut( FunName()+" - O Arquivo " + cArqXml + " foi renomeado para " + cNewXml )
		FRename(cArqXml,cNewXml)
	EndIf
	cBody += "</Htm>"
	
	ConOut( FunName()+" - Final processamento Aquivo: "+cArqXml+" em "+DToC(Date())+" - "+Time() )
	
	*-----------------------------------*
	* Envio do processamento do arquivo *
	*-----------------------------------*
	If !Empty(cMailTo)
		U__EnviaMail(cFrom,cMailTo,cAssunto,,cBody)
	EndIf
	
Next nArqXml

Return

*------------------------------------------*
Static Function fProcXML(oXml,cAliasXml,lOk)
*------------------------------------------*
Local   nRegXml,cTpMov,aMovim := {}

If lExcJob
	RpcSetType(3)
	RpcSetEnv( cEmpPad , cFilPad , , , , "LE_XML" )
EndIf

cAliasTrb := GetNextAlias()

*--------------------------*
* Cria Arquivo de Trabalho *
*--------------------------*

aCampos := {{ "COD_EMP"    , "C" , 02 , 0 , "EMPRESA"             ,"Left(@@,02)"                             },;
{ "COD_FIL"    , "C" , 02 , 0 , "FILIAL"              ,"Left(@@,02)"                             },;
{ "TP_MOVIMEN" , "C" , 03 , 0 , "TIPO_MOVIMENTO"      ,"Left(@@,03)"                             },;
{ "TP_DE_NOTA" , "C" , 01 , 0 , "TIPO_DE_NOTA"        ,"Left(@@,01)"                             },;
{ "FORM_PROP"  , "C" , 01 , 0 , "FORM_PROP"           ,"Left(@@,01)"                             },;
{ "CLI_FOR"    , "C" , 06 , 0 , "CLI_FOR"             ,"PadR(Right(@@,06),06)"                   },;
{ "LJ_CLI_FOR" , "C" , 02 , 0 , "LOJA_CLI_FOR"        ,"PadR(Right(@@,02),02)"                   },;
{ "ESTADO"     , "C" , 02 , 0 , "ESTADO"              ,"PadR(Right(@@,02),02)"                   },;
/*{ "NR_NFISCAL" , "C" , 06 , 0 , "NR_NFISCAL"          ,"PadR(Right(@@,06),06)"                   },*/;
{ "NR_NFISCAL" , "C" , 09 , 0 , "NR_NFISCAL"          ,"PadR(Right(@@,09),09)"                   },;
{ "DT_EMISSAO" , "D" , 08 , 0 , "DATA_EMISSAO"        ,"SToD(@@)"                                },;
{ "DT_ENTRADA" , "D" , 08 , 0 , "DATA_ENTRADA"        ,"SToD(@@)"                                },;
{ "SERIE"      , "C" , 03 , 0 , "SERIE"               ,"PadR(Left(@@,03),03)"                    },;
{ "ESPECIE"    , "C" , 05 , 0 , "ESPECIE"             ,"PadR(Left(@@,05),05)"                    },;
{ "COD_PROD"   , "C" , 15 , 0 , "COD_PRODUTO"         ,"PadR(Left(@@,15),15)"                    },;
{ "QUANTIDADE" , "N" , 13 , 4 , "QUANTIDADE"          ,"Val(@@)/10000"                           },;
{ "UNIDADE"    , "C" , 02 , 0 , "UNIDADE"             ,"PadR(Left(@@,02),02)"                    },;
{ "VLR_UNIT"   , "N" , 15 , 4 , "VLR_UNITARIO"        ,"NoRound(Val(@@)/10000,4)"                },;
{ "VLR_TOTAL"  , "N" , 13 , 2 , "VLR_TOTAL"           ,"Val(@@)/100"                             },;
{ "TES"        , "C" , 03 , 0 , "TES"                 ,"PadR(Left(@@,03),03)"                    },;
{ "ALMOXARIFA" , "C" , 02 , 0 , "ALMOXARIFADO"        ,"PadR(Left(@@,02),02)"                    },;
{ "BASE_ICMS"  , "N" , 13 , 2 , "BASE_ICMS"           ,"Val(@@)/100"                             },;
{ "VLR_ICMS"   , "N" , 13 , 2 , "VLR_ICMS"            ,"Val(@@)/100"                             },;
{ "ALIQ_ICMS"  , "N" , 05 , 2 , "ALIQUOTA_ICMS"       ,"Val(@@)/100"                             },;
{ "DESC_PERC"  , "N" , 05 , 2 , "DESCONTO_PERCENTUAL" ,"Val(@@)/100"                             },;
{ "DESC_VALOR" , "N" , 13 , 2 , "DESCONTO_VALOR"      ,"Val(@@)/100"                             },;
{ "VLR_BRUTO"  , "N" , 13 , 2 , "VALOR_BRUTO"         ,"Val(@@)/100"                             },;
{ "PESO_LIQ"   , "N" , 13 , 2 , "PESO_LIQUIDO"        ,"Val(@@)/100"                             },;
{ "GRP_PROD"   , "C" , 04 , 0 , "GRUPO_PRODUTO"       ,"PadR(Left(@@,04),04)"                    },;
{ "COND_PAG"   , "C" , 03 , 0 , "CONDICAO_PAGTO"      ,"PadR(Left(@@,03),03)"                    },;
{ "CCUSTO"     , "C" , 09 , 0 , "CENTRO_CUSTO"        ,"PadR(Left(@@,09),09)"                    },;
{ "CCONTABIL"  , "C" , 20 , 0 , "CONTA_CONTABIL"      ,"PadR(Left(@@,20),20)"                    },;
{ "ITEM_CONT"  , "C" , 09 , 0 , "ITEM_CONTABIL"       ,"PadR(Left(@@,09),09)"                    },;
{ "NF_COMPRA"   , "C" , 06 , 0 , "NF_COMPRA"    	   ,"PadR(Right(@@,06),06)"                   },;
{ "SERIE_COM", "C" , 03 , 0 , "SERIE_COM"   		,"PadR(Left(@@,03),03)"                    },;
{ "ITEM_COM"  , "C" , 04 , 0 ,"ITEM_COM"        ,"PadR(Left(@@,04),04)"                    },;
{ "DT_INTEGRA" , "D" , 08 , 0 , "DATA_INTEGRACAO"     ,'SToD(If(At("/",@@)>0,DToS(CToD(@@)),@@))'}}

aStru := {}
aEval(aCampos,{|x| AAdd( aStru , {x[1],x[2],x[3],x[4]} ) } )

cArqTrb  := CriaTrab(aStru,.T.)
cArqInd  := CriaTrab(Nil,.F.)
cChave   := "COD_EMP+COD_FIL+TP_MOVIMEN+TP_DE_NOTA+SERIE+NR_NFISCAL+ESPECIE+CLI_FOR+LJ_CLI_FOR"

If Select(cAliasTrb) > 0
	(cAliasTrb)->(DbCloseArea())
Endif
DbUseArea(.T.,,cArqTrb,cAliasTrb)

(cAliasTrb)->(DbCreateIndex( cArqInd, cChave, {|| &cChave}, .F. ))
(cAliasTrb)->(DbCommitAll())
(cAliasTrb)->(DbGoTop())

(cAliasTrb)->(DbClearInd())
(cAliasTrb)->(DbSetIndex( cArqInd ))
(cAliasTrb)->(DbSetOrder(1))

nRegs := fRet(oXml,cAliasXml,"ITENS",,,"LEN")

If !lExcJob
	oProcess:SetRegua2( nRegs*2 )
EndIf

For nRegXml := 1 To nRegs
	
	If !lExcJob
		oProcess:IncRegua2()
	EndIf
	
	(cAliasTrb)->(RecLock(cAliasTrb,.T.))
	aEval(aCampos,{|x|(cAliasTrb)->(FieldPut( (cAliasTrb)->(FieldPos(x[1])) , &(StrTran(x[6],"@@","fRet(oXml,cAliasXml,'ITENS',"+AllTrim(Str(nRegXml))+",'"+x[5]+"')")) ))})
	(cAliasTrb)->(MsUnLock())
	
	If AScan(aMovim,(cAliasTrb)->(COD_EMP+COD_FIL+TP_MOVIMEN)) == 0
		AAdd( aMovim , (cAliasTrb)->(COD_EMP+COD_FIL+TP_MOVIMEN) )
	EndIf
	
Next nRegXml
(cAliasTrb)->(DbCloseArea())
FErase(cArqInd+IndexExt())

If lExcJob
	RpcClearEnv()
EndIf

For nMovim := 1 To Len(aMovim)
	cTpMov  := Right(aMovim[nMovim],3)
	If lExcJob
		cEmpAnt := Left(aMovim[nMovim],2)
		cFilAnt := SubStr(aMovim[nMovim],3,2)
		
		RpcSetType(3)
		RpcSetEnv( cEmpAnt, cFilAnt, , , , "LE_XML" )
	Else
		cEmpAnt := Left(aMovim[nMovim],2)
		cFilAnt := SubStr(aMovim[nMovim],3,2)
	EndIf
	
	If Select(cAliasTrb) > 0
		(cAliasTrb)->(DbCloseArea())
	Endif
	DbUseArea(.T.,,cArqTrb,cAliasTrb)
	
	(cAliasTrb)->(DbCreateIndex( cArqInd, cChave, {|| &cChave}, .F. ))
	(cAliasTrb)->(DbCommitAll())
	(cAliasTrb)->(DbGoTop())
	
	(cAliasTrb)->(DbClearInd())
	(cAliasTrb)->(DbSetIndex( cArqInd ))
	(cAliasTrb)->(DbSetOrder(1))
	
	If     cTpMov$"NFE|PRE"
		fProcNFE(cFilAnt,cTpMov,cAliasTrb,@lOk)
	ElseIf cTpMov$"NFS"
		fProcNFS(cFilAnt,cTpMov,cAliasTrb,@lOk)
	EndIf
	
	(cAliasTrb)->(DbCloseArea())
	FErase(cArqInd+IndexExt())
	
	If lExcJob
		RpcClearEnv()
	EndIf
Next nMovim

FErase(cArqTrb+GetDbExtension())
FErase(cArqInd+IndexExt())

Return(lOk)

*----------------------------------------------------*
Static Function fProcNFE(cFilReg,cTpMov,cAliasTrb,lOk)
*----------------------------------------------------*
Local cFilSB1  := If( Empty(xFilial("SB1")) , Space(02) , cFilReg )
Local cFilSD1  := If( Empty(xFilial("SD1")) , Space(02) , cFilReg )
Local cFilSF1  := If( Empty(xFilial("SF1")) , Space(02) , cFilReg )
Local cFilSF4  := If( Empty(xFilial("SF4")) , Space(02) , cFilReg )
Local aErros   := {}
Local lPreNota := (cTpMov=="PRE")
Private lMsErroAuto := .f.

(cAliasTrb)->(DbSeek(cEmpAnt+cFilReg+cTpMov))

While !(cAliasTrb)->(Eof()) .And. (cAliasTrb)->COD_EMP    == cEmpAnt .And. (cAliasTrb)->COD_FIL    == cFilReg ;
	.And. (cAliasTrb)->TP_MOVIMEN == cTpMov
	
	lPreNota := (cTpMov=="PRE")
	lErro    := .F.
	cItem	 := StrZero(1,Len(SD1->D1_ITEM))
	cTipoNf  := (cAliasTrb)->TP_DE_NOTA
	cFormul  := (cAliasTrb)->FORM_PROP
	cSerNf   := (cAliasTrb)->SERIE
	cNFiscal := (cAliasTrb)->NR_NFISCAL
	cEspecie := (cAliasTrb)->ESPECIE
	cCliFor  := (cAliasTrb)->CLI_FOR
	cLoja	 := (cAliasTrb)->LJ_CLI_FOR
	dEmissao := (cAliasTrb)->DT_EMISSAO
	dDtDigit := (cAliasTrb)->DT_ENTRADA
	cEstado  := (cAliasTrb)->ESTADO
	cCondPag := (cAliasTrb)->COND_PAG 
	nBaseIcm := 0
	nValIcm  := 0
	nValMerc := 0
	nValBrut := 0
	aItem	 := {}
	
	ConOut( FunName()+" - Processando registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf )
	
	If AScan( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf ) > 0
		(cAliasTrb)->(DbSkip())
		Loop
	EndIf
	
	If cTipoNF $"DB"
		cAliasCli := "SA1"
		cTipoCli  := SA1->A1_TIPO
		cEstCli   := SA1->A1_EST
	Else
		cAliasCli := "SA2"
		cTipoCli  := SA2->A2_TIPO
		cEstCli   := SA2->A2_EST
	EndIf
	
	If !(cAliasCli)->(DbSeek(xFilial(cAliasCli)+cCliFor+cLoja))
		If !lErro
			AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
			cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
			cBody+="Erros :<br>"+CRLF
		EndIf
		lOk   := .F.
		lErro := .T.
		cBody+="Cliente/Fornecedor "+cCliFor+"/"+cLoja+" nao esta cadastrado!<br>"+CRLF
		cBody+="<br>"+CRLF
	EndIf
	
	
	SF1->(DbSetOrder(1))
	If SF1->(DbSeek(cFilSF1+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf))
		lOk   := .F.
		lErro := .T.
		cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado, pois ja existe no sistema!<br>"+CRLF
		AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
		(cAliasTrb)->(DbSkip())
		Loop
	Else
		If SF1->(DbSeek(cFilSF1+Right(cNFiscal,6)+Space(3)+cSerNf+cCliFor+cLoja+cTipoNf))
			lOk   := .F.
			lErro := .T.
			cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado, pois ja existe no sistema!<br>"+CRLF
			AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
			(cAliasTrb)->(DbSkip())
			Loop
		EndIf
	EndIf
	
	
	While !(cAliasTrb)->(Eof()) .And. (cAliasTrb)->COD_EMP    == cEmpAnt ;
		.And. (cAliasTrb)->COD_FIL    == cFilReg ;
		.And. (cAliasTrb)->TP_MOVIMEN == cTpMov	;
		.And. (cAliasTrb)->TP_DE_NOTA == cTipoNf ;
		.And. (cAliasTrb)->SERIE      == cSerNf  ;
		.And. (cAliasTrb)->NR_NFISCAL == cNFiscal;
		.And. (cAliasTrb)->ESPECIE    == cEspecie;
		.And. (cAliasTrb)->CLI_FOR    == cCliFor ;
		.And. (cAliasTrb)->LJ_CLI_FOR == cLoja
		
		If !lExcJob
			oProcess:IncRegua2()
		EndIf
		
		lPreNota := Empty((cAliasTrb)->TES)
		
		If !SB1->(DbSeek(cFilSB1+(cAliasTrb)->COD_PROD))
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="O Produto "+(cAliasTrb)->COD_PROD+" nao esta cadastrado!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
		
		If !SF4->(DbSeek(cFilSF4+(cAliasTrb)->TES)).And.!lPreNota
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="A TES "+(cAliasTrb)->TES+" nao esta cadastrada!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
		
		If (cAliasTrb)->QUANTIDADE == 0
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="Quantidade nao informada<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
		If (cAliasTrb)->VLR_UNIT == 0
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="Valor Unitario nao informado<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
		If (cAliasTrb)->VLR_TOTAL == 0
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="Valor total nao informado!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
		     
		//Incluido 09/08/11 - Ana. Para não importar notas com data menor que o fechamento
		//If (cAliasTrb)->DT_EMISSAO < GETMV("MV_DATAFIS") .or. (cAliasTrb)->DT_ENTRADA < GETMV("MV_DATAFIS")
		//Alterado 02/05/12 - Ana. Conforme solicitacao do departamento fiscal, deve considerar apenas a data de entrada
		If (cAliasTrb)->DT_ENTRADA < GETMV("MV_DATAFIS")
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="Data de Entrada menor que a data do fechamento (MV_DATAFIS)<br>"+CRLF
			cBody+="<br>"+CRLF		
		Endif       
		
		If !lErro
			//alterado Davi - Eliminado o processo de conversao de unidade de medida
			cUM := If(Empty((cAliasTrb)->UNIDADE),SB1->B1_UM,(cAliasTrb)->UNIDADE)
//			cUM := SB1->B1_UM //(cAliasTrb)->UNIDADE
			_nValUnit	:= round(((cAliasTrb)->VLR_TOTAL / (cAliasTrb)->QUANTIDADE) ,4)
			
			// *** INICIO ALTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA *** //
	
			IF !RetArqProd((cAliasTrb)->COD_PROD)
			
				_cLocPad := POSICIONE("SBZ",1,xFilial("SBZ")+(cAliasTrb)->COD_PROD,"BZ_LOCPAD")
				
			ELSE
			
				_cLocPad := POSICIONE("SB1",1,xFilial("SB1")+(cAliasTrb)->COD_PROD,"B1_LOCPAD")
		
			ENDIF
			
			// *** FINAL ALTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA *** //
			
			AAdd(aItem,{{"D1_FILIAL" ,cFilSD1                                     ,Nil},;
			{"D1_COD"    ,(cAliasTrb)->COD_PROD                       ,Nil},;
			{"D1_DOC"    ,(cAliasTrb)->NR_NFISCAL                     ,Nil},;
			{"D1_SERIE"  ,(cAliasTrb)->SERIE                          ,Nil},;
			{"D1_ITEM"   ,cItem                                       ,Nil},;
			{"D1_UM"     ,cUm                                         ,Nil},;
			{"D1_QUANT"  ,(cAliasTrb)->QUANTIDADE                     ,Nil},;
			{"D1_VUNIT"  ,_nValUnit 				                       ,Nil},;
			{"D1_TOTAL"  ,(cAliasTrb)->VLR_TOTAL                      ,Nil},;
			{"D1_PICM"   ,(cAliasTrb)->ALIQ_ICMS                      ,Nil},;
			{"D1_IPI"    ,0                                           ,Nil},;
			{"D1_FORNECE",(cAliasTrb)->CLI_FOR                        ,Nil},;
			{"D1_LOJA"   ,(cAliasTrb)->LJ_CLI_FOR                     ,Nil},;
			{"D1_EMISSAO",(cAliasTrb)->DT_EMISSAO                     ,Nil},;
			{"D1_DTDIGIT",(cAliasTrb)->DT_ENTRADA                     ,Nil},;
			{"D1_LOCAL"  ,_cLocPad                                    ,Nil},;
			{"D1_CC"     ,(cAliasTrb)->CCUSTO                         ,Nil},;
			{"D1_CONTA"  ,(cAliasTrb)->CCONTABIL                      ,Nil},;
			{"D1_ITEMCTA",(cAliasTrb)->ITEM_CONT                      ,Nil},;
			{"D1_GRUPO"  ,(cAliasTrb)->GRP_PROD                       ,Nil},;
			{"D1_TP"     ,SB1->B1_TIPO                                ,Nil},;
			{"D1_FORMUL" ,cFormul                                     ,Nil},;
			{"D1_TIPO"   ,cTipoNF                                     ,Nil},;
			{"D1_PESO"   ,(cAliasTrb)->PESO_LIQ                       ,Nil},;
			{"D1_DESC"   ,(cAliasTrb)->DESC_PERC                      ,Nil},;
			{"D1_VALDESC",(cAliasTrb)->DESC_VALOR                     ,Nil},;
			{"AUTDELETA" ,"N"                                         ,Nil}})
			
			If !lPreNota
				AAdd( aItem[Len(aItem)] ,  {"D1_TES" ,(cAliasTrb)->TES                                 ,Nil} )
				//                 AAdd( aItem[Len(aItem)] ,  {"D1_CF"  ,fCfop(cFilSF4,(cAliasTrb)->TES,cTipoCli,cEstCli) ,Nil} )
			EndIf
			
			cItem    := Soma1(cItem,Len(SD1->D1_ITEM))
			nBaseIcm += (cAliasTrb)->BASE_ICMS
			nValIcm  += (cAliasTrb)->VLR_ICMS
			nValMerc += (cAliasTrb)->VLR_TOTAL
			nValBrut += (cAliasTrb)->VLR_BRUTO
		EndIf
		(cAliasTrb)->(DbSkip())
	End
	
	If !lErro
		aCab := {{"F1_FILIAL" , cFilSF1  ,NIL},;
		{"F1_TIPO"   , cTipoNF  ,NIL},;
		{"F1_FORMUL" , cFormul  ,NIL},;
		{"F1_DOC"    , cNFiscal ,NIL},;
		{"F1_SERIE"  , cSerNf   ,NIL},;
		{"F1_EMISSAO", dEmissao ,NIL},;
		{"F1_DTDIGIT", dDtDigit ,NIL},;
		{"F1_FORNECE", cCliFor  ,NIL},;
		{"F1_LOJA"   , cLoja    ,NIL},;
		{"F1_EST"    , cEstado  ,Nil},;
		{"F1_COND"   , cCondPag ,NIL},;
		{"F1_ESPECIE", cEspecie ,NIL},;
		{"F1_BASEICM", nBaseIcm ,NIL},;
		{"F1_VALICM" , nValIcm  ,NIL},;
		{"F1_VALMERC", nValMerc ,NIL},;
		{"F1_VALBRUT", nValBrut ,NIL},;
		{"F1_ORIGEM" , "LEXML"  ,NIL},;
		{"F1_MOEDA"  , 1        ,Nil}}
		lMsErroAuto := .F.
		If lPreNota
			ddatabase:=dDtDigit
			MSExecAuto({|x,y,z| Mata140(x,y,z) }, aCab, aItem, 3)
			If lMsErroAuto
			  //					MostraErro()
			EndIf
		Else
			ddatabase:=dDtDigit
			MSExecAuto({|x,y,z| Mata103(x,y,z) }, aCab, aItem, 3)
			If lMsErroAuto
				//				MostraErro()
			EndIf
			
		EndIf
		
		If lMsErroAuto
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			aErros := GetAutoGrLog()
			For nErro := 1 To Len(aErros)
				cBody+= aErros[nErro]+"<br>"+CRLF
			Next nErro
			cBody+="<br>"+CRLF
		Else
			cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" foi importado com sucesso!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
	EndIf
End

Return(lOk)

*----------------------------------------------------*
Static Function fProcNFS(cFilReg,cTpMov,cAliasTrb,lOk)
*----------------------------------------------------*
Local cFilSB1  := If( Empty(xFilial("SB1")) , Space(02) , cFilReg )
Local cFilSB2  := If( Empty(xFilial("SB2")) , Space(02) , cFilReg )
Local cFilSC5  := If( Empty(xFilial("SC5")) , Space(02) , cFilReg )
Local cFilSC6  := If( Empty(xFilial("SC6")) , Space(02) , cFilReg )
Local cFilSC9  := If( Empty(xFilial("SC9")) , Space(02) , cFilReg )
Local cFilSE4  := If( Empty(xFilial("SE4")) , Space(02) , cFilReg )
Local cFilSF2  := If( Empty(xFilial("SF2")) , Space(02) , cFilReg )
Local cFilSF4  := If( Empty(xFilial("SF4")) , Space(02) , cFilReg )
Local cFilSD1  := If( Empty(xFilial("SD1")) , Space(02) , cFilReg )
Local cFilSF1  := If( Empty(xFilial("SF1")) , Space(02) , cFilReg )
Local cchavetrb:= "" 
Local aErros   := {}
Local aCab     := {}
Local aItem    := {}
Local aPvlNfs  := {}
Local cItem
Private lMsErroAuto := .f.
Public cNFiscal,cSerNf

(cAliasTrb)->(DbSeek(cEmpAnt+cFilReg+cTpMov))
While !(cAliasTrb)->(Eof()) .And. (cAliasTrb)->COD_EMP    == cEmpAnt ;
	.And. (cAliasTrb)->COD_FIL    == cFilReg ;
	.And. (cAliasTrb)->TP_MOVIMEN == cTpMov
	
	lErro    := .F.
	cItem    := StrZero(1,Len(SC6->C6_ITEM))
	cTipoNf  := (cAliasTrb)->TP_DE_NOTA
	cSerNf   := (cAliasTrb)->SERIE
	cNFiscal := (cAliasTrb)->NR_NFISCAL
	cEspecie := (cAliasTrb)->ESPECIE
	cCliFor  := (cAliasTrb)->CLI_FOR
	cLoja	 := (cAliasTrb)->LJ_CLI_FOR
	dEmissao := (cAliasTrb)->DT_EMISSAO
	dDtDigit := (cAliasTrb)->DT_ENTRADA
	cEstado  := (cAliasTrb)->ESTADO
	cCondPag := (cAliasTrb)->COND_PAG
	cNFOri	 := (cAliasTrb)->NF_COMPRA  	
	cSerOri	 := (cAliasTrb)->SERIE_COM 
	cItemOri := SPACE(4) //"00" + (cAliasTrb)->ITEM_COM 
	cProduto := (cAliasTrb)->COD_PROD         

	nValMerc := 0
	nValBrut := 0
	aItem	   := {}
	ConOut( FunName()+" - Processando registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf )
	
	If AScan( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf ) > 0
		(cAliasTrb)->(DbSkip())
		Loop
	EndIf
	
	If cTipoNF $ "DB"
		cAliasCli := "SA2"
		cTipoCli  := "R"
		cEstCli   := SA2->A2_EST
	Else
		dbSelectArea( "SA1" )
		dbSetOrder( 01 )
		dbSeek( xFilial( "SA1" ) + cCLiFor + cLoja )
		
		cAliasCli := "SA1"
		cTipoCli  := SA1->A1_TIPO
		cEstCli   := SA1->A1_EST
	EndIf
	
	If !(cAliasCli)->(DbSeek(xFilial(cAliasCli)+cCliFor+cLoja))
		If !lErro
			AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
			cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
			cBody+="Erros :<br>"+CRLF
		EndIf
		lOk   := .F.
		lErro := .T.
		cBody+="Cliente/Fornecedor "+cCliFor+"/"+cLoja+" nao esta cadastrado!<br>"+CRLF
		cBody+="<br>"+CRLF
	EndIf

	If cTipoNF $ "D"
    		SF1->(DbSetOrder(1))
   		If !SF1->(DbSeek(cFilSF1+cNFOri+cSerOri+cCliFor+cLoja,.T.))
	   		lOk   := .F.
		  		lErro := .T.
		  		cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFORI+"/"+cSerORI+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado, pois nao existe nf de entrada !<br>"+CRLF
	  			AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
	  			(cAliasTrb)->(DbSkip())
	  	 	Loop
   		EndIf
	Endif 
	
	
	SF2->(DbSetOrder(1))
	If SF2->(DbSeek(cFilSF2+cNFiscal+cSerNf+cCliFor+cLoja))
		lOk   := .F.
		lErro := .T.
		cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado, pois ja existe no sistema!<br>"+CRLF
		AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
		(cAliasTrb)->(DbSkip())
		Loop
	EndIf
	
	*-----------------------------*
	* Geracao do pedido de vendas *
	*-----------------------------*
	DbSelectArea(cAliasTrb)
	cPedido := GetSxeNum("SC5","C5_NUM")
	SC5->(dbSetOrder(1))
	While SC5->(dbSeek(cFilReg+cPedido))
		ConfirmSX8()
		cPedido := GetSxeNum("SC5","C5_NUM")
	End
	//        BeginTran()
	
	While !(cAliasTrb)->(Eof()) .And. (cAliasTrb)->COD_EMP    == cEmpAnt ;
		.And. (cAliasTrb)->COD_FIL    == cFilReg ;
		.And. (cAliasTrb)->TP_MOVIMEN == cTpMov ;
		.And. (cAliasTrb)->TP_DE_NOTA == cTipoNf ;
		.And. (cAliasTrb)->SERIE      == cSerNf  ;
		.And. (cAliasTrb)->NR_NFISCAL == cNFiscal;
		.And. (cAliasTrb)->ESPECIE    == cEspecie;
		.And. (cAliasTrb)->CLI_FOR    == cCliFor ;
		.And. (cAliasTrb)->LJ_CLI_FOR == cLoja
		
		If !lExcJob
			oProcess:IncRegua2()
		EndIf
		
		If !SB1->(DbSeek(cFilSB1+(cAliasTrb)->COD_PROD))
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="O Produto "+(cAliasTrb)->COD_PROD+" nao esta cadastrado!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
		
		If !SF4->(DbSeek(cFilSF4+(cAliasTrb)->TES))
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="A TES "+(cAliasTrb)->TES+" nao esta cadastrada!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
		
		If (cAliasTrb)->QUANTIDADE == 0
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="Quantidade nao informada!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
		If (cAliasTrb)->VLR_UNIT == 0
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="Valor Unitario nao informado!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf

		If (cAliasTrb)->VLR_TOTAL == 0
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="Valor total nao informado!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf

		If (cAliasTrb)->TP_DE_NOTA $ "D"  
		CChaveTrb:= (cAliasTrb)->(NF_COMPRA + SERIE_COM + CLI_FOR + LJ_CLI_FOR + COD_PROD)		
    	SD1->(DbSetOrder(1))
   		 If !SD1->(DbSeek(cFilSD1 + CChaveTrb ,.T.))
//    			 If !lErro
	  				cBody+="O Registro " + CChaveTrb + " nao foi importado, pois nao existe nf de entrada !<br>"+CRLF
	  				AAdd( aErros , cFilReg+cChaveTrb )
//             endif 
	   	 		lOk   := .F.
	  		 		lErro := .T.
		  	 else
			  	 cItemOri := SD1->D1_ITEM 
   		EndIf
		Endif 
 
			
		If !lErro
			cUM := If(Empty((cAliasTrb)->UNIDADE),SB1->B1_UM,(cAliasTrb)->UNIDADE)
			
			// *** INICIO ALTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA *** //
	
			IF !RetArqProd((cAliasTrb)->COD_PROD)
			
				_cLocPad := POSICIONE("SBZ",1,xFilial("SBZ")+(cAliasTrb)->COD_PROD,"BZ_LOCPAD")
				
			ELSE
			
				_cLocPad := POSICIONE("SB1",1,xFilial("SB1")+(cAliasTrb)->COD_PROD,"B1_LOCPAD")
		
			ENDIF
			
			// *** FINAL ALTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA *** //
			
			If SB1->B1_CONV<=1
				AAdd( aItem  , {{"C6_FILIAL" ,cFilSC6      ,Nil},;
								{"C6_ITEM"   ,cItem                        ,Nil},;     // 02
								{"C6_PRODUTO",(cAliasTrb)->COD_PROD        ,Nil},;    //  03
								{"C6_DESCRI" ,SB1->B1_DESC                 ,Nil},;    // 04
								{"C6_UNSVEN" ,(cAliasTrb)->QUANTIDADE      ,Nil},;   //  06
					         	{"C6_PRCVEN" ,(cAliasTrb)->VLR_UNIT        ,Nil},;   //  07
								{"C6_UM"     ,cUM                          ,Nil},;    //  09
								{"C6_QTDVEN" ,(cAliasTrb)->QUANTIDADE      ,Nil},;    // 10
								{"C6_TES"    ,(cAliasTrb)->TES             ,Nil},;    // 11
								{"C6_QTDLIB" ,(cAliasTrb)->QUANTIDADE      ,Nil},;    // 12
								{"C6_LOCAL"  ,_cLocPad 			     	  ,Nil},;    // 15
								{"C6_CLI"    ,(cAliasTrb)->CLI_FOR         ,Nil},;    // 19
								{"C6_DESCONT",(cAliasTrb)->DESC_PERC       ,Nil},;    // 20
								{"C6_VALDESC",(cAliasTrb)->DESC_VALOR      ,Nil},;    // 21
								{"C6_ENTREG" ,(cAliasTrb)->DT_EMISSAO      ,Nil},;    // 22
								{"C6_NFORI"  ,(cAliasTrb)->NF_COMPRA        ,Nil},;    // 22
								{"C6_SERIORI",(cAliasTrb)->SERIE_COM     ,Nil},;    // 22
								{"C6_ITEMORI",cItemOri 				     ,Nil},;    // 22
								{"C6_LOJA"   ,(cAliasTrb)->LJ_CLI_FOR      ,Nil},;    // 24
								{"C6_NUM"    ,cPedido                      ,Nil},;    // 28
								{"C6_PRUNIT" ,(cAliasTrb)->VLR_UNIT			 ,Nil},;    // 35
								{"C6_OP"     ,"02"                         ,Nil},;    // 39
								{"C6_TPOP"   ,"F"                          ,Nil}} )   // 67
         Else
				AAdd( aItem  , {{"C6_FILIAL" ,cFilSC6      ,Nil},;
								{"C6_ITEM"   ,cItem                        ,Nil},;     // 02
								{"C6_PRODUTO",(cAliasTrb)->COD_PROD        ,Nil},;    //  03
								{"C6_DESCRI" ,SB1->B1_DESC                 ,Nil},;    // 04
								{"C6_SEGUM"  ,cUM									  ,Nil},;    //  05
								{"C6_UNSVEN" ,(cAliasTrb)->QUANTIDADE      ,Nil},;   //  06
					        	{"C6_PRCVEN" ,(cAliasTrb)->VLR_UNIT        ,Nil},;   //  07
								{"C6_UM"     ,cUM                          ,Nil},;    //  09
								{"C6_QTDVEN" ,(cAliasTrb)->QUANTIDADE      ,Nil},;    // 10
								{"C6_TES"    ,(cAliasTrb)->TES             ,Nil},;    // 11
								{"C6_QTDLIB" ,(cAliasTrb)->QUANTIDADE      ,Nil},;    // 12
								{"C6_LOCAL"  ,_cLocPad 							  ,Nil},;    // 15
								{"C6_CLI"    ,(cAliasTrb)->CLI_FOR         ,Nil},;    // 19
								{"C6_DESCONT",(cAliasTrb)->DESC_PERC       ,Nil},;    // 20
								{"C6_VALDESC",(cAliasTrb)->DESC_VALOR      ,Nil},;    // 21
								{"C6_ENTREG" ,(cAliasTrb)->DT_EMISSAO      ,Nil},;    // 22
								{"C6_NFORI"  ,(cAliasTrb)->NF_COMPRA        ,Nil},;    // 22
								{"C6_SERIORI",(cAliasTrb)->SERIE_COM	    ,Nil},;    // 22
								{"C6_ITEMORI",cItemOri 			        	 ,Nil},;    // 22
								{"C6_LOJA"   ,(cAliasTrb)->LJ_CLI_FOR      ,Nil},;    // 24
								{"C6_NUM"    ,cPedido                      ,Nil},;    // 28
								{"C6_PRUNIT" ,(cAliasTrb)->VLR_UNIT			 ,Nil},;    // 35
								{"C6_OP"     ,"02"                         ,Nil},;    // 39
								{"C6_TPOP"   ,"F"                          ,Nil}} )   // 67
			Endif					
			//         {"C6_VALOR"  ,(cAliasTrb)->VLR_TOTAL       ,Nil},;
			//         {"C6_CLASFIS","A"                                                 ,Nil}} )
			//         {"C6_CF"     ,"" fCfop(cFilSF4,(cAliasTrb)->TES,cTipoCli,cEstCli) ,Nil},;
			//         {"C6_PRUNIT" ,(cAliasTrb)->VLR_UNIT                               ,Nil},;
			//		     {"C6_PRCVEN" ,(cAliasTrb)->VLR_TOTAL/(cAliasTrb)->QUANTIDADE ,Nil},;
			
			cItem := Soma1(cItem,Len(SC6->C6_ITEM))
		EndIf
		(cAliasTrb)->(DbSkip())
	End
	
	If lErro
		DisarmTransaction()
		RollBackSxe()
		Loop
	EndIf
	// alterado Davi Jesus
	aCab := {{"C5_FILIAL" ,cFilSC5      ,Nil},;
	{"C5_NUM"    ,cPedido      ,Nil},;
	{"C5_TIPO"   ,cTipoNF      ,Nil},;
	{"C5_CLIENTE",cCliFor      ,Nil},;
	{"C5_LOJAENT",cLoja        ,Nil},;
	{"C5_LOJACLI",cLoja        ,Nil},;
	{"C5_CONDPAG",cCondPag     ,Nil},;     // 15
	{"C5_TIPLIB" ,"1"          ,Nil},;     // 21
	{"C5_TIPOCLI",cTipoCli     ,Nil},;     // 28
	{"C5_EMISSAO",dEmissao     ,Nil},;     // 40
	{"C5_MOEDA"  ,1            ,Nil},;     // 53
	{"C5_LIBEROK","S"          ,Nil}}      // 71
	
	RegToMemory("SC5")
	M->C5_FILIAL := cFilSC5
	
	RegToMemory("SC6")  
M->C6_FILIAL := cFilSC6
	
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItem,3)
	If lMsErroAuto
 //			MostraErro()
		If !lErro
			AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
			cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
			cBody+="Erros :<br>"+CRLF
		EndIf
		lOk   := .F.
		lErro := .T.
		aErros := GetAutoGrLog()
		For nErro := 1 To Len(aErros)
			cBody+= aErros[nErro]+"<br>"+CRLF
		Next nErro
		cBody+="<br>"+CRLF
		DisarmTransaction()
	Else
		cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" foi gerado o pedido "+cPedido+" com sucesso!<br>"+CRLF
		cBody+="<br>"+CRLF
	EndIf
	DbSelectArea(cAliasTrb)
	//      EndTran()
	
	If lErro
		Loop
	EndIf
	
	*------------------------------*
	* Liberacao do pedido de venda *
	*------------------------------*
	SC5->(DbSetOrder(1))
	SC6->(DbSetOrder(1))
	SE4->(DbSetOrder(1))
	SB1->(DbSetOrder(1))
	SB2->(DbSetOrder(1))
	SF4->(DbSetOrder(1))
	
	*--------------------------------------*
	* Define Variaveis usados pelo MATA440 *
	*--------------------------------------*
	lGerouPv := .T.
	lLiber   := .T.
	lTrans   := .F.
	lCredito := .F.
	lEstoque := .F.
	lAvCred  := .T.
	lAvEst   := .T.
	lLiberOk := .T.
	lItLib   := .T.
	aPvlNfs  := {}
	DDATABASE:= dEmissao
	DbSelectArea(cAliasTrb)
	
	//        BeginTran()
	*-----------------------------*
	* Efetua a Liberacao por item *
	*-----------------------------*
	SC5->(DbSeek(cFilSC5+cPedido))
	SC6->(DbSeek(cFilSC6+cPedido))
	While !SC6->(Eof()) .And. SC6->C6_FILIAL == cFilSC6 .And. SC6->C6_NUM  == cPedido
		
		nQtdLib := SC6->C6_QTDVEN
		
		*----------------------------------------------*
		* Posiciona registros para efetuar a liberacao *
		*----------------------------------------------*
		SB1->(DbSeek(cFilSB1+SC6->C6_PRODUTO))
		
		nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,lAvCred,lAvEst,lLiber,lTrans)
		
		If nQtdLib != SC6->C6_QTDVEN
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lGerouPv := .F.
			lOk      := .F.
			lErro    := .T.
			cBody+="Nao foi possivel liberar o Produto "+Trim(SC6->C6_PRODUTO)+"!<br>"+CRLF
			cBody+="<br>"+CRLF
			DisarmTransaction()
			Exit
		EndIf
		                 
		SC9->( dbSetOrder(1) )
		IF SC9->(DbSeek(cFilSC9+SC6->C6_NUM+SC6->C6_ITEM))
			
			SC9->(RecLock("SC9",.F.))
			SC9->C9_BLEST  := ""
			SC9->C9_BLCRED := ""
			SC9->C9_DTENTR := DDATABASE
			
		ELSE
			
			SC9->(RecLock("SC9",.T.))
			SC9->C9_BLEST   := ""
			SC9->C9_BLCRED  := ""
			SC9->C9_DTENTR  := DDATABASE
			SC9->C9_FILIAL  := XFILIAL("SC9")
			SC9->C9_PEDIDO  := SC6->C6_NUM
			SC9->C9_ITEM    := SC6->C6_ITEM
			SC9->C9_CLIENTE := SC6->C6_CLI
			SC9->C9_LOJA    := SC6->C6_LOJA
			SC9->C9_PRODUTO := SC6->C6_PRODUTO
			SC9->C9_DATALIB := dDataBase
			SC9->C9_PRCVEN  := SC6->C6_PRCVEN
			SC9->C9_BLEST   := "10"
			SC9->C9_BLCRED  := "10"
			SC9->C9_LOCAL   := SC6->C6_LOCAL
			SC9->C9_QTDLIB  := SC6->C6_QTDVEN
			
		ENDIF
		
		SC9->(MsUnLock())
		
		SE4->(DbSeek(cFilSE4+SC5->C5_CONDPAG) )
		SB1->(DbSeek(cFilSB1+SC6->C6_PRODUTO) )
		SB2->(DbSeek(cFilSB2+SC6->C6_PRODUTO+SC6->C6_LOCAL) )
		SF4->(DbSeek(cFilSF4+SC6->C6_TES) )
		
		Aadd(aPvlnfs, { SC9->C9_PEDIDO  ,;
		SC9->C9_ITEM    ,;
		SC9->C9_SEQUEN  ,;
		SC9->C9_QTDLIB  ,;
		SC9->C9_PRCVEN  ,;
		SC9->C9_PRODUTO ,;
		SF4->F4_ISS=="S",;
		SC9->(RecNo())  ,;
		SC5->(RecNo())  ,;
		SC6->(RecNo())  ,;
		SE4->(RecNo())  ,;
		SB1->(RecNo())  ,;
		SB2->(RecNo())  ,;
		SF4->(RecNo())  ,;
		SC9->C9_LOCAL   })

		SC6->(DbSkip())
	End
	DbSelectArea(cAliasTrb)
	//       EndTran()
	
	*---------------------------------*
	* Geracao da nota fiscal de saida *
	*---------------------------------*
	If lGerouPv .And. Len(aPvlnfs) > 0
		Pergunte("MT461A",.f.)
		
		lMostraCtb   := .F.
		lAglutCtb    := .F.
		lCtbOnLine   := .F.
		lCtbCusto    := .F.
		lReajuste    := .F.
		nCalAcrs     := 0
		nArredPrcLis := 0
		lAtuSA7      := .F.
		lECF         := .F.
		
		cNota := MaPvlNfs(aPvlNfs,"XML",lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,nCalAcrs,nArredPrcLis,lAtuSA7,lECF)
		If cNota != cNFiscal .Or. !SF2->(DbSeek(cFilSF2+cNota+cSerNf+cCliFor+cLoja))
			If !lErro
				AAdd( aErros , cFilReg+cNFiscal+cSerNf+cCliFor+cLoja+cTipoNf )
				cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" nao foi importado!<br>"+CRLF
				cBody+="Erros :<br>"+CRLF
			EndIf
			lOk   := .F.
			lErro := .T.
			cBody+="Nao foi possivel gerar a nota fiscal de saida "+cSerNf+"-"+cNFiscal+" !<br>"+CRLF
			cBody+="<br>"+CRLF
		Else
			cBody+="O Registro "+cTpMov+"-"+cFilReg+"/"+cNFiscal+"/"+cSerNf+"/"+cCliFor+"/"+cLoja+"/"+cTipoNf+" foi gerado a NF "+cSerNf+"/"+cNota+" com sucesso!<br>"+CRLF
			cBody+="<br>"+CRLF
		EndIf
	EndIf
	
End

Return(lOk)

*--------------------------------------------------------------------*
Static Function fRet(oXml,cAliasXml,cItemXml,nItemXml,cVarXml,cFuncao)
*--------------------------------------------------------------------*
Local xRet, lIsArray

cAliasXml := If(cAliasXml==Nil,"",If(Left(cAliasXml,1)!="_","_","") + cAliasXml)
cItemXml  := If(cItemXml ==Nil,"",If(Left(cItemXml ,1)!="_","_","") + cItemXml)
nItemXml  := If(nItemXml ==Nil,"",AllTrim(Str(nItemXml)))
cVarXml   := If(cVarXml  ==Nil,"",If(Left(cVarXml  ,1)!="_","_","") + cVarXml)
cFuncao   := If(cFuncao  ==Nil,"",cFuncao)

xRet := "oXml:"+cAliasXml + If(!Empty(cItemXml),":"+cItemXml    ,"")

lIsArray := ValType(&xRet) == "A"

If lIsArray
	xRet += If(!Empty(nItemXml),"["+nItemXml+"]","")
EndIf

xRet += If(!Empty(cVarXml) ,":"+cVarXml ,"") + If(Empty(cFuncao) ,":TEXT" ,"")

If lIsArray
	xRet := If(!Empty(cFuncao),cFuncao+"(","") + xRet + If(!Empty(cFuncao),")","")
Else
	If !Empty(cFuncao)
		xRet := "1"
	EndIf
EndIf

Return(&xRet)

*--------------------------------------------------*
Static Function fCfop(cFilSF4,cTes,cTipoCli,cEstCli)
*--------------------------------------------------*
Local aAreaSF4 := SF4->(GetArea())
Local cRet     := ""
Local cAliasTab

SF4->(DbSetOrder(1))
If SF4->(DbSeek(cFilSF4+cTES,.F.))
	If SF4->F4_CODIGO >= "500"
		cRet := If(cTipoCli != "X",If(cEstCli == AllTrim(GetMv("MV_ESTADO")),SF4->F4_CF,"6"+;
		Subs(SF4->F4_CF,2,Len(SF4->F4_CF)-1)),"7"+Subs(SF4->F4_CF,2,Len(SF4->F4_CF)-1))
	Else
		cRet := If(cTipoCli != "X",If(cEstCli == AllTrim(GetMv("MV_ESTADO")),SF4->F4_CF,"2"+;
		Subs(SF4->F4_CF,2,Len(SF4->F4_CF)-1)),"3"+Subs(SF4->F4_CF,2,Len(SF4->F4_CF)-1))
	endif
Endif
RestArea(aAreaSF4)
Return(cRet)

User Function _EnviaMail(cFrom,cTo,cAssunto,cAttach,cBody)

U_ADINF009P('LEXML' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'LeXml')

cAttach := If(cAttach==Nil,"",AllTrim(cAttach))

If !Empty(cAttach).And.!File(cAttach)
	ApMsgInfo("Arquivo Anexo ("+cAttach+") nao encontrado!")
	Return
EndIF

If lExcJob
	RpcSetType(3)
	RpcSetEnv( cEmpPad , cFilPad , , , , "LE_XML" )
EndIf

cFrom       := If(cFrom==Nil,GetMv("MV_RELFROM"),cFrom)
aTo         := {cTo}
aCC         := {}
aBcc        := {}
cSubject    := cAssunto

aAttach     := {}
AAdd( aAttach , cAttach )

cMailServer := GetMv("MV_RELSERV")
cMailConta  := GetMv("MV_RELACNT")
cMailSenha  := GetMv("MV_RELPSW")

If MailSmtpOn( cMailServer, cMailConta, cMailSenha )
	If !MailAuth(cMailConta,cMailSenha)
		MsgStop("erro na Autenticação !!!")
		Return
	Endif
	If !MailSend(cFrom,aTo,aCc,aBcc,cSubject,cBody,aAttach,.T.)
		Msgstop("Erro no envio do e-mail!! - " + MailGetErr())
	EndIf
	lDiscSmtp:=MailSmtpOff()
Else
	cErrorMsg:= "Erro na Conexão!!!"  + MailGetErr()
EndIf
If lExcJob
	RpcClearEnv()
EndIf

FErase(cAttach)
Return