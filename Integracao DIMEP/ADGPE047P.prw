#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
   
Static cTitulo      := "Libera Empresas Terceiras para ser visto no Dimep "

/*/{Protheus.doc} User Function ADGPE047P
	Integracao Protheus e Dimep - Envia os Usuarios que podem ver as empresas Terceiras no DMP
	@type  Function
	@author William Costa
	@since 20/03/2019
	@version version
	@history chamado 050729 - FWNM          - 26/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
/*/

User Function ADGPE047P()

	Local   oMark      := NIL
	Local   cFunNamBkp := FunName()
	Local   aSeek      := {}
    Local   aIndex     := {}
    Local   lMarcar    := .F.
    Private aMark      := {}
    Private cAliasTmp  := "TRC"
    Private cInd1      := ""
	Private cInd2      := ""
	Private cInd3      := ""
	Private cInd4      := ""
	Private aTrab      := NIL
	Private cArqs      := ""
	Private aAllUser   := FWSFALLUSERS()
	Private cIntregou  := ''
	Private lIntegra   := .T.
	Private aArea      := GetArea()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao Protheus e Dimep Envia os Usuarios que podem ver as empresas Terceiras no DMP')
	
	If Select("TRC") > 0
		TRC->(DbCloseArea())
	EndIf
	
	MsgRun("Criando estrutura e carregando dados no arquivo temporário...",,{|| aTRC := FileTRC() } )
		
	//Definindo as colunas que serão usadas no browse
	
	aAdd(aMark,{"Num Estrutura" , "TMP_NUESTR","C",010,0,"@!"            })
    aAdd(aMark,{"Nome Estrutura", "TMP_NMESTR","C",100,0,"@!"            })
    aAdd(aMark,{"CNPJ"          , "TMP_CGC"   ,"N",014,0,"99999999999999"})
    aAdd(aMark,{"Razao Social"  , "TMP_RZSOCI","C",150,0,"@!"            })
    
    SetFunName("ADGPE047P")
	
	aAdd(aIndex, "TMP_NUESTRU" )
	aAdd(aIndex, "TMP_NMESTRU" )
	aAdd(aIndex, "TMP_CGC" )
	aAdd(aIndex, "TMP_RZSOCIAL" )
	
	aAdd(aSeek,{"Num Estrutura" ,{{"","C",010,0,"TMP_NUESTR","@!"            }}})
	aAdd(aSeek,{"Nome Estrutura",{{"","C",100,0,"TMP_NMESTR","@!"            }}})
	aAdd(aSeek,{"CNPJ"          ,{{"","N",014,0,"TMP_CGC"   ,"99999999999999"}}})
    aAdd(aSeek,{"Razao Social"  ,{{"","C",150,0,"TMP_RZSOCI","@!"            }}})
	 
    //Criando o browse da temporária
    oMark := FWMarkBrowse():New()
    oMark:SetAlias(cAliasTmp)
    oMark:oBrowse:SetQueryIndex(aIndex)
    oMark:SetTemporary(.T.)
    oMark:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
    oMark:SetFields(aMark)
    oMark:DisableDetails()
    oMark:SetDescription(cTitulo)
    oMark:SetFieldMark( 'TMP_OK' )
    oMark:oBrowse:Setfocus() //Seta o foco na grade
    
    oMark:Activate()
	
	SetFunName("cFunNamBkp")
	DelTabTemporaria()
	RestArea(aArea)
	
Return Nil

Static Function MenuDef()

	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Marcar Todos'              ACTION 'u_GPE047Marcar()'    OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Desmarcar Todos'           ACTION 'u_GPE047Desmarcar()' OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Processar Campos Marcados' ACTION 'u_GPE047Processa()'  OPERATION 2 ACCESS 0
	
Return(aRot)

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

STATIC FUNCTION DelTabTemporaria()

    DbSelectArea('TRC')
    Dbclosearea('TRC')

    //FErase( GetSrvProfString("StartPath", "\undefined") + cArqs + ".DBF" )
    FErase( GetSrvProfString("StartPath", "\undefined") + cArqs + GETDBEXTENSION() ) // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 26/06/2020
    	
	FErase( GetSrvProfString("StartPath", "\undefined") + cInd1 + OrdBagExt() )
    FErase( GetSrvProfString("StartPath", "\undefined") + cInd2 + OrdBagExt() )
    FErase( GetSrvProfString("StartPath", "\undefined") + cInd3 + OrdBagExt() )
    FErase( GetSrvProfString("StartPath", "\undefined") + cInd4 + OrdBagExt() )
     
Return (NIL)

Static Function FileTRC()

	Local aStrut   := {}
	
    //Criando a estrutura que terá na tabela
    aAdd(aStrut, {"TMP_OK"    ,"C",002,0})
	aAdd(aStrut, {"TMP_NUESTR","C",010,0})
    aAdd(aStrut, {"TMP_NMESTR","C",100,0})
    aAdd(aStrut, {"TMP_CGC"   ,"N",014,0})
    aAdd(aStrut, {"TMP_RZSOCI","C",150,0})
    aAdd(aStrut, {"TMP_CDESTR","N",010,0})
     
    // Criar fisicamente o arquivo.
	cArqs := CriaTrab( aStrut, .T. )
	cInd1 := Left( cArqs, 7 ) + "1"
	cInd2 := Left( cArqs, 7 ) + "2"
	cInd3 := Left( cArqs, 7 ) + "3"
	cInd4 := Left( cArqs, 7 ) + "4"
	
	// Acessar o arquivo e coloca-lo na lista de arquivos abertos.
	dbUseArea( .T., __LocalDriver, cArqs, cAliasTmp, .F., .F. )
	
	// Criar os índices.               
	IndRegua( cAliasTmp, cInd1, "TMP_NUESTR",,,"Criando índices...")
	IndRegua( cAliasTmp, cInd2, "TMP_NMESTR",,,"Criando índices...")
	IndRegua( cAliasTmp, cInd3, "TMP_CGC"   ,,,"Criando índices...")
	IndRegua( cAliasTmp, cInd4, "TMP_RZSOCI",,,"Criando índices...")
	
	// Libera os índices.
	dbClearIndex()
	
	// Agrega a lista dos índices da tabela (arquivo).
	dbSetIndex( cInd1 + OrdBagExt() )  
	dbSetIndex( cInd2 + OrdBagExt() )
	dbSetIndex( cInd3 + OrdBagExt() )
	dbSetIndex( cInd4 + OrdBagExt() )
	
	// *** INICIO CRIAR LINHAS TABELA TEMPORARIA *** //
	SqlEstrutura()
	WHILE TRB->(!EOF())
	
		TRC->(RecLock("TRC",.T.))
		
			 TRC->TMP_OK     := ''
			 TRC->TMP_NUESTR := TRB->NU_ESTRUTURA
			 TRC->TMP_NMESTR := TRB->NM_ESTRUTURA
			 TRC->TMP_CGC    := TRB->NU_CNPJ
			 TRC->TMP_RZSOCI := TRB->DS_RAZAO_SOCIAL
			 TRC->TMP_CDESTR := TRB->CD_ESTRUTURA_ORGANIZACIONAL
			 
		TRC->(MsUnLock())
		TRB->(dbSkip())    
	
	END //end do while TRB
	TRB->( DBCLOSEAREA() ) 
	
	// *** FINAL CRIAR LINHAS TABELA TEMPORARIA *** //
	
Return({cArqs,cInd1,cInd2,cInd3,cInd4})

User Function GPE047Marcar(cMarca,lMarcar)

    Local aArea  := TRC->( GetArea() )
    Local cMarca := oMark:Mark()

	U_ADINF009P('ADGPE047' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao Protheus e Dimep Envia os Usuarios que podem ver as empresas Terceiras no DMP')
    
    dbSelectArea("TRC")
    TRC->( dbGoTop() )
    While !TRC->( Eof() )
    
        RecLock( "TRC", .F. )
        	TRC->TMP_OK := cMarca
        MsUnlock()
        
        TRC->( dbSkip() )
        
    EndDo
 
 	oMark:Refresh(.T.)
    RestArea(aArea)
    
Return(Nil)

User Function GPE047Desmarcar(cMarca,lMarcar)

    Local aArea  := TRC->( GetArea() )

	U_ADINF009P('ADGPE047' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao Protheus e Dimep Envia os Usuarios que podem ver as empresas Terceiras no DMP')
 
    dbSelectArea("TRC")
    TRC->( dbGoTop() )
    While !TRC->( Eof() )
    
        RecLock( "TRC", .F. )
        	TRC->TMP_OK := ''
        MsUnlock()
        
        TRC->( dbSkip() )
        
    EndDo
 
 	oMark:Refresh(.T.)
    RestArea(aArea)
    
Return(Nil)

User Function GPE047Processa()

	Local aArea    := GetArea()
    Local cMarca   := oMark:Mark()
    Local lInverte := oMark:IsInvert()
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
	
STATIC FUNCTION PROCESSAR()

	Local nCont  := 0
	Local nCont1 := 0
	
    //Percorrendo os registros da TRC
    DBSELECTAREA("TRC")
    TRC->(DbGoTop())
    While !TRC->(EoF())
    
        //Caso esteja marcado processa as informacoes.
        If oMark:IsMark(oMark:Mark())
        
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
    		RecLock('TRC', .F.)
    		
                TRC->TMP_OK     := ''
                
            TRC->(MsUnlock())
                
        ENDIF
         
        TRC->(DbSkip())
        
    ENDDO
	    
    //Mostrando a mensagem de registros marcados
    MsgInfo('Foram Processados <b>' + cValToChar(nCont) + ' Campo(s)</b>.', "Atenção")
     
    //Restaurando área armazenada
    RestArea(aArea)
	
	oMark:Refresh(.T.)
	
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

	BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT NU_ESTRUTURA,
			       NM_ESTRUTURA,
				   NU_CNPJ,
				   DS_RAZAO_SOCIAL,
				   CD_ESTRUTURA_ORGANIZACIONAL 
		     FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL WITH (NOLOCK)
		    WHERE CD_ESTRUTURA_RELACIONADA = 1223
						
	EndSQl      
	
RETURN(NIL)

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
