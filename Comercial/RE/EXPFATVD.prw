#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} User Function EXPFATVD()  
   Exporta para arquivo .csv massa de dados relativos ao faturamento por vendedor
   @type  Function
   @author Mauricio
   @since 10/11/2010
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
	@history chamado 050729  - FWNM         - 25/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE   
   @history Ticket TI - Leonardo P. Monteiro - 28/12/2021 - Correção de error.log.
/*/
User Function EXPFATVD()  

   Local _cRet := ""

   Private oGeraTxt
   Private _cPerg := "EXFTVD"
   Private _cArqTmp

   U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Exporta para arquivo .csv massa de dados relativos ao faturamento por vendedor-Chamado 008156')

   PutSx1(_cPerg,"01","Data inicial          ?","Data inicial        ?","Data inicial        ?","mv_ch1","D",8 ,0,0,"G",""         ,""   ,"","","mv_par01",""      ,"","","","","","","","","","","","","","","")
   PutSx1(_cPerg,"02","Data Final(max.31dias)?","Data Final          ?","Data Final          ?","mv_ch2","D",8 ,0,0,"G",""         ,""   ,"","","mv_par02",""      ,"","","","","","","","","","","","","","","")
   PutSx1(_cPerg,"03","Do Vendedor           ?","Do Vendedor         ?","Do Vendedor         ?","mv_ch3","C",6 ,0,0,"G",""         ,"SA3","","","mv_par03",""      ,"","","","","","","","","","","","","","","")
   PutSx1(_cPerg,"04","Ate Vendedor          ?","Ate Vendedor        ?","Ate Vendedor        ?","mv_ch4","C",6 ,0,0,"G",""         ,"SA3","","","mv_par04",""      ,"","","","","","","","","","","","","","","")
   PutSx1(_cPerg,"05","Selecione Filiais"      ,"Selecione Filiais"    ,"Selecione Filiais"    ,"mv_ch5","C",50,0,0,"G","U_FXFIL()",""   ,"","","mv_par05",""      ,"","","","","","","","","","","","","","","")
   PutSX1(_cPerg,"06","Imprime..."             ,"Imprime..."           ,"Imprime..."           ,"MV_CH6","N",1 ,0,1,"C",""         ,""   ,"","","MV_PAR06","Volume","","","","Preco","","","Ambos","","","","","","","","","","","")
   //PutSx1(_cPerg,"05","Arquivo de saida    ?"    , "Arquivo de saida    ?"    , "Arquivo de saida    ?"    , "mv_ch5","C",50,0,0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")

   pergunte(_cPerg,.T.)

   dbSelectArea("SD2")
   dbSetOrder(1)

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Montagem da tela de processamento.                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   @ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Gera arquivo com detalhe por produto faturado por vendedor")
   @ 02,10 TO 080,190
   @ 10,018 Say " Este programa ira gerar um arquivo .csv,  conforme os parame- "
   @ 18,018 Say " tros definidos  pelo usuario,  com os registros ref. aos pro- "
   @ 26,018 Say " dutos faturados por vendedor(Por dia, volume e preco unitario)"

   @ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
   @ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)

   Activate Dialog oGeraTxt Centered

   If Select("TSD2") > 0
      TSD2->(DbCloseArea())
   ENDIF

   //@Ticket TI - Leonardo P. Monteiro - 28/12/2021 - Correção de error.log.
   if type("_cArqTmp") == "C"
      // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 25/06/2020
      If File(_cArqTmp+GetDBExtension()); fErase(_cArqTmp+GetDBExtension()); EndIf
      If File(_cArqTmp); fErase(_cArqTmp); EndIf
   endif
   //If File(_cArqTmp+".DBF"); fErase(_cArqTmp+".DBF"); EndIf
   //If File(_cArqTmp); fErase(_cArqTmp); EndIf

Return

/*/{Protheus.doc} nomeStaticFunction
   (long_description)
   @type  Static Function
   @author user
   @since 25/06/2020
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function OkGeraTxt

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Cria o arquivo texto                                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   _cArqTmp := Alltrim(__RELDIR) //diretorio padrao, do usuario, para gravacao de relatorio em disco
   _cArqTmp += "PV"+DtoS(MV_PAR01)+"a"+DtoS(MV_PAR02)+".csv"

   if file(_cArqTmp)
      ALERT("ARQUIVO "+_CARQTMP+" JA EXISTE, E SERA APAGADO.")
      FErase(_cArqTmp)
   endif

   Private nHdl    := fCreate(_cArqTmp)
   Private cEOL    := "CHR(13)+CHR(10)"

   If Empty(cEOL)
      cEOL := CHR(13)+CHR(10)
   Else
      cEOL := Trim(cEOL)
      cEOL := &cEOL
   Endif

   If nHdl == -1
      MsgAlert("O arquivo de nome "+_cArqTmp+" nao pode ser executado! Verifique os parametros.","Atencao!")
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

Return
             
/*/{Protheus.doc} nomeStaticFunction
   (long_description)
   @type  Static Function
   @author user
   @since 25/06/2020
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function RunCont

   Local nTamLin, cLin, cCpo

   If Select ("TVEND") > 0
      DbSelectArea("TVEND")
      TVEND->(DbCloseArea())
   Endif

   _cQuery := ""
   _cQuery += "SELECT SF2.F2_VEND1, SD2.D2_COD, SD2.D2_EMISSAO, SUM(SD2.D2_QUANT) AS QUANT, SUM(SD2.D2_TOTAL) AS PRUNIT "
   _cQuery += " FROM "+RetSqlname("SF2")+" SF2, "+RetSqlname("SD2")+" SD2
   _cQuery += " WHERE SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE"
   _cQuery += " AND SF2.F2_FILIAL = SD2.D2_FILIAL "
   _cQuery += " AND SD2.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' "
   _cQuery += " AND SF2.F2_FILIAL IN ("+MV_PAR05+") "
   _cQuery += " AND SD2.D2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' " 
   _cQuery += " AND SF2.F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " 
   _cQuery += " AND SF2.F2_VEND1 <> '      ' "
   _cQuery += "GROUP BY SF2.F2_VEND1, SD2.D2_COD, SD2.D2_EMISSAO "
   _cQuery += "ORDER BY SF2.F2_VEND1, SD2.D2_COD, SD2.D2_EMISSAO "

   TcQuery _cQuery NEW ALIAS "TVEND"

   &&Array com as Datas consideradas
   _aDatas := {}
   DbSelectArea("TVEND")
   DbGotop()
   While !Eof()
         if Ascan(_aDatas,TVEND->D2_EMISSAO) == 0
            AADD(_aDatas,TVEND->D2_EMISSAO)
         endif   
         TVEND->(DbSkip())
   enddo

   aSort(_aDatas)

   &&cria arquivo temporario para impressao
   _aStr := {}

   If Select ("VEND") > 0
      DbSelectArea("VEND")
      VEND->(DbCloseArea())
   Endif

   AADD(_aStr,{'VENDEDOR'  ,"C",06})
   AADD(_aStr,{'PRODUTO'   ,"C",15})
   AADD(_aStr,{'DESCRICAO' ,"C",35})
   For _n1 := 1 to len(_aDatas)
      _cNomCpo := "'"+"A"+Substr(_aDatas[_n1],7,2)+Substr(_aDatas[_n1],5,2)+Substr(_aDatas[_n1],3,2)+"VOL"+"'"
      AADD(_aStr,{&_cNomCpo,"N",17,02})
      _cNomCpo := "'"+"A"+Substr(_aDatas[_n1],7,2)+Substr(_aDatas[_n1],5,2)+Substr(_aDatas[_n1],3,2)+"PRC"+"'"
      AADD(_aStr,{&_cNomCpo,"N",12,02})
   Next    
      
   _cArqTmp :=CriaTrab(_aStr,.T.)
   DbUseArea(.T.,,_cArqTmp,"VEND",.F.,.F.)
   _cIndex:="VENDEDOR+PRODUTO"
   indRegua("VEND",_cArqTmp,_cIndex,,,"Criando Indices...") 

   &&alimenta arquivo temporario de impressao
   DbSelectArea("TVEND")
   DbGotop()
   ProcRegua(RecCount())
   While TVEND->(!eof())
         _cVendedor := TVEND->F2_VEND1
         _cProduto  := TVEND->D2_COD
         while _cVendedor == TVEND->F2_VEND1 .And. _cProduto == TVEND->D2_COD
               IncProc("Vendedor: " + TVEND->F2_VEND1+" - Produto: " + TVEND->D2_COD )
               DbSelectArea("VEND")
               DbSeek(TVEND->F2_VEND1+TVEND->D2_COD)
               if found()
                  Reclock("VEND",.F.)
                     _cNomCpo := "A"+Substr(TVEND->D2_EMISSAO,7,2)+Substr(TVEND->D2_EMISSAO,5,2)+Substr(TVEND->D2_EMISSAO,3,2)+"VOL"
                     VEND->&_cNomCpo := TVEND->QUANT
                     _cNomCpo := "A"+Substr(TVEND->D2_EMISSAO,7,2)+Substr(TVEND->D2_EMISSAO,5,2)+Substr(TVEND->D2_EMISSAO,3,2)+"PRC"
                     VEND->&_cNomCpo := (TVEND->PRUNIT/TVEND->QUANT)
                  MsUnlock()
               Else
                  Reclock("VEND",.T.)
                     VEND->VENDEDOR  := TVEND->F2_VEND1
                     VEND->PRODUTO   := TVEND->D2_COD
                     VEND->DESCRICAO := Posicione("SB1",1,xFilial("SB1") + TVEND->D2_COD, "B1_DESC")
                     _cNomCpo := "A"+Substr(TVEND->D2_EMISSAO,7,2)+Substr(TVEND->D2_EMISSAO,5,2)+Substr(TVEND->D2_EMISSAO,3,2)+"VOL"
                     VEND->&_cNomCpo := TVEND->QUANT
                     _cNomCpo := "A"+Substr(TVEND->D2_EMISSAO,7,2)+Substr(TVEND->D2_EMISSAO,5,2)+Substr(TVEND->D2_EMISSAO,3,2)+"PRC"
                     VEND->&_cNomCpo := (TVEND->PRUNIT/TVEND->QUANT)
                  MsUnlock()
               Endif
               TVEND->(DbSkip())
         enddo
   enddo

   _nCols := Len(_aDatas)
   _nCamp := 3  &&Total de campos fora a coluna de datas
               
   dbSelectArea("VEND")
   dbGoTop()

   cLin := ""  
   For _x:=1 to ("VEND")->( fCount() )
         _cCabec := ("VEND")->( FieldName( _x ) )
         if _x <= 3				
            cLin += _cCabec+";"
         Else
            If MV_PAR06 == 1
               if Substr(_cCabec,8,3) <> "VOL"
                  loop
               Else
                  cLin += Substr(_cCabec,2,2)+"/"+Substr(_cCabec,4,2)+"/"+Substr(_cCabec,6,2)+";"
               Endif   
            Elseif MV_PAR06 == 2
               if Substr(_cCabec,8,3) <> "PRC"
                  loop
               Else
                  cLin += Substr(_cCabec,2,2)+"/"+Substr(_cCabec,4,2)+"/"+Substr(_cCabec,6,2)+";"
               Endif              
            Else
                  cLin += Substr(_cCabec,2,2)+"/"+Substr(_cCabec,4,2)+"/"+Substr(_cCabec,6,2)+";"
            Endif    
         Endif      
   next
   _nFinal := Len(cLin)
   cLin := substr(cLin,1,_nfinal-1)+cEOL

   If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
      If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
         //Exit
      Endif
   Endif

   cLin := ""
   _cVa := "x"  
   For _x:=1 to ("VEND")->( fCount() )
         _cCabec := ("VEND")->( FieldName( _x ) )
         if _x <= 3				
            cLin += ";"
         Else   
            If MV_PAR06 == 1
               if Substr(_cCabec,8,3) == "VOL"
                  cLin += "Volume ;"
               Else
                  Loop
               Endif   
            Elseif MV_PAR06 == 2
               if Substr(_cCabec,8,3) == "PRC"
                  cLin += "Preco ;"
               Else
                  loop
               Endif              
            Else           
               if _cVa == "x"
                  cLin += "Volume ;"
                  _cVa := "y"
               Elseif _cVa == "y"
                  cLin += "Preco ;"
                  _cVa := "x"
               Endif
            Endif     
         Endif      
   next
   _nFinal := Len(cLin)
   cLin := substr(cLin,1,_nfinal-1)+cEOL

   If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
      If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
         //Exit
      Endif
   Endif

   dbSelectArea("VEND")
   dbGoTop()
   ProcRegua(RecCount()) // Numero de registros a processar
   While VEND->(!EOF())

      IncProc("Gerando arquivo .CSV...")
         
      //nTamLin := _nCamp+_nCols
      cLin := ""
      For _x:=1 to ("VEND")->( fCount() )
         _cNmCpo := ("VEND")->( FieldName( _x ) )
         if _x <= 3				
            If ValType(VEND->&_cNmCpo) == "C"				
                     cLin += VEND->&_cNmCpo
            Else
                     cLin += STRTRAN(STR(VEND->&_cNmCpo),".",",")
            Endif   
            cLin += ";"         
         Else 
            IF MV_PAR06 == 1
               if Substr(_cNmCpo,8,3) == "VOL"		    
                  If ValType(VEND->&_cNmCpo) == "C"				
                     cLin += VEND->&_cNmCpo
                  Else
                     cLin += STRTRAN(STR(VEND->&_cNmCpo),".",",")
                  Endif
                  cLin += ";"
               else
                  loop   
               Endif                            
            Elseif MV_PAR06 == 2
               if Substr(_cNmCpo,8,3) == "PRC"		    
                  If ValType(VEND->&_cNmCpo) == "C"				
                     cLin += VEND->&_cNmCpo
                  Else
                     cLin += STRTRAN(STR(VEND->&_cNmCpo),".",",")
                  Endif   
                  cLin += ";"
               else
                  loop   
               endif
            else
               If ValType(VEND->&_cNmCpo) == "C"				
                     cLin += VEND->&_cNmCpo
               Else
                     cLin += STRTRAN(STR(VEND->&_cNmCpo),".",",")
               Endif   
               cLin += ";"         
            endif
         endif     
      next
      
      _nFinal := Len(cLin)
      cLin := substr(cLin,1,_nfinal-1)+cEOL
      
      If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
         If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
            Exit
         Endif
      Endif
      
      VEND->(dbSkip())
   
   Enddo    
      
   fClose(nHdl)
   Close(oGeraTxt) 

Return
