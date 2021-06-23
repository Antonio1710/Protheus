#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4	
#DEFINE GD_UPDATE	2
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CERTSAN   ³ Autor ³ ADRIANA - HC       ³ Data ³  19/05/10   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Programa para impressao do CERTIFICADO SANITARIO, baseado   ³±±
±±³          ³nas informacoes da NF fiscal e nas informacoes digitadas    ³±±
±±³          ³em tela                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Faturamento                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador    ³ Data       ³  Motivo da Alteracao                  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Luciano Mafra ³ 30/01/2014 ³  Atendendo chamado Jéssica Logistica     ³±±
±±³               ³            ³             Nº 018558                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CERTSAN()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as variáveis utilizadas na rotina                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local bFiltSF2
Local aAreaAtu	:= GetArea()
Local aCores    := {	{  'F2_TIPO=="N"'	, 'DISABLE'},;		// NF Normal
						{  'F2_TIPO=="P"'	, 'BR_AZUL'},;		// NF de Compl. IPI
						{  'F2_TIPO=="I"'	, 'BR_MARRON'},;	// NF de Compl. ICMS
						{  'F2_TIPO=="C"'	, 'BR_PINK'},;		// NF de Compl. Preco/Frete
						{  'F2_TIPO=="B"'	, 'BR_CINZA'},;		// NF de Beneficiamento
						{  'F2_TIPO=="D"'  	, 'BR_AMARELO'} }	// NF de Devolucao
						
Local aRegs		:= {}
Local aIndexSF2	:= {}
Local lWhen		:= .T.
Local cQuerySF2	:= ""

Private cString		:= "SF2"
Private cCadastro 	:= "Certificado Sanitario"
Private cTitulo 	:= ""
Private aRotina		:= MenuDef()    
Private _cUsuario	:= __CUSERID //CODIGO DO USUARIO ATUAL
Private _UsuCS		:= GetMv( "MV_#USUCS" , .F. , "000000" )  //LISTA DOS USUARIOS QUE PODEM DIGITAR INFORMACOES NO CERTIFICADO SANITARIO

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para impressao do CERTIFICADO SANITARIO, baseado nas informacoes da NF fiscal e nas informacoes digitadas em tela')

dbSelectArea( "SF2" )
dbSetOrder( 1 )
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a interface com o usuário dos registros já cadastrados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6,1,22,75,"SF2",,,,,,aCores,,,,,,,,cQuerySF2)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraCert  ³ Autor ³ ADRIANA - HC       ³ Data ³  19/05/10   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Abre tela do certificado para digitacao dos dados a serem   ³±±
±±³          ³impressos                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Faturamento                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador³ Data   ³ BOPS ³  Motivo da Alteracao                  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ³        ³      ³                                           ³±±
±±³           ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GeraCert( cAlias, nReg, nOpcx )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as variáveis da rotina                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpcConf		:= 0
Local lRetorno		:= .T.
Local lGravou		:= .F.
Local aPosObj    	:= {} 
Local aObjects   	:= {}                        
Local aSize      	:= MsAdvSize() 
Local aCposGet		:= {}                                                             
Local nOpcA			:= 0
Local nLoop1		:= 0

Local nSaveSX8		:= GetSX8Len()          

Local aButtons		:= { {"S4WB010N",{ || ImpCert() },"Imprime Cert.Sanitario","Imprime" }}

Private oDlgMain
Private oFldDados
Private oGDados
Private oTemp
Private oLacre
Private oMeioTr
Private oHLacre
Private oDTDE
Private oDTATE
Private oDIASVLD
Private oCONSIG
Private oMsg1
Private oMsg2
Private oMsg3
Private oMsg4
Private oMsg5
Private cDoc		
Private cSerie	 	
Private cCliente
Private cLoja 	 	
Private cTemp
Private cLacre
Private cMeioTr
Private cHLacre
Private cDTDE
Private cDTATE
Private cDIASVLD
Private cCONSIG
Private cMsg1
Private cMsg2
Private cMsg3
Private cMsg4
Private cMsg5
Private cPlaca
Private cNCliente
Private cDestino
Private aCols	 	:= {} 
Private aHeader 	:= {}
Private aGets		:= {}
Private aTELA   	:= {}    
Private cDTPRD 
Private oDTPRD  

U_ADINF009P('CERTSAN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para impressao do CERTIFICADO SANITARIO, baseado nas informacoes da NF fiscal e nas informacoes digitadas em tela')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no registro, caso ainda não esteja posicionado                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( cAlias )
dbSetOrder( 1 )
dbGoTo( nReg )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a operacao que esta sendo executada                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDoc		:= F2_DOC
cSerie	 	:= F2_SERIE
cCliente   	:= F2_CLIENTE
cLoja		:= F2_LOJA
IF SF2->F2_TIPO $ "B/D"
   cNCliente   := Alltrim(Posicione("SA2",1,xFilial("SA2")+cCliente+cLoja,"A2_NOME"))
   cDestino    := Alltrim(Posicione("SA2",1,xFilial("SA2")+cCliente+cLoja,"A2_MUN"))+"/ "+F2_EST
Else
    cNCliente   := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME"))
    cDestino    := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_MUN"))+"/ "+F2_EST
Endif    
cPlaca		:= F2_PLACA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta variaveis de tela                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "ZZ8" )
dbSetOrder( 1 )
if DbSeek( xFilial( "ZZ8" ) + cDoc + cSerie, .F.)         
	cTemp	:= ZZ8_TEMP
	cLacre	:= ZZ8_LACRE
	cMeioTr	:= ZZ8_MEIOTR
	cHLacre	:= ZZ8_HLACRE
	cDTDE   := ZZ8_DTPRDD
    cDTATE  := ZZ8_DTPRDA
    cDIASVLD:= ZZ8_DIASVL
    cCONSIG := ZZ8_CONSIG
	cMsg1	:= ZZ8_MSG1
	cMsg2	:= ZZ8_MSG2
	cMsg3	:= ZZ8_MSG3
	cMsg4	:= ZZ8_MSG4
	cMsg5	:= ZZ8_MSG5
	cDtPrd  := ZZ8_DTPRD
else
	cTemp	:= Criavar( "ZZ8_TEMP" )
	cLacre	:= Criavar( "ZZ8_LACRE" )
	cMeioTr	:= Criavar( "ZZ8_MEIOTR" )
	cHLacre	:= Time() //Criavar( "ZZ8_HLACRE" )
	cDTDE   := CRIAVAR("ZZ8_DTPRDD")
    cDTATE  := CRIAVAR("ZZ8_DTPRDA")
    cDIASVLD:= CRIAVAR("ZZ8_DIASVL")
    cCONSIG := CRIAVAR("ZZ8_CONSIG")
	cMsg1	:= "OBS:O PRODUTO ATENDE AS CONDICOES TECNICAS E HIGIENICO-SANITARIAS EXIGIDAS PELA LEGISLACA"  //Criavar( "ZZ8_MSG1" )
	cMsg2	:= "O DO(S) PAIS(ES) PARA O(S) QUAL(AIS) ESTA(AO)HABILITADOS:LISTA GERAL"  //Criavar( "ZZ8_MSG2" )
	cMsg3	:= "ESTE CERTIFICADO CANCELA E SUBSTITUI O DE NR. 005259"   //Criavar( "ZZ8_MSG3" )
	cMsg4	:= Criavar( "ZZ8_MSG4" )
	cMsg5	:= Criavar( "ZZ8_MSG5" )
	cDtPrd  := Criavar( "ZZ8_DTPRD" )
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o header do arquivo                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SX3" )
dbSetOrder( 1 )
MsSeek( "ZZ9" )
While	SX3->( !Eof() ) .And. SX3->X3_ARQUIVO $ "ZZ9"
	If X3USO(X3_USADO) .And.;
		cNivel >= X3_NIVEL .And.;
		!( Alltrim( SX3->X3_CAMPO ) $ "ZZ9_FILIAL/ZZ9_DOC/ZZ9_SERIE")
		aAdd( aHeader,{	AllTrim(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT,;
						SX3->X3_CBOX,;
						SX3->X3_RELACAO,;
						SX3->X3_WHEN,;
						SX3->X3_VISUAL,;
						SX3->X3_VLDUSER,;
						SX3->X3_PICTVAR,;
						SX3->X3_OBRIGAT})
	EndIf
	SX3->( dbSkip() )
EndDo 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o acols  do arquivo                                                            ³
//³ Varre o arquivo e pega os registros relativos a chave                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "ZZ9" )
dbSetOrder( 1 )
MsSeek( xFilial( "ZZ9" ) + cDoc + cSerie, .F.)
While ZZ9->( !Eof() ) .And. ZZ9->ZZ9_FILIAL == xFilial( "ZZ9" ) .And. ZZ9->ZZ9_DOC == cDoc   
	aAdd( aCols, Array( Len( aHeader ) + 1 ) )
	For nLoop1 := 1 To Len( aHeader )
			aCols[Len(aCols),nLoop1]	:= &(Alltrim( aHeader[nLoop1,2] ))
	Next nLoop1
	aCols[Len(aCols), Len( aHeader ) + 1] := .F.
	ZZ9->( dbSkip() )
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os acols se o mesmo estiver vazio                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aCols ) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona um elemento                                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbselectarea("SD2")
	dbsetorder(3)
	dbseek(xfilial("SD2")+cdoc+cserie)
	while !eof() .and. D2_DOC = cdoc .and. D2_SERIE = cserie
		aAdd( aCols, Array( Len( aHeader ) + 1) )
		For nLoop1 := 1 To Len( aHeader )
			if Alltrim(aHeader[nLoop1,2]) == "ZZ9_ITEM"
				aCols[Len(aCols),nLoop1]	:= SD2->D2_ITEM
			elseif Alltrim(aHeader[nLoop1,2]) == "ZZ9_PRODUT"
				aCols[Len(aCols),nLoop1]	:= SD2->D2_COD
			elseif Alltrim(aHeader[nLoop1,2]) == "ZZ9_DESCRI"
				aCols[Len(aCols),nLoop1]	:= Posicione("SC6",1,xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV,"C6_DESCRI")
			else
				aCols[Len(aCols),nLoop1]	:= CriaVar( aHeader[nLoop1,2] )
			endif
		Next nLoop1 
		
		aCols[Len(aCols), Len( aHeader ) + 1] := .F.
		dbskip()
	end
EndIf                    

cTitulo := "Certificado Sanitario - NF "+cSerie+cDoc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a area dos objetos                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aObjects := {} 
AAdd( aObjects, { 100, 030, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t. } )

aInfo 		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj 	:= MsObjSize( aInfo, aObjects ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface principal com o usuário                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgMain := TDialog():New(aSize[7],00,aSize[6]-50,aSize[5]-480,cTitulo,,,,,,,,oMainWnd,.T.)
//oDlgMain := TDialog():New(17,00,552,766,cTitulo,,,,,,,,oMainWnd,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os gets de cabeçalho                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
@ aPosObj[1,1],aPosObj[1,2] 		SAY "Temperatura:" OF oDlgMain PIXEL SIZE 50,09 SHADED
@ aPosObj[1,1]+8,aPosObj[1,2] 		MSGET oTemp VAR cTemp F3 "USR" PICTURE "999999" ;
										VALID VldUsr( oCodUsr, cCodUsr, @oNomUsr, @cNomUsr ) WHEN lAdo01Inc ;
										OF oDlgMain PIXEL SIZE 50,09
*/

@ aPosObj[1,1],aPosObj[1,2] 			SAY "Temperatura:" OF oDlgMain PIXEL SIZE 50,09 SHADED
@ aPosObj[1,1]+8,aPosObj[1,2] 			MSGET oTemp VAR cTemp PICTURE "@!" WHEN (_cUsuario $ _UsuCS) ;
										OF oDlgMain PIXEL SIZE 50,09
	
@ aPosObj[1,1],aPosObj[1,2]+70			SAY "Lacre:" OF oDlgMain PIXEL SIZE 50,09 SHADED
	@ aPosObj[1,1]+8,aPosObj[1,2]+70	MSGET oLacre VAR cLacre  WHEN (_cUsuario $ _UsuCS) ;
										OF oDlgMain PIXEL SIZE 50,09  	

@ aPosObj[1,1],aPosObj[1,2]+140		SAY "Meio Transporte:" OF oDlgMain PIXEL SIZE 50,09 SHADED
	@ aPosObj[1,1]+8,aPosObj[1,2]+140	MSGET oMeiotr VAR cMeiotr  WHEN (_cUsuario $ _UsuCS) ;
										OF oDlgMain PIXEL SIZE 150,09

@ aPosObj[1,1],aPosObj[1,2]+300		SAY "Hora lacracao:" OF oDlgMain PIXEL SIZE 50,09 SHADED
	@ aPosObj[1,1]+8,aPosObj[1,2]+300	MSGET oHLacre VAR cHLacre  WHEN (_cUsuario $ _UsuCS) ;
										OF oDlgMain PIXEL SIZE 50,09
										
//*****************************************************************************************************
// Alteração Chamado 018558 - Data de Produção de/até em um único campo alfanumérico de 50 posições.
//*****************************************************************************************************
@ aPosObj[1,1]+20,aPosObj[1,2] 			SAY "Data Produção:" OF oDlgMain PIXEL SIZE 300,09 SHADED
@ aPosObj[1,1]+28,aPosObj[1,2] 			MSGET oDTPRD VAR cDTPRD WHEN (_cUsuario $ _UsuCS) ;
										OF oDlgMain PIXEL SIZE 300,09

//@ aPosObj[1,1]+20,aPosObj[1,2] 			SAY "Data Prod. De:" OF oDlgMain PIXEL SIZE 50,09 SHADED
//@ aPosObj[1,1]+28,aPosObj[1,2] 			MSGET oDTDE VAR cDTDE WHEN (_cUsuario $ _UsuCS) ;
//										OF oDlgMain PIXEL SIZE 50,09
	
//@ aPosObj[1,1]+20,aPosObj[1,2]+70			SAY "Data Prod. Ate:" OF oDlgMain PIXEL SIZE 50,09 SHADED
//	@ aPosObj[1,1]+28,aPosObj[1,2]+70	MSGET oDTATE VAR cDTATE  WHEN (_cUsuario $ _UsuCS) ;
//										OF oDlgMain PIXEL SIZE 50,09  	            
										
//*****************************************************************************************************										
@ aPosObj[1,1]+20,aPosObj[1,2]+300		SAY "Validade em Dias:" OF oDlgMain PIXEL SIZE 50,09 SHADED
	@ aPosObj[1,1]+28,aPosObj[1,2]+300	MSGET oDIASVLD VAR cDIASVLD  WHEN (_cUsuario $ _UsuCS) ;
										OF oDlgMain PIXEL SIZE 50,09  

//@ aPosObj[1,1]+20,aPosObj[1,2]+140		SAY "Validade em Dias:" OF oDlgMain PIXEL SIZE 50,09 SHADED
//	@ aPosObj[1,1]+28,aPosObj[1,2]+140	MSGET oDIASVLD VAR cDIASVLD  WHEN (_cUsuario $ _UsuCS) ;
//										OF oDlgMain PIXEL SIZE 50,09

//@ aPosObj[1,1]+20,aPosObj[1,2]+300		SAY "Consignatario:" OF oDlgMain PIXEL SIZE 50,09 SHADED
//	@ aPosObj[1,1]+28,aPosObj[1,2]+300	MSGET oConsig VAR cConsig  WHEN (_cUsuario $ _UsuCS) ;
//										OF oDlgMain PIXEL SIZE 120,09
										
										

	@ aPosObj[1,1]+40,aPosObj[1,2]			SAY "Mensagens:" OF oDlgMain PIXEL SIZE 50,09 SHADED
	@ aPosObj[1,1]+50,aPosObj[1,2]   	MSGET oMsg1 VAR cMsg1 ;
										OF oDlgMain PIXEL SIZE 350,09
	@ aPosObj[1,1]+60,aPosObj[1,2]   	MSGET oMsg2 VAR cMsg2 ;
					 					OF oDlgMain PIXEL SIZE 350,09
	@ aPosObj[1,1]+70,aPosObj[1,2]   	MSGET oMsg3 VAR cMsg3 ;
										OF oDlgMain PIXEL SIZE 350,09
	@ aPosObj[1,1]+80,aPosObj[1,2]   	MSGET oMsg4 VAR cMsg4 ;
										OF oDlgMain PIXEL SIZE 350,09
	@ aPosObj[1,1]+90,aPosObj[1,2]    	MSGET oMsg5 VAR cMsg5 ;
										OF oDlgMain PIXEL SIZE 350,09
										
										
	/*Posicionamento original - MAuricio - MDS TEC - 15/01/14									
	@ aPosObj[1,1]+28,aPosObj[1,2]			SAY "Mensagens:" OF oDlgMain PIXEL SIZE 50,09 SHADED
	@ aPosObj[1,1]+38,aPosObj[1,2]   	MSGET oMsg1 VAR cMsg1 ;
										OF oDlgMain PIXEL SIZE 350,09
	@ aPosObj[1,1]+48,aPosObj[1,2]   	MSGET oMsg2 VAR cMsg2 ;
					 					OF oDlgMain PIXEL SIZE 350,09
	@ aPosObj[1,1]+58,aPosObj[1,2]   	MSGET oMsg3 VAR cMsg3 ;
										OF oDlgMain PIXEL SIZE 350,09
	@ aPosObj[1,1]+68,aPosObj[1,2]   	MSGET oMsg4 VAR cMsg4 ;
										OF oDlgMain PIXEL SIZE 350,09
	@ aPosObj[1,1]+78,aPosObj[1,2]    	MSGET oMsg5 VAR cMsg5 ;
										OF oDlgMain PIXEL SIZE 350,09									
    */										
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o folder dos itens                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	oFldDados 	:= TFolder():New(aPosObj[2,1]-10,aPosObj[2,2],{ "&Itens da NF" },,oDlgMain,,,,.T.,.T.,(aPosObj[2,4]-aPosObj[2,2]),((aPosObj[2,3]-aPosObj[2,1])+10))
  	oFldDados 	:= TFolder():New(aPosObj[2,1]+70,aPosObj[2,2],{ "&Itens da NF" },,oDlgMain,,,,.T.,.T.,(aPosObj[2,4]-aPosObj[2,2])-270,((aPosObj[2,3]-aPosObj[2,1])-100)) 
//	oFldDados 	:= TFolder():New(118,3,{ "&Itens da NF" },,oDlgMain,,,,.T.,.T.,347,143.5) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a getdados da folder                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)
	oGDados := MsNewGetDados():New(000,000,oFldDados:aDialogs[1]:nClientHeight/2,oFldDados:aDialogs[1]:nClientWidth/2,iif(_cUsuario$_UsuCS,GD_INSERT+GD_DELETE+GD_UPDATE,0),,,"+ZZ9_ITEM",,,9999,,,,oFldDados:aDialogs[1],@aHeader,@aCols)
//	oGDados:bLinhaOk	:= { || U_Ado01LOk() }
//	oGDados:bTudoOk 	:= { || U_Ado01TOk() }
oDlgMain:Activate(,,,,,,{||EnchoiceBar(oDlgMain,{||Iif(nOpcx == 2, (nOpcA := 0,oDlgMain:End()), nOpcA := If(Obrigatorio(aGets,aTela),1,0)),If(nOpcA==1,oDlgMain:End(),Nil)},{||oDlgMain:End()},,aButtons	)})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a gravacao das informacoes                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1
	lGravou	:= GrvDados( @lRetorno, nOpcX, @nSaveSX8 )
Endif

If lGravou
	While GetSx8Len() > nSaveSX8
		ConfirmSX8()
	EndDo
Else
	While GetSx8Len() > nSaveSX8
		RollBackSX8()
	EndDo
EndIf

Return( lRetorno )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma    ³GrvDados³Grava os dados da rotina                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAutor       ³28.05.10³hc                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros  ³Nil                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno     ³ExpL1 - .T. gravação com sucesso                                          º±±
±±º            ³        .F. erro na gravação                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservações ³                                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlterações  ³ 99.99.99 - Consultor - Descrição da Alteração                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GrvDados( lRetorno, nOpcX )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara as variáveis da rotina                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nLoop1		:= 0
Local nLoop2		:= 0
Local nPItem		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_ITEM" } )
Local nPProdut		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_PRODUT" } )
Local nPDescri		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_DESCRI" } )
Local nPValida		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_VALIDA" } )
Local nPProd  		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_PROD" } )
                                                                                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a ampulheta de processamento e o controle de transação                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CursorWait()
Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varre todo o acols                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoop1 := 1 To Len( oGDados:aCols )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o item estiver deletado e encontrar o registro na base, deleta        	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	oGDados:aCols[nLoop1, Len(aHeader) + 1] .And.;
			ZZ9->( MsSeek( xFilial( "ZZ9" ) + cDoc + cSerie + oGDados:aCols[nLoop1,nPItem] ) )
			RecLock( "ZZ9", .F. )
				dbDelete()
			MsUnLock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o item não estiver deletado atualiza dados                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf !( oGDados:aCols[nLoop1, Len(aHeader) + 1] )
			If ZZ9->(MsSeek( xFilial( "ZZ9" ) + cDoc + cSerie + oGDados:aCols[nLoop1,nPItem] ))
				RecLock( "ZZ9", .F. ) // se existe altera
			Else
				RecLock( "ZZ9", .T. ) // se nao existe inclui
				ZZ9->ZZ9_FILIAL	:= xFilial("ZZ9")
				ZZ9->ZZ9_DOC	:= cDoc
				ZZ9->ZZ9_SERIE	:= cSerie
				ZZ9->ZZ9_ITEM 	:= oGDados:aCols[nLoop1,nPItem]
				ZZ9->ZZ9_PRODUT	:= oGDados:aCols[nLoop1,nPProdut]
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os campos do acols                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
			
			ZZ9->ZZ9_DESCRI	:= oGDados:aCols[nLoop1,nPDescri]
			ZZ9->ZZ9_VALIDA	:= oGDados:aCols[nLoop1,nPValida]
			ZZ9->ZZ9_PROD   := oGDados:aCols[nLoop1,nPProd]

			MsUnlock()
		Endif
		
	Next nLoop1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os campos fixos                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ZZ8->(MsSeek( xFilial( "ZZ8" ) + cDoc + cSerie ))
		RecLock( "ZZ8", .F. ) // se existe altera
	Else
		RecLock( "ZZ8", .T. ) // se nao existe inclui
		ZZ8->ZZ8_FILIAL	:= xFilial("ZZ8")
		ZZ8->ZZ8_DOC	:= cDoc
		ZZ8->ZZ8_SERIE	:= cSerie
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os campos da get                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	ZZ8->ZZ8_TEMP	:= cTemp
	ZZ8->ZZ8_LACRE	:= cLacre
	ZZ8->ZZ8_MEIOTR	:= cMeioTR
	ZZ8->ZZ8_HLACRE := cHLacre
	ZZ8->ZZ8_MSG1	:= cMsg1
	ZZ8->ZZ8_MSG2	:= cMsg2
	ZZ8->ZZ8_MSG3	:= cMsg3
	ZZ8->ZZ8_MSG4	:= cMsg4
	ZZ8->ZZ8_MSG5	:= cMsg5
	ZZ8->ZZ8_DTPRDD := cDTDE
    ZZ8->ZZ8_DTPRDA := cDTATE
    ZZ8->ZZ8_DIASVL := cDIASVLD
    ZZ8->ZZ8_CONSIG := cCONSIG                                 
//***********************************
// Alteração chamado Nº 018558 
//***********************************
    ZZ8->ZZ8_DTPRD  := cDTPRD                                
//***********************************

	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza flag de processamento de gravação concluido	                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetorno	:= .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a transacao                               		                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
End Transaction
CursorArrow()

Return( lRetorno )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma    ³ImpCert ³Imprime certificado                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAutor       ³29.05.10³hc                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros  ³Nil                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno     ³Nil                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservações ³                                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlterações  ³ 99.99.99 - Consultor - Descrição da Alteração                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpCert( )

Local _cRet := ""
Local titulo := "Certificado Sanitario"
Local cdesc1 := "Este programa tem como objetivo imprimir Certificado Sanitario"
Local cdesc2 := ""
Local cdesc3 := ""              
Local aOrd := {}
Private lEnd := .F.
Private lAbortPrint := .F.
Private Limite := 80
Private Tamanho := "P"
Private NomeProg := "CERTSAN.PRW"
Private nTipo := 18
Private aReturn := { "ZEBRADO", 1, "ADMINISTRACAO",2,2, 1, "",1}
Private nLastkey := 0
Private nLin :=18
Private wNrel := "CERTSAN"
Private M_PAG := 01
Private Cabec1 := ""
Private Cabec2 := ""

wNrel := SetPrint(cString,wNrel,,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd ,.T.,Tamanho,,.T.)

IF nLastkey == 27
	Return
ENDIF

SetDefault(aReturn,cString)
IF nLastkey == 27
	Return
Endif
nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| Runreport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
      
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma    ³RunReport³Imprime certificado                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAutor       ³29.05.10³hc                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros  ³Nil                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno     ³Nil                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservações ³                                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlterações  ³ 99.99.99 - Consultor - Descrição da Alteração                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Runreport(Cabec1,Cabec2,Titulo,nLin)
Local lContinua := .f.
Local _i
Local nPItem		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_ITEM" } )
Local nPProdut		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_PRODUT" } )
Local nPDescri		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_DESCRI" } )
Local nPValida		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_VALIDA" } )
Local nPProd  		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "ZZ9_PROD" } )
nTotlinm := 0
nTotlin := 0
SetRegua(Reccount())

nTotLin := len(aCols)*3
nTotlinM := nTotLinM+iif(!empty(cMsg1),1,0)
nTotlinM := nTotLinM+iif(!empty(cMsg2),1,0)
nTotlinM := nTotLinM+iif(!empty(cMsg3),1,0)
nTotlinM := nTotLinM+iif(!empty(cMsg4),1,0)
nTotlinM := nTotLinM+iif(!empty(cMsg5),1,0)
                    
nTotLin += nTotlinM
SetPrc(0,0)                              // (Zera o Formulario)
@ 00,00 Psay Chr(15)

for _i := 1 to len(aCols)
	If nLin >= 27
		lContinua := .t. 
		_Rodape()
		Quebra:='S'
		SetPrc(0,0)                              // (Zera o Formulario)
		@ 00,00 Psay Chr(15)
		nLin:=18
	endif
		Quebra:='N'
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbSeek(xFilial("SD2")+cDoc+cSerie+cCliente+cLoja+(oGDados:aCols[_i,nPProdut])+(oGDados:aCols[_i,nPItem]))
		
		nLin += 1
		
		@ nLin, 10 Psay oGDados:aCols[_i,nPDescri]
		@ nLin, 70 Psay Transform(SD2->D2_QUANT,'@E 999,999')
	    @ nLin, 89 Psay Transform(SD2->D2_QTSEGUM,'@E 999,999')   
		@ nLin,106 Psay "CAIXAS"   //AllTrim(Posicione("SAH",1,xFilial("SAH")+SD2->D2_SEGUM,"AH_DESCPO"))
		
		if Alltrim(oGDados:aCols[_i,nPProdut]) = "113075"
			nlin ++
			@ nLin, 10 Psay '"PRODUTO DESTINADO EXCLUSIVAMENTE PARA FINS INDUSTRIAIS"'
			nlin ++
			@ nLin, 10 Psay '"MERCADO INTERNO"'
        endif
		
		//nlin ++ *
		//@ nLin, 00 Psay "DATA DE PRODUCAO: DE "+Alltrim(oGDados:aCols[_i,nPProd]) // incluido por Adriana para atender chamado 7621
		
		//nlin ++
		//@ nLin, 00 Psay "DATA DE VALIDADE: "+Alltrim(oGDados:aCols[_i,nPValida])+" DIAS A PARTIR DA DATA DE PRODUCAO"

        //nlin++

	//if (_i < len(aCols) .and. (nlin+2+nTotLinM+iif(Alltrim(oGDados:aCols[_i,nPProdut]) = "113075",2,0)) > 27) .or. (_i = len(aCols))
   	//	for _m := 1 to 5
   	//	  	if !Empty(&("cMsg"+Str(_m,1)))
	//			@ nLin, 00 Psay &("cMsg"+Str(_m,1))
	//			nlin++
	//		endif
   	//	next
   	//	nLin := 30
	//endif
Next
//***********************************
// Alteração chamado Nº 018558 
//***********************************
nlin++
@ nLin, 10 Psay "DATA DE PRODUCAO: "+Alltrim(cDTPRD) 
//@ nLin, 00 Psay "DATA DE PRODUCAO: "+DTOC(cDTDE)+" A "+DTOC(cDTATE)   //+Alltrim(oGDados:aCols[_i,nPProd]) // incluido por Adriana para atender chamado 7621
nlin ++
//***********************************
@ nLin, 10 Psay "DATA DE VALIDADE: "+cDIASVLD+" DIAS A PARTIR DA DATA DE PRODUCAO"
nlin++

for _m := 1 to 5
  	if !Empty(&("cMsg"+Str(_m,1)))
		@ nLin, 10 Psay &("cMsg"+Str(_m,1))
		nlin++
	endif
next
nLin := 30

_Rodape()

Set device to screen

If aReturn[5]==1
	DbCommitAll()
	Set Printer to
	OurSpool(wNrel)
Endif

Ms_Flush()
Return

Static Function _Rodape()
Local aMES := {"Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

nLin:=28

@nLin,19 Psay CHR(15)+cDoc
@nLin,50 Psay cSerie
@nLin,104 Psay "TEMPERATURA: "+Alltrim(cTemp)
 
nLin +=2
@nLin,31 Psay "ADORO S/A - VARZEA PAULISTA/SP" //PONTO DE EMBARQUE
nLin +=1
@nLin,094 Psay cNCliente //CONSIGNATARIO
nLin ++
@nLin,094 Psay "ADORO S/A - S.I.F. 414" //EMBARCADOR
nLin ++
@nLin,31 Psay Alltrim(cMeioTR)+" - "+cPlaca //MEIO DE TRANSPORTE
@nLin,094 Psay cDestino //DESTINO
nLin++          
@nLin,31 Psay cHLacre //HORA LACRE
@nLin,094 Psay Alltrim(cLacre) // LACRE
nLin++
@nLin,70 PSay "03"

@40, 79 PSay StrZero(Day(Date()),2)
@40, 92 PSay Upper(aMes[Month(Date())])
@40,121 PSay Right((Str(Year(Date()),4)),2)  //113

@51,000 PSay " "

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma    ³MenuDef ³Definição das rotinas para o programa                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAutor       ³27.05.10³HC                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros  ³Nil                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno     ³Nil.                                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservações ³                                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlterações  ³ 99.99.99 - Consultor - Descrição da Alteração                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Private aRotina	:= {}     

aRotina		:= {	{ "Pesquisar",		"AxPesqui()",								0, 	1, 0, Nil },; 
					{ "Visualiza NF",	"MC090Visual",								0,	2, 0, Nil },; 
					{ "Certificado",	"U_GeraCert('SF2', SF2->( Recno() ), 4)",	0,	2, 0, Nil },; 
					{ "Legenda",		"MC090Legend",								0,	5, 0, Nil } }

Return( aRotina ) 