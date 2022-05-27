#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOPCONN.CH'
// #########################################################################################################
// Projeto: Projeto Banco de dados para confecção do BI
// Modulo : SIGAFAT
// Fonte  : ADFAT055P
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 20/05/22 | Antonio Domingos  | Cortes de Expedição                                        | 68089
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################

User Function ADFAT055P()

LOCAL oBrowse
PRIVATE aRotina		:= MenuDef()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cortes de Expedição')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZHF")
	oBrowse:SetDescription("Cortes de Expedição")
	
	oBrowse:Activate()
	
Return NIL

// #########################################################################################################
// Projeto: Projeto Banco de dados para confecção do BI
// Modulo : SIGAFAT
// Fonte  : MenuDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 20/05/22 | Antonio Domingos  | Cortes de Expedição                                       | 68089
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################

STATIC Function MenuDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADFAT055P" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ADFAT055P" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ADFAT055P" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ADFAT055P" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Importação" ACTION "U_FFAT055P" OPERATION 6 ACCESS 0

Return aRotina

// #########################################################################################################
// Projeto: Projeto Banco de dados para confecção do BI
// Modulo : SIGAFAT
// Fonte  : ModelDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 20/05/22 | Antonio Domingos  | Cortes de Expedição                                       | 68089
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################


STATIC Function ModelDef()

	LOCAL oModel
	LOCAL oStruZHF := FWFormStruct( 1, "ZHF", /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:SetDescription("Cortes de Expedição")

	oModel:AddFields("ZHFMASTER", /*cOwner*/, oStruZHF, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	oModel:SetPrimaryKey( {"ZHF_FILIAL","ZHF_PEDIDO" } )

Return oModel

// #########################################################################################################
// Projeto: Projeto Banco de dados para confecção do BI
// Modulo : SIGAFAT
// Fonte  : ViewDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 20/05/22 | Antonio Domingos      | Cortes de Expedição                                   | 68089
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################
STATIC Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStruZHF	:= FWFormStruct( 2, "ZHF" )

	oView := FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField("VIEW_ZHF", oStruZHF, "ZHFMASTER" )

	oView:CreateHorizontalBox("TELA" , 100 )

	oView:EnableTitleView("VIEW_ZHF" , "Cortes de Expedição" )

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk( { || .T. } )
Return oView


// #########################################################################################################
// Projeto: Projeto Banco de dados para confecção do BI
// Modulo : SIGAFAT
// Fonte  : ViewDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 20/05/22 | Antonio Domingos      | Cortes de Expedição                                   | 68089
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################
User Function FFAT055P()

	Local oView
	Local oModel	    := ModelDef()
	Local oStruZHF	    := FWFormStruct( 2, "ZHF" )
    Local _cAliasCortes := GetNextAlias()
    Local _aGetArea     := GetArea()
	
    //Parametro da consulta
    Data Carregamento De
    Data CArregamento Ate
    Horario De 
    Horario Ate

    BeginSQL Alias cNewAlias
	
        SELECT PEDIDO_VENDA_ITEM.ID_PEDIVEND,                       // Cód Pedido MIMS
        PEDIDO_VENDA.IE_PEDIVEND,                            // Cód Pedido ERP
        CONVERT(VARCHAR(8), (PEDIDO_VENDA.DT_PEDIVEND), 112) DT_PEDIVEND,         // Data Pedido 
        CONVERT(VARCHAR(8), (PEDIDO_VENDA.DT_ENTRPEDIVEND), 112) DT_ENTRPEDIVEND, // Data Digitação pedido
        PEDIDO_VENDA.EMPRESA,                                // Empresa MIMS
        PEDIDO_VENDA.ID_CLIENTE,                             // Código Cliente MIMS
        CLIENTE.NM_CLIENTE,                                  // Cliente
        CLIENTE.IE_CLIENTE,                                  // Cód. Ext. Cliente
        PEDIDO_VENDA_ITEM.ID_PRODMATEEMBA,                  // Cód Produto
        //--MATERIAL_EMBALAGEM.NM_PRODMATEEMBA,                  // Descrição produto
        SISTEMA_FILIAL.NM_FILISIST,                          // Cód Ext. Cliente
        EXPEDICAO_CARGA.ID_CARGEXPE,                         // Cód Carga MIMS
        TRANSPORTADOR_VEICULO.GN_PLACVEICTRAN,               // Placa
        PEDIDO_VENDA.DT_FATUPEDIVEND DT_FATUPEDIVEND, // Data faturamento
        PEDIDO_VENDA_ITEM.QN_EMBAITEMPEDIVEND + COALESCE(PEDIDO_VENDA_ITEM.QN_CAIXCORTITEMPEDIVEND, 0) QN_EMBAITEMPEDIVEND,  // Embalagens do pedido
        COALESCE(PEDIDO_VENDA_ITEM.QN_CAIXCORTITEMPEDIVEND, 0) QN_CAIXCORTITEMPEDIVEND,                                      // Embalagens cortadas (ferramenta)
        PEDIDO_VENDA_ITEM.QN_EMBAITEMPEDIVEND QN_EMBALIQUITEMPEDIVEND,                                                       // Embalagens pedidas
        PEDIDO_VENDA_ITEM.QN_EMBAITEMPEDIVEND - COALESCE(QN_EMBAEXPEITEMPEDIVEND, 0) QN_CAIXCORTPLATITEM,                    // Embalagens cortadas (plataforma)
        COALESCE(QN_EMBAEXPEITEMPEDIVEND, 0) QN_EMBAEXPEITEMPEDIVEND                                                         // Embalagens expedidas
    FROM [LNKMIMS].[SMART].[dbo].[PEDIDO_VENDA_ITEM]
                
                JOIN [LNKMIMS].[SMART].[dbo].[PEDIDO_VENDA]
                ON (PEDIDO_VENDA_ITEM.ID_PEDIVEND = PEDIDO_VENDA.ID_PEDIVEND)
                
                //--JOIN [LNKMIMS].[SMART].[dbo].[MATERIAL_EMBALAGEM_ALMO_ENDE] MATERIAL_EMBALAGEM
                //  --ON (PEDIDO_VENDA_ITEM.ID_MATEEMBA = MATERIAL_EMBALAGEM.ID_MATEEMBA)
                
                JOIN [LNKMIMS].[SMART].[dbo].[CLIENTE_GERAL] CLIENTE
                ON (PEDIDO_VENDA.ID_CLIENTE = CLIENTE.ID_CLIENTE)
                
                JOIN [LNKMIMS].[SMART].[dbo].[DISTRIBUICAO_CENTRO]
                ON (PEDIDO_VENDA.ID_CENTDIST = DISTRIBUICAO_CENTRO.ID_CENTDIST)
                
                JOIN [LNKMIMS].[SMART].[dbo].[SISTEMA_FILIAL]                            
                ON (PEDIDO_VENDA.FILIAL = SISTEMA_FILIAL.FILIAL)
                
                JOIN [LNKMIMS].[SMART].[dbo].[VENDEDOR]
                ON (PEDIDO_VENDA.ID_VENDEDOR = VENDEDOR.ID_VENDEDOR)
        
                //--LEFT JOIN [LNKMIMS].[SMART].[dbo].[MARCA]
                        //--ON (MATERIAL_EMBALAGEM.ID_MARCA = MARCA.ID_MARCA)
        
                LEFT JOIN [LNKMIMS].[SMART].[dbo].[EXPEDICAO_CARGA]   
                        ON (PEDIDO_VENDA.ID_CARGEXPE = EXPEDICAO_CARGA.ID_CARGEXPE)
                
                LEFT JOIN [LNKMIMS].[SMART].[dbo].[CAMINHAO_PROGRAMACAO_ITEM]
                        ON (EXPEDICAO_CARGA.ID_ITEMPROGCAMI = CAMINHAO_PROGRAMACAO_ITEM.ID_ITEMPROGCAMI)
                
                LEFT JOIN [LNKMIMS].[SMART].[dbo].[TRANSPORTADOR_VEICULO]
                        ON (CAMINHAO_PROGRAMACAO_ITEM.ID_VEICTRAN = TRANSPORTADOR_VEICULO.ID_VEICTRAN)

            WHERE PEDIDO_VENDA.FL_STATPEDIVEND IN('FE', 'EX', 'ZR')
                AND (COALESCE(PEDIDO_VENDA_ITEM.QN_CAIXCORTITEMPEDIVEND, 0) > 0
                    OR  (COALESCE(PEDIDO_VENDA_ITEM.QN_EMBAITEMPEDIVEND, 0) - COALESCE(QN_EMBAEXPEITEMPEDIVEND, 0)) > 0)
    EndSQl

    dbSelectArea(_cAliasCortes)
    (_cAliasCortes)->(dbGotop())

    If !(_cAliasCortes)->(Eof())
        While !(_cAliasCortes)->(Eof())
            dbSelectArea('ZHF')
            dbSetOrder(1)
            dbSeek(xFilial("ZHF"))
            If ZHF->(Eof())
                RECLOCK("ZHF",.T.)
                ZHF->ZHF_FILIAL     := XFilial("ZHF")
                ZHF->ZHF_PEDMIMS 	:= (_cAliasCortes)->ID_PEDIVEND				//Cód Pedido MIMS
                ZHF->ZHF_PEDERP  	:= (_cAliasCortes)->IE_PEDIVEND				//Cód Pedido ERP
            Else
                RECLOCK("ZHF",.F.)
            EndIf    
            ZHF->ZHF_DTPEDID	:= STOD((_cAliasCortes)->DT_PEDIVEND)		//Data Pedido 
            ZHF->ZHF_DTDIGPD	:= STOD((_cAliasCortes)->DT_ENTRPEDIVEND)	//Data Digitação pedido
            ZHF->ZHF_EMPMIMS	:= (_cAliasCortes)->EMPRESA					//Empresa MIMS
            ZHF->ZHF_CLIMIMS	:= (_cAliasCortes)->ID_CLIENTE				//Código Cliente MIMS
            ZHF->ZHF_CLIENTE	:= (_cAliasCortes)->NM_CLIENTE				//Cliente
            ZHF->ZHF_CEXTCLI 	:= (_cAliasCortes)->IE_CLIENTE				//Cód. Ext. Cliente
            ZHF->ZHF_CODPROD 	:= (_cAliasCortes)->ID_PRODMATEEMBA			//Cód Produto
            //ZHF->ZHF_DESPROD	:= (_cAliasCortes)->NM_PRODMATEEMBA			//Descrição produto
            ZHF->ZHF_FILSIST	:= (_cAliasCortes)->NM_FILISIST				//Cód Ext. Cliente
            ZHF->ZHF_CARMIMS 	:= (_cAliasCortes)->ID_CARGEXPE				//Cód Carga MIMS
            ZHF->ZHF_PLACA		:= (_cAliasCortes)->GN_PLACVEICTRAN			//Placa
            ZHF->ZHF_DTFATUR	:= (_cAliasCortes)->DT_FATUPEDIVEND			//Data faturamento
            ZHF->ZHF_EMBAPED	:= (_cAliasCortes)->QN_EMBAITEMPEDIVEND		//Embalagens do pedido
            ZHF->ZHF_EMBACOR	:= (_cAliasCortes)->QN_CAIXCORTITEMPEDIVEND	//Embalagens cortadas (ferramenta)
            ZHF->ZHF_EMBAPDI	:= (_cAliasCortes)->QN_EMBALIQUITEMPEDIVEND	//Embalagens pedidas
            ZHF->ZHF_EMBACPL	:= (_cAliasCortes)->QN_CAIXCORTPLATITEM		//Embalagens cortadas (plataforma)
            ZHF->ZHF_EMBAEXP	:= (_cAliasCortes)->QN_EMBAEXPEITEMPEDIVEND	//Embalagens expedidas
            //ZHF->ZHF_CODIMOT	//Codigo Descrição do Motivo
            //ZHF->ZHF_DESCMOT  //Descrição do Motivo
            //ZHF->ZHF_OBSERVA  //Observação Campo Livre 
            ZHF->(MSUNLOCK())
            (_cAliasCortes)->(dbSkip())
        EndDo

    else
        
        MsgInfo("Na Tabela "+_cAliasCortes+" não há dados para importar", "Cortes de Expedição")

    EndIf

    (_cAliasCortes)->(dbCloseARea())

Return

