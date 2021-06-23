#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAD0179    บ Autor ณ DANIEL             บ Data ณ  24/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO DE OCORRENCIAS DE DEVOLUCOES                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOGISTICA/ATENDIMENTO                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function AD0179


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Consultas de Ocorrencias"
Local cPict          := ""
Local titulo       := "Consultas de Ocorrencias"
Local nLin         := 80

Local Cabec1       := ""
Local Cabec2       := "Relatorio de Ocorrencias"
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 132
Private tamanho          := "G"
Private nomeprog         := "AD0179" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey        := 0
Private cPerg       := "AD0179"
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "AD0179"+DTOS(DDATABASE) // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := ""     

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RELATORIO DE OCORRENCIAS DE DEVOLUCOES')

NOMEEMP:=''
DBSELECTAREA("SM0")
NOMEEMP:=M0_NOMECOM
Cabec1			 := NOMEEMP

pergunte(cPerg,.F.)


/*
MV_PAR01 CLIENTE INI
MV_PAR02 CLIENTE FIM
MV_PAR03 DATA INI
MV_PAR04 DATA FIM
MV_PAR05 MOTIVO
MV_PAR06 RESPONSAVEL              


MV_PAR11 1 = NAO QUEBRA/ 2 = QUEBRA

*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  24/04/06   บฑฑ
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

Local nOrdem              
Local lQuebra := (MV_PAR11 == 2)



_zxfnd:=.T.
_cObserv:=''

//*********
cQuery:= " SELECT * FROM "+RetSqlName("SZD")+ " WHERE "
cQuery+= " ZD_CODCLI >= '"+MV_PAR01+"' And  ZD_CODCLI <= '"+MV_PAR02+"' "
cQuery+= " AND (ZD_DTDEV BETWEEN '"+ dtos(MV_PAR03) +"' AND  '"+dtos(MV_PAR04) +"') "
cQuery+= " AND (ZD_MOTIVO>='"+MV_PAR05+"'  AND ZD_MOTIVO<='"+MV_PAR06+"')"
cQuery+= " AND (ZD_RESPONS>='"+MV_PAR07+"' AND ZD_RESPONS<='"+MV_PAR08+"')"
cQuery+= " AND (ZD_VEND>='"+MV_PAR09+"'    AND ZD_VEND<='"+MV_PAR10+"')"
IF !lQuebra  // NAO DEMONSRA QUEBRA
	cQuery+= " AND (ZD_DEVTOT <> 'Q' )  "
ENDIF

TCQUERY cQuery new alias "DEV1"
DBSELECTAREA ("DEV1")


//*******

DBGOTOP()
WHILE !EOF() //.And. (ZD_CODCLI>=MV_PAR01 .And. ZD_CODCLI<=MV_PAR02);
	//.AND. (ZD_DTDEV>=MV_PAR03 .AND. ZD_DTDEV<=MV_PAR04);
	//.AND. (ZD_MOTIVO=MV_PAR05)
	
	//IF 		 (ZD_CODCLI>=MV_PAR01 .And. ZD_CODCLI<=MV_PAR02);
	//         .AND. (ZD_DTDEV>=MV_PAR03 .AND. ZD_DTDEV<=MV_PAR04);
	//		 .AND. (ZD_MOTIVO>=MV_PAR05 .AND. ZD_MOTIVO<=MV_PAR06);
	//		 .AND. (ZD_RESPONS>=MV_PAR07 .AND. ZD_RESPONS<=MV_PAR08)
	
	_cMotivo     :=DEV1->ZD_MOTIVO   //MOTIVO
	_cCodRespons :=DEV1->ZD_RESPONS  //responsavel
	_cNresp      :=DEV1->ZD_RESPNOM	//NOME DO RESPONSAVEL
	_cUsuario    :=DEV1->ZD_AUTNOME  //Autorisante
	_OBS1        :=DEV1->ZD_OBS1		//OBS 1
	
	_cCodCli	 :=DEV1->ZD_CODCLI   //CODIGO DO CLIENTE
	_Ped		 :=DEV1->ZD_PEDIDO	 //PEDIDO
	_cNumNf      :=DEV1->ZD_NUMNF	 //NF
	_cSerie      :=DEV1->ZD_SERIE	 //SERIE
	_cplac       :=DEV1->ZD_PLACA    //PLACA
	_CODCLI		 :=DEV1->ZD_CODCLI   //CLIENTE
	
	//else
	//	DBSKIP()
	//  	loop
	//endif
	
	
	DBSELECTAREA("SA1")
	DBSETORDER(1)
	IF DBSEEK(xFilial("SA1")+_CODCLI,.T.)
		_cNomCli     :=SA1->A1_NOME  //Cliente
	ELSE
		
		_cNomCli:=''
	ENDIF
	
	
	IF EMPTY(ALLTRIM(_cNresp))
		_cNresp:=""
	ENDIF
	
	/*MONTANDO CABECALHO*/
	_cObserv+=CHR(13)
	_cObserv+="RESPONSAVEL: "+_cCodRespons+" - "+_cNresp+" PLACA: "+_cPlac
	_cObserv+=" PEDIDO :"+_Ped
	_cObserv+=CHR(13)
	_cObserv+=" Cliente:"+_CODCLI+" "+_cNomCli
	_cObserv+=CHR(13)
	/*PROCURANDO OBS NOS DETALHES */
	DbSelectArea("SZD")
	DbsetOrder(1)
	
	IF dbSeek(xfilial("SZD")+alltrim(_cNumNf)+alltrim(_cSerie),.T.)
		
		_cObs_Mn := SZD->ZD_OBSHST
		/*OBS*/
		_nTam :=1
		DO While _nTam <= len(alltrim(_cObs_Mn))
			_cObserv+= SUBSTR(_cObs_Mn,_nTam,79)
			_cObserv+=CHR(13)			
			_nTam :=_nTam+79
		End
	Endif
	DBSELECTAREA ("SZD")
	/*CABEC DO DETALHE*/
	_cObserv+=CHR(13)
	_cObserv+="+------------------------------------------------------------------------------------+"
	_cObserv+=CHR(13)
	_cObserv+="|                                   DETALHE DA NOTA                                  |"
	_cObserv+=CHR(13)
	_cObserv+="+------------------------------------------------------------------------------------+"
	_cObserv+=CHR(13)
	
	/*PROCURANDO OBS NOS DETALHES */
	DbSelectArea("SZX")
	DbsetOrder(1)
	
	IF dbSeek(xfilial("SZX")+alltrim(_cNumNf)+alltrim(_cSerie),.T.)
		WHILE !EOF() .AND. (ZX_NF=_cNumNf) .AND. (ZX_SERIE=_cSerie)
			_cObserv+=CHR(13)
			_cObserv+="PRODUTO: "+SUBSTR(ZX_CODPROD,1,10)+ZX_DESCRIC
			//_cObserv+=CHR(13)
			_cObserv+=" ENTR.: "+STR(ZX_QTDE,6)+" "+ZX_UNIDADE+" DEVOL.:"+STR(ZX_QTDEV1U,6)+" "+ZX_UNIDADE
			IF lQuebra  .AND. ZX_QUEBRA > 0 
				_cObserv+= " QUEBRA: "+TRANSFORM(ZX_QUEBRA,"@E 999.999,99999")
			Endif
			_cObserv+=CHR(13)
			_cObserv+="OBS:"
			_cObserv+=CHR(13)
			_cObserv+=ZX_OBSER
			_zxfnd:=.T.
			DBSKIP()
		ENDDO
		
	ENDIF
	_cObserv+="+------------------------------------------------------------------------------------+"
	_cObserv+=CHR(13)
	
	//*SE NNAO OBS NOS DETALHES*//
	if _zxfnd=.F.
		_cObserv+=CHR(13)
		_cObserv+="***SEM OCORRENCIA NOS DETALHES DESTA NF***"
		_cObserv+=CHR(13)
	endif
	dbselectarea("DEV1")
	DBSKIP()
ENDDO
DBSELECTAREA("DEV1")                     //VOLTANDO PARA AREA ANTERIOR
DBCLOSEAREA("DEV1")                     //FECHANDO AREA


/*IMPRIMINDO*/


I:=0
texto:=''
txt:=''

/*
Trocando as quebras de linha por *, as quebras de linha sao utilizadas na exibicao do campo memo
com isso transformo numa string unica
*/    

TxtNew:=STRTRAN(_cObserv,CHR(13),"*")

for I:=0 to LEN(TxtNew)
	TEXTO+=SUBSTR(TxtNew,1,1)
	txt:=SUBSTR(TxtNew,1,1)
	TxtNew:=STUFF(TxtNew,1,1,"")
	
	if 	txt=="*"
		If nLin > 60 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin :=10
		Endif
		if texto<>"*"
			TEXTO:=SUBSTR(TEXTO,1,LEN(TEXTO)-1)
			@ nlin,000 Psay TEXTO
			TEXTO:=""
			nlin++
		else
			texto:=""
			nlin++
		endif
	endif
next

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