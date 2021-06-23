#INCLUDE "MATR115.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ADEST025R � Autor � Ricardo Berti         � Data � 25.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controle de entregas das Solicitacoes ao Almoxarifado.     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR115()			                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum		                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function ADEST025R()  //relatorio ajustado para atender a demandas da adoro, apos migra��o para a versao 12

Local oReport

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Controle de entregas das Solicitacoes ao Almoxarifado.')

If TRepInUse()

	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef()
	oReport:PrintDialog()

EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Ricardo Berti 		� Data �25.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relatorio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ADEST025R                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport 
Local oSection
Local oSection2 
Local oCell         
Local cPerg	:= "MTR115"

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("MATR115",STR0001,cPerg, {|oReport| ReportPrint(oReport)},STR0002+" "+STR0003)  //"Controle de entrega das Solicitacoes ao Almox."##"  Este relatorio lista a posicao das Pre-Requisicoes geradas pelas"##"solicitacoes ao almoxarifado de acordo com parametros selecionados."
If !(TamSX3("B1_COD")[1] > 15)
	oReport:SetPortrait()  // sugere formato retrato
Else
	oReport:SetLandscape() // sugere formato paisagem
EndIf

//������������������������������������������������������������������������Ŀ
//� Verifica as Perguntas Selecionadas                                     �
//� mv_par01  -  Da data      ?                                            �
//� mv_par02  -  Ate a data   ?                                            �
//� mv_par03  -  Numero de    ?                                            �
//� mv_par04  -  Numero Ate   ?                                            �
//��������������������������������������������������������������������������
Pergunte(cPerg,.F.)

oSection := TRSection():New(oReport,STR0009,{"SCQ","SCP","SC1","DHN"}) // "Itens da pre-requisi��o"
oSection:SetHeaderPage()

TRCell():New(oSection,"CP_NUM"		,"SCP",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CP_ITEM"	    ,"SCP",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CQ_PRODUTO"	,"SCQ",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CQ_DESCRI"	,"SCQ",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CQ_DATPRF"	,"SCQ",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CP_QUANT"	,"SCP",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CP_QUJE"	    ,"SCP",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"DHN_DOCDES"	,"DHN",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"C1_PEDIDO"	,"SC1",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CP_CC"		,"SCP",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CP_SOLICIT"	,"SCP",/*Titulo*/,"@X"			,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"STATUS"	    ,"SCP",/*Titulo*/,"@X"			,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2 := TRSection():New(oReport,"Documentos Gerados por pre-requisi��o",{"DHN","SCP"}) //"Documentos Gerados por pre-requisi��o"

TRCell():New(oSection2,"CP_NUM"		,"SCP",/*Titulo*/,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"CP_ITEM"	,"SCP"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"CP_PRODUTO","SCP"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"CP_DESCRI"	,"SCP"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DHN_TIPO"	,"DHN"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DHN_DOCDES","DHN"	,/*Titulo*/	,/*Picture*/,10/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DHN_ITDES"	,"DHN"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DHN_QTDATE","DHN"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DHN_QTDTOT","DHN"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor � Ricardo Berti 		� Data �25.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)

Local oSection	 := oReport:Section(1)
Local oSection2	 := oReport:Section(2)
Local cNReqVazia := Criavar("CQ_NUMREQ",.F.)

Local cAliasQRY	:= GetNextAlias()
Local cAliasQRY2	:= GetNextAlias()

//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �	
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao 1                                           �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQRY
SELECT CQ_FILIAL,CP_NUM,CP_ITEM,CQ_PRODUTO,CQ_DESCRI,CQ_DATPRF,CP_QUANT,
  	   CP_QUJE,DHN_DOCDES,DHN_ITDES,CP_CC,CP_SOLICIT,
	   CASE WHEN CP_STATUS = 'E' THEN 'ENCERRADO' WHEN CP_QUANT <> CP_QUJE AND CP_QUJE = 0 THEN 'ABERTO' ELSE 'ATENDIMENTO PARCIAL' END AS STATUS
FROM %table:SCQ% SCQ
  JOIN %table:SCP% SCP
  ON CP_FILIAL = %xFilial:SCP% AND 
	CP_NUM   = CQ_NUM AND 
	CP_ITEM  = CQ_ITEM AND 
	CP_EMISSAO >= %Exp:Dtos(mv_par01)% AND 
	CP_EMISSAO <= %Exp:Dtos(mv_par02)% AND 
	//CP_STATUS  <> 'E' AND
	SCP.%NotDel%
  LEFT JOIN %table:DHN% DHN
  ON DHN_DOCORI = CP_NUM AND
		DHN_TIPO = '1' AND
		DHN.%NotDel%

WHERE CQ_FILIAL = %xFilial:SCQ% AND 
	CQ_NUM   >= %Exp:mv_par03% AND 
	CQ_NUM   <= %Exp:mv_par04% AND 
    //CQ_NUMREQ = %Exp:cNReqVazia% AND
	CQ_STATUSC <> 'D' AND
	SCQ.%NotDel%

ORDER BY %Order:SCQ%
		
EndSql 
//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

TRPosition():New(oSection,"SC1",1,{|| xFilial("SC1") + (cAliasQRY)->DHN_DOCDES+(cAliasQRY)->DHN_ITDES})


oSection:Print()

//DOCUMENTOS
oReport:SkipLine()
oReport:ThinLine()
oReport:SkipLine()
oReport:PrtLeft(" __________________________________________________________________________" + "DOCUMENTOS" + " __________________________________________________________________________") // "DOCUMENTOS"
oReport:SkipLine()

//Query do relatorio da secao 2
oSection2:BeginQuery()	

BeginSql Alias cAliasQRY2

SELECT 
	CP_FILIAL,CP_NUM,CP_ITEM,CP_PRODUTO,CP_DESCRI,DHN_TIPO,DHN_DOCDES,DHN_ITDES,DHN_QTDATE,DHN_QTDTOT 
FROM %table:SCP% SCP
	LEFT JOIN %table:DHN% DHN
	ON DHN_DOCORI = CP_NUM
WHERE 
	SCP.%NotDel% AND
	DHN.%NotDel% AND
	CP_NUM >= %Exp:mv_par03% AND
	CP_NUM <= %Exp:mv_par04% AND
	CP_STATUS <> 'E'
ORDER BY 
	CP_FILIAL,CP_NUM,CP_ITEM,DHN_TIPO
		
EndSql 
//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oSection2:EndQuery(/*Array com os parametros do tipo Range*/)

TRPosition():New(oSection2,"SCP",1,{|| xFilial("SCP") + (cAliasQRY2)->(CP_NUM + CP_ITEM)})

oSection2:cTitle := 'DOCUMENTOS'
oSection2:init()
oSection2:Print()
oSection2:Finish()

Return NIL




/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �A115ImpDet� Autor �  Edson Maricate       � Data �02.12.1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime a linha detalhe do Relatorio.                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Matr115                                                    ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A115ImpDet(lEnd,wnrel,cString,nomeprog,Titulo)

Local li      := 100 // Contador de Linhas
Local cNumPed := ""
Local lImp    := .F. // Indica se algo foi impresso
Local cbCont  := 0   // Numero de Registros Processados            
Local cbText  := ""  // Mensagem do Rodape
Local nDifTam := (TamSX3("B1_COD")[1] - 15) // diferenca a ser acrescida as colunas

Local cCabec1 := IIf(nDifTam == 0, STR0008, STR0010)
Local cCabec2 :=  ""

dbSelectArea(cString)
SetRegua(LastRec())
dbSetOrder(1)
dbSeek(xFilial()+mv_par03,.T.)

While (!Eof() .And. xFilial()==SCQ->CQ_FILIAL .And. SCQ->CQ_NUM >= mv_par03 .And. SCQ->CQ_NUM <= mv_par04)
	SCP->(dbSeek(xFilial("SCP")+SCQ->CQ_NUM+SCQ->CQ_ITEM))
	If !(SCP->CP_EMISSAO >= mv_par01 .And. SCP->CP_EMISSAO <= mv_par02)
		dbSkip()
		loop
	EndIf
	If SCP->CP_STATUS == "E" .And. Empty(SCQ->CQ_NUMREQ)	// Foi Encerrado Antes de Entregar o Produto...
		dbSkip()
		loop
	EndIf
	If !Empty(SCQ->CQ_NUMREQ) .Or. SCQ->CQ_STATUSC=="D"	// Foi Requisitado Ou Deletado...
		dbSkip()
		loop
	EndIf
	If lEnd
		@ Prow()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	lImp := .T.
	If ( li > 60 )
		li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,If(aReturn[4]==1,15,18))
		li++
	Endif
	
	DHN->(DbSetOrder(1)) //DHN_FILIAL+DHN_TIPO+DHN_ROTINA+DHN_FILORI+DHN_DOCORI+DHN_ITORI+DHN_FILDES+DHN_DOCDES+DHN_ITDES
	If DHN->(DbSeek(xFilial("DHN") + '1' + 'MATA106' + SCP->(CP_FILIAL + CP_NUM + CP_ITEM )))
		cNumPed := DHN->DHN_DOCDES
	Else
		cNumPed := ""
	EndIf
	
	dbSelectArea("SCQ")

	@ li,000 PSay SCP->CP_NUM
	@ li,010 PSay SCP->CP_ITEM
	//@ li,000 PSay SCQ->CQ_NUM
	//@ li,010 PSay SCQ->CQ_NUMSQ
	@ li,016 PSay SCQ->CQ_PRODUTO
	@ li,034+nDifTam PSay SubStr(SCQ->CQ_DESCRI,1,30)
	@ li,067+nDifTam PSay SCQ->CQ_DATPRF
	@ li,084+nDifTam PSay SCP->CP_QUANT  Picture PesqPict("SCP","CP_QUANT")
    @ li,104+nDifTam PSay SCP->CP_QUJE   Picture PesqPict("SCP","CP_QUJE")
	@ li,124+nDifTam PSay DHN->DHN_DOCDES
	@ li,141+nDifTam PSay cNumPed
	@ li,150+nDifTam PSay PadL(Alltrim(SCP->CP_CC),15)
	@ li,175+nDifTam PSay SCP->CP_SOLICIT
	li++
	dbSelectArea(cString)
	dbSkip()
	cbCont++
	IncRegua()
EndDo

If ( lImp )
	Roda(cbCont,cbText,Tamanho)
EndIf
dbSelectArea(cString)
dbClearFilter()
dbSetOrder(1)
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(.T.)
