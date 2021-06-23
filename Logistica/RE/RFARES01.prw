#INCLUDE "rwmake.ch"           
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATLOG01  º Autor ³ DANIEL             º Data ³  06/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ESTE RELATORIO IMPRIME O RESUMO DE CARREGAMENTO             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOGISTICA                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RFARES01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Resumo de Carregamento"
Local cPict          := ""
Local titulo       := "Resumo de Carregamento"
Local nLin         := 80

Local Cabec1       := "Logística"
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 220
Private tamanho          := "M"
Private nomeprog         := "RFARES01" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RFARES01" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := ""

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

Pergunte("RFARES",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,"RFARES",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  06/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//SetRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VARIAVEIS                                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//+----------------+
//|TOTAIS          |
//+----------------+
TtCx	:=0		//Total de Caixas
TtPesLi	:=0 	//Total de Peso Liquido
Ttbrt 	:=0		//Total de Peso Bruto   
TgCx	:=0		//Total de Caixas
TgPesLi	:=0 	//Total de Peso Liquido
Tgbrt 	:=0		//Total de Peso Bruto   

//+------------------------+
//|DADOS 				   |
//+------------------------+
nTara	:=0		//Tara da Unidade
PPrut	:=0		//Peso Bruto    
nQbr	:=0		//Guarda o Roteiro Anterior   
dtaCabec:=''	//Data do Cabecalho           
//+------------------+
//|TESTE LOGICOS     |
//+------------------+
lQbr:=.F.		//Teste de Quebra
lLoop:=.F.		//Testa se entrou no Loop 
lVez:=.T.		//Primeira Vez

	
//LAY-OUT
/*
+------------------------------------------------------------------------------------------------------------------------------------+
|ROTEIRO NUMERO 920                Data Entrega : 29/11/06                           PLACA VEICULO : LAY9147                         |
+------------------------------------------------------------------------------------------------------------------------------------+ 
|Produto         Descricao do Produto                                  Qtde        Peso       Peso                                   |
|                                                                       Cx        Liquido     Bruto                                  |
+------------------------------------------------------------------------------------------------------------------------------------+
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
0 
+------------------------------------------------------------------------------------------------------------------------------------+
|INICIO:                                                               TERMINO:                                                      |
+____________________________________________________________________________________________________________________________________+
|LACRES:      |                   |                   |                   |                   |                  |                   |
|             |                   |                   |                   |                   |                  |                   |
+___________ _|___________________|___________________|___________________|___________________|__________________|___________________+
|CONFERENTE:                                                                                                                         |
|                                                                                                                                    |
+------------------------------------------------------------------------------------------------------------------------------------+
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
0         1         2         3         4         5         6         7         8         9        10        11        12        13        14
*/
Cabec4:='+------------------------------------------------------------------------------------------------------------------------------------+'
Cabec6:='|Produto         Descricao do Produto                                  Qtde        Peso       Peso                                   |'
Cabec7:='|                                                                       Cx        Liquido     Bruto                                  |'

cabec10:='|INICIO:                                                               TERMINO:                                                      |'
cabec11:='+____________________________________________________________________________________________________________________________________+'
cabec12:='|LACRES:      |                   |                   |                   |                   |                  |                   |'
cabec13:='|             |                   |                   |                   |                   |                  |                   |'
cabec14:='+_____________|___________________|___________________|___________________|___________________|__________________|___________________+'
cabec15:='|CONFERENTE:                                                                                                                         |'
cabec16:='|                                                                                                                                    |'



//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//0         1         2         3         4         5         6         7         8         9        10        11        12        13        14



   			

cQuery:=''
cQuery:=" SELECT "
cQuery+=" C6_NUM, "
cQuery+=" C6_NOTA, "
cQuery+=" C6_CLI, "
cQuery+=" C6_LOJA, "
cQuery+=" C5_PLACA, "
cQuery+=" C6_ENTREG, "
cQuery+=" C6_ITEM, "
cQuery+=" C6_PRODUTO, "
cQuery+=" C6_DESCRI, "
cQuery+=" C6_SEGUM, "
cQuery+=" C6_UNSVEN, "
cQuery+=" C6_UM, "
cQuery+=" C6_QTDVEN, "
cQuery+=" C6_ROTEIRO "
cQuery+=" FROM "	
cQuery+=" "+retsqlname("SC6")+" AS SC6 WITH(NOLOCK), "
cQuery+=" "+RETSQLNAME("SC5")+" AS SC5 WITH(NOLOCK) "
cQuery+=" WHERE "
cQuery+=" C5_NUM=C6_NUM "
cQuery+=" AND (C6_ROTEIRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"') "
cQuery+=" AND (C6_ENTREG BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"') "
cQuery+=" AND (C5_NOTA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
cQuery+=" AND C6_NOTA<>'' "
cQuery+=" AND C5_NOTA<>'' "
cQuery+=" AND SC6.D_E_L_E_T_='' "
cQuery+=" AND SC5.D_E_L_E_T_='' "          
//+-----------------------------+
//|ESCOLHENDO A ORDENACAO       |
//+-----------------------------+
DO CASE
      CASE MV_PAR07=1 						
      	cQuery+=" ORDER BY C6_ROTEIRO "
      CASE MV_PAR07=2
   		cQuery+=" ORDER BY C6_NOTA "
      CASE MV_PAR07=3
		cQuery+=" ORDER BY C6_NUM "      
      CASE MV_PAR07=4
		cQuery+=" ORDER BY C6_CLI "
      OTHERWISE
       	cQuery+=" ORDER BY C6_ROTEIRO "
ENDCASE
TCQUERY cQuery NEW ALIAS "TMP1"	

DBSELECTAREA("TMP1")	
dbGoTop()
While !EOF()
    
  	//VERIFICANDO A PRIMEIRA VEZ
	If lVez
	     lLoop:=.T.		//Flag para verificar se ha dados a ser impresso
	     lVez:=.F.
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
    
   DtaCabec:=SUBSTR (C6_ENTREG,7,2)+ "/" + SUBSTR (C6_ENTREG,5,2) +"/"+ SUBSTR (C6_ENTREG,1,4)

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
      @nlin,000 PSAY CABEC4; NLIN++ 
      @nlin,000 PSAY "|ROTEIRO NUMERO: "+C6_ROTEIRO+"               Data Entrega : "+DtaCabec+"                           PLACA VEICULO : "+C5_PLACA+"                       |"; NLIN++
      @nlin,000 PSAY CABEC4; NLIN++
      @nlin,000 PSAY CABEC6; NLIN++
      @nlin,000 PSAY CABEC7; NLIN++
      @nlin,000 PSAY CABEC4; NLIN++
   Endif
/*
+------------------------------------------------------------------------------------------------------------------------------------+
|ROTEIRO NUMERO 920                Data Entrega : 29/11/06                           PLACA VEICULO : LAY9147                         |
+------------------------------------------------------------------------------------------------------------------------------------+ 
|Produto         Descricao do Produto                                  Qtde        Peso       Peso                                   |
|                                                                       Cx        Liquido     Bruto                                  |
+------------------------------------------------------------------------------------------------------------------------------------+
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
0         1         2         3         4         5         6         7         8         9        10        11        12        13        14
*/
	@nLin,001 Psay C6_PRODUTO
	@nLin,018 Psay LEFT(C6_DESCRI,50)
	@nLin,070 Psay C6_UNSVEN PICTURE '@E 999,999.99'
	@nlIn,082 Psay C6_QTDVEN PICTURE '@E 999,999.99'
	
	//Calculando Peso Bruto
	dbSelectArea("SZC")
	dbSetOrder(1)
	If dbSeek(xFilial("SZC")+ TMP1->C6_SEGUM)
		nTara := ZC_TARA
	Endif                           
	DBSELECTAREA("TMP1")
	PBrut :=((C6_UNSVEN * nTara) + C6_QTDVEN)	
	
	@nLin,094 Psay PBrut Picture "@E 999,999.99"
	
	//Acumulando Valores
	Ttbrt 	+=PBrut 								//Total Bruto
	TtCx	+=C6_UNSVEN								//Total de Caixas
	TtPesLi	+=C6_QTDVEN								//Total de Peso Liquido

   	nLin++ 											// Avanca a linha de impressao
  
//+---------------------------+
//|SETANDO A QUEBRA DE PAGINA |  
//+---------------------------+
   DO CASE
      CASE MV_PAR08=1
      	nQbr:=C6_ROTEIRO
      CASE MV_PAR08=2
   		nQbr:=C6_NOTA
      OTHERWISE
      	nQbr:=C6_ROTEIRO
	ENDCASE                                                                                               

   dbSkip() 										// Avanca o ponteiro do registro no arquivo  
 
	
	DO CASE
      CASE MV_PAR08=1
      	lQbr:=nQbr<>C6_ROTEIRO						//QUEBRA POR ROTEIRO
      CASE MV_PAR08=2
   		lQbr:=nQbr<>C6_NOTA							//QUEBRA POR NOTA
      OTHERWISE
      	lQbr:=nQbr<>C6_ROTEIRO
	ENDCASE  
	  	
   	//----------------------------
   	//IMPRIMINDO TOTAL DA QUEBRA
   	//----------------------------
   	
   	//SE TROCOU O ROTEIRO FACO A QUEBRA DE PAGINA
   	If lQbr  
		@nLin,000 Psay cabec4; nlin++
		@nlin,000 Psay "|TOTAL "; @nlin,133 Psay "|"				
   		@nLin,070 Psay  TtCx	PICTURE '@E 999,999.99'
   		@nlin,082 Psay  TtPesli PICTURE '@E 999,999.99'
   		@nLin,094 Psay  Ttbrt	Picture "@E 999,999.99"
   		nLin++
		@nLin,000 Psay cabec4; nlin+=2  
		
	  	@nlin,000 PSAY CABEC4;  NLIN++
      	@nlin,000 PSAY CABEC10; NLIN++
     	@nlin,000 PSAY CABEC11; NLIN++
      	@nlin,000 PSAY CABEC12; NLIN++
      	@nlin,000 PSAY CABEC13; NLIN++
      	@nlin,000 PSAY CABEC14; NLIN++
      	@nlin,000 PSAY CABEC15; NLIN++
      	@nlin,000 PSAY CABEC16; NLIN++
      	@nlin,000 PSAY CABEC4; NLIN++		
		
		TgCx	+=TtCx		//Total GERAL de Caixas
		TgPesLi	+=TtPesLi 	//Total GERAL de Peso Liquido
		Tgbrt 	+=Ttbrt		//Total GERAL de Peso Bruto   
		
		TtCx	:=0		//Total de Caixas
		TtPesLi	:=0 	//Total de Peso Liquido
		Ttbrt 	:=0		//Total de Peso Bruto	
		dLin:=nLin
   		nLin:=999
	EndIf   		
EndDo   

//SE TEM DADOS 
If lLoop  	                   
		dlin+=2
   		@dLin,000 Psay cabec4; dlin++
		@dlin,000 Psay "|TOTAL GERAL "
   		@dLin,070 Psay  TGCx	PICTURE '@E 999,999.99'
   		@dlin,082 Psay  TGPesli PICTURE '@E 999,999.99'
   		@dLin,094 Psay  TGbrt	Picture "@E 999,999.99"
  		@dlin,133 Psay "|"
   		dLin++
		@dLin,000 Psay cabec4; nlin+=5  
EndIf 

DbCloseArea("TMP1")																	//Fecha area Selecionada
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
