#include 'totvs.ch'
#include 'fwmvcdef.ch'   
#Include 'topconn.ch'

/* 
#define EE7CAMPOS  '|F1_FILIAL|F1_FORNECE|F1_LOJA|F1_DOC|F1_SERIE|F1_ESPECIE|F1_EMISSAO|F1_DTDIGIT|F1_ZINSREC|F1_ZCQIQTD|F1_ZCQIQLD|'
#define EE8CAMPOS  '|D1_FILIAL|D1_ITEM|D1_DOC|D1_SERIE|D1_FORNECE|D1_LOJA|D1_COD|D1_QUANT|D1_ZCHQLD|D1_ZCHQTD|D1_ZCODRNC|'

#define EE7VISUAL  '|F1_FORNECE|F1_LOJA|F1_DOC|F1_SERIE|F1_ESPECIE|F1_EMISSAO|F1_DTDIGIT|F1_ZINSREC|F1_ZCQIQTD|F1_ZCQIQLD|'
#define EE8VISUAL  '|D1_ITEM|D1_COD|D1_QUANT|D1_ZCHQTD|'
*/
#define EE7EXCLUS  '|EE7_CODBOL|EE7_DSCBOL|'
#define EE8CAMPOS  '|EE8_FILIAL|EE8_PEDIDO|EE8_COD_I|EE8_SEQUEN|EE8_UNIDAD|EE8_DTPREM|EE8_DTENTR|EE8_SLDINI|EE8_EMBAL1|EE8_UNPRC|EE8_QE|EE8_QTDEM1|EE8_PRECO|EE8_PRECOI|EE8_PRCTOT|EE8_SLDATU|EE8_UNPES|EE8_PSQLUN|EE8_PSLQUN|EE8_PSBRUN|EE8_POSIPI|EE8_TES|EE8_PRCINC|EE8_CF|EE8_PRCUN|'
#define EE8VISUAL  '|EE8_COD_I|EE8_SEQUEN|EE8_UNIDAD|EE8_DTPREM|EE8_DTENTR|EE8_SLDINI|EE8_EMBAL1|EE8_UNPRC|EE8_QE|EE8_QTDEM1|EE8_PRECO|EE8_PRECOI|EE8_PRCTOT|EE8_SLDATU|EE8_UNPES|EE8_PSQLUN|EE8_PSLQUN|EE8_PSBRUN|EE8_POSIPI|EE8_TES|EE8_PRCINC|EE8_CF|EE8_PRCUN|'
#define SC6CAMPOS  '|C6_FILIAL|C6_NUM|C6_ITEM|C6_PRODUTO|C6_DESCRI|C6_QTDVEN|'
#define SC6VISUAL  '|C6_ITEM|C6_PRODUTO|C6_DESCRI|C6_QTDVEN|'
#define ZEXCAMPOS  '|ZEX_FILIAL|ZEX_NUMERO|ZEX_PRODUT|ZEX_DTFABR|ZEX_DTVALD|ZEX_PALLET|ZEX_TURNO|ZEX_QUANTI|ZEX_QTDSUM|ZEX_TEMPER|ZEX_ID|ZEX_ROTEDT|ZEX_ROTEIR|ZEX_PLACA|ZEX_CARGA|ZEX_EDTPRD|ZEX_QTDREA|ZEX_TARAEM|ZEX_LACRE1|ZEX_LACRE2|ZEX_DTCARG|ZEX_HRICAR|ZEX_HRTCAR|ZEX_CONTAI|ZEX_DTLACRE|ZEX_HRLACRE|ZEX_LIMPINT|ZEX_LIMPEXT|ZEX_TEMPBAU|ZEX_BORRACH|ZEX_EQUIPFR|'
#define ZEXVISUAL  '|ZEX_DTFABR|ZEX_DTVALD|ZEX_PALLET|ZEX_TURNO|ZEX_QUANTI|ZEX_QTDSUM|ZEX_TEMPER|ZEX_ID|ZEX_ROTEDT|ZEX_ROTEIR|ZEX_PLACA|ZEX_CARGA|ZEX_EDTPRD|ZEX_QTDREA|ZEX_TARAEM|ZEX_LACRE1|ZEX_LACRE2|ZEX_DTCARG|ZEX_HRICAR|ZEX_HRTCAR|ZEX_CONTAI|ZEX_DTLACRE|ZEX_HRLACRE|ZEX_LIMPINT|ZEX_LIMPEXT|ZEX_TEMPBAU|ZEX_BORRACH|ZEX_EQUIPFR|'
#define ZEYCAMPOS  '|ZEY_FILIAL|ZEY_NUMERO|ZEY_ID|ZEY_PRODUT|ZEY_DESCRI|ZEY_ARQUIV|'
#define ZEYVISUAL  '|ZEY_DESCRI|ZEY_ARQUIV|'

/*/{Protheus.doc} User Function ADEEC009P
	Alteracao das devolucoes
	@author user
	@since 03/04/2006
	@history Chamado 8465 - Leonardo P. Monteiro    - 19/05/2021 - Permissão para a gravação e alteração da data de entrega nos processos de exportação.
	@history Chamado 8465 - Leonardo P. Monteiro    - 22/05/2021 - Implementação dos campos de container, temperatura, lacres SIF, lacres armador, e datas de produção.
	@history Chamado 8465 - Leonardo P. Monteiro    - 02/07/2021 - Ajustes no relacionamento do processo de exportação com os registros de inspeção da qualidade.
	@history Chamado 8465 - Leonardo P. Monteiro    - 02/07/2021 - Adição de novos campos retornados do aplicativo da Qualidade.
/*/
// --------------------------------------------------------------------------------------------------------------
Static Function Modeldef()
	Local oModel    	:= MPFormModel():New("mdlADEEP009P",, {|| fVldForm()}, {|oMld| fAfterTTS(oMld)})
	//Local oModel    	:= MPFormModel():New("mdlADEEP009P")
    Local oStruCab 		:= NIL
	Local oStruEE8 		:= NIL
	Local oStruSC6 		:= NIL
	Local oStruZEX 		:= NIL
	Private lAltera		:= .T.

    //oStruCab 	:= FWFormStruct( 1, 'EE7',{| cCampo | AllTrim( cCampo ) + '|' $ EE7CAMPOS  }) 
	//oStruEE8 	:= FWFormStruct( 1, 'EE8',{| cCampo | AllTrim( cCampo ) + '|' $ EE8CAMPOS  }) 
		
	oStruCab 	:= FWFormStruct( 1, 'EE7', {| cCampo | !('|' + AllTrim( cCampo ) + '|' $ EE7EXCLUS)	})
	oStruEE8 	:= FWFormStruct( 1, 'EE8', {| cCampo |   '|' + AllTrim( cCampo ) + '|' $ EE8CAMPOS	})
	oStruSC6 	:= FWFormStruct( 1, 'SC6', {| cCampo |   '|' + AllTrim( cCampo ) + '|' $ SC6CAMPOS	})
	oStruZEX 	:= FWFormStruct( 1, 'ZEX', {| cCampo |   '|' + AllTrim( cCampo ) + '|' $ ZEXCAMPOS	})
	oStruZEY 	:= FWFormStruct( 1, 'ZEY', {| cCampo |   '|' + AllTrim( cCampo ) + '|' $ ZEYCAMPOS	})
	
	oStruEE8:AddField( ; 
                        AllTrim("") , ;             // [01] C Titulo do campo 
                        AllTrim("") , ;             // [02] C ToolTip do campo 
                        "DESCRICAO", ;              // [03] C identificador (ID) do Field 
                        "C" , ;                     // [04] C Tipo do campo 
                        50 , ;                      // [05] N Tamanho do campo 
                        0 , ;                       // [06] N Decimal do campo 
                        NIL , ;                     // [07] B Code-block de validação do campo 
                        NIL , ;                     // [08] B Code-block de validação When do campo 
                        NIL , ;                     // [09] A Lista de valores permitido do campo 
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório 
                        { || Posicione("SB1",1,xFilial("SB1")+EE8->EE8_COD_I,"B1_DESC" ) } , ;        // [11] B Code-block de inicializacao do campo 
                        NIL , ;                     // [12] L Indica se trata de um campo chave 
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update. 
                        .T. )                       // [14] L Indica se o campo é virtual 
	
	oStruCab:SetProperty( "*"   , MODEL_FIELD_WHEN, {|| .F. } )
	oStruEE8:SetProperty( "*"   , MODEL_FIELD_WHEN, {|| .F. } )
    oStruSC6:SetProperty( "*"   , MODEL_FIELD_WHEN, {|| .F. } )
    oStruZEX:SetProperty( "*"   , MODEL_FIELD_WHEN, {|| .F. } )
    oStruZEY:SetProperty( "*"   , MODEL_FIELD_WHEN, {|| .F. } )

	oStruCab:SetProperty( "EE7_XDLCAR"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_XINDOC"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_ESTUFA"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_XBOOKI"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_XPAGAM"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_XEMBAR"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_XORDCO"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_XOPCTE"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_XCODTE"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_CONTAI"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_NLACR1"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_NLACR2"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_TEMPER"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_DTPROD"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruCab:SetProperty( "EE7_XTARA"    , MODEL_FIELD_WHEN, {|| .T. } )
	
	if Empty(SC5->C5_NOTA) .AND. Empty(SC5->C5_PLACA).AND. Empty(SC5->C5_X_SQED)
		oStruCab:SetProperty( "EE7_XETQUE"   , MODEL_FIELD_WHEN, {|| .T. } )
		oStruCab:SetProperty( "EE7_XESPEM"   , MODEL_FIELD_WHEN, {|| .T. } )
		oStruCab:SetProperty( "EE7_CONSIG"   , MODEL_FIELD_WHEN, {|| .T. } )
		oStruCab:SetProperty( "EE7_COLOJA"   , MODEL_FIELD_WHEN, {|| .T. } )
		oStruCab:SetProperty( "EE7_XTPFRE"   , MODEL_FIELD_WHEN, {|| .T. } )
		oStruCab:SetProperty( "EE7_XDLDRA"   , MODEL_FIELD_WHEN, {|| .T. } )
		
		oStruEE8:SetProperty( "EE8_DTENTR"   , MODEL_FIELD_WHEN, {|| .T. } )
		oStruEE8:SetProperty( "EE8_DTENTR"   , MODEL_FIELD_VALID, {|| oModel:GetModel("EE8DETAIL"):getValue("EE8_DTENTR") >= Date() } )
	endif

	/*
	oStruEE8:SetProperty( "D1_ZCHQLD"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruEE8:SetProperty( "D1_ZCHQTD"   , MODEL_FIELD_WHEN, {|| .T. } )
	oStruEE8:SetProperty( "D1_ZCODRNC"  , MODEL_FIELD_WHEN, {|| .T. } )
	*/
	oModel:AddFields('EE7MASTER',nil , oStruCab,,)
	oModel:AddGrid('EE8DETAIL', 'EE7MASTER', oStruEE8)
	oModel:AddGrid('SC6DETAIL', 'EE7MASTER', oStruSC6)
	oModel:AddGrid('ZEXDETAIL', 'SC6DETAIL', oStruZEX)
	oModel:AddGrid('ZEYDETAIL', 'ZEXDETAIL', oStruZEY)
	
	oModel:GetModel( 'EE7MASTER' ):SetDescription('Pedido de Exportação') 
	oModel:GetModel( 'EE8DETAIL' ):SetDescription('Itens Exportação')
	oModel:GetModel( 'SC6DETAIL' ):SetDescription('Itens Vendidos')
	oModel:GetModel( 'ZEXDETAIL' ):SetDescription('Dados de Carregamento')
	oModel:GetModel( 'ZEYDETAIL' ):SetDescription('Arquivos de Imagem')

	oModel:GetModel("EE8DETAIL"):setNoInsertLine(.T.)
	oModel:GetModel("EE8DETAIL"):setNoDeleteLine(.T.)
	
	oModel:GetModel("SC6DETAIL"):setNoInsertLine(.T.)
	oModel:GetModel("SC6DETAIL"):setNoDeleteLine(.T.)

	oModel:GetModel("ZEXDETAIL"):setNoInsertLine(.T.)
	oModel:GetModel("ZEXDETAIL"):setNoDeleteLine(.T.)

	oModel:GetModel("ZEYDETAIL"):setNoInsertLine(.T.)
	oModel:GetModel("ZEYDETAIL"):setNoDeleteLine(.T.)
	
	oModel:SetRelation( 'EE8DETAIL',;
                        {{ 'EE8_FILIAL'	, 'FwXFilial("EE8")'		},;   
                         { 'EE8_PEDIDO'	, 'EE7_PEDIDO'      }},;
                        EE8->(IndexKey(1));
                      )
	oModel:SetRelation( 'SC6DETAIL',;
                        {{ 'C6_FILIAL'	, 'FwXFilial("SC6")'		},;   
                         { 'C6_NUM'	, 'EE7_PEDFAT'      }},;
                        SC6->(IndexKey(1));
                      )
	oModel:SetRelation( 'ZEXDETAIL',;
                        {{ 'ZEX_FILIAL'	, 'FwXFilial("ZEX")'},;   
                         { 'ZEX_NUMERO'	, 'EE7_PEDFAT'      },;
						 { 'ZEX_PRODUT' , 'C6_PRODUTO'      }},;
                        ZEX->(IndexKey(1));
                      )
		
	oModel:SetRelation( 'ZEYDETAIL',;
                        {{ 'ZEY_FILIAL'	, 'FwXFilial("ZEY")'},;
						 { 'ZEY_NUMERO'	, 'EE7_PEDFAT'}},;
                        ZEY->(IndexKey(2));
                      )
	
	oModel:getModel("ZEXDETAIL"):setOptional(.T.)
	oModel:getModel("ZEYDETAIL"):setOptional(.T.)

	oModel:SetPrimaryKey({'EE7_FILIAL','EE7_PEDIDO'})

Return oModel

// --------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
	local oView
	local oModel	:= FWLoadModel('ADEEC009P')
    local oStruCab	:= FWFormStruct(2, 'EE7', {| cCampo | !('|' + AllTrim( cCampo ) + '|' $ EE7EXCLUS)	}) 
	local oStruEE8	:= FWFormStruct(2, 'EE8', {| cCampo |   "|" + AllTrim( cCampo ) + '|' $ EE8VISUAL	})
	local oStruSC6	:= FWFormStruct(2, 'SC6', {| cCampo |   "|" + AllTrim( cCampo ) + '|' $ SC6VISUAL	})
	local oStruZEX	:= FWFormStruct(2, 'ZEX', {| cCampo |   "|" + AllTrim( cCampo ) + '|' $ ZEXVISUAL	})
	local oStruZEY	:= FWFormStruct(2, 'ZEY', {| cCampo |   "|" + AllTrim( cCampo ) + '|' $ ZEYVISUAL	})
	
	Private lAltera		:= .T.
	
	oStruEE8:AddField(		;		// Ord. Tipo Desc. 
	     "DESCRICAO"		, ;		// [01] C   Nome do Campo 
	     "20"				, ;     // [02] C   Ordem 
	     "Descrição"		, ;     // [03] C   Titulo do campo 
	     AllTrim("")		, ;     // [04] C   Descricao do campo 
	     { "Tipo" }			, ;     // [05] A   Array com Help 
	     "C"				, ;     // [06] C   Tipo do campo 
	     "@!"				, ;     // [07] C   Picture 
	     NIL				, ;     // [08] B   Bloco de Picture Var 
	     ""					, ;     // [09] C   Consulta F3 
	     .F.				, ;     // [10] L   Indica se o campo é alteravel 
	     NIL				, ;     // [11] C   Pasta do campo 
	     NIL				, ;     // [12] C   Agrupamento do campo 
	     NIL				, ;     // [13] A   Lista de valores permitido do campo (Combo) 
	     NIL				, ;     // [14] N   Tamanho maximo da maior opção do combo 
	     NIL				, ;     // [15] C   Inicializador de Browse 
	     .T.				, ;     // [16] L   Indica se o campo é virtual 
	     NIL				, ;     // [17] C   Picture Variavel 
	     NIL				)  		// [19] N	Largura Fixa do campo
	
	oStruEE8:setProperty("EE8_SEQUEN"	, MVC_VIEW_ORDEM, "01")
	oStruEE8:setProperty("EE8_COD_I"	, MVC_VIEW_ORDEM, "02")
	oStruEE8:setProperty("DESCRICAO"	, MVC_VIEW_ORDEM, "03")
	oStruEE8:setProperty("EE8_DTENTR"	, MVC_VIEW_ORDEM, "04")
	oStruEE8:setProperty("EE8_SLDINI"	, MVC_VIEW_ORDEM, "05")
	oStruEE8:setProperty("EE8_UNPRC"	, MVC_VIEW_ORDEM, "06")
	oStruEE8:setProperty("EE8_PRECO"	, MVC_VIEW_ORDEM, "07")
	oStruEE8:setProperty("EE8_PRECOI"	, MVC_VIEW_ORDEM, "08")
	oStruEE8:setProperty("EE8_PRCTOT"	, MVC_VIEW_ORDEM, "09")
	oStruEE8:setProperty("EE8_UNIDAD"	, MVC_VIEW_ORDEM, "10")
	oStruEE8:setProperty("EE8_SLDATU"	, MVC_VIEW_ORDEM, "11")
	oStruEE8:setProperty("EE8_QE"		, MVC_VIEW_ORDEM, "12")
	oStruEE8:setProperty("EE8_EMBAL1"	, MVC_VIEW_ORDEM, "13")
	oStruEE8:setProperty("EE8_QTDEM1"	, MVC_VIEW_ORDEM, "14")
	oStruEE8:setProperty("EE8_PSLQUN"	, MVC_VIEW_ORDEM, "15")
	oStruEE8:setProperty("EE8_PSBRUN"	, MVC_VIEW_ORDEM, "16")
	oStruEE8:setProperty("EE8_POSIPI"	, MVC_VIEW_ORDEM, "17")
	oStruEE8:setProperty("EE8_TES"		, MVC_VIEW_ORDEM, "18")
	oStruEE8:setProperty("EE8_CF"		, MVC_VIEW_ORDEM, "19")
	oStruEE8:setProperty("EE8_PRCINC"	, MVC_VIEW_ORDEM, "20")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VW_CABEE7', oStruCab, 'EE7MASTER')
	oView:AddGrid('VW_ITEMEE8', oStruEE8, 'EE8DETAIL')
	oView:AddGrid('VW_ITEMSC6', oStruSC6, 'SC6DETAIL')
	oView:AddGrid('VW_ITEMZEX', oStruZEX, 'ZEXDETAIL')
	oView:AddGrid('VW_ITEMZEY', oStruZEY, 'ZEYDETAIL')
	
	oView:createHorizontalBox("H_GERAL"    ,100)
    
    oView:CreateFolder("PASTAS","H_GERAL")
    oView:AddSheet("PASTAS","ABA01","Pedido de Exportação")
    oView:AddSheet("PASTAS","ABA02","Dados de Embarque")

	oView:CreateHorizontalBox('MASTER', 70, , , "PASTAS", "ABA01")
	oView:CreateHorizontalBox('DETAIL1',30, , , "PASTAS", "ABA01")

	oView:CreateHorizontalBox('DETAIL2', 30, , , "PASTAS", "ABA02")
	oView:CreateHorizontalBox('DETAIL3', 40, , , "PASTAS", "ABA02")
	oView:CreateHorizontalBox('DETAIL4', 30, , , "PASTAS", "ABA02")
	
	oView:SetOwnerView('VW_CABEE7' , 'MASTER')                                                                                                 
	oView:SetOwnerView('VW_ITEMEE8', 'DETAIL1')
	oView:SetOwnerView('VW_ITEMSC6', 'DETAIL2')
	oView:SetOwnerView('VW_ITEMZEX', 'DETAIL3')
	oView:SetOwnerView('VW_ITEMZEY', 'DETAIL4')
	
	oView:EnableTitleView("VW_ITEMEE8"   , "Itens Processos de Exportação (EE8)")
	oView:EnableTitleView("VW_ITEMSC6"   , "Itens Pedidos de Venda (SC6)")
	oView:EnableTitleView("VW_ITEMZEX"   , "Registro de Produção (eData)")
	oView:EnableTitleView("VW_ITEMZEY"   , "Arquivos de Imagens")

	oView:SetDescription( "Pedidos de Exportação" )
	
	oView:SetViewCanActivate({|oView| fVieCanAc(oView)})
	
Return oView


Static Function fVieCanAc(oView)
	Local lRet 		:= .T.
	Local dDtentr	:= Stod("")
	
	If oView:GetOperation() ==  1 
		lRet	:= .T.
	// Insert
	ElseIf oView:GetOperation() == 3
		lRet	:= .F.
	//Update or Only Update.
	ElseIf oView:GetOperation() == 4 .OR. oView:GetOperation() == 6
		
		DbSelectArea("SC5")
        SC5->(DbsetOrder(1))

        if SC5->(DbSeek(xFilial("SC5")+EE7->EE7_PEDFAT))

			//LPM
			//if Empty(SC5->C5_NOTA) .AND. Empty(SC5->C5_ROTEIRO) .AND. Empty(SC5->C5_X_SQED)
            if Empty(SC5->C5_NOTA)
			    lRet := .T.
            else
                lRet := .F.
			    MsgAlert("[ADEEC009P-01] - Pedidos de Venda faturados ou integrados ao eData não podem ser alterados!")
            endif
		else
			MsgAlert("[ADEEC009P-02] - Não foi possível encontrar o pedido de venda criado no módulo de Faturamento!")
			lRet := .F.
		EndIf
		
	// Delete
	ElseIf oView:GetOperation() == 5
		lRet := .F.
	EndIf
	
Return lRet

static function fVldForm()
	Local lRet 		:= .T.
	Local dDtentr	:= Stod("")
	Local oView     := FWViewActive()
	Local oModel	:= FWModelActive()
	Local oModEE8	:= oModel:getModel("EE8DETAIL")

	If oView:GetOperation() ==  1 
		lRet	:= .T.
	// Insert
	ElseIf oView:GetOperation() == 3
		lRet	:= .F.
	//Update or Only Update.
	ElseIf oView:GetOperation() == 4 .OR. oView:GetOperation() == 6
		
		DbSelectArea("SC5")
        SC5->(DbsetOrder(1))

        if SC5->(DbSeek(xFilial("SC5")+EE7->EE7_PEDFAT))

            // LPM
			//if Empty(SC5->C5_NOTA) .AND. Empty(SC5->C5_ROTEIRO).AND. Empty(SC5->C5_X_SQED)
			if Empty(SC5->C5_NOTA)
			    lRet := .T.
				
				// Pergunta ao usuário se vai ser enviado o workflow de coleta.
				/*
				dbSelectArea("EE7")
				if !Empty(EE7->EE7_XWFNED)
					IF msgYesNo("Deseja reenviar o workflow de notificação de embarque?")
						If Reclock("EE7",.F.)
							EE7->EE7_XWFNEE := "N"
							MsUnLock("EE7")
						endif
					endif
				endif
				*/
				// Caso esteja roterizado as informações de datas de entrega e informações relacionadas a logística não
				// podem ser mais alteradas.
				/*
				if Empty(SC5->C5_ROTEIRO).AND. Empty(SC5->C5_X_SQED)
					//@history Chamado 8465 - Leonardo P. Monteiro    - 19/05/2021 - Permissão para a gravação e alteração da data de entrega nos processos de exportação.
					dDtentr     := oModEE8:getValue("EE8_DTENTR")

					For nI := 1 To oModEE8:Length()
							oModEE8:GoLine( nI )
							
							dDtentr	:= iif(oModEE8:getValue("EE8_DTENTR") < dDtentr .or. nI == 1, oModEE8:getValue("EE8_DTENTR"), dDtentr)
							
					next nI

					// Atualiza as datas de entrega do Pedido de Venda e a liberação(SC9).
					if Reclock("SC5",.F.)
						SC5->C5_DTENTR := dDtentr

						Msunlock("SC5")

						DBSELECTAREA("SC6")
						SC6->(DBSETORDER(1))
						if SC6->(DbSeek(xFilial("SC6")+EE7->EE7_PEDFAT))

							WHILE SC6->(!EOF()) .And. SC6->C6_NUM == EE7->EE7_PEDFAT
								if RECLOCK("SC6",.F.)
									SC6->C6_ENTREG	:= dDtentr
									SC6->(MsUnLock())

										DBSELECTAREA("SC9")
										SC9->(DBSETORDER(1))
										if SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM+SC6->C6_ITEM))
											WHILE SC9->(!EOF()); 
														.And. SC9->C9_FILIAL == SC5->C5_FILIAL; 
														.And. SC9->C9_PEDIDO == SC5->C5_NUM; 
														.And. SC9->C9_ITEM == SC6->C6_ITEM
												
												if Empty(SC9->C9_NFISCAL)
													RECLOCK("SC9",.F.)
														SC9->C9_DATENT	:= dDtentr
													SC9->(MsUnLock())
												endif
												
												SC9->(dbSkip())
											ENDDO
										endif

								endif

								SC6->(dbSkip())
							ENDDO
						endif

					endif

				endif
				*/
			else
                lRet := .F.
			    MsgAlert("[ADEEC009P-01] - Pedidos de Venda faturados ou integrados ao eData não podem ser alterados!")
            endif
		else
			MsgAlert("[ADEEC009P-02] - Não foi possível encontrar o pedido de venda criado no módulo de Faturamento!")
			lRet := .F.
		EndIf
		
	// Delete
	ElseIf oView:GetOperation() == 5
		lRet := .F.
	EndIf

return lRet

Static Function fAfterTTS(oModel)
	Local lRet 			:= .T.
	Local ALTERA		:= .T.

	lRet := fwformcommit(oModel)
	
	If EasyEntryPoint("EECAP100")
      MsAguarde({|| ExecBlock("EECAP100",.F.,.F.,{'GRV_PED'}) },"Aguarde","Gravando as informações no PV (Faturamento)...")
   	Endif

return lRet
