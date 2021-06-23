#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"


#INCLUDE "ParmType.ch"
#INCLUDE "MntTRCell.ch"

//Estrutura de arquivo
#DEFINE POS_CMP		1
#DEFINE POS_TIP		2
#DEFINE POS_TAM		3
#DEFINE POS_DEC		4

//Estrutura de campos para formar arquivo HTML
#DEFINE POS_HT_CMP		1
#DEFINE POS_HT_TAM		2
#DEFINE POS_HT_TIT		3
#DEFINE POS_HT_PIC		4

Static nEsqCont			:= 001
Static nAltCont			:= 009
Static nDistPad			:= 002
Static nAltBot			:= 013
Static nDistAPad		:= 004
Static nDistEtq			:= 001
Static nAltEtq			:= 007
Static nLargEtq			:= 035 
Static nLargBot			:= 040
Static cHK				:= "&"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO6     บAutor  ณMicrosiga           บ Data ณ  07/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็๕es gen้ricas da interface                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro P11                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAdriana     ณ24/05/2019ณTI-Devido a substituicao email para shared     บฑฑ
ฑฑบ            ณ          ณrelay, substituido MV_RELACNT p/ MV_RELFROM    บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function CCSGrvLog(_P, _P2, _P3, _P4, _P5,_P6)

Local cPara      := SuperGetMV("MV_XMPARA" ,,"")
Local cCopia     := "" //SuperGetMV("MV_XMCOPIA",,"julianof@sag.com.br")
Local cCpOcul    := SuperGetMV("MV_XMCPOCU",,"")
Local cAssunto   := SuperGetMV("MV_XMASSUN",,"Integracao Protheus X SAG")
Local cDe        := SuperGetMV("MV_XMAILDE",,"workflow@adoro.com.br")
Local cMensag    := ""
Local lHtml      := .T.
Local cAnexo     := ""        
Local _lJob		 := .T.  
Local aEstruC01			:= {}
Local nTotREG			:= 0
Local aLstC01			:= {}
Local aLstV01			:= {}
Local cLstC				:= ""
Local aLstC01 := {"ZA1_FILIAL","ZA1_TABELA","ZA1_REGISTR","ZA1_ACAO","ZA1_DATA","ZA1_HORA","ZA1_MENSAG","ZA1_USER","ZA1_MOVTO"}

Default _P6 := .F.

U_ADINF009P('ADINTXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็๕es gen้ricas da interface')

RecLock("ZA1",.T.)
ZA1->ZA1_FILIAL := _P5
ZA1->ZA1_TABELA := _P2
ZA1->ZA1_REGISTR:= _P3
ZA1->ZA1_ACAO   := Iif(_P4 == 3, "I", Iif(_P4 == 4, "A", Iif(_P4 == 5, "E", "P") ))
ZA1->ZA1_DATA   := dDataBase
ZA1->ZA1_HORA   := Time()
ZA1->ZA1_MENSAG := _P
ZA1->ZA1_USER   := SubStr(cusuario,7,15)
ZA1->(MsUnLock())                            

IF !_P6

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeterminar estrutura dos campos  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For ni := 1 to ("ZA1")->(FCount())
		aAdd(aEstruC01,Array(4))
		nPos := Len(aEstruC01)
		cTipoD := ValType(("ZA1")->(FieldGet(ni)))
		//Verificar se o campo existe no dicionario de dados
		If SX3->(dbSeek(("ZA1")->(FieldName(ni))))
			aEstruC01[nPos][POS_HT_CMP] := SX3->X3_CAMPO
			aEstruC01[nPos][POS_HT_TAM] := SX3->X3_TAMANHO
			aEstruC01[nPos][POS_HT_TIT] := GetSX3Cache(("ZA1")->(FieldName(ni)),"X3_TITENG")
			aEstruC01[nPos][POS_HT_PIC] := SX3->X3_PICTURE
		Else
			aEstruC01[nPos][POS_HT_CMP] := ("ZA1")->(FieldName(ni))
			aEstruC01[nPos][POS_HT_TAM] := 20
			aEstruC01[nPos][POS_HT_TIT] := ("ZA1")->(FieldName(ni))
			aEstruC01[nPos][POS_HT_PIC] := IIf(cTipoD == "D","@D",IIf(cTipoD == "N","@E 99,999,999,999.99","@!"))
		Endif
	Next ni               
	
	aAdd(aLstV01,Array(Len(aLstC01)))
	nPos := Len(aLstV01)
	For ni := 1 to ("ZA1")->(FCount())
		aLstV01[nPos][ni] := ("ZA1")->(FieldGet(ni))
	Next ni
	
	
	cTitulo := "INTERFACE SAG X PROTHEUS " + "<br>" + "EMPRESA [" + cEmpAnt + "-" + cFilAnt + "]"
	cHTML := U_MntHTMCb(cTitulo,"http://www.ccskf.com.br/SiteImages/CCSKFwf.jpg")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณItens SF2  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤู
	cHTML += U_MntHTMIt(aClone(aEstruC01),aClone(aLstV01),"Movimentos nใo integrados","<b>Itens</b> : " + cValToChar(1),.T.)
	//ฺฤฤฤฤฤฤฤฤฟ
	//ณRodape  ณ
	//ภฤฤฤฤฤฤฤฤู
	cHTML += U_MntHTMRd()
	
	/*
	cHtml := '<body lang=PT-BR style="tab-interval:35.4pt">'  + CRLF
	cHtml += '   <div class=WordSection1>'  + CRLF
	cHtml += '      <table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 style="border-collapse:collapse;border:none;mso-border-alt:solid windowtext.5pt;mso-yfti-tbllook:1184;mso-padding-alt:0cm 5.4pt 0cm 5.4pt">'  + CRLF
	cHtml += '         <table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=712 style="width:534.3pt;border-collapse:collapse;border:none;mso-yfti-tbllook:1184;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;mso-border-insidev:none">'  + CRLF
	cHtml += '            <tr style="mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;height:27.35pt">'  + CRLF
	cHtml += '               <td width=84 valign=top style="width:53.3pt;padding:0cm 5.4pt 0cm 5.4pt;height:27.35pt">'  + CRLF
	cHtml += '               <p>'  + CRLF
	cHtml += '                  <img src='+GetSrvProfString( 'ROOTPATH', '' )+GetSrvProfString( 'STARTPATH', '' )+"\Adoro.gif"+'>'+ CRLF//+"lgrl"+cEmpAnt+".bmp"+'>'+ CRLF
	cHtml += '               </p>' + CRLF
	cHtml += '               </td>'  + CRLF
	cHtml += '               <td width=588 style="width:441.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:27.35pt">'  + CRLF
	cHtml += '                  <p class=MsoNormal style="margin-bottom:0cm;margin-bottom:.0001pt; line-height:normal">
	cHtml += '                     <span style="font-size:18.0pt;mso-bidi-font-size:11.0pt"><span style="mso-spacerun:yes">             </span>INTEGRAวรO PROTHEUS X SAG</span>'  + CRLF
	cHtml += '                  </p>'  + CRLF
	cHtml += '               </td>'  + CRLF
	cHtml += '            </tr>'  + CRLF
	cHtml += '         </table>'  + CRLF
	cHtml += '         <tr style="mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes">'  + CRLF
	cHtml += '            <td width=707 valign=top style="width:530.3pt;border:solid windowtext 1.0pt; mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">'  + CRLF
	cHtml += '               <p class=MsoNormal align=center style="margin-bottom:0cm;margin-bottom:.0001pt;text-align:center;line-height:normal">'  + CRLF
	cHtml += '                  <span style="font-size:16.0pt;mso-bidi-font-size:11.0pt;color:red"> A T E N ว ร O </span>'  + CRLF
	cHtml += '               </p>'  + CRLF
	cHtml += '               <p class=MsoNormal style="margin-bottom:0cm;margin-bottom:.0001pt;line-height:normal">'  + CRLF
	cHtml += '                  Em '+DtoC(dDatabase)+' เs '+Left(Time(),5)+' horas, ocorreu erro na integra็ใo Protheus x SAG, favor analisar os Logs !'  + CRLF
	cHtml += '               </p>'  + CRLF
	cHtml += '            </td>'  + CRLF
	cHtml += '         </tr>'  + CRLF
	cHtml += '      </table>'  + CRLF
	cHtml += '   </div>'  + CRLF
	cHtml += '</body>'  + CRLF
	cHtml += '</html>'  + CRLF
	*/
	
	cMensag := cHtml
	
	U_M001MAIL(cPara,cCopia,cCpOcul,cAssunto,cDe,cMensag,lHtml,cAnexo,_lJob)

EndIf

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออออออออออัอออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Funcao             ณ RESPM001  ณ Fuuncao para encio de email de erros na integracao Protheus X SAG        บฑฑ
ฑฑฬออออออออออออออออออออุอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออัอออออออออออนฑฑ
ฑฑบ Autor              ณ Descricoes                                                               ณ  Data     บฑฑ
ฑฑฬออออออออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออุอออออออออออนฑฑ
ฑฑบ www.cellvla.com.br ณ 1 -                                                                      ณ 25/02/13  บฑฑ
ฑฑศออออออออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฯอออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function M001MAIL(cPara,cCopia,cCpOcul,cAssunto,cDe,cMensag,lHtml,cAnexo,_lJob)

Local lOk       := .F.
Local cAccount  := SuperGetMv("MV_RELACNT",,"")
Local cPassword := SuperGetMv("MV_RELPSW" ,,"")
Local cServer   := SuperGetMv("MV_RELSERV",,"")

U_ADINF009P('ADINTXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็๕es gen้ricas da interface')

Default cPara   := ""
Default cCopia  := ""
Default cCpOcul := ""
Default cAssunto:= "Integracao Protheus X SAG"
Default cDe     := Iif(ValType(cDe)="U",.F.,SuperGetMv("MV_RELFROM",,"")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
Default cMensag := ""
Default lHtml   := Iif(ValType(lHtml)="U",.F.,lHtml)
Default cAnexo  := ""

Connect Smtp Server cServer Account cAccount Password cPassword Result lOk

If lOk == .T.
	If !MailAuth(cAccount,cPassword)
		Get Mail Error cErrorMsg
		If _lJob == .F.
			Help("",1,"Erro conexใo 0001",,"Error: "+cErrorMsg,2,0)
		EndIf
		Disconnect Smtp Server Result lOk
		
		If !lOk
			Get Mail Error cErrorMsg
			If _lJob == .F.
				Help("",1,"Erro conexใo 0002",,"Error: "+cErrorMsg,2,0)
			EndIf
		EndIf
		Return ( .f. )
	EndIf
	
	If !Empty(cCopia)
		If lHtml
			If !Empty(cAnexo)
				Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cMensag Attachment cAnexo Result lOk
			Else
				Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cMensag Result lOk
			EndIf
		else
			If !Empty(cAnexo)
				Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cMensag Format Text Attachment cAnexo Result lOk
			Else
				Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cMensag Format Text Result lOk
			EndIf
		EndIf
	Else
		If lHtml
			If !Empty(cAnexo)
				Send Mail From cDe To cPara CC cCopia BCC cCpOcul Subject cAssunto Body cMensag Attachment cAnexo Result lOk
			Else
				Send Mail From cDe To cPara CC cCopia BCC cCpOcul Subject cAssunto Body cMensag Result lOk
			EndIf
		else
			If !Empty(cAnexo)
				Send Mail From cDe To cPara CC cCopia BCC cCpOcul Subject cAssunto Body cMensag Format Text Attachment cAnexo Result lOk
			Else
				Send Mail From cDe To cPara CC cCopia BCC cCpOcul Subject cAssunto Body cMensag Format Text Result lOk
			EndIf
		EndIf
	EndIf
	
	If ! lOk
		Get Mail Error cErrorMsg
		If _lJob == .F.
			Help("",1,"Erro conexใo 0003",,"Error: "+cErrorMsg,2,0)
		EndIf
	EndIf
Else
	Get Mail Error cErrorMsg
	If _lJob == .F.
		Help("",1,"Erro conexใo 0004",,"Error: "+cErrorMsg,2,0)
	EndIf
EndIf

Disconnect Smtp Server

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMntHTMCb   บAutor  ณPablo Gollan Carreras บ Data ณ25/05/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณMonta um cabecalho de um arquivo HTML                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Titulo do arquivo                                      บฑฑ
ฑฑบ          ณExp02[C] : Link do logo da empresa ou o desejado                  บฑฑ
ฑฑบ          ณExp03[L] : Imprimir dados da empresa                              บฑฑ
ฑฑบ          ณExp04[L] : Imprimir linha de quebra                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcCabec[C] : Cabecalho em formato HTML                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
User Function MntHTMCb(cTituloM,cLinkLOGO,lEmpresa,lQuebra)

Local cCabec			:= ""

PARAMTYPE 0	VAR cTituloM	AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 1	VAR cLinkLOGO	AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 2	VAR lEmpresa	AS Logical		OPTIONAL	DEFAULT .T.
PARAMTYPE 3	VAR lQuebra		AS Logical		OPTIONAL	DEFAULT .T.

cCabec := '<html><head>' + CRLF
cCabec += '<title>' + Upper(cTituloM) + '</title>' + CRLF
cCabec += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">' + CRLF
cCabec += '</head>' + CRLF
//FORM
cCabec += '<form name="FORM">' + CRLF
cCabec += '<div align="center">' + CRLF
cCabec += '<table background="" border="0" cellpadding="0" cellspacing="0" width="100%">' + CRLF
cCabec += '<tbody>' + CRLF
cCabec += '<tr>' + CRLF
cCabec += '<td height="84">' + CRLF
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCABECALHO PRINCIPAL  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCabec += '<table border="0" cellpadding="0" cellspacing="0" width="100%">' + CRLF
cCabec += '<tbody>' + CRLF
cCabec += '<tr>' + CRLF
cCabec += '<td height="16" width="33%">' + CRLF
cCabec += '<div align="left">' + IIf(!Empty(cLinkLOGO),'<img src="' + RTrim(cLinkLOGO) + '" height="65" width="170">','') + '</div>' + CRLF
cCabec += '</td>' + CRLF
cCabec += '<td height="16" width="33%">' + CRLF
cCabec += '<div align="center"><font face="Arial, Helvetica, sans-serif" size="2"><b><font size="4">' + cTituloM + '</font></b></font></div>' + CRLF
cCabec += '</td>' + CRLF
cCabec += '<td height="16" valign="top" width="34%"> <br>' + CRLF
cCabec += '</td>' + CRLF
cCabec += '</tr>' + CRLF
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDADOS DA EMPRESA  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lEmpresa
	cCabec += '<tr>' + CRLF
	cCabec += '<td colspan="2" height="41"><b><font face="Arial, Helvetica, sans-serif" size="1">' + SM0->M0_NOMECOM + '<br></font></b>' + CRLF
	cCabec += '<font face="Arial, Helvetica, sans-serif" size="1">' + "CNPJ : " + SM0->M0_CGC + '<br>' + CRLF
	cCabec += SM0->M0_ENDENT + '<br>' + CRLF
	cCabec += "CEP: " + RTrim(SM0->M0_CEPENT) + "- Tel. " + RTrim(SM0->M0_TEL) + '<br>' + CRLF
	cCabec += '</font></td>' + CRLF
	cCabec += '<td height="41" valign="top" width="34%"> <br>' + CRLF
	cCabec += '</td>' + CRLF
	cCabec += '</tr>' + CRLF
Endif
cCabec += '</tbody>' + CRLF
cCabec += '</table>' + CRLF
//QUEBRA DE LINHA
If lQuebra
	cCabec += '<tr>' + CRLF
	cCabec += '<td>' + CRLF
	cCabec += '<hr noshade="noshade">' + CRLF
	cCabec += '</td>' + CRLF
	cCabec += '</tr>' + CRLF
Endif

Return cCabec
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMntHTMIt   บAutor  ณPablo Gollan Carreras บ Data ณ25/05/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณMonta cabecalho e conteudo de uma lista de itens                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Lista de campos, com a seguinte estrutura :            บฑฑ
ฑฑบ          ณ           [1] Nome do campo                                      บฑฑ
ฑฑบ          ณ           [2] Tamanho do campo                                   บฑฑ
ฑฑบ          ณ           [3] Titulo                                             บฑฑ
ฑฑบ          ณ           [4] Picture de formatacao de dados                     บฑฑ
ฑฑบ          ณExp02[A] : Array com a lista de valores                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcMens[C] : Bloco de itens em formato HTML                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
User Function MntHTMIt(aLstC,aLstVal,cTitulo,cRodape,lQuebra)

Local cMens				:= ""
Local nEspTotH			:= 0
Local ni				:= 0
Local nx				:= 0
Local nz				:= 0
Local cMasc				:= ""

PARAMTYPE 0	VAR aLstC		AS Array
PARAMTYPE 1	VAR aLstVal		AS Array
PARAMTYPE 2	VAR cTitulo		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 3	VAR cRodape		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 4	VAR lQuebra		AS Logical		OPTIONAL	DEFAULT .F.

If Len(aLstC) # Len(aLstVal[1])
	Return cMens
Endif
If !Empty(cTitulo)
	cMens += '<table style="width: 100%;" nowrap="1" background="" border="0" bordercolor="#cccccc" cellpadding="0" cellspacing="0">' + CRLF
	cMens += '<tr><td>' + CRLF
	cMens += '<font face="Arial, Helvetica, sans-serif" size="4"><b>' + cTitulo + '</b></font>' + CRLF
	cMens += '</td></tr>'
	cMens += '</table>'
Endif
cMens += '<table style="width: 100%;" nowrap="1" background="" border="0" bordercolor="#cccccc" cellpadding="0" cellspacing="0">' + CRLF
cMens += '<thead> <tr bgcolor="#cccccc">' + CRLF
//Levantar o espacamento total das colunas
nEspTotH := 0
aEval(aLstC,{|x| nEspTotH += x[POS_HT_TAM]})
For ni := 1 to Len(aLstC)
	cMens += '<td height="' + cValToChar(Int((aLstC[ni][POS_HT_TAM] / nEspTotH) * 100)) + '">' + CRLF
	cMens += '<div align="left"><b><font face="Arial, Helvetica, sans-serif" size="1">' + Capital(AllTrim(aLstC[ni][POS_HT_TIT])) + '</font></b></div>' + CRLF
	cMens += '</td>' + CRLF
Next ni	
//ฺฤฤฤฤฤฤฤฟ
//ณITENS  ณ
//ภฤฤฤฤฤฤฤู
cMens += '<tbody>' + CRLF
For nx := 1 to Len(aLstVal)
	cMens += '<tr>' + CRLF
	For ni := 1 to Len(aLstC)
		cCmpAt := aLstC[ni][POS_HT_CMP]
		If Empty(cMasc := aLstC[ni][POS_HT_PIC])
			If Empty(cMasc := GetSX3Cache(cCmpAt,"X3_PICTURE"))
				cMasc := "@!"
			Endif
		Endif
		cMens += '<td>&nbsp;<font face="Verdana" size="1">' + Transform(aLstVal[nx][ni],cMasc) + '</font></td>' + CRLF
	Next ni
	cMens += '</tr>' + CRLF
Next nx
cMens += '</tbody>' + CRLF
cMens += '</table>'
//ฺฤฤฤฤฤฤฤฤฟ
//ณQUEBRA  ณ
//ภฤฤฤฤฤฤฤฤู
If lQuebra
	cMens += '<tr>' + CRLF
	cMens += '<td>' + CRLF
	cMens += '<hr noshade="noshade">' + CRLF
	cMens += '</td>' + CRLF
	cMens += '</tr>' + CRLF
Endif
//ฺฤฤฤฤฤฤฤฤฟ
//ณRODAPE  ณ
//ภฤฤฤฤฤฤฤฤู
If !Empty(cTitulo)
	If !lQuebra
		cMens += "<p>" + CRLF
	Endif
	cMens += '<table style="width: 100%;" nowrap="1" background="" border="0" bordercolor="#cccccc" cellpadding="0" cellspacing="0">' + CRLF
	cMens += '<tr><td>' + CRLF
	cMens += '<font face="Arial, Helvetica, sans-serif" size="1">' + cRodape + '</font><p>' + CRLF
	cMens += '</td></tr>'
	cMens += '</table>'
Endif

Return cMens
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMntHTMRd   บAutor  ณPablo Gollan Carreras บ Data ณ25/05/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o rodape do arquivo HTML, deve trabalhar c/ os outros comp. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcRodape[C] : Cabecalho em formato HTML                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
User Function MntHTMRd()

Local cRodape 			:= ""

cRodape := '</tbody>' + CRLF
cRodape += '</tbody>' + CRLF
cRodape += '</table>' + CRLF
cRodape += '</div>' + CRLF
cRodape += '</form>' + CRLF
cRodape += '</body></html>' + CRLF

Return cRodape
*/

User Function SbzTest(cProd)

U_ADINF009P('ADINTXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็๕es gen้ricas da interface')

SB1->(dbselectArea("SB1"))
SB1->(dbsetorder(1))
SB1->(dbseek(xFilial("SB1")+cProd))

alert(SB1->(B1_COD))

alert(RetFldProd(SB1->(B1_COD),"B1_LOCPAD"))                                                                                         

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณnewGrSX1   บAutor  ณPablo Gollan Carreras บ Data ณ10/04/12     บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para criar o grupo de perguntas                         บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome do grupo de perguntas                          บฑฑ
ฑฑบ          ณExp02[A] : Array com as perguntas (estrutura)                  บฑฑ
ฑฑบ          ณ           01. PERGUNTA                                        บฑฑ
ฑฑบ          ณ           02. TIPO                                            บฑฑ
ฑฑบ          ณ           03. TAM                                             บฑฑ
ฑฑบ          ณ           04. DECIMAL (POSICAO OPCIONAL PODE SER INIBIDA)     บฑฑ
ฑฑบ          ณ           05. OBJETO                                          บฑฑ
ฑฑบ          ณ           06. PS                                              บฑฑ
ฑฑบ          ณ           07. COMBO                                           บฑฑ
ฑฑบ          ณ           08. SXG                                             บฑฑ
ฑฑบ          ณ           09. SX3                                             บฑฑ
ฑฑบ          ณ           10. VALID                                           บฑฑ
ฑฑบ          ณ           11. HELP                                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function newGrSX1(cPerg, aPerg, aHelp)

Local aArea 	:= GetArea()
Local aCpoPerg 	:= {}
Local cNome		:= ""
Local nX 		:= 0
Local nY		:= 0
Local _nPosHelp := 0
Local lAcao		:= .T.

Default cPerg := ""
Default aPerg := {} 
Default aHelp := {}

U_ADINF009P('ADINTXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็๕es gen้ricas da interface')

	// DEFINE ESTRUTUA DO ARRAY DAS PERGUNTAS COM AS PRINCIPAIS INFORMACOES
	AADD( aCpoPerg, 'X1_ORDEM' 	)
	AADD( aCpoPerg, 'X1_PERGUNT')
	AADD( aCpoPerg, 'X1_PERSPA' )
	AADD( aCpoPerg, 'X1_PERENG' )
	AADD( aCpoPerg, 'X1_TIPO' 	)
	AADD( aCpoPerg, 'X1_TAMANHO')
	AADD( aCpoPerg, 'X1_DECIMAL')
	AADD( aCpoPerg, 'X1_PRESEL' )
	AADD( aCpoPerg, 'X1_GSC' 	)
	AADD( aCpoPerg, 'X1_VALID' 	)	
	AADD( aCpoPerg, 'X1_DEF01' 	)
	AADD( aCpoPerg, 'X1_DEFSPA1')
	AADD( aCpoPerg, 'X1_DEFENG1')
	AADD( aCpoPerg, 'X1_CNT01' 	)
	AADD( aCpoPerg, 'X1_VAR02' 	)
	AADD( aCpoPerg, 'X1_DEF02' 	)
	AADD( aCpoPerg, 'X1_DEFSPA2')
	AADD( aCpoPerg, 'X1_DEFENG2')
	AADD( aCpoPerg, 'X1_CNT02' 	)
	AADD( aCpoPerg, 'X1_VAR03' 	)
	AADD( aCpoPerg, 'X1_DEF03' 	)
	AADD( aCpoPerg, 'X1_DEFSPA3')
	AADD( aCpoPerg, 'X1_DEFENG3')
	AADD( aCpoPerg, 'X1_CNT03' 	)
	AADD( aCpoPerg, 'X1_VAR04' 	)
	AADD( aCpoPerg, 'X1_DEF04' 	)
	AADD( aCpoPerg, 'X1_DEFSPA4')
	AADD( aCpoPerg, 'X1_DEFENG4')
	AADD( aCpoPerg, 'X1_CNT04' 	)
	AADD( aCpoPerg, 'X1_VAR05' 	)
	AADD( aCpoPerg, 'X1_DEF05' 	)
	AADD( aCpoPerg, 'X1_DEFSPA5')
	AADD( aCpoPerg, 'X1_DEFENG5')
	AADD( aCpoPerg, 'X1_CNT05' 	)
	AADD( aCpoPerg, 'X1_F3'		)
	AADD( aCpoPerg, 'X1_PYME' 	)
	AADD( aCpoPerg, 'X1_GRPSXG' )	
	AADD( aCpoPerg, 'X1_PICTURE')
	AADD( aCpoPerg, 'X1_IDFIL' 	)
	
	AADD( aCpoPerg, 'X1_VAR01' 	)
	AADD( aCpoPerg, 'X1_VARIAVL')


	DBSelectArea( "SX1" )
	DBSetOrder( 1 )
	For nX := 1 To Len( aPerg )
		
		If !DBSeek( PADR(cPerg,10) + aPerg[nX][1] )
			lAcao := .T.
		Else
			lAcao := .F.
		Endif

		RecLock( "SX1", lAcao )
			
			// Grava informacoes dos campos da SX1
			For nY := 1 To Len( aPerg[nX] )
				If aPerg[nX][nY] <> NIL

					If aCpoPerg[nY] == "X1_VARIAVL"
						SX1->X1_VARIAVL := "mv_ch" + Lower( Soma1( cValToChar(nY - 1), 1) )

					ElseIf aCpoPerg[nY] == "X1_VAR01"
						X1->X1_VAR01 := "mv_par" + aPerg[nX][1] //StrZero(nX, 2)
					
					Else
						SX1->( &( aCpoPerg[nY] ) ) := aPerg[nX][nY]
					EndIf
				EndIf
			Next
			SX1->X1_GRUPO := PADR(cPerg,10)
		
		MsUnlock() // Libera Registro
		
		// Verifica se campo possui Help
		_nPosHelp := aScan(aHelp,{|x| x[1] == aPerg[nX][1]}) 
		IF (_nPosHelp > 0)
			cNome := "P." + TRIM(cPerg) + aHelp[_nPosHelp][1] + "."
			PutSX1Help(cNome, aHelp[_nPosHelp][2], {}, {}, .T.)
		Else
			// Apaga help ja existente.
			cNome := "P." + TRIM(cPerg) + aPerg[nX][1] + "."
			PutSX1Help(cNome, {" "}, {}, {}, .T.)
		Endif
	Next

	// Apaga perguntas nao definidas no array
	DbSeek(cPerg, .T.)
	DO WHILE SX1->(!Eof()) .And. SX1->X1_GRUPO == cPerg
		IF ASCAN(aPerg, {|Y| Y[1] == SX1->X1_ORDEM}) == 0
			Reclock("SX1", .F.)
				SX1->(DBDELETE())
			Msunlock()
		ENDIF
		SX1->(DBSKIP())
	ENDDO
	
	RestArea( aArea ) 

Return Nil