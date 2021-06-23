#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

#DEFINE CRLF ( chr(13)+chr(10) )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออออออออออัอออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Programa           ณ RESPM001  ณ Rotina de exportacao/importacao de dados para interface Protheus X SAG   บฑฑ
ฑฑฬออออออออออออออออออออุอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออัอออออออออออนฑฑ
ฑฑบ Autor              ณ Descricoes                                                               ณ  Data     บฑฑ
ฑฑฬออออออออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออุอออออออออออนฑฑ
ฑฑบ www.cellvla.com.br ณ 1 -                                                                      ณ 25/02/13  บฑฑ
ฑฑศออออออออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฯอออออออออออผฑฑ
ฑฑบAdriana  ณ24/05/2019ณTI-Devido a substituicao email p/shared relay, substituido MV_RELACNT p/ MV_RELFROM   บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RESPM001(_cAliasX, _nAcao, _Regis, _lJob)

Local _lRet      := .T.
Local _cNomBco1  := GetPvProfString("INTSAGBD","BCO1","ERROR",GetADV97()) 
Local _cSrvBco1  := GetPvProfString("INTSAGBD","SRV1","ERROR",GetADV97()) 
Local _cPortBco1 := Val(GetPvProfString("INTSAGBD","PRT1","ERROR",GetADV97()) )
Local _cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97()) 
Local _cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97()) 
Local _cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
Local cPara      := SuperGetMV("MV_XMPARA" ,,"")
Local cCopia     := SuperGetMV("MV_XMCOPIA",,"")
Local cCpOcul    := SuperGetMV("MV_XMCPOCU",,"")
Local cAssunto   := SuperGetMV("MV_XMASSUN",,"Integracao Protheus X SAG")
Local cDe        := SuperGetMV("MV_XMAILDE",,"")
Local cMensag    := ""
Local lHtml      := .T.
Local cAnexo     := ""
Local _aTabelas  := {"SA1", "SA2", "SB1", "SBM", "SF2" , "SD2" }
Local _aCampos   := {"A1_MSEXP", "A2_MSEXP", "B1_MSEXP", "BM_MSEXP", "F2_MSEXP", "D2_MSEXP"}
Local _cEmpresa  := "99"                                           
Local _cFilial   := "01"
Local cMsgError  := ""         
Local cCposSA1 := "A1_FILIAL,A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_END,A1_PESSOA,A1_TIPO,A1_EST,A1_COD_MUN,A1_BAIRRO,A1_CEP,A1_DDD,A1_TEL,A1_FAX,A1_ENDCOB,A1_PAIS,A1_ENDREC,A1_ENDENT,A1_CGC,A1_INSCR,A1_INSCRM,A1_CONTA,A1_RECISS,A1_INCISS,A1_BAIRROC,A1_CEPC,A1_MUNC,A1_ESTC,A1_CEPE,A1_BAIRROE,A1_MUNE,A1_ESTE,A1_EMAIL,A1_CNAE,A1_RECINSS,A1_RECCOFI,A1_RECCSLL,A1_RECPIS,A1_ABATIMP,A1_RECIRRF,A1_RISCO,A1_MSEXP,R_E_C_N_O_ "

Default _cAliasX := ""
Default _nAcao   := 0
Default _Regis   := 0
Default _lJob    := .T.

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina de exportacao/importacao de dados para interface Protheus X SAG')

Return()

If !Empty(_cAliasX)
	If _cAliasX == "SF2"
		_aTabelas  := {"SF2" , "SD2" }
		_aCampos   := {"F2_MSEXP", "D2_MSEXP"}
	Else
		If (nPos  := Ascan(_aTabelas, { | x | AllTrim( x ) == _cAliasX })) <> 0
			_aCampos := {_aCampos[nPos]}
		EndIf
		_aTabelas := {_cAliasX}
	EndIf
EndIf

If _lJob == .F.
	ProcRegua(1000)
	IncProc("Conectando ao banco de produ็ใo","Conexใo")
Endif

TcConType("TCPIP")

_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1)
If _nTcConn1 < 0
	_lRet     := .F.
	cMsgError := "Nใo foi possํvel  conectar ao banco produ็ใo"
	
	If _lJob == .T.
		ConOut("Nใo foi possํvel  conectar ao banco produ็ใo, verifique com administrador","ERROR","ERROR")
	Else
		MsgInfo("Nใo foi possํvel  conectar ao banco produ็ใo, verifique com administrador","ERROR")
	EndIf
EndIf

_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2)
If _nTcConn2 < 0
	_lRet     := .F.
	cMsgError := "Nใo foi possํvel  conectar ao banco integra็ใo"
	
	If _lJob == .T.
		ConOut("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR","ERROR")
	Else
		MsgInfo("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR")
	EndIf
EndIf

If _lRet == .T.
	For _x1 := 1 To Len(_aTabelas)
		cTMP    := AllTrim(_aTabelas[_x1])
		_cCampo := AllTrim(_aCampos[_x1])
		
		TcSetConn(_nTcConn1)
		
		// ****************************** Seleciona registros para exportacao
		If _lJob == .F.
			IncProc("Selecionado dados para integra็ใo","Conexใo")
		Endif
		
		cAliasA := GetNextAlias()

		If cTMP == "SA1"
			cQuery  := "SELECT " + 	cCposSA1 + " FROM "+RetSqlName(cTMP)+" "+cTMP
		Else
			cQuery  := "SELECT * FROM "+RetSqlName(cTMP)+" "+cTMP
		EndIf

		If cTMP == "SD2"
			cQuery  += " "
		Else
			cQuery  += " WHERE "+cTMP+"."+_cCampo+" = '"+CriaVar(_cCampo,,.F.) +"'"
		EndIf
		
		If _lJob == .F. .OR. ISINCALLSTACK("U_INTERCAD")
			If cTMP == "SD2"
				cQuery  += " WHERE D2_FILIAL  = '"+ SF2->F2_FILIAL +"'"
				cQuery  += "   AND D2_DOC     = '"+ SF2->F2_DOC    +"'"
				cQuery  += "   AND D2_SERIE   = '"+ SF2->F2_SERIE  +"'"
				cQuery  += "   AND D2_CLIENTE = '"+ SF2->F2_CLIENTE+"'"
				cQuery  += "   AND D2_LOJA    = '"+ SF2->F2_LOJA   +"'"
				If _nAcao <> 5
					cQuery  += " AND D_E_L_E_T_ = ' '"
				Endif
			Else
				cQuery  += " AND R_E_C_N_O_ = "+AllTrim(Str(_Regis))+""
			Endif
		Endif
		cQuery  := ChangeQuery(cQuery)
		
		DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasA , .F., .T.)
		aEval( (cAliasA)->(DbStruct()),{|x| If(x[2] != "C", TcSetField(cAliasA, AllTrim(x[1]), x[2], x[3], x[4]),Nil)})
		(cAliasA)->(DbGoTop())
		aStruPrd := (cAliasA)->(DbStruct())
		
		// ****************************** Conecta o banco de integracao
		If _lJob == .F.
			IncProc("Conectando ao banco de integra็ใo","Conexใo")
		Endif
		
		TcSetConn(_nTcConn2)
		
		// ****************************** Verifica se existe tabela SQL
		cAliasB := GetNextAlias()
		cQuery  := " SELECT * FROM sys.sysobjects WHERE XTYPE = 'U' AND NAME = '"+RetSqlName(cTMP)+"'"
		DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasB , .F., .T.)
		
		cNameTable := (cAliasB)->Name
		
		(cAliasB)->(DbCloseArea())
		
		If Empty(cNameTable)
			_lRet     := .F.
			cMsgError := "Nใo foi possํvel  encontrar tabela "+RetSqlName(cTMP)+"  no banco de integra็ใo
			
			If _lJob == .T.
				ConOut("Nใo foi possํvel  encontrar tabela "+RetSqlName(cTMP)+" no banco de integra็ใo, verifique com administrador","ERROR","ERROR")
			Else
				MsgInfo("Nใo foi possํvel  encontrar tabela "+RetSqlName(cTMP)+"  no banco de integra็ใo, verifique com administrador","ERROR")
			EndIf
		Else
			// ****************************** Valida estrutura das tabelas
			nTotReg := 0
			cAliasC := GetNextAlias()
			
			If cTMP == "SA1"
				cQuery  := "SELECT " + 	cCposSA1 + " FROM "+RetSqlName(cTMP)+" "+cTMP
			Else
				cQuery  := "SELECT * FROM "+RetSqlName(cTMP)+" "+cTMP
			EndIf           
			
			cQuery  := ChangeQuery(cQuery)
			
			DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasC , .F., .T.)
			aEval( (cAliasC)->(DbStruct()),{|x| If(x[2] != "C", TcSetField(cAliasC, AllTrim(x[1]), x[2], x[3], x[4]),Nil)})
			(cAliasC)->(DbGoTop())
			aStruInt := (cAliasC)->(DbStruct())
			
			DbSelectArea( cAliasA )
			(cAliasA)->( DbEval( { || nTotReg++ },,{ || !Eof() } ) )
			(cAliasA)->( DbGoTop() )
			

			nErrStru := 0
			If cTMP <> "SA1"			
				For _n1 := 1 to Len(aStruPrd)
					If (nPos := Ascan(aStruInt, { | x | AllTrim( x[ 1 ] ) == aStruPrd[_n1,1]  })) <> 0
						If aStruPrd[_n1,2] <> aStruInt[nPos,2] .or. aStruPrd[_n1,3] <> aStruInt[nPos,3] .or. aStruPrd[_n1,4] <> aStruInt[nPos,4]
							nErrStru++
						EndIf
					Else
						nErrStru++
					EndIf
				Next _n1
			EndIf
			
			If nErrStru <> 0
				_lRet     := .F.
				cMsgError := "Diverg๊ncia na estrutura das tabelas"
				
				If _lJob == .T.
					ConOut("Diverg๊ncia na estrutura das tabelas, verifique com administrador","ERROR","ERROR")
				Else
					MsgInfo("Diverg๊ncia na estrutura das tabelas, verifique com administrador","ERROR")
				EndIf
			Else
				// ****************************** Exporta registro para base intergracao e grava MSEXP
				cCampos := ""
				aEval( aStruPrd , { | x | cCampos += ',' + x[1]  } )
				cCampos := Right( Alltrim(cCampos), Len(Alltrim(cCampos))-1)
				cCampos += ", STATUS_INT, OPERACAO_INT, MENSAGEM_INT "
				
				cValores := ""
				aEval( aStruPrd , { | x | cValores += ',' + iif(Alltrim(x[1]) == _cCampo, "'"+DtoS(dDataBase)+"'" , Iif( valType((cAliasA)->&(x[1])) == "N", Str((cAliasA)->&(x[1])), Iif( valType((cAliasA)->&(x[1])) == "D", "'"+DtoS((cAliasA)->&(x[1]))+"'", "'"+STRTRAN((cAliasA)->&(x[1]),"'","")+"'" ))) } )
				cValores := Right( Alltrim(cValores), Len(Alltrim(cValores))-1)
				
				cStatus   := ",'I'"                                                          // STATUS_INT   = I = Novo; S = Sucesso  ; E = Erro
				cOperacao := ",'"+Iif(_nAcao == 3, "I", Iif(_nAcao == 4, "A", "E" ))+"'"	 // OPERACAO_INT = I = Novo; A = Alteracao; E = Exclusao
				cMensagem := ",'"+cMsgError+"'"                                              // MENSAGEM_INT
				
				nContErro := 0
				cValores  := AllTrim(cValores) + cStatus + cOperacao + cMensagem 
				
				(cAliasA)->(DbGoTop())
				While (cAliasA)->(!Eof())
					If _lJob == .F.
						IncProc("Executando integra็ใo","Conexใo")
					Endif
					
					cMensagem := ""
					
					cQuery  := " INSERT INTO "+RetSqlName(cTMP)
					cQuery  += " ("+cCampos +")"
					cQuery  += " VALUES ("+cValores+")"
					
					TcSetConn(_nTcConn2)
					
					If TcSqlExec( cQuery ) <> 0
						cMensagem := TCSQLError()
						_lRet     := .F.
						cMsgError := "Erro ao executar integra็ใo"
						
						If _lJob == .T.
							ConOut("Erro ao executar integra็ใo, verifique com administrador","ERROR","ERROR")
						Else
							MsgInfo("Erro ao executar integra็ใo, verifique com administrador","ERROR")
						EndIf
						nContErro++
					EndIf
					
					// ****************************** Grava erro na tabela de LOG
					TcSetConn(_nTcConn1)
					SET DELETED ON
					
					If !Empty(cMensagem)
						RecLock("ZA1",.T.)
						ZA1->ZA1_TABELA := cTMP
						ZA1->ZA1_REGISTR:= (cTMP)->(Recno())
						ZA1->ZA1_ACAO   := Iif(_nAcao == 3, "I", Iif(_nAcao == 4, "A", "E" ))
						ZA1->ZA1_DATA   := dDataBase
						ZA1->ZA1_HORA   := Time()
						ZA1->ZA1_MENSAG := cMensagem
						ZA1->ZA1_USER   := SubStr(cusuario,7,15)
						ZA1->(MsUnLock())
						
						RecLock(cTMP,.F.)
						(cTMP)->&(_cCampo) := DtoS(CtoD(""))
						(cTMP)->(MsUnLock())
					Else
						RecLock(cTMP,.F.)
						(cTMP)->&(_cCampo) := DtoS(dDataBase)
						(cTMP)->(MsUnLock())
					EndIf
					SET DELETED OFF
			
					(cAliasA)->(DbSkip())
				End-While
			EndIf
			
			(cAliasA)->(DbCloseArea())
		EndIf
	Next
EndIf

TcUnLink(_nTcConn1)
TcUnLink(_nTcConn2)

If !Empty(cMsgError) .Or. nContErro > 0
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
	
	cMensag := cHtml
	
	M001MAIL(cPara,cCopia,cCpOcul,cAssunto,cDe,cMensag,lHtml,cAnexo,_lJob)
EndIf

Return(_lRet)

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

Static Function M001MAIL(cPara,cCopia,cCpOcul,cAssunto,cDe,cMensag,lHtml,cAnexo,_lJob)

Local lOk       := .F.
Local cAccount  := SuperGetMv("MV_RELACNT",,"")
Local cPassword := SuperGetMv("MV_RELPSW" ,,"")
Local cServer   := SuperGetMv("MV_RELSERV",,"")

Default cPara   := ""
Default cCopia  := ""
Default cCpOcul := ""
Default cAssunto:= ""
Default cDe     := Iif(ValType(cDe)="U",.F.,AllTrim(GetMv("MV_RELFROM"))) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
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