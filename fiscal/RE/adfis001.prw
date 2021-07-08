#INCLUDE "Protheus.CH"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} User Function ADFIS001
	Apresenta STATUS da transmissao de Nota Fiscal Eletronica
	@type  Function
	@author Adriana Oliveira
	@since 30/05/11
	@history Chamado 057012 - Abel Babini - 30/03/2020 - Rel. Conferência. Ajustar para permitir geração para empresas 07 e 09
	@history Ticket  16374  - Abel Babini - 05/07/2021 - Rel. Conferência. Informações faltantes no relatório para a SAFEGG
	
	/*/

USER FUNCTION ADFIS001()

	Local cDesc1		:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2		:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3		:= "Transmissao NFe - Status de Envio"
	Local cPict			:= ""
	Local titulo		:= "Transmissao NFe - Status de Envio"
	Local nLin			:= 80
	Local Cabec1		:= "N. Fiscal     Emissao   Cliente                        Data/Hora Lote        Protocolo         Chave de acesso da NF-e                   Ret.SF3 Mensagem Retorno SEFAZ                      CFOP   Valor Fiscal  Modalidade"
	Local Cabec2		:= ""
	Local imprime		:= .T.
	Local aOrd			:= {"Por Situacao+Emisssao+Nota"}
	Private lEnd		:= .F.
	Private lAbortPrint	:= .F.
	Private CbTxt		:= ""
	Private limite		:= 220
	Private tamanho		:= "G"
	Private nomeprog	:= "ADFIS001" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo		:= 18
	Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey	:= 0
	Private cbtxt		:= Space(10)
	Private cbcont		:= 00
	Private CONTFL		:= 01
	Private m_pag		:= 01
	Private wnrel		:= "ADFIS001" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cPerg		:= "ADFIS001"
	Private cString		:= "SF2"
	Private BaseSped	:= "[SPED]"      	//PRODUCAO [VPSRV02].[SPED]       //HOMOLOGACAO [SPED]
	Private BaseDado	:= "DADOSADV"    	//PRODUCAO DADOSADV
	Private lSped		:= .t.
	Private lSf3		:= .t.
	//
	Private _aEntidade  := {}
	Private _cEntidade  := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Apresenta STATUS da transmissao de Nota Fiscal Eletronica')
	
	If cEmpAnt =  "01" 

		_aEntidade  :={{"01","000011"},{"02","000001"},{"03","000002"},{"04","000005"},{"05","000007"},{"06","000004"},{"07","000013"},{"08","000014"},{"09","000015"},{"0A","000021"}}

	ElseIf cEmpAnt =  "02"

		_aEntidade  :={{"01","000006"}}
	//INICIO Chamado 057012 - Abel Babini - 30/03/2020 - Rel. Conferência. Ajustar para permitir geração para empresas 07 e 09
	ElseIf cEmpAnt =  "07" //RNX2

		_aEntidade  :={{"01","000017"}}

	ElseIf cEmpAnt =  "09" //SAFEGG

		_aEntidade  :={{"01","000020"}}
	//FIM Chamado 057012 - Abel Babini - 30/03/2020 - Rel. Conferência. Ajustar para permitir geração para empresas 07 e 09
	EndIf
	//+-------------------------------------------------------------------------+
	//|Monta grupo de perguntas                                                 |
	//+-------------------------------------------------------------------------+

	//Fernando Sigoli 040311 - Comentando para funcionar para as demais empresas
	//if cEmpAnt <> "01" 
	If !cEmpAnt $ "01/02/07/09" 
		Alert("Empresa nao configurada para este relatorio !!!")
		Return
	endif

	_cEntidade := _aEntidade[Ascan(_aEntidade, {|x| Alltrim(x[1]) = cFilAnt } ), 2]

	//

	MontaPerg()

	Pergunte(cPerg,.F.)

	/*
	lay-out
	N. Fiscal     Emissao     Cliente                      Data/Hora Lote      Protocolo       Chave de acesso da NF-e                            Ret.SF3 Mensagem Retorno SEFAZ                 CFOP   Valor Fiscal  Modalidade"
	Nota Fiscal Emissao    Cliente                        Data/Hora Lote   Stats       Protocolo        Chave de acesso da NF-e                                Guia      No. Integrado  ValBrut        Mod.
	XXXXXX-XXX  XX/XX/XXXX xxxxxx xx xxxxxxxxxxxxxxxxxxxx xx/xx/xxxx xx:xx X Cancelada xxxxxxxxxxxxxxx  XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX XXXXXXXXX XXXXXXXXX      999,999,999.99 Contin
	Normal
	1         2         3         4         5         6         7         8         9        10        12        13        14        15        16        17        18        19         20        22
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/{Protheus.doc} User Function RUNREPORT
	Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
	@type  Function
	@author Adriana Oliveira
	@since 30/05/11
	/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	Private cQuery:=""
	Private nRegs :=0

	Private FILSA1:=xFilial("SA1")
	Private FILSA2:=xFilial("SA2")

	Private cClieFor	:=""
	Private cCgcClieFor :=""
	Private nGuia		:=""
	Private nNumGrj		:=""
	Private nValBrut	:=0
	Private nTotVal		:=0
	Private cSerie 		:= ""
	Private cNFiscal	:= ""
	Private nTamNF		:= len(alltrim(MV_PAR01))

	For _i := Val(MV_PAR01) to Val(MV_PAR02)
		
		cQuery	:=""
		cQuery2	:=""
		
		cQuery+="SELECT "
		cQuery+="LEFT(SP50.NFE_ID,3)+RIGHT(RTRIM(SP50.NFE_ID),6) AS NFE_ID, "
		cQuery+="SP50.ID_ENT AS ENTID_50, "
		cQuery+="SP50.NFE_ID AS NFE_IDX, "
		cQuery+="SP50.CNPJDEST AS CNPJ, "
		cQuery+="SP54.DTREC_SEFR   AS DT_TRANS, "
		cQuery+="SP54.HRREC_SEFR   AS HR_TRANS, "
		cQuery+="SP50.STATUS  AS ST_SPED, "
		cQuery+="SP50.STATUSCANC   AS ST_CABCEL, "
		cQuery+="SP50.STATUSMAIL   AS ST_SENDMA, "
		cQuery+="SP50.NFE_PROT     AS NF_PROT, "
		cQuery+="SP54.NFE_CHV AS NFE_CHV    	 , "
		cQuery+="SP54.CSTAT_SEFR CODMOTIVO	 , "
		cQuery+="SP54.XMOT_SEFR MOTIVO    	 , "
		cQuery+="SP54.ID_ENT ENTID_54    	 , "
		cQuery+="SP50.AMBIENTE AS AMBI, "
		cQuery+="SP50.MODALIDADE  AS MODAL, "
		cQuery+="SP52.XMOT_SEFR AS MOTIVO2    	 , "
		cQuery+="SP52.ID_ENT AS ENTID_52    	 , "
		cQuery+="SP52.XMOT_SEF  AS MOTIVO3    	 , "
		cQuery+="SP52.DATE_LOTE AS DT_TRANS2, "
		cQuery+="SP52.TIME_LOTE AS HR_TRANS2, "
		cQuery+="SP52.RECIBO_SEF AS NF_PROT2 "
		cQuery+="FROM "+BaseSped+".[dbo].SPED050 AS SP50 "
		cQuery+="INNER JOIN "+BaseSped+".dbo.SPED054 AS SP54 ON SP54.ID_ENT = SP50.ID_ENT AND SP50.NFE_ID=SP54.NFE_ID AND SP50.ID_ENT = SP54.ID_ENT AND SP54.D_E_L_E_T_='' "
		cQuery+="INNER JOIN "+BaseSped+".dbo.SPED052 AS SP52 ON SP52.ID_ENT = SP50.ID_ENT AND SP52.ID_ENT=SP54.ID_ENT AND SP52.LOTE = SP54.LOTE AND SP52.D_E_L_E_T_='' "
		cQuery+="WHERE "
		cQuery+="((SP50.NFE_ID	= '"+MV_PAR03+StrZero(_i,6)+"') OR "
		cQuery+="(SP50.NFE_ID	= '"+MV_PAR03+StrZero(_i,9)+"')) AND "
		cQuery+="SP50.ID_ENT = '"+_cEntidade+"' AND "
		cQuery+="SP50.D_E_L_E_T_= '' "
		cQuery+="ORDER BY SP54.NFE_ID, SP54.DTREC_SEFR, SP54.HRREC_SEFR, SP54.CSTAT_SEFR "
		
		TCQUERY cQuery NEW ALIAS "SPED"
		
		cQuery2 := "SELECT * FROM "+RetSqlName("SF3")+" WHERE "
		cQuery2 += "F3_SERIE = '"+MV_PAR03+"' AND (F3_NFISCAL = '"+StrZero(_i,6)+"' OR F3_NFISCAL = '"+StrZero(_i,9)+"') "
		cQuery2 += "AND ((F3_CFO < '5000' AND F3_FORMUL = 'S') OR (F3_CFO >= '5000') ) "
		cQuery2 += "AND F3_ESPECIE = 'SPED' AND F3_FILIAL = '"+cFilAnt+"' AND D_E_L_E_T_ = '' "
		cQuery2 += "ORDER BY F3_CFO  "
		
		TCQUERY cQuery2 NEW ALIAS "SPEDSF3"
		
		cAlias:=ALIAS()
		
		DbSelectArea("SPED")
		DbGoTop()
		
		If SPED->(EOF())
			lSped := .f.
		Else
			lSped := .t.
		EndIf
		
		DbSelectArea("SPEDSF3")
		DbGoTop()
		
		If SPEDSF3->(EOF())
			lSF3 := .f.
		Else
			lSF3 := .t.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If nLin > 65 // Salto de Página. Neste caso o formulario tem 65 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
		
		If !(lSped) .and. !(lSF3)
			
			@nlin,000 Psay MV_PAR03+StrZero(_i,nTamNF)
			@nLin,013 Psay "***************** VERIFICAR NUMERACAO ******************"
			@nLin,146 Psay "Sem registro"
			nLin++
			
		ElseIf lSped .and. !lSF3
			
			DbSelectArea("SPED")
			DbGoTop()
			
			While !(SPED->(Eof()))
				
				@nlin,000 Psay LEFT(SPED->NFE_IDX,12)
				@nLin,055 Psay STOD(Iif(Empty(SPED->DT_TRANS),SPED->DT_TRANS2,SPED->DT_TRANS))
				@nLin,066 Psay Left(Iif(Empty(SPED->HR_TRANS),SPED->HR_TRANS2,SPED->HR_TRANS),8)
				@nLin,077 Psay Iif(Empty(SPED->NF_PROT),STR(SPED->NF_PROT2,15), SPED->NF_PROT)
				@nLin,094 Psay iif(MV_PAR04=1,space(44),SPED->NFE_CHV)
				@nLin,140 Psay "   "
				@nLin,146 Psay SPED->CODMOTIVO+" "+Left(Iif(Empty(SPED->MOTIVO),Iif(Empty(SPED->MOTIVO2),SPED->MOTIVO3,SPED->MOTIVO2),SPED->MOTIVO),37)
				@nLin,210 Psay iIf(SPED->MODAL>1,"Contingencia","Normal")
				
				nLin++
				
				If nLin > 65 // Salto de Página. Neste caso o formulario tem 65 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				EndIf
				
				SPED->(DBSkip())
				
			EndDo
			
		ElseIf !lSped .and. lSF3
			
			DbSelectArea("SPEDSF3")
			
			While !(SPEDSF3->(EOF()))
				
				//+------------------------------------------------------------+
				//|Posiciona no Cadastro do Cliente ou fornecedor               |
				//+------------------------------------------------------------+
				If (SPEDSF3->F3_CFO < '5000' .AND. !SPEDSF3->F3_TIPO$'BD') .OR. (SPEDSF3->F3_CFO >= '5000' .AND. SPEDSF3->F3_TIPO$'BD')
					//Alterado para pegar cliente ou fornecedor corretamente por Adriana em 18/07/12
					DbSelectArea("SA2")
					DbSeek(xFilial("SA2")+SPEDSF3->F3_CLIEFOR+SPEDSF3->F3_LOJA)
					cClieFor	 :=	A2_COD+" "+A2_LOJA+" "+A2_NREDUZ
					cCgcClieFor := A2_CGC
				Else
					DbSelectArea("SA1")
					DbSeek(xFilial("SA1")+SPEDSF3->F3_CLIEFOR+SPEDSF3->F3_LOJA)
					cClieFor	:=	A1_COD+" "+A1_LOJA+" "+A1_NREDUZ
					cCgcClieFor := A1_CGC
				EndIf
				
				@nlin,000 Psay SPEDSF3->F3_SERIE+SPEDSF3->F3_NFISCAL
				@nLin,013 Psay STOD(SPEDSF3->F3_EMISSAO)
				@nLin,024 Psay cClieFor
				@nLin,146 Psay "Nao Enviada"
				@nLin,189 Psay SPEDSF3->F3_CFO
				@nLin,194 Psay SPEDSF3->F3_VALCONT  PICTURE("@E 999,999,999.99")
				
				nLin++
				
				If nLin > 65 // Salto de Página. Neste caso o formulario tem 65 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				EndIf
				
				DbSelectArea("SPEDSF3")
				DbSkip()
			EndDo
			
		ElseIf lSped .and. lSF3
			
			DbSelectArea("SPED")
			DbGoTop()
			
			While !(SPED->(Eof()))
				
				DbSelectArea("SPEDSF3")
				DbGoTop()
				
				While !(SPEDSF3->(EOF()))
					
					If SPEDSF3->F3_SERIE+SPEDSF3->F3_NFISCAL = LEFT(SPED->NFE_IDX,12)
						
						if (mv_par05 = 1 .and. Empty(SPEDSF3->F3_CHVNFE)) .or. mv_par05 <> 1  //se imprime somente SEM CHAVE ou todas     
						
							if mv_par06 = 1 .or. (mv_par06 <> 1 .and. !iif(MV_PAR04=1,SPEDSF3->F3_CODRSEF,SPED->CODMOTIVO)$"   100 101 102")   ;
											.or. (mv_par06 <> 1 .and. Empty(SPEDSF3->F3_CODRSEF) .and. SPED->CODMOTIVO$"101 102") ;    //se cancelada ou inutilizada verifica se SF3 foi atualizado 
											.or. (mv_par06 <> 1 .and. Empty(SPEDSF3->F3_CHVNFE)  .and. SPED->CODMOTIVO="100")          //Nota autorizada SEFAZ verifica se SF3 foi atualizado
							
							//+------------------------------------------------------------+
							//|Posiciona no Cadastro do Cliente ou fornecedor               |
							//+------------------------------------------------------------+
							If (SPEDSF3->F3_CFO < '5000' .AND. !SPEDSF3->F3_TIPO$'BD') .OR. (SPEDSF3->F3_CFO >= '5000' .AND. SPEDSF3->F3_TIPO$'BD')
								//Alterado para pegar cliente ou fornecedor corretamente por Adriana em 18/07/12
								DbSelectArea("SA2")
								DbSeek(xFilial("SA2")+SPEDSF3->F3_CLIEFOR+SPEDSF3->F3_LOJA)
								cClieFor	:=	A2_COD+" "+A2_LOJA+" "+A2_NREDUZ
								cCgcClieFor := A2_CGC
							Else
								DbSelectArea("SA1")
								DbSeek(xFilial("SA1")+SPEDSF3->F3_CLIEFOR+SPEDSF3->F3_LOJA)
								cClieFor	:=	A1_COD+" "+A1_LOJA+" "+A1_NREDUZ
								cCgcClieFor := A1_CGC
							EndIf      
							
							//WILL  - chamado 0200030 OS 020527 verificação do CNPJ Diferente em 09/10/2014
							IF UPPER(ALLTRIM(cCgcClieFor)) <> UPPER(ALLTRIM(SPED->CNPJ))  
							
								@nlin,000 Psay LEFT(SPED->NFE_IDX,12)
								@nLin,013 Psay STOD(SPEDSF3->F3_EMISSAO)
								@nLin,024 Psay SUBSTR(cClieFor,1,6) +   ' *** ATENÇÃO CNPJ DIFERENTE TSS x PROTHEUS!***' //cClieFor
								//@nLin,055 Psay STOD(Iif(Empty(SPED->DT_TRANS),SPED->DT_TRANS2,SPED->DT_TRANS))
								//@nLin,066 Psay Left(Iif(Empty(SPED->HR_TRANS),SPED->HR_TRANS2,SPED->HR_TRANS),8)
								@nLin,077 Psay iif(Empty(SPED->NF_PROT),iif(Empty(SPEDSF3->F3_OBSERV),STR(SPED->NF_PROT2,15),Left(SPEDSF3->F3_OBSERV,15)),SPED->NF_PROT)
								@nLin,094 Psay iif(MV_PAR04=1,SPEDSF3->F3_CHVNFE,SPED->NFE_CHV)
								@nLin,140 Psay SPEDSF3->F3_CODRSEF
								@nLin,146 Psay SPED->CODMOTIVO+" "+Left(Iif(Empty(SPED->MOTIVO),Iif(Empty(SPED->MOTIVO2),SPED->MOTIVO3,SPED->MOTIVO2),SPED->MOTIVO),37)
								@nLin,189 Psay SPEDSF3->F3_CFO
								@nLin,194 Psay SPEDSF3->F3_VALCONT  PICTURE("@E 999,999,999.99")
								@nLin,210 Psay iIf(SPED->MODAL>1,"Contingencia","Normal") 
							
							
							ELSE 
								
								@nlin,000 Psay LEFT(SPED->NFE_IDX,12)
								@nLin,013 Psay STOD(SPEDSF3->F3_EMISSAO)
								@nLin,024 Psay cClieFor
								@nLin,055 Psay STOD(Iif(Empty(SPED->DT_TRANS),SPED->DT_TRANS2,SPED->DT_TRANS))
								@nLin,066 Psay Left(Iif(Empty(SPED->HR_TRANS),SPED->HR_TRANS2,SPED->HR_TRANS),8)
								@nLin,077 Psay iif(Empty(SPED->NF_PROT),iif(Empty(SPEDSF3->F3_OBSERV),STR(SPED->NF_PROT2,15),Left(SPEDSF3->F3_OBSERV,15)),SPED->NF_PROT)
								@nLin,094 Psay iif(MV_PAR04=1,SPEDSF3->F3_CHVNFE,SPED->NFE_CHV)
								@nLin,140 Psay SPEDSF3->F3_CODRSEF
								@nLin,146 Psay SPED->CODMOTIVO+" "+Left(Iif(Empty(SPED->MOTIVO),Iif(Empty(SPED->MOTIVO2),SPED->MOTIVO3,SPED->MOTIVO2),SPED->MOTIVO),37)
								@nLin,189 Psay SPEDSF3->F3_CFO
								@nLin,194 Psay SPEDSF3->F3_VALCONT  PICTURE("@E 999,999,999.99")
								@nLin,210 Psay iIf(SPED->MODAL>1,"Contingencia","Normal")
								
							ENDIF
							
							nLin++
							
							If nLin > 65 // Salto de Página. Neste caso o formulario tem 65 linhas...
								Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
								nLin := 8
							EndIf
							
							Endif
							
						EndIf
						
					Endif
					
					DbSelectArea("SPEDSF3")
					DbSkip()
					
				EndDo
				
				DbSelectArea("SPED")
				DbSkip()
				
			EndDo
		EndIf
		
		DbSelectArea("SPED")
		DbCloseArea()
		DbSelectArea("SPEDSF3")
		DbCloseArea()
	Next

	SET DEVICE TO SCREEN
	
	//Se impressao em disco, chama o gerenciador de impressao...          
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

/*/{Protheus.doc} User Function MONTAPERG
	Monta as perguntas no SX1
	@type  Function
	@author Adriana Oliveira
	@since 30/05/11
	/*/

Static Function MontaPerg()

	Local _aArea:= GetArea()
	Local aRegs	:={}

	cPerg := PADR(cPerg,10)

	DbSelectArea("SX1")
	DbSetOrder(1)

	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	//              1  2      3             4    5       6       7      8   9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25 26

	aAdd(aRegs,{cPerg,"01","Da NF  ?"					,"mv_ch1","C",9,0,0 ,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até a NF  ?"   				,"mv_ch2","C",9,0,0 ,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Série    ?"					,"mv_ch3","C",3,0,0 ,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Chave NF-e?"   				,"mv_ch4","N",1,0,1	,"C","","mv_par04","SF3-Fiscal","","","SPED","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Somente SEM Chave NF-e?"	,"mv_ch5","N",1,0,1	,"C","","mv_par05","SIM","","","NAO","","","","","","","","","","",""})  
	aAdd(aRegs,{cPerg,"06","Notas Autorizadas?"			,"mv_ch6","N",1,0,1	,"C","","mv_par06","SIM","","","NAO","","","","","","","","","","",""})  //Incluido conf chamado 019911


	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			SX1->X1_GRUPO	:= aRegs[i,01]
			SX1->X1_ORDEM	:= aRegs[i,02]
			SX1->X1_PERGUNT	:= aRegs[i,03]
			SX1->X1_VARIAVL	:= aRegs[i,04]
			SX1->X1_TIPO	:= aRegs[i,05]
			SX1->X1_TAMANHO	:= aRegs[i,06]
			SX1->X1_DECIMAL	:= aRegs[i,07]
			SX1->X1_PRESEL	:= aRegs[i,08]
			SX1->X1_GSC		:= aRegs[i,09]
			SX1->X1_VALID	:= aRegs[i,10]
			SX1->X1_VAR01	:= aRegs[i,11]
			SX1->X1_DEF01	:= aRegs[i,12]
			SX1->X1_CNT01	:= aRegs[i,13]
			SX1->X1_VAR02	:= aRegs[i,14]
			SX1->X1_DEF02	:= aRegs[i,15]
			SX1->X1_CNT02	:= aRegs[i,16]
			SX1->X1_VAR03	:= aRegs[i,17]
			SX1->X1_DEF03	:= aRegs[i,18]
			SX1->X1_CNT03	:= aRegs[i,19]
			SX1->X1_VAR04	:= aRegs[i,20]
			SX1->X1_DEF04	:= aRegs[i,21]
			SX1->X1_CNT04	:= aRegs[i,22]
			SX1->X1_VAR05	:= aRegs[i,23]
			SX1->X1_DEF05	:= aRegs[i,24]
			SX1->X1_CNT05	:= aRegs[i,25]
			SX1->X1_F3		:= aRegs[i,26]
			MsUnlock()
			DbCommit()
		Endif
	Next

	RestArea(_aArea)
	
Return
