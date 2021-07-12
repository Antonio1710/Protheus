#INCLUDE "Totvs.ch"
#INCLUDE "PROTHEUS.CH"
#Include "RwMake.ch"
#Include "topconn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function CEXPNFOK
	Emissao do Boletim de Entrada 
	@type  Function
	@author Fernando
	@since 09/08/2018
	@version 01
	@history Chamado - 048464 09/04/2019 - Fernando Sigoli   - validação da placa XML x Ocorrencia Devolução
	@history Chamado - 048464 15/04/2019 - Fernando Sigoli   - Nao enviar worflow,quando F1_PLACA estiver vazio 
	@history Chamado - T.I    24/05/2019 - Adriana.          - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Chamado - 050334 12/07/2019 - Abel Babini.      - Padronizar Série da NF de Entrada 
	@history TicKet  - 28 	  04/08/2020 - Richard Fabrietch - Correção do posicionamento de alteração de Serie NFE
	@history Ticket 10781     17/03/2021 - Abel Babini       - Padronização de Séries nas empresas. Adição dos CNPJ´s da Safegg e Simplify
	@history Ticket 16758     14/07/2021 - Abel Babini       - Padronização de Séries nas empresas Adoro para notas do tipo complemento.
/*/


User Function CEXPNFOK()

Local cPlcVeic 	:= ""
Local cDocNro  	:= ""
Local cDocSer  	:= ""
Local cA2CGC   	:= ""
Local lAlterSD1 := "N"
Local cPlcVeic  := Alltrim(SF1->F1_PLACA) //chamado: 048464 09/04/2019 - Fernando Sigoli 
         
//Devolução
If SF1->F1_TIPO == "D" .AND. Alltrim(cFilAnt) $ '02' //devolução com integração com Edata, somente na filial 02

	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	While SD1->(!EOF()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
	
		cDocNro	:= SD1->D1_NFORI
		cDocSer	:= SD1->D1_SERIORI
			
		
		SD1->(DbSkip())
	EndDo
	
	//Inicio. Chamado: 048464 09/04/2019 - Fernando Sigoli 
	If Alltrim(SF1->F1_PLACA) <> Alltrim(Posicione("SZD",1,xFilial("SZD")+cDocNro+cDocSer,"ZD_PLACA"))
   
		cPlcVeic := Alltrim(Posicione("SZD",1,xFilial("SZD")+cDocNro+cDocSer,"ZD_PLACA"))
		
		If !Empty(SF1->F1_PLACA) //Chamado : 048464 15/04/2019 - Fernando Sigoli.
			EnviaWF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_PLACA,cPlcVeic)
		EndIf	
	
	EndiF
		
	If !Empty(cPlcVeic)
		
		RecLock("SF1",.F.)
		SF1->F1_PLACA := cPlcVeic
		MsUnlock()
		
	Else
		
		Aviso(" CEXPNFOK-01","Placa nao encontrada nas ocorrecias/devolução!",{"OK"},3)
	
	EndIf
	//Fim.Chamado: 048464 09/04/2019 - Fernando Sigoli 
	
Endif

//Ticket 16758     14/07/2021 - Abel Babini       - Padronização de Séries nas empresas Adoro para notas do tipo complemento.
//tranferencia 
If SF1->F1_TIPO == "N" .OR. SF1->F1_TIPO == "C"  .OR. SF1->F1_TIPO == "I"  .OR. SF1->F1_TIPO == "P"   //Entrada normal Cadastro de Fornecedor
		
	lAlterSD1 := 'N'
		
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
	If SA2->(!EOF())         
	
		cA2CGC 	:= Alltrim(SA2->A2_CGC)
		cA2CGC  := substr(cA2CGC,1,9)
		
	EndIf
	//Ticket 10781 - Padronização de Séries nas empresasa. Adição dos CNPJ´s da Safegg e Simplify
	If !Empty(cA2CGC) .and. (cA2CGC = '600370580' .OR. cA2CGC = '020903840' .OR. cA2CGC = '120976720' .OR. cA2CGC = '200525410' .OR. cA2CGC = '154093150') //Ch. 050334 - 12/07/2019 - Abel Babini - Padronizar Série da NF de Entrada para empresa 07

		_aRecserie := {}

		DbSelectArea('SD1')
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		While SD1->(!EOF()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
				
			AADD(_aRecserie,{SD1->(RECNO())})

			lAlterSD1 := 'S'
			SD1->(DbSkip())
		EndDo
		
		//Inicio - TicKet  - 28 - Richard Fabrietch 04/08/2020	
		For _x := 1 To Len(_aRecserie)
			
			DbSelectArea('SD1')
			Dbgoto(_aRecserie[_x][1])

			Reclock("SD1",.F.)
			SD1->D1_SERIE 	:= '01'
			MsUnlock("SD1")	

		Next _x
		//Fim - TicKet  - 28 - Richard Fabrietch 04/08/2020
		
		
		//atualiza SF1 (cabeçalho)
		If lAlterSD1 = 'S' 
			
			RecLock("SF1",.F.)
			SF1->F1_SERIE := '01'
			MsUnlock() 
			
		EndIf
			
	EndIf
	
EndIf    

Return NIL
 

//------------------------------------------|
//Funcao enviar email para o resposanvel    |
//------------------------------------------|
Static Function EnviaWF(cNfiscal,cSerie,cCliente,cLoja,cPlacNF,CPlaOC)

	Local nPerc1     := 0
	Local nPerc2     := 0
	Local cAssunto	 := "[ CEXPNFOK ] - Nota Fiscal "+Alltrim(cNfiscal)+'/'+Alltrim(cSerie)+" Clie/Forn: "+cCliente+'-'+cLoja +" com Placa "+ cPlacNF+ " Divergente do veiculo/pesagem " +CPlaOC+ " - " + DtoC(msDate()) + " - " + time()
	Local cMensagem	 := ""
	Local cMails     := GetMV("MV_#WFPLAC",,"sistemas@adoro.com.br")

	//Cabecalho corpo email
	cMensagem += '<html>'
	cMensagem += '<body>'
	cMensagem += '<p style="color:red">'+cValToChar(cAssunto)+'</p>'
	cMensagem += '</body>'
	cMensagem += '</html>'
	
	// envia email
	ProcEmail(cAssunto,cMensagem,cMails)

Return 
   
//------------------------------------------|
//processa envio email                      |
//------------------------------------------|
Static Function ProcEmail(cAssunto,cMensagem,email)

	Local lOk           := .T.
	Local lAutOk        := .F.
	Local aArea			:= GetArea()
	Local cBody         := cMensagem
	Local cTo           := email
	Local cErrorMsg     := ""
	Local cAtach        := ""
	Local cSubject      := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	
	cSubject := cAssunto
	
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf
	
	If lOk .And. lAutOk
		
		Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("3 - " + cErrorMsg)
		EndIf
	
	Else
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)
	
	EndIf
	
	If lOk
		Disconnect Smtp Server
	EndIf
	
	RestArea(aArea)

Return
