#INCLUDE "FWBROWSE.CH"
#Include "RwMake.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} User Function ADFIN054P
    Integração no Financeiro de PA Gerada pelo SAG
    @type  Function
    @author Ricardo Lima
    @since 26/03/2018
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 043195 - Abel Babini - 13/09/2019 - Pedido de Compra com Adiantamento de PA
    @history chamado 052031 - FWNM        - 23/09/2019 - Preencher E2_CREDIT com conta contabil do banco
    @history chamado 057682 - FWNM        - 28/04/2020 - || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS
    @history chamado 059447 - Everson     - 09/07/2020 - Altera regra para carregar as datas de emissão, vencimento e vencimento real igual a data de vencimento.
    @history ticket 10979   - Abel Babini - 22/03/2021 - Cria validação para tx não preenchida no Pedido de Compras ou Cadastro de Moedas
    @history ticket 10979   - Abel Babini - 24/03/2021 - Alterar regra para moeda 1
/*/
User Function ADFIN054P()

	Local cArqTrb, cIndice1, cIndice2, cIndice3
    Local cAliasE2 := GetNextAlias()

	Private oBrowse
	Private aRotina		:= MenuDef()
	Private cCadastro 	:= "Pa Integração SAG"
	Private aCampos	:= {}, aSeek := {}, aFieFilter := {}

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integração no Financeiro de PA Gerada pelo SAG')

    AAdd(aCampos,{"E2_PREFIXO"  , "C" , 03 , 0})
    AAdd(aCampos,{"E2_NUM"  	, "C" , 09 , 0})
    AAdd(aCampos,{"E2_PARCELA"  , "C" , 03 , 0})
    AAdd(aCampos,{"E2_TIPO"  	, "C" , 03 , 0})
    AAdd(aCampos,{"E2_NATUREZ"  , "C" , 10 , 0})
    AAdd(aCampos,{"E2_FORNECE"  , "C" , 06 , 0})
    AAdd(aCampos,{"E2_LOJA"  	, "C" , 02 , 0})
    AAdd(aCampos,{"E2_EMISSAO"  , "D" , 08 , 0})
    AAdd(aCampos,{"E2_VENCTO"  	, "D" , 08 , 0})
    AAdd(aCampos,{"E2_VENCREA"  , "D" , 08 , 0})
    AAdd(aCampos,{"E2_VALOR"  	, "N" , 14 , 2})
    AAdd(aCampos,{"E2_HIST"  	, "C" , 25 , 0})
    AAdd(aCampos,{"E2_MOEDA"  	, "C" , 01 , 0})
    AAdd(aCampos,{"E2_PRODUTO"  , "C" , 50 , 0})
    AAdd(aCampos,{"E2_TOTAL"  	, "N" , 14 , 2})
    AAdd(aCampos,{"E2_PORTADO"  , "C" , 03 , 0})
    AAdd(aCampos,{"E2_AGENCIA"  , "C" , 05 , 0})
    AAdd(aCampos,{"E2_CONTA"  	, "C" , 10 , 0})
    AAdd(aCampos,{"E2_ORIVENC"  , "C" , 08 , 0})
    AAdd(aCampos,{"RECNO"       , "C" , 20 , 0})
    AAdd(aCampos,{"TAB_ORIGEM"  , "C" , 10 , 0})
    AAdd(aCampos,{"E2_CREDIT"   , "C" , TamSX3("E2_CREDIT")[1] , 0}) // Chamado n. 052031 || OS 053365 || FINANCAS || FLAVIA || 8461 || IMPORTAR AS PA X SAG - fwnm - 23/09/2019
	
	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		TRB->(dbCloseArea ())
	Endif
	
	//Criar tabela temporária
	cArqTrb   := CriaTrab(aCampos,.T.)
	
	//Definir indices da tabela
	cIndice1 := Alltrim(CriaTrab(,.F.))
	cIndice2 := cIndice1
	cIndice3 := cIndice1

	cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
	cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
	cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"

	If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf

	If File(cIndice2+OrdBagExt())
		FErase(cIndice2+OrdBagExt())
	EndIf

	If File(cIndice3+OrdBagExt())
		FErase(cIndice3+OrdBagExt())
	EndIf
	
	//Criar e abrir a tabela
	dbUseArea(.T.,,cArqTrb,"TRB",Nil,.F.)
	
	/*Criar indice*/
	IndRegua("TRB", cIndice1, "E2_NUM"	,,, "Indice Titulo...")
	IndRegua("TRB", cIndice2, "E2_FORNECE",,, "Indice Fornecedor...")
	
    dbClearIndex()
	
    dbSetIndex(cIndice1+OrdBagExt())
	dbSetIndex(cIndice2+OrdBagExt())

    cQry := "SELECT * FROM SGFIN010 WHERE E2_FILIAL = '"+cFilAnt+"' AND E2_TIPO = 'PA' AND STATUS_LIB = '1' AND OPERACAO_INT <> 'E' "
    // INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
	cQry += " UNION "
	cQry += " SELECT "
	cQry += " 	ZFQ_FILIAL COLLATE Latin1_General_CI_AS AS E2_FILIAL, "
	cQry += " 	ZFQ_PREFIX COLLATE Latin1_General_CI_AS AS E2_PREFIXO, "
	cQry += " 	ZFQ_NUM COLLATE Latin1_General_CI_AS AS E2_NUM, "
	cQry += " 	ZFQ_PARCEL COLLATE Latin1_General_CI_AS AS E2_PARCELA, "
	cQry += " 	ZFQ_TIPO COLLATE Latin1_General_CI_AS AS E2_TIPO, "
	cQry += " 	ZFQ_NATURE COLLATE Latin1_General_CI_AS AS E2_NATUREZ, "
	cQry += " 	ZFQ_FORNEC COLLATE Latin1_General_CI_AS AS E2_FORNECE, "
	cQry += " 	ZFQ_LOJA COLLATE Latin1_General_CI_AS AS E2_LOJA, "
	cQry += " 	ZFQ_EMISSA COLLATE Latin1_General_CI_AS AS E2_EMISSAO, "
	cQry += " 	ZFQ_VENCTO COLLATE Latin1_General_CI_AS AS E2_VENCTO, "
	cQry += " 	ZFQ_VENCRE COLLATE Latin1_General_CI_AS AS E2_VENCREA, "
	cQry += " 	ZFQ_VALOR AS E2_VALOR, "
	cQry += " 	ZFQ_HIST COLLATE Latin1_General_CI_AS AS E2_HIST, "
	cQry += " 	'' AS E2_MSEXP, "
	cQry += " 	'' AS E2_DTBAIXA, "
	cQry += " 	ZFQ_MOEDA COLLATE Latin1_General_CI_AS AS E2_MOEDA, "
	cQry += " 	ZFQ_RECORI AS RECORIGEM, "
	cQry += " 	'' AS CODIGENE, "
	cQry += " 	ZFQ_TABGEN COLLATE Latin1_General_CI_AS AS TABEGENE, "
	cQry += " 	ZFQ.R_E_C_N_O_ AS R_E_C_N_O_, "
	cQry += " 	'' AS STATUS_INT, "
	cQry += " 	ZFQ_OPEINT COLLATE Latin1_General_CI_AS AS OPERACAO_INT, "
	cQry += " 	'' AS MENSAGEM_INT, "
	cQry += " 	'' AS STATUS_PRC, "
	cQry += " 	'' AS MENSAGEM_PRC, "
	cQry += " 	ZFQ_STSLIB COLLATE Latin1_General_CI_AS AS STATUBS_LIB, "
	cQry += " 	ZFQ_PRODUT COLLATE Latin1_General_CI_AS AS E2_PRODUTO, "
	cQry += " 	ZFQ_TOTAL AS E2_TOTAL, "
	cQry += " 	ZFQ_PORTAD COLLATE Latin1_General_CI_AS AS E2_PORTADO, "
	cQry += " 	ZFQ_AGENCI COLLATE Latin1_General_CI_AS AS E2_AGENCIA, "
	cQry += " 	ZFQ_CONTA COLLATE Latin1_General_CI_AS AS E2_CONTA, "
    cQry += " 	ZFQ_ORIVEN COLLATE Latin1_General_CI_AS AS W2_ORIVENC, "
    cQry += " 	'' AS E2_CREDIT "
	cQry += " FROM "+RetSqlName("ZFQ")+" AS ZFQ " 
	cQry += " WHERE ZFQ.D_E_L_E_T_ = '' "
	cQry += " AND ZFQ.ZFQ_FILIAL = '"+cFilAnt+"'"
	cQry += " AND ZFQ.ZFQ_STSLIB = '1' "
	cQry += " AND ZFQ.ZFQ_OPEINT = 'I' "
    // FIM | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasE2, .F., .T.)

	TcSetField( cAliasE2, "E2_EMISSAO", "D", 8, 0 )
	TcSetField( cAliasE2, "E2_VENCTO" , "D", 8, 0 )
    TcSetField( cAliasE2, "E2_VENCREA", "D", 8, 0 )

    While !(cAliasE2)->(Eof())
        If RecLock("TRB",.t.)

            TRB->E2_PREFIXO := (cAliasE2)->E2_PREFIXO
            TRB->E2_NUM     := (cAliasE2)->E2_NUM
            TRB->E2_PARCELA := (cAliasE2)->E2_PARCELA
            TRB->E2_TIPO    := (cAliasE2)->E2_TIPO
            TRB->E2_NATUREZ := (cAliasE2)->E2_NATUREZ
            TRB->E2_FORNECE := (cAliasE2)->E2_FORNECE
            TRB->E2_LOJA    := (cAliasE2)->E2_LOJA
            TRB->E2_EMISSAO := Iif(AllTrim((cAliasE2)->E2_TIPO)=="PA",(cAliasE2)->E2_VENCTO,(cAliasE2)->E2_EMISSAO)//Everson, 09/07/2020. Chamado 059447. //Iif(AllTrim((cAliasE2)->E2_TIPO)=="PA",(cAliasE2)->E2_VENCREA,(cAliasE2)->E2_EMISSAO) // Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 28/04/2020
            TRB->E2_VENCTO  := Iif(AllTrim((cAliasE2)->E2_TIPO)=="PA",(cAliasE2)->E2_VENCTO,(cAliasE2)->E2_EMISSAO)//Everson, 09/07/2020. Chamado 059447. //Iif(AllTrim((cAliasE2)->E2_TIPO)=="PA",(cAliasE2)->E2_VENCREA,(cAliasE2)->E2_EMISSAO) // Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 28/04/2020
            TRB->E2_VENCREA := Iif(AllTrim((cAliasE2)->E2_TIPO)=="PA",(cAliasE2)->E2_VENCTO,(cAliasE2)->E2_EMISSAO)//Everson, 09/07/2020. Chamado 059447. //Iif(AllTrim((cAliasE2)->E2_TIPO)=="PA",(cAliasE2)->E2_VENCREA,(cAliasE2)->E2_EMISSAO) // Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 28/04/2020
            TRB->E2_VALOR   := (cAliasE2)->E2_VALOR
            TRB->E2_HIST    := (cAliasE2)->E2_HIST
            TRB->E2_MOEDA   := (cAliasE2)->E2_MOEDA
            TRB->E2_PRODUTO := (cAliasE2)->E2_PRODUTO
            TRB->E2_TOTAL   := (cAliasE2)->E2_TOTAL
            TRB->E2_PORTADO := (cAliasE2)->E2_PORTADO
            TRB->E2_AGENCIA := (cAliasE2)->E2_AGENCIA
            TRB->E2_CONTA   := (cAliasE2)->E2_CONTA
            TRB->E2_ORIVENC := (cAliasE2)->E2_ORIVENC
            TRB->RECNO      := AllTrim(Str( (cAliasE2)->R_E_C_N_O_  ))
            TRB->TAB_ORIGEM	:= (cAliasE2)->TABEGENE // INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
            
	        // Chamado n. 052031 || OS 053365 || FINANCAS || FLAVIA || 8461 || IMPORTAR AS PA X SAG - fwnm - 23/09/2019
	        // SA6 = ORDER 1 = A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
            If Empty( (cAliasE2)->E2_CREDIT )
                TRB->E2_CREDIT := Posicione("SA6",1,FWxFilial("SA6")+PadR((cAliasE2)->E2_PORTADO,TamSX3("A6_COD")[1])+PadR((cAliasE2)->E2_AGENCIA,TamSX3("A6_AGENCIA")[1])+PadR((cAliasE2)->E2_CONTA,TamSX3("A6_NUMCON")[1]),"A6_CONTA")
            EndIf
            //
            
            MsUnLock()
	    Endif
		(cAliasE2)->(DbSkip())
	EndDo

	dbSelectArea("TRB")
	TRB->(DbGoTop())

	//Campos que irão compor o combo de pesquisa na tela principal
	Aadd(aSeek,{"Titulo"    , {{"","C",06,0, "E2_NUM"    ,"@!"}}, 1, .T. } )
	Aadd(aSeek,{"Fornecedor", {{"","C",06,0, "E2_FORNECE","@!"}}, 2, .T. } )
	
	//Campos que irão compor a tela de filtro
	Aadd(aFieFilter,{"E2_NUM"     , "Titulo"     , "C", 09, 0,"@!"})
	Aadd(aFieFilter,{"E2_FORNECE" , "Fornecedor" , "C", 06, 0,"@!"})
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( "TRB" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:DisableDetails()
	
	//Legenda da grade, é obrigatório carregar antes de montar as colunas
	oBrowse:AddLegend("EMPTY(E2_PORTADO)" ,"RED" ,"Sem Banco")
	oBrowse:AddLegend("!EMPTY(E2_PORTADO)","GREEN","Banco Cadastrado")
	
	//Detalhes das colunas que serão exibidas
    oBrowse:SetColumns(MontaColunas("E2_PREFIXO","Prefixo"      ,01,"@!",0,03,0))
    oBrowse:SetColumns(MontaColunas("E2_NUM"	,"Titulo"       ,02,"@!",1,09,0))
    oBrowse:SetColumns(MontaColunas("E2_PARCELA","Parcela"		,03,"@!",1,03,0))
    oBrowse:SetColumns(MontaColunas("E2_TIPO"	,"Tipo"		    ,04,"@!",1,03,0))
    oBrowse:SetColumns(MontaColunas("E2_NATUREZ","Natureza"		,05,"@!",1,10,0))
    oBrowse:SetColumns(MontaColunas("E2_FORNECE","Fornecedor"	,06,"@!",1,06,0))
    oBrowse:SetColumns(MontaColunas("E2_LOJA"	,"Loja"		    ,07,"@!",1,02,0))
    oBrowse:SetColumns(MontaColunas("E2_EMISSAO","Emissao"		,08,"@!",1,08,0))
    oBrowse:SetColumns(MontaColunas("E2_VENCTO"	,"Vencimento"	,09,"@!",1,08,0))
    oBrowse:SetColumns(MontaColunas("E2_VENCREA","Venc.Real"	,10,"@!",1,08,0))
    oBrowse:SetColumns(MontaColunas("E2_VALOR"	,"Valor"		,11,X3Picture( "E2_VALOR" ),1,08,0))
    oBrowse:SetColumns(MontaColunas("E2_HIST"	,"Historico"	,12,"@!",1,50,0))
    oBrowse:SetColumns(MontaColunas("E2_MOEDA"	,"Moeda"		,13,"@!",1,01,0))
    oBrowse:SetColumns(MontaColunas("E2_PRODUTO","Produto"		,14,"@!",1,15,0))
    oBrowse:SetColumns(MontaColunas("E2_TOTAL"	,"Total"		,15,X3Picture( "E2_VALOR" ),1,08,0))
    oBrowse:SetColumns(MontaColunas("E2_PORTADO","Banco"		,16,"@!",1,03,0))
    oBrowse:SetColumns(MontaColunas("E2_AGENCIA","Agencia"		,17,"@!",1,05,0))
    oBrowse:SetColumns(MontaColunas("E2_CONTA"	,"Conta"		,18,"@!",1,10,0))
    oBrowse:SetColumns(MontaColunas("E2_ORIVENC","Venc.Original",19,"@!",1,08,0))
    oBrowse:SetColumns(MontaColunas("RECNO"     ,"RECNO"        ,20,""  ,1,20,0))
    oBrowse:SetColumns(MontaColunas("TAB_ORIGEM","Tabela Origem",10,""  ,1,20,0)) // INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
    oBrowse:SetColumns(MontaColunas("E2_CREDIT","Contabil"      ,10,"@!",1,20,0)) // Chamado n. 052031 || OS 053365 || FINANCAS || FLAVIA || 8461 || IMPORTAR AS PA X SAG - FWNM - 23/09/2019
    
	oBrowse:Activate()
	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())
		cArqTrb := ""
		TRB->(DbCloseArea())
		delTabTmp('TRB')
    	//dbClearAll()
	Endif
    	
return(Nil)

// ##############################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADFIN054P
// ---------+-------------------+------------------------------------------------+---------------
// Data     | Autor             | Descricao                                      | Chamado
// ---------+-------------------+------------------------------------------------+---------------
// 26/03/18 | Ricardo Lima      | Integração no Financeiro de PA Gerada pelo SAG | 
// ---------+-------------------+------------------------------------------------+---------------
// ##############################################################################################

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

/*/{Protheus.doc} Static Function MENUDEF
    Integração no Financeiro de PA Gerada pelo SAG
    @type  Function
    @author Ricardo Lima
    @since 26/03/2018
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MenuDef()

	Local aArea   := GetArea()
	Local aRotina := {}
	
	AADD(aRotina, {"Visualizar" , "U_ADFIN54A('V')" , 0, 2, 0, .F. })
	AADD(aRotina, {"Alterar"    , "U_ADFIN54A('A')" , 0, 4, 0, Nil })
    AADD(aRotina, {"Legenda"    , "U_ADFIN54L()"    , 0, 2, 0, .F. })
    
    RestArea(aArea)	

Return( aRotina )

/*/{Protheus.doc} User Function ADFIN054A
    Integração no Financeiro de PA Gerada pelo SAG
    @type  Function
    @author Ricardo Lima
    @since 26/03/2018
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function ADFIN54A(nOpc)

    Local aAreaAtu   := GetArea()
    Local oSay1
    Local oGet1

    Local nTxC7 := 0 //ticket 10979   - Abel Babini - 22/03/2021 - Cria validação para tx não preenchida no Pedido de Compras ou Cadastro de Moedas
    Local nVlrCvt := 0 //ticket 10979   - Abel Babini - 22/03/2021 - Cria validação para tx não preenchida no Pedido de Compras ou Cadastro de Moedas

    Private cPrefix := ""
    Private cNumTit := ""
    Private cParcel := ""
    Private cTptit  := ""
    Private cNaturez:= ""
    Private cNumFor := ""
    Private cLojFor := ""
    Private cNomFor := ""
    Private cProd   := ""
    Private dEmiss  := ""
    Private dVencto := ""
    Private nVlrTit := 0
    Private cBco := ""
    Private cAgen := ""
    Private cConta := ""
    Private cCredit := ""
    Private nRecMOV := ""
    Private dOriVenc := ""
    Private cTabOri		:= "" // INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO

    U_ADINF009P('ADFIN054P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integração no Financeiro de PA Gerada pelo SAG')

    //ticket 10979   - Abel Babini - 22/03/2021 - Cria validação para tx não preenchida no Pedido de Compras ou Cadastro de Moedas
    nTxC7 := GetAdvFVal("SC7","C7_XTXMOED",xFilial("SC7")+Alltrim(TRB->E2_NUM),1,"")
    IF TRB->E2_MOEDA <> '1' .and. !Empty(Alltrim(TRB->E2_MOEDA))
        nVlrCvt := Round(xMoeda(TRB->E2_VALOR,vAL(TRB->E2_MOEDA),1,TRB->E2_VENCTO,2,nTxC7),2)
    ENDIF
    //ticket 10979   - Abel Babini - 24/03/2021 - Alterar regra para moeda 1
    IF (TRB->E2_MOEDA <> '1' .and. nVlrCvt > 0) .or. TRB->E2_MOEDA == '1'
        
        aSize	:= {}
        aSize := MsAdvSize(.T.)
        
        //If !EMPTY(E2_PORTADO)
        //	Alert("Pa ja encontra-se com banco vicnculado")	     
        //	Return (.F)
        //EndIF
        
        Define MsDialog oPrjWindow TITLE "Status do Pedido de PA no SAG" STYLE DS_MODALFRAME From aSize[7],0 To aSize[6]-(aSize[6]/3),aSize[5]-(aSize[5]/4) OF oPrjWindow /*oMainWnd*/ PIXEL

        oSay1 := TSay():New( 041, 008, { || "Prefixo"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cPrefix := TRB->E2_PREFIXO
        oGet1 := TGet():New( 041, 050, { |u| If( PCount() > 0, cPrefix := u, cPrefix ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cPrefix", , )

        oSay1 := TSay():New( 054, 008, { || "Titulo"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cNumTit := TRB->E2_NUM 
        oGet1 := TGet():New( 054, 050, { |u| If( PCount() > 0, cNumTit := u, cNumTit ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cNumTit", , )

        oSay1 := TSay():New( 068, 008, { || "Parcela"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cParcel := TRB->E2_PARCELA
        oGet1 := TGet():New( 068, 050, { |u| If( PCount() > 0, cParcel := u, cParcel ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cParcel", , )

        oSay1 := TSay():New( 082, 008, { || "Tipo"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cTptit := TRB->E2_TIPO
        oGet1 := TGet():New( 082, 050, { |u| If( PCount() > 0, cTptit := u, cTptit ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cTptit", , )

        oSay1 := TSay():New( 096, 008, { || "Natureza"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cNaturez := TRB->E2_NATUREZ
        oGet1 := TGet():New( 096, 050, { |u| If( PCount() > 0, cNaturez := u, cNaturez ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cNaturez", , )

        oSay1 := TSay():New( 110, 008, { || "Cod.Fornecedor"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cNumFor := TRB->E2_FORNECE
        oGet1 := TGet():New( 110, 050, { |u| If( PCount() > 0, cNumFor := u, cNumFor ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cNumFor", , )

        oSay1 := TSay():New( 110, 128, { || "Fornecedor"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cNomFor := POSICIONE("SA2",1,FWxFilial("SA2") + TRB->E2_FORNECE + TRB->E2_LOJA,"A2_NOME")
        oGet1 := TGet():New( 110, 158, { |u| If( PCount() > 0, cNomFor := u, cNomFor ) }, oPrjWindow, 100, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cNomFor", , )

        oSay1 := TSay():New( 124, 128, { || "Produto"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cProd := TRB->E2_PRODUTO
        oGet1 := TGet():New( 124, 158, { |u| If( PCount() > 0, cProd := u, cProd ) }, oPrjWindow, 200, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cProd", , )

        oSay1 := TSay():New( 124, 008, { || "Loja"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cLojFor := TRB->E2_LOJA
        oGet1 := TGet():New( 124, 050, { |u| If( PCount() > 0, cLojFor := u, cLojFor ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cLojFor", , )

        oSay1 := TSay():New( 138, 008, { || "Emissão"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        dEmiss := TRB->E2_EMISSAO
        oGet1 := TGet():New( 138, 050, { |u| If( PCount() > 0, dEmiss := u, dEmiss ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "dEmiss", , )
        If nOpc = 'A'
            oSay1 := TSay():New( 152, 008, { || "Vencimento"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
            dVencto := TRB->E2_VENCTO
            dOriVenc := TRB->E2_VENCTO
            oGet1 := TGet():New( 152, 050, { |u| If( PCount() > 0, dVencto := u, dVencto ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "dVencto", , )        
        Else
            oSay1 := TSay():New( 152, 008, { || "Vencimento"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
            dVencto := TRB->E2_VENCTO
            dOriVenc := TRB->E2_VENCTO
            oGet1 := TGet():New( 152, 050, { |u| If( PCount() > 0, dVencto := u, dVencto ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "dVencto", , )
        Endif
        oSay1 := TSay():New( 164, 008, { || "Valor"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        nVlrTit := TRB->E2_VALOR
        oGet1 := TGet():New( 164, 050, { |u| If( PCount() > 0, nVlrTit := u, nVlrTit ) }, oPrjWindow, 060, 008, "@E 999,999,999.99"		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nVlrTit", , )
        if nOpc = 'A'
            oSay1 := TSay():New( 041, 128, { || "Banco"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
            cBco := TRB->E2_PORTADO
            oGet1 := TGet():New( 041, 158, { |u| If( PCount() > 0, cBco := u, cBco ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "SA6", "cBco", , )

            oSay1 := TSay():New( 054, 128, { || "Agencia"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
            cAgen := TRB->E2_AGENCIA
            oGet1 := TGet():New( 054, 158, { |u| If( PCount() > 0, cAgen := u, cAgen ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cAgen", , )

            oSay1 := TSay():New( 068, 128, { || "Conta"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
            cConta := TRB->E2_CONTA
            oGet1 := TGet():New( 068, 158, { |u| If( PCount() > 0, cConta := u, cConta ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cConta", , )
        else
            oSay1 := TSay():New( 041, 128, { || "Banco"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
            cBco := TRB->E2_PORTADO
            oGet1 := TGet():New( 041, 158, { |u| If( PCount() > 0, cBco := u, cBco ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cBco", , )

            oSay1 := TSay():New( 054, 128, { || "Agencia"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
            cAgen := TRB->E2_AGENCIA
            oGet1 := TGet():New( 054, 158, { |u| If( PCount() > 0, cAgen := u, cAgen ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cAgen", , )

            oSay1 := TSay():New( 068, 128, { || "Conta"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
            cConta := TRB->E2_CONTA
            oGet1 := TGet():New( 068, 158, { |u| If( PCount() > 0, cConta := u, cConta ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cConta", , )

        Endif
        
        //27/09/19 | FWNM              | Preencher E2_CREDIT com conta contabil do banco| 052031 || OS 053365 || FINANCAS || FLAVIA || 8461 || IMPORTAR AS PA X SAG
        oSay1 := TSay():New( 082, 128, { || "Cta Credito"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
        cCredit := Posicione("SA6",1,FWxFilial("SA6")+PadR(cBco,TamSX3("A6_COD")[1])+PadR(cAgen,TamSX3("A6_AGENCIA")[1])+PadR(cConta,TamSX3("A6_NUMCON")[1]),"A6_CONTA")
        oGet1 := TGet():New( 082, 158, { |u| If( PCount() > 0, cCredit := u, cCredit ) }, oPrjWindow, 060, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cCredit", , )
        //
        
        nRecMOV := TRB->RECNO
        
        cTabOri := TRB->TAB_ORIGEM // INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
        
        //ACTIVATE MSDIALOG oPrjWindow ON INIT EnchoiceBar( oPrjWindow , {|| U_ADFIN54U(nOpc) , oPrjWindow:End()} , {|| oPrjWindow:End()} ) CENTERED  
        
        // Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 28/04/2020
        If AllTrim(TRB->E2_TIPO) == "PA"
            dEmiss := TRB->E2_VENCREA
            dVencto := TRB->E2_VENCREA
            dOriVenc := TRB->E2_VENCREA
        EndIf
        //
    
        ACTIVATE MSDIALOG oPrjWindow ON INIT EnchoiceBar(oPrjWindow ,  {|| U_ADFIN54U(nOpc) , oPrjWindow:End()} , {|| oPrjWindow:End()},oGet1:Refresh())  CENTERED  
        
        GetdRefresh()
        SysRefresh()
    ELSE
        msgAlert("[ADFIN054P-03] - Não existe cotação para a moeda no Pedido de Compra ou no cadastro de Moedas! Verifique...")
    ENDIF
    RestArea( aAreaAtu )

Return(.T.)

/*/{Protheus.doc} User Function ADFIN54U
    Integração no Financeiro de PA Gerada pelo SAG
    @type  Function
    @author Ricardo Lima
    @since 26/03/2018
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function ADFIN54U(nOpc)

    Local cInstSQL   := ""

    U_ADINF009P('ADFIN054P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integração no Financeiro de PA Gerada pelo SAG')

    // Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 28/04/2020
    If AllTrim(TRB->E2_TIPO) == "PA"
    
        If msgYesNo("Você informou uma nova data de vencimento! A PA será gerada com a emissão igual a data de vencimento. Confirma?")
            dEmiss := dVencto
            dOriVenc := dVencto
        EndIf

        /*
        If ( dEmiss <> dVencto ) .or. ( dEmiss <> dOriVenc )
            msgAlert("[ADFIN054P-01] - Adiantamento a Fornecedor precisa possuir emissão e vencimentos iguais! Verifique...")
            Return .F.
        EndIf
    
        If ( TRB->E2_EMISSAO <> TRB->E2_VENCTO ) .or. ( TRB->E2_EMISSAO <> TRB->E2_VENCREA ) .or. ( TRB->E2_VENCTO <> TRB->E2_VENCREA ) 
            msgAlert("[ADFIN054P-02] - Adiantamento a Fornecedor precisa possuir emissão e vencimentos iguais! Verifique...")
            Return .F.
        EndIf
        */

    EndIf
    //

    IF nOpc = 'A'

        //Begin Transaction

        if Alltrim(cTabOri) == "SC7" // INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO

        	if dVencto <> dOriVenc
	            IF !EMPTY(cBco) .AND. !EMPTY(cAgen) .AND. !EMPTY(cConta) .AND. !EMPTY(dVencto) .AND. !EMPTY(dOriVenc)
	                cInstSQL := "UPDATE "+RetSqlName("ZFQ")+" SET ZFQ_STSLIB='2' , ZFQ_PORTAD = '"+ cBco +"' , ZFQ_AGENCI = '"+ cAgen +"' , ZFQ_CONTA = '"+ cConta +"' , ZFQ_VENCTO = '"+DTOS(dVencto)+"' , ZFQ_ORIVEN = '"+DTOS(dOriVenc)+"'  WHERE R_E_C_N_O_="+AllTrim( nRecMOV )+" "
	            ENDIF
	        else
	            IF !EMPTY(cBco) .AND. !EMPTY(cAgen) .AND. !EMPTY(cConta)
	                cInstSQL := "UPDATE "+RetSqlName("ZFQ")+" SET ZFQ_STSLIB='2' , ZFQ_PORTAD = '"+ cBco +"' , ZFQ_AGENCI = '"+ cAgen +"' , ZFQ_CONTA = '"+ cConta +"'  WHERE R_E_C_N_O_="+AllTrim( nRecMOV )+" "
	            ENDIF
	        endif

        else // FIM | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO

	        if dVencto <> dOriVenc
	         	
	            IF !EMPTY(cBco) .AND. !EMPTY(cAgen) .AND. !EMPTY(cConta) .AND. !EMPTY(dVencto) .AND. !EMPTY(dOriVenc)
	            	// Chamado n. 052031 || OS 053365 || FINANCAS || FLAVIA || 8461 || IMPORTAR AS PA X SAG - fwnm - 23/09/2019
	                //cInstSQL := "UPDATE SGFIN010 SET STATUS_LIB='2' , E2_PORTADO = '"+ cBco +"' , E2_AGENCIA = '"+ cAgen +"' , E2_CONTA = '"+ cConta +"' , E2_VENCTO = '"+DTOS(dVencto)+"' , E2_ORIVENC = '"+DTOS(dOriVenc)+"'  WHERE R_E_C_N_O_="+AllTrim( nRecMOV )+" "
	                cInstSQL := "UPDATE SGFIN010 SET STATUS_LIB='2' , E2_PORTADO = '"+ cBco +"' , E2_AGENCIA = '"+ cAgen +"' , E2_CONTA = '"+ cConta +"' , E2_CREDIT = '"+cCredit+"' , E2_VENCTO = '"+DTOS(dVencto)+"' , E2_ORIVENC = '"+DTOS(dOriVenc)+"'  WHERE R_E_C_N_O_="+AllTrim( nRecMOV )+" "
	            
                ENDIF
	        else
	            IF !EMPTY(cBco) .AND. !EMPTY(cAgen) .AND. !EMPTY(cConta)
	            	// Chamado n. 052031 || OS 053365 || FINANCAS || FLAVIA || 8461 || IMPORTAR AS PA X SAG - fwnm - 23/09/2019
	                //cInstSQL := "UPDATE SGFIN010 SET STATUS_LIB='2' , E2_PORTADO = '"+ cBco +"' , E2_AGENCIA = '"+ cAgen +"' , E2_CONTA = '"+ cConta +"'  WHERE R_E_C_N_O_="+AllTrim( nRecMOV )+" "
	                cInstSQL := "UPDATE SGFIN010 SET STATUS_LIB='2' , E2_PORTADO = '"+ cBco +"' , E2_AGENCIA = '"+ cAgen +"' , E2_CONTA = '"+ cConta +"' , E2_CREDIT = '"+cCredit+"' WHERE R_E_C_N_O_="+AllTrim( nRecMOV )+" "
	            ENDIF
	        endif 

	    endif // INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO

        IF !EMPTY(cInstSQL)
            If TcSqlExec( cInstSQL ) < 0
                //DisarmTransaction()
                Alert( "Erro: " + tcSqlError() )
            EndIf
            //u_ADFIN053P('M')
            MsAguarde({|| u_ADFIN053P('M') },"Aguarde","Gerando adiantamento fornecedor n. " + cNumTit)
        ENDIF

        //End Transaction
        
    ENDIF

Return(.T.)

/*/{Protheus.doc} User Function ADFIN54L
    Integração no Financeiro de PA Gerada pelo SAG
    @type  Function
    @author Ricardo Lima
    @since 26/03/2018
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function ADFIN54L()

    Local aLegenda := {}

    aAdd( aLegenda, { "BR_VERDE"    , "Banco Informado" })
    aAdd( aLegenda, { "BR_VERMELHO" , "Sem Banco" })

    BrwLegenda( "Complemento de PA SAG", "Legenda", aLegenda )

Return Nil
