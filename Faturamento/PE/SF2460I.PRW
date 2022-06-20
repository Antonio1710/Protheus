#INCLUDE "rwmake.ch" 
#INCLUDE "topconn.ch"
#INCLUDE "ParmType.ch"
//#INCLUDE "PROTHEUS.CH" //Ticket 1165	- Adriana	   - 09/09/2020

/*/{Protheus.doc} User Function SF2460I 
	PE - Grava o campo de volume no SF2 a partir do SC5
	@type  Function
	@author Rogerio E S Nutti
	@since 12/12/2001
	@version 1
	@history chamado ?????? - Daniel        - 22/02/2011 - INCLUIDO ROTINAS DE TRANSACAO E BUSCA DOS TITULOS NO SE1
	@history chamado 044861 - Sigoli        - 30/10/2018 - Estava desposicionando SD2 RS
	@history chamado 045310 - Sigoli        - 26/11/2018 - Estava desposicionando SD2 MG
	@history chamado TI     - Sigoli        - 19/12/2018 - Alteração da agência KOBOLD
	@history chamado 046222 - Everson       - 17/01/2019 - validação de grupo de produto e CFOP para gerar guia ST
	@history chamado 047943 - Sigoli        - 15/03/2019 - Conforme solilcitação do SIF, necessario ajustar a mensagem da Nota De LACRE SIF para LACRE OFICIAL
	@history chamado 048048 - Sigoli        - 20/03/2019 - Para os bancos 341/655/KOB/422/SAF/SFF - tratar o sequencia do numero bancario EE_FAXATU sem tratamento com parte do numero (substring)
	@history chamado 048333 - Adriana       - 06/05/2019 - Alterado para somar o valor de SENAR, quando tiver, independente se tem o Valor do Funrural, nas devoluções titulos NDF
	@history chamado TI     - Adriana       - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history chamado 050420 - William       - 23/07/2019 - || OS 051718 || FINANCAS || EDUARDO || 8352 || NOVA CONTA BRADESCO Boleto Bradesco conta vinculada
	@history Chamado 057085 - Abel Babini   - 01/04/20   - Criação de Parâmetro para controlar a geração de GNRE de ICMS ST dos clientes
	@history chamado 056247 - FWNM          - 09/03/2020 - OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 056247 - FWNM          - 18/03/2020 - OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 056247 - FWNM          - 19/03/2020 - OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 059092 - FWNM          - 23/06/2020 - || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK
	@history chamado 059415 - FWNM          - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
	@history chamado TI     - FWNM          - 10/08/2020 - Gravar E1_NUMBCO apenas se estiver em branco
	@history chamado 060632 - Abel Babini   - 17/08/2020 - Ajustar campo D2_EMISSÃO para ficar igual F2_EMISSAO
	@history Ticket 40		- Glauco	    - 01/09/2020 - Gera dados para o registro C113 do SPED Fiscal
	@history Ticket 1165	- Adriana	    - 09/09/2020 - Ajuste função de tela registro C113, padronizando com demais telas apresentadas pelo PE - devido incompatibilidade include #Protheus com DIALOG
	@history Ticket 1715    - William Costa - 16/11/2020 - Novo boleto para a Empresa SAFEGG
	@history Ticket 4220    - William Costa	- 16/11/2020 - Gravar o campo E2_LOGDTHR
	@history Ticket 8465 	- Leonardo P. Monteiro - 22/05/2021 - Implementação dos campos de container, temperatura, lacres SIF, lacres armador, e datas de produção. 
	@history Ticket 8465 	- Leonardo P. Monteiro - 09/08/2021 - Implementação da carga automática das informações referente a inspeção da qualidade. 
	@history Ticket 8465 	- Leonardo P. Monteiro - 13/08/2021 - Inclusão do comando DbselectArea para a tabela ZEX. 
	@history Ticket 68178 	- Leonardo P. Monteiro - 14/02/2022 - Gerar log das informações de exportação gravadas na NFe.
	@history Ticket 63560	- Abel Babini          - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	@history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history Ticket 63560	- Abel Babini          - 13//2022 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
/*/
User Function SF2460I()

	Local _cRet := ""

	Local aDadVol 		:= {} // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
	Local aAreaAtu 		:= GetArea() // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
	Local aDadImp		:= {}
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	Private SF2AREA     := SF2->(GETAREA())
	Private SD2AREA     := SD2->(GETAREA())
	Private SF3AREA     := SF3->(GETAREA())
	Private SE1AREA     := SE1->(GETAREA())
	Private SC6AREA     := SC6->(GETAREA())
	Private SD2AREA     := SD2->(GETAREA())
	Private SA1AREA     := SA1->(GETAREA())	//Incluido para manter ponteiro no SA1 em 10/11/16 por Adriana - chamado 031170
	Private cE1PORTADO  := CriaVar("A6_COD",.F.)
	Private cE1AGEDEP   := CriaVar("A6_AGENCIA",.F.)
	Private cE1CONTA    := CriaVar("A6_NUMCON",.F.)
	Private cTipoBanco  := Space(01)	// Controle Bradesco/Banco ABC
	Private _cNum       := SC5->C5_NUM 
	Private _cConv      := "2228147"
	Private lAchouIdC   := .F.
	Private cCgc        := ''
	Private cQuery      := ""
	Private cRePlac		:= ""
	Private cReCont		:= ""
	Private cReDtFa		:= ""
	Private cReLac1		:= ""
	Private cReLac2		:= ""

	//Chamado: 057085 - Abel Babini      - 01/04/20 - Criação de Parâmetro para controlar a geração de GNRE de ICMS ST dos clientes
	Private lMVCLGST		:= GETMV("MV_#CLGNRE",,.F.) //Gera Título e Guia de Recolhimento do ICMS ST dos clientes
	
	//+------------------------------------------+
	//|Gravando SF2 com volume do SC5            |
	//+------------------------------------------+
	
	// Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
	dbSelectArea("SF2")

	If AllTrim(cEmpAnt) == "01"
		aDadVol := u_VerVolume(SF2->F2_FILIAL,SF2->F2_SERIE,SF2->F2_DOC) //Incluido por Adriana em 11/08/2017 - chamado 036402
	EndIf

	// Retorna dados do processo de exportação coletados pela qualidade.
	if AllTrim(SF2->F2_EST) == "EX"
		fGetInfo(SC5->C5_FILIAL, SC5->C5_NUM, @cRePlac, @cReCont, @cReDtFa, @cReLac1, @cReLac2)
		// Gerar log das informações de exportação gravadas na NFe.
		u_GrLogZBE(Date(),TIME(),cUserName,"GetInfo","SIGAFAT","SF2460I",;
			    "PV: "+ SC5->C5_NUM +", cRePlac="+cRePlac+", cReCont="+cReCont+", cReDtFa"+cReDtFa+", cReLac1="+cReLac1+", cReLac2="+cReLac2,ComputerName(),LogUserName())
	Endif

	RecLock("SF2",.F.)

		If EMPTY(SC5->C5_ESPECI1)
			SF2->F2_ESPECI1 := "VOLUMES"
		Else 
			SF2->F2_ESPECI1	:= SC5->C5_ESPECI1 
		EndIf 

		//Alterado 12/03/12 - Ana. Solicitacao da Rosangela para considerar o volume 2 quando estiver preenchido. (Tratamento para o frango quando possui peso variavel)
		If SC5->C5_VOLUME2 <> 0
			Replace F2_VOLUME1 With SC5->C5_VOLUME2
		Else 
			Replace F2_VOLUME1 With SC5->C5_VOLUME1
		Endif  

		If Len(aDadVol) > 0
			SF2->F2_ESPECI1 := aDadVol[1]
			SF2->F2_VOLUME1 := aDadVol[2]
		EndIf
		
		//@history Ticket 8465 	- Leonardo P. Monteiro - 22/05/2021 - Implementação dos campos de container, temperatura, lacres SIF, lacres armador, e datas de produção. 
		//@history Ticket 8465 	- Leonardo P. Monteiro - 22/05/2021 - Finalizando a integração automática das informações coletadas no processo de inspeção da qualidade. 
		if AllTrim(SF2->F2_EST) == "EX"
			//REPLACE F2_PLACA   WITH iif(!Empty(cRePlac), cRePlac, SC5->C5_PLACA)
			REPLACE F2_CONTAIN WITH iif(!Empty(cReCont), cReCont, SC5->C5_CONTAIN)
			REPLACE F2_DTPROD  WITH iif(!Empty(cReDtFa), cReDtFa, SC5->C5_DTPROD)
			REPLACE F2_TEMPERA WITH SC5->C5_TEMPERA
			REPLACE F2_NLACRE1 WITH iif(!Empty(cReLac1), cReLac1, SC5->C5_NLACRE1)
			REPLACE F2_NLACRE2 WITH iif(!Empty(cReLac2), cReLac2, SC5->C5_NLACRE2)
		else
			//REPLACE F2_PLACA   WITH SC5->C5_PLACA
			REPLACE F2_CONTAIN WITH SC5->C5_CONTAIN
			REPLACE F2_DTPROD  WITH SC5->C5_DTPROD
			REPLACE F2_TEMPERA WITH SC5->C5_TEMPERA
			REPLACE F2_NLACRE1 WITH SC5->C5_NLACRE1
			REPLACE F2_NLACRE2 WITH SC5->C5_NLACRE2
		endif
		If AllTrim(cEmpAnt) != "06"
			REPLACE F2_EMISSAO WITH msDate()
		EndIf

	SF2->( msUnLock() )

	// SF3
	SF3->( dbGoTop() )
	SF3->( dbSetOrder(4) ) //F3_FILIAL, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE
	If SF3->( dbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE) )
		Do While SF3->( !EOF() ) .And. SF3->F3_FILIAL == SF2->F2_FILIAL .And. DTOS(SF3->F3_ENTRADA) == DTOS(dDatabase) .And. SF3->F3_NFISCAL == SF2->F2_DOC .And. SF3->F3_SERIE == SF2->F2_SERIE .And. SF3->F3_CLIEFOR == SF2->F2_CLIENTE .And. SF3->F3_LOJA == SF2->F2_LOJA
			Reclock("SF3",.F.)  
				SF3->F3_EMISSAO := msDate()      
				SF3->F3_ENTRADA := msDate()
			SF3->( msUnlock() )
			
			SF3->( dbSkip() )
		EndDo 
	EndIf

	// SFT
	SFT->( dbGoTop() )
	SFT->( dbSetOrder(1) ) //FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA
	If SFT->( dbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA) ) 
		
		Do While SFT->( !EOF() ) .And. SFT->FT_FILIAL == SF2->F2_FILIAL .And. DTOS(SFT->FT_ENTRADA) == DTOS(dDatabase) .And. SFT->FT_NFISCAL == SF2->F2_DOC .And. SFT->FT_SERIE == SF2->F2_SERIE .And. SFT->FT_CLIEFOR == SF2->F2_CLIENTE .And. SFT->FT_LOJA == SF2->F2_LOJA
			Reclock("SFT",.F.)  
				SFT->FT_EMISSAO := msDate()      
				SFT->FT_ENTRADA := msDate()
			SFT->( MsUnlock() )
	
			SFT->( dbSkip() )
		EndDo
	
	EndIf 
	
	//INICIO chamado 060632 - Abel Babini  - 17/08/2020 - Ajustar campo D2_EMISSÃO para ficar igual F2_EMISSAO
	// SD2
	SD2->( dbGoTop() )
	SD2->( dbSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->( dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) ) 
		
		Do While SD2->( !EOF() ) .And. SD2->D2_FILIAL == SF2->F2_FILIAL .And. SD2->D2_DOC == SF2->F2_DOC .And. SD2->D2_SERIE == SF2->F2_SERIE .And. SD2->D2_CLIENTE == SF2->F2_CLIENTE .And. SD2->D2_LOJA == SF2->F2_LOJA
			Reclock("SD2",.F.)  
				SD2->D2_EMISSAO := msDate()
			SD2->( MsUnlock() )
	
			SD2->( dbSkip() )
		EndDo
	
	EndIf
	//FIM chamado 060632 - Abel Babini  - 17/08/2020 - Ajustar campo D2_EMISSÃO para ficar igual F2_EMISSAO

	/*
	DbSelectArea("SF2")
	Reclock("SF2",.F.)

	If EMPTY(SC5->C5_ESPECI1)
		SF2->F2_ESPECI1 := "VOLUMES"
	ELSE 
		SF2->F2_ESPECI1	:= SC5->C5_ESPECI1 
	ENDIF 

	//Alterado 12/03/12 - Ana. Solicitacao da Rosangela para considerar o volume 2 quando estiver preenchido. (Tratamento para o frango quando possui peso variavel)
	If SC5->C5_VOLUME2 <> 0
		Replace F2_VOLUME1 With SC5->C5_VOLUME2
	Else 
		Replace F2_VOLUME1 With SC5->C5_VOLUME1
	Endif  


	if cEmpAnt = "01"
		U_VerVolume(SF2->F2_FILIAL,SF2->F2_SERIE,SF2->F2_DOC) //Incluido por Adriana em 11/08/2017 - chamado 036402
	endif

	REPLACE F2_DTPROD WITH SC5->C5_DTPROD
	REPLACE F2_TEMPERA WITH SC5->C5_TEMPERA
	REPLACE F2_NLACRE1 WITH SC5->C5_NLACRE1
	if cEmpAnt != "06"
		REPLACE F2_EMISSAO WITH Date()
	Endif	

	DbSelectArea("SF3")
	dbGoTop()
	dbSetOrder(4) //F3_FILIAL, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE
	dbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE) 
	While !Eof() .And. F3_FILIAL == SF2->F2_FILIAL .And. DTOS(F3_ENTRADA) == DTOS(dDatabase) .And. F3_NFISCAL == SF2->F2_DOC .And. F3_SERIE == SF2->F2_SERIE .And. F3_CLIEFOR == SF2->F2_CLIENTE .And. F3_LOJA == SF2->F2_LOJA
		Reclock("SF3",.F.)  
		REPLACE F3_EMISSAO WITH Date()      
		REPLACE F3_ENTRADA WITH Date()
		MsUnlock() 
		dbSkip()
	End 

	DbSelectArea("SFT")
	dbGoTop()
	dbSetOrder(1)
	dbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA) //FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA
	While !Eof() .And. FT_FILIAL == SF2->F2_FILIAL .And. DTOS(FT_ENTRADA) == DTOS(dDatabase) .And. FT_NFISCAL == SF2->F2_DOC .And. FT_SERIE == SF2->F2_SERIE .And. FT_CLIEFOR == SF2->F2_CLIENTE .And. FT_LOJA == SF2->F2_LOJA
		Reclock("SFT",.F.)  
		REPLACE FT_EMISSAO WITH Date()      
		REPLACE FT_ENTRADA WITH Date()
		MsUnlock() 
		dbSkip()
	End 

	MsUnlock()
	*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclusao RNUTTI 17/12/2002                                          ³
	//³ Gravacao do Desconto Financeiro                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	If !SF2->F2_TIPO $ "D/B" .and. SC5->C5_DESCFI > 0    //So NF Venda e Percentual de desconto > 0
		Reclock("SE1",.F.)
			SE1->E1_DESCONT := SF2->F2_VALBRUT * SC5->C5_DESCFI / 100
		SE1->( MsUnlock() )
	EndIf


	//Liberação dos titulos NDF, que não devem cair bloqueados no contas a pagar
	If SF2->F2_TIPO $ "D"

		If Alltrim(SE2->E2_TIPO) == "NDF"	

			Reclock("SE2",.F.)

				SE2->E2_DATALIB := DDATABASE
				SE2->E2_LOGDTHR	:= IIF(EMPTY(SE2->E2_LOGDTHR),DTOC(DATE()) + ' ' + TIME(),SE2->E2_LOGDTHR)
				
			SE2->( MsUnlock() )

			// Adriana Oliveira - 03/10/18 - Chamado 044194 - somar valor titulo + SENAR na devolucao em titulos NDF
			IF SF2->F2_VLSENAR > 0 //alterado por Adriana Chamado 048333 em 06/05/19

				// Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
				
				/*
				cQuery := "UPDATE SE2010 SET "
				cQuery += "E2_VALOR  = E2_VALOR + F2_VLSENAR , "
				cQuery += "E2_SALDO  = E2_VALOR + F2_VLSENAR , "
				cQuery += "E2_VLCRUZ = E2_VALOR + F2_VLSENAR   "
				cQuery += "FROM SE2010 "
				cQuery += "INNER JOIN SF2010 WITH (NOLOCK) "
				cQuery += "ON E2_FILIAL = F2_FILIAL AND E2_NUM = F2_DOC AND E2_PREFIXO = F2_SERIE "
				cQuery += "AND F2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND F2_LOJA = '"+SF2->F2_LOJA+"' "
				cQuery += "AND F2_VLSENAR > 0 AND SF2010.D_E_L_E_T_ = '' " //alterado por Adriana Chamado 048333 em 06/05/19
				cQuery += "WHERE "                                                                                                                          
				cQuery += "E2_FILIAL = '"+SF2->F2_FILIAL+"' AND E2_NUM = '"+SF2->F2_DOC+"' AND E2_PREFIXO = '"+SF2->F2_SERIE+"' "
				cQuery += "AND E2_TIPO = 'NDF' AND E2_FORNECE = '"+SF2->F2_CLIENTE+"' AND E2_LOJA = '"+SF2->F2_LOJA+"' AND SE2010.D_E_L_E_T_ = '' "
				*/

				cQuery := "UPDATE " + RetSqlName("SE2") + " SET "
				cQuery += "E2_VALOR  = E2_VALOR + F2_VLSENAR , "
				cQuery += "E2_SALDO  = E2_VALOR + F2_VLSENAR , "
				cQuery += "E2_VLCRUZ = E2_VALOR + F2_VLSENAR   "
				cQuery += "FROM " + RetSqlName("SE2")
				cQuery += "INNER JOIN " + RetSqlName("SF2") + " WITH (NOLOCK) "
				cQuery += "ON E2_FILIAL = F2_FILIAL AND E2_NUM = F2_DOC AND E2_PREFIXO = F2_SERIE "
				cQuery += "AND F2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND F2_LOJA = '"+SF2->F2_LOJA+"' "
				cQuery += "AND F2_VLSENAR > 0 AND SF2010.D_E_L_E_T_ = '' " //alterado por Adriana Chamado 048333 em 06/05/19
				cQuery += "WHERE "                                                                                                                          
				cQuery += "E2_FILIAL = '"+SF2->F2_FILIAL+"' AND E2_NUM = '"+SF2->F2_DOC+"' AND E2_PREFIXO = '"+SF2->F2_SERIE+"' "
				cQuery += "AND E2_TIPO = 'NDF' AND E2_FORNECE = '"+SF2->F2_CLIENTE+"' AND E2_LOJA = '"+SF2->F2_LOJA+"' AND SE2010.D_E_L_E_T_ = '' "

				//
				
				TCSQLExec(cQuery)       

			ENDIF   
			// FIM Chamado 044194		

		Endif	

	Endif

	_cContain		:=" "
	_cNLacre1		:=" "
	_cNLacre2		:=" "
	_nNTempera		:=0

	
	// ALTERADO POR HCCONSYS EM 06/11/08 PARA GRAVAR NUMERO DO LACRE PARA SER
	// UTILIZADO NO MOMENTO DA ROTERIZACAO DOS PEDIDOS.
	
	// Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	If Alltrim(FWxFilial("SC5")) $ cFilSF .and. AllTrim(cEmpAnt) == cEmpSF
	
		SC9->( dbSetOrder(1) )
		If SC9->( dbSeek(FWxfilial("SC9")+SC5->C5_NUM) )
	
			Reclock("SC5",.F.)
				SC5->C5_NLACRE1 := Iif(!Empty(SC9->C9_LACRE1), SC9->C9_LACRE1, "SEM LACRE")
				SC5->C5_NOTA    := SF2->F2_DOC
				SC5->C5_SERIE   := SF2->F2_SERIE
			SC5->( msUnlock() )

		EndIf

	EndIf

	/*
	if xFilial("SC5") == "02" .and. ALLTRIM(CEMPANT)=="01"
		DbSelectArea("SC9")
		DbSetOrder(1)
		DbSeek(xfilial("SC9")+SC5->C5_NUM)
		SC5->(Reclock("SC5",.F.))
		SC5->C5_NLACRE1 := iIf(!Empty(SC9->C9_LACRE1), SC9->C9_LACRE1, "SEM LACRE")
		SC5->C5_NOTA := SF2->F2_DOC
		SC5->C5_SERIE:= SF2->F2_SERIE
		MsUnlock()
	Endif
	*/

	//
	
	// FIM ALTERACAO HCCONSYS
	//fim da alteracao hcconsys 17/11/08

	//DANIEL 05/03/07
	//+--------------------------------+
	//|Tratamento da NF quando for     |
	//|remessa para exportacao         |
	//+--------------------------------+
	If  AllTrim(SF2->F2_EST) == "EX" .or. FNDCF(SF2->F2_DOC,SF2->F2_SERIE)
		AtuExp()			// Atualiza dados da exportação
	Endif

	dbSelectArea("SE1")
	_cAlias := Alias()
	_cIndex := IndexOrd()
	_cRecno := Recno()

	DbSetOrder(2) 
	If DBSEEK(xFilial("SE1")+SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC)

		While SE1->(!Eof()) .AND. xfilial("SF2")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC) == xFilial("SE1")+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)

			dbSelectArea("SA1")
			SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			_cBcoCli	:= SA1->A1_BCO1                             
			cCgc       := SA1->A1_CGC
			cQuery := "SELECT A6_COD,A6_AGENCIA,A6_NUMCON FROM " + RETSQLNAME("SA6") + " (NOLOCK) "
			cQuery += "WHERE D_E_L_E_T_ = ' ' AND A6_FILIAL = '" + XFILIAL("SA6") + "' AND "
			cQuery += "A6_COD = '" + _cBcoCli + "' AND A6_ZZBLT = 'S' "

			TcQuery cQuery New Alias "TSA6"

			TSA6->(dbGoTop())

			If TSA6->(!Eof())

				dbSelectArea("SA6")
				SA6->(dbSetOrder(1))			
				SA6->( dbSeek(xFilial("SA6")+TSA6->A6_COD + TSA6->A6_AGENCIA + TSA6->A6_NUMCON ) )
				dbSelectArea("SE1")

				cE1PORTADO 	:= TSA6->A6_COD
				cE1AGEDEP 	:= TSA6->A6_AGENCIA
				cE1CONTA 	:= TSA6->A6_NUMCON

				fCalcBlt(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)	// Gera Nosso Numero

			Endif	

			TSA6->(dbCloseArea())

			dbSelectArea("SE1")

			Reclock("SE1",.F.)
				SE1->E1_ROTEIRO 	:= SF2->F2_ROTEIRO
				SE1->E1_BANCO 		:= _cBcoCli
				If AllTrim(cEmpAnt) == "01"
					SE1->E1_XCGC 	:= IIF(ALLTRIM(cCgc) <> '',SUBSTR(cCgc,1,8),SUBSTR(SA1->A1_CGC,1,8))
				EndIf	
			SE1->( MsUnlock() )

			SE1->(dbSkip())

		EndDo

	ENDIF

	dbSelectArea(_cAlias)
	dbSetOrder(_cIndex)
	dbGoto(_cRecno)

	//Endif

	// Acrescentado por Michel em 12/09/08 - Fim 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona Item contabil em SE1
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//+-----------------------------+
	//|daniel 22/02/07              |
	//|Incluido busca no SE1
	//+-----------------------------+
	//|ALTERADO EM 10/05/07 POR HCCONSYS(HEVERSON)               |
	//|Alteracao o indice utilizado no SE1 e atualizacao do campo E1_ITEMD
	//+-----------------------------+

	DBSELECTAREA("SE1")
	DBSETORDER(2)
	If DBSEEK(xFilial("SE1")+SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC)	

		While !EOF() .AND. xfilial("SF2")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC) == xFilial("SE1")+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)

			IF empty(SE1->E1_ITEMD)
				dbSelectArea("SD2")
				DBSETORDER(3)

				If DBSEEK(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			
					While	!EOF() .AND. xfilial("SD2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)==xFilial("SE1")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)
			
						if !(Empty(SD2->D2_ITEMCC))
			
							dbSelectArea("SE1")
			
							Reclock("SE1",.F.)
								Replace SE1->E1_ITEMD With SD2->D2_ITEMCC
							SE1->( MsUnlock() )
			
							Exit
			
						Else
			
							DbSelectArea("SD2")
							SD2->(DbSkip())
			
						Endif     
			
					Enddo
			
				Endif		
			
			Endif
			
			DbSelectArea("SE1")
			SE1->(dbSkip())
		
		Enddo  

	EndIf

	// INICIO CHAMADO 031745 WILLIAM COSTA - 26/01/2017 INFORMAR NOTA FISCAL ORIGINAL QUANDO FOR NF REMESSA PARA CONTA ORDERM
	DBSELECTAREA("SD2")
	DBSETORDER(3)
	IF DBSEEK(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)

		//PARAMETRO CONTEM AS SEGUINTES CFOPS 5923/6923/5924/6924
		IF ALLTRIM(SD2->D2_CF) $ ALLTRIM(GETMV("MV_#CFOPRC"))
			TelaRemessa()
		ENDIF

	ENDIF                  

	//SD2->(dbCloseArea()) 

	//Chamado: 057085 - Abel Babini      - 01/04/20 - Criação de Parâmetro para controlar a geração de GNRE de ICMS ST dos clientes
	IF lMVCLGST //chamado:045310
		FIN040INC()
	ENDIF

	// FINAL CHAMADO 031745 WILLIAM COSTA - 26/01/2017 INFORMAR NOTA FISCAL ORIGINAL QUANDO FOR NF REMESSA PARA CONTA ORDERM

	fAjustaCDD() // chamado 40		- Glauco	   - 01/09/2020

	SF2->(RestArea(SF2AREA))
	SD2->(RestArea(SD2AREA))
	SF3->(RestArea(SF3AREA))
	SE1->(RestArea(SE1AREA))
	SC6->(RestArea(SC6AREA))
	//SD2->(RestArea(SD2AREA))
	SA1->(RestArea(SA1AREA))	//Incluido para manter ponteiro no SA1 em 10/11/16 por Adriana - chamado 031170

	RestArea( aAreaAtu ) // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020

Return

/* Retorna as informações do processo de exportação */
Static Function fGetInfo(cSC5Fil, cSC5Num, cRePlac, cReCont, cReDtFa, cReLac1, cReLac2)

	Local cQuery	:= ""
	Local cEOL      := Chr(13)+chr(10)
	Local dDtIni	:= Stod("")
	Local dDtFim	:= Stod("")
	
	DbSelectArea("ZEX")
	// Gerar log das informações de exportação gravadas na NFe.
    cQuery := " SELECT ZEX_NUMERO, ZEX_PLACA,ZEX_CONTAI, ZEX_LACRE1, ZEX_LACRE2, MIN(ZEX_DTFABR) DT_MIN, MAX(ZEX_DTFABR) DT_MAX  "+ cEOL
    cQuery += " FROM "+ RetSqlName("ZEX") +" (NOLOCK) ZEX "+ cEOL
    cQuery += " WHERE ZEX.D_E_L_E_T_='' AND ZEX.ZEX_FILIAL='"+ cSC5Fil +"' AND ZEX.ZEX_FILIAL='"+ cSC5Fil +"' AND ZEX.ZEX_NUMERO='"+ cSC5Num +"' "+ cEOL
	cQuery += " GROUP BY ZEX_NUMERO, ZEX_PLACA,ZEX_CONTAI, ZEX_LACRE1, ZEX_LACRE2 "
	cQuery += " ORDER BY ZEX_NUMERO, ZEX_PLACA,ZEX_CONTAI, ZEX_LACRE1, ZEX_LACRE2; "

    Tcquery cQuery ALIAS "QINF" NEW

    TCSETFIELD("QINF","DT_MIN"		,"D",08,00)
	TCSETFIELD("QINF","DT_MAX"		,"D",08,00)
    
    IF QINF->(!EOF())
		if !Empty(QINF->ZEX_PLACA)
			cRePlac := Alltrim(QINF->ZEX_PLACA)
		endif

		if !Empty(QINF->ZEX_CONTAI)
			cReCont := Alltrim(QINF->ZEX_CONTAI)
		endif

		if !Empty(QINF->ZEX_LACRE1)
			cReLac1 := Alltrim(QINF->ZEX_LACRE1)
		endif

		if !Empty(QINF->ZEX_LACRE2)
			cReLac2 := Alltrim(QINF->ZEX_LACRE2)
		endif

		if !Empty(QINF->DT_MIN) .AND. !Empty(QINF->DT_MAX)
			if QINF->DT_MIN == QINF->DT_MAX
				cReDtFa := Dtoc(QINF->DT_MIN)
			else
				cReDtFa := Dtoc(QINF->DT_MIN) +" A "+ Dtoc(QINF->DT_MAX)
			endif
		endif

		//QINF->(DbSkip())
	ENDIF

	QINF->(DBCLOSEAREA())
return 


/*/{Protheus.doc} Static Function ATUEXP
	Utilizado na geracao da NF de saida de Exportacao: Checando se a UF do cliente = "EX" e se o primeiro digito do CFOP = 7
	Utilizado para alimentar informacoes sobre CONTAINER, NUMERO DO LACRE DO CONTAINER/SIF e TEMPERATURA
	@type  Static Function
	@author Heraldo C. Hebling
	@since 23/06/2005
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)

	@history Ticket 68663  - Leonardo P. Monteiro   - 25/02/2022 - Inibir a impressão dos lacres do armador.
/*/
Static Function AtuExp()
	//@history Ticket 8465 	- Leonardo P. Monteiro - 22/05/2021 - Implementação dos campos de container, temperatura, lacres SIF, lacres armador, e datas de produção. 
	_cNumContai		:= SF2->F2_CONTAIN
	_cNLacreConta	:= SF2->F2_NLACRE1
	_cNLacreSIF		:= SF2->F2_NLACRE2
	_cTemp			:= SF2->F2_TEMPERA
	_cDtprod        := SF2->F2_DTPROD

	@ 00,000 TO 280,500 DIALOG oDlg1 TITLE "DADOS DO EMBARQUE"

	@  05,010 SAY "PEDIDO: " +  _cNum + "   NOTA: " + SF2->F2_DOC
	@  15,010 TO 120,240 TITLE "Informações de Embarque "
	@  25,015 SAY " NUMERO DO CONTAINER      : "
//@history Ticket 68663  - Leonardo P. Monteiro   - 25/02/2022 - Inibir a impressão dos lacres do armador.
	//@  45,015 SAY " NUMERO LACRE CONTAINER: "
	@  45,015 SAY " NUMERO LACRE OFICIAL(SIF): "             // 15/03/19-Chamado:047943 - Fernando Sigoli
	@  65,015 SAY " TEMPERATURA DE EMBARQUE: "
	@  85,015 SAY " DATA DE PRODUCAO: "

	@  25,110 GET _cNumContai 	Valid !Vazio()   picture "@!"		Size 080,009
	//@history Ticket 68663  - Leonardo P. Monteiro   - 25/02/2022 - Inibir a impressão dos lacres do armador.
	//@  45,110 GET _cNLacreConta Valid !Vazio()   picture "@!"		Size 080,009
	@  45,110 GET _cNLacreSIF 	Valid !Vazio()   picture "@!"		Size 080,009
	@  65,110 GET _cTemp 		Valid !Vazio()   picture "999.99"	Size 080,009
	@  85,110 GET _cDtprod 		Valid !Vazio()   picture "@!"		Size 080,009

	@ 125,100 BMPBUTTON TYPE 01 ACTION GravaSF2()
	@ 125,130 BMPBUTTON TYPE 02 ACTION Close(oDlg1)

	ACTIVATE DIALOG oDlg1 CENTER

Return

/*/{Protheus.doc} Static Function GRAVASF2
	(long description)
	@type  Static Function
	@author Heraldo C. Hebling
	@since 23/06/2005
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GravaSF2()

	Reclock("SF2",.F.)
		SF2->F2_CONTAIN		:=  _cNumContai
		//SF2->F2_NLACRE1		:=  _cNLacreConta
		SF2->F2_NLACRE2		:=	 _cNLacreSIF
		SF2->F2_TEMPERA		:=	 _cTemp
		SF2->F2_DTPROD       := _cDtprod
	MsUnlock()

	Close(oDlg1)
	
Return

/*/{Protheus.doc} Static Function FNDCF
	VERIFICA SE O TIPO DE CF E REMESSA PARA EXPORTACAO
	@type  Static Function
	@author Heraldo C. Hebling
	@since 03/05/2007
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function FNDCF(_nf,_serie)

	//+------------------------------------------------------+
	//|Informar os CFOPs para movimentacoes equiparadas a    |
	//|exportacao - CIAP Modelo C                            |
	//+------------------------------------------------------+
	Local _cCfops := ALLTRIM(GETMV("MV_CFOEXPD",,""))
	Local _lRet   := .F.
	Local _cFnd   := ''

	Local aAreaSD2 := SD2->( GetArea() ) // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020

	//DbselectArea("SD2")
	SD2->( DBSETORDER(3) )

	//+----------------------------------------------+
	//|VARRENDO O SD2 EM BUSCA DAS CF                |
	//|CASO HAJA ALGUMA CF 6501 REMESSA PARA EXPORT  |
	//|IMPRIMO NOTA COMO EXPOERTACAO                 |
	//+----------------------------------------------+
	IF SD2->( DBSEEK(FWxFilial("SD2")+_nf+_serie,.T.) )

		Do While SD2->( !EOF() ) .and. SD2->D2_DOC == SF2->F2_DOC .and. SD2->D2_SERIE == SF2->F2_SERIE
	
			//+---------------------------------------------------------+
			//|VERIFICANDO SE O CFOP E PARA MOVIMENTACOES DE EQUIPARACAO|
			//|PARA EXPORTACAO                                          |
			//+---------------------------------------------------------+
			IF TRIM(SD2->D2_CF) $ _cCfops
				_cFnd+='S'
			Else
				_cFnd+='N'
			EndIf
			
			SD2->( DBSKIP() )
		
		EndDo
	
	Else
	
		_lRet := .F.
	
	EndIf

	If 'S' $ _cFnd

		_lRet := .T.

	EndIf

	RestArea( aAreaSD2 ) // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020

Return(_lRet)

/*/{Protheus.doc} Static Function fCalcBlt
	Funcao para calculo do Nosso Numero conf. solicitacao Reginaldo ADORO
	@type  Static Function
	@author HCConsys
	@since Ago/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fCalcBlt(cPrefixo,cNum,cParcela,cTipTit)

	Local lRet				:= .T.
	Local aArea				:= GetArea()

	// Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
	Local aAreaSF2 := SF2->( GetArea() )
	Local aAreaSE4 := SE4->( GetArea() )
	Local aAreaSE1 := SE1->( GetArea() )
	//

	Private _cDV_NNUM   	:= SPACE(01)
	Private _cDV_SAFRA  	:= SPACE(01)
	Private _cDV_BARRA  	:= SPACE(01)
	Private _RE_Campo       := SPACE(1) // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
	Private _ccBARRA    	:= ""
	Private _cLineDig   	:= ""
	Private _cNumBoleta 	:= ""
	Private _cnDigito   	:= ""
	Private _cPedaco    	:= ""
	Private _cNome_Bco 		:= Space(20)
	Private _cCod_Comp		:= Space(07)
	Private	_cAg_Conta  	:= Space(08)
	Private	_cCarteira  	:= Space(02)
	Private	_cAceite    	:= Space(01)
	Private	_cB_Campo  		:= ""
	Private _cCodBarras 	:= ""
	Private cDigNNr     	:= ""
	Private n6_Dig      	:=0
	Private n2_Dig      	:=0
	Private n3_Dig      	:=0
	Private n4_Dig      	:=0
	Private n5_Dig      	:=0
	Private n1_Dig      	:=0
	Private nDigCB      	:= 0
	Private cVencto     	:= ""
	Private cVlrFim     	:= ""
	Private _nVlrBol    	:= 0
	Private _nVlrAbat   	:= 0
	Private cIDCNAB		    := "" //CriaVar("E1_IDCNAB",.F.) // Chamado n. 059415 - FWNM         - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
	// ALEX BORGES 20/12/11
	Private _nQtdBol        := 0
	//Private   lRet	     	:= .f.
	Private cQuery := ""

	PARAMTYPE 0	VAR cPrefixo	AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_PREFIXO")[1])
	PARAMTYPE 1	VAR cNum		AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_NUM")[1])
	PARAMTYPE 2	VAR cParcela	AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_PARCELA")[1])
	PARAMTYPE 3	VAR cTipTit		AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_TIPO")[1])

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 18/06/2020
	// Condicao Pagto de adiantamento não deve gerar boleto para NF pois o mesmo já foi gerado no RA
	If !IsInCallStack("u_GeraRAPV")

		If ExistFIE(cPrefixo,cNum,cParcela,cTipTit)
			Return .F.
		EndIf

	EndIf
	//

	dbSelectArea("SEE")
	SEE->(dbSetOrder(1))	//EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	If SEE->(dbSeek(xFilial("SEE")+ cE1PORTADO + cE1AGEDEP + cE1CONTA))

		// ALEX BORGES 20/12/11
		_nQtdBol := Val( SEE->EE_FAXFIM)  - Val( SEE->EE_FAXATU) 		
		_cMens := "A faixa atual do banco " +cE1PORTADO +" Ag." + cE1AGEDEP + " C/C "+ cE1CONTA+" esta chegando ao fim, está faltando "+Str(_nQtdBol)+" boletos. Favor verificar com o banco."

		If  _nQtdBol <= GetMv("MV_NBOLAVI")		
			lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),GetMv("MV_FINMAIL"),_cMens,"FAIXA DO BANCO"+cE1PORTADO +"CHEGANDO AO FIM","") //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
		EndIf

		If cE1PORTADO == "033"
		
			_cNumBoleta := Substr(SEE->EE_FAXATU,1,5) + StrZero( (Val( Substr(SEE->EE_FAXATU,6,7) )+1),07)
		
		ElseIf cE1PORTADO == "399"	// HSBC
		
			_cNumBoleta := Substr(SEE->EE_FAXATU,1,5) + StrZero( (Val( Substr(SEE->EE_FAXATU,6,5) )+1),05)
		
		ElseIf cE1PORTADO == "637"	// SOFISA
			
			_cNumBoleta := Substr(SEE->EE_FAXATU,1,5) + StrZero( (Val( Substr(SEE->EE_FAXATU,6,5) )+1),05)
		
			//ElseIf cE1PORTADO $ "422/SAF/SFF"                                                                     //comentado: /chamado: 048048 - Fernando Sigoli 20/03/2019
			//_cNumBoleta := Substr(SEE->EE_FAXATU,1,4) + StrZero( (Val( Substr(SEE->EE_FAXATU,5,4) )+1),04)        //comentado: /chamado: 048048 - Fernando Sigoli 20/03/2019
		
		ElseIf cE1PORTADO $ "341/655/KOB/422/SAF/SFF/ITV"    //chamado: 048048 - Fernando Sigoli 20/03/2019
		
			_cNumBoleta := StrZero(Val(AllTrim(SEE->EE_FAXATU))+1,8) 
		
		ElseIf cE1PORTADO == "246"	// ABC
		
			_cNumBoleta := Substr(SEE->EE_FAXATU,1,5) + StrZero( (Val( Substr(SEE->EE_FAXATU,6,6) )+1),06)
		
		Elseif cE1PORTADO == "001"
		
			_cNumBoleta := "2228147" + StrZero( (Val( Substr(SEE->EE_FAXATU,1,10) )+1),10) 
			_cNBoletaBB := StrZero(Val(SubStr(SEE->EE_FAXATU,1,10))+1,10)	
		
		Elseif cE1PORTADO == "104" 	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		
			_cNumBoleta := "14000" + StrZero( (Val( Substr(SEE->EE_FAXATU,1,12) )+1),12) 
			_cNBoletCEF := StrZero(Val(SubStr(SEE->EE_FAXATU,1,12))+1,12)
		
		Else
		
			_cNumBoleta := Substr(SEE->EE_FAXATU,1,4) + StrZero( (Val( Substr(SEE->EE_FAXATU,5,7) )+1),07) 

		Endif

		// Chamado n. 059415 - FWNM         - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
		/*
		If !FindFunction("U_RtPrxIDC")
			ExUserException("A função necessária para o levantamento do próximo ID CNAB (RtPrxIDC) não pode ser encontrada!")
			Return .F.
		Else
			cIDCNAB := U_RtPrxIDC(cPrefixo,cNum,cParcela,cTipTit,.F.)
		Endif
		*/
		//

		// Atualizacao do campo de multa mora dia
		If SEE->EE_ZZMORA > 0	
			_nVlrBol	:= SE1->E1_VALOR - SE1->E1_ISS - SE1->E1_INSS - SE1->E1_CSLL - SE1->E1_COFINS - SE1->E1_PIS - SE1->E1_VALLIQ
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30

			If nValMora > 0   
				RecLock("SE1",.F.)
					SE1->E1_VLMULTA := nValMora
				SE1->( MsUnLock() ) // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
				//MsUnLock("SEE")
			EndIf

		Endif
	
	Else                                                                                               

		lRet := .f. 
		MsgInfo("CNAB nao configurado para este Banco. Boleto para impressao cancelada para este titulo. Verifique!!")
		RestArea(aARea)
		Return(lRet)

	Endif

	// Posiciona tabela de Bancos
	dbSelectArea("SA6")
	SA6->(dbSetOrder(1))
	dbSeek( xFilial("SA6")+ cE1PORTADO + cE1AGEDEP + cE1CONTA )                      

	dbSelectArea("SEE")
	SEE->(dbSeek(xFilial("SEE")+ cE1PORTADO + cE1AGEDEP + cE1CONTA ))

	dbSelectArea("SE1")
	If cE1PORTADO == "KOB"

		//NNumDV( "2001" + "91898" + "109" + Alltrim(_cNumBoleta)  ) // Comentado - 19/12/18 Fernando Sigoli Chamado:  TI 
		NNumDV( "2001" + "02680" + "109" + Alltrim(_cNumBoleta)  )  //19/12/18 Fernando Sigoli Chamado:  TI 

	ElseIf cE1PORTADO == "104" 	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17

		NNumDV(Alltrim(_cNumBoleta))

	Else                                                                     // Carteira 

		NNumDV( SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5) + "109" + Alltrim(_cNumBoleta)  )	// Calculo dos Boletos

	Endif

	_cNumBoleta  := _cNumBoleta 		// IIF(cE1PORTADO == "341",cAuxNNr,AllTrim(_cNumBoleta))
	_cDV_NNUM    := _cDV_NNUM 			// IIF(cE1PORTADO == "341",Str(cDigNNr,1),_cDV_NNUM)

	// Alterado por Adriano Dias 25102011
	If cE1PORTADO == "001"

		If Empty(SE1->E1_NUMBCO) // @history chamado TI     - FWNM         - 10/08/2020 - Gravar E1_NUMBCO apenas se estiver em branco

			cQuery := "UPDATE " 		+ RETSQLNAME("SE1") + " SET "
			cQuery += "E1_BANCO   = '" 	+ cE1PORTADO + "',  " 
			cQuery += "E1_NUMBCO  = '" 	+ (_cConv)+AllTrim(_cNBoletaBB) + "',  " 	// Numero da Boleta sem o Digito
			cQuery += "E1_NUMBCO1 = '" 	+ (_cConv)+AllTrim(_cNBoletaBB) + "',  " 	    // Numero da Boleta sem o Digito (cópia) - Paulo - TDS - 26/05/11
			//cQuery += "E1_IDCNAB  = '" 	+ cIDCNAB + "',  " // Chamado n. 059415 - FWNM         - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
			cQuery += "E1_DVNBCO  = '" 	+ Alltrim(_cDV_NNUM) + "' "		// Campo customizado para guardar informacao do Digito.
			cQuery += "WHERE "
			cQuery += "E1_FILIAL = '" 	+ xFilial("SE1") + "' AND "
			cQuery += "E1_PREFIXO = '" 	+ SE1->E1_PREFIXO + "' AND "
			cQuery += "E1_NUM = '" 		+ SE1->E1_NUM + "' AND "
			cQuery += "E1_PARCELA =  '" + SE1->E1_PARCELA  + "' AND "
			cQuery += "E1_TIPO   <>  'AB-' AND " //chamado 027642, alterado para não carregar o AB- William Costa
			cQuery += "D_E_L_E_T_ =  ' ' " 

			If TCSQLExec(cQuery) != 0
				Aviso(FunDesc(),TCSQLERROR(),{"OK"})
			Else
				TcSqlExec("COMMIT")
			EndIf
		
		EndIf

	Else 
		
		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/04/2020
		If AllTrim(FunName()) == "RPC" .or. IsInCallStack("u_GeraRAPV")

			If Empty(SE1->E1_NUMBCO) // @history chamado TI     - FWNM         - 10/08/2020 - Gravar E1_NUMBCO apenas se estiver em branco

				RecLock("SE1", .F.)
					
					SE1->E1_BANCO   := cE1PORTADO
					SE1->E1_NUMBCO  := AllTrim(_cNumBoleta)
					SE1->E1_NUMBCO1 := AllTrim(_cNumBoleta)
					SE1->E1_DVNBCO  := Alltrim(_cDV_NNUM)
					//SE1->E1_IDCNAB  := cIDCNAB // Chamado n. 059415 - FWNM         - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 

				SE1->( msUnLock() )

			EndIf
		//

		Else
		
			If Empty(SE1->E1_NUMBCO) // @history chamado TI     - FWNM         - 10/08/2020 - Gravar E1_NUMBCO apenas se estiver em branco

				cQuery := "UPDATE " 		+ RETSQLNAME("SE1") + " SET "
				cQuery += "E1_BANCO   = '" 	+ cE1PORTADO + "',  " 
				cQuery += "E1_NUMBCO  = '" 	+ AllTrim(_cNumBoleta) + "',  " 	// Numero da Boleta sem o Digito
				cQuery += "E1_NUMBCO1 = '" 	+ AllTrim(_cNumBoleta) + "',  " 	    // Numero da Boleta sem o Digito (cópia) - Paulo - TDS - 26/05/11
				//cQuery += "E1_IDCNAB  = '" 	+ cIDCNAB + "',  " // Chamado n. 059415 - FWNM         - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
				cQuery += "E1_DVNBCO  = '" 	+ Alltrim(_cDV_NNUM) + "' "		// Campo customizado para guardar informacao do Digito.
				cQuery += "WHERE "
				cQuery += "E1_FILIAL = '" 	+ xFilial("SE1") + "' AND "
				cQuery += "E1_PREFIXO = '" 	+ SE1->E1_PREFIXO + "' AND "
				cQuery += "E1_NUM = '" 		+ SE1->E1_NUM + "' AND "
				cQuery += "E1_PARCELA =  '" + SE1->E1_PARCELA  + "' AND "
				cQuery += "E1_TIPO   <>  'AB-' AND " //chamado 027642, alterado para não carregar o AB- William Costa
				cQuery += "D_E_L_E_T_ =  ' ' "

				If TCSQLExec(cQuery) != 0
					Aviso(FunDesc(),TCSQLERROR(),{"OK"})
				Else
					TcSqlExec("COMMIT")
				EndIf
			
			EndIf

		EndIf

	Endif 

	If cE1PORTADO == "001"

		cQuery := "UPDATE "+RETSQLNAME("SEE")+" SET EE_FAXATU = '"+AllTrim(_cNBoletaBB)+ "' "
		cQuery += "WHERE EE_FILIAL  = '"+xFilial("SEE")+"' AND "
		cQuery += "      EE_CODIGO  = '"+cE1PORTADO+"'     AND "
		cQuery += "      EE_AGENCIA = '"+cE1AGEDEP+"'      AND "
		cQuery += "      EE_CONTA   = '"+cE1CONTA+"'       AND "
		cQuery += "      D_E_L_E_T_	= ' ' "

		If TCSQLExec(cQuery) != 0
			Aviso(FunDesc(),TCSQLERROR(),{"OK"})
		Else
			TcSqlExec("COMMIT")		
		EndIf

	ElseIf cE1PORTADO == "104" 	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17

		cQuery := "UPDATE "+RETSQLNAME("SEE")+" SET EE_FAXATU = '"+AllTrim(_cNBoletCEF)+ "' "
		cQuery += "WHERE EE_FILIAL  = '"+xFilial("SEE")+"' AND "
		cQuery += "      EE_CODIGO  = '"+cE1PORTADO+"'     AND "
		cQuery += "      EE_AGENCIA = '"+cE1AGEDEP+"'      AND "
		cQuery += "      EE_CONTA   = '"+cE1CONTA+"'       AND "
		cQuery += "      D_E_L_E_T_	= ' ' "

		If TCSQLExec(cQuery) != 0
			Aviso(FunDesc(),TCSQLERROR(),{"OK"})
		Else
			TcSqlExec("COMMIT")		
		EndIf

	Else   

		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/04/2020
		If AllTrim(FunName()) == "RPC" .or. IsInCallStack("u_GeraRAPV")

			RecLock("SEE", .F.)
				SEE->EE_FAXATU := AllTrim(_cNumBoleta)
			SEE->( msUnLock() )
		//
		Else

			cQuery := "UPDATE "+RETSQLNAME("SEE")+" SET EE_FAXATU = '"+AllTrim(_cNumBoleta)+ "' "
			cQuery += "WHERE EE_FILIAL  = '"+xFilial("SEE")+"' AND "
			cQuery += "      EE_CODIGO  = '"+cE1PORTADO+"'     AND "
			cQuery += "      EE_AGENCIA = '"+cE1AGEDEP+"'      AND "
			cQuery += "      EE_CONTA   = '"+cE1CONTA+"'       AND "
			cQuery += "      D_E_L_E_T_	= ' ' "

			If TCSQLExec(cQuery) != 0
				Aviso(FunDesc(),TCSQLERROR(),{"OK"})
			Else
				TcSqlExec("COMMIT")		
			EndIf

		EndIf

	Endif	

	Do Case
		// Atenção: Acrescentar aqui os codigos dos demais bancos
		Case cE1PORTADO == "001"	// BANCO DO BRASIL
			_cNome_Bco := "Banco do Brasil"
			_cCod_Comp := "|001-9|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Substr(SA6->A6_AGENCIA,5,1)+"/"+Substr(SA6->A6_NUMCON,1,5)+"-"+Substr(SA6->A6_NUMCON,7,1)
			_cCarteira := "17/019" 
			_cAceite   := "N"

		Case cE1PORTADO $ "422/SAF"	// SAFRA   ALEX BORGES 03/04/12
			//Case cE1PORTADO == "422"	// SAFRA
			_cNome_Bco := "Banco Safra SA"
			_cCod_Comp := "|422-7|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,5)+"."+Substr(SA6->A6_NUMCON,1,8)+"-"+Substr(SA6->A6_NUMCON,10,1)
			_cCarteira := "01"
			_cAceite   := "N"				

		Case cE1PORTADO $ "SFF"	//fernando sigoli 10/05/2018
			_cNome_Bco := "Banco Safra SA"
			_cCod_Comp := "|422-7|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,5)+"."+Substr(SA6->A6_NUMCON,1,8)+"-"+Substr(SA6->A6_NUMCON,10,1)
			_cCarteira := "02"
			_cAceite   := "N"			

		Case cE1PORTADO $ "237|RED|BRD"	// Bradesco
			_cNome_Bco := "BRADESCO"
			_cCod_Comp := "|237-2|"
			If cE1PORTADO = "RED"
				_cAg_Conta := Substr(SA6->A6_AGENCIA,2,4)+"-"+SA6->A6_DVAGE+"/"+Substr(SA6->A6_NUMCON,4,6)+"-"+SA6->A6_DVCTA
			Else
				_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Substr(SA6->A6_AGENCIA,5,1)+"/0"+Substr(SA6->A6_NUMCON,1,6)+"-"+Substr(SA6->A6_NUMCON,8,1)
			EndIf
			_cCarteira := "09"
			_cAceite   := "N"
		
		// *** INICIO CHAMADO 050420	
		Case cE1PORTADO == "BRV"	
			_cNome_Bco := "BRADESCO"
			_cCod_Comp := "|237-2|"
			_cAg_Conta := ALLTRIM(SA6->A6_AGENCIA)+"-"+Alltrim(SA6->A6_DVAGE)+"/"+ALLTRIM(SA6->A6_NUMCON)+"-"+Alltrim(SA6->A6_DVCTA)
			_cCarteira := "02"
			_cAceite   := "N"	
		// *** FINAL CHAMADO 050420
		
		Case cE1PORTADO == "246"	// ABC
			_cNome_Bco := "BRADESCO"
			_cCod_Comp := "|237-2|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Substr(SA6->A6_AGENCIA,5,1)+"/"+Substr(SA6->A6_NUMCON,1,7)+"-"+Substr(SA6->A6_NUMCON,8,1)
			_cCarteira := "009"
			_cAceite   := "N"			

		Case cE1PORTADO = "399"	// HSBC
			_cNome_Bco := "HSBC"
			_cCod_Comp := "|399-9|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7)
			_cCarteira := "CSB"
			_cAceite   := "N"

		Case cE1PORTADO == "033"			// BANESPA SANTANDER
			_cNome_Bco := "SANTANDER"
			_cCod_Comp := "|033-7|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"/" + "1809571"
			_cCarteira := "101"
			_cAceite   := "N"

		Case cE1PORTADO $ "341/655/ITV"			// BANCO ITAU
			_cNome_Bco := "Banco Itaú SA"
			_cCod_Comp := "|341-7|"
			_cAg_Conta := SUBSTR(SA6->A6_AGENCIA,1,4) + "/" + SUBSTR(SA6->A6_NUMCON,1,5)+"-"+IIF(ALLTRIM(SA6->A6_DVCTA) == '',SUBSTR(SA6->A6_NUMCON,Len(Alltrim(SA6->A6_NUMCON)),1),SA6->A6_DVCTA)
			_cCarteira := "109"
			_cAceite   := "A" 

		Case cE1PORTADO = "637"	// HSBC
			_cNome_Bco := "HSBC"
			_cCod_Comp := "|399-9|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"/" + Substr(SA6->A6_NUMCON,1,5) + "-" + Substr(SA6->A6_NUMCON,6,2)
			_cCarteira := "CSB"
			_cAceite   := "N"  

		Case cE1PORTADO = "104"	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
			_cNome_Bco := "CX EC.FEDERAL"
			_cCod_Comp := "|104-0|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+" / "+Posicione("SEE",1,xFilial("SEE")+cE1PORTADO+cE1AGEDEP+cE1CONTA,"EE_CODEMP") 	// Somente na impressao
			_cCarteira := "14"
			_cAceite   := "N" 

	EndCase

	dbSelectArea("SF2")
	dbSetOrder(1)
	dbseek(xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO)

	dbSelectArea("SE4")
	dbSetorder(1)
	dbSeek(xFilial("SE4")+SF2->F2_COND)

	//Calculo do fator de Vencimento para atender ao Banco do Brasil
	If IsInCallStack("u_GeraRAPV") .or. IsInCallStack("u_GeraBlPV") .or. IsInCallStack("u_RunHCRFB") // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 19/06/2020
		_cFatorVcto := Str( ( msDate() - Ctod("07/10/1997") ),4 ) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 18/06/2020
	Else
		_cFatorVcto := Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 )
	EndIf

	DbSelectArea("SE1")
	_nVlrBol	:= SE1->E1_VALOR 
	_nVlrAbat	:= SE1->E1_VALLIQ

	Do Case

		Case cE1PORTADO == "001" // Banco do Brasil
			//Codigo convenio 7 posições - Mauricio 21/10/11.
			// Calculo do Codigo de Barras
			_cB_Campo 	:= "001" 												// 03 posicoes   B
			_cB_Campo 	+= "9" 													// 01
			_cB_Campo 	+= _cFatorVcto											// 04 posicoes 
			_cB_Campo 	+= StrZero(Int(Round(_nVlrBol*100,2)),10)   	        // 10 posicoes
			_cB_Campo   += "000000"                                             // Zeros 6 posições
			_cB_Campo   += Alltrim(_cNumboleta)+"17"                            //Nosso numero 17 posições(CONVENIO+SEQUENCIAL)+ 02 posições Carteira
			//_cB_Campo 	+= Alltrim(_cNumboleta) + Substr(cE1AGEDEP,1,4)+StrZero(Val(SubStr(cE1CONTA,1,5)),8)+"17" 

			BarraDV()

			_cCodBarras := cE1PORTADO  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras += "000000"
			_cCodBarras += Alltrim(_cNumboleta) + "17"
			//_cCodBarras += Alltrim(_cNumboleta) + Substr(cE1AGEDEP,1,4)+StrZero(Val(SubStr(cE1CONTA,1,5)),8)+"17" 										

		Case cE1PORTADO $ "422/SAF/SFF" // Banco Safra   ALEX BORGES 03/04/12
			//Case cE1PORTADO == "422" // Banco Safra

			_cB_Campo := "422"  + "9" + _cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo += "7"+Substr(SA6->A6_AGENCIA,1,5)+Substr(SA6->A6_NUMCON,1,8)+Substr(SA6->A6_NUMCON,10,1)+Alltrim(_cNumboleta)+_cDV_NNUM+"2"

			BarraDV()

			_cCodBarras := "422"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras += "7"+Substr(SA6->A6_AGENCIA,1,5)+Substr(SA6->A6_NUMCON,1,8)+Substr(SA6->A6_NUMCON,10,1)+Alltrim(_cNumboleta)+_cDV_NNUM+"2"

		Case cE1PORTADO $ "237|RED|BRD" // Bradesco

			_cB_Campo := "237"  + "9" + _cFatorVcto
			_cB_Campo := _cB_Campo + StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo := _cB_Campo + Substr(SA6->A6_AGENCIA,1,4)+"09"+Alltrim(_cNumboleta) +Substr(SA6->A6_NUMCON,1,6) +Substr(SA6->A6_NUMCON,8,1)+"0" 

			BarraDV()

			_cCodBarras := "237"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras := _cCodBarras + StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras := _cCodBarras + Substr(SA6->A6_AGENCIA,1,4)+"09"+Alltrim(_cNumboleta) +Substr(SA6->A6_NUMCON,1,6) +Substr(SA6->A6_NUMCON,8,1) +"0" 
		
		// *** INICIO CHAMADO 050420
		Case cE1PORTADO $ "BRV" // Bradesco

			_cB_Campo := "237"  + "9" + _cFatorVcto
			_cB_Campo := _cB_Campo + StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo := _cB_Campo + ALLTRIM(SA6->A6_AGENCIA)+"02"+Alltrim(_cNumboleta) +ALLTRIM(SA6->A6_NUMCON)+"0" 

			BarraDV()

			_cCodBarras := "237"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras := _cCodBarras + StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras := _cCodBarras + ALLTRIM(SA6->A6_AGENCIA)+"02"+Alltrim(_cNumboleta) +ALLTRIM(SA6->A6_NUMCON)+"0"
		
		// *** FINAL CHAMADO 050420
		
		Case cE1PORTADO == "246" // ABC

			_cB_Campo := "237"  + "9" + _cFatorVcto
			_cB_Campo := _cB_Campo + StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo := _cB_Campo + Substr(SA6->A6_AGENCIA,1,4)+"09"+Alltrim(_cNumboleta) +Substr(SA6->A6_NUMCON,1,6) +Substr(SA6->A6_NUMCON,8,1)+"0" 

			BarraDV()

			_cCodBarras := "237"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras := _cCodBarras + StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras := _cCodBarras + Substr(SA6->A6_AGENCIA,1,4)+"09"+Alltrim(_cNumboleta) +Substr(SA6->A6_NUMCON,1,6) +Substr(SA6->A6_NUMCON,8,1) +"0" 

		Case cE1PORTADO == "399" // HSBC

			_cB_Campo := "399"  + "9" + _cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10) + Alltrim(_cNumboleta) + _cDV_NNUM
			_cB_Campo += Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7) +"00"+"1"

			BarraDV()

			_cCodBarras := "399"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) + Alltrim(_cNumboleta) + _cDV_NNUM
			_cCodBarras += Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7) +"00"+"1"   

		Case cE1PORTADO == "637" // SOFISA

			_cB_Campo := "399"  + "9" + _cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10) + Alltrim(_cNumboleta) + _cDV_NNUM
			_cB_Campo += Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7) +"00"+"1"

			BarraDV()

			_cCodBarras := "399"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) + Alltrim(_cNumboleta) + _cDV_NNUM
			_cCodBarras += Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7) +"00"+"1"	

		Case cE1PORTADO == "033" // SANTANDER

			_cB_Campo := "033"  + "9" + _cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo += "9" + "1809571" + Alltrim(_cNumboleta) + _cDV_NNUM + "0" + "101"

			BarraDV()

			_cCodBarras := "033"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) 
			_cCodBarras += "9" + "1809571" + Alltrim(_cNumboleta) + _cDV_NNUM + "0" + "101"

		Case cE1PORTADO $ "341/ITV" // ITAU

			_cB_Campo := "341"  + "9" + _cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5)  + fDACITAU(SUBSTR(SA6->A6_AGENCIA,1,4) +SUBSTR(SA6->A6_NUMCON,1,5) ) + "000"
			//CARTEIRA
			BarraDV()

			_cCodBarras := "341"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) 
			_cCodBarras += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5)  + fDACITAU(SUBSTR(SA6->A6_AGENCIA,1,4) +SUBSTR(SA6->A6_NUMCON,1,5) ) + "000"

		Case cE1PORTADO == "655" // ITAU

			_cB_Campo := "655"  + "9" + _cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5)  + fDACITAU(SUBSTR(SA6->A6_AGENCIA,1,4) +SUBSTR(SA6->A6_NUMCON,1,5) ) + "000"
			//CARTEIRA
			BarraDV()

			_cCodBarras := "655"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) 
			_cCodBarras += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5)  + fDACITAU(SUBSTR(SA6->A6_AGENCIA,1,4) +SUBSTR(SA6->A6_NUMCON,1,5) ) + "000"

		Case cE1PORTADO == "104" //  // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17

			_cB_Campo 	:= "104" 												//01-03 [03]- Idetificação Banco
			_cB_Campo 	+= "9" 													//04-04 [01]- Moeda  
			_cB_Campo 	+= _cFatorVcto											//06-09 [04]- Fator Vcnto
			_cB_Campo 	+= StrZero(Int(Round(_nVlrBol*100,2)),10)   	        //10-19 [10]- Posicoes
			_cB_Campo   += "8325375"                                            //20-26 [07]- Posições
			_cB_Campo   += SUBSTR(_cNumboleta,3,3)                              //27-29 [03]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
			_cB_Campo   += SUBSTR(_cNumboleta,1,1)    							//30-30 [01]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
			_cB_Campo   += SUBSTR(_cNumboleta,6,3)                              //31-33 [01]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
			_cB_Campo   += SUBSTR(_cNumboleta,2,1)                              //34-34 [01]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
			_cB_Campo   += SUBSTR(_cNumboleta,9,9)                              //35-43 [01]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
			_cB_Campo   += u_Dgdvpliv("8325375"+SUBSTR(_cNumboleta,3,3)+SUBSTR(_cNumboleta,1,1)+;
			SUBSTR(_cNumboleta,6,3)+SUBSTR(_cNumboleta,2,1)+SUBSTR(_cNumboleta,9,9)) //44-44 [01]- DV DO CAMPO LIVRE

			_cDV_BARRA := u_DgVerECF(_cB_Campo) //Calcula digito verificador do codigo de barras completo.

			_cCodBarras := cE1PORTADO  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras += "8325375" 
			_cCodBarras += SUBSTR(_cNumboleta,3,3)                                           
			_cCodBarras += SUBSTR(_cNumboleta,1,1)                                               
			_cCodBarras += SUBSTR(_cNumboleta,6,3)                             
			_cCodBarras += SUBSTR(_cNumboleta,2,1)                                               
			_cCodBarras += SUBSTR(_cNumboleta,9,9)                            
			_cCodBarras += _RE_Campo                                               

	EndCase

	RestArea(aArea)

	// Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
	RestArea( aAreaSF2 )
	RestArea( aAreaSE4 )
	RestArea( aAreaSE1 )
	//

Return(lRet)

/*/{Protheus.doc} Static Function fDACITAU
	Funcao para Calculo de DAC Itau
	@type  Static Function
	@author ?
	@since ?
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fDACITAU(cAgenConta)

	Local cRet 	:= ""

	Local nP1 	:= Val(Substr(cAgenConta,01,1)) * 2
	Local nP2 	:= Val(Substr(cAgenConta,02,1)) * 1
	Local nP3 	:= Val(Substr(cAgenConta,03,1)) * 2
	Local nP4 	:= Val(Substr(cAgenConta,04,1)) * 1
	Local nP5 	:= Val(Substr(cAgenConta,05,1)) * 2
	Local nP6 	:= Val(Substr(cAgenConta,06,1)) * 1
	Local nP7 	:= Val(Substr(cAgenConta,07,1)) * 2
	Local nP8 	:= Val(Substr(cAgenConta,08,1)) * 1
	Local nP9 	:= Val(Substr(cAgenConta,09,1)) * 2
	Local nDC 	:= nP1 + nP2 + nP3 + nP4 + nP5 + nP6 + nP7 + nP8 + nP9 
	Local nResto:= ( nDC % 10 ) 
	Local nRet	:= 10 - nResto

	If nRet >= 10
		cRet := "0"
	Else
		cRet := StrZero(nRet,1)
	Endif

Return(cRet)

/*/{Protheus.doc} Static Function fDACITAU
	Função de Calculo do Digito verificador do Nosso Numero 
	@type  Static Function
	@author ?
	@since ?
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function NNumDV(cDACItau)

	Do Case

		Case cE1PORTADO == "001"	// Banco do Brasil

			_cnCont := 0
			_ccPeso := 9
	
			For i := 11 To 1 Step -1
				_cnCont := _cnCont + (Val(SUBSTR(Alltrim(_cNumBoleta),i,1))) * _ccPeso
				_ccPeso := _ccPeso - 1
				If _ccPeso == 1
					_ccPeso := 9
				Endif
			Next
			_cResto := ( _cnCont % 11 )
			If _cResto < 10
				_cDV_NNUM := Str(_cResto,1)
			Else
				_cDV_NNUM := "X"
			EndIf

		Case cE1PORTADO $ "422/SAF/SFF"	// Banco Safra  //ALEX BORGES 03/04/12
		
			//Case cE1PORTADO == "422"	// Banco Safra		
			_cnCont 	:= 0
			_ccPeso 	:= 9
			_cnBoleta:= Alltrim(_cNumBoleta)
			_cNumBoleta := Alltrim(_cNumBoleta)
	
			nP1 := Val(Substr(_cNumBoleta,01,1)) * 9
			nP2 := Val(Substr(_cNumBoleta,02,1)) * 8
			nP3 := Val(Substr(_cNumBoleta,03,1)) * 7
			nP4 := Val(Substr(_cNumBoleta,04,1)) * 6
			nP5 := Val(Substr(_cNumBoleta,05,1)) * 5
			nP6 := Val(Substr(_cNumBoleta,06,1)) * 4
			nP7 := Val(Substr(_cNumBoleta,07,1)) * 3
			nP8 := Val(Substr(_cNumBoleta,08,1)) * 2
	
			_nValor := nP1 + nP2 + nP3 + nP4 + nP5 + nP6 + nP7 + nP8 
			_cResto :=  _nValor % 11 
			If _cResto == 0
				_cDV_NNUM := '1'
			ElseIf _cResto == 1
				_cDV_NNUM := '0'
			Else
				_cResto := 11 - _cResto       
				_cDV_NNUM := AllTrim(Str(_cResto))
			EndIf	

		Case cE1PORTADO $ "237|RED|BRD"	// Bradesco

			_cnCont   := 0
			_ccPeso   := 2
			_cnBoleta :="09" + Alltrim(_cNumBoleta)
	
			For i := 13 To 1 Step -1
	
				_cnCont := _cnCont + (Val(SUBSTR(_cnBoleta,i,1))) * _ccPeso
	
				_ccPeso := _ccPeso + 1
	
				If _ccPeso == 8
					_ccPeso := 2
				Endif
	
			Next
	
			_cResto := ( _cnCont % 11 )
	
			Do Case
				Case _cResto == 1
				_cDV_NNUM := "P"
				Case _cResto == 0
				_cDV_NNUM := "0"
				OtherWise
				_cResto   := ( 11 - _cResto )
				_cDV_NNUM := AllTrim(Str(_cResto))
			EndCase
		
		// *** INICIO CHAMADO 050420	
		Case cE1PORTADO $ "BRV"	// Bradesco

			_cnCont   := 0
			_ccPeso   := 2
			_cnBoleta :="02" + Alltrim(_cNumBoleta)
	
			For i := 13 To 1 Step -1
	
				_cnCont := _cnCont + (Val(SUBSTR(_cnBoleta,i,1))) * _ccPeso
	
				_ccPeso := _ccPeso + 1
	
				If _ccPeso == 8
					_ccPeso := 2
				Endif
	
			Next
	
			_cResto := ( _cnCont % 11 )
	
			Do Case
				Case _cResto == 1
				_cDV_NNUM := "P"
				Case _cResto == 0
				_cDV_NNUM := "0"
				OtherWise
				_cResto   := ( 11 - _cResto )
				_cDV_NNUM := AllTrim(Str(_cResto))
			EndCase	
			
		// *** FINAL CHAMADO 050420	
			
		Case cE1PORTADO == "246"	// ABC
		
			_cnCont   := 0
			_ccPeso   := 2
			_cnBoleta :="09" + Alltrim(_cNumBoleta)
	
			For i := 13 To 1 Step -1
	
				_cnCont := _cnCont + (Val(SUBSTR(_cnBoleta,i,1))) * _ccPeso
	
				_ccPeso := _ccPeso + 1
	
				If _ccPeso == 8
					_ccPeso := 2
				Endif
	
			Next
	
			_cResto := ( _cnCont % 11 )
	
			Do Case
				Case _cResto == 1
				_cDV_NNUM := "P"
				Case _cResto == 0
				_cDV_NNUM := "0"
				OtherWise
				_cResto   := ( 11 - _cResto )
				_cDV_NNUM := AllTrim(Str(_cResto))
			EndCase
					
		Case cE1PORTADO == "399"	// HSBC
		
			_cNumBoleta := Alltrim(_cNumBoleta)
	
			nP1 := Val(Substr(_cNumBoleta,01,1)) * 5
			nP2 := Val(Substr(_cNumBoleta,02,1)) * 4
			nP3 := Val(Substr(_cNumBoleta,03,1)) * 3
			nP4 := Val(Substr(_cNumBoleta,04,1)) * 2
			nP5 := Val(Substr(_cNumBoleta,05,1)) * 7
			nP6 := Val(Substr(_cNumBoleta,06,1)) * 6
			nP7 := Val(Substr(_cNumBoleta,07,1)) * 5
			nP8 := Val(Substr(_cNumBoleta,08,1)) * 4
			nP9 := Val(Substr(_cNumBoleta,09,1)) * 3
			nP0 := Val(Substr(_cNumBoleta,10,1)) * 2
	
			_nRHSBC := nP1 + nP2 + nP3 + nP4 + nP5 + nP6 + nP7 + nP8 + nP9 + nP0
			_nResto := ( _nRHSBC % 11 )
	
			If _nResto == 0 .OR. _nResto == 1
				_nResto := 0
			Else	
				_nResto := 11 - _nResto
			Endif	                    
	
			_cDV_NNUM := Str(_nResto,1)          

		Case cE1PORTADO == "637"	// SOFISA
		
			_cNumBoleta := Alltrim(_cNumBoleta)
	
			nP1 := Val(Substr(_cNumBoleta,01,1)) * 5
			nP2 := Val(Substr(_cNumBoleta,02,1)) * 4
			nP3 := Val(Substr(_cNumBoleta,03,1)) * 3
			nP4 := Val(Substr(_cNumBoleta,04,1)) * 2
			nP5 := Val(Substr(_cNumBoleta,05,1)) * 7
			nP6 := Val(Substr(_cNumBoleta,06,1)) * 6
			nP7 := Val(Substr(_cNumBoleta,07,1)) * 5
			nP8 := Val(Substr(_cNumBoleta,08,1)) * 4
			nP9 := Val(Substr(_cNumBoleta,09,1)) * 3
			nP0 := Val(Substr(_cNumBoleta,10,1)) * 2
	
			_nRHSBC := nP1 + nP2 + nP3 + nP4 + nP5 + nP6 + nP7 + nP8 + nP9 + nP0
			_nResto := ( _nRHSBC % 11 )
	
			If _nResto == 0 .OR. _nResto == 1
				_nResto := 0
			Else	
				_nResto := 11 - _nResto
			Endif	                    
	
			_cDV_NNUM := Str(_nResto,1)     
	
		Case cE1PORTADO == "033"	// SANTANDER
		
			_cNumBoleta := Alltrim(_cNumBoleta)
			nP01 := Val(Substr(_cNumBoleta,12,1)) * 2
			nP02 := Val(Substr(_cNumBoleta,11,1)) * 3
			nP03 := Val(Substr(_cNumBoleta,10,1)) * 4
			nP04 := Val(Substr(_cNumBoleta,09,1)) * 5
			nP05 := Val(Substr(_cNumBoleta,08,1)) * 6
			nP06 := Val(Substr(_cNumBoleta,07,1)) * 7
			nP07 := Val(Substr(_cNumBoleta,06,1)) * 8
			nP08 := Val(Substr(_cNumBoleta,05,1)) * 9
			nP09 := Val(Substr(_cNumBoleta,04,1)) * 2
			nP10 := Val(Substr(_cNumBoleta,03,1)) * 3
			nP11 := Val(Substr(_cNumBoleta,02,1)) * 4
			nP12 := Val(Substr(_cNumBoleta,01,1)) * 5
	
			_nRSANT := nP01 + nP02 + nP03 + nP04 + nP05 + nP06 + nP07 + nP08 + nP09 + nP10 + nP11 + nP12
	
			_nResto := ( _nRSANT % 11 )
	
			If _nResto == 10
				_cDV_NNUM := "1"
			ElseIf _nResto == 1 .OR. _nResto == 0
				_cDV_NNUM := "0"
			Else
				_nResto := 11 - _nResto
				_cDV_NNUM := Str(_nResto,1)
			Endif		

		Case cE1PORTADO == "104"	// caixa economica federal

			_cNumBoleta := Alltrim(_cNumBoleta)
	
			nP01 := Val(Substr(_cNumBoleta,17,1)) * 2
			nP02 := Val(Substr(_cNumBoleta,16,1)) * 3
			nP03 := Val(Substr(_cNumBoleta,15,1)) * 4
			nP04 := Val(Substr(_cNumBoleta,14,1)) * 5
			nP05 := Val(Substr(_cNumBoleta,13,1)) * 6
			nP06 := Val(Substr(_cNumBoleta,12,1)) * 7
			nP07 := Val(Substr(_cNumBoleta,11,1)) * 8
			nP08 := Val(Substr(_cNumBoleta,10,1)) * 9
			nP09 := Val(Substr(_cNumBoleta,09,1)) * 2
			nP10 := Val(Substr(_cNumBoleta,08,1)) * 3
			nP11 := Val(Substr(_cNumBoleta,07,1)) * 4
			nP12 := Val(Substr(_cNumBoleta,06,1)) * 5
			nP13 := Val(Substr(_cNumBoleta,05,1)) * 6
			nP14 := Val(Substr(_cNumBoleta,04,1)) * 7
			nP15 := Val(Substr(_cNumBoleta,03,1)) * 8
			nP16 := Val(Substr(_cNumBoleta,02,1)) * 9
			nP17 := Val(Substr(_cNumBoleta,01,1)) * 2
	
			_nRSANT := nP01 + nP02 + nP03 + nP04 + nP05 + nP06 + nP07 + nP08 + nP09 + nP10 + nP11 + nP12+;
			nP13 + nP14 + nP15 + nP16 + nP17
	
			_nResto := ( _nRSANT % 11 )
	
			_nResto := 11 - _nResto
	
			If _nResto > 9
	
				_cDV_NNUM := "0"
	
			Else
	
				_cDV_NNUM := Str(_nResto,1)
	
			Endif		

		Case cE1PORTADO  $  "341/655/KOB/ITV"	// ITAU  VOTORANTIM

			nP01 := Val(Substr(cDACItau,01,01)) * 1
			If nP01 > 9       
				nP01 := Alltrim(Str(nP01))
				nP01 := Val(Substr(nP01,1,1)) + Val(Substr(nP01,2,1))
			Endif
			nP02 := Val(Substr(cDACItau,02,01)) * 2
			If nP02 > 9       
				nP02 := Alltrim(Str(nP02))
				nP02 := Val(Substr(nP02,1,1)) + Val(Substr(nP02,2,1))
			Endif        	
			nP03 := Val(Substr(cDACItau,03,01)) * 1           
			If nP03 > 9       
				nP03 := Alltrim(Str(nP03))
				nP03 := Val(Substr(nP03,1,1)) + Val(Substr(nP03,2,1))
			Endif        	
			nP04 := Val(Substr(cDACItau,04,01)) * 2           
			If nP04 > 9       
				nP04 := Alltrim(Str(nP04))
				nP04 := Val(Substr(nP04,1,1)) + Val(Substr(nP04,2,1))
			Endif        	
			nP05 := Val(Substr(cDACItau,05,01)) * 1           
			If nP05 > 9       
				nP05 := Alltrim(Str(nP05))
				nP05 := Val(Substr(nP05,1,1)) + Val(Substr(nP05,2,1))
			Endif        	
			nP06 := Val(Substr(cDACItau,06,01)) * 2           
			If nP06 > 9       
				nP06 := Alltrim(Str(nP06))
				nP06 := Val(Substr(nP06,1,1)) + Val(Substr(nP06,2,1))
			Endif        	
			nP07 := Val(Substr(cDACItau,07,01)) * 1           
			If nP07 > 9       
				nP07 := Alltrim(Str(nP07))
				nP07 := Val(Substr(nP07,1,1)) + Val(Substr(nP07,2,1))
			Endif        	
			nP08 := Val(Substr(cDACItau,08,01)) * 2           
			If nP08 > 9       
				nP08 := Alltrim(Str(nP08))
				nP08 := Val(Substr(nP08,1,1)) + Val(Substr(nP08,2,1))
			Endif        	
			nP09 := Val(Substr(cDACItau,09,01)) * 1           
			If nP09 > 9       
				nP09 := Alltrim(Str(nP01))
				nP09 := Val(Substr(nP09,1,1)) + Val(Substr(nP09,2,1))
			Endif        	
			nP10 := Val(Substr(cDACItau,10,01)) * 2           
			If nP10 > 9       
				nP10 := Alltrim(Str(nP10))
				nP10 := Val(Substr(nP10,1,1)) + Val(Substr(nP10,2,1))
			Endif
			nP11 := Val(Substr(cDACItau,11,01)) * 1
			If nP11 > 9       
				nP11 := Alltrim(Str(nP11))
				nP11 := Val(Substr(nP11,1,1)) + Val(Substr(nP11,2,1))
			Endif        	
			nP12 := Val(Substr(cDACItau,12,01)) * 2              
			If nP12 > 9       
				nP12 := Alltrim(Str(nP12))
				nP12 := Val(Substr(nP12,1,1)) + Val(Substr(nP12,2,1))
			Endif        	
			nP13 := Val(Substr(cDACItau,13,01)) * 1              
			If nP13 > 9       
				nP13 := Alltrim(Str(nP13))
				nP13 := Val(Substr(nP13,1,1)) + Val(Substr(nP13,2,1))
			Endif        	
			nP14 := Val(Substr(cDACItau,14,01)) * 2              
			If nP14 > 9       
				nP14 := Alltrim(Str(nP14))
				nP14 := Val(Substr(nP14,1,1)) + Val(Substr(nP14,2,1))
			Endif        	
			nP15 := Val(Substr(cDACItau,15,01)) * 1              
			If nP15 > 9       
				nP15 := Alltrim(Str(nP15))
				nP15 := Val(Substr(nP15,1,1)) + Val(Substr(nP15,2,1))
			Endif        	
			nP16 := Val(Substr(cDACItau,16,01)) * 2              
			If nP16 > 9        
				nP16 := Alltrim(Str(nP16))
				nP16 := Val(Substr(nP16,1,1)) + Val(Substr(nP16,2,1))
			Endif        	
			nP17 := Val(Substr(cDACItau,17,01)) * 1              
			If nP17 > 9       
				nP17 := Alltrim(Str(nP17))
				nP17 := Val(Substr(nP17,1,1)) + Val(Substr(nP17,2,1))
			Endif        	
			nP18 := Val(Substr(cDACItau,18,01)) * 2              
			If nP18 > 9       
				nP18 := Alltrim(Str(nP18))
				nP18 := Val(Substr(nP18,1,1)) + Val(Substr(nP18,2,1))
			Endif        	
			nP19 := Val(Substr(cDACItau,19,01)) * 1              
			If nP19 > 9       
				nP19 := Alltrim(Str(nP19))
				nP19 := Val(Substr(nP19,1,1)) + Val(Substr(nP19,2,1))
			Endif        	
			nP20 := Val(Substr(cDACItau,20,01)) * 2              
			If nP20 > 9       
				nP20 := Alltrim(Str(nP20))
				nP20 := Val(Substr(nP20,1,1)) + Val(Substr(nP20,2,1))
			Endif        	
	
			_nRSANT := nP01 + nP02 + nP03 + nP04 + nP05 + nP06 + nP07 + nP08 + nP09 + nP10 + nP11 + nP12+ nP13+ nP14+ nP15+ nP16+ nP17+ nP18+ nP19+ nP20
			_nResto := ( _nRSANT % 10 )
			If _nResto > 0
				_nResto := 10 - _nResto
			Endif   
	
			If _nResto >= 10
				_cDV_NNUM := "0"
			Else    
				_cDV_NNUM := Str(_nResto,1)
			Endif		

	EndCase
	
Return

/*/{Protheus.doc} Static Function fDACITAU
	Função de Calculo do Digito de Verificação do Codigo de Barras 
	@type  Static Function
	@author ?
	@since ?
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function BarraDV()

	Do Case

		Case cE1PORTADO == "001"			// Banco do Brasil

			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
	
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 10 .or. _cResult == 11 .or. _cResult == 0
				_cDV_BARRA := "1"
				OtherWise
				_cDV_BARRA := Str(_cResult,1)
			EndCase

		Case cE1PORTADO $ "422/SAF/SFF"			// Banco Safra    ALEX BORGES 03/04/12
		
			//	Case cE1PORTADO == "422"			// Banco Safra		
			_cnCont := 0
			_ccPeso := 8 //2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 8 //2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 10 .or. _cResult == 11 .OR. _cResult == 0 //Case _cResult == 10 .or. _cResult == 11
				_cDV_BARRA := "1"
				OtherWise
				_cDV_BARRA := Str(_cResult,1)
			EndCase


		Case cE1PORTADO $ "237|RED|BRD"	// Bradesco

			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 10 .or. _cResult == 11
				_cDV_BARRA := "1"
				OtherWise
				_cDV_BARRA := Str(_cResult,1)
			EndCase
			
		// *** INICIO CHAMADO 050420
		Case cE1PORTADO $ "BRV"	// Bradesco

			_cDV_BARRA := MODULO11(_cB_Campo,43,1)
			
		// *** FINAL CHAMADO 050420
		
		Case cE1PORTADO $ "399/637"	// HSBC

			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 10 .or. _cResult == 11
				_cDV_BARRA := "1"
				OtherWise
				_cDV_BARRA := Str(_cResult,1)
			EndCase		

		Case cE1PORTADO == "033"	// SANTANDER

			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 0 .OR. _cResult == 1 .OR. _cResult == 10 
				_cDV_BARRA := "1"
				OtherWise
				_cDV_BARRA := Str(_cResult,1)
			EndCase

		Case cE1PORTADO $ "341/655/KOB/ITV"	// ITAU

			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 0 .OR. _cResult == 1 .OR. _cResult >= 10 
				_cDV_BARRA := "1"
				OtherWise
				_cDV_BARRA := Str(_cResult,1)
			EndCase		

	EndCase

Return()

/*/{Protheus.doc} Static Function fCalcNNR
	Calcula e grava o Numero-Digito do Nosso Numero para o banco Itaú
	@type  Static Function
	@author Microsiga
	@since 30/05/2007
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fCalcNNr()

	cDigNNr		 := " "
	_cNumboleta  := SE1->E1_NUM + _nSeqParcela

	nAgen01 := Val(SubStr(_cAg,1,1))
	nAgen02 := Val(SubStr(_cAg,2,1))        
	nAgen03 := Val(SubStr(_cAg,3,1))
	nAgen04 := Val(SubStr(_cAg,4,1))
	nCont01 := Val(SubStr(_cCc,1,1))
	nCont02 := Val(SubStr(_cCc,2,1))
	nCont03 := Val(SubStr(_cCc,3,1))
	nCont04 := Val(SubStr(_cCc,4,1))
	nCont05 := Val(SubStr(_cCc,5,1))
	nCart01 := Val(SubStr(Alltrim(Str(_nCart)),1,1)) //--1
	nCart02 := Val(SubStr(Alltrim(Str(_nCart)),2,1)) //--7
	nCart03 := Val(SubStr(Alltrim(Str(_nCart)),3,1)) //--9
	nNNum01 := Val(SubStr(_cNumboleta,1,1))
	nNNum02 := Val(SubStr(_cNumboleta,2,1))
	nNNum03 := Val(SubStr(_cNumboleta,3,1))
	nNNum04 := Val(SubStr(_cNumboleta,4,1))
	nNNum05 := Val(SubStr(_cNumboleta,5,1))
	nNNum06 := Val(SubStr(_cNumboleta,6,1))
	nNNum07 := Val(SubStr(_cNumboleta,7,1))
	nNNum08 := Val(SubStr(_cNumboleta,8,1))

	nAux101 := nAgen01 * 1
	If nAux101 >= 10
		cAux101 := STR(nAux101)
		nAux101 := Val(SubStr(ALLTrim(cAux101),1,1))+Val(SubStr(ALLTrim(cAux101),2,1))
	EndIf

	nAux102 := nAgen02 * 2
	If nAux102 >= 10
		cAux102 := STR(nAux102)
		nAux102 := Val(SubStr(ALLTrim(cAux102),1,1))+Val(SubStr(ALLTrim(cAux102),2,1))
	EndIf
	nAux103 := nAgen03 * 1

	If nAux103 >= 10
		cAux103 := STR(nAux103)
		nAux103 := Val(SubStr(ALLTrim(cAux103),1,1))+Val(SubStr(ALLTrim(cAux103),2,1))
	EndIf

	nAux104 := nAgen04 * 2
	If nAux104 >= 10
		cAux104 := STR(nAux104)
		nAux104 := Val(SubStr(ALLTrim(cAux104),1,1))+Val(SubStr(ALLTrim(cAux104),2,1))
	EndIf

	nAux105 := nCont01 * 1
	If nAux105 >= 10
		cAux105 := STR(nAux105)
		nAux105 := Val(SubStr(ALLTrim(cAux105),1,1))+Val(SubStr(ALLTrim(cAux105),2,1))
	EndIf

	nAux106 := nCont02 * 2
	If nAux106 >= 10
		cAux106 := STR(nAux106)
		nAux106 := Val(SubStr(ALLTrim(cAux106),1,1))+Val(SubStr(ALLTrim(cAux106),2,1))
	EndIf

	nAux107 := nCont03 * 1
	If nAux107 >= 10
		cAux107 := STR(nAux107)
		nAux107 := Val(SubStr(ALLTrim(cAux107),1,1))+Val(SubStr(ALLTrim(cAux107),2,1))
	EndIf

	nAux108 := nCont04 * 2
	If nAux108 >= 10
		cAux108 := STR(nAux108)
		nAux108 := Val(SubStr(ALLTrim(cAux108),1,1))+Val(SubStr(ALLTrim(cAux108),2,1))
	EndIf

	nAux109 := nCont05 * 1
	If nAux109 >= 10
		cAux109 := STR(nAux109)
		nAux109 := Val(SubStr(ALLTrim(cAux109),1,1))+Val(SubStr(ALLTrim(cAux109),2,1))
	EndIf

	nAux110 := nCart01 * 2
	If nAux110 >= 10
		cAux110 := STR(nAux110)
		nAux110 := Val(SubStr(ALLTrim(cAux110),1,1))+Val(SubStr(ALLTrim(cAux110),2,1))
	EndIf

	nAux111 := nCart02 * 1
	If nAux111 >= 10
		cAux111 := STR(nAux111)
		nAux111 := Val(SubStr(ALLTrim(cAux111),1,1))+Val(SubStr(ALLTrim(cAux111),2,1))
	EndIf
	nAux112 := nCart03 * 2
	If nAux112 >= 10
		cAux112 := STR(nAux112)
		nAux112 := Val(SubStr(ALLTrim(cAux112),1,1))+Val(SubStr(ALLTrim(cAux112),2,1))
	EndIf
	nAux113 := nNNum01 * 1
	If nAux113 >= 10
		cAux113 := STR(nAux113)
		nAux113 := Val(SubStr(ALLTrim(cAux113),1,1))+Val(SubStr(ALLTrim(cAux113),2,1))
	EndIf
	nAux114 := nNNum02 * 2
	If nAux114 >= 10
		cAux114 := STR(nAux114)
		nAux114 := Val(SubStr(ALLTrim(cAux114),1,1))+Val(SubStr(ALLTrim(cAux114),2,1))
	EndIf
	nAux115 := nNNum03 * 1
	If nAux115 >= 10
		cAux115 := STR(nAux115)
		nAux115 := Val(SubStr(ALLTrim(cAux115),1,1))+Val(SubStr(ALLTrim(cAux115),2,1))
	EndIf
	nAux116 := nNNum04 * 2
	If nAux116 >= 10
		cAux116 := STR(nAux116)
		nAux116 := Val(SubStr(ALLTrim(cAux116),1,1))+Val(SubStr(ALLTrim(cAux116),2,1))
	EndIf
	nAux117 := nNNum05 * 1
	If nAux117 >= 10
		cAux117 := STR(nAux117)
		nAux117 := Val(SubStr(ALLTrim(cAux117),1,1))+Val(SubStr(ALLTrim(cAux117),2,1))
	EndIf
	nAux118 := nNNum06 * 2
	If nAux118 >= 10
		cAux118 := STR(nAux118)
		nAux118 := Val(SubStr(ALLTrim(cAux118),1,1))+Val(SubStr(ALLTrim(cAux118),2,1))
	EndIf
	nAux119 := nNNum07 * 1
	If nAux119 >= 10
		cAux119 := STR(nAux119)
		nAux119 := Val(SubStr(ALLTrim(cAux119),1,1))+Val(SubStr(ALLTrim(cAux119),2,1))
	EndIf
	nAux120 := nNNum08 * 2
	If nAux120 >= 10
		cAux120 := STR(nAux120)
		nAux120 := Val(SubStr(ALLTrim(cAux120),1,1))+Val(SubStr(ALLTrim(cAux120),2,1))
	EndIf

	nTot1:=nAux101+nAux102+nAux103+nAux104+nAux105+nAux106+nAux107+nAux108+nAux109
	nTot1:=nTot1+nAux110+nAux111+nAux112+nAux113+nAux114+nAux115+nAux116+nAux117+nAux118+nAux119+nAux120 // nAux119

	nRstDig := MOD(nTot1,10)
	cDigNNr := 10 - nRstDig
	cDigNNr := IIf(cDigNNr == 10,0,cDigNNr)

	cNossoNr:=Alltrim(Str(_nCart))+"/"+cAuxNNr+"-"+Str(cDigNNr,1)

Return(.T.) 

/*/{Protheus.doc} Static Function FIN040INC
	Função para geração de Titulo no contas a receber. Para pagamento de Guia de ICMS ST do RS
	@type  Static Function
	@author Microsiga
	@since ?
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static FUNCTION FIN040INC()

	Local _aArea		:= GetArea()
	Local _aArSD2 		:= SD2->(GetArea())
	Local aAreaSA1 		:= SA1->( GetArea() ) // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
	Local aAreaSE1      := SE1->( GetArea() ) // 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - fwnm - 23/06/2020
	Local aAreaSA6      := SA6->( GetArea() ) // 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - fwnm - 23/06/2020

	Local aArray 		:= {} 
	Local nBIcmST 		:= 0
	Local nVIcmST 		:= 0 
	Local dVenc 		:= SF2->F2_EMISSAO
	Local nDiasUteis 	:= 0     
	Local nDtValida 	:= 0
	Local nCont 		:= 0
	Local lDtValida 	:= .F.     

	Local _cEmbut 		:= AllTrim(GETMV("MV_#EMBUT"))     	// chamado 031274 por Adriana - Embutidos
	Local _cIntTemp 	:= AllTrim(GETMV("MV_#INTTP"))		// chamado 031274 por Adriana - Frango Inteiro Temperado
	Local _cIntSTemp	:= AllTrim(GETMV("MV_#INTSTP"))		// chamado 031274 por Adriana - Frango Inteiro sem tempero
	Local _cCtTemp		:= AllTrim(GETMV("MV_#CTTP"))		// chamado 031274 por Adriana - Corte Frango Temperado
	
	//
	Local _nAlqIT			:= GETMV("MV_#ALQIT",,0.17)		//Aliquota calculo do ICMS ST Frango Inteiro Temperado para boletos clientes RS - //Ticket 63560	- Abel Babini          - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlqIST		:= GETMV("MV_#ALQIST",,0.12)	//Aliquota calculo do ICMS ST Frango Inteiro sem tempero para boletos clientes RS	//Ticket 63560	- Abel Babini          - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlqCT			:= GETMV("MV_#ALQCT",,0.17)		//Aliquota calculo do ICMS ST Corte Frango Temperado para boletos clientes RS//Ticket 63560	- Abel Babini          - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlqOu			:= GETMV("MV_#ALQOU",,0.12)		//Aliquota calculo do ICMS ST para boletos clientes RS//Ticket 63560	- Abel Babini          - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	
	Local _nAlBl01		:= GETMV("MV_#ALBS01",,0.411765)	//Alq calculo do ICMS ST para boletos clientes RS 01 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl02		:= GETMV("MV_#ALBS02",,0.2)	//Alq calculo do ICMS ST para boletos clientes RS 02 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl03		:= GETMV("MV_#ALBS03",,0.12)	//Alq calculo do ICMS ST para boletos clientes RS 03 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl11		:= GETMV("MV_#ALBS11",,0.4)	//Alq calculo do ICMS ST para boletos clientes RS 01 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas

	Local _nAlBl04		:= GETMV("MV_#ALBS04",,0.5833)	//Alq calculo do ICMS ST para boletos clientes RS 04 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl05		:= GETMV("MV_#ALBS05",,0.2)	//Alq calculo do ICMS ST para boletos clientes RS 05 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas

	Local _nAlBl06		:= GETMV("MV_#ALBS06",,0.411765)	//Alq calculo do ICMS ST para boletos clientes RS 06 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl07		:= GETMV("MV_#ALBS07",,0.6)	//Alq calculo do ICMS ST para boletos clientes RS 07 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl08		:= GETMV("MV_#ALBS08",,0.12)	//Alq calculo do ICMS ST para boletos clientes RS 08 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl12		:= GETMV("MV_#ALBS12",,0.4)	//Alq calculo do ICMS ST para boletos clientes RS 01 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas

	Local _nAlBl09		:= GETMV("MV_#ALBS09",,0.5833)	//Alq calculo do ICMS ST para boletos clientes RS 09 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl10		:= GETMV("MV_#ALBS10",,0.6)	//Alq calculo do ICMS ST para boletos clientes RS 10 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas

	Local _nAlBl13		:= GETMV("MV_#ALBS13",,0.5833)	//Alq calculo do ICMS ST para boletos clientes RS 04 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl14		:= GETMV("MV_#ALBS14",,0.12)	//Alq calculo do ICMS ST para boletos clientes RS 05 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl15		:= GETMV("MV_#ALBS15",,0.2341)	//Alq calculo do ICMS ST para boletos clientes RS 05 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl16		:= GETMV("MV_#ALBS16",,0.18)	//Alq calculo do ICMS ST para boletos clientes RS 05 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas

	Local _nAlBl17		:= GETMV("MV_#ALBS17",,0.07)	//Alq calculo do ICMS ST para boletos clientes RS 04 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl18		:= GETMV("MV_#ALBS18",,0.25)	//Alq calculo do ICMS ST para boletos clientes RS 05 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	Local _nAlBl19		:= GETMV("MV_#ALBS19",,0.18)	//Alq calculo do ICMS ST para boletos clientes RS 05 //Tickets 63560 - Abel Babini - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	//
	Local cNCM_MG 		:= GetMV("MV_#ICSTMG",,"0207") 		// Chamado 043061 - FWNM em 22/08/2018 
	
	Local cCMS			:= AllTrim( GETMV("MV_#VLCMS",,"") ) //Everson - 17/01/2019. Chamado 046222.
	Local cCFOP			:= AllTrim( GETMV("MV_#VLCF",,"") )  //Everson - 17/01/2019. Chamado 046222.

	PRIVATE lMsErroAuto:= .F. 
	
	Conout("SF2460I - FIN040INC - Início geração guia ST " + DToC(Date()) + " " +  Time() ) 

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()   
	If dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)

		//	If SF2->F2_EST != "RS" .OR. Alltrim(SA1->A1_REGIMST) == "S" .OR. Alltrim(SF2->F2_TIPO) $ "I/P/D/B"
		If !AllTrim(SF2->F2_EST) $ "MG#RS" .OR. Alltrim(SA1->A1_REGIMST) == "S" .OR. Alltrim(SF2->F2_TIPO) $ "I/P/D/B"

			Conout("SF2460I - FIN040INC - Entrou primeira validação")		

			RestArea(_aArea)
			RestArea(_aArSD2)		
			RestArea(aAreaSA1) // 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - fwnm - 23/06/2020

			Return
			
		Endif

	Else 

		Return

	Endif

	If AllTrim(SF2->F2_EST) == "RS"

		SqlVerificaProdutos()
		While TRB->(!EOF())

			If  Alltrim(TRB->D2_GRUPO) $ _cEmbut .Or.; //"0341/0342/0512/0511/0541/0542/0344/0345" - grupo embutidos salsicha, linguica, CMS nao imprime boleto  - Alterado por Adriana chamado 031274
				Alltrim(TRB->D2_CF) $ cCFOP //5923 //Everson - 17/01/2019. Chamado 046222.
				
				TRB->(dbCloseArea())
				
				Conout("SF2460I - FIN040INC - Entrou segunda validação RS " + DToC(Date()) + " " +  Time() )				
				
				RestArea(_aArea)
				RestArea(_aArSD2)
				RestArea(aAreaSA1) // 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - fwnm - 23/06/2020

				Return
				
			Endif
			
			TRB->(dbSkip())
		
		ENDDO
		
		If Select("TRB") > 0 // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
			TRB->(dbCloseArea())
		EndIf

		//Inicio chamado: 044861 
		DbSelectArea("SD2")
		dbSetOrder(3)
		If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)	    

			//INICIO Ticket 63560	- Abel Babini          - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
			IF Alltrim(SD2->D2_COD) $ _cIntTemp // "100252/100253" inteiro temperado - Alterado por Adriana chamado 031274
				nBIcmST := (SF2->F2_VALMERC * _nAlBl01 * _nAlBl02) + (SF2->F2_VALMERC * _nAlBl01)
				//    nVIcmST := (nBIcmST * 0.18) - SF2->F2_VALICM
				nVIcmST := (nBIcmST * _nAlqIT) - ((SF2->F2_VALMERC * _nAlBl11)	* _nAlBl03)

			ElseIF Alltrim(SD2->D2_COD) $ _cIntSTemp // "128270" inteiro sem tempero - Alterado por Adriana chamado 031274
				nBIcmST := (SF2->F2_VALMERC * _nAlBl04 * _nAlBl05) + (SF2->F2_VALMERC * _nAlBl04)
				nVIcmST := (nBIcmST * _nAlqIST) - SF2->F2_VALICM

			ElseIF Alltrim(SD2->D2_COD) $ _cCtTemp // corte temperado - Alterado por Adriana chamado 031274
				nBIcmST := (SF2->F2_VALMERC * _nAlBl06 * _nAlBl07) + (SF2->F2_VALMERC * _nAlBl06)
				//    nVIcmST := (nBIcmST * 0.18) - SF2->F2_VALICM
				nVIcmST := (nBIcmST * _nAlqCT) - ((SF2->F2_VALMERC * _nAlBl12) * _nAlBl08)

			Else                                            
				nBIcmST := (SF2->F2_VALMERC * _nAlBl09 * _nAlBl10) + (SF2->F2_VALMERC * _nAlBl09)
				nVIcmST := (nBIcmST * _nAlqOu) - SF2->F2_VALICM

			EndIf 
			//FIM Ticket 63560	- Abel Babini          - 09/11/2021 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas

		EndIf	                                    
		//Fim chamado: 044861 

	ElseIf AllTrim(SF2->F2_EST) == "MG"
		
		//Everson - 17/01/2019. Chamado 046222.
		//Valida códigos de produtos CMS e CFOP.
		SqlVerificaProdutos()

		While TRB->(!EOF())

			If  Alltrim(TRB->D2_GRUPO) $ cCMS .Or.; //0341/0342/0344/0345 //Everson - 17/01/2019. Chamado 046222.
				Alltrim(TRB->D2_CF) $ cCFOP //5923

				TRB->(dbCloseArea())				

				Conout("SF2460I - FIN040INC - Entrou terceira validação MG " + DToC(Date()) + " " +  Time() )	

				RestArea(_aArea)
				RestArea(_aArSD2)				
				RestArea(aAreaSA1)				

				Return
				
			Endif

			TRB->(dbSkip())

		ENDDO

		If Select("TRB") > 0 // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
			TRB->(dbCloseArea())
		EndIf
		//

		//Inicio: chamado:045310 - Fernando Sigoli 26/11/2018
		DbSelectArea("SD2")
		dbSetOrder(3)
		If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)	    

			If Left(AllTrim(Posicione("SB1",1,FWxFilial("SB1")+SD2->D2_COD,"B1_POSIPI")),4) $ cNCM_MG

				nA := SF2->F2_VALBRUT
				nB := nA * _nAlBl13 * _nAlBl14
				nC := (nA * _nAlBl15) + nA

				nVIcmST := (nC * _nAlBl16) - nB

			EndIf

		EndIf
	//INICIO Ticket 63560	- Abel Babini          - 13/06/2022 - Alteração de alíquotas e parametros de acordo com a nova tabela de alíquotas
	ElseIf AllTrim(SF2->F2_EST) == "BA"
		
		//Everson - 17/01/2019. Chamado 046222.
		//Valida códigos de produtos CMS e CFOP.
		SqlVerificaProdutos()

		While TRB->(!EOF())

			If  Alltrim(TRB->D2_GRUPO) $ cCMS .Or.; //0341/0342/0344/0345 //Everson - 17/01/2019. Chamado 046222.
				Alltrim(TRB->D2_CF) $ cCFOP //5923

				TRB->(dbCloseArea())				

				Conout("SF2460I - FIN040INC - Entrou terceira validação BA " + DToC(Date()) + " " +  Time() )	

				RestArea(_aArea)
				RestArea(_aArSD2)				
				RestArea(aAreaSA1)				

				Return
				
			Endif

			TRB->(dbSkip())

		ENDDO

		If Select("TRB") > 0 // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
			TRB->(dbCloseArea())
		EndIf
		//

		//Inicio: chamado:045310 - Fernando Sigoli 26/11/2018
		DbSelectArea("SD2")
		dbSetOrder(3)
		If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)	    

			If Left(AllTrim(Posicione("SB1",1,FWxFilial("SB1")+SD2->D2_COD,"B1_POSIPI")),4) $ cNCM_MG

				nA := SF2->F2_VALBRUT
				nB := nA * _nAlBl17
				nC := (nA * _nAlBl18) + nA

				nVIcmST := (nC * _nAlBl19) - nB

			EndIf

		EndIf
	EndIf

	If nVIcmST > 0  //chamado:045310

		While nDtValida < 5
			nCont += 1         
			nDtEmi := SF2->F2_EMISSAO + nCont
			If nDtEmi == datavalida(nDtEmi)
				nDtValida += 1	
			Endif	
		Enddo

		cCC := ""
		dbSelectArea("SD2")
		dbSetOrder(3)
		If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)	    
			cCC := U_LP610CC()
		Endif 

		dbSelectArea("SE1")
		aArray := { { "E1_PREFIXO"  , "MAN"             				 , NIL },;
					{ "E1_NUM"      , SF2->F2_DOC       				 , NIL },;
					{ "E1_TIPO"     , "NDC"             				 , NIL },;
					{ "E1_NATUREZ"  , "10111"           				 , NIL },;
					{ "E1_CLIENTE"  , SF2->F2_CLIENTE   				 , NIL },;
					{ "E1_LOJA"  	, SF2->F2_LOJA   					 , NIL },; //em 08/12/2015 - incluido por Adriana pois estava gerando travamento no momento de faturar
					{ "E1_EMISSAO"  , SF2->F2_EMISSAO  	 				 , NIL },;
					{ "E1_VENCTO"   , SF2->F2_EMISSAO+nCont 			 , NIL },;
					{ "E1_VENCREA"  , SF2->F2_EMISSAO+nCont 			 , NIL },;
					{ "E1_BANCO"    , "237"             				 , NIL },;          
					{ "E1_HIST"     , "ICMS ST / " + AllTrim(SF2->F2_EST), NIL },;  
					{ "E1_DEBITO"   , "111720002"    					 , NIL },;            
					{ "E1_CREDIT"   , "191110012"    					 , NIL },;
					{ "E1_CCC"      , cCC    						     , NIL },;
					{ "E1_VALOR"    , nVIcmST              				 , NIL }}

		MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão


		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
		Endif 

		_cBcoCli	:= "237"                             

		cQuery := "SELECT A6_COD,A6_AGENCIA,A6_NUMCON FROM " + RETSQLNAME("SA6") + " (NOLOCK) "
		cQuery += "WHERE D_E_L_E_T_ = ' ' AND A6_FILIAL = '" + XFILIAL("SA6") + "' AND "
		cQuery += "A6_COD = '" + _cBcoCli + "' AND A6_ZZBLT = 'S' "

		TcQuery cQuery New Alias "TSA6NDC"

		TSA6NDC->(dbGoTop())

		If TSA6NDC->(!Eof())

			dbSelectArea("SA6")
			SA6->(dbSetOrder(1))			
			SA6->( dbSeek(xFilial("SA6")+TSA6NDC->A6_COD + TSA6NDC->A6_AGENCIA + TSA6NDC->A6_NUMCON ) )

			dbSelectArea("SE1")
			cE1PORTADO 	:= TSA6NDC->A6_COD
			cE1AGEDEP 	:= TSA6NDC->A6_AGENCIA
			cE1CONTA 	:= TSA6NDC->A6_NUMCON

			fCalcBlt("MAN",SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)	// Gera Nosso Numero

		Endif	

		TSA6NDC->(dbCloseArea()) 

	EndIf //chamado:045310

	RestArea(_aArea)
	RestArea(_aArSD2)
	RestArea(aAreaSA1) // 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - fwnm - 23/06/2020
	RestArea(aAreaSE1) // 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - fwnm - 23/06/2020
	RestArea(aAreaSA6) // 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - fwnm - 23/06/2020

Return 


Static Function SqlVerificaProdutos()

	BeginSQL Alias "TRB"
		%NoPARSER%
		SELECT D2_GRUPO, D2_COD, D2_CF //Everson - 17/01/2019. Chamado 046222.
		FROM %Table:SD2% SD2
		WHERE SD2.D2_FILIAL  = %EXP:xFilial("SD2")%
		AND SD2.D2_DOC     = %EXP:SF2->F2_DOC%
		AND SD2.D2_SERIE   = %EXP:SF2->F2_SERIE%
		AND SD2.D2_CLIENTE = %EXP:SF2->F2_CLIENTE%
		AND SD2.D2_LOJA    = %EXP:SF2->F2_LOJA%

		ORDER BY D2_ITEM  
	EndSQl    
	         
RETURN(NIL)

/*/{Protheus.doc} User Function Dgdvpliv
	Calcula digito verificador codigo do campo livre CEF
	@type  Function
	@author Fernando Sigoli
	@since 06/01/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 032158
/*/
User Function Dgdvpliv(cCampoLiv)

	Local _nRSANT := 0

	nD01 := Val(Substr(cCampoLiv,01,1)) * 9
	nD02 := Val(Substr(cCampoLiv,02,1)) * 8
	nD03 := Val(Substr(cCampoLiv,03,1)) * 7
	nD04 := Val(Substr(cCampoLiv,04,1)) * 6
	nD05 := Val(Substr(cCampoLiv,05,1)) * 5
	nD06 := Val(Substr(cCampoLiv,06,1)) * 4
	nD07 := Val(Substr(cCampoLiv,07,1)) * 3
	nD08 := Val(Substr(cCampoLiv,08,1)) * 2
	nD09 := Val(Substr(cCampoLiv,09,1)) * 9
	nD10 := Val(Substr(cCampoLiv,10,1)) * 8
	nD11 := Val(Substr(cCampoLiv,11,1)) * 7
	nD12 := Val(Substr(cCampoLiv,12,1)) * 6
	nD13 := Val(Substr(cCampoLiv,13,1)) * 5 
	nD14 := Val(Substr(cCampoLiv,14,1)) * 4 
	nD15 := Val(Substr(cCampoLiv,15,1)) * 3
	nD16 := Val(Substr(cCampoLiv,16,1)) * 2 
	nD17 := Val(Substr(cCampoLiv,17,1)) * 9 
	nD18 := Val(Substr(cCampoLiv,18,1)) * 8
	nD19 := Val(Substr(cCampoLiv,19,1)) * 7
	nD20 := Val(Substr(cCampoLiv,20,1)) * 6 
	nD21 := Val(Substr(cCampoLiv,21,1)) * 5
	nD22 := Val(Substr(cCampoLiv,22,1)) * 4
	nD23 := Val(Substr(cCampoLiv,23,1)) * 3 
	nD24 := Val(Substr(cCampoLiv,24,1)) * 2 

	_nRSANT := nD01 + nD02 + nD03 + nD04 + nD05 + nD06 + nD07 + nD08 + nD09 + nD10 + nD11 + nD12+;
	           nD13 + nD14 + nD15 + nD16 + nD17 + nD18 + nD19 + nD20 + nD21 + nD22 + nD23 + nD24


	_nResto := ( _nRSANT % 11 ) //calcula para achar o resto da divisão

	_nResto := 11-_nResto       //subtrair o resto da divisao por 11

	If _nResto > 9  //se _nResto maior que 9, o DV será um a 0
		_RE_Campo := "0"
	Else
		_RE_Campo := Str(_nResto,1)
	Endif    

Return _RE_Campo

/*/{Protheus.doc} Static Function TelaRemessa
	calcula Difito Verificar codigo do campo livre Economica Federal.
	@type  Function
	@author Microsiga
	@since ?
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function TelaRemessa()

	cNotaOrig  := SPACE(9)
	cSerieOrig := SPACE(3)
	oDlg2      := NIL

	@ 00,000 TO 160,350 DIALOG oDlg2 TITLE "DADOS REMESSA CONTA ORDEM"

	@  05,010 SAY "PEDIDO: " +  SD2->D2_PEDIDO + "   NOTA: " + SF2->F2_DOC
	@  15,010 TO 60,160 TITLE "Informações da Nota Conta e Ordem "
	@  25,015 SAY " NOTA ORIGINAL: "
	@  45,015 SAY " SERIE ORIGINAL: "

	cNotaOrig  := SPACE(9)
	cSerieOrig := SPACE(3)

	@  25,080 GET cNotaOrig  VALID !Vazio() PICTURE "@!"
	@  45,080 GET cSerieOrig VALID !Vazio() PICTURE "@!"

	@ 65,100 BMPBUTTON TYPE 01 ACTION (GravaNFORI(),Close(oDlg2))
	//@ 80,130 BMPBUTTON TYPE 02 ACTION Close(oDlg2)

	ACTIVATE DIALOG oDlg2 CENTER

Return(NIL)

/*/{Protheus.doc} Static Function GravaNFORI
	(long description)
	@type  Function
	@author Microsiga
	@since ?
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GravaNFORI()

	DBSELECTAREA("SC5")
	DBSETORDER(1)
	IF DBSEEK(xFilial("SC5")+SD2->D2_PEDIDO)

		Reclock("SC5",.F.)

		SC5->C5_MENNOT5  := 'REF A NF ORIG: ' + cNotaOrig + ;
		' SERIE ORIG: '   + cSerieOrig + ;      
		' / ' 
		MsUnlock()

	ENDIF                  
	SC5->(dbCloseArea())

Return(NIL)

/*/{Protheus.doc} User Function VerVolume
	Verificar se tem Volume e Especie especifico MV_#PALLET
	@type  Function
	@author Adriana Oliveira
	@since 11/08/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 036402 
/*/
User Function VerVolume(_cFilial, _cSerie, _cDoc)

	Local _cPallet	:= Alltrim(GETMV("MV_#PALLET"))
	Local _cCodProd := ""
	Local _nQtd		:= 0
	Local _cQuery 	:= ""    

	// Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020
	Local aAreaAtu  := GetArea() 
	Local aRetDados := {}
	//

	_cQuery := "SELECT D2_COD COD,D2_QTSEGUM QTD FROM " + RETSQLNAME("SD2") + " (NOLOCK) "
	_cQuery += "WHERE D2_FILIAL = '" + _cFilial + "' AND D2_SERIE = '" + _cSerie + "' AND D2_DOC = '" + _cDoc + "' AND "
	_cQuery += "'"+_cPallet+"' LIKE '%'+Rtrim(D2_COD)+'%' AND D_E_L_E_T_ = ' ' "

	TcQuery _cQuery New Alias "TSD2"

	DbSelectArea("TSD2")            
	TSD2->(dbGoTop())

	If TSD2->(!Eof())

		_cCodProd 	:= Alltrim(TSD2->COD)
		_nQtd		:= TSD2->QTD / Val(Substr(_cPallet,at(_cCodProd,_cPallet)+6,3))

		// Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020

		If _nQtd > 0
			aAdd(aRetDados, "PALLETS")
			aAdd(aRetDados, _nQtd)
		EndIf

		/*
		If _nQtd > 0
			SF2->F2_ESPECI1 := "PALLETS"
			SF2->F2_VOLUME1 := _nQtd
		Endif
		*/
		
		//

	Endif	 

	DbSelectArea("TSD2")     
	dbCloseArea()     

	DbSelectArea("SF2")

	RestArea( aAreaAtu ) // Chamado n. 059092 || OS 060609 || FISCAL || ANDRESA || 8423 || ERRO LOG MSRUNLOCK - FWNM - 23/06/2020

Return aRetDados
//Return Nil

/*/{Protheus.doc} Static Function ExistFIE(cPrefixo,cNum,cParcela,cTipTit)
	Confere se existe adiantamento 
	@type  Static Function
	@author FWNM
	@since 18/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ExistFIE(cPrefixo,cNum,cParcela,cTipTit)

	Local lRet   := .f.
	Local cQuery := ""

	If Select("WorkFIE") > 0
		WorkFIE->( dbCloseArea() )
	EndIf

	cQuery := " SELECT COUNT(1) TT
	cQuery += " FROM " + RetSqlName("FIE") + " FIE (NOLOCK)
	cQuery += " WHERE FIE_FILIAL='"+FWxFilial("FIE")+"' 
	cQuery += " AND FIE_PREFIX='"+cPrefixo+"'
	cQuery += " AND FIE_NUM='"+cNum+"'
	cQuery += " AND FIE_PARCEL='"+cParcela+"'
	cQuery += " AND FIE_TIPO='"+cTipTit+"'
	cQuery += " AND FIE_CART='R'
	cQuery += " AND D_E_L_E_T_='' 

	tcQuery cQuery New Alias "WorkFIE"

	If WorkFIE->TT >= 1
		lRet := .t.
	EndIf

	If Select("WorkFIE") > 0
		WorkFIE->( dbCloseArea() )
	EndIf

Return lRet

/*/{Protheus.doc} fAbTelaCpl
  	Verifica se a tela se aberta para atualização/criação do CDD e CDT
	@type  Static Function
  	@author  Glauco Oliveira - Eleva
  	@since  01/09/2020
	@version 01
	@history Adoro - chamado 40
 /*/

Static Function fAbTelaCpl()
	
	Local lRet		:= .F.

	dbSelectArea( 'SD2' )
	SD2->( dbSetOrder( 3 ) )
	SD2->( dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) ) )
	While SD2->( !EOF() ) .And. ( xFilial( "SD2" ) + SD2->( D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) ) == SF2->( F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
		If !Empty( SD2->D2_NFORI )
			lRet	:= .T.
			Exit
		EndIf
		SD2->(DbSkip())
	EndDo

Return lRet

/*/{Protheus.doc} fAjustaCDD
	Realiza o ajuste da gravação da CDD
	@type  Static Function
	@author  Glauco Oliveira - Eleva
	@since   01/09/2020
	@version 01
	@history Adoro - chamado 40 
/*/

Static Function fAjustaCDD()

	Local aArea		:= GetArea()
	Local aAreaCDD 	:= CDD->( GetArea() )
  	Local aAreaCDT 	:= CDT->( GetArea() )
	Local cFilSD2	:= SF2->F2_FILIAL
	Local cNf		:= SF2->F2_DOC
	Local dEmissao	:= SF2->F2_EMISSAO
	Local cSerie   	:= SF2->F2_SERIE
	Local cCliFor 	:= SF2->F2_CLIENTE
	Local cLoja    	:= SF2->F2_LOJA
	Local cMenNota 	:= SF2->F2_MENNOTA
	Local cNFOri	:= ""
	Local cSerOri	:= ""
	Local cChvOri	:= ""
	Local cDesc		:= ""
	Local cIfComp 	:= Space( TamSX3( "CDD_IFCOMP" ) [ 1 ] )
	Local nOpca		:= 0
	Local aDados	:= {}
	Local dEmissOri	:= fEmissOri( SD2->D2_NFORI , SD2->D2_SERIORI , cCliFor , cLoja )
   	Local cDescComp :=  ""
	Local cTabGeni	:= AllTrim(SC5->C5_TABEGEN)

	If cTabGeni == "PO02MVES"
		nOpca	:= 1

		cIfComp	:= SuperGetMV("MV_#IFCOMP")

		fChgIfComp(cIfComp, @cDesc, @cDescComp) 
	Else
		If fAbTelaCpl()
		//Inicio Ticket 1165	- Adriana	   - 09/09/2020
		/*
			oModal := FWDialogModal():New()
			oModal:SetTitle("Complemento Bloco C113") 
			oModal:SetFreeArea( 500, 50 )
			oModal:SetEscClose( .T. )
			oModal:CreateDialog()

			@ 10,005	SAY "Cod.Inf.Compl." 													SIZE 73, 8 	OF oModal:GetPanelMain() PIXEL 
			@ 08,050	MSGET cIfComp		PICTURE "@!"	On change fChgIfComp(cIfComp, @cDesc, @cDescComp)	F3 "CCE"	SIZE 40,10	OF oModal:GetPanelMain() PIXEL	HASBUTTON

			@ 10,095	SAY "Dsc.Inf.Compl."                                                    Size 73, 8	OF oModal:GetPanelMain() PIXEL
			@ 08,140	MSGET oGet01 VAR cDesc 																									SIZE 350,9 	OF oModal:GetPanelMain() PIXEL	WHEN .F.

			@ 30,005	SAY "Desc. Compl."		                                                  SIZE 73, 8	OF oModal:GetPanelMain() PIXEL
			@ 28,050	MSGET cDescComp	PICTURE "@!"																						SIZE 440,10	OF oModal:GetPanelMain() PIXEL

			oModal:AddButton( "Confirmar"	,{|| (nOpca := 1, fConfirma(oModal, cIfComp)) }, "Confirmar"	, , .T., .F., .T., )

			oModal:Activate()
		*/
			@ 00,000 TO 150, 1000 DIALOG oDlg1 TITLE "Complemento Bloco C113"

			@ 10,005	SAY "Cod.Inf.Compl." 
			@ 08,050	GET cIfComp		PICTURE "@!"	valid fChgIfComp(cIfComp, @cDesc, @cDescComp)	F3 "CCE"	SIZE 40,10	

			@ 10,095	SAY "Dsc.Inf.Compl."  
			@ 08,140	GET cDesc 	SIZE 350,9 	WHEN .F.

			@ 30,005	SAY "Desc. Compl."	
			@ 28,050	GET cDescComp	PICTURE "@!" SIZE 440,10	

			@ 50,450        BMPBUTTON  TYPE 13 ACTION (nOpca := 1, fConfirma(cIfComp), Close(oDlg1)) 

			ACTIVATE DIALOG oDlg1 CENTER

		//Fim Ticket 1165	- Adriana	   - 09/09/2020

		EndIf
	EndIf

	If nOpca == 1
		If Empty(AllTrim(cMenNota))
			cMenNota	:= AllTrim(cDescComp)
		Else
			cMenNota	:= AllTrim(cMenNota) + " - " + AllTrim(cDescComp)
		EndIf
		// Atualiza mensagem para nota
		RecLock("SF2", .F.)
		SF2->F2_MENNOTA		:= cMenNota
		SF2->(MsUnlock())

		// Tratativas para os complementos.
		dbSelectArea( "SD2" )
		SD2->( DbSetOrder( 3 ) )
		SD2->( DbGoTop() )
		If SD2->( DbSeek( FWxFilial("SD2") + cNf + cSerie + cCliFor +  cLoja ) )
			While !SD2->( Eof() ) .And. cFilSD2 == SD2->D2_FILIAL .And. cNf == SD2->D2_DOC .And.;
			cSerie == SD2->D2_SERIE .And. cCliFor == SD2->D2_CLIENTE .And.;
			cLoja == SD2->D2_LOJA
				If !Empty( SD2->D2_NFORI ) .And. !Empty( SD2->D2_SERIORI ) .And. ( cNFOri + cSerOri # SD2->( D2_NFORI + D2_SERIORI ) )
					aDados		:= {}
					cNFOri		:= SD2->D2_NFORI
					cSerOri		:= SD2->D2_SERIORI
					cChvOri		:= fChvNfeOri( cNFOri , cSerOri , cCliFor , cLoja )

					// Dados para atualização das tabelas CDD e CDT
  					aAdd(aDados, cNf)
					aAdd(aDados, cSerie)
					aAdd(aDados, cCliFor)
					aAdd(aDados, cLoja)
					aAdd(aDados, cNFOri)
					aAdd(aDados, cSerOri)
					aAdd(aDados, cIfComp)
					aAdd(aDados, cDescComp)
					aAdd(aDados, cChvOri)

					// Cria/Atualiza CDD
					Processa({|| atlzCDD(aDados) }, "Atualizando tabela de complemento (CDD)...")

					// Cria/Atualiza CDT
					Processa({|| atlzCDT(aDados) }, "Atualizando tabela de complemento (CDT)...")
				EndIf

				SD2->(DbSkip())	
			EndDo	
		EndIf
	EndIf

	RestArea(aAreaCDT)
	RestArea(aAreaCDD)
	RestArea(aArea)

Return

/*/{Protheus.doc} fChgIfComp
	Change do campo Inf. Compl.
	@type  Static Function
	@author  Glauco Oliveira - Eleva
	@since   01/09/2020
	@version 01
	@history Adoro - chamado 40 
  /*/

Static Function fChgIfComp(cIfComp, cDesc, cDescComp)

	dbSelectArea('CCE')
	CCE->(dbSetOrder(1))
	If CCE->(dbSeek(xFilial('CCE') + cIfComp))
		cDesc	:= CCE->CCE_DESCR   
		cDescComp := CCE->CCE_DESCR
	EndIf

Return

/*/{Protheus.doc} fConfirma
	Valida informações digitadas
 	@type  Static Function
  	@author  Glauco Oliveira - Eleva
  	@since   01/09/2020
  	@version 01
 	@history Adoro - chamado 40 
/*/

Static Function fConfirma(cIfComp)
//Static Function fConfirma(oModal, cIfComp)
	If Empty(cIfComp)
		HELP(' ',1,"CODINFVAZIO" ,,"O campo Cod.Inf.Compl. é obrigatório.",2,0,,,,,, {"Preencha o campo Cod.Inf.Compl. e tente novamente."})
	Else
		dbSelectArea('CCE')
		CCE->(dbSetOrder(1))
		If !CCE->(dbSeek(xFilial('CCE') + cIfComp))
			HELP(' ',1,"CODINFNOREG" ,,"O Cod.Inf.Compl. não foi localizado.",2,0,,,,,, {"Verifique o Cod.Inf.Compl. digitado e tente novamente."})
//		Else
//			oModal:Deactivate()
		EndIf
	EndIf
Return

/*/{Protheus.doc} atlzCDD
 	Atualiza tabela de complemento CDD
 	@type  Static Function
  	@author  Glauco Oliveira - Eleva
  	@since   01/09/2020
  	@version 01
 	@history Adoro - chamado 40 
/*/

Static Function atlzCDD(aDados)

	dbSelectArea('CDD')
	CDD->(dbSetOrder(1)) //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF
	If !CDD->(dbSeek(xFilial('CDD') + "S" + aDados[1] + aDados[2] + aDados[3] + aDados[4] + aDados[5] + aDados[6] + aDados[3] + aDados[4]))
		RecLock("CDD", .T.)
			CDD->CDD_FILIAL	:= xFilial("CDD")	
			CDD->CDD_TPMOV	:= "S"	
			CDD->CDD_DOC	:= aDados[1]	
			CDD->CDD_SERIE	:= aDados[2]	
			CDD->CDD_CLIFOR	:= aDados[3]	
			CDD->CDD_LOJA	:= aDados[4]									
			CDD->CDD_PARREF	:= aDados[3]
			CDD->CDD_LOJREF	:= aDados[4]
			CDD->CDD_DOCREF	:= aDados[5]
			CDD->CDD_SERREF	:= aDados[6]
			CDD->CDD_IFCOMP	:= aDados[7]
			CDD->CDD_CHVNFE	:= aDados[9]
		CDD->(MsUnlock())   
	Else   
		If Empty(CDD->CDD_IFCOMP)
			RecLock("CDD", .F.)
				CDD->CDD_IFCOMP	:= aDados[7]
			CDD->(MsUnlock())   
		EndIf
	EndIf	

Return

/*/{Protheus.doc} atlzCDT
  	Atualiza tabela de complemento CDT
	@type  Static Function
  	@author  Glauco Oliveira - Eleva
  	@since   01/09/2020
  	@version 01
	@history Adoro - chamado 40 
/*/

Static Function atlzCDT(aDados)

	// Cria/Atualiza CDT
	dbSelectArea('CDT')
	CDT->(dbSetOrder(1)) //CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SERIE+CDT_CLIFOR+CDT_LOJA+CDT_IFCOMP
	If !CDT->(dbSeek(xFilial('CDT') + "S" + aDados[1] + aDados[2] + aDados[3] + aDados[4]+ aDados[7] ) )// .And. SF1->F1_TIPO == "N"
		RecLock("CDT", .T.)
			CDT->CDT_FILIAL	:= xFilial("CDT")	
			CDT->CDT_TPMOV	:= "S"	
			CDT->CDT_DOC	:= aDados[1]	
			CDT->CDT_SERIE	:= aDados[2]	
			CDT->CDT_CLIFOR	:= aDados[3]	
			CDT->CDT_LOJA	:= aDados[4]
			CDT->CDT_IFCOMP	:= aDados[7]
			CDT->CDT_DCCOMP	:= aDados[8]
			CDT->(MsUnlock())
	EndIf

Return

/*/{Protheus.doc} fEmissOri
	Retorna a emissão de origem
 	@type  Static Function
  	@author  Glauco Oliveira - Eleva
  	@since   01/09/2020
  	@version 01
	@history Adoro - chamado 40 
/*/

Static Function fEmissOri(cNFOri, cSerOri, cCliFor, cLoja)

	Local dEmissOri		:= dDataBase
	Local cAliasQry		:= GetNextAlias()
	Local cQuery		:= ""

	BeginSQL Alias cAliasQry
		SELECT 
			SF1.F1_EMISSAO EMISSAO_ORI
		FROM 
			%Table:SF1% SF1
		WHERE 
			SF1.F1_FILIAL	= %xFilial:SF1% AND 
			SF1.F1_DOC		= %Exp:cNFOri% AND
			SF1.F1_SERIE	= %Exp:cSerOri% AND
			SF1.F1_FORNECE	= %Exp:cCliFor% AND 
			SF1.F1_LOJA		= %Exp:cLoja% AND
			SF1.%notDel%
	EndSQL

	cQuery	:= GetLastQuery()[2]
	ConOut(cQuery)

	dbSelectArea( cAliasQry )
	( cAliasQry )->( DbGoTop() )
	If ( cAliasQry )->( !Eof() )
		dEmissOri	:= SToD( ( cAliasQry )->EMISSAO_ORI )
	EndIf

Return dEmissOri

/*/{Protheus.doc} fChvNfeOri
	Retorna a chave da NF de origem
 	@type  	Static Function
  	@author  Glauco Oliveira - Eleva
  	@since   01/09/2020
  	@version 01
	@history Adoro - chamado 40 
/*/

Static Function fChvNfeOri(cNFOri, cSerOri, cCliFor, cLoja)

	Local cChaveNfe		:= ""
	Local cAliasQry		:= GetNextAlias()
	Local cQuery		  := ""

	BeginSQL Alias cAliasQry
		SELECT 
			SF1.F1_CHVNFE CHAVENFE
		FROM 
			%Table:SF1% SF1
		WHERE 
			SF1.F1_FILIAL	= %xFilial:SF1% AND 
			SF1.F1_DOC		= %Exp:cNFOri% AND
			SF1.F1_SERIE	= %Exp:cSerOri% AND
			SF1.F1_FORNECE	= %Exp:cCliFor% AND 
			SF1.F1_LOJA		= %Exp:cLoja% AND
			SF1.%notDel%
	EndSQL

	cQuery	:= GetLastQuery()[2]
	ConOut(cQuery)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!Eof())
		cChaveNfe	:= (cAliasQry)->CHAVENFE
	EndIf

Return cChaveNfe

/*/{Protheus.doc} u_2460IA0
//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_2460IA0( uPar1, uPar2, uPar3, uPar4 )
Return( fCalcBlt( uPar1, uPar2, uPar3, uPar4 ) )
