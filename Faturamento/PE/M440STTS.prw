#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M440STTS ³ Autor ³ Mauricio MDS TEC      ³ Data ³ 16.11.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Força bloqueio por limite de credito se necessario.        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ versionamento:  ³                                                     ³±±
±±³Chamado 045119. Everson 12/11/2018. Comentado o trecho de código que   ³±±
±±³não bloqueava pedido exportação por crédito.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
// ---------+-------------------+----------------------------------------------------+---------------
// 03/04/18 | Ricardo Lima      | Atualiza Status dos pedidos com integração do SAG  |
// ---------+-------------------+----------------------------------------------------+---------------
/*/
User Function M440STTS()

Local _NVLRITEM := 0
Local _nLimCred := 0

// Ricardo Lima - 03/04/18
Local cUpdate	:= ""
Local lAtuSAG := SuperGetMv( "MV_#ATUSAG" , .F. , .F. ,  )

SetPrvt("_CALIAS,_CORDER,_CRECNO,_CNUMPED,_CCLIENTE,_CLOJA")
SetPrvt("_SC6cAliasSC6,_SC6cOrderSC6,_SC6cRecnoSC6,_SC5cAliasSC5,_SC5cOrderSC5,_SC5cRecnoSC5")

_cAlias := Alias()
_cOrder := IndexOrd()
_cRecno := Recno()

dbSelectArea("SC6")
_SC6cAliasSC6 := Alias()
_SC6cOrderSC6 := IndexOrd()
_SC6cRecnoSC6 := Recno()
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda o Pedido Posicionado 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC5")
_cNumPed  := M->C5_NUM
_cCliente := M->C5_CLIENTE
_cLoja    := M->C5_LOJACLI
_Tipo     := M->C5_TIPO
_Estado   := M->C5_EST

_SC5cAliasSC5 := Alias()
_SC5cOrderSC5 := IndexOrd()
_SC5cRecnoSC5 := Recno()


_nLimCred := Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_LC")
_lBloq := .F. 
_nSldAb := fBscSld(_cCliente,_cLoja)   //traz saldo em aberto para o cliente

DbSelectArea("SC6")
DbSetOrder(1)
If DbSeek(xFilial("SC6")+_cNumPed)
   While !Eof() .And. SC6->C6_NUM == _cNumPed
         if SC6->C6_QTDENT < SC6->C6_QTDVEN  //qtd total pendente
            _nVlrItem := ((SC6->C6_QTDVEN - SC6->C6_QTDENT) * SC6->C6_PRCVEN)   //valor pendente no pedido (inclusive parcial)
         endif
          // Alex Borges - 22/12/11 Quando o pedido faturado e cancelado tera que buscar a situação do pedido para liberar o credito ou nao
         DbSelectArea("SC5")
	     DbSetOrder(1)
         If DbSeek(xFilial("SC5")+_cNumPed)
         	_Tipo     := SC5->C5_TIPO
			_Estado   := SC5->C5_EST
         End If
         // Alex Borges - 28/11/11 - If para tratar a TES
         DbSelectArea("SF4")
	     DbSetOrder(1)
	     if dbseek(xFilial("SF4")+SC6->C6_TES)
		    // If (ALLTRIM(SF4->F4_DUPLIC) = 'S')  Alex Borges 01/12/11
		    If ((ALLTRIM(SF4->F4_DUPLIC) = 'S') .and. (ALLTRIM(_Tipo) $ "N/C")) //.and. (ALLTRIM(_estado)<> "EX")) //Everson - 12/11/2018. Chamado 045119. Pedido exportação deve ficar bloqueado por crédito.
		         if (_nVlrItem + _nSldAb) > _nLimCred   //limite excedido deve bloquear
		            DbSelectArea("SC9")
		            DbSetOrder(1)
		            if dbseek(xFilial("SC9")+_cNumPed+SC6->C6_ITEM)  //somente se achou item liberado no SC9
		               If empty(SC9->C9_BLCRED)   //somente se ja não houver bloqueio
		                  Reclock("SC9",.F.) 
		                     SC9->C9_BLCRED := "01"  //bloqueio por limite de valor
		                  MsUnlock()
		               Endif      
		            Endif
		         Endif 
		     Else
			     DbSelectArea("SC9")
			     DbSetOrder(1)
			     if dbseek(xFilial("SC9")+_cNumPed+SC6->C6_ITEM)
			     	Reclock("SC9",.F.)
			       	SC9->C9_BLCRED := ""  // libera crédito
			     	MsUnlock()
			     End If
		     End If  
         End If
         _nLimCred -= _nVlrItem  //deduzo o valor do item ja validado do limite utilizado.
         SC6->(dbSkip())
   Enddo
Endif            

	IF lAtuSAG
		// Ricardo Lima - 03/04/18
		cUpdate := " UPDATE PED SET STATUS_PRC= CASE WHEN SC5.D_E_L_E_T_ = '' THEN 'S' ELSE 'N' END, STATUS_INT='' " 
		cUpdate += " FROM SGPED010 PED WITH(NOLOCK) " 
		cUpdate += " INNER JOIN " + RetSqlName("SC5") + " SC5 WITH(NOLOCK) ON PED.C5_FILIAL = SC5.C5_FILIAL COLLATE Latin1_General_CI_AS AND PED.C5_NUM = C5_PEDSAG COLLATE Latin1_General_CI_AS  AND PED.C5_CLIENTE = SC5.C5_CLIENTE COLLATE Latin1_General_CI_AS  AND PED.C5_LOJACLI = SC5.C5_LOJACLI COLLATE Latin1_General_CI_AS  AND PED.TABEGENE = SC5.C5_TABEGEN COLLATE Latin1_General_CI_AS  " 
		cUpdate += " INNER JOIN " + RetSqlName("SC6") + " SC6 WITH(NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_CLIENTE = C6_CLI AND SC5.C5_LOJACLI = C6_LOJA  AND PED.CODIGENE = SC6.C6_XCODIGE " 
		cUpdate += " INNER JOIN " + RetSqlName("SC9") + " SC9 WITH(NOLOCK) ON SC6.C6_FILIAL = C9_FILIAL AND SC6.C6_NUM = C9_PEDIDO AND SC6.C6_CLI = C9_CLIENTE AND SC6.C6_LOJA = C9_LOJA AND SC6.C6_ITEM = C9_ITEM AND SC6.C6_PRODUTO = C9_PRODUTO " 
		cUpdate += " WHERE SC5.C5_XLIBSAG = '1' AND PED.STATUS_PRC='A' AND SC5.C5_PEDSAG <> '' AND SC6.C6_XCODIGE <> '' AND SC9.C9_BLCRED = '' AND C9_BLEST = '' AND (SELECT COUNT(*) FROM SGPED010 PED2 WITH(NOLOCK) WHERE PED2.C5_NUM = PED.C5_NUM AND PED2.TABEGENE= PED.TABEGENE) = (SELECT COUNT(*) FROM " + RetSqlName("SC9") + " SC9 WITH(NOLOCK) WHERE SC6.C6_FILIAL = SC9.C9_FILIAL AND SC6.C6_NUM = SC9.C9_PEDIDO AND SC6.C6_CLI = SC9.C9_CLIENTE AND SC6.C6_LOJA = SC9.C9_LOJA AND SC9.D_E_L_E_T_ = '' AND SC9.C9_BLCRED = '' AND C9_BLEST = '') " 
	
		If TcSqlExec(cUpdate) < 0
			ConOut( "M440STTS - Não foi possível atualizar os status de liberação dos movimentos 'Saída por venda'" + "Num Filial: " + SC5->C5_FILIAL + " Num Pedido: " + SC5->C5_NUM + "||" + SC5->C5_PEDSAG)
		Else	
			ConOut( "M440STTS - Atualizado os status de liberação dos movimentos 'Saída por venda'" + "Num Filial: " + SC5->C5_FILIAL + " Num Pedido: " + SC5->C5_NUM + "||" + SC5->C5_PEDSAG)
		EndIf
	ENDIF 
          
dbSelectArea(_SC6cAliasSC6)
dbSetOrder(_SC6cOrderSC6)
dbGoto(_SC6cRecnoSC6)

dbSelectArea(_SC5cAliasSC5)
dbSetOrder(_SC5cOrderSC5)
dbGoto(_SC5cRecnoSC5)

dbSelectArea(_cAlias)
dbSetOrder(_cOrder)
dbGoto(_cRecno)

Return 

static function fBscSld(_cCl,_cL) //Mauricio 16/11/11 - retorna saldo em aberto para o Cliente.
//Local _cCl
//Local _cL
Local _nSld := 0
Local _cQuery := ""

If Select("TSE1") > 0
   DbSelectArea("TSE1")
   DbCloseArea("TSE1")
Endif

// RICARDO LIMA - 25/01/18
//_cQuery := ""
//_cQuery += "SELECT E1_SALDO FROM "+RetSqlName("SE1")+" SE1 "
//_cQuery += " WHERE SE1.E1_CLIENTE = '"+_cCL+"' AND SE1.E1_LOJA = '"+_cL+"' AND SE1.D_E_L_E_T_ = '' AND SE1.E1_SALDO > 0"

_cQuery := " SELECT SUM(E1_SALDO) E1_SALDO " 
_cQuery += " FROM "+RetSqlName("SE1")+" SE1 "
_cQuery += " WHERE SE1.E1_CLIENTE = '"+_cCL+"' AND SE1.E1_LOJA = '"+_cL+"' " 
_cQuery += " AND SE1.E1_SALDO > 0 AND SE1.D_E_L_E_T_ = ' ' "
				
_cQuery := ChangeQuery(_cQuery) // RICARDO LIMA - 25/01/18
TCQUERY _cQuery NEW ALIAS "TSE1"

dbSelectArea("TSE1")

IF TSE1->(!Eof())
	_nSld += TSE1->E1_SALDO
EndIF 

dbcloseArea("TSE1")   
return(_nSld)
