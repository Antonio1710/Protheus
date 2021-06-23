#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ EPCP003  ³ Autor ³ Erike Yuri da Silva   ³ Data ³06/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Listagem do pre'-inventario do dia Ripasa                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³         Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function EPCP003

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Tamanho 
Local Titulo	:= "Listagem para Inventario do dia Ripasa"	
Local cDesc1	:= "Este programa emite um relatorio que facilita a digitacao"  
Local cDesc2	:= 'das quantidades inventariadas.'
Local cDesc3	:= "Ele e' emitido de acordo com os parametros informados." 
Local cString	:= 'SD3'
Local aOrd		:= {OemToAnsi(" Por Codigo       "),OemToAnsi(" Por Tipo         "),OemToAnsi(" Por Grupo        "),OemToAnsi(" Por Localizacao Física")}   
Local wnRel		:= 'EPCP003'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn  := {OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 2, 2, 1, '',1 }   //'Zebrado'###'Administracao'
Private nLastKey := 0
Private cPerg    := 'PCP003'

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Listagem do pre-inventario do dia Ripasa')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Almox. de                                    ³
//³ mv_par02     // Almox. ate                                   ³
//³ mv_par03     // Produto de                                   ³
//³ mv_par04     // Produto ate                                  ³
//³ mv_par05     // tipo de                                      ³
//³ mv_par06     // tipo ate                                     ³
//³ mv_par07     // grupo de                                     ³
//³ mv_par08     // grupo ate                                    ³
//³ mv_par09     // data Selecao de                              ³
//³ mv_par10     // data Selecao ate                             ³  
//³ mv_par11     // Da Op                                        ³
//³ mv_par12     // Ate Op                                       ³
//³ mv_par13     // Imprime Lote/Sub-Lote e N£mero de S‚rie ?    ³
//³ mv_par14     // Lista Prod. C/ Sld Zerado ? (Sim/Nao)        ³
//³ mv_par15     // Imprime produtos que geram Op?               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()
Pergunte(cPerg,.F.)
//-- Define a variavel Tamanho de acordo com Impress„o ou N„o do Lote/Sub-Lote e N.S.
Tamanho := If(mv_par13 == 1,'G','M')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnRel:=SetPrint(cString,wnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	dbClearFilter()
	Return Nil
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	dbClearFilter()
	Return Nil
Endif

//-- Re-Define a variavel Tamanho de acordo com Impress„o ou N„o do Lote/Sub-Lote e N.S.
Tamanho := If(mv_par13 == 1,'G','M')

RptStatus({|lEnd| E003Run(aOrd,@lEnd,wnRel,cString,Titulo,Tamanho)},Titulo)

Return Nil
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ E003Run  ³ Autor ³ Erike Yuri da Silva   ³ Data ³06/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP003			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function E003Run(aOrd,lEnd,wnRel,cString,Titulo,Tamanho)
	MsgRun("Aguarde, Gerando relatorio...." ,,{|lEnd| E003Imp(aOrd,lEnd,wnRel,cString,Titulo,Tamanho) })  
Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ E003Imp  ³ Autor ³ Erike Yuri da Silva   ³ Data ³06/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP003			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function E003Imp(aOrd,lEnd,wnRel,cString,Titulo,Tamanho)
Local ntipo		:= 0
Local lRastro	:= .F.
Local lRastroS 	:= .F.
Local lCLocal	:= .F.
Local cDet		:= '[               ]  [             ] '
Local aStruSD3	:= {}
Local cQuery	:= ""
Local cAliasSQL	:= "SD3SQL"
Local cEnd,cNumSeri,cLoteCtl,cNumLote
Local nX      
Local aAreaSB2	:= GetArea("SB2")
Local aAreaSD3	:= GetArea("SD3")
Local nLin		:= 80
Local lImpLote	:= If(mv_par13==1,.T.,.F.)     
Local aLstPrint	:= {}
Private m_pag	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := If(aReturn[4]==1,15,18)

Titulo += ' (' + AllTrim(aOrd[aReturn[8]]) + ')'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImpLote
	Cabec1 := "CODIGO          TP GRUPO DESCRICAO                       UM  AMZ  ENDERECO         LOTE        SUB     NUMERO                       __________CONTAGEM_________ " 
	Cabec2 := "                                                                                               LOTE    SERIE                        QUANTIDADE         ETIQUETA " 
	//--       123456789012345 12 1234  123456789012345678901234567890  12  12   123456789012345  1234567890  123456  12345678901234             [               ]  [             ]   
	//--       0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//--       01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Else
	Cabec1 := "CODIGO          TP GRUP DESCRICAO                        UM  AMZ  ENDERECO           __________CONTAGEM_________ " 
	Cabec2 := "                                                                                     QUANTIDADE         ETIQUETA " 
EndIf
//--           123456789012345 12 1234 123456789012345678901234567890   12  12   123456789012345   [               ]  [             ]   
//--           0         1         2         3         4         5         6         7         8         9        10        11        12        13
//--           0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os Arquivos e Ordens a serem utilizados           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
dbSelectArea('SB1')
dbSetOrder(1)

dbSelectArea('SB2')
dbSetOrder(1)
                   
DbSelectArea("SDB")
DbSetOrder(1)

DbSelectArea("SD5")
DbSetOrder(3)		

cAliasSQL := "SD3SQL"
aStruSD3 := SD3->(dbStruct()) 
cQuery := "SELECT D3_FILIAL,D3_COD,D3_TIPO,D3_GRUPO,D3_UM,D3_LOCAL,D3_LOCALIZ,D3_NUMSERI,D3_LOTECTL,D3_NUMLOTE,D3_NUMSEQ"
cQuery += " FROM "
cQuery += RetSqlName("SD3")+" SD3"
cQuery += " WHERE SD3.D3_FILIAL='"+xFilial("SD3")+"' AND" 
cQuery += " SD3.D3_EMISSAO>='"+DTOS(mv_par09)+"' AND SD3.D3_EMISSAO<='"+DTOS(mv_par10)+"' AND" 
cQuery += " SD3.D3_LOCAL>='"+mv_par01+"' AND SD3.D3_LOCAL<='"+mv_par02+"' AND"    
cQuery += " SD3.D3_COD>='"+mv_par03+"' AND SD3.D3_COD<='"+mv_par04+"' AND"
cQuery += " SD3.D3_OP>='"+mv_par11+"' AND SD3.D3_OP<='"+mv_par12+"' AND" 
cQuery += " SD3.D3_OP<>'"+Space(TamSX3("D3_OP")[1])+"'AND"    
cQuery += " SD3.D3_TIPO>='"+mv_par05+"' AND SD3.D3_TIPO<='"+mv_par06+"' AND"
cQuery += " SD3.D3_GRUPO>='"+mv_par07+"' AND SD3.D3_GRUPO<='"+mv_par08+"' AND"     
If mv_par15==2
	cQuery += " SD3.D3_CF<>'PR0' AND"           
EndIf
cQuery += " SD3.D3_FLAGINV='' AND"
cQuery += " SD3.D_E_L_E_T_<>'*' "  
cQuery += " ORDER BY "
DO CASE
	Case aReturn[8]==2 //Por Tipo
		cQuery += "SD3.D3_FILIAL,SD3.D3_TIPO,SD3.D3_COD,SD3.D3_LOCAL,SD3.D3_LOCALIZ,SD3.D3_NUMSERI,SD3.D3_LOTECTL,SD3.D3_NUMLOTE"
	Case aReturn[8]==3 //Por Grupo  
		cQuery += "SD3.D3_FILIAL,SD3.D3_GRUPO,SD3.D3_COD,SD3.D3_LOCAL,SD3.D3_LOCALIZ,SD3.D3_NUMSERI,SD3.D3_LOTECTL,SD3.D3_NUMLOTE"	
	Case aReturn[8]==4 //Por Localizacao Fisica
		cQuery += "SD3.D3_FILIAL,SD3.D3_LOCAL,SD3.D3_LOCALIZ,SD3.D3_NUMSERI,SD3.D3_LOTECTL,SD3.D3_NUMLOTE,SD3.D3_COD"	
	OtherWise  //Por Produto
		cQuery += "SD3.D3_FILIAL,SD3.D3_COD,SD3.D3_LOCAL,SD3.D3_LOCALIZ,SD3.D3_NUMSERI,SD3.D3_LOTECTL,SD3.D3_NUMLOTE"	
ENDCASE	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSQL,.F.,.T.)
For nX := 1 To Len(aStruSD3)
	If aStruSD3[nX][2]<>"C" .And. FieldPos(aStruSD3[nX][1])<>0
		TcSetField(cAliasSQL,aStruSD3[nX][1],aStruSD3[nX][2],aStruSD3[nX][3],aStruSD3[nX][4])
	EndIf
Next nX

DbSelectArea(cAliasSQL) 

Do While !Eof()
	If lEnd
		@ pRow()+1, 001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica consistencia da base de dados.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If !SB1->(dbSeek(xFilial('SB1') + (cAliasSQL)->D3_COD)) 
		(cAliasSQL)->(dbSkip())
		Loop
	EndIf     
	
	If !SB2->(dbSeek(xFilial('SB2') + (cAliasSQL)->(D3_COD+D3_LOCAL))) 
		(cAliasSQL)->(dbSkip())
		Loop
	EndIf     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o saldo estiver zerado (mv_par14 == 2 (Nao))     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If mv_par14 == 2 .And. SB2->B2_QATU == 0
		(cAliasSQL)->(dbSkip())
		Loop
	EndIf

	lRastro  := Rastro((cAliasSQL)->D3_COD)
	lRastroS := Rastro((cAliasSQL)->D3_COD, 'S')
	lCLocal  := Localiza((cAliasSQL)->D3_COD)
	cEnd	 := (cAliasSQL)->D3_LOCALIZ
	cNumSeri := (cAliasSQL)->D3_NUMSERI
	cLoteCtl := (cAliasSQL)->D3_LOTECTL
	cNumLote := (cAliasSQL)->D3_NUMLOTE     
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o SD3 nao possuir as informacoes de endereco busco no SDB ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   	
	If lCLocal .And. Empty(cEnd) .And. SDB->(DbSeek(xFilial("SDB")+(cAliasSQL)->(D3_COD+D3_LOCAL+D3_NUMSEQ)))
		cEnd 		:= SDB->DB_LOCALIZ
		cNumSeri	:= SDB->DB_NUMSERI
		cLoteCtl	:= SDB->DB_LOTECTL
		cNumLote	:= SDB->DB_NUMLOTE	 
	ElseIf !lCLocal .And. lRastro .And. Empty(cLoteCtl+cNumLote) .And. SD5->(DbSeek(xFilial("SD5")+(cAliasSQL)->(D3_NUMSEQ+D3_COD+D3_LOCAL)))	
		cLoteCtl	:= SD5->D5_LOTECTL
		cNumLote	:= SD5->D5_NUMLOTE
	EndIf  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz distinct manual utilizando array temporario              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If Empty( AsCan(aLstPrint,{|x|x == (cAliasSQL)->(D3_COD+D3_LOCAL)+cEnd+cNumSeri+cLoteCtl+cNumLote}) ) 
		Aadd( aLstPrint,(cAliasSQL)->(D3_COD+D3_LOCAL)+cEnd+cNumSeri+cLoteCtl+cNumLote )     
	Else
		(cAliasSQL)->(dbSkip())
		Loop	
	EndIf
	
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,wnRel,Tamanho,nTipo)
		nLin := 9
	EndIf                                                       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao de Detalhamento.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nLin, 000 PSAY Left((cAliasSQL)->D3_COD    , 15)
	@ nLin, 016 PSAY Left((cAliasSQL)->D3_TIPO   , 02)
	@ nLin, 019 PSAY Left((cAliasSQL)->D3_GRUPO  , 04)
	@ nLin, 025 PSAY Left(SB1->B1_DESC   , 30)
	@ nLin, 057 PSAY Left((cAliasSQL)->D3_UM     , 02)
	@ nLin, 061 PSAY Left((cAliasSQL)->D3_LOCAL  , 02)
	 
	If lCLocal           
		@ nLin, 066 PSAY Left(cEnd, 15) 
	EndIf
	If lImpLote
		If lCLocal   
	   		@ nLin, 103 PSAY Left(cNumSeri, 14) + " " 
		EndIf		
		If lRastro       
			@ nLin, 083 PSAY Left(cLoteCtl,10)
			@ nLin, 095 PSAY If(lRastroS,Left(cNumLote,06),'')+" " 			
		EndIf 
		@ nLin, 130 PSAY cDet
	Else
		@ nLin, 84 PSAY cDet
	EndIf  
	
	nLin++ 
	
	(cAliasSQL)->(dbSkip())	 
EndDo

dbSelectArea(cAliasSQL)
dbCloseArea()               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
dbClearFilter()    

RestArea(aAreaSB2)
RestArea(aAreaSD3)

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnRel)
Endif

MS_FLUSH()

Return Nil                                   


Static Function AjustaSX1()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui pergunta no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
//       1        2         3                             4                                5                               6      7     8  9 0  1   2    3   4   5   6               7       8       9       0                   1      2        3       4  5  6  7  8  9  0   1  2
PutSX1("PCP003","01","Armazem  de ?	                ","?De Deposito ?	             ","From Warehouse ?	          ","mv_ch1","C",	2 ,0,0,"G","","   ","","","mv_alm_de"		,""		,""		,""		,"01"				,""		,""		,""		,"","","","","","","","","",{},{},{})				
PutSX1("PCP003","02","Armazem ate ?	                ","?A Deposito ?	             ","To Warehouse ?	              ","mv_ch2","C",	2 ,0,0,"G","","   ","","","mv_alm_ate"	,""		,""		,""		,"ZZ"				,""		,""		,""		,"","","","","","","","","",{},{},{})				
PutSX1("PCP003","03","Produto de ?	                ","?De Producto ?	             ","From Product ?	              ","mv_ch3","C",	15,0,0,"G","","SB1","","","mv_prod_de"	,""		,""		,""		,Space(15)			,""		,""		,""		,"","","","","","","","","",{},{},{})				
PutSX1("PCP003","04","Produto ate ?	                ","?A Producto ?	             ","To Product ? 	              ","mv_ch4","C",	15,0,0,"G","","SB1","","","mv_prod_ate"	,""		,""		,""		,"ZZZZZZZZZZZZZZZ"	,""		,""		,""		,"","","","","","","","","",{},{},{})			
PutSX1("PCP003","05","Tipo de ?	                    ","?De Tipo ?                    ","From Type ?	                  ","mv_ch5","C",	2 ,0,0,"G","","   ","","","mv_tipo_de"	,""		,""		,""		,Space(2)			,""		,""		,""		,"","","","","","","","","",{},{},{})				
PutSX1("PCP003","06","Tipo ate ?	                ","?A Tipo ?	                 ","To Type ?	                  ","mv_ch6","C",	2 ,0,0,"G","","   ","","","mv_tipo_ate"	,""		,""		,""		,"ZZ"				,""		,""		,""		,"","","","","","","","","",{},{},{})				
PutSX1("PCP003","07","Grupo de ?	                ","?De Grupo ?	                 ","From Group ?	              ","mv_ch7","C",	4 ,0,0,"G","","   ","","","mv_grupo_de"	,""		,""		,""		,Space(4)			,""		,""		,""		,"","","","","","","","","",{},{},{})				
PutSX1("PCP003","08","Grupo ate ?	                ","?A Grupo ?	                 ","To Group ?	                  ","mv_ch8","C",	4 ,0,0,"G","","   ","","","mv_grupo_ate"	,""		,""		,""		,"ZZZZ"				,""		,""		,""		,"","","","","","","","","",{},{},{})				
PutSX1("PCP003","09","Data Selecao de ?	            ","?A Fecha Seleccion ?	         ","From Selection Date ?	      ","mv_ch9","D",	8 ,0,0,"G","","   ","","","mv_Sel_de"		,""		,""		,""		,"01/01/06"			,""		,""		,""		,"","","","","","","","","",{},{},{})				
PutSX1("PCP003","10","Data Selecao ate ?	        ","?A Fecha Seleccion ?	         ","To Selection Date ?	          ","mv_cha","D",	8 ,0,0,"G","","   ","","","mv_Sel_ate"	,""		,""		,""		,"31/12/49"			,""		,""		,""		,"","","","","","","","","",{},{},{})
PutSX1("PCP003","11","Da Op ?	                    ","?De O. P. ?	                 ","From Product.Order ?	      ","mv_chb","C",	13,0,0,"G","","SC2","","","mv_par11"		,""		,""		,""		,Space(13)			,""		,""		,""		,"","","","","","","","","",{},{},{})	
PutSX1("PCP003","12","Ate Op?	                    ","?A O. P. ?	                 ","To Production Order ?	      ","mv_chc","C",	13,0,0,"G","","SC2","","","mv_par12"		,""		,""		,""		,"ZZZZZZZZZZZZZ"	,""		,""		,""		,"","","","","","","","","",{},{},{}) 		
PutSX1("PCP003","13","Impr.Lote/S.Lote/NS ?	        ","?Impr.Lot/S.Lote/NS ?	     ","Print Lot/S.Lot/NS ?	      ","mv_chd","N",	1 ,0,1,"C","","   ","","","mv_par13"		,"Sim"	,"Si"	,"Yes"	,""					,"Nao"	,"No"	,"No"	,"","","","","","","","","",{},{},{})      
PutSX1("PCP003","14","Lista Prod. Com Saldo Zerado ?","Lista Prod. Con Saldo Nulo ?  ","Cons. Prod. With Stock Zero ? ","mv_che","N",   1 ,0,0,"C","","  ","","","mv_par14"		,"Sim"	,"Si"	,"Yes"	,""					,"Nao"	,"No"	,"No"	,"","","","","","","","","",{"Considera o produto com saldo zerado na","filtragem do cadastro de saldos (SB2)."},{"Consider the product with zeroed balance","in filtering the balances file (SB2)."},{"Considera el producto con saldo cero en","el filtro del archivo de saldos (SB2)."})
PutSX1("PCP003","15","Imprime produtos que geram Op?","Imprime produtos que geram Op?","Imprime produtos que geram Op?","mv_chf","N",   1 ,0,2,"C","","  ","","","mv_par15"		,"Sim"	,"Si"	,"Yes"	,""					,"Nao"	,"No"	,"No"	,"","","","","","","","","",{"Considera o produto que possuem movimen","tacao de producao na listagem.        "},{"Considera o produto que possuem movimen","tacao de producao na listagem.        "},{"Considera o produto que possuem movimen","tacao de producao na listagem.        "})
Return