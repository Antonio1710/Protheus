#INCLUDE "fiveWin.ch"   
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function EMAILPEDRJ
	(Envia email para pedidos rejeitados(excluidos) pelo processo de aprovação da nova tabela de preco.)
	@type  Function
	@author Mauricio - MDS
	@since 03/08/2011
	@version 01
	@history Adriana - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM.
	@history Adriano Savoine - 23/10/2019 - Parametro criado para facilitar ajustes na lista de email chamado: 052862.
	/*/

User Function EMAILPEDRJ(_cPedido,_cVended,_aArray,_cTipo)

Local _cPedido
Local _cVended  
Local _cTipo        &&se _ctipo igual a 1 eh varejo senão eh rede.
Local _aArray
Local cMotivo 	:= Space(115)
Local lRet		:= .f.
Local _lMail	:= .T.
Local _nTotSC6	:= 0
Local _cMens	:= " "
Local _cMens1	:= " "
Local _cMens2	:= " "
Local _cMens3	:= " "

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Envia email para pedidos rejeitados(excluidos) pelo processo de aprovação da nova tabela de preco')
    
cMotivo := "O pedido "+_cPedido+" foi rejeitado e excluido no processo de aprovação pelo usuario "+ALLTRIM(UPPER(SUBSTR(CUSUARIO,7,15)))   

If _lMail
			
			_cMens1 := '<html>'
			_cMens1 += '<head>'
			_cMens1 += '<meta http-equiv="content-type" content="text/html;charset=iso-8859-1">'
			_cMens1 += '<meta name="generator" content="Microsoft FrontPage 4.0">'
			_cMens1 += '<title>Pedido Rejeitado na Aprovação</title>'
			_cMens1 += '<meta name="ProgId" content="FrontPage.Editor.Document">'
			_cMens1 += '</head>'
			_cMens1 += '<body bgcolor="#C0C0C0">'
			_cMens1 += '<center>'
			_cMens1 += '<table border="0" width="982" cellspacing="0" cellpadding="0">'
			_cMens1 += '<tr height="80">'
			_cMens1 += '<td width="100%" height="80" background="http://www.adoro.com.br/microsiga/pedido_bloq.jpg">&nbsp;</td>'
			_cMens1 += '</tr>'
			_cMens1 += '</center>'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="100%" bgcolor="#386079">'
			_cMens1 += '<div align="left">'
			_cMens1 += '<table border="1" width="100%">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="982" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
			_cMens1 += '<b><font face="Arial" color="#FFFFFF" size="4">Pedido: '+SC5->C5_NUM+'</font></b>'
			_cMens1 += '</td></tr>'
			_cMens1 += '</table>'
			_cMens1 += '</div>'
			_cMens1 += '</td>'
			_cMens1 += '</tr>' 
			_cMens1 += '<center>'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="100%">'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="87" bgcolor="#FAA21B"><font face="Arial" size="1">Cod.Cliente:</font></td>'
			_cMens1 += '<td width="38" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CLIENTE+'</font></td>'
			_cMens1 += '</center>'
			_cMens1 += '<td width="25" bgcolor="#FAA21B">'
			_cMens1 += '<p align="right"><font face="Arial" size="1">Loja:</font></td>'
			_cMens1 += '<center>'
			_cMens1 += '<td width="17" bgcolor="#FFFFFF">'
			_cMens1 += '<p align="center"><font face="Arial" size="1">'+SC5->C5_LOJACLI+'</font></td>'
			_cMens1 += '</center>'
			_cMens1 += '<td width="36" bgcolor="#FAA21B">'
			_cMens1 += '<p align="right"><font face="Arial" size="1">Nome:</font></td>'
			_cMens1 += '<center>'
			_cMens1 += '<td width="751" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_NOMECLI+'</font></td>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="8%" bgcolor="#FAA21B"><font face="Arial" size="1">Endereço:</font></td>'
			_cMens1 += '<td width="41%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_ENDERE+'</font></td>'
			_cMens1 += '<td width="4%" bgcolor="#FAA21B"><font face="Arial" size="1">Bairro:</font></td>'
			_cMens1 += '<td width="17%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_BAIRRO+'</font></td>'
			_cMens1 += '<td width="5%" bgcolor="#FAA21B"><font face="Arial" size="1">Cidade:</font></td>'
			_cMens1 += '<td width="40%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CIDADE+'</font></td>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '<center><table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="6%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Roteiro:</font></td>'
			_cMens1 += '<td width="44%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_ROTEIRO+'</font></td>'
			_cMens1 += '<td width="7%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Sequência:</font></td>'
			_cMens1 += '<td width="43%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_SEQUENC+'</font></td>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="170" bgcolor="#FAA21B"><font face="Arial" size="1">Condição de Pagamento:</font></td>'
			_cMens1 += '<td width="81" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CONDPAG+'</font></td>'
			_cMens1 += '<td width="84" bgcolor="#FAA21B"><font face="Arial" size="1">Vencimento:</font></td>'
			_cMens1 += '<td width="168" bgcolor="#FFFFFF"><font face="Arial" size="1">'+DTOC(SC5->C5_DATA1)+'</font></td>'
			_cMens1 += '<td width="46" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Emissão:</font></td>'
			_cMens1 += '<td width="393" bgcolor="#FFFFFF"><font face="Arial" size="1">'+DTOC(SC5->C5_DTENTR)+'</font></td>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="7%" bgcolor="#FAA21B">'
			_cMens1 += '<p align="center"><font size="1" face="Arial">Vendedor:</font></p>'
			_cMens1 += '</td>'
			_cMens1 += '<td width="12%" bgcolor="#FFFFFF">'
			_cMens1 += '<p align="center"><font face="Arial" size="1">'+SC5->C5_VEND1+'</font></p>'
			_cMens1 += '</td>'
			_cMens1 += '<td width="15%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Carteira:</font></td>'
			_cMens1 += '</center>'
			_cMens1 += '<td width="66%" bgcolor="#FFFFFF">'
			DBSelectArea("SA3")
			DBSetOrder(1)
			DBSeek(XFilial("SA3")+SC5->C5_VEND1)
			_cMens1 += '<p align="left"><font face="Arial" size="1">'+UPPER(ALLTRIM(SA3->A3_NOME))+'</font></p>'
			_cMens1 += '</td></tr></table><center>'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="982%" bgcolor="#FAA21B">'
			_cMens1 += '<p align="center"><font face="Arial" size="1">Motivo</font></td>'
			_cMens1 += '</tr><tr>'
			_cMens1 += '<td width="982" bgcolor="#FFFFFF">'
			_cMens1 += '<p align="center"><b><font color="#FF0000" face="Verdana" size="3">'+cMotivo+'</font></b></p>
			_cMens1 += '</tr>'
			_cMens1 += '</table></center>'
			_cMens1 += '<table border="1" cellpadding="0" cellspacing="2" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td align="center" bgcolor="#FAA21B" width="1468" colspan="9">'
			_cMens1 += '<p align="center"><font face="Arial" size="1">Itens do Pedido</font></td>'
			_cMens1 += '</tr></center>'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="14" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Item</b></font></td>'
			_cMens1 += '<td width="50" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Produto</b></font></td>'
			_cMens1 += '<td width="544" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1" color="#FFFFFF"><b>Descrição</b></font></td>'
			_cMens1 += '<td width="57" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial"  color="#FFFFFF"><b>TES</b></font></p></td>'
			_cMens1 += '<td width="283" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Operação</b></font></p></td>'
			_cMens1 += '<td width="42" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>UM</b></font></td>'
			_cMens1 += '<td width="91" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Quantidade</b></font></td>'
			_cMens1 += '<td width="244" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor Unitário</b></font></td>'
			_cMens1 += '<td width="263" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor</b></font></td>'
			_cMens1 += '</tr>'
			_nTotSC6 := 0.00				         
		    For _n := 1 to len(_aArray)
		        //{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_DESCRI,SC6->C6_TES,SC6->C6_UM,SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALOR}
				
				_cItem 	    := _aArray[_n][1]
				_cProduto   := _aArray[_n][2]
				_cDescri 	:= _aArray[_n][3]
				_cTes 		:= _aArray[_n][4]
				_cUM 		:= _aArray[_n][5]
				nQTDVEN 	:= _aArray[_n][6]
				nPRCVEN 	:= _aArray[_n][7]
				nVALOR 	    := _aArray[_n][8]
				
			
				_cMens2 += '<tr>'
				_cMens2 += '<td width="14" bgcolor="#FFFFFF"><font face="Arial" size="1">'+_cITEM+'</font></td>'
				_cMens2 += '<td width="50" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+_cPRODUTO+'</font></td>'
				_cMens2 += '<td width="544" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+_cDESCRI+'</font></td>'
				_cMens2 += '<td width="57" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+_cTES+'</font></p></td>'
				_cMens2 += '<td width="283" bgcolor="#FFFFFF"><font face="Arial" size="1">'+Posicione("SF4",1,XFilial("SF4")+_cTES,"F4_TEXTO")+'</font></td>'
				_cMens2 += '<td width="42" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+_cUM+'</font></p></td>'
				_cMens2 += '<td width="91" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+TRANSFORM(nQTDVEN,"@!")+'</font></p></td>'
				_cMens2 += '<td width="244" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(nPRCVEN,"@E 999,999,999.99")+'</font></p></td>'
				_cMens2 += '<td width="263" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(nVALOR,"@E 999,999,999.99")+'</font></p></td>'
				_cMens2 += '</tr>'
				_nTotSC6 += nVALOR
			Next _n 
					
			_cMens3 := '<tr>'
			_cMens3 += '<td width="1325" bgcolor="#386079" colspan="8">'
			_cMens3	+= '<p align="right"><font face="Arial" size="1" color="#FFFFFF"><b>TOTAL DO PEDIDO</b></font></td>'
			_cMens3	+= '<td width="263" bgcolor="#FFFFFF"><font face="Arial" size="1">'+TRANSFORM(_nTotSC6,"@E 999,999,999.99")+'</font></td>'
			_cMens3	+= '</tr>'
			_cMens3	+= '</table>'
			_cMens3	+= '</td>'
			_cMens3	+= '</tr>'
			_cMens3	+= '<center>'
			_cMens3	+= '<tr>'
			_cMens3	+= '<td width="100%" bgcolor="#386079" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
			_cMens3	+= '<p align="center">'
			_cMens3	+= '<font face="Arial" size="1" color="#FFFFFF"><b>Email Enviado Automaticamente pelo Sistema Protheus by Adoro Informática</b></font>'
			_cMens3	+= '</p>'
			_cMens3	+= '</td>'
			_cMens3	+= '</tr>'
			_cMens3	+= '</table>'
			_cMens3	+= '</center>'
			_cMens3	+= '</body>'
			_cMens3	+= '</html>'
			/* Verificar com Alex se precisa gravar nesta tabela.
			DBSelectAreA("SZD")
			RecLock("SZD",.t.)
					ZD_FILIAL := SC5->C5_FILIAL
					ZD_CODCLI := SC5->C5_CLIENTE
					ZD_NOMECLI := SC5->C5_NOMECLI
					ZD_AUTNOME := UPPER(SUBSTR(CUSUARIO,7,15))
					ZD_RESPONS := "33"
					ZD_RESPNOM := "CREDITO"
					ZD_PEDIDO  := SC5->C5_NUM
					ZD_ROTEIRO := SC5->C5_ROTEIRO
					ZD_SEQUENC := SC5->C5_SEQUENC
					ZD_OBS1    := UPPER(cMotivo)
					ZD_VEND    := SC5->C5_VEND1
					ZD_LOJA    := SC5->C5_LOJACLI
					ZD_DEVTOT  := 'O'
					ZD_DTDEV   := ddatabase
			MsUnlock()
			*/
			if _cTipo == "3" //Doação
			cEmail:= GetMv("MV_#EMAREJ") //Parametro criado para facilitar ajustes na lista de email chamado: 052862 Adriano Savoine 23/10/2019
			Elseif _cTipo == "1"        &&varejo
			   DbSelectArea("SA3")
			   DbSetOrder(1)
			   DbSeek(Xfilial("SA3")+SC5->C5_VEND1) 
			   _eMailVend := SA3->A3_EMAIL
			   _cSuper    := SA3->A3_SUPER
			   cEmail     := _eMailVend
			   _cEmailS   := Posicione("SA3",1,xFilial("SA3")+_cSuper,"A3_EMAIL")
			   cEmail     += ";"+_cEmailS
            Else                 &&rede
               DbSelectArea("SA3")
			   DbSetOrder(1)
			   DbSeek(Xfilial("SA3")+SC5->C5_VEND1)
			   _eMailVend  := SA3->A3_EMAIL
			   _cRepresent := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CODRED,"A1_VEND")
			   _cEmailRed  := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_EMAIL")
			   _cSuper     := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_SUPER")
			   _cEmailS    := Posicione("SA3",1,xFilial("SA3")+_cSuper,"A3_EMAIL")                                                               
			   cEmail      := _cEmailRed+";"+_cEmailS
			   //_cEmailRed  := "mau_silva@hotmail.com"
			   /*
			   if Alltrim(_eMailVend) <> Alltrim(_cEmailRed)			
			      cEmail := _eMailVend+';'+_cEmailRed
			   else
			      cEmail := _eMailVend
			   Endif
			   */   			   			        
            Endif
			/*
			DbSelectArea("SZR")
			DbSetOrder(1)
			DbSeek(Xfilial("SZR")+SA3->A3_CODSUP)
			_eMailSup := alltrim(UsrRetMail(SZR->ZR_USER))
			
				IF !Empty(Getmv("mv_mailtst"))
   				cEmail := Alltrim(Getmv("mv_mailtst"))
				ELSE
					cEmail :=_eMailVend+';'+_eMailSup+';'+Alltrim(GetMv("mv_emails1"))
				ENDIF
			*/
		    //cEmail := "mauricio.silva@adoro.com.br"
		    			
			_cMens := _cMens1+_cMens2+_cMens3
			_cData := transform(MsDate(),"@!")
			_cHora := transform(Time(),"@!")  
	 
	  		lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+SC5->C5_NUM+" REJEITADO/EXCLUÍDO NA APROVAÇÃO- "+_cData+" - "+_cHora,"")	//Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM  		
Endif
&&Tratamento de exibição não implementado para não causar impacto em tela de aprovação.     
/*  
//+-----------------------------------------+
//|Nao consegui enviar o e-mail vou exibir  |
//|o resultado em tela                      |
//+-----------------------------------------+                                                                                                          
If !lRet 
	ApMsgInfo("Nao foi possível o Envio do E-mail.O E-mail será impresso em "+;
				"Tela e o registro será processado. "+;
				"Possíveis causas podem ser:  Problemas com E-mail do destinatário "+;
					"ou  no serviço interno de E-mail da empresa.","Erro de Envio")
	//+---------------------------------+
	//|Montando arquivo de Trabalho     |
	//+---------------------------------+	
	_aFile:={}
	AADD(_aFile,{"LINHA","C",1000,0})    
	_cNom := CriaTrab(_aFile)
	dbUseArea(.T.,,_cNom,"TRB",.F.,.F.)		
	DbSelectArea("TRB")
	
	//+----------------------------------+
	//|Montando o Texto em TRB           |
	//+----------------------------------+	
 
		TxtNew:=ALLTRIM(STRTRAN(_cMens,CHR(13),"ª"))+"ª"  
		TEXTO :=''
		For I:=0 to LEN(TxtNew)
		    // Pego o proximo bloco
			TEXTO+=SUBSTR(TxtNew,1,1)	
			// Exclui o caracter posicionado
			TxtNew:=STUFF(TxtNew,1,1,"")	
			If 	LEN(TEXTO)>=200 	//txt=="ª" .or. _nTamLin > limite			
					TEXTO:=SUBSTR(TEXTO,1,LEN(TEXTO)-1)
					RecLock("TRB",.t.)
					Replace TRB->LINHA With TEXTO 
					MsUnlock()
					TEXTO:=""							
			Endif
		Next
       
   //+-------------------------+
	//|Copiando para Arquivo    |
   //+-------------------------+
      
	DbSelectArea("TRB")    	
	//COPY to &"c:\"+_cNom+".html" SDF  
	cPath := GetSrvProfString("StartPath","")+"PED_EXC\"
	COPY to &cPath+_cNom+".html" SDF	
		
	DbCloseArea("TRB")
	
	//ShellExecute('open',"c:\"+_cNom+".html",'','',1)
	ShellExecute('open',cPath+_cNom+".html",'','',1)
		
Endif
*/
Return()