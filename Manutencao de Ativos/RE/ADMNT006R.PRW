#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"


/*/{Protheus.doc} User Function ADMNT006R
	(Exporta para .CSV dados as tabelas SCP e SD3 relativas as requisicoes ao almoxarifado)
	@type  Function
	@author Mauricio - MDS TEC
	@since 03/05/2016
	@version version
	@history Solicitado por Sonia - Chamado 028067
	@history 15/06/2020 - ADRIANO SAVOINE - 058564 - Criado uma nova coluna para trazer o Status e tratado a mesma quando for M.
	@history 25/06/2020 - ADRIANO SAVOINE - 059151 - Incluido no Relatorio o Cod. Projeto e Descrição do Projeto.
	/*/



User Function ADMNT006R()  

	Private _cPerg   := "ADMNT006"
	Private _cArqTmp
	Private cObserv  := '' //19/07/2018 - WILLIAM COSTA - 042596 || RECURSOS || DANIELE || 8504 || REL. SOLICITACOES
	Private cNrBem   := '' //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO   
	Private cNomeBem := '' //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO   

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Exporta para .CSV dados as tabelas SCP e SD3 relativas as requisicoes ao almoxarifado')
	
	PutSx1(_cPerg,"01","Arquivo de saida(.CSV) ?"    , "Arquivo de saida(.CSV) ?"    , "Arquivo de saida(.CSV) ?"    , "mv_ch1","C",60,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","")
	PutSX1(_cPerg,"02","Emissao De "          ,"Emissao De "      ,"Emissao De "      ,"mv_ch2","D",08,0,0,"G",""         ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")
	PutSX1(_cPerg,"03","Emissao Ate "         ,"Emissao Ate "     ,"Emissao Ate "     ,"mv_ch3","D",08,0,0,"G",""         ,"","","","mv_par03" ,"","","","","","","","","","","","","","",""," ")
	PutSX1(_cPerg,"04","Do C.Custo    "  ,"Do C.Custo    "  ,"Do C.Custo    "  ,"mv_ch4","C",09,0,0,"G","","CTT","","","mv_par04" ,"","","","","","","","","","","","","","",""," ")
	PutSX1(_cPerg,"05","Ate o C.Custo "  ,"Ate o C.Custo "  ,"Ate o C.Custo "  ,"mv_ch5","C",09,0,0,"G","","CTT","","","mv_par05" ,"","","","","","","","","","","","","","",""," ")
	
	pergunte(_cPerg,.T.)
	
	dbSelectArea("SCP")
	dbSetOrder(1)
	
	@ 200,1 TO 380,380 DIALOG oTxtTela TITLE OemToAnsi("Geracao arquivo de Requisicoes(SCP)")
	@ 02,10 TO 080,190
	@ 10,018 Say " Este programa ira gerar um arquivo,  a apartir dos "
	@ 18,018 Say " dados da tabela SCP(requisicao) e SD3(Valor movimento) "
	@ 26,018 Say " conforme parametros informados. " 
	
	@ 70,128 BMPBUTTON TYPE 01 ACTION GeraTxt()
	@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oTxtTela)
	
	Activate Dialog oTxtTela Centered

Return

Static Function GeraTxt

	if file(ALLTRIM(MV_PAR01))
		ALERT("ARQUIVO "+ALLTRIM(MV_PAR01)+" JA EXISTE, E SERA APAGADO.")
		FErase(ALLTRIM(MV_PAR01))
	endif
	
	private nHdl    := fCreate(ALLTRIM(MV_PAR01))
	
	Private cEOL    := "CHR(13)+CHR(10)"
	If Empty(cEOL)
	    cEOL := CHR(13)+CHR(10)
	Else
	    cEOL := Trim(cEOL)
	    cEOL := &cEOL
	Endif
	
	If nHdl == -1
	    MsgAlert("O arquivo de nome "+mv_par01+" nao pode ser executado! Verifique os parametros.","Atencao!")
	    Return
	Endif
	
	Processa({|| RunCont() },"Processando...") 

Return

Static Function RunCont

	Local nTamLin, cLin, cCpo
	
	If Select ("TRB01") > 0
	  	DbSelectArea("TRB01")
		TRB01->(DbCloseArea())
	Endif
	
	/*
	_cQuery := ""
	_cQuery += "SELECT * FROM "+RetSQLName("SCP")+" AS SCP, "+RETSQLNAME("SD3")+" AS SD3 "
	_cQuery += "WHERE SCP.CP_CC >= '"+MV_PAR04+"' AND SCP.CP_CC <= '"+MV_PAR05+"' AND "
	_cQuery += "SCP.CP_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' AND "
	_cQuery += "SUBSTRING(SD3.D3_DOC,1,6) = SCP.CP_NUM AND SD3.D3_COD = SCP.CP_PRODUTO AND "
	_cQuery += "SCP.CP_CC = SD3.D3_CC AND SD3.D3_CF = 'RE0' AND SCP.CP_LOCAL = SD3.D3_LOCAL AND "
	_cQuery += "SD3.D3_ESTORNO = ' ' AND "
	_cQuery += "SCP.D_E_L_E_T_ = '' AND SD3.D_E_L_E_T_ = '' ORDER BY SCP.CP_NUM,SCP.CP_ITEM "
	*/
	
	_cQuery := ""
	_cQuery += "SELECT * FROM "+RetSQLName("SD3")+" AS SD3 "
	_cQuery += "WHERE SD3.D3_CC >= '"+MV_PAR04+"' AND SD3.D3_CC <= '"+MV_PAR05+"' AND "
	_cQuery += "SD3.D3_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' AND "
	_cQuery += "SD3.D3_ESTORNO = ' ' AND SUBSTRING(SD3.D3_CF,2,1) = 'E' AND SD3.D3_OP = '' AND "
	_cQuery += "SD3.D_E_L_E_T_ = '' AND SD3.D3_FILIAL = '"+xFilial("SD3")+"' ORDER BY SD3.D3_GRUPO, SD3.D3_COD "
	
	TcQuery _cQuery NEW ALIAS "TRB01"     
	
	ProcRegua(RecCount()) 
	DbSelectArea("TRB01")
	DbGotop()
	
	&&Gravo 1 linha de cabecalho para o arquivo
	cLin := ""
	cLin += "Requisicao;"
	cLin += "Produto;"
	cLin += "Descricao;"
	cLin += "Unid.Medida;"                        
	cLin += "Local;"
	cLin += "Grupo;"
	cLin += "Centro Custo;"
	cLin += "Emissao;"
	cLin += "Entrega;"
	cLin += "Quantidade;"
	cLin += "Valor Total;"
	cLin += "Solicitante;" 
	cLin += "Observacao;"
	cLin += "Nr do Bem;"
	cLin += "Nome do Bem;"
	cLin += "Tipo Solicitacao;" // 15/06/2020 - ADRIANO SAVOINE - 058564 - Criado uma nova coluna para trazer o Status e tratado a mesma quando for M
	cLin += "Cod. Projeto;" //25/06/2020 - ADRIANO SAVOINE - 059151 - Incluido no Relatorio o Cod. Projeto.
	cLin += "Desc. Projeto" //25/06/2020 - ADRIANO SAVOINE - 059151 - Incluido no Relatorio o Desc. Projeto.
	cLin += cEOL
	
	fWrite(nHdl,cLin,Len(cLin))                          
	       
	While TRB01->(!EOF())
	
	       IncProc("Processando...")
	        
	       _cReq    := Alltrim(TRB01->D3_DOC)   //SUBSTRING(TRB01->D3_DOC,1,6)
	       _cCod    := TRB01->D3_COD
	       _cUM     := TRB01->D3_UM
	       _cLoc    := TRB01->D3_LOCAL
	       _cGrp    := TRB01->D3_GRUPO
	       _cCC     := TRB01->D3_CC
	       _dEmi    := TRB01->D3_EMISSAO
	       _dEnt    := TRB01->D3_EMISSAO
	       _nQTD    := TRB01->D3_QUANT       
	       _nVal    := TRB01->D3_CUSTO1                 
	       _cDesc   := Space(30)
	       _cSol    := Space(25)
	       cObserv  := '' //19/07/2018 - WILLIAM COSTA - 042596 || RECURSOS || DANIELE || 8504 || REL. SOLICITACOES
	       cNrBem   := '' //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO   
	       cNomeBem := '' //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO
		   cTipoSol := ''
		   cCodProj := TRB01->D3_PROJETO //25/06/2020 - ADRIANO SAVOINE - 059151 - Incluido no Relatorio o Cod. Projeto.
		   cDesProj := Posicione("AF8",1,xFilial("AF8")+TRB01->D3_PROJETO,"AF8_DESCRI")  //25/06/2020 - ADRIANO SAVOINE - 059151 - Incluido no Relatorio o Desc. Projeto.
		   _cReq    := STRTRAN(_cReq,'/','') //15/06/2020 - ADRIANO SAVOINE - 058564 - Criado uma nova coluna para trazer o Status e tratado a mesma quando for M
	       
	       DbSelectArea("SCP")
	       DbSetOrder(2)
	       IF dbseek(xFilial("SCP")+_cCod+_cReq)
	              
                IncProc("Processando...")
                _cDesc   := SCP->CP_DESCRI
                _cSol    := SCP->CP_SOLICIT
                cObserv  := SCP->CP_OBS     //19/07/2018 - WILLIAM COSTA - 042596 || RECURSOS || DANIELE || 8504 || REL. SOLICITACOES
                cNrBem   := SCP->CP_XCODBEM //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO   
                cNomeBem := Posicione("ST9",1,xFilial("ST9")+SCP->CP_XCODBEM,"T9_NOME") //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO
				cTipoSol := SCP->CP_XTIPO //15/06/2020 - ADRIANO SAVOINE - 058564 - Criado uma nova coluna para trazer o Status e tratado a mesma quando for M
	       Else
	       
	           _cDesc   := Posicione("SB1",1,xFilial("SB1")+TRB01->D3_COD,"B1_DESC")
	           _cSol    := TRB01->D3_USUARIO
	           cObserv  := '' //19/07/2018 - WILLIAM COSTA - 042596 || RECURSOS || DANIELE || 8504 || REL. SOLICITACOES
	           cNrBem   := '' //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO   
               cNomeBem := '' //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO
	                            
	       Endif
	              
	       cLin := ""
	       cLin += _cReq+";"       
	       cLin += _cCod+";"
	       cLin += _cDesc+";"
	       cLin += _cUM+";"
	       cLin += _cLoc+";"
	       cLin += _cGrp+";"
	       cLin += _cCC+";"
	       cLin += DTOC(STOD(_dEmi))+";"
	       cLin += DTOC(STOD(_dEnt))+";"
	       cLin += Transform(_nQtd,"@E 999,999,999.99")+";"       
	       cLin += Transform(_nVal,"@E 999,999,999.99")+";"       
	       cLin += _cSol+";" 
	       cLin += cObserv+";"  //19/07/2018 - WILLIAM COSTA - 042596 || RECURSOS || DANIELE || 8504 || REL. SOLICITACOES
	       cLin += cNrBem+";"   //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO   
           cLin += cNomeBem+";" //26/08/2019 - WILLIAM COSTA - 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO
		   cLin += cTipoSol+";" //15/06/2020 - ADRIANO SAVOINE - 058564 - Criado uma nova coluna para trazer o Status e tratado a mesma quando for M
	       cLin += cCodProj+";" //25/06/2020 - ADRIANO SAVOINE - 059151 - Incluido no Relatorio o Cod. Projeto.
		   cLin += cDesProj+";"	//25/06/2020 - ADRIANO SAVOINE - 059151 - Incluido no Relatorio o Desc. Projeto.
		   cLin += cEOL 
	                                         
	       If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		       If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		       		Exit
		       Endif
	       Endif
	       
	       TRB01->(dbSkip())       
	Enddo         
	
	TRB01->(dbCloseArea())
	fClose(nHdl)
	Close(oTxtTela) 

Return() 