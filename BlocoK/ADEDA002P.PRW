
#Include "RwMake.ch"             
#Include "Protheus.ch"
#Include "Topconn.ch" 
#INCLUDE "MntTRCell.ch"

/*/{Protheus.doc} User Function ADEDA002P
	Funções de integração com o EData
	@type  Function
	@author Microsiga
	@since 19/07/2013
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s
	@history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
	@history ticket 13858 - Fernando Macieira - 10/05/2021 - APONTAMENTO DE PRODUÇÃO ABRIL - FILIAL 02
    @history ticket 11639 - Fernando Macieira - 27/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
	@history ticket 64739 - Fernando Macieira - 10/12/2021 - Ativação Begin Transaction por OP - ADEDA003P
	@history ticket 65585 - Fernando Macieira - 01/02/2022 - Processamento OP - Edata p/ Protheus - Item Salsicha 193229
/*/
User Function ADEDA002P(cEmp,cFil,cJobFile)

	Local   aTables		:={"SB1","SC2","SD3","SB2","SD4","SF5","ZA1","SD1","SD2","SD5","TD9","QP6"}

	Private cPara       := ""
	Private cCopia      := ""
	Private cCpOcul     := ""
	Private cAssunto    := ""
	Private cDe         := ""
	
	Default cEmp		:= "01"
	Default cFil		:= "02"
	Default cJobFile	:= "ADEDA002P"

	//Apaga arquivo ja existente
	If File(cJobFile)
		fErase(cJobFile)
	EndIf

	// Criacao do arquivo de controle de jobs
	nHd1 := MSFCreate(cJobFile)

	// STATUS 1 - Iniciando execucao do Job
	PutGlbValue("ADEDA002P", "1" )
	GlbUnLock()

	// Seta job para nao consumir licensas
	RpcSetType(3)

	// Seta job para empresa filial desejada
	RpcSetEnv( cEmp, cFil,,,"PCP","MATA650",aTables, , , ,   )

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funções de integração com o Edata')

	cPara      := SuperGetMV("MV_XMPARA" ,,"")
	cCopia     := SuperGetMV("MV_XMCOPIA",,"")
	cCpOcul    := SuperGetMV("MV_XMCPOCU",,"")
	cAssunto   := SuperGetMV("MV_XMASSUN",,"Integracao Protheus X SAG")
	cDe        := SuperGetMV("MV_XMAILDE",,"")

	// STATUS 2 - Conexao efetuada com sucesso
	PutGlbValue("ADEDA002P", "2" )
	GlbUnLock()

	ConOut(dtoc(Date())+" "+Time()+"Inicio Job Integrações Producao "+cJobFile)

	cEmail		:= GetMV("MV_XEMAIL",.F.,"sistemas@adoro.com.br")
	cExt		:= GetMv("MV_XEXT",.F.,"*.CSV")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PROCESSAMENTO DA INTERFACE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	U_ADEDA003P() // PRODUCAO (INCLUSÃO OP/APONTAMENTO DE PRODUÇÃO / EXCLUSÃO APONTAMENTO DE PRODUÇÃO/OP)

	U_ADEDA004P() // INTERNOS INCLUSÃO

	U_ADEDA005P() // INTERNOS EXCLUSÃO

	U_ADEDA006P() // INVENTARIO INCLUSÃO

	ConOut(dtoc(Date())+" "+Time()+"Final do Job Integrações Producao "+cJobFile)
									
	PutGlbValue("ADEDA002P","3")
	GlbUnLock()

Return()

/*/{Protheus.doc} User Function nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 03/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function ADEDA003P(nRec, lExclui)

	Local _aArea       		:= GetArea()
	Local _aAreaOPR
	Local _lExporta	   		:= .F.
	Local _lRet    	   		:= .T.
	Local lHtml    		 	:= .T.
	Local cAnexo   		    := ""
	Local cMsgError 	    := ""
	Local aErroLog			:= ""
	Local cFilBack			:= cFilAnt
	Local cOP				:= ""
	Local cOPProduto		:= ""
	//Local cErro				:= ""
	Local cData				:= ""

	Private _dData			:= DDATABASE
	Private cAliasOP		:= GetNextAlias()
	Private cAliasOPR
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.
    Private cLoc3           := "" // @history ticket 11639 - Fernando Macieira - 27/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
    Private cPrd3           := "" // @history ticket 11639 - Fernando Macieira - 27/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
	Private cErro           := ""

	Default nRec 		:= 0
	Default lExclui		:= .F.
	Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADEDA007R como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADEDA007R*/

    cFilBkp := cFilAnt
    
    lMsErroAuto := .F.
    _lJob       := .F.
    
    cQry := " SELECT * FROM OPR010 (NOLOCK) WHERE D_E_L_E_T_=' ' AND "
    If lExclui
        cQry += " MSEXP <> ' ' "
    Else		
        cQry +=	" (MSEXP='' OR ( MSEXP<> '' AND  STATUS ='E' )) "
    EndIf
    If nRec > 0
        cQry +=	" AND REC = '" + ALLTRIM(StrZero(nRec,10)) + "' "
    EndIf
    cQry += " AND QUANT > 0 
    cQry += " ORDER BY FILIAL,DATA,PRODUTO "
    
    cAliasOPR	:= GetNextAlias()
    DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasOPR, .F., .T.)
    TcSetField( cAliasOPR, "EMISSAO", "D", 8, 0 )

    nQuantOP := 0
    cC2_Num  := ""
    cOperacao := ""
    
    If (cAliasOPR)->(Eof())
        _lRet:= .F.
    EndIf
    
    (cAliasOPR)->(dbGotop())
    While !(cAliasOPR)->(Eof())
        
        nRecXOpr := (cAliasOPR)->REC
        cData	 := (cAliasOPR)->DATA
        nQtdeTot := (cAliasOPR)->QUANT    
		cLoc3    := (cAliasOPR)->LOCAL // @history ticket 11639 - Fernando Macieira - 27/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
		cPrd3    := (cAliasOPR)->PRODUCAO // @history ticket 11639 - Fernando Macieira - 27/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento

        If nQtdeTot <= 0 
            dbSkip()
            Loop
        EndIf
        
        If (cAliasOPR)->OPERACAO == "E" .OR. lExclui
            
            If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

                Begin Transaction // @history ticket 64739 - Fernando Macieira - 10/12/2021 - Ativação Begin Transaction por OP - ADEDA003P
                
                    nRecOPR := (cAliasOPR)->REC
                
                    If ( _lRet := ADEDA002PD(cAliasOPR, @cOp) ) //ESTORNA APONTAMENTOS DE PRODUÇÃO (SD3) MATA250
                        
                        If ( _lRet := ADEDA002G(nRecOPR, nQtdeTot, cOp, 5, cData) ) //ESTORNA MOVIMENTAÇÃO (SD3) MATA240
                    
                            If ( _lRet := ADEDA002PE(cAliasOPR, nQtdeTot, 5, cOp) ) //ESTORNA PRODUÇÃO (SC2) MATA650
                                
                                DDATABASE := _dData
                                U_CCSGrvLog("ok", "OPR", 0, 3, (cAliasOPR)->FILIAL, .T.)
                                TcSqlExec("UPDATE OPR010 SET D_E_L_E_T_='*' WHERE REC=" + AllTrim(Str(nRecOPR)) + " AND D_E_L_E_T_=' ' " )

                            Else

                                _MsgMotivo += "(Problema no estorno da Ordem de Produção) " + CHR(13) + CHR(10)
                                DisarmTransaction() 
                                Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

                            EndIf

                        Else

                            _MsgMotivo += "(Problema no estorno da Movimentação Interna) " + CHR(13) + CHR(10)
                            DisarmTransaction() 
                            Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

                        EndIf

                    Else

                        _MsgMotivo += "(Problema no estorno do Apontamento de Produção) " + CHR(13) + CHR(10)
                        DisarmTransaction() 
                        Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

                    EndIf
                
                End Transaction

                MsUnLockAll() 									// @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s

            EndIf
            
        ElseIf (cAliasOPR)->OPERACAO == "I"
            
            If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

				PutSBFSB2()
                
				Begin Transaction //@history ticket 64739 - Fernando Macieira - 10/12/2021 - Ativação Begin Transaction por OP - ADEDA003P
                
                    nRecOPR 	:= (cAliasOPR)->REC
                    cOPProduto	:= (cAliasOPR)->PRODUTO
                    
				 	//GERA A OP (SC2) MATA650
                    If ( _lRet := ADEDA002PB(cAliasOPR, nQtdeTot, nRecOPR, @cOp) )
                        
                        /* Função usada para verificar se controla saldo e se existe saldo */
                        If _lRet := ADEDA002PG(cOPProduto, nQtdeTot)

							//CRIA A MOVIMENTAÇÃO (SD3) MATA240 // MOVIMENTO ESPECÍFICO DO FRANGO VIVO 300042
                            If ( _lRet := ADEDA002G(nRecOPR, nQtdeTot, cOp, 3, cData) )
                
								// CRIA O APONTAMENTO DA PRODUÇÃO (SD3) MATA250
                                If !( _lRet := ADEDA002PC(@cErro,nRecOPR,cOp) ) 
                                    
									ADEDA002PF(nRecOPR) //ESTORNA A MOVIMENTAÇÃO
                                    ADEDA002PE(cAliasOPR,nQtdeTot,5,cOp) //ESTORNA A PRODUCAO
                                    
                                    TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRecOPR))+" AND OPERACAO='I' ")

                                    DDATABASE := _dData
                                    U_CCSGrvLog(cErro, "OPR", 0, 3, (cAliasOPR)->FILIAL, .T.)
                                    _MsgMotivo += "(Problema na geração do Apontamento de Produção) " + CHR(13) + CHR(10)

                                    DisarmTransaction() 
                                    Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

                                EndIf
                    
                            Else
                            
                                _MsgMotivo += "(Problema na geração da Movimentação Interna) " + CHR(13) + CHR(10)
                                ADEDA002PE(cAliasOPR,nQtdeTot,5,cOp) //ESTORNA A PRODUCAO
                                DDATABASE := _dData
                                cErro := "Não foi possível criar uma requisição da ordem de produção criada" 
                                U_CCSGrvLog(cErro, "OPR", 0, 3, (cAliasOPR)->FILIAL, .T.)
                                TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRecOPR))+" AND OPERACAO='I' ")
                                DisarmTransaction() 
                                Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

                            EndIf

                        Else

                            ADEDA002PE(cAliasOPR, nQtdeTot, 5, cOp) //ESTORNA A PRODUCAO
                            DDATABASE := _dData
                            cErro := "Não foi possível gerar a movimentação da OP, porque algum componente não possui saldo." 
                            U_CCSGrvLog(cErro, "OPR", nRecOPR, 3, cFilAnt, .T.)
                            TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='" + cErro + "' WHERE REC="+AllTrim(Str(nRecOPR))+" ")
                            DisarmTransaction() 
                            Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

                        EndIf					
                    
                    Else

                        _MsgMotivo += "(Problema na geração da Ordem de Produção) " + CHR(13) + CHR(10)
                        DisarmTransaction() 
                        Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

                    EndIf
                
                End Transaction

                MsUnLockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

            EndIf

            MsUnLockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
                
        EndIf
        
        go nRecXOpr
        (cAliasOPR)->(DbSkip())
        
    EndDo

    (cAliasOPR)->(DbCloseArea())
    cFilAnt := cFilBkp
    DDATABASE := _dData
    RestArea(_aArea)        
    MsUnLockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

Return _lRet

/*/{Protheus.doc} nomeStaticFunction
	GERA OP (SC2) MATA650
	@type  Static Function
	@author user
	@since 03/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA002PB(cAliasOPR,nQtdeTot,nRecOPR,cOp)

	Local cOP		:= ""
	Local _dData	:= DDATABASE
	Local cNum		:= GetNumSC2()
	Local cItem   	:= "01"
	Local cSequen 	:= StrZero(1, Len(SC2->C2_SEQUEN))
	Local lRet		:= .F.
	Local cError  	:= ""
	Local k
	
	Local cRevisao   := "" 
	Local _cCCustoC2 := GetMV("MV_#CCPROP",,"5131") 

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

    cFilBkp 	:= cFilAnt
    cCod		:= (cAliasOPR)->PRODUTO
    DDATABASE	:= STOD((cAliasOPR)->DATA)
    cFilAnt		:= (cAliasOPR)->FILIAL
    nRecB1		:= (cAliasOPR)->REC
    
    dbSelectArea("SB1")
    dbSetOrder(1)  // B1_FILIAL+B1_COD
    dbSeek(xFilial("SB1") + cCod)
    If Eof()

        cErro := "OPR - Produto nao cadastrado no Protheus "+cCod
        TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRecB1))+" AND OPERACAO='I' ")

        DisarmTransaction() 
        //Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

        Return lRet

    EndIf
    
    cFilAnt	:= (cAliasOPR)->FILIAL
    
    If STOD((cAliasOPR)->DATA) < dDataBase
        dData := dDataBase
    Else
        dData := STOD((cAliasOPR)->DATA)
    EndIf
    
    cChaveOP := cNum + cItem + cSequen
    cOP		 := cChaveOP
    nQuantOP := nQtdeTot

	// @history ticket 11639 - Fernando Macieira - 27/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
	If Upper(AllTrim(cPrd3)) == "T" // Produção de terceiro

		If AllTrim(cCod) $ GetMV("MV_#3SALSI",,"193229#")
			_cCCustoC2 := GetMV("MV_#3CCSAL",,"5901")
		ElseIf AllTrim(cCod) $ GetMV("MV_#3LINGU",,"142477#195562")
			_cCCustoC2 := GetMV("MV_#3CCLIN",,"5903")
		ElseIf AllTrim(cCod) $ GetMV("MV_#3GALO",,"113069#113071#113081#113093#142476#147679#148257#149104#149105#149106")
			_cCCustoC2 := GetMV("MV_#3CCGAL",,"5906")
		EndIf

		If At("-", cLoc3) > 0
			cRevisao := Right(AllTrim(cLoc3),3)
		EndIf

	EndIf
	//
    
    // CENTRO DE CUSTO ESTÁ FIXO MAIS PRECISARÁ SER REVISTO
    //{"C2_NUM"          , cNum					            , .f.},;
    aAuto := {  {"C2_FILIAL"       , cFilAnt			 	            , Nil},;
                {"C2_NUM"          , cNum					            , Nil},;
                {"C2_ITEM"         , cItem				                , Nil},;
                {"C2_SEQUEN"       , cSequen							, Nil},;
                {"C2_PRODUTO"      , (cAliasOPR)->PRODUTO		        , Nil},;
                {"C2_LOCAL"        , RetFldProd(SB1->B1_COD,"B1_LOCPAD"), Nil},;
                {"C2_CC"           , _cCCustoC2 /*'5131'*/		        , Nil},;
                {"C2_QUANT"        , nQtdeTot			                , Nil},;
                {"C2_UM"           , SB1->B1_UM                         , Nil},;
                {"C2_DATPRI"       , STOD((cAliasOPR)->DATA)            , Nil},;
                {"C2_DATPRF"       , dData				                , Nil},;
                {"C2_EMISSAO"      , DDATABASE		                    , Nil},;
                {"C2_TPOP"         , "F"                                , Nil},;
                {"C2_RECORI"       , StrZero((cAliasOPR)->REC,10)       , Nil},;
                {"C2_REVISAO"      , cRevisao                           , Nil},; // @history ticket 11639 - Fernando Macieira - 31/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
				{"AUTEXPLODE"      , "S"                                , Nil}}
    
    cFilOPR	  := (cAliasOPR)->FILIAL
    _aAreaOPR := (cAliasOPR)->(GetArea())
    
    cError += " PRODUTO = " + ALLTRIM((cAliasOPR)->PRODUTO) + "; OP = " + ALLTRIM(cNum+cItem+cSequen) + "; EMISSAO = " + ALLTRIM( DTOC(DDATABASE)) + "; RECORI = " + ALLTRIM( StrZero( (cAliasOPR)->REC,10) ) + "; "
    
    SB1->(dbSetOrder(1))  // B1_FILIAL+B1_COD
    SB1->(dbSeek(xFilial("SB1") + cCod))
    
    CTT->(dbSetOrder(1))  // B1_FILIAL+B1_COD
    CTT->(dbSeek(xFilial("CTT") + _cCCustoC2)) // @history ticket 11639 - Fernando Macieira - 28/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
    
    lMsErroAuto := .F.
    
    // verifica se a OP ja existe, se existir altera a quantidade da OP e dos Empenhos somando a nota quantidade da batida
    dbSelectArea("SC2")
    dbSetOrder(1)
    dbSeek(xFilial("SC2")+cChaveOP)
    If !Eof()
        Return .T.
    Else

        // ABERTURA DA OP
        MsAguarde({|| MSExecAuto({|x,y| MATA650(x,y)}, aAuto, 3) },"Execauto MATA650","Incluindo OP... " + cChaveOP )
        
        dbSelectArea("SC2")
        dbSetOrder(1)
        dbSeek(xFilial("SC2") + cChaveOP)
        If !Eof()
            
			lMsErroAuto := .F.

			// @history ticket 65585 - Fernando Macieira - 01/02/2022 - Processamento OP - Edata p/ Protheus - Item Salsicha 193229
			FixSalsicha(cChaveOP)
			
			// @history ticket 11639 - Fernando Macieira - 31/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
			If Upper(AllTrim(cPrd3)) == "T" // Produção de terceiro 
				
				SD4->( dbSetOrder(2) ) // D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, R_E_C_N_O_, D_E_L_E_T_
				If SD4->( dbSeek(FWxFilial("SD4")+cChaveOP) )

					Do While SD4->( !EOF() ) .and. AllTrim(SD4->D4_OP) == AllTrim(cChaveOP) .and. SD4->D4_FILIAL==FWxFilial("SD4")

						If Left(AllTrim(SD4->D4_COD),1) <> "Z"
							RecLock("SD4", .F.)
								SD4->D4_LOCAL := cLoc3
							SD4->( msUnLock() )
						EndIf

						SD4->( dbSkip() )

					EndDo

				EndIf

			EndIf
			//

        EndIf
        
        If lMsErroAuto

            lRet := .F.

            aErroLog := GetAutoGrLog()
            cErro 	 := Alltrim(aErrolog[1])
            For k := 1 to Len(aErroLog)
                If "INVALIDO" $ UPPER (aErroLog[k])
                    cErro+= Alltrim(aErroLog[k])
                EndIf
            Next
            
            cErro := CleanStr(cErro)
            DDATABASE := _dData
            
            _MsgMotivo += "Erro no Cadastro da Ordem de Produção " + cError + CHR(13) + CHR(10)
            _MsgMotivo += "Mensagem de ErrorLog Protheus : " + cErro
            
            U_CCSGrvLog(cErro, "OPR", 0, 3, cFilOPR, .T.)
            TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRecOPR))+" AND OPERACAO='I' ")
            DisarmTransaction() 
            //Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

        Else
            
            lRet := .T.
            DDATABASE := _dData
            TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='S' WHERE REC="+AllTrim(Str(nRecOPR))+" AND OPERACAO='I' ")

        EndIf

    EndIf                       

    MsUnLockAll() 								// @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s

Return lRet

/*/{Protheus.doc} User Function nomeFunction
	aponta produção
	@type  Function
	@author user
	@since 03/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA002PC(cErro, nRecOPR, cOp)

	Local cSeek     := Nil
	Local aAuto     := Nil
	Local lRet      := .F.
	Local aSavAre   := GetArea()
	Local cTM       := Alltrim(GetMv('MV_XTMPRD',.F., "010"))   		//Tm para movimentação
	Local nQuantC2  := 0
	Local cLocalC2 	:= ""
	Local cProdC2	:= ""
	Local cRefTrf	:= ""
	Local _dData			:= DDATABASE
	Local cError  	:= ""
	Local k

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

    cFilBkp := cFilAnt           
    
    SC2->( dbSetOrder(1) ) // C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
    If SC2->( dbSeek(FWxFilial("SC2")+cOp) )

        nQuantC2	:= SC2->C2_QUANT - SC2->C2_QUJE
        cLocalC2	:= SC2->C2_LOCAL
        cProdC2		:= SC2->C2_PRODUTO
        cRefTrf		:= SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
        cCCC2		:= SC2->C2_CC
        dDataC2		:= SC2->C2_DATPRF
        cNumOP		:= SC2->(C2_NUM)
        cItem		:= SC2->(C2_ITEM)
        DDATABASE	:= SC2->C2_EMISSAO //(cAliasOPR)->DATA
        
        //{"D3_FILIAL"       , cFIl	                           , Nil}, ;
        aAuto := {	{"D3_FILIAL"       , SC2->C2_FILIAL	                           , Nil}, ;
                    {"D3_TM"           , cTM				                       , Nil}, ;
                    {"D3_COD"          , SC2->C2_PRODUTO                           , Nil}, ;
                    {"D3_QUANT"        , SC2->C2_QUANT				               , Nil}, ;
                    {"D3_OP"           , SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD), Nil}, ;
                    {"D3_LOCAL"        , SC2->C2_LOCAL                             , Nil}, ;
                    {"D3_EMISSAO"      , DDATABASE		                           , Nil}, ;
                    {"D3_CC"           , SC2->C2_CC                                , Nil}, ;
                    {"D3_RECORI"       , StrZero(nRecOPR,10)        		  	   , Nil}}
                    
        cError += " PRODUTO = " + ALLTRIM(SC2->C2_PRODUTO) + "; TM = " + ALLTRIM(cTM) + "; OP = " + ALLTRIM(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)) + "; EMISSAO = " + ALLTRIM( DTOC(DDATABASE)) + "; RECORI = " + ALLTRIM( StrZero(nRecOPR,10) ) + "; "
        
        //Begin Transaction // já está dentro de um begin

            lMsErroAuto := .F.
            MsAguarde({|| MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 3) },"Execauto MATA250","Incluindo apontamento... " + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) )

            If lMsErroAuto

				lRet      := .F.

                aErroLog := GetAutoGrLog()
                cErro := Alltrim(aErrolog[1])

                For k := 1 to Len(aErroLog)
                    If "INVALIDO" $ UPPER (aErroLog[k])
                        cErro+= Alltrim(aErroLog[k])
                    EndIf
                Next

                cErro := CleanStr(cErro)			
                _MsgMotivo += "Erro no Apontamento de Produção " + cError + CHR(13) + CHR(10)
                _MsgMotivo += "Mensagem de ErrorLog Protheus : " + cErro
                U_CCSGrvLog(cErro, "OPR", nRecOPR, 3, cFilAnt, .T.)
                DisarmTransaction() 
                //Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
				
            Else

                lRet := .T.
                TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='S' WHERE REC="+AllTrim(Str(nRecOPR))+" AND OPERACAO='I' ")

            Endif

        //End Transaction

    Else

        _MsgMotivo += "Erro no Apontamento de Produção " + cError + CHR(13) + CHR(10)
        _MsgMotivo += "OP não encontrada: " + cOp
        
        U_CCSGrvLog(cErro, "OPR", nRecOPR, 3, cFilAnt, .T.)

    EndIf
    
    cFilAnt := cFilBkp
    RestArea(aSavAre)
    DDATABASE :=_dData
    MsUnLockAll() 										// @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s

Return (lRet)

/*/{Protheus.doc} static Function nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 03/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA002PD(cAliasOPR, cOp)

	Local cSeek   := Nil
	Local aAuto   := Nil
	Local lRet    := .F.
	Local aSavAre := GetArea()
	Local cError  := ""
	Local k

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

		//BUSCAR MOVIMENTO DE PRODUCAO COM BASE NO RECNO DE ORIGEM	
		cFilBkp := cFilAnt
		SD3->(DbOrderNickName("RECORI"))
		SD3->(DbSeek(xFilial("SD3") + StrZero((cAliasOPR)->REC, 10) + PADR((cAliasOPR)->PRODUTO, TamSX3("D3_COD")[1]) ))
		cOp := SD3->D3_OP

		aAuto := {	{"D3_FILIAL"    , SD3->D3_FILIAL	, Nil}, ;
					{"D3_TM"        , SD3->D3_TM		, Nil}, ;
					{"D3_COD"       , SD3->D3_COD       , Nil}, ;
					{"D3_QUANT"     , SD3->D3_QUANT     , Nil}, ;
					{"D3_OP"        , SD3->D3_OP		, Nil}, ;
					{"D3_LOCAL"     , SD3->D3_LOCAL     , Nil}, ;
					{"D3_EMISSAO"   , SD3->D3_EMISSAO   , Nil}, ;
					{"D3_CC"        , SD3->D3_CC        , Nil}, ;
					{"D3_DOC"       , SD3->D3_DOC       , Nil}, ;
					{"D3_PARCTOT"	, SD3->D3_PARCTOT   , Nil}, ;
					{"D3_NUMSEQ"    , SD3->D3_NUMSEQ    , Nil}, ;
					{"D3_CHAVE"     , SD3->D3_CHAVE     , Nil}, ;
					{"INDEX"     	, 4        			, Nil}   }
		
		cError += " PRODUTO = " + ALLTRIM(SD3->D3_COD) + "; TM = " + ALLTRIM(SD3->D3_TM) + "; OP = " + ALLTRIM(SD3->D3_OP) + "; EMISSAO = " + ALLTRIM( DTOC(SD3->D3_EMISSAO)) + "; "
		
		//Begin Transaction // já esta dentro de um begin
		lMsErroAuto := .F.
		MsAguarde({|| MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 5) },"Execauto MATA250","Excluindo apontamento... " + SD3->D3_OP + " " + SD3->D3_COD )

		If lMsErroAuto
			
			aErroLog:=GetAutoGrLog()
			cErro:=Alltrim(aErrolog[1])
			
			For k:=1 to Len(aErroLog)
				If "INVALIDO" $ UPPER (aErroLog[k])
					cErro+= Alltrim(aErroLog[k])
				EndIf
			Next
			
			cErro := CleanStr(cErro)
			_MsgMotivo += "Erro no Estorno do Apontamento de Produção " + cError + CHR(13) + CHR(10)
			_MsgMotivo += "Mensagem de ErrorLog Protheus : " + cErro + CHR(13) + CHR(10)
			MsUnlockAll()
			DisarmTransaction() 
			//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
			
		Else
			lRet := .T.
		Endif
		
		//End Transaction
		
		cFilAnt := cFilBkp
		RestArea(aSavAre)
	
Return .T.	//lRet	//Retorna valor default como True(.T.) porque pode ser que não tenha gerado a Produção, mas sempre terá a requisição

/*/{Protheus.doc} nomeStaticFunction
	Estorna a OP 
	@type  Static Function
	@author user
	@since 03/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA002PE(cAliasOPR, nQuant, nOpc, cOp)

	Local aAuto   := Nil
	Local aSavAre := SaveArea1({"SB1"})
	Local lRet    := .F.
	Local nLoop1
	Local nLoop
	Local nPos                                 

	Local cFilOP  := (cAliasOPR)->FILIAL
	Local cCod    := (cAliasOPR)->PRODUTO
	Local cNum
	Local cItem
	Local cSequen
	Local cError  := ""
	Local k

	Private lAutoErrNoFile 	:= .T.

		cFilBkp := cFilAnt
		cFilAnt := (cAliasOPR)->FILIAL
		
		SB1->(dbSetOrder(1))  // B1_FILIAL+B1_COD
		SB1->(dbSeek(xFilial("SB1") + cCod))
		
		SC2->( dbSetOrder(1) ) // C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
		If SC2->( dbSeek(FWxFilial("SC2")+cOp) )

			cNum 	:= SC2->C2_NUM
			cItem	:= SC2->C2_ITEM
			cSequen	:= SC2->C2_SEQUEN
			//{"C2_CC"           , SB1->B1_CC                         , Nil}, ;
			aAuto := {  {"C2_FILIAL"       , cFilOP		                        , Nil}, ;
						{"C2_NUM"          , cNum			                    , Nil}, ;
						{"C2_ITEM"         , cItem                              , Nil}, ;
						{"C2_SEQUEN"       , cSequen							, Nil}, ;
						{"C2_PRODUTO"      , cCod		                        , Nil}, ;
						{"C2_LOCAL"        , RetFldProd(SB1->B1_COD,"B1_LOCPAD"), Nil}, ;
						{"C2_CC"           , SC2->C2_CC                         , Nil}, ;
						{"C2_QUANT"        , nQuant		                        , Nil}, ; // ou trocar para ZZ_PBRUTO
						{"C2_UM"           , SB1->B1_UM                         , Nil}, ;
						{"C2_DATPRI"       , SC2->C2_DATPRI             		, Nil}, ;
						{"C2_DATPRF"       , SC2->C2_DATPRF             		, Nil}, ;
						{"C2_EMISSAO"      , SC2->C2_EMISSAO            		, Nil}, ;
						{"C2_TPOP"         , "F"                                , Nil}, ;
						{"C2_REVISAO"      , ""				                    , Nil}, ;
						{"AUTEXPLODE"      , "S"                                , Nil}}
						
			cError += " PRODUTO = " + ALLTRIM(cCod) + "; OP = " + ALLTRIM(cNum+cItem+cSequen) + "; EMISSAO = " + ALLTRIM( DTOC(SC2->C2_EMISSAO) ) + "; "

			/* Se alteracao ou exclusao, deve-se posicionar no registro da SC2 antes de executar a rotina automatica */
			If nOpc == 4 .Or. nOpc == 5
				SC2->(DbSetOrder(6)) //C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
				SC2->( DbSeek( xFilial("SC2") + SC2->(C2_NUM + C2_ITEM + C2_SEQUEN + C2_PRODUTO ) ) )
			EndIf

			lMsErroAuto := .F.
			MsAguarde({|| MSExecAuto({|x,y| MATA650(x,y)}, aAuto, nOpc) },"Execauto MATA650","Ordem de produção... " + cNum + " " + cCod )
			
			If lMsErroAuto

				aErroLog:=GetAutoGrLog()
				cErro:=Alltrim(aErrolog[1])
				
				For k:=1 to Len(aErroLog)
					If "INVALIDO" $ UPPER (aErroLog[k])
						cErro+= Alltrim(aErroLog[k])
					EndIf
				Next
				
				cErro := CleanStr(cErro)
				_MsgMotivo += "Erro " + IIF( nOpc == 3, "no Cadastro", IIF( nOpc == 4, "na Alteração", "no Estorno" ) ) + " da Produção " + cError + CHR(13) + CHR(10)
				_MsgMotivo += "Mensagem de ErrorLog Protheus : " + cErro
				DisarmTransaction() 
				//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 

			Else
				lRet := .T. 		
			Endif

		Else
			
			_MsgMotivo += "Erro no estorno do Apontamento de Produção " + cError + CHR(13) + CHR(10)
			_MsgMotivo += "OP não encontrada: " + cOp
			U_CCSGrvLog(cErro, "OPR", nRecOPR, 3, cFilAnt, .T.)

		EndIf
		
		cFilAnt := cFilBkp
		
		RestArea1(aSavAre)

		MsUnLockAll() 								// @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s

Return lRet
                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADEDA004P  ºAutor  ³Microsiga           º Data ³  07/19/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Integra Movimentos de devolução/requisição                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADEDA004P(nRec)

	// NECESSÁRIO READEQUAR PARA O LAYOUT DA TABELA DE INTEGRAÇÃO COM O EDATA

	Local _aArea    := GetArea()
	Local _lExporta := .F.
	Local lRet      := .F.
	Local lHtml     := .T.
	Local cAnexo    := ""
	Local cMsgError := ""
	Local dData		:= DDATABASE
	Local k

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

	Default nRec := 0
	//Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADEDA007R como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADEDA007R*/

    _lJob    := .F.
    
    /*
    TcConType("TCPIP")
    If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
        _lRet     := .F.
        cMsgError := "Não foi possível  conectar ao banco Protheus"
        MsgInfo("Não foi possível  conectar ao banco produção, verifique com administrador","ERROR")
        
    EndIf
    
    If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
        _lRet     := .F.
        cMsgError := "Não foi possível  conectar ao banco integração"
        MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")
        
    EndIf
    */
    
    //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
    
    cQry:="SELECT * FROM MOV010 (NOLOCK) WHERE D_E_L_E_T_=' ' AND (MSEXP='' OR ( MSEXP<> '' AND  STATUS ='E' )) "
    
    If nRec > 0
        cQry +=	" AND REC = " +ALLTRIM(STR(nRec))
    EndIf
    
    cQry += " ORDER BY FILIAL,DATA,PRODUTO "
    
    DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), "MOV", .F., .T.)
    
    TcSetField( "MOV", "DATA", "D", 8, 0 )
    
    //backup da filial corrente
    cFilBck := cFilAnt
    
    cChave:=""	
    While !MOV->(Eof())

        dbSelectArea("MOV")

        cFilAnt	:= MOV->FILIAL
        cCod 	:= MOV->PRODUTO
        cFil 	:= MOV->FILIAL
        
        DDATABASE := MOV->DATA
        
        aCampos:={}
        
        //TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
        
        dbSelectArea("SB1")
        dbSetOrder(1)  // B1_FILIAL+B1_COD
        dbSeek(xFilial("SB1") + MOV->PRODUTO)
        If Eof()
            //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
            cErro := "OPR - Produto nao cadastrado no Protheus "+cCod
            TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRecB1))+" AND OPERACAO='I' ")
            Return lRet
        EndIf
        
        cLoc 	:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
        
        //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
        
        AADD(aCampos, {"D3_FILIAL"	,cFilAnt		 				, Nil})
        AADD(aCampos, {"D3_TM"		,MOV->TM		 				, Nil})
        AADD(aCampos, {"D3_COD"		,MOV->PRODUTO	 				, Nil})
        AADD(aCampos, {"D3_QUANT"	,MOV->QUANT				 		, Nil})
        AADD(aCampos, {"D3_LOCAL"	,RetFldProd(SB1->B1_COD,"B1_LOCPAD"), Nil})
        AADD(aCampos, {"D3_CC"		,'5131'							, Nil}) // ESTÁ FIXO MAIS PRECISARÁ SER REVISTO...VERIFICAR
        AADD(aCampos, {"D3_RECORI"  ,StrZero(MOV->REC,10)		 	, Nil}) // setado como caracter pois indices numericos sao problematicos no banco
        
        cFilMOV := MOV->FILIAL
        nRecMOV := MOV->REC
        
        //TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
        
        // o Mata240 nao executa um criasb2 e se isso nao for feito a interface vai gerar um log
        dbSelectArea("SB1")
        dbSetOrder(1)
        dbSeek(xFilial("SB1") + MOV->PRODUTO)
        If Eof()
            // Deixa dar log na interface de que nao existe o produto para o armazem
        Else
            // se existir o produto, crio ele no armazem do movimento com saldo zero
            dbSelectArea("SB2")
            dbSetOrder(1)
            If !dbSeek(cFilAnt+PADR(cCod,TAMSX3("B1_COD")[1])+RetFldProd(SB1->B1_COD,"B1_LOCPAD"))
                CriaSb2(cCod,cLoc)
            EndIf
        EndIf
        
        lMsErroAuto:=.F.
        
        //Begin Transaction
        
            //MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 3)
            MsAguarde({|| MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 3) },"Execauto MATA240","Incluindo movimentação... " + MOV->PRODUTO + " " + StrZero(MOV->REC,10) )
        
            If lMsErroAuto
        
                //DisarmTransaction()
                aErroLog:=GetAutoGrLog()
                cErro := Alltrim(aErrolog[1])
                For k := 1 to Len(aErroLog)
                    If "INVALIDO" $ UPPER (aErroLog[k])
                        cErro+= Alltrim(aErroLog[k]) //+ Chr(13)+Chr(10)
                    EndIf
                Next
                cErro := CleanStr(cErro)
                
                _MsgMotivo += cErro
                
                U_CCSGrvLog(cErro, "MOV", nRecMOV, 3, cFilMOV, .T.)
                
                //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
                TcSqlExec("UPDATE MOV010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRecMOV))+" ")
        
            Else
        
                //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
                TcSqlExec("UPDATE MOV010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='S' WHERE REC="+AllTrim(Str(nRecMOV))+" ")
                
                lRet := .T.

            EndIF
        
        //End Transaction
        
        //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
        
        MOV->(DbSkip())
        
    EndDo
    
    MOV->(DbCloseArea())
    
    //If !(IsInCallStack("U_ADORP001") .OR. IsInCallStack("U_ADEDA007R"))
    //	TcUnLink(_nTcConn1)
    //	TcUnLink(_nTcConn2)
    //EndIf
    
    //restaura filial corrente
    cFilAnt := cFilBck           
    DDATABASE := dData
        
    RestArea(_aArea)

    MsUnLockAll()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADEDA005P  ºAutor  ³Microsiga           º Data ³  07/19/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Integra Movimentos de Cancelamento devolução/requisição     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADEDA005P(nRec, lEstorno)

	// NECESSÁRIO READEQUAR PARA O LAYOUT DA TABELA DE INTEGRAÇÃO COM O EDATA

	Local _aArea    := GetArea()
	Local _lExporta := .F.
	Local lRet   	:= .F.
	Local lHtml     := .T.
	Local cAnexo    := ""
	Local cMsgError := ""
	Local cProduto	:= ""
	Local cProdTm	:= ""
	Local k

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

	Default nRec 	:= 0
	Default lEstorno:= .F. 
	//Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADEDA007R como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADEDA007R*/

		_lJob    := .F.
		/*
		TcConType("TCPIP")
		If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
			_lRet     := .F.
			cMsgError := "Não foi possível  conectar ao banco Protheus"
			MsgInfo("Não foi possível  conectar ao banco produção, verifique com administrador","ERROR")
			
		EndIf
		
		If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
			_lRet     := .F.
			cMsgError := "Não foi possível  conectar ao banco integração"
			MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")
			
		EndIf
		*/
		//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
		cQry := " SELECT * FROM MOV010 (NOLOCK) WHERE D_E_L_E_T_=' ' AND "
		
		If lEstorno
			cQry += " MSEXP <> ' ' "
		Else		
			cQry +=	" (MSEXP='' OR ( MSEXP<> '' AND  STATUS ='E' )) "
		EndIf
		
		If nRec > 0
			cQry += " AND REC = '" + ALLTRIM(StrZero(nRec,10)) + "' "
		EndIf
		
		cQry += " ORDER BY FILIAL "
		
		DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), "MOV", .F., .T.)

		TcSetField( "MOV", "D3_EMISSAO", "D", 8, 0 )
		TcSetField( "MOV", "D3_DTLANC", "D", 8, 0 )
		TcSetField( "MOV", "D3_DTVALID", "D", 8, 0 )
		
		cFilBkp := cFilAnt
		
		cChave:=""
		While !MOV->(Eof())

			cFilMOV := MOV->FILIAL
			nRecMOV := MOV->REC
			cRecMov := StrZero(MOV->REC,10) // foi setado como caracter pois indices numericos dao problema no protheus
			cProduto:= MOV->PRODUTO
			cProdTm	:= MOV->TM
		
			If MOV->FILIAL == "04"
				cFilAnt := "03"
			Else
				cFilAnt := MOV->FILIAL
			EndIf
			cFilMov := cFilAnt
			
			//TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
			
			dbSelectArea("SD3")
			SD3->(DbOrderNickName("RECORI"))
			SD3->(dbSeek(cFilMov + cRecMov + PADR(cProduto, TamSX3("D3_COD")[1]) + PADR(cProdTm, TamSX3("D3_TM")[1]) ))
			
			If 	SD3->(!Eof())

				aCampos:={}
				AADD(aCampos, {"D3_FILIAL"	, SD3->D3_FILIAL	, Nil})
				AADD(aCampos, {"D3_TM"		, SD3->D3_TM		, Nil})
				AADD(aCampos, {"D3_COD"		, SD3->D3_COD		, Nil})
				AADD(aCampos, {"D3_QUANT"	, SD3->D3_QUANT 	, Nil})
				AADD(aCampos, {"D3_LOCAL"	, SD3->D3_LOCAL 	, Nil})
				AADD(aCampos, {"D3_EMISSAO" , SD3->D3_EMISSAO   , Nil})
				AADD(aCampos, {"D3_DOC"     , SD3->D3_DOC       , Nil})
				AADD(aCampos, {"D3_NUMSEQ"  , SD3->D3_NUMSEQ    , Nil})
				AADD(aCampos, {"INDEX"     	, 4        			, Nil})
	//			AADD(aCampos, {"D3_RECORI"  ,SD3->D3_RECORI 	, Nil}) // setado como caracter pois indices numericos sao problematicos no banco
				
				lMsErroAuto:=.F.
				
				//Begin Transaction
					
					//MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5)
					MsAguarde({|| MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5) },"Execauto MATA240","Estornando movimentos... " + SD3->D3_DOC + " " + SD3->D3_COD )
					
					If lMsErroAuto
						
						//DisarmTransaction()
						
						aErroLog:=GetAutoGrLog()
						cErro:=Alltrim(aErrolog[1])
						
						For k:=1 to Len(aErroLog)
							If "INVALIDO" $ UPPER (aErroLog[k])
								cErro+= Alltrim(aErroLog[k]) //+ Chr(13)+Chr(10)
							EndIf
						Next
						
						cErro := CleanStr(cErro)
						
						_MsgMotivo += cErro
						
						U_CCSGrvLog(cErro, "MOV", nRecMOV, 5, cFilMOV, .T.)
						
						//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
						
						_MsgMotivo += "Problema ao estornar a Movimentação Interna. "
						
						/*Não altera os dados do item da tabela MOV se foi um estorno do fonte ADEDA007R que executou esta função*/
						If !lEstorno
							TcSqlExec("UPDATE MOV010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRecMOV))+" ")
						EndIf
					
					Else
					
						//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
						
						/*Seta o campo D_E_L_E_T_='*' caso seja um item da tabela que foi um estorno do fonte ADEDA007R que executou esta função*/
						If lEstorno
							TcSqlExec("UPDATE MOV010 SET D_E_L_E_T_='*' WHERE REC=" + AllTrim(Str(nRecMOV)) + " AND D_E_L_E_T_=' ' ")
						Else
							TcSqlExec("UPDATE MOV010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='S' WHERE REC=" + AllTrim(Str(nRecMOV)) + " AND D_E_L_E_T_=' ' ")
						EndIf
						
						lRet := .T.
					
					EndIf
				
				//End Transaction

			Else
				
				cErro := "HELP: Requisição de MP nao Encontrada para ser Cancelada."
				
				_MsgMotivo += cErro
				U_CCSGrvLog(cErro, "MOV", nRecMOV, 5, cFilMOV, .T.)
				
				//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
				
				/*Não altera os dados do item da tabela MOV se foi um estorno do fonte ADEDA007R que executou esta função*/
				If !lEstorno
					TcSqlExec("UPDATE MOV010 SET MSEXP='" + DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC=" + AllTrim(Str(nRecMOV)) + " ")			
				EndIf
			
			EndIf
			
			//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
			
			MOV->(DbSkip())
			
		EndDo
		
		MOV->(DbCloseArea())
		
		RestArea(_aArea)
		
		cFilAnt := cFilBkp
		
		//If !(IsInCallStack("U_ADORP001") .OR. IsInCallStack("U_ADEDA007R"))
		//	TcUnLink(_nTcConn1)
		//	TcUnLink(_nTcConn2)
		//EndIf

		MsUnLockAll()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADEDA006P  ºAutor  ³Microsiga           º Data ³  07/19/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Integra Movimentos de inventario                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADEDA006P(nRec, lInclui, lEstorno)

	// NECESSÁRIO READEQUAR PARA O LAYOUT DA TABELA DE INTEGRAÇÃO COM O EDATA

	Local _aArea    := GetArea()
	Local _lExporta := .F.
	Local lRet 		:= .F.
	Local lHtml     := .T.
	Local cAnexo    := ""
	Local cMsgError := ""
	Local cFilBkp 	:= cFilAnt
	Local cCodAux	:= ""			/*Código do produto auxiliar para usar nos processamentos*/
	Local cDocAux	:= ""			/*Código do documento auxiliar para usar nos processamentos*/
	Local cLocAux	:= ""			/*Local do produto auxiliar para usar nos processamentos*/
	Local dDtaAux	:= dDataBase	/* Data auxiliar para uso nos processamentos */

	Local k

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

	Default nRec 	:= 0
	Default lInclui := .T.
	Default lEstorno:= .F.
	//Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADEDA007R como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADEDA007R*/

		lMsErroAuto	:= .F.
		_lJob    	:= .F.
		/*
		TcConType("TCPIP")
		If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
			_lRet     := .F.
			cMsgError := "Não foi possível  conectar ao banco Protheus"
			MsgInfo("Não foi possível  conectar ao banco produção, verifique com administrador","ERROR")
			
		EndIf
		
		If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
			_lRet     := .F.
			cMsgError := "Não foi possível  conectar ao banco integração"
			MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")
			
		EndIf
		*/
		//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA

		cQry:="SELECT * FROM INV010 (NOLOCK) WHERE D_E_L_E_T_=' ' AND "
		
		If lEstorno
			cQry += " MSEXP <> ' ' "
		Else		
			cQry +=	" (MSEXP='' OR ( MSEXP<> '' AND  STATUS ='E' )) "
		EndIf
		
		If nRec > 0 
			cQry += " AND REC = '" + ALLTRIM(StrZero(nRec,10)) + "' "
		EndIf
		
		cQry += " ORDER BY FILIAL "
		
		DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), "INV", .F., .T.)

		TcSetField( "INV", "B7_DATA", "D", 8, 0 )
		TcSetField( "INV", "B7_DTVALID", "D", 8, 0 )
		
		cChave:=""
		While !INV->(Eof())
		
			//TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
			dbSelectArea("SB1")
			dbSetOrder(1)  // B1_FILIAL+B1_COD
			dbSeek(xFilial("SB1") + INV->PRODUTO)
			If Eof()
				//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
				cErro := "INV - Produto nao cadastrado no Protheus "+INV->PRODUTO
				TcSqlExec("UPDATE INV010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(INV->REC)) )
				Return lRet
			EndIf
			
			//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
			
			cLocalProd := RetFldProd(INV->PRODUTO,"B1_LOCPAD")
			
			aInvent:={}
			Aadd(aInvent,{"B7_FILIAL"  ,INV->FILIAL				,Nil})
			Aadd(aInvent,{"B7_COD"     ,INV->PRODUTO			,Nil})
			Aadd(aInvent,{"B7_LOCAL"   ,cLocalProd		 		,Nil})
			Aadd(aInvent,{"B7_DOC"     ,INV->DOC   				,Nil})
			Aadd(aInvent,{"B7_QUANT"   ,INV->QUANT  			,Nil})
			Aadd(aInvent,{"B7_DATA"    ,STOD(INV->DATA)			,Nil})
			Aadd(aInvent,{"B7_RECORI"  ,StrZero(INV->REC, 10)	,Nil})
		
			cFilINV := INV->FILIAL
			nRecINV := INV->REC
			
			cFilAnt := INV->FILIAL
			
			dDtaAux := INV->B7_DATA
			cCodAux	:= INV->B7_COD
			cLocAux := INV->B7_LOCAL
			cDocAux	:= INV->B7_DOC
			
			//TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
			lMsErroAuto := .f.
			
			If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
			
				//Begin Transaction // analiseFWNM
				
					SB2->(DbSetOrder(1))
					If !SB2->(DbSeek( xFilial("SB2") + cCodAux + cLocAux ))
		
						CriaSB2(cCodAux, cLocAux)
		
					Else
		
						dbSelectArea("SB2")
						RecLock("SB2",.F.)
							Replace B2_DINVENT With dDtaAux
						SB2->( msUnLock() ) //@history ticket   10248 - Fernando Macieira     - 03/03/2021 - Revisão das rotinas de apontamento de OP´s
						//MsUnlockAll() // @history ticket   10248 - Fernando Macieira     - 03/03/2021 - Revisão das rotinas de apontamento de OP´s

					EndIf
					
					/*
						Efetua o processamento de todos os movimentos relacionados ao inventário (Estorno do Acerto de Inventário)
					*/
					If !lInclui
					
						/*Posiciona no item para buscar os movimentos relacionados ao inventário que deverá ser estornado*/
						/*
							SD3 - Index RECORI
							D3_FILIAL, D3_RECORI, D3_COD, R_E_C_N_O_, D_E_L_E_T_
						*/				
						dbSelectArea("SD3")
						SD3->(DbOrderNickName("RECORI"))
						SD3->( dbSeek( cFilINV + ALLTRIM(StrZero(nRecINV, 10)) + PADR(cCodAux, TamSX3("D3_COD")[1]) ) )
				
						If !SD3->(Eof())
										
							AADD(aCabSD3, {"D3_FILIAL"	,SD3->D3_FILIAL	, Nil})
							AADD(aCabSD3, {"D3_DOC" 	,SD3->D3_DOC 	, NIL})
							AADD(aCabSD3, {"D3_TM"		,SD3->D3_TM		, Nil})
							AADD(aCabSD3, {"D3_COD"		,SD3->D3_COD	, Nil})
							AADD(aCabSD3, {"D3_QUANT"	,SD3->D3_QUANT	, Nil})
							AADD(aCabSD3, {"D3_LOCAL"	,SD3->D3_LOCAL	, Nil})
							AADD(aCabSD3, {"D3_CC"		,SD3->D3_CC 	, Nil})
							AADD(aCabSD3, {"D3_OP"		,SD3->D3_OP	  	, Nil})
							AADD(aCabSD3, {"D3_NUMSEQ"	,SD3->D3_NUMSEQ	, Nil})
							AADD(aCabSD3, {"D3_EMISSAO"	,SD3->D3_EMISSAO, Nil})
							
							lMsErroAuto := .F.
							
							/*
								SD3 - Index 07
								D3_FILIAL, D3_COD, D3_LOCAL, D3_EMISSAO, D3_NUMSEQ, R_E_C_N_O_, D_E_L_E_T_
							*/
							/*Posiciona no item do SD3 para que no execauto não se perca*/
				//			SD3->(DbSetOrder(7))
				//			SD3->(DbSeek( Padr(cFilINV, TamSX3("D3_FILIAL")[1]) + Padr(cCodAux, TamSX3("D3_COD")[1]) + Padr(cLocAux, TamSX3("D3_LOCAL")[1]) + Padr(DTOS(dDtaAux), TamSX3("D3_EMISSAO")[1]) + Padr(cNumSeqAux, TamSX3("D3_NUMSEQ")[1]) ))
							
							/*Efetua o estorno das requisições relacionados ao inventário que foi estornado*/
							//MSExecAuto({|x,y| MATA240(x,y)}, aCabSD3, 5)
							MsAguarde({|| MSExecAuto({|x,y| MATA240(x,y)}, aCabSD3, 5) },"Execauto MATA240","Estornando movimentos... " + SD3->D3_OP + " " + SD3->D3_COD )
				
							If lMsErroAuto
				
								aErroLog:=GetAutoGrLog()
								For k:=1 to Len(aErroLog)
									If "INVALIDO" $ UPPER (aErroLog[k])
										cErro+= Alltrim(aErroLog[k])
									EndIf
								Next
								
								cErro := CleanStr(cErro)
							
								_MsgMotivo += cErro
				
								U_CCSGrvLog(cErro, "INV", nRecINV, 3, cFilINV)
				
								//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
								
								_MsgMotivo += "Problema no estorno do acerto de inventário. "

								/*Não altera os dados do item da tabela INV se foi um estorno do fonte ADEDA007R que executou esta função*/
								If !lEstorno							
		//							TODO: VERIFICAR A QUERY DE UPDATE
									TcSqlExec("UPDATE INV010 SET MSEXP='" + DTOS(dData) + "' ,STATUS='E', MSG='" + cErro + "' WHERE REC=" + AllTrim(Str(nRecINV)) + " ")
								EndIf

								lRet := .F.

								// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
								DisarmTransaction() 
								//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
								//

							Else
				
								//TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
								
								SB2->(DbSetOrder(1))
								If SB2->(DbSeek( Padr(cFilINV, TamSX3("D3_FILIAL")[1]) + Padr(cCodAux, TamSX3("D3_COD")[1]) + Padr(cLocAux, TamSX3("D3_LOCAL")[1]) ))
									RecLock("SB2", .F.)
										SB2->B2_DINVENT := dDtaAux - 1
									SB2->( MsUnlock() ) //@history ticket   10248 - Fernando Macieira     - 03/03/2021 - Revisão das rotinas de apontamento de OP´s
								EndIf

								lRet := .T.		

							EndIf
							
							//TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
							
						EndIf
								
					EndIf
					
					/*
						SB7 - Index 01
						B7_FILIAL, B7_DATA, B7_COD, B7_LOCAL, B7_LOCALIZ, B7_NUMSERI, B7_LOTECTL, B7_NUMLOTE, B7_CONTAGE, R_E_C_N_O_, D_E_L_E_T_
					*/
					/*Posiciona no item do SB7 para que no execauto não se perca*/			
				//	SB7->(dbSetOrder(1))
				//  SB7->(dbSeek( Padr(cFilINV, TamSX3("B7_FILIAL")[1]) + Padr(DTOS(dDtaAux), TamSX3("B7_DATA")[1]) + Padr(cCodAux, TamSX3("B7_COD")[1]) + Padr(cLocAux, TamSX3("B7_LOCAL")[1]) ))
					
					/*Executa o cadastro/estorno de inventário no Protheus*/
					//MSExecAuto({|x,y,z| mata270(x,y,z)}, aInvent, .T., IIF(lInclui, 3, 5))
					MsAguarde({|| MSExecAuto({|x,y,z| mata270(x,y,z)}, aInvent, .T., IIF(lInclui, 3, 5)) },"Execauto MATA270","Efetuando inventário... " + cDocAux )
					
					If lMsErroAuto
						
						aErroLog:=GetAutoGrLog()
						cErro:=Alltrim(aErrolog[1])
						
						For k:=1 to Len(aErroLog)
							If "INVALIDO" $ UPPER (aErroLog[k])
								cErro+= Alltrim(aErroLog[k])
							EndIf
						Next
						
						cErro := CleanStr(cErro)
							
						_MsgMotivo += cErro
						
						U_CCSGrvLog(cErro, "INV", nRecINV, 3, cFilINV, .T.)
						
						//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
						
						_MsgMotivo += "Problema no estorno do inventário. "
						
						/*
							Não altera os dados do item da tabela INV se foi um estorno do fonte ADEDA007R que executou esta função.
							Condições:
								lInclui = Operação de inclusão
								!lInclui .AND. !Estorno = Operação de Exclusão
								!lInclui .AND. Estorno = Operação de Estorno por interface
						*/
						If lInclui .OR. (!lInclui .AND. !Estorno)
							TcSqlExec("UPDATE INV010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRecINV))+" ")
						EndIf
				
						lRet := .F.

						// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
						DisarmTransaction() 
						//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
						//

					Else
					
						If lInclui
				
							/*Efetua o processamento de todos os movimentos relacionados ao inventário (Acerto de Inventário)*/
							dDataBase := dDtaAux
							
							lMsErroAuto := .F.
							
							/*
								MATA340 - Processa Acerto de Inventário ( < ExpL01>, < ExpC01>, < ExpL02> )
							
								- ExpL01: Lógico - Variável lógica que determina se a execução da função é originada de rotina automática. Conteúdo deve ser (.T.)	X	
								- ExpC01: Caracter - Variável do tipo caracter que informa o código do inventário que deverá ser processado o acerto (B7_DOC)	X	
								- ExpL02: Lógico - Variável lógica para definir se o processamento deverá ser executado apenas para o registro previamente 
													posicionado na tabela SB7, correspondente ao código de inventário desejado (.T.) ou se deverá ser processada 
													para todos os itens que compreedem o código de inventário informado (.F.)
							*/
							//MSExecAuto({|x,y,z| mata340(x,y,z)}, .T., cDocAux, .T.)
							MsAguarde({|| MSExecAuto({|x,y,z| mata340(x,y,z)}, .T., cDocAux, .T.) },"Execauto MATA340","Processando inventário... " + cDocAux )

							If lMsErroAuto
				
								aErroLog:=GetAutoGrLog()
								cErro:=Alltrim(aErrolog[1])
								For k:=1 to Len(aErroLog)
									If "INVALIDO" $ UPPER (aErroLog[k])
										cErro+= Alltrim(aErroLog[k])
									EndIf
								Next
								
								cErro := CleanStr(cErro)
							
								_MsgMotivo += cErro
							
								U_CCSGrvLog(cErro, "INV", nRecINV, 3, cFilINV)
								
								//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
								TcSqlExec("UPDATE INV010 SET MSEXP='" + DTOS(dData) + "' ,STATUS='E', MSG='" + cErro + "' WHERE REC=" + AllTrim(Str(nRecINV)) + " ")			
					
								lRet := .F.

								// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
								DisarmTransaction() 
								//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
								//

							Else
							
								/*Amarra o item do SD3 ao inventário devido ao acerto de inventário(mata340) ter sido gerado*/
								If DTOS(SD3->D3_EMISSAO) == DTOS(dDtaAux) .AND. ALLTRIM(SD3->D3_DOC) == 'INVENT' .AND. ALLTRIM(SD3->D3_COD) == ALLTRIM(cCodAux) .AND.; 
									ALLTRIM(SD3->D3_LOCAL) == ALLTRIM(cLocAux) .AND. SD3->D3_FILIAL == cFilINV
									
									RecLock("SD3", .F.)
										SD3->D3_RECORI := ALLTRIM( StrZero(nRecINV, 10) )
									SD3->( MsUnlock() ) // @history ticket   10248 - Fernando Macieira     - 03/03/2021 - Revisão das rotinas de apontamento de OP´s
								
								EndIf
				
								//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
								TcSqlExec("UPDATE INV010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='S',  MSG='' WHERE REC="+AllTrim(Str(nRecINV))+" ")

								lRet := .T.

							EndIf

						Else

							//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
							TcSqlExec("UPDATE INV010 SET D_E_L_E_T_='*' WHERE REC=" + AllTrim(Str(nRecINV)) + " AND D_E_L_E_T_=' ' ")

						EndIf
						
					EndIf
				
				//End Transaction // analiseFWNM

				MsUnLockAll() // @history ticket   10248 - Fernando Macieira     - 03/03/2021 - Revisão das rotinas de apontamento de OP´s

			EndIf
			
			//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
			INV->(DbSkip())
			
		EndDo
		
		//TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
		cFilAnt := cFilBkp
		
		INV->(DbCloseArea())
		
		//If !(IsInCallStack("U_ADORP001") .OR. IsInCallStack("U_ADEDA007R"))
		//	TcUnLink(_nTcConn1)
		//	TcUnLink(_nTcConn2)
		//EndIf
		
		RestArea(_aArea)

		MsUnLockAll() 

Return lRet

/*/{Protheus.doc} static Function nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 03/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA002G(nRec, nQuant, cOP, nOpc, cData)

	Local _aArea    := GetArea()
	Local _lRet     := .F.
	Local cProd		:= GetMv("MV_XPRDFV",.F.,"") // 300042
	Local cTPMov	:= GetMv("MV_XTMFV",.F.,"")
	Local cLoc		:= RetFldProd(cProd,"B1_LOCPAD")   // 26
	Local dData		:= DDATABASE
	Local cError  := ""
	Local k

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

	Default nRec	:= 0
	Default nQuant 	:= 0
	Default cOP		:= ""
	Default nOpc	:= 3
	Default cData	:= ""

	//Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADEDA007R como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADEDA007R*/

    // @history ticket 11639 - Fernando Macieira - 27/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
 	If Upper(AllTrim(cPrd3)) == "T" // Produção de terceiro NUNCA DEVE GERAR O MOVIMENTO DE FRANGO VIVO 300042
		_lRet := .t.
		Return _lRet
    EndIf
   //
    
    //backup da filial corrente
    cFilBck 	:= cFilAnt                        
    DDATABASE 	:= stod((cAliasOPR)->DATA)
    
    aCampos:={}
    
    //TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
    
    If EMPTY(ALLTRIM(cProd)) .OR. EMPTY(ALLTRIM(cTPMov))

        //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
        cErro := "OPR/MOV - Produto ou Tipo de Movimentação vazia nos parâmetros MV_XPRDFV/MV_XTMFV cadastrados no Protheus "
        TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRec))+" AND OPERACAO='I' ")
        
        // @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s
        DisarmTransaction() 
        //Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
        //
        
        Return .F.

    EndIf
    
    dbSelectArea("SB1")
    dbSetOrder(1)  // B1_FILIAL+B1_COD
    dbSeek(xFilial("SB1") + cProd)
    If Eof()

        //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
        cErro := "OPR/MOV - Produto nao cadastrado no Protheus " + cProd
        TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRec))+" AND OPERACAO='I' ")

        // @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s
        DisarmTransaction() 
        //Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
        //

        Return .F.

    EndIf
    
    //TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
    
    AADD(aCampos, {"D3_FILIAL"	,cFilAnt		 		, Nil})
    AADD(aCampos, {"D3_TM"		,cTPMov			 		, Nil})
    AADD(aCampos, {"D3_COD"		,cProd					, Nil})
    AADD(aCampos, {"D3_QUANT"	,nQuant					, Nil})
    AADD(aCampos, {"D3_LOCAL"	,cLoc					, Nil})
    AADD(aCampos, {"D3_EMISSAO"	,STOD(cData)			, Nil})
    
    If nOpc == 5

        dbSelectArea("SD3")
        SD3->(DbOrderNickName("RECORI"))
        If SD3->( dbSeek( cFilAnt + ALLTRIM(StrZero(nRec,10)) + PADR(cProd, TamSX3("D3_COD")[1]) + PADR(cTPMov, TamSX3("D3_TM")[1]) ) )
        
            While SD3->D3_RECORI == ALLTRIM(StrZero(nRec,10)) .AND. SD3->D3_ESTORNO == "S"
                SD3->(DbSkip())
            EndDo
        
            If SD3->D3_RECORI <> ALLTRIM(StrZero(nRec, 10))
                Return .T.
            EndIf
            aCampos[Len(aCampos)][2] := SD3->D3_EMISSAO
//	        AADD(aCampos, {"D3_EMISSAO"	, SD3->D3_EMISSAO		, Nil})
            AADD(aCampos, {"D3_DOC"		, SD3->D3_DOC			, Nil})
            AADD(aCampos, {"D3_NUMSEQ"	, SD3->D3_NUMSEQ		, Nil})			

        EndIf        

    EndIf
		
//	AADD(aCampos, {"D3_CC"		,'5131'					, Nil}) // ESTÁ FIXO MAIS PRECISARÁ SER REVISTO...VERIFICAR
//	AADD(aCampos, {"D3_OP"  	,cOp					, Nil})
    AADD(aCampos, {"D3_RECORI"  ,StrZero(nRec,10)		, Nil}) // setado como caracter pois indices numericos sao problematicos no banco
    AADD(aCampos, {"INDEX"     	, 4        				, Nil})
    
    cError += " PRODUTO = " + ALLTRIM(cProd) + "; TM = " + ALLTRIM(cTPMov) + "; RECORI = " + ALLTRIM(StrZero(nRec,10)) + "; EMISSAO = " + ALLTRIM( DTOC( STOD(cData) ) ) + "; "
    
    // o Mata240 nao executa um criasb2 e se isso nao for feito a interface vai gerar um log
    dbSelectArea("SB1")
    dbSetOrder(1)
    dbSeek(xFilial("SB1") + cProd)
    If Eof()
        // Deixa dar log na interface de que nao existe o produto para o armazem
    Else
        // se existir o produto, crio ele no armazem do movimento com saldo zero
        dbSelectArea("SB2")
        dbSetOrder(1)
        If !dbSeek(cFilAnt + PADR(cProd,TAMSX3("B1_COD")[1])+cLoc)
            CriaSb2(cProd,cLoc)
        EndIf
    EndIf
    
    lMsErroAuto := .F.
    
    SF5->( dbSetOrder(1) )
    SF5->( dbSeek( xFilial("SF5") + cTPMov ) )

    // Begin Transaction // inibido pois já está dentro de um begin // @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s
        //MSExecAuto({|x,y| MATA240(x,y)}, aCampos, nOpc)
        MsAguarde({|| MSExecAuto({|x,y| MATA240(x,y)}, aCampos, nOpc) },"Execauto MATA240","Movimentações... " + cTPMov + " " + cProd )
        If lMsErroAuto
            aErroLog:=GetAutoGrLog()
            cErro := Alltrim(aErrolog[1])
            For k := 1 to Len(aErroLog)
                If "INVALIDO" $ UPPER (aErroLog[k])
                    cErro+= Alltrim(aErroLog[k]) //+ Chr(13)+Chr(10)
                EndIf
            Next
            
            cErro := CleanStr(cErro)
            
            _MsgMotivo += "Erro no " + IIF(nOpc == 3, "Cadastro", "Estorno") + " da Movimentação " + cError + CHR(13) + CHR(10)
            _MsgMotivo += "Mensagem de ErrorLog Protheus : " + cErro
            
            U_CCSGrvLog(cErro, "OPR", nRec, 3, cFilAnt, .T.)
            
            //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
            
            If nOpc <> 5				
                TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRec))+" ")
            EndIf

            // @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s
            DisarmTransaction() 
            //Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
            //

        Else
    //		TcSetConn(_nTcConn2)
    //		TcSqlExec("UPDATE MOV010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='S' WHERE REC="+AllTrim(Str(nRecMOV))+" ")
            _lRet := .T.
        EndIf
    
    //End Transaction
    
    //TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
        
    //restaura filial corrente
    cFilAnt := cFilBck  
    DDATABASE := dData
        
    RestArea(_aArea)

    MsUnLockAll() 								// @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s

Return _lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ADEDA002PF   ºAutor  ³Leonardo Rios   º Data ³  01/21/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estorno de movimentação de uma produção				      º±±
±±º          ³ ExecAuto                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADEDA002P                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ADEDA002PF(nRec)

	Local _aArea    := GetArea()
	Local lRet		:= .F.
	Local k

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

	Default nRec := 0
	//Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADEDA007R como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADEDA007R*/

		cRecMov := StrZero(nRec,10) // foi setado como caracter pois indices numericos dao problema no protheus

		cFilMov := cFilAnt
		
		//TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
		
		dbSelectArea("SD3")
		SD3->(DbOrderNickName("RECORI"))
		SD3->(dbSeek(cFilMov+cRecMov))
		If !Eof()
		
			aCampos:={}
			AADD(aCampos, {"D3_FILIAL"	,SD3->D3_FILIAL		, Nil})
			AADD(aCampos, {"D3_TM"		,SD3->D3_TM			, Nil})
			AADD(aCampos, {"D3_COD"		,SD3->D3_COD		, Nil})
			AADD(aCampos, {"D3_QUANT"	,SD3->D3_QUANT 		, Nil})
			AADD(aCampos, {"D3_LOCAL"	,SD3->D3_LOCAL 		, Nil})
			AADD(aCampos, {"D3_RECORI"  ,SD3->D3_RECORI 	, Nil}) // setado como caracter pois indices numericos sao problematicos no banco
			
			lMsErroAuto:=.F.
			//Begin Transaction // já está dentro de um begin 
			//MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5)
			MsAguarde({|| MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 3) },"Execauto MATA240","Incluindo movimentação... " + SD3->D3_COD + " " + SD3->D3_RECORI ) 

			If lMsErroAuto
				aErroLog:=GetAutoGrLog()
				cErro:=Alltrim(aErrolog[1])
				For k:=1 to Len(aErroLog)
					If "INVALIDO" $ UPPER (aErroLog[k])
						cErro+= Alltrim(aErroLog[k]) //+ Chr(13)+Chr(10)
					EndIf
				Next
				cErro := CleanStr(cErro)
						
				_MsgMotivo += cErro
				
				U_CCSGrvLog(cErro, "OPR", nRec, 5, cFilMOV, .T.)
				
	//			TcSetConn(_nTcConn2)
	//			TcSqlExec("UPDATE MOV010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRecMOV))+" ")

				// @history ticket 10248 - Fernando Macieira - 03/03/2021 - Revisão das rotinas de apontamento de OP´s
				DisarmTransaction() 
				//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
				//

			Else

				//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
				TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='S' WHERE REC="+AllTrim(Str(nRec))+" ")
				lRet := .T.

			EndIF
			
			//End Transaction

		Else
			
			cErro := "HELP: Requisição de MP nao Encontrada para ser Cancelada."
			U_CCSGrvLog(cErro, "OPR", nRec, 5, cFilMOV, .T.)
			
			//TcSetConn(_nTcConn2) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
			TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='"+cErro+ "' WHERE REC="+AllTrim(Str(nRec))+" ")
			lRet := .T.

		EndIf

	RestArea(_aArea)

	cFilAnt := cFilBkp

Return lRet







/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CleanStr  ºAutor  ³Microsiga           º Data ³  01/21/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para limpar a string retornada de um erro no        º±±
±±º          ³ ExecAuto                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADEDA002P                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CleanStr(cErro)

Local nCnt
            
Default cErro := ""

	cErro := StrTran(cErro, Chr(13)+Chr(10), "")
	
 	For nCnt:=9 To 2 STEP -1
   		cErro := StrTran(cErro, SPACE(nCnt), " ")
	Next nCnt

Return cErro

/*
|___________________________________________________________________________________________________________________________________|
|   ºPrograma  	 ADEDA002PG		ºAutor  ³Leonardo Rios														ºData   ³18/01/2018		|
|___________________________________________________________________________________________________________________________________|
|   ºAlteração  ºAutor  ³#####																				ºData   ³//     		|
|				ºMotivo	³ DESCRIÇÃO																								    |
|___________________________________________________________________________________________________________________________________|
|	ºDescricao 	³ Verifica se o item possui saldo no SBF comparando com o SD4 e retorna True se tiver saldo ou False se não tiver	|
|___________________________________________________________________________________________________________________________________|
|	ºParâmetros	³ aParam[1]  :[C] cProduto  - Código do produto analisado se possui controle de localização e se possui saldo		|
|				³ aParam[2]  :[C] cFilial   - Filial que será analisado o produto													|
|				³ aParam[3]  :[N] nQuant	- Quantidade que será efetuado no apontamento para ver se existe saldo para isto		|
|___________________________________________________________________________________________________________________________________|
|	ºRetorno    ³ lRet		 :[L] - Indicará se irá permitir(TRUE) efetuar o apontamento do item caso tenha controle de localização	|
|___________________________________________________________________________________________________________________________________|
|	ºUso       	³ ADEDA002P - Funções para processamento da tela de integração do EDATA x Protheus									|
|			   	³ Módulo Estoque/Custos (04)																						|
|			   	³ Projeto de Integração Protheus x EDATA																			|
|			   	³ ADORO - Protheus 12																								|
|				³ Integração Protheus x EDATA		                          		  												|
|___________________________________________________________________________________________________________________________________|
*/
/*/
	{Protheus.doc} ADEDA002PG
	Descriação

	@type  Static  Function

	@author Leonardo Rios

	@since 16/10/2017

	@version version 1.0

	@param cProduto, String, Código do produto que será analisaso se possui controle de localização e se possui saldo
	@param cFilial, String, Filial que será analisado o produto
	@param nQuant, Numérico, Quantidade que será efetuado no apontamento para ver se existe saldo para isto

	@return lRet, Lógico, Indicará se irá permitir(TRUE) efetuar o apontamento do item caso tenha controle de localização

/*/
Static Function ADEDA002PG(cProduto, nQuant)

	Local aArea		:= GetArea()
	Local aItemEstru:= {}

	Local cErro		:= ""
	Local cEnd 		:= GetMv('MV_X_ENPRO',.F.,"PRODUCAO")
	Local cAlEst  	:= GetMv('MV_X_ALPRO',.F.,"03")
	Local cMensAux	:= ""
	Local cQuery	:= ''

	Local lRet    	:= .T.
	Local lSaldo	:= .T.

	Local nQnt		:= 0
	Local nSaldo    := 0
	Local nZ

	//TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA

	// @history ticket 11639 - Fernando Macieira - 27/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
	If Upper(AllTrim(cPrd3)) == "T" // Produção de terceiro
		cAlEst := cLoc3
	EndIf
	//

	// Pega os componentes da estrutura da PA no SG1 e guarda em um array para ser usado 
	dbSelectArea("SG1")
	SG1->(dbSetOrder(1)) // G1_FILIAL, G1_COD, G1_COMP, G1_TRT, R_E_C_N_O_, D_E_L_E_T_
	If SG1->(dbSeek( xFilial("SG1") + cProduto ))
		
		While SG1->(!Eof()) .and. SG1->G1_COD == cProduto
			
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + SG1->G1_COMP))
			
			If AllTrim(SB1->B1_CCCUSTO) <> ""
				SG1->(dbSkip())
				Loop
			EndIf

			AADD(aItemEstru, { SG1->G1_COMP, SG1->G1_QUANT })
			
			SG1->(dbSkip())

		EndDo

		lSaldo 	:= .T.
		cMensAux:= ""

		For nZ:= 1 to Len(aItemEstru)

			nQnt := aItemEstru[nZ][2] * nQuant
					
			dbSelectArea("SB2")
			dbSeek( xFilial("SB2") + aItemEstru[nZ][1] + cAlEst ) //TODO: DEPOIS COLOCAR EM UM PARAMETRO OU VER OUTRA FORMA EM RELACAO AO ARMAZEM

			If !Localiza(Alltrim(aItemEstru[nZ][1]))
				
				nSaldo := SaldoMov(Nil, Nil, Nil, .T., Nil, Nil, Nil, dDatabase)

				If ( nSaldo - nQnt ) < 0 //.and. GetMV("MV_ESTNEG") == "N"
					lSaldo 	:= .F.
					cMensAux+= " Não existe saldo para o componente " + ALLTRIM( aItemEstru[nZ][1] ) 		 +;
															" da PA " + ALLTRIM( cProduto ) 		 		 +;
															" ( Saldo = " + ALLTRIM( STR( nSaldo ) ) + "; "  +;
															" Quant = " + ALLTRIM( STR( nQnt ) ) + "; " +;
															CHR(13) + CHR(10)
				EndIf

			Else
				
				nSaldo := SaldoSBF( cAlEst, cEnd, aItemEstru[nZ][1] )

				//TODO: DEPOIS COLOCAR EM UM PARAMETRO OU VER OUTRA FORMA EM RELACAO AO ARMAZEM
				If ( nSaldo - nQnt ) < 0 //.and. GetMV("MV_ESTNEG") == "N"	
					lSaldo := .F.
					cMensAux+= " Não existe saldo para o componente " + ALLTRIM( aItemEstru[nZ][1] ) 		 +;
															" da PA " + ALLTRIM( cProduto ) 		 		 +;
															" ( Saldo = " + ALLTRIM( STR( nSaldo ) ) + "; "  +;
															" Quant = " + ALLTRIM( STR( nQnt ) ) + "; " +;
															CHR(13) + CHR(10)
				EndIf

			EndIf

		Next nZ

		If !lSaldo

			cErro := "Produto " + ALLTRIM(cProduto) + " possui controle de endereço e não possui saldo"
								
			_MsgMotivo += "Produto " + ALLTRIM( cProduto ) + " possui controle de endereço e não possui saldo" + CHR(13) + CHR(10)
			_MsgMotivo += "Mensagem de ErrorLog Protheus : " + ALLTRIM( cMensAux ) 		+;
															CHR(13) + CHR(10) + " " 	+;
															CHR(13) + CHR(10)
			
			U_CCSGrvLog(cErro, "OPR", nRecOPR, 3, cFilAnt, .T.)
			
			//TcSetConn(_nTcConn2)      // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
			
			TcSqlExec("UPDATE OPR010 SET MSEXP='" +DTOS(DDATABASE) + "' ,STATUS='E', MSG='" + cErro + "' WHERE REC="+AllTrim(Str(nRecOPR))+" ")

			//TcSetConn(_nTcConn1) // @history ticket   12048 - Fernando Macieira     - 07/04/2021 - Revisão das integrações e geração das OPS - Banco DBINTEREDATA
			
			lRet := .F.
		
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 09/12/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function PutSBFSB2()
	
	Local cSql := ""

	cSql := " UPDATE " + RetSqlName("SBF") + " SET BF_QUANT=B2_QATU
	cSql += " FROM " + RetSqlName("SBF") + " SBF
	cSql += " INNER JOIN " + RetSqlName("SB2") + " SB2 ON B2_FILIAL=BF_FILIAL AND B2_COD=BF_PRODUTO AND B2_LOCAL=BF_LOCAL AND SB2.D_E_L_E_T_=''
	cSql += " WHERE BF_FILIAL='"+FWxFilial("SBF")+"' 
	cSql += " AND BF_LOCAL BETWEEN '' AND 'ZZ'
	cSql += " AND BF_LOCALIZ='PROD'
	cSql += " AND BF_QUANT<>B2_QATU
	cSql += " AND SBF.D_E_L_E_T_=''
	
	tcSqlExec( cSql )

Return

/*/{Protheus.doc} Static Function FixSalsicha()
	Na estrutura do item 193229 - Salsicha temos alguns itens que são Produtos Acabados da Adoro, como por exemplo: 113075 CMS,  395565 Retalho p/ industrialização e outros itens que podem eventualmente ser utilizados, nesse caso precisamos entender que estes itens que são PA da Adoro já foram produzidos e enviados p/ terceiros, NÃO SENDO NECESSÁRIO CRIAR uma ordem de produção para os itens intermediários. 
	@type  Static Function
	@author user
	@since 01/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 65585 - Fernando Macieira - 01/02/2022 - Processamento OP - Edata p/ Protheus - Item Salsicha 193229
/*/
Static Function FixSalsicha(cChaveOP)

	Local aArea     := {}
	Local aAreaSD4  := {}
	Local aAreaSC2  := {}
	Local cQuery    := ""
	Local cOPSD4    := ""
	Local cNumOP 	:= Left(AllTrim(cChaveOP),6)
	Local cSequenOP	:= Right(AllTrim(cChaveOP),3)

	Local cSalsicha := GetMV("MV_#EDASAL",,"193229")
	Local lSalsicha := .f.
	
	lSalsicha := AllTrim(cSalsicha) $ AllTRim(SC2->C2_PRODUTO)

	If lSalsicha
	
		aArea     := GetArea()
		aAreaSD4  := SD4->( GetArea() )
		aAreaSC2  := SC2->( GetArea() )

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf

		cQuery := " SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_SEQPAI
		cQuery += " FROM " + RetSqlName("SC2") + " (NOLOCK)
		cQuery += " WHERE C2_FILIAL='"+FWxFilial("SC2")+"'
		cQuery += " AND C2_NUM='"+cNumOP+"'
		cQuery += " AND C2_SEQUEN<>'"+cSequenOP+"'
		cQuery += " AND C2_SEQPAI='"+cSequenOP+"'
		cQuery += " AND D_E_L_E_T_=''

		tcQuery cQuery New Alias "Work"

		Work->( dbGoTop() )
		Do While Work->( !EOF() )

			cOPSD4 := AllTrim(Work->(C2_NUM+C2_ITEM+C2_SEQUEN))

			SD4->( dbSetOrder(2) ) // D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, R_E_C_N_O_, D_E_L_E_T_
			If SD4->( dbSeek(FWxFilial("SD4")+cOPSD4) )
			
				Do While SD4->( !EOF() ) .and. SD4->D4_FILIAL==FWxFilial("SD4") .and. AllTrim(SD4->D4_OP) == cOPSD4

					RecLock("SD4", .F.)
						SD4->( dbDelete() )
					SD4->( msUnLock() )

					SD4->( dbSkip() )
				
				EndDo
			
			EndIf

			// Limpo D4_OPORIG
			SD4->( dbSetOrder(4) ) // D4_FILIAL, D4_OPORIG, D4_LOTECTL, D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
			If SD4->( dbSeek(FWxFilial("SD4")+cOPSD4) )
				RecLock("SD4", .F.)
					SD4->D4_OPORIG := ""
				SD4->( msUnLock() )
			EndIf

			SC2->( dbSetOrder(1) ) // C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
			If SC2->( dbSeek(FWxFilial("SC2")+cOPSD4) )
				RecLock("SC2", .F.)
					SC2->( dbDelete() )
				SC2->( msUnLock() )
			EndIf

			Work->( dbSkip() )
		
		EndDo

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf

		RestArea( aArea )
		RestArea( aAreaSD4 )
		RestArea( aAreaSC2 )
	
	EndIf

Return
