#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"   
#Include "FINC030.CH"
#Include "AP5mail.ch"

Static cNfs	 	:= "" 
Static nTipoFrt	:= 0 

/*/{Protheus.doc} User Function ADLOG040P
	Realiza manutenção em movimento de frete gerado.
	@type  Function 
	@author Ricardo Lima
	@since 14/11/2018
	@version version
	@history 11/02/2019, Ricardo Lima, Ch:044314- Mostra as notas que pertence ao frete gerado.               
	@history 14/03/2019, Everson, Ch:044314 Adicionada validaçãoes na inclusão e alteração de cadastro.     
	@history 15/03/2019, Everson, Ch:044314 Melhoria para o vincular nota fiscal de saída à ocorrência.     
	@history 18/03/2019, Everson, Ch:044314 Tratamento para cálculo do pedágio.                             
	@history 19/03/2019, Everson, Ch:044314 Tratamento para envio de lançamento para aprovação.             
	@history 20/03/2019, Everson, Ch:044314 Tratamento para lançamento de desconto de transportador.        
	@history 21/03/2019, Everson, Ch:044314 Adicionados campos de cidade,peso e volume na consulta de NF.   
	@history 28/03/2019, Everson, Ch:044314 Alterado índice e adicionada a origem do lançamento na ZC7.     
	@history 23/04/2019, Everson, Ch:044314 Criada consulta de descontos aplicados a transportadora.        
	@history 26/04/2019, Everson, Ch:044314 Corrigida rotina de exibição das notas fiscais de saída.        
	@history 08/05/2019, Everson, Ch:044314 Adicionada exportação de CSV na conferência de descontos.       
	@history 14/05/2019, Everson, Ch:044314 Adicionada rotina de fechamento e estorno de fechamento de frete.
	@history 15/05/2019, Everson, Ch:044314 Tratamento para o histórico do desconto de transportador.        
	@history 23/05/2019, Everson, Ch:044314 Acrescentada a opção de pesquisa no aRotina.                     
	@history 29/05/2019, Everson, Ch:044314 Adicionado parâmetro com data de fechamento de frete.            
	@history 12/06/2019, Everson, Ch:044314 Tratamento para o histórico do desconto de transportador.        
	@history 25/06/2019, Everson, Ch:044314 Rotina para visualizar CT-e e MDF-e emitidos.                    
	@history 26/06/2019, Everson, Ch:044314 Rotina para geração de pedido de compra diariamente.             
	@history 02/07/2019, Everson, Ch:044314 Adicionado cálculo de desconto de manutenção da bomba de abastec.
	@history 25/07/2019, Everson, Ch:044314 Alterada lógica da rotina de fechamento de frete.                
	@history 26/07/2019, Everson, Ch:044314 Corrigido script de atualização da tabela ZFA.                   
	@history 30/07/2019, Everson, Ch:044314 Inclusão de TES na geração do pedido de compra.                  
	@history 31/07/2019, Everson, Ch:044314 Adicionada rotina para lançamento de NDF no fechamento de período
	@history 01/08/2019, Everson, Ch:044314 Corrigido script sql para conferência de fechamento de frete.    
	@history 02/08/2019, Everson, Ch:044314 Adicionado chamada do relatório de fechamento enviado aos transportadores.                                                                                              
	@history 06/08/2019, Everson, Ch:044314 Adicionado parâmetros para geração de NDF no fechamento de frete.
	@history 09/08/2019, Everson, Ch:044314 Tratamento para visualizar notas de fornecedores.                
	@history 14/08/2019, Everson, Ch:044314 Tratamento para cálculo do fechamento de frete.                  
	@history 15/08/2019, Everson, Ch:044314 Tratamento para cálculo do fechamento de frete com acréscimo de ICMS.                                                                                                    
	@history 26/08/2019, Everson, Ch:044314 Tratamento para considerar o valor cheio do adiantamento.        
	@history 27/08/2019, Everson, Ch:044314 Tratamento para considerar o valor de CT-e no adiantamento.      
	@history 28/08/2019, Everson, Ch:044314 Removida validação de roteiro para fechamento zerado ou negativo.
	@history 03/09/2019, Everson, Ch:044314 Alterado cálculo do valor de abastecimento                      
	@history 01/10/2019, Everson, Ch:044314 Adicionado de até para geração de pedido de compra.             
	@history 02/10/2019, Everson, Ch:044314 Tratamento para condição de pagamento de pedido de compra de fechamento.                                                                                               
	@history 02/10/2019, Everson, Ch:044314 Removido RollBack.                                              
	@history 10/10/2019, Everson, Ch:044314 Tratamento para identificação de pedido de fechamento e rotina 
	para exibição de CT-e de fechamento, criado totalizadores na interface de fechamento.                   
	@history 14/10/2019, Everson, Ch:044314 Removida mensagem de geração pedido de compra.                   
	@history 18/10/2019, Everson, Ch:052666 Adicionadas datas de emissão, vencimento e baixa na tela de conferência de descontos.
	@history 05/11/2019, Everson, Ch:029058 Alterações para contemplar o controle de frete de frango vivo. 
	@history 06/11/2019, Everson, Ch:029058 Tratamento para não validar a carga, quando for lançamento por rotina automática.  
	@history 07/11/2019, Everson, Ch:029058 Corrigida validação de carga.
	@history 26/11/2019, Everson, Ch:029058 Adicionada validação de valor na importação de CSV.   
	@history 27/11/2019, Everson, Ch:029058 Alterado filtro inicial do programa. 
	@history 28/11/2019, Everson, Ch:029058 Tratamento para lançamento automático. 
	@history 04/12/2019, Everson, Ch:029058 Correção importação de combustível e fechamento de frete.   
	@history 06/12/2019, Everson, Ch:029058 Adicionados checagem se há transação aberta e logs.   
	@history 09/12/2019, Everson, Ch:029058 Adicionado tratamento para exclusão de registro de frete. 
	@history 12/12/2019, Everson, Ch:029058 Tratamento para campo ZFK_ROTEIR.   
	@history 13/12/2019, Everson, Ch:029058 Tratamento para campo ZFK_ROTEIR.   
	@history 06/01/2020, Everson, Ch:054680 Tratamento para exclusão de registro de frete.     
	@history 17/01/2020, Everson, Ch:054941 Tratamento para alteração e exclusão de registros.      
	@history 21/01/2020, Everson, Ch:054941 Tratamento para geração de pedido de compra para frete de ovo e pintinhos. 
	@history 23/01/2020, Everson, Ch:054941 Tratametno para registros de fechamento.  
	@history 24/01/2020, Everson, Ch:054941 Tratametno para exclusão de registros de fechamento. 
	@history 03/02/2020, Everson, Ch:T.I. Correção na conferência de registro de fechamento já gerado.   
	@history 27/02/2020, Everson, Ch:053926 Tratamento para considerar lançamento de abastecimento do sistema WinFleet.   
	@history 28/02/2020, Everson, Ch:053926 Correção do erro de estorno de abastecimento.    
	@history 06/03/2020, Everson, Ch:054941 Tratamento para geração de pedido de compra para frete de ovos. 
	@history 06/03/2020, Everson (2), Ch:054941 Corrigidos registros que vão para aprovação.    
	@history 12/03/2020, Everson, Ch: 053926 - Tratamento para importação de registros de abastecimento que não estejam bloqueados.  
	@history 17/03/2020, Everson, Ch: 054941 - Tratamento para que seja exibida a descrição do lote na geração de pedido de compra de frete de ovo.    
	@history 23/03/2020, Everson, Ch: 054941 - Tratamento para importação de todos os registros de abastecimento.   
	@history 06/05/2020, Everson, Ch: 057974 - Tratamento para quando houver alteração de transportadora antes do fechamento do período.   
	@history 02/06/2020, Everson, Ch: TI - Retirada validação de geração de NDF.    
	@history 03/06/2020, Everson, Ch: TI - Adicionado filtro na importação de abastecimentos.     
	@history 25/06/2020, Everson, Ch: 058332, Adicionada funcionalidade para importação de desconto por co-participação no seguro de carga. 
	@history 02/07/2020, Everson, Ch: 059405, Adicionado tratamento para quando há alteração de transportadora antes do fechamento do período.                            
	@history 20/07/2020, Everson, Ch: TI, Tratamento pra checar se há documento fiscal vinculado apenas para registros que não tem restrição de alteração/exclusão.
	@history 21/07/2020, Everson, Ch: TI, Tratamento pra checar se há documento fiscal vinculado apenas para registros que não tem restrição de alteração/exclusão.
	@history 05/08/2020, Everson, Ch: TI, Tratamento de duplicidade de numeração de registro.
	@history 11/08/2020, Everson, Ch: 059326, Tratamento para geração de registros de frete na Ceres.
	@history 28/08/2020, Everson, Ch: 060994, Tratamento para carregar centro de custo, lote e descrição de lote da tabela ZCN, na geração de pedidos de compra, quando a nota gera duplicata.
	@history 30/09/2020, Everson, Ch: 1826  , Tratamento condicional para escolha do produto a ser utilizado na geração de pedido de compra.
	@history 05/10/2020, Everson, Ch: 2936  , Tratamento para error log.
	@history ticket 3873 - Fernando Macieira - 23/11/2020 - Projeto - Contrato e Controle de Entradas - São Carlos
	@history ticket TI   - Fernando Macieira - 04/12/2020 - Checar se o PC existe na base antes de efetuar o execauto
	@history 29/01/2021, Everson, Ch: 8210  , Adicionada funcionalidade para alteração em massa (CSV) de tabela de preço de combustível.  
	@history Chamado 11607 - Leonardo P. Monteiro - 30/04/2021 - Extração das CTe averbadas e adição no menu da rotina.
	@history 05/05/2021, Everson, Ch:13434  - Tratamento para não emitir CT-e globalizado quando a UF da transportadora não estiver no parâmetro MV_#UFTCAT.
    @history ticket 14223 - Fernando Macieira - 09/06/2021 - E-mail automático adiantamento de frete
	@history TICKET 18451 - ADRIANO SAVOINE   - 17/08/2021 - Retirada a limpeza da variavel "cEmailC" a mesma é carregada via parametro para enviar email´s de copia e não pode ser Limpa ficando vazia.
	@history 21/09/2021, Everson, Ch:40420  - Tratamento para quando houver deadlock no fechamento de registros.
	@history 04/11/2021, Everson, Ch:63137  - Tratamento para não permitir alteração e exclusão de registro por usuário diferente que inseriu o registro.
	@history 05/11/2021  Sigoli Tkt: T.I    - Declaração de variavel  - CFECHADO on VLDPOS 
	@history 24/03/2022  Sigoli Tkt 70153   - Declaração de variavel OK na função principal
	@history Ticket 70142   - Edvar   / Flek Solution - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history 28/03/2022 - ADRIANO SAVOINE - Criado o bloqueio para o tipo de ocorrencia 012 e 014 somente para pessoas especificas.
	@history ticket 70750 - Everson - 07/04/2022 - Adaptação do fonte para nova filial.
	@history ticket 73505 - Everson - 24/05/2022 - Tratamento para validar exclusão/alteração de registros fechado em rotinas com execauto. 
	@history ticket 76823 - Fernando Macieira - 21/07/2022 - Configuração visualização de cidade NF
/*/
User Function ADLOG040P()

	//Variáveis.
	Local oBrowse	:= Nil
	Local cFilSec	:= Alltrim(cValToChar(FWxFilial("ZFA")))
	Local cTpFrtSec	:= ""
	PRIVATE OK := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')



	//Everson - 05/11/2019. Chamado 029058.
	If ! Pergunte("ADLOG040P",.T.)
		Return Nil 

	EndIf

	//
	nTipoFrt  := MV_PAR01
	cTpFrtSec := Alltrim(cValToChar(nTipoFrt))

	//
	DbSelectArea("ZFA")
	// ZFA->(DbSetOrder(16))

	//
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZFA")
	oBrowse:SetFilterDefault(" ZFA_FILIAL = '" + cFilSec + "' .And. ZFA_VA = '" + cTpFrtSec + "'") // 27/11/2019, Everson, Ch:029058.
	oBrowse:SetDescription("Manutenção de Frete - " + retDescFrt( nTipoFrt ) )
	oBrowse:AddLegend("ZFA_FECHA = 'S'"                      ,"BLUE"    ,"Frete Fechado")
	oBrowse:AddLegend("ZFA_APRMOV = 'S'.AND.ZFA_PEDCOM = ' '","GREEN"   ,"Frete Liberado")
	oBrowse:AddLegend("ZFA_APRMOV = 'N'.AND.ZFA_PEDCOM = ' '","RED"		,"Frete Bloqueado")
	oBrowse:AddLegend("ZFA_APRMOV = 'R'.AND.ZFA_PEDCOM = ' '","BLACK"   ,"Frete Reprovado")
	oBrowse:Activate()

Return Nil
/*/{Protheus.doc} retDescFrt
	Retorna a descrição do tipo de frete. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/ 
Static Function retDescFrt(nOpc)
	
	//Variáveis.
	Local aArea  := GetArea()
	Local aCampo := {}
	Local cDesc	 := ""
	Local nPosIni:= 0

	//
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If DbSeek( "ZFA_VA" )     
		aCampo  := StrToKarr(Alltrim(X3Cbox()),";")

	EndIf 

	//
	nPosIni := At("=",Alltrim(cValToChar(aCampo[nOpc]))) + 1
	cDesc := Substr(Alltrim(cValToChar(aCampo[nOpc])),nPosIni,Len(aCampo[nOpc]))

	//
	RestArea(aArea)

Return cDesc
/*/{Protheus.doc} User Function ADLG40H
	Retorna o tipo de frete (1=Frt Abatido,2=Frt Frango Vivo,3=Frt Ovo;4=Frt Pintinho,5=Frt Ração)
	@type  Function
	@author Everson
	@since 23/10/2019
	@version 01
	/*/
User Function ADLG40H()
Return nTipoFrt
/*/{Protheus.doc} MenuDef
	Menu com as opções disponíveis de funções. Chamado 044314.
	@type  Static Function
	@author Ricardo Lima
	@since 14/11/2018
	@version 01
	/*/
Static Function MenuDef()
	
	//Variáveis.
	Local aRotina 	:= {}
	Local nTpFrtS	:= U_ADLG40H()

	//
	ADD OPTION aRotina TITLE "Pesquisar" 			  ACTION "PesqBrw"          	OPERATION 1   ACCESS 0 //Everson-Ch:044314-23/05/2019.
	ADD OPTION aRotina TITLE "Visualizar" 			  ACTION "VIEWDEF.ADLOG040P" 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    			  ACTION "VIEWDEF.ADLOG040P" 	OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    			  ACTION "VIEWDEF.ADLOG040P" 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    			  ACTION "VIEWDEF.ADLOG040P" 	OPERATION MODEL_OPERATION_DELETE ACCESS 0
	ADD OPTION aRotina TITLE "Legenda"    			  ACTION "U_ADLG40A()"       	OPERATION 10  ACCESS 0
	ADD OPTION aRotina TITLE "Gera Ped. Compra"		  ACTION "U_ADLG40B()"       	OPERATION 11   ACCESS 0 
	ADD OPTION aRotina TITLE "Fechamento"  			  ACTION "U_ADLG40C()" 	   		OPERATION 12  ACCESS 0 //Everson-Ch:044314-14/05/2019.

	//Everson - 05/11/2019. Chamado 029058.
	ADD OPTION aRotina TITLE "Visualizar Nf-es"  	  ACTION "U_ADLG40D()"      	OPERATION 13  ACCESS 0
	ADD OPTION aRotina TITLE "Conf. descontos"		  ACTION "U_ADLG40E()"       	OPERATION 14  ACCESS 0 //Everson-Ch:044314-23/04/2019.
	ADD OPTION aRotina TITLE "Visualizar CT-e/MDF-e"  ACTION "U_ADLG40F()"      	OPERATION 15  ACCESS 0 //Everson-Ch:044314-25/06/2019.
	ADD OPTION aRotina TITLE "Importar Arquivo"		  ACTION "Processa({|| U_ADLG40G() },'Aguarde','Processando registros...',.F.)" OPERATION 16 ACCESS 0 //Everson-Ch:044314-24/04/2019.

	//Everson - 05/11/2019. Chamado 029058.
	If nTpFrtS = 1
		ADD OPTION aRotina TITLE "Refaz Frete"		  ACTION "U_ADLOG412()" 			OPERATION 17  ACCESS 0 //Everson - 21/01/2020 - Chamado 054941.

	EndIf 

	ADD OPTION aRotina TITLE "Env. Rel. Fech."        ACTION "U_ADLOG060R()" 		OPERATION 18  ACCESS 0 //Everson-Ch:044314-02/08/2019.
	ADD OPTION aRotina TITLE "Relatório Movimentação" ACTION "U_ADLOG045R()" 		OPERATION 19  ACCESS 0
	ADD OPTION aRotina TITLE "Gerar Doc"    		  ACTION "U_ADLOG057P(1," + cValToChar( nTpFrtS ) + ")" OPERATION 20  ACCESS 0
	ADD OPTION aRotina TITLE "Relat. Doc. Emit."      ACTION "MsAguarde({|| U_ADLOG059R() },'Aguarde','Gerando relatório...')" OPERATION 21 ACCESS 0
	
	ADD OPTION aRotina TITLE "Atlz. Tab Abast."       ACTION "MsAguarde({|| U_ADLG40J() },'Aguarde','Processando...')" OPERATION 22 ACCESS 0 //Everson - 29/01/2020. Chamado 8210.
	//@history Chamado 11607 - Leonardo P. Monteiro - 30/04/2021 - Extração das CTe averbadas e adição no menu da rotina.
	ADD OPTION aRotina TITLE "Relat. Cte Averba"      ACTION "MsAguarde({|| U_ADLOG076R() },'Aguarde','Gerando relatório...')" OPERATION 21 ACCESS 0
Return aRotina
/*/{Protheus.doc} User Function ADLG40A
	Exibe legenda com os status dos registros de movimento de frete. Chamado 044314.
	@type  Function
	@author Ricardo Lima
	@since 14/11/2018
	@version 01
	/*/
User Function ADLG40A()

	//Variáveis.
	Local aLegenda := {}

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	Aadd(aLegenda,{"BR_VERDE"   ,"Frete Liberado" })
	Aadd(aLegenda,{"BR_VERMELHO","Frete Bloqueado"})
	Aadd(aLegenda,{"BR_PRETO"   ,"Frete Reprovado"})
	Aadd(aLegenda,{"BR_AZUL"    ,"Frete Fechado"})

	BrwLegenda("Manutenção de Frete","Legenda",aLegenda)

Return Nil
/*/{Protheus.doc} ModelDef
	Model do padrão MVC. Chamado 044314.
	@type  Static Function
	@author Ricardo Lima
	@since 14/11/2018
	@version 01
	/*/
Static Function ModelDef()

	//Variáveis.
	Local oModel		:= Nil
	Local oStruZFA 		:= FWFormStruct( 1, "ZFA" )
	Local bPre			:= {|oModel| vldPre(oModel)} //Everson - 04/11/2021. Chamado 63137.
	Local bPost			:= {|oModel| vldPos(oModel)}
	//Local bCommit		:= {|oModel| vldCommit(oModel)}
	Local bCancel		:= {||.T.}
	Local bPreSub		:= {||.T.}
	Local bPosSub		:= {||.T.}
	Local bCarga		:= Nil

	//
	oModel:= MPFormModel():New("ADLOG40", bPre, bPost, /*bCommit*/, bCancel)
	oModel:AddFields("ZFAMASTER","", oStruZFA, bPreSub, bPosSub, bCarga)
	oModel:GetModel("ZFAMASTER"):SetDescription("Manutenção de Frete") //Everson - 05/11/2019. Chamado 029058.
	oModel:SetPrimaryKey( {"ZFA_FILIAL","ZFA_COD" } ) //Everson - 05/11/2019. Chamado 029058.

Return oModel
/*/{Protheus.doc} vldPre
	Pré validação do modelo de dados.
	Chamado 63137.
	@type  Static Function
	@author Everson
	@since 04/11/2021
	@version 01
/*/
Static Function vldPre(oModel)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lRet 			:= .T.
	Local cCodUsr       := RetCodUsr()
	Local nOperation	:= oModel:GetOperation()
	Local cCod	     	:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_COD"    )))
	Local cStatus   	:= Alltrim(GetMv("MV_#STSEMI",,"0/1/4/7"))
	Local cFechado		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_FECHA"  )))
	Local cCodOcorr		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_OCORRE" )))
	Local cFlgFrt		:= Alltrim(Posicione("ZF7",1,FWxFilial("ZF7") + cCodOcorr,"ZF7_TOTCOD"))
	Local cPedDia		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_PEDADT" )))
	Local cPedFch		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_PEDCOM" )))
	Local cOcorrImp		:= Alltrim(cValToChar(GetMv("MV_#ALTOCO",,"")))
	Local lVlAbast		:= (! IsInCallStack("estAbast")) //Não é estorno de abastecimento.
	Local lVlAdia		:= (! IsInCallStack("estAdianta")) //Não é estorno de adiantamento.
	Local lFuncLib		:= (! IsInCallStack("U_ADLOG047P") .And. ! IsInCallStack("U_ADLOG067P")) //Não é aprovação de registro.
	Local cPerExl		:= Alltrim(GetMv("MV_#FRTEXL",,""))
	Local cTpLcReg		:= oModel:GetValue("ZFAMASTER","ZFA_TPMOV" )
	Local cUsuario		:= oModel:GetValue("ZFAMASTER","ZFA_USUARI" )
	Local cTpFrg		:= oModel:GetValue("ZFAMASTER","ZFA_VA" ) //Tipo de frete.
	Local cFilVlUsr		:= Alltrim(cValToChar(GetMv("MV_#FTVLUS",,""))) //Tipo de frete com validação por filial de usuário para alteração e exclusão.

	//Validações para Inclusão e alteração.
	//Ticket: 68841 - ADRIANO SAVOINE - 28/03/2022.
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) .AND. !(cCodUsr $ SuperGetMV("MV_#USUFRT",.F.,"000000")) .AND.(cCodOcorr $ '012/014')
		//lRet := .F.
		MsgAlert("Seu usuario não pode inserir ou alterar Ocorrencia para ocorrencia do Tipo 012 ou 014, solicite autorização!!!", "Ocorrencia")
		cCodOcorr:= oModel:LoadValue("ZFAMASTER","ZFA_OCORRE", " ")
	ENDIF	

	//Validações para alteração e exclusão.
	If lRet .And. ( nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE )

		//Verifica se o registro fechado.
		If lRet .And. ( cFechado = "S" .Or. !Empty(cPedDia) .Or. !Empty(cPedFch) )
			lRet := .F.
			Help(Nil, Nil, "Função vldPre(ADLOG040P)", Nil, "Movimento " + cCod + " encerrado ou com pedido de compra vinculado não pode ser alterado ou excluído.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

		EndIf
	
		//Verifica se é movimento automático.
		If lRet .And. cTpLcReg = "A" .And.;
		   !(cCodOcorr $cOcorrImp)   .And. lVlAbast .And. lVlAdia .And. lFuncLib //Everson-Ch:044314-20/03/2019

			//
			If lRet .And. nOperation == MODEL_OPERATION_UPDATE 
				lRet := .F.
				Help(Nil, Nil, "Função vldPre(ADLOG040P)", Nil, "Movimento automático não pode ser alterado.", 1, 0)

			EndIf

			//Everson - 06/01/2020 - Chamado 054680.
			If lRet .And. nOperation == MODEL_OPERATION_DELETE .And. ( !(__cUserId $ cPerExl) .Or. cFlgFrt <> "S" )
				lRet := .F.
				Help(Nil, Nil, "Função vldPre(ADLOG040P)", Nil, "Movimento automático não pode ser excluído.", 1, 0)

			EndIf


		EndIf
		
		//Valida usuário. Everson - 04/11/2021. Chamado 63137.
		If lRet .And. cTpLcReg = "M"  .And. Alltrim(cValToChar(cUsuario)) <> Alltrim(cValToChar(cUserName)) .And.;
		   lVlAbast .And. lVlAdia .And. lFuncLib .And. Alltrim(cValToChar(cTpFrg)) $cFilVlUsr
			lRet := .F.
			Help(Nil, Nil, "Função vldPre(ADLOG040P)", Nil, "Ação permitida apenas para o usuário que inseriu o registro.", 1, 0)
		
		EndIf 

		//Verifica vinculo com documento fiscal de transporte.
		If lRet //Everson - 20/07/2020. Chamado T.I.
			lRet := chkZFK(cCod, cStatus,.T.)

		EndIf

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} vldPos
	Validação dos dados equivalente ao TudoOk. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
Static Function vldPos(oModel)

	//Variáveis.
	Local aArea			:= GetArea()	
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local cCod	     	:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_COD"    )))
	//Local cOrigem		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_ORIGEM" ))) //Everson - 05/11/2019. Chamado 029058.	
	Local cTpBloq		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_TPBLQF" ))) //Everson - 05/11/2019. Chamado 029058.
	Local cCodOcorr		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_OCORRE" )))
	Local cRegAprv		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_APRMOV" ))) //Everson - 05/11/2019. Chamado 029058.
	Local nDesco 		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_DESCOC" ))) //Everson - 04/12/2019. Chamado 029058.
	Local nTrans 		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_TRANPA" ))) //Everson - 04/12/2019. Chamado 029058.
	Local nLojtr 		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_LJPPAG" ))) //Everson - 04/12/2019. Chamado 029058.
	Local nVlrFr 		:= oModel:GetValue( "ZFAMASTER" , "ZFA_VALOR" ) //Everson - 04/12/2019. Chamado 029058.
	Local cNumRegF		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_REGFCH" )))
	Local cDtFchmt		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_DATAPG" )))
	Local cDtFchIni		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_DTFCIN" )))
	Local cDtFchFim		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_DTFCFM" )))
	Local cFechado		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_FECHA"  ))) //05/11/2021  Sigoli Tkt: T.I    - Declaração de variavel  - CFECHADO on VLDPOS 
	Local cOcFech		:= Alltrim(GetMv("MV_#OCFHFT",,"106/107"))
	Local cPedDia		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_PEDADT" )))
	Local cPedFch		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_PEDCOM" )))

	//Everson - 24/05/2022. Chamado 73505.
	//Validações para alteração e exclusão.
	If lRet .And. ( nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE )

		//Verifica se o registro fechado.
		If lRet .And. ( cFechado = "S" .Or. !Empty(cPedDia) .Or. !Empty(cPedFch) )
			lRet := .F.
			Help(Nil, Nil, "Função vldPos(ADLOG040P)", Nil, "Movimento " + cCod + " encerrado ou com pedido de compra vinculado não pode ser alterado ou excluído.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

		EndIf

	EndIf
	//

	//Valida origem do lançamento.
	If lRet .And. ! ( nOperation == MODEL_OPERATION_DELETE )

		//Valida se há tipo de bloqueio para o tipo de frete selecionado.
		If lRet .And. Empty(cTpBloq)
			lRet := .F.
			Help(Nil, Nil, "Função vldPos(ADLOG040P)", Nil, "Operação não pode ser realizada pois não há tipo de bloqueio de frete cadastrado para o tipo - " + retDescFrt(nTpFrtS) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

		EndIf

		//Valida parâmetros de fechamento de período.
		If lRet .And. cFechado = "S" .And. ( ( Empty(cNumRegF) .And. !(cCodOcorr $cOcFech) ) .Or. Empty(cDtFchmt) .Or. Empty(cDtFchIni) .Or. Empty(cDtFchFim) .Or. cRegAprv = "N" )
			lRet := .F.
			Help(Nil, Nil, "Função vldPos(ADLOG040P)", Nil, "Dados incompletos para fechamento de período.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

		EndIf

	EndIf

	//Everson - 05/11/2019. Chamado 029058.
	If lRet .And. Empty(cCod) .And. nOperation == MODEL_OPERATION_INSERT
		oModel:SetValue("ZFAMASTER","ZFA_COD", GETSXENUM("ZFA","ZFA_COD"))
		Confirmsx8()

	ElseIf lRet .And. Empty(cCod) .And. ! ( nOperation == MODEL_OPERATION_INSERT )
		lRet := .F.
		Help(Nil, Nil, "Função vldPos(ADLOG040P)", Nil, "Movimento está sem código.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

	EndIf

	//Everson - 05/08/2020. Chamado TI.
	cCod := Alltrim(cValToChar(oModel:GetValue("ZFAMASTER" , "ZFA_COD"))) 
	If ! Empty(cCod) .And. nOperation == MODEL_OPERATION_INSERT

		If ! ExistChav("ZFA", cCod, 13)
			lRet := .F.
			Help(Nil, Nil, "Função vldPos(ADLOG040P)", Nil, "Numeração sequencial já existe " + cCod + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

		EndIf 

	EndIf

	//Everson-Ch:044314-04/12/2019
	If lRet .And. ! (nOperation == MODEL_OPERATION_DELETE )

		//
		oModel:SetValue( "ZFAMASTER", "ZFA_USUARI", cUserName )
		oModel:SetValue( "ZFAMASTER", "ZFA_DATAIN", Date() )
		oModel:SetValue( "ZFAMASTER", "ZFA_HORA"  , Time() )

		//
		If ( Empty(cRegAprv) .Or. cRegAprv = "N" .Or. ! Empty(Alltrim(oModel:GetValue( "ZFAMASTER", "ZFA_USRAPR"))) ) //Everson - 05/11/2019. Chamado 029058. //06/03/2020, Everson (2), Ch:054941.
			oModel:SetValue( "ZFAMASTER", "ZFA_APRMOV", "N" )
			oModel:SetValue( "ZFAMASTER", "ZFA_USRAPR", "" )
			oModel:SetValue( "ZFAMASTER", "ZFA_NOMAPR", "" )
			oModel:SetValue( "ZFAMASTER", "ZFA_DTAPRO", SToD("") )
			oModel:SetValue( "ZFAMASTER", "ZFA_HRAPRO", "" )
			cRegAprv := "N" //Everson - 06/03/2020. Chamado 054941.

		EndIf

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - vldPos - Entrou envio aprovação - lRet/cRegAprv " + cValToChar(lRet) + " " + cValToChar(cRegAprv) )

	//Everson - 04/12/2019. Chamado 029058.
	If lRet .And. cRegAprv = "N"

		//
		Conout( DToC(Date()) + " " + Time() + " ADLOG040P - vldPos - Entrou envio aprovação " + cValToChar(nOperation) )

		//Everson-Ch:044314-19/03/2019
		U_ADLOG050P( cCod , cCodOcorr , nLojtr , nTrans , nVlrFr , nDesco , nOperation, "ADLOG040P", cTpBloq ) //Everson - 05/11/2019. Chamado 029058.

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - vldPos - cCarga " + Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_CARGA"    ))) )

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} chkZFK
	Valida se o registro de frete 
	@type  Static Function
	@author Everson
	@since 23/01/2020
	@version 01
	/*/
Static Function chkZFK(cCod,cStatus,lChkStatus)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lRet 			:= .T.
	Default lChkStatus	:= .T.

	//
	DbSelectArea("ZFK")
	ZFK->(DbSetOrder(6))
	ZFK->(DbGoTop())
	If ZFK->( DbSeek( FWxFilial("ZFK") + cCod ) )

		//Everson - 09/12/2019. Chamado 029058.
		While ! ZFK->(Eof()) .And. Alltrim(FWxFilial("ZFK")) == Alltrim(ZFK->ZFK_FILIAL) .And. Alltrim(ZFK->ZFK_CODZFA) == Alltrim(cCod)

			//
			If lChkStatus

				//
				If Alltrim(cValToChar(ZFK->ZFK_STATUS)) $cStatus
					lRet := .F.
					Help(Nil, Nil, "Função vldPos(ADLOG040P)", Nil, "Movimento está vinculado a documento fiscal de transporte.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

				EndIf

			Else
				lRet := .F.

			EndIf

			//
			ZFK->(DbSkip())

		End
		//
		
	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} vldCommit
	Validação do Model ao fazer o commit dos dados. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 1.0
	/*/
// Static function vldCommit(oModel)

// 	//Variáveis.
// 	Local aArea			:= GetArea()	
// 	Local nOperation	:= oModel:GetOperation()
// 	Local cRegAprv		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_APRMOV" ))) //Everson - 05/11/2019. Chamado 029058.
// 	Local cCod	     	:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_COD"    )))
// 	Local cOcorr 		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_OCORRE" ))) 
// 	Local nDesco 		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_DESCOC" )))
// 	Local nTrans 		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_TRANPA" )))
// 	Local nLojtr 		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_LJPPAG" )))	
// 	Local nVlrFr 		:= oModel:GetValue( "ZFAMASTER" , "ZFA_VALOR" )
// 	//Local cOrigem		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_ORIGEM" )))
// 	Local cTpBloq		:= Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_TPBLQF" )))

// 	//Everson-Ch:044314-20/03/2019
// 	If ! (nOperation == MODEL_OPERATION_DELETE )

// 		//
// 		oModel:SetValue( "ZFAMASTER", "ZFA_USUARI", cUserName )
// 		oModel:SetValue( "ZFAMASTER", "ZFA_DATAIN", Date() )
// 		oModel:SetValue( "ZFAMASTER", "ZFA_HORA"  , Time() )

// 		//
// 		If Empty(cRegAprv) .Or. cRegAprv = "N"  //Everson - 05/11/2019. Chamado 029058.
// 			oModel:SetValue( "ZFAMASTER", "ZFA_APRMOV", "N" )
// 			oModel:SetValue( "ZFAMASTER", "ZFA_USRAPR", "" )
// 			oModel:SetValue( "ZFAMASTER", "ZFA_NOMAPR", "" )
// 			oModel:SetValue( "ZFAMASTER", "ZFA_DTAPRO", SToD("") )
// 			oModel:SetValue( "ZFAMASTER", "ZFA_HRAPRO", "" )

// 		EndIf

// 	EndIf

// 	//
// 	If ! FWFormCommit(oModel)
// 		Final("Não foi possível salvar o formulário(vldCommit - ADLOG040P)")

// 	EndIf 

// 	//
// 	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - vldCommit - cCarga " + Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_CARGA"    ))) )

// 	//
// 	If cRegAprv = "N"

// 		//
// 		Conout( DToC(Date()) + " " + Time() + " ADLOG040P - vldCommit - Entrou envio aprovação " + cValToChar(nOperation) )

// 		//Everson-Ch:044314-19/03/2019
// 		U_ADLOG050P( cCod , cOcorr , nLojtr , nTrans , nVlrFr , nDesco , nOperation, "ADLOG040P", cTpBloq ) //Everson - 05/11/2019. Chamado 029058.

// 	EndIf

// 	//
// 	RestArea(aArea)

// Return .T.
/*/{Protheus.doc} ViewDef
	View do padrão MVC. Chamado 044314.
	@type  Static Function
	@author Ricardo Lima
	@since 14/11/2018
	@version 01
	/*/
Static Function ViewDef()

	//Variáveis.
	Local oView		:= Nil
	Local oModel   	:= FWLoadModel( "ADLOG040P" )
	Local oStruZFA 	:= FWFormStruct( 2, "ZFA" )
	Local nTpFrtS	:= U_ADLG40H()

	//
	oStruZFA:RemoveField("ZFA_JSONPE") //Everson-Ch:044314-18/03/2019.
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField("VIEW_ZFA", oStruZFA, "ZFAMASTER" )
	oView:CreateHorizontalBox("TELA" , 100 )

	//Everson - 05/11/2019. Chamado 029058.
	If nTpFrtS = 1
		oView:AddUserButton("Vincular nota fiscal","",{|oView| U_ADLG0405(oView) } ,"",, {MODEL_OPERATION_INSERT ,MODEL_OPERATION_UPDATE} , .T. )   
	
	EndIf

	//
	oView:SetCloseOnOk( { || .T. } )

Return oView
/*/{Protheus.doc} User Function ADLOG050P
	Envia registro de movimento de frete para aprovação.
	@type  Function
	@author Ricardo Lima
	@since 14/11/2018
	@version 01
	/*/
User Function ADLOG050P( ZFACOD , ZFAOCORRE , ZFALOJTRA , ZFATRANSP , ZFAVALOR , ZFADESCOC , nOpc, cOrigem, cTpBloq ) //Everson-Ch:044314-28/03/2019

	//Variáveis.	
	Local aArea		:= GetArea()

	Default cOrigem := "ADLOG040P"
	Default cTpBloq := "000006"

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLOG050P - cOrigem " + cValToChar(cOrigem) )
	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//Everson-Ch:044314-28/03/2019
	DbSelectArea("ZC7")
	ZC7->(DbSetOrder(5))
	ZC7->(DbGoTop())

	//
	If nOpc == 3 .Or. nOPc == 4 //Everon - 16/12/2019 - Chamado 029058. //

		//Everson-Ch:044314-28/03/2019
		If ZC7->( DbSeek( FWxFilial("ZC7") + Padr(Alltrim(ZFAOCORRE), TamSX3("ZC7_PREFIX")[1]," ") + Padr(Alltrim(ZFACOD), TamSX3("ZC7_NUM")[1]," ") +  cOrigem  ) )

			//Everson-Ch:044314-19/03/2019
			While ! ZC7->(Eof()) .And. ZC7->ZC7_TPBLQ = cTpBloq .And. ZC7->ZC7_FILIAL = FwxFilial("ZC7") .And. ZC7->ZC7_CLIFOR = ZFATRANSP .And.;
			ZC7->ZC7_LOJA = ZFALOJTRA .And. ZC7->ZC7_PREFIX = ZFAOCORRE .And. ZC7->ZC7_NUM = ZFACOD .And. ZC7->ZC7_ORIGEM = cOrigem

				RecLock("ZC7",.F.)
					ZC7->( DbDelete() )
				MSUnlock()

				ZC7->(DbSkip())

			End

		Else
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLOG050P - não encontrou registro para exclusão na ZC7. ZFAOCORRE " + ZFAOCORRE )

		EndIf

		//
		RecLock("ZC7",.T.)
			ZC7->ZC7_FILIAL := FwxFilial("ZC7")
			ZC7->ZC7_PREFIX := ZFAOCORRE
			ZC7->ZC7_NUM    := ZFACOD
			ZC7->ZC7_CLIFOR := ZFATRANSP
			ZC7->ZC7_LOJA   := ZFALOJTRA
			ZC7->ZC7_TPBLQ  := cTpBloq
			ZC7->ZC7_DSCBLQ := "Bloqueio de Frete, " + Alltrim(ZFADESCOC)
			ZC7->ZC7_RECPAG := "F"	
			ZC7->ZC7_VLRBLQ := ZFAVALOR
			ZC7->ZC7_DATA   := Date()
			ZC7->ZC7_USRALT := __cUserID
			ZC7->ZC7_ORIGEM	:= cOrigem
		MSUnlock()

	ElseIf nOpc == 5
		//Everson-Ch:044314-28/03/2019
		If ZC7->( DbSeek( FWxFilial("ZC7") + Padr(Alltrim(ZFAOCORRE), TamSX3("ZC7_PREFIX")[1]," ") + Padr(Alltrim(ZFACOD), TamSX3("ZC7_NUM")[1]," ") +  cOrigem  ) )

			//
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLOG050P - encontrou registro para exclusão na ZC7. ZFAOCORRE/RecZC7 " + ZFACOD + " " + cValToChar(ZC7->(Recno())) )

			//Everson-Ch:044314-19/03/2019
			While ! ZC7->(Eof()) .And. Alltrim(ZC7->ZC7_TPBLQ) = Alltrim(cTpBloq) .And. Alltrim(ZC7->ZC7_FILIAL) = Alltrim(FwxFilial("ZC7")) .And. Alltrim(ZC7->ZC7_CLIFOR) = Alltrim(ZFATRANSP) .And.;
			Alltrim(ZC7->ZC7_LOJA) = Alltrim(ZFALOJTRA) .And. Alltrim(ZC7->ZC7_PREFIX) = Alltrim(ZFAOCORRE) .And. Alltrim(ZC7->ZC7_NUM) = Alltrim(ZFACOD) .And. Alltrim(ZC7->ZC7_ORIGEM) = Alltrim(cOrigem)

				//
				Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLOG050P - while para exclusão na ZC7. ZFAOCORRE " + ZFACOD )

				RecLock("ZC7",.F.)
					ZC7->( DbDelete() )
				MSUnlock()

				ZC7->(DbSkip())

			End

		Else
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLOG050P - não encontrou registro para exclusão na ZC7. ZFAOCORRE " + ZFAOCORRE )

		EndIf

	EndIf

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function ADLG40B
	Exibe informções de CT-es emitidos para inclusão de pedido de compra. Chamado 044314.
	@type  Function
	@author Everson
	@since 26/06/2019
	@version 01
	/*/
User Function ADLG40B()

	//Variáveis.
	Local aArea			:= GetArea()
	Local oInterface	:= Nil
	Local oGrPed		:= Nil
	Local oFechar		:= Nil

	Private aHDc		:= {}
	Private aColsDc		:= {}
	Private oDocs		:= Nil

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//
	If ! Pergunte("CTE3",.T.)
		RestArea(aArea)
		Return Nil

	EndIf

	//
	oInterface			 := MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Pedido de Compra x CT-e"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1200
	oInterface:nHeight   := 550
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.

	//
	Aadd(aHDc,{" ","LEGENDA"       	,"@BMP", 3,0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	Aadd(aHDc,{"Dt Emissao" 		,"CRDTEMIS" ,"" ,008, 0,"","" ,"D","",""})
	Aadd(aHDc,{"Num Doc" 			,"CRNUMDOC"	,"" ,009, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Série" 				,"CRSRDOC" 	,"" ,003, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Seq Env" 			,"CRSEQENV"	,"" ,004, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Valor"    			,"CRVALOR"	,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
	Aadd(aHDc,{"Cond Pag" 			,"CRCONPAG"	,"" ,TamSX3("E4_CODIGO")[1], 0,"","" ,"C","SE4",""}) //Everson - 06/03/2020. Chamado 054941.
	Aadd(aHDc,{"DT Entrega" 		,"CRDTE"    ,"" ,008, 0,"","" ,"D","",""})
	Aadd(aHDc,{"Roteiro"   			,"CRROT"    ,"" ,005, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Placa"   			,"CRPLACA"  ,"" ,005, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Cod Transp" 		,"CRTRAN"   ,"" ,006, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Loja"   			,"CRLOJA"   ,"" ,002, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Nome" 				,"CRNMTR"	,"" ,035, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Produto" 			,"CRPROD"	,"" ,TamSX3("B1_COD")[1]    , 0,"","" ,"C","SB1FRT",""})
	Aadd(aHDc,{"Desc"   			,"CRDESC"   ,"" ,TamSX3("B1_DESC")[1]   , 0,"","" ,"C","",""})	
	Aadd(aHDc,{"Lote X CC"	        ,"CRLCR"	,"" ,TamSX3("C7_XLOTECC")[1], 0,"","" ,"C","ZCNCT2",""}) //Everson - 06/03/2020. Chamado 054941. //Everson - 17/03/2020. Chamado 054941.
	Aadd(aHDc,{"Desc Lote"	 		,"CRLDS"	,"" ,TamSX3("ZCN_DESCLT")[1], 0,"","" ,"C","",""}) 		 //Everson - 17/03/2020. Chamado 054941.
	Aadd(aHDc,{"Centro de Custo"	,"CRCC"	    ,"" ,TamSX3("CTT_CUSTO")[1] , 0,"","" ,"C","CTTFRT",""}) //Everson - 06/03/2020. Chamado 054941.
	Aadd(aHDc,{"Mensagem" 			,"CROPHOS"	,"" ,050, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Tp Frt" 			,"CRTPFRT"	,"" ,003, 0,"","" ,"N","",""})
	Aadd(aHDc,{"Tes" 				,"CRTES"	,"" ,TamSX3("F4_CODIGO")[1], 0,"","" ,"C","",""}) //Everson-Ch:044314-30/07/2019.
	Aadd(aHDc,{"Ocorrência" 		,"CROCORR"	,"" ,003, 0,"","" ,"C","",""})

	//
	oDocs := MsNewGetDados():New(001,005,230,500,GD_UPDATE,"Allwaystrue()","Allwaystrue()","",{"CRCONPAG","CRPROD","CRCC","CRLCR"},Nil,999,Nil,Nil,Nil,oInterface,aHDc,@aColsDc) //Everson - 06/03/2020. Chamado 054941.	

	//
	TGroup():Create(oInterface,001,505,230,595,"",,,.T.)
	oGrPed	 := TButton():New(010,510,"Gerar Ped. Comp."  ,oInterface,{|| grPedCom() },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	//
	TGroup():Create(oInterface,239,005,260,595,"",,,.T.)	
	TButton():New(245,015,"Legenda"    ,oInterface,{|| lgdGPedC() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(245,505,"Atualizar"  ,oInterface,{|| MsAguarde({ || carCTE() },"Aguarde","Obtendo dados...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar	 := TButton():New(245,550,"Fechar"     ,oInterface,{||oInterface:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

	oInterface:Activate(,,,.T.,{||.T.},,{|| MsAguarde({ || carCTE() },"Aguarde","Obtendo dados...") })	

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} lgdGPedC
	Exibe legenda referente aos status dos registros da interface de geração de pedido de compra. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 16/07/2019
	@version 01
	/*/
Static Function lgdGPedC()

	//Variáveis.
	Local cTitulo := "Legenda"
	Local aLegenda:= {}

	//
	Aadd(aLegenda,{"BR_VERDE"  		,"Ok para geração de pedido de compra"})
	Aadd(aLegenda,{"BR_VERMELHO"	,"Dados faltantes para geração de pedido de compra"}) 

	//
	BrwLegenda("Legenda",cTitulo,aLegenda)

Return Nil
/*/{Protheus.doc} carCTE
	Carrega informações de CT-e no objeto MsNewGetDados da função ADLG40B.
	@type  Static Function
	@author Everson
	@since 25/06/2019
	@version 01
	/*/
Static Function carCTE()

	//Variáveis.
	Local aArea	 	:= GetArea()
	Local cQuery	:= ""
	Local aRet		:= {}	
	Local oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	//Local aParam	:= Static Call(ADFIS032P,paramFis,Val(cEmpAnt))
	Local aParam	:= u_FIS032A0() 
	Local nPosPrd	:= 0
	Local aOcFech	:= StrToKarr(Alltrim(GetMv("MV_#OCFHFT")),"/") //Everson-Ch:044314-02/10/2019.
	Local cOcFAcr	:= Alltrim(aOcFech[1]) //Everson-Ch:044314-02/10/2019.
	Local lEmFech	:= .F. //Everson-Ch:044314-02/10/2019.
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	
	//
	oDocs:aCols := {}
	Aadd(oDocs:aCols , Array(Len(aHDc) + 1) )
	oDocs:aCols[Len(oDocs:aCols), Len(oDocs:aCols[1]) ] := .F.	
	oDocs:Refresh()

	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ZFK_TRANSP, " 
	cQuery += " ZFK_LOJA, " 
	cQuery += " ZFK_NMTRAN, " 
	cQuery += " ZFK_CARGA, " 
	cQuery += " ZFK_DTENTR, " 
	cQuery += " ZFK_ROTEIR, " 
	cQuery += " ZFK_SEQENV, " 
	cQuery += " ZFK_TPDOC, " 
	cQuery += " ZFK_NUMDOC, " 
	cQuery += " ZFK_SERDOC, " 
	cQuery += " ZFK_STATUS, " 
	cQuery += " ZFK_HASH, " 
	cQuery += " ZFK_DATA, " 
	cQuery += " ZFK_PLACA, " 
	cQuery += " ZFK_OPHOS, "  
	cQuery += " ZFK_CHAVE, " 
	cQuery += " ZFK_PROTEM, " 
	cQuery += " ZFK_PROTCA, " 
	cQuery += " ZFK_REBOQU, " 
	cQuery += " ZFK_PROENC, ZFK_DTEMIS, "
	cQuery += " SUM(ZFK_VALOR) AS ZFK_VALOR, ZFK_ICMS, ZFK_OCORRE " //Everson-Ch:044314-02/10/2019.
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK " 

	//Everson - 05/08/2020. Chamado TI.
	//Everson - 05/11/2019. Chamado 029058.
	//cQuery += " INNER JOIN " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA ON "
	//cQuery += " ZFK_FILIAL = ZFA_FILIAL "
	//cQuery += " AND ZFK_CODZFA = ZFA_COD "

	cQuery += " WHERE " 
	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_DTENTR >= '" + DToS(MV_PAR05)  + "' " 
	cQuery += " AND ZFK_DTENTR <= '" + DToS(MV_PAR06)  + "' " //Everson - 01/10/2019. Chamado 044314.

	cQuery += "AND ZFK_TRANSP BETWEEN '" + cValToChar(MV_PAR01) + "' AND '" + cValToChar(MV_PAR03) + "' " 
	cQuery += "AND ZFK_LOJA   BETWEEN '" + cValToChar(MV_PAR02) + "' AND '" + cValToChar(MV_PAR04) + "' " 

	cQuery += " AND ZFK_PEDCOM = '' "
	cQuery += " AND ZFK_TPDOC  = '1' " 
	cQuery += " AND ZFK_STATUS = '1' "
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	//cQuery += " AND ZFA.D_E_L_E_T_ = '' " 
	//cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar( nTpFrtS )) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND RTRIM(LTRIM(ZFK_TPCARG)) = '" + Alltrim(cValToChar( nTpFrtS )) + "' " //Everson - 05/08/2020. Chamado TI.

	cQuery += " GROUP BY "
	cQuery += " ZFK_TRANSP, " 
	cQuery += " ZFK_LOJA, " 
	cQuery += " ZFK_NMTRAN, " 
	cQuery += " ZFK_CARGA, " 
	cQuery += " ZFK_DTENTR, " 
	cQuery += " ZFK_ROTEIR, " 
	cQuery += " ZFK_SEQENV, " 
	cQuery += " ZFK_TPDOC, " 
	cQuery += " ZFK_NUMDOC, " 
	cQuery += " ZFK_SERDOC, " 
	cQuery += " ZFK_STATUS, " 
	cQuery += " ZFK_HASH, " 
	cQuery += " ZFK_DATA, " 
	cQuery += " ZFK_PLACA, " 
	cQuery += " ZFK_OPHOS, "  
	cQuery += " ZFK_CHAVE, " 
	cQuery += " ZFK_PROTEM, " 
	cQuery += " ZFK_PROTCA, " 
	cQuery += " ZFK_REBOQU, " 
	cQuery += " ZFK_PROENC, ZFK_DTEMIS, ZFK_ICMS, ZFK_OCORRE "	//Everson-Ch:044314-02/10/2019.
	cQuery += " ORDER BY ZFK_TRANSP, ZFK_LOJA, ZFK_DTEMIS, ZFK_SERDOC, ZFK_NUMDOC " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - carCTE - cQuery " + cQuery )

	//
	If Select("D_DOCS") > 0
		D_DOCS->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_DOCS"
	DbSelectArea("D_DOCS")
	D_DOCS->(DbGoTop())

	//
	If D_DOCS->(Eof())
		D_DOCS->(DbCloseArea())
		RestArea(aArea)
		Return Nil

	EndIf

	//
	oDocs:aCols := {}
	While ! D_DOCS->(Eof())

		//
		Aadd(oDocs:aCols , Array(Len(aHDc) + 1) )
		oDocs:aCols[Len(oDocs:aCols), Len(oDocs:aCols[1]) ] := .F.
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRDTEMIS" })]	:= SToD(D_DOCS->ZFK_DTEMIS)
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRDTE" })]		:= SToD(D_DOCS->ZFK_DTENTR)
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRROT" })]		:= Alltrim(D_DOCS->ZFK_ROTEIR) //Everson - 12/12/2019 - Chamado 029058.
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPLACA"})]		:= D_DOCS->ZFK_PLACA
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRTRAN" })]		:= D_DOCS->ZFK_TRANSP
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRLOJA" })]		:= D_DOCS->ZFK_LOJA
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRNMTR" })]		:= D_DOCS->ZFK_NMTRAN
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRNUMDOC" })] 	:= D_DOCS->ZFK_NUMDOC
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSRDOC" })] 	:= D_DOCS->ZFK_SERDOC
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSEQENV" })] 	:= D_DOCS->ZFK_SEQENV
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRVALOR" })] 	:= D_DOCS->ZFK_VALOR
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CROPHOS" })] 	:= D_DOCS->ZFK_OPHOS
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CROCORR" })] 	:= D_DOCS->ZFK_OCORRE //Everson - 10/10/2019 - Chamado 044314.

		//Everson-Ch:044314-02/10/2019.
		lEmFech := .F.
		If Alltrim(cValToChar(D_DOCS->ZFK_OCORRE)) = cOcFAcr
			lEmFech := .T.

		EndIf

		//
		aRet := retPrdFrt(SToD(D_DOCS->ZFK_DTEMIS),D_DOCS->ZFK_TRANSP,D_DOCS->ZFK_LOJA,D_DOCS->ZFK_NUMDOC,D_DOCS->ZFK_SERDOC,SToD(D_DOCS->ZFK_DTENTR),Alltrim(D_DOCS->ZFK_ROTEIR),lEmFech) //Everson-Ch:044314-02/10/2019. //Everson - 12/12/2019 - Chamado 029058.
		
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRCONPAG" })]	:= aRet[1][1]
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPROD"   })]	:= aRet[1][2]
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRCC"     })]	:= aRet[1][3]
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRDESC"   })]	:= aRet[1][4]
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRTPFRT"   })]	:= aRet[1][5]

		//Everson - 06/03/2020. Chamado 054941.
		If nTpFrtS == 3
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRLCR"   })]	:= aRet[1][6] //Everson - 06/03/2020. Chamado 054941.
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRLDS"   })]	:= aRet[1][7] //Everson - 17/03/2020. Chamado 054941.

		EndIf
		//
		
		//Everson-Ch:044314-30/07/2019.
		nPosPrd := Ascan(aParam,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aRet[1][2])) })
		If nPosPrd > 0
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRTES"   })]	:= Iif(Alltrim(cValToChar(D_DOCS->ZFK_ICMS)) == "1",aParam[nPosPrd][2],aParam[nPosPrd][3])
		
		EndIf
		//

		//
		If ! Empty(aRet[1][1]) .And. ! Empty(aRet[1][2]) .And. ! Empty(aRet[1][3]) .And. ! Empty(aRet[1][4])
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "LEGENDA"   })]	:= oVerde

		Else
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "LEGENDA"   })]	:= oVermelho

		EndIf

		D_DOCS->(DbSkip())

	End

	//
	D_DOCS->(DbCloseArea())

	//
	oDocs:Refresh()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} retPrdFrt
	Retorna parâmetros para geração de pedido de compra de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 12/07/2019
	@version 01
	/*/
Static Function retPrdFrt(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech) //Everson-Ch:044314-02/10/2019.

	//Variáveis.	
	Local aArea		:= GetArea()
	Local aRet		:= {}
	Local nTpFrtS	:= U_ADLG40H()
	
	Default lEmFech := .F. //Everson-Ch:044314-02/10/2019.

	//
	If nTpFrtS == 1 //Frete Abatido.
		aRet := prFrtAbat(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)

	ElseIf nTpFrtS == 2 //Frete Frango Vivo.
		aRet := prFrtFrvV(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)

	ElseIf nTpFrtS == 3 //Frete Ovo.
		aRet := prFrtOvo(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)

	ElseIf nTpFrtS == 4 //Frete Pintinho.
		aRet := prFrtPinto(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)

	ElseIf nTpFrtS == 5 //Frete Ração.
		aRet := prFrtRacao(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)

	EndIf

	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} prFrtAbat
	Retorna parâmetros para geração de pedido de compra de frete abatido.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
Static Function prFrtAbat(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)
	
	//Variáveis.	
	Local aArea			:= GetArea()
	Local nTpFrtS		:= U_ADLG40H()
	Local aDiaFim		:= getDiasF(nTpFrtS) //Everson - 05/11/2019 - Chamado 029058.
	Local aPrdCC		:= {}
	Local cCond 		:= ""
	Local cClRosaves	:= Alltrim(cValToChar(GetMv("MV_#ADL411")))
	Local lRosaves		:= .F.
	Local cClGuarata	:= Alltrim(cValToChar(GetMv("MV_#ADL412")))
	Local lGuaranta		:= .F.
	Local nEstCli		:= 0
	Local aRet			:= {}
	Local cGrpSbPrd		:= Alltrim(cValToChar(GetMv("MV_#ADL413")))
	Local lSubprod		:= .F.
	Local cTesArma		:= Alltrim(cValToChar(GetMv("MV_#ADL414")))
	Local lArmazena		:= .F.
	Local cTesCop		:= Alltrim(cValToChar(GetMv("MV_#ADL415")))
	Local lCopeval		:= .F.
	Local aCond			:= getConPg(nTpFrtS) //Everson - 05/11/2019. Chamado 029058.

	Default lEmFech		:= .F. //Everson-Ch:044314-02/10/2019.

	//
	Aadd(aRet, {"","","","",0} )

	//
	If Empty(dDtEmiss) .Or. Empty(cFornec) .Or. Empty(cLoja) .Or. Empty(cNumDoc) .Or. Empty(cSerDoc) .Or. Empty(dDtEnt) .Or. Empty(cRoteiro)
		RestArea(aArea)
		Return aRet

	EndIf

	//
	DbSelectArea("SC5")
	SC5->(DbSetOrder(20))

	//
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))

	//
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	//
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	//
	SC5->(DbGoTop())
	If ! SC5->( DbSeek( FWxFilial("SC5") + DToS(dDtEnt) + Alltrim(cValToChar(cRoteiro)) ) )
		RestArea(aArea)
		Return aRet

	EndIf

	//
	While FWxFilial("SC5") == SC5->C5_FILIAL .And. SC5->C5_DTENTR == dDtEnt .And. SC5->C5_ROTEIRO == cRoteiro

		//
		SA1->(DbGoTop())
		If SA1->( DbSeek( FWxFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )

			//Rosaves.
			If Alltrim(cValToChar(SA1->A1_COD)) + Alltrim(cValToChar(SA1->A1_LOJA)) $cClRosaves
				lRosaves := .T.	

			EndIf

			//Guarantâ.
			If Alltrim(cValToChar(SA1->A1_COD)) + Alltrim(cValToChar(SA1->A1_LOJA)) $cClGuarata
				lGuaranta := .T.	

			EndIf

			//Cliente exportação.
			If Alltrim(cValToChar(SA1->A1_EST)) = 'EX'
				nEstCli := 1

			ElseIf Alltrim(cValToChar(SA1->A1_EST)) <> 'EX' .And. Alltrim(cValToChar(SA1->A1_EST)) <> 'SP' //Interestadual.
				nEstCli := 2

			Else //Estadual.
				nEstCli := 3

			EndIf

		EndIf

		//
		SC6->(DbGoTop())
		If SC6->(DbSeek( FWxFilial("SC6") + SC5->C5_NUM ))

			//
			While FWxFilial("SC6") == SC6->C6_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM

				//TES Coopeval.
				If Alltrim(cValToChar(SC6->C6_TES)) $cTesCop
					lCopeval := .T.
					Exit

				EndIf

				//TES de armazenagem.
				If Alltrim(cValToChar(SC6->C6_TES)) $cTesArma
					lArmazena := .T.
					Exit

				EndIf

				//Grupo de subproduto.
				SB1->(DbGoTop())
				If SB1->( DbSeek( FWxFilial("SB1") + Alltrim(cValToChar(SC6->C6_PRODUTO)) ) )

					//
					If Alltrim(cValToChar(SB1->B1_GRUPO)) $cGrpSbPrd
						lSubprod := .T.
						Exit

					EndIf

				EndIf

				SC6->(DbSkip())

			End

		EndIf

		//
		If lCopeval .Or. lArmazena .Or. lSubprod
			Exit

		EndIf

		SC5->(DbSkip())

	End

	//
	If Day(dDtEmiss) >= Val(aDiaFim[1]) .And. Day(dDtEmiss) <= Val(aDiaFim[2]) .And. ! lEmFech //Everson-Ch:044314-02/10/2019.
		cCond := aCond[1]

	Else
		cCond := aCond[2]

	EndIf

	//
	aRet := {}

	//Condição de pagamento, produto, conta contábil, item da conta contábil, centro de custo, local.
	If lRosaves //Rosaves.
		aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL402"))),"|")
		Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),2} )

	ElseIf lGuaranta //Guarantã.
		aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL403"))),"|")
		Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC",3)} )

	ElseIf lCopeval                                  //Coopeval. TES 819 895.
		aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL405"))),"|")
		Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),5} )

	ElseIf lArmazena                                 //Frete armazenagem - TES 583.
		aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL404"))),"|")
		Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC",4)} )

	ElseIf lSubprod 							     //Subproduto. 
		aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL409"))),"|")
		Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),8} )

	ElseIf nEstCli == 1 //Exportação.
		aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL401"))),"|")
		Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),1} )

	ElseIf nEstCli == 2 .And. ! lSubprod            //Longo percurso.
		aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL407"))),"|")
		Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),6} )

	ElseIf nEstCli == 3 .And. ! lSubprod 		     //Varejo.
		aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL408"))),"|")
		Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),7} )

	Else
		Aadd(aRet, {"","","","",9} )

	EndIf

	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} prFrtFrvV
	Retorna parâmetros para geração de pedido de compra de frete de frango vivo.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
Static Function prFrtFrvV(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)

	//Variáveis.	
	Local aArea			:= GetArea()
	Local nTpFrtS		:= U_ADLG40H()
	Local aDiaFim		:= getDiasF(nTpFrtS)
	Local aPrdCC		:= {}
	Local cCond 		:= ""
	Local aRet			:= {}
	Local aCond			:= getConPg(nTpFrtS)

	Default lEmFech		:= .F. //Everson-Ch:044314-02/10/2019.

	//
	Aadd(aRet, {"","","","",0} )

	//
	If Empty(dDtEmiss)
		RestArea(aArea)
		Return aRet

	EndIf

	//
	If Day(dDtEmiss) >= Val(aDiaFim[1]) .And. Day(dDtEmiss) <= Val(aDiaFim[2]) .And. ! lEmFech //Everson-Ch:044314-02/10/2019.
		cCond := aCond[1]

	Else
		cCond := aCond[2]

	EndIf

	//
	aRet := {}
	aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL420"))),"|")
	Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10} )

	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} prFrtOvo
	Retorna parâmetros para geração de pedido de compra de frete de ovo.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
Static Function prFrtOvo(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)
	
	//Variáveis.	
	Local aArea			:= GetArea()
	Local nTpFrtS		:= U_ADLG40H()
	//Local aDiaFim		:= getDiasF(nTpFrtS)
	Local aPrdCC		:= {}
	Local cCond 		:= ""
	Local aRet			:= {}
	Local aCond			:= getConPg(nTpFrtS)
	Local cQuery		:= ""
	Local cCcFch		:= ""

	//Everson - 28/08/2020. Chamado 060994.
	//Local cLote 		:= ""
	//Local cDesLote		:= ""
	//Local cCC 			:= ""
	//

	Default lEmFech		:= .F. 

	//Everson - 21/01/2020 - Chamado 054941.
	Aadd(aRet, {"","","","",0,"",""} )

	//
	If Empty(dDtEmiss)
		RestArea(aArea)
		Return aRet

	EndIf

	//
	If ! lEmFech//Day(dDtEmiss) >= Val(aDiaFim[1]) .And. Day(dDtEmiss) <= Val(aDiaFim[2]) .And. ! lEmFech //Everson - 06/03/2020. Chamado 054941.
		cCond := aCond[1]

	Else
		cCond := aCond[2]

	EndIf

	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " TOP 1 ZCN_LOTE, ZCN_DESCLT, ZCN_CENTRO, D2_DOC, F4_DUPLIC, F2_DOC, F2_EST, ZCN.R_E_C_N_O_ AS REC, F2_CLIENTE,F2_LOJA " //Everson - 17/03/2020. Chamado 054941. //Everson - 30/09/2020. Chamado 1826.
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 ON  " 
	cQuery += " ZFK_FILIAL = D2_FILIAL " 
	cQuery += " AND ZFK_NOTA = D2_DOC " 
	cQuery += " AND ZFK_SERIE = D2_SERIE " 
	cQuery += " AND ZFK_PEDVEN = D2_PEDIDO " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " " + RetSqlName("ZCN") + " (NOLOCK) AS ZCN ON " 
	cQuery += " D2_FILIAL = ZCN_FILIAL " 
	cQuery += " AND D2_LOCAL = ZCN_ARMAZE " 
	cQuery += " INNER JOIN  " 
	cQuery += " " + RetSqlName("SF4") + " (NOLOCK) AS SF4 ON " 
	cQuery += " D2_TES = F4_CODIGO " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SF2") + " (NOLOCK) AS SF2 ON "
	cQuery += " D2_FILIAL = F2_FILIAL "
	cQuery += " AND D2_DOC = F2_DOC "
	cQuery += " AND D2_SERIE = F2_SERIE "
	cQuery += " WHERE " 
	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_NUMDOC = '" + cNumDoc + "' " 
	cQuery += " AND ZFK_SERDOC = '" + cSerDoc + "' " 
	cQuery += " AND ZFK_TRANSP = '" + cFornec + "' " 
	cQuery += " AND ZFK_LOJA = '" + cLoja + "' " 
	cQuery += " AND ZFK_TPDOC = '1' " 
	cQuery += " AND ZFK_STATUS = '1' "
	cQuery += " AND ZCN_STATUS = 'A' " 
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	cQuery += " AND SD2.D_E_L_E_T_ = '' " 
	cQuery += " AND ZCN.D_E_L_E_T_ = '' " 
	cQuery += " AND SF4.D_E_L_E_T_ = '' " 
	cQuery += " AND SF2.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY REC DESC " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - prFrtOvo - cQuery " + cQuery )

	//
	If Select("D_CCOVO") > 0
		D_CCOVO->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_CCOVO"
	DbSelectArea("D_CCOVO")
	D_CCOVO->(DbGoTop())
	If D_CCOVO ->(Eof())
		D_CCOVO->(DbCloseArea())
		RestArea(aArea)
		Return aRet

	EndIf

	//Everson - 30/09/2020. Chamado 1826.
	If lEmFech

		//
		cCcFch := Alltrim(cValToChar(GetMv("MV_#ADL432")))

		//
		If Alltrim(D_CCOVO->F4_DUPLIC) == "S"
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL430"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],cCcFch,Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,Space(TamSX3("C7_XLOTECC")[1]),Space(TamSX3("ZCN_DESCLT")[1])} ) //Everson - 17/03/2020. Chamado 054941.

		Else
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL421"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],cCcFch,Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,Space(TamSX3("C7_XLOTECC")[1]),Space(TamSX3("ZCN_DESCLT")[1])} ) //Everson - 17/03/2020. Chamado 054941.

		EndIf

	Else 

		//
		If Alltrim(D_CCOVO->F2_CLIENTE) $GetMv("MV_#CTEEXC",,"") //Everson - 30/09/2020. Chamado 1826.
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL421"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],D_CCOVO->ZCN_CENTRO,Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,D_CCOVO->ZCN_LOTE,D_CCOVO->ZCN_DESCLT} ) //Everson - 17/03/2020. Chamado 054941.

		ElseIf Alltrim(D_CCOVO->F4_DUPLIC) == "S" .And. Alltrim(D_CCOVO->F2_DOC) == "SP"
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL430"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,Space(TamSX3("C7_XLOTECC")[1]),Space(TamSX3("ZCN_DESCLT")[1])} ) //Everson - 17/03/2020. Chamado 054941.

		ElseIf  Alltrim(D_CCOVO->F4_DUPLIC) == "S" .And. Alltrim(D_CCOVO->F2_DOC) <> "SP"
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL431"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,Space(TamSX3("C7_XLOTECC")[1]),Space(TamSX3("ZCN_DESCLT")[1])} ) //Everson - 17/03/2020. Chamado 054941.

		ElseIf  Alltrim(D_CCOVO->F4_DUPLIC) == "N" .And. ! Empty(Alltrim(D_CCOVO->ZCN_LOTE))
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL421"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],D_CCOVO->ZCN_CENTRO,Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,D_CCOVO->ZCN_LOTE,D_CCOVO->ZCN_DESCLT} ) //Everson - 17/03/2020. Chamado 054941.

		EndIf

	EndIf

	//Everson - 06/03/2020. Chamado 054941.
	/*If lEmFech

		//
		cCcFch := Alltrim(cValToChar(GetMv("MV_#ADL432")))

		//
		If Alltrim(D_CCOVO->F4_DUPLIC) == "S"
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL430"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],cCcFch,Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,Space(TamSX3("C7_XLOTECC")[1]),Space(TamSX3("ZCN_DESCLT")[1])} ) //Everson - 17/03/2020. Chamado 054941.

		Else
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL421"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],cCcFch,Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,Space(TamSX3("C7_XLOTECC")[1]),Space(TamSX3("ZCN_DESCLT")[1])} ) //Everson - 17/03/2020. Chamado 054941.

		EndIf

	Else 

		//Everson - 28/08/2020. Chamado 060994.
		cCC     := D_CCOVO->ZCN_CENTRO
		cLote 	:= Iif(!Empty(Alltrim(D_CCOVO->ZCN_LOTE))  ,Alltrim(D_CCOVO->ZCN_LOTE)  ,Space(TamSX3("C7_XLOTECC")[1]))
		cDesLote:= IIf(!Empty(Alltrim(D_CCOVO->ZCN_DESCLT)),Alltrim(D_CCOVO->ZCN_DESCLT),Space(TamSX3("ZCN_DESCLT")[1]))

		//
		If Alltrim(D_CCOVO->F2_EST) == "SP" //Everson - 28/08/2020. Chamado 060994.
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL430"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],cCC,Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,cLote,cDesLote} ) //Everson - 17/03/2020. Chamado 054941. //Everson - 28/08/2020. Chamado 060994.

		ElseIf Alltrim(D_CCOVO->F2_EST) <> "SP" //Everson - 28/08/2020. Chamado 060994.Y
			aRet := {}
			aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL431"))),"|")
			Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10,Space(TamSX3("C7_XLOTECC")[1]),Space(TamSX3("ZCN_DESCLT")[1])} ) //Everson - 17/03/2020. Chamado 054941. //Everson - 28/08/2020. Chamado 060994.

		EndIf

	EndIf*/

	//
	D_CCOVO->(DbCloseArea())

	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} prFrtPinto
	Retorna parâmetros para geração de pedido de compra de frete de pintinho. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
Static Function prFrtPinto(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)
	
	//Variáveis.	
	Local aArea			:= GetArea()
	Local nTpFrtS		:= U_ADLG40H()
	Local aDiaFim		:= getDiasF(nTpFrtS)
	Local aPrdCC		:= {}
	Local cCond 		:= ""
	Local aRet			:= {}
	Local aCond			:= getConPg(nTpFrtS)

	Default lEmFech		:= .F. 

	//Everson - 21/01/2020 - Chamado 054941.
	Aadd(aRet, {"","","","",0} )

	//
	If Empty(dDtEmiss)
		RestArea(aArea)
		Return aRet

	EndIf

	//
	If Day(dDtEmiss) >= Val(aDiaFim[1]) .And. Day(dDtEmiss) <= Val(aDiaFim[2]) .And. ! lEmFech
		cCond := aCond[1]

	Else
		cCond := aCond[2]

	EndIf

	//
	aRet := {}
	aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL425"))),"|")
	Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10} )

	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} prFrtRacao
	Retorna parâmetros para geração de pedido de compra de frete de ração. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
Static Function prFrtRacao(dDtEmiss,cFornec,cLoja,cNumDoc,cSerDoc,dDtEnt,cRoteiro,lEmFech)
	
	//Variáveis.	
	Local aArea			:= GetArea()
	Local nTpFrtS		:= U_ADLG40H()
	Local aDiaFim		:= getDiasF(nTpFrtS)
	Local aPrdCC		:= {}
	Local cCond 		:= ""
	Local aRet			:= {}
	Local aCond			:= getConPg(nTpFrtS)

	Default lEmFech		:= .F. 

	//Everson - 21/01/2020 - Chamado 054941.
	Aadd(aRet, {"","","","",0} )

	//
	If Empty(dDtEmiss)
		RestArea(aArea)
		Return aRet

	EndIf

	//
	If Day(dDtEmiss) >= Val(aDiaFim[1]) .And. Day(dDtEmiss) <= Val(aDiaFim[2]) .And. ! lEmFech
		cCond := aCond[1]

	Else
		cCond := aCond[2]

	EndIf

	//
	aRet := {}
	aPrdCC := StrToKarr(Alltrim(cValToChar(GetMv("MV_#ADL426"))),"|")
	Aadd(aRet, {cCond,aPrdCC[1],aPrdCC[2],Posicione("SB1",1,FWxFilial("SB1") + aPrdCC[1] ,"B1_DESC"),10} )

	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} grPedCom
	Processa registros do objeto MsNewGetDados da função ADLG40B, para geração de pedido de compra. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 25/06/2019
	@version 01
	/*/
Static Function grPedCom()

	//Variáveis.
	Local aArea	 	:= GetArea()
	Local nTpFrtS	:= U_ADLG40H()
	Local i		 	:= 1
	Local aValores	:= {}
	Local cCond		:= ""
	Local cUpdat	:= ""
	Local nNumPedC	:= ""
	Local cCodTran	:= ""
	Local cLojTran	:= ""
	Local cNumDoc	:= ""
	Local cSrDoc	:= ""
	Local cProduto	:= ""
	Local xPula		:= Chr(13) + Chr(10)
	Local cCC		:= ""
	Local aClvlPC	:= Separa(Alltrim(GetMv("MV_#ADL406")),'/',.T.) //Everson - 05/11/2019. Chamado 029058.
	Local cClvlPC	:= aClvlPC[nTpFrtS]
	Local aResp		:= Separa(Alltrim(GetMv("MV_#ADL417")),'/',.T.) //Everson - 05/11/2019. Chamado 029058.
	Local cResp	 	:= aResp[nTpFrtS]
	Local cObs		:= ""
	Local cDocs		:= ""
	Local lRet		:= .F.
	Local dEmissao	:= Date()
	Local cPlaca	:= ""
	Local cNmTrans	:= ""
	Local cTes		:= ""

	Local aOcFech	:= StrToKarr(Alltrim(GetMv("MV_#OCFHFT",,"106/107")),"/") //Everson-Ch:044314-10/10/2019.
	Local cOcFAcr	:= Alltrim(aOcFech[1]) //Everson-Ch:044314-10/10/2019.
	Local lPedFch	:= .F. //Everson-Ch:044314-10/10/2019.
	Local cLote		:= ""  //Everson-Ch:054941-06/03/2020.

	//
	If ! MsgYesNo("Deseja gerar pedidos de compra?","Função grPedCom(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	For i :=1 To Len(oDocs:aCols)

		//
		cCond	 := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRCONPAG" })]))
		cProduto := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPROD"   })]))
		cCC		 := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRCC"     })]))
		nTpFrt	 := oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2])     == "CRTPFRT"	 })]
		cPlaca	 := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPLACA"	 })]))
		cTes	 := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRTES"	 })])) //Everson-Ch:044314-30/07/2019.
		cLote 	 := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRLCR"	 })])) //Everson-Ch:054941-06/03/2020.

		//Para CT-e de frete exportação, o pedido não é gerado de forma automática. A inclusão do CT-e precisa ser feita manualmente.
		If ! Empty(cCond) .And. ! Empty(cProduto) .And. ! Empty(cCC) .And. nTpFrt <> 1 .And. ! Empty(cTes) //Everson-Ch:044314-30/07/2019.

			//
			dEmissao := oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRDTEMIS" })]
			cCodTran := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRTRAN" })]))
			cLojTran := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRLOJA" })]))
			cNumDoc	 := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRNUMDOC" })]))
			cSrDoc	 := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSRDOC" })]))
			cRot	 := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRROT" })]))
			cDtEnt	 := DToC(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRDTE" })])

			lPedFch	 := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CROCORR" })])) == cOcFAcr

			cObs	 := "Ger. Aut. - CT-e " + cNumDoc + "/" + cSrDoc + " Rot.: " + cRot + "-" + cDtEnt + " - " + cPlaca + Iif( lPedFch," - Fechamento - " + retDescFrt( nTpFrtS ),"" ) //Everson-Ch:044314-10/10/2019. //Everson - 05/11/2019. Chamado 029058.
			cDocs 	 += "'" + cNumDoc + cSrDoc + "',"
			cNmTrans := Alltrim(cValToChar(oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRNMTR" })]))
			
			//
			Aadd(aValores, {oDocs:aCols[i,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRVALOR" })], cProduto, cCC, cObs, cClvlPC, cNumDoc, cSrDoc, cTes,cLote} ) //Everson-Ch:044314-30/07/2019. //Everson - 06/03/2020. Chamado 054941.

			//
			If nTpFrtS == 3 .Or. ( i == Len(oDocs:aCols) .Or.; //Everson - 06/03/2020. Chamado 054941.
			cCodTran <> oDocs:aCols[i+1,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRTRAN" })] .Or.;
			cLojTran <> oDocs:aCols[i+1,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRLOJA" })] ) .And. Len(aValores) > 0

				//
				lRet := .F.
				MsAguarde({|| lRet := geraSC7("I",cCodTran, cLojTran, aValores,@nNumPedC,cCond,.F.,dEmissao,cResp) },"Aguarde","Ger. pedido | Fornecedor: " + cCodTran + "-" + cLojTran)

				//
				If lRet

					//
					cDocs  := Substr(cDocs,1,Len(cDocs)-1)
					cUpdat := " UPDATE " + RetSqlName("ZFK") + " SET ZFK_PEDCOM = '" + nNumPedC + "' WHERE ZFK_FILIAL = '" + FWxFilial("ZFK") + "' AND ZFK_TRANSP = '" + cCodTran + "' AND ZFK_LOJA = '" + cLojTran + "' AND RTRIM(LTRIM(ZFK_NUMDOC)) + RTRIM(LTRIM(ZFK_SERDOC)) IN (" + cDocs + ") AND ZFK_TPDOC = '1' AND ZFK_STATUS = '1' AND D_E_L_E_T_ = '' "

					//
					If TCSqlExec(cUpdat) < 0
						MsgAlert("Não foi possível realizar o update na tabela ZFK." + xPula + TCSQLError() ,"Função grPedCom(ADLOG040P)")

					Else

						//Everson-Ch:044314-26/07/2019.
						cUpdat := ""
						cUpdat += " UPDATE " 
						cUpdat += " " + RetSqlName("ZFA") + "  " 
						cUpdat += " SET ZFA_PEDADT = '" + nNumPedC + "' " 
						cUpdat += " FROM " 
						cUpdat += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK " 
						cUpdat += " INNER JOIN " 
						cUpdat += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA ON " 
						cUpdat += " ZFK_FILIAL = ZFA_FILIAL " 
						cUpdat += " AND ZFK_CODZFA = ZFA_COD " 
						cUpdat += " AND ZFK_TRANSP = ZFA_TRANPA " 
						cUpdat += " AND ZFK_LOJA = ZFA_LJPPAG " 
						cUpdat += " WHERE " 
						cUpdat += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
						cUpdat += " AND ZFK_PEDCOM = '" + nNumPedC + "' " 
						cUpdat += " AND ZFK.D_E_L_E_T_ = '' " 
						cUpdat += " AND ZFA.D_E_L_E_T_ = '' " 
						cUpdat += " AND RTRIM(LTRIM(ZFA_VA)) = '" + cValToChar(nTpFrtS) + "' " //Everson - 05/11/2019 - Chamado 052666.
						
						//
						If TCSqlExec(cUpdat) < 0
							MsgAlert("Não foi possível realizar o update na tabela ZFA." + xPula + TCSQLError() ,"Função grPedCom(ADLOG040P)")

						EndIf

					EndIf
					
					//Everson - 14/10/2019. Chamado 044314.
					//Everson - 29/07/2019. Chamado 044314.
					Conout( DToC(Date()) + " " + Time() + " ADLOG040P - grPedCom - Pedido de compra " + nNumPedC + " gerado para o fornecedor " + cCodTran + "/" + cLojTran + "-" + cNmTrans + ".Referente ao(s) CT-e(s): " + Chr(13) + Chr(10) + cDocs)

				EndIf

				//
				aValores := {}
				cDocs    := ""

			EndIf

		EndIf

	Next i

	//
	Pergunte("CTE3",.F.)
	MsAguarde({ || carCTE() },"Aguarde","Obtendo dados...")

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} geraSC7
	Gera pedido de compra. Chamado 044314.
	@type  Static Function
	@author Ricardo Lima
	@since 30/11/2018
	@version 01
	/*/
Static Function geraSC7(cOpc,cCodTran, cLojTran, aValores, nNumPedC, cCond, lUpdt, dEmissao, cResp, cPlaca, cCodZFA)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local aCab     	:= {}
	Local aItens   	:= {}
	Local aLinha   	:= {}
	Local cNumPc   	:= ""
	Local nAux2		:= 1
	Local nTotLiq	:= 0
	Local cUptZFA	:= ""
	Local lLocaPed	:= .F.
	Local cNmFor	:= ""
	Local cProduto	:= ""
	Local cCC		:= ""
	Local cObs		:= ""
	Local cClvlPC 	:= ""
	Local cNumDoc	:= ""
	Local cSrDoc	:= ""
	Local cTes		:= "" //Everson-Ch:044314-30/07/2019.
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	Local cLote		:= "" //Everson - 06/03/2020. Chamado 054941.

	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.

	Default nNumPedC	:= ""
	Default lUpdt		:= .T.
	Default cResp		:= ""
	Default cPlaca		:= ""
	Default cCodZFA		:= ""

	//
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	If DbSeek( FWxFilial("SA2") + cCodTran + cLojTran )
		cNmFor	:= SA2->A2_NOME

	Else
		MsgStop("Não foi possível localizar o cadastro de fornecedor. " + Chr(13) + Chr(10) + cCodTran + "/" + cLojTran,"Função geraSC7(ADLOG040P)")
		lRet := .F.
		RestArea(aArea)
		Return lRet

	Endif

	//
	If cOpc == "I"
		//cNumPc := GetSXENum("SC7","C7_NUM")
		cNumPc := u_SXESXF("SC7") // @history ticket    3873 - Fernando Macieira - 23/11/2020 - Projeto - Contrato e Controle de Entradas - São Carlos

	Else
		DbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		If ! SC7->( DbSeek( FWxFilial("SC7") + nNumPedC ) )
			MsgStop("Não foi possível localizar o pedido de compra. " + Chr(13) + Chr(10) + nNumPedC + " " + cCodTran + "/" + cLojTran,"Função geraSC7(ADLOG040P)")
			lRet := .F.
			RestArea(aArea)
			Return lRet

		EndIf

		//
		cNumPc := nNumPedC

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - geraSC7 - cNumPc " + cValToChar(cNumPc) )

	//
	If cOpc == "I"

		//Aadd(aCab,{"C7_NUM" 	,cNumPc    	}) // // @history ticket TI   - Fernando Macieira - 04/12/2020 - Checar se o PC existe na base antes de efetuar o execauto
		Aadd(aCab,{"C7_EMISSAO"	,dEmissao	})
		Aadd(aCab,{"C7_FORNECE"	,cCodTran  	})
		Aadd(aCab,{"C7_LOJA" 	,cLojTran  	})
		Aadd(aCab,{"C7_COND"	,cCond   	})
		Aadd(aCab,{"C7_CONTATO"	,""        	})
		Aadd(aCab,{"C7_FILENT"	,FWxFilial("SC7") })

		For nAux2 := 1 To Len(aValores)

			//
			nTotLiq := aValores[nAux2][1]
			cProduto:= aValores[nAux2][2]
			cCC		:= aValores[nAux2][3]
			cObs	:= aValores[nAux2][4]
			cClvlPC := aValores[nAux2][5]
			cNumDoc	:= aValores[nAux2][6]
			cSrDoc	:= aValores[nAux2][7]
			cTes	:= aValores[nAux2][8] //Everson-Ch:044314-30/07/2019.
			cLote	:= aValores[nAux2][9] //Everson-Ch:044314-30/07/2019.

			//
			aLinha := {}
			Aadd(aLinha,{"C7_PRODUTO" 	,cProduto           ,Nil})
			Aadd(aLinha,{"C7_QUANT" 	,1                  ,Nil})
			Aadd(aLinha,{"C7_PRECO" 	,nTotLiq            ,Nil})
			Aadd(aLinha,{"C7_TOTAL" 	,nTotLiq            ,Nil})
			Aadd(aLinha,{"C7_CC" 		,cCC            	,Nil})
			Aadd(aLinha,{"C7_CLVL"     	,cClvlPC           	,Nil})
			Aadd(aLinha,{"C7_XRESPON" 	,cResp              ,Nil})
			Aadd(aLinha,{"C7_XTIPCTE" 	,"CTE"              ,Nil})  
			Aadd(aLinha,{"C7_OBS" 	    ,cObs             	,Nil}) 
			Aadd(aLinha,{"C7_XNUMCTE" 	,Padl(cNumDoc,9,"0"),Nil}) 
			Aadd(aLinha,{"C7_XNUSCTE" 	,Padl(cSrDoc ,3,"0"),Nil})  
			Aadd(aLinha,{"C7_TES" 		,cTes               ,Nil}) //Everson-Ch:044314-30/07/2019.

			//Everson - 06/03/2020. Chamado 054941.
			If nTpFrtS == 3 .And. ! Empty(cLote)
				Aadd(aLinha,{"C7_XLOTECC" 		,cLote      ,Nil}) 

			EndIf
			//

			Aadd(aItens,aLinha)

		Next nAux2

	Else

		//
		Aadd(aCab,{"C7_NUM" 	,SC7->C7_NUM      })
		Aadd(aCab,{"C7_EMISSAO"	,SC7->C7_EMISSAO  })
		Aadd(aCab,{"C7_FORNECE"	,SC7->C7_FORNECE  })
		Aadd(aCab,{"C7_LOJA" 	,SC7->C7_LOJA 	  })
		Aadd(aCab,{"C7_COND"	,SC7->C7_COND     })
		Aadd(aCab,{"C7_CONTATO"	,SC7->C7_CONTATO  })
		Aadd(aCab,{"C7_FILENT"	,SC7->C7_FILENT   })

		//
		While ! SC7->(Eof()) .And. SC7->C7_FILIAL = FWxFilial("SC7") .And. SC7->C7_NUM = nNumPedC

			//
			aLinha := {}
			Aadd(aLinha,{"C7_PRODUTO"	,SC7->C7_PRODUTO	,Nil})
			Aadd(aLinha,{"C7_QUANT"		,SC7->C7_QUANT      ,Nil})
			Aadd(aLinha,{"C7_PRECO"		,SC7->C7_PRECO      ,Nil})
			Aadd(aLinha,{"C7_TOTAL"		,SC7->C7_TOTAL      ,Nil})
			Aadd(aLinha,{"C7_CC"		,SC7->C7_CC         ,Nil})
			Aadd(aLinha,{"C7_LOCAL"		,SC7->C7_LOCAL      ,Nil})
			Aadd(aLinha,{"C7_CONTA"		,SC7->C7_CONTA      ,Nil})
			Aadd(aLinha,{"C7_ITEMCTA"	,SC7->C7_ITEMCTA    ,Nil})
			Aadd(aLinha,{"C7_CLVL"		,SC7->C7_CLVL 		,Nil})
			Aadd(aLinha,{"C7_XRESPON"	,SC7->C7_XRESPON    ,Nil})
			Aadd(aLinha,{"C7_XTIPCTE"	,SC7->C7_XTIPCTE    ,Nil})  
			Aadd(aLinha,{"C7_OBS"		,SC7->C7_OBS        ,Nil})  
			Aadd(aLinha,{"C7_REC_WT"	,SC7->(RECNO()) 	,Nil})

			//
			Aadd(aItens,aLinha)

			SC7->(DbSkip())

		End

	EndIf
	
	// @history ticket TI   - Fernando Macieira - 04/12/2020 - Checar se o PC existe na base antes de efetuar o execauto
	If cOpc == "I"

		SC7->( dbGoTop() )
		Do While .T.
			SC7->( dbSetOrder(1) )
			If SC7->( dbSeek( FwxFilial("SC7") + cNumPc ) )
				cNumPc := u_SXESXF("SC7")
			Else
				Exit
			EndIf
		EndDo
		//

		Aadd(aCab,{"C7_NUM" 	,cNumPc    	}) 
	
	EndIf

	VarInfo("aCab",aCab)
	VarInfo("aItens",aItens)

	//
	lMsErroAuto := .F.                    
	SetFunName("MATA120")
	MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCab,aItens, Iif(cOpc == "I",3,5 ) ) 

	//
	If lMsErroAuto 
		//RollbackSx8() // @history ticket TI   - Fernando Macieira - 04/12/2020 - Checar se o PC existe na base antes de efetuar o execauto
		lRet := .F.
		MostraErro()

	Else 

		//
		lLocaPed := .F.
		DbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		SC7->(DbGoTop())
		If SC7->(DbSeek( FwxFilial("SC7") + cNumPc ))
			lLocaPed := .T.

		EndIf

		//
		If cOpc == "I"

			//
			If lLocaPed

				//
				//ConfirmSX8() // @history ticket TI   - Fernando Macieira - 04/12/2020 - Checar se o PC existe na base antes de efetuar o execauto
				nNumPedC := cNumPc

				//
				If lUpdt
					cUptZFA := " UPDATE " + RetSqlName("ZFA") + " SET ZFA_PEDCOM = '" + cNumPc + "' "
					cUptZFA += " WHERE "
					cUptZFA += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "' " 
					cUptZFA += " AND ZFA_COD  = '" + cCodZFA + "' AND ZFA_VA = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019 - Chamado 029058.
					cUptZFA += " AND D_E_L_E_T_ = '' "

				EndIf

			Else
				//RollbackSx8() // @history ticket TI   - Fernando Macieira - 04/12/2020 - Checar se o PC existe na base antes de efetuar o execauto
				MsgStop("Não foi possível incluir o pedido de compra para o fornecedor " + cCodTran +"-"+ cLojTran + "/" + cNmFor + "-" + cPlaca + ".","Função geraSC7(ADLOG040P)")
				lRet := .F.

			EndIf

		Else

			//
			If ! lLocaPed

				//
				If lUpdt
					cUptZFA := " UPDATE " + RetSqlName("ZFA") + " SET ZFA_PEDCOM = '' "
					cUptZFA += " WHERE ZFA_FILIAL = '" + FWxFilial("ZFA") + "' " 
					cUptZFA += " AND ZFA_COD  = '" + cCodZFA + "' AND ZFA_VA = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019 - Chamado 029058.
					cUptZFA += " AND D_E_L_E_T_ = '' "

				EndIf

			Else
				MsgStop("Não foi possível excluir o pedido " + cNumPc + " do fornecedor " + cCodTran +"-"+ cLojTran + "/" + cNmFor + ".","Função geraSC7(ADLOG040P)")
				lRet := .F.

			EndIf			

		EndIf

		//
		If lUpdt
			If TCSqlExec(cUptZFA) < 0
				MsgAlert("Não foi possível atualizar os registros da tabela ZFA.","Função geraSC7(ADLOG040P)")

			EndIf

		EndIf

	EndIf

	//
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} User Function ADLG40C
	Interface para execução do fechamento de período do frete. Chamado 044314.
	@type  Function
	@author Everson
	@since 15/05/2019
	@version 01
/*/
User Function ADLG40C()

	//Variáveis.	
	Local aArea			:= GetArea()
	Local nTpFrtS		:= U_ADLG40H()
	Local oModal		:= Nil
	Local oTotTra		:= Nil
	Local oTotVlr		:= Nil
	Local oTotBlq		:= Nil
	Local oDadosP2		:= Nil
	Local aCmpAltP		:= {}
	Local aHToP			:= {}
	Local aColsP		:= {}
	Local aCmpAltP2		:= {} 
	Local aHToP2		:= {}
	Local aColsP2		:= {}
	Local oGroup1		:= Nil
	Local oGroup2		:= Nil
	Local oAtual		:= Nil
	Local oFechar		:= Nil
	Local aFiltro 		:= {"T=Todos","B=Bloqueado","L=Liberado"}
	Local cFiltro		:= aFiltro[1]
	Local bCrgDados		:= {|| MsAguarde({||ADLG146J(oDadosP,aHToP,oTotTra,@nTotTra,oTotVlr,@nTotVlr,oTotBlq,@nTotBlq,cFiltro,oDadosP2,aHTop2),;
											carCTeJEm(aHToP3,aColsP3,oDadosP3);
								},"Aguarde","Carregando dados...") }
	Local aPastas		:= {}
	Local oPastas		:= Nil
	Local oPnlBtn1		:= Nil
	Local oPnlBtn2		:= Nil
	Local lAltPag		:= GetMv("MV_#FRTCON",,.F.)

	//Everson - 10/10/2019 - Chamado 044314.
	Local oDadosP3		:= Nil
	Local aHToP3		:= {}
	Local aColsP3		:= {}
	//

	//Everson - 31/10/2019. Chamado 029058.
	Local oBtnAbast		:= Nil
	Local oBtnEsAb		:= Nil
	Local aImpAbas		:= Separa( Alltrim( GetMv("MV_#LIBABT",,"S/N/N/N/N")),"/",.T.)
	Local lImpAbast		:= Iif( Alltrim(aImpAbas[nTpFrtS]) == "S", .T.,.F.)
	
	Local oBtnAdia		:= Nil
	Local oBtnSAdi		:= Nil
	Local aImpAdia		:= Separa( Alltrim( GetMv("MV_#LIBADI",,"S/N/N/N/N")),"/",.T.)
	Local lImpAdia		:= Iif( Alltrim(aImpAdia[nTpFrtS]) == "S", .T.,.F.)
	//

	//25/06/2020, Everson, Ch: 058332.
	Local oBtnCSI		:= Nil
	Local oBtnCSE		:= Nil
	//

	Private nTotTra		:= 0
	Private nTotVlr		:= 0
	Private nTotBlq		:= 0
	Private cOcorAB 	:= Alltrim(GetMv( "MV_#ADL46D" ,, "010"))
	Private cOcorBo		:= Alltrim(GetMv( "MV_#ADL47D" ,, "040"))
	Private lFchDvg		:= .F.
	Private lFchCndPg	:= .F.

	//Everson - 10/10/2019 - Chamado 044314.
	Private nTotPerF 	:= 0
	Private oTotPerF 	:= Nil
	Private nTotAdiF 	:= 0
	Private oTotAdiF 	:= Nil
	Private nTotBlqF 	:= 0
	Private oTotBlqF 	:= Nil
	Private nTotSldRT	:= 0
	Private oTotSldRT	:= Nil
	Private nTotCTeEF	:= 0
	Private oTotCTeEF	:= Nil
	Private nTotICMSF	:= 0
	Private oTotICMSF	:= Nil
	Private nTotComplF	:= 0
	Private oTotComplF	:= Nil

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//
	If ! Pergunte("ADLG146P",.T.)
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	If MV_PAR02 > Date()
		MsgStop("Data final do fechamento deve ser menor ou igual a data atual.","Função ADLG40C(ADLOG040P)")
		RestArea(aArea)
		Return Nil
			
	EndIf

	//Everson-Ch:044314-25/07/2019
	If lAltPag
		aCmpAltP := {"CONDPAG"} 

	EndIf

	//
	Aadd(aHToP,{" ","LEGENDA"    		,"@BMP", 3, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	Aadd(aHToP,{"Cod Transp"     		,"TFA_TRANPA" ,"" ,TamSX3("ZFA_TRANPA")[1],0,"","","C","",""})
	Aadd(aHToP,{"Loja"           		,"TFA_LJPPAG" ,"" ,TamSX3("ZFA_LJPPAG")[1],0,"","","C","",""})
	Aadd(aHToP,{"Nome"           		,"TFA_NMTPAG" ,"" ,TamSX3("ZFA_NMTPAG")[1],0,"","","C","",""})
	Aadd(aHToP,{"Placa"          		,"TFA_PLACA"  ,"" ,TamSX3("ZFA_VEICPG")[1],0,"","","C","",""})
	Aadd(aHToP,{"Menor Dt"    	  		,"TFA_MINDT"  ,"" ,TamSX3("ZFA_DTENTR")[1],0,"","","D","",""})
	Aadd(aHToP,{"Maior Dt"    	  		,"TFA_MAXDT"  ,"" ,TamSX3("ZFA_DTENTR")[1],0,"","","D","",""})
	Aadd(aHToP,{"Valor do Período"		,"TFA_VALOR"  ,X3Picture('ZFA_VALOR'),TamSX3("ZFA_VALOR")[1], TamSX3("ZFA_VALOR")[1],"","" ,"N","",""})
	Aadd(aHToP,{"Valor do Adiantamento"	,"TFA_VLRAD"  ,X3Picture('ZFA_VALOR'),TamSX3("ZFA_VALOR")[1], TamSX3("ZFA_VALOR")[1],"","" ,"N","",""}) //Everson-Ch:044314-14/08/2019.
	Aadd(aHToP,{"Valor Bloqueado"   	,"TFA_VALORB" ,X3Picture('ZFA_VALOR'),TamSX3("ZFA_VALOR")[1], TamSX3("ZFA_VALOR")[1],"","" ,"N","",""}) 
	Aadd(aHToP,{"Saldo a Receber"   	,"TFA_SALDO"  ,X3Picture('ZFA_VALOR') ,TamSX3("ZFA_VALOR")[1], TamSX3("ZFA_VALOR")[1],"","" ,"N","",""}) //Everson-Ch:044314-14/08/2019.
	Aadd(aHToP,{"Total CT-e Emitido"	,"TFA_TOTACT" ,X3Picture('ZFA_VALOR'),TamSX3("ZFA_VALOR")[1], TamSX3("ZFA_VALOR")[1],"","" ,"N","",""})
	Aadd(aHToP,{"Valor ICMS"		    ,"TFA_ICMS"   ,X3Picture('ZFA_VALOR'),TamSX3("ZFA_VALOR")[1], TamSX3("ZFA_VALOR")[1],"","" ,"N","",""}) //Everson-Ch:044314-15/08/2019.
	Aadd(aHToP,{"Valor Complemento"		,"TFA_TOTAFI" ,X3Picture('ZFA_VALOR'),TamSX3("ZFA_VALOR")[1], TamSX3("ZFA_VALOR")[1],"","" ,"N","",""})	
	Aadd(aHToP,{"CT-e"           		,"TFA_CTE"    ,"" ,TamSX3("ZFK_NUMDOC")[1],0,"","","C","",""})
	Aadd(aHToP,{"Série"          		,"TFA_SCTE"   ,"" ,TamSX3("ZFK_SERDOC")[1],0,"","","C","",""})
	Aadd(aHToP,{"Tp Emissao"     		,"TFA_TPCTE"  ,"" ,TamSX3("ZFK_TPENVC")[1],0,"","","C","",""})
	Aadd(aHToP,{"Chave"          		,"TFA_CHVCTE" ,"" ,TamSX3("ZFK_CHAVE")[1] ,0,"","","C","",""})
	Aadd(aHToP,{"Roteiro"        		,"TFA_ROTEIR" ,"" ,TamSX3("ZFK_ROTEIR")[1] ,0,"","","C","",""})
	Aadd(aHToP,{"Dt Entr"        		,"TFA_DTENTR" ,"" ,TamSX3("ZFK_DTENTR")[1] ,0,"","","D","",""})
	Aadd(aHToP,{"Cond. Pag"		  		,"CONDPAG"    ,"",TamSX3("A2_COND")[1],0,"","","C","SE4",""})

	//
	Aadd(aHToP2,{"Cod Ocorren" ,"TFA_OCORRE" ,"" ,TamSX3("ZFA_OCORRE")[1],0,"","","C","",""})
	Aadd(aHToP2,{"Desc Ocorren","TFA_DESCOC" ,"" ,TamSX3("ZFA_DESCOC")[1],0,"","","C","",""})
	Aadd(aHToP2,{"Deb/Cred"    ,"TFA_DC"     ,"" ,TamSX3("ZFA_DC")[1]    ,0,"","","C","",""})
	Aadd(aHToP2,{"Valor"       ,"TFA_VALOR"  ,X3Picture('ZFA_VALOR')  ,TamSX3("ZFA_VALOR")[1] ,TamSX3("ZFA_VALOR")[2],"","","N","",""})	

	//
	Aadd(aHToP3,{"Dt Fech."		,"TFA_DATA"   ,"" ,TamSX3("ZFK_DTENTR")[1] ,0,"","","D","",""})
	Aadd(aHToP3,{"Cod Transp"	,"TFA_TRANPA" ,"" ,TamSX3("ZFK_TRANSP")[1],0,"","","C","",""})
	Aadd(aHToP3,{"Loja"			,"TFA_LJPPAG" ,"" ,TamSX3("ZFK_LOJA")[1],0,"","","C","",""})
	Aadd(aHToP3,{"Nome"			,"TFA_NMTPAG" ,"" ,TamSX3("ZFA_NMTPAG")[1],0,"","","C","",""})
	Aadd(aHToP3,{"Placa"		,"TFA_PLACA"  ,"" ,TamSX3("ZFK_PLACA")[1],0,"","","C","",""})
	Aadd(aHToP3,{"CT-e"			,"TFA_CTE"    ,"" ,TamSX3("ZFK_NUMDOC")[1],0,"","","C","",""})
	Aadd(aHToP3,{"Série"		,"TFA_SCTE"   ,"" ,TamSX3("ZFK_SERDOC")[1],0,"","","C","",""})
	Aadd(aHToP3,{"Valor"		,"TFA_VALOR"  ,X3Picture('ZFK_VALOR')  ,TamSX3("ZFA_VALOR")[1] ,TamSX3("ZFA_VALOR")[2],"","","N","",""})
	Aadd(aHToP3,{"Hash"			,"TFA_HASH"   ,"" ,TamSX3("ZFK_HASH")[1],0,"","","C","",""})

	//
	oModal			 := MsDialog():Create()
	oModal:cName     := "oModal"
	oModal:cCaption  := "Registros Pendentes de Fechamento"
	oModal:nLeft     := 34
	oModal:nTop      := 222
	oModal:nWidth    := 1200
	oModal:nHeight   := 610
	oModal:lShowHint := .F.
	oModal:lCentered := .T.

	//
	oGroup1	 := TGroup():Create(oModal,001,005,027,595,"",,,.T.)

	oSay:= TSay():New(010,010,{|| "Datas de fechamento: " + DToC(MV_PAR01) + " - " + DToC(MV_PAR02) + " / " + retDescFrt(nTpFrtS) },oModal,,,,,,.T.,CLR_RED,CLR_WHITE,300,50)

	//
	oTotTra  := TGet():New(002,060,{|u|If(PCount() == 0,nTotTra,nTotTra := u)},oModal,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotTra",,,,.T.,,,"Qtd. Transp.:",1) 
	oTotTra:lVisibleControl := .F.

	oTotVlr  := TGet():New(002,065,{|u|If(PCount() == 0,nTotVlr,nTotVlr := u)},oModal,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotVlr",,,,.T.,,,"Subtotal:",1) 
	oTotVlr:lVisibleControl := .F.
	
	oTotBlq  := TGet():New(002,140,{|u|If(PCount() == 0,nTotBlq,nTotBlq := u)},oModal,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotBlq",,,,.T.,,,"Saldo Blq.:",1) 
	oTotBlq:lVisibleControl := .F.
	
	//
	aPastas := {"Agrupado por transportadora e placa","Agrupado por ocorrências","CT-e Emitido"}
	oPastas := TFolder():New(025,005,aPastas,,oModal,,,,.T.,,590,242)
	oPnlBtn1 := TPanel():New(000,000,"",oPastas:aDialogs[1],,.T.,,,,585,207)
	oPnlBtn1:Align := CONTROL_ALIGN_ALLCLIENT

	//Everson - 10/10/2019 - Chamado 044314.
	nTotPerF := 0
	oTotPerF := TGet():New(005,000,{|u|If(PCount() == 0,nTotPerF,nTotPerF := u)},oPnlBtn1,065,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotPerF",,,,.T.,,,"Total Período:",1) 

	nTotAdiF := 0
	oTotAdiF := TGet():New(005,065,{|u|If(PCount() == 0,nTotAdiF,nTotAdiF := u)},oPnlBtn1,065,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotAdiF",,,,.T.,,,"Total Adiant.:",1) 

	nTotBlqF := 0
	oTotBlqF := TGet():New(005,130,{|u|If(PCount() == 0,nTotBlqF,nTotBlqF := u)},oPnlBtn1,065,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotBlqF",,,,.T.,,,"Total Bloq.:",1)

	nTotSldRT := 0
	oTotSldRT := TGet():New(005,195,{|u|If(PCount() == 0,nTotSldRT,nTotSldRT := u)},oPnlBtn1,065,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotSldRT",,,,.T.,,,"Total Saldo R.:",1)

	nTotCTeEF := 0
	oTotCTeEF := TGet():New(005,260,{|u|If(PCount() == 0,nTotCTeEF,nTotCTeEF := u)},oPnlBtn1,065,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotCTeEF",,,,.T.,,,"Total CT-e Emt.:",1)

	nTotICMSF := 0
	oTotICMSF := TGet():New(005,325,{|u|If(PCount() == 0,nTotICMSF,nTotICMSF := u)},oPnlBtn1,065,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotICMSF",,,,.T.,,,"Total ICMS:",1)

	nTotComplF := 0
	oTotComplF := TGet():New(005,390,{|u|If(PCount() == 0,nTotComplF,nTotComplF := u)},oPnlBtn1,065,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotComplF",,,,.T.,,,"Total Compl.:",1)

	//
	oDadosP := MsNewGetDados():New(030,000,220,500,GD_UPDATE,"Allwaystrue()","Allwaystrue()","",aCmpAltP,Nil,999,Nil,Nil,Nil,oPnlBtn1,aHToP,@aColsP)

	oPnlBtn2 := TPanel():New(000,000,"",oPastas:aDialogs[2],,.T.,,,,585,207)
	oPnlBtn2:Align := CONTROL_ALIGN_ALLCLIENT

	oDadosP2 := MsNewGetDados():New(000,000,220,585,,"Allwaystrue()","Allwaystrue()","",aCmpAltP2,Nil,999,Nil,Nil,Nil,oPnlBtn2,aHToP2,@aColsP2)

	oGroup2	 := TGroup():Create(oModal,269,005,289,595,"",,,.T.)

	//Everson - 10/10/2019. Chamado 044314.
	oPnlBtn3 := TPanel():New(000,000,"",oPastas:aDialogs[3],,.T.,,,,585,207)
	oDadosP3 := MsNewGetDados():New(000,000,200,500,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnlBtn3,aHToP3,@aColsP3)

	//
	TButton():New(005,505,"Registros Transportadora",oPnlBtn1,{|| MsAguarde({|| aprovConf(oDadosP,aHToP,MV_PAR01,MV_PAR02) },"Aguarde","Carregando dados...") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnAdia  := TButton():New(030,505,"Lançar Adiantamento"     ,oPnlBtn1,{|| MsAguarde({|| gerAdianta() },"Aguarde","Efetuando lançamentos...")  , Eval(bCrgDados) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnSAdi  := TButton():New(050,505,"Estornar Adiantamento"   ,oPnlBtn1,{|| MsAguarde({|| estAdianta() },"Aguarde","Estornando lançamentos...") , Eval(bCrgDados) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnAbast := TButton():New(070,505,"Importar Abastecimento"  ,oPnlBtn1,{|| MsAguarde({|| abastc(oDadosP,aHToP) }    ,"Aguarde","Importando registros...")   , Eval(bCrgDados) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnEsAb  := TButton():New(090,505,"Estornar Abastecimento"  ,oPnlBtn1,{|| MsAguarde({|| estAbast(2,oDadosP,aHToP) } ,"Aguarde","Estornando registros...")   , Eval(bCrgDados) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )		
	
	//25/06/2020, Everson, Ch: 058332.
	oBtnCSI  := TButton():New(110,505,"Lançar Desc Seguro"    ,oPnlBtn1,{|| Processa({||;
									U_ADLOG070P(nTpFrtS,1,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR05,MV_PAR07,MV_PAR08);
									},"Aguarde","Importando registros...")   , Pergunte("ADLG146P",.F.), Eval(bCrgDados) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	oBtnCSE  := TButton():New(130,505,"Estornar Desc Seguro"  ,oPnlBtn1,{|| Processa({||;
									U_ADLOG070P(nTpFrtS,2,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR05,MV_PAR07,MV_PAR08);
									},"Aguarde","Estornando registros...")   , Pergunte("ADLG146P",.F.), Eval(bCrgDados) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	//

	TButton():New(150,505,"Relatório Movimentação"  ,oPnlBtn1,{|| MsAguarde({|| U_ADLOG045R() },"Aguarde","Gerando relatório...")   , Pergunte("ADLG146P",.F.) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//Everson-Ch:044314-14/08/2019.
	TButton():New(170,505,"Enviar Fechamento"       ,oPnlBtn1,{|| MsAguarde({|| U_ADLOG060R() },"Aguarde","Gerando relatório...")   , Pergunte("ADLG146P",.F.) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//Everson-Ch:044314-14/08/2019.
    TButton():New(185,505,"Enviar Adiantamento"     ,oPnlBtn1,{|| MsAguarde({|| SendADI() },"Aguarde","Enviando adiantamento...")   , Pergunte("ADLG146P",.F.) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )	// @history ticket 14223 - Fernando Macieira - 09/06/2021 - E-mail automático adiantamento de frete
	TButton():New(205,505,"Fechar Período"          ,oPnlBtn1,{|| Processa({||  Eval(bCrgDados), fechFrt(oDadosP,aHToP), Eval(bCrgDados), Pergunte("ADLG146P",.F.), MsgInfo("Processo finalizado.","Função fechFrt (ADLOG040P)")},"Aguarde","Processando fechamento...",.F.) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	//Everson - 31/10/2019 - Chamado 029058.
	oBtnAbast:SetDisable(!lImpAbast)
	oBtnEsAb:SetDisable(!lImpAbast)
	oBtnAdia:SetDisable(!lImpAdia)
	oBtnSAdi:SetDisable(!lImpAdia)
	
	//Everson - 10/10/2019 - Chamado 044314.
	TButton():New(005,505,"Consulta CT-e"  ,oPnlBtn3,{|| MsAguarde({|| funcCTE(oDadosP3,aHToP3,1) },"Aguarde","Carregando dados....") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(030,505,"Download DACTE" ,oPnlBtn3,{|| MsAguarde({|| funcCTE(oDadosP3,aHToP3,2) },"Aguarde","Carregando dados....") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(055,505,"Download XML"   ,oPnlBtn3,{|| MsAguarde({|| funcCTE(oDadosP3,aHToP3,3) },"Aguarde","Carregando dados....") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	//
	TButton():New(274,010,"Legenda",oModal, {|| lgdFchPer() } ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oAtual	 := TButton():New(274,505,"Atualizar",oModal, {|| Iif( Pergunte("ADLG146P",.T.), Eval(bCrgDados) , Nil) } ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )	//Everson-Ch:044314-14/08/2019.
	oFechar	 := TButton():New(274,550,"Fechar",oModal,{||oModal:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")		

	oModal:Activate(,,,.T.,{||.T.},, bCrgDados )	

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} obtPlacas
	Retorna string com valor de campo do objeto MsNewGetDados separada por ",". Chamado 029058.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
// Static Function obtVlrCmp(oObj,aCabec,cCampo)

// 	//Variáveis.
// 	Local aArea		:= GetArea()
// 	Local cPlacas	:= ""
// 	Local nAux		:= 1

// 	//
// 	For nAux := 1 To Len(oObj:aCols)
// 		cPlacas += "'" + Alltrim(oObj:aCols[nAux,Ascan(aCabec,{|x| AllTrim(x[2]) == cCampo})]) + "'" + Iif(nAux < Len(oObj:aCols),",","")

// 	Next nAux
	
// 	//
// 	RestArea(aArea)

// Return cPlacas
/*/{Protheus.doc} ADLG146J
	Executa funções para exibição dos dados de fechamento de período de frete.
	@type  Static Function
	@author Everson
	@since 22/03/2019
	@version 01
	/*/
Static Function ADLG146J(oDadosP,aHToP,oTotTra,nTotTra,oTotVlr,nTotVlr,oTotBlq,nTotBlq,cFiltro,oDadosP2,aHTop2)

	//
	If MV_PAR02 > Date()
		MsgStop("Data final do fechamento deve ser menor ou igual a data atual.","Função ADLG146J(ADLOG040P)")
		Return Nil
			
	EndIf

	agrpTrap(oDadosP,aHToP,oTotTra,@nTotTra,oTotVlr,@nTotVlr,oTotBlq,@nTotBlq,cFiltro)

	agrpOcorre(oDadosP2,aHTop2,cFiltro)

Return Nil
/*/{Protheus.doc} agrpTrap
	Carrega informações no objeto MsNewGetDados da rotina ADLG40C para o período informado, agrupo por transportadora e 
	placa para fechamento de período de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 22/03/2019
	@version 01
	/*/
Static Function agrpTrap(oDadosP,aHToP,oTotTra,nTotTra,oTotVlr,nTotVlr,oTotBlq,nTotBlq,cFiltro)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cQuery   		:= ""
	Local cChkBlq		:= ""
	Local cCondPg		:= ""
	Local nTpFrtS		:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	Local aCond			:= getConPg(nTpFrtS) //Everson - 05/11/2019. Chamado 029058.
	Local aCTeEmit		:= vlrCTEmit()
	Local nPos			:= 0

	Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
	Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")

	Default cFiltro		:= "T"

	//
	oDadosP:aCols := {}
	nTotTra := 0
	nTotVlr := 0
	nTotBlq	:= 0

	//Everson - 10/10/2019 - Chamado 044314.
	nTotPerF := 0
	oTotPerF:Refresh()
	nTotAdiF := 0
	oTotAdiF:Refresh()
	nTotBlqF := 0
	oTotBlqF:Refresh()
	nTotSldRT  := 0
	oTotSldRT:Refresh()
	nTotCTeEF := 0
	oTotCTeEF:Refresh()
	nTotICMSF := 0
	oTotICMSF:Refresh()
	nTotComplF := 0
	oTotComplF:Refresh()
	//

	//Obtém script sql de consulta para conferência.
	cQuery := scpPend()

	If Select("tADGPENDF") > 0
		tADGPENDF->(DbCloseArea())	

	EndIf

	//
	TcQuery cQuery New Alias "tADGPENDF"
	DbSelectArea("tADGPENDF")
	tADGPENDF->(DbGoTop())

	//
	lFchDvg 	:= .F.
	lFchCndPg	:= .F.
	If tADGPENDF->(Eof())

		Aadd(oDadosP:aCols , Array(Len(aHToP) + 1) )
		oDadosP:aCols[Len(oDadosP:aCols), Len(oDadosP:aCols[1]) ] := .F.	
		oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TRANPA"})] := ""
		lFchDvg  := .T.
		lFchCndPg:= .T.

	Else

		While tADGPENDF->( !Eof() )

			//
			cChkBlq := Iif(tADGPENDF->ZFA_VALORCHK <> 0,"B","L")

			//
			If ( cFiltro = cChkBlq .Or. cFiltro = "T" )

				//
				nTotTra++
				nTotVlr += Val(cValToChar(tADGPENDF->ZFA_VALOR))
				nTotBlq += Val(cValToChar(tADGPENDF->ZFA_VALORB))

				//Everson - 10/10/2019 - Chamado 044314.
				nTotPerF	+= tADGPENDF->ZFA_VALOR
				nTotAdiF 	+= tADGPENDF->ZFA_VLRAD
				nTotBlqF 	+= tADGPENDF->ZFA_VALORB
				nTotSldRT  	+= tADGPENDF->ZFA_VALOR + tADGPENDF->ZFA_VLRAD + tADGPENDF->ZFA_VALORB
				//

				Aadd(oDadosP:aCols , Array(Len(aHToP) + 1) )
				oDadosP:aCols[Len(oDadosP:aCols), Len(oDadosP:aCols[1]) ] := .F.

				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TRANPA"})]  := tADGPENDF->ZFA_TRANPA
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_LJPPAG" })] := tADGPENDF->ZFA_LJPPAG
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_NMTPAG" })] := tADGPENDF->ZFA_NMTPAG
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_PLACA"})]   := tADGPENDF->ZFA_VEICPG
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_MINDT"})]   := SToD(tADGPENDF->DATAINI)
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_MAXDT"})]   := SToD(tADGPENDF->DATAFIM)
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_VALOR"})]   := tADGPENDF->ZFA_VALOR
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_VALORB"})]  := tADGPENDF->ZFA_VALORB
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_SALDO"})]   := tADGPENDF->ZFA_VALOR + tADGPENDF->ZFA_VLRAD + tADGPENDF->ZFA_VALORB //Everson-Ch:044314-14/08/2019.				
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_VLRAD"})]   := tADGPENDF->ZFA_VLRAD //Everson-Ch:044314-14/08/2019.

				//
				If tADGPENDF->ZFA_VALORCHK > 0
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "LEGENDA"})]  := oVermelho
					lFchDvg := .T.

				Else
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "LEGENDA"})]  := oVerde

				EndIf

				//
				cCondPg := Alltrim(cValToChar(aCond[2]))

				//
				If Empty(cCondPg)
					lFchCndPg := .T.

				EndIf

				//
				oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "CONDPAG"})]  := cCondPg

				//
				nPos := 0
				If Len(aCTeEmit) > 0
					nPos := Ascan(aCTeEmit,{|x| x[1] == Alltrim(tADGPENDF->ZFA_TRANPA) + Alltrim(tADGPENDF->ZFA_LJPPAG) + Alltrim(tADGPENDF->ZFA_VEICPG) })

				EndIf

				//
				If nPos > 0
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TOTACT"})]	:= aCTeEmit[nPos][3]
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TOTAFI"})]	:= tADGPENDF->ZFA_VALOR - aCTeEmit[nPos][3]	+ aCTeEmit[nPos][10] //Everson-Ch:044314-15/08/2019.
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_CTE"})]		:= aCTeEmit[nPos][4]	
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_SCTE"})]	:= aCTeEmit[nPos][5]	
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TPCTE"})]	:= aCTeEmit[nPos][6]	
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_CHVCTE"})]	:= aCTeEmit[nPos][7]						
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_ROTEIR"})]	:= aCTeEmit[nPos][8]
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_DTENTR"})]	:= SToD(aCTeEmit[nPos][9])
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_ICMS"})]	:= aCTeEmit[nPos][10] //Everson-Ch:044314-15/08/2019.

					//Everson - 10/10/2019 - Chamado 044314.
					nTotCTeEF 	+= aCTeEmit[nPos][3]
					nTotICMSF 	+= aCTeEmit[nPos][10]
					nTotComplF 	+= tADGPENDF->ZFA_VALOR - aCTeEmit[nPos][3]	+ aCTeEmit[nPos][10]
					//

				Else
					oDadosP:aCols[Len(oDadosP:aCols),Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TOTAFI"})]  := tADGPENDF->ZFA_VALOR

				EndIf

			EndIf

			tADGPENDF->( DbSkip() )	

		End

	EndIf

	//
	oDadosP:Refresh()
	oTotTra:Refresh()
	oTotVlr:Refresh()
	oTotBlq:Refresh()

	//Everson - 10/10/2019 - Chamado 044314.
	oTotPerF:Refresh()
	oTotAdiF:Refresh()
	oTotBlqF:Refresh()
	oTotSldRT:Refresh()
	oTotCTeEF:Refresh()
	oTotICMSF:Refresh()
	oTotComplF:Refresh()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scpPend
	Retorna script sql com os registros pendentes de fechamento. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 22/03/2019
	@version 01
	/*/
Static Function scpPend()

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cOcorre	:= Alltrim(GetMv("MV_#ADIFRT",,"017"))
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " ZFA_TRANPA, ZFA_LJPPAG, SA4.A4_NOME AS ZFA_NMTPAG, ZFA_VEICPG, " 
	cQuery += " MIN(ZFA_DATA) AS DATAINI, MAX(ZFA_DATA) AS DATAFIM,  " 
	cQuery += " SUM ( CASE WHEN ZFA_OCORRE = '" + cOcorre + "' THEN 0 ELSE (CASE WHEN ZFA_DC = 'D' THEN ZFA_VALOR*-1 ELSE ZFA_VALOR END) END ) AS ZFA_VALOR, " 
	cQuery += " SUM ( CASE WHEN ZFA_OCORRE = '" + cOcorre + "' THEN (CASE WHEN ZFA_DC = 'D' THEN ZFA_VALOR*-1 ELSE ZFA_VALOR END) ELSE 0 END ) AS ZFA_VLRAD, " 
	cQuery += " SUM(CASE WHEN (ZFA_APRMOV = 'N' ) THEN (CASE WHEN ZFA_DC = 'D' THEN ZFA_VALOR*-1 ELSE ZFA_VALOR END) ELSE 0 END) AS ZFA_VALORB, " 
	cQuery += " SUM(CASE WHEN (ZFA_APRMOV = 'N' ) THEN 1 ELSE 0 END) AS ZFA_VALORCHK, ZFA_PEDCOM  " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( SELECT DISTINCT C7_FILIAL, C7_NUM FROM " + RetSqlName("SC7") + " (NOLOCK) AS SC7 WHERE C7_FILIAL = '" + FWxFilial("SC7") + "' AND SC7.D_E_L_E_T_ = '') AS SC7 ON " 
	cQuery += " ZFA_FILIAL = C7_FILIAL " 
	cQuery += " AND ZFA_PEDCOM = C7_NUM "
	cQuery += " INNER JOIN "
	cQuery += " (SELECT A4_COD, A4_LOJTRA, A4_NOME FROM " + RetSqlName("SA4") + " (NOLOCK) AS SA4 WHERE SA4.D_E_L_E_T_ = '') AS SA4 ON "
	cQuery += " ZFA_TRANPA = SA4.A4_COD AND ZFA_LJPPAG = SA4.A4_LOJTRA "
	cQuery += " WHERE " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "' "  
	cQuery += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)    + "' AND '" + DToS(MV_PAR02) + "' "
	cQuery += " AND ZFA_TRANPA BETWEEN '" + Alltrim(MV_PAR03) + "' AND '" + Alltrim(MV_PAR05) + "' "
	cQuery += " AND ZFA_LJPPAG BETWEEN '" + Alltrim(MV_PAR04) + "' AND '" + Alltrim(MV_PAR06) + "' "
	cQuery += " AND ZFA_VEICPG BETWEEN '" + Alltrim(MV_PAR07) + "' AND '" + Alltrim(MV_PAR08) + "' "
	cQuery += " AND ZFA_FECHA <> 'S' " 
	cQuery += " AND ZFA_APRMOV <> 'R' " 
	cQuery += " AND ZFA_VA = '" + Alltrim(cValToChar(nTpFrtS)) + "' "
	cQuery += " AND ZFA.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY " 
	cQuery += " ZFA_TRANPA, ZFA_LJPPAG, SA4.A4_NOME, ZFA_PEDCOM, ZFA_VEICPG " 
	cQuery += " ORDER BY ZFA_VALORB DESC, ZFA_TRANPA, ZFA_LJPPAG, SA4.A4_NOME, ZFA_VEICPG " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - scpPend - cQuery " + cQuery )

	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} agrpOcorre
	Carrega informações no objeto MsNewGetDados da rotina ADLG40C para o período informado, 
	agrupado por ocorrências para fechamento de período de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 22/03/2019
	@version 01
	/*/
Static Function agrpOcorre(oDadosP2,aHTop2,cFiltro)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery   	:= ""
	Local cChkBlq	:= ""

	Default cFiltro	:= "T"

	//
	oDadosP2:aCols := {}

	//Obtém script sql de consulta para conferência.
	cQuery := scpPendO()

	If Select("tADGPENDO") > 0
		tADGPENDO->(DbCloseArea())	

	EndIf

	//
	TcQuery cQuery New Alias "tADGPENDO"
	DbSelectArea("tADGPENDO")
	tADGPENDO->(DbGoTop())

	//
	If tADGPENDO->(Eof())

		Aadd(oDadosP2:aCols , Array(Len(aHTop2) + 1) )
		oDadosP2:aCols[Len(oDadosP2:aCols), Len(oDadosP2:aCols[1]) ] := .F.	
		oDadosP2:aCols[Len(oDadosP2:aCols),Ascan(aHTop2,{|x| AllTrim(x[2]) == "TFA_OCORRE"})] := ""

	Else

		While tADGPENDO->( !Eof() )

			//
			cChkBlq := Iif(tADGPENDF->ZFA_VALORCHK <> 0,"B","L")

			//
			If ( cFiltro = cChkBlq .Or. cFiltro = "T" )

				//
				Aadd(oDadosP2:aCols , Array(Len(aHTop2) + 1) )
				oDadosP2:aCols[Len(oDadosP2:aCols), Len(oDadosP2:aCols[1]) ] := .F.

				oDadosP2:aCols[Len(oDadosP2:aCols),Ascan(aHTop2,{|x| AllTrim(x[2]) == "TFA_OCORRE"})]  	:= tADGPENDO->ZFA_OCORRE
				oDadosP2:aCols[Len(oDadosP2:aCols),Ascan(aHTop2,{|x| AllTrim(x[2]) == "TFA_DESCOC" })]	:= tADGPENDO->ZFA_DESCOC
				oDadosP2:aCols[Len(oDadosP2:aCols),Ascan(aHTop2,{|x| AllTrim(x[2]) == "TFA_DC" })] 	    := tADGPENDO->ZFA_DC
				oDadosP2:aCols[Len(oDadosP2:aCols),Ascan(aHTop2,{|x| AllTrim(x[2]) == "TFA_VALOR"})]   	:= tADGPENDO->ZFA_VALOR

			EndIf

			tADGPENDO->( DbSkip() )	

		End

	EndIf

	//
	oDadosP2:Refresh()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scpPendO
	Retorna script sql com os registros pendentes de fechamento. Chamado 044314.
	@type  Static Function
	@author Ricardo Lima
	@since 22/03/2019
	@version 01
	/*/
Static Function scpPendO()

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " ZFA_OCORRE, ZFA_DESCOC, ZFA_DC,   " 
	cQuery += " SUM(CASE WHEN ZFA_DC = 'D' THEN ZFA_VALOR*-1 ELSE ZFA_VALOR END) AS ZFA_VALOR, " 
	cQuery += " SUM(CASE WHEN (ZFA_APRMOV = 'N' ) THEN (CASE WHEN ZFA_DC = 'D' THEN ZFA_VALOR*-1 ELSE ZFA_VALOR END) ELSE 0 END) AS ZFA_VALORB, " 
	cQuery += " SUM(CASE WHEN (ZFA_APRMOV = 'N' ) THEN 1 ELSE 0 END) AS ZFA_VALORCHK  " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFA") + " AS ZFA " 
	cQuery += " WHERE " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "' " 
	cQuery += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "' "
	cQuery += " AND ZFA_TRANPA BETWEEN '" + Alltrim(MV_PAR03) + "' AND '" + Alltrim(MV_PAR05) + "' "
	cQuery += " AND ZFA_LJPPAG BETWEEN '" + Alltrim(MV_PAR04) + "' AND '" + Alltrim(MV_PAR06) + "' "
	cQuery += " AND ZFA_VEICPG BETWEEN '" + Alltrim(MV_PAR07) + "' AND '" + Alltrim(MV_PAR08) + "' "
	cQuery += " AND ZFA_FECHA <> 'S' " 
	cQuery += " AND ZFA_APRMOV <> 'R' " 
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " 
	cQuery += " AND ZFA.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY " 
	cQuery += " ZFA_OCORRE, ZFA_DESCOC, ZFA_DC " 
	cQuery += " ORDER BY ZFA_OCORRE, ZFA_DESCOC, ZFA_DC " 

	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} carCTeJEm
	Carrega informações de CT-es já emitidos no objeto MsNewGetDados da função ADLG40C. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 10/10/2019
	@version 01
	/*/
Static Function carCTeJEm(aHToP3,aColsP3,oDadosP3)

	//Variáveis.
	Local cQuery 	:= ""
	Local aOcFech	:= StrToKarr(Alltrim(GetMv("MV_#OCFHFT",,"106/107")),"/") //Everson-Ch:044314-10/10/2019.
	Local cOcFAcr	:= Alltrim(aOcFech[1]) //Everson-Ch:044314-10/10/2019
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " CTE.*, ZFA_NMTPAG, ZFA_DATA  " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
	cQuery += " INNER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " ZFK_FILIAL, ZFK_TRANSP, ZFK_LOJA, ZFK_NUMDOC, ZFK_SERDOC, ZFK_PLACA, ZFK_CODZFA, ZFK_HASH, SUM(ZFK_VALOR) AS ZFK_VALOR " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK  " 
	cQuery += " WHERE  " 
	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "'  " 
	cQuery += " AND ZFK_OCORRE = '" + cOcFAcr + "'  " 
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	cQuery += " AND ZFK_TPDOC = '1' " 
	cQuery += " GROUP BY " 
	cQuery += " ZFK_FILIAL, ZFK_TRANSP, ZFK_LOJA, ZFK_NUMDOC, ZFK_SERDOC, ZFK_PLACA, ZFK_CODZFA, ZFK_HASH " 
	cQuery += " ) AS CTE ON " 
	cQuery += " ZFA_FILIAL = CTE.ZFK_FILIAL " 
	cQuery += " AND ZFA_COD = CTE.ZFK_CODZFA " 
	cQuery += " AND ZFA_TRANPA = CTE.ZFK_TRANSP " 
	cQuery += " AND ZFA_LJPPAG = CTE.ZFK_LOJA " 
	cQuery += " AND ZFA_VEICPG = CTE.ZFK_PLACA " 
	cQuery += " WHERE " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") +  "' " 
	cQuery += " AND ZFA_OCORRE = '" + cOcFAcr + "' " 
	cQuery += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)    + "' AND '" + DToS(MV_PAR02) + "' " 
	cQuery += " AND ZFA_TRANPA BETWEEN '" + Alltrim(MV_PAR03) + "' AND '" + Alltrim(MV_PAR05) + "' "
	cQuery += " AND ZFA_LJPPAG BETWEEN '" + Alltrim(MV_PAR04) + "' AND '" + Alltrim(MV_PAR06) + "' "
	cQuery += " AND ZFA_VEICPG BETWEEN '" + Alltrim(MV_PAR07) + "' AND '" + Alltrim(MV_PAR08) + "' "
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND ZFA.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA, ZFK_NUMDOC, ZFK_SERDOC "  

	//
	If Select("CTEJEMT") > 0
		CTEJEMT->(DbCloseArea())

	EndIf 

	//
	oDadosP3:aCols := {}

	//
	TcQuery cQuery New Alias "CTEJEMT"
	DbSelectArea("CTEJEMT")
	If CTEJEMT->(Eof())

		//
		Aadd(oDadosP3:aCols , Array(Len(aHToP3) + 1) )
		oDadosP3:aCols[Len(oDadosP3:aCols), Len(oDadosP3:aCols[1]) ] := .F.

	Else 

		While ! CTEJEMT->(Eof())

			//
			Aadd(oDadosP3:aCols , Array(Len(aHToP3) + 1) )
			oDadosP3:aCols[Len(oDadosP3:aCols), Len(oDadosP3:aCols[1]) ] := .F.

			oDadosP3:aCols[Len(oDadosP3:aCols),Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_DATA"})]  	:= SToD(CTEJEMT->ZFA_DATA)
			oDadosP3:aCols[Len(oDadosP3:aCols),Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_TRANPA"})]  	:= CTEJEMT->ZFK_TRANSP
			oDadosP3:aCols[Len(oDadosP3:aCols),Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_LJPPAG" })] 	:= CTEJEMT->ZFK_LOJA
			oDadosP3:aCols[Len(oDadosP3:aCols),Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_NMTPAG" })] 	:= CTEJEMT->ZFA_NMTPAG
			oDadosP3:aCols[Len(oDadosP3:aCols),Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_PLACA" })] 	:= CTEJEMT->ZFK_PLACA
			oDadosP3:aCols[Len(oDadosP3:aCols),Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_CTE"})]   	:= CTEJEMT->ZFK_NUMDOC
			oDadosP3:aCols[Len(oDadosP3:aCols),Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_SCTE"})]   	:= CTEJEMT->ZFK_SERDOC
			oDadosP3:aCols[Len(oDadosP3:aCols),Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_VALOR"})]   	:= CTEJEMT->ZFK_VALOR
			oDadosP3:aCols[Len(oDadosP3:aCols),Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_HASH"})]   	:= CTEJEMT->ZFK_HASH

			CTEJEMT->(DbSkip())

		End

	EndIf 

	//
	oDadosP3:Refresh()

	//
	CTEJEMT->(DbCloseArea())

Return Nil
/*/{Protheus.doc} aprovConf
	Interface com os detalhes do fechamento por transportadora. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 25/03/2019
	@version 01
	/*/
Static Function aprovConf(oDadosP,aHToP,dDtaIni,dDtFim)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cTransp		:= Alltrim(cValToChar( oDadosP:aCols[oDadosP:nAt][ aScan(aHToP,{|x| Alltrim(cValToChar(x[2])) == "TFA_TRANPA" })]))
	Local cLoja			:= Alltrim(cValToChar( oDadosP:aCols[oDadosP:nAt][ aScan(aHToP,{|x| Alltrim(cValToChar(x[2])) == "TFA_LJPPAG" })]))
	//Local cPlaca		:= Alltrim(cValToChar( oDadosP:aCols[oDadosP:nAt][ aScan(aHToP,{|x| Alltrim(cValToChar(x[2])) == "TFA_LJPPAG" })]))
	Local oSay			:= Nil
	Local aPastas		:= {}
	Local oPastas		:= Nil
	Local oPnlBtn1		:= Nil
	Local oPnlBtn2		:= Nil   
	Local oGroup1		:= Nil
	Local oGroup2		:= Nil
	Local oGroup3		:= Nil
	Local oFechar		:= Nil    
	Local oFont 		:= TFont():New(,,-16,.T.)	
	Local oDadosD		:= Nil
	Local aCmpAltD		:= {}
	Local aHDoD			:= {}
	Local aColsD		:= {}	
	Local oDadosD2		:= Nil
	Local aCmpAltD2		:= {}
	Local aHDoD2		:= {}
	Local aColsD2		:= {}	
	Local bDadosD		:= Nil
	Local oTotCr  		:= Nil
	Local oTotDb  		:= Nil 
	Local oSubTot 		:= Nil 
	Local oTotBl  		:= Nil
	Local oTotRec		:= Nil

	Private oModal		:= Nil
	Private nTotCr  	:= 0
	Private nTotDb  	:= 0 
	Private nSubTot 	:= 0 
	Private nTotBl  	:= 0
	Private nTotRec		:= 0
	Private cDescTran	:= ""   
	Private aVeiculos	:= {}
	Private cVeiculo	:= ""
	Private oVeiculos	:= Nil    
	Private aOcorren	:= {}
	Private cOcorren	:= ""
	Private oOcorren 	:= Nil	
	Private aCredDeb	:= {}
	Private cCredDeb	:= ""
	Private oCredDeb 	:= Nil	
	Private aBlqLib		:= {}
	Private cBlqLib		:= ""
	Private oBlqLib 	:= Nil	
	Private oAtual		:= Nil
	Private lConfere	:= .T.
	Private lFcFrt		:= .T.
	Private nQtdConf	:= 0

	//
	bDadosD	:= {|| MsAguarde({|| ADLG146G(dDtaIni,dDtFim,cTransp,cLoja,"",@oDadosD,aHDoD,oTotCr,oTotDb,oSubTot,oTotBl,oTotRec,oDadosD2,aHDoD2) },"Aguarde","Carregando dados..."), MsAguarde({|| ADLG146I(dDtaIni,dDtFim,cTransp,cLoja,"",oDadosD2,aHDoD2) },"Aguarde","Carregando dados...") }

	//
	Aadd(aHDoD,{" ","LEGENDA" , "@BMP", 3, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	Aadd(aHDoD,{"Registro"    ,"ZFA_COD"    ,"" ,TamSX3("ZFA_COD")[1]   ,0,"","","C","",""})
	Aadd(aHDoD,{"Data Movto"  ,"ZFA_DATA"   ,"" ,TamSX3("ZFA_DATA")[1]  ,0,"","","D","",""})
	Aadd(aHDoD,{"Carga"       ,"ZFA_CARGA"  ,"" ,TamSX3("ZFA_CARGA")[1] ,0,"","","C","",""})
	Aadd(aHDoD,{"Roteiro"     ,"ZFA_ROTEIR" ,"" ,TamSX3("ZFA_ROTEIR")[1],0,"","","C","",""})
	Aadd(aHDoD,{"Placa"       ,"ZFA_VEICPG" ,"" ,TamSX3("ZFA_VEICPG")[1],0,"","","C","",""})
	Aadd(aHDoD,{"Entrega"     ,"ZFA_DTENTR" ,"" ,TamSX3("ZFA_DTENTR")[1],0,"","","D","",""})
	Aadd(aHDoD,{"Deb/Cred"    ,"ZFA_DC"     ,"" ,TamSX3("ZFA_DC")[1]    ,0,"","","C","",""})
	Aadd(aHDoD,{"Cod Ocorren" ,"ZFA_OCORRE" ,"" ,TamSX3("ZFA_OCORRE")[1],0,"","","C","",""})
	Aadd(aHDoD,{"Desc Ocorren","ZFA_DESCOC" ,"" ,TamSX3("ZFA_DESCOC")[1],0,"","","C","",""})
	Aadd(aHDoD,{"Valor"       ,"ZFA_VALOR"  ,X3Picture('ZFA_VALOR')  ,TamSX3("ZFA_VALOR")[1] ,TamSX3("ZFA_VALOR")[2],"","","N","",""})
	Aadd(aHDoD,{"Aprovado"    ,"ZFA_APRMOV" ,"" ,3,0,"","" ,"C","",""})
	Aadd(aHDoD,{"Conferido"   ,"ZFA_FECHA"  ,"" ,3,0,"","" ,"C","",""})
	Aadd(aHDoD,{"Recno"       ,"ZFA_RECNO"  ,"" ,10,0,"","","R","",""})

	//
	Aadd(aHDoD2,{"Placa"       ,"ZFA_VEICPG" ,"" ,TamSX3("ZFA_VEICPG")[1],0,"","","C","",""})
	Aadd(aHDoD2,{"Deb/Cred"    ,"ZFA_DC"     ,"" ,TamSX3("ZFA_DC")[1]    ,0,"","","C","",""})
	Aadd(aHDoD2,{"Cod Ocorren" ,"ZFA_OCORRE" ,"" ,TamSX3("ZFA_OCORRE")[1],0,"","","C","",""})
	Aadd(aHDoD2,{"Desc Ocorren","ZFA_DESCOC" ,"" ,TamSX3("ZFA_DESCOC")[1],0,"","","C","",""})
	Aadd(aHDoD2,{"Valor"       ,"ZFA_VALOR"  ,X3Picture('ZFA_VALOR')  ,TamSX3("ZFA_VALOR")[1] ,TamSX3("ZFA_VALOR")[2],"","","N","",""})	

	//Informações da transportadora.
	If ! Empty(Alltrim(cValToChar(cTransp)))
		cDescTran := Alltrim(cValToChar(Posicione("SA4",1, xFilial("SA4") + Alltrim(cValToChar(cTransp)) ,"A4_NOME") ))
		cDescTran := cDescTran + " " + Alltrim(cValToChar(cTransp)) + "-" + Alltrim(cValToChar(cLoja))

	Else
		cDescTran := "Transportadora não localizada."

	EndIf

	//
	oModal			:= MsDialog():Create()
	oModal:cName     := "oModal"
	oModal:cCaption  := "Conferência de Frete"
	oModal:nLeft     := 34
	oModal:nTop      := 222
	oModal:nWidth    := 1200
	oModal:nHeight   := 610
	oModal:lShowHint := .F.
	oModal:lCentered := .T.

	//
	oSay:= TSay():New(002,005,{||'Transportadora: ' + cDescTran + " | Período de " + DToC(dDtaIni) + " até " + DToC(dDtFim) },oModal,,oFont,,,,.T.,CLR_RED,CLR_WHITE,595,20)

	oGroup3	 := TGroup():Create(oModal,013,005,035,595,"",,,.T.)

	//
	aPastas := {"Agrupado por ocorrêcias","Detalhado"}
	oPastas := TFolder():New(035,005,aPastas,,oModal,,,,.T.,,590,203)

	oPnlBtn2 := TPanel():New(000,000,"",oPastas:aDialogs[1],,.T.,,,,590,170)
	oPnlBtn2:Align := CONTROL_ALIGN_ALLCLIENT
	oDadosD2 := MsNewGetDados():New(000,000,163,588,,"Allwaystrue()","Allwaystrue()","",aCmpAltD2,Nil,999,Nil,Nil,Nil,oPnlBtn2,aHDoD2,@aColsD2)

	//
	oPnlBtn1 := TPanel():New(000,000,"",oPastas:aDialogs[2],,.T.,,,,590,170)
	oPnlBtn1:Align := CONTROL_ALIGN_ALLCLIENT
	oDadosD := MsNewGetDados():New(000,000,163,588,,"Allwaystrue()","Allwaystrue()","",aCmpAltD,Nil,999,Nil,Nil,Nil,oPnlBtn1,aHDoD,@aColsD)
	oDadosD:oBrowse:bLDblClick := {|| MsAguarde({|| visuReg(oDadosD,aHDoD) },"Aguarde","Carregando registro...") , Eval(bDadosD) }

	//
	oGroup1	 := TGroup():Create(oModal,239,005,268,595,"",,,.T.)
	oTotCr  := TGet():New(244,220,{|u|If(PCount() == 0,nTotCr,nTotCr := u)}  ,oModal,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotCr" ,,,,.T.,,,"Tot. Crédito:",1) 
	oTotDb  := TGet():New(244,295,{|u|If(PCount() == 0,nTotDb,nTotDb := u)}  ,oModal,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotDb" ,,,,.T.,,,"Tot. Débito:",1) 
	oSubTot := TGet():New(244,370,{|u|If(PCount() == 0,nSubTot,nSubTot := u)},oModal,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nSubTot",,,,.T.,,,"Subtotal:",1) 
	oTotBl  := TGet():New(244,445,{|u|If(PCount() == 0,nTotBl,nTotBl := u)}  ,oModal,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"oTotBl" ,,,,.T.,,,"Tot. Bloq.:",1)
	oTotRec := TGet():New(244,520,{|u|If(PCount() == 0,nTotRec,nTotRec := u)},oModal,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotRec",,,,.T.,,,"Total:",1) 

	//
	oGroup2	 := TGroup():Create(oModal,269,005,289,595,"",,,.T.)
	oAtual	 := TButton():New(274,010,"Atualizar"   ,oModal,bDadosD,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar	 := TButton():New(274,550,"Fechar",oModal,{||oModal:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")		

	oModal:Activate(,,,.T.,{||.T.},, bDadosD )

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADLG146G
	Cria filtro e carrega detalhes dos lançamentos de frete da transportadora. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 26/03/2019
	@version 01
	/*/
Static Function ADLG146G(dDataIni,dDataFim,cCodTran,cLojTran,cPlaca,oDadosD,aHDoD,oTotCr,oTotDb,oSubTot,oTotBl,oTotRec,oDadosD2,aHDoD2)

	//Variáveis.
	Local aArea		:= GetArea()	
	Local bFiltro	:= {|| ADLG146I(dDataIni,dDataFim,cCodTran,cLojTran,cPlaca,oDadosD2,aHDoD2,cVeiculo,cOcorren,cCredDeb,cBlqLib),;
                           carDetalhe(dDataIni,dDataFim,cCodTran,cLojTran,cPlaca,@oDadosD,aHDoD,oTotCr,oTotDb,oSubTot,oTotBl,oTotRec,cVeiculo,cOcorren,cCredDeb,cBlqLib) }

	//
	carDetalhe(dDataIni,dDataFim,cCodTran,cLojTran,cPlaca,@oDadosD,aHDoD,oTotCr,oTotDb,oSubTot,oTotBl,oTotRec)

	//Filtro por veículo.
	If ValType(oVeiculos) == "O"
		FreeObj(oVeiculos)
		oVeiculos := Nil

	EndIf

	//
	ASort(aVeiculos)
	oVeiculos 	:= TComboBox():New(020,010,{|u|if(PCount()>0,cVeiculo:=u,cVeiculo)},aVeiculos,100,10,oModal,,bFiltro,,,,.T.,,,,,,,,,'cVeiculo',"Placa",2)		
	cVeiculo	:= "Todos"
	oVeiculos:Refresh()

	//Filtro por ocorrência.
	If ValType(oOcorren) == "O"
		FreeObj(oOcorren)
		oOcorren := Nil

	EndIf

	//
	ASort(aOcorren)
	cOcorren	:= "T"
	oOcorren 	:= TComboBox():New(020,133,{|u|if(PCount()>0,cOcorren:=u,cOcorren)},aOcorren,100,10,oModal,,bFiltro,,,,.T.,,,,,,,,,'cOcorren',"Ocorrência",2)
	oOcorren:Refresh()


	//Filtro por crédito ou débito.
	If ValType(oCredDeb) == "O"
		FreeObj(oCredDeb)
		oCredDeb := Nil

	EndIf


	cCredDeb	:= aCredDeb[1]
	oCredDeb 	:= TComboBox():New(020,270,{|u|if(PCount()>0,cCredDeb:=u,cCredDeb)},aCredDeb,100,10,oModal,,bFiltro,,,,.T.,,,,,,,,,'cCredDeb',"Cred/Deb",2)

	//Filtro por crédito ou débito.
	If ValType(oBlqLib) == "O"
		FreeObj(oBlqLib)
		oBlqLib := Nil

	EndIf

	cBlqLib	:= aBlqLib[1]
	oBlqLib := TComboBox():New(020,407,{|u|if(PCount()>0,cBlqLib:=u,cBlqLib)},aBlqLib,100,10,oModal,,bFiltro,,,,.T.,,,,,,,,,'cBlqLib',"Situação",2)

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADLG146I
	Carrega informações de lançamentos agrupadas por ocorrência. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 26/03/2019
	@version 01
	/*/
Static Function ADLG146I(dDataIni,dDataFim,cCodTran,cLojTran,cPlaca,oDadosD2,aHDoD2,cFilPlaca,cFilOcorr,cFilCD,cBlqLib)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery   := ""

	Default	 cFilPlaca	:= "Todos"
	Default cFilOcorr	:= "T"
	Default cFilCD		:= "T"
	Default cBlqLib		:= "T"

	//
	oDadosD2:aCols := {}

	//Obtém script sql de consulta para conferência.
	cQuery := scpConferT(cCodTran,cLojTran,dDataIni,dDataFim,cPlaca,cFilPlaca,cFilOcorr,cFilCD,cBlqLib)

	If Select("tADLG146E") > 0
		tADLG146E->(DbCloseArea())	

	EndIf

	TcQuery cQuery New Alias "tADLG146E"

	DbSelectArea("tADLG146E")
	tADLG146E->(DbGoTop())

	//
	If tADLG146E->(Eof())

		Aadd(oDadosD2:aCols , Array(Len(aHDoD2) + 1) )
		oDadosD2:aCols[Len(oDadosD2:aCols), Len(oDadosD2:aCols[1]) ] := .F.	
		oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "ZFA_VEICPG"})] := ""

	Else

		While tADLG146E->( !Eof() )

			//
			Aadd(oDadosD2:aCols , Array(Len(aHDoD2) + 1) )
			oDadosD2:aCols[Len(oDadosD2:aCols), Len(oDadosD2:aCols[1]) ] := .F.	
			oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "ZFA_VEICPG"})] 	:= tADLG146E->ZFA_VEICPG
			oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "ZFA_DC"})] 		:= tADLG146E->ZFA_DC
			oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "ZFA_OCORRE"})] 	:= tADLG146E->ZFA_OCORRE
			oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "ZFA_DESCOC"})] 	:= tADLG146E->ZFA_DESCOC
			oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "ZFA_VALOR"})] 	:= tADLG146E->ZFA_VALOR

			tADLG146E->( DbSkip() )	

		End

	EndIf

	//
	If Len(oDadosD2:aCols) <= 0
		Aadd(oDadosD2:aCols , Array(Len(aHDoD2) + 1) )
		oDadosD2:aCols[Len(oDadosD2:aCols), Len(oDadosD2:aCols[1]) ] := .F.	
		oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "ZFA_VEICPG"})] := """

	EndIf

	//
	oDadosD2:Refresh()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scpConferT
	Retorna script sql para conferência de fechamento de frete agrupado por ocorrência. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 21/03/2019
	@version 01
	/*/
Static Function scpConferT(cCodTran,cLojTran,dDataIni,dDataFim,cPlaca,cFilPlaca,cFilOcorr,cFilCD,cBlqLib)

	//Variáveis.
	Local cQuery 	:= ""
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	//
	cQuery := " SELECT ZFA_VEICPG, ZFA_DC, ZFA_OCORRE, ZFA_DESCOC, ZFA_APRMOV, ZFA_FECHA, SUM(ZFA_VALOR) AS ZFA_VALOR " 
	cQuery += " FROM " + RetSqlName("ZFA") + " ZFA "
	cQuery += " WHERE ZFA_FILIAL = '" + FWxFilial("ZFA") + "' "
	cQuery += " AND ZFA_TRANPA = '" + cCodTran + "' AND ZFA_LJPPAG = '" + cLojTran + "' "
	cQuery += " AND ZFA_DATA >= '" + DToS(dDataIni) + "' " //Everson - 01/08/2019. Chamado 044314.
	cQuery += " AND ZFA_DATA <= '" + DToS(dDataFim) + "' " //Everson - 01/08/2019. Chamado 044314.

	//
	If ! Empty(cPlaca)
		cQuery += " AND ZFA_VEICPG = '" + cPlaca + "' "

	EndIf

	//
	If cFilPlaca <> "Todos"
		cQuery += " AND ZFA_VEICPG = '" + cFilPlaca + "' "

	EndIf

	//
	If cFilOcorr <> "T"
		cQuery += " AND ZFA_OCORRE = '" + cFilOcorr + "' "

	EndIf

	//
	If cFilCD <> "T"
		cQuery += " AND ZFA_DC = '" + cFilCD + "' "

	EndIf	

	//
	If cBlqLib = "B"
		cQuery += " AND ( ZFA_APRMOV = 'N')  "

	ElseIf cBlqLib = "L"
		cQuery += " AND ( ZFA_APRMOV = 'S')  "

	EndIf	

	cQuery += " AND ZFA_FECHA <> 'S' AND ZFA_APRMOV <> 'R' "
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY ZFA_VEICPG, ZFA_DC, ZFA_OCORRE, ZFA_DESCOC, ZFA_APRMOV, ZFA_FECHA "
	cQuery += " ORDER BY ZFA_VEICPG, ZFA_OCORRE,  ZFA_APRMOV, ZFA_FECHA "
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - scpConferT - cQuery " + cQuery)

Return cQuery
/*/{Protheus.doc} ³ADLG146G
	Carrega detalhes dos lançamentos de frete da transportadora. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 26/03/2019
	@version 01
	/*/
Static Function carDetalhe(dDataIni,dDataFim,cCodTran,cLojTran,cPlaca,oDadosD,aHDoD,oTotCr,oTotDb,oSubTot,oTotBl,oTotRec,cFilPlaca,cFilOcorr,cFilCD,cBlqLib)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cQuery   		:= "" 
	Local cChkBlq		:= ""

	Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
	Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")

	Default cFilPlaca	:= "Todos"
	Default cFilOcorr	:= "T"
	Default cFilCD		:= "T"
	Default cBlqLib		:= "T"

	//
	oDadosD:aCols := {}
	nTotCr 	:= 0
	nTotDb	:= 0
	nSubTot	:= 0
	nTotBl	:= 0
	nTotRec	:= 0
	lConfere:= .T.
	lFcFrt	:= .T.
	nQtdConf:= 0

	aVeiculos := {}
	Aadd(aVeiculos,'Todos')

	aOcorren := {}
	Aadd(aOcorren,'T=Todos')

	aCredDeb := {}
	Aadd(aCredDeb,'T=Todos')

	aBlqLib  := {}
	Aadd(aBlqLib,'T=Todos')

	//Obtém script sql de consulta para conferência.
	cQuery := scpConfere(cCodTran,cLojTran,dDataIni,dDataFim,cPlaca)

	If Select("tADLG146D") > 0
		tADLG146D->(DbCloseArea())	

	EndIf

	//
	TcQuery cQuery New Alias "tADLG146D"

	DbSelectArea("tADLG146D")
	tADLG146D->(DbGoTop())

	//
	If tADLG146D->(Eof())

		Aadd(oDadosD:aCols , Array(Len(aHDoD) + 1) )
		oDadosD:aCols[Len(oDadosD:aCols), Len(oDadosD:aCols[1]) ] := .F.	
		oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_COD"})] := ""

	Else

		While ! tADLG146D->( Eof() )

			//
			cChkBlq := Iif(tADLG146D->ZFA_APRMOV = "N","B","L")

			//
			If 	tADLG146D->ZFA_APRMOV = "N"
				lConfere := .F.
				lFcFrt	 := .F.

			EndIf

			//
			If	( tADLG146D->ZFA_VEICPG = cFilPlaca .Or. cFilPlaca = "Todos" ) .And.;
			( tADLG146D->ZFA_OCORRE = cFilOcorr .Or. cFilOcorr = "T" ) .And.;
			( tADLG146D->ZFA_DC = cFilCD .Or. cFilCD = "T" ) .And.;
			( cChkBlq = cBlqLib .Or. cBlqLib = "T" )

				Aadd(oDadosD:aCols , Array(Len(aHDoD) + 1) )
				oDadosD:aCols[Len(oDadosD:aCols), Len(oDadosD:aCols[1]) ] := .F.	
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_COD"})] 	:= tADLG146D->ZFA_COD				
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_DATA"})] 	:= SToD(tADLG146D->ZFA_DATA)
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_CARGA"})] 	:= tADLG146D->ZFA_CARGA
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_ROTEIR"})] 	:= tADLG146D->ZFA_ROTEIR
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_VEICPG"})] 	:= tADLG146D->ZFA_VEICPG
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_DTENTR"})] 	:= SToD(tADLG146D->ZFA_DTENTR)
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_DC"})] 		:= tADLG146D->ZFA_DC
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_OCORRE"})] 	:= tADLG146D->ZFA_OCORRE
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_DESCOC"})] 	:= tADLG146D->ZFA_DESCOC
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_VALOR"})] 	:= tADLG146D->ZFA_VALOR
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_APRMOV"})] 	:= tADLG146D->ZFA_APRMOV
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_FECHA"})] 	:= tADLG146D->ZFA_FECHA
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_RECNO"})] 	:= tADLG146D->RECNO

				//
				nTotCr 	+= Iif(tADLG146D->ZFA_DC = "C",tADLG146D->ZFA_VALOR,0)
				nTotDb	+= Iif(tADLG146D->ZFA_DC = "D",tADLG146D->ZFA_VALOR,0)
				nTotBl	+= Iif( (tADLG146D->ZFA_APRMOV = "N") ,Iif(tADLG146D->ZFA_DC = "C",tADLG146D->ZFA_VALOR,tADLG146D->ZFA_VALOR*-1),0) //Everson 27/05/2019. Chamado 044314.

				//
				If tADLG146D->ZFA_APRMOV = "N" 
					oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "LEGENDA"})] := oVermelho

				Else
					oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "LEGENDA"})] := oVerde

				EndIf

				//
				nQtdConf++

			EndIf

			//
			If Ascan(aVeiculos, tADLG146D->ZFA_VEICPG) <= 0
				Aadd(aVeiculos,tADLG146D->ZFA_VEICPG)

			EndIf

			//
			If Ascan(aOcorren, tADLG146D->ZFA_OCORRE +"="+  tADLG146D->ZFA_DESCOC) <= 0
				Aadd(aOcorren,tADLG146D->ZFA_OCORRE +"="+  tADLG146D->ZFA_DESCOC)

			EndIf

			//
			If Ascan(aCredDeb, tADLG146D->ZFA_DC +"="+ Iif(tADLG146D->ZFA_DC = "C","Crédito","Débito") ) <= 0
				Aadd(aCredDeb, tADLG146D->ZFA_DC +"="+ Iif(tADLG146D->ZFA_DC = "C","Crédito","Débito") )

			EndIf

			//
			If Ascan(aBlqLib, cChkBlq +"="+ Iif(cChkBlq = "B","Bloqueado","Liberado") ) <= 0 
				Aadd(aBlqLib, cChkBlq +"="+ Iif(cChkBlq = "B","Bloqueado","Liberado") )

			EndIf

			//
			tADLG146D->( DbSkip() )	

		End

	EndIf

	//
	If Len(oDadosD:aCols) <= 0
		Aadd(oDadosD:aCols , Array(Len(aHDoD) + 1) )
		oDadosD:aCols[Len(oDadosD:aCols), Len(oDadosD:aCols[1]) ] := .F.	
		oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "ZFA_COD"})] := ""

	EndIf

	//
	nSubTot	:= nTotCr - nTotDb
	nTotRec := nSubTot - nTotBl

	//
	tADLG146D->( DbCloseArea() )

	//
	oDadosD:Refresh()
	oTotCr:Refresh()
	oTotDb:Refresh()
	oSubTot:Refresh()
	oTotBl:Refresh()
	oTotRec:Refresh()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scpConfere
	Retorna script sql para conferência de fechamento de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 21/03/2019
	@version 01
	/*/
Static Function scpConfere(cCodTran,cLojTran,dDataIni,dDataFim,cPlaca)

	//Variáveis.
	Local cQuery 	:= ""
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	//
	cQuery := " SELECT ZFA_COD, ZFA_CARGA, ZFA_ROTEIR, ZFA_DTENTR, ZFA_DATA, ZFA_DC, ZFA_OCORRE, ZFA_DESCOC, ZFA_VALOR, " 
	cQuery += " ZFA_VLDVEN, ZFA_ABAUNI, ZFA_ABALTR, ZFA_OBS, ZFA_USUARI, ZFA_DATAIN, ZFA_HORA, ZFA_USRAPR, " 
	cQuery += " ZFA_NOMAPR, ZFA_DTAPRO, ZFA_HRAPRO, ZFA_APRMOV, ZFA_KMTOT, ZFA_FECHA, ZFA_VEICPG, ZFA.R_E_C_N_O_ AS RECNO "
	cQuery += " FROM " + RetSqlName("ZFA") + " ZFA "
	cQuery += " WHERE ZFA_FILIAL = '" + FWxFilial("ZFA") + "' "
	cQuery += " AND ZFA_TRANPA = '" + cCodTran + "' AND ZFA_LJPPAG = '" + cLojTran + "' "

	//
	If ! Empty(cPlaca)
		cQuery += " AND ZFA_VEICPG = '" + cPlaca + "' "

	EndIf

	cQuery += " AND ZFA_DATA >= '" + DToS(dDataIni) + "' " //Everson - 01/08/2019. Chamado 044314.
	cQuery += " AND ZFA_DATA <= '" + DToS(dDataFim) + "' " //Everson - 01/08/2019. Chamado 044314.
	cQuery += " AND ZFA_FECHA <> 'S' AND ZFA_APRMOV <> 'R' "
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZFA_DATA, ZFA_COD, ZFA_CARGA, ZFA_ROTEIR, ZFA_OCORRE "
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - scpConfere - cQuery " + cQuery)

Return cQuery
/*/{Protheus.doc} funcCTE
Executa funções relacionadas a CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 10/10/2019
	@version 01
	/*/
Static Function funcCTE(oDadosP3,aHToP3,nOpc)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()
	Local cHash	:= Alltrim(cValToChar(oDadosP3:aCols[oDadosP3:nAt,Ascan(aHToP3,{|x| AllTrim(x[2]) == "TFA_HASH" })]))
	
	//
	If Empty(cHash)
		RestArea(aArea)
		Return Nil
		
	EndIf
		
	//
	If nOpc == 1
		//MsAguarde({|| Static Call(ADLOG057P,consulCTE,cHash,1) },"Aguarde...","Consultando CT-e.",.F.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		MsAguarde({|| u_LOG057A2(cHash,1) },"Aguarde...","Consultando CT-e.",.F.)
	ElseIf nOpc == 2
		//MsAguarde({|| Static Call(ADLOG057P,pdfCTEdow,cHash)}  ,"Aguarde...","Efetuando download DACTE.",.F.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		MsAguarde({|| u_LOG057A0(cHash)}  ,"Aguarde...","Efetuando download DACTE.",.F.)
	ElseIf nOpc == 3
		//MsAguarde({|| Static Call(ADLOG057P,xmlCTEdow,cHash)}  ,"Aguarde...","Efetuando download XML.",.F.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		MsAguarde({|| u_LOG057A3(cHash)}  ,"Aguarde...","Efetuando download XML.",.F.)
	EndIf
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} gerAdianta
	Gera lançamento de adiantamento de pagamento de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since  22/07/2019
	@version 01
	/*/
Static Function gerAdianta()

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cUpdate	:= ""
	Local cOcorre	:= Alltrim(GetMv("MV_#ADIFRT",,"017"))
	Local cDscOcos	:= ""
	Local cTpOcorr	:= ""
	Local xPula		:= Chr(13) + Chr(10)
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	Local aDiaFim	:= getDiasF(nTpFrtS) //Everson - 05/11/2019. Chamado 029058.
	Local cDtFimAd	:= cValToChar(Year(MV_PAR02)) + Padl(cValToChar(Month(MV_PAR02)),2,"0") + Padl(cValToChar(Alltrim(aDiaFim[2])),2,"0")
	Local aError	:= {}

	//Everson - 05/11/2019 - Chamado 029058.
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}
	
	//
	If ! MsgYesNo("Deseja efetuar os lançamentos dos registros de adiantamento?","Função gerAdianta(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cDscOcos := Alltrim(Posicione("ZF7",1,FWxFilial("ZF7") + cOcorre, "ZF7_DESC"))
	cTpOcorr := Alltrim(Posicione("ZF7",1,FWxFilial("ZF7") + cOcorre, "ZF7_DBCD")) 

	//
	cQuery := scriptAdi()

	//
	If Select("D_ADIANT") > 0
		D_ADIANT->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_ADIANT"
	DbSelectArea("D_ADIANT")

	//
	If D_ADIANT->(Eof())

		//Everson - 05/10/2020. Chamado 2936.
		D_ADIANT->(DbCloseArea())
		MsgStop("Não há registros a serem processados." ,"Função gerAdianta(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	Else

		//
		If ! estAdianta(.T.)
			D_ADIANT->(DbCloseArea())
			RestArea(aArea)
			Return Nil

		EndIf

	EndIf

	//Everson - 06/12/2019 - Chamado 029058.
	If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função gerAdianta(ADLOG040P)")
		logZBE("Sistema está em transação ou TTSBreak - abortando operação. Função gerAdianta(ADLOG040P) ")
		final()

	EndIf

	//
	Begin Transaction //Everson - 06/12/2019 - Chamado 029058.

		//
		While ! D_ADIANT->(Eof())

			//
			If D_ADIANT->ZFK_VALOR > 0
				
				//
				oModel:= FwLoadModel ("ADLOG040P")
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
				oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,Iif( Date() < SToD(cDtFimAd), Date(), SToD(cDtFimAd) ))
				oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,cOcorre)
				oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,cDscOcos)
				oModel:SetValue("ZFAMASTER","ZFA_DC"		,cTpOcorr)
				oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,D_ADIANT->ZFA_VEICPG)
				oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,D_ADIANT->ZFA_TRANPA)
				oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,D_ADIANT->ZFA_LJPPAG)
				oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,D_ADIANT->ZV4_NOMFOR)
				oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,D_ADIANT->ZFK_VALOR)
				oModel:SetValue("ZFAMASTER","ZFA_OBSERV"  	,"Adiantamento de Frete " + DToC(MV_PAR01) + " - " + DToC( Iif( Date() < SToD(cDtFimAd), Date(), SToD(cDtFimAd) ) ))
				oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"S")
				oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"N")
				oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
				oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
				oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"A")
				oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,cUserName)
				oModel:SetValue("ZFAMASTER","ZFA_VA"		,Alltrim(cValToChar( nTpFrtS )))
				oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"	,"ADLOG040P")
				oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"	,Alltrim(cValToChar(U_ADLG40I(nTpFrtS))))

				//
				If oModel:VldData()
					oModel:CommitData()	

				Else
					aError := oModel:GetErrorMessage()
					Help(Nil, Nil, "Função gerAdianta(ADLOG040P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] + " " + cValToChar(D_ADIANT->ZFA_VEICPG), 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
					DisarmTransaction()
					Break

				EndIf       
					
				oModel:DeActivate()
				oModel:Destroy()
				
				oModel := Nil
			
			EndIf

			D_ADIANT->(DbSkip())

		End	

		//
		cUpdate := ""
		cUpdate += " UPDATE " 
		cUpdate += " " + RetSqlName("ZFK") + " SET ZFK_ADIANT = '2' " 
		cUpdate += " FROM " 
		cUpdate += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
		cUpdate += " INNER JOIN " 
		cUpdate += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK ON " 
		cUpdate += " ZFA_FILIAL = ZFK_FILIAL " 
		cUpdate += " AND ZFA_COD = ZFK_CODZFA " 
		cUpdate += " AND ZFA_TRANPA = ZFK_TRANSP " 
		cUpdate += " AND ZFA_LJPPAG = ZFK_LOJA " 
		cUpdate += " AND ZFA_VEICPG = ZFK_PLACA " 
		cUpdate += " WHERE " 
		cUpdate += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "' " 
		cUpdate += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)	  + "' AND '" + cDtFimAd + "' "
		cUpdate += " AND ZFA_TRANPA = '" + D_ADIANT->ZFA_TRANPA + "' "
		cUpdate += " AND ZFA_LJPPAG = '" + D_ADIANT->ZFA_LJPPAG + "' "
		cUpdate += " AND ZFA_VEICPG = '" + D_ADIANT->ZFA_VEICPG + "' "
		cUpdate += " AND ZFA_FECHA  <> 'S' " 
		cUpdate += " AND ZFA_APRMOV <> 'R' " 
		cUpdate += " AND ZFK_TPDOC  = '1' " 
		cUpdate += " AND ZFK_STATUS = '1' " 
		cUpdate += " AND ZFK_ADIANT <> '2' " 
		cUpdate += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019. Chamado 029058.
		cUpdate += " AND ZFA.D_E_L_E_T_ = '' " 
		cUpdate += " AND ZFK.D_E_L_E_T_ = '' " 

		//
		If TCSqlExec(cUpdate) < 0
		
			//
			MsgStop("Não foi possível realizar o update na tabela ZFK (lançamento de adiantamento)." + xPula + TCSQLError() ,"Função gerAdianta(ADLOG040P)")
			Conout( DToC(Date()) + " " + Time() + " " + " ADLOG040P - [ERRO] - gerAdianta -  TCSQLError() " + TCSQLError())
			DisarmTransaction()
			Break

		EndIf

	End Transaction

	//
	D_ADIANT->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptAdi
	Retorna script sql com os registros pendentes de lançamento de adiantamento. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 22/07/2019
	@version 01
	/*/
Static Function scriptAdi()

	//Variáveis.	
	Local aArea	 	:= GetArea()
	Local cQuery	:= ""
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	Local aDiaFim	:= getDiasF(nTpFrtS) //Everson - 05/11/2019. Chamado 029058.
	Local cDtFimAd	:= cValToChar(Year(MV_PAR02)) + Padl(cValToChar(Month(MV_PAR02)),2,"0") + Padl(cValToChar(Alltrim(aDiaFim[2])),2,"0")

	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " ZFA_TRANPA, ZFA_LJPPAG, ZV4_NOMFOR, ZFA_VEICPG, SUM(ZFK_VALOR) - SUM(ZFK_VLRICM) AS ZFK_VALOR "
	cQuery += " FROM "
	cQuery += " ( "
	cQuery += " SELECT  " 
	cQuery += " ZFA_ROTEIR,ZFA_DTENTR,ZFA_TRANPA, ZFA_LJPPAG, ZFA_NMTPAG AS ZV4_NOMFOR, ZFA_VEICPG, ZFK_NUMDOC, ZFK_SERDOC, SUM(ZFK_VALOR) AS ZFK_VALOR, AVG(ZFK_VLRICM) AS ZFK_VLRICM " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK ON " 
	cQuery += " ZFA_FILIAL = ZFK_FILIAL " 
	cQuery += " AND ZFA_COD = ZFK_CODZFA " 
	cQuery += " AND ZFA_TRANPA = ZFK_TRANSP " 
	cQuery += " AND ZFA_LJPPAG = ZFK_LOJA " 
	cQuery += " AND ZFA_VEICPG = ZFK_PLACA " 
	// cQuery += " INNER JOIN "
	// cQuery += " " + RetSqlName("ZV4") + " (NOLOCK) AS ZV4 ON "
	// cQuery += " ZFA_TRANPA = ZV4_FORNEC "
	// cQuery += " AND ZFA_LJPPAG = ZV4_LOJFOR "
	// cQuery += " AND ZFA_VEICPG = ZV4_PLACA " //Everson - 02/07/2020. Chamado 059405.
	cQuery += " WHERE " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "' " 
	cQuery += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)	  + "' AND '" + cDtFimAd + "' "
	cQuery += " AND ZFA_TRANPA BETWEEN '" + Alltrim(MV_PAR03) + "' AND '" + Alltrim(MV_PAR05) + "' "
	cQuery += " AND ZFA_LJPPAG BETWEEN '" + Alltrim(MV_PAR04) + "' AND '" + Alltrim(MV_PAR06) + "' "
	cQuery += " AND ZFA_VEICPG BETWEEN '" + Alltrim(MV_PAR07) + "' AND '" + Alltrim(MV_PAR08) + "' "
	cQuery += " AND ZFA_FECHA <> 'S'  " 
	cQuery += " AND ZFA_APRMOV <> 'R'  " 
	cQuery += " AND ZFK_TPDOC = '1' " 
	cQuery += " AND ZFK_STATUS = '1' " 
	cQuery += " AND ZFK_ADIANT <> '2' "
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND ZFA.D_E_L_E_T_ = '' " 
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	//cQuery += " AND ZV4.D_E_L_E_T_ = '' " //Everson - 02/07/2020. Chamado 059405.
	cQuery += " GROUP BY ZFA_ROTEIR,ZFA_DTENTR,ZFA_FILIAL, ZFA_TRANPA, ZFA_NMTPAG, ZFA_LJPPAG, ZFA_VEICPG, ZFK_NUMDOC, ZFK_SERDOC " 
	cQuery += " ) AS FONTE "
	cQuery += " GROUP BY "
	cQuery += " ZFA_TRANPA, ZFA_LJPPAG, ZV4_NOMFOR, ZFA_VEICPG "
	cQuery += " ORDER BY ZFA_TRANPA, ZV4_NOMFOR, ZFA_LJPPAG, ZFA_VEICPG " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - scriptAdi - cQuery " + cQuery )

	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} ³estAdiantaº
	Estorna o lançamento de adiantamento de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 22/07/2019
	@version 01
	/*/
Static Function estAdianta(lAut)

	//Variáveis.	
	Local aArea	 	:= GetArea()
	Local lRet		:= .T.
	//Local xPula		:= Chr(13) + Chr(10)
	Local cOcorre	:= Alltrim(GetMv("MV_#ADIFRT",,"017"))
	Local cQuery	:= ""
	//Local cUpdate	:= ""
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	//Local aDiaFim	:= getDiasF(nTpFrtS) //Everson - 05/11/2019 - Chamado 029058.
	//Local cDtFimAd	:= cValToChar(Year(MV_PAR02)) + Padl(cValToChar(Month(MV_PAR02)),2,"0") + Padl(cValToChar(Alltrim(aDiaFim[2])),2,"0")

	//Everson - 05/11/2019 - Chamado 029058.
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}

	Default lAut	:= .F.

	//
	If ! lAut .And. ! MsgYesNo("Deseja efetuar os lançamentos dos registros de adiantamento?","Função gerAdianta(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cQuery	:= " SELECT ZFA_COD " 
	cQuery	+= " FROM " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA "
	cQuery	+= " WHERE " 
	cQuery	+= " ZFA_FILIAL = '" + FWxFilial("ZFA") + "' " 
	cQuery	+= " AND ZFA_OCORRE = '" + cOcorre + "' " 
	cQuery	+= " AND ZFA_FECHA <> 'S' " 
	cQuery 	+= " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)    + "' AND '" + DToS(MV_PAR02) + "' "
	cQuery 	+= " AND ZFA_TRANPA BETWEEN '" + Alltrim(MV_PAR03) + "' AND '" + Alltrim(MV_PAR05) + "' "
	cQuery 	+= " AND ZFA_LJPPAG BETWEEN '" + Alltrim(MV_PAR04) + "' AND '" + Alltrim(MV_PAR06) + "' "
	cQuery 	+= " AND ZFA_VEICPG BETWEEN '" + Alltrim(MV_PAR07) + "' AND '" + Alltrim(MV_PAR08) + "' "
	cQuery 	+= " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery	+= " AND D_E_L_E_T_ = '' "	

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - estAdianta - cQuery " + cQuery )

	//
	If Select("EST_ADIANT") > 0
		EST_ADIANT->(DbCloseArea())

	EndIf 

	//
	TcQuery cQuery New Alias "EST_ADIANT"
	EST_ADIANT->(DbGoTop())

	//
	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(13))
	ZFA->(DbGoTop())

	//Everson - 06/12/2019 - Chamado 029058.
	If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função estAdianta(ADLOG040P)")
		logZBE("Sistema está em transação ou TTSBreak - abortando operação. Função estAdianta(ADLOG040P) ")
		final()

	EndIf                                                                                                                                                                                                                                                                                                                    

	//
	Begin Transaction

		While ! EST_ADIANT->(Eof())

			//
			If ! ZFA->(DbSeek( FWxFilial("ZFA") + Alltrim(EST_ADIANT->ZFA_COD) ))
				MsgStop("Não foi possível localizar o registro (ZFA) " + Alltrim(EST_ADIANT->ZFA_COD) + ".","Função estAdianta(ADLOG040P)")
				DisarmTransaction()
				Break	

			EndIf

			//Everson - 28/10/2019. Chamado 029058.
			oModel:= FwLoadModel ("ADLOG040P")
			oModel:SetOperation( MODEL_OPERATION_DELETE )
			oModel:Activate()

			//
			If oModel:VldData()
				oModel:CommitData()

			Else
				lRet := .F.
				aError := oModel:GetErrorMessage()
				Help(Nil, Nil, "Função estAdianta(ADLOG040P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION], 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
				DisarmTransaction()
				Break	

			EndIf					

			oModel:DeActivate()
			oModel:Destroy()
			
			oModel := Nil

			//
			EST_ADIANT->(DbSkip())

		End 	

	End Transaction

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} lgdFchPer
	Legenda de status dos registros da interface de fechamento de período de frete.
	@type  Static Function
	@author Everson
	@since 16/07/2019
	@version 01
	/*/
Static Function lgdFchPer()

	//Variáveis.
	Local cTitulo := "Legenda"
	Local aLegenda:= {}

	//
	Aadd(aLegenda,{"BR_VERDE"  		,"Ok para fechamento"})
	Aadd(aLegenda,{"BR_VERMELHO"	,"Registros bloqueados"}) 

	//
	BrwLegenda("Legenda",cTitulo,aLegenda)

Return Nil
/*/{Protheus.doc} chkAbast
	Retorna a quantidade registros de abastecimento pendentes de importação para tabela de movimento de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 10/05/2019
	@version 01
	/*/
Static Function chkAbast(oDadosP,aHToP)

	//Variáveis.	
	Local aArea	 	:= GetArea()
	Local nNumReg	:= 0
	Local cQuery	:= ""

	//
	cQuery := scpAbast(2,oDadosP,aHToP)

	//
	If Select("D_QTDABS") > 0
		D_QTDABS->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_QTDABS"
	DbSelectArea("D_QTDABS")
		nNumReg := Val(cValToChar(D_QTDABS->QTD))
	D_QTDABS->(DbCloseArea())

	//
	RestArea(aArea)

Return nNumReg
/*/{Protheus.doc} scpAbast
	Retorno script sql com os registros de abastecimento pendentes de importação. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 26/03/2019
	@version 01
	/*/
Static Function scpAbast(nOPc,oObj,aCabec)

	//Variáveis.	
	Local cQuery	:= ""
	//Local cPlacas	:= obtVlrCmp(oObj,aCabec,"TFA_PLACA")
	Default nOPc	:= 1

	//
	cQuery := ""
	cQuery += " SELECT    " 

	//
	If nOPc == 1
		cQuery += " ZBB_IDABAS, ZBB_DTINI, ZBB_DTFIM, ZBB_PLACA, ZBB_BOMBA, ZBB_VOLUME, ZV4_XFRET, " 
		cQuery += " ISNULL(ZB9500.ZB9_VLS500,0) AS S500, ISNULL(ZB910.ZB9_VLS10,0) AS S10, A4_COD, A4_LOJTRA, A4_NOME, ZBB_SISTEM " //Everson - 27/02/2020. Chamado 0539426.

	ElseIf nOPc == 2
		cQuery += " COUNT(ZBB_IDABAS) AS QTD "

	EndIf

	cQuery += " FROM " + RetSqlName("ZBB") + "  AS ZBB " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT ZV4_FILIAL, ZV4_PLACA, ZV4_FORNEC, ZV4_LOJFOR, ZV4_XFRET, ZV4_OLS10, ZV4_OLS500 FROM  " + RetSqlName("ZV4") + "  AS ZV4 WHERE ZV4_FILIAL = '" + FWxFilial("ZV4") + "' AND ZV4.D_E_L_E_T_ = '') AS ZV4 ON " //ticket 70750 - Everson - 07/04/2022.
	cQuery += " ZBB_PLACA = ZV4_PLACA " 
	cQuery += " LEFT OUTER JOIN  " 
	cQuery += " (SELECT A4_COD, A4_LOJTRA, A4_NOME FROM  " + RetSqlName("SA4") + "  AS SA4 WHERE A4_FILIAL = '" + FWxFilial("SA4") + "' AND SA4.D_E_L_E_T_ = '') AS SA4 ON " //ticket 70750 - Everson - 07/04/2022.
	cQuery += " ZV4_FORNEC = A4_COD " 
	cQuery += " AND ZV4_LOJFOR = A4_LOJTRA " 

	//Everson-Ch:044314-03/09/2019.
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT ZB9_FILIAL, ZB9_CODTAB, ZB9_VLS10 FROM " + RetSqlName("ZB9") + " AS ZB9 WHERE ZB9_FILIAL = '" + FWxFilial("ZB9") + "' AND ZB9.D_E_L_E_T_ = '') AS ZB910 ON " 
	cQuery += " ZV4_OLS10 = ZB910.ZB9_CODTAB " 

	//Everson-Ch:044314-03/09/2019.
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT ZB9_FILIAL, ZB9_CODTAB, ZB9_VLS500 FROM " + RetSqlName("ZB9") + " AS ZB9 WHERE ZB9_FILIAL = '" + FWxFilial("ZB9") + "' AND ZB9.D_E_L_E_T_ = '') AS ZB9500 ON " 
	cQuery += " ZV4_OLS10 = ZB9500.ZB9_CODTAB " 
	cQuery += " WHERE    " 
	cQuery += " ZBB_FILIAL = '" + FWxFilial("ZBB") + "' " //ticket 70750 - Everson - 07/04/2022.
	cQuery += " AND ZBB_DTFIM BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "' "
	cQuery += " AND ZV4_FORNEC BETWEEN '" + Alltrim(MV_PAR03) + "' AND '" + Alltrim(MV_PAR05) + "' "
	cQuery += " AND ZV4_LOJFOR BETWEEN '" + Alltrim(MV_PAR04) + "' AND '" + Alltrim(MV_PAR06) + "' "
	//cQuery += " AND ZBB_PLACA IN (" + cPlacas + ") "
	cQuery += " AND ZBB_PLACA BETWEEN '" + Alltrim(MV_PAR07) + "' AND '" + Alltrim(MV_PAR08) + "' " //Everson - 23/03/2020. Chamado 054941.
	cQuery += " AND ZBB_FCHFRT = 'F'  " 
	cQuery += " AND ZBB_APRMOV <> 'N'  " //Everson - 12/03/2020. Chamado 053926. 

	//Everson - 03/06/2020. Chamado T.I.
	If FWCodEmp() + FWCodFil() $"0102"
		cQuery += " AND ZBB_SISTEM IN ('A','M') "

	Else 
		cQuery += " AND ZBB_SISTEM IN ('B','N') "

	EndIf
	//

	cQuery += " AND ZBB.D_E_L_E_T_ = '' " 

	//
	If nOPc == 1
		cQuery += " ORDER BY ZBB_PLACA, ZBB_DTFIM, ZBB_BOMBA  "

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " " + " ADLOG040P - scpAbast - cQuery " + cQuery )

Return cQuery
/*/{Protheus.doc} abastc
	Executa funções para lançamentos de abastecimento e manutenção de bomba na tabela de movimentos de frete (ZFA). Chamado 044314.
	@type  Static Function
	@author Everson
	@since 10/05/2019
	@version 01
	/*/
Static Function abastc(oDadosP,aHToP)

	//Variáveis.	
	Local aArea		 := GetArea()

	//
	If ! MsgYesNo("Deseja realizar a importação dos registros de abastecimento ?","Função ADLG0464(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	Processa( {|| procAbast(oDadosP,aHToP) }, "Aguarde", "Processando registros de abastecimento...",.F.)

	//
	Processa( {|| manBomba() } , "Aguarde", "Processando registros de manutenção de bomba...",.F.) //Everson-Ch:044314-02/07/2019.

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} procAbast
	Processa lançamentos de abastecimento na tabela de movimentos de frete(ZFA). Chamado 044314.
	@type  Static Function
	@author Everson
	@since 26/03/2019
	@version 01
	/*/
Static Function procAbast(oDadosP,aHToP)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cQuery   	:= ""
	Local cDscOcos	:= ""
	Local cTpOcorr	:= ""
	Local cPlaca	:= ""
	Local nVlrL		:= 0
	Local nVlrT		:= 0
	Local nTotReg	:= 0
	Local cZFACod	:= ""
	Local lInclui	:= .T.
	//Local xPula		:= Chr(13) + Chr(10)
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	//Everson - 05/11/2019 - Chamado 029058.
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}

	//Everson - 06/12/2019 - Chamado 029058.
	If ! estAbast(1,oDadosP,aHToP)
		MsgStop("Não foi possível realizar o estorno dos registros de abastecimento/manutenção de bomba.","Função procAbast(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cDscOcos := Alltrim(cValToChar(Posicione("ZF7",1, FWxFilial("ZF7") + cOcorAB, "ZF7_DESC" )))
	cTpOcorr := Alltrim(cValToChar(Posicione("ZF7",1, FWxFilial("ZF7") + cOcorAB, "ZF7_DBCD" )))

	//
	cQuery := scpAbast(1,oDadosP,aHToP)

	//
	If Select("ZBBTMP") > 0
		ZBBTMP->(DbCloseArea())

	EndIf

	//Everson - 06/12/2019 - Chamado 029058.
	TcQuery cQuery New Alias "ZBBTMP"
	DbSelectArea("ZBBTMP")
	ZBBTMP->(DbGoTop())
	nTotReg := Contar("ZBBTMP","!Eof()")
	If nTotReg <= 0
		MsgInfo("Não há registros de abastecimento a serem importados.","Função procAbast(ADLOG040P)")
		ZBBTMP->(DbCloseArea())
		RestArea(aArea)
		Return Nil
		
	EndIf

	//Everson - 06/12/2019 - Chamado 029058.
	ProcRegua(nTotReg)
	ZBBTMP->(DbGoTop())
	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(14)) //Everson - 05/11/2019. Chamado 029058.
	ZFA->(DbGoTop())

	//
	DbSelectArea("ZBB")
	ZBB->(DbSetOrder(3)) //Everson - 27/02/2020. Chamado 053926.
	ZBB->(DbGoTop())

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - procAbast - " + cValToChar(nTotReg) )

	//Everson - 06/12/2019 - Chamado 029058.
	If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função procAbast(ADLOG040P)")
		logZBE("Sistema está em transação ou TTSBreak - abortando operação. Função procAbast(ADLOG040P) ")
		final()

	EndIf  

	//
	Begin Transaction

		//	
		While ! ZBBTMP->(Eof())

			//
			IncProc() 

			//
			cPlaca := ZBBTMP->ZBB_PLACA
			nVlrL  := Iif( Alltrim(cValToChar(ZBBTMP->ZBB_BOMBA)) = "S500", ZBBTMP->S500, ZBBTMP->S10 )
			nVlrT  := nVlrL * ZBBTMP->ZBB_VOLUME

			//
			lInclui := .T.
			If ZFA->(DbSeek( FWxFilial("ZFA") + Alltrim(cValToChar(ZBBTMP->ZBB_IDABAS)) ))
				cZFACod := ZFA->ZFA_COD
				lInclui := .F.

			EndIf

			//
			oModel:= FwLoadModel ("ADLOG040P")
			oModel:SetOperation( Iif(lInclui,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE) )
			oModel:Activate()

			//
			If ! lInclui //Everson - 04/12/2019 - Chamado 029058.
				oModel:SetValue("ZFAMASTER","ZFA_COD",cZFACod)

			EndIf 
				
			//
			oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,SToD(ZBBTMP->ZBB_DTFIM))
			oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,cOcorAB)
			oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,cDscOcos)
			oModel:SetValue("ZFAMASTER","ZFA_DC"		,cTpOcorr)
			oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,ZBBTMP->ZBB_PLACA)
			oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,ZBBTMP->A4_COD)
			oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,ZBBTMP->A4_LOJTRA)
			oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,ZBBTMP->A4_NOME)
			oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,nVlrT)
			oModel:SetValue("ZFAMASTER","ZFA_OBSERV"  	,"Litros " + Alltrim(Transform(ZBBTMP->ZBB_VOLUME,"@E 999,999,999.999")) + " " + Alltrim(cValToChar(ZBBTMP->ZBB_BOMBA)) + " | ID " + Alltrim(ZBBTMP->ZBB_IDABAS))
			oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"S")
			oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"N") 
			oModel:SetValue("ZFAMASTER","ZFA_SISABA"  	,ZBBTMP->ZBB_SISTEM) //Everson - 27/02/2020. Chamado 053926.
			oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
			oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
			oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"A")
			oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,cUserName)
			oModel:SetValue("ZFAMASTER","ZFA_ABAUNI"  	,nVlrL)
			oModel:SetValue("ZFAMASTER","ZFA_ABALTR"  	,ZBBTMP->ZBB_VOLUME)    
			oModel:SetValue("ZFAMASTER","ZFA_IDABAS"  	,ZBBTMP->ZBB_IDABAS)
			oModel:SetValue("ZFAMASTER","ZFA_VA"		,Alltrim(cValToChar( nTpFrtS )))
			oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"  	,U_ADLG40I(nTpFrtS)) 
			oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"	,"ADLOG040P")

			//
			If oModel:VldData()
				oModel:CommitData()

				//
				If ZBB->( DbSeek( FWxFilial("ZBB") + ZBBTMP->ZBB_SISTEM + ZBBTMP->ZBB_IDABAS ) ) //Everson - 27/02/2020. Chamado 053926.
					RecLock("ZBB",.F.)
						ZBB->ZBB_FCHFRT := .T.
					ZBB->(MsUnlock())
				EndIf

			Else
				aError := oModel:GetErrorMessage()
				Help(Nil, Nil, "Função procAbast(ADLOG040P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] + ;
								cValToChar(ZBBTMP->ZBB_IDABAS) + " " + cValToChar(ZBBTMP->ZBB_PLACA), 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
				DisarmTransaction()
				Break

			EndIf					

			oModel:DeActivate()
			oModel:Destroy()
			oModel := Nil

			//
			ZBBTMP->(DbSkip())

		End

	//
	End Transaction

	//
	ZBBTMP->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} estAbast
	Realiza o estorno dos movimentos de abastecimento. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 26/03/2019
	@version 01
	/*/
Static Function estAbast(nOpc,oDadosP,aHToP)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	//Local cUpdate	:= ""
	//Local xPula		:= Chr(13) + Chr(10)
	Local cQuery	:= ""
	Local nTotReg	:= 0
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	//Local cPlacas	:= obtVlrCmp(oDadosP,aHToP,"TFA_PLACA") //Everson - 05/11/2019. Chamado 029058.

	Default nOpc	:= 1

	//Everson - 05/11/2019 - Chamado 029058.
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}

	//
	If nOpc == 2 .And. ! MsgYesNo("Deseja realizar o estorno dos registros de abastecimento ?","Função ADLG0464(ADLOG040P)")
		RestArea(aArea)
		Return .F.

	EndIf

	//
	cQuery := " SELECT * " 
	cQuery += " FROM " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
	cQuery += " WHERE " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "' " 
	cQuery += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)	  + "' AND '" + DToS(MV_PAR02)	  + "' "
	cQuery += " AND ZFA_TRANPA BETWEEN '" + Alltrim(MV_PAR03) + "' AND '" + Alltrim(MV_PAR05) + "' "
	cQuery += " AND ZFA_LJPPAG BETWEEN '" + Alltrim(MV_PAR04) + "' AND '" + Alltrim(MV_PAR06) + "' "
	//cQuery += " AND ZFA_VEICPG IN (" + cPlacas + ") " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND ZFA_VEICPG BETWEEN '" + Alltrim(MV_PAR07) + "' AND '" + Alltrim(MV_PAR08) + "' " //Everson - 03/06/2020. Chamado TI.
	cQuery += " AND ( ZFA_OCORRE = '" + cOcorAB + "' OR ZFA_OCORRE = '" + cOcorBo + "' ) AND ZFA_FECHA <> 'S' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND D_E_L_E_T_ = '' "

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - estAbast - cQuery " + cQuery )

	//
	If Select("D_REGABS") > 0
		D_REGABS->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_REGABS"
	DbSelectArea("D_REGABS")
	D_REGABS->(DbGoTop())
	nTotReg := Contar("D_REGABS","!Eof()")

	//
	If nTotReg <= 0

		//
		If nOpc == 2
			MsgInfo("Não há registros de abastecimento a serem estornados.","Função estAbast(ADLOG040P)")
			
		EndIf
		D_REGABS->(DbCloseArea())
		RestArea(aArea)
		Return .T.

	EndIf

	//
	D_REGABS->(DbGoTop())
	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(13))
	ZFA->(DbGoTop())

	//
	DbSelectArea("ZBB")
	ZBB->(DbSetOrder(3)) //Everson - 27/02/2020. Chamado 053926.
	ZBB->(DbGoTop())

	//Everson - 06/12/2019 - Chamado 029058.
	If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função estAbast(ADLOG040P)")
		logZBE("Sistema está em transação ou TTSBreak - abortando operação. Função estAbast(ADLOG040P) ")
		final()

	EndIf                                                                                                                                                                                                                                                                                                                    

	//
	Begin Transaction

		//
		While ! D_REGABS->(Eof())

			//
			If ZFA->( DbSeek( FWxFilial("ZFA") + Alltrim(D_REGABS->ZFA_COD) ) ) //Everson - 28/02/2020. Chamado 053926.

				//Everson - 28/10/2019. Chamado 029058.
				oModel:= FwLoadModel ("ADLOG040P")
				oModel:SetOperation( MODEL_OPERATION_DELETE )
				oModel:Activate()

				//
				If oModel:VldData()
					oModel:CommitData()

					//
					If ! Empty(D_REGABS->ZFA_IDABAS)
						If ZBB->( DbSeek( FWxFilial("ZBB") + Alltrim(D_REGABS->ZFA_SISABA)  + D_REGABS->ZFA_IDABAS ) ) //Everson - 28/02/2020. Chamado 053926.
							RecLock("ZBB",.F.)
								ZBB->ZBB_FCHFRT := .F.
							ZBB->(MsUnlock())

						EndIf

					EndIf

				Else
					lRet := .F.
					aError := oModel:GetErrorMessage()
					Help(Nil, Nil, "Função procAbast(ADLOG040P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] + " Id Abastecimento " +;
								cValToChar(D_REGABS->ZFA_IDABAS) , 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
					DisarmTransaction() //Everson - 06/12/2019 - Chamado T.I.
					Break //Everson - 06/12/2019 - Chamado T.I.

				EndIf					

				oModel:DeActivate()
				oModel:Destroy()
				
				oModel := Nil

			EndIf 

			D_REGABS->(DbSkip())

		End

	End Transaction

	//
	D_REGABS->(DbCloseArea())

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} manBomba
	Lança ocorrência de de manutenção de bomba nos movimentos de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 02/07/2019
	@version 01
	/*/
Static Function manBomba()

	//Variáveis.	
	Local aArea	 	:= GetArea()
	Local cQuery	:= ""
	Local cDscOcos	:= ""
	Local cTpOcorr	:= ""
	Local nVlrL  	:= GetMv("MV_#VLRBOM",,0.02)
	Local nTotReg	:= 0
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	Local aImpAdia	:= Separa( Alltrim( GetMv("MV_#DESBOM",,"S/N/N/N/N")),"/",.T.) //Everson - 05/11/2019. Chamado 029058.
	Local lImpAdia	:= Iif( Alltrim(aImpAdia[nTpFrtS]) == "S", .T.,.F.) //Everson - 05/11/2019. Chamado 029058.

	//Everson - 05/11/2019 - Chamado 029058.
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}

	//Everson - 05/11/2019. Chamado 029058.
	If ! lImpAdia
		RestArea(aArea)
		Return Nil 

	EndIf

	//
	cDscOcos := Alltrim(cValToChar(Posicione("ZF7",1, FWxFilial("ZF7") + cOcorBo, "ZF7_DESC" )))
	cTpOcorr := Alltrim(cValToChar(Posicione("ZF7",1, FWxFilial("ZF7") + cOcorBo, "ZF7_DBCD" )))

	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " ZFA_TRANPA, ZFA_LJPPAG, ZFA_NMTPAG, ZFA_VEICPG, SUM(ZFA_ABALTR) AS  ZFA_ABALTR " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
	cQuery += " WHERE  " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "'  " 
	cQuery += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)	  + "' AND '" + DToS(MV_PAR02)	  + "' "
	cQuery += " AND ZFA_TRANPA BETWEEN '" + Alltrim(MV_PAR03) + "' AND '" + Alltrim(MV_PAR05) + "' "
	cQuery += " AND ZFA_LJPPAG BETWEEN '" + Alltrim(MV_PAR04) + "' AND '" + Alltrim(MV_PAR06) + "' "
	cQuery += " AND ZFA_VEICPG BETWEEN '" + Alltrim(MV_PAR07) + "' AND '" + Alltrim(MV_PAR08) + "' "
	cQuery += " AND ZFA_OCORRE = '" + cOcorAB + "'  " 
	cQuery += " AND ZFA_FECHA = 'N'  "
	cQuery += " AND ZFA_VALOR > 0 " //Everson - 02/10/2019. Chamado 044314.
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND ZFA.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY " 
	cQuery += " ZFA_TRANPA, ZFA_LJPPAG, ZFA_NMTPAG, ZFA_VEICPG " 
	cQuery += " ORDER BY " 
	cQuery += " ZFA_TRANPA, ZFA_LJPPAG, ZFA_VEICPG " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - manBomba - cQuery " + cQuery  )

	//
	If Select("D_MABO") > 0
		D_MABO->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_MABO"
	DbSelectArea("D_MABO")
	D_MABO->(DbGoTop())
	nTotReg := Contar("D_MABO","!Eof()")
	ProcRegua(nTotReg)
	D_MABO->(DbGoTop())
	While ! D_MABO->(Eof())

		//
		IncProc() 

		//
		Conout("MV_#VLRBOM " + cValToChar(nVlrL) )
		Conout("D_MABO->ZFA_ABALTR " + cValToChar(D_MABO->ZFA_ABALTR) )
		Conout("Round(nVlrL*D_MABO->ZFA_ABALTR,2)" + cValToChar(Round(nVlrL*D_MABO->ZFA_ABALTR,2)) )

		//
		oModel:= FwLoadModel ("ADLOG040P")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,MV_PAR02)
		oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,cOcorBo)
		oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,cDscOcos)
		oModel:SetValue("ZFAMASTER","ZFA_DC"		,cTpOcorr)
		oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,D_MABO->ZFA_VEICPG)
		oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,D_MABO->ZFA_TRANPA)
		oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,D_MABO->ZFA_LJPPAG)
		oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,D_MABO->ZFA_NMTPAG)
		oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,Round(nVlrL*D_MABO->ZFA_ABALTR,2))
		oModel:SetValue("ZFAMASTER","ZFA_OBSERV"  	,"Litros " + Alltrim(Transform(D_MABO->ZFA_ABALTR,"@E 999,999,999.9999")))
		oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"S")
		oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"N")
		oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
		oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
		oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"A")
		oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,cUserName)
		oModel:SetValue("ZFAMASTER","ZFA_ABAUNI"  	,nVlrL)
		oModel:SetValue("ZFAMASTER","ZFA_ABALTR"  	,D_MABO->ZFA_ABALTR)    
		oModel:SetValue("ZFAMASTER","ZFA_VA"		,Alltrim(cValToChar( nTpFrtS )))
		oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"  	,U_ADLG40I(nTpFrtS)) 
		oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"	,"ADLOG040P")

		//
		If oModel:VldData()
			oModel:CommitData()

		Else
			aError := oModel:GetErrorMessage()
			Help(Nil, Nil, "Função procAbast(ADLOG040P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] + ;
							cValToChar(D_MABO->ZFA_VEICPG), 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

		EndIf					

		oModel:DeActivate()
		oModel:Destroy()
		oModel := Nil

		//
		Conout( DToC(Date()) + " " + Time() + " " + " ADLOG040P - procAbast - manBomba " + cValToChar(ZFA->ZFA_COD) )

		D_MABO->(DbSkip())

	End

	//
	D_MABO->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} fechFrt
	Executa rotinas de fechamento de período de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/05/2019
	@version 01
	/*/
Static Function fechFrt(oDadosP,aHToP)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local nAux		:= 1
	//Local aValores	:= {}
	Local cCodTran	:= ""
	Local cLojTran	:= ""
	Local nTotLiq	:= 0
	//Local nValor	:= 0
	//Local nNumPedC	:= ""
	Local nRegAbast	:= 0
	Local cCond		:= ""
	Local cNmTra	:= ""
	Local lVld		:= .T.
	Local cTxtVld	:= ""
	Local xPular	:= Chr(13) + Chr(10)
	Local cRoteiro	:= ""
	Local cDtEntr	:= ""
	Local aPorcOco	:= {}
	Local cUpdt		:= ""
	Local cHash		:= ""
	Local cHashGrp  := "" //Everson - 05/05/2021. Chamado 13434.
	Local aOcFech	:= StrToKarr(Alltrim(GetMv("MV_#OCFHFT",,"106/107")),"/")
	Local cOcFAcr	:= Alltrim(aOcFech[1])
	Local cOcFDes	:= Alltrim(aOcFech[2])
	Local cDscOcos	:= ""
	Local cTpOcorr	:= ""
	Local cDscOcosD	:= ""
	Local cTpOcorrD	:= ""
	Local nVlrOcorr	:= 0
	//Local aRet		:= {}
	//Local dEmissao 	:= Nil
	//Local cObs		:= ""
	//Local cProduto	:= ""
	//Local cCC		:= ""
	Local cTitulo	:= ""
	Local lRetFina	:= .F.
	//Local cTes		:= ""
	//Local nPosPrd	:= 0
	//Local aParam	:= Static Call(ADFIS032P,paramFis)
	Local cTpComp	:= Alltrim( GetMv("MV_#TPEMCO") ) //Everson-Ch:044314-31/07/2019.
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	Local cCodZFA2	:= ""
	//Local cStatus	:= ""
	//Local cNumDoc	:= ""
	Local cNmTran	:= "" //Everson - 03/02/2020. Chamado T.I.

	//Everson - 21/09/2021. Chamado 40420.
	Local nAuxFR	:= 0
	Local lAuxFR 	:= .F.
	Local nTmSlp 	:= 3000
	//

	Private aRetCFch:= {}
	
	//
	If MV_PAR02 > Date()
		MsgStop("Data final do fechamento deve ser menor ou igual a data atual.","Função fechFrt(ADLOG040P)")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//Everson-Ch:044314-25/07/2019

	//Busca informações da tabela de ocorrências.
	DbSelectArea("ZF7")
	ZF7->(DbSetOrder(1))
	If ! ZF7->(DbSeek( FWxFilial("ZF7") + cOcFAcr ))
		MsgStop("Cadastro da ocorrência " + cOcFAcr + " não localizado.","Função fechFrt(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cDscOcos := ZF7->ZF7_DESC
	cTpOcorr := ZF7->ZF7_DBCD
		
	//Busca informações da tabela de ocorrências.
	DbSelectArea("ZF7")
	ZF7->(DbSetOrder(1))
	If ! ZF7->(DbSeek( FWxFilial("ZF7") + cOcFDes ))
		MsgStop("Cadastro da ocorrência " + cOcFDes + " não localizado.","Função fechFrt(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cDscOcosD := ZF7->ZF7_DESC
	cTpOcorrD := ZF7->ZF7_DBCD

	//
	If Len(oDadosP:aCols) == 0 .Or. Empty(Alltrim( oDadosP:aCols[1,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TRANPA"})] ))
		cTxtVld += "Não há fechamento a ser realizado." + xPular
		lVld := .F.

	EndIf

	//
	nRegAbast := chkAbast(oDadosP,aHToP)

	//
	If nRegAbast > 0
		cTxtVld += "Há " + cValToChar(nRegAbast) + " registro(s) de abastecimento não importados para o período informado." + xPular
		lVld := .F.

	EndIf

	//
	If lFchDvg
		cTxtVld += "Há registros de frete aguardando aprovação/reprovação." + xPular
		lVld := .F.

	EndIf

	//
	If lFchCndPg
		cTxtVld += "Há transportadora sem condição de pagamento informada." + xPular
		lVld := .F.

	EndIf	

	//
	If  ! lVld
		MsgStop("O período não pode ser fechado pelo(s) motivo(s) abaixo." + xPular + cTxtVld,"Função fechFrt(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIF

	//
	If ! MsgYesNo("Deseja efetuar o fechamento para o período informado?","Função fechFrt(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	ProcRegua(Len(oDadosP:aCols))

	//
	Private cTpVa 	:= cValToChar(nTipoFrt) //Everson - 04/12/2019 - Chamado 029058.
	Private cCodZFA	:= "" //Everson - 04/12/2019 - Chamado 029058.

	//Everson - 06/12/2019 - Chamado 029058.
	If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função gerAdianta(ADLOG040P)")
		logZBE("Sistema está em transação ou TTSBreak - abortando operação. Função gerAdianta(ADLOG040P) ")
		final()

	EndIf 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - fechFrt - Len(oDadosP:aCols) " + cValToChar(Len(oDadosP:aCols)) )
	For nAux := 1 To Len(oDadosP:aCols)

		//	
		cCodTran := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TRANPA" })]
		cLojTran := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_LJPPAG" })]
		cNmTran  := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_NMTPAG" })]
		nTotLiq  := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TOTAFI" })]
		cCond    := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "CONDPAG"    })]
		cNmTra   := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_NMTPAG" })]

		cPlaca	:= oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_PLACA" })]
		cNumCTe	:= oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_CTE"   })]
		cSNumCte:= oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_SCTE"  })]
		cTpEnv  := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_TPCTE" })]
		cChvCte := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_CHVCTE"})]

		cRoteiro := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_ROTEIR"})]
		cDtEntr	 := oDadosP:aCols[nAux,Ascan(aHToP,{|x| AllTrim(x[2]) == "TFA_DTENTR"})]
		cHash	 := ""
		cHashGrp := "" //Everson - 05/05/2021. Chamado 13434.
		cCodZFA	 := ""
		cCodZFA2 := ""

		//
		IncProc(cCodTran + "-" + cLojTran + "/" + cNmTra)

		//
		If Empty(cCond)
			logZBE("A transportadora " + cCodTran + "-" + cLojTran + "/" + cNmTra + " não possui condição de pagamento. Não será possível gerar o pedido de compra. Função fechFrt(ADLOG040P)")
			MsgStop("A transportadora " + cCodTran + "-" + cLojTran + "/" + cNmTra + " não possui condição de pagamento. Não será possível gerar o pedido de compra.","Função fechFrt(ADLOG040P)")
			Loop

		EndIf

		//Fechamento de frete com acréscimo.
		If nTotLiq > 0 .And. ! Empty(cNumCTe) .And. ! Empty(cSNumCte) .And. ! Empty(cTpEnv) .And. ! Empty(cChvCte) .And.;
		   ! Empty(cRoteiro) .And. ! Empty(cDtEntr) //Gera CT-e complementar.

			//
			cDtEntr := DToS(cDtEntr)
			
			//Posiciona no roteiro que será complementado.
			DbSelectArea("ZFA")
			ZFA->(DbSetOrder(15)) //Everson - 05/11/2019 - Chamado 029058.
			ZFA->(DbGoTop())
			If ! ZFA->( DbSeek( FWxFilial("ZFA") + cDtEntr + cRoteiro ) )

				//Everson - 06/12/2019 - Chamado 029058.
				logZBE("Não foi possivel localizar o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + " Função fechFrt(ADLOG040P)")
				If ! MsgYesNo("Não foi possivel localizar o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) +; 
					". Será necessário executar novamente o fechamento para o veículo " + cPlaca + ". Deseja prosseguir com os demais fechamentos?","Função fechFrt(ADLOG040P)")
					logZBE("Não foi possivel localizar o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + " (ABORTADO) Função fechFrt(ADLOG040P)")
					RestArea(aArea)
					Return Nil

				EndIf
				Loop

			EndIf

			//Gera registro de fechametno de frete (acréscimo).
			//Everson - 04/12/2019 - Chamado 029058.
			cCodZFA := ""
			cCodZFA2:= ""

			//Gera registro na tabela ZFA de fechamento de frete para ser utilizado na geração do CT-e.
			If ! grvFechZFA(cCodTran,cLojTran,cNmTran,cOcFAcr,cDscOcos,nTotLiq,cTpOcorr,cPlaca,@cCodZFA,"",.T.,.T.) //Everson - 03/02/2020. Chamado T.I.

				//Everson - 06/12/2019 - Chamado 029058.
				logZBE("Não foi possivel lançar a ocorrência " + cOcFAcr + " para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + " Função fechFrt(ADLOG040P)")
				If ! MsgYesNo("Não foi possivel lançar a ocorrência " + cOcFAcr + " para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) +; 
				". Será necessário executar novamente o fechamento para o veículo " + cPlaca + ". Deseja prosseguir com os demais fechamentos?","Função fechFrt(ADLOG040P)")
					logZBE("Não foi possivel lançar a ocorrência " + cOcFAcr + " para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + " (ABORTADO) Função fechFrt(ADLOG040P)")
					RestArea(aArea)
					Return Nil

				EndIf

				Loop

			EndIf

			//
			cCodZFA2 := cCodZFA
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - fechFrt - cCodZFA 1 - " + cValToChar(cCodZFA) )
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - fechFrt - cCodZFA2 1 - " + cValToChar(cCodZFA2) )
			
			//
			Aadd(aPorcOco,{cOcFAcr,nTotLiq,1,""} )

			//Gera o CT-e complementar.
			aRetCFch := {}
	
			//Everson-Ch:044314-31/07/2019.                         
			//MsAguarde({|| Static Call(ADLOG057P,grCTECompl,cRoteiro,cDtEntr,nTotLiq,"",cTpComp,cTpEnv,cNumCTe,cSNumCte,cChvCte,.T., aPorcOco ) } ,;
			//"Aguarde...","CT-e complementar " + cCodTran + "/" + cLojTran + "-" + cPlaca ,.F.)
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			MsAguarde({|| u_LOG057A6( cRoteiro,cDtEntr,nTotLiq,"",cTpComp,cTpEnv,cNumCTe,cSNumCte,cChvCte,.T., aPorcOco ) } ,;
			"Aguarde...","CT-e complementar " + cCodTran + "/" + cLojTran + "-" + cPlaca ,.F.)
			aPorcOco := {}

			//
			cCodZFA := cCodZFA2
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - fechFrt - cCodZFA 2 - " + cValToChar(cCodZFA) )
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - fechFrt - cCodZFA2 2 - " + cValToChar(cCodZFA2) )

			//
			Pergunte("ADLG146P",.F.)

			//Everson - 05/05/2021. Chamado 13434.
			If ! chkRet057(cRoteiro, cDtEntr, aRetCFch, cCodZFA, @cHashGrp)
				apgFcht(cHashGrp,"")
				RestArea(aArea)
				Return Nil

			EndIf
			//
			
			//Atualiza registros na tabela ZFK com o código da ZFA.
			//Everson - 05/05/2021. Chamado 13434.
			cUpdt :=  " UPDATE " + RetSqlName("ZFK") + " SET ZFK_CODZFA = '" + cCodZFA + "' WHERE ZFK_FILIAL = '" + FWxFilial("ZFK") + "' AND ZFK_HASH IN (" + cHashGrp + ") AND D_E_L_E_T_ = '' "
			
			//
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - fechFrt - cUpdt - " + cValToChar(cUpdt) )

			//Everson - 21/09/2021. Chamado 40420.
			//Vincula ZFA x ZFK.
			nAuxFR := 0
			lAuxFR := .F.
			While nAuxFR < 10
				logZBE("Início vínculo ZFA x ZFK - " + cValToChar(cCodZFA) + " " + cValToChar(cHashGrp))
				If TcSqlExec(cUpdt) < 0
					logZBE("Não foi possível realizar o vínculo ZFA x ZFK. cCodZFA: " + cValToChar(cCodZFA))
					MsgAlert("Não foi possível realizar o vínculo ZFA x ZFK. cCodZFA: " + cValToChar(cCodZFA),"fechFrt(ADLOG0440P)")

				Else
					lAuxFR := .T.
					logZBE("Fim vínculo ZFA x ZFK - " + cValToChar(cCodZFA) + " " + cValToChar(cHashGrp))
					Exit

				EndIf

				//
				nAuxFR++
				Sleep(nTmSlp)

			EndDo
			//

			//Everson - 21/09/2021. Chamado 40420
			If ! lAuxFR
				apgFcht(cHashGrp,"")
				MsgAlert("Não foi possível realizar o vínculo ZFA x ZFK. cCodZFA: " + cValToChar(cCodZFA),"fechFrt(ADLOG0440P)")
				RestArea(aArea)
				Return Nil

			EndIf

			//Fecha registros do período.
			nAuxFR := 0
			lAuxFR := .F.
			While nAuxFR < 10 //Everson - 21/09/2021. Chamado 40420.
				logZBE("Início do fechamento dos registros ZFA cCodZFA - " + cValToChar(cCodZFA))
				If ! fchPer(cCodZFA,cCodTran,cLojTran,cPlaca,nTpFrtS)
					logZBE("Não foi possível realizar o fechamento dos registros ZFA SLD+. cCodZFA: " + cValToChar(cCodZFA))
					MsgAlert("Não foi possível realizar o fechamento dos registros ZFA. cCodZFA: " + cValToChar(cCodZFA),"fechFrt(ADLOG0440P)")

				Else
					lAuxFR := .T.
					logZBE("Fim do fechamento dos registros ZFA SLD+ cCodZFA - " + cValToChar(cCodZFA))
					Exit
				
				EndIf

				//
				nAuxFR++
				Sleep(nTmSlp)

			EndDo
			//

			//Everson - 21/09/2021. Chamado 40420
			If ! lAuxFR
				apgFcht(cHashGrp,"")
				MsgAlert("Não foi possível realizar o fechamento dos registros ZFA. cCodZFA: " + cValToChar(cCodZFA),"fechFrt(ADLOG0440P)")
				RestArea(aArea)
				Return Nil

			EndIf
			
		//Fechamento de frete com valor final zerado.
		ElseIf nTotLiq == 0 .And. ! Empty(cCodTran) .And. ! Empty(cLojTran) .And. ! Empty(cPlaca) //Não há valor para acréscimo ou decréscimo.
			
			//Everson-Ch:044314-28/08/2019.
			//Gera registro de fechametno de frete (acréscimo).
			nVlrOcorr := 0
			cCodZFA   := ""
			If ! grvFechZFA(cCodTran,cLojTran,cNmTran,cOcFAcr,cDscOcos,nVlrOcorr,cTpOcorr,cPlaca,@cCodZFA,"",.F.,.F.) //Everson - 03/02/2020. Chamado T.I.
				//Everson - 06/12/2019 - Chamado 029058.
				logZBE("Não foi possivel lançar a ocorrência " + cOcFAcr + ". " +" Função fechFrt(ADLOG040P)")
				If ! MsgYesNo("Não foi possivel lançar a ocorrência " + cOcFAcr + ". " + ; 
				"Será necessário executar novamente o fechamento para o veículo " + cPlaca + ". Deseja prosseguir com os demais fechamentos?","Função fechFrt(ADLOG040P)")
					logZBE("Não foi possivel lançar a ocorrência " + cOcFAcr + ". " +" (ABORTADO) Função fechFrt(ADLOG040P)")
					RestArea(aArea)
					Return Nil

				EndIf
				Loop

			EndIf
			
			//
			If ! fchPer(cCodZFA,cCodTran,cLojTran,cPlaca,nTpFrtS)
				RestArea(aArea)
				Return Nil
		
			EndIf			
		
		//Fechamento de frete com valor final negativo.
		ElseIf nTotLiq < 0  .And. ! Empty(cCodTran) .And. ! Empty(cLojTran) .And. ! Empty(cPlaca)
			
			//Everson-Ch:044314-28/08/2019.
			cTitulo := DToS(dDataBAse) + "F"
			cCodZFA := ""
			If ! grvFechZFA(cCodTran,cLojTran,cNmTran,cOcFDes,cDscOcosD,AbS(nTotLiq),cTpOcorrD,cPlaca,@cCodZFA,"Título " + cTitulo,.F.,.F.) //Everson - 03/02/2020. Chamado T.I.
				//Everson - 06/12/2019 - Chamado 029058.
				logZBE("Não foi possivel lançar a ocorrência " + cOcFDes + " para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) +" Função fechFrt(ADLOG040P)")
				If ! MsgYesNo("Não foi possivel lançar a ocorrência " + cOcFDes + " para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) +; 
				". Será necessário executar novamente o fechamento para o veículo " + cPlaca + ". Deseja prosseguir com os demais fechamentos?","Função fechFrt(ADLOG040P)")
					logZBE("Não foi possivel lançar a ocorrência " + cOcFDes + " para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) +" (ABORTADO) Função fechFrt(ADLOG040P)")
					RestArea(aArea)
					Return Nil

				EndIf
				Loop

			EndIf
			
			//
			lRetFina := .F.
			lRetFina := FIN050INC(cTitulo,AbS(nTotLiq),cCodTran,cLojTran,"Fch Frete " + DToC(MV_PAR01) + "-" + DToC(MV_PAR02) + "-" + cPlaca ) //Everson-Ch:044314-31/07/2019. 
			
			//
			Pergunte("ADLG146P",.F.)
			
			//
			If ! lRetFina
				apgFcht("",cCodZFA)
				
				//Everson - 06/12/2019 - Chamado 029058.
				logZBE("Não foi possivel gerar o título NDF no financeiro. Função fechFrt(ADLOG040P)")
				If ! MsgYesNo("Não foi possivel gerar o título NDF no financeiro. " +; 
					"Será necessário executar novamente o fechamento para o veículo " + cPlaca + ". Deseja prosseguir com os demais fechamentos?","Função fechFrt(ADLOG040P)")
					logZBE("Não foi possivel gerar o título NDF no financeiro (ABORTADO). Função fechFrt(ADLOG040P)")
					RestArea(aArea)
					Return Nil

				EndIf									
				Loop
							
			EndIf

			//Everson - 21/09/2021. Chamado 40420
			While .T.
				If ! fchPer(cCodZFA,cCodTran,cLojTran,cPlaca,nTpFrtS)
					logZBE("Não foi possível realizar o fechamento dos registros ZFA SLD-. cCodZFA: " + cValToChar(cCodZFA))
					MsgAlert("Não foi possível realizar o fechamento dos registros ZFA. cCodZFA: " + cValToChar(cCodZFA),"fechFrt(ADLOG0440P)")

				Else
					logZBE("Fim do fechamento dos registros ZFA SLD- cCodZFA - " + cValToChar(cCodZFA))
					Exit
			
				EndIf
				
				Sleep(nTmSlp)
			EndDo
			
		EndIf

	Next nAux

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} chkRet057
	Valida a geração co CT-e complementar.
	@type  Static Function
	@author Everson
	@since 05/05/2021
	@version01
	/*/
Static Function chkRet057(cRoteiro, cDtEntr, aRetCFch, cCodZFA, cHashGrp)

	//Variáveis.
	Local aArea 	:= GetArea()
	Local nAux2 	:= 1
	Local cHash 	:= ""
	Local cStatus  	:= ""
	Local nVlrOcorr	:= 0
	Local cNumDoc	:= ""
	Local dEmissao 	:= Nil

	//Valida geração do CT-e complementar.
	VarInfo("aRetCFch",aRetCFch)
	If Len(aRetCFch) <= 0
		logZBE("Não foi possivel gerar o CT-e complementar para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + " Função chkRet057(ADLOG040P)")
		MsgStop("Não foi possivel gerar o CT-e complementar para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ".","Função chkRet057(ADLOG040P)")
		RestArea(aArea)
		Return .F.

	EndIf

	//
	For nAux2 := 1 To Len(aRetCFch) //Everson - 05/05/2021. Chamado 13434.

		//Everson - 05/05/2021. Chamado 13434.
		cHash 	 := Alltrim(cValToChar(aRetCFch[nAux2][7]))
		cHashGrp += "'" + cHash + "',"
		cStatus  := Alltrim(cValToChar(aRetCFch[nAux2][6]))
		nVlrOcorr+= aRetCFch[nAux2][9]
		cNumDoc	 := Alltrim(cValToChar(aRetCFch[nAux2][10]))
		dEmissao := SToD(Alltrim(cValToChar(aRetCFch[nAux2][12])))

		//Valida o status de retorno do CT-e complementar.
		If Alltrim(cStatus) <> "101" .And. Alltrim(cStatus) <> "503" .And. Alltrim(cStatus) <> "502" //CT-e com status Aprovado/CT-e com status já emitido.				

			//
			apgFcht(cHash,"") //Everson - 24/01/2020. Chamado 054941.

			//
			logZBE("O Status do CT-e do roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + " está diferente de liberado (retorno " + cStatus + ")  Função chkRet057(ADLOG040P)")
			If ! MsgYesNo("O Status do CT-e do roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + " está diferente de liberado (retorno " + cStatus + ") " +; 
			". Será necessário executar novamente o fechamento para o veículo " + cPlaca + ". Deseja prosseguir com os demais fechamentos?","Função chkRet057(ADLOG040P)")
				logZBE("O Status do CT-e do roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + " está diferente de liberado (retorno " + cStatus + ")  (ABORTADO) Função chkRet057(ADLOG040P)")
				RestArea(aArea)
				Return .T.

			EndIf
			Loop

		EndIf

	Next nAux2

	//
	cHashGrp := Substr(cHashGrp,1,Len(cHashGrp)-1)

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} fchPer
	Fecha registros do período de fechamento de frete.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version01
	/*/
Static Function fchPer(cCodZFA,cCodTran,cLojTran,cPlaca,nTpFrtS)

	//Variáveis.
	Local aArea	:= GetArea()
	Local cUpdt	:= ""
	Local lRet 	:= .T.	
	
	//
	cUpdt := " UPDATE " + RetSqlName("ZFA") + " "
	cUpdt += " SET ZFA_FECHA = 'S', ZFA_DATAPG = '" + DToS(Date()) + "', ZFA_PEDCOM = 'XXXXXX', "
	cUpdt += " ZFA_DTFCIN = '" + DToS(MV_PAR01) + "', ZFA_DTFCFM = '" + DToS(MV_PAR02) + "', ZFA_REGFCH = '" + cCodZFA + "' "
	cUpdt += " WHERE " 
	cUpdt += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "'   " 
	cUpdt += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)	 + "' AND '" + DToS(MV_PAR02)  	 + "' "
	cUpdt += " AND ZFA_TRANPA BETWEEN '" + Alltrim(cCodTran) + "' AND '" + Alltrim(cCodTran) + "' "
	cUpdt += " AND ZFA_LJPPAG BETWEEN '" + Alltrim(cLojTran) + "' AND '" + Alltrim(cLojTran) + "' "
	cUpdt += " AND ZFA_VEICPG BETWEEN '" + Alltrim(cPlaca)   + "' AND '" + Alltrim(cPlaca)   + "' "
	cUpdt += " AND ZFA_FECHA  <> 'S' "
	cUpdt += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019. Chamado 029058.
	cUpdt += " AND D_E_L_E_T_ = '' "

	//
	If TcSqlExec(cUpdt) < 0
		lRet := .F.
		Conout(DToC(Date()) + " " + Time() + " ADLOG040P - fchPer - Erro - TcSqlError() " + TcSqlError() )
		logZBE(DToC(Date()) + " " + Time() + " ADLOG040P - fchPer - Erro - TcSqlError() " + TcSqlError() +" Função fchPer(ADLOG040P)")
		MsgStop("Ocorreu erro no fechamento do período - " + cValToChar(cPlaca) + "." + Chr(13) + Chr(10) + TcSqlError(),"Função fchPer(ADLOG040P)")

	Else
		Conout(DToC(Date()) + " " + Time() + " ADLOG040P - fchPer - Ok - update realizado - cUpdt " + cValToChar(cUpdt) )

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} FIN050INC
	Gera NDF no contas a pagar. Chamado 044314;
	@type  Static Function
	@author user
	@since 25/07/2019
	@version 01
	/*/
Static Function FIN050INC(cTitulo,nTotLiq,cCodTran,cLojTran,cHist)

	//Variáveis.
	Local aArea	 	:= GetArea()
	Local lRet		:= .T.
	Local aArray 	:= {}
	Local dData		:= Nil
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	//Local aDiaFim	:= getDiasF(nTpFrtS) //Everson - 05/11/2019 - Chamado 029058.
	Local aCond		:= getConPg(nTpFrtS) //Everson - 05/11/2019. Chamado 029058.
	Local cCond		:= ""
	Local aRet		:= {}
	Local cParcela	:= Padl("1",TamSX3("E2_PARCELA")[1],"0")
	Local cQuery	:= ""

	//Everson - 05/11/2019. Chamado 029058.
	Local aParams	:= paramFina(nTpFrtS)
	Local cNaturez	:= aParams[1][1]
	Local cItemC	:= aParams[1][2]
	Local cCTADeb	:= aParams[1][3]
	Local cCTACre	:= aParams[1][4]
	Local cCCC		:= aParams[1][5]
	//
	
	Private lMsErroAuto := .F.
	
	//Everson-Ch:044314-06/08/2019.
	If Empty(cNaturez) .Or. Empty(cItemC) .Or. Empty(cCTADeb) .Or. Empty(cCTACre) .Or. Empty(cCCC)
		logZBE("Há parâmetro(s), para lançamento de NDF, não parametrizados. Função FIN050INC(ADLOG040P)")
		MsgStop("Há parâmetro(s), para lançamento de NDF, não parametrizados.","Função FIN050INC(ADLOG040P)")
		RestArea(aArea)
		Return lRet
		
	EndIf
	
	//
	cCond := aCond[2]

	//
	aRet := Condicao(nTotLiq,cCond,,dDataBAse)
	
	//
	dData := aRet[1][1]
	
	//Everson-Ch:044314-06/08/2019.
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " MAX(E2_PARCELA) AS E2_PARCELA  " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SE2") + " (NOLOCK) AS SE2 " 
	cQuery += " WHERE " 
	cQuery += " E2_FILIAL = '" + FWxFilial("SE2") + "' " 
	cQuery += " AND E2_PREFIXO = 'MAN' " 
	cQuery += " AND E2_NUM = '" + cTitulo + "' " 
	cQuery += " AND E2_TIPO = 'NDF' " 
	cQuery += " AND E2_FORNECE = '" + cCodTran + "' " 
	cQuery += " AND E2_LOJA    = '" + cLojTran + "' " 
	cQuery += " AND SE2.D_E_L_E_T_ = '' " 
	
	//
	If Select("D_PARCSE2") > 0
		D_PARCSE2->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_PARCSE2"
	DbSelectArea("D_PARCSE2")
	D_PARCSE2->(DbGoTop())
		cParcela := Soma1( Iif( Empty(Alltrim(cValToChar(D_PARCSE2->E2_PARCELA))),"0",Alltrim(cValToChar(D_PARCSE2->E2_PARCELA)) ) )
		cParcela := Padl(cParcela,TamSX3("E2_PARCELA")[1],"0")
	D_PARCSE2->(DbCloseArea())
	
	//Everson-Ch:044314-31/07/2019. 
	aArray := { { "E2_EMISSAO"  , dDataBAse    , Nil },;
				{ "E2_PREFIXO"  , "MAN"        , Nil },;
	            { "E2_NUM"      , cTitulo      , Nil },;
	            { "E2_PARCELA"  , cParcela     , Nil },;
	            { "E2_TIPO"     , "NDF"        , Nil },;
	            { "E2_NATUREZ"  , cNaturez     , Nil },;
	            { "E2_FORNECE"  , cCodTran     , Nil },;
	            { "E2_LOJA"     , cLojTran     , Nil },;
	            { "E2_EMISSAO"  , MV_PAR02     , Nil },;
	            { "E2_HIST"     , cHist        , Nil },;
	            { "E2_VENCTO"   , dData        , Nil },;
	            { "E2_VENCREA"  , dData        , Nil },;
	            { "E2_VALOR"    , nTotLiq      , Nil },;		                        
	            { "E2_ITEMD"    , cItemC       , Nil },;
	            { "E2_ITEMC"    , cItemC       , Nil },;
	            { "E2_DEBITO"   , cCTADeb      , Nil },;
	            { "E2_CREDIT"   , cCTACre      , Nil },;
	            { "E2_CCC"      , cCCC         , Nil }}
	
	//
	aArray := FWVetByDic(aArray ,"SE2", .F., 1)
	SetFunName("FINA050")
	VarInfo("aArray",aArray)
	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)
	 
	//
	If lMsErroAuto
	    MostraErro()
	    lRet := .F.

		//Everson - 02/06/2020. Chamado T.I. 
		/*Else
			
			//Everson-Ch:044314-06/08/2019.
			SE2->(DbGoTop())
			If SE2->( DbSeek( FWxFilial("SE2") + Padr("MAN", TamSX3("E2_PREFIXO")[1], " ") + cTitulo + cParcela + Padr("NDF", TamSX3("E2_TIPO")[1], " ") + cCodTran + cLojTran ) )
				lRet := .T.
				
			Else
				logZBE("Não foi possível gerar o título NDF para transportadora " + cCodTran +"-"+ cLojTran + Chr(13) + Chr(10) + cHist + ". Função FIN050INC(ADLOG040P)")
				MsgStop("Não foi possível gerar o título NDF para transportadora " + cCodTran +"-"+ cLojTran + Chr(13) + Chr(10) + cHist + ".","Função FIN050INC(ADLOG050P)")
				lRet := .F.
				
			EndIf*/
	    
	EndIf

	//
	RestArea(aArea)
	
Return lRet
/*/{Protheus.doc} paramFina
	Obtém parâmetros para geração de NDF. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
Static Function paramFina(nTpFrtS)

	//Variáveis.
	Local aArea	 	:= GetArea()
	Local aParam	:= {}

	Local aNaturez	:= Separa(Alltrim(GetMV("MV_#NATFRT",,"")),"/",.T.) //
	Local aItemC	:= Separa(Alltrim(GetMV("MV_#ITCTFR",,"")),"/",.T.) //
	Local aCTADeb	:= Separa(Alltrim(GetMV("MV_#CTADFR",,"")),"/",.T.) //
	Local aCTACre	:= Separa(Alltrim(GetMV("MV_#CTACFR",,"")),"/",.T.) //
	Local aCCC		:= Separa(Alltrim(GetMV("MV_#CCCCFR",,"")),"/",.T.) //

	Local cNaturez	:= Alltrim(aNaturez[nTpFrtS])
	Local cItemC	:= Alltrim(aItemC[nTpFrtS])
	Local cCTADeb	:= Alltrim(aCTADeb[nTpFrtS])
	Local cCTACre	:= Alltrim(aCTACre[nTpFrtS])
	Local cCCC		:= Alltrim(aCCC[nTpFrtS])

	//
	Aadd(aParam,{cNaturez,cItemC,cCTADeb,cCTACre,cCCC})

	//
	RestArea(aArea)

Return aParam
/*/{Protheus.doc} getDiasF
	Retorna os dias de fechamento do período de frete. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
Static Function getDiasF(nTpFrtS)

	//Variáveis.
	Local aArea		:= GetArea()
	Local aDiaFim	:= {}

	//
	If nTpFrtS = 1
		aDiaFim	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL410"))), "/" )

	ElseIf nTpFrtS = 2
		aDiaFim	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL418"))), "/" )
	
	ElseIf nTpFrtS = 3
		aDiaFim	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL427"))), "/" )

	ElseIf nTpFrtS = 4
		aDiaFim	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL428"))), "/" )

	ElseIf nTpFrtS = 5
		aDiaFim	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL429"))), "/" )

	EndIf

	//
	RestArea(aArea)

Return aDiaFim
/*/{Protheus.doc} getConPg
Retorna as condições de pagamento de fechamento do período de frete. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
Static Function getConPg(nOPc)

	//Variáveis.
	Local aArea	:= GetArea()
	Local aCond	:= {}

	//
	If nOpc = 1
		aCond	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL416"))), "/" )

	ElseIf nOpc = 2
		aCond	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL419"))), "/" )
	
	ElseIf nOpc = 3
		aCond	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL422"))), "/" )

	ElseIf nOpc = 4
		aCond	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL423"))), "/" )

	ElseIf nOpc = 5
		aCond	 := STrToKarr( Alltrim(cValToChar(GetMv("MV_#ADL424"))), "/" )

	EndIf

	//
	RestArea(aArea)

Return aCond
/*/{Protheus.doc} User ADLG40I nomeFunction
	Retorna o tipo de bloqueio financeiro da central de aprovação para o frete utilizado. Chamado 029058.
	@type  Function
	@author Everson
	@since 05/11/2019
	@version 01
	/*/
User Function ADLG40I(nTpFrtS)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local aTpBlq	:= Separa(GetMv("MV_#FRTTBL"),'/',.T.)
	Local cTpBloq	:= aTpBlq[nTpFrtS] //Everson - 05/11/2019. Chamado 029058.

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//
	RestArea(aArea)

Return cTpBloq
/*/{Protheus.doc} apgFcht
	Apaga registros de fechamento de período de frete. Chamado 044314.
	@type  Static Function
	@author user
	@since 24/10/2019
	@version 01
	/*/
Static Function apgFcht(cHashGrp,cCodZFA)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cUpdt		:= ""
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	Default cHashGrp	:= ""
	Default cCodZFA		:= ""

	//
	If ! Empty(cHashGrp)
		cUpdt :=  " UPDATE " + RetSqlName("ZFK") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZFK_FILIAL = '" + FWxFilial("ZFK") + "' AND ZFK_HASH IN (" + cHashGrp + ") AND D_E_L_E_T_ = '' "
		Conout( DToC(Date()) + " " + Time() + " ADLOG040P - apgFcht 1 - cUpdt " + cValToChar(cUpdt) )

		//Everson - 21/09/2021. Chamado 40420.
		While .T.

			If TcSqlExec(cUpdt) < 0
				logZBE("Erro ao apagar ZFK cHashGrp " + cValToChar(cHashGrp))

			Else
				Exit

			EndIf

		EndDo

	EndIf

	//
	If ! Empty(cCodZFA)

		cUpdt :=  " UPDATE " + RetSqlName("ZFA") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZFA_FILIAL = '" + FWxFilial("ZFA") + "' AND ZFA_COD = '" + cCodZFA + "' AND ZFA_VA = '" + Alltrim(cValToChar(nTpFrtS)) + "' AND D_E_L_E_T_ = '' "
		Conout( DToC(Date()) + " " + Time() + " ADLOG040P - apgFcht 2 - cUpdt " + cValToChar(cUpdt) )

		//Everson - 21/09/2021. Chamado 40420.
		While .T.

			If TcSqlExec(cUpdt) < 0
				logZBE("Erro ao apagar ZFA cCodZFA " + cValToChar(cCodZFA))

			Else
				Exit

			EndIf

		EndDo

	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} grvFechZFA
	Gera movimentos de fechamento de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 27/07/2019
	@version 01
	/*/
Static Function grvFechZFA(cCodTran,cLojTran,cNomT,cOcFAcr,cDscOcos,nVlrOcorr,cTpOcorr,cPlaca,cCodZFA,cObsCompl,lPos,lCheckReg) //Everson - 03/02/2020. Chamado T.I.

	//Variáveis.
	Local aArea 	:= GetArea()
	Local lRet 		:= .F.
	Local cCarga	:= ""
	Local dDTEntr	:= ""
	Local cRoteir	:= ""
	Local nNumEnt	:= ""
	Local cTpCarga	:= ""
	Local cVeiculo	:= ""
	Local cTransp	:= ""
	Local cLjTran	:= ""
	Local cNmTran	:= ""
	Local cTransPa	:= cCodTran //Everson - 03/02/2020. Chamado T.I.
	Local cLojaPa	:= cLojTran //Everson - 03/02/2020. Chamado T.I.
	Local cNmTpa	:= Alltrim(cNomT) //Everson - 03/02/2020. Chamado T.I.
	Local nTotKm	:= ""
	Local nVlrPdg	:= ""
	Local nTotKg	:= ""
	Local nTotCx	:= ""
	Local nTotBr	:= ""
	Local cTbFrt	:= ""
	Local cDscFrt	:= ""
	Local cTpFrt	:= ""
	Local cPlcCV	:= ""
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	Local aError	:= {} //Everson - 05/11/2019. Chamado 029058.
	
	Default lPos		:= .F.
	Default cObsCompl	:= ""

	//Everson - 05/11/2019 - Chamado 029058.
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}	

	//
	If lPos

		//
		cCarga	:= ZFA->ZFA_CARGA
		dDTEntr	:= ZFA->ZFA_DTENTR
		cRoteir	:= ZFA->ZFA_ROTEIR
		nNumEnt	:= ZFA->ZFA_NUMENT
		cTpCarga:= ZFA->ZFA_VA
		cVeiculo:= ZFA->ZFA_VEICUL
		cPlcCV	:= ZFA->ZFA_PLCCAV
		cTransp	:= ZFA->ZFA_TRANSP
		cLjTran	:= ZFA->ZFA_LOJTRA
		cNmTran	:= ZFA->ZFA_NMTRAN
		nTotKm	:= ZFA->ZFA_KMTOT
		nVlrPdg	:= ZFA->ZFA_VLRPDG
		nTotKg	:= ZFA->ZFA_CARKG
		nTotCx	:= ZFA->ZFA_CARCX
		nTotBr	:= ZFA->ZFA_KGBT	
		cTbFrt	:= ZFA->ZFA_TABFRT
		cDscFrt	:= ZFA->ZFA_DSCFRT
		cTpFrt	:= ZFA->ZFA_TPFRT

		//
		cTransPa:= ZFA->ZFA_TRANPA
		cLojaPa	:= ZFA->ZFA_LJPPAG
		cNmTpa	:= ZFA->ZFA_NMTPAG
		
	EndIf

	//Everson - 23/01/2020. Chamado 054941.
	If lCheckReg //Everson - 03/02/2020. Chamado T.I.

		         //chkRegF(dDTEntr,cRoteir,cOcFAcr,cCarga,cPlaca,cTransPa,cLojaPa,nVlrOcorr,nTpFrtS,dDtIni,dDtFim)
		cCodZFA := chkRegF(dDTEntr,cRoteir,cOcFAcr,cCarga,cPlaca,cTransPa,cLojaPa,nVlrOcorr,nTpFrtS,MV_PAR01,MV_PAR02)

		//Everson - 23/01/2020. Chamado 054941.
		If ! Empty(cCodZFA)
			lRet := .T.
			RestArea(aArea)
			Return lRet 

		EndIf

	EndIf

	//
	//Everson - 05/11/2019. Chamado 029058.
	oModel:= FwLoadModel ("ADLOG040P")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:SetValue("ZFAMASTER","ZFA_CARGA"	  	,cCarga)
	oModel:SetValue("ZFAMASTER","ZFA_DTENTR"	,dDTEntr)
	oModel:SetValue("ZFAMASTER","ZFA_ROTEIR"	,cRoteir)
	oModel:SetValue("ZFAMASTER","ZFA_NUMENT"	,nNumEnt)
	oModel:SetValue("ZFAMASTER","ZFA_VA"		,cTpCarga)
	oModel:SetValue("ZFAMASTER","ZFA_VEICUL"	,cVeiculo)
	oModel:SetValue("ZFAMASTER","ZFA_TRANSP"	,cTransp)
	oModel:SetValue("ZFAMASTER","ZFA_LOJTRA"	,cLjTran)
	oModel:SetValue("ZFAMASTER","ZFA_NMTRAN"	,cNmTran)
	oModel:SetValue("ZFAMASTER","ZFA_KMTOT"		,nTotKm)
	oModel:SetValue("ZFAMASTER","ZFA_VLRPDG"	,nVlrPdg)
	oModel:SetValue("ZFAMASTER","ZFA_CARKG"		,nTotKg)
	oModel:SetValue("ZFAMASTER","ZFA_CARCX"		,nTotCx)
	oModel:SetValue("ZFAMASTER","ZFA_KGBT"		,nTotBr)
	oModel:SetValue("ZFAMASTER","ZFA_TABFRT"	,cTbFrt)
	oModel:SetValue("ZFAMASTER","ZFA_DSCFRT"	,cDscFrt)
	oModel:SetValue("ZFAMASTER","ZFA_TPFRT"		,cTpFrt)
	oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,MV_PAR02)
	oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,cOcFAcr)
	oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,cDscOcos)
	oModel:SetValue("ZFAMASTER","ZFA_DC"		,cTpOcorr)
	oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,cPlaca)
	oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,cTransPa)
	oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,cLojaPa)
	oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,cNmTpa)
	oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,nVlrOcorr)
	oModel:SetValue("ZFAMASTER","ZFA_OBSERV"  	,"Fechamento de frete " + DToC(MV_PAR01) + "-" + DToC(MV_PAR02) + " " + cObsCompl)
	oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"S")
	oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"S")
	oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
	oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
	oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"A")
	oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,cUserName)
	oModel:SetValue("ZFAMASTER","ZFA_PLCCAV"	,cPlcCV)
	oModel:SetValue("ZFAMASTER","ZFA_DTFCIN"  	,MV_PAR01)
	oModel:SetValue("ZFAMASTER","ZFA_DTFCFM"  	,MV_PAR02)
	oModel:SetValue("ZFAMASTER","ZFA_VA"		,Alltrim(cValToChar( nTpFrtS )))
	oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"  	,U_ADLG40I(nTpFrtS)) 
	oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"	,"ADLOG040P")

	//
	If oModel:VldData()
		oModel:CommitData()
		cCodZFA := oModel:GetValue("ZFAMASTER","ZFA_COD")
		lRet := .T.
		
	Else
		aError := oModel:GetErrorMessage()
		Conout( aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] )
		Help(Nil, Nil, "Função grvFechZFA(ADLOG040P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION], 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

	EndIf       
		
	oModel:DeActivate()
	oModel:Destroy()
	
	oModel := Nil
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} chkRegF
	Retorna registro ZFA de fechamento. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 23/01/2020
	@version 01
	/*/
Static Function chkRegF(dDTEntr,cRoteir,cOcFAcr,cCarga,cPlaca,cTransPa,cLojaPa,nVlrOcorr,nTpFrtS,dDtIni,dDtFim)

	//Variáveis.	
	Local aArea 	:= GetArea()
	Local cNum 		:= ""
	Local lChkZFK	:= .F.

	//
	cCarga := Alltrim(cValToChar(cCarga))

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - chkRegF - dDtIni" )
	varInfo("dDtIni",dDtIni)
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - chkRegF - dDtFim" )
	varInfo("dDtFim",dDtFim)

	//
	logZBE("chkRegF - Checa registro de fechamento, carga " + Alltrim(cCarga) )

	//
	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(1))
	ZFA->(DbGoTop())
	If ! ZFA->( DbSeek( FWxFilial("ZFA") + cCarga ) )
		Conout( DToC(Date()) + " " + Time() + " ADLOG040P - chkRegF - não localizou a carga " + cCarga )
		logZBE("chkRegF - Checa registro de fechamento, opção 0 cCarga " + Alltrim(cCarga))
		RestArea(aArea)
		Return cNum

	EndIf

	//
	While ! ZFA->(Eof()) .And.;
	        Alltrim(ZFA->ZFA_FILIAL) == Alltrim(FWxFilial("ZFA")) .And.;
			Alltrim(ZFA->ZFA_CARGA) == Alltrim(cCarga)

		//
		If DToS(ZFA->ZFA_DTENTR)    == DToS(dDTEntr)     .And.;
		   Alltrim(ZFA->ZFA_ROTEIR) == Alltrim(cRoteir)  .And.;
		   Alltrim(ZFA->ZFA_OCORRE) == Alltrim(cOcFAcr)  .And.;
		   Alltrim(ZFA->ZFA_VEICPG) == Alltrim(cPlaca)   .And.;
		   Alltrim(ZFA->ZFA_TRANPA) == Alltrim(cTransPa) .And.;
		   Alltrim(ZFA->ZFA_LJPPAG) == Alltrim(cLojaPa)  .And.;
		   Alltrim(ZFA->ZFA_VA)     == Alltrim(cValToChar(nTpFrtS))  .And.;
		   DTos(ZFA->ZFA_DTFCIN)    == DTos(dDtIni)  	 .And.;
		   DTos(ZFA->ZFA_DTFCFM)    == DTos(dDtFim)

			//
			cCod := Alltrim(ZFA->ZFA_COD)

			//
			lChkZFK := chkZFK(cCod,"",.F.)

			//Se o registro estiver vinculado a documento fiscal, será necessário gerar outro registro de fechamento.
			If ! lChkZFK
				logZBE("chkRegF - Checa registro de fechamento, opção 1 cCod/cNum " + Alltrim(cCod) + " / " + Alltrim(cNum))
				RestArea(aArea)
				Return cNum

			ElseIf lChkZFK .And. ZFA->ZFA_VALOR == nVlrOcorr //Se o registro não estiver vinculado a documento fiscal e o valor de fechamento é o mesmo, retorna o registro já existente.
				logZBE("chkRegF - Checa registro de fechamento, opção 2 cCod/cNum " + Alltrim(cCod) + " / " + Alltrim(cNum))
				cNum := cCod
				RestArea(aArea)
				Return cNum

			ElseIf lChkZFK .And. ZFA->ZFA_VALOR <> nVlrOcorr //Se o registro não estiver vinculado a documento fiscal e o valor de fechamento é diferente, apaga o registro existe para gerar outro.
				logZBE("chkRegF - Checa registro de fechamento, opção 3 cCod/cNum " + Alltrim(cCod) + " / " + Alltrim(cNum))
				apgFcht("",cCod)
				RestArea(aArea)
				Return cNum

			Else
				logZBE("chkRegF - Checa registro de fechamento, opção 4 cCod/cNum " + Alltrim(cCod) + " / " + Alltrim(cNum))

			EndIf

		EndIf

		//
		ZFA->(DbSkip())

	End

	//
	RestArea(aArea)

Return cNum
/*/{Protheus.doc} vlrCTEmit
Retorna valores de CT-es emitidos. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 23/07/2019
	@version 01
	/*/
Static Function vlrCTEmit(cOpc)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aReturn	:= {}
	Local cTranspVe	:= ""
	Local cCTe   	:= ""
	Local cSerie 	:= ""
	Local cTpEmis	:= ""
	Local cChave 	:= ""
	Local cRot		:= ""
	Local cDtEnt	:= ""
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	Default cOpc	:= ""
	
	//
	cQuery := ""
	cQuery += " SELECT      " 
	cQuery += " ZFA_TRANPA, ZFA_LJPPAG, A4_NOME, ZFA_VEICPG, " //Everson - 06/05/2020. Chamado 057974.
	cQuery += " SUM(ZFK.ZFK_VALOR) AS ZFK_VALOR,  " 
	cQuery += " SUM(ICMS.ZFK_VLRICM) AS ZFK_VLRICM " 
	cQuery += " FROM     " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA "

	cQuery += " INNER JOIN    " 
	//Everson-Ch:044314-15/08/2019.
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " ZFK_FILIAL, ZFK_TRANSP, ZFK_LOJA, ZFK_NUMDOC, ZFK_SERDOC, ZFK_CODZFA, ZFK_PLACA, SUM(ZFK_VALOR) AS ZFK_VALOR   " 
	cQuery += " FROM " + RetSqlName("ZFK") + "  (NOLOCK) AS ZFK WHERE " 
	cQuery += " ZFK_FILIAL =  '" + FWxFilial("ZFK") + "'   " 
	cQuery += " AND ZFK_TPDOC  = '1'      " 
	cQuery += " AND ZFK_STATUS = '1' " 
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY    " 
	cQuery += " ZFK_FILIAL, ZFK_TRANSP, ZFK_LOJA, ZFK_NUMDOC, ZFK_SERDOC, ZFK_CODZFA, ZFK_PLACA " 
	cQuery += "  )AS ZFK ON     " 
	cQuery += " ZFA_FILIAL = ZFK_FILIAL     " 
	cQuery += " AND ZFA_COD = ZFK_CODZFA     " 
	cQuery += " AND ZFA_TRANPA = ZFK_TRANSP     " 
	cQuery += " AND ZFA_LJPPAG = ZFK_LOJA     " 
	cQuery += " AND ZFA_VEICPG = ZFK_PLACA     " 

	cQuery += " LEFT OUTER JOIN  " 
	//Everson-Ch:044314-15/08/2019.
	cQuery += " (  " 
	cQuery += " SELECT  " 
	cQuery += " ZFK_FILIAL, ZFK_TRANSP, ZFK_LOJA, ZFK_NUMDOC, ZFK_SERDOC, ZFK_CODZFA, ZFK_PLACA, AVG(ZFK_VLRICM) AS ZFK_VLRICM   " 
	cQuery += " FROM   " 
	cQuery += "  " + RetSqlName("ZFK") + "  (NOLOCK) AS ZFK   " 
	cQuery += " WHERE   " 
	cQuery += " ZFK_FILIAL =  '" + FWxFilial("ZFK") + "'     " 
	cQuery += " AND ZFK_VLRICM > 0 " 
	cQuery += " AND ZFK.D_E_L_E_T_ = ''   " 
	cQuery += " GROUP BY ZFK_FILIAL, ZFK_TRANSP, ZFK_LOJA, ZFK_NUMDOC, ZFK_SERDOC, ZFK_CODZFA, ZFK_PLACA   " 
	cQuery += " ) AS ICMS ON  " 
	cQuery += " ZFK.ZFK_FILIAL = ICMS.ZFK_FILIAL     " 
	cQuery += " AND ZFK.ZFK_CODZFA = ICMS.ZFK_CODZFA     " 
	cQuery += " AND ZFK.ZFK_TRANSP = ICMS.ZFK_TRANSP     " 
	cQuery += " AND ZFK.ZFK_LOJA   = ICMS.ZFK_LOJA     " 
	cQuery += " AND ZFK.ZFK_PLACA  = ICMS.ZFK_PLACA     " 
	cQuery += " AND ZFK.ZFK_NUMDOC = ICMS.ZFK_NUMDOC     " 
	cQuery += " AND ZFK.ZFK_SERDOC = ICMS.ZFK_SERDOC     " 

	//Everson - 06/05/2020. Chamado 057974.
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("SA4") + " (NOLOCK) AS SA4 ON "
	cQuery += " ZFA_TRANPA = A4_COD "
	cQuery += " AND ZFA_LJPPAG = A4_LOJTRA "
	//

	cQuery += " WHERE     " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "'   " 
	cQuery += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)    + "' AND '" + DToS(MV_PAR02)    + "' "
	cQuery += " AND ZFA_TRANPA BETWEEN '" + Alltrim(MV_PAR03) + "' AND '" + Alltrim(MV_PAR05) + "' "
	cQuery += " AND ZFA_LJPPAG BETWEEN '" + Alltrim(MV_PAR04) + "' AND '" + Alltrim(MV_PAR06) + "' "
	cQuery += " AND ZFA_VEICPG BETWEEN '" + Alltrim(MV_PAR07) + "' AND '" + Alltrim(MV_PAR08) + "' "
	cQuery += " AND ZFA_FECHA  <> 'S'     " 
	cQuery += " AND ZFA_APRMOV <> 'R'     " 
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019 - Chamado 029058.
	cQuery += " AND ZFA.D_E_L_E_T_ = ''       " 
	cQuery += " AND SA4.D_E_L_E_T_ = ''     " 
	cQuery += " GROUP BY    " 
	cQuery += " ZFA_FILIAL, ZFA_TRANPA, A4_NOME, ZFA_LJPPAG, ZFA_VEICPG  " //Everson - 06/05/2020. Chamado 057974.

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - vlrCTEmit - cQuery " + cQuery )

	//
	If Select("D_VLRCTEM") > 0
		D_VLRCTEM->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_VLRCTEM"
	DbSelectArea("D_VLRCTEM")
	D_VLRCTEM->(DbGoTop())
	While ! D_VLRCTEM->(Eof())

		//
		aDados := {}
		aDados := obtCTeComp( Alltrim(D_VLRCTEM->ZFA_VEICPG), Alltrim(D_VLRCTEM->ZFA_TRANPA), Alltrim(D_VLRCTEM->ZFA_LJPPAG))

		//
		If Len(aDados) > 0
			cCTe   := aDados[1][1]
			cSerie := aDados[1][2]
			cTpEmis:= aDados[1][3]
			cChave := aDados[1][4]
			cRot   := aDados[1][5]
			cDtEnt := aDados[1][6]

		EndIf

		//
		cTranspVe := Alltrim(D_VLRCTEM->ZFA_TRANPA) + Alltrim(D_VLRCTEM->ZFA_LJPPAG) + Alltrim(D_VLRCTEM->ZFA_VEICPG)

		//
		Aadd(aReturn,{ cTranspVe, D_VLRCTEM->ZFA_VEICPG, Val(cValToChar(D_VLRCTEM->ZFK_VALOR)), cCTe, cSerie, cTpEmis, cChave, cRot, cDtEnt, Val(cValToChar(D_VLRCTEM->ZFK_VLRICM)) })

		//
		cCTe   := ""
		cSerie := ""
		cTpEmis:= ""
		cChave := ""

		D_VLRCTEM->(DbSkip())

	End
	//
	D_VLRCTEM->(DbCloseArea())

	//
	RestArea(aArea)

Return aReturn
/*/{Protheus.doc} obtCTeComp
	Retorna CT-e a ser complementado no fechamento do período. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 23/07/2019
	@version 01
	/*/
Static Function obtCTeComp(cPlaca, cTransp, cLoja)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aRetorno	:= {}
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	//Everson - 05/05/2021. Chamado 13434.
	Local cEstTran  := Posicione("SA4",1,FWxFilial("SA4") + cTransp ,"A4_EST")
	Local lTransEst := cEstTran $GetMv("MV_#UFTCAT",,"")
	//

	//
	cQuery := ""
	cQuery += " SELECT    " 
	cQuery += " TOP 1 ZFA_TRANPA, ZFA_LJPPAG, ZFA_VEICPG, ZFK_NUMDOC, ZFK_SERDOC,  " 
	cQuery += " ZFK_TPENVC, ZFK_CHAVE, "
	cQuery += " ZFK_ROTEIR, ZFK_DTENTR, SUM(ZFK_VALOR) AS ZFK_VALOR   " 
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA   " 
	cQuery += " INNER JOIN  " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK ON   " 
	cQuery += " ZFA_FILIAL = ZFK_FILIAL   " 
	cQuery += " AND ZFA_COD = ZFK_CODZFA   " 
	cQuery += " AND ZFA_TRANPA = ZFK_TRANSP   " 
	cQuery += " AND ZFA_LJPPAG = ZFK_LOJA   " 
	cQuery += " AND ZFA_VEICPG = ZFK_PLACA   " 
	//cQuery += " INNER JOIN  " + RetSqlName("ZV4") + " (NOLOCK) AS ZV4 ON   " 
	// cQuery += " ZFA_TRANPA = ZV4_FORNEC   " 
	// cQuery += " AND ZFA_LJPPAG = ZV4_LOJFOR   " 
	// cQuery += " AND ZFA_VEICPG = ZV4_PLACA   "  //Everson - 02/07/2020. Chamado 059405.

	//Everson - 05/05/2021. Chamado 13434.
	If ! lTransEst
		cQuery += " AND ZFK_TPENVC = '00' "

	EndIf
	//

	cQuery += " WHERE   " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "'   " 
	cQuery += " AND ZFA_DATA   BETWEEN '" + DToS(MV_PAR01)	 + "' AND '" + DToS(MV_PAR02)    + "' "
	cQuery += " AND ZFA_TRANPA BETWEEN '" + Alltrim(cTransp) + "' AND '" + Alltrim(cTransp)  + "' "
	cQuery += " AND ZFA_LJPPAG BETWEEN '" + Alltrim(cLoja)   + "' AND '" + Alltrim(cLoja)  + "' "
	cQuery += " AND ZFA_VEICPG BETWEEN '" + Alltrim(cPlaca)  + "' AND '" + Alltrim(cPlaca)    + "' " 
	cQuery += " AND ZFA_FECHA <> 'S'    " 
	cQuery += " AND ZFA_APRMOV <> 'R'    " 
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' " //Everson - 05/11/2019 - Chamado 029058.
	cQuery += " AND ZFK_TPDOC = '1'   " 
	cQuery += " AND ZFK_STATUS = '1'    " 
	cQuery += " AND ZFA.D_E_L_E_T_ = ''   " 
	cQuery += " AND ZFK.D_E_L_E_T_ = ''   " 
	//cQuery += " AND ZV4.D_E_L_E_T_ = ''   "  //Everson - 02/07/2020. Chamado 059405.
	cQuery += " GROUP BY  " 
	cQuery += " ZFA_FILIAL, ZFA_TRANPA, ZFA_LJPPAG, ZFA_VEICPG,  ZFK_NUMDOC, ZFK_SERDOC, " 
	cQuery += " ZFK_ROTEIR, ZFK_DTENTR, ZFK_TPENVC, ZFK_CHAVE " 
	cQuery += " ORDER BY ZFK_VALOR DESC " 

	//
	If Select("D_CTECOM") > 0
		D_CTECOM->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_CTECOM"
	DbSelectArea("D_CTECOM")
	D_CTECOM->(DbGoTop())

	If ! D_CTECOM->(Eof())
		Aadd(aRetorno, {  D_CTECOM->ZFK_NUMDOC, D_CTECOM->ZFK_SERDOC, D_CTECOM->ZFK_TPENVC, D_CTECOM->ZFK_CHAVE,Alltrim(D_CTECOM->ZFK_ROTEIR), D_CTECOM->ZFK_DTENTR  } ) //Everson - 12/12/2019 - Chamado 029058.

	EndIf

	D_CTECOM->(DbCloseArea())

	//
	RestArea(aArea)

Return aRetorno
/*/{Protheus.doc} ³visuReg
	Carrega o registro do movimento de frete para visualização/alteração. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 25/03/2019
	@version 01
	/*/
Static Function visuReg(oDadosD,aHDoD)

	//Variáveis.
	Local aArea		:= GetArea()	
	Local nRecno	:= Val(cValToChar( oDadosD:aCols[oDadosD:nAt][ aScan(aHDoD,{|x| Alltrim(cValToChar(x[2])) == "ZFA_RECNO" })]))
	Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

	//
	If nQtdConf <= 0
		MsgStop("Não há registro selecionado.","Função visuReg(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	DbSelectArea("ZFA")
	ZFA->(DbGoTo(nRecno))
	If ZFA->(Eof())
		MsgStop("Não foi possível localizar o registro (recno " + cValToChar(nRecno) + ").","Função visuReg(ADLOG040P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	FWExecView('Inclusao por FWExecView','ADLOG040P', 4, , { || .T. }, , ,aButtons )

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADLG40G
	Importa dados de movimento de frete a partir de arquivo CSV. Chamado 044314.
	@type  Function
	@author Everson
	@since 24/04/2018
	@version 01
	/*/ 
User Function ADLG40G()

	//Variáveis.
	Local aArea			:= GetArea()
	Local cArq			:= ""
	Local cOcorren		:= GetMv("MV_#OCFRT",,"")
	Local nHdl			:= 0
	Local nTotLinhas	:= 0
	Local cCodOc		:= ""
	Local dData			
	Local cPlaca		:= ""
	Local cObserv		:= ""
	Local aInfo			:= {}
	Local lErro			:= .F.
	Local aDados		:= {}
	Local nAux			:= 0
	Local cBuffer		:= ""
	Local i				:= 1
	Local aError		:= {} //Everson - 05/11/2019 - Chamado 029058.
	Local nTpFrtS		:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.

	//Everson - 05/11/2019 - Chamado 029058.
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}	

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//
	cArq := cGetFile('Arquivo CSV|*.*|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

	//Valida arquivo.  
	If Empty(cArq)
		Help(Nil, Nil, "Função IMPARQ(ADLOG040P) Função IMPARQ(ADLOG040P)", Nil,"Não foi possível obter o arquivo.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		RestArea(aArea)
		Return Nil

	Endif

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLG40G - cArq " + cArq )

	//Abre o arquivo.
	nHdl := FT_FUse(cArq)

	//Valida abertura do arquivo.
	If nHdl == -1
		Help(Nil, Nil, "Função IMPARQ(ADLOG040P) Função IMPARQ(ADLOG040P)", Nil,"Não foi possível abrir o arquivo " + Chr(13) + Chr(13) + cArq, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		RestArea(aArea)
		Return Nil

	Endif

	//
	FT_FGoTop()

	//Obtém a quantidade de linhas.
	nTotLinhas := FT_FLastRec()

	//Atribui o tamanho da régua.
	ProcRegua(nTotLinhas)

	FT_FGoTop()

	//Percorre arquivo.
	While ! FT_FEof()

		//
		IncProc()

		//
		nAux++

		//
		cBuffer  := Alltrim(cValToChar(FT_FReadln()))

		//Buffer vazio.
		If Empty(cBuffer)
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLG40G - cBuffer vazio . Linha " + cValToChar(nAux) )
			FT_FSkip()
			Loop

		EndIf

		//Cabeçalho.
		If nAux == 1
			FT_FSkip()
			Loop

		EndIf		

		//
		aInfo := Separa(cBuffer,';',.T.)
		
		//Valida quantidade de campos do arquivo.
		If Len(aInfo) <> 5
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLG40G - Len(aInfo) " + cValToChar(Len(aInfo)) )
			Help(Nil, Nil, Nil, Nil,"Função IMPARQ(ADLOG040P) Quantidade incorreta de campos. Linha " + cValToChar(nAux) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lErro := .T.
			Exit

		EndIf		

		//
		dData	:= CToD(aInfo[1])
		cPlaca	:= Alltrim(cValToChar(aInfo[2]))
		cCodOc 	:= Alltrim(cValToChar(aInfo[3]))
		cObserv	:= Alltrim(cValToChar(aInfo[4]))
		nValor	:= Val( StrTran(StrTran(cValToChar(aInfo[5]),".",""),",",".") )


		//Valida o código.
		//Everson - 26/11/2019 - Chamado 029058.
		If nValor <= 0
			Help(Nil, Nil, "Função IMPARQ(ADLOG040P)", Nil,"Função IMPARQ(ADLOG040P), valor inválido . Linha " + cValToChar(nAux) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lErro := .T.
			Exit

		EndIf

		//Valida o código.
		If !  (cCodOc $cOcorren)
			Help(Nil, Nil, "Função IMPARQ(ADLOG040P)", Nil,"Ocorrência não permitida " + cValToChar(cCodOc) + ". Linha " + cValToChar(nAux) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lErro := .T.
			Exit

		EndIf

		//
		cDescOc := Alltrim(cValToChar(Posicione("ZF7",1, FWxFilial("ZF7") + cCodOc, "ZF7_DESC" )))
		cTpMov	:= Alltrim(cValToChar(Posicione("ZF7",1, FWxFilial("ZF7") + cCodOc, "ZF7_DBCD" )))

		//Valida o código.
		If Empty(cDescOc)
			Help(Nil, Nil, "Função IMPARQ(ADLOG040P)", Nil,"Função IMPARQ(ADLOG040P) Não é possível importar a ocorrência " + cCodOc + ". Linha " + cValToChar(nAux) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lErro := .T.
			Exit

		EndIf

		//Valida placa/transportadora.
		cTrans 	:= Alltrim(cValToChar(Posicione("ZV4",1, FWxFilial("ZV4") + cPlaca, "ZV4_FORNEC" )))
		cLoja  	:= Alltrim(cValToChar(Posicione("ZV4",1, FWxFilial("ZV4") + cPlaca, "ZV4_LOJFOR" )))
		cNmFor	:= Alltrim(cValToChar(Posicione("ZV4",1, FWxFilial("ZV4") + cPlaca, "ZV4_NOMFOR" )))

		//Valida transportadora.
		If Empty(cTrans)
			Help(Nil, Nil, "Função IMPARQ(ADLOG040P)", Nil,"Função IMPARQ(ADLOG040P) Placa do veículo ou transportadora não encontrada. Linha " + cValToChar(nAux) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lErro := .T.
			Exit

		EndIf		

		//
		Aadd(aDados,{dData,cCodOc,cDescOc,cTpMov,cPlaca,cTrans,cLoja,cNmFor,nValor,cObserv})

		FT_FSkip()

	EndDo

	//
	If ! lErro .And. Len(aDados) > 0

		//
		If ! MsgYesNo("Serão importados " + cValToChar(Len(aDados)) + " registros. Deseja prosseguir?","Função IMPARQ(ADLOG040P)")
			RestArea(aArea)
			Return Nil

		EndIf

		//Everson - 06/12/2019 - Chamado 029058.
		If InTransact() .Or. FwInTTSBreak()
			MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função ADLG40G(ADLOG040P)")
			logZBE("Sistema está em transação ou TTSBreak - abortando operação. Função ADLG40G(ADLOG040P) ")
			final()

		EndIf  
		
		//
		Begin Transaction

			//
			For i := 1 To Len(aDados)
				
				//
				//Everson - 05/11/2019. Chamado 029058.
				oModel:= FwLoadModel ("ADLOG040P")
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
				oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,aDados[i][1])
				oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,aDados[i][2])
				oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,aDados[i][3])
				oModel:SetValue("ZFAMASTER","ZFA_DC"		,aDados[i][4])
				oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,aDados[i][5])

				oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,aDados[i][6])
				oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,aDados[i][7])
				oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,Substr(Alltrim(cValToChar(aDados[i][8])),1,TamSX3("ZFA_NMTPAG")[1]) )
				oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,aDados[i][9])
				oModel:SetValue("ZFAMASTER","ZFA_OBSERV"  	,aDados[i][10])

				oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"N")
				oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"N")
				oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
				oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
				oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"M")
				oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,cUserName)
				oModel:SetValue("ZFAMASTER","ZFA_VA"		,Alltrim(cValToChar( nTpFrtS )))
				oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"  	,U_ADLG40I(nTpFrtS)) 
				oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"	,"ADLOG040P")

				//
				If oModel:VldData()
					oModel:CommitData()

				Else
					aError := oModel:GetErrorMessage()
					Help(Nil, Nil, "Função IMPARQ(ADLOG040P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION], 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
					DisarmTransaction() //Everson - 06/12/2019 - Chamado T.I.
					Break //Everson - 06/12/2019 - Chamado T.I.
					
				EndIf       
					
				oModel:DeActivate()
				oModel:Destroy()
				
				oModel := Nil

			Next i

		End Transaction

	EndIf

	//
	If nHdl <> -1
		FT_FUse(cArq)

	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} ³ADLG0404
	Valida carga selecionada para lançamento de movimento de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 14/03/2019
	@version 01
	/*/
User Function ADLG0404(cCarga,cTpFrtS,cTpMov) // U_ADLG0404(M->ZFA_CARGA,M->ZFA_VA) //Everson - 07/11/2019. Chamado 029058.

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cQuery	:= ""

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//Everson - 28/11/2019 - Chamado 029058.
	If Alltrim(cTpMov) == "A"
		RestArea(aArea)
		Return lRet
		
	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT  "
	cQuery += " TOP 1 *  "
	cQuery += " FROM  "
	cQuery += " " + RetSqlName("ZFA") + " AS ZFA "
	cQuery += " WHERE "
	cQuery += " ZFA_FILIAL = '" + FwFilial("ZFA") + "' "
	cQuery += " AND ZFA_CARGA = '" + cCarga + "' "
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar( cTpFrtS )) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND ZFA.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY R_E_C_N_O_ DESC "

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLG0404 - cCarga " + cValToChar(cCarga) )
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLG0404 - cQuery " + cValToChar(cQuery) )

	//
	If Select("D_CARGA") > 0
		D_CARGA->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_CARGA"
	DbSelectArea("D_CARGA")

	If ! D_CARGA->(Eof()) .And. ! Empty(D_CARGA->ZFA_CARGA)

		M->ZFA_DTENTR := SToD(D_CARGA->ZFA_DTENTR)
		M->ZFA_ROTEIR := D_CARGA->ZFA_ROTEIR
		M->ZFA_NUMENT := D_CARGA->ZFA_NUMENT		
		M->ZFA_VA	  := D_CARGA->ZFA_VA
		M->ZFA_TRANSP := D_CARGA->ZFA_TRANSP
		M->ZFA_LOJTRA := D_CARGA->ZFA_LOJTRA
		M->ZFA_NMTRAN := D_CARGA->ZFA_NMTRAN		
		M->ZFA_VEICUL := D_CARGA->ZFA_VEICUL		
		M->ZFA_KMTOT  := D_CARGA->ZFA_KMTOT		
		M->ZFA_VLRPDG := D_CARGA->ZFA_VLRPDG		
		M->ZFA_CARKG  := D_CARGA->ZFA_CARKG
		M->ZFA_KGBT   := D_CARGA->ZFA_KGBT
		M->ZFA_CARCX  := D_CARGA->ZFA_CARCX
		M->ZFA_ROTEIR := D_CARGA->ZFA_ROTEIR		
		M->ZFA_TABFRT := D_CARGA->ZFA_TABFRT
		M->ZFA_DSCFRT := D_CARGA->ZFA_DSCFRT
		M->ZFA_TPFRT  := D_CARGA->ZFA_TPFRT	

		M->ZFA_VEICPG := D_CARGA->ZFA_VEICUL
		M->ZFA_TRANPA := D_CARGA->ZFA_TRANSP
		M->ZFA_LJPPAG := D_CARGA->ZFA_LOJTRA
		M->ZFA_NMTPAG := D_CARGA->ZFA_NMTRAN
		M->ZFA_PLCCAV := D_CARGA->ZFA_PLCCAV

	Else
		//MsgStop("Carga " + cCarga + " não localizada.","Função ADLG0404(ADLOG040P)")
		lRet := .F.

	EndIf

	//
	D_CARGA->(DbCloseArea())

	//
	If ! lRet .Or. Empty(cCarga)
		M->ZFA_DTENTR := SToD("")
		M->ZFA_ROTEIR := ""
		M->ZFA_NUMENT := 0		
		M->ZFA_VA	  := ""
		M->ZFA_TRANSP := ""
		M->ZFA_LOJTRA := ""
		M->ZFA_NMTRAN := ""		
		M->ZFA_VEICUL := ""	
		M->ZFA_KMTOT  := 0		
		M->ZFA_VLRPDG := 0		
		M->ZFA_CARKG  := 0
		M->ZFA_KGBT   := 0
		M->ZFA_CARCX  := 0		
		M->ZFA_TABFRT := ""
		M->ZFA_DSCFRT := ""
		M->ZFA_TPFRT  := ""

		M->ZFA_VEICPG := Space(TamSX3("ZFA_VEICPG")[1])
		M->ZFA_TRANPA := ""
		M->ZFA_LJPPAG := ""
		M->ZFA_NMTPAG := ""
		M->ZFA_PLCCAV := ""

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLG0404 - lRet " + cValToChar(lRet) )

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADLG40F
	Exibe informações do CT-e e MDF-e gerados para o roteiro. Chamado 044314.
	@type  Function
	@author Everson
	@since 25/06/2019
	@version 01
	/*/
User Function ADLG40F()

	//Variáveis.
	Local aArea			:= GetArea()
	Local oInterface	:= Nil

	Private aHDc		:= {}
	Private aColsDc		:= {}
	Private oDocs		:= Nil

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//
	oInterface			 := MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Documentos Fiscais da Carga"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1200
	oInterface:nHeight   := 550
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.

	//
	Aadd(aHDc,{" ","LEG"    	,"@BMP"     ,001, 0,.T.,"","","","R","","",.F.,"V","","","",""})
	Aadd(aHDc,{"Ped Comp" 		,"CRPDCOM"  ,"" ,006, 0,"","" ,"D","",""})
	Aadd(aHDc,{"DT Entrega" 	,"CRDTE"    ,"" ,008, 0,"","" ,"D","",""})
	Aadd(aHDc,{"Roteiro"   		,"CRROT"    ,"" ,005, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Tipo Doc"   	,"CRTPDOC" 	,"" ,006, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Num Doc" 		,"CRNUMDOC"	,"" ,009, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Série" 			,"CRSRDOC" 	,"" ,003, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Status" 		,"CRSTATUS"	,"" ,020, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Seq Env" 		,"CRSEQENV"	,"" ,004, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Valor"    		,"CRVALOR"	,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""})				
	Aadd(aHDc,{"Mensagem" 		,"CROPHOS"	,"" ,100, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Hash" 			,"CRHASH"	,""  ,030, 0,"","" ,"C","",""})				
	Aadd(aHDc,{"Chave"   		,"CRCHAVE"	,"" ,030, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Prot Emissão"	,"CRPEMI" 	,"" ,030, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Prot Cancela"	,"CRPCAN" 	,"" ,030, 0,"","" ,"C","",""})
	Aadd(aHDc,{"Prot Encerra"	,"CRPENC"	,"" ,030, 0,"","" ,"C","",""})

	//
	oDocs := MsNewGetDados():New(010,002,205,590,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oInterface,aHDc,@aColsDc)	

	//
	TGroup():Create(oInterface,239,005,260,595,"",,,.T.)
	TButton():New(245,010,"Legenda"    ,oInterface,{|| U_adlog574(2) }   ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(245,550,"Fechar"     ,oInterface,{|| oInterface:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oInterface:Activate(,,,.T.,{||.T.},,{|| carrDocs() })	

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} carrDocs
	Carrega objeto MsNewGetDados da função ADLG40F com as informações de CT-e e MDF-e gerados. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 25/06/2019
	@version 01
	/*/
Static Function carrDocs()

	//Variáveis.
	Local aArea	 	:= GetArea()
	Local cQuery	:= ""	
	Local cDtEntr	:= DToS(ZFA->ZFA_DTENTR)
	Local cRoteiro	:= Alltrim(cValToChar(ZFA->ZFA_ROTEIR))
	Local nTpFrtS	:= U_ADLG40H() //Everson - 05/11/2019. Chamado 029058.
	Local cStatus	:= ""

	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ZFK_TRANSP, " 
	cQuery += " ZFK_LOJA, " 
	cQuery += " ZFK_NMTRAN, " 
	cQuery += " ZFK_CARGA, " 
	cQuery += " ZFK_DTENTR, " 
	cQuery += " ZFK_ROTEIR, " 
	cQuery += " ZFK_SEQENV, " 
	cQuery += " ZFK_TPDOC, " 
	cQuery += " ZFK_NUMDOC, " 
	cQuery += " ZFK_SERDOC, " 
	cQuery += " ZFK_STATUS, " 
	cQuery += " ZFK_HASH, " 
	cQuery += " ZFK_DATA, " 
	cQuery += " ZFK_PLACA, " 
	cQuery += " ZFK_OPHOS, "  
	cQuery += " ZFK_CHAVE, " 
	cQuery += " ZFK_PROTEM, " 
	cQuery += " ZFK_PROTCA, " 
	cQuery += " ZFK_REBOQU, " 
	cQuery += " ZFK_PROENC, "
	cQuery += " SUM(ZFK_VALOR) AS ZFK_VALOR, ZFK_PEDCOM "
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK "

	//Everson - 05/11/2019. Chamado 029058.
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA ON "
	cQuery += " ZFK_FILIAL = ZFA_FILIAL "
	cQuery += " AND ZFK_CODZFA = ZFA_COD " 

	cQuery += " WHERE " 
	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_DTENTR = '" + cDtEntr  + "' " 
	cQuery += " AND ZFK_ROTEIR = '" + cRoteiro   + "' " 
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar( nTpFrtS )) + "' " //Everson - 05/11/2019. Chamado 029058.
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	cQuery += " AND ZFA.D_E_L_E_T_ = '' "

	cQuery += " GROUP BY "
	cQuery += " ZFK_TRANSP, " 
	cQuery += " ZFK_LOJA, " 
	cQuery += " ZFK_NMTRAN, " 
	cQuery += " ZFK_CARGA, " 
	cQuery += " ZFK_DTENTR, " 
	cQuery += " ZFK_ROTEIR, " 
	cQuery += " ZFK_SEQENV, " 
	cQuery += " ZFK_TPDOC, " 
	cQuery += " ZFK_NUMDOC, " 
	cQuery += " ZFK_SERDOC, " 
	cQuery += " ZFK_STATUS, " 
	cQuery += " ZFK_HASH, " 
	cQuery += " ZFK_DATA, " 
	cQuery += " ZFK_PLACA, " 
	cQuery += " ZFK_OPHOS, "  
	cQuery += " ZFK_CHAVE, " 
	cQuery += " ZFK_PROTEM, " 
	cQuery += " ZFK_PROTCA, " 
	cQuery += " ZFK_REBOQU, " 
	cQuery += " ZFK_PROENC, ZFK_PEDCOM "	
	cQuery += " ORDER BY ZFK_DTENTR, ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA, ZFK_TPDOC, CAST(ZFK_SEQENV AS INTEGER), ZFK_PEDCOM " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - carrDocs - cQuery " + cQuery )

	//
	If Select("D_DOCS") > 0
		D_DOCS->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_DOCS"
	DbSelectArea("D_DOCS")
	D_DOCS->(DbGoTop())

	//
	If D_DOCS->(Eof())
		D_DOCS->(DbCloseArea())
		RestArea(aArea)
		Return Nil

	EndIf

	//
	oDocs:aCols := {}
	While ! D_DOCS->(Eof())

		//
		cStatus 	:= Alltrim(cValToChar(D_DOCS->ZFK_STATUS))
		//cMsgStatus 	:= Static Call(ADLOG057P,tlbStatus,cStatus,1)
		//cTipoDoc 	:= Static Call(ADLOG057P,tabelaDoc,Alltrim(cValtoChar(D_DOCS->ZFK_TPDOC)))
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		cMsgStatus 	:= u_LOG057A4(cStatus,1)
		cTipoDoc 	:= u_LOG057A5(Alltrim(cValtoChar(D_DOCS->ZFK_TPDOC)))

		//
		If cMsgStatus == 'Processando'
			oCor := LoadBitmap( GetResources(), "BR_AMARELO")

		ElseIf cMsgStatus == 'Emitido'
			oCor := LoadBitmap( GetResources(), "BR_VERDE")

		ElseIf cMsgStatus == 'Cancelado'
			oCor := LoadBitmap( GetResources(), "BR_CANCEL")

		ElseIf cMsgStatus == 'Rejeitado'
			oCor := LoadBitmap( GetResources(), "BR_PINK")

		ElseIf cMsgStatus == 'Contingência'
			oCor := LoadBitmap( GetResources(), "BR_MARROM")

		ElseIf cMsgStatus == 'Hash não localizado'
			oCor := LoadBitmap( GetResources(), "BR_VIOLETA")

		ElseIf cMsgStatus == 'Denegado'
			oCor := LoadBitmap( GetResources(), "BR_PRETO")

		ElseIf cMsgStatus == 'Encerrado' 
			oCor := LoadBitmap( GetResources(), "BR_AZUL")

		ElseIf cMsgStatus == 'Não emitido' 
			oCor := LoadBitmap( GetResources(), "BR_VERMELHO")

		Else
			oCor := LoadBitmap( GetResources(), "BR_LARANJA")

		EndIf

		//
		Aadd(oDocs:aCols , Array(Len(aHDc) + 1) )
		oDocs:aCols[Len(oDocs:aCols), Len(oDocs:aCols[1]) ] := .F.
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "LEG" })]			:= oCor
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRDTE" })]		:= SToD(cDtEntr)
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRROT" })]		:= cRoteiro
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSTATUS" })]	:= cMsgStatus
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRTPDOC" })] 	:= cTipoDoc
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRNUMDOC" })] 	:= D_DOCS->ZFK_NUMDOC
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSRDOC" })] 	:= D_DOCS->ZFK_SERDOC
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSEQENV" })] 	:= D_DOCS->ZFK_SEQENV
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRVALOR" })] 	:= D_DOCS->ZFK_VALOR
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CROPHOS" })] 	:= D_DOCS->ZFK_OPHOS
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRHASH" })] 		:= D_DOCS->ZFK_HASH
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRCHAVE" })] 	:= D_DOCS->ZFK_CHAVE
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPEMI" })] 		:= D_DOCS->ZFK_PROTEM
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPCAN" })] 		:= D_DOCS->ZFK_PROTCA
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPENC" })] 		:= D_DOCS->ZFK_PROENC
		oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPDCOM" })] 	:= D_DOCS->ZFK_PEDCOM

		D_DOCS->(DbSkip())

	End

	//
	D_DOCS->(DbCloseArea())

	//
	oDocs:Refresh()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADLG40D
	Exibe informações das notas fiscais relacionadas ao roteiro. Chamado 044314.
	@type  Function
	@author Everson
	@since 11/02/2019
	@version 01
	/*/
User Function ADLG40D()

	//Variáveis.
	Local aArea		:= GetArea()
	Local oModal	:= Nil
	Local oContainer:= Nil
	Local oFont		:= TFont():New("Verdana",,014,,.T.,,,,,.F.,.F.)
	Local cCarga   	:= ZFA->ZFA_CARGA
	Local cTransp  	:= ZFA->ZFA_TRANSP
	Local cLojTrp  	:= ZFA->ZFA_LOJTRA
	Local cNomeTrp 	:= ZFA->ZFA_NMTRAN
	Local cPlaca   	:= ZFA->ZFA_VEICPG
	Local cRoteir  	:= ZFA->ZFA_ROTEIR
	Local dData    	:= ZFA->ZFA_DATA
	Local oBrwTrb	:= Nil
	Local dDataE	:= ZFA->ZFA_DTENTR
	Local cEntregas	:= cValToChar(ZFA->ZFA_NUMENT)
	Local cTpCarga	:= Alltrim(ZFA->ZFA_VA) //Everson - 21/01/2020. Chamado 054941.

	Private aCpoBro	 := {}
	Private lInverte := .F.  
	Private cMark    := GetMark()

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//
	Aadd( aCpoBro,{"ZFD_SEQCAR" ,  ,"Sequencia"    , "" } )
	Aadd( aCpoBro,{"ZFD_CAMINH" ,  ,"Placa"        , "" } )
	Aadd( aCpoBro,{"ZFD_PEDIDO" ,  ,"Pedido Venda" , "" } )
	Aadd( aCpoBro,{"ZFD_CLIENT" ,  ,"Cliente"      , "" } )
	Aadd( aCpoBro,{"ZFD_LOJA"   ,  ,"Loja"         , "" } )
	Aadd( aCpoBro,{"ZFD_NOMECL" ,  ,"Nome Cliente" , "" } )
	Aadd( aCpoBro,{"ZFD_NUMNF"  ,  ,"Numero Nota"  , "" } )
	Aadd( aCpoBro,{"ZFD_SERIE"  ,  ,"Serie"        , "" } )

	//Everson-Ch:044314-21/03/2019
	Aadd( aCpoBro,{"ZFD_PBRUTO" ,  ,"Peso Bruto"   , "@E 999,999,999.99" } )
	Aadd( aCpoBro,{"ZFD_PESOL"  ,  ,"Peso Liq. "   , "@E 999,999,999.99" } )
	Aadd( aCpoBro,{"ZFD_VOLUME" ,  ,"Volume"       , "@E 999,999.9999" } )
	Aadd( aCpoBro,{"ZFD_CIDADE" ,  ,"Cidade"       , "" } )
	//Everson - 11/08/2020. Chamado 059326.
	//Aadd( aCpoBro,{"ZFD_LATITU" ,  ,"Latitude"     , "" } )
	//Aadd( aCpoBro,{"ZFD_LONGIT" ,  ,"Longitude"    , "" } )
	Aadd( aCpoBro,{"ZFD_CHAVE" ,   ,"Chave"        , "" } )

	ADLG0402(cCarga,.F.,cRoteir,cTpCarga) //Everson 26/04/2019. Chamado 044314. Adicionado roteiro.

	oModal := FWDialogModal():New()        
	oModal:SetEscClose(.T.)
	oModal:setTitle("Conferência de Frete")
	oModal:setSubTitle("Detalhes das notas fiscais do frete para conferência.")
	oModal:setSize( 250 , 600 )
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")

	oContainer := TPanel():New( ,,, oModal:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	TSay():New(003,002,{|| "Carga"         },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
	TGet():New(015,002,{|u| if( PCount() > 0, cCarga := u, cCarga ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cCarga")
	TSay():New(003,050,{|| "Transp."  },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
	TGet():New(015,050,{|u| if( PCount() > 0, cTransp := u, cTransp ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cTransp")
	TSay():New(003,100,{|| "Loja"  },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
	TGet():New(015,100,{|u| if( PCount() > 0, cLojTrp := u, cLojTrp ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cLojTrp")
	TSay():New(003,150,{|| "Nome"  },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
	TGet():New(015,150,{|u| if( PCount() > 0, cNomeTrp := u, cNomeTrp ) } ,oContainer,100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cNomeTrp")
	TSay():New(003,260,{|| "Placa"  },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
	TGet():New(015,260,{|u| if( PCount() > 0, cPlaca := u, cPlaca ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cPlaca")
	TSay():New(003,310,{|| "Roteiro"  },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
	TGet():New(015,310,{|u| if( PCount() > 0, cRoteir := u, cRoteir ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cRoteir")
	TSay():New(003,360,{|| "Data Lançamento"  },oContainer,,oFont,,,,.T.,,,115,20,,,,,,.T.)
	TGet():New(015,360,{|u| if( PCount() > 0, dData := u, dData ) } ,oContainer,35,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"dData")

	TSay():New(003,430,{|| "Data entrega"  },oContainer,,oFont,,,,.T.,,,115,20,,,,,,.T.)
	TGet():New(015,430,{|u| if( PCount() > 0, dDataE := u, dDataE ) } ,oContainer,35,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"dDataE")

	TSay():New(003,500,{|| "Entregas"  },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
	TGet():New(015,500,{|u| if( PCount() > 0, cEntregas := u, cEntregas ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cEntregas")

	oBrwTrb := MsSelect():New("ADLG0403","OK","",aCpoBro,@lInverte,@cMark,{030,000,180,600}, , , oContainer )
	Eval(oBrwTrb:oBrowse:bGoTop)

	oModal:Activate()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADLG0405
	Exibe informações de notas fiscais vinculadas ao roteiro para que o usuário
	selecione as notas fiscais que estão relacionadas a ocorrência que está sendo lançada. Chamado 044314.
	@type  Function
	@author Everson
	@since 15/03/2019
	@version 01
	/*/
User Function ADLG0405(oView)

	//Variáveis.
	Local aArea		:= GetArea()
	Local oModal	:= Nil
	Local oContainer:= Nil
	Local cCarga   	:= oView:GetValue( 'ZFAMASTER' , 'ZFA_CARGA' )
	Local cRoteir  	:= oView:GetValue( 'ZFAMASTER' , 'ZFA_ROTEIR' )
	Local cTpCarga	:= oView:GetValue( 'ZFAMASTER' , 'ZFA_VA' )
	Local oBrwTrb	:= Nil
  
	//
	Private aCpoBro	 := {}
	Private lInverte := .F.  
	Private cMark    := GetMark()

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//
	cNfs := ""

	//
	Aadd( aCpoBro,{ "OK"        ,  , "Mark"        ,"@!"})
	Aadd( aCpoBro,{"ZFD_SEQCAR" ,  ,"Sequencia"    , "" } )
	Aadd( aCpoBro,{"ZFD_CAMINH" ,  ,"Placa"        , "" } )
	Aadd( aCpoBro,{"ZFD_PEDIDO" ,  ,"Pedido Venda" , "" } )
	Aadd( aCpoBro,{"ZFD_CLIENT" ,  ,"Cliente"      , "" } )
	Aadd( aCpoBro,{"ZFD_LOJA"   ,  ,"Loja"         , "" } )
	Aadd( aCpoBro,{"ZFD_NOMECL" ,  ,"Nome Cliente" , "" } )
	Aadd( aCpoBro,{"ZFD_NUMNF"  ,  ,"Numero Nota"  , "" } )
	Aadd( aCpoBro,{"ZFD_SERIE"  ,  ,"Serie"        , "" } )

	//Everson-Ch:044314-21/03/2019
	Aadd( aCpoBro,{"ZFD_PBRUTO" ,  ,"Peso Bruto"   , "@E 999,999,999.99" } )
	Aadd( aCpoBro,{"ZFD_PESOL"  ,  ,"Peso Liq. "   , "@E 999,999,999.99" } )
	Aadd( aCpoBro,{"ZFD_VOLUME" ,  ,"Volume"       , "@E 999,999.9999" } )
	Aadd( aCpoBro,{"ZFD_CIDADE" ,  ,"Cidade"       , "" } )

	//Everson - 11/08/2020. Chamado 059326.
	//Aadd( aCpoBro,{"ZFD_LATITU" ,  ,"Latitude"     , "" } )
	//Aadd( aCpoBro,{"ZFD_LONGIT" ,  ,"Longitude"    , "" } )

	ADLG0402(cCarga,.T.,cRoteir,cTpCarga) //Everson 26/04/2019. Chamado 044314. Adicionado roteiro.

	oModal := FWDialogModal():New()        
	oModal:SetEscClose(.T.)
	oModal:setTitle("Lançamento de Ocorrência")
	oModal:setSubTitle("Selecione as notas fiscais de saída para víncular na ocorrência")
	oModal:setSize( 250 , 600 )
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")

	oContainer := TPanel():New( ,,, oModal:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	oBrwTrb := MsSelect():New("ADLG0403","OK","",aCpoBro,@lInverte,@cMark,{001,000,180,600}, , , oContainer )
	//oBrwTrb:bMark := {| | mrkBrw(@oBrwTrb)} //Everson, 21/07/2020. Chamado 
	Eval(oBrwTrb:oBrowse:bGoTop)

	oModal:Activate()

	//
	ADLG0403->(DbGoTop())
	While ! ADLG0403->(Eof())

		If ! Empty(Alltrim(cValToChar(ADLG0403->OK)))
			cNfs += Alltrim(cValToChar(ADLG0403->ZFD_SERIE)) + Alltrim(cValToChar(ADLG0403->ZFD_NUMNF)) + "-"

		EndIf

		ADLG0403->(DbSkip())

	End

	//
	If ! Empty(cNfs)
		cNfs := Substr(cNfs,1,Len(cNfs)-1)

	EndIf

	//
	ADLG0403->(DbCloseArea())

	FWFldPut("ZFA_NFSAID",cNfs)

	oView:Refresh()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} mrkBrw
	Controla a marcação dos registros selecionados na interface da função ADLG0405. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 15/03/2019
	@version 01
	/*/
// Static Function mrkBrw(oBrwTrb,cMark)

// 	RecLock("ADLG0403",.F.) 
// 	If ! Marked("OK")      
// 		ADLG0403->OK := cMark
// 	Else      
// 		ADLG0403->OK := ""
// 	Endif                             
// 	ADLG0403->(MsUnlock()) 
// 	oBrwTrb:oBrowse:Refresh() 

// Return Nil
/*/{Protheus.doc} ADLG0402
	Carrega objeto MsNewGetDados com as informações de notas fiscais
	vinculadas ao roteiro. Chamado 044314.
	@type  Static Function ADLG0402
	@author Ricardo Lima
	@since 11/02/2019
	@version 01
	/*/
Static Function ADLG0402( cCarga, lMarca, cRoteiro,cTpCarga) //Everson 26/04/2019. Chamado 044314. Adicionado roteiro.

	//Variáveis.
	Local aArea		:= GetArea()
	Local cArq		:= CriaTrab( NIL, .F.)
	Local cNameIdx	:= FileNoExt(cArq)
	Local cQuery	:= ""

	Default lMarca	:= .F.

	Private aCampos	:= {}

	//
	If lMarca
		Aadd( aCampos,{"OK", "C"   , 2 , 0 } )

	EndIf

	Aadd( aCampos,{"ZFD_SEQCAR"  , "C" , TamSX3("ZFD_SEQCAR")[1] , 0 } )
	Aadd( aCampos,{"ZFD_CAMINH"  , "C" , TamSX3("ZFD_CAMINH")[1] , 0 } )
	Aadd( aCampos,{"ZFD_PEDIDO"  , "C" , TamSX3("ZFD_PEDIDO")[1] , 0 } )
	Aadd( aCampos,{"ZFD_CLIENT"  , "C" , TamSX3("ZFD_CLIENT")[1] , 0 } )
	Aadd( aCampos,{"ZFD_LOJA"    , "C" , TamSX3("ZFD_LOJA")[1]   , 0 } )
	Aadd( aCampos,{"ZFD_NOMECL"  , "C" , TamSX3("ZFD_NOMECL")[1] , 0 } )
	Aadd( aCampos,{"ZFD_NUMNF"   , "C" , TamSX3("ZFD_NUMNF")[1]  , 0 } )
	Aadd( aCampos,{"ZFD_SERIE"   , "C" , TamSX3("ZFD_SERIE")[1]  , 0 } )

	//Everson-Ch:044314-21/03/2019
	Aadd( aCampos,{"ZFD_PBRUTO"  , "N" , TamSX3("C5_PBRUTO")[1]  , TamSX3("C5_PBRUTO")[2] } )
	Aadd( aCampos,{"ZFD_PESOL"   , "N" , TamSX3("C5_PESOL")[1]   , TamSX3("C5_PESOL")[2] } )
	Aadd( aCampos,{"ZFD_VOLUME"  , "N" , TamSX3("C5_VOLUME1")[1] , TamSX3("C5_VOLUME1")[2] } )
	Aadd( aCampos,{"ZFD_CIDADE"  , "C" , TamSX3("C5_CIDADE")[1]  , 0 } )
	//Aadd( aCampos,{"ZFD_LATITU"  , "C" , TamSX3("A1_XLATITU")[1] , TamSX3("A1_XLATITU")[2] } ) //Everson - 11/08/2020. Chamado 059326.
	//Aadd( aCampos,{"ZFD_LONGIT"  , "C" , TamSX3("A1_XLONGIT")[1] , TamSX3("A1_XLONGIT")[2] } ) //Everson - 11/08/2020. Chamado 059326.
	Aadd( aCampos,{"ZFD_CHAVE"   , "C" , TamSX3("F2_CHVNFE")[1]  , 0 } )

	//
	If ( SELECT("ADLG0403" ) !=  0 )
		dbSelectArea("ADLG0403")
		dbCloseArea()

	EndIf

	dbCreate( cArq, aCampos )
	dbUseArea( .T., , cArq, "ADLG0403", .F., .F.)
	DBCreateIndex(cNameIdx,'ZFD_SEQCAR')

	//Everson-Ch:044314-21/03/2019
	cQuery := " SELECT "
	cQuery += " ZFD_SEQCAR, ZFD_CAMINH, ZFD_PEDIDO, "
	cQuery += " ZFD_CLIENT, ZFD_LOJA, ZFD_NOMECL, ZFD_NUMNF, " 
	cQuery += " ZFD_SERIE, C5_CIDADE, C5_PBRUTO, C5_PESOL, "
	cQuery += " C5_VOLUME1, C5_TIPO, F2_CHVNFE, "
	cQuery += " C5_CLIENT, C5_LOJAENT " // @history ticket 76823 - Fernando Macieira - 21/07/2022 - Configuração visualização de cidade NF
	cQuery += " FROM " + RetSqlName("ZFD") + " AS ZFD "
	cQuery += " INNER JOIN " + RetSqlName("SC5") + " AS SC5 ON "
	cQuery += " ZFD_FILIAL = C5_FILIAL "
	cQuery += " AND ZFD_PEDIDO = C5_NUM "

	//Everson - 0810/2019 - Chamado 044314.
	cQuery += " LEFT OUTER JOIN "
	cQuery += " " + RetSqlName("SF2") + " (NOLOCK) AS SF2 ON " 
	cQuery += " C5_FILIAL = F2_FILIAL "
	cQuery += " AND C5_NOTA = F2_DOC "
	cQuery += " AND C5_SERIE = F2_SERIE "
	//

	cQuery += " WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' "
	cQuery += " AND ZFD_COD = '" + cCarga + "' "
	cQuery += " AND ZFD_VA = '" + cTpCarga + "' "
	cQuery += " AND ZFD.D_E_L_E_T_ = '' "
	cQuery += " AND SC5.D_E_L_E_T_ = '' "
	cQuery += " AND SF2.D_E_L_E_T_ = '' "
	cQuery += " AND ZFD_NUMNF <> '' ORDER BY ZFD_SEQCAR " //Everson 26/04/2019. Chamado 044314. Adicionado roteiro.

	//
	Conout( DToS(Date()) + " " + Time()  + " ADLOG040P - ADLG0402 - cQuery " + cQuery )

	//
	If Select("tADLG0403") > 0
		tADLG0403->(DbCloseArea())		
	EndIf
	TcQuery cQuery New Alias "tADLG0403"

	While tADLG0403->( !Eof() )

		dbSelectArea("ADLG0403")
		RecLock("ADLG0403", .T.)

		//
		// If lMarca
		// 	ADLG0403->OK := ""

		// EndIf

		ADLG0403->ZFD_SEQCAR := tADLG0403->ZFD_SEQCAR
		ADLG0403->ZFD_CAMINH := tADLG0403->ZFD_CAMINH
		ADLG0403->ZFD_PEDIDO := tADLG0403->ZFD_PEDIDO
		ADLG0403->ZFD_CLIENT := tADLG0403->ZFD_CLIENT
		ADLG0403->ZFD_LOJA   := tADLG0403->ZFD_LOJA
		ADLG0403->ZFD_NOMECL := tADLG0403->ZFD_NOMECL
		ADLG0403->ZFD_NUMNF  := tADLG0403->ZFD_NUMNF
		ADLG0403->ZFD_SERIE  := tADLG0403->ZFD_SERIE

		//Everson-Ch:044314-21/03/2019
		ADLG0403->ZFD_PBRUTO := tADLG0403->C5_PBRUTO
		ADLG0403->ZFD_PESOL  := tADLG0403->C5_PESOL 
		ADLG0403->ZFD_VOLUME := tADLG0403->C5_VOLUME1
		
		//
		If Alltrim(tADLG0403->C5_TIPO) = "B" //Everson - 09/08/2019. Chamado 044314.
			ADLG0403->ZFD_CIDADE := Posicione("SA2",1, FWxFilial("SA2") + Alltrim(tADLG0403->ZFD_CLIENT) + Alltrim(tADLG0403->ZFD_LOJA) ,"A2_MUN")
			
			//Everson - 11/08/2020. Chamado 059326.
			//ADLG0403->ZFD_LATITU := ""
			//ADLG0403->ZFD_LONGIT := ""
		
		Else
			//ADLG0403->ZFD_CIDADE := Posicione("SA1",1, FWxFilial("SA1") + Alltrim(tADLG0403->ZFD_CLIENT) + Alltrim(tADLG0403->ZFD_LOJA) ,"A1_MUN") // @history ticket 76823 - Fernando Macieira - 21/07/2022 - Configuração visualização de cidade NF
			ADLG0403->ZFD_CIDADE := Posicione("SA1",1, FWxFilial("SA1") + Alltrim(tADLG0403->C5_CLIENT) + Alltrim(tADLG0403->C5_LOJAENT) ,"A1_MUNE") // @history ticket 76823 - Fernando Macieira - 21/07/2022 - Configuração visualização de cidade NF
			
			//Everson - 11/08/2020. Chamado 059326.
			//ADLG0403->ZFD_LATITU := Posicione("SA1",1, FWxFilial("SA1") + Alltrim(tADLG0403->ZFD_CLIENT) + Alltrim(tADLG0403->ZFD_LOJA) ,"A1_XLATITU")
			//ADLG0403->ZFD_LONGIT := Posicione("SA1",1, FWxFilial("SA1") + Alltrim(tADLG0403->ZFD_CLIENT) + Alltrim(tADLG0403->ZFD_LOJA) ,"A1_XLONGIT")		
		
		EndIf

		//Everson - 0810/2019 - Chamado 044314.
		ADLG0403->ZFD_CHAVE := tADLG0403->F2_CHVNFE

		MSUnLock()
		dbSelectArea("tADLG0403")

		tADLG0403->( DbSkip() )	

	End

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADLG40E
	Exibe informações relativas a descontos financeiros realizados de fornecedores. Chamado 044314.
	@type  Function
	@author Everon
	@since 23/04/2019
	@version 01
	/*/
User Function ADLG40E()

//Variáveis.
	Local aArea		:= GetArea()
	Local oModal	:= Nil
	Local oSay		:= Nil
	Local oFont 	:= TFont():New(,,-16,.T.)	
	Local aPastas	:= {}
	Local oPastas	:= Nil
	Local oPnlBtn2	:= Nil
	Local oPnlBtn1	:= Nil
	Local oDadosD2	:= Nil
	Local oDadosD	:= Nil
	Local oGroup2	:= Nil
	Local oAtual	:= Nil
	Local oFechar	:= Nil	
	Local cDescTran	:= ""
	//Local dDtaIni	:= Date()
	//Local dDtFim	:= Date()
	Local aHDoD		:= {}
	Local aHDoD2	:= {}
	Local aColsD2	:= {}
	Local aColsD	:= {}
	Local aCmpAltD2	:= {}
	Local aCmpAltD	:= {}
	Local bCarga	:= {|| MsAguarde({|| scpSE5(oDadosD,aHDoD,oDadosD2,aHDoD2) } ,"Aguarde","Carregando dados...") }
	Local cDir		:= ""

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza manutenção em movimento de frete gerado.')

	//
	If ! Pergunte("ADLOG401",.T.)
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cDescTran := Alltrim(cValToChar(MV_PAR01)) + "/" + Alltrim(cValToChar(MV_PAR02)) + "-" + Posicione("SA2",1, FWxFilial("SA2") + Alltrim(cValToChar(MV_PAR01)) + Alltrim(cValToChar(MV_PAR02)), "A2_NOME"  )

	//
	Aadd(aHDoD,{"Filial"      ,"E5_FILIAL"  ,"" ,TamSX3("E5_FILIAL")[1] ,0,"","","C","",""})
	Aadd(aHDoD,{"Data"        ,"E5_DATA"    ,"" ,TamSX3("E5_DATA")[1]   ,0,"","","D","",""})
	Aadd(aHDoD,{"Emissão"     ,"E2_EMISSAO" ,"" ,TamSX3("E2_EMISSAO")[1]   ,0,"","","D","",""}) //Everson-Ch:052666-18/10/2019.
	Aadd(aHDoD,{"Vencimento"  ,"E2_VENCREA" ,"" ,TamSX3("E2_VENCREA")[1]   ,0,"","","D","",""}) //Everson-Ch:052666-18/10/2019.
	Aadd(aHDoD,{"Baixa"  	  ,"E2_BAIXA"   ,"" ,TamSX3("E2_BAIXA")[1]   ,0,"","","D","",""})   //Everson-Ch:052666-18/10/2019.
	Aadd(aHDoD,{"Tipo"        ,"E5_TIPO"    ,"" ,TamSX3("E5_TIPO")[1]   ,0,"","","C","",""})
	Aadd(aHDoD,{"Prefixo"     ,"E5_PREFIXO" ,"" ,TamSX3("E5_PREFIXO")[1],0,"","","C","",""})
	Aadd(aHDoD,{"Número"      ,"E5_NUMERO"  ,"" ,TamSX3("E5_NUMERO")[1] ,0,"","","C","",""})
	Aadd(aHDoD,{"Valor"       ,"E2_VALOR"   ,X3Picture('E2_VALOR')  ,TamSX3("E2_VALOR")[1] ,TamSX3("E2_VALOR")[2],"","","N","",""})
	Aadd(aHDoD,{"Vlr Líquido" ,"E5_VALOR"   ,X3Picture('E5_VALOR')  ,TamSX3("E5_VALOR")[1] ,TamSX3("E5_VALOR")[2],"","","N","",""})	
	Aadd(aHDoD,{"Mot. Baixa"  ,"E5_MOTBX"   ,"" ,TamSX3("E5_MOTBX")[1] ,0,"","","C","",""})
	Aadd(aHDoD,{"Histórico"   ,"E2_HIST"    ,"" ,TamSX3("E2_HIST")[1] ,0,"","","C","",""})
	Aadd(aHDoD,{"Doc original","E5_DOCUMEN" ,"" ,TamSX3("E5_DOCUMEN")[1] ,0,"","","C","",""})

	//
	Aadd(aHDoD2,{"Id"          ,"E1_IDENTEE" ,"" ,TamSX3("E1_IDENTEE")[1],0,"","","C","",""})
	Aadd(aHDoD2,{"Filial"      ,"E1_FILIAL"  ,"" ,TamSX3("E1_FILIAL")[1] ,0,"","","C","",""})
	Aadd(aHDoD2,{"Data"        ,"E1_EMISSAO" ,"" ,TamSX3("E5_DATA")[1]   ,0,"","","D","",""})
	Aadd(aHDoD2,{"Tipo"        ,"E1_TIPO"    ,"" ,TamSX3("E1_TIPO")[1]   ,0,"","","C","",""})
	Aadd(aHDoD2,{"Prefixo"     ,"E1_PREFIXO" ,"" ,TamSX3("E1_PREFIXO")[1],0,"","","C","",""})
	Aadd(aHDoD2,{"Número"      ,"E1_NUM"     ,"" ,TamSX3("E1_NUM")[1]    ,0,"","","C","",""})
	Aadd(aHDoD2,{"Parcela"     ,"E1_PARCELA" ,"" ,TamSX3("E1_PARCELA")[1],0,"","","C","",""})
	Aadd(aHDoD2,{"Pedido"      ,"D2_PEDIDO"  ,"" ,TamSX3("D2_PEDIDO")[1] ,0,"","","C","",""})
	Aadd(aHDoD2,{"Produto"     ,"D2_COD"     ,"" ,TamSX3("D2_COD")[1]    ,0,"","","C","",""})
	Aadd(aHDoD2,{"Descrição"   ,"B1_DESC"    ,"" ,TamSX3("B1_DESC")[1]   ,0,"","","C","",""})
	Aadd(aHDoD2,{"UM"          ,"D2_UM"      ,"" ,TamSX3("D2_UM")[1]     ,0,"","","C","",""})
	Aadd(aHDoD2,{"Quantidade"  ,"D2_QUANT"   ,X3Picture('D2_QUANT')  ,TamSX3("D2_QUANT")[1] ,TamSX3("D2_QUANT")[2] ,"","","N","",""})
	Aadd(aHDoD2,{"Prc Vend"    ,"D2_PRCVEN"  ,X3Picture('D2_PRCVEN') ,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2],"","","N","",""})	
	Aadd(aHDoD2,{"Total"       ,"D2_TOTAL"   ,X3Picture('D2_TOTAL')  ,TamSX3("D2_TOTAL")[1] ,TamSX3("D2_TOTAL")[2] ,"","","N","",""})

	//
	oModal			 := MsDialog():Create()
	oModal:cName     := "oModal"
	oModal:cCaption  := "Conferência de Descontos"
	oModal:nLeft     := 34
	oModal:nTop      := 222
	oModal:nWidth    := 1200
	oModal:nHeight   := 610
	oModal:lShowHint := .F.
	oModal:lCentered := .T.

	//
	oSay:= TSay():New(007,005,{||'Transportadora: ' + cDescTran  },oModal,,oFont,,,,.T.,CLR_RED,CLR_WHITE,595,20)

	//
	aPastas := {"Movimentação","Faturamento"}
	oPastas := TFolder():New(015,005,aPastas,,oModal,,,,.T.,,590,253)

	//
	oPnlBtn1 := TPanel():New(000,000,"",oPastas:aDialogs[1],,.T.,,,,590,247)
	oPnlBtn1:Align := CONTROL_ALIGN_ALLCLIENT
	oDadosD := MsNewGetDados():New(000,000,230,588,,"Allwaystrue()","Allwaystrue()","",aCmpAltD,Nil,999,Nil,Nil,Nil,oPnlBtn1,aHDoD,@aColsD)

	oPnlBtn2 := TPanel():New(000,000,"",oPastas:aDialogs[2],,.T.,,,,590,247)
	oPnlBtn2:Align := CONTROL_ALIGN_ALLCLIENT
	oDadosD2 := MsNewGetDados():New(000,000,230,588,,"Allwaystrue()","Allwaystrue()","",aCmpAltD2,Nil,999,Nil,Nil,Nil,oPnlBtn2,aHDoD2,@aColsD2)

	//
	oGroup2	 := TGroup():Create(oModal,269,005,289,595,"",,,.T.)
	oAtual	 := TButton():New(274,010,"Atualizar"   ,oModal, bCarga ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson 08/05/2019. Chamado 044314.

	TButton():New(274,055,"CVS",oModal,{|| geraCSV(oDadosD,aHDoD,"Lanca_",@cDir), geraCSV(oDadosD2,aHDoD2,"Fatura_",@cDir) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oFechar	 := TButton():New(274,550,"Fechar",oModal,{||oModal:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")		

	oModal:Activate(,,,.T.,{||.T.},, Eval(bCarga) )

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} geraCSV
	Gera arquivo CSV a partir de objeto MsNewGetDados. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 08/05/2019
	@version 01
	/*/
Static Function geraCSV(oDadosD,aHDoD,cTexto,cDir)

//Variáveis.
	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cArq  	:= cTexto+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl		:= 0
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""

	//
	If Empty(cDir)
		cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	EndIf

	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil

	EndIf

	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)

	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
		    	MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grCSVS")
		Return Nil

	EndIf

	//
	cLin := ""
	For i := 1 To Len(aHDoD)
		cLin += cValToChar(aHDoD[i][1]) + ";"

	Next i

	cLin += cEof

	For i := 1 To Len(oDadosD:aCols)

		For w := 1 To Len(aHDoD)

			If Alltrim(cValToChar(aHDoD[w][8])) == "N"

				cLin += Transform(Val(cValToChar(oDadosD:aCols[i][w])),"@E 999,999,999.99") + ";"

			Else
				cLin += cValToChar(oDadosD:aCols[i][w]) + ";"

			EndIf

		Next w

		cLin += cEof

		FWrite(nHdl,cLin,Len(cLin))

		cLin := ""

	Next i

	//Fecha o arquivo.
	FClose(nHdl)

	//
	If cTexto = "Fatura_"

		WinExec("Explorer.exe" + Space(1) + cDir )

		MsgInfo("Arquivos gerados.","Função grCSVS(ADLOG040P)")

	EndIf

	RestArea(aArea)

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scpSE5
	Script sql para consulta de descontos de transportadora. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 23/04/2019
	@version 01
	/*/
Static Function scpSE5(oDadosD,aHDoD,oDadosD2,aHDoD2)

//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cId		:= ""
	Local cQuery2	:= ""
	Local cCodCli	:= ""
	Local cLojCli	:= ""
	Local cCNPJ		:= ""
	Local nPago   	:= 0
	Local nCotac  	:= 0

	//
	cQuery := ""
	cQuery += " SELECT SUBSTRING(E5_DOCUMEN,1,15) AS DOC_ORIGEM, " 
	cQuery += " E5_FILIAL AS FILIAL, E5_DATA AS 'DATA', E5_TIPO AS 'TIPO', E5_PREFIXO AS 'PREFIXO', E5_NUMERO AS 'NUMERO', E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, " 
	cQuery += " E5_FORNECE AS 'COD_FOR', E5_LOJA AS 'LOJA', E5_BENEF AS 'NOME', ISNULL(E2_VALOR,0) AS 'VALOR', E5_VALOR AS 'VLR_LIQ', E5_VLMOED2, E5_TIPO, " 
	cQuery += " ISNULL(CASE WHEN E5_IDENTEE <> '' AND E5_MOTBX = 'CEC' " 
	cQuery += " THEN  " 
	cQuery += " 'FATURAMENTO C/ TRANSPORTADOR ID ' + RTRIM(LTRIM(E5_IDENTEE)) " 
	cQuery += " ELSE  " 
	cQuery += " E2_HIST " 
	cQuery += " END,'') AS 'HIST', E5_IDENTEE, E5_MOTBX, SE2.R_E_C_N_O_  AS RECSE2, SE5.R_E_C_N_O_  AS RECSE5, E5_DOCUMEN, E2_VENCREA, E2_EMISSAO, E2_BAIXA " //Everson-Ch:052666-18/10/2019.

	cQuery += " FROM "+RetSqlName("SE2")+" SE2,"
	cQuery +=         RetSqlName("SE5")+" SE5 "
	cQuery += " WHERE "
	cQuery +=       "SE2.E2_FORNECE='" + cValToChar(MV_PAR01) + "' AND "
	cQuery +=       "SE2.E2_LOJA='" + cValToChar(MV_PAR02) + "' AND "
	cQuery +=       "SE2.E2_EMISSAO>='" + DToS(MV_PAR03) + "' AND "
	cQuery +=       "SE2.E2_EMISSAO<='" + DToS(MV_PAR04) + "' AND "
	cQuery +=       "SE2.E2_VENCREA>='" + DToS(MV_PAR05) + "' AND "
	cQuery +=       "SE2.E2_VENCREA<='" + DToS(MV_PAR06) + "' AND "                  
	cQuery += "SE2.E2_TIPO NOT IN " + FormatIn(MVABATIM,";") +" AND "
	cQuery += "SE2.E2_TIPO NOT IN " + FormatIn(MVPAGANT+";"+MVRECANT+";"+MV_CRNEG+";"+MV_CPNEG,";")+" AND "
	cQuery += "SE2.E2_VALOR != SE2.E2_SALDO AND "
	cQuery += "SE2.D_E_L_E_T_=' ' AND "
	cQuery += "SE5.E5_PREFIXO=SE2.E2_PREFIXO AND "
	cQuery += "SE5.E5_NUMERO=SE2.E2_NUM AND "
	cQuery += "SE5.E5_PARCELA=SE2.E2_PARCELA AND "
	cQuery += "SE5.E5_TIPO=SE2.E2_TIPO AND "
	cQuery += "SE5.E5_CLIFOR=SE2.E2_FORNECE AND "
	cQuery += "SE5.E5_LOJA=SE2.E2_LOJA AND "
	cQuery += "SE5.E5_RECPAG='P' AND "
	cQuery += "SE5.E5_SITUACA!='C' AND "
	cQuery += "SE5.E5_TIPODOC IN ('BA','VL','CP') AND "	
	cQuery += "SE5.D_E_L_E_T_=' ' AND NOT EXISTS ("
	cQuery += "SELECT A.E5_NUMERO "
	cQuery += "FROM " + RetSqlName("SE5") + " A "
	cQuery += "WHERE "
	cQuery += "A.E5_PREFIXO=SE5.E5_PREFIXO AND "
	cQuery += "A.E5_NUMERO=SE5.E5_NUMERO AND "
	cQuery += "A.E5_PARCELA=SE5.E5_PARCELA AND "
	cQuery += "A.E5_TIPO=SE5.E5_TIPO AND "
	cQuery += "A.E5_CLIFOR=SE5.E5_CLIFOR AND "
	cQuery += "A.E5_LOJA=SE5.E5_LOJA AND "
	cQuery += "A.E5_SEQ=SE5.E5_SEQ AND "
	cQuery += "A.E5_TIPODOC='ES' AND "
	cQuery += "A.E5_RECPAG!='P' AND "
	cQuery += "A.E5_DATA<='" + DtoS(dDataBase) + "' AND "
	cQuery += "A.D_E_L_E_T_=' ')"	
	DbSelectArea("SE2")	
	cOrder := SqlOrder(IndexKey())
	cQuery += " ORDER BY " + cOrder	
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - scpSE5 - cQuery " + cValToChar(cQuery) )

	//
	If Select("D_SE5") > 0
		D_SE5->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_SE5"
	DbSelectArea("D_SE5")
	D_SE5->(DbGoTop())
	If D_SE5->(Eof())
		D_SE5->(DbCloseArea())
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cCNPJ :=  Posicione("SA2",1, FWxFilial("SA2") +  Alltrim(cValToChar(D_SE5->COD_FOR)) + Alltrim(cValToChar(D_SE5->LOJA)) ,"A2_CGC" )

	//
	DbSelectArea("SE5")
	SE5->(DbSetOrder(7))	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ

	//
	oDadosD:aCols := {}
	While ! D_SE5->(Eof())

		//
		If SE5->(dbSeek(xFilial("SE5") + D_SE5->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
			If AllTrim(SE5->E5_TIPODOC) == "BA" .AND. AllTrim(SE5->E5_MOTBX) == "DSD"
				D_SE5->(dbSkip())
				Loop
			Endif
		Endif	

		//
		nPago   := 0
		nCotac  := 0

		//
		If D_SE5->E5_TIPO $ MV_CPNEG
			nPago -= D_SE5->E5_VLMOED2

		Else
			nPago += D_SE5->E5_VLMOED2

		EndIf

		nCotac++ 

		//
		If nPago != 0 .Or. nCotac <> 0 

			Aadd(oDadosD:aCols , Array(Len(aHDoD) + 1) )
			oDadosD:aCols[Len(oDadosD:aCols), Len(oDadosD:aCols[1]) ] := .F.	
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E5_FILIAL"})] 	:= D_SE5->FILIAL
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E5_DATA"})]  	:= SToD(D_SE5->DATA)
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E2_EMISSAO"})]  := SToD(D_SE5->E2_EMISSAO) //Everson-Ch:052666-18/10/2019.
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E2_VENCREA"})]  := SToD(D_SE5->E2_VENCREA) //Everson-Ch:052666-18/10/2019.
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E2_BAIXA"})]  	:= SToD(D_SE5->E2_BAIXA) //Everson-Ch:052666-18/10/2019.
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E5_TIPO"})] 	:= D_SE5->TIPO
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E5_PREFIXO"})] 	:= D_SE5->PREFIXO
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E5_NUMERO"})] 	:= D_SE5->NUMERO
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E2_VALOR"})] 	:= Val(cValToChar(D_SE5->VALOR))
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E5_VALOR"})] 	:= Val(cValToChar(D_SE5->VLR_LIQ))
			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E5_MOTBX"})] 	:= D_SE5->E5_MOTBX

			//Everson-Ch:044314-12/06/2019.
			If ! Empty(D_SE5->HIST) .And. D_SE5->E5_MOTBX == "CEC"
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E2_HIST"})] := D_SE5->HIST

			Else 

				//
				Conout( DToC(Date()) + " " + Time() + " ADLOG040P - scpSE5 - DOC_ORIGEM " + Alltrim(cValToChar(D_SE5->DOC_ORIGEM)) )
				Conout( DToC(Date()) + " " + Time() + " ADLOG040P - scpSE5 - DbSeek " + Alltrim(cValToChar(D_SE5->FILIAL)) + Alltrim(cValToChar(D_SE5->DOC_ORIGEM)) + Alltrim(cValToChar(D_SE5->E2_TIPO)) + Alltrim(cValToChar(MV_PAR01)) + Alltrim(cValToChar(MV_PAR02)) )
				oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E2_HIST"})] := carrHist(Alltrim(cValToChar(D_SE5->FILIAL)) + Alltrim(cValToChar(D_SE5->DOC_ORIGEM)) + Alltrim(cValToChar(MV_PAR01)) + Alltrim(cValToChar(MV_PAR02)))

			EndIf

			oDadosD:aCols[Len(oDadosD:aCols),Ascan(aHDoD,{|x| AllTrim(x[2]) == "E5_DOCUMEN"})] 	:= D_SE5->E5_DOCUMEN

			//
			If Alltrim(cValToChar(D_SE5->E5_MOTBX)) == "CEC" .And. !Empty(Alltrim(cValToChar(D_SE5->E5_IDENTEE)))
				cId += "'" +  Alltrim(cValToChar(D_SE5->E5_IDENTEE)) + "',"

			EndIf

		EndIf

		D_SE5->(DbSkip())

	End

	//
	D_SE5->(DbCloseArea())

	//
	If ! Empty(cId)

		//
		cId 	:= Substr(cId,1,Len(cId)-1)
		cCodCli	:= Posicione("SA1",3, FWxFilial("SA1") + cCNPJ ,"A1_COD" )
		cLojCli	:= Posicione("SA1",3, FWxFilial("SA1") + cCNPJ ,"A1_LOJA" )

		//
		cQuery2 += " SELECT " 
		cQuery2 += " E1_IDENTEE AS ID,  " 
		cQuery2 += " E1_FILIAL AS FILIAL,  " 
		cQuery2 += " E1_EMISSAO AS EMISSAO,  " 
		cQuery2 += " E1_TIPO AS TIPO,  " 
		cQuery2 += " E1_PREFIXO AS SERIE,  " 
		cQuery2 += " E1_NUM AS DOC,  " 
		cQuery2 += " E1_PARCELA AS PARCELA,  " 
		cQuery2 += " D2_PEDIDO AS PEDIDO,  " 
		cQuery2 += " D2_COD AS PRODUTO,  " 
		cQuery2 += " B1_DESC AS DESCRICAO,  " 
		cQuery2 += " D2_UM AS UM,  " 
		cQuery2 += " D2_QUANT AS QUANT,  " 
		cQuery2 += " D2_PRCVEN AS PRECO,  " 
		cQuery2 += " D2_TOTAL AS TOTAL " 
		cQuery2 += " FROM " 
		cQuery2 += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1 " 
		cQuery2 += " INNER JOIN " 
		cQuery2 += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 " 
		cQuery2 += " ON E1_FILIAL = D2_FILIAL " 
		cQuery2 += " AND E1_SERIE = D2_SERIE " 
		cQuery2 += " AND E1_NUM = D2_DOC " 
		cQuery2 += " AND E1_CLIENTE = D2_CLIENTE " 
		cQuery2 += " AND E1_LOJA = D2_LOJA " 
		cQuery2 += " INNER JOIN " 
		cQuery2 += " " + RetSqlName("SB1") + " AS SB1 " 
		cQuery2 += " ON D2_COD = B1_COD " 
		cQuery2 += " WHERE " 
		cQuery2 += " E1_FILIAL = '" + FWxFilial("SE1") + "' " 
		cQuery2 += " AND E1_CLIENTE = '" + cCodCli + "' " 
		cQuery2 += " AND E1_LOJA = '" + cLojCli + "' " 
		cQuery2 += " AND SE1.D_E_L_E_T_ = '' " 
		cQuery2 += " AND SD2.D_E_L_E_T_ = '' " 
		cQuery2 += " AND SB1.D_E_L_E_T_ = '' " 
		cQuery2 += " AND E1_IDENTEE IN (" + cId + ") ORDER BY E1_IDENTEE, E1_NUM " 

		//
		If Select("D_SE1") > 0
			D_SE1->(DbCloseArea())

		EndIf

		//
		TcQuery cQuery2 new Alias "D_SE1"
		DbSelectArea("D_SE1")
		D_SE1->(DbGoTop())
		If ! D_SE1->(Eof())

			//
			oDadosD2:aCols := {}

			//
			While ! D_SE1->(Eof())

				Aadd(oDadosD2:aCols , Array(Len(aHDoD2) + 1) )
				oDadosD2:aCols[Len(oDadosD2:aCols), Len(oDadosD2:aCols[1]) ] := .F.	
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "E1_IDENTEE"})] 	:= D_SE1->ID
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "E1_FILIAL"})]  	:= D_SE1->FILIAL
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "E1_EMISSAO"})] 	:= SToD(D_SE1->EMISSAO)
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "E1_TIPO"})] 		:= D_SE1->TIPO
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "E1_PREFIXO"})] 	:= D_SE1->SERIE
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "E1_PARCELA"})] 	:= D_SE1->DOC
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "D2_PEDIDO"})] 	:= D_SE1->PEDIDO
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "D2_COD"})] 		:= D_SE1->PRODUTO	

				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "B1_DESC"})] 		:= D_SE1->DESCRICAO	
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "D2_UM"})] 		:= D_SE1->UM	
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= Val(cValToChar(D_SE1->QUANT))
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "D2_PRCVEN"})] 	:= Val(cValToChar(D_SE1->PRECO))
				oDadosD2:aCols[Len(oDadosD2:aCols),Ascan(aHDoD2,{|x| AllTrim(x[2]) == "D2_TOTAL"})] 	:= Val(cValToChar(D_SE1->TOTAL))		

				D_SE1->(DbSkip())

			End

		EndIf
		D_SE1->(DbCloseArea())

	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} nomeStaticFunction
	Carrega histórico do registro (SE2). Chamado 044314.
	@type  Static Function
	@author Everson
	@since 23/04/2019
	@version 01
	/*/
Static Function carrHist(cString)

//Variáveis.	
	Local aArea		:= GetArea()
	Local cHist		:= ""
	Local cQuery	:= ""
	Conout(cString)
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " E2_HIST " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SE2") + " (NOLOCK) AS SE2 " 
	cQuery += " WHERE " 
	cQuery += " RTRIM(LTRIM(E2_FILIAL)) + RTRIM(LTRIM(E2_PREFIXO)) + RTRIM(LTRIM(E2_NUM)) + RTRIM(LTRIM(E2_PARCELA)) +  RTRIM(LTRIM(E2_FORNECE)) + RTRIM(LTRIM(E2_LOJA)) = '" + cString + "' " 
	cQuery += " AND SE2.D_E_L_E_T_ = '' " 

	//
	If Select("D_HIST") > 0
		D_HIST->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_HIST"
	DbSelectArea("D_HIST")
	cHist := Alltrim(cValToChar(D_HIST->E2_HIST))
	D_HIST->(DbCloseArea())

	//
	RestArea(aArea)

Return cHist
/*/{Protheus.doc} ADLG40J
	Função para atualizar tabela de combustível em massa.
	@type  Static Function
	@author Everson
	@since 29/01/2021
	@version 01
	/*/
User Function ADLG40J()

	//Variáveis.
	Local aArea			:= GetArea()
	Local cArq			:= ""
	Local nHdl			:= 0
	Local nTotLinhas	:= 0
	Local cPlaca		:= ""
	Local cTab 			:= ""
	Local aInfo			:= {}
	Local lErro			:= .F.
	Local aDados		:= {}
	Local nAux			:= 0
	Local cBuffer		:= ""
	Local i				:= 1	

	U_ADINF009P('ADLOG040P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),"Atualiza cadastro do veículo com tabela de preço de combustível.")

	//
	cArq := cGetFile('Arquivo CSV|*.*|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

	//Valida arquivo.  
	If Empty(cArq)
		RestArea(aArea)
		Return Nil

	Endif

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLG40J - cArq " + cArq )

	//Abre o arquivo.
	nHdl := FT_FUse(cArq)

	//Valida abertura do arquivo.
	If nHdl == -1
		Help(Nil, Nil, "Função ADLG40J(ADLOG040P) Função ADLG40J(ADLOG040P)", Nil,"Não foi possível abrir o arquivo " + Chr(13) + Chr(13) + cArq, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		RestArea(aArea)
		Return Nil

	Endif

	//
	FT_FGoTop()

	//Obtém a quantidade de linhas.
	nTotLinhas := FT_FLastRec()

	//Atribui o tamanho da régua.
	ProcRegua(nTotLinhas)

	FT_FGoTop()

	//
	DbSelectArea("ZV4")
	ZV4->(DbSetOrder(1))
	ZV4->(DbGoTop())

	//
	DbSelectArea("ZB9")
	ZB9->(DbSetOrder(1))
	ZB9->(DbGoTop())

	//Percorre arquivo.
	While ! FT_FEof()

		//
		IncProc()

		//
		nAux++

		//
		cBuffer  := Alltrim(cValToChar(FT_FReadln()))

		//Buffer vazio.
		If Empty(cBuffer)
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLG40J - cBuffer vazio . Linha " + cValToChar(nAux) )
			FT_FSkip()
			Loop

		EndIf

		//Cabeçalho.
		If nAux == 1
			FT_FSkip()
			Loop

		EndIf		

		//
		aInfo := Separa(cBuffer,';',.T.)
		
		//Valida quantidade de campos do arquivo.
		If Len(aInfo) <> 2
			Conout( DToC(Date()) + " " + Time() + " ADLOG040P - ADLG40J - Len(aInfo) " + cValToChar(Len(aInfo)) )
			Help(Nil, Nil, "Função ADLG40J(ADLOG040P)", Nil,"Quantidade de campos inválida. Linha " + cValToChar(nAux) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lErro := .T.
			Exit

		EndIf		

		//
		cPlaca	:= Alltrim(cValToChar(aInfo[1]))
		cTab 	:= Alltrim(cValToChar(aInfo[2]))

		//Valida placa.
		ZV4->(DbGoTop())
		If ! ZV4->(DbSeek( FWxFilial("ZV4") + cPlaca ))
			Help(Nil, Nil, "Função ADLG40J(ADLOG040P)", Nil,"Função ADLG40J(ADLOG040P) Placa " + cPlaca + " não encontrada. Linha " + cValToChar(nAux) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lErro := .T.
			Exit

		EndIf

		//Valida tabela.
		ZB9->(DbGoTop())
		If ! ZB9->(DbSeek( FWxFilial("ZB9") + cTab ))
			Help(Nil, Nil, "Função ADLG40J(ADLOG040P)", Nil,"Função ADLG40J(ADLOG040P) Tabela " + cTab + " não encontrada. Linha " + cValToChar(nAux) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lErro := .T.
			Exit

		EndIf

		//
		Aadd(aDados,{cPlaca,cTab})

		FT_FSkip()

	EndDo

	//
	If ! lErro .And. Len(aDados) > 0

		//
		If ! MsgYesNo("Serão atualizados " + cValToChar(Len(aDados)) + " registros. Deseja prosseguir?","Função cTab(ADLOG040P)")
			RestArea(aArea)
			Return Nil

		EndIf
		
		//
		Begin Transaction

			//
			For i := 1 To Len(aDados)

				//
				If ZV4->(DbSeek( FWxFilial("ZV4") + aDados[i][1] ))

					//
					RecLock("ZV4",.F.)
						ZV4->ZV4_OLS10	:= aDados[i][2]
						ZV4->ZV4_OLS500 := aDados[i][2]
					ZV4->(MsUnlock())

					//
					logZBE("Alteração tabela abastecimento placa/tabela: " + aDados[i][1] + "/" + aDados[i][2])

				Else
					Help(Nil, Nil, "Função ADLG40J(ADLOG040P)", Nil,"Função ADLG40J(ADLOG040P) Placa " + cPlaca + " não encontrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
					DisarmTransaction()
					Exit

				EndIf

			Next i

		End Transaction

		//
		MsgInfo("Processo finalizado.","Função ADLG40J(ADLOG040P)")

	EndIf

	//
	If nHdl <> -1
		FT_FUse(cArq)

	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} logZBE 
	Gera log na tabela ZBE. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 06/12/2019
	@version 01
	/*/
Static Function logZBE(cMensagem)

	//Variáveis.	
	Local aArea	:= GetArea()

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With dDataBase
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "LOGISTICA"
		Replace ZBE_ROTINA	    With "ADLOG040P" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function SendADI
    Envia email para transportadora da previsão dos 60% dos adiantamentos
    @type  Static Function
    @author Fernando Macieira
    @since 09/06/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 14223 - E-mail automático adiantamento de frete
/*/
Static Function SendADI()

    Local cQuery    := ""
    Local cDir	    := "\cte_log\"
    Local cEmailC   := Alltrim(GetMv("MV_#CELFFT"))
	Local cFornece	:= ""
	Local cLoja		:= ""
	Local cNmForc	:= ""
	Local cEmail	:= ""
	Local cAssunto	:= ""
	Local cHtml  	:= ""
	//Local cPlaca	:= ""
	Local cArq		:= ""
	Local cMensagem	:= ""
    Local nTotal    := 0
    
	If !Pergunte("ADLOG060R",.T.)
		Return
	EndIf

    If Select("Work") > 0
        Work->(dbCloseArea() )
    EndIf

    cQuery := " SELECT  DISTINCT   ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA, SUM(ZFK_VALOR) AS ZFK_VALOR
    cQuery += " FROM " + RetSqlName("ZFK") + " (NOLOCK)
	cQuery += " WHERE ZFK_FILIAL      = '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_DTENTR >= '" + DToS(MV_PAR01)		+ "' " 
	cQuery += " AND ZFK_DTENTR <= '" + DToS(MV_PAR02)   	+ "' " 
	cQuery += " AND ZFK_TRANSP >= '" + Alltrim(MV_PAR03)	+ "' " 
	cQuery += " AND ZFK_TRANSP <= '" + Alltrim(MV_PAR04)	+ "' " 
	/*cQuery += " AND ZFK_LOJA   >= '" + Alltrim(MV_PAR05)	+ "' " 
	cQuery += " AND ZFK_LOJA   <= '" + Alltrim(MV_PAR06)	+ "' " 
	cQuery += " AND ZFK_PLACA  >= '" + Alltrim(MV_PAR07)	+ "' " 
	cQuery += " AND ZFK_PLACA  <= '" + Alltrim(MV_PAR08)	+ "' " 
	cQuery += " AND ZFK_ROTEIR >= '" + Alltrim(MV_PAR09)	+ "' " 
	cQuery += " AND ZFK_ROTEIR <= '" + Alltrim(MV_PAR10)	+ "' " */
	cQuery += " AND D_E_L_E_T_ = '' " 
    cQuery += " and ZFK_TPDOC='1'
    cQuery += " and ZFK_STATUS='1'
    cQuery += " GROUP BY ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA
    cQuery += " ORDER BY ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA

    tcQuery cQuery New Alias "Work"

    Work->( dbGoTop() )
    If Work->( EOF() )
		Work->( dbCloseArea() )
		MsgStop("Não há dados a serem enviados.","Função ADLOG040R-SendADI")
		Return
	EndIf

    Work->( dbGoTop() )
    Do While Work->( !EOF() )

		cFornece := Alltrim(cValToChar(Work->ZFK_TRANSP))
		cLoja	 := Alltrim(cValToChar(Work->ZFK_LOJA))
		cNmForc	 := Alltrim(cValToChar( Posicione("SA2",1, FWxFilial("SA2") + cFornece + cLoja ,"A2_NOME") ))
		
        If MV_PAR05 == 1
			cEmail := cEmailC
		Else
            cEmail   := Alltrim(cValToChar( Posicione("SA4",1, FWxFilial("SA4") + cFornece  ,"A4_EMAIL") ))
        EndIf
		
		cArq := "FchADI_"+cFornece+cLoja+"_"+DToS(MV_PAR01)+"_"+DToS(MV_PAR02)+".html"
		cAssunto := "[ Adiantamento de 60% dos fretes ] - de " + DToC(MV_PAR01) + " até " + DToC(MV_PAR02) + " " + cFornece + "/" + cLoja + "-" + cNmForc + "."
		
		cMensagem := "<html>"
		cMensagem += "<body>"
		cMensagem += "<div style='text-align: left;'> "
			cMensagem += "<p>Olá, " + cFornece + "/" + cLoja + "-" + cNmForc + ".</p>"
			cMensagem += "<p>Segue adiantamento de 60% dos fretes entre " + DToC(MV_PAR01) + " e " + DToC(MV_PAR02) + ".</p>"
            //cMensagem += "<p>Previsão de pagamento: entre dias 25 e 28.</p>"
		cMensagem += "</div> "
		
		cMensagem += "<div style='text-align: left;'> "
			cMensagem += "<span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Sistema de Frete - Ad&#39;oro - e-mail enviado automaticamente. Por favor, não responda.</span></span>" 
		cMensagem += "</div> "
		cMensagem += "</body>"
		cMensagem += "</html>"
		
		cHtml := ''
		cHtml += ' <!DOCTYPE html> '
		cHtml += ' <html> '
		cHtml += ' <head> '
		cHtml += ' <style> '
		
		cHtml += ' table{ border-collapse: collapse; width: 100%; } '
		cHtml += ' td{ text-align: left; font-size: 12px; padding: 5px; border: 1px solid #dddddd; } '
		cHtml += ' th{ font-size: 12px; padding: 5px; border: 1px solid #dddddd; } '
		cHtml += ' tr:nth-child(even){background-color: #f2f2f2;} '		
		cHtml += ' @media print{ tr:nth-child(even) td{background-color: #f2f2f2 !important; -webkit-print-color-adjust: exact; } '		
		cHtml += ' </style> '
		cHtml += ' </head> '
		cHtml += ' <body> '

        cHtml += ' <div style="display:table;">
        
        cHtml += ' <div style="border: 1px solid #dddddd; padding: 5px">
            cHtml += ' <h5 class="pageHeader">Adiantamento 60% </h5> '
            cHtml += ' <h5>Período de: ' +  DToC(MV_PAR01) + ' Até: ' +  DToC(MV_PAR02) + '</h5> '
            cHtml += ' <h5>Transp.: ' + cFornece + ' ' + cLoja + ' ' + cNmForc + '</h5> '
        cHtml += ' </div>

        cHtml += ' <table> '
        cHtml += ' <thead> '
        cHtml += ' <th>NOME</th> '
        cHtml += ' <th>PLACA</th> '
        cHtml += ' <th>VALOR</th> '
        cHtml += ' </thead> '
        cHtml += ' <tbody> '

		Do While Work->( !EOF() ) .And. cFornece == Alltrim(cValToChar(Work->ZFK_TRANSP)) .and. cLoja == Alltrim(cValToChar(Work->ZFK_LOJA))
			
            cHtml += ' <tr> '
            cHtml += ' <td> ' + cNmForc + ' </td> '
			cHtml += ' <td> ' + AllTrim(Work->ZFK_PLACA) + ' </td> '
			cHtml += ' <td> ' + Alltrim( Transform(Work->ZFK_VALOR ,"@E 999,999,999.99")) + ' </td> '
					
			cHtml += ' </tr> '

            nTotal += Work->ZFK_VALOR
				
			Work->( dbSkip() )
			
		EndDo
			
		cHtml += ' </tr> '

        cHtml += ' <tr style="font-weight: bold;"> '
            cHtml += ' <td>TOTAL GERAL</td> '
            cHtml += ' <td></td> '
            cHtml += ' <td> ' + Transform(nTotal ,"@E 999,999,999,999.99") + '</td> '
        cHtml += ' </tr> '
			
        cHtml += ' <tr> '
        cHtml += ' </tr> '
			
        cHtml += ' </tbody> '
        cHtml += ' </table> '
        cHtml += ' <hr> '
        cHtml += ' </div>
        cHtml += ' <br/><br/><br/><br/> '
			
        If cFornece == Alltrim(cValToChar(Work->ZFK_TRANSP)) .And. cLoja == Alltrim(cValToChar(Work->ZFK_LOJA))
            cHtml += ' <p style="page-break-before:always"> '
        EndIf

		cHtml += ' </body> '
		cHtml += ' </html> '

		If MemoWrite( cDir + cArq, Alltrim(cValToChar(cHtml)) )
			
			MsAguarde({|| U_F50En2WF(cEmail,cEmailC,cAssunto,cMensagem,cDir + cArq)  } ,"Adiantamento-Aguarde","Env p/ " + cFornece + "-" + cLoja + "/" + "(" + cEmail + ")")
				
			FErase(cDir + cArq)

		Else

			Alert("Email de Adiantamento do fornecedor " + cFornece + " NÃO enviado pois o arquivo HTML com os totais por placa não foi gerado.","Função ADLOG040P-SendADI")

		EndIf
		
		cHtml   := ""
		cEmail  := ""
		//cEmailC := "" TICKET 18451 - ADRIANO SAVOINE - 17/08/2021
		nTotal  := 0
				
		//Work->( dbSkip() )

	EndDo			
		
	MsgInfo("Email de Adiantamento enviado com sucesso.","Função ADLOG040P-SendADI")
		
    If Select("Work") > 0
        Work->(dbCloseArea() )
    EndIf

Return

/*/{Protheus.doc} u_LOG040A0
//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG040A0( uPar1 )
Return( retDescFrt( uPar1 ) )
