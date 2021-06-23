#INCLUDE "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAD0023    บ Autor ณ AP5 IDE            บ Data ณ  24/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Emissao da relacao de devolucoes em determinado periodo    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
//Manutencao Daniel Pitthan Silveira 06/02/07


User Function AD0023  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cPerg   := "DEVOL3"
If !Pergunte(cPerg,.T.)
	Return
EndIf

Private cString
Private CbTxt        := ""
cDesc1         := "Este programa tem como objetivo imprimir relatorio "
cDesc2         := "de ocorrencias de devolucoes"
cDesc3         := "Relatorio Diario de Devolucoes"
cPict          := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "AD0023.PRW" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao",2,2, 1, "",1}
Private nLastKey        := 0
titulo       := "Devolucoes Diarias"
nLin         :=0
aOrd := {}
_cCont:=0  
_nQtdeDevol:=0
_nQtdeSaida:=0
_dt1:=dtos(mv_par01)
_dt2:=dtos(mv_par02)

Cabec1       := "Periodo De "+substr(_dt1,7,2)+"/"+substr(_dt1,5,2)+"/"+substr(_dt1,1,4)+" Ate ";
+substr(_dt2,7,2)+"/"+ substr(_dt2,5,2)+"/"+substr(_dt2,1,4)+Space(25)+"       Numero"+Space(53)+"Quantidade"
Cabec2 := "Vendedor     Cliente                             Placa        Pedido   Documento                Produtos                       Saida    Devolvido         Motivo                      Responsavel        "

Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
imprime      := .T.
Private wnrel      := "AD0023" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SZD"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd ,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP5 IDE            บ Data ณ  24/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


SetRegua(RecCount())

aStru:={}

// INICIO DO FILTRO POR VENDEDOR - RAFAEL H SILVEIRA 27/04/2006
_cUserName  := Subs(cUsuario,7,15)  // Nome do Usuario

    REGRA:=''
    CONDICAO:=''

	dbSelectArea("SZR")
	dbSetOrder(2)            // ZR_FILIAL+ZR_DESCRIC
	If dbSeek( xFilial("SZR")+_cUserName )
    REGRA:= ALLTRIM(ZR_CODIGO)+"' "
	CONDICAO:= " AND ZR_CODIGO = '"
    else
 	dbSelectArea("SA3")
	DbSetOrder(2)
	If dbSeek( xFilial("SA3")+_cUserName )
		REGRA:= ALLTRIM(A3_COD)+"' "
		CONDICAO:= " AND ZD_VEND = '"
	ENDIF
	dbclosearea("SA3")
	endif
	dbclosearea("SZR")
// FIM DO FILTRO POR VENDEDOR - RAFAEL H SILVEIRA 27/04/2006



cQuery1:=" SELECT ZD_CODCLI ,ZD_LOJA , ZD_NOMECLI, ZD_PLACA ,ZD_FILIAL ,ZD_NUMNF, 
cQuery1+=" ZD_SERIE,ZD_PEDIDO, ZD_MOTIVO, ZD_DESCMOT, ZD_RESPONS, ZD_RESPNOM, "
cQuery1+=" D2_EMISSAO "
cQuery1+=" D2_COD,D2_CLIENTE,D2_LOJA,D2_DOC , D2_EMISSAO , D2_GRUPO , D2_QTDEDEV , D2_VALDEV, "
cQuery1+=" ZX_CODPROD, ZX_DESCRIC, ZX_QTSEGUM, ZX_QTDEV1U,ZD_VEND,ZX_QTDE "          
cQuery1+=" FROM " +retsqlname("SZD")+","+retsqlname("SZX")+","+retsqlname("SD2") "
cQuery1+=" WHERE  "                       

//DANIEL 06/02/07
If MV_PAR05=2 //DATA DE DIGITACAO/DATA DE EMISSAO 
	cQuery1+=" ZD_DTDEV between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "
Else 
	cQuery1+=" D2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "
EndIF	
//FIM
cQuery1+=" and "+retsqlname("SZD")+".ZD_SERIE  ="+retsqlname("SZX")+".ZX_SERIE "
cQuery1+=" and "+retsqlname("SZD")+".D_E_L_E_T_= '' AND  "+retsqlname("SZD")+".ZD_NUMNF ="+retsqlname("SZX")+".ZX_NF " 
cQuery1+=" and "+retsqlname("SZX")+".D_E_L_E_T_= '' "
cQuery1+=" and "+retsqlname("SZX")+".ZX_NF      = D2_DOC "
cQuery1+=" and "+retsqlname("SZX")+".ZX_SERIE   = D2_SERIE "
cQuery1+=" and "+retsqlname("SZX")+".ZX_CODPROD = D2_COD " 
cQuery1+=" and ZD_DEVTOT IN ('T','O','P') "
cQuery1+=" ORDER BY ZD_PEDIDO"   

TCQUERY cQuery1 new alias "TMP1"
dbSelectArea("TMP1")
TMP1->(dbgotop()) 
Processa( {|| Procx()},"Aguarde ...","Gerando Dados....")

Return

Static Function ProcX()
ProcRegua(RecCount())           
//grupo de produtos
_cGrupo:=''

While !EOF()  


	// Substituir pelo campo do SD2
	_cProduto := alltrim(TMP1->ZX_CODPROD)
	
	//DANIEL 06/02/07
	//busca grupo de produtos 
	DbSelectArea("SB1")	
	DbSetOrder(1)
	IF DbSeek(xFilial("SB1")+_cProduto,.t.)
		_cGrupo:=B1_GRUPO
	Else                
		_cGrupo:=''
	EndIf    
	//FIM    
	dbSelectArea("TMP1")
	If _cGrupo>=MV_PAR03 .and.  _cGrupo<=MV_PAR04
	   	IncProc(_cGrupo+" "+ZD_CODCLI+" "+ZD_DESCMOT)
			aadd(aStru,	{ZD_CODCLI						,;
							SUBSTR(ZD_NOMECLI,1,20)		,;
							ZD_PLACA							,;
							ZD_NUMNF							,;
							ZD_PEDIDO						,;
							SUBSTR(ZD_MOTIVO,1,2)		,;
							ZD_DESCMOT						,;
							SUBSTR(ZD_RESPONS,1,2)		,;
							ZD_RESPNOM						,;
							SUBSTR(ZX_CODPROD,1,10)		,;
							SUBSTR(ZX_DESCRIC,1,30)		,;
							ZX_QTDE							,;     
							D2_QTDEDEV						,;  
							ZD_VEND})                  
	EndIf
								
	dbskip()
Enddo

DbCloseArea("TMP1")
//Imprimindo
Impx()

Return

Static Function Impx()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica o cancelamento pelo usuario...                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If lAbortPrint
	@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao do cabecalho do relatorio. . .                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

nLin:=8

Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

nLin++ 

_cPedido:=""

//IMPRIMINDO
For _I:=1 to len(aStru)

    If _cPedido != aStru[_I][4]
	  	nLin++
	   @nlin,001 PSAY aStru[_I][14]   //VENDEDOR
		@nlin,015 PSAY aStru[_I][1]   //COD CLI
		@nlin,024 PSAY aStru[_I][2]   // NOME CLI
		@nlin,050 PSAY aStru[_I][3]   //PLACA
		@nlin,062 PSAY aStru[_I][5]   //PED
		@nlin,072 PSAY aStru[_I][4]   //DOC
  
    	_cCont++
    Endif

	
	@nlin,083 PSAY aStru[_I][10]  //COD PRO
	@nlin,093 PSAY aStru[_I][11]  //DESC PRO
	@nlin,130 PSAY aStru[_I][12]  //QTDE SAIDA
	@nlin,140 PSAY aStru[_I][13] //QTDE DEVOL 
	
	_nQtdeSaida+= aStru[_I][12]
	_nQtdeDevol+= aStru[_I][13]

    If _cPedido != aStru[_I][4]	
		@nlin,153 PSAY aStru[_I][6]  //COD MOTIVO
		@nlin,157 PSAY aStru[_I][7] //DESC MOTIVO
		@nlin,182 PSAY aStru[_I][8] //COD REP
		@nlin,186 PSAY aStru[_I][9] //DESC REP   
	Endif
		
	_cPedido:=	aStru[_I][4]
	nLin++
	
	If nLin > 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)		
		nLin := 8
	Endif
	
Next 

nLin++
@nLin,000 PSAY REPL("_",190)
nLin++
@nLin,000 PSAY 	"Total de Ocorrencias: "+str(_cCont)
@nLin,130 PSAY  	_nQtdeSaida
@nLin,140 PSAY 	_nQtdeDevol

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()


Return
