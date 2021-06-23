#include "rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'FWMVCDef.ch'
// #########################################################################################################
// Modulo : SIGACON
// Fonte  : ADCON013P
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 24/10/18 | Ricardo Lima      | Visão Contabil com dados do pedido de Compra              | 037647
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################

User Function ADCON013P

    Local oTempTable
    Local nI
    Local cQuery
    Local cAliasE := "CT2"
    Private cAlias := GetNextAlias()
    
    Private aFields := {}
    Private oBrowse
	Private cCadastro 	:= "Contabilizações com Lote de Criação"
    Private aSeek := {}, aFieFilter := {}

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    oTempTable := FWTemporaryTable():New( cAlias )

    dbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAliasE)
    While !SX3->(EOF()) .And. SX3->X3_Arquivo == cAliasE
        If (X3Uso(SX3->X3_Usado) .And. SX3->X3_CONTEXT <> 'V') .OR. X3_CAMPO="CT2_FILIAL"
            aadd(aFields,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
        EndIf
    SX3->(dbSkip())
    End

    dbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("C7_XLOTECC")
        aadd(aFields,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    EndIf
    dbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("C7_XDLOTCC")
        aadd(aFields,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    EndIf

    oTemptable:SetFields( aFields )
    oTempTable:AddIndex("indice1", {"CT2_FILIAL","CT2_DATA"} )
    oTempTable:Create()

    cQuery := " SELECT C7_XLOTECC, C7_XDLOTCC, CT2.* "
    cQuery += " FROM "+RetSqlName("CT2")+" CT2 "
    cQuery += " INNER JOIN "+RetSqlName("SD1")+" D1 ON CT2_FILKEY = D1_FILIAL AND CT2_PREFIX = D1_SERIE AND CT2_NUMDOC = D1_DOC AND CT2_CLIFOR = D1_FORNECE AND CT2_LOJACF = D1_LOJA AND D1.D_E_L_E_T_ = ' '
    cQuery += " INNER JOIN "+RetSqlName("SC7")+" C7 ON D1_FILIAL = C7_FILIAL AND D1_PEDIDO = C7_NUM AND D1_FORNECE = C7_FORNECE AND D1_LOJA = C7_LOJA AND C7.D_E_L_E_T_ = ' '
    If Select("TCT2") > 0
		TCT2->(DbCloseArea())
	EndIf
	MPSysOpenQuery( cQuery, 'TCT2' )
    DbSelectArea('TCT2')

    while TCT2->(!eof())
        Reclock(cAlias,.T.)
        for nI := 1 to Len(aFields)
            If aFields[nI][2] = 'D'
                (cAlias)->(&(ALLTRIM(aFields[nI][1]))) := StoD( TCT2->(&(ALLTRIM(aFields[nI][1]))) )
            Else
                (cAlias)->(&(ALLTRIM(aFields[nI][1]))) := TCT2->(&(ALLTRIM(aFields[nI][1])))
            EndIf
        next
        (cAlias)->(MSUNLOCK())
        DbSelectArea('TCT2')
        TCT2->(dbskip())
    Enddo

	Aadd(aSeek,{"Data",{{"","D",08,0,"CT2_DATA","@!"}},1,.T.} )
	
    For nI:=1 to Len(aFields)
        Aadd(aFieFilter,{aFields[nI][5] , aFields[nI][1] , aFields[nI][2] , aFields[nI][3] , aFields[nI][4] , aFields[nI][6]})
    Next 
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( cAlias )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:DisableDetails()
        For nI:=1 To Len(aFields)
            oBrowse:SetColumns(MontaColunas(aFields[nI][1],aFields[nI][5],nI,aFields[nI][6],0,aFields[nI][3],aFields[nI][4])) 
        Next
    oBrowse:Activate()
    oTempTable:Delete() 

Return
// #########################################################################################################
// Modulo : SIGACON
// Fonte  : MontaColunas
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 24/10/18 | Ricardo Lima      | Visão Contabil com dados do pedido de Compra              | 037647
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	
    Local aColumn
	Local bData 	 := {||}

	Default nAlign 	 := 1
	Default nSize 	 := 20
	Default nDecimal := 0
	Default nArrData := 0
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}  
	
Return {aColumn}