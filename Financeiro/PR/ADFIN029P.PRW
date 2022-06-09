#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"  
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN029P ºAutor  ³Sigoli              º Data ³29/03/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio - Situação de Pedidos no Financeiro               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro/Comercial                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAdriana     ³24/05/2019³TI-Devido a substituicao email para shared     º±±
±±º            ³          ³relay, substituido MV_RELACNT p/ MV_RELFROM    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
User Function ADFIN029P() 

Local cTipo 	  := ""
Local cVendSuper  := "" 
Local aArea       := GetArea()

nOrden = IndexOrd()  //GUARDO A ORDEM DO INDICE             
nRecno := Recno()

     
Private cCATEIRA  := ""
Private cVendedor := ""
Private cSupUsu   := ""

If !(Alltrim(FunName()) == "MATA440") .and. !(Alltrim(FunName()) == "MATA410")   &&nao sendo chamado pela rotina é porque é schedulada...
	
	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //
	RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
	RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //
	
	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADFIN029P", .T., .F.)
		ConOut("[ADFIN029P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	//	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	ConOut("INICIO DO SCHEDULE ADFIN029P" + '||' + DTOC(DATE()) + '||' + TIME())
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio - Situação de Pedidos no Financeiro')

	logZBN("1") //Log início.

	MV_PAR01 := Date()
	MV_PAR02 := Date() + 3         //Conforme definido Sr. Reginaldo para schedule
	
	RunProcRel()			
	
Else
    
    If (Alltrim(FunName()) == "MATA410")
    	
    	cCodUser  := RetCodUsr() //pega codigo do usuario logado 
    	cVendedor := Posicione("SA3",7,xFilial("SA3")+alltrim(cCodUser),"A3_COD")  //verifico se esta cadastrado como vendedor
    	cSupUsu   := Supervend(cCodUser)
    
		If !Empty(Alltrim(cSupUsu))
 			cCATEIRA := "SUPERVISOR" 
   		ElseIf !Empty(cVendedor)
   			cCATEIRA := "REPRESENTANTE" 
   		Endif	
    
    Endif
   	
   	cPerg := "ADF029P"
	ValidPerg(cPerg)

	
	IF Pergunte(cPerg,.T.)		
	   
	   If DateDiffDay( MV_PAR01, MV_PAR02) > 10   //coloquei essa trava, para nao estourar o Buffer
	   		Alert("Relatorio permitido para até 10 dias do periodo de entrega")
        	Return()	   
	   EndIf
       
	   If MsgBox("Gerar Relatorio de situação de pedidos no financeiro?","Confirme","YESNO") //chamado 035745 - Fernando Sigoli 14/06/2017
			   msAguarde({||RunProcRel()},"Relatório","Aguarde. Gerando relatório...",.T.)
	   Else	   
		  Return()	   
	   EndIf
	
	EndIf
		
Endif

If !(Alltrim(FunName()) == "MATA440") .and. !(Alltrim(FunName()) == "MATA410")   &&nao sendo chamado pela rotina é porque é schedulada...
	
	ConOut("FINAL DO SCHEDULE ADFIN029P" + '||' + DTOC(ddatabase) + '||' + TIME())

	logZBN("2") //Log fim.

	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //
	RpcClearEnv()
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADFIN029P")

Endif

RestArea(aArea)

If (Alltrim(FunName()) == "MATA440") .or. (Alltrim(FunName()) == "MATA410") //chamado 035745 - Fernando Sigoli 14/06/2017
	MsgAlert("Processo Finalizado")
EndIf

Return

&& gera relatorio
Static Function RunProcRel()

Local dtEntrega		:= mv_par01
Local dtEntreg2		:= mv_par02
Local cListaEmail	:= "" 
Local cQuery 		:= ""
Local cBuffer		:= ""
Local cSuper		:= ""
Local cRepres		:= ""
Local cEmailSup		:= ""
Local cEmailRep		:= ""
Local cArq			:= ""
Local cEmailA		:= ""
Local lEnviar 		:= .F.
Local nSubPed		:= 0
Local nSubCor		:= 0
Local nTotPed		:= 0
Local nTotCor		:= 0
Local nSupervisor	:= 0
Local cRepresenta   := ""
Local cNumFilial    := Substr(CNUMEMP,3,2)
        
Local cFile     	:= ""
Local arq       	:= ""
Local cArqName  	:= ""
Local cTitulo   	:= ""
Local lFile           
Local cEmailCred    := Alltrim(GETMV("MV_#LISTPD"))

Local _nx

Private cString		:= ""
Private cNomeUser 	:= Alltrim(UsrRetName(__CUSERID))

IF !(Substr(cEmailCred,Len(cEmailCred),1) == ";")
   cEmailCred += ";"
Endif   

cFile := "C:\TEMP\"
      
// FAZ A BUSCA NO BANCO DE DADOS
cQuery := " SELECT "
cQuery += " fontes.PED, "
cQuery += " fontes.CLI, "
cQuery += " fontes.LOJ, "
cQuery += " fontes.CLIENTE, "

cQuery += " sum(fontes.QTDCX) as QTDCX, "       
cQuery += " sum(fontes.QTDKG) as QTDKG, "

cQuery += " sum(fontes.CXORIG) as CXORIG, "
cQuery += " sum(fontes.KGORIG) as KGORIG, "

cQuery += " sum(fontes.VLTOT)  as VLTOT, "

cQuery += " fontes.VEND		   as VEND , "
cQuery += " fontes.REPRES      as 'REPRES', "
cQuery += " fontes.SUPER       as SUPER,  "
cQuery += " fontes.DESCSUP     as DESCSUP,  "
cQuery += " fontes.C5_XPREAPR  as 'SITUA', "

cQuery += " fontes.C9_PEDIDO as C9PED, "
cQuery += " fontes.CREDITO   as C9CRED, "
cQuery += " fontes.ESTOQUE   as C9EST, "

cQuery += " fontes.EXC "

cQuery += " from "

cQuery += " (SELECT "
cQuery += " distinct(C6_PRODUTO) AS PROD, "
cQuery += " C6_NUM as PED, "
cQuery += " C6_CLI AS CLI, "
cQuery += " C6_LOJA AS LOJ, "
cQuery += " C5_NOMECLI AS CLIENTE, "

cQuery += " C6_QTDORI2 AS CXORIG, "
cQuery += " C6_QTDORI AS KGORIG, "

cQuery += " C6_UNSVEN  AS QTDCX, "
cQuery += " C6_QTDVEN  AS QTDKG, "

cQuery += " C6_VALOR   AS VLTOT, "

cQuery += " ISNULL(SC9.C9_PEDIDO,'') AS C9_PEDIDO, "
cQuery += " ISNULL(SC9.C9_BLCRED,'  ') AS CREDITO, "
cQuery += " ISNULL(SC9.C9_BLEST,'  ') AS ESTOQUE,  "

cQuery += " C5_VEND1 AS VEND, "
cQuery += " A3_NOME  AS 'REPRES', "
cQuery += " SZR.ZR_USER AS SUPER, "
cQuery += " SZR.ZR_DESCRIC AS DESCSUP, "
cQuery += " SC5.D_E_L_E_T_ AS EXC, "
cQuery += " C5_NOTA AS NOTA, "
cQuery += " C5_SERIE AS SERIE, "
cQuery += " C5_XPREAPR, "
cQuery += " CASE WHEN  SC5.D_E_L_E_T_ = '' and SC6.D_E_L_E_T_ = '*' THEN '1'  ELSE '2' END FLAG "

cQuery += " FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK)"

cQuery += " LEFT JOIN "+RetSqlName("SC9")+" SC9 WITH (NOLOCK)"
cQuery += " ON  SC6.C6_FILIAL = SC9.C9_FILIAL "
cQuery += " AND SC6.C6_NUM    = SC9.C9_PEDIDO "
cQuery += " AND SC6.C6_CLI    = SC9.C9_CLIENTE "
cQuery += " AND SC6.C6_LOJA   = SC9.C9_LOJA "
cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' " 

cQuery += " INNER JOIN  "+RetSqlName("SC5")+" SC5 WITH (NOLOCK)"
cQuery += " ON  SC6.C6_FILIAL  = SC5.C5_FILIAL "
cQuery += " AND SC6.C6_NUM     = SC5.C5_NUM "
cQuery += " AND SC6.C6_CLI     = SC5.C5_CLIENTE "
cQuery += " AND SC6.C6_LOJA    = SC5.C5_LOJACLI "

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK)"
cQuery += " ON SC5.C5_VEND1 = SA3.A3_COD "
cQuery += " AND SA3.D_E_L_E_T_ <> '*' "

cQuery += " INNER JOIN "+RetSqlName("SZR")+" SZR WITH (NOLOCK)"
cQuery += " ON SA3.A3_CODSUP = SZR.ZR_CODIGO "
cQuery += " AND SZR.D_E_L_E_T_ <> '*' "

cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK)"
cQuery += " ON SC6.C6_TES       = SF4.F4_CODIGO "
cQuery += " AND SF4.D_E_L_E_T_  <> '*' "
cQuery += " AND SF4.F4_DUPLIC   = 'S' "
cQuery += " WHERE SC6.C6_FILIAL = '"+cNumFilial+"' "   //pega a filial que esta logada e nao posicionada
cQuery += " AND SC5.C5_DTENTR   >= '"+DTOS(MV_PAR01)+"' AND  SC5.C5_DTENTR     <= '"+DTOS(MV_PAR02)+"' "   

If cCATEIRA == "REPRESENTANTE" 
	cQuery += " AND SC5.C5_VEND1 = '"+Alltrim(cVendedor)+"' "
Endif

If cCATEIRA == "SUPERVISOR" 
	cQuery += " AND SA3.A3_CODSUP = '"+Alltrim(cSupUsu)+"' "
Endif 

cQuery += " ) as fontes "
cQuery += " WHERE FLAG <> '1' "

cQuery += " group by fontes.PED,fontes.CLI,fontes.CLIENTE,fontes.LOJ, fontes.C9_PEDIDO,fontes.CREDITO,fontes.ESTOQUE, "
cQuery += " fontes.VEND,fontes.REPRES,fontes.SUPER,fontes.DESCSUP,fontes.C5_XPREAPR, fontes.EXC "

cQuery1 := cQuery
cQuery1 += " ORDER BY fontes.SUPER,fontes.VEND, fontes.PED, fontes.C5_XPREAPR , fontes.CREDITO DESC, fontes.ESTOQUE DESC "

cQuery  += " ORDER BY fontes.VEND,fontes.SUPER, fontes.PED, fontes.C5_XPREAPR , fontes.CREDITO DESC, fontes.ESTOQUE DESC "

TcQuery cQuery new alias "DADOV"            &&ordem por vendedor,superivsor

TcQuery cQuery1 new alias "DADOS"           &&ordem por Supervisor,vendedor

DbSelectArea("DADOS")
DbGotop() 

//chamado 035745 - Fernando Sigoli 14/06/2017
If (Alltrim(FunName()) == "MATA440") .or. (Alltrim(FunName()) == "MATA410")
	If DADOS->(Eof())
		MsgAlert("Nao existem Pedidos a serem gerados!!!")
	EndIf 
EndIF	

//-------------------------------------------|
&&primeira passagem por supervisor           |
//-------------------------------------------|
If Empty(cCATEIRA) .or. cCATEIRA == "SUPERVISOR"

While !DADOS->(EOF())
	
	_cSuper  := DADOS->(SUPER)
	_cDescSP := DADOS->(DESCSUP)
	
	If (Alltrim(FunName()) == "MATA410") .and. cCATEIRA == "SUPERVISOR" 
		lEnviar  := .T.
	EndIf
	
	// FAZ O CABEÇALHO DO HTML
	cBuffer := "<html>"
	cBuffer += "<head></head>"
	cBuffer += "<body>"
	cBuffer += "<span style='font-family: Arial; font-size: 18px; font-weight: bold;'>Relatorio - Situação de Pedidos no Financeiro </span><br /><br />"
	
	// Mostra Data de Entrega
	cBuffer += "Entrega dia: <span style='font-weight: bold;'>"+DTOC(dtEntrega)+" à "+DTOC(dtEntreg2)+"</span><br />"
	// Mostra o usuario logado
	cBuffer += "Supervisor : <span style='font-weight: bold;'>"+_cSuper+" - "+_cDescSP+"</span><br /><br />"
	
	_aLiber := {}
	_aBloq  := {}
	_aExc   := {}
	_aPend  := {}
	_cPed   := ""
	
	While DADOS->(!EOF()) .And. _cSuper == DADOS->(SUPER)  &&Supervisor
	    if DADOS->(PED) == _cPed   &&tratamento porque o select ira repetir registros por conta do SC9(itens)
	       DADOS->(dbSkip())
	       loop
	    Endif
	    _cPed := DADOS->(PED) 
		
		If DADOS->(EXC) == "*" && excluido
		   
			_nAscan := Ascan( _aExc, { |x|x[ 01 ] == DADOS->(PED) } )
			If _nAscan <= 00
				_cMot := fbscMot(DADOS->(PED),DADOS->(CLI),DADOS->(LOJ))
				
				If Empty(_cMot) 
					_cMot := fSZDMot(DADOS->(PED),DADOS->(CLI),DADOS->(LOJ))
			    EndIF
				
				AADD(_aExc,{DADOS->(PED),DADOS->(CLI)+"-"+DADOS->(LOJ)+"-"+DADOS->(CLIENTE),CVALTOCHAR(DADOS->(QTDCX)),CVALTOCHAR(DADOS->(QTDKG)),CVALTOCHAR(Transform(DADOS->(VLTOT),"@E 99999999.99")),DADOS->(VEND)+"-"+SUBSTR(DADOS->(REPRES),1,35),_cMot})
			Endif
		
		Elseif DADOS->(SITUA) == "L"    && liberado
		
			_nAscan := Ascan( _aliber, { |x|x[ 01 ] == DADOS->(PED) } )
			If _nAscan <= 00
				AADD(_aliber,{DADOS->(PED),DADOS->(CLI)+"-"+DADOS->(LOJ)+"-"+DADOS->(CLIENTE),CVALTOCHAR(DADOS->(QTDCX)),CVALTOCHAR(DADOS->(QTDKG)),CVALTOCHAR(Transform(DADOS->(VLTOT),"@E 99999999.99")),DADOS->(VEND)+"-"+SUBSTR(DADOS->(REPRES),1,35)})
			Endif
		
		Elseif DADOS->(SITUA) == "B"   && bloqueado
		
			_nAscan := Ascan( _aBloq, { |x|x[ 01 ] == DADOS->(PED) } )
		
			If _nAscan <= 00
			   _cMot := ""
			   DbSelectArea("ZBH")
			   DbSetOrder(1)
			   If dbseek(xFilial("ZBH")+DADOS->(PED)) 
			   
			      _cMot := Alltrim(ZBH->ZBH_MOTIVO)
			   
			   Endif 
			   
			   If Empty(_cMot) 
					
					_cMot := fbscMot(DADOS->(PED),DADOS->(CLI),DADOS->(LOJ))
			        
			        If Empty(_cMot) 
						_cMot := "EM ANALISE"
			        EndIF
			        
			   EndIF
			   AADD(_aPend,{DADOS->(PED),DADOS->(CLI)+"-"+DADOS->(LOJ)+"-"+DADOS->(CLIENTE),CVALTOCHAR(DADOS->(QTDCX)),CVALTOCHAR(DADOS->(QTDKG)),CVALTOCHAR(Transform(DADOS->(VLTOT),"@E 99999999.99")),DADOS->(VEND)+"-"+SUBSTR(DADOS->(REPRES),1,35),_cMot})
			    
			   //AADD(_aBloq,{DADOS->(PED),DADOS->(CLI)+"-"+DADOS->(LOJ)+"-"+DADOS->(CLIENTE),CVALTOCHAR(DADOS->(QTDCX)),CVALTOCHAR(DADOS->(QTDKG)),CVALTOCHAR(Transform(DADOS->(VLTOT),"@E 99999999.99")),DADOS->(VEND)+"-"+SUBSTR(DADOS->(REPRES),1,35),_cMot})
			Endif
		
		Elseif Empty(DADOS->(SITUA))
			
			If DADOS->(C9CRED) == "01" .Or. DADOS->(C9EST) == "02"
			
				_nAscan := Ascan( _aBloq, { |x|x[ 01 ] == DADOS->(PED) } )
				If _nAscan <= 00		
		   	   		_cMot := ""
			   		DbSelectArea("ZBH")
			   		DbSetOrder(1)
			   		If dbseek(xFilial("ZBH")+DADOS->(PED)) 
			   			_cMot := Alltrim(ZBH->ZBH_MOTIVO)
			   		Endif 
			   		
			   		 If Empty(_cMot) 
					
						_cMot := fbscMot(DADOS->(PED),DADOS->(CLI),DADOS->(LOJ))
				        
				        If Empty(_cMot) 
							_cMot := "BLOQUEADO CREDITO/ESTOQUE"
				        EndIF
				        
			   		EndIF
				    
				    //AADD(_aBloq,{DADOS->(PED),DADOS->(CLI)+"-"+DADOS->(LOJ)+"-"+DADOS->(CLIENTE),CVALTOCHAR(DADOS->(QTDCX)),CVALTOCHAR(DADOS->(QTDKG)),CVALTOCHAR(Transform(DADOS->(VLTOT),"@E 99999999.99")),DADOS->(VEND)+"-"+SUBSTR(DADOS->(REPRES),1,35),_cMot})
				
				    AADD(_aPend,{DADOS->(PED),DADOS->(CLI)+"-"+DADOS->(LOJ)+"-"+DADOS->(CLIENTE),CVALTOCHAR(DADOS->(QTDCX)),CVALTOCHAR(DADOS->(QTDKG)),CVALTOCHAR(Transform(DADOS->(VLTOT),"@E 99999999.99")),DADOS->(VEND)+"-"+SUBSTR(DADOS->(REPRES),1,35),_cMot})
			    
			    EndIf
			    
			Else
				If !Empty(DADOS->(C9PED))
			   		
			   		_nAscan := Ascan( _aliber, { |x|x[ 01 ] == DADOS->(PED) } )
					If _nAscan <= 00
					AADD(_aliber,{DADOS->(PED),DADOS->(CLI)+"-"+DADOS->(LOJ)+"-"+DADOS->(CLIENTE),CVALTOCHAR(DADOS->(QTDCX)),CVALTOCHAR(DADOS->(QTDKG)),CVALTOCHAR(Transform(DADOS->(VLTOT),"@E 99999999.99")),DADOS->(VEND)+"-"+SUBSTR(DADOS->(REPRES),1,35)})
					Endif
			   	
			   	Else
					_nAscan := Ascan( _aPend, { |x|x[ 01 ] == DADOS->(PED) } )
					If _nAscan <= 00
						_cMot := ""
				   		DbSelectArea("ZBH")
				   		DbSetOrder(1)
				   		If dbseek(xFilial("ZBH")+DADOS->(PED)) 
				   			_cMot := Alltrim(ZBH->ZBH_MOTIVO)
				   		Endif 
				   		
				   		
					   If Empty(_cMot) 
							
							_cMot := fbscMot(DADOS->(PED),DADOS->(CLI),DADOS->(LOJ))
					        
					        If Empty(_cMot) 
								_cMot := "EM ANALISE"
					        EndIF
					        
					   EndIF
	
						AADD(_aPend,{DADOS->(PED),DADOS->(CLI)+"-"+DADOS->(LOJ)+"-"+DADOS->(CLIENTE),CVALTOCHAR(DADOS->(QTDCX)),CVALTOCHAR(DADOS->(QTDKG)),CVALTOCHAR(Transform(DADOS->(VLTOT),"@E 99999999.99")),DADOS->(VEND)+"-"+SUBSTR(DADOS->(REPRES),1,35),_cMot})
					
					Endif
			   	
			   	EndIf
			   
			Endif
		
		Endif
		
	DADOS->(dbSkip())
	Enddo
	
	If Len(_aExc) > 0 && Pedido(s) Excluido(s) 
			
		cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
		cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='6' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Excluido(s): "+_aExc[1][6]+" </td></tr>"
		cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"  
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>"  
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>MOTIVO</td></tr>"
		
		For _nx := 1 To len(_aExc)
		
			If cRepresenta = _aExc[_nx][6] .or. _nx = 1 
			
				cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][1]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][2]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][3]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][4]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][5]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][7]+"</td></tr>"
			
				cRepresenta := _aExc[_nx][6]    
		    
		    Else  
		    	If _nx <= len(_aExc)
		    	 
		    		cBuffer += "</table>"                                    
					cBuffer += "<br> </br>" 
				
	    			cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
					cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='6' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Excluido(s): "+_aExc[_nx][6]+" </td></tr>"
					cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>" 
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>"  
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>MOTIVO</td></tr>"
		            
		   			cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][1]+"</td>"                                                                                                                            
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][2]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][3]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][4]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][5]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][7]+"</td></tr>"
		        
		   			cRepresenta := _aExc[_nx][6]    
		        EndIF
		        
		   EndIF
		    
		Next _nx
		cBuffer += "</table>"                                    
		cBuffer += "<br></br>" 
				
	
	Endif
	
	If Len(_aLiber) > 0 &&Pedido(s) Liberado(s)
		
		cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
		cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='5' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Liberado(s): "+_aLiber[1][6]+" </td></tr>"
		cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
		
		For _nx := 1 To len(_aLiber)
		   
			If cRepresenta = _aLiber[_nx][6] .or. _nx = 1 
			
				cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aLiber[_nx][1]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aLiber[_nx][2]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aliber[_nx][3]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aliber[_nx][4]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aLiber[_nx][5]+"</td>"
		 	
		 		cRepresenta := _aLiber[_nx][6]   
		    
		    Else
		    	If _nx <= len(_aLiber)
			    
			    	cBuffer += "</table>"
					cBuffer += "<br></br>"
			    	
			    	cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
					cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='5' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Liberado(s): "+_aLiber[_nx][6]+" </td></tr>"
					cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
			        
			        cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
			   		cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aLiber[_nx][1]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aLiber[_nx][2]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aliber[_nx][3]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aliber[_nx][4]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aLiber[_nx][5]+"</td>"
				
	   				cRepresenta := _aLiber[_nx][6]
		        
		        EndIF
		        
		    EndIF
		Next _nx
		
		cBuffer += "</table>"
		cBuffer += "<br /br>"
	
	Endif
	/*
	If Len(_aBloq) > 0 &&Pedido(s) Bloqueados(s)
	    
	   	cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
		cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='6' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Bloqueados(s): "+_aBloq[1][6]+" </td></tr>"
		cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>MOTIVO DO BLOQUEIO</td></tr>"
		
		For _nx := 1 To len(_aBloq)
		
			If cRepresenta = _aBloq[_nx][6] .or. _nx = 1 
			
				cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][1]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][2]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][3]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][4]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][5]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][7]+"</td></tr>"
		         
		    	cRepresenta = _aBloq[_nx][6]
		    	
		    Else
		    
		    	If _nx <= len(_aBloq)
			    	    
			        cBuffer += "</table>"
					cBuffer += "<br></br>"
			
			    	cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
					cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='6' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Bloqueados(s): "+_aBloq[_nx][6]+" </td></tr>"
					cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>MOTIVO</td></tr>"
					
					cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][1]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][2]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][3]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][4]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][5]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][7]+"</td></tr>"

		    		cRepresenta = _aBloq[_nx][6]
		    	
		    	EndIf
		    EndIf
		Next _nx
		
		cBuffer += "</table>"
		cBuffer += "<br></br>"
		
	Endif
	*/
	
	If Len(_aPend) > 0 &&Pedido(s) Em Analise
	   	
	   	cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
		cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='6' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Em Analise: "+_aPend[1][6]+" </td></tr>"
		cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"  
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>"  
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>MOTIVO</td></tr>"
		
		For _nx := 1 To len(_aPend)
		                                                      
			If cRepresenta = _aPend[_nx][6] .or. _nx = 1 
		
				cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][1]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][2]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][3]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][4]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][5]+"</td>"
				cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][7]+"</td>"
				
				cRepresenta := _aPend[_nx][6]
			
			Else
				
				If _nx <= len(_aPend)
			    
			   		cBuffer += "</table>"
					cBuffer += "<br></br>"
				
					cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
					cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='6' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Em Analise: "+_aPend[_nx][6]+" </td></tr>"
					cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>"
					cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
				    cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>MOTIVO</td></tr>"
		
				   	cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][1]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][2]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][3]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][4]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][5]+"</td>"
					cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][7]+"</td>"
				
					cRepresenta := _aPend[_nx][6]
			    EndIf
			    
			EndIF                            
			
		Next _nx
		
		cBuffer += "</table>"
		cBuffer += "<br></br>"
		
	Endif
	
	If !lEnviar
		
		//ENVIA O EMAIL COM TODOS OS DADOS DOS REPRESENTANTES DE UM SUPERVISOR para o supervisor						                        
		If Alltrim(GETMV("MV_#ENVIA")) == '.T.' 
			cListaEmail += alltrim(UsrRetMail(_cSuper)) 
		EndIf
			
		cEmailA := "Relatorio - Situação de Pedidos no Financeiro - Supervisor - " + _cSuper+" - "+_cDescSP
		
		IF ALLTRIM(cListaEmail) <> ""
		 	MsAguarde({||	U_enviaremail(allTrim(cEmailCred+";"+cListaEmail), cEmailA, cBuffer,,)},"Relatório","Aguarde. Enviando Email...",.T.)
			cListaEmail := ""
		ENDIF
	
	Else			
	
		folder      := cFile
    	arq         := "Relatorio_Pedidos_Financeiro.html"
    	cArqName    := folder+arq
    
    	lFile := Fcreate(cArqName)
    	fWrite(lFile, cBuffer)
    	fClose(lFile)
    	//sleep(1000)
                  
	    If  FILE(Alltrim("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe "))
	        WinExec("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe "+cArqName)
	    ElseIf  FILE(Alltrim("C:\Program Files\Google\Chrome\Application\chrome.exe "))
	        WinExec("C:\Program Files\Google\Chrome\Application\chrome.exe "+cArqName)
	    ElseIf  FILE(Alltrim("C:\Program Files (x86)\Mozilla Firefox\firefox.exe "))
	        WinExec("C:\Program Files (x86)\Mozilla Firefox\firefox.exe "+cArqName)
	    ElseIf  FILE(Alltrim("C:\Program Files\Mozilla Firefox\firefox.exe "))
	        WinExec("C:\Program Files\Mozilla Firefox\firefox.exe "+cArqName)
	    ElseIf  File(Alltrim("C:\Program Files (x86)\Internet Explorer\iexplore.exe "))
	        WinExec("C:\Program Files (x86)\Internet Explorer\iexplore.exe "+cArqName)
	    Else
	        WinExec("C:\Program Files\Internet Explorer\iexplore.exe "+cArqName)
	    EndIf 
	    
    EndIf
	
	//sigoli
	lEnviar == .F.
Enddo

Endif

//---------------------------------------------------------------------------------|
// Aqui inicia o relatorio para os vendedores. Apontando para o primeiro #Registro |
//---------------------------------------------------------------------------------|
If Empty(cCATEIRA) .or. cCATEIRA == "REPRESENTANTE"

DBSELECTAREA("DADOV")
DBGOTOP()

cRepres := ""
lEnviar := .F.
nSubPed := 0
nSubCor := 0

&&dados por vendedor
While !DADOV->(EOF())
	_cVend := DADOV->(VEND)
	
	If (Alltrim(FunName()) == "MATA410") .and. cCATEIRA == "REPRESENTANTE" 
		lEnviar  := .T.
	EndIf

	//-------------------------------------------|
	// FAZ O CABEÇALHO DO HTML PARA O VENDEDOR   |
	//-------------------------------------------|
	cBuffer := ""
	cBuffer += "<html>"
	cBuffer += "<head></head>"
	cBuffer += "<body>"
	cBuffer += "<span style='font-family: Arial; font-size: 18px; font-weight: bold;'> Relatorio - Situação de Pedidos no Financeiro </span><br /><br />"
	
	// Mostra Data de Entrega
	cBuffer += "Entrega dia: <span style='font-weight: bold;'>"+DTOC(dtEntrega)+" à "+DTOC(dtEntreg2)+"</span><br />"
	
	cBuffer += "Vendedor : <span style='font-weight: bold;'>"+_cVend+" - "+POSICIONE("SA3",1,XFILIAL("SA3")+_cVend,"A3_NOME")+"</span><br /><br />"
	
	_aLiber := {}
	_aBloq  := {}
	_aExc   := {}
	_aPend  := {}
	_cPed   := ""
	
	While DADOV->(!Eof()) .And. _cVend == DADOV->(VEND)
	    if DADOV->(PED) == _cPed   &&tratamento porque o select ira repetir registros por conta do SC9
	       DADOV->(dbSkip())
	       loop
	    Endif
	    _cPed := DADOV->(PED)  &&Excluido 
		If DADOV->(EXC) == "*"
		
			_nAscan := Ascan( _aExc, { |x|x[ 01 ] == DADOV->(PED) } )
			
			If _nAscan <= 00
				_cMot := fbscMot(DADOV->(PED),DADOV->(CLI),DADOV->(LOJ))
				
			    If Empty(_cMot) 
					_cMot := fSZDMot(DADOV->(PED),DADOV->(CLI),DADOV->(LOJ))
			    EndIF
				
				AADD(_aExc,{DADOV->(PED),DADOV->(CLI)+"-"+DADOV->(LOJ)+"-"+DADOV->(CLIENTE),CVALTOCHAR(DADOV->(QTDCX)),CVALTOCHAR(DADOV->(QTDKG)),CVALTOCHAR(Transform(DADOV->(VLTOT),"@E 99999999.99")),DADOV->(VEND)+"-"+SUBSTR(DADOV->(REPRES),1,35),_cMot})
			Endif
		
		Elseif DADOV->(SITUA) == "L" &&Liberado
			
			_nAscan := Ascan( _aliber, { |x|x[ 01 ] == DADOV->(PED) } )
			
			If _nAscan <= 00
				AADD(_aliber,{DADOV->(PED),DADOV->(CLI)+"-"+DADOV->(LOJ)+"-"+DADOV->(CLIENTE),CVALTOCHAR(DADOV->(QTDCX)),CVALTOCHAR(DADOV->(QTDKG)),CVALTOCHAR(Transform(DADOV->(VLTOT),"@E 99999999.99")),DADOV->(VEND)+"-"+SUBSTR(DADOV->(REPRES),1,35)})
			Endif
		
		Elseif DADOV->(SITUA) == "B" && Bloqueado
		
			_nAscan := Ascan( _aBloq, { |x|x[ 01 ] == DADOV->(PED) } )
			
			If _nAscan <= 00
			   
			   _cMot := ""
			   DbSelectArea("ZBH")
			   DbSetOrder(1)
			   If dbseek(xFilial("ZBH")+DADOV->(PED))
			      _cMot := Alltrim(ZBH->ZBH_MOTIVO)
			   Endif
			   
			   If Empty(_cMot) 
					
					_cMot := fbscMot(DADOV->(PED),DADOV->(CLI),DADOV->(LOJ))
			        
			        If Empty(_cMot) 
						_cMot := "EM ANALISE"
			        EndIF
			        
			   EndIF
		   
			   //AADD(_aBloq,{DADOV->(PED),DADOV->(CLI)+"-"+DADOV->(LOJ)+"-"+DADOV->(CLIENTE),CVALTOCHAR(DADOV->(QTDCX)),CVALTOCHAR(DADOV->(QTDKG)),CVALTOCHAR(Transform(DADOV->(VLTOT),"@E 99999999.99")),DADOV->(VEND)+"-"+SUBSTR(DADOV->(REPRES),1,35),_cMot})
				AADD(_aPend,{DADOV->(PED),DADOV->(CLI)+"-"+DADOV->(LOJ)+"-"+DADOV->(CLIENTE),CVALTOCHAR(DADOV->(QTDCX)),CVALTOCHAR(DADOV->(QTDKG)),CVALTOCHAR(Transform(DADOV->(VLTOT),"@E 99999999.99")),DADOV->(VEND)+"-"+SUBSTR(DADOV->(REPRES),1,35),_cMot})
				
			Endif
		Elseif Empty(DADOV->(SITUA))
			
			If DADOV->(C9CRED) == "01" .Or. DADOV->(C9EST) == "02"
				
				_nAscan := Ascan( _aBloq, { |x|x[ 01 ] == DADOV->(PED) } )				
				If _nAscan <= 00
				    _cMot := ""
			   		DbSelectArea("ZBH")
			   		DbSetOrder(1)
			   		If dbseek(xFilial("ZBH")+DADOV->(PED)) 
			   			_cMot := Alltrim(ZBH->ZBH_MOTIVO)
			   		Endif 
			   		
			   		If Empty(_cMot) 
					
						_cMot := fbscMot(DADOV->(PED),DADOV->(CLI),DADOV->(LOJ))
				        
				        If Empty(_cMot) 
							_cMot := "BLOQUEADO CREDITO/ESTOQUE"
				        EndIF
				        
			   		EndIF    
				    
				    //AADD(_aBloq,{DADOV->(PED),DADOV->(CLI)+"-"+DADOV->(LOJ)+"-"+DADOV->(CLIENTE),CVALTOCHAR(DADOV->(QTDCX)),CVALTOCHAR(DADOV->(QTDKG)),CVALTOCHAR(Transform(DADOV->(VLTOT),"@E 99999999.99")),DADOV->(VEND)+"-"+SUBSTR(DADOV->(REPRES),1,35),_cMot})
				
				    AADD(_aPend,{DADOV->(PED),DADOV->(CLI)+"-"+DADOV->(LOJ)+"-"+DADOV->(CLIENTE),CVALTOCHAR(DADOV->(QTDCX)),CVALTOCHAR(DADOV->(QTDKG)),CVALTOCHAR(Transform(DADOV->(VLTOT),"@E 99999999.99")),DADOV->(VEND)+"-"+SUBSTR(DADOV->(REPRES),1,35),_cMot})
				
				
				Endif
				
			Else
				
				If !Empty(DADOV->(C9PED))
			   		
			   		_nAscan := Ascan( _aliber, { |x|x[ 01 ] == DADOV->(PED) } )
					If _nAscan <= 00
					AADD(_aliber,{DADOV->(PED),DADOV->(CLI)+"-"+DADOV->(LOJ)+"-"+DADOV->(CLIENTE),CVALTOCHAR(DADOV->(QTDCX)),CVALTOCHAR(DADOV->(QTDKG)),CVALTOCHAR(Transform(DADOV->(VLTOT),"@E 99999999.99")),DADOV->(VEND)+"-"+SUBSTR(DADOV->(REPRES),1,35)})
					Endif
			   	
			   	Else
				
					_nAscan := Ascan( _aPend, { |x|x[ 01 ] == DADOV->(PED) } )
				
					If _nAscan <= 00
					
						_cMot := ""
			   			DbSelectArea("ZBH")
			   			DbSetOrder(1)
			   			If dbseek(xFilial("ZBH")+DADOV->(PED)) 
			   				_cMot := Alltrim(ZBH->ZBH_MOTIVO)
			   			Endif
			   		 	
			   		 	If Empty(_cMot) 
					
							_cMot := fbscMot(DADOV->(PED),DADOV->(CLI),DADOV->(LOJ))
				        
				        	If Empty(_cMot) 
								_cMot := "EM ANALISE"
				        	EndIF
				        
			   			EndIF    
				   
			   		 
						AADD(_aPend,{DADOV->(PED),DADOV->(CLI)+"-"+DADOV->(LOJ)+"-"+DADOV->(CLIENTE),CVALTOCHAR(DADOV->(QTDCX)),CVALTOCHAR(DADOV->(QTDKG)),CVALTOCHAR(Transform(DADOV->(VLTOT),"@E 99999999.99")),DADOV->(VEND)+"-"+SUBSTR(DADOV->(REPRES),1,35),_cMot})
				
					Endif
				
				EndIf	
				
			Endif
			
		Endif
		// Faz a soma de caixas do pedido e a soma de caixas cortadas por representante
		nSubPed += DADOV->(QTDCX)
		nSubCor += DADOV->(CXORIG)
		DADOV->(dbSkip())
		
	Enddo
	
	If Len(_aExc) > 0 &&Pedido(s) Excluido(s):
	
		cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
		cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='6' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Excluido(s): </td></tr>"
		cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>MOTIVO</td></tr>"
		
		For _nx := 1 To len(_aExc)
			cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][1]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][2]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][3]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][4]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][5]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aExc[_nx][7]+"</td></tr>"
		Next _nx
		                  
		cBuffer += "</table>"
		cBuffer += "<br /br>"

	Endif
	
	If Len(_aLiber) > 0 &&Pedido(s) Liberado(s)
		cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
		cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='5' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Liberado(s): </td></tr>"
	   	cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>" 
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>" 
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
	
		For _nx := 1 To len(_aLiber)           
		
			cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aLiber[_nx][1]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aLiber[_nx][2]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aliber[_nx][3]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aliber[_nx][4]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aLiber[_nx][5]+"</td>"
	
		Next _nx
		cBuffer += "</table>"
		cBuffer += "<br /br>"

	Endif
	
	/*
	If Len(_aBloq) > 0 &&Pedidos Bloqueados:
		
		cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
		cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='6' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) Bloqueado(s): </td></tr>"
		cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>MOTIVO BLOQUEIO</td></tr>"
		
		For _nx := 1 To len(_aBloq)
		
			cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][1]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][2]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][3]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][4]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][5]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aBloq[_nx][7]+"</td></tr>"						
		
		Next _nx
		cBuffer += "</table>"
		cBuffer += "<br /br>"

	Endif
	*/
	
	If Len(_aPend) > 0 &&Pedido(s) em Analise:
		
		cBuffer += "<table style='border-collapse: collapse; border: 1px solid #000; font-family: Arial; font-size: 14px;'>"
		cBuffer += "<tr style='border-collapse: collapse; border: 1px solid #000; background: #555; color: #FFF;'><td colspan='6' style='border-collapse: collapse; border: 1px solid #000; font-weight: bold; text-align: left;'>Pedido(s) em Analise: </td></tr>"
		cBuffer += "<tr><td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>PEDIDO</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>CLIENTE</td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD CX </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> QTD KG </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'> R$ TOTAL </td>"
		cBuffer += "    <td style='border-collapse: collapse; border: 1px solid #000;font-weight: bold;'>MOTIVO</td></tr>"
		
		For _nx := 1 To len(_aPend)
		
			cBuffer += " <tr style='border-collapse: collapse; border: 1px solid #000;'>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][1]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][2]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][3]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][4]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][5]+"</td>"
			cBuffer += " <td style='border-collapse: collapse; border: 1px solid #000; padding: 5px;'>"+_aPend[_nx][7]+"</td>"
	
		Next _nx
		cBuffer += "</table>"
		cBuffer += "<br /br>"

	Endif
		
	If !lEnviar
		//ENVIA O EMAIL COM TODOS OS DADOV DOS REPRESENTANTES DE UM SUPERVISOR				
		
		If Alltrim(GETMV("MV_#ENVIA")) == '.T.'
	 		cListaEmail += Alltrim(POSICIONE("SA3",1,XFILIAL("SA3")+_cVend,"A3_EMAIL"))
	   	EndIf
			
		cEmailA := "Relatorio - Situação de Pedidos no Financeiro - VENDEDOR - " + POSICIONE("SA3",1,XFILIAL("SA3")+_cVend,"A3_NOME")
		
		IF ALLTRIM(cListaEmail) <> ""
			msAguarde({||	U_enviaremail(allTrim(cEmailCred+";"+cListaEmail), cEmailA, cBuffer,,)},"Relatório","Aguarde. Enviando Email...",.T.)
			cListaEmail := ""
		ENDIF
		
	Else			
	
		folder      := cFile
    	arq         := "Relatorio_Pedidos_Financeiro.html"
    	cArqName    := folder+arq
    
    	lFile := Fcreate(cArqName)
    	fWrite(lFile, cBuffer)
    	fClose(lFile)
    	//sleep(1000)
                  
	    If  FILE(Alltrim("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe "))
	        WinExec("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe "+cArqName)
	    ElseIf  FILE(Alltrim("C:\Program Files\Google\Chrome\Application\chrome.exe "))
	         WinExec("C:\Program Files\Google\Chrome\Application\chrome.exe "+cArqName)
	    ElseIf  FILE(Alltrim("C:\Program Files (x86)\Mozilla Firefox\firefox.exe "))
	        WinExec("C:\Program Files (x86)\Mozilla Firefox\firefox.exe "+cArqName)
	    ElseIf  FILE(Alltrim("C:\Program Files\Mozilla Firefox\firefox.exe "))
	        WinExec("C:\Program Files\Mozilla Firefox\firefox.exe "+cArqName)
	    ElseIf  File(Alltrim("C:\Program Files (x86)\Internet Explorer\iexplore.exe "))
	        WinExec("C:\Program Files (x86)\Internet Explorer\iexplore.exe "+cArqName)
	    Else
	        WinExec("C:\Program Files\Internet Explorer\iexplore.exe "+cArqName)
	    EndIf 
	    
    EndIf		
	lEnviar == .F. 
	
Enddo
EndIf

DADOS->(dbCloseArea())
DADOV->(dbCloseArea())



Return 





//-----------------|
//valida pergunta  |
//-----------------|
Static Function ValidPerg(cPerg)
	
	local i,j
	sAlias := ALIAS()
	aRegs  := {}
	cPerg  := PADR(cPerg,10)
	
	dbselectarea("SX1")
	Dbsetorder(1)
	
	AADD(aRegs,{cPerg,"01",	"Entrega De :"				   		,"","","mv_ch1","D",08,00,00,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02",	"Entrega Ate:"						,"","","mv_ch2","D",08,00,00,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	For i := 1 to Len(aRegs)
		If !Dbseek(cPerg+aRegs[i,2])
			RECLOCK("SX1", .T.)
			For j := 1 TO FCount()
				If j <= LEN(aRegs[i])
					FIELDPUT(j, aRegs[i,j])
				EndIf
			Next
			Msunlock()
		EndIF
	Next
	DbSelectArea(sAlias)

Return()  



//--------------------------------------------|
// Função genérica para envio de email        |
// Fernando Sigoli 07/03/2017                 |
//--------------------------------------------|
User Function EnviarEmail(cPara,cAssunto,cBody,cAtach,lLog)

	U_ADINF009P('ADFIN029P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio - Situação de Pedidos no Financeiro')
	
	cAtach := if(cAtach==nil,"",cAtach)
	lLog   := if(lLog==nil,.f.,lLog)
	
	CONNECT SMTP SERVER GetMV("MV_RELSERV") ACCOUNT GetMV("MV_RELACNT") PASSWORD GetMV("MV_RELPSW") RESULT lOk
	
	If !lOK
		cErro := MailGetErr()
		If ! lLog
			//ConOut("Erro ao Conectar o Servidor - "+cErro) // Conout
		EndIf
		Return .F.
	EndIf
	
	//Servidor com autenticação
	lRelauth := GetNewPar("MV_RELAUTH", .F.)
	If lRelAuth
		lOk := MailAuth(GetMV("MV_RELACNT"),GetMV("MV_RELPSW"))
		If !lOK
			cErro := MailGetErr()
			If (Alltrim(FunName()) == "MATA440") .or. (Alltrim(FunName()) == "MATA410")
				Alert("Erro ao conectar com autenticacao - " + cErro)
			EndIf
			lOk := MailSmtpOff( )
			Return .F.
		EndIf
	EndIf
	
	SEND MAIL FROM GetMv("MV_RELFROM") TO cPara SUBJECT cAssunto BODY cBody ATTACHMENT cAtach RESULT lOK //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	
	If !lOK
		cErro := MailGetErr()
		If !lLog 
			If (Alltrim(FunName()) == "MATA440") .or. (Alltrim(FunName()) == "MATA410")
				Alert("Erro ao Enviar Mensagem - " + cErro)
			EndIf
		EndIf
		lOk := MailSmtpOff( )
		Return .F.
	EndIf
	
	lOk := MailSmtpOff()
	
	If !lOK
		If ! lLog 
			If (Alltrim(FunName()) == "MATA440") .or. (Alltrim(FunName()) == "MATA410")
				Alert("Erro ao Desconectar do Servidor")
			EndIf
		EndIf
		Return .F.
	EndIf
	
Return .T.


//mauricio

Static function fbscMot(_PD,_CL,_LJ)

_cMT := ""

If Select("MZBH") > 0
   dbSelectArea("MZBH")
   DbCLoseArea("MZBH")
EndIf   

&&Na query abaixo virão todos, inclusive possivelmente deletados		
_cQueryR := "SELECT TOP 1 * FROM "+RetSqlName("ZBH")+" "
_cQueryR += "WHERE ZBH_PEDIDO = '"+_PD+"' AND "
_cQueryR += "      ZBH_CLIENT = '"+_CL+"' AND "
_cQueryR += "      ZBH_LOJA   = '"+_LJ+"'"
_cQueryR += "ORDER BY ZBH_PEDIDO, ZBH_CLIENT,ZBH_LOJA,R_E_C_N_O_ DESC
		
TCQUERY _cQueryR NEW ALIAS "MZBH"
		
dbSelectArea("MZBH")
dbGoTop()
		
_cMT := MZBH->ZBH_MOTIVO

Return(_cMT)
                         

//Rotinas para saber quem esta logado é vendedor ou Supervisor
//Data: 31/03/2017
Static Function Supervend(cCodigo)

Local aArea      := GetArea() 
Local cQry  	 := ""  
Local cVendSuper := ""  

cQry := " SELECT ZR_CODIGO,COUNT(*) as CONTADOR FROM "+RetSqlName("SZR")+" WHERE D_E_L_E_T_ = '' and ZR_USER = '"+cCodigo+"'"
cQry += " Group by ZR_CODIGO "                        

TCQUERY cQry NEW ALIAS "FONTE" 

If FONTE->CONTADOR > 0 // é Supervisor que esta logado
	cVendSuper := FONTE->ZR_CODIGO
EndIf

DbCLoseArea("FONTE")
RestArea(aArea)

Return cVendSuper

                       
//motivo - excluir o pedido pela rotina padrao 
Static function fSZDMot(_PD,_CL,_LJ)

Local _cMotivo1 := ""

If Select("MSZD") > 0
   dbSelectArea("MSZD")
   DbCLoseArea("MSZD")
EndIf   

&&Na query abaixo virão todos, inclusive possivelmente deletados		
_cQueryR := "SELECT TOP 1 * FROM "+RetSqlName("SZD")+" "
_cQueryR += "WHERE ZD_PEDIDO = '"+_PD+"' AND "
_cQueryR += "      ZD_CODCLI = '"+_CL+"' AND "
_cQueryR += "      ZD_LOJA   = '"+_LJ+"'"
_cQueryR += "ORDER BY ZD_PEDIDO, ZD_CODCLI,ZD_LOJA,R_E_C_N_O_ DESC
		
TCQUERY _cQueryR NEW ALIAS "MSZD"
		
dbSelectArea("MSZD")
dbGoTop()
		
_cMotivo1 := MSZD->ZD_OBS1

Return(_cMotivo1)

Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIN029P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADFIN029P'
			ZBN_DESCRI  := 'Envio de email para os vendedores referente a situação dos pedidos no financeiro'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '17:30:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '17:30:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADFIN029P'
			ZBN_DESCRI  := 'Envio de email para os vendedores referente a situação dos pedidos no financeiro'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '17:30:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '17:30:00'
			ZBN_STATUS	:= cStatus

	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil
