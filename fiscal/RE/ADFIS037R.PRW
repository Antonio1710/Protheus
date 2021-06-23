#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"

/*/{Protheus.doc} User Function ADFIS037R
  Relatório de Devolução de Compras
  @type  Function
  @author Abel Babini
  @since 27/04/2020
  @version 1
  /*/
User Function ADFIS037R
  Local aArea		:= GetArea()
	Local aPergs	:= {}
	Local aRet		:= {}
	Local _lPerg	:= .F.
	
	U_ADINF009P('ADFIS037R' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rel Devolucao Compras')
	
	//Adiciona Perguntas / Parâmetros ao relatório
	aAdd( aPergs ,{1,"Data De "     		,Ctod(space(8))	,"" ,'.T.',,'.T.',80,.T.})
	aAdd( aPergs ,{1,"Data Até"     		,Ctod(space(8))	,"" ,'.T.',,'.T.',80,.T.})
	aAdd( aPergs ,{1,"CNPJ Fornecedor"	,space(14)			,"" ,'.T.',,'.T.',80,.T.})
	aAdd( aPergs ,{1,"CFOP"	,space(250)			,"" ,'.T.',,'.T.',80,.T.})

	//Executa as perguntas ao usuário e só executa o relatório caso o usuário confirme a tela de parâmetros;
	If ParamBox(aPergs ,"Parâmetros ",aRet,,,,,,,,.T.,.T.)
		_lPerg	:= .T.
	Else
		Alert("Não foram informados os parâmetros. Operação cancelada!")
		//Return
	Endif

	if _lPerg
		cPathRel	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",1,'C:\TEMP\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
		IF Alltrim(cPathRel) == ""
			cPathRel := "C:\TEMP\"
		ENDIF
		MsgRun( "Carregando dados - Relatório Devolução de Compras, aguarde...",,{ || UFIS037R(aRet[1],aRet[2],aRet[3],aRet[4]) } )
	endif

	RestArea(aArea)

Return 

/*/{Protheus.doc} Static Function UFIS037R
  Relatório de Devolução de Compras
  @type  Static Function
  @author Abel Babini
  @since 13/01/2020
  @version 1
  /*/
Static Function UFIS037R(dDtIni, dDtFim, cCNPJ, cCFOP)
  Local cQuery1, cQuery2
	Local oDlg
	Local oFont001	:= TFont():New( "Arial",,14,,.f.,,,,,.f. )
	Local oFont002	:= TFont():New( "Arial",,16,,.T.,,,,,.f. )
	//Local oFont003	:= TFont():New( "Arial",,18,,.T.,,,,,.f. )
	Local _aFields	:= {}
	Local aCampos		:= {}
	Local _aIndex 	:= {}
	Local oTmpTb01
	Local aSize   	:= MsAdvSize(.f.)
	Local aInfo   	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aObjects	:= aPosObj := {}
	Local _i 				:= 03
	Local aEmp			:= FWLoadSM0( .T. , .T. )
	Local cEmpDest	:= ''
	Local cFilDest	:= ''
	Local cNomDest	:= ''
	Local cCgcOri		:= ''
	Local cNomOri		:= ''	
	Local cCodCli		:= ''
	Local cCodForn	:= ''

	Private oBrw01Dv
	Private cAlTmp01

	U_ADINF009P('ADFIS037R' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rel Devolucao Compras')

	For _i := 1 to Len(aEmp)
		IF Alltrim(cCNPJ) == aEmp[_i,18]
			cEmpDest	:= aEmp[_i,01]
			cFilDest	:= aEmp[_i,02]
			cNomDest	:= aEmp[_i,06] + ' - ' + aEmp[_i,07]
		ENDIF	
		IF cEmpAnt == aEmp[_i,01] .AND. cFilAnt == aEmp[_i,02]
			cCgcOri	:= aEmp[_i,18]
			cNomOri	:= aEmp[_i,06] + ' - ' + aEmp[_i,07]
		ENDIF	
	Next _i

	//
	//Encontra Código e Loja do Fornecedor na Empresa de Destino
	//
	If Select(cQuery1) > 0
		(cQuery1)->(dbCloseArea())
	Endif
	cQuery1:=GetNextAlias()

	cTblSA1 := '%'+'SA1'+cEmpDest+'0'+'%'
	cTblSA2 := '%'+'SA2'+cEmpDest+'0'+'%'
	BeginSQL Alias cQuery1
		SELECT
			'C' 		AS TIPO,
			A1_CGC	AS CGC,
			A1_COD	AS COD,
			A1_LOJA	AS LOJA
		FROM %Exp:cTblSA1% SA1
		WHERE
				A1_CGC = %Exp:cCgcOri%
		AND SA1.%notDel%
		UNION
		SELECT
			'F' 		AS TIPO,
			A2_CGC	AS CGC,
			A2_COD	AS COD,
			A2_LOJA	AS LOJA
		FROM %Exp:cTblSA2% SA2
		WHERE
				A2_CGC = %Exp:cCgcOri%
		AND SA2.%notDel%
	EndSQL

	(cQuery1)->(dbGoTop())
	While !(cQuery1)->(Eof())
		IF (cQuery1)->TIPO == 'F'
			IF Alltrim(cCodForn) = ''
				cCodForn := (cQuery1)->COD
			ELSEIF !ALLTRIM((cQuery1)->COD) $ cCodForn
				cCodForn += ','+(cQuery1)->COD
			ENDIF			
		ELSE
			IF Alltrim(cCodCli) = ''
				cCodCli := (cQuery1)->COD
			ELSEIF !ALLTRIM((cQuery1)->COD) $ cCodCli
				cCodCli += ','+(cQuery1)->COD
			ENDIF
			
		ENDIF
		(cQuery1)->(DbSkip())
	EndDo
	(cQuery1)->(dbCloseArea())

	cINCCli	:= '%'+FormatIn(cCodCli,",")+'%'
	cINCFor	:= '%'+FormatIn(cCodForn,",")+'%'
	cINCFOP	:= '%'+FormatIn(cCFOP,",")+'%'
	//
	//SELECIONA OS REGISTROS NA ORIGEM
	//
	If Select(cQuery1) > 0
		(cQuery1)->(dbCloseArea())
	Endif
	cQuery1:=GetNextAlias()

	BeginSQL Alias cQuery1
		column DTENTRADA as Date
		column DTEMISSAO as Date
		column DTCANC	as Date
		SELECT
			RES.FILIAL, 
			RES.DTENTRADA, 
			RES.DTEMISSAO, 
			RES.SERIE,
			RES.NFISCAL, 
			RES.ITEM,
			RES.CLIEFOR, 
			RES.LOJA,
			RES.NOME,
			RES.CNPJ,
			RES.CODPROD, 
			RES.PRODUTO,
			RES.QUANT,
			RES.PRCUNIT,
			RES.TOTAL,
			RES.VALCONT,
			RES.ICMSBASE,
			RES.ICMSALIQ,
			RES.ICMSVAL,
			RES.ICMSRET,
			RES.ICMSOUTR,
			RES.DESCONT,
			RES.SEGURO,
			RES.DESPESA,
			RES.FRETE,
			RES.CSTPIS,
			RES.VALPIS,
			RES.CSTCOF,
			RES.VALCOF,
			RES.DTCANC,
			RES.OBSERV,
			RES.CONTACONT,
			RES.TES, 
			RES.CFOP, 
			RES.TIPOMOV,
			RES.TIPO,
			RES.NFORI,
			RES.SERORI,
			RES.ITEMORI,
			RES.ESPECIE
		FROM (SELECT
				SFT.FT_FILIAL		AS FILIAL, 
				SFT.FT_ENTRADA	AS DTENTRADA, 
				SFT.FT_EMISSAO	AS DTEMISSAO, 
				SFT.FT_SERIE		AS SERIE,
				SFT.FT_NFISCAL	AS NFISCAL, 
				SFT.FT_ITEM			AS ITEM,
				SFT.FT_CLIEFOR	AS CLIEFOR, 
				SFT.FT_LOJA			AS LOJA,
				CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
				CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_CGC ELSE SA1.A1_CGC END AS CNPJ,
				SFT.FT_PRODUTO	AS CODPROD, 
				SB1.B1_DESC			AS PRODUTO,
				SFT.FT_QUANT		AS QUANT,
				SFT.FT_PRCUNIT	AS PRCUNIT,
				SFT.FT_TOTAL		AS TOTAL,
				SFT.FT_VALCONT	AS VALCONT,
				SFT.FT_BASEICM	AS ICMSBASE,
				SFT.FT_ALIQICM	AS ICMSALIQ,
				SFT.FT_VALICM		AS ICMSVAL,
				SFT.FT_ICMSRET	AS ICMSRET,
				SFT.FT_OUTRICM	AS ICMSOUTR,
				SFT.FT_DESCONT	AS DESCONT,
				SFT.FT_SEGURO		AS SEGURO,
				SFT.FT_DESPESA	AS DESPESA,
				SFT.FT_FRETE		AS FRETE,
				SFT.FT_CSTPIS		AS CSTPIS,
				SFT.FT_VALPIS		AS VALPIS,
				SFT.FT_CSTCOF		AS CSTCOF,
				SFT.FT_VALCOF		AS VALCOF,
				SFT.FT_DTCANC		AS DTCANC,
				SFT.FT_OBSERV		AS OBSERV,
				SFT.FT_CONTA		AS CONTACONT,
				SFT.FT_TES			AS TES, 
				SFT.FT_CFOP			AS CFOP, 
				SFT.FT_TIPOMOV	AS TIPOMOV,
				SFT.FT_TIPO			AS TIPO,
				SFT.FT_NFORI		AS NFORI,
				SFT.FT_SERORI		AS SERORI,
				SFT.FT_ITEMORI	AS ITEMORI,
				SFT.FT_ESPECIE	AS ESPECIE
			FROM %TABLE:SFT% SFT
			LEFT JOIN %TABLE:SB1% SB1 ON
				SB1.B1_COD = SFT.FT_PRODUTO
			AND SB1.%notDel%
			LEFT JOIN %TABLE:SA2% SA2 ON
				SA2.A2_COD = SFT.FT_CLIEFOR
			AND SA2.A2_LOJA = SFT.FT_LOJA
			AND SA2.%notDel%
			AND ( (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) )
			LEFT JOIN %TABLE:SA1% SA1 ON
				SA1.A1_COD = SFT.FT_CLIEFOR
			AND SA1.A1_LOJA = SFT.FT_LOJA
			AND SA1.%notDel%
			AND ( (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B') ) )
			WHERE SFT.FT_FILIAL = %xFilial:SFT%
			AND SFT.FT_ENTRADA BETWEEN %Exp:DToS(dDtIni)% AND %Exp:DToS(dDtFim)%
			AND SFT.FT_DTCANC = ''
			AND SFT.%notDel% ) AS RES
		WHERE
			RES.CNPJ = %Exp:cCNPJ%
		AND RES.CFOP IN %Exp:cINCFOP%
	EndSQL

	//Cria Tabela Temporária
	If Select(cAlTmp01) > 0
		(cAlTmp01)->(dbCloseArea())
	Endif
	cAlTmp01:=GetNextAlias()
	
	aadd(_aFields,{"TIPOLINHA","C",3,0})

	aadd(_aFields,{"EMPRESA","C",2,0})
	aadd(_aFields,{"EMPDEST","C",2,0})

	aSFil 	:= FWTamSX3("FT_FILIAL")
	aadd(_aFields,{"FILIAL",aSFil[3],aSFil[1],aSFil[2]})
	aadd(_aFields,{"FILDEST",aSFil[3],aSFil[1],aSFil[2]})

	aSDtEnt := FWTamSX3("FT_ENTRADA")
	aadd(_aFields,{"DTENTRADA",aSDtEnt[3],aSDtEnt[1],aSDtEnt[2]})
	aadd(_aFields,{"DTENTDEST",aSDtEnt[3],aSDtEnt[1],aSDtEnt[2]})

	aSDtEmi := FWTamSX3("FT_EMISSAO")
	aadd(_aFields,{"DTEMISSAO",aSDtEmi[3],aSDtEmi[1],aSDtEmi[2]})
	aadd(_aFields,{"DTEMIDEST",aSDtEmi[3],aSDtEmi[1],aSDtEmi[2]})

	ASCEspec:= FWTamSX3("FT_ESPECIE")
	aadd(_aFields,{"ESPECIE",ASCEspec[3],ASCEspec[1],ASCEspec[2]})
	aadd(_aFields,{"ESPECIED",ASCEspec[3],ASCEspec[1],ASCEspec[2]})

	aSNFSer := FWTamSX3("FT_SERIE")
	aadd(_aFields,{"SERIE",aSNFSer[3],aSNFSer[1],aSNFSer[2]})
	aadd(_aFields,{"SERIEDEST",aSNFSer[3],aSNFSer[1],aSNFSer[2]})

	aSNF		:= FWTamSX3("FT_NFISCAL")
	aadd(_aFields,{"NFISCAL",aSNF[3],aSNF[1],aSNF[2]})
	aadd(_aFields,{"NFISCALDE",aSNF[3],aSNF[1],aSNF[2]})

	aSNFIte := FWTamSX3("FT_ITEM")
	aadd(_aFields,{"ITEM",aSNFIte[3],aSNFIte[1],aSNFIte[2]})
	aadd(_aFields,{"ITEMDEST",aSNFIte[3],aSNFIte[1],aSNFIte[2]})

	aSCliFo := FWTamSX3("FT_CLIEFOR")
	aadd(_aFields,{"CLIEFOR",aSCliFo[3],aSCliFo[1],aSCliFo[2]})
	aadd(_aFields,{"CLIEFORDE",aSCliFo[3],aSCliFo[1],aSCliFo[2]})

	aSLoja	:= FWTamSX3("FT_LOJA")
	aadd(_aFields,{"LOJA",aSLoja[3],aSLoja[1],aSLoja[2]})
	aadd(_aFields,{"LOJADEST",aSLoja[3],aSLoja[1],aSLoja[2]})

	aSNome	:= FWTamSX3("A1_NOME")
	aadd(_aFields,{"NOME",aSNome[3],aSNome[1],aSNome[2]})
	aadd(_aFields,{"NOMEDEST",aSNome[3],aSNome[1],aSNome[2]})

	aSCNPJ	:= FWTamSX3("A1_CGC")		
	aadd(_aFields,{"CNPJ",aSCNPJ[3],aSCNPJ[1],aSCNPJ[2]})
	aadd(_aFields,{"CNPJDEST",aSCNPJ[3],aSCNPJ[1],aSCNPJ[2]})
	
	aSPrd 	:= FWTamSX3("FT_PRODUTO")
	aadd(_aFields,{"CODPROD",aSPrd[3],aSPrd[1],aSPrd[2]})
	aadd(_aFields,{"CODPRODD",aSPrd[3],aSPrd[1],aSPrd[2]})

	aSDPr		:= FWTamSX3("B1_DESC")
	aadd(_aFields,{"PRODUTO",aSDPr[3],aSDPr[1],aSDPr[2]})
	aadd(_aFields,{"PRODUTOD",aSDPr[3],aSDPr[1],aSDPr[2]})
	
	ASCTpMov:= FWTamSX3("FT_TIPOMOV")
	aadd(_aFields,{"TIPOMOV",ASCTpMov[3],ASCTpMov[1],ASCTpMov[2]})
	aadd(_aFields,{"TIPOMOVD",ASCTpMov[3],ASCTpMov[1],ASCTpMov[2]})

	ASCTipo	:= FWTamSX3("FT_TIPO")
	aadd(_aFields,{"TIPO",ASCTipo[3],ASCTipo[1],ASCTipo[2]})
	aadd(_aFields,{"TIPODEST",ASCTipo[3],ASCTipo[1],ASCTipo[2]})

	aSCfo 	:= FWTamSX3("FT_CFOP")
	aadd(_aFields,{"CFOP",aSCfo[3],aSCfo[1],aSCfo[2]})
	aadd(_aFields,{"CFOPDEST",aSCfo[3],aSCfo[1],aSCfo[2]})

	ASCTES	:= FWTamSX3("FT_TES")
	aadd(_aFields,{"TES",ASCTES[3],ASCTES[1],ASCTES[2]})
	aadd(_aFields,{"TESDEST",ASCTES[3],ASCTES[1],ASCTES[2]})

	aSQtd 	:= FWTamSX3("FT_QUANT")
	aadd(_aFields,{"QUANT",aSQtd[3],aSQtd[1],aSQtd[2]})
	aadd(_aFields,{"QUANTDES",aSQtd[3],aSQtd[1],aSQtd[2]})

	aSPrcUn := FWTamSX3("FT_PRCUNIT")
	aadd(_aFields,{"PRCUNIT",aSPrcUn[3],aSPrcUn[1],aSPrcUn[2]})
	aadd(_aFields,{"PRCUNITD",aSPrcUn[3],aSPrcUn[1],aSPrcUn[2]})

	aSVTt 	:= FWTamSX3("FT_TOTAL")
	aadd(_aFields,{"TOTAL",aSVTt[3],aSVTt[1],aSVTt[2]})
	aadd(_aFields,{"TOTALDES",aSVTt[3],aSVTt[1],aSVTt[2]})

	aSVCt 	:= FWTamSX3("FT_VALCONT")
	aadd(_aFields,{"VALCONT",aSVCt[3],aSVCt[1],aSVCt[2]})
	aadd(_aFields,{"VALCONTD",aSVCt[3],aSVCt[1],aSVCt[2]})

	aSBsICM := FWTamSX3("FT_BASEICM")
	aadd(_aFields,{"ICMSBASE",aSBsICM[3],aSBsICM[1],aSBsICM[2]})
	aadd(_aFields,{"ICMSBASD",aSBsICM[3],aSBsICM[1],aSBsICM[2]})
	
	aSAlqICM:= FWTamSX3("FT_ALIQICM")
	aadd(_aFields,{"ICMSALIQ",aSAlqICM[3],aSAlqICM[1],aSAlqICM[2]})
	aadd(_aFields,{"ICMSALID",aSAlqICM[3],aSAlqICM[1],aSAlqICM[2]})

	aSVlICM := FWTamSX3("FT_VALICM")
	aadd(_aFields,{"ICMSVAL",aSVlICM[3],aSVlICM[1],aSVlICM[2]})
	aadd(_aFields,{"ICMSVALD",aSVlICM[3],aSVlICM[1],aSVlICM[2]})

	aSVIcmRt:= FWTamSX3("FT_ICMSRET")
	aadd(_aFields,{"ICMSRET",aSVIcmRt[3],aSVIcmRt[1],aSVIcmRt[2]})
	aadd(_aFields,{"ICMSRETD",aSVIcmRt[3],aSVIcmRt[1],aSVIcmRt[2]})

	aSVIcmOu:= FWTamSX3("FT_OUTRICM")
	aadd(_aFields,{"ICMSOUTR",aSVIcmOu[3],aSVIcmOu[1],aSVIcmOu[2]})
	aadd(_aFields,{"ICMSOUTD",aSVIcmOu[3],aSVIcmOu[1],aSVIcmOu[2]})

	aSVDesco:= FWTamSX3("FT_DESCONT")
	aadd(_aFields,{"DESCONT",aSVDesco[3],aSVDesco[1],aSVDesco[2]})
	aadd(_aFields,{"DESCONTD",aSVDesco[3],aSVDesco[1],aSVDesco[2]})
	
	aSVSegur:= FWTamSX3("FT_SEGURO")
	aadd(_aFields,{"SEGURO",aSVSegur[3],aSVSegur[1],aSVSegur[2]})
	aadd(_aFields,{"SEGURODE",aSVSegur[3],aSVSegur[1],aSVSegur[2]})
	
	aSVDespe:= FWTamSX3("FT_DESPESA")
	aadd(_aFields,{"DESPESA",aSVDespe[3],aSVDespe[1],aSVDespe[2]})
	aadd(_aFields,{"DESPESAD",aSVDespe[3],aSVDespe[1],aSVDespe[2]})
	
	aSVFrete:= FWTamSX3("FT_FRETE")
	aadd(_aFields,{"FRETE",aSVFrete[3],aSVFrete[1],aSVFrete[2]})
	aadd(_aFields,{"FRETEDES",aSVFrete[3],aSVFrete[1],aSVFrete[2]})
	
	aSCCSTPi:= FWTamSX3("FT_CSTPIS")
	aadd(_aFields,{"CSTPIS",aSCCSTPi[3],aSCCSTPi[1],aSCCSTPi[2]})
	aadd(_aFields,{"CSTPISDE",aSCCSTPi[3],aSCCSTPi[1],aSCCSTPi[2]})

	aSVValPi:= FWTamSX3("FT_VALPIS")
	aadd(_aFields,{"VALPIS",aSVValPi[3],aSVValPi[1],aSVValPi[2]})
	aadd(_aFields,{"VALPISDE",aSVValPi[3],aSVValPi[1],aSVValPi[2]})

	ASCCSTCo:= FWTamSX3("FT_CSTCOF")
	aadd(_aFields,{"CSTCOF",ASCCSTCo[3],ASCCSTCo[1],ASCCSTCo[2]})
	aadd(_aFields,{"CSTCOFDE",ASCCSTCo[3],ASCCSTCo[1],ASCCSTCo[2]})

	ASVValCo:= FWTamSX3("FT_VALCOF")
	aadd(_aFields,{"VALCOF",ASVValCo[3],ASVValCo[1],ASVValCo[2]})
	aadd(_aFields,{"VALCOFDE",ASVValCo[3],ASVValCo[1],ASVValCo[2]})

	ASDDtCan:= FWTamSX3("FT_DTCANC")
	aadd(_aFields,{"DTCANC",ASDDtCan[3],ASDDtCan[1],ASDDtCan[2]})
	aadd(_aFields,{"DTCANCDE",ASDDtCan[3],ASDDtCan[1],ASDDtCan[2]})

	ASCObser:= FWTamSX3("FT_OBSERV")
	aadd(_aFields,{"OBSERV",ASCObser[3],ASCObser[1],ASCObser[2]})
	aadd(_aFields,{"OBSERVDE",ASCObser[3],ASCObser[1],ASCObser[2]})

	ASCConta:= FWTamSX3("FT_CONTA")
	aadd(_aFields,{"CONTACONT",ASCConta[3],ASCConta[1],ASCConta[2]})
	aadd(_aFields,{"CONTACOD",ASCConta[3],ASCConta[1],ASCConta[2]})

	ASCNFSer:= FWTamSX3("FT_SERORI")
	aadd(_aFields,{"SERORI",ASCNFSer[3],ASCNFSer[1],ASCNFSer[2]})
	aadd(_aFields,{"SERORIDE",ASCNFSer[3],ASCNFSer[1],ASCNFSer[2]})

	ASCNFOri:= FWTamSX3("FT_NFORI")
	aadd(_aFields,{"NFORI",ASCNFOri[3],ASCNFOri[1],ASCNFOri[2]})
	aadd(_aFields,{"NFORIDES",ASCNFOri[3],ASCNFOri[1],ASCNFOri[2]})

	ASCNFIte:= FWTamSX3("FT_ITEMORI")
	aadd(_aFields,{"ITEMORI",ASCNFIte[3],ASCNFIte[1],ASCNFIte[2]})
	aadd(_aFields,{"ITEMORID",ASCNFIte[3],ASCNFIte[1],ASCNFIte[2]})

	AADD(_aIndex,{'01',{'FILIAL', 'DTENTRADA', 'SERIE', 'NFISCAL', 'ITEM', 'CLIEFOR', 'LOJA'}})

	oTmpTb01 := FWTemporaryTable():New(cAlTmp01)
	oTmpTb01:SetFields( _aFields )
	For i:=1 to Len(_aIndex)
		oTmpTb01:AddIndex(_aIndex[i,1], _aIndex[i,2] )
	Next i
	oTmpTb01:Create()

	DbSelectArea(cQuery1)
	(cQuery1)->(dbGoTop())
	ProcRegua((cQuery1)->(RecCount()))

	(cQuery1)->(dbGoTop())
	While !(cQuery1)->(Eof())
		IncProc()	

		//Armazena os nomes das tabelas que serão utilizadas na query
		cTbSFT	:= '%'+'SFT'+cEmpDest+'0'+'%'
		cTbSB1	:= '%'+'SB1'+cEmpDest+'0'+'%'
		cTbSA1	:= '%'+'SA1'+cEmpDest+'0'+'%'
		cTbSA2	:= '%'+'SA2'+cEmpDest+'0'+'%'

		//
		//Localiza As NF´s escrituradas no Destino
		//
		If Select(cQuery2) > 0
			(cQuery2)->(dbCloseArea())
		Endif
		cQuery2:=GetNextAlias()

		BeginSQL Alias cQuery2
			column DTENTDEST as Date
			column DTEMIDEST as Date
			column DTCANCDE	as Date
			SELECT
				SFT2.FT_FILIAL		AS FILDEST, 
				SFT2.FT_ENTRADA		AS DTENTDEST, 
				SFT2.FT_EMISSAO		AS DTEMIDEST, 
				SFT2.FT_SERIE			AS SERIEDEST,
				SFT2.FT_NFISCAL		AS NFISCALDE, 
				SFT2.FT_ITEM			AS ITEMDEST,
				SFT2.FT_CLIEFOR		AS CLIEFORDE, 
				SFT2.FT_LOJA			AS LOJADEST,
				CASE WHEN (SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO NOT IN ('D','B') ) OR (SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO IN ('D','B') ) THEN SA22.A2_NOME ELSE SA12.A1_NOME END AS NOMEDEST,
				CASE WHEN (SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO NOT IN ('D','B') ) OR (SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO IN ('D','B') ) THEN SA22.A2_CGC ELSE SA12.A1_CGC END AS CNPJDEST,
				SFT2.FT_PRODUTO		AS CODPRODD, 
				SB12.B1_DESC			AS PRODUTOD,
				SFT2.FT_QUANT			AS QUANTDES,
				SFT2.FT_PRCUNIT		AS PRCUNITD,
				SFT2.FT_TOTAL			AS TOTALDES,
				SFT2.FT_VALCONT		AS VALCONTD,
				SFT2.FT_BASEICM		AS ICMSBASD,
				SFT2.FT_ALIQICM		AS ICMSALID,
				SFT2.FT_VALICM		AS ICMSVALD,
				SFT2.FT_ICMSRET		AS ICMSRETD,
				SFT2.FT_OUTRICM		AS ICMSOUTD,
				SFT2.FT_DESCONT		AS DESCONTD,
				SFT2.FT_SEGURO		AS SEGURODE,
				SFT2.FT_DESPESA		AS DESPESAD,
				SFT2.FT_FRETE			AS FRETEDES,
				SFT2.FT_CSTPIS		AS CSTPISDE,
				SFT2.FT_VALPIS		AS VALPISDE,
				SFT2.FT_CSTCOF		AS CSTCOFDE,
				SFT2.FT_VALCOF		AS VALCOFDE,
				SFT2.FT_DTCANC		AS DTCANCDE,
				SFT2.FT_OBSERV		AS OBSERVDE,
				SFT2.FT_CONTA			AS CONTACOD,
				SFT2.FT_TES				AS TESDEST, 
				SFT2.FT_CFOP			AS CFOPDEST, 
				SFT2.FT_TIPOMOV		AS TIPOMOVD,
				SFT2.FT_TIPO			AS TIPODEST,
				SFT2.FT_NFORI			AS NFORIDES,
				SFT2.FT_SERORI		AS SERORIDE,
				SFT2.FT_ITEMORI		AS ITEMORID,
				SFT2.FT_ESPECIE		AS ESPECIED

			FROM %Exp:cTbSFT% SFT2
			LEFT JOIN %Exp:cTbSB1% SB12 ON
				SB12.B1_COD = SFT2.FT_PRODUTO
			AND SB12.%notDel%
			LEFT JOIN %Exp:cTbSA2% SA22 ON 
				SA22.A2_COD = SFT2.FT_CLIEFOR
			AND SA22.A2_LOJA = SFT2.FT_LOJA
			AND ( (SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO NOT IN ('D','B') ) OR (SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO IN ('D','B') ) )
			AND SA22.%notDel%
			LEFT JOIN %Exp:cTbSA1% SA12 ON 
				SA12.A1_COD = SFT2.FT_CLIEFOR
			AND SA12.A1_LOJA = SFT2.FT_LOJA
			AND ( (SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO NOT IN ('D','B') ) OR (SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO IN ('D','B') ) )
			AND SA12.%notDel%
			WHERE SFT2.FT_FILIAL = %Exp:cFilDest%
 			AND SFT2.FT_NFISCAL = %Exp:(cQuery1)->NFISCAL%
			AND CAST(SFT2.FT_ITEM AS INTEGER) = CAST(%Exp:(cQuery1)->ITEM% AS INTEGER)
			AND (SA22.A2_COD IN %Exp:cINCFor% OR SA12.A1_COD IN %Exp:cINCCli%)
			AND SFT2.%notDel%
		EndSQL
		//AND SFT2.FT_SERIE = %Exp:(cQuery1)->SERIE%
		//AND CAST(SFT2.FT_SERIE AS INTEGER) = CAST(%Exp:(cQuery1)->SERIE% AS INTEGER)


		If Alltrim((cQuery1)->CFOP) $ cCFOP
			//Apenda registros na tabela temporária
			If (Alltrim(cCNPJ) <> '' .AND. Alltrim((cQuery1)->CNPJ) $ Alltrim(cCNPJ)) .OR. Alltrim(cCNPJ) == ''
				RECLOCK(cAlTmp01,.T.)
					(cAlTmp01)->TIPOLINHA	:= 'SEM'
					(cAlTmp01)->EMPRESA		:= cEmpAnt
					(cAlTmp01)->FILIAL		:= (cQuery1)->FILIAL
					(cAlTmp01)->DTENTRADA	:= (cQuery1)->DTENTRADA
					(cAlTmp01)->DTEMISSAO	:= (cQuery1)->DTEMISSAO
					(cAlTmp01)->SERIE			:= (cQuery1)->SERIE
					(cAlTmp01)->NFISCAL		:= (cQuery1)->NFISCAL
					(cAlTmp01)->ITEM			:= (cQuery1)->ITEM
					(cAlTmp01)->CLIEFOR		:= (cQuery1)->CLIEFOR
					(cAlTmp01)->LOJA			:= (cQuery1)->LOJA
					(cAlTmp01)->NOME			:= (cQuery1)->NOME
					(cAlTmp01)->CNPJ			:= (cQuery1)->CNPJ
					(cAlTmp01)->CODPROD		:= (cQuery1)->CODPROD
					(cAlTmp01)->PRODUTO		:= (cQuery1)->PRODUTO
					(cAlTmp01)->QUANT			:= (cQuery1)->QUANT
					(cAlTmp01)->PRCUNIT		:= (cQuery1)->PRCUNIT
					(cAlTmp01)->TOTAL			:= (cQuery1)->TOTAL
					(cAlTmp01)->VALCONT		:= (cQuery1)->VALCONT
					(cAlTmp01)->ICMSBASE	:= (cQuery1)->ICMSBASE
					(cAlTmp01)->ICMSALIQ	:= (cQuery1)->ICMSALIQ
					(cAlTmp01)->ICMSVAL		:= (cQuery1)->ICMSVAL
					(cAlTmp01)->ICMSRET		:= (cQuery1)->ICMSRET
					(cAlTmp01)->ICMSOUTR	:= (cQuery1)->ICMSOUTR
					(cAlTmp01)->DESCONT		:= (cQuery1)->DESCONT
					(cAlTmp01)->SEGURO		:= (cQuery1)->SEGURO
					(cAlTmp01)->DESPESA		:= (cQuery1)->DESPESA
					(cAlTmp01)->FRETE			:= (cQuery1)->FRETE
					(cAlTmp01)->CSTPIS		:= (cQuery1)->CSTPIS
					(cAlTmp01)->VALPIS		:= (cQuery1)->VALPIS
					(cAlTmp01)->CSTCOF		:= (cQuery1)->CSTCOF
					(cAlTmp01)->VALCOF		:= (cQuery1)->VALCOF
					(cAlTmp01)->DTCANC		:= (cQuery1)->DTCANC
					(cAlTmp01)->OBSERV		:= (cQuery1)->OBSERV
					(cAlTmp01)->CONTACONT	:= (cQuery1)->CONTACONT
					(cAlTmp01)->TES				:= (cQuery1)->TES 
					(cAlTmp01)->CFOP			:= (cQuery1)->CFOP 
					(cAlTmp01)->TIPOMOV		:= (cQuery1)->TIPOMOV
					(cAlTmp01)->TIPO			:= (cQuery1)->TIPO
					(cAlTmp01)->NFORI			:= (cQuery1)->NFORI
					(cAlTmp01)->SERORI		:= (cQuery1)->SERORI
					(cAlTmp01)->ITEMORI		:= (cQuery1)->ITEMORI
					(cAlTmp01)->ESPECIE		:= (cQuery1)->ESPECIE

					If Alltrim((cQuery2)->NFISCALDE) != ''
						(cAlTmp01)->TIPOLINHA	:= 'OK '
						(cAlTmp01)->EMPDEST		:= cEmpDest
						(cAlTmp01)->FILDEST		:= cFilDest
						(cAlTmp01)->DTENTDEST	:= (cQuery2)->DTENTDEST
						(cAlTmp01)->DTEMIDEST	:= (cQuery2)->DTEMIDEST
						(cAlTmp01)->SERIEDEST	:= (cQuery2)->SERIEDEST
						(cAlTmp01)->NFISCALDE	:= (cQuery2)->NFISCALDE
						(cAlTmp01)->ITEMDEST	:= (cQuery2)->ITEMDEST
						(cAlTmp01)->CLIEFORDE	:= (cQuery2)->CLIEFORDE
						(cAlTmp01)->LOJADEST	:= (cQuery2)->LOJADEST
						(cAlTmp01)->NOMEDEST	:= (cQuery2)->NOMEDEST
						(cAlTmp01)->CNPJDEST	:= (cQuery2)->CNPJDEST
						(cAlTmp01)->CODPRODD	:= (cQuery2)->CODPRODD
						(cAlTmp01)->PRODUTOD	:= (cQuery2)->PRODUTOD
						(cAlTmp01)->QUANTDES	:= (cQuery2)->QUANTDES
						(cAlTmp01)->PRCUNITD	:= (cQuery2)->PRCUNITD
						(cAlTmp01)->TOTALDES	:= (cQuery2)->TOTALDES
						(cAlTmp01)->VALCONTD	:= (cQuery2)->VALCONTD
						(cAlTmp01)->ICMSBASD	:= (cQuery2)->ICMSBASD
						(cAlTmp01)->ICMSALID	:= (cQuery2)->ICMSALID
						(cAlTmp01)->ICMSVALD	:= (cQuery2)->ICMSVALD
						(cAlTmp01)->ICMSRETD	:= (cQuery2)->ICMSRETD
						(cAlTmp01)->ICMSOUTD	:= (cQuery2)->ICMSOUTD
						(cAlTmp01)->DESCONTD	:= (cQuery2)->DESCONTD
						(cAlTmp01)->SEGURODE	:= (cQuery2)->SEGURODE
						(cAlTmp01)->DESPESAD	:= (cQuery2)->DESPESAD
						(cAlTmp01)->FRETEDES	:= (cQuery2)->FRETEDES
						(cAlTmp01)->CSTPISDE	:= (cQuery2)->CSTPISDE
						(cAlTmp01)->VALPISDE	:= (cQuery2)->VALPISDE
						(cAlTmp01)->CSTCOFDE	:= (cQuery2)->CSTCOFDE
						(cAlTmp01)->VALCOFDE	:= (cQuery2)->VALCOFDE
						IF Alltrim(DtoS((cQuery2)->DTCANCDE)) != ''
							(cAlTmp01)->TIPOLINHA	:= 'CAN'
						ENDIF
						(cAlTmp01)->DTCANCDE	:= (cQuery2)->DTCANCDE
						(cAlTmp01)->OBSERVDE	:= (cQuery2)->OBSERVDE
						(cAlTmp01)->CONTACOD	:= (cQuery2)->CONTACOD
						(cAlTmp01)->TESDEST		:= (cQuery2)->TESDEST
						(cAlTmp01)->CFOPDEST	:= (cQuery2)->CFOPDEST
						(cAlTmp01)->TIPOMOVD	:= (cQuery2)->TIPOMOVD
						(cAlTmp01)->TIPODEST	:= (cQuery2)->TIPODEST
						(cAlTmp01)->NFORIDES	:= (cQuery2)->NFORIDES
						(cAlTmp01)->SERORIDE	:= (cQuery2)->SERORIDE
						(cAlTmp01)->ITEMORID	:= (cQuery2)->ITEMORID
						(cAlTmp01)->ESPECIED	:= (cQuery2)->ESPECIED
					ENDIF

					IF	(cAlTmp01)->TIPOLINHA	== 'OK ' .AND.;
							((cQuery1)->ICMSVAL - (cQuery2)->ICMSVALD) != 0
						(cAlTmp01)->TIPOLINHA	:= 'ICM'
					ELSEIF (cAlTmp01)->TIPOLINHA	== 'OK ' .AND.;
							((cQuery1)->VALPIS - (cQuery2)->VALPISDE) != 0
						(cAlTmp01)->TIPOLINHA	:= 'PIS'
					ELSEIF (cAlTmp01)->TIPOLINHA	== 'OK ' .AND.;
							((cQuery1)->VALCOF - (cQuery2)->VALCOFDE) != 0
						(cAlTmp01)->TIPOLINHA	:= 'COF'
					ENDIF
				MSUNLOCK()	
			Endif
		Endif		
		(cQuery1)->(DbSkip())
	EndDo
	(cQuery1)->(dbCloseArea())

	(cAlTmp01)->(dbGoTop())

	AADD(aObjects,{100,040,.T.,.F.,.F.})
	AADD(aObjects,{100,100,.T.,.T.,.F.})
	aPosObj:=MsObjSize(aInfo,aObjects)

	//TELA
	DEFINE MSDIALOG oDlg TITLE "Relatório Devolução de Compras" OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
	oDlg:lMaximized := .T.

	oFLr01	:= FWLayer():New()
	oFLr01:Init( oDlg, .F., .T.)

	//Define os Paineis
	//TITULO
	oFLr01:AddLine ('TITULO', 16, .F.)
	oFLr01:AddCollumn('TITULO',100,.F.,'TITULO')
	//DETALHE
	oFLr01:AddLine ('DETALHE', 84, .F.)
	oFLr01:AddCollumn('DET_ESQ',100,.F.,'DETALHE')

	oPn01TE	:= oFLr01:GetColPanel('TITULO','TITULO')
	oPn01DE	:= oFLr01:GetColPanel('DET_ESQ','DETALHE')

	oPn01TE:FreeChildren()
	oPn01DE:FreeChildren()



	@ 001,aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] OF oPn01TE PIXEL

	@ 004,008 SAY OemToAnsi("Dt.Inicial")				FONT oFont002 SIZE 040,7 OF oPn01TE PIXEL
	@ 014,008 SAY OemtoAnsi("Dt.Final")					FONT oFont002 SIZE 040,7 OF oPn01TE PIXEL
	@ 024,008 SAY OemToAnsi("Filial Atual")			FONT oFont002 SIZE 040,7 OF oPn01TE PIXEL
	@ 034,008 SAY OemToAnsi("CNPJ Fornecedor")	FONT oFont002 SIZE 040,7 OF oPn01TE PIXEL

	@ 004,050 SAY OemToAnsi(DtoC(dDtIni))				FONT oFont001 SIZE 060,7 OF oPn01TE PIXEL
	@ 014,050 SAY OemtoAnsi(DtoC(dDtFim))				FONT oFont001 SIZE 060,7 OF oPn01TE PIXEL
	@ 024,050 SAY OemToAnsi(SM0->M0_FILIAL)			FONT oFont001 SIZE 060,7 OF oPn01TE PIXEL
	@ 034,050 SAY OemToAnsi(cCNPJ)							FONT oFont001 SIZE 060,7 OF oPn01TE PIXEL

	@ 004,200 SAY OemToAnsi("Legenda")					FONT oFont002 SIZE 040,7 OF oPn01TE PIXEL
	@ 014,210 SAY OemtoAnsi("PRETO    - NF Cancelada")									FONT oFont001 SIZE 150,7 OF oPn01TE PIXEL
	@ 024,210 SAY OemToAnsi("VERMELHO - NF não localizada no destino")	FONT oFont001 SIZE 150,7 OF oPn01TE PIXEL
	@ 034,210 SAY OemToAnsi("AMARELO  - Divergência Valor ICMS")				FONT oFont001 SIZE 150,7 OF oPn01TE PIXEL

	@ 014,350 SAY OemtoAnsi("AZUL     - Divergência Valor Pis/Cofins")	FONT oFont001 SIZE 150,7 OF oPn01TE PIXEL
	@ 024,350 SAY OemToAnsi("BRANCO   - OK")														FONT oFont001 SIZE 150,7 OF oPn01TE PIXEL

	@ 004,540 BUTTON OemToAnsi('Sair')     	 		FONT oFont001 SIZE 42,13 OF oPn01TE PIXEL ACTION oDlg:End() 
	@ 020,540 BUTTON OemToAnsi('Gera Relatório') FONT oFont001 SIZE 42,13 OF oPn01TE PIXEL ACTION xRelExl() 

	//oFolder030:=TFolder():New(aPosObj[2,1],aPosObj[2,2],{"Dev.Compras"},{},oDlg,,,, .T., .F.,aPosObj[2,4]-2,aPosObj[2,3]-40,)
	//oFolder030:aDialogs[1]:oFont :=oDlg:oFont
	oBrw01Dv:= TcBrowse():New(010,050,150,150,,,,oPn01DE,,,,,,,oFont001,,,,,.f.,cAlTmp01,.t.,,.f.,,,,)
	oBrw01Dv:AddColumn( TcColumn():New( "Tipo Linha"			, {|| (cAlTmp01)->TIPOLINHA},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Empresa"			, {|| (cAlTmp01)->EMPRESA},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Filial"			, {|| (cAlTmp01)->FILIAL},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Dt.Entrada"	, {|| (cAlTmp01)->DTENTRADA},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Dt.Emissão"	, {|| (cAlTmp01)->DTEMISSAO},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Especie"			, {|| (cAlTmp01)->ESPECIE},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Série"				, {|| (cAlTmp01)->SERIE},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Nfiscal"			, {|| (cAlTmp01)->NFISCAL},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Item NF"			, {|| (cAlTmp01)->ITEM},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Cod.Forn"		, {|| (cAlTmp01)->CLIEFOR},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Loja"				, {|| (cAlTmp01)->LOJA},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Fornecedor"	, {|| (cAlTmp01)->NOME},"@!",,,"LEFT",50,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "CNPJ"				, {|| (cAlTmp01)->CNPJ},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Cod. Prod."	, {|| (cAlTmp01)->CODPROD},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Produto"			, {|| (cAlTmp01)->PRODUTO},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Tipo Mov."		, {|| (cAlTmp01)->TIPOMOV},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Tipo Doc."		, {|| (cAlTmp01)->TIPO},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "CFOP"				, {|| (cAlTmp01)->CFOP},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "TES"					, {|| (cAlTmp01)->TES},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Quant."			, {|| (cAlTmp01)->QUANT},"@E 999,999,999.9999",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Prc.Unit."		, {|| (cAlTmp01)->PRCUNIT},"@E 999,999,999.9999",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.Total"		, {|| (cAlTmp01)->TOTAL},"@E 999,999,999.9999",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.Contab."	, {|| (cAlTmp01)->VALCONT},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Bs ICMS"			, {|| (cAlTmp01)->ICMSBASE},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Alq ICMS"		, {|| (cAlTmp01)->ICMSALIQ},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.ICMS"			, {|| (cAlTmp01)->ICMSVAL},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "ICMS Ret."		, {|| (cAlTmp01)->ICMSRET},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "ICMS Outras"	, {|| (cAlTmp01)->ICMSOUTR},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Descont."		, {|| (cAlTmp01)->DESCONT},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Seguro"			, {|| (cAlTmp01)->SEGURO},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Despesas"		, {|| (cAlTmp01)->DESPESA},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Frete"				, {|| (cAlTmp01)->FRETE},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "CST Pis"			, {|| (cAlTmp01)->CSTPIS},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.Pis"			, {|| (cAlTmp01)->VALPIS},"@E 999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "CST Cof"			, {|| (cAlTmp01)->CSTCOF},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.Cof"			, {|| (cAlTmp01)->VALCOF},"@E 999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Dt.Canc."		, {|| (cAlTmp01)->DTCANC},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Observ."			, {|| (cAlTmp01)->OBSERV},"@!",,,"LEFT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Conta Contab.", {|| (cAlTmp01)->CONTACONT},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Serie NF Ori", {|| (cAlTmp01)->SERORI},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "NF Ori"			, {|| (cAlTmp01)->NFORI},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Item NF Ori"	, {|| (cAlTmp01)->ITEMORI},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )

	oBrw01Dv:AddColumn( TcColumn():New( "Empresa Dest."			, {|| (cAlTmp01)->EMPDEST},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Filial Dest."			, {|| (cAlTmp01)->FILDEST},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Dt.Entrada Dest."	, {|| (cAlTmp01)->DTENTDEST},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Dt.Emissão Dest."	, {|| (cAlTmp01)->DTEMIDEST},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Especie Dest."			, {|| (cAlTmp01)->ESPECIED},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Série Dest."				, {|| (cAlTmp01)->SERIEDEST},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Nfiscal Dest."			, {|| (cAlTmp01)->NFISCALDE},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Item NF Dest."			, {|| (cAlTmp01)->ITEMDEST},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Cod.Forn Dest."		, {|| (cAlTmp01)->CLIEFORDE},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Loja Dest."				, {|| (cAlTmp01)->LOJADEST},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Fornecedor Dest."	, {|| (cAlTmp01)->NOMEDEST},"@!",,,"LEFT",50,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "CNPJ Dest."				, {|| (cAlTmp01)->CNPJDEST},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Cod. Prod. Dest."	, {|| (cAlTmp01)->CODPRODD},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Produto Dest."			, {|| (cAlTmp01)->PRODUTOD},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Tipo Mov. Dest."		, {|| (cAlTmp01)->TIPOMOVD},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Tipo Doc. Dest."		, {|| (cAlTmp01)->TIPODEST},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "CFOP Dest."				, {|| (cAlTmp01)->CFOPDEST},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "TES Dest."					, {|| (cAlTmp01)->TESDEST},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Quant. Dest."			, {|| (cAlTmp01)->QUANTDES},"@E 999,999,999.9999",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Prc.Unit. Dest."		, {|| (cAlTmp01)->PRCUNITD},"@E 999,999,999.9999",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.Total Dest."		, {|| (cAlTmp01)->TOTALDES},"@E 999,999,999.9999",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.Contab. Dest."	, {|| (cAlTmp01)->VALCONTD},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Bs ICMS Dest."			, {|| (cAlTmp01)->ICMSBASD},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Alq ICMS Dest."		, {|| (cAlTmp01)->ICMSALID},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.ICMS Dest."			, {|| (cAlTmp01)->ICMSVALD},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "ICMS Ret. Dest."		, {|| (cAlTmp01)->ICMSRETD},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "ICMS Outras Dest."	, {|| (cAlTmp01)->ICMSOUTD},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Descont. Dest."		, {|| (cAlTmp01)->DESCONTD},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Seguro Dest."			, {|| (cAlTmp01)->SEGURODE},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Despesas Dest."		, {|| (cAlTmp01)->DESPESAD},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Frete Dest."				, {|| (cAlTmp01)->FRETEDES},"@E 9,999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "CST Pis Dest."			, {|| (cAlTmp01)->CSTPISDE},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.Pis Dest."			, {|| (cAlTmp01)->VALPISDE},"@E 999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "CST Cof Dest."			, {|| (cAlTmp01)->CSTCOFDE},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Vl.Cof Dest."			, {|| (cAlTmp01)->VALCOFDE},"@E 999,999,999.99",,,"RIGHT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Dt.Canc. Dest."		, {|| (cAlTmp01)->DTCANCDE},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Observ. Dest."			, {|| (cAlTmp01)->OBSERVDE},"@!",,,"LEFT",40,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Conta Contab. Dest.", {|| (cAlTmp01)->CONTACOD},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Serie NF Ori Dest.", {|| (cAlTmp01)->SERORIDE},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "NF Ori Dest."			, {|| (cAlTmp01)->NFORIDES},"@!",,,"LEFT",30,.f.,.f.,,,,.f.,) )
	oBrw01Dv:AddColumn( TcColumn():New( "Item NF Ori Dest."	, {|| (cAlTmp01)->ITEMORID},"@!",,,"LEFT",20,.f.,.f.,,,,.f.,) )

	oBrw01Dv:Align		:=	CONTROL_ALIGN_ALLCLIENT
	
	// Muda a cor da linha do browser 
	oBrw01Dv:lUseDefaultColors := .F.
	oBrw01Dv:lAdjustColSize := .T.

	oBrw01Dv:SetBlkBackColor({|| ;
		IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'CAN', CLR_BLACK, ;
		IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'SEM', CLR_RED, ;
		IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'ICM', CLR_YELLOW, ;
		IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'OK', CLR_WHITE, CLR_WHITE ) ) ) ) })
		//IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'PIS', CLR_BLUE, ;
		//IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'COF', CLR_BLUE, ;

	oBrw01Dv:SetBlkColor		({|| ;
		IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'CAN', CLR_WHITE, ;
		IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'SEM', CLR_WHITE, ;
		IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'ICM', CLR_YELLOW,;
		IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'OK', CLR_BLACK, CLR_BLACK ) ) ) ) })
		//IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'PIS', CLR_WHITE, ;
		//IIf(Alltrim((cAlTmp01)->TIPOLINHA) == 'COF', CLR_WHITE, ;

	ACTIVATE MSDIALOG oDlg

	oTmpTb01:Delete()
Return

/*/{Protheus.doc} Static Function fAddCols
	Cria colunas no Browser dinamicamente 
	@author Abel Babini Filho
	@since 13/01/2020
	@version 01
	/*/
Static Function fAddCols( cTitCol , cTitCpo, cMascara, cAlinha, nTamCol)
	oBrw01Dv:AddColumn( TcColumn():New( cTitCol	, {|| cTitCpo}	, cMascara		,,,cAlinha	,nTamCol,.f.,.f.,,,,.f.,) )
Return( NIL )

/*/{Protheus.doc} Static Function xRelExl
	Gera Relatório em Excel
	@author Abel Babini Filho
	@since 20/01/2020
	@version 01
	/*/
Static Function xRelExl()
		Local aSays			:= {}
		Local aButtons		:= {}
		Local nOpca			:= 0
		//+-----------------------------------------------+
		//|Monta Form Batch - Interface com o Usuario     |
		//+-----------------------------------------------+
		AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
		AADD(aSays,"Relatorio Dev. Compras" )
			
		AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelat01()},"Gerando arquivo","Aguarde...")    }})
		AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
		FormBatch( "Relatório Devolução de Compras", aSays, aButtons )
		
		MsgInfo("Arquivo Excel gerado!")        

Return


/*/{Protheus.doc} Static Function xRelat01
	Gera Relatório em Excel
	@author Abel Babini Filho
	@since 20/01/2020
	@version 01
	/*/
Static Function xRelat01()
		Private oExcel		:= FWMSEXCELEX():New()
		Private oMsExcel	:= NIL
		Private cWorksht	:= 'DevCompras'
		Private cPlan01		:= 'Devolução de Compras - Detalhes'
		
		cArquivo := cPathRel +  'DEVCOMPRAS_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
		BEGIN SEQUENCE
			
			IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
				Alert("Nao Existe Excel Instalado")
				BREAK
			EndIF
						
			//Planilha1 - Detalhamento
			ExlCab01()             
			ExlDet01()					
	
			SalvaXml()
			CriaExcel()
		
		END SEQUENCE
	Return

	/*/{Protheus.doc} Static Function SalvaXml  
	Salva Arquivo XML - Excel
	@author Abel Babini Filho
	@since 20/01/2020
	@version 01
	/*/
	Static Function SalvaXml()
	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
Return()

/*/{Protheus.doc} Static Function CriaExcel  
	Cria Arquivo XML - Excel
	@author Abel Babini Filho
	@since 20/01/2020
	@version 01
	/*/
Static Function CriaExcel()
  oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open(cArquivo)
	oMsExcel:SetVisible( .T. )
	oMsExcel:Destroy()
Return() 


/*/{Protheus.doc} Static Function ExlCab01  
	Gera linha de cabeçalho
	@author Abel Babini Filho
	@since 20/01/2020
	@version 01
	/*/
Static Function ExlCab01()

	oExcel:AddworkSheet(cWorksht)
	oExcel:AddTable(cWorksht,cPlan01)
	oExcel:AddColumn(cWorksht,cPlan01,"Empresa"			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Filial"			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Dt.Entrada"	,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Dt.Emissão"	,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Especie"			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Série"				,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Nfiscal"			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Item NF"			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Cod.Forn"		,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Loja"				,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Fornecedor"	,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"CNPJ"				,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Cod. Prod."	,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Produto"			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Tipo Mov."		,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Tipo Doc."		,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"CFOP"				,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"TES"					,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Quant."			,2,2,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Prc.Unit."		,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.Total"		,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.Contab."	,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Bs ICMS"			,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Alq ICMS"		,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.ICMS"			,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"ICMS Ret."		,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"ICMS Outras"	,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Descont."		,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Seguro"			,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Despesas"		,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Frete"				,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"CST Pis"			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.Pis"			,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"CST Cof"			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.Cof"			,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Dt.Canc."		,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Observ."			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Conta Contab.",1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Serie NF Ori",1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"NF Ori"			,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Item NF Ori"	,1,1)

	oExcel:AddColumn(cWorksht,cPlan01,"Empresa Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Filial Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Dt.Entrada Dest."	, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Dt.Emissão Dest."	, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Especie Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Série Dest."				, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Nfiscal Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Item NF Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Cod.Forn Dest."		, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Loja Dest."				, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Fornecedor Dest."	, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"CNPJ Dest."				, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Cod. Prod. Dest."	, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Produto Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Tipo Mov. Dest."		, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Tipo Doc. Dest."		, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"CFOP Dest."				, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"TES Dest."					, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Quant. Dest."			, 2,2,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Prc.Unit. Dest."		, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.Total Dest."		, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.Contab. Dest."	, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Bs ICMS Dest."			, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Alq ICMS Dest."		, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.ICMS Dest."			, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"ICMS Ret. Dest."		, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"ICMS Outras Dest."	, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Descont. Dest."		, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Seguro Dest."			, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Despesas Dest."		, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Frete Dest."				, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"CST Pis Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.Pis Dest."			, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"CST Cof Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.Cof Dest."			, 2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Dt.Canc. Dest."		, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Observ. Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Conta Contab. Dest.", 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Serie NF Ori Dest.", 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"NF Ori Dest."			, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Item NF Ori Dest."	, 1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Status Linha"	, 1,1)

RETURN(NIL)

/*/{Protheus.doc} Static Function ExlDet01
	Gera linhas de detalhe
	@author Abel Babini Filho
	@since 20/01/2020
	@version 01
	/*/
Static Function ExlDet01()
	//
	ProcRegua((cAlTmp01)->(RecCount()))
	(cAlTmp01)->(dbGoTop())
	While !(cAlTmp01)->(Eof())
		IncProc()
		oExcel:AddRow(cWorksht,cPlan01,{(cAlTmp01)->EMPRESA,;
																		(cAlTmp01)->FILIAL,;
																		IIF(Alltrim(DTOS((cAlTmp01)->DTENTRADA))=="","",(cAlTmp01)->DTENTRADA),;
																		IIF(Alltrim(DTOS((cAlTmp01)->DTEMISSAO))=="","",(cAlTmp01)->DTEMISSAO),;
																		(cAlTmp01)->ESPECIE,;
																		(cAlTmp01)->SERIE,;
																		(cAlTmp01)->NFISCAL,;
																		(cAlTmp01)->ITEM,;
																		(cAlTmp01)->CLIEFOR,;
																		(cAlTmp01)->LOJA,;
																		(cAlTmp01)->NOME,;
																		(cAlTmp01)->CNPJ,;
																		(cAlTmp01)->CODPROD,;
																		(cAlTmp01)->PRODUTO,;
																		(cAlTmp01)->TIPOMOV,;
																		(cAlTmp01)->TIPO,;
																		(cAlTmp01)->CFOP,;
																		(cAlTmp01)->TES,;
																		(cAlTmp01)->QUANT,;
																		(cAlTmp01)->PRCUNIT,;
																		(cAlTmp01)->TOTAL,;
																		(cAlTmp01)->VALCONT,;
																		(cAlTmp01)->ICMSBASE,;
																		(cAlTmp01)->ICMSALIQ,;
																		(cAlTmp01)->ICMSVAL,;
																		(cAlTmp01)->ICMSRET,;
																		(cAlTmp01)->ICMSOUTR,;
																		(cAlTmp01)->DESCONT,;
																		(cAlTmp01)->SEGURO,;
																		(cAlTmp01)->DESPESA,;
																		(cAlTmp01)->FRETE,;
																		(cAlTmp01)->CSTPIS,;
																		(cAlTmp01)->VALPIS,;
																		(cAlTmp01)->CSTCOF,;
																		(cAlTmp01)->VALCOF,;
																		IIF(Alltrim(DTOS((cAlTmp01)->DTCANC))=="","",(cAlTmp01)->DTCANC),;
																		(cAlTmp01)->OBSERV,;
																		(cAlTmp01)->CONTACONT,;
																		(cAlTmp01)->SERORI,;
																		(cAlTmp01)->NFORI,;
																		(cAlTmp01)->ITEMORI,;
																		(cAlTmp01)->EMPDEST,;
																		(cAlTmp01)->FILDEST,;
																		(cAlTmp01)->DTENTDEST,;
																		(cAlTmp01)->DTEMIDEST,;
																		(cAlTmp01)->ESPECIED,;
																		(cAlTmp01)->SERIEDEST,;
																		(cAlTmp01)->NFISCALDE,;
																		(cAlTmp01)->ITEMDEST,;
																		(cAlTmp01)->CLIEFORDE,;
																		(cAlTmp01)->LOJADEST,;
																		(cAlTmp01)->NOMEDEST,;
																		(cAlTmp01)->CNPJDEST,;
																		(cAlTmp01)->CODPRODD,;
																		(cAlTmp01)->PRODUTOD,;
																		(cAlTmp01)->TIPOMOVD,;
																		(cAlTmp01)->TIPODEST,;
																		(cAlTmp01)->CFOPDEST,;
																		(cAlTmp01)->TESDEST,;
																		(cAlTmp01)->QUANTDES,;
																		(cAlTmp01)->PRCUNITD,;
																		(cAlTmp01)->TOTALDES,;
																		(cAlTmp01)->VALCONTD,;
																		(cAlTmp01)->ICMSBASD,;
																		(cAlTmp01)->ICMSALID,;
																		(cAlTmp01)->ICMSVALD,;
																		(cAlTmp01)->ICMSRETD,;
																		(cAlTmp01)->ICMSOUTD,;
																		(cAlTmp01)->DESCONTD,;
																		(cAlTmp01)->SEGURODE,;
																		(cAlTmp01)->DESPESAD,;
																		(cAlTmp01)->FRETEDES,;
																		(cAlTmp01)->CSTPISDE,;
																		(cAlTmp01)->VALPISDE,;
																		(cAlTmp01)->CSTCOFDE,;
																		(cAlTmp01)->VALCOFDE,;
																		IIF(Alltrim(DTOS((cAlTmp01)->DTCANCDE))=="","",(cAlTmp01)->DTCANCDE),;
																		(cAlTmp01)->OBSERVDE,;
																		(cAlTmp01)->CONTACOD,;
																		(cAlTmp01)->SERORIDE,;
																		(cAlTmp01)->NFORIDES,;
																		(cAlTmp01)->ITEMORID,;
																		(cAlTmp01)->TIPOLINHA})

		(cAlTmp01)->(dbSkip())
	ENDDO
	(cAlTmp01)->(dbGoTop())
	oExcel:AddRow(cWorksht,cPlan01,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return




