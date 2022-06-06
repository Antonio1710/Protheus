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
#INCLUDE "PROTHEUS.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include 'TOTVS.ch'
#INCLUDE "topconn.ch"
 #define CRLF Chr(13)+Chr(10)
/*/{Protheus.doc} ADMNT012R - Relatorio de Custo por OS / Eqto Exporta Excel
)
    @type  Function
    @author Tiago Stocco
    @since 20/07/2020
    @version TKT - 7571
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    @see (links_or_references) u_ADMNT012R()
    @Ticket 11502, Data 05/04/2021, Leonardo P. Monteiro, Adição do tipo do cliente na inclusão ou alteração;
	@Ticket 13241, Data 10/05/2021, TIAGO STOCCO, adição do solicitante
    @Ticket 13242, Data 26/05/2021, DENIS GUEDES, Compatibilizado o relatório para ser envia por email através de Schedule
    @Ticket 13242, Data 26/05/2021, DENIS GUEDES, Incluído a coluna ST1.T1_NOME no relatório
    @Ticket 13242, Data 02/06/2021, DENIS GUEDES, Incluído funcionalidade para copiar a planilha gerada para a pasta "Relatorio"
    @Ticket 69385, Data 25/04/2022, Everson     , Inclusão de OS em SS.
/*/

User Function ADFAT055P(aParam)

Local bProcess 		:= {|oSelf| Executa(oSelf) }
Local cPerg 		:= ""
Local aInfoCustom 	:= {}
Local cTxtIntro	    := "Rotina responsável pela importação de Cortes da Expedição"
local lSetEnv       := .f.

cPara      := ""
cAssunto   := "Cortes da Expedição"
cCorpo     := "Cortes da Expedição"
aAnexos    := {}
lMostraLog := .F.
lUsaTLS    := .T.

//Local cEmp 		:= "01"
//Local cFil 		:= "02"

		//RPCClearEnv()
		//RPCSetType(3)
		//RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })		

Private lJob          := IsBlind()
Private oProcess
Private dMVPAR01   
Private dMVPAR02   
Private cMVPAR03   
Private cMVPAR04  
Private czEMP
Private czFIL


If lJob
	RpcSetType(3)
	lSetEnv  := RpcSetEnv(aParam[1],aParam[2],,,"")
    czEMP    := aParam[1]   
    czFIL    := aParam[2]   
    
    PREPARE ENVIRONMENT EMPRESA czEMP FILIAL czFIL MODULO "FAT"
    cPara      :=  SuperGetMv('AD_FAT055P', .f. ,"antonio.filho@adoro.com.br" ) 
    
    oProcess := Executa()
Else
    oProcess := tNewProcess():New("ADFAT055P","Cortes da Expedição",bProcess,cTxtIntro,cPerg,aInfoCustom, .T.,5, "Cortes da Expedição", .T. )
Endif

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Custo por OS ')

Return

Static Function Executa(oProcess)

U_FAT055A_PRO()
U_FAT055B_MVC()

Return

User Function FAT055B_MVC()

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

	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.FAT055B_MVC" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.FAT055B_MVC" OPERATION 4 ACCESS 0

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
 USER Function FAT055A_PRO()

    Local _cAliasCortes := GetNextAlias()
    Local _aGetArea     := GetArea()
	Private aParamBox   := {}
    Private aRet        := {}

    //Parametro da consulta
    Aadd( aParamBox ,{1,"Data Carregamento De" ,dDatabase-1,"" ,'.T.',"",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Data CArregamento Ate",dDatabase-1,"" ,'.T.',"",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Horario De",Space(10) ,time() ,'.T.',"",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Horario Ate",Space(10) ,time() ,'.T.',"",'.T.',80,.F.})

    if ParamBox(aParamBox,"Parâmetros",@aRet)
    
        dDataIni := aRet[1] //Data Carga
        dDataFin := aRet[2] //Data Fechamento da Carga
        cHoraIni := aRet[3] //Hora Carga
        cHOraFin := aRet[4] //Hora Fechamento da Carga

        BeginSQL Alias _cAliasCortes
        
            SELECT DISTINCT PEDIDO_VENDA_ITEM.ID_PEDIVEND,                
                PEDIDO_VENDA.IE_PEDIVEND,                            
                CONVERT(VARCHAR(8), (PEDIDO_VENDA.DT_PEDIVEND), 112) DT_PEDIVEND,
                CONVERT(VARCHAR(8), (PEDIDO_VENDA.DT_ENTRPEDIVEND), 112) DT_ENTRPEDIVEND,
                PEDIDO_VENDA.DT_ENTRPEDIVEND,
                PEDIDO_VENDA.EMPRESA,                                
                PEDIDO_VENDA.ID_CLIENTE,                             
                CLIENTE.NM_CLIENTE,                                  
                CLIENTE.IE_CLIENTE,                                  
                PEDIDO_VENDA_ITEM.ID_MATEEMBA ID_PRODMATEEMBA,                  
                MATERIAL_EMBALAGEM_D.NM_PRODDEFIMATEEMBA,                  
                SISTEMA_FILIAL.NM_FILISIST,                          
                EXPEDICAO_CARGA.ID_CARGEXPE,                         
                TRANSPORTADOR_VEICULO.GN_PLACVEICTRAN,              
                PEDIDO_VENDA.DT_FATUPEDIVEND DT_FATUPEDIVEND, 
                PEDIDO_VENDA_ITEM.QN_EMBAITEMPEDIVEND + COALESCE(PEDIDO_VENDA_ITEM.QN_CAIXCORTITEMPEDIVEND, 0) QN_EMBAITEMPEDIVEND,  
                COALESCE(PEDIDO_VENDA_ITEM.QN_CAIXCORTITEMPEDIVEND, 0) QN_CAIXCORTITEMPEDIVEND,                                      
                PEDIDO_VENDA_ITEM.QN_EMBAITEMPEDIVEND QN_EMBALIQUITEMPEDIVEND,                                                       
                PEDIDO_VENDA_ITEM.QN_EMBAITEMPEDIVEND - COALESCE(QN_EMBAEXPEITEMPEDIVEND, 0) QN_CAIXCORTPLATITEM,                    
                COALESCE(QN_EMBAEXPEITEMPEDIVEND, 0) QN_EMBAEXPEITEMPEDIVEND,
                CONVERT(VARCHAR(8), (EXPEDICAO_CARGA.DT_CARGEXPE), 112) DT_CARGEXPE,
                CONVERT(VARCHAR(8), (EXPEDICAO_CARGA.DT_FECHCARGEXPE), 112) DT_FECHCARGEXPE,
                CONVERT(VARCHAR(8), EXPEDICAO_CARGA.DT_CARGEXPE, 8) HR_CARGEXPE,
                CONVERT(VARCHAR(8), EXPEDICAO_CARGA.DT_FECHCARGEXPE, 8) HR_FECHCARGEXPE
                FROM [LNKMIMS].[SMART].[dbo].[PEDIDO_VENDA_ITEM]
                    
                    JOIN [LNKMIMS].[SMART].[dbo].[PEDIDO_VENDA]
                        ON (PEDIDO_VENDA_ITEM.ID_PEDIVEND = PEDIDO_VENDA.ID_PEDIVEND)
                    
                    JOIN [LNKMIMS].[SMART].[dbo].[MATERIAL_EMBALAGEM_ALMO_ENDE] MATERIAL_EMBALAGEM
                        ON (PEDIDO_VENDA_ITEM.ID_MATEEMBA = MATERIAL_EMBALAGEM.ID_MATEEMBA)
                    
                    JOIN [LNKMIMS].[SMART].[dbo].[CLIENTE_GERAL] CLIENTE
                        ON (PEDIDO_VENDA.ID_CLIENTE = CLIENTE.ID_CLIENTE)
                    
                    JOIN [LNKMIMS].[SMART].[dbo].[DISTRIBUICAO_CENTRO]
                        ON (PEDIDO_VENDA.ID_CENTDIST = DISTRIBUICAO_CENTRO.ID_CENTDIST)
                    
                    JOIN [LNKMIMS].[SMART].[dbo].[SISTEMA_FILIAL]                            
                            ON (PEDIDO_VENDA.FILIAL = SISTEMA_FILIAL.FILIAL)
                    
                    JOIN [LNKMIMS].[SMART].[dbo].[VENDEDOR]
                            ON (PEDIDO_VENDA.ID_VENDEDOR = VENDEDOR.ID_VENDEDOR)
            
                     JOIN [LNKMIMS].[SMART].[dbo].[MATERIAL_EMBALAGEM_DEFINICAO] MATERIAL_EMBALAGEM_D
                        ON (MATERIAL_EMBALAGEM.ID_MATEEMBA = MATERIAL_EMBALAGEM_D.ID_DEFIMATEEMBA )

					LEFT JOIN [LNKMIMS].[SMART].[dbo].[MARCA]
                            ON (MATERIAL_EMBALAGEM_D.ID_MARCA = MARCA.ID_MARCA)
            
                    LEFT JOIN [LNKMIMS].[SMART].[dbo].[EXPEDICAO_CARGA]   
                            ON (PEDIDO_VENDA.ID_CARGEXPE = EXPEDICAO_CARGA.ID_CARGEXPE)
                    
                    LEFT JOIN [LNKMIMS].[SMART].[dbo].[CAMINHAO_PROGRAMACAO_ITEM]
                            ON (EXPEDICAO_CARGA.ID_ITEMPROGCAMI = CAMINHAO_PROGRAMACAO_ITEM.ID_ITEMPROGCAMI)
                    
                    LEFT JOIN [LNKMIMS].[SMART].[dbo].[TRANSPORTADOR_VEICULO]
                            ON (CAMINHAO_PROGRAMACAO_ITEM.ID_VEICTRAN = TRANSPORTADOR_VEICULO.ID_VEICTRAN)

                WHERE PEDIDO_VENDA.FL_STATPEDIVEND IN('FE', 'EX', 'ZR')
                    AND (COALESCE(PEDIDO_VENDA_ITEM.QN_CAIXCORTITEMPEDIVEND, 0) > 0
                        OR  (COALESCE(PEDIDO_VENDA_ITEM.QN_EMBAITEMPEDIVEND, 0) - COALESCE(QN_EMBAEXPEITEMPEDIVEND, 0)) > 0)
                    AND CONVERT(VARCHAR(8), (EXPEDICAO_CARGA.DT_CARGEXPE), 112) >= %Exp:DTOS(dDataini)%
                    AND CONVERT(VARCHAR(8), (EXPEDICAO_CARGA.DT_FECHCARGEXPE), 112) <= %Exp:DTOS(dDataFin)%
                    AND CONVERT(VARCHAR(8), EXPEDICAO_CARGA.DT_CARGEXPE, 8) >= %Exp:cHoraini%
                    AND CONVERT(VARCHAR(8), EXPEDICAO_CARGA.DT_FECHCARGEXPE, 8) <= %Exp:cHoraFin%
                FROM [LNKMIMS].[SMART].[dbo].[PEDIDO_VENDA_ITEM]
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
                    ZHF->ZHF_FILIAL := XFilial("ZHF")
                    ZHF->ZHF_PEDMIM := (_cAliasCortes)->ID_PEDIVEND				//Cód Pedido MIMS
                    ZHF->ZHF_PEDERP := (_cAliasCortes)->IE_PEDIVEND				//Cód Pedido ERP
                Else
                    RECLOCK("ZHF",.F.)
                EndIf    
                ZHF->ZHF_DTPEDI	:= STOD((_cAliasCortes)->DT_PEDIVEND)		//Data Pedido 
                ZHF->ZHF_DTENTP	:= STOD((_cAliasCortes)->DT_ENTRPEDIVEND)	//Data Digitação pedido
                ZHF->ZHF_EMPMIM	:= (_cAliasCortes)->EMPRESA					//Empresa MIMS
                ZHF->ZHF_CLIMIM	:= (_cAliasCortes)->ID_CLIENTE				//Código Cliente MIMS
                ZHF->ZHF_NMCLIM	:= (_cAliasCortes)->NM_CLIENTE				//Cliente
                ZHF->ZHF_CEXTCL := (_cAliasCortes)->IE_CLIENTE				//Cód. Ext. Cliente
                ZHF->ZHF_CODPRO := (_cAliasCortes)->ID_PRODMATEEMBA			//Cód Produto
                ZHF->ZHF_DESPRO	:= (_cAliasCortes)->NM_PRODMATEEMBA			//Descrição produto
                ZHF->ZHF_FILSIS	:= (_cAliasCortes)->NM_FILISIST				//Cód Ext. Cliente
                ZHF->ZHF_CARMIM := (_cAliasCortes)->ID_CARGEXPE				//Cód Carga MIMS
                ZHF->ZHF_PLACA	:= (_cAliasCortes)->GN_PLACVEICTRAN			//Placa
                ZHF->ZHF_DTFATU	:= (_cAliasCortes)->DT_FATUPEDIVEND			//Data faturamento
                ZHF->ZHF_EMBAPE	:= (_cAliasCortes)->QN_EMBAITEMPEDIVEND		//Embalagens do pedido
                ZHF->ZHF_EMBACO	:= (_cAliasCortes)->QN_CAIXCORTITEMPEDIVEND	//Embalagens cortadas (ferramenta)
                ZHF->ZHF_EMBAPD	:= (_cAliasCortes)->QN_EMBALIQUITEMPEDIVEND	//Embalagens pedidas
                ZHF->ZHF_EMBACP	:= (_cAliasCortes)->QN_CAIXCORTPLATITEM		//Embalagens cortadas (plataforma)
                ZHF->ZHF_EMBAEX	:= (_cAliasCortes)->QN_EMBAEXPEITEMPEDIVEND	//Embalagens expedidas
                ZHF->ZHF_DTCARE	:= STOD((_cAliasCortes)->DT_CARGEXPE)       //Data da Carga
                ZHF->ZHF_DFCARE := STOD((_cAliasCortes)->DT_FECHCARGEXPE)   //Data de Fechamento da Carga                                
                ZHF->ZHF_HRCARE	:= (_cAliasCortes)->HR_CARGEXPE             //Hora da Carga
                ZHF->ZHF_HFCARE := (_cAliasCortes)->HR_FECHCARGEXPE         //Hora de Fechamento da Carga                                
                ZHF->(MSUNLOCK())
                (_cAliasCortes)->(dbSkip())
            EndDo

        else
            
            MsgInfo("Na Tabela "+_cAliasCortes+" não há dados para importar", "Cortes de Expedição")

        EndIf
    
    EndIf

    (_cAliasCortes)->(dbCloseARea())
    RestArea(_aGetArea)
Return

