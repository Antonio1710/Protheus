#Include "Protheus.CH"
#Include "TOPCONN.CH"

#DEFINE USADO Chr(0)+Chr(0)+Chr(1) 	

/*/{Protheus.doc} User Function ADRANFIMP
	Atualiza os arquivos de Importacao para os Itens de SC
	@type  Function
	@author HCCONSYS
	@since 26/05/2008
	@version version
	@history Alteração - WILLIAM COSTA    - 03/09/2019 - 051417, Adicionado campo Transportadora e loja, criado regra para nao deixar gerar uma nova nota se ja existe uma nota salva no campo ZZA_NUMNF
	@history Alteração - Adriana Oliveira - 13/12/2019 - Revisão leiaute fonte
	@history Alteração - Adriana Oliveira - 13/12/2019 - 053647, para corrigir busca na tabela SFT e gravar corretamente os valores no Livro Fiscal
	@history Alteração - WILLIAM COSTA    - 04/03/2020 - 056219, Colocado trava no tudo OK para que se não tiver Codigo da Transportadora e Loja Cadastrado dar a mensagem que está em branco e não deixa passar ao não ser que preencha.
	@history Alteração - Adriana Oliveira - 18/03/2020 - 056339, para somar o valor do AFRMM no total da NF
/*/

User Function ADRANFIMP()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	Private cCadastro	:= "Digitacao da Nf de Entrada de Importacao"
	Private aCores		:= {}
	Private aRotina		:= { 		{ "Pesquisar	" 			,"AxPesqui" 		, 0, 1},;								
									{ "Visualizar	" 			,"Axvisual" 		, 0, 2},;
									{ "Inclusao		" 			,"U_CadNF(3)" 		, 0, 3},;
									{ "Alteracao	" 			,"U_CadNF(4)" 		, 0, 4},;
									{ "Exclusao		" 			,"U_Excluzf()" 		, 0, 5},;
									{ "Gera NF 		"			,"U_GeraNF()" 		, 0, 5}}
	
	mBrowse(6, 1, 22, 75, "ZZA",,,,,,aCores)
	
Return(Nil)

/*/{Protheus.doc} User Function CadNF
	Tela de Cadastro da NF de Importação
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function CadNF(_nOpca)

	Private oInf,oInf1,oInf2,oInf3,oInf4,oInf5,oInf6,oInf7,oInf8
	Private nOpca:=0
	Private aObjects  	:= {},aPosObj :={}
	Private aSize     	:= MsAdvSize()
	Private aInfo     	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Private aCols      	:= {}
	Private aEntr      	:= {}
	Private aHeader    	:= {}
	Private aSMValAdu	:={}
	Private _ndespesas	:= 0
	Private _nFrete		:= 0
	Private _ntaxaus	:= 0
	Private _nSeguro	:= 0
	Private _nSiscoMex	:= 0
	Private _nPBrut     := 0
	Private _nPLiquid   := 0     
	Private cNumDI		:= Criavar("ZZA_NUMDI",.F.)
	Private cCodigo		:= Criavar("ZZA_CODIGO",.F.)		&& Codigo Sequencial de DI para permitir que sejam repetidos os numeros DI
	Private _nBaseICMS	:= 0
	Private _nValorICMS	:= 0
	Private _nBaseIPI	:= 0
	Private _nValorIPI	:= 0
	Private _nBasePIS	:= 0
	Private _nValorPIS	:= 0
	Private _nBaseCOF	:= 0
	Private _nValorCOF	:= 0
	Private _nValorTot	:= 0
	Private _Emissao	:= dDataBase 
	Private _nSisComex	:= 0
	Private _nPBrut     := 0
	Private _nPLiquid   := 0
	Private _cnome		:= ""
	Private _ncontrol	:= 0
	Private _CODSB1		:= ""
	Private _nValAdu	:= 0
	Private _nBaseII	:= 0
	Private _nValorII	:= 0   
	Private cFornece	:= CriaVar("A2_COD",.F.)
	Private cLoja		:= CriaVar("A2_LOJA",.F.)
	Private cTransp		:= CriaVar("A4_COD",.F.) // WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
	Private cLojaTrans  := CriaVar("A4_LOJTRA",.F.) // WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
	Private cCondPag	:= CriaVar("E4_CODIGO",.F.)
	Private oGetDados
	Private nQuantEmb	:= 0
	Private cEspecie	:= Space(30)
	Private nPBruto		:= 0
	Private nPLiquido	:= 0
	Private cConta		:= CriaVar("ZZB_CONTA",.F.)
	Private cItemConta	:= CriaVar("ZZB_ITEMCT",.F.)
	Private cCC			:= CriaVar("ZZB_CC",.F.)
	Private cCVLV		:= CriaVar("ZZB_CVLV",.F.)
	Private cNREF		:= CriaVar("ZZA_NREF",.F.)
	Private cSREF		:= CriaVar("ZZA_SREF",.F.)
	Private cNUMNF		:= CriaVar("ZZA_NUMNF",.F.)
	Private cSERINF		:= CriaVar("ZZA_SERINF",.F.)
	//Incluido novos campos para DI - 26/05/11 Ana Helena    
	Private cLocDes     := CriaVar("ZZA_LOCDES",.F.) //Space(60)
	Private cUFDes      := Criavar("ZZA_UFDESE",.F.)
	Private cDataDes    := Criavar("ZZA_DTDESE",.F.)
	Private cAdicao		:= CriaVar("ZZB_ADICAO",.F.)
	Private cSeqAdi 	:= CriaVar("ZZB_SEQADI",.F.)
	Private nDescAd 	:= 0
	Private cC7Num	 	:= CriaVar("ZZB_C7NUM",.F.)
	Private cItemPC 	:= CriaVar("ZZB_ITEMPC",.F.)
	//Incluido novos campos para DI - 16/03/2015 para NFe 3.10 - por Adriana
	Private c_VTRANS	:= CriaVar("ZZA_VTRANS",.F.)    
	Private n_VAFRMM	:= CriaVar("ZZA_VAFRMM",.F.) 
	Private c_INTERM	:= CriaVar("ZZA_INTERM",.F.) 
	Private c_CNPJAE    := CriaVar("ZZA_CNPJAE",.F.) 
	Private c_UFTERC	:= CriaVar("ZZA_UFTERC",.F.) 
	Private c_ACDRAW	:= CriaVar("ZZA_ACDRAW",.F.) 
	Private oVTRANS 
	Private a_VTRANS	:= {"01=Maritima","02=Fluvial","03=Lacustre","04=Aerea","05=Postal","06=Ferroviaria",;
	  					    "07=Rodoviaria","08=Conduto","09=Meios proprios","10=Entrada/Saida ficta"}   
	Private oINTERM 
	Private a_INTERM	:= {"1=Importacao por conta propria","2=Importacao por conta e ordem","3=Importacao por encomenda"}

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	nUsado		:= 0
	aHeader 	:= {}
	aCols		:= {}
	aEntr		:= {}
	_inclui		:= .F.
	_incluir	:= .F.
		
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	DbSeek("ZZB_COD")
	AADD(AHEADER,{"Produto"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_QUANT")
	AADD(AHEADER,{"Quant"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_VUNIT")
	AADD(AHEADER,{"Vlr Unit"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_TOTAL")                                                                                                
	AADD(AHEADER,{"Vlr Total"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_TES")
	AADD(AHEADER,{"TES"			,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_CF")
	AADD(AHEADER,{"CFOP"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_FRETE")
	AADD(AHEADER,{"Valor Frete"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_SEGURO")
	AADD(AHEADER,{"Valor Seguro",X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_DESPES")
	AADD(AHEADER,{"Valor Despesas"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_BASEII")
	AADD(AHEADER,{"Base II"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_PII")
	AADD(AHEADER,{"% II"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_II")
	AADD(AHEADER,{"Valor II"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_BASEIP")
	AADD(AHEADER,{"Base IPI"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_IPI")
	AADD(AHEADER,{"% IPI"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_VALIPI")
	AADD(AHEADER,{"Vlr IPI"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_BSIMP5")
	AADD(AHEADER,{"Base PIS"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_ALIMP5")
	AADD(AHEADER,{"% PIS"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_VLIMP5")
	AADD(AHEADER,{"Vlr PIS"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_BSIMP6")
	AADD(AHEADER,{"Base COFINS"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_ALIMP6")
	AADD(AHEADER,{"% COFINS"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_VLIMP6")
	AADD(AHEADER,{"Vlr COFINS"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_BASEIC")
	AADD(AHEADER,{"Base ICMS"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_PICM")
	AADD(AHEADER,{"% ICMS"		,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_VALICM")
	AADD(AHEADER,{"Vlr ICMS"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_CONTA")
	AADD(AHEADER,{"Conta Contabil",X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, "ExistCPO('CT1')",X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_ITEMCT")
	AADD(AHEADER,{"Item Contabil",X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, "ExistCPO('CTD')",X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_CC")
	AADD(AHEADER,{"Centro de Custo"	,X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_CVLV")
	AADD(AHEADER,{"Classe Valor",X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, "ExistCPO('CTH')",X3_USADO, X3_TIPO, X3_ARQUIVO } )
	//Inserido 26/05/11 Ana Helena. Pois incluido campos para DI
	DbSeek("ZZB_ADICAO")
	AADD(AHEADER,{"Num Adicao",X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_SEQADI")
	AADD(AHEADER,{"Num Seq Adicao",X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_DESCADI")
	AADD(AHEADER,{"Val desc Item",X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_C7NUM")
	AADD(AHEADER,{"No.Ped.Compra",X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	DbSeek("ZZB_ITEMPC")
	AADD(AHEADER,{"Item PC",X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO } )
	
	If _nOpca == 4
	
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+ZZA->ZZA_FORNECE+ZZA->ZZA_LOJA,.T.)
		
		&&	Atualiza variaves
		
		cCodigo				:= ZZA->ZZA_CODIGO
		cNumDI				:= ZZA->ZZA_NUMDI
		_nBaseICMS			:= ZZA->ZZA_BASEIC
		_nValorICMS			:= ZZA->ZZA_VALICM
		_nBaseIPI			:= ZZA->ZZA_BASEIP
		_nValorIPI			:= ZZA->ZZA_VALIPI
		_nBasePIS			:= ZZA->ZZA_BAIMP5
		_nValorPIS			:= ZZA->ZZA_VLIMP5
		_nBaseCOF			:= ZZA->ZZA_BSIMP6
		_nValorCOF			:= ZZA->ZZA_VLIMP6
		_nValorTot			:= ZZA->ZZA_VALBRU
		_nFrete				:= ZZA->ZZA_FRETE
		_nSeguro			:= ZZA->ZZA_SEGURO
		_Emissao			:= ZZA->ZZA_EMISSA
		_nSisComex			:= ZZA->ZZA_DESPES                        
		_nPBrut     		:= ZZA->ZZA_PBRUT
		_nPLiquid   		:= ZZA->ZZA_PLIQU
		cCondPag			:= ZZA->ZZA_CONDPG
		_ntotalUS			:= 0
		_nBaseII			:= ZZA->ZZA_BASEII
		_nValorII			:= ZZA->ZZA_II
		cFornece			:= ZZA->ZZA_FORNEC
		cLoja				:= ZZA->ZZA_LOJA
		cTransp             := ZZA->ZZA_TRANSP // WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
		cLojaTrans          := ZZA->ZZA_LOJATR // WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
		nQuantEmb			:= ZZA->ZZA_QTDEMB
		cEspecie			:= ZZA->ZZA_ESPECI
		nPBruto				:= ZZA->ZZA_PBRUTO
		nPLiquido			:= ZZA->ZZA_LIQUID	           
		cNREF				:= ZZA->ZZA_NREF
		cSREF				:= ZZA->ZZA_SREF                  
		cNUMNF				:= ZZA->ZZA_NUMNF	
		cSERINF				:= ZZA->ZZA_SERINF
		cLocDes				:= ZZA->ZZA_LOCDES
		cUFDes				:= ZZA->ZZA_UFDESE
		cDataDes			:= ZZA->ZZA_DTDESE
		//nfe 3.10
		c_VTRANS			:= ZZA->ZZA_VTRANS 
		n_VAFRMM			:= ZZA->ZZA_VAFRMM 
		c_INTERM			:= ZZA->ZZA_INTERM
		c_CNPJAE    		:= ZZA->ZZA_CNPJAE
		c_UFTERC			:= ZZA->ZZA_UFTERC
		c_ACDRAW			:= ZZA->ZZA_ACDRAW
	
	Endif
	
	cLinhaOk	:="U_XalcImp()"
	cTudoOk 	:="U_Xed03TOK()"
	AADD(aObjects,{0,85,.T.,.F.,.F.})
	AADD(aObjects,{130,130,.T.,.T.,.F.})
	
	aPosObj:=MsObjSize(aInfo,aObjects)
	
	Define MsDialog oDlg Title cCadastro From aSize[ 07 ], 00 To aSize[ 06 ], aSize[ 05 ] Pixel Of oMainWnd
	
	If _nOpca == 3                                                               
		fRetCod()	&& Retorna Sequencia de codigo em ZZA.
		
		@ 2.5, 00.5 SAY   "Codigo"
		@ 2.5, 05.0 MSGET cCodigo			Valid ExistChav("ZZA") 
		
		@ 2.5, 12.5 SAY   "Num. DI"
		@ 2.5, 17.0 MSGET cNumDI				
	Else                                                          
		
		@ 2.5, 00.5 SAY   "Codigo"
		@ 2.5, 05.0 MSGET cCodigo			When .F.
		
		@ 2.5, 12.5 SAY   "Num. DI "
		@ 2.5, 17.0 MSGET ZZA->ZZA_NUMDI  	When .F.
	Endif	
	
	@ 2.5, 28.5 SAY   "Fornecedor "			
	@ 2.5, 33.0 MSGET cFornece				Valid ExistCPO("SA2") 	F3 "SA2ADR"
	@ 2.5, 38.0 MSGET cLoja	
	
	// Em testes - Paulo - TDS - 26/05/2011
	@ 2.5, 41.5 SAY   "Data DI "
	@ 2.5, 45.0 MSGET _emissao   			Valid !empty(_emissao)      
	
	@ 2.5, 51.5 SAY   "Cond.Pag "
	@ 2.5, 55.0 MSGET cCondPag   			Valid ExistCPO("SE4") .AND. !Empty(cCondPag) 	F3 "SE4"
	
	@ 3.5, 00.5 SAY   "Base ICMS "
	@ 3.5, 12.5 SAY   "Vlr ICMS "
	@ 3.5, 28.5 SAY   "Base IPI "
	
	// Em testes - Paulo - TDS - 26/05/2011
	@ 3.5, 41.5 SAY   "Vlr IPI "
	@ 3.5, 51.5 SAY   "Base II "
	
	@ 3.5, 05.0 MSGET oInf0 	VAR _nBaseICMS 		Picture "@E 999,999.99" 	When .F.
	@ 3.5, 17.0 MSGET oInf1 	VAR _nValorICMS 	Picture "@E 999,999.99"
	@ 3.5, 33.0 MSGET oInf2 	VAR _nBaseIPI  		Picture "@E 999,999.99"		When .F.
	
	// Em testes - Paulo - TDS - 26/05/2011
	@ 3.5, 45.0 MSGET oInf3 	VAR _nValorIPI  	Picture "@E 999,999.99"
	@ 3.5, 54.0 msget oInf11 	VAR _nBaseII	  	Picture "@E 999,999.99"		When .F.
	
	@ 4.5, 00.5 SAY   "Base PIS  "
	@ 4.5, 12.5 SAY   "Vlr PIS "
	@ 4.5, 28.5 SAY   "Base COFINS "
	
	// Em testes - Paulo - TDS - 26/05/2011
	@ 4.5, 41.5 SAY   "Vlr COFINS "
	@ 4.5, 51.5 SAY   "Vlr II"
	
	@ 4.5, 05.0 MSGET oInf4 	VAR _nBasePIS 		Picture "@E 999,999.99"		When .F.
	@ 4.5, 17.0 MSGET oInf5 	VAR  _nValorPIS 	Picture "@E 999,999.99"
	@ 4.5, 33.0 MSGET oInf6 	VAR  _nBaseCOF  	Picture "@E 999,999.99"		When .F.
	
	// Em testes - Paulo - TDS - 26/05/2011
	@ 4.5, 45.0 msget oInf7 	VAR _nValorCOF  	Picture "@E 999,999.99"
	@ 4.5, 54.0 MSGET oInf12	VAR _nValorII   	Picture "@E 999,999.99"
	
	@ 5.5, 00.5 SAY   "Frete "
	@ 5.5, 12.5 SAY   "Seguro  "
	@ 5.5, 28.5 SAY   "Despesas "
	
	@ 5.5, 05.0 MSGET _nFrete		 Picture "@E 999,999.99"    //Valid _nFrete > 0
	//@ 5.5, 05.0 MSGET _nDespesas Picture "@E 999,999.99"    Valid _nDespesas > 0
	
	GetdRefresh()
	
	@ 5.5, 17.0 MSGET _nSeguro  	Picture "@E 999,999.9999"    //Valid _nSeguro > 0
	//@ 4.5, 17.0 MSGET _ntaxaus  Picture "@E 999,999.9999"    Valid _ntaxaus > 0
	@ 5.5, 33.0 MSGET _nSiscoMex 	Picture "@E 999,999.99"  	 //Valid _nSiscomex >= 0
	
	&& Novo                  
	
	@ 6.5, 00.5 SAY   "Quant.Emb."
	@ 6.5, 05.0 MSGET nQuantEmb			Picture "@E 999,999.99"  	 Valid nQuantEmb >= 0
	
	@ 6.5, 12.5 SAY   "Especie "			
	@ 6.5, 17.0 MSGET cEspecie				Picture "@!" 
		
	@ 6.5, 41.5 SAY   "Peso Bruto "
	@ 6.5, 45.0 MSGET nPBruto   			Picture "@E 999,999.99"  	 Valid nPBruto >= 0
	                            
	@ 6.5, 51.5 SAY   "Peso Liquido "
	@ 6.5, 56.0 MSGET nPLiquido			Picture "@E 999,999.99"  	 Valid nPLiquido >= 0
	
	@ 7.5, 00.5 SAY   "N/REF "
	@ 7.5, 03.0 MSGET cNREF				Picture "@!" Size 60, 10 	 
	
	// Testes - PAULO - TDS - 26/05/11
	@ 7.5, 12.5 SAY   "S/REF "			
	@ 7.5, 17.0 MSGET cSREF				Picture "@!" Size 60, 10   
	
	// Testes PAULO - TDS - 26/05/11
	@ 5.5, 41.5 SAY   "UF Desemb "			
	@ 5.5, 45.0 MSGET cUFDes				Picture "@!" 
	
	// Testes PAULO - TDS - 26/05/11
	@ 5.5, 51.5 SAY   "Data Desemb "			
	@ 5.5, 56.0 MSGET cDataDes				Picture "99/99/99"    
	
	// Testes PAULO - TDS - 26/05/11
	@ 7.5, 41.5 SAY   "Local Des "			
	@ 7.5, 45.0 MSGET cLocDes				Picture "@S40" 
	
	// Campos novos para NFe 3.10 
	@ 8.5, 00.5 SAY   "Via Transp."			
	@ 8.5, 05.0 ComboBox oVTRANS Var c_VTRANS Items a_VTRANS Size 140, 10 //Pixel Of oDlg
	
	@ 8.5, 28.5 SAY   "Val. AFRMM"			
	@ 8.5, 33.0 MSGET n_VAFRMM      		Picture "@E 999,999,999,999.99" Size 060, 10
	
	@ 8.5, 41.5 SAY   "Forma Import."			
	@ 8.5, 48.0 ComboBox oINTERM Var c_INTERM Items a_INTERM Size 140, 10 //Pixel Of oDlg
	
	@ 9.5, 00.5 SAY   "CNPJ Adqui."			
	@ 9.5, 05.0 MSGET c_CNPJAE      		Picture "@R 99.999.999/9999-99" Size 050, 10
	
	@ 9.5, 12.5 SAY   "UF Terceiro"			
	@ 9.5, 17.0 MSGET c_UFTERC     		    Picture "@!"    F3 "12"
	
	@ 9.5, 41.5 SAY   "Num Drawback"			
	@ 9.5, 48.0 MSGET c_ACDRAW     		    Picture "@!"    
	
	@ 10.5, 00.5 SAY   "Transp:" // WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO			
	@ 10.5, 05.0 MSGET cTransp Valid ExistCPO("SA4") F3 "SA4" // WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
	@ 10.5, 10.5 MSGET cLojaTrans // WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
	
	nAliQCOFIN	:= GETMV("MV_TXCOFIN")  		&& Aliquota de Cofins
	nAliqPIS	:= GETMV("MV_TXPIS") 			&& Aliquota de PIS
	
	If _nOpca == 4
	
		dbSelectArea("ZZB")
		dbSetOrder(1)
		dbSeek(xFilial("ZZB")+ZZA->ZZA_CODIGO,.T.)
		While !eof().and. ZZB->ZZB_CODIGO == ZZA->ZZA_CODIGO
			
			dbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xfilial("SF4")+ZZB->ZZB_TES)
					
			dbSelectArea("ZZB")
			dbSetOrder(1)
							
			Aadd(ACOLS,{ZZB_COD,;
							ZZB_QUANT,;
							ZZB_VUNIT,;
							ZZB_TOTAL,;
							ZZB_TES,;
							ZZB_CF,;
							ZZB_FRETE,;
							ZZB_SEGURO,;
							ZZB_DESPES,;
							ZZB_BASEII,;	
							ZZB_PII,;
							ZZB_II,;
							ZZB_BASEIPI,;
							ZZB_IPI,;
							ZZB_VALIPI,;	
							ZZB_BSIMP5,;
							ZZB_ALIMP5,;
							ZZB_VLIMP5,;
							ZZB_BSIMP6,;
							ZZB_ALIMP6,;
							ZZB_VLIMP6,;
							ZZB_BASEIC,;
							ZZB_PICM,;
							ZZB_VALICM,;
							ZZB_CONTA,;
							ZZB_ITEMCT,;
							ZZB_CC,;
							ZZB_CVLV,; 
							ZZB_ADICAO,;
							ZZB_SEQADI,;
							ZZB_DESCAD,;
							ZZB_C7NUM,;
							ZZB_ITEMPC,;
							.F.	}) 
	
			_ncontrol:=_ncontrol+1
			dbSelectArea("ZZB")
			dbSkip()
		Enddo
	
	Endif
	
	cCampos := "ZZB_PRODUTO"
	
	oGetDados := MSGetDados():New(160,00,270,aPosObj[2,4],_nOpca,cLinhaOK,cTudoOK,,)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGetDados:TudoOK(),nOpca:=1,nOpca:=0)},{||oDlg:End()},oGetDados:Refresh())
	
	If nOpca == 1
		if _nOpca == 3
			u_GravaSZ(3) 	&& Inclui ZZA/ZZB
		Else
			u_GravaSZ(4) 	&& Altera ZZA/ZZB
		Endif
	Endif

Return(nil)

/*/{Protheus.doc} User Function GravaSZ
	Grava dados da NF de Importação
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/

User Function GravaSZ(nOPc)

	Local dEntCli2   
	Local dEntOld	:= CriaVar("C6_ENTREG",.F.)     
	Local nP01 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_NCM'})
	Local nP02 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_ITEM'})
	Local nP03 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_COD'})
	Local nP04 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_QUANT'})
	Local nP05 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_VUNIT'})
	Local nP06 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_TOTAL'})
	Local nP07 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_INVOIC'})
	Local nP08 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_PEDIDO'})
	Local nP09 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_PICM'})
	Local nP10 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_PII'})
	Local nP11 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_IPI'})
	Local nP12 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_BASEIC'})
	Local nP13 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_VALICM'})
	Local nP14 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_BASEIP'})
	Local nP15 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_VALIPI'})
	Local nP16 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_BASEII'})
	Local nP17 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_II'})
	Local nP18 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_TES'})
	Local nP19 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_ITEMPC'})
	Local nP20 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_BSIMP5'})
	Local nP21 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_VLIMP5'})
	Local nP22 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_ALIMP5'})
	Local nP23 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_BSIMP6'})
	Local nP24 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_VLIMP6'})
	Local nP25 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_ALIMP6'})
	Local nP26 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_LOCAL'})
	Local nP27 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_DESPES'})
	Local nP28 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_CODFAB'})
	Local nP29 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_LOJFAB'})
	Local nP30 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_EMISSA'})
	Local nP31 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_UM'})
	Local nP32 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_VALADU'})
	Local nP33 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_DATPRF'})
	Local nP34 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_TOTAL'})
	Local nP35 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_ADICAO'})
	Local nP36 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_SEQADI'})
	Local nP37 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_DESCAD'})
	Local nP38 		:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_C7NUM'})

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	DbSelectArea("ZZB")
	DbSetOrder(1)
	Dbseek(xfilial("ZZB")+cCodigo)
	
	IF !Empty(ZZB->ZZB_NUMNF) && Se ja foi gerada NF nao pode regravar Aviso de Embarque
		Return(nil)
	endif
	
	If nOpc == 4
	
		While !eof().and. ZZB->ZZB_CODIGO == ZZA->ZZA_CODIGO
		
			dbSelectArea("ZZB")
			RecLock("ZZB",.F.)
			DbDelete()
			MsUnlock()
			DbSkip()
			
		Enddo
	
	Endif
	
	nAliQCOFIN	:= GETMV("MV_TXCOFIN")  	&& Aliquota de Cofins
	nAliqPIS	:= GETMV("MV_TXPIS") 			&& Aliquota de PIS
	
	_nTotMerc	:= 0
	_nTotII		:= 0
	
	For zd:=1 To len(Acols) 	&& Grava ZZB
			
		dbSelectArea("ZZB")
		RecLock("ZZB",.T.)
			ZZB_FILIAL 		:= xFilial("ZZB")
			ZZB_CODIGO		:= cCodigo
			ZZB_NUMDI		:= cNumDI
			ZZB_ITEM 		:= strzero(zd,4)
			ZZB_COD			:= Acols[zd,01]
			ZZB_QUANT 		:= Acols[zd,02]
			ZZB_VUNIT		:= Acols[zd,03]
			ZZB_TOTAL		:= Acols[zd,04]
			ZZB_TES   		:= Acols[zd,05]
			ZZB_CF	  		:= Acols[zd,06]       
			ZZB_FRETE		:= Acols[zd,07]
			ZZB_SEGURO		:= Acols[zd,08]
			ZZB_DESPES		:= Acols[zd,09] 
			ZZB_BASEII		:= Acols[zd,10]
			ZZB_PII			:= Acols[zd,11]
			ZZB_II	 		:= Acols[zd,12]
			ZZB_BASEIP		:= Acols[zd,13]
			ZZB_IPI			:= Acols[zd,14]
			ZZB_VALIPI		:= Acols[zd,15]
			ZZB_BSIMP5		:= Acols[zd,16] 		&& PIS
			ZZB_ALIMP5		:= Acols[zd,17] 		&& PIS
			ZZB_VLIMP5		:= Acols[zd,18] 		&& PIS
			ZZB_BSIMP6		:= Acols[zd,19]		&& COFINS
			ZZB_ALIMP6		:= Acols[zd,20]		&& COFINS
			ZZB_VLIMP6		:= Acols[zd,21]		&& COFINS
			ZZB_BASEIC		:= Acols[zd,22]
			ZZB_PICM		:= Acols[zd,23]
			ZZB_VALICM		:= Acols[zd,24]
			ZZB_CONTA		:= Acols[zd,25]		&& Conta Contabil
			ZZB_ITEMCT		:= Acols[zd,26]		&& Item Contabil
			ZZB_CC			:= Acols[zd,27]		&& Centro de Custos
			ZZB_CVLV		:= Acols[zd,28]		&& Classe Valor
			ZZB_FORNEC		:= cFornece
			ZZB_LOJA		:= cLoja
			ZZB_ADICAO      := Acols[zd,29]
			ZZB_SEQADI      := Acols[zd,30]
			ZZB_DESCAD      := Acols[zd,31]				
			ZZB_C7NUM       := Acols[zd,32]				
			ZZB_ITEMPC      := Acols[zd,33]				
		MsUnlock("ZZB")
				
		&& Atualiza Totais
			
		_nTotMerc 	:= _nTotMerc 	+ Acols[zd,04]		&& Soma ZZB_TOTAL
		_nTotII		:= _nTotII   	+ Acols[zd,12]		&& Soma ZZB_II
			
	Next zd
	
	dbSelectArea("ZZA")
	If nOpc == 3
		RecLock("ZZA",.T.)
	Else
		RecLock("ZZA",.F.)
	Endif	                   
		       
		If nOpc == 3
		  	ZZA_CODIGO	 	:= cCodigo
		  	ZZA_NUMDI	 	:= cNumDI
		EndIf
		
	  	ZZA_FORNEC	 		:= cFornece
	  	ZZA_LOJA 			:= cLoja
	  	ZZA_TRANSP          := cTransp 		// WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
	  	ZZA_LOJATR          := cLojaTrans 	// WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
	  	ZZA_EMISSAO 		:= _Emissao
	  	ZZA_DTDIGIT			:= _Emissao
	  	ZZA_CONDPG	 		:= cCondPag
	  	ZZA_BASEIC	 		:= _nBaseICMS
	  	ZZA_VALICM 			:= _nValorICMS
	  	ZZA_BASEIP			:= _nBaseIPI
	  	ZZA_VALIPI 			:= _nValorIPI
	  	ZZA_BAIMP5			:= _nBasePIS
	  	ZZA_VLIMP5			:= _nValorPIS
	 	ZZA_BSIMP6	 		:= _nBaseCOF
	  	ZZA_VLIMP6			:= _nValorCOF
	  	ZZA_VALMER			:= _nTotMerc
	  	ZZA_VALBRU	 		:= _nValorTot
	  	ZZA_II				:= _nValorII 	// _nTotII
	  	ZZA_BASEII			:= _nBaseII
	  	ZZA_DESPES			:= _nSiscomex
	  	ZZA_SEGURO			:= _nSeguro
	  	ZZA_FRETE			:= _nFrete
	 	ZZA_PBRUT			:= _nPBrut
	  	ZZA_PLIQU			:= _nPLiquid 
		ZZA_QTDEMB 			:= nQuantEmb
		ZZA_ESPECI			:= cEspecie	
		ZZA_PBRUTO			:= nPBruto	
		ZZA_LIQUID			:= nPLiquido
		ZZA_NREF			:= cNREF
		ZZA_SREF 			:= cSREF          
		ZZA_NUMNF			:= cNUMNF
		ZZA_SERINF			:= cSERINF
		ZZA_LOCDES			:= cLocDes
		ZZA_UFDESE			:= cUFDes
		ZZA_DTDESE			:= cDataDes
	
	//  nfe 3.10
		ZZA_VTRANS			:= Left(c_VTRANS    ,2)
		ZZA_VAFRMM			:= n_VAFRMM
		ZZA_INTERM			:= Left(c_INTERM	,1)
		ZZA_CNPJAE			:= c_CNPJAE
		ZZA_UFTERC			:= c_UFTERC
		ZZA_ACDRAW			:= c_ACDRAW
	
	MsUnlock("ZZA")

Return(nil)


/*/{Protheus.doc} User Function ExcluZF
	Exclui pre-nota de Importação
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/

User Function ExcluZF()		// Exclui Pre Nota

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	_nOPCA:=0
	
	IIF(MsgYesNo(OemToAnsi("Confirma Exclusao Pre Nota " + ZZA->ZZA_CODIGO + " ?"),"Atencao"),_nOpca:=1,_nOpca:=2)
	
	If _nOpcA == 2
		
		Return(.f.)
	Else
		
		Processa({|| U_ExcluZFE(ZZA->ZZA_CODIGO)})
	Endif

Return


/*/{Protheus.doc} User Function ExCluZFE
	Processa exclusão da pre-nota de Importação
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function ExCluZFE(xCODIGO)

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	DbSelectArea("ZZB")
	DbSetOrder(1)
	Dbseek(xfilial("ZZB")+xCODIGO)
	
	IF !Empty(ZZB->ZZB_NUMNF)
		Msgstop("DI com NF numero " + ZZB->ZZB_NUMNF + " ja gerada, caso necessite Exclua a NF ")
		lRetorno:= .F.
		Return
	endif
	
	cPVs := " "
	
	IF !Empty(cPVs)
		Msgstop("ERRO. Esta Importacao nao pode ser excluida. Favor retirar o empenho no(s) pedido(s) de venda: " + cPVs)
		lRetorno:= .F.
		Return
	endif
	
	While !eof().and. ZZB->ZZB_CODIGO == ZZA->ZZA_CODIGO
		
		incproc("Excluindo Pre Nota " + ZZB->ZZB_CODIGO + " " + ZZB->ZZB_ITEM)
					   
		dbSelectArea("ZZB")
		RecLock("ZZB",.F.)
		DbDelete()
		MsUnlock()
		DbSkip()
	
	Enddo
	
	DbSelectArea("ZZA")
	RecLock("ZZA",.F.)
	DbDelete()
	MsUnlock()

Return


/*/{Protheus.doc} User Function GeraNF
	Gera NF via rotina automática
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/

User Function GeraNF()

	Local aCab		:={}
	Local aItem1	:={}
	Local lRetorno	:= .T.
	Local _nVAFRMM  := 0 	//Por Adriana em 18/03/2020 chamado 056339
	  
	Local aAreaSF3
		
	Private lMsHelpAuto,lMsErroAuto
		
	Private cTipoNf:= "N"
	Private cNumero:= ""
	Private cSerie := "NF2"

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//INICIO CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO 
	//INICIO VALIDAR SE JA TEM NOTA ENTRADA PARA PARA ESSA NOTA DE IMPORTACAO
	
	IF ALLTRIM(ZZA->ZZA_NUMNF)  <> '' .AND. ;
	   ALLTRIM(ZZA->ZZA_SERINF) <> ''
	   
	   MsgAlert("Olá " + Alltrim(cUserName) + ", você não pode gerar a nota fiscal de importação Por que ela já existe com o número: " + ZZA->ZZA_NUMNF + ' e Série: ' + ZZA->ZZA_SERINF, "ADRANFIMP - GERANF")
	   
	   RETURN()
	
	ENDIF
	
	//FINAL VALIDAR SE JA TEM NOTA ENTRADA PARA PARA ESSA NOTA DE IMPORTACAO
	//FINAL CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
	
	dbSelectArea("ZZB")
	dbSetOrder(1)
	dbSeek(xFilial("ZZB")+ZZA->ZZA_CODIGO,.T.)
	
	While ZZB->ZZB_CODIGO == ZZA->ZZA_CODIGO
		
		SF1->(dbSetOrder(1))
		If SF1->(MsSeek(xFilial("SF1")+cNumero+cSerie+ZZA->ZZA_FORNECE+ZZA->ZZA_LOJA,.F.))
			Help(" ",1,"EXISTNF")
			lRetorno := .F.
			cNumero:= ""
			cSerie := ""
		EndIf
		
		_nTotValAdu := _nTotBasICM := _nTotValICM := _nTotBasIPI :=	_nTotValIPI := _nTotValBru := 0
		_nTBasIm5 := _nTValIm5 := _nTBasIm6 := _nTValIm6 := _nTValDes := 0
		_nTBruBR := 0
		
		lRetorno := .T. 
		lRetorno := Sx5NumNota(@cSerie,cTipoNf)
		
		If lRetorno
	
			aAreaAtu := GetArea()
			dbSelectArea("SX5")
			dbSeek(xFilial("SX5")+"01"+cSerie)
			
			Begin Transaction
			
			RecLock("SX5",.F.)
			  X5_DESCRI  := Soma1(cNumero)
			  X5_DESCSPA := Soma1(cNumero)
			  X5_DESCENG := Soma1(cNumero)
			RestArea(aAreaAtu)
			
			If !Empty(ZZB->ZZB_NUMNF)
				Msgstop("AWB com NF numero " + ZZB->ZZB_NUMNF + " ja gerada, caso necessite Exclua a NF ")
				lRetorno:= .F.
				Return
			endif
			
			_cFORNECE := ZZA->ZZA_FORNECE 		&& ZZB->ZZB_CODFAB
			_cLJ      := ZZA->ZZA_LOJA	 			&& ZZB->ZZB_LOJFAB
	
			While !eof() .AND. ZZA->ZZA_FORNECE+ZZA->ZZA_LOJA 	== _cFORNECE+_cLJ  .And. ZZB->ZZB_CODIGO == ZZA->ZZA_CODIGO
				
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(Xfilial("SB1")+ZZB->ZZB_COD)
	
				dbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek(xfilial("SF4")+ZZB->ZZB_TES)
								
				aAdd(aItem1,{})
				aAdd(aItem1[Len(aItem1)],{"D1_FILIAL"		,xFilial('SD1')						,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_COD"			,ZZB->ZZB_COD 						,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_DOC"			,cNumero	 						,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_SERIE"		,cSerie 							,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_ITEM"			,ZZB->ZZB_ITEM  					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_UM"			,SB1->B1_UM 						,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_QUANT"		,ZZB->ZZB_QUANT						,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_VUNIT"		,ZZB->ZZB_VUNIT  					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_TOTAL"		,ZZB->ZZB_TOTAL					  	,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_TES"			,ZZB->ZZB_TES 						,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_CF"			,ZZB->ZZB_CF						,NIL})
	//			aAdd(aItem1[Len(aItem1)],{"D1_PICM"			,ZZB->ZZB_PICM 						,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_IPI"			,ZZB->ZZB_IPI  						,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_BASEICM"		,ZZB->ZZB_BASEIC					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_VALICM"		,ZZB->ZZB_VALICM 					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_BASEIPI" 		,ZZB->ZZB_BASEIP 					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_VALIPI"		,ZZB->ZZB_VALIPI 					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_ALQIMP6" 		,ZZB->ZZB_ALIMP6 					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_BASIMP6"		,ZZB->ZZB_BSIMP6 					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_VALIMP6" 		,ZZB->ZZB_VLIMP6  					,NIL})
	//			aAdd(aItem1[Len(aItem1)],{"D1_FORNECE"		,ZZB->ZZB_CODFAB 	  				,NIL})
	//			aAdd(aItem1[Len(aItem1)],{"D1_LOJA"			,ZZB->ZZB_LOJFAB 					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_EMISSAO"	 	,dDataBase		  					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_DTDIGIT"		,dDataBase			  				,NIL})
	//			aAdd(aItem1[Len(aItem1)],{"D1_LOCAL" 		,ZZB->ZZB_LOCAL  					,NIL})
	//			aAdd(aItem1[Len(aItem1)],{"D1_ITEMCTA" 		,SB1->B1_ITEMCC 					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_GRUPO"		,SB1->B1_GRUPO  					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_TIPO"			,"N" 								,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_TP"			,SB1->B1_TIPO   			  		,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_FORMUL"		,"S"								,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_BASIMP5"		,ZZB->ZZB_BSIMP5  					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_VALIMP5"		,ZZB->ZZB_VLIMP5  					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_ALQIMP5"		,ZZB->ZZB_ALIMP5  					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_QTDPEDI"		,ZZB->ZZB_QUANT   					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_OP"			,SPACE(13)		   					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_RATEIO" 		,"2" 								,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_DESPESA"		,ZZB->ZZB_DESPES  					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_SEGURO"		,ZZB->ZZB_SEGURO  					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_VALFRE"		,ZZB->ZZB_FRETE	  					,NIL})
	//			aAdd(aItem1[Len(aItem1)],{"D1_CONTA"		,ZZB->ZZB_CONTA						,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_ITEMCTA"		,ZZB->ZZB_ITEMCT					,NIL})
				aAdd(aItem1[Len(aItem1)],{"D1_CC"			,ZZB->ZZB_CC						,NIL})
	//			aAdd(aItem1[Len(aItem1)],{"D1_CVLV"			,ZZB->ZZB_CVLV						,NIL})
				If !Empty(ZZB->ZZB_C7NUM) .AND. !Empty(ZZB->ZZB_ITEMPC)
					aAdd(aItem1[Len(aItem1)],{"D1_PEDIDO"	,ZZB->ZZB_C7NUM						,NIL})
					aAdd(aItem1[Len(aItem1)],{"D1_ITEMPC"	,ZZB->ZZB_ITEMPC					,NIL})
				Endif
				aadd(aItem1[Len(aItem1)],{"AUTDELETA" 		,"N"								,Nil}) 
							
				_nTotValAdu += ZZB->ZZB_TOTAL 					&& ZZB->ZZB_VALADU
				_nTotBasICM += ZZB->ZZB_BASEIC
				_nTotValICM += ZZB->ZZB_VALICM
				_nTotBasIPI += ZZB->ZZB_BASEIP
				_nTotValIPI += ZZB->ZZB_VALIPI
				_nTotValBru += ZZB->ZZB_TOTAL//+ZZB->ZZB_II 	&& ZZB->ZZB_VALADU + ZZB->ZZB_II
				//_nTBruBR    += ZZB->ZZB_TOTAL + ZZB->ZZB_DESPES + ZZB->ZZB_VALICM + ZZB->ZZB_VLIMP5 + ZZB->ZZB_VLIMP6 //Para Base de Icms Reduzido
				_nTBruBR    += ZZB->ZZB_TOTAL + ZZB->ZZB_DESPES + ZZB->ZZB_VALICM + ZZB->ZZB_VLIMP5 + ZZB->ZZB_VLIMP6 + ZZB->ZZB_VALIPI //+ ZZB->ZZB_II 
				_nTBasIm5   += ZZB->ZZB_BSIMP5 
				_nTValIm5   += ZZB->ZZB_VLIMP5
				_nTBasIm6   += ZZB->ZZB_BSIMP6
				_nTValIm6   += ZZB->ZZB_VLIMP6
				_nTValDes   += ZZB->ZZB_DESPES
				
				dbSelectArea("ZZB")
				dbSetOrder(1)
				RecLock("ZZB",.F.)
					ZZB->ZZB_NUMNF 	:= cNumero
					ZZB->ZZB_SERINF := cSerie
					ZZB->ZZB_ITEMNF := ZZB->ZZB_ITEM
				MsUnlock()						
	
				dbSelectArea("ZZB")
				DbSkip()
			
			Enddo        
			                  
			&& Atualiza ZZA	
			dbSelectArea("ZZA")
			_nVAFRMM   := ZZA->ZZA_VAFRMM //Por Adriana em 18/03/2020 chamado 056339

			RecLock("ZZA",.F.)
				ZZA->ZZA_NUMNF 	:= cNumero
				ZZA->ZZA_SERINF := cSerie
			MsUnlock("ZZA")
	
			lMsHelpAuto := .f. && se .t. direciona as mensagens de help
			lMsErroAuto := .f. 
		    
		    If Len(aItem1) > 0
	
				dbSelectArea("ZZA")
				dbSetOrder(1)
				
				if cfilant == "02" .OR. cfilant == "03" .OR. cfilant == "06"
				   _cEspNf := "SPED"
				else
				   _cEspNf := "NF"
				endif
				
				aCab := {;
				{"F1_FILIAL"	,xfilial("SF1")					,NIL},;
				{"F1_TIPO"		,'N'							,NIL},;
				{"F1_FORMUL"	,'S'							,NIL},;
				{"F1_DOC"		,cNumero						,NIL},; 		&& cnumero
				{"F1_SERIE"		,cSerie							,NIL},;
				{"F1_ORIGLAN"	,'D'							,NIL},;
				{"F1_STATUS"	,'A'							,NIL},;
				{"F1_EMISSAO"	,dDataBase						,NIL},;
				{"F1_FORNECE"	,_cFORNECE						,NIL},;
				{"F1_LOJA"	   ,_cLJ 	     					,NIL},;
				{"F1_TRANSP"   ,ZZA->ZZA_TRANSP	     			,NIL},; // WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO  
				{"F1_LOJATRA"  ,ZZA->ZZA_LOJATR     		    ,NIL},; // WILLIAM COSTA - 30/08/2019 CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO  
				{"F1_EST" 		,"EX" 		      				,NIL},;
				{"F1_BASEICM" 	,_nTotBasICM   					,NIL},;
				{"F1_VALIMC" 	,_nTotValICM    				,NIL},;
				{"F1_BASEIPI" 	,_nTotBasIPI   					,NIL},;
				{"F1_VALIPI" 	,_nTotValIPI    				,NIL},;
				{"F1_VALMERC"	,_nTotValAdu    				,NIL},;
				{"F1_VALBRUT" 	,_nTotValBru   					,NIL},;
				{"F1_TIPO" 		,"N" 		      				,NIL},;
				{"F1_DTDIGIT" 	,dDataBase		   				,NIL},;
				{"F1_FORMUL" 	,"S" 			 				,NIL},;
				{"F1_ESPECIE"  ,_cEspNf				 			,NIL},;     //	"SPED" - Mauricio HC 03/07/09.
				{"F1_BASIMP5" 	,_nTBasIm5  					,NIL},;		&& 	COFINS - F1 PIS
				{"F1_BASIMP6" 	,_nTBasIm6  					,NIL},;		&& 	PIS - F1 COFINS
				{"F1_VALIMP6" 	,_nTValIm6  					,NIL},;	
				{"F1_DESPESA" 	,_nTValDes 						,NIL},;	
				{"F1_VALIMP5" 	,_nTValIm5  					,NIL},;	
				{"F1_COND" 		,ZZA->ZZA_CONDPG			  	,NIL},;
				{"F1_FRETE" 	,ZZA->ZZA_FRETE				  	,NIL},; 	// 	incluído em 03/02/10 por Daniel G.Jr.
				{"F1_SEGURO" 	,ZZA->ZZA_SEGURO			  	,NIL}}		// 	incluído em 03/02/10 por Daniel G.Jr.
	//			{"F1_COND" 		,ZZA->ZZA_CONDPG			  	,NIL}}		// 	comentado em 03/02/10 por Daniel G.Jr.
	//         	{"F1_ESPECIE" 	,ZZA->ZZA_ESPECI				,NIL},;	  		Retirado para nao sobrepor F1_ESPECIE - Mauricio HC 03/07/09
	//			{"F1_VALBRUT" 	,_nTotValBru   					,NIL},;
				//dbSelectArea("ZZB")
				//xaArea   := { Alias(),Recno() }
	
				MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCab, aItem1, 3)
				//Incluido Ana 10/08/11 - Pois para base de icms reduzido o Valor contabil estava incorreto, estava assumindo o valor da base de calculo do icms
				//E, segundo o departamento fiscal deve ser: Total dos produtos + Despesas + Valor Icms + Pis + Cofins - Chamado 011222
				If !lMsErroAuto
					dbSelectArea("SF1")
					Reclock("SF1",.F.)		
					F1_VALBRUT := _nTBruBR + _nVAFRMM //Por Adriana em 18/03/2020 chamado 056339
					MsUnLock()
							
					dbSelectArea("SF3")
					Reclock("SF3",.F.)		
					F3_VALCONT := _nTBruBR + _nVAFRMM //Por Adriana em 18/03/2020 chamado 056339
					MsUnLock()    						   			
							  
					dbSelectArea("SE2")            //Contas a Pagar
					dbSetOrder(6)                 ////E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO	
					if dbSeek(Xfilial("SE2")+SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC,.T. )
						Do While .not. eof() .and. SF1->(F1_FORNECE + F1_LOJA + F1_SERIE + F1_DOC) == SE2->(E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM )
										
							dbSelectArea("SE2")
							Reclock("SE2",.F.)		
							E2_VALOR  := _nTBruBR + _nVAFRMM //Por Adriana em 18/03/2020 chamado 056339
							E2_SALDO  := _nTBruBR + _nVAFRMM //Por Adriana em 18/03/2020 chamado 056339
							E2_VLCRUZ := _nTBruBR + _nVAFRMM //Por Adriana em 18/03/2020 chamado 056339
							MsUnLock()
							dbSkip()
						Enddo						
					Endif				
								
					aCab	:={}
					aItem1:={}
				Endif
			Endif	
				
			If lMsErroAuto
				Mostraerro()
				DisarmTransaction()
												           
				&& Atualiza ZZA	
				dbSelectArea("ZZA")
				RecLock("ZZA",.F.)
					ZZA->ZZA_NUMNF	:= CriaVar("ZZA_NUMNF",.F.)
					ZZA->ZZA_SERINF	:= CriaVar("ZZA_SERINF",.F.)
				MsUnlock("ZZA")
									
				dbSelectArea("ZZB")
				dbSetOrder(2)
				If Dbseek(xfilial("ZZB")+cNumero)
	
					Do While ZZB->(!Eof()) .AND. ZZB->ZZB_NUMNF == cNumero
						
						RecLock("ZZB",.F.)
	
							ZZB->ZZB_NUMNF	:= CriaVar("ZZB_NUMNF",.F.)
							ZZB->ZZB_ITEMNF	:= CriaVar("ZZB_ITEMNF",.F.)
	
						MsunLock("ZZB")
						
						ZZB->(DbSkip())
						
					Enddo
	
				Endif
				
			Else
			
				fAtuCD2(cNumero,cSerie,_cFORNECE,_cLJ,ZZA->ZZA_CODIGO)	&& Atualizacao Complemento 
				
				MsgInfo("Geracao de NF "+Alltrim(cNumero)+"/"+Alltrim(cSerie)+" concluida."  )
				
			Endif
			
			End Transaction   
			
			//Incluido 08/03/12 - Ana. Pois estava gravando o total dos itens no ultimo item da SFT, e os demais itens nao estava atualizando.(Continuacao do trecho abaixo do MSExecAuto de 10/08/11)
			dbSelectArea("ZZB")
			dbSetOrder(2)
			If Dbseek(xfilial("ZZB")+cNumero)
			
				Do While ZZB->(!Eof()) .AND. ZZB->ZZB_NUMNF == cNumero					  
					dbSelectArea("SFT")
					dbSetOrder(1)
					//Inicio Alterações por Adriana em 13/12/2019 - chamado 053647
					If dbSeek(xFilial("SFT")+"E"+cSerie+cNumero+_cFORNECE+_cLJ+ZZB->ZZB_ITEM+ZZB->ZZB_COD) 
						Reclock("SFT",.F.)		
						FT_VALCONT := ZZB->ZZB_TOTAL + ZZB->ZZB_DESPES + ZZB->ZZB_VALICM + ZZB->ZZB_VLIMP5 + ZZB->ZZB_VLIMP6 + ZZB->ZZB_VALIPI 
						FT_OUTRIPI := FT_VALCONT-ZZB->ZZB_VALIPI  		
						FT_OUTRICM := FT_VALCONT-ZZB->ZZB_VALIPI  		
						MsUnLock()				
					//Fim Alterações por Adriana em 13/12/2019 - chamado 053647
					Endif						
					ZZB->(DbSkip())					
				Enddo
			Endif		
	
		Else
			Exit
		Endif	
	
	EndDo
    
Return()


/*/{Protheus.doc} User Function XalcImp
	Ajusta as bases de impostos
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/

User Function XalcImp()

	Private a  := 0
	        _nBaseICMS := 0
	        _nBaseIPI  := 0
	        _nBaseCof  := 0
	        _nBasePIS  := 0
	        _nBaseII   := 0

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')		
	
	For a:=1 To len(Acols)
		
		_nBaseIpi		:=	_nBaseIPI 	+ Acols[a,13]
		_nBaseCof		:= _nBaseCof  	+ Acols[a,19]
		_nBasePIS		:= _nBasePIS  	+ Acols[a,16]
		_nBaseICMS		:=	_nBaseICMS 	+ Acols[a,22]
		_nBaseII		:= _nBaseII		+ Acols[a,10]
			
	Next A
	
	oInf0:Refresh()
	oInf1:Refresh()
	oInf2:Refresh()
	oInf3:Refresh()
	oInf4:Refresh()
	oInf5:Refresh()
	oInf6:Refresh()
	oInf7:Refresh()
	oInf11:Refresh()
	oInf12:Refresh()
	oGetDados:Refresh()

Return(.T.)


/*/{Protheus.doc} User Function Xed03TOK
	VAlida Totais
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function Xed03TOK()
           
	Local _nBaseICM1	:= Criavar("ZZA_BASEIC",.F.)
	Local _nValorIC1	:= Criavar("ZZA_VALICM",.F.)
	Local _nBaseIPI1	:= Criavar("ZZA_BASEIP",.F.)
	Local _nValorIP1	:= Criavar("ZZA_VALIPI",.F.)
	Local _nBasePIS1	:= Criavar("ZZA_BAIMP5",.F.)
	Local _nValorPI1	:= Criavar("ZZA_VLIMP5",.F.)
	Local _nBaseCOF1	:= Criavar("ZZA_BSIMP6",.F.)
	Local _nValorCO1	:= Criavar("ZZA_VLIMP6",.F.)
	Local _nFrete1		:= Criavar("ZZA_FRETE",.F.)
	Local _nSeguro1		:= Criavar("ZZA_SEGURO",.F.)
	Local _nSisCome1	:= Criavar("ZZA_DESPES",.F.)
	Local _nBaseII1		:= Criavar("ZZA_BASEII",.F.)
	Local _nValorII1	:= Criavar("ZZA_II",.F.)
	Local lRet			:= .T.                                                
	Local nP01 			:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_TES'})
	Local nP02 			:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_CF'})
	Local nP03 			:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_C7NUM'})
	Local nP04 			:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZZB_ITEMPC'})
	
	_nQtdEmb:=0
	_nOpca:=0

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	// Validar se os totais de Cabecalho batem com as soma dos itens

	IF ALLTRIM(cTransp)    == '' .OR. ;
	   ALLTRIM(cLojaTrans) == ''

		MsgInfo("Necessário informar Transportadora e Loja da Transportadora. Verifique!!")
		lRet := .F. 

	ENDIF

	IF lRet == .T.

		If Len(aCols) > 0
			
			For nx := 1 to Len(aCols)
		
				If Empty(aCols[nx,nP01])
					MsgInfo("TES invalido. Verifique!!")
					lRet := .F. 
					Exit
					nX := Len(aCols)
				Endif	
				
				If Empty(aCols[nx,nP02])
					MsgInfo("CFOP invalido. Verifique!!")
					lRet := .F. 
					Exit
					nX := Len(aCols)
				Endif
				If !Empty(aCols[nx,nP03]) .AND. Empty(Posicione("SC7",1,xFilial("SC7")+aCols[nx,nP03]+aCols[nx,nP04],"C7_NUM"))
					MsgInfo("Numero Pedido ou item invalido. Verifique!!")
					lRet := .F. 
					Exit
					nX := Len(aCols)
				Endif	
			
				_nBaseICM1	+= aCols[nx,22]
				_nValorIC1	+= aCols[nx,24]
				_nBaseIPI1	+= aCols[nx,13]
				_nValorIP1	+= aCols[nx,15]
				_nBasePIS1	+= aCols[nx,16]
				_nValorPI1	+= aCols[nx,18]
				_nBaseCOF1	+= aCols[nx,19]
				_nValorCO1	+= aCols[nx,21]
				_nFrete1	+= aCols[nx,07]
				_nSeguro1	+= aCols[nx,08]
				_nSisCome1	+= aCols[nx,09]
				_nBaseII1	+= aCols[nx,10]
				_nValorII1	+= aCols[nx,12]
			
			Next nX       
			
			If lRet
		
				If Round(_nValorIC1,2) != Round(_nValorICMS,2)
					MsgInfo("Valor de ICMS incorreto. Verifique!!")
					lret := .F.
				Elseif Round(_nValorIP1,2) != Round(_nValorIPI,2)
					MsgInfo("Valor de IPI incorreto. Verifique!!")
					lret := .F.
				Elseif Round(_nValorPIS1,2) != Round(_nValorPIS,2)
					MsgInfo("Valor de PIS incorreto. Verifique!!")
					lret := .F.
				Elseif Round(_nValorCO1,2) != Round(_nValorCOF,2)
					MsgInfo("Valor de COFINS incorreto. Verifique!!")
					lret := .F.
				Elseif Round(_nFrete1,2) != Round(_nFrete,2)
					MsgInfo("Valor de FRETE incorreto. Verifique!!")
					lret := .F.
				Elseif Round(_nSeguro1,2) != Round(_nSeguro,2)
					MsgInfo("Valor de SEGURO incorreto. Verifique!!")		
					lret := .F.
				Elseif Round(_nSisCome1,2) != Round(_nSisComex,2)
					MsgInfo("Valor de DESPESA incorreto. Verifique!!")		
					lret := .F.
				Elseif Round(_nValorII1,2) != Round(_nValorII,2)
					MsgInfo("Valor de IMPOSTO IMPORTACAO incorreto. Verifique!!")
					lret := .F.
				Endif	
				
			Endif
			
		Endif
	ENDIF

	If lRet
		oDlg:End()
	Endif	

Return(lRet)


/*/{Protheus.doc} User Function MATAval012
	Valida Pedido
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function MATAval012()

	Local cRet := "X"

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	IF SC7->C7_QUJE < SC7->C7_QUANT .AND. !Empty(C7_APROV) .AND. C7_CONAPRO != "B"
		cRet := ""
	Endif

Return cRet


/*/{Protheus.doc} User Function A012AllMark
	Marca todos os Registros da MarkBrowse
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function A012AllMark()

	Local aArea   := { Alias(),Recno() }
	Local nRecord := 0
	Local lMarca  :=  NIL

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	DbSelectArea("SC7")
	DbSeek( xFilial("SC7"),.F. )
	
	While !Eof()
		
		If (lMarca == NIL)
			lMarca := (SC7->C7_OK == cMarca)
		EndIf
		
		RecLock("SC7")
		SC7->C7_OK := If( lMarca,"",cMarca )
		MsUnLock("SC7")
		
		DbSkip(1)
	EndDo
	
	dbSelectArea( aArea[1] )
	dbGoto( aArea[2] )

Return(NIL)


/*/{Protheus.doc} User Function A012Pedido
	Consulta do Pedido
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function A012Pedido()       

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
 
	cAlias:= "SC7"
	Inclui := .F.
	aBackSC7 := {}
	l120Auto := .F.
	
	A120Pedido(cAlias,RECNO("SC7"),2,"C7_TIPO",,.F.)

Return


/*/{Protheus.doc} User Function XCPA03E
	EXCLUSAO do Processo
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function XCPA03E(_cCodigo)   

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	ProcRegua(100)
	Dbselectarea("ZZA")
	DbSetOrder(1)
	Dbseek(xFilial("ZZA")+_cCodigo)
	
	While !Eof() .and. ZZA->ZZA_CODIGO  == _cCodigo
		
		Dbselectarea("ZZB")
		DbSetOrder(1)
		Dbseek(xFilial("ZZB")+_cCodigo)
		
		While !Eof() .and. ZZB->ZZB_CODIGO  == ZZA->ZZA_CODIGO
			
			incproc("Excluindo Processo " + ZZB->ZZB_CODIGO + ZZB->ZZB_ITEM  )
			
			Reclock("ZZB",.F.)
			dbDelete()
			MsUnlock("ZZB")
			Dbskip()
			
		Enddo
		
		Dbselectarea("ZZA")
		Reclock("ZZB",.F.)
		dbDelete()
		MsUnlock("ZZB")
		Dbskip()
	Enddo

Return


/*/{Protheus.doc} User Function SMRateio
	Rateio das despesas
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function SMRateio(xSMCod,nSMTotal)      

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nSMValAdu 		:= 0
	nSMBASEIPI 		:= 0
	nSMTotDesp 		:= 0
	nSMTotMerc 		:= 0
	nSMIndice		:= 0
	nSMTotalReais	:= 0
	nSMValRat 		:= 0
	//nTotRat		:= 0
	nDIf			:= 0
	
	nSMTotDesp:= round((_ndespesas * _ntaxaus),2)  			&& /+ _nSisComex  // Converte as despesas para Reais
	
	nSMTotMerc:= round((ZZA->ZZA_VALMERC * _ntaxaus),2) 	&& Converte total da mercadoria em reais
	
	nSMTotalReais:= round((nSMTotal * _nTaxaUS),2) 			&& Converte o valor do Item em Reais
	
	nSMValRat	:= round((( nSMTotDesp  * nSMtotalReais) / nSMTotMerc),2)
	
	nTotRat		:= nTotRat + nSMVAlRat
	
	IF (a + 1) > len(Acols)
		
		nDif := nSMTotDesp - nTotRat
		
		IF nDif < 0
			
			nSMValRat := nSMValRat - abs(nDiF)
		else
			
			nSMValRat := nSMValRat + nDIF
		Endif
	Endif
	
	nSMValAdu	:= nSMTotalReais + nSMValRat
	
	
	aCols[a][30] := nSMVALAdu

Return


/*/{Protheus.doc} User Function SMRatDesp
	Rateio das despesas
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function SMRatDesp(xSMCod,nSMTotal)       

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nSMValDesp 		:= 0
	nSMBASEIPI 		:= 0
	nSMTotDesp 		:= 0
	nSMTotMerc 		:= 0
	nSMIndice		:= 0
	nSMTotalReais	:= 0
	nSMValRat 		:= 0
	nDIf			:= 0
	
	nSMTotDesp:= _nSisComex
	
	nSMTotMerc:= noround((ZZA->ZZA_VALMERC * _ntaxaus),2) 	&& Converte total da mercadoria em reais
	
	nSMTotalReais:= noround((nSMTotal * _nTaxaUS),2) 			&& Converte o valor do Item em Reais
	
	nSMValRat	:= noround((( nSMTotDesp  * nSMtotalReais) / nSMTotMerc),2)
	
	nTotRatDesp		:= nTotRatDesp + nSMVAlRat
	
	IF (a + 1) > len(Acols)
		
		nDif := nSMTotDesp - nTotRatDesp
		
		IF nDif < 0
			
			nSMValRat := nSMValRat - abs(nDiF)
		else
			
			nSMValRat := nSMValRat + nDIF
		Endif
	Endif
	
	nSMValDesp	:= nSMValRat
	
	aCols[a][26] := nSMVALDesp

Return


/*/{Protheus.doc} User Function SMcalcII
	Valor do II
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function SMcalcII(xSMCod,nSMTotal,xSMTES,nSMBaseII,nSMPII)

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nSMVALII := 0
	
	nSMValII 	:= noround((nSMBaseII * (nSMPII / 100)),2)  // Valor do II
	
	aCols[a,17] := nSMBASEII
	aCols[a,18] := nSMValII

Return


/*/{Protheus.doc} User Function SMcalcIPI
	Valor do IPI
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function SMcalcIPI(xSMCod,nSMTotal,xSMTES,nSMBaseIPI,nSMPIPI)      // Calculo do IPI

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nSMVALIPI := 0
	
	dbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xfilial("SF4")+xSMTES)
	
	if SF4->F4_IPI == "S"
		nSMValIPI 	:= noround((nSMBaseIPI * (nSMPIPI / 100)),2)  				&& Valor do IPI
	Endif
	
	aCols[a,15] := IIF(nSMValIPI == 0 , 0, nSMBASEIPI)
	aCols[a,16] := nSMValIPI

Return


/*/{Protheus.doc} User Function SMcalcCOF
	Calculo do COFINS
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function SMcalcCOF(xSMCod,nSMTotal,xSMTES,nSMBaseCOF,nSMPIPI)      	

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nSMVALCOF 	:= 0
	nSMfatorx	:= 0
	
	dbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xfilial("SF4")+xSMTES)
	
	IF SF4->F4_PISCRED <> "3"
		
		IF Empty(SF4->F4_BASEICM) 											// se nao tem reducao ICMS
	
			nSMFatorx	:= U_FATOR1(aCols[a,10],aCols[a,12],aCols[a,11],nAliqPIS,nAliqCOFIN)
			
			nSMBaseCOF 	:= noround((nSMBaseCOF * nSMFatorx),2)
			nSMValCOF 	:= noround((nSMBaseCOF * (nAliQCOFIN / 100)),2)  	// Valor do IPI
		else
	        nSMAliqICM :=  aCols[a,10] - (aCols[a,10] * ((100-SF4->F4_BASEICM) / 100))
	                       //Fator1(nSMAliqICM,nSMAliqIpI,nSMAliqII,nSMAliqPIS,nSMAliqCOF)
			nSMFatorx	:= U_FATOR1(nSMAliqICM,aCols[a,12],aCols[a,11],nAliqPIS,nAliqCOFIN)
			
			nSMBaseCOF 	:= noround((nSMBaseCOF * nSMFatorx),2)
			nSMValCOF 	:= noround((nSMBaseCOF * (nAliQCOFIN / 100)),2)  	// Valor do IPI
	
		Endif	
	Else
		
		nSMBASECOF	:= 0
		nSMValCOF	:= 0
		
	Endif
	
	aCols[a,23] := nSMBASECOF
	aCols[a,24] := nSMValCOF

Return


/*/{Protheus.doc} User Function SMcalcPIS
	Calculo do PIS
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function SMcalcPIS(xSMCod,nSMTotal,xSMTES,nSMBasePIS,nSMPIPI)      		

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nSMVALPIS 	:= 0
	nSMfatorx	:= 0
	
	dbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xfilial("SF4")+xSMTES)
		
	if SF4->F4_PISCRED <> "3"
	
		IF Empty(SF4->F4_BASEICM) 	&& se nao tem reducao ICMS
		
			nSMFatorx	:= U_FATOR1(aCols[a,10],aCols[a,12],aCols[a,11],nAliqPIS,nAliqCOFIN)
		
			nSMBasePIS 	:= noround((nSMBasePIS * nSMFatorx),2)
			nSMValPIS 	:= noround((nSMBasePIS * (nAliqPIS / 100)),2)  	&& Valor do IPI
		ELSE 
	
	        nSMAliqICM :=  aCols[a,10] - (aCols[a,10] * ((100-SF4->F4_BASEICM) / 100))
	                       //Fator1(nSMAliqICM,nSMAliqIpI,nSMAliqII,nSMAliqPIS,nSMAliqCOF)
			nSMFatorx	:= U_FATOR1(nSMAliqICM,aCols[a,12],aCols[a,11],nAliqPIS,nAliqCOFIN)
		
			nSMBasePIS 	:= noround((nSMBasePIS * nSMFatorx),2)
			nSMValPIS 	:= noround((nSMBasePIS * (nAliqPIS / 100)),2)  	&& Valor do IPI
		
		ENDIF
	else
		
		nSMBASEPIS	:= 0
		nSMValPIS	:= 0
		
		
	Endif
	
	aCols[a,21] := nSMBASEPIS
	aCols[a,22] := nSMValPIS

Return


/*/{Protheus.doc} User Function SMcalcICM
	Calculo do ICMS
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function SMcalcICM(xSMCod,nSMTotal,xSMTES,nSMBaseIPI,nSMValIPI,nSMValCOF,nSMValPIS,nSMAliqICM,nSMDespesas)		

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nSMVALICM 	:= 0
	nSMBaseICM	:= 0
	
	dbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xfilial("SF4")+xSMTES)
		
	if SF4->F4_ICM == "S"
		
		if SF4->F4_DESPICM == "1"
			
			nSMBaseICM 	:= noround(((nSMBaseIPI + nSMValIPI + nSMVALCOF + nSMVALPIS + nSMDespesas)  /  (1 - (nSMAliqICM / 100))),2)
		else
			nSMBaseICM 	:= noround(((nSMBaseIPI + nSMValIPI + nSMVALCOF + nSMVALPIS)  /  (1 - (nSMAliqICM / 100))),2)
			
		endif  
		
		IF !Empty(SF4->F4_BASEICM) 		&& se tem reducao ICMS
	
			nSMBaseICM 	:= nSMBaseIPI + nSMValIPI + nSMVALCOF + nSMVALPIS + nSMDespesas
	        nSMAliqICM :=  aCols[a,10] - (aCols[a,10] * ((100-SF4->F4_BASEICM) / 100))  
	        nSMFatICM  :=  1 - (nSMAliqICM / 100)      
	   		nSMBaseICM :=  nSMBaseICM / nSMFatICM    
	   		nSMRedICM  :=  nSMBaseICM * ((100-SF4->F4_BASEICM) / 100)  	// vlr da reducao
	   		nSMBaseICM :=  nSMBaseICM - nSMRedICM     					// base - reducao
	
		Endif
		
		nSMValICM 	:= noround((nSMBaseICM *  (aCols[a,10] / 100)),2)   // Valor do ICM
		
	else
		
		nSMBASEICM	:= 0
		nSMValICM	:= 0
		
	Endif
	
	aCols[a,13] := nSMBASEICM
	aCols[a,14] := nSMValICM

Return

/*/{Protheus.doc} User Function Fator1
	Calculo do Fator1
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function Fator1(nSMAliqICM,nSMAliqIpI,nSMAliqII,nSMAliqPIS,nSMAliqCOF)

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nFator1:= 0
	nSMAliqICM	:= nSMAliqICM / 100
	nSMAliqII	:= nSMAliqII/100
	nSMAliqIPI	:= nSMAliqIPI/100
	nSMAliqPIS	:= nSMAliqPIS/100
	nSMAliqCOF	:= nSMAliqCOF/100
	
	nFator1:= ( 1 + nSMAliqICM  * (nSMAliqII + nSMAliqIPI * (1 + nSMAliqII))) / ((1 - nSMAliqPIS - nSMAliqCOF ) * (1 - nSMAliqICM))

Return(nFator1)

/*/{Protheus.doc} User Function ValTotZD
	Calculo do Total
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function ValTotZD(_nTotal)

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	_lRetorno:= .t.
	nDif := Abs(acols[n][5] * acols[n][6]) - _nTotal
	If nDif <> 0.00
		Help(" ",1,"TOTAL")
		_lRetorno := .F.
	EndIf

Return(_lRetorno)    


/*/{Protheus.doc} Static Function Visual
	Arquivo Temporario
	@type  Static Function 
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
Static Function Visual()

	aDbStru :={}
	aadd(aDbStru,{"TR_ADI"       ,"C",03,0})
	aadd(aDbStru,{"TR_FOR"       ,"C",06,0})
	aadd(aDbStru,{"TR_LJ"        ,"C",02,0})
	aadd(aDbStru,{"TR_NCM"       ,"C",10,0})
	aadd(aDbStru,{"TR_VLADU"     ,"N",11,2})
	aadd(aDbStru,{"TR_VLII"      ,"N",11,2})
	aadd(aDbStru,{"TR_VLIPI"     ,"N",11,2})
	aadd(aDbStru,{"TR_DESP"      ,"N",11,2})
	aadd(aDbStru,{"TR_SISCO"     ,"N",11,2})
	aadd(aDbStru,{"TR_BASEPC"    ,"N",11,2})
	aadd(aDbStru,{"TR_VLPIS"     ,"N",11,2})
	aadd(aDbStru,{"TR_VLCOF"     ,"N",11,2})
	aadd(aDbStru,{"TR_BASEIC"    ,"N",11,2})
	aadd(aDbStru,{"TR_VLICM"     ,"N",11,2})
	
	_cArq1 := CriaTrab(aDbStru, .T. )
	dbUseArea(.T.,,_cArq1,"TRB",.T.,.F.)
	IndRegua("TRB",_cArq1,"TR_FOR+TR_LJ+TR_NCM",,,"Selecionando Registros...")
	
	_cont := 1
	
	&& Acumulo dados por Fornecedor / NCM
	For yy:=1 To len(Acols) 
	
		    Dbselectarea("TRB")
		    Dbseek(Acols[yy,27]+Acols[yy,28]+Acols[yy,02])
		    If  !Found()
		        Reclock("TRB",.T.)    
	              TRB->TR_ADI    := STRZERO(_cont,3)
	              TRB->TR_FOR    := Acols[yy,27]
	              TRB->TR_LJ     := Acols[yy,28]
	              TRB->TR_NCM    := Acols[yy,02]
	              TRB->TR_VLADU  := Acols[yy,30]
	              TRB->TR_VLII   := Acols[yy,18]
	              TRB->TR_VLIPI  := Acols[yy,16]
	              TRB->TR_DESP   := 0  
	              TRB->TR_SISCO  := Acols[yy,26]
	              TRB->TR_BASEPC := Acols[yy,21]
	              TRB->TR_VLPIS  := Acols[yy,22]
	              TRB->TR_VLCOF  := Acols[yy,24]
	              TRB->TR_BASEIC := Acols[yy,13]
	              TRB->TR_VLICM  := Acols[yy,14]
	              _cont := _cont + 1 
		        MSUNLOCK()
		    Else
		        Reclock("TRB",.F.)
	              TRB->TR_VLADU  += Acols[yy,30]
	              TRB->TR_VLII   += Acols[yy,18]
	              TRB->TR_VLIPI  += Acols[yy,16]
	              TRB->TR_DESP   += 0  
	              TRB->TR_SISCO  += Acols[yy,26]
	              TRB->TR_BASEPC += Acols[yy,21]
	              TRB->TR_VLPIS  += Acols[yy,22]
	              TRB->TR_VLCOF  += Acols[yy,24]
	              TRB->TR_BASEIC += Acols[yy,13]
	              TRB->TR_VLICM  += Acols[yy,14]
		        MSUNLOCK()
			Endif
	Next
	
	aMatz := {}
	aADD(aMatz,{"TR_ADI"		,"Adicao"			    						})
	aADD(aMatz,{"TR_FOR"	 	,"Fornecedor"		    						})
	aADD(aMatz,{"TR_LJ"	     	,"Loja"			    							})
	aADD(aMatz,{"TR_NCM"	 	,"NCM"											})
	aADD(aMatz,{"TR_VLADU"   	,"Valor Aduaneiro","Picture @E 999,999.99"		})
	aADD(aMatz,{"TR_VLII"	 	,"Valor II","Picture @E 999,999.99"				})
	aADD(aMatz,{"TR_VLIPI"	 	,"Valor IPI", "Picture @E 999,999.99"  			})
	aADD(aMatz,{"TR_DESP"	 	,"Despesas", "Picture @E 999,999.99" 			})
	aADD(aMatz,{"TR_SISCO"	 	,"Siscomex", "Picture @E 999,999.99" 			})
	aADD(aMatz,{"TR_BASEPC"  	,"Base PIS/COF", "Picture @E 999,999.99"     	})
	aADD(aMatz,{"TR_VLPIS"   	,"Valor PIS", "Picture @E 999,999.99" 			})
	aADD(aMatz,{"TR_VLCOF"	 	,"Valor COF", "Picture @E 999,999.99" 			})
	aADD(aMatz,{"TR_BASEIC"	 	,"Base ICMS", "Picture @E 999,999.99" 			})
	aADD(aMatz,{"TR_VLICM"	 	,"Valor ICMS", "Picture @E 999,999.99"  		})
	
	 bSet15		:= {||U_OK()}
	 bSet24		:= {||U_OK()}
	
	DEFINE MSDIALOG oDlg5 TITLE "Visualizacao dos dados por Fornecedor / NCM" From 010,010 To 040,110 OF oMainWnd
	
	@ 015,004 To 035,392
	
	@ 020,190 SAY "Processo :"  + ZZA->ZZA_NUMDI              SIZE 50,12
	
	dbSelectArea("TRB")
	dbGoTop()
	
	oGet := MSGetDados():New( 045, 005, 217, 390, nOpcx,,,,, aMatz,,, 99 )
	
	ACTIVATE MSDIALOG oDlg5 ON INIT EnchoiceBar( oDlg5 , bSet15 , bSet24 , NIL ,  ) CENTERED

Return

/*/{Protheus.doc} User Function OK
	Arquivo Temporario
	@type  User Function
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
User Function OK

	U_ADINF009P('ADRANFIMP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	If Select("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea("TRB")
	Endif
	
	oDlg5:End()

Return


/*/{Protheus.doc} Static Function Seguro
	Dados para Seguro
	@type  Static Function 
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
Static Function Seguro()

	_cDescMerc  := "PECAS PARA MAQUINARIO DE LATAS DE ALUMINIO                  "  
	_cEmbal     := "CAIXA DE PAPELAO E/OU MADEIRA + PALLETS                     "
	_cMeio      := "AERONAVE            " 
	_cLocSai    := "MIAMI               " 
	_dSai       := dDatabase
	_cLoChe     := "VCP                 " 
	_cDestFin   := "INDAIATUBA          "
	_dChe       := dDatabase
	_dDesemb    := dDatabase
	_cFrete     := "FOB                 " 
	
	Define MsDialog JanelaMotivo Title "Dados para relatorio do Seguro" From 100, 10 To 420, 680
	
	@ 001,001 SAY "Descricao das Mercadorias:"
	@ 001,010 GET _cDescMerc  PICTURE "@!" Valid !Empty(_cDescMerc) SIZE 200,10
	
	@ 002,001 SAY "Embalagem:                "  
	@ 002,010 GET _cEmbal PICTURE "@!" Valid !Empty(_cEmbal) SIZE 200,10
	
	@ 003,001 SAY "Meio: AERONAVE/NAVIO      "       
	@ 003,010 GET _cMeio  PICTURE "@!" Valid !Empty(_cMeio) SIZE 80,10
	
	@ 004,001 SAY "Local de Saida:           "       
	@ 004,010 GET _cLocSai  PICTURE "@!" Valid !Empty(_cMeio) SIZE 80,10
	
	@ 005,001 SAY "Data de Saida:            "       
	@ 005,010 GET _dSai  Valid !Empty(_cMeio) 
	
	@ 006,001 SAY "Local de Chegada:         "       
	@ 006,010 GET _cLoChe  PICTURE "@!" Valid !Empty(_cMeio) SIZE 80,10
	
	@ 007,001 SAY "Destino Final:            "       
	@ 007,010 GET _cDestFin  PICTURE "@!" Valid !Empty(_cMeio) SIZE 80,10
	
	@ 008,001 SAY "Data de Chegada:          "       
	@ 008,010 GET _dChe  PICTURE "@!" Valid !Empty(_cMeio) 
	
	@ 009,001 SAY "Data de Desembaraco:      "       
	@ 009,010 GET _dDesemb  PICTURE "@!" Valid !Empty(_cMeio) 
	
	@ 010,001 SAY "Frete:                    "       
	@ 010,010 GET _cFrete  PICTURE "@!" Valid !Empty(_cMeio) SIZE 80,10
	
	@ 138,230 BUTTON "OK" Action GrvSeq()
	
	ACTIVATE MSDIALOG JanelaMotivo Centered

Return


/*/{Protheus.doc} Static Function GrvSeg
	Grava Dados para Seguro
	@type  Static Function 
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
Static Function GrvSeg()

	dbSelectArea("ZZA")
	RecLock("ZZA",.F.) 
	  ZZA_DESCMER			:= _cDescMerc
	  ZZA_EMBAL				:= _cEmbal 
	  ZZA_MEIO	 			:= _cMeio 
	  ZZA_LOCSAI 			:= _cLocSai 
	  ZZA_DSAI				:= _dSai
	  ZZA_LOCHE 			:= _cLoChe
	  ZZA_DESTFIN			:= _cDestFin
	  ZZA_DCHE				:= _dChe
	  ZZA_DESEMB	 		:= _dDesemb   
	  ZZA_TFRETE			:= _cFrete
	
	MsUnlock("ZZA")
	
	Close(JanelaMotivo)

Return

/*/{Protheus.doc} Static Function fAtuCD2
	Grava Informações complementares
	@type  Static Function 
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
Static Function fAtuCD2(cNum,cSer,cForn,cLj,cCodi)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""            
	Local cChave 	:= "" 
	
	cQuery 	:= "SELECT * FROM " + RETSQLNAME("ZZB") + "   "
	cQuery 	+= "WHERE ZZB_FILIAL = '" + xFilial("ZZB") + "' AND D_E_L_E_T_ = '' "
	cQuery	+= "AND ZZB_CODIGO =  '" + cCodi + "' AND ZZB_FORNEC = '" + Substr(cForn,1,6) + "' AND ZZB_LOJA = '" + cLj + "'  " 
	
	TcQuery cQuery New Alias "TZZB"
	
	TZZB->(dbGoTop())
	
	While TZZB->(!Eof())
		
		dbSelectArea("CD2")
		CD2->(dbSetOrder(2))
		
		If CD2->( DbSeek(xfilial("CD2") + "E" + cSer + TZZB->ZZB_NUMNF + TZZB->ZZB_FORNEC + TZZB->ZZB_LOJA + TZZB->ZZB_ITEM + TZZB->ZZB_COD ) )
			
			cChave := xfilial("CD2")                  + "E"            + cSer           + TZZB->ZZB_NUMNF + TZZB->ZZB_FORNEC + TZZB->ZZB_LOJA  + TZZB->ZZB_ITEM  + TZZB->ZZB_COD
				
			While CD2->(!Eof()) .AND. CD2->CD2_FILIAL + CD2->CD2_TPMOV + CD2->CD2_SERIE + CD2->CD2_DOC    + CD2->CD2_CODFOR  + CD2->CD2_LOJFOR + CD2->CD2_ITEM   + CD2->CD2_CODPRO == cChave
	
				RecLock("CD2",.F.)
					If Alltrim(CD2->CD2_IMP) == "ICM"
						CD2->CD2_BC			:= TZZB->ZZB_BASEIC
						CD2->CD2_ALIQ		:= TZZB->ZZB_PICM
						CD2->CD2_VLTRIB		:= TZZB->ZZB_VALICM
					ElseIf	Alltrim(CD2->CD2_IMP) == "IPI"
						CD2->CD2_BC			:= TZZB->ZZB_BASEIP
						CD2->CD2_ALIQ		:= TZZB->ZZB_IPI
						CD2->CD2_VLTRIB		:= TZZB->ZZB_VALIPI
					ElseIf	Alltrim(CD2->CD2_IMP) == "PS2"
						CD2->CD2_BC			:= TZZB->ZZB_BSIMP5
						CD2->CD2_ALIQ		:= TZZB->ZZB_ALIMP5
						CD2->CD2_VLTRIB		:= TZZB->ZZB_VLIMP5
					ElseIf	Alltrim(CD2->CD2_IMP) == "CF2"
						CD2->CD2_BC			:= TZZB->ZZB_BSIMP6
						CD2->CD2_ALIQ		:= TZZB->ZZB_ALIMP6
						CD2->CD2_VLTRIB		:= TZZB->ZZB_VLIMP6
					EndIf	
				MsUnLock("CD2")		
	   		
	   		CD2->(dbSkip())
	   		   		
	   	Enddo
	   	   
	 	EndIf
	 	
	 	TZZB->(dbSkip())
	
	EndDo
	
	TZZB->(dbCloseArea())
	
	RestArea(aArea)

Return()


/*/{Protheus.doc} Static Function fRetCod
	Funcao para retornar Sequencia de Codigo em ZZA
	@type  Static Function 
	@author HCCONSYS
	@since 26/05/2008
	@version 01
/*/
Static Function fRetCod()  
                         
	Local cQuery 	:= ""
	Local aArea		:= GetArea()                             
	Local nCod		:= 0
	
	cQuery := "SELECT MAX(ZZA_CODIGO) AS CODZZA FROM " + RETSQLNAME("ZZA") 	+ "  	"
	cQuery += "WHERE D_E_L_E_T_ = ' ' AND ZZA_FILIAL = '" + xFilial("ZZA")  + "' 	"
	
	TcQuery cQuery New Alias "TZZA"
	
	TZZA->(dbGoTop())
	If Empty(TZZA->CODZZA)
		cCodigo 	:= '000001'
	Else
		cCodigo	:= Soma1(TZZA->CODZZA)
	Endif	
	
	TZZA->(dbCloseArea())
	
	RestArea(aArea)
	
Return()