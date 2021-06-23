#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

// ADORO\LOGISTICA\PEDFAT
// RELACAO DE PEDIDOS DE VENDA DIARIOS
// SOLICITADO PELA GERENCIA DE LOGISTICA E SUPRIMENTOS
// RAFAEL HENRIQUE DA SILVEIRA, 31/07/2007

USER FUNCTION PEDFAT

Private _AAREA			:= GETAREA()
Private CPERG   		:= "PEDFAT"
Private CSTRING
Private AORD 			:= {}
Private TITULO 		:= "Conferencia Recebimento Canhotos"
Private CDESC1 		:= "Este programa tem como objetivo imprimir relatorio"
Private CDESC2 		:= "para conferencia de recebimento de canhotos"
Private CDESC3 		:= ""
Private LEND 			:= .F.
Private LABORTPRINT 	:= .F.
Private LIMITE 		:= 132
Private TAMANHO 		:= "M"
Private NOMEPROG 		:= "PEDFAT.PRW"
Private NTIPO 			:= 18
Private ARETURN 		:= { "ZEBRADO", 1, "ADMINISTRACAO",2,2, 1, "",1}
Private NLASTKEY 		:= 0
Private NLIN 			:=8
Private WNREL 			:= "PEDFAT"
Private M_PAG 			:= 01
Private C6PED           := ""

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RELACAO DE PEDIDOS DE VENDA DIARIOS')
                                                     
CABEC1 := "PEDIDO   CLIENTE                           CIDADE           ROT   ENTREGA    PLACA     NF"
CABEC2 := Space(56)

Pergunte(CPERG,.F.)

WNREL := SetPrint(CSTRING,WNREL,CPERG,TITULO,CDESC1,CDESC2,CDESC3,.T.,AORD ,.T.,TAMANHO,,.T.)

If NLASTKEY == 27
	Return()
EndIf

SetDefault(ARETURN,CSTRING)

If NLASTKEY == 27
	Return()
EndIf

NTIPO := If(ARETURN[4]==1,15,18)

RptStatus({|| RUNREPORT(CABEC1,CABEC2,TITULO,NLIN) },TITULO)

Return()


Static Function RunReport(CABEC1,CABEC2,TITULO,NLIN)

Local cQuery	:= ""

SetRegua(RecCount())

If MV_PAR07 = 1
	SNPAR:=""
Else
	SNPAR:="AND C5_NOTA <> '' "
EndIf

cQuery	:=	"SELECT C5_FILIAL FILIAL, C5_NUM PEDIDO, C5_CLIENTE+'-'+C5_LOJACLI+':'+C5_NOMECLI CLIENTE, "
cQuery	+=	"C5_ROTEIRO ROTEIRO, C5_DTENTR ENTREGA, C5_PLACA PLACA, C5_CIDADE CIDADE, "
cQuery	+=	"CASE WHEN C5_NOTA <> '' THEN C5_NOTA+'-'+C5_SERIE ELSE "
cQuery	+=	"(CASE WHEN MAX(C6_NOTA) = '' THEN 'NAO' ELSE 'PARCIAL' END) END AS SITUACAO "
cQuery	+=	"FROM "	+	RetSqlName("SC5")	+	", "	+	RetSqlName("SC6")	+	" "
cQuery	+=	"WHERE C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "
cQuery	+=	"AND C5_FILIAL BETWEEN '"	+		MV_PAR01			+"' AND '"	+	MV_PAR02				+"' "
cQuery	+=	"AND C5_ROTEIRO BETWEEN '"	+		MV_PAR03			+"' AND '"	+	MV_PAR04				+"' "
cQuery	+=	"AND C5_DTENTR BETWEEN '"	+		DTOS(MV_PAR05)	+"' AND '"	+	DTOS(MV_PAR06)		+"' "
cQuery	+=	"AND "	+	RetSqlName("SC5")	+	".D_E_L_E_T_ = '' AND "		+	RetSqlName("SC6")	+".D_E_L_E_T_ = '' "
cQuery	+=	SNPAR
cQuery	+=	"GROUP BY C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI, C5_ROTEIRO, C5_DTENTR, C5_PLACA, C5_CIDADE, "
cQuery	+=	"C5_NOTA, C5_SERIE ORDER BY ROTEIRO "

TcQuery cQuery New Alias "TEMP"
TEMP->(dbGoTop())

dbSelectArea("TEMP")

CABEC(TITULO,CABEC1,CABEC2,WNREL,TAMANHO,nLIN)

While TEMP->(!EOF())

	@ nLin, 00 PSAY PEDIDO
	@ nLin, 09 PSAY CLIENTE
	@ nLin, 43 PSAY CIDADE
	@ nLin, 60 PSAY ROTEIRO       //43
	@ nLin, 66 PSAY STOD(ENTREGA) //49
	@ nLin, 77 PSAY PLACA         //60
	@ nLin, 87 PSAY SITUACAO      //70
	
	If MV_PAR08 = 1  
		nLin:=nLin+1
		C6PED:=TEMP->PEDIDO
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek(XFILIAL("SC6")+C6PED)
		
			While SC6->(!EOF()) .AND. XFILIAL("SC6")+C6_NUM = XFILIAL("SC5")+C6PED
				
				@ nLin, 03 PSAY SUBSTRING((ALLTRIM(C6_PRODUTO)+'-'+ALLTRIM(C6_DESCRI)),1,43)
				@ nLin, 46 PSAY TRANSFORM(C6_UNSVEN,'@E 999,999')
				@ nLin, 54 PSAY ALLTRIM(C6_SEGUM)
				@ nLin, 57 PSAY TRANSFORM(C6_QTDVEN,'@E 999,999')
				@ nLin, 65 PSAY ALLTRIM(C6_UM)
				If !Empty(C6_NOTA)
					@ nLin, 70 PSAY 'FATURADO'
				ELSE
					@ nLin, 70 PSAY 'NAO FATURADO'
				EndIf
				
				nLin++
				If nLin > 63 
					CABEC(TITULO,CABEC1,CABEC2,WNREL,TAMANHO,NTIPO)
					nLin := 8
				EndIf
				SC6->(dbSkip())
			EndDo

		EndIf
		dbSelectArea("TEMP")
	EndIf

	nLin++

	If nLin > 63 
		CABEC(TITULO,CABEC1,CABEC2,WNREL,TAMANHO,NTIPO)
		nLin := 8
	EndIf
	dbSkip()

EndDo

dbCloseArea("TEMP")

Set Device To Screen

If Areturn[5]==1
	DBCOMMITALL()
	Set Printer To
	OurSpool(WNREL)
EndIf

MS_FLUSH()
RestArea(_AAREA)

Return()