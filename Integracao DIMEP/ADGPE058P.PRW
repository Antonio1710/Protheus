#INCLUDE "PROTHEUS.CH"  
#INCLUDE "AP5MAIL.CH"     
#INCLUDE "rwmake.ch"  
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'  
#INCLUDE "FILEIO.CH"

/*{Protheus.doc} User Function ADGPE058P
	Programa de Manutenção entre Protheus X Dimep Marcação de Terceiros
	@type  Function
	@author WILLIAM COSTA
	@since 12/06/2016
	@version 01
	@history TICKET  224    - William Costa   - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
*/	

USER FUNCTION ADGPE058P()
         
    Local aArea   	  := GetArea()  
    Local oBrowse   
    Local cFiltro     := ''         
    Local cFunNamBkp  := FunName()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de Manutenção entre Protheus X Dimep Marcação de Terceiros')

	IF !(__cUserId $ GetMv("MV_#USUTER",,"000000"))
	
		MsgStop("OLÁ " + Alltrim(cUserName) + ", Você não tem permissão de Utilizar essa Rotina", "ADGPE058P-01 MV_#USUTER")
		RETURN(NIL)
	
	ENDIF
    
	SetFunName("ADGPE058P")
	
	// Instanciamento da Classe de Browse 
	oBrowse := FWMBrowse():New() 
	 
	// Definição da tabela do Browse 
	oBrowse:SetAlias('ZG1') 
	 
	// Definição da legenda 
	//oBrowse:AddLegend( "!EMPTY(ZB7_CODDE) .AND. !EMPTY(ZB7_CODPAR)", "RED", "COD EAN AJUSTADO"  ) 
	 
	// Titulo da Browse 
	oBrowse:SetDescription('Manutenção Horários de Terceiros') 
	 
	// Opcionalmente pode ser desligado a exibição dos detalhes 
	//oBrowse:DisableDetails() 
	 
	// Ativação da Classe 
	oBrowse:Activate() 
	        
	SetFunName("cFunNamBkp")
	RestArea(aArea)
	 
Return(NIL)

Static Function ModelDef() 
               
	// Cria a estrutura a ser usada no Modelo de Dados 
	Local oStruZG1    := FWFormStruct( 1,'ZG1')
	Local oModel         // Modelo de dados que será construído
	
	// Cria o objeto do Modelo de Dados 
	oModel := MPFormModel():New("_GPE058P",/*bPreVld*/,{|oModel| u_BTOKGPE058P(oModel)},/*bCommit */,/*bCancel*/ )
	 
	// Adiciona ao modelo um componente de formulário 
	oModel:AddFields('ZG1MASTER', /*cOwner*/, oStruZG1)
	
	oModel:SetPrimaryKey({"ZG1_FILIAL", "ZG1_IDPROT"})       
	        
	// Adiciona a descrição do Modelo de Dados 
	oModel:SetDescription('Manutenção Horários de Terceiros')
	 
	// Adiciona a descrição do Componente do Modelo de Dados 
	oModel:GetModel('ZG1MASTER'):SetDescription('Manutenção Horários de Terceiros')  
    
	
	// Editando caracteristicas do dicionario
	oStruZG1:SetProperty('ZG1_MAT'   ,MODEL_FIELD_WHEN ,{|oModel| oModel:GetOperation() == 3 })
	oStruZG1:SetProperty('ZG1_DATA'  ,MODEL_FIELD_WHEN ,{|oModel| oModel:GetOperation() == 3 })
	oStruZG1:SetProperty('ZG1_HORA'  ,MODEL_FIELD_WHEN ,{|oModel| oModel:GetOperation() == 3 })
	oStruZG1:SetProperty('ZG1_PREFIX',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,'MAN','')})
	oStruZG1:SetProperty('ZG1_IDPROT',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,u_BUSCAIDPRO(),'')})
	oStruZG1:SetProperty('ZG1_LOGACE',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,999999,0)})
	oStruZG1:SetProperty('ZG1_TPAUTE',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,1,0)})
	oStruZG1:SetProperty('ZG1_CDGRUP',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,12,0)})
	oStruZG1:SetProperty('ZG1_DSGRUP',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,"Ponto Terceiros Manutenção",'')})
	oStruZG1:SetProperty('ZG1_AORIGE',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,12,0)})
	oStruZG1:SetProperty('ZG1_DAORIG',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,"PONTO TERCEIROS",'')})
	oStruZG1:SetProperty('ZG1_ADESTI',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,12,0)})
	oStruZG1:SetProperty('ZG1_DADEST',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,"PONTO TERCEIROS",'')})
	oStruZG1:SetProperty('ZG1_CDEQUI',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,19,0)})
	oStruZG1:SetProperty('ZG1_DEQUIP',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,"TERCEIROS ENTRADA",'')})
	oStruZG1:SetProperty('ZG1_NUEQUI',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,15,0)})
	oStruZG1:SetProperty('ZG1_TPEVEN',MODEL_FIELD_INIT ,{|oModel|IIF(oModel:GetOperation() == 3,99,0)})
	oStruZG1:SetProperty('ZG1_MAT'   ,MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "U_VALZG1MAT(M->ZG1_MAT)" ))

Return oModel     

Static Function ViewDef()                                                         

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
	Local oModel := FWLoadModel('ADGPE058P')        
	
	// Cria a estrutura a ser usada na View 
	Local oStruZG1 := FWFormStruct( 2,'ZG1') 
	 
	// Interface de visualização construída 
	Local oView   
	
	// Cria o objeto de View 
	oView := FWFormView():New() 
	 
	// Define qual o Modelo de dados será utilizado na View 
	oView:SetModel( oModel ) 
    
	// Adiciona no nosso View um controle do tipo formulário  
	// (antiga Enchoice) 
	oView:AddField('VIEW_ZG1',oStruZG1,'ZG1MASTER') 
	   
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox('TELA',100) 
	
	// Relaciona o identificador (ID) da View com o "box" para exibição 
	oView:SetOwnerView('VIEW_ZG1','TELA')  
	
	//Colocando título do formulário
	
	oView:EnableTitleView('VIEW_ZG1','Manutenção Horários de Terceiros')  
	
    //Força o fechamento da janela na confirmação
	
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	
	oView:SetOwnerView("VIEW_ZG1","TELA")
	
Return oView 

Static Function MenuDef() 

	Local aRotina := {}  
	
	ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.ADGPE058P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.ADGPE058P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.ADGPE058P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.ADGPE058P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    
Return aRotina     

USER FUNCTION BTOKGPE058P(oModel)

	Local lRet     := .T.
	Local aArea    := GetArea()
	Local oView    := FWViewActive()
	Local aAreaZG1 := ZG1->(GetArea())

	IF oModel:GetOperation() == 4 //ALTERAR
	
		IF ZG1->ZG1_SENTID <> oModel:GetValue('ZG1MASTER', 'ZG1_SENTID')

			IF MSGNOYES("OLÁ " + Alltrim(cUserName)                 + CHR(10) + CHR(13)+;
						"Identificamos que você quer alterar o Sentido desse Apontamento" + CHR(10) + CHR(13)+;
						" Nesse caso você tem certeza que quer alterar sentido, todas as outras passagens desse terceiro serão ajustadas?", "ADGPE058P-01")

				SqlALTZG1(oModel:GetValue('ZG1MASTER', 'ZG1_IDPROT'),oModel:GetValue('ZG1MASTER', 'ZG1_MAT'))

				While TRB->(!EOF())

					DbSelectArea("ZG1") 
					ZG1->(DbSetOrder(1))
					ZG1->(DbGoTop()) 
					IF DbSeek(FWxFilial("ZG1") + CVALTOCHAR(TRB->ZG1_IDPROT),.F.)

						IF ZG1->ZG1_IDPROT == oModel:GetValue('ZG1MASTER', 'ZG1_IDPROT')

							GRAVARLOG(Date(),TIME(),cUserName,"IF ALTERAÇÃO DIMEP BATIDA MANUTENÇÃO","PORTARIA","ADGPE058P",;
                					   "Código Batida:" + TRB->ZG1_IDPROT + " de: " + ZG1->ZG1_SENTID + " para: " + oModel:GetValue('ZG1MASTER', 'ZG1_SENTID'),ComputerName(),LogUserName())

							RECLOCK("ZG1",.F.)

								ZG1->ZG1_SENTID := oModel:GetValue('ZG1MASTER', 'ZG1_SENTID')

							MSUNLOCK()

						ELSE

							GRAVARLOG(Date(),TIME(),cUserName,"ELSE ALTERAÇÃO DIMEP BATIDA MANUTENÇÃO","PORTARIA","ADGPE058P",;
                					   "Código Batida:" + TRB->ZG1_IDPROT + " de: " + ZG1->ZG1_SENTID + " para: " + oModel:GetValue('ZG1MASTER', 'ZG1_SENTID'),ComputerName(),LogUserName())

							RECLOCK("ZG1",.F.)

								ZG1->ZG1_SENTID := IIF(ZG1->ZG1_SENTID == '1','2','1')

							MSUNLOCK()
						ENDIF
					ENDIF
					TRB->(dbSkip())
	
				ENDDO //FECHA WHILE DO TRB
				
				TRB->(dbCloseArea()) 

				MSGINFO("Todos os Sentidos do Terceiros foi alterado", "ADGPE058P-02")
				

			ELSE // QUANDO ESCOLHE NÃO NA PERGUNTA

				oModel:SetValue( 'ZG1MASTER', 'ZG1_SENTID', ZG1->ZG1_SENTID)
				oView:Refresh()
				Help(NIL, NIL, "ADGPE058P-03", NIL, "O campo não foi alterado",1, 0, NIL, NIL, NIL, NIL, NIL, {"Alterar o campo de Sentido"})
				lRet := .F. // não deixa alterar o sentido

			ENDIF		 
		ENDIF
	ENDIF

	RestArea(aArea)
	RestArea(aAreaZG1)

RETURN(lRet)

USER FUNCTION BUSCAIDPRO()

    Local cId      := '0000000000000001'
	Local aArea    := GetArea()
	Local aAreaZG1 := ZG1->(GetArea())

	SqlZG1()
	While TRC->(!EOF())

		cId := STRZERO(VAL(SUBSTR(TRC->ZG1_IDPROT,4,13)) + 1,16)

	TRC->(dbSkip())
		
	ENDDO //FECHA WHILE DO TRC
	
	TRC->(dbCloseArea())
	
	RestArea(aArea)
	RestArea(aAreaZG1) 

RETURN(cId)

USER FUNCTION VALZG1MAT(cMAT)

	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local aArea    := GetArea()
	Local aAreaZG1 := ZG1->(GetArea())

	SqlMatDimep(cMAT)
	IF TRD->(!EOF())

		oModel:SetValue( 'ZG1MASTER', 'ZG1_NOMEPE', ALLTRIM(TRD->NM_PESSOA))
		oModel:SetValue( 'ZG1MASTER', 'ZG1_CDESTR', VAL(TRD->CD_ESTRUTURA_ORGANIZACIONAL))
		oModel:SetValue( 'ZG1MASTER', 'ZG1_NMESTR', ALLTRIM(TRD->NM_ESTRUTURA))
		lRet := .T.

	ELSE

		Help(NIL, NIL, "ADGPE058P-04", NIL, "CPF não é válido",1, 0, NIL, NIL, NIL, NIL, NIL, {"Provavelmente o CPF informado pode ser: Inválido, Não é um Terceiro,está demitido ou afastado no Dimep, verifique!!!"})
		lRet := .F.

	ENDIF
	TRD->(dbCloseArea())
	
	RestArea(aArea)
	RestArea(aAreaZG1) 

Return(lRet)

STATIC FUNCTION GRAVARLOG(dDate,cTime,cUser,cLog,cModulo,cRotina,cParamer,cEquipam,cUserRed)

    Local aArea := GetArea()

    //log de alteração de data de entrega	
    DbSelectArea("ZG2")
    IF RecLock("ZG2",.T.)//incluido if para certificar que o registro foi travado em 23/08/2017 por Adriana 

        Replace ZG2_FILIAL 	WITH xFilial("ZG2")
        Replace ZG2_DATA 	WITH dDate
        Replace ZG2_HORA 	WITH cTime
        Replace ZG2_USUARI	WITH UPPER(Alltrim(cUser))
        Replace ZG2_LOG	    WITH ALLTRIM(cLog)
        Replace ZG2_MODULO	WITH cModulo
        Replace ZG2_ROTINA	WITH cRotina
        Replace ZG2_PARAME  WITH ALLTRIM(cParamer)
        Replace ZG2_EQUIPA  WITH UPPER(Alltrim(cEquipam))
        Replace ZG2_USURED  WITH UPPER(Alltrim(cUserRed))
        ZG2->(MsUnlock())    

    ENDIF

    RestArea(aArea)


RETURN(NIL)

STATIC FUNCTION SqlALTZG1(cIdProtheus,cMat)

	cFilAtu := FWXFILIAL("ZG1")

	BeginSQL Alias "TRB"
			%NoPARSER% 
				 SELECT ZG1_IDPROT
				   FROM %TABLE:ZG1%
				  WHERE ZG1_FILIAL  = %EXP:cFilAtu%
				    AND ZG1_IDPROT >= %EXP:cIdProtheus%
					AND ZG1_MAT     = %EXP:cMat%
					AND D_E_L_E_T_ <> '*'

	EndSQl

RETURN(NIL)

STATIC FUNCTION SqlZG1()

    BeginSQL Alias "TRC"
			%NoPARSER% 
				 SELECT TOP(1) ZG1_IDPROT
                    FROM %TABLE:ZG1%
                        
                    ORDER BY ZG1_IDPROT DESC 
	EndSQl          

RETURN(NIL)

STATIC FUNCTION SqlMatDimep(cMat)

    BeginSQL Alias "TRD"
			%NoPARSER% 
				 SELECT CONVERT(VARCHAR,NU_MATRICULA) AS NU_MATRICULA,
				        NM_PESSOA,
						CONVERT(VARCHAR,PESSOA.CD_ESTRUTURA_ORGANIZACIONAL) AS CD_ESTRUTURA_ORGANIZACIONAL,
						NM_ESTRUTURA 
				   FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA] PESSOA 
			 INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] ESTRUTURA_ORGANIZACIONAL 
			         ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL 
					AND CD_ESTRUTURA_RELACIONADA = 1223 
				  WHERE NU_MATRICULA       = %EXP:cMat%
				    AND CD_SITUACAO_PESSOA = 11 
	EndSQl          

RETURN(NIL)
