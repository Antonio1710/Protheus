#INCLUDE "rwmake.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*{Protheus.doc} User Function ADEST045P
	Zera Empenho e Reserva de um produto 
	@type  Function
	@author William Costa
	@since 17/02/2020
	@version 01
	@history Chamado 056597 - William Costa - 12/03/2020 - Identificado falha no fechamento da tabela era pra fechar a TRD e estava a TRE
	@history TICKET  5331   - William Costa - 19/11/2020 - Adicionado o campo B2_QEMPSA, também para ser zerado
	@history chamado TI     - Leonardo P. Monteiro - 08/03/2022 - Correção do msunlock para prevenir lock na tabela SB2.
*/

USER FUNCTION ADEST045P()

	Private oDlg               := NIL
	Private oEmpresa           := Array(01)                                                                           
	Private oBtnConf           := Array(02)
	Private oFilial            := Array(04)
	Private oLocal             := Array(05)
	Private oNomeLocal         := Array(06)
	Private oProd              := Array(07)
	Private oEnd               := Array(08)
	Private oNomeProd          := Array(09)
	Private oNomeEnd           := Array(10)
	Private oBtnCanc           := Array(11)
	Private cEmpresa           := SPACE(02)
	Private cFilAtu            := SPACE(02)
	Private cLocal             := SPACE(02)
	Private cNomeLocal         := SPACE(60)
	Private cProd              := SPACE(15)
	Private cNomeProd          := SPACE(60)
	Private cEnd               := SPACE(15)
	Private cNomeEnd           := SPACE(60)
	Private cKeyBloq           := "ADEST045P" // Carregar Matricula para o Dimep
	
	cEmpresa := cEmpAnt
	cFilAtu  := FWXFILIAL("SRA")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao com o sistema DIMEP de catracas Gerar Perfil de Acesso Especificos para funcionario que tem particularidades por exemplo acessos em cancelas e portas')

	IF !(__cUserId $ GetMv("MV_#USUEMP",,"001439"))
	
		MsgStop("OLÁ " + Alltrim(cUserName) + ", Você não tem permissão de Utilizar essa Rotina", "ADGPE044P-01")
		RETURN(NIL)
	
	ENDIF

	// Garanto uma unica thread sendo executada por empresa
	IF !LOCKBYNAME(cKeyBloq, .T., .F.)

		MSGALERT("[ADEST045P] - Existe outro processamento sendo executado! Aguarde ou peça para seu colega de trabalho fechar a rotina... Esta rotina será desconectada pelo Administrador...")

		RETURN(NIL)

	ENDIF
	
	DEFINE MSDIALOG oDlg TITLE "Ajusta Empenhos do Estoque" FROM 0,0 TO 270,450 OF oDlg PIXEL
		
		@ 003, 003 TO 130,225 PIXEL OF oDlg
		
		@ 010,005 Say "Empresa:" of oDlg PIXEL 
		@ 008,030 MsGet oEmpresa Var cEmpresa SIZE 30,10 of oDlg PIXEL Picture "@!" WHEN .F. 
		
		@ 030,005 Say "Filial:" of oDlg PIXEL 
		@ 028,030 MsGet oFilial Var cFilAtu SIZE 30,10 of oDlg PIXEL Picture "@!" WHEN .F. 
		
		@ 050,005 Say "Local:" of oDlg PIXEL
		@ 048,030 MsGet oLocal Var cLocal SIZE 60,10 of oDlg PIXEL Picture "@!" VALID VALLOCAL(cFilAtu,cLocal) F3 "NNR" 
		
		@ 048,095 MsGet oNomeLocal Var cNomeLocal SIZE 100,10 of oDlg PIXEL Picture "@!" WHEN .F.

		@ 070,005 Say "Produto:" of oDlg PIXEL
		@ 068,030 MsGet oProd Var cProd SIZE 60,10 of oDlg PIXEL Picture "@!" VALID VALPROD(cFilAtu,cProd) F3 "SB1" 
		
		@ 068,095 MsGet oNomeProd Var cNomeProd SIZE 100,10 of oDlg PIXEL Picture "@!" WHEN .F.

		@ 090,005 Say "Endereço:" of oDlg PIXEL
		@ 088,030 MsGet oEnd Var cEnd SIZE 60,10 of oDlg PIXEL Picture "@!" VALID VALEND(cFilAtu,cProd,cEnd) F3 "SBECOD" 
		
		@ 088,095 MsGet oNomeEnd Var cNomeEnd SIZE 100,10 of oDlg PIXEL Picture "@!" WHEN .F.
		
		@ 110,005 BUTTON oBtnConf [01] PROMPT "Mostrar Saldos" OF oDlg SIZE 60,12 PIXEL ACTION (MsAguarde({||MOSTRASALDO(cEmpresa,cFilAtu,cLocal,cProd,cEnd) },"Aguarde","Ajustando Empenho..."), oDlg:End())
		@ 110,160 BUTTON oBtnCanc [01] PROMPT "Cancelar"  OF oDlg SIZE 60,12 PIXEL ACTION (oDlg:End())
		
	ACTIVATE MSDIALOG oDlg CENTERED
	
RETURN(NIL)

STATIC FUNCTION MOSTRASALDO(cEmpresa,cFilAtu,cLocal,cProd,cEnd)

	Local lRet       := .T.
	
	lRet := VALIDENVIO(cEmpresa,cFilAtu,cLocal,cProd,cEnd) //Valida os campos de Funcionario
	
	// Se a Validacao retornar falso nao cria o perfil
	IF lRet == .F.
	
		RETURN(NIL)
	
	ENDIF

RETURN(NIL)

STATIC FUNCTION VALIDENVIO(cEmpresa,cFilAtu,cLocal,cProd,cEnd)

	Local lRet       := .T.
	Local nSaldoProd := 0
	Local nSaldoEnd  := 0
	Local nSaldoEmp  := 0
	Local nSalEmpSA  := 0
	
	IF ALLTRIM(cEnd) == ''

		SqlProdEnd(cFilAtu,cProd)
		IF TRD->(!EOF())
	
			IF ALLTRIM(TRD->B1_LOCALIZ) == 'S' .OR. ;
			   ALLTRIM(TRD->BZ_LOCALIZ) == 'S'			 

				lRet := .F.
				MSGALERT("Este produto tem Endereçamento, o Endereço não pode ser vazio, verifique!!!", "ADEST045P")

			ENDIF

		ENDIF
		TRD->(dbCloseArea())

	ELSE

		SqlProdEnd(cFilAtu,cProd)
		IF TRD->(!EOF())
	
			IF ALLTRIM(TRD->B1_LOCALIZ) <> 'S' .OR. ;
			   ALLTRIM(TRD->BZ_LOCALIZ) <> 'S'			 

				lRet := .F.
				MSGALERT("Este produto tem Endereçamento, não pode ser vazio o Endereço, verifique campos B1_LOCALIZ  e BZ_LOCALIZ!!!", "ADEST045P")

			ENDIF

		ENDIF
		TRD->(dbCloseArea())

	ENDIF

	//Verifica se a quantidade empenha em S.A, é sujeira de base.
	IF lRet == .T.

		IF ALLTRIM(cLocal) <> '03'
	
			SqlSaldo(cEmpresa,cFilAtu,cLocal,cProd,cEnd)
			
		ELSE
		
			SqlSaldo1(cEmpresa,cFilAtu,cLocal,cProd,cEnd)
			
		ENDIF

		IF TRF->(!EOF())

			IF TRF->B2_QEMPSA > 0
			
				SqlSCP(TRF->B2_FILIAL,TRF->B1_COD,TRF->B2_LOCAL)
				IF TRG->(!EOF())

					lRet := .F.
					MSGALERT("Este produto tem Solicitações de Armazém a serem baixadas: " + TRG->CP_NUM + " Antes de zerar o Saldos, Verifique!!!", "ADEST045P")

				ENDIF
				TRG->(dbCloseArea())
			ENDIF

		ENDIF
		TRF->(dbCloseArea())
	ENDIF
	
	IF lRet == .T.

		IF ALLTRIM(cLocal) <> '03'
	
			SqlSaldo(cEmpresa,cFilAtu,cLocal,cProd,cEnd)
			
		ELSE
		
			SqlSaldo1(cEmpresa,cFilAtu,cLocal,cProd,cEnd)
			
		ENDIF

		IF TRF->(!EOF())

			IF MSGNOYES("Deseja Zerar Saldo Empenhado (B2_QEMP) e de Reserva (B2_RESERVA) do Produto ?" + CHR(13) + CHR(10) +;
						"B2_QATU    = " + CVALTOCHAR(TRF->B2_QATU)                                      + CHR(13) + CHR(10) +;
						"B2_QACLASS = " + CVALTOCHAR(TRF->B2_QACLASS)                                   + CHR(13) + CHR(10) +;
						"B2_QEMPSA  = " + CVALTOCHAR(TRF->B2_QEMPSA)                                    + CHR(13) + CHR(10) +;
						"B2_RESERVA = " + CVALTOCHAR(TRF->B2_RESERVA)                                   + CHR(13) + CHR(10) +;
						"B2_QEMP    = " + CVALTOCHAR(TRF->B2_QEMP)                                      + CHR(13) + CHR(10) +;
						"BF_LOCALIZ = " + CVALTOCHAR(TRF->BF_LOCALIZ)                                   + CHR(13) + CHR(10) +;
						"BF_QUANT   = " + CVALTOCHAR(TRF->BF_QUANT)                                     + CHR(13) + CHR(10))

				nSaldoProd := TRF->B2_QATU
				nSaldoEnd  := TRF->BF_QUANT
				nSalEmpSA  := TRF->B2_QEMPSA
				nSaldoEmp  := TRF->B2_QEMP + TRF->B2_RESERVA  + TRF->B2_QEMPSA

				IF nSaldoEmp > 0

					dbSelectArea("SB2")
					SB2->(DbSetOrder(1))
					IF SB2->(DbSeek( xFilial("SB2") + TRF->B1_COD + TRF->B2_LOCAL ))

						IF RECLOCK("SB2",.F.)

							SB2->B2_QEMP    := 0
							SB2->B2_RESERVA := 0
							SB2->B2_QEMPSA  := 0
							SB2->(MsUnlock())
							
							MsUnlockAll()

						ENDIF
                        
						GERALOG(FWXFILIAL("SB2"), 'Filial: ' + ALLTRIM(TRF->B2_FILIAL) + ' Produto: ' + ALLTRIM(TRF->B1_COD) + ' Local: ' + ALLTRIM(TRF->B2_LOCAL) , ' Ajuste de Empenho de: ' + CVALTOCHAR(TRF->B2_QEMP) + ' PARA: ' + CVALTOCHAR(SB2->B2_QEMP) + ' Ajuste de Reserva de: ' + CVALTOCHAR(TRF->B2_RESERVA) + ' PARA: ' + CVALTOCHAR(SB2->B2_RESERVA) + ' Ajuste de Empenho de SA de: ' + CVALTOCHAR(TRF->B2_QEMPSA) + ' PARA: ' + CVALTOCHAR(SB2->B2_QEMPSA))
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		TRF->(dbCloseArea())
	ENDIF
	
RETURN(lRet)

STATIC FUNCTION VALLOCAL(cFilAtu,cLocal)

	Local lRet := .T.

	SqlLocal(cFilAtu,cLocal)
		
	IF TRB->(!EOF())
	
		cNomeLocal := TRB->NNR_DESCRI
			
	ELSE

		lRet := .F.
		MSGALERT("Local não é válido", "ADEST045P")

	ENDIF
	TRB->(dbCloseArea())

	oDlg:REFRESH()
	oLocal:REFRESH()
	oDlg:SetFocus()	
    
RETURN(lRet)

STATIC FUNCTION VALPROD(cFilAtu,cProd)

	Local lRet := .T.

	SqlProd(cFilAtu,cProd)
		
	IF TRC->(!EOF())
	
		cNomeProd := TRC->B1_DESC
			
	ELSE

		lRet := .F.
		MSGALERT("Produto não é válido", "ADEST045P")

	ENDIF
	TRC->(dbCloseArea())

	oDlg:REFRESH()
	oProd:REFRESH()
	oDlg:SetFocus()	
    
RETURN(lRet)

STATIC FUNCTION VALEND(cFilAtu,cProd,cEnd)

	Local lRet := .T.

	IF ALLTRIM(cEnd) == ''

		SqlProdEnd(cFilAtu,cProd)
		IF TRD->(!EOF())
	
			IF ALLTRIM(TRD->B1_LOCALIZ) == 'S' .OR. ;
			   ALLTRIM(TRD->BZ_LOCALIZ) == 'S'			 

				lRet := .F.
				MSGALERT("Este produto tem Endereçamento, o Endereço não pode ser vazio, verifique!!!", "ADEST045P")

			ENDIF

		ENDIF
		TRD->(dbCloseArea())

	ELSE

		SqlProdEnd(cFilAtu,cProd)
		IF TRD->(!EOF())
	
			IF ALLTRIM(TRD->B1_LOCALIZ) <> 'S' .OR. ;
			   ALLTRIM(TRD->BZ_LOCALIZ) <> 'S'			 

				lRet := .F.
				MSGALERT("Este produto tem Endereçamento, não pode ser vazio o Endereço, verifique campos B1_LOCALIZ  e BZ_LOCALIZ!!!", "ADEST045P")

			ENDIF

		ENDIF
		TRD->(dbCloseArea())

	ENDIF

	IF lRet == .T.

		SqlEnd(cFilAtu,cEnd)
		IF TRE->(!EOF())
		
			cNomeEnd := TRE->BE_DESCRIC

		ELSE

			lRet := .F.
			MSGALERT("Endereço não é válido", "ADEST045P")

		ENDIF
		TRE->(dbCloseArea())

	ENDIF

	oDlg:REFRESH()
	oEND:REFRESH()
	oDlg:SetFocus()	
    
RETURN(lRet)

STATIC FUNCTION GERALOG(cFil,cTexto,cParam)

	DbSelectArea("ZBE")
		Reclock("ZBE",.T.)
			ZBE->ZBE_FILIAL	:= cFil
			ZBE->ZBE_DATA 	:= Date()
			ZBE->ZBE_HORA 	:= cValToChar(Time())
			ZBE->ZBE_USUARI := cUserName
			ZBE->ZBE_LOG 	:= cTexto
			ZBE->ZBE_MODULO := "SIGAEST"
			ZBE->ZBE_ROTINA := "ADEST045P"
			ZBE->ZBE_PARAME := cParam
		MsUnlock()
	ZBE->(DbCloseArea())
	
RETURN(NIL)

Static Function SqlLocal(cFilAtu,cLocal)

	BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT NNR_CODIGO,NNR_DESCRI
			  FROM %Table:NNR% WITH (NOLOCK)
			 WHERE NNR_CODIGO = %EXP:cLocal%
			   AND D_E_L_E_T_ <> '*'

	EndSQl            

RETURN(NIL)

Static Function SqlProd(cFilAtu,cProd)

	BeginSQL Alias "TRC"
			%NoPARSER% 
			SELECT B1_COD,B1_DESC
			  FROM %Table:SB1% WITH (NOLOCK)
			 WHERE B1_COD = %EXP:cProd%
			   AND D_E_L_E_T_ <> '*'

	EndSQl            

RETURN(NIL)

Static Function SqlProdEnd(cFilAtu,cProd)

	BeginSQL Alias "TRD"
			%NoPARSER% 
			SELECT B1_LOCALIZ,BZ_LOCALIZ 
				FROM %Table:SB1% WITH (NOLOCK)
				INNER JOIN %Table:SBZ% WITH (NOLOCK)
					    ON BZ_FILIAL               = %EXP:cFilAtu%
					   AND BZ_COD                  = B1_COD
				  	   AND %Table:SBZ%.D_E_L_E_T_ <> '*'
				     WHERE B1_COD                  = %EXP:cProd%
				       AND %Table:SB1%.D_E_L_E_T_ <> '*'

	EndSQl            

RETURN(NIL)

Static Function SqlEnd(cFilAtu,cEnd)

	BeginSQL Alias "TRE"
			%NoPARSER% 
			SELECT BE_LOCALIZ,BE_DESCRIC 
			  FROM %Table:SBE% WITH (NOLOCK)
			 WHERE BE_LOCALIZ = %EXP:cEnd%
			   AND D_E_L_E_T_ <> '*'

	EndSQl            

RETURN(NIL)

Static Function SqlSaldo(cEmpresa,cFilAtu,cLocal,cProd,cEnd)

	BeginSQL Alias "TRF"
			%NoPARSER%  
			SELECT B1_COD,
			       B1_DESC,
			       B1_LOCALIZ,
			       BZ_LOCALIZ,
			       BZ_COD,
			       B1_CODBAR,
				   B2_FILIAL,
				   B2_LOCAL,
			       B2_QATU,
			       B2_QACLASS,
			       B2_QEMPSA,
			       B2_RESERVA,
			       B2_QEMP,
			       B2_DINVENT,
			       B2_SALPEDI, 
			       BE_LOCALIZ,
			       BE_DTINV, 
			       BF_LOCALIZ,
			       BF_QUANT
			  FROM %TABLE:SB2% WITH(NOLOCK),%TABLE:SB1% WITH(NOLOCK)
			 LEFT JOIN %TABLE:SBE% WITH(NOLOCK)
			         ON BE_FILIAL               = %EXP:cFilAtu%           
			        AND BE_CODPRO               = B1_COD
					AND BE_LOCAL                = %EXP:cLocal%
			        AND %TABLE:SBE%.D_E_L_E_T_ <> '*' 
			   LEFT JOIN %TABLE:SBF% WITH(NOLOCK)
			         ON BF_FILIAL               = %EXP:cFilAtu% 
			        AND BF_LOCALIZ              = BE_LOCALIZ 
			        AND %TABLE:SBF%.D_E_L_E_T_ <> '*' 
			   LEFT JOIN %TABLE:SBZ% WITH(NOLOCK)
			         ON BZ_FILIAL               = %EXP:cFilAtu%
					AND BZ_COD                  = B1_COD
			        AND %TABLE:SBZ%.D_E_L_E_T_ <> '*' 
			     WHERE B2_FILIAL                = %EXP:cFilAtu%
			       AND B2_COD                  >= %EXP:cProd%
			       AND B2_COD                  <= %EXP:cProd%
			       AND B2_LOCAL                 = %EXP:cLocal%
			       AND %TABLE:SB2%.D_E_L_E_T_  <> '*'
			       AND B1_COD                   = B2_COD
			       AND B1_MSBLQL                = '2'
			       AND %TABLE:SB1%.D_E_L_E_T_  <> '*'
			
			ORDER BY SB1010.B1_COD
						  
	EndSQl
RETURN()    

Static Function SqlSaldo1(cEmpresa,cFilAtu,cLocal,cProd,cEnd)

	BeginSQL Alias "TRF"
			%NoPARSER%  
			SELECT B1_COD,
			       B1_DESC,
			       B1_LOCALIZ,
			       BZ_LOCALIZ,
			       BZ_COD,
				   B1_CODBAR,
				   B2_FILIAL,
				   B2_LOCAL,
			       B2_QATU,
			       B2_QACLASS,
			       B2_QEMPSA,
			       B2_RESERVA,
			       B2_QEMP,
			       B2_DINVENT,
			       B2_SALPEDI, 
			       BE_LOCALIZ,
			       BE_DTINV, 
			       BF_LOCALIZ,
			       BF_QUANT
			  FROM %TABLE:SB2% WITH(NOLOCK),%TABLE:SB1% WITH(NOLOCK)
			 LEFT JOIN %TABLE:SBE% WITH(NOLOCK)
			         ON BE_FILIAL               = %EXP:cFilAtu%           
			        AND BE_LOCALIZ              = 'PROD'
					AND BE_LOCAL                = %EXP:cLocal%
			        AND %TABLE:SBE%.D_E_L_E_T_ <> '*' 
			   LEFT JOIN %TABLE:SBF% WITH(NOLOCK)
			         ON BF_FILIAL               = %EXP:cFilAtu% 
			        AND BF_LOCALIZ              = BE_LOCALIZ 
			        AND BF_PRODUTO              = B1_COD
			        AND %TABLE:SBF%.D_E_L_E_T_ <> '*' 
			   LEFT JOIN %TABLE:SBZ% WITH(NOLOCK)
			         ON BZ_FILIAL               = %EXP:cFilAtu%
					AND BZ_COD                  = B1_COD
			        AND %TABLE:SBZ%.D_E_L_E_T_ <> '*' 
			     WHERE B2_FILIAL                = %EXP:cFilAtu%
			       AND B2_COD                  >= %EXP:cProd%
			       AND B2_COD                  <= %EXP:cProd%
			       AND B2_LOCAL                 = %EXP:cLocal%
			       AND %TABLE:SB2%.D_E_L_E_T_  <> '*'
			       AND B1_COD                   = B2_COD
			       AND B1_MSBLQL                = '2'
			       AND %TABLE:SB1%.D_E_L_E_T_  <> '*'
			
			ORDER BY SB1010.B1_COD
						  
	EndSQl

RETURN()

STATIC FUNCTION SqlSCP(cFilAtu,cProduto,cLocalProd)

	BeginSQL Alias "TRG"
			%NoPARSER% 
			SELECT CP_NUM, CP_ITEM, CP_PRODUTO, CP_QUANT, CP_QUJE,CP_STATUS,CP_PREREQU
			  FROM  %Table:SCP% WITH (NOLOCK)
			 WHERE CP_FILIAL   = %EXP:cFilAtu%
			   AND CP_PRODUTO  = %EXP:cProduto%
			   AND CP_LOCAL    = %EXP:cLocalProd%
			   AND CP_QUJE    <> CP_QUANT
			   AND CP_STATUS  <> 'E'       
			   AND CP_PREREQU  = 'S'
			   AND CP_NUMSC    = ''
			   AND D_E_L_E_T_ <> '*'

	EndSQl    

RETURN(NIL)
