#include "protheus.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author Fernando Macieira
    @since 01/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history Ticket 62276 - Fernando Macieira - 06/12/2021 - Endereçamento automático - Armazéns de terceiros 70 a 74 - Projeto Industrialização - Alguns casos o EXECAUTO retorna ERRO
    @history Ticket 77543 - Fernando Macieira - 03/08/2022 - SD1 sem endereçamento automático apartir de 25/07/2022
/*/
User Function MTA265MNU()

    aAdd(aRotina,{ "* Endereça A2_XTIPO=4", "u_RunChkSDA()", 0 , 2, 0, .F.})
    aAdd(aRotina,{ "* Endereça Produtos Almoxarifado", "u_RunSBE()", 0 , 2, 0, .F.}) // @history Ticket 77543 - Fernando Macieira - 03/08/2022 - SD1 sem endereçamento automático apartir de 25/07/2022
    
Return

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author FWNM
    @since 01/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function RunChkSDA()
    
    FWMsgRun(, {|| u_ChkSDA() }, "Aguarde", "Checando endereçamentos pendentes ["+Time()+"] ...")

    msgInfo("Endereçamentos pendentes finalizados! Verifique... ")

Return

/*/{Protheus.doc} User Function RunSBE
    (long_description)
    @type  Function
    @author FWNM
    @since 03/08/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history Ticket 77543 - Fernando Macieira - 03/08/2022 - SD1 sem endereçamento automático apartir de 25/07/2022
/*/
User Function RunSBE()
    
    FWMsgRun(, {|| RunSBESDA() }, "Aguarde", "Checando endereçamentos pendentes ["+Time()+"] ...")

    If msgYesNo("Endereçamentos pendentes finalizados! " + chr(13)+chr(10)+ " Deseja emitir listagem agora?")
        MATR245()
    EndIf

Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author FWNM
    @since 03/08/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history Ticket 77543 - Fernando Macieira - 03/08/2022 - SD1 sem endereçamento automático apartir de 25/07/2022
/*/
Static Function RunSBESDA()

    Local cQuery     := ""
    Local aAreaAtu   := GetArea()
    Local nX

	Local cEndereco   := ""
	Local cProduto    := ""
	Local cLocal      := ''
	Local aCab        := {}
	Local aItem       := {}
	Local aLog    := {}
	Local aDadSBE := {}

    PRIVATE lMsErroAuto := .F.// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
    Private lMsHelpAuto	:= .T.    // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
    Private lAutoErrNoFile := .T. 

    If Select("TRBSDA") > 0
        TRBSDA->( dbCloseArea() )
    EndIf

    cQuery := " SELECT DA_FILIAL, DA_PRODUTO, DA_SALDO, DA_LOCAL, DA_NUMSEQ, DA_DOC, DA_SERIE, DA_CLIFOR, DA_DATA, DA_LOJA
    cQuery += " FROM " + RetSqlName("SDA") + " SDA (NOLOCK)
    cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 (NOLOCK) ON A2_FILIAL='"+FWxFilial("SA2")+"' AND A2_COD=DA_CLIFOR AND A2_LOJA=DA_LOJA AND SA2.D_E_L_E_T_=''
    cQuery += " WHERE DA_FILIAL='"+FWxFilial("SDA")+"' 
    cQuery += " AND DA_LOCAL NOT IN ('70','71','72','73','74')
    cQuery += " AND DA_ORIGEM='SD1'
    cQuery += " AND DA_TIPONF='N'
    cQuery += " AND DA_SALDO>0
    cQuery += " AND SDA.D_E_L_E_T_=''
    cQuery += " AND A2_XTIPO<>'4'

    tcQuery cQuery New Alias "TRBSDA"

    aTamSX3	:= TamSX3("DA_SALDO")
    tcSetField("TRBSDA", "DA_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    aTamSX3	:= TamSX3("DA_DATA")
    tcSetField("TRBSDA", "DA_DATA", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    TRBSDA->( dbGoTop() )
    Do While TRBSDA->( !EOF() )

        If Localiza(TRBSDA->DA_PRODUTO)
        
			cEndereco := ''
			cProduto  := ''
			cLocal    := ''
			
			// @history ticket 77543 - Fernando Macieira - 03/08/2022 - SD1 sem endereçamento automático apartir de 25/07/2022
			aDadSBE := u_GetSBE(TRBSDA->DA_PRODUTO,TRBSDA->DA_LOCAL)

			cEndereco := aDadSBE[1]
			cProduto  := aDadSBE[2]
			cLocal    := aDadSBE[3]

			IF ALLTRIM(cEndereco) <> '' .AND. ;
			   ALLTRIM(cProduto)  <> '' .AND. ;
			   ALLTRIM(cLocal)    <> '' 
			
			    // Carrega o cabecalho (SDA)
				aAdd(aCab,{"DA_FILIAL ", FWxFilial("SDA")    ,NIL}) // Filial do sistema
				aAdd(aCab,{"DA_PRODUTO", cProduto   	   ,NIL}) // Produto
				aAdd(aCab,{"DA_LOCAL"  , cLocal            ,NIL}) // Local Padrao
				aAdd(aCab,{"DA_NUMSEQ" , TRBSDA->DA_NUMSEQ ,NIL}) // Numero Sequencial
				aAdd(aCab,{"DA_DOC"    , TRBSDA->DA_DOC    ,NIL}) // Nota Fiscal
				aAdd(aCab,{"DA_SERIE"  , TRBSDA->DA_SERIE  ,NIL}) // Serie
				aAdd(aCab,{"DA_CLIFOR" , TRBSDA->DA_CLIFOR ,NIL}) // Fornecedor
				aAdd(aCab,{"DA_LOJA"   , TRBSDA->DA_LOJA   ,NIL}) // Loja
								
				// Carrega os Itens (SDB)
				aAdd(aItem,{{"DB_FILIAL"  , xFilial("SDB")       ,NIL},;  // Filial do sistema
				            {"DB_ITEM"   , "001"                 ,NIL},;  // Item
				            {"DB_LOCALIZ", cEndereco             ,NIL},;  // Endereco
				            {"DB_DATA"   , TRBSDA->DA_DATA       ,NIL},;  // Data
				            {"DB_QUANT"  , TRBSDA->DA_SALDO      ,NIL}} ) // Quantidade
				
				//Begin Transaction

					lMSErroAuto := .F.
					MSExecAuto({|x,y,z| Mata265(x,y,z)},aCab,aItem,3)
					
					IF lMSErroAuto  // Se der erro

						aLog := GetAutoGrLog()

						For nX := 1 To Len(aLog)
						u_GrLogZBE( msDate(), TIME(), cUserName,"ENDERECAMENTO AUTOMATICO PRODUTOS ALMOXARIFADO NAO REALIZADO - MATA265 - NF/SERIE/FORNECE " + TRBSDA->DA_DOC + "/" + TRBSDA->DA_SERIE + "/" + TRBSDA->DA_CLIFOR + " PRODUTO/ARMAZEM/ENDERECO " + cProduto + "/" + cLocal + "/" + cEndereco,"CONTROLADORIA","SF1100I",;
						"Linha Error log " + AllTrim(Str(nX)) + " - Erro " + aLog[nX], ComputerName(), LogUserName() )
						Next nX			

					ELSE 

						u_GrLogZBE( msDate(), TIME(), cUserName,"ENDERECAMENTO AUTOMATICO PRODUTOS ALMOXARIFADO - MATA265","CONTROLADORIA","SF1100I",;
						"NF/SERIE/FORNECE " + TRBSDA->DA_DOC + "/" + TRBSDA->DA_SERIE + "/" + TRBSDA->DA_CLIFOR + " PRODUTO/ARMAZEM/ENDERECO " + cProduto + "/" + cLocal + "/" + cEndereco, ComputerName(), LogUserName() )

						EvalTrigger()
						//Commit

					ENDIF
				
				//END Transaction
				
				aCab    := {}
				aItem   := {}
                aDadSBE := {}

            EndIf

        EndIf

        TRBSDA->( dbSkip() )

    EndDo

    If Select("TRBSDA") > 0
        TRBSDA->( dbCloseArea() )
    EndIf

    RestArea( aAreaAtu )

Return 
