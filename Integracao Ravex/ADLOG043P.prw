#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH"  

/*{Protheus.doc} User Function ADLOG043P
	Programa consumir de webservice ravex para Integrar Cliente Completo 
	@type  Function
	@author WILLIAM COSTA
	@since 22/11/2018
	@version 01
	@history Chamado 046860 - WILLIAM COSTA - 13/02/2019 - ALTERA PARA NAO TER MAIS ENTREGA  
	@history Chamado 058323 - WILLIAM COSTA - 20/05/2020 - Adicionado no NOACENTO o Apostofro para retirar '
	@history Chamado T.I    - WILLIAM COSTA - 16/07/2020 - Adicionado o campo Cnegocio após solicitação da Ravex

*/

User Function ADLOG043P(cCliente,cLoja)

	PRIVATE oWsCli  := NIL
	PRIVATE oResp   := NIL 
    PRIVATE cMetodo := ''
    PRIVATE nId     := 0 
    PRIVATE aCli    := {}
    
	ConOut("INICIO ADLOG043P " + ALLTRIM(FUNNAME()) + ' ' + TIME())

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa consumir de webservice ravex para Integrar Cliente Completo')

    CRIAWEBSERVICE(cCliente,cLoja)
    
	ConOut("FINAL ADLOG043P " + ALLTRIM(FUNNAME()) + ' ' + TIME())
   
RETURN(aCli)

STATIC FUNCTION CRIAWEBSERVICE(cCliente,cLoja)

	DelClassIntF() // COMANDO PARA LIMPAR A MEMORIA WILLIAM COSTA CHAMADO 041161 || ADM.LOG || DIEGO || INTEGRACAO RAVEX 02/05/2018
	
	oWsCli := WSsivirafullWebService():New()

	oWsCli:cLogin := 'adoro_user_ws'
	oWsCli:cSenha := 'SdUdWSdA'
	 
	ExportaXML(cCliente,cLoja)  
	
RETURN(aCli)

Static Function ExportaXML(cCliente,cLoja)

	Local nCont := 0

	SqlClientes(cCliente,cLoja)
	While TRE->(!EOF())
	
		oWsCli:oWSCliente:cCodigo                                  := ALLTRIM(TRE->A1_COD + TRE->A1_LOJA)  
		oWsCli:oWSCliente:cTipoPessoa                              := ALLTRIM(TRE->A1_PESSOA) 
		oWsCli:oWSCliente:cCNPJCPF                                 := ALLTRIM(TRE->A1_CGC)
		oWsCli:oWSCliente:cRGInscricao                             := ''
		oWsCli:oWSCliente:cNome                                    := NOACENTO2(ALLTRIM(TRE->A1_NOME))
		oWsCli:oWSCliente:cRazaoSocial                             := NOACENTO2(ALLTRIM(TRE->A1_NREDUZ))
		oWsCli:oWSCliente:cTelefone                                := ALLTRIM(TRE->A1_DDD+TRE->A1_TEL)
		oWsCli:oWSCliente:cEmail                                   := ALLTRIM(TRE->A1_EMAIL)
		oWsCli:oWSCliente:cResponsavel                             := ''
		oWsCli:oWSCliente:cEndereco                                := NOACENTO2(ALLTRIM(TRE->A1_ENDENT))
		oWsCli:oWSCliente:cComplemento                             := NOACENTO2(ALLTRIM(TRE->A1_COMPLEM))
		oWsCli:oWSCliente:cBairro                                  := NOACENTO2(ALLTRIM(TRE->A1_BAIRROE))
		oWsCli:oWSCliente:cCidade                                  := NOACENTO2(ALLTRIM(TRE->A1_MUNE))
		oWsCli:oWSCliente:cEstado                                  := NOACENTO2(ALLTRIM(TRE->A1_ESTE))
		oWsCli:oWSCliente:cPais                                    := NOACENTO2(ALLTRIM(TRE->A1_PAIS))
		oWsCli:oWSCliente:cCep                                     := ALLTRIM(TRE->A1_CEPE)
		oWsCli:oWSCliente:nLatitude                                := VAL(STRTRAN(TRE->A1_XLATITU,',','.'))
		oWsCli:oWSCliente:nLongitude                               := VAL(STRTRAN(TRE->A1_XLONGIT,',','.'))
		oWsCli:oWSCliente:nRaioEntrega                             := 0 
		oWsCli:oWSCliente:nTempoEntrega                            := 0
		oWsCli:oWSCliente:cRegiao                                  := ALLTRIM(TRE->A1_REGIAO) 
		oWsCli:oWSCliente:cPreRota                                 := ''    
		oWsCli:oWSCliente:cNegocio                                 := Posicione("SX5",1,cFilAnt+"_S"+TRE->A1_SATIV1,"X5_DESCRI")
		oWsCli:oWSCliente:cCodigoTabelaFrete                       := ''  
		oWsCli:oWSCliente:oWSGradeAtendimento                      := sivirafullWebService_JanelaAtendimento():New()
		oWsCli:oWSCliente:oWSGradeAtendimento:CCODIGO              := ALLTRIM(TRE->A1_COD + TRE->A1_LOJA)
		oWsCli:oWSCliente:oWSGradeAtendimento:CNOME                := NOACENTO2(ALLTRIM(TRE->A1_NOME))
		oWsCli:oWSCliente:oWSGradeAtendimento:CREGIONALVENDA       := ''
		oWsCli:oWSCliente:oWSGradeAtendimento:CUNIDADE             := ''
		oWsCli:oWSCliente:oWSGradeAtendimento:OWSATENDIMENTODIARIO := sivirafullWebService_ArrayOfGradeDiaria():New()
		
		FOR nCont:=1 TO 7
		
			cHoraIni                        := Substr(DTOS(DATE()),1,4)+ '-' + Substr(DTOS(DATE()),5,2)+ '-' + Substr(DTOS(DATE()),7,2) +  "T" + IIF(EMPTY(TRE->A1_HRINIM), '00:00', TRE->A1_HRINIM) + ':00'
			cHoraFin                        := Substr(DTOS(DATE()),1,4)+ '-' + Substr(DTOS(DATE()),5,2)+ '-' + Substr(DTOS(DATE()),7,2) +  "T" + IIF(EMPTY(TRE->A1_HRFINM), '23:59', TRE->A1_HRFINM) + ':00'
			oWSGradeDiaria                  := NIL
			oWSGradeDiaria                  := sivirafullWebService_GradeDiaria():New()
			oWSGradeDiaria:NDIASEMANA       := nCont
			oWSGradeDiaria:CTIPOATENDIMENTO := ''
			oWSGradeDiaria:NPERIODO         := 0
			oWSGradeDiaria:CINICIO          := cHoraIni
			oWSGradeDiaria:CTERMINO         := cHoraFin
			
			AADD(oWsCli:oWSCliente:oWSGradeAtendimento:OWSATENDIMENTODIARIO:oWSGradeDiaria,oWSGradeDiaria)
			
			cHoraIni                        := Substr(DTOS(DATE()),1,4)+ '-' + Substr(DTOS(DATE()),5,2)+ '-' + Substr(DTOS(DATE()),7,2) +  "T" + IIF(EMPTY(TRE->A1_HRINIT), '00:00', TRE->A1_HRINIT) + ':00'
			cHoraFin                        := Substr(DTOS(DATE()),1,4)+ '-' + Substr(DTOS(DATE()),5,2)+ '-' + Substr(DTOS(DATE()),7,2) +  "T" + IIF(EMPTY(TRE->A1_HRFINT), '23:59', TRE->A1_HRFINT) + ':00'
			oWSGradeDiaria                  := NIL
			oWSGradeDiaria                  := sivirafullWebService_GradeDiaria():New()
			oWSGradeDiaria:NDIASEMANA       := nCont
			oWSGradeDiaria:CTIPOATENDIMENTO := ''
			oWSGradeDiaria:NPERIODO         := 1
			oWSGradeDiaria:CINICIO          := cHoraIni
			oWSGradeDiaria:CTERMINO         := cHoraFin
		
			AADD(oWsCli:oWSCliente:oWSGradeAtendimento:OWSATENDIMENTODIARIO:oWSGradeDiaria,oWSGradeDiaria)
		    
		NEXT nCont 
		
		IF oWsCli:IntegrarClienteCompleto()
	
		   oResp   := oWsCli:oWSIntegrarClienteCompletoResult
		   cMetodo := 'TabelaCliente'
		   nId     := oResp:NID
		   aCli    := {}
		   Aadd(aCli,IIF(TYPE("oResp:CIDENTIFICADOR") == 'U','',oResp:CIDENTIFICADOR) + " || " + oResp:cmensagem)
	       
		ELSE
		 
			cMetodo := 'TabelaCliente'
		    nId     := -2
		    aTab    := {}
		    Aadd(aCli,ALLTRIM(TRE->A1_COD + TRE->A1_LOJA) + '||' + GetWSCError())
	        
		    
		ENDIF
					
		TRE->(dbSkip())
		
	ENDDO //FECHA WHILE DO TRD
	TRE->(dbCloseArea()) 
	
RETURN(aCli)

STATIC FUNCTION SqlClientes(cCliente,cLoja)

	Local cFilOrig := FWFILIAL("SA1")
     
    BeginSQL Alias "TRE"
			%NoPARSER% 
			SELECT A1_COD,
			       A1_LOJA,
			       A1_PESSOA,
				   A1_CGC,
				   A1_NOME,
				   A1_NREDUZ,
				   A1_DDD,
				   A1_TEL,
				   A1_EMAIL,
				   A1_ENDENT,
				   A1_COMPLEM,
				   A1_BAIRROE,
				   A1_MUNE,
				   A1_ESTE,
				   A1_PAIS,
				   A1_CEPE,
				   A1_XLATITU,
				   A1_XLONGIT,
				   A1_REGIAO,
				   A1_HRINIM,
				   A1_HRFINM,
				   A1_HRINIT,
				   A1_HRFINT,
				   A1_SATIV1
			  FROM %TABLE:SA1% WITH(NOLOCK)
			 WHERE A1_FILIAL   = %EXP:cFilOrig%
			   AND A1_COD      = %EXP:cCliente%
			   AND A1_LOJA     = %EXP:cLoja%
			   AND D_E_L_E_T_ <> '*'
			   
			
			   ORDER BY A1_COD,A1_LOJA
   		
    EndSQl          

RETURN(NIL)

STATIC FUNCTION NOACENTO2(cString)

	Local cChar      := ""
	Local nX         := 0 
	Local nY         := 0
	Local cVogal     := "aeiouAEIOU"
	Local cAgudo     := "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu     := "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema     := "äëïöü"+"ÄËÏÖÜ"
	Local cCrase     := "àèìòù"+"ÀÈÌÒÙ" 
	Local cTio       := "ãõÃÕ"
	Local cCecid     := "çÇ"
	Local cMaior     := "&lt;"
	Local cMenor     := "&gt;"
	Local cApostofro := "'"
	
	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf		
			nY:= At(cChar,cTio)
			If nY > 0          
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			EndIf		
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		Endif
	Next
	
	If cMaior$ cString 
		cString := strTran( cString, cMaior, "" ) 
	EndIf
	If cMenor$ cString 
		cString := strTran( cString, cMenor, "" )
	EndIf

	If cApostofro $ cString 
		cString := strTran( cString, cApostofro, "" )
	EndIf
	
	cString := StrTran( cString, CRLF, " " )
	
	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|' 
			cString:=StrTran(cString,cChar,".")
		Endif
	Next nX
	//Especifico Adoro devido a erro XML não solucionado versao 3.10
	cString := StrTran(cString,"&","e")
	cString := StrTran(cString,"'","")
	
Return cString
