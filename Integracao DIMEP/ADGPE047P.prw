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
	@history TICKET  224    - William Costa - 11/11/2020 - Altera��o do Fonte na parte de Funcion�rios, trocar a integra��o do Protheus para a Integra��o do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history ticket  62822  - Leonardo P. Monteiro - 11/11/2021 - Reformul�rio da rotina e do grid para a Cloud.
	@history Ticket: 65853  - Adriano Savoine 		- 28/12/2021 - Corrigido o Local da variavel o mesmo estava como Priveate e fora da Static function, Declarei como Local e movi a mesma para a static function correta.
	@history Ticket: TI     - Leonardo P. Monteiro 	- 07/01/2022 - Corre��o do versionamento do fonte ADGPE047P colocado em base PLEONARDO.
	@history Ticket TI - Leonardo P. Monteiro - Fontes compilados emergencialmente 13/01/2022 11:44.
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

	Aadd( aButtons, {"Processar Campos Marcados", {|| GPE047Processa()}, "Processando...", "Processando" , {|| .T.}} ) 

	EnchoiceBar(oWnd,{||lOk:=.T.,oWnd:End()},{||oWnd:End()},,@aButtons)

	MsgRun("Criando estrutura e carregando dados no arquivo tempor�rio...",,{|| FileTRC() } )
		
	//Definindo as colunas que ser�o usadas no browse
	
	aAdd(aMark,fGetCol({"Num Estrut"    , "TMP_NUESTR","C",010,0,"@!"   }))
    aAdd(aMark,fGetCol({"Nome Estrut"   , "TMP_NMESTR","C",100,0,"@!"   }))
    aAdd(aMark,fGetCol({"CNPJ"          , "TMP_CGC"   ,"N",014,0,""		}))
    aAdd(aMark,fGetCol({"Razao Social"  , "TMP_RZSOCI","C",150,0,"@!"   }))
    

	aAdd(aIndex, "TMP_NUESTR" )
	aAdd(aIndex, "TMP_NMESTR" )
	aAdd(aIndex, "TMP_CGC" )
	aAdd(aIndex, "TMP_RZSOCI" )
	
	aAdd(aSeek,{"Num Estrut" ,{{"","C",010,0,"TMP_NUESTR","@!"            }}})
	aAdd(aSeek,{"Nome Estru" ,{{"","C",100,0,"TMP_NMESTR","@!"            }}})
	aAdd(aSeek,{"CNPJ"       ,{{"","N",014,0,"TMP_CGC"   ,""			  }}})
    aAdd(aSeek,{"Raz. Social",{{"","C",150,0,"TMP_RZSOCI","@!"            }}})

    
    

    //Criando o browse da tempor�ria
    oMarkBrw := FWBrowse():New(oWnd)
    oMarkBrw:SetDataTable(.T.)
	oMarkBrw:SetAlias("TRC")
	oMarkBrw:SetQueryIndex(aIndex)
    //oMarkBrw:SetTemporary(.T.)
    //oMarkBrw:SetSeek(.T.,aSeek) //Habilita a utiliza��o da pesquisa de registros no Browse
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
	
    //Criando a estrutura que ter� na tabela
	aAdd(aStrut, {"TMP_OK"    ,"C",002,0})
	aAdd(aStrut, {"TMP_NUESTR","C",010,0})
    aAdd(aStrut, {"TMP_NMESTR","C",100,0})
    aAdd(aStrut, {"TMP_CGC"   ,"N",014,0})
    aAdd(aStrut, {"TMP_RZSOCI","C",150,0})
    aAdd(aStrut, {"TMP_CDESTR","N",010,0})

	oArqTmp := FWTemporaryTable():New("TRC")

	oArqTmp:SetFields(aStrut)

	// Criar os �ndices.               
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

	Local aArea    := GetArea()
    Local oDlg     := NIL

	U_ADINF009P('ADGPE047' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao Protheus e Dimep Envia os Usuarios que podem ver as empresas Terceiras no DMP')
    
    DEFINE MSDIALOG oDlg FROM	18,1 TO 80,300 TITLE "GPE047Processa - Processar" PIXEL
	  
		@  1, 3 	TO 28, 140 OF oDlg  PIXEL
		
		If File("adoro.bmp")
		
			@ 3,5 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL 
			oBmp:lStretch:=.T.
			
		EndIf
		
		@ 05, 37 SAY "Processar dados?" SIZE 90, 7 OF oDlg PIXEL 
		@ 012,036 BUTTON "Processar" SIZE 035, 015 PIXEL OF oDlg ACTION (PROCESSAR(), oDlg:End())
		

	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea(aArea)
return

STATIC FUNCTION PROCESSAR()

	Local nCont  := 0
	Local nCont1 := 0

	Local cIntregou  := '' // Ticket: 65853 - Adriano Savoine - 28/12/2021.
	
    //Percorrendo os registros da TRC
    DBSELECTAREA("TRC")
	TRC->(DbSetOrder(1))
    
	TRC->(DbGoTop())
    While !TRC->(EoF())
    
        //Caso esteja marcado processa as informacoes.
        If TRC->TMP_OK == cMark
        
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
							
								INSDIM(TRC->TMP_CDESTR,TRE->CD_USUARIO) // Integra Usuario Perfil de Acesso
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
    MsgInfo('Foram Processados <b>' + cValToChar(nCont) + ' Campo(s)</b>.', "Aten��o")
     
    //Restaurando �rea armazenada
    RestArea(aArea)
	
	oMarkBrw:Refresh(.T.)
	
RETURN(.T.)


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
				   CD_ESTRUTURA_ORGANIZACIONAL 
		     FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL WITH (NOLOCK)
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
    cQuery += " FROM [DIMEP].[DMPACESSOII].[DBO].[USUARIO_SISTEMA]  WITH (NOLOCK) "
    cQuery += " WHERE DS_LOGIN LIKE '%"+cName+"%' "

	TCQUERY cQuery new alias "TRE"
             
RETURN(NIL)

STATIC FUNCTION SqlEstUsu(cEstrutura,nUser)	

	BeginSQL Alias "TRF"
			%NoPARSER%
			SELECT CD_ESTRUTURA_ORGANIZACIONAL,
			        CD_USUARIO 
		     FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORG_USUARIO_SISTEMA] AS ESTRUTURA_ORG_USUARIO_SISTEMA WITH (NOLOCK)
		    WHERE CD_ESTRUTURA_ORGANIZACIONAL = %EXP:cEstrutura%
		      AND CD_USUARIO                  = %EXP:nUser%
						
	EndSQl      
	
RETURN(NIL)

STATIC FUNCTION INSDIM(nEst,nUsers)   

	Local cQuery1 := ''
	
	cQuery1 := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[ESTRUTURA_ORG_USUARIO_SISTEMA] " + "(CD_ESTRUTURA_ORGANIZACIONAL, " + "CD_USUARIO " + ") " + "VALUES (" + " '" + CVALTOCHAR(nEst)   + "'," + " '" + CVALTOCHAR(nUsers) + "' )" 
        
    If (TCSQLExec(cQuery1) < 0)
    	cIntregou += " TCSQLError() - INSDIM: "
	EndIf        
	
RETURN(NIL)

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

			//Caso encontre um registro v�lido
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
			MsgAlert("N�o foi encontrado nenhum registro!")
			nRet	:= nAt
		endif
	else
		MsgInfo("Informe um valor v�lido!", "Pesquisa")
		//nRet	:= nAt
	endif
	oBrowse:Refresh()
return nRet
