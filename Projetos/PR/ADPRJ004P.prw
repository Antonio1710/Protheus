#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EnviaWF   ºAutor  ³Fernando Macieira   º Data ³  01/05/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para enviar email na recusa do projeto              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADPRJ004P(aDadWF, cTipoWF)

Local cTitulo   := ""
Local cHTML     := ""
Local aWFCabec  := {}
Local aWFItens  := {}

Local cCodPrj  := AllTrim(aDadWF[1,1])
Local cRevPrj  := AllTrim(aDadWF[1,2])
Local cNomApr  := AllTrim(adadWF[1,4])
Local dDtaApr  := aDadWF[1,5]
Local cHrApr   := AllTrim(aDadWF[1,6])
Local cObs     := AllTrim(aDadWF[1,7])
Local cMail    := AllTrim(aDadWF[1,8])
Local cUsrMail := AllTrim(aDadWF[1,10])

Default cTipoWF := ""

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If cTipoWF == "APROVACAO"
	cTitulo := "[ Projetos ] - Aprovação - Projeto n. " + cCodPrj + "/" + cRevPrj + " - " + aDadWF[1,9]
	
ElseIf cTipoWF == "RECUSA"
	cTitulo := "[ Projetos ] - Recusa - Projeto n. " + cCodPrj + "/" + cRevPrj + " - " + aDadWF[1,9]

ElseIf cTipoWF == "INCLUSAO"
	cTitulo := "[ Projetos ] - Inclusão - Projeto n. " + cCodPrj + "/" + cRevPrj + " - " + aDadWF[1,9]

ElseIf cTipoWF == "REVISAO"
	cTitulo := "[ Projetos ] - Revisão - Projeto n. " + cCodPrj + "/" + cRevPrj + " - " + aDadWF[1,9]

ElseIf cTipoWF == "EXCLUSAO"
	cTitulo := "[ Projetos ] - Exclusão - Projeto n. " + cCodPrj + "/" + cRevPrj + " - " + aDadWF[1,9]

ElseIf cTipoWF == "ENCERRAPRJ"
	cTitulo := "[ Projetos ] - Encerramento - Projeto n. " + cCodPrj + "/" + cRevPrj + " - " + aDadWF[1,9]

EndIf
	
If cTipoWF == "APROVACAO" .or. cTipoWF == "RECUSA"

	aWFCabec := { {"Projeto", TamSX3("AF8_PROJETO")[1]},;
		{"Revisão", TamSX3("AF8_REVISA")[1]},;
		{"Nome Projeto", TamSX3("AF8_DESCRI")[1]},;
		{"Gestor", TamSX3("ZC7_NOMAPR")[1]},;
		{"Data", TamSX3("ZC7_DTAPR")[1]},;
		{"Hora", TamSX3("ZC7_HRAPR")[1]},;
		{"Observações", TamSX3("ZC7_OBS")[1]} }
		
	aWFItens := { {cCodPrj, TamSX3("AF8_PROJETO")[1], "left"},;
		{cRevPrj, TamSX3("AF8_REVISA")[1], "left"},;
		{aDadWF[1,9], TamSX3("AF8_DESCRI")[1], "left"},;
		{cNomApr, TamSX3("ZC7_NOMAPR")[1], "left"},;
		{DtoC(dDtaApr), TamSX3("ZC7_DTAPR")[1], "right"},;
		{cHrApr, TamSX3("ZC7_HRAPR")[1], "right"},;
		{cObs, TamSX3("ZC7_OBS")[1], "left"} }


ElseIf cTipoWF == "INCLUSAO" .or. cTipoWF == "REVISAO" .or. cTipoWF == "EXCLUSAO"

	/*aAdd( aDadWF, { ZC7->ZC7_PROJET, ZC7->ZC7_REVPRJ, cUsrSol, cNomSol, dDatInc, cHorInc, AF8->AF8_XVALOR, cMail, AF8->AF8_DESCRI } )*/
	
	aWFCabec := { {"Projeto", TamSX3("AF8_PROJETO")[1]},;
		{"Revisão", TamSX3("AF8_REVISA")[1]},;
		{"Nome Projeto", TamSX3("AF8_DESCRI")[1]},;
		{"Valor", TamSX3("AF8_XVALOR")[1]},;
		{"Solicitante", TamSX3("ZC7_NOMAPR")[1]},;
		{"Data", TamSX3("ZC7_DTAPR")[1]},;
		{"Hora", TamSX3("ZC7_HRAPR")[1]} }
		
	aWFItens := { {cCodPrj, TamSX3("AF8_PROJETO")[1], "left"},;
		{cRevPrj, TamSX3("AF8_REVISA")[1], "left"},;
		{aDadWF[1,9], TamSX3("AF8_DESCRI")[1], "left"},;
		{aDadWF[1,7], TamSX3("AF8_XVALOR")[1], "right"},;
		{aDadWF[1,4], TamSX3("ZC7_NOMAPR")[1], "left"},;
		{DtoC(dDtaApr), TamSX3("ZC7_DTAPR")[1], "right"},;
		{cHrApr, TamSX3("ZC7_HRAPR")[1], "right"} }


ElseIf cTipoWF == "ENCERRAPRJ" 

	/*aAdd( aDadWF, { ZC7->ZC7_PROJET, ZC7->ZC7_REVPRJ, cUsrSol, cNomSol, dDatInc, cHorInc, AF8->AF8_XVALOR, cMail, AF8->AF8_DESCRI } )*/
	
	aWFCabec := { {"Projeto", TamSX3("AF8_PROJETO")[1]},;
		{"Revisão", TamSX3("AF8_REVISA")[1]},;
		{"Nome Projeto", TamSX3("AF8_DESCRI")[1]},;
		{"Valor", TamSX3("AF8_XVALOR")[1]},;
		{"Usuário", TamSX3("ZC7_NOMAPR")[1]},;
		{"Data", TamSX3("ZC7_DTAPR")[1]},;
		{"Hora", TamSX3("ZC7_HRAPR")[1]} }
		
	aWFItens := { {cCodPrj, TamSX3("AF8_PROJETO")[1], "left"},;
		{cRevPrj, TamSX3("AF8_REVISA")[1], "left"},;
		{aDadWF[1,9], TamSX3("AF8_DESCRI")[1], "left"},;
		{aDadWF[1,7], TamSX3("AF8_XVALOR")[1], "right"},;
		{aDadWF[1,4], TamSX3("ZC7_NOMAPR")[1], "left"},;
		{DtoC(dDtaApr), TamSX3("ZC7_DTAPR")[1], "right"},;
		{cHrApr, TamSX3("ZC7_HRAPR")[1], "right"} }

EndIf

cHTML := u_ADPRJ005P(aWFCabec, aWFItens, cTitulo) //ALTERADO WILLIAM COSTA MONTAHTML 12/03/2018

u_ADPRJ003P(cTitulo, cHTML, cMail, cUsrMail) //ENVIA EMAIL WILLIAM COSTA ERRO 12/03/2018

Return
