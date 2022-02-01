#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
/*{Protheus.doc} User Function ADFIN024P
	Rotina de pre aprovacao por REDE
	@type  Function
	@author Mauricio
	@since 01/11/2016
	@version 01
	@history Chamado 048296 - William Costa - 05/04/2019 - Adicionado Ab- na query de consulta as redes
   @history Chamado 056381 - William Costa - 17/03/2020 - Adicionado log em todos os reclock do campo ZF_LCREDE para descobrir seu valor antes e depois 
   @history Chamado 057170 - Everson       - 23/04/2020 - Tratamento para otimizar a rotina.
   @history Ticket  8      - Abel Babini   - 31/01/2022 - Gravação da liberação na tabela de pedidos liberados. 
   @history Ticket  8      - Abel Babini   - 01/02/2022 - Ajuste de variáveis
*/   
User Function ADFIN024P()

   Local aArea       := GetArea()
   Local aAreaSC5    := SC5->(GetArea())
   Local aRegSC6     := {}
   Local lContinua   := .T.
   Local lQuery      := .F.
   Local nOpcA       := 0

   Local cPedido     := ""
   Local cAliasSC5   := "SC5"
   Local cAliasSC6   := "SC6"
   Local dLimLib     := dDataBase
   Local lProcessa   := .T.	
   Local _cQry       := ""
   local _nOpc       := 0
   Local _dDTENTR1   := MV_PAR02
   Local _dDTENTR2   := MV_PAR03

   //Ticket  8      - Abel Babini   - 31/01/2022 - Gravação da liberação na tabela de pedidos liberados.
   Local cPerfPgt := ''
   Local nMedAtr	:= 0
   Local aPerPgt	:= {}
       
   //Mauricio - 28/09/16 - adicionado novo conteudo a tela de liberação de rede(solicitado Alberto)
   Private _aMot     := {}
   Private oCabD4 

   U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina de pre aprovacao por REDE')

   //Mauricio 23/11/16 - incluida chamada de função, com parte do fonte ADLCRED2.prw hoje utilizado, conforme solicitacao Alberto.
   bBloco := {|lEnd| ProcSql()}  
   MsAguarde(bBloco,"Aguarde, Atualizando o credito das redes","Atualizando...",.F.)

   DbselectArea("SC5")
   Eval(bFiltrabrw)        //ratifico o filtro padrão da rotina principal.
   dbgotop()

   //busco por query os mesmos dados apresentados em tela pelo filtro padrão acima.
   If Select("TSC5") > 0
      DbSelectArea("TSC5")
      DbCloseArea("TSC5")
   Endif

   _cQuery := "SELECT C5_NUM, C5_FILIAL, C5_XPREAPR, C5_CLIENTE, C5_LOJACLI, ZF_REDE FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1 "
   _cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND "
   If mv_par01 == 1
      _cQuery += "C5.C5_XPREAPR='B' AND "
   Else 
      _cQuery += "(C5.C5_XPREAPR = 'L' OR C5.C5_XPREAPR = 'B') AND "    
   Endif
   _cQuery += "C5.C5_NOTA = '' AND "
   _cQuery += "(C5.C5_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C5_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "
   _cQuery += "C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA AND "
   _cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' "
   _cQuery += "ORDER BY ZF.ZF_REDE, C5.C5_NUM "

   TCQuery _cQuery NEW ALIAS "TSC5"

   DbSelectArea("TSC5")
   DbGotop()

   IF TSC5->(Eof())
      Msginfo("Não foram encontrados pedidos relativos a REDE para liberação de credito","Atenção")
      Return()
   Endif

   //Apuro valor em aberto de pedidos no periodo/parametro especificado                   
   _lRdPri := .T.
   While TSC5->(!Eof())
         _cRD := TSC5->ZF_REDE
         //mostrar a tela para analise da rede para o usuario Aprovar ou Rejeitar a Rede.....
         If Select("TMP") > 0
            DbSelectArea("TMP")
            DbCloseArea("TMP")
         Endif
         
         
         IF _lRdPri
         _nOpc := 0
         _nTotRede   := 0
         _nTotSdRede := 0
         _nTotVenci  := 0
         _nTotAVenc  := 0
         
               
         dbSelectArea("SZF")
         dbSetOrder(1)

         dbSeek(xFilial("SZF")+SubStr(AllTrim(Posicione("SA1",1,xFilial("SA1")+TSC5->C5_CLIENTE+TSC5->C5_LOJACLI,"A1_CGC")),1,8))
         
         //Chamado 032992 - 01/02/17 - Dados relativos ao cadastro SA1 aonde conforme informações todos os clientes da rede
         //tem esses campos igualmente preenchidos.
         _cRisco   := Posicione("SA1",1,xFilial("SA1")+TSC5->C5_CLIENTE+TSC5->C5_LOJACLI,"A1_XRISCO")
         _dDTUATU  := Posicione("SA1",1,xFilial("SA1")+TSC5->C5_CLIENTE+TSC5->C5_LOJACLI,"A1_XDTRISC") //Campo incluido em 13/02/2017 por Adriana
         _dDTUCOM  := Posicione("SA1",1,xFilial("SA1")+TSC5->C5_CLIENTE+TSC5->C5_LOJACLI,"A1_DTULTRE")      
                  
         _cRede := SZF->ZF_REDE
         _cCnpj := SZF->ZF_CGCMAT
         
         //Mauricio - 02/05/17 - chamado 034919 - mudança na forma de trazer este valor para a rede.
         //_nVLMACU  := Posicione("SA1",1,xFilial("SA1")+TSC5->C5_CLIENTE+TSC5->C5_LOJACLI,"A1_VLACUMU")
         //_dDTMACU  := Posicione("SA1",1,xFilial("SA1")+TSC5->C5_CLIENTE+TSC5->C5_LOJACLI,"A1_DTACUMU")
         _dDTMACU  := fBscDtAc(_cRede,TSC5->C5_CLIENTE,TSC5->C5_LOJACLI)
         _nVLMACU  := fBscAcum(_cRede,TSC5->C5_CLIENTE,TSC5->C5_LOJACLI)
      
         
         _cQrFlt := "SELECT ZF_REDE,SUM(ZF_LCREDE) AS LCREDE,SUM(ZF_SLDREDE) AS SLDREDE, SUM(ZF_VENCIDO) AS VENCIDO, SUM(ZF_AVENCER) AS AVENCER  "
         _cQrFlt += "FROM "+RetSqlName("SZF")+" "
         _cQrFlt += "WHERE ZF_REDE = '"+AllTrim(_cRede)+"' AND D_E_L_E_T_ <> '*' "
         _cQrFlt += "GROUP BY ZF_REDE "
         _cQrFlt += "ORDER BY ZF_REDE" 
      
         TCQUERY _cQrFlt New Alias "TMP"

         dbSelectArea("TMP")
         dbGoTop()
         While TMP->(!Eof())
               _nTotRede   += TMP->LCREDE
               _nTotSdRede += TMP->SLDREDE
               _nTotVenci  += TMP->VENCIDO
               _nTotAVenc  += TMP->AVENCER
               TMP->(dbSkip())
         EndDo
         
         //Apuro agora valor de todos os pedidos em aberto para esta rede no periodo parametrizado..
         _nPedPer := 0
         If Select("TPA6") > 0
            DbSelectArea("TPA6")
            DbCloseArea("TPA6")
      Endif
         
      _cQuery := "SELECT SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1 "
      _cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND "
      _cQuery += "(C6.C6_ENTREG >= '" + Dtos(_dDtEntr1) + "' AND C6.C6_ENTREG <= '" + Dtos(_dDtEntr2)  + "') AND "					
      _cQuery += "C6.C6_CLI = A1.A1_COD AND C6.C6_LOJA = A1.A1_LOJA AND "
      _cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.ZF_REDE = '"+_cRD+"' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C6.D_E_L_E_T_='' AND "
      _cQuery += "((C6.C6_QTDVEN - C6.C6_QTDENT) > 0) "    //somente em aberto
      
      TCQuery _cQuery NEW ALIAS "TPA6"

      DbSelectArea("TPA6")
      DbGotop()
      
      _nPedPer += TPA6->TOTAL
                     
         //Apuro agora valor de todos os pedidos em aberto para esta rede no periodo posterior ao parametrizado...
      _nPedPos := 0
      If Select("TPA6") > 0
            DbSelectArea("TPA6")
            DbCloseArea("TPA6")
      Endif
         
      _cQuery := "SELECT SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1 "
      _cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND "
      _cQuery += "(C6.C6_ENTREG > '" + Dtos(_dDtEntr2)  + "') AND "					
      _cQuery += "C6.C6_CLI = A1.A1_COD AND C6.C6_LOJA = A1.A1_LOJA AND "
      _cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.ZF_REDE = '"+_cRD+"' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C6.D_E_L_E_T_='' AND "
      _cQuery += "((C6.C6_QTDVEN - C6.C6_QTDENT) > 0) "    //somente em aberto
               
      TCQuery _cQuery NEW ALIAS "TPA6"
                                                         
      DbSelectArea("TPA6")
      DbGotop()
      
      _nPedPos += TPA6->TOTAL  
      
      DbSelectArea("TPA6")
      dbCloseArea("TPA6") 
      
      //Contagem de quantidade de pedidos por Rede...
      _nQtdPed := 0
         If Select("TPA5") > 0
            DbSelectArea("TPA5")
            DbCloseArea("TPA5")
         Endif
         
         _cQuery := "SELECT COUNT(C5_NUM) AS TOTPED FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1 "
         _cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND "
         If mv_par01 == 1
            _cQuery += "C5.C5_XPREAPR='B' AND "
         Else 
            _cQuery += "(C5.C5_XPREAPR = 'L' OR C5.C5_XPREAPR = 'B') AND "    
         Endif
         _cQuery += "(C5.C5_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C5_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "        
         _cQuery += "C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA AND "
      _cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.ZF_REDE = '"+_cRD+"' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' "
      
      TCQuery _cQuery NEW ALIAS "TPA5"
                                                         
      DbSelectArea("TPA5")
      DbGotop()
      
      _nQtdPed += TPA5->TOTPED
      
      //Mauricio - 28/09/16 - tratamento para buscar pedidos de venda bloqueados e seus motivos...
      If Select("TPA5") > 0
            DbSelectArea("TPA5")
            DbCloseArea("TPA5")
         Endif
         
         _cQuery := "SELECT C5_NUM, C5_FILIAL FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1 "
         _cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND "
         If mv_par01 == 1
            _cQuery += "C5.C5_XPREAPR='B' AND "
         Else 
            _cQuery += "(C5.C5_XPREAPR = 'L' OR C5.C5_XPREAPR = 'B') AND "    
         Endif
         _cQuery += "(C5.C5_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C5_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "        
         _cQuery += "C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA AND "
      _cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.ZF_REDE = '"+_cRD+"' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' "
      _cQuery += "ORDER BY C5.C5_NUM "

      TCQuery _cQuery NEW ALIAS "TPA5"

      DbSelectArea("TPA5")
      DbGotop()
      
      _aMot := {}
      While TPA5->(!Eof())
            DbSelectArea("ZBH")
            DbSetOrder(1)
            If dbseek(TPA5->C5_FILIAL+TPA5->C5_NUM)
               While ZBH->(!Eof()) .And. ZBH->ZBH_PEDIDO == TPA5->C5_NUM .And. TPA5->C5_FILIAL == ZBH->ZBH_FILIAL
                     //Mauricio - 01/02/17 - chamado 033003
                     //AADD(_aMot,{ZBH->ZBH_FILIAL,ZBH->ZBH_PEDIDO,ZBH->ZBH_CLIENT,ZBH->ZBH_LOJA,ZBH->ZBH_NOME,Alltrim(ZBH->ZBH_MOTIVO)})
                     AADD(_aMot,{ZBH->ZBH_FILIAL,ZBH->ZBH_PEDIDO,ZBH->ZBH_CLIENT,ZBH->ZBH_LOJA,ZBH->ZBH_NOME,Alltrim(ZBH->ZBH_MOTIVO),ZBH->ZBH_CODVEN,Alltrim(ZBH->ZBH_NOMVEN)})
                     ZBH->(dbSkip())              
               Enddo
            Endif             
            TPA5->(dbSkip())
      Enddo
      
      _aMtv := {}
      
      If len(_aMot) > 0
         For _xx := 1 to len(_aMot)
               //Mauricio - 01/02/17 - chamado 033003
               //AADD(_aMtv,{_aMot[_xx][1],_aMot[_xx][2],_aMot[_xx][6],.F.})
               AADD(_aMtv,{_aMot[_xx][1],_aMot[_xx][2],_aMot[_xx][7],_aMot[_xx][8],_aMot[_xx][6],.F.})     
         Next _xx
      Endif
      
      DbSelectArea("TPA5")
      dbCloseArea("TPA5") 
                                 
         @ 200,051 TO 900,700 DIALOG oDlg1 TITLE "PRE APROVACAO CREDITO POR REDE"        //200,051     900,800
         @ 001,007 SAY "Pedidos/Motivo Bloqueio: " of oDlg1 PIXEL
         
         //Borda Interna 01/02/17 - chamado 032992 - e mais linhas de informacoes incluidos na tela, intercalados abaixo
         @ 075, 170 GROUP oGroup1 TO 140, 320 PROMPT "" OF oDlg1 COLOR 0, 16777215 PIXEL 
                     
         aHeaderT := {}

         AAdd(aHeaderT,{"FILIAL"                   ,"_cfill"    ,"",008,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
         AAdd(aHeaderT,{"PEDIDO"                   ,"_cPdd"     ,"",008,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})      
         //Mauricio - 01/02/17 - chamado 033003
         AAdd(aHeaderT,{"VENDEDOR"                 ,"_cVdd"     ,"",008,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
         AAdd(aHeaderT,{"NOME"                     ,"_cNdd"     ,"",020,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
         
         AAdd(aHeaderT,{"MOTIVO    "               ,"_cMott"    ,"",200,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
                                       
         IF len(_aMtv) <= 0
         AADD(_aMtv,{"","","","","",.F.})
         Endif
                                 //003,007,060,340                                                                             
         oCabD4 :=MsNewGetDados():New( 008,007,065,320,,"AllwaysTrue",,"",,,5,,,"AllwaysTrue",oDlg1,aHeaderT,@_aMtv) 
         oCabD4:oBrowse:Refresh()
         oCabD4:GoBottom()
         oCabD4:GoTop()
         oCabD4:Refresh(.T.)
         oDlg1:Refresh()
         GetdRefresh()
         SysRefresh()
            
         @ 060,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL                                       
         @ 070,010 SAY "Matriz CNPJ (8 digitos): "+AllTrim(_cCnpj) of oDlg1 PIXEL
         @ 080,010 SAY "Rede: "+AllTrim(_cRede) of oDlg1 PIXEL
         @ 080,180 SAY "RISCO: " of oDlg1 PIXEL
         @ 080,250 SAY _cRisco of oDlg1 PIXEL
               
         @ 090,010 SAY "Qtdade. Pedidos: " of oDlg1 PIXEL 
         @ 090,130 SAY Transform(_nQtdPed  ,"@E 999,999,999.99") of oDlg1 PIXEL
         @ 090,180 SAY "Data Ultima Atualiz.:" of oDlg1 PIXEL
         @ 090,250 SAY DTOC(_dDTUATU) of oDlg1 PIXEL
               
         @ 100,010 SAY "Limite de Credito desta Rede de Lojas: " of oDlg1 PIXEL 
         @ 100,130 SAY Transform(_nTotRede  ,"@E 999,999,999.99") of oDlg1 PIXEL
         @ 100,180 SAY "Data Ultima Compra:" of oDlg1 PIXEL
         @ 100,250 SAY DTOC(_dDTUCOM) of oDlg1 PIXEL
                           
         @ 110,010 SAY "Utilizado desta Rede de Lojas:" of oDlg1 PIXEL 
         @ 110,130 SAY Transform(_nTotSdRede,"@E 999,999,999.99") of oDlg1 PIXEL
         @ 110,180 SAY "Data Maior Acumulo:" of oDlg1 PIXEL
         @ 110,250 SAY DTOC(_dDTMACU) of oDlg1 PIXEL
         
         //05/10/16 - Incluido na tela, mas a informação ira vir somente quando for implementada a pre-aprovacao dos pedidos de venda....
         @ 120,010 SAY "Valor pedidos ja liberados(pre aprovação):" of oDlg1 PIXEL
         @ 120,130 SAY " - "
         @ 120,180 SAY "Valor Maior Acumulo:" of oDlg1 PIXEL
         @ 120,250 SAY Transform(_nVLMACU,"@E 999,999,999.99") of oDlg1 PIXEL
         
         _cPer := "Valor Pedidos entre("+DTOC(_dDtEntr1)+" e "+DTOC(_dDtEntr2)+"): "
         @ 130,010 SAY _cPer of oDlg1 PIXEL 
         @ 130,130 SAY Transform(_nPedPer,"@E 999,999,999.99") of oDlg1 PIXEL
         @ 140,010 SAY "Total utilizado: " of oDlg1 PIXEL        
         @ 140,130 SAY Transform((_nTotSdRede)+_nPedPer,"@E 999,999,999.99") of oDlg1 PIXEL
         @ 150,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL
         @ 160,010 SAY "PERCENTUAL" of oDlg1 PIXEL
         @ 160,130 SAY Transform(((_nTotSdRede+_nPedPer)/_nTotRede)*100,"@E 999999.99 %") of oDlg1 PIXEL
         @ 170,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL
         @ 180,010 SAY "Valor Total Vencidos: " of oDlg1 PIXEL        
         @ 180,130 SAY Transform(_nTotVenci,"@E 999,999,999.99") of oDlg1 PIXEL
         @ 190,010 SAY "Valor Total A Vencer: " of oDlg1 PIXEL        
         @ 190,130 SAY Transform(_nTotAvenc,"@E 999,999,999.99") of oDlg1 PIXEL                  
         _cPos := "Valor Pedidos após "+DTOC(_dDtEntr2)+": "
         @ 200,010 SAY _cPos  of oDlg1 PIXEL                                          
         @ 200,130 SAY Transform(_nPedPos,"@E 999,999,999.99") of oDlg1 PIXEL
         //@ 130,012 BUTTON OemToAnsi("SAIR") SIZE 34,11 ACTION(_nOpc := 1,oDlg1:End() ) of oDlg1 PIXEL
         @ 220,012 BUTTON OemToAnsi("PRE APROVA TODOS") SIZE 60,11 ACTION(_nOpc := 4,oDlg1:End() ) of oDlg1 PIXEL      //libera todos
         @ 220,190 BUTTON OemToAnsi("PRE BLOQUEIA TODOS") SIZE 60,11 ACTION(_nOpc := 3,oDlg1:End() ) of oDlg1 PIXEL     //rejeita
         
         @ 240,012 BUTTON OemToAnsi("SAIR DA REDE") SIZE 50,11 ACTION(_nOpc := 1,oDlg1:End() ) of oDlg1 PIXEL
         @ 240,190 BUTTON OemToAnsi("SAIR DA ROTINA") SIZE 50,11 ACTION(_nOpc := 5,oDlg1:End() ) of oDlg1 PIXEL       
                        
         ACTIVATE DIALOG oDlg1 CENTERED
                                                                                    
         dbSelectArea("TMP")
         dbCloseArea()               
         Endif
         
         //Mauricio - 23/03/16 - sai da rotina      
         If _nOpc == 5
            exit      
         Endif
               
         If _nOpc == 4 .Or. _nOpc == 3
                                                   
            While TSC5->(!Eof()) .And. _cRD == TSC5->ZF_REDE
               
                  DbSelectArea("TSC5")                    
                  _cPD := TSC5->C5_NUM
                  
                  While TSC5->(!Eof()) .And. _cRD == TSC5->ZF_REDE .And. _cPD == TSC5->C5_NUM            
                                             
                        DbSelectArea("SC5")
                        DbSetOrder(1)
                        If Dbseek(xFilial("SC5")+_cPD)               
                        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        //³PRE APROVACAO BLOQUEIO ³
                        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        If _nOpc == 3
                           If RecLock("SC5",.F.)
                              SC5->C5_XPREAPR := "B"
                              SC5->(MsUnlock())
                           EndIf		                   		                   		                   
                           /*
                           if Reclock("SC5",.F.)
                           SC5->C5_XPREAPR := "B"
                           SC5->(MsUnlock())
                        Endif      		                         		    
                        */
                        ElseIf _nOpc == 4
                           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                           //³Liberacao do pedido pre aprovado³
                           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                           If RecLock("SC5",.F.)
                                 SC5->C5_XPREAPR := "L"
                                 SC5->(MsUnlock())
                           EndIf

                           //INICIO Ticket  8      - Abel Babini   - 31/01/2022 - Gravação da liberação na tabela de pedidos liberados.
                           cPerfPgt := ''
                           nMedAtr	:= 0
                           aPerPgt	:= {}
                           
                           //Carrega Perfil de Pagamento
                           aPerPgt 	:= StaticCall(ADFIN103P,fMedPgt,SC5->C5_CLIENTE, SC5->C5_LOJACLI) //01/02/2022 - Ajuste de Variáveis
                           IF ValType(aPerPgt) = 'A' 
                              cPerfPgt	:= IIF(Empty(Alltrim(aPerPgt[2])) .OR. ValType(aPerPgt) != 'A','NDA', aPerPgt[2])
                              nMedAtr		:= IIF(ValType(aPerPgt) != 'A',0, aPerPgt[1])
                           ELSE
                              cPerfPgt	:= 'NDA'
                           ENDIF
                           //GRAVA REGISTRO DA LIBERAÇÃO DE CRÉDITO
                           If RecLock("ZEJ",.T.)
                              ZEJ->ZEJ_FILIAL	:= SC5->C5_FILIAL					//
                              ZEJ->ZEJ_NUM		:= SC5->C5_NUM						//
                              ZEJ->ZEJ_DTLIB	   := MsDate()							//
                              ZEJ->ZEJ_HRLIB	   := TIME()							//
                              ZEJ->ZEJ_USRLIB	:= cUserName						//
                              ZEJ->ZEJ_VLLIB	   := SC5->C5_XTOTPED				//
                              ZEJ->ZEJ_MOTLIB	:= ''									//
                              ZEJ->ZEJ_PARECE	:= ''									//
                              ZEJ->ZEJ_PERFPG	:= cPerfPgt								//	
                              ZEJ->ZEJ_RATCIS	:= _cRisco								//
                              ZEJ->ZEJ_MEDATR	:= nMedAtr								//
                              ZEJ->ZEJ_VLPED	   := _nPedPer								//
                              ZEJ->ZEJ_VLAVEN	:= _nTotAvenc	//
                              ZEJ->ZEJ_VLVENC	:= _nTotVenci							//
                              ZEJ->ZEJ_VLPESP	:= 0											//
                              ZEJ->ZEJ_TTACUM	:= 0											//	
                              ZEJ->ZEJ_LIMCRD	:= _nTotRede							//
                              ZEJ->(MsUnlock())
                           Endif
                           //FIM Ticket  8      - Abel Babini   - 31/01/2022 - Gravação da liberação na tabela de pedidos liberados.
                           /*
                           if Reclock("SC5",.F.)
                              SC5->C5_XPREAPR := "L"
                              SC5->(MsUnlock())
                           Endif
                           */					                        	                      
                        EndIf
                        //Mauricio - 15/02/17 - log de registro		  
                           dbSelectArea("ZBE")
                           RecLock("ZBE",.T.)
                           Replace ZBE_FILIAL WITH xFilial("ZBE")
                           Replace ZBE_DATA   WITH dDataBase
                           Replace ZBE_HORA   WITH TIME()
                           Replace ZBE_USUARI WITH UPPER(Alltrim(cUserName))
                           Replace ZBE_LOG    WITH "PEDIDO " + SC5->C5_NUM + " C5_FLAGFIN: "+SC5->C5_FLAGFIN + " C5_XPREAPR: "+SC5->C5_XPREAPR
                           Replace ZBE_MODULO WITH "SC5"
                           Replace ZBE_ROTINA WITH "ADFIN024P"
                           ZBE->(MsUnlock())
                                             
                     Endif
                     DbSelectArea("TSC5")
                        TSC5->(DbSkip())   	                    
               Enddo                       
                                                                                                                           
            Enddo 
         Else                                                           
            DbSelectArea("TSC5")
            TSC5->(DbSkip())
            If TSC5->ZF_REDE == _cRD
               _lRDPRI := .F.
            Else
               _lRDPRI := .T.
            Endif
         Endif     
   Enddo 

   MsUnLockAll()

   RestArea(aAreaSC5)
   Eval(bFiltrabrw)
   dbgotop()
   SYSREFRESH() 
   RestArea(aArea)

Return() 

Static Function ProcSql()
	
   MsProcTxt("Selecionando Dados  .....")
      
   nTotCredRede := nTotSaldRede := nTotCred := nTotSld := 0
   nTotVencRd   := nTotAvenRD   := nTotVCD   := nTotAVC  := 0

   If Select("ZF1") > 0
      DbSelectArea("ZF1")
      DbCloseArea("ZF1")
   Endif


   /*
   cQuery := "SELECT ZF_REDE,ZF_NOMERED,SUBSTRING(A1_CGC,1,8) AS A1_CGC, "
   cQuery += "       (CASE WHEN A1_LC>ZF_LCREDE THEN A1_LC         ELSE ZF_LCREDE END) AS LC, "
   cQuery += "       (CASE WHEN E1_TIPO = 'RA'  THEN E1_SALDO*(-1) ELSE E1_SALDO  END) AS SALDO "
   cQuery += "FROM "+RetSQLName("SZF")+" AS SZF, "+RetSQLName("SA1")+" AS SA1 LEFT OUTER JOIN "+RetSQLName("SE1")+" AS SE1 "
   cQuery += "ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND E1_TIPO NOT IN ('PR','NCC') AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') AND E1_SALDO > 0  AND SE1.D_E_L_E_T_='' "
   cQuery += "WHERE LEFT(A1_CGC,8) = ZF_CGCMAT AND SZF.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' "
   cQuery += "ORDER BY ZF_REDE, LC DESC, ZF_NOMERED" 
   */

   //Mauricio - 21/09/16 implementado apuracao e gravacao dos campos ZF_VENCIDO e ZF_AVENCER solicitado por Alberto.
   //e ajustado o relatorio com novos campos.

   _dDT  := Date()
   _dDTA := (Date() + 1)

   //Everson - 23/04/2020. Chamado 057170.
   cQuery := ""
   cQuery += " SELECT "
   cQuery += " FONTE.ZF_REDE, A1_CGC, MAX(LC) AS LC, SUM(ISNULL(SALDO,0)) AS SALDO, SUM(VENC1+VENC2) AS VENC, SUM(AVENC1+AVENC2) AS AVENC, "
   cQuery += " SZF.ZF_LCREDE, SZF.ZF_SLDREDE, SZF.ZF_VENCIDO, SZF.ZF_AVENCER "
   cQuery += " FROM "
   cQuery += " ( "
   //

      cQuery += "SELECT ZF_REDE,ZF_NOMERED,SUBSTRING(A1_CGC,1,8) AS A1_CGC, A1_MSBLQL, "
      cQuery += "       (CASE WHEN A1_LC>ZF_LCREDE THEN A1_LC         ELSE ZF_LCREDE END) AS LC, "
      cQuery += "       (CASE WHEN E1_TIPO = 'RA'  THEN E1_SALDO*(-1) ELSE E1_SALDO  END) AS SALDO, "
      cQuery += "       (CASE WHEN E1_TIPO = 'RA' AND (E1_VENCREA < '"+DTOS(_dDT)+"') THEN E1_SALDO*(-1) ELSE 0  END) AS VENC1, "
      cQuery += "       (CASE WHEN E1_TIPO <> 'RA' AND (E1_VENCREA < '"+DTOS(_dDT)+"') THEN E1_SALDO ELSE 0  END) AS VENC2, "
      cQuery += "       (CASE WHEN E1_TIPO = 'RA' AND (E1_VENCREA BETWEEN '"+DTOS(_dDT)+"' AND '"+DTOS(_dDTA)+"') THEN E1_SALDO*(-1) ELSE 0  END) AS AVENC1, "
      cQuery += "       (CASE WHEN E1_TIPO <> 'RA' AND (E1_VENCREA BETWEEN '"+DTOS(_dDT)+"' AND '"+DTOS(_dDTA)+"') THEN E1_SALDO ELSE 0  END) AS AVENC2 "
      cQuery += "FROM "+RetSQLName("SZF")+" AS SZF, "+RetSQLName("SA1")+" AS SA1 LEFT OUTER JOIN "+RetSQLName("SE1")+" AS SE1 "
      cQuery += "ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND E1_TIPO NOT IN ('PR','NCC','AB-') AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') AND E1_SALDO > 0  AND SE1.D_E_L_E_T_='' " // 05/04/2019 William Costa 048296 || OS 049620 || FINANCAS || ANDREA || 8351 || SALDO REDE
      cQuery += "WHERE LEFT(A1_CGC,8) = ZF_CGCMAT AND SZF.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' "
      //cQuery += "ORDER BY ZF_REDE, LC DESC, ZF_NOMERED" //Everson - 23/04/2020. Chamado 057170.

   //Everson - 23/04/2020. Chamado 057170.
   cQuery += " ) AS FONTE "
   cQuery += " LEFT OUTER JOIN "
   cQuery += " (SELECT SZF.ZF_CGCMAT, SZF.ZF_LCREDE, SZF.ZF_SLDREDE, SZF.ZF_VENCIDO, SZF.ZF_AVENCER  FROM " + RetSQLName("SZF") + " AS SZF WHERE SZF.D_E_L_E_T_ = '') AS SZF ON  "
   cQuery += " FONTE.A1_CGC = ZF_CGCMAT "
   cQuery += " GROUP BY "
   cQuery += " FONTE.ZF_REDE, A1_CGC, "
   cQuery += " SZF.ZF_LCREDE, SZF.ZF_SLDREDE, SZF.ZF_VENCIDO, SZF.ZF_AVENCER "
   cQuery += " HAVING "
   cQuery += " ( MAX(LC) <> SZF.ZF_LCREDE OR SUM(ISNULL(SALDO,0)) <> SZF.ZF_SLDREDE OR SUM(VENC1+VENC2) <> SZF.ZF_VENCIDO OR SUM(AVENC1+AVENC2) <> SZF.ZF_AVENCER) "
   cQuery += " ORDER BY FONTE.ZF_REDE, LC DESC "
   //

   TCQUERY cQuery NEW ALIAS "ZF1"
   Processa( {|| RunRel()},"Aguarde ..." )
	
Return
/*/{Protheus.doc} GravaSZF
   (long_description)
   @type  Static Function
   @author 
   @since 
   @version 01
   /*/ 
Static Function RunRel()

   dbSelectArea("ZF1")
   dbGoTop()
   ProcRegua(RecCount())
                                                
   While ZF1->(!Eof())

      //Everson - 23/04/2020. Chamado 057170.
      If ZF1->LC = ZF1->ZF_LCREDE .And. ZF1->SALDO = ZF1->ZF_SLDREDE .And. ZF1->VENC = ZF1->ZF_VENCIDO .And. ZF1->AVENC = ZF1->ZF_AVENCER
         Conout( DToC(Date()) + " " + Time() + " ADFIN024P - RunRel - desconsiderar : "+AllTrim(ZF1->ZF_REDE)+" - "+AllTrim(ZF1->A1_CGC))
         ZF1->(dbSkip())
         Loop 

      EndIf
      //
                                                      
      nSld     := 0
      _nVenc   := 0
      _nAvenc  := 0
      
      Conout( DToC(Date()) + " " + Time() + " ADFIN024P - RunRel - Atualizando limites : "+AllTrim(ZF1->ZF_REDE)+" - "+AllTrim(ZF1->A1_CGC)) //Everson - 23/04/2020. Chamado 057170.
      IncProc(OemToAnsi("Atualizando limites : "+AllTrim(ZF1->ZF_REDE)+" - "+AllTrim(ZF1->A1_CGC)))   	     
      
      cRede     := ZF1->ZF_REDE   
      //cNomeRede := ZF1->ZF_NOMERED //Everson - 23/04/2020. Chamado 057170.
      cCGC      := ZF1->A1_CGC
      nLC       := ZF1->LC
      
      //
      While ZF1->ZF_REDE+ZF1->A1_CGC == cRede + cCGC

         //
         nSld    += ZF1->SALDO
         _nVenc  += ZF1->VENC
         _nAVenc += ZF1->AVENC

         //
         ZF1->(dbSkip())

      EndDo
      
      GravaSZF()
      
   Enddo    
   
Return()   
/*/{Protheus.doc} GravaSZF
   (long_description)
   @type  Static Function
   @author 
   @since 
   @version 01
   /*/    
Static Function GravaSZF()

   DbSelectArea("SZF")
   SZF->(dbSetOrder(1))
   If SZF->(dbSeek( xFilial() + cCGC ))

      u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE","FINANCEIRO","ADFIN024P",;
      "CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(nLC),ComputerName(),LogUserName())

      //
      RecLock("SZF",.F.)
         SZF->ZF_LCREDE  := nLC
         SZF->ZF_SLDREDE := nSld
         SZF->ZF_VENCIDO := _nVenc
         SZF->ZF_AVENCER := _nAVENC     
      MsUnlock()

   EndIf
   dbSelectArea("ZF1")

Return()
/*/{Protheus.doc} fBscAcum
   (long_description)
   @type  Static Function
   @author 
   @since 
   @version 01
   /*/
Static Function fBscAcum(_cRede,c_Cli,c_Loj)

   _nMaior := Posicione("SA1",1,xFilial("SA1")+c_Cli+c_Loj,"A1_VLACUMU")

   If Select("ACUM") > 0
      DbSelectArea("ACUM")
      DbCloseArea("ACUM")
   Endif

   _cQryM := "SELECT ZF_REDE,ZF_VLACUMU  "
   _cQryM += "FROM "+RetSqlName("SZF")+" "
   _cQryM += "WHERE ZF_REDE = '"+AllTrim(_cRede)+"' AND D_E_L_E_T_ <> '*' "
   _cQryM += "ORDER BY ZF_REDE" 
      
   TCQUERY _cQryM New Alias "ACUM"

   _nCt := 0
   _nValAcu := 0
   DbSelectarea("ACUM")
   Dbgotop()
   While ACUM->(!EOf())
         _nCt ++
         _nValAcu := ACUM->ZF_VLACUMU
         ACUM->(dbskip())
   Enddo

   If _nCt > 1
      _nMaior := _nValAcu
   Endif

   DbCLoseArea("ACUM")

Return(_nMaior)
/*/{Protheus.doc} fBscAcum
   (long_description)
   @type  Static Function
   @author 
   @since 
   @version 01
   /*/
Static Function fBscDtAc(_cRede,c_Cli,c_Loj)

   _dDTM := CTOD("  /  /  ")
   _dDTM := Posicione("SA1",1,xFilial("SA1")+c_Cli+c_Loj,"A1_DTACUMU")

   If Select("ACUM") > 0
      DbSelectArea("ACUM")
      DbCloseArea("ACUM")
   Endif

   _cQryM := "SELECT ZF_REDE,ZF_DTACUMU  "
   _cQryM += "FROM "+RetSqlName("SZF")+" "
   _cQryM += "WHERE ZF_REDE = '"+AllTrim(_cRede)+"' AND D_E_L_E_T_ <> '*' "
   _cQryM += "ORDER BY ZF_REDE" 
      
   TCQUERY _cQryM New Alias "ACUM"

   _nCt := 0
   _sDTM := "        "
   DbSelectarea("ACUM")
   Dbgotop()
   While ACUM->(!EOf())
         _nCt ++
         _sDTM := ACUM->ZF_DTACUMU
         ACUM->(dbskip())
   Enddo

   If _nCt > 1
      _dDTM := STOD(_sDTM)
   Endif

   DbCLoseArea("ACUM")

Return(_dDTM)   
