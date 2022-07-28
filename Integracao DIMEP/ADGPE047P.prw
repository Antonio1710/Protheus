#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
//#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
   
Static cTitulo      := "Libera Empresas Terceiras para ser visto no Dimep "

/*/{Protheus.doc} User Function ADGPE047P
	Integracao Protheus e Dimep - Envia os Usuarios que podem ver as empresas Terceiras no DMP
	@type  Function
	@author William Costa
	@since 20/03/2019
	@version version
	@history chamado 050729 - FWNM          - 26/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
	@history TICKET  224    - William Costa - 11/11/2020 - AlteraÁ„o do Fonte na parte de Funcion·rios, trocar a integraùùo do Protheus para a Integraùùo do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history ticket  62822  - Leonardo P. Monteiro - 11/11/2021 - Reformul·rio da rotina e do grid para a Cloud.
	@history Ticket: 65853  - Adriano Savoine 		- 28/12/2021 - Corrigido o Local da variavel o mesmo estava como Priveate e fora da Static function, Declarei como Local e movi a mesma para a static function correta.
	@history Ticket: TI     - Leonardo P. Monteiro 	- 07/01/2022 - CorreÁ„o do versionamento do fonte ADGPE047P colocado em base PLEONARDO.
	@history Ticket TI - Leonardo P. Monteiro - Fontes compilados emergencialmente 13/01/2022 11:44.
	@history Ticket 72264 - Everson - 03/05/2022. Tratamento para ativar e inativar cadastro de empresa no Dimep.
	@history Ticket  77205 - Adriano Savoine  - 27/07/2022- Alterado o Link de dados de DIMEP para DMPACESSO
/*/

User Function ADGPE047P()

	
	//Local   cFunNamBkp := FunName()
    Local aIndex     	:= {}
    Local aMark      	:= {}
    Local nAlt      	:= 0
    Local nLarg    		:= 0
    Local aSize     	:= {}
    Private oWnd
	Private aAllUser   	:= FWSFALLUSERS()
	//Private cIntregou  := ''
	//Private lIntegra   := .T.
	Private aArea      	:= GetArea()
	Private oArqTmp	
	Private oMarkBrw    := NIL
	Private bMark       := {|oBrowser| fMark(oBrowser)}
    Private bDblClk     := {|oBrowser| fDblClk(oBrowser)}
    Private bHeaClk     := {|oBrowser| fHeaClk(oBrowser)}
	Private cMark   	:= GetMark()
	Private aButtons	:= {}
	Private aSeek       := {}

	//SetFunName("ADGPE047P")
	/*
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao Protheus e Dimep Envia os Usuarios que podem ver as empresas Terceiras no DMP')
	
	If Select("TRC") > 0
		TRC->(DbCloseArea())
	EndIf
	*/

	if type("cFilAnt") == "U"
        //RpcsetType(3)
        //Rpcsetenv("01","02","LEONARDO_MONTEIRO","")
        nAlt    := GetScreenRes()[02]*0.965
        nLarg   := GetScreenRes()[01]
    else
        aSize   := MsAdvSize(.T.)
        nAlt    := aSize[06]
        nLarg   := aSize[05]
    endif

	oWnd            := Msdialog():Create()
    oWnd:cTitle     := cTitulo
    ownd:nWidth     := nLarg
    oWnd:nHeight    := nAlt
    oWnd:lMaximized := .T.

	Aadd( aButtons, {"Processar Campos Marcados", {|| MsAguarde({|| GPE047Processa()}, "Aguarde", "Processando...")  }, "Processando...", "Processar registros marcados" , {|| .T.}} ) 
	Aadd( aButtons, {"Inativar Registros", {|| MsAguarde({|| GPE047In("X")}, "Aguarde", "Processando...") }, "Processando...", "Inativar registros marcados" , {|| .T.}} ) 
	Aadd( aButtons, {"Ativar Registros"  , {|| MsAguarde({|| GPE047In("")}, "Aguarde", "Processando...") }, "Processando...", "Ativar registros marcados" , {|| .T.}} ) 

	EnchoiceBar(oWnd,{||lOk:=.T.,oWnd:End()},{||oWnd:End()},,@aButtons)

	MsgRun("Criando estrutura e carregando dados no arquivo temporùrio...",,{|| FileTRC() } )
		
	//Definindo as colunas que serùo usadas no browse
	
	aAdd(aMark,fGetCol({"Num Estrut"    , "TMP_NUESTR","C",010,0,"@!"   }))
    aAdd(aMark,fGetCol({"Nome Estrut"   , "TMP_NMESTR","C",100,0,"@!"   }))
    aAdd(aMark,fGetCol({"CNPJ"          , "TMP_CGC"   ,"N",014,0,""		}))
    aAdd(aMark,fGetCol({"Razao Social"  , "TMP_RZSOCI","C",150,0,"@!"   }))
    aAdd(aMark,fGetCol({"Inativo ?"     , "TMP_INATIV","C",003,0,"@!"   }))
    
	aAdd(aIndex, "TMP_NUESTR" )
	aAdd(aIndex, "TMP_NMESTR" )
	aAdd(aIndex, "TMP_CGC" )
	aAdd(aIndex, "TMP_RZSOCI" )
	
	aAdd(aSeek,{"Num Estrut" ,{{"","C",010,0,"TMP_NUESTR","@!"            }}})
	aAdd(aSeek,{"Nome Estru" ,{{"","C",100,0,"TMP_NMESTR","@!"            }}})
	aAdd(aSeek,{"CNPJ"       ,{{"","N",014,0,"TMP_CGC"   ,""			  }}})
    aAdd(aSeek,{"Raz. Social",{{"","C",150,0,"TMP_RZSOCI","@!"            }}})

    //Criando o browse da temporùria
    oMarkBrw := FWBrowse():New(oWnd)
    oMarkBrw:SetDataTable(.T.)
	oMarkBrw:SetAlias("TRC")
	oMarkBrw:SetQueryIndex(aIndex)
    //oMarkBrw:SetTemporary(.T.)
    //oMarkBrw:SetSeek(.T.,aSeek) //Habilita a utilizaùùo da pesquisa de registros no Browse
	oMarkBrw:setSeek({|oSeek, oBrowse| fFiltra(oSeek, oBrowse)}, aSeek)
	oMarkBrw:setLocate()
    oMarkBrw:setFieldFilter({ {"TMP_NUESTR", "Num Estrut" 	, "C", 010, 0, "@!"},;
                            {"TMP_NMESTR", "Nome Estru" 	, "C", 100, 0, "@!"},;
							{"TMP_CGC"	 , "CNPJ"			, "C", 100, 0, 	 ""},;
							{"TMP_RZSOCI", "Raz. Social"	, "C", 150, 0, "@!"};
						  })
    oMarkBrw:addMarkColumns(bMark, bDblClk, bHeaClk)
	oMarkBrw:SetColumns(aMark)
    //oMarkBrw:DisableDetails()
	//oMarkBrw:DisableReport()
    oMarkBrw:SetDescription(cTitulo)
    //oMarkBrw:SetFieldMark( 'TMP_OK' )
    oMarkBrw:SetProfileID('ADGPE047P') 
	//oMarkBrw:oBrowse:SetFilterDefault("")          
	
    oMarkBrw:Activate()
	
	oWnd:Activate()

	//SetFunName("cFunNamBkp")
	oArqTmp:Delete()
	//DelTabTemporaria()
	RestArea(aArea)
	
Return Nil

Static Function fGetCol(aCol)
	Local oColumn 	:= FWBrwColumn():New()
	
	// {"Razao Social"  , "TMP_RZSOCI","C",150,0,"@!"   }
	
	oColumn:SetTitle(aCol[01])
	oColumn:SetData(&("{|| " + aCol[02] + "}"))
	oColumn:SetType(aCol[03])
	oColumn:SetSize(aCol[04])
	oColumn:setPicture(aCol[06])
    
return oColumn

Static Function ModelDef()
	
	Local oModel    := Nil
	
	//Criando o modelo e os relacionamentos
	oModel := FWLoadModel('zAGPE047') 
	
Return(oModel)

Static Function ViewDef()
	
	Local oView			:= Nil
	
	//Criando a View
	oView := FWLoadView('zAGPE047')
	
Return(oView)

Static Function FileTRC()

	Local aStrut   := {}
	
    //Criando a estrutura que terù na tabela
	aAdd(aStrut, {"TMP_OK"     ,"C",002,0})
	aAdd(aStrut, {"TMP_NUESTR" ,"C",010,0})
    aAdd(aStrut, {"TMP_NMESTR" ,"C",100,0})
    aAdd(aStrut, {"TMP_CGC"    ,"N",014,0})
    aAdd(aStrut, {"TMP_RZSOCI" ,"C",150,0})
    aAdd(aStrut, {"TMP_CDESTR" ,"N",010,0})
    aAdd(aStrut, {"TMP_INATIV" ,"C",003,0})

	oArqTmp := FWTemporaryTable():New("TRC")

	oArqTmp:SetFields(aStrut)

	// Criar os ùndices.               
	oArqTmp:AddIndex("01", {"TMP_NUESTR"} )
	oArqTmp:AddIndex("02", {"TMP_NMESTR"} )
	oArqTmp:AddIndex("03", {"TMP_CGC"} )
	oArqTmp:AddIndex("04", {"TMP_RZSOCI"} )
	oArqTmp:AddIndex("05", {"TMP_CDESTR"} )

	oArqTmp:Create()

	// *** INICIO CRIAR LINHAS TABELA TEMPORARIA *** //
	SqlEstrutura()
	WHILE DIMEP->(!EOF())
	
		IF RecLock("TRC",.T.)
			TRC->TMP_OK     := ''
			TRC->TMP_NUESTR := Alltrim(DIMEP->NU_ESTRUTURA)
			TRC->TMP_NMESTR := Alltrim(DIMEP->NM_ESTRUTURA)
			TRC->TMP_CGC    := DIMEP->NU_CNPJ
			TRC->TMP_RZSOCI := ALLTRIM(REPLACE(REPLACE(DIMEP->DS_RAZAO_SOCIAL,CHR(13),""),CHR(10),""))
			TRC->TMP_CDESTR := DIMEP->CD_ESTRUTURA_ORGANIZACIONAL
			TRC->TMP_INATIV:= Iif(Alltrim(cValToChar(DIMEP->AD_INATIVO)) == "X", "Sim", "N„o")
			 
			TRC->(MsUnLock())
		ENDIF
		DIMEP->(dbSkip())    
	
	ENDdo //end do while DIMEP
	DIMEP->( DBCLOSEAREA() ) 
	
	// *** FINAL CRIAR LINHAS TABELA TEMPORARIA *** //
	TRC->(DbGotop())
	DbSelectArea("TRC")
Return

Static Function GPE047Processa()

	//Vari·veis
	Local aArea  := GetArea()
	Local nCont  := 0
	Local nCont1 := 0
	Local lGrv	 := .F.

	Local cIntregou  := '' // Ticket: 65853 - Adriano Savoine - 28/12/2021.

	If ! MsgYesNo("Deseja processar os registros marcados?")
		RestArea(aArea)
		Return Nil

	EndIf
	
    //Percorrendo os registros da TRC
    DBSELECTAREA("TRC")
	TRC->(DbSetOrder(1))
    
	TRC->(DbGoTop())
    While !TRC->(EoF())
    
        //Caso esteja marcado processa as informacoes.
        If TRC->TMP_OK == cMark .And. TRC->TMP_INATIV == "N„o"
        
        	nCont:= nCont + 1
        	
        	// *** INICIO LIBERA PERFIL DE ACESSO PARA OUTROS USUARIOS *** // 
			SqlUsuProtheus()
			While TRD->(!EOF())
			
				For nCont1 :=1 to Len(aAllUser)
			
					IF aAllUser[nCont1][2] == TRD->ZFG_CODUSR
					 
						SqlUsuDimep(aAllUser[nCont1][3])
						While TRE->(!EOF())
						
							lIntegra := .T.
						    SqlEstUsu(TRC->TMP_CDESTR,TRE->CD_USUARIO)	

							IF TRF->(!EOF())
						
								lIntegra   := .F.
								
							ENDIF
							TRF->(dbCloseArea())
							
							IF lIntegra == .T.
							
								lGrv := INSDIM(TRC->TMP_CDESTR,TRE->CD_USUARIO) // Integra Usuario Perfil de Acesso
								GERALOG(FWFILIAL("SRA"),aAllUser[nCont1][3] + '||' + CVALTOCHAR(TRC->TMP_CDESTR)  + '||' + CVALTOCHAR(TRE->CD_USUARIO) , 'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))

							ENDIF
							TRE->(dbSkip())
					    ENDDO
					    TRE->(dbCloseArea())
					ENDIF
				NEXT nCont1
			
				TRD->(dbSkip())
									
		    ENDDO
		    TRD->(dbCloseArea())
			// *** FINAL LIBERA PERFIL DE ACESSO PARA OUTROS USUARIOS *** //
        	
        	//Limpando a marca
    		RecLock("TRC", .F.)
    		
                TRC->TMP_OK     := ''
                
            TRC->(MsUnlock())
                
        ENDIF
         
        TRC->(DbSkip())
        
    ENDDO
	    
    //Mostrando a mensagem de registros marcados
    MsgInfo('Foram Processados ' + cValToChar(nCont) + ' registros.', "FunÁ„o PROCESSAR")
     
    //Restaurando ùrea armazenada
    RestArea(aArea)
	
	oMarkBrw:Refresh(.T.)
	
RETURN(.T.)
/*/{Protheus.doc} GPE047In
	Marca registro no Dimep como inativo/ativo.
	@type  Static Function
	@author Everson
	@since 03/05/2022
	@version 01
/*/
Static Function GPE047In(cFlag)

	//Vari·veis.
	Local aArea  := GetArea()
	Local nCount := 0
	Local cTxt   := Iif(cFlag == "X", "Sim", "N„o")

	If ! MsgYesNo("Deseja " + Iif(Empty(cFlag), "ativar", "inativar") + " os registros marcados?")
		RestArea(aArea)
		Return Nil

	EndIf

	DbSelectArea("TRC")
	TRC->(DbSetOrder(1))
    
	TRC->(DbGoTop())
    While ! TRC->(EoF())

		If TRC->TMP_OK == cMark .And. cTxt <> TRC->TMP_INATIV

			If TCSQLExec("UPDATE [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] SET AD_INATIVO = '" + cFlag + "' WHERE CD_ESTRUTURA_ORGANIZACIONAL = '" + Alltrim(cValToChar(TRC->TMP_CDESTR)) + "'  AND NU_ESTRUTURA = '" + Alltrim(cValToChar(TRC->TMP_NUESTR)) + "' AND CD_ESTRUTURA_RELACIONADA = 1223") < 0
				MsgInfo("Ocorreu erro na atualizaÁ„o do registro " + Alltrim(cValToChar(TRC->TMP_CDESTR)) + " " + Alltrim(cValToChar(TRC->TMP_NMESTR)) + ". O processo ser· interrompido." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + TCSQLError(), "FunÁ„o GPE047In(ADGPE047P)")
				Exit

			Else

				RecLock("TRC", .F.)
					TRC->TMP_OK     := ""
					TRC->TMP_INATIV := cTxt
				TRC->(MsUnlock())

				nCount++

				If cFlag == "X" .And. TCSQLExec("DELETE FROM [DMPACESSO].[DMPACESSOII].[dbo].[ESTRUTURA_ORG_USUARIO_SISTEMA] WHERE CD_ESTRUTURA_ORGANIZACIONAL = '" + Alltrim(cValToChar(TRC->TMP_CDESTR)) + "'") < 0
					MsgInfo("Ocorreu erro no processo para desvincular usu·rios da estrutura " + Alltrim(cValToChar(TRC->TMP_CDESTR)) + " " + Alltrim(cValToChar(TRC->TMP_NMESTR)) + ". O processo ser· interrompido." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + TCSQLError(), "FunÁ„o GPE047In(ADGPE047P)")
					Exit

				EndIf

			EndIf

		EndIf

		TRC->(DbSkip())

	End

	TRC->(DbGoTop())

	RestArea(aArea)
	
	oMarkBrw:Refresh(.T.)

	MsgInfo("Foram processados " + cValToChar(nCount) + " registros.", "FunÁ„o GPE047In(ADGPE047P)")

Return Nil

STATIC FUNCTION GERALOG(cFil,cTexto,cParam)

	DbSelectArea("ZBE")
		Reclock("ZBE",.T.)
			ZBE->ZBE_FILIAL	:= cFil
			ZBE->ZBE_DATA 	:= Date()
			ZBE->ZBE_HORA 	:= cValToChar(Time())
			ZBE->ZBE_USUARI := cUserName
			ZBE->ZBE_LOG 	:= cTexto
			ZBE->ZBE_MODULO := "SIGAGPE"
			ZBE->ZBE_ROTINA := "ADGPE047P"
			ZBE->ZBE_PARAME := cParam
		MsUnlock()
	ZBE->(DbCloseArea())
	
RETURN(NIL)


STATIC FUNCTION SqlEstrutura()	

	BeginSQL Alias "DIMEP"
			%NoPARSER%
			SELECT NU_ESTRUTURA,
			       NM_ESTRUTURA,
				   NU_CNPJ,
				   DS_RAZAO_SOCIAL,
				   CD_ESTRUTURA_ORGANIZACIONAL,
				   AD_INATIVO
		     FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL WITH (NOLOCK)
		    WHERE CD_ESTRUTURA_RELACIONADA = 1223
						
	EndSQl      
	
RETURN

Static Function SqlUsuProtheus()

    BeginSQL Alias "TRD"
			%NoPARSER%  
			SELECT ZFG_CODUSR,
			       ZFG_PERFIL,
				   ZFG_EMPRES
			  FROM ZFG010 WITH (NOLOCK)
			 WHERE ZFG_EMPRES = 'T'
			   AND D_E_L_E_T_ <> '*'
		
 	EndSQl    
             
RETURN(NIL)  

Static Function SqlUsuDimep(cName)

	Local cQuery := ''

    cQuery := " SELECT CD_USUARIO,DS_LOGIN,DS_NOME   "
    cQuery += " FROM [DMPACESSO].[DMPACESSOII].[DBO].[USUARIO_SISTEMA]  WITH (NOLOCK) "
    cQuery += " WHERE DS_LOGIN LIKE '%"+cName+"%' "

	TCQUERY cQuery new alias "TRE"
             
RETURN(NIL)

STATIC FUNCTION SqlEstUsu(cEstrutura,nUser)	

	BeginSQL Alias "TRF"
			%NoPARSER%
			SELECT CD_ESTRUTURA_ORGANIZACIONAL,
			        CD_USUARIO 
		     FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORG_USUARIO_SISTEMA] AS ESTRUTURA_ORG_USUARIO_SISTEMA WITH (NOLOCK)
		    WHERE CD_ESTRUTURA_ORGANIZACIONAL = %EXP:cEstrutura%
		      AND CD_USUARIO                  = %EXP:nUser%
						
	EndSQl      
	
RETURN(NIL)

STATIC FUNCTION INSDIM(nEst,nUsers)   

	Local cQuery1 := ''
	Local lRet    := .T.
	
	cQuery1 := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[ESTRUTURA_ORG_USUARIO_SISTEMA] " + "(CD_ESTRUTURA_ORGANIZACIONAL, " + "CD_USUARIO " + ") " + "VALUES (" + " '" + CVALTOCHAR(nEst)   + "'," + " '" + CVALTOCHAR(nUsers) + "' )" 
        
    If (TCSQLExec(cQuery1) < 0)
		lRet := .F.
    	cIntregou += " TCSQLError() - INSDIM: "
		MsgInfo("Ocorreu erro na criaÁ„o do registro " + Alltrim(cValToChar(nEst)) + " " + Alltrim(cValToChar(nUsers)) + "." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + TCSQLError(), "FunÁ„o INSDIM(ADGPE047P)")
	
	EndIf        
	
RETURN lRet

Static Function fMark(oBrowse)
    Local cRet := "LBNO"

	cRet := iif(Empty(TRC->TMP_OK), 'LBNO', 'LBOK')

return cRet

Static Function fDblClk(oBrowse)
    Local lRet      := .T.
    
    if Empty(TRC->TMP_OK)
			TRC->TMP_OK := cMark
	else
		TRC->TMP_OK := ''
	endif
	
return lRet


Static Function fHeaClk(oBrowse)
    Local lRet 		:= .T.
	Local aAreaTRC	:= TRC->(GetArea())

	TRC->(dbgotop())

	While TRC->(!EOF())
		fDblClk(oBrowse)

		TRC->(DbSkip())
	enddo

	RestArea(aAreaTRC)
	oBrowse:refresh()
return lRet


static function fFiltra(oSeek, oBrowse)
	Local nRet		:= 0
	Local nAt		:= oBrowse:At()
	Local lEOF		:= .F.
	Local nPosAtu	:= 0
	Local cFiltro	:= Alltrim(oSeek:getSeek())
	Local nFiltro	:= Len(cFiltro)
    Local nOrder	:= oSeek:getOrder()
	Local cCampo	:= aSeek[nOrder][2][1][5]

	if !Empty(cFiltro)
		
		oBrowse:gotop()

		while !lEOF .and. nRet == 0
			if nOrder == 1
				uValor := Alltrim(cValtochar(&("TRC->"+Alltrim(cCampo))))
			else
				uValor := Left(Alltrim(cValtochar(&("TRC->"+Alltrim(cCampo)))),nFiltro)
			endif

			//Caso encontre um registro vùlido
			if  uValor == cFiltro
				nRet := oBrowse:at()
			// Caso seja o final do arquivo
			elseif nPosAtu == oBrowse:at()
				lEOF := .T.
			else
				nPosAtu := oBrowse:at()
				oBrowse:GoDown()
			endif
				
				
		enddo

		if nRet == 0
			MsgAlert("Nùo foi encontrado nenhum registro!")
			nRet	:= nAt
		endif
	else
		MsgInfo("Informe um valor vùlido!", "Pesquisa")
		//nRet	:= nAt
	endif
	oBrowse:Refresh()
return nRet
