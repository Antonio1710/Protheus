#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} User Function EXPPRJNF
   Exporta para txt massa de dados relativos ao controle de projetos/investimentos.Baseado nas NFs, feito em cima do programa EXPPROJ utilizado até esta data.
   @type  Function
   @author user
   @since 21/01/2015
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   @history chamado 050729 - FWNM - 13/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Bloqueado, pois existem outras 2 rotinas que fazem a mesma coisa (EXPPROJ e ADEST031R)
/*/
User Function EXPPRJNF()  

   Local _cRet := ""

   Private oGeraTxt
   Private _cPerg := "EXPPRJ"
   Private _cArqTmp

   U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Exporta para txt massa de dados relativos ao controle de projetos/investimentos.Baseado nas NFs, feito em cima do programa EXPPROJ utilizado até esta data.')

   // Bloqueado, pois existem outras 2 rotinas que fazem a mesma coisa (EXPPROJ e ADEST031R)
   msgAlert("Rotina desativada e obsoleta! Utilizar EXPPROJ ou ADEST031R...") // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 13/07/2020

Return

   PutSx1(_cPerg,"01","Filial de           ?"    , "Filial de           ?"    , "Filial de           ?"    , "mv_ch1","C",2 ,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","")
   PutSx1(_cPerg,"02","Filial ate          ?"    , "Filial ate          ?"    , "Filial ate          ?"    , "mv_ch2","C",2 ,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","")
   PutSx1(_cPerg,"03","Da emissao          ?"    , "Da emissao          ?"    , "Da emissao          ?"    , "mv_ch3","D",8 ,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","")
   PutSx1(_cPerg,"04","Ate emissao         ?"    , "Ate emissao         ?"    , "Ate emissao         ?"    , "mv_ch4","D",8 ,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","")
   PutSx1(_cPerg,"05","Arquivo de saida    ?"    , "Arquivo de saida    ?"    , "Arquivo de saida    ?"    , "mv_ch5","C",50,0,0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")

   pergunte(_cPerg,.T.)

   dbSelectArea("SC7")
   dbSetOrder(1)

   @ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Geracao TXT de Projetos Baseado nas NFs")
   @ 02,10 TO 080,190
   @ 10,018 Say " Este programa ira gerar um arquivo texto, conforme os parame- "
   @ 18,018 Say " tros definidos  pelo usuario,  com os registros referentes as "
   @ 26,018 Say " movimentacoes de projetos mas baseado nas Notas Fiscais.      "

   @ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
   @ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)

   Activate Dialog oGeraTxt Centered

   If Select("PROJ") > 0
      PROJ->(DbCloseArea())
   ENDIF
   If Select("PSD1") > 0   
      PSD1->(DbCloseArea())
   ENDIF
   If Select("PSD2") > 0   
      PSD2->(DbCloseArea())
   Endif   
   If File(_cArqTmp+".DBF"); fErase(_cArqTmp+".DBF"); EndIf
   If File(_cArqTmp); fErase(_cArqTmp); EndIf

   Return()

   Static Function OkGeraTxt

   Private nHdl    := fCreate(mv_par05)

   Private cEOL    := "CHR(13)+CHR(10)"
   If Empty(cEOL)
      cEOL := CHR(13)+CHR(10)
   Else
      cEOL := Trim(cEOL)
      cEOL := &cEOL
   Endif

   If nHdl == -1
      MsgAlert("O arquivo de nome "+mv_par05+" nao pode ser executado! Verifique os parametros.","Atencao!")
      Return
   Endif

   Processa({|| RunCont() },"Processando...") 

   // fecha arquivo temporario caso tenha sido criado
   If Select("PROJ") > 0
         DbSelectArea("PROJ")
         PROJ->(DbCloseArea())
         If File(_cArqTmp+".DBF"); fErase(_cArqTmp+".DBF"); EndIf
         If File(_cArqTmp); fErase(_cArqTmp); EndIf
   EndIf
   Return()

   Static Function RunCont

   Local nTamLin, cLin, cCpo
   _aStr := {}

   AADD(_aStr,{'FILIAL'    ,"C",02})
   AADD(_aStr,{'PEDIDO'    ,"C",06})
   AADD(_aStr,{'PEDATE'    ,"C",01}) &&Chamado 008500 - Inclusao de status para pedidos parcialmente atendidos.
   AADD(_aStr,{'REQUISICAO',"C",06})
   AADD(_aStr,{'NFISCAL'   ,"C",09})
   AADD(_aStr,{'SERIE'     ,"C",03})
   AADD(_aStr,{'DATAEMISS' ,"C",10})
   AADD(_aStr,{'ITEM'      ,"C",04})
   AADD(_aStr,{'CCUSTO'    ,"C",09})
   AADD(_aStr,{'CODFORNEC' ,"C",09})
   AADD(_aStr,{'NOME'      ,"C",40})
   AADD(_aStr,{'PRODUTO'   ,"C",15})
   AADD(_aStr,{'DESCRI'    ,"C",40})
   AADD(_aStr,{'VALOR'     ,"N",17,02})
   AADD(_aStr,{'PROJETO'   ,"C",09})
   AADD(_aStr,{'CONTA'     ,"C",20})
   AADD(_aStr,{'ENCERRADO' ,"C",01})
   AADD(_aStr,{'DTDIGNF'   ,"C",10})  &&Chamado 005696 - Mauricio.
   AADD(_aStr,{'VALORNF'   ,"N",17,02}) &&Chamado 007139 - Mauricio.
   AADD(_aStr,{'NFDEVOL'   ,"C",09})  &&Chamado 007452 - Mauricio - inicio
   AADD(_aStr,{'SERDEV'    ,"C",03})  
   AADD(_aStr,{'VLRDEV'    ,"N",17,02})  
   AADD(_aStr,{'DTNFDEV'   ,"C",10})  &&Chamado 007452 - Mauricio - fim
   AADD(_aStr,{'DESCODPRO' ,"C",41})  && Chamado
   AADD(_aStr,{'OBSERVACA' ,"C",50})  && Chamado 

   //AADD(_aStr,{'DTINIPRE'  ,"C",10})
   //AADD(_aStr,{'DTFIMPRE'  ,"C",10})
   //AADD(_aStr,{'DATAINI'   ,"C",10})
   //AADD(_aStr,{'DATAFIM'   ,"C",10})
   //AADD(_aStr,{'VALCIPI'   ,"N",17,02})

   _cArqTmp :=CriaTrab(_aStr,.T.)
   DbUseArea(.T.,,_cArqTmp,"PROJ",.F.,.F.)
   //_cIndex:="PEDIDO+ITEM"
   _cIndex:="PEDIDO+ITEM"
   indRegua("PROJ",_cArqTmp,_cIndex,,,"Criando Indices...") 

   If Select ("PSD3") > 0
      DbSelectArea("PSD3")
      PSD3->(DbCloseArea())
   Endif

   _cQuery := "SELECT SD3.D3_FILIAL, SD3.D3_COD, SD3.D3_CONTA, SD3.D3_EMISSAO, SD3.D3_CC, SD3.D3_CUSTO1, SB1.B1_DESC, SD3.D3_DOC, SD3.D3_ESTORNO, SD3.D3_QUANT, SD3.D3_PROJETO, SD3.D3_CODPROJ "
   _cQuery += "FROM "
   _cQuery += RetSqlName( "SD3" ) + " SD3, "
   _cQuery += RetSqlName( "SB1" ) + " SB1 "
   //_cQuery += "WHERE SD3.D3_PROJETO = '" + _cProjeto + "' "
   _cQuery += "WHERE SD3.D3_PROJETO <> '         ' "
   _cQuery += "AND SD3.D3_EMISSAO BETWEEN '" + DtoS( mv_par03 ) + "' AND '" + DtoS( mv_par04 ) + "' "
   _cQuery += "AND SD3.D3_FILIAL BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
   _cQuery += "AND SD3.D3_CF = 'RE0' "      && somente requisicoes.
   _cQuery += "AND SD3.D3_ESTORNO = ' ' "   &&somente nao estornados
   _cQuery += "AND SD3.D_E_L_E_T_ = '' "
   _cQuery += "AND SB1.B1_COD = SD3.D3_COD "
   //_cQuery += "AND SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "' "
   _cQuery += "AND SB1.D_E_L_E_T_ = '' "
   _cQuery += "ORDER BY SD3.D3_EMISSAO "

   TcQuery _cQuery NEW ALIAS "PSD3"
                           
   DbSelectArea("PSD3")
   DbGotop()
   While !EOF()
         RecLock("PROJ",.T.)
            PROJ->FILIAL     := PSD3->D3_FILIAL 
            PROJ->PEDIDO     := SPACE(06)
            PROJ->REQUISICAO := PSD3->D3_DOC
            PROJ->NFISCAL    := SPACE(09)
            PROJ->SERIE      := SPACE(03)
            PROJ->DATAEMISS  := substr(PSD3->D3_EMISSAO,7,2)+"/"+substr(PSD3->D3_EMISSAO,5,2)+"/"+substr(PSD3->D3_EMISSAO,1,4)
            PROJ->ITEM       := SPACE(04)
            PROJ->CCUSTO     := PSD3->D3_CC
            PROJ->CODFORNEC  := SPACE(09)
            PROJ->NOME       := SPACE(40)
            PROJ->PRODUTO    := PSD3->D3_COD
            PROJ->DESCRI     := SUBSTR(PSD3->B1_DESC,1,40)
            PROJ->VALORNF    := PSD3->D3_CUSTO1
            PROJ->PROJETO    := PSD3->D3_PROJETO
            PROJ->CONTA      := PSD3->D3_CONTA
            PROJ->ENCERRADO  := "E"  //SPACE(01) Solicitado por fabiana vir sempre E - 15/01/10.
         PROJ->DESCODPRO  := IIF(!EMPTY(PSD3->D3_CODPROJ), Posicione("ZZC",1,xFilial("ZZC")+PSD3->D3_CODPROJ,"ZZC_DESCR"), "")
         MsUnlock()
         DbSelectArea("PSD3")
         DbSkip()
   Enddo

   If Select ("PSD1") > 0
      DbSelectArea("PSD1")
      PSD1->(DbCloseArea())
   Endif
         
   _cQuery2 := "SELECT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_PEDIDO, SD1.D1_ITEMPC, SD1.D1_QUANT, SD1.D1_CUSTO, SD1.D1_DTDIGIT, SD1.D1_ITEM, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_PROJETO, SD1.D1_EMISSAO, SD1.D1_CC, SD1.D1_COD, "
   _cQuery2 += "SC7.C7_FILIAL, SC7.C7_PRODUTO, SC7.C7_EMISSAO, SC7.C7_QUJE, SC7.C7_QUANT,SC7.C7_CONTA, SC7.C7_ENCER, SC7.C7_CC, SC7.C7_TOTAL, SC7.C7_VALIPI, SC7.C7_NUM, SC7.C7_ITEM, "
   _cQuery2 += "SB1.B1_DESC, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NOME, SC7.C7_PROJETO, SC7.C7_CODPROJ, SC7.C7_OBS, SD1.D1_TOTAL, SD1.D1_VALIPI, SD1.D1_CONTA, SD1.D1_CC "
   _cQuery2 += "FROM "
   _cQuery2 += RetSqlName( "SD1" ) + " SD1, "
   _cQuery2 += RetSqlName( "SC7" ) + " SC7, "
   _cQuery2 += RetSqlName( "SB1" ) + " SB1, "
   _cQuery2 += RetSqlName( "SA2" ) + " SA2 "
   _cQuery2 += "WHERE SD1.D1_PEDIDO = SC7.C7_NUM "
   _cQuery2 += "AND SD1.D1_ITEMPC = SC7.C7_ITEM "
   _cQuery2 += "AND SD1.D1_PROJETO <> '         ' "
   _cQuery2 += "AND SD1.D1_DTDIGIT BETWEEN '" + DtoS( mv_par03 ) + "' AND '" + DtoS( mv_par04 ) + "' "
   _cQuery2 += "AND SD1.D1_FILIAL BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
   _cQuery2 += "AND SD1.D1_ITEMPC = SC7.C7_ITEM "
   _cQuery2 += "AND SD1.D1_FILIAL = SC7.C7_FILIAL "
   _cQuery2 += "AND SB1.B1_COD = SD1.D1_COD "
   _cQuery2 += "AND SA2.A2_COD = SD1.D1_FORNECE "
   _cQuery2 += "AND SA2.A2_LOJA = SD1.D1_LOJA "
   _cQuery2 += "AND SD1.D_E_L_E_T_ = '' "
   _cQuery2 += "AND SC7.D_E_L_E_T_ = '' "
   _cQuery2 += "AND SB1.D_E_L_E_T_ = '' "
   _cQuery2 += "AND SA2.D_E_L_E_T_ = '' "

   TcQuery _cQuery2 NEW ALIAS "PSD1"

   DbSelectArea("PSD1")
   DbGotop()
   While PSD1->(!EOF())
         _cNOTA := PSD1->D1_DOC
         _cSER  := PSD1->D1_SERIE
         _cDT   := PSD1->D1_DTDIGIT
         _cEMIS := PSD1->D1_EMISSAO
         _nVlr  := PSD1->D1_CUSTO
         _cFOR  := PSD1->D1_FORNECE
         _cLOJ  := PSD1->D1_LOJA
         _cITE  := PSD1->D1_ITEM
         _nQTD  := PSD1->D1_QUANT
            
         &&Chamado 007452 - Mauricio.
         If Select ("PSD2") > 0
            DbSelectArea("PSD2")
            PSD2->(DbCloseArea())
         Endif
            
         _cQuery3 := "SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_QUANT, SD2.D2_TOTAL, SD2.D2_EMISSAO "
         _cQuery3 += "FROM "
         _cQuery3 += RetSqlName( "SD2" ) + " SD2 "
         _cQuery3 += "WHERE SD2.D2_NFORI = '" + _cNOTA + "' "
         _cQuery3 += "AND SD2.D2_SERIORI = '" + _cSER + "' "
         _cQuery3 += "AND SD2.D2_CLIENTE = '" + _cFOR + "' "
         _cQuery3 += "AND SD2.D2_LOJA = '" + _cLOJ + "' "
         _cQuery3 += "AND SD2.D2_ITEMORI = '" + _cITE + "' "
         _cQuery3 += "AND SD2.D_E_L_E_T_ = '' "
                                       
         TcQuery _cQuery3 NEW ALIAS "PSD2"

         DbSelectarea("PSD2")
         DBGOTOP()
         IF PSD2->(!EOF())
            &&Tratamento para apurar valor proporcional para NF devolucao conforme acordado com Jair Sbaraini.
            _cNFDEV := PSD2->D2_DOC
            _cSEDEV := PSD2->D2_SERIE
            If _nQTD <> PSD2->D2_QUANT
               _nVLDEV := Round((_nVlr/_nQTD)* PSD2->D2_QUANT,2)
            Else
               _nVLDEV := _nVlr
            Endif
            _dDTDEV := PSD2->D2_EMISSAO
         ELSE
            _cNFDEV := SPACE(09)
            _cSEDEV := SPACE(02)
            _nVLDEV := 0.00
            _dDTDEV := SPACE(10)
         ENDIF
            
         RecLock("PROJ",.T.)
         PROJ->FILIAL     := PSD1->C7_FILIAL 
         PROJ->PEDIDO     := PSD1->C7_NUM
         //PROJ->PEDATE     := IIF(PSC7->C7_QUJE > 0 .AND. PSC7->C7_QUJE < PSC7->C7_QUANT,"P"," ")
         PROJ->REQUISICAO := SPACE(06)
         PROJ->NFISCAL    := _cNOTA
         PROJ->SERIE      := _cSER
         PROJ->DATAEMISS  := substr(PSD1->C7_EMISSAO,7,2)+"/"+substr(PSD1->C7_EMISSAO,5,2)+"/"+substr(PSD1->C7_EMISSAO,1,4)
         PROJ->ITEM       := PSD1->C7_ITEM
         PROJ->CCUSTO     := PSD1->C7_CC
         PROJ->CODFORNEC  := PSD1->D1_FORNECE+"-"+PSD1->D1_LOJA
         PROJ->NOME       := SUBSTR(PSD1->A2_NOME,1,40)
         PROJ->PRODUTO    := PSD1->D1_COD
         PROJ->DESCRI     := SUBSTR(PSD1->B1_DESC,1,40)
         PROJ->VALOR      := PSD1->C7_TOTAL + PSD1->C7_VALIPI
         PROJ->PROJETO    := PSD1->C7_PROJETO
         PROJ->CONTA      := PSD1->C7_CONTA
         //PROJ->ENCERRADO  := IIF(EMPTY(PSC7->C7_ENCER),"A",PSC7->C7_ENCER)
         PROJ->ENCERRADO  := IIF(EMPTY(PSD1->C7_ENCER),IIF(PSD1->C7_QUJE > 0 .AND. PSD1->C7_QUJE < PSD1->C7_QUANT,"P","A"),PSD1->C7_ENCER)
         PROJ->DTDIGNF    := IIF(!EMPTY(_cDT),substr(_cDT,7,2)+"/"+substr(_cDT,5,2)+"/"+substr(_cDT,1,4),_cDT)
         PROJ->VALORNF    := _nVlr
         PROJ->NFDEVOL    := _cNFDEV
         PROJ->SERDEV     := _cSEDEV
         PROJ->VLRDEV     := _nVLDEV
         PROJ->DTNFDEV    := IIF(!EMPTY(_dDTDEV),substr(_dDTDEV,7,2)+"/"+substr(_dDTDEV,5,2)+"/"+substr(_dDTDEV,1,4),_dDTDEV)
         PROJ->DESCODPRO  := IIF(!EMPTY(PSD1->C7_CODPROJ), Posicione("ZZC",1,xFilial("ZZC")+PSD1->C7_CODPROJ,"ZZC_DESCR"), "")
         PROJ->OBSERVACA  := PSD1->C7_OBS
         MsUnlock()
         DbSelectArea("PSD1")
         PSD1->(Dbskip())
   Enddo
   /*
   &&21/01/14 - Incluo agora os pedidos de compras no mesmo periodo sem relacionamento com nota fiscal alguma....devido a mudança na base ser NF e não mais pedido
   If Select ("PSC7") > 0
      DbSelectArea("PSC7")
      PSC7->(DbCloseArea())
   Endif         

   _cQuery1 := "SELECT SC7.C7_FILIAL, SC7.C7_PRODUTO, SC7.C7_EMISSAO, SC7.C7_QUJE, SC7.C7_QUANT,SC7.C7_CONTA, SC7.C7_ENCER, SC7.C7_CC, SC7.C7_TOTAL, SC7.C7_VALIPI, SC7.C7_NUM, SC7.C7_ITEM, "
   _cQuery1 += "SB1.B1_DESC, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NOME, SC7.C7_PROJETO, SC7.C7_CODPROJ, SC7.C7_OBS "
   _cQuery1 += "FROM "
   _cQuery1 += RetSqlName( "SC7" ) + " SC7, "
   _cQuery1 += RetSqlName( "SB1" ) + " SB1, "
   _cQuery1 += RetSqlName( "SA2" ) + " SA2 "
   _cQuery1 += "WHERE SC7.C7_PROJETO <> '         ' "
   _cQuery1 += "AND SC7.C7_EMISSAO BETWEEN '" + DtoS( mv_par03 ) + "' AND '" + DtoS( mv_par04 ) + "' "
   _cQuery1 += "AND SC7.C7_FILIAL BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
   _cQuery1 += "AND SC7.D_E_L_E_T_ = '' "
   _cQuery1 += "AND SB1.B1_COD = SC7.C7_PRODUTO "
   _cQuery1 += "AND SB1.D_E_L_E_T_ = '' "
   _cQuery1 += "AND SA2.A2_COD = SC7.C7_FORNECE "
   _cQuery1 += "AND SA2.A2_LOJA = SC7.C7_LOJA "
   _cQuery1 += "AND SA2.D_E_L_E_T_ = '' "
   _cQuery1 += "AND (SC7.C7_NUM NOT IN(SELECT D1_PEDIDO FROM "+RetSqlName("SD1")+" D1 "
   _cQuery1 += "WHERE D1.D1_PEDIDO <> ' ' AND D1.D_E_L_E_T_ <> '*' AND D1.D1_DTDIGIT >= '" + DtoS( mv_par03 ) + "') AND "
   _cQuery1 += "SC7.C7_ITEM NOT IN(SELECT D1_ITEMPC FROM "+RetSqlName("SD1")+" D1 "
   _cQuery1 += "WHERE D1.D1_ITEMPC <> ' ' AND D1.D_E_L_E_T_ <> '*' AND D1.D1_DTDIGIT >= '" + DtoS( mv_par03 ) + "')) "
   _cQuery1 += "ORDER BY SC7.C7_NUM, SC7.C7_ITEM "     

   TcQuery _cQuery1 NEW ALIAS "PSC7"

   DbSelectArea("PSC7")
   DbGotop()
   While PSC7->(!Eof())              
            _cNOTA := SPACE(09)
            _cSER  := SPACE(03)
            _cDt   := SPACE(10)
            _nVlr  := 0
            _cNFDEV := SPACE(09)
            _cSEDEV := SPACE(02)
            _nVLDEV := 0.00
            _dDTDEV := SPACE(10)
            
            RecLock("PROJ",.T.)
            PROJ->FILIAL     := PSC7->C7_FILIAL 
            PROJ->PEDIDO     := PSC7->C7_NUM
            //PROJ->PEDATE     := IIF(PSC7->C7_QUJE > 0 .AND. PSC7->C7_QUJE < PSC7->C7_QUANT,"P"," ")
            PROJ->REQUISICAO := SPACE(06)
            PROJ->NFISCAL    := _cNOTA
            PROJ->SERIE      := _cSER
            PROJ->DATAEMISS  := substr(PSC7->C7_EMISSAO,7,2)+"/"+substr(PSC7->C7_EMISSAO,5,2)+"/"+substr(PSC7->C7_EMISSAO,1,4)
            PROJ->ITEM       := PSC7->C7_ITEM
            PROJ->CCUSTO     := PSC7->C7_CC
            PROJ->CODFORNEC  := PSC7->C7_FORNECE+"-"+PSC7->C7_LOJA
            PROJ->NOME       := SUBSTR(PSC7->A2_NOME,1,40)
            PROJ->PRODUTO    := PSC7->C7_PRODUTO
            PROJ->DESCRI     := SUBSTR(PSC7->B1_DESC,1,40)
            PROJ->VALOR      := PSC7->C7_TOTAL + PSC7->C7_VALIPI
            PROJ->PROJETO    := PSC7->C7_PROJETO
            PROJ->CONTA      := PSC7->C7_CONTA
            //PROJ->ENCERRADO  := IIF(EMPTY(PSC7->C7_ENCER),"A",PSC7->C7_ENCER)
            PROJ->ENCERRADO  := IIF(EMPTY(PSC7->C7_ENCER),IIF(PSC7->C7_QUJE > 0 .AND. PSC7->C7_QUJE < PSC7->C7_QUANT,"P","A"),PSC7->C7_ENCER)
            PROJ->DTDIGNF    := IIF(!EMPTY(_cDT),substr(_cDT,7,2)+"/"+substr(_cDT,5,2)+"/"+substr(_cDT,1,4),_cDT)
            PROJ->VALORNF    := _nVlr
            PROJ->NFDEVOL    := _cNFDEV
            PROJ->SERDEV     := _cSEDEV
            PROJ->VLRDEV     := _nVLDEV
            PROJ->DTNFDEV    := IIF(!EMPTY(_dDTDEV),substr(_dDTDEV,7,2)+"/"+substr(_dDTDEV,5,2)+"/"+substr(_dDTDEV,1,4),_dDTDEV)
            PROJ->DESCODPRO  := IIF(!EMPTY(PSC7->C7_CODPROJ), Posicione("ZZC",1,xFilial("ZZC")+PSC7->C7_CODPROJ,"ZZC_DESCR"), "")
            PROJ->OBSERVACA  := PSC7->C7_OBS
            MsUnlock()     
         DbSelectArea("PSC7")
         PSC7->(DbSkip())
   Enddo
   */
   dbSelectArea("PROJ")
   dbGoTop()

   ProcRegua(RecCount()) // Numero de registros a processar

   While !EOF()

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Incrementa a regua                                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      IncProc()

      //ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
      //º Lay-Out do arquivo Texto gerado:                                º
      //ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
      //ºCampo           ³ Inicio ³ Tamanho                               º
      //ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
      //º FILIAL         ³ 01     ³ 02                                    º
      //º PEDIDO         ³ 03     ³ 06                                    º
      //º PEDPARCIAL     ³ 09     ³ 01                                    º
      //º REQUISICAO     ³ 09     ³ 06                                    º
      //º NOTA FISCAL    ³ 15     ³ 09                                    º
      //º SERIE          ³ 24     ³ 03                                    º
      //º EMISSAO        ³ 27     ³ 10                                    º
      //º ITEM           ³ 37     ³ 04                                    º
      //º CENTRO CUSTO   ³ 41     ³ 09                                    º
      //º COD FORNECEDOR ³ 50     ³ 09                                    º
      //º NOME FORNEC    ³ 59     ³ 40                                    º
      //º PRODUTO        ³ 99     ³ 15                                    º
      //º DESCRICAO PROD ³ 114    ³ 40                                    º
      //º VALOR          ³ 154    ³ 17                                    º
      //º PROJETO        ³ 171    ³ 09                                    º
      //º CONTA          ³ 180    ³ 20                                    º
      //º ENCERRADO      ³ 200    ³ 01                                    º
      //º DTDIGNF        | 201    | 10									º
      //º VALOR          ³ 211    ³ 17                                    º
      //  NFDEVOL          228      09
      //  SERDEV           237      03  
      //  VLRDEV           240      17  
      //  DTNFDEV          257      10
      //ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
         
      nTamLin := 357
      cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Substitui nas respectivas posicioes na variavel cLin pelo conteudo  ³
      //³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
      //³ string dentro de outra string.                                      ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      cCpo := PADR(PROJ->FILIAL,02)
      cLin := Stuff(cLin,01,02,cCpo)
      cCpo := PADR(PROJ->PEDIDO,06)
      cLin := Stuff(cLin,03,06,cCpo)
      //cCpo := PADR(PROJ->PEDATE,01)
      //cLin := Stuff(cLin,09,01,cCpo)
      cCpo := PADR(PROJ->REQUISICAO,06)
      cLin := Stuff(cLin,09,06,cCpo)
      cCpo := PROJ->NFISCAL
      cLin := Stuff(cLin,15,09,cCpo)
      cCpo := PROJ->SERIE
      cLin := Stuff(cLin,24,03,cCpo)        
      cCpo := PROJ->DATAEMISS
      cLin := Stuff(cLin,27,10,cCpo)            
      cCpo := PADR(PROJ->ITEM,04)
      cLin := Stuff(cLin,37,04,cCpo)
      cCpo := PADR(PROJ->CCUSTO,09)
      cLin := Stuff(cLin,41,09,cCpo)
      cCpo := PADR(PROJ->CODFORNEC,09)
      cLin := Stuff(cLin,50,09,cCpo)
      cCpo := PROJ->NOME
      cLin := Stuff(cLin,59,40,cCpo)                                                
      cCpo := PADR(PROJ->PRODUTO,15)
      cLin := Stuff(cLin,99,15,cCpo)
      cCpo := PROJ->DESCRI
      cLin := Stuff(cLin,114,40,cCpo)                               
      cCpo := Str(PROJ->VALOR,17,02)
               _ncount  := AT(".",cCpo)  &&Chamado 005342 - Mauricio HC Consys.
               _cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
      cCpo := _cString    
      cLin := Stuff(cLin,154,17,cCpo)
      cCpo := PROJ->PROJETO
      cLin := Stuff(cLin,171,09,cCpo)
      cCpo := PROJ->CONTA
      cLin := Stuff(cLin,180,20,cCpo)        
      cCpo := PROJ->ENCERRADO
      cLin := Stuff(cLin,200,01,cCpo)
      cCpo := PROJ->DTDIGNF
      cLin := Stuff(cLin,201,10,cCpo)
      cCpo := Str(PROJ->VALORNF,17,02)
               _ncount  := AT(".",cCpo)  
               _cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
      cCpo := _cString    
      cLin := Stuff(cLin,211,17,cCpo)    
      cCpo := PROJ->NFDEVOL
      cLin := Stuff(cLin,228,09,cCpo)
      cCpo := PROJ->SERDEV
      cLin := Stuff(cLin,237,03,cCpo)
      cCpo := Str(PROJ->VLRDEV,17,02)
               _ncount  := AT(".",cCpo)  
               _cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
      cCpo := _cString    
      cLin := Stuff(cLin,240,17,cCpo)            
      cCpo := PROJ->DTNFDEV
      cLin := Stuff(cLin,257,10,cCpo)
      cCpo := PROJ->DESCODPRO
      cLin := Stuff(cLin,267,41,cCpo)
      cCpo := PROJ->OBSERVACA
      cLin := Stuff(cLin,308,50,cCpo)

      //cCpo := PROJ->DTINIPRE
      //cLin := Stuff(cLin,201,10,cCpo)
      //cCpo := PROJ->DTFIMPRE
      //cLin := Stuff(cLin,211,10,cCpo)
      //cCpo := PROJ->DATAINI
      //cLin := Stuff(cLin,221,10,cCpo)
      //cCpo := PROJ->DATAFIM
      //cLin := Stuff(cLin,231,10,cCpo)                
      //cCpo := Str(PROJ->VALCIPI,17,02)
      //        _ncount  := AT(".",cCpo)  
      //        _cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
      //cCpo := _cString    
      //cLin := Stuff(cLin,242,17,cCpo)    
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
      //³ linha montada.                                                      ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
         If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
               Exit
         Endif
      Endif
      DbSelectArea("PROJ")
      dbSkip()
   EndDo

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
   //³ cao anterior.                                                       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   fClose(nHdl)
   Close(oGeraTxt) 

   Return 

   static function DTINIPRE(_Proj)
   Local _cProj := _Proj
   Local _cData := ""

   DbSelectArea("AF8")
   DbSetOrder(1)
   if dbSeek(xFilial("AF8")+_cProj)   
      _cData := substr(DTOS(AF8->AF8_START),7,2)+"/"+substr(DTOS(AF8->AF8_START),5,2)+"/"+substr(DTOS(AF8->AF8_START),1,4)
   endif

   return(_cData)   

   static function DTFIMPRE(_Proj)
   Local _cProj := _Proj
   Local _cData := ""

   DbSelectArea("AF8")
   DbSetOrder(1)
   if dbSeek(xFilial("AF8")+_cProj)   
      _cData := substr((DTOS(AF8->AF8_FINISH)),7,2)+"/"+substr((DTOS(AF8->AF8_FINISH)),5,2)+"/"+substr((DTOS(AF8->AF8_FINISH)),1,4)
   endif

   return(_cData)

   static function DATAINI(_Proj)
   Local _cProj := _Proj
   Local _cData := ""

   DbSelectArea("AF8")
   DbSetOrder(1)
   if dbSeek(xFilial("AF8")+_cProj)   
      _cData := substr((DTOS(AF8->AF8_DTATUI)),7,2)+"/"+substr((DTOS(AF8->AF8_DTATUI)),5,2)+"/"+substr((DTOS(AF8->AF8_DTATUI)),1,4)
   endif

   return(_cData)   

   static function DATAFIM(_Proj)
   Local _cProj := _Proj
   Local _cData := ""

   DbSelectArea("AF8")
   DbSetOrder(1)
   if dbSeek(xFilial("AF8")+_cProj)   
      _cData := substr((DTOS(AF8->AF8_DTATUF)),7,2)+"/"+substr((DTOS(AF8->AF8_DTATUF)),5,2)+"/"+substr((DTOS(AF8->AF8_DTATUF)),1,4)
   endif

return(_cData)