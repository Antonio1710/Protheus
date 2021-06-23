#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"  
#INCLUDE "FILEIO.CH"      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADEST028RบAutor  ณWILLIAM COSTA       บ Data ณ  25/04/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ GERACAO DE ETIQUETA ZEBRA A PARTIR DE UM CSV COM CODIGO DE บฑฑ
ฑฑบ          ณ PRODUTOS SOMENTE - PARA UTILIZAR NO INVENTARIO             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AD'oro - ESTOQUE                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADEST028R()

	PRIVATE cPorta     := "" 
	PRIVATE cQuery1    := ""
	PRIVATE nLin       := 0
	PRIVATE nCont      := 0
	PRIVATE nPos1      := 0
	PRIVATE _cLF       := Chr( 10 )
	PRIVATE _cTxt      := ''
	PRIVATE _cChr      := ''
	PRIVATE _nTam      := 0
	PRIVATE cArq     := CriaTrab(,.F.)+".TXT" //Nome do Arquivo a Gerar
	PRIVATE cPath    := GetTempPath() + cArq //Local de Gera็ใo do Arquivo
	Private nHdl  
	Private cVar     := '' 
	Private cCodProd := ''  
	Private cLocal   := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'GERACAO DE ETIQUETA ZEBRA A PARTIR DE UM CSV COM CODIGO DE PRODUTOS SOMENTE - PARA UTILIZAR NO INVENTARIO')
		  
	cPerg      := "ADEST028R" // Nome da Pergunte
	MontaPerg()
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica as perguntas selecionadas                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	IF !Pergunte(cPerg,.T.)               
    	 Return
	Endif
	
	IF MV_PAR02 == '02'
	
		EtiqFil02()
	
	ELSE
	
		EtiqFil03()
		
	ENDIF
	
    Alert(" Impressao Finalizada" ) 
    
Return(Nil)

STATIC FUNCTION EtiqFil03()

	_cFile := cGetFile( "Lista Arquivos CSV|*.csv|Lista Arquivos TXT|*.txt",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)

	If ! Empty( _cFile )
	
	   If ( MsgNoYes( "Confirma importacao do arquivo " + _cFile ) )
	
	      	_aFile := Directory( _cFile )
	      
	      	FT_FUse( _cFile ) 
			_nTam += FT_FlastRec()
			_nTam ++
			FT_FGoTop()
			ProcRegua( _nTam )
			
			//campos     12
			//Cod PRoduto      12
			
			_nLinha := 1
			While ! ( FT_FEof() )
			
				  IncProc( 'Aguarde, importando registros..' )
				  _cTxt :=  FT_FReadLN()
				  
				  IF _nLinha <> 1   &&primeira linha de cabe็alho ้ preciso ser pulada            
				     IF LEN(_cTxt) <> 0 .AND. ALLTRIM(SUBSTR(_cTxt,1,1)) <> ';'  
				
						cCodProd := Alltrim(Substr(_cTxt, 01,06))
						
						If Select("_QRY") > 0
						
							_QRY->(DbCloseArea())
							
						Endif
						 
						cQuery1 := "SELECT B1_COD, B1_DESC,B1_ENDALM2,B1_UM  "
						cQuery1 += " FROM " + RetSqlName("SB1") + " SB1 "
						cQuery1 += " WHERE SB1.D_E_L_E_T_<> '*' "
						cQuery1 += " AND  SB1.B1_COD  = '"+cCodProd+"'" 
						cQuery1 += " ORDER BY B1_COD " 
						
						TcQuery cQuery1  New Alias "_QRY"
						
						cPorta := "LPT1"
						
						//MSCBPRINTER("ZEBRA",cPorta,,120,.F.,,,,,,.T.)
						MSCBPRINTER("ZEBRA",cPorta,,,.F.,,,,,,.T.)
						 
						ProcRegua(_QRY->(RecCount()))
						
						_QRY->(DBGoTop())
						While ! _QRY->(eof())
						
						 	nCont := mv_par01
						 	
							MSCBBEGIN(1,6)   
							
							// Imprimindo Etiquetas C๓digo de Barra do Produto
						
							nLin := 4
							
							MSCBSAY(8,nLin,+"Contagem: 0" + CVALTOCHAR(nCont)+'  -   '+ 'Sใo Carlos Almox: 04' ,"N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 5
							 
							MSCBSAY(8,nLin,+"Cod: " + SUBSTR(_QRY->B1_COD,1,6)+'   -   '+SUBSTR(_QRY->B1_ENDALM2,1,30),"N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 5
							 
							MSCBSAY(8,nLin,+'Desc: ' + SUBSTR(_QRY->B1_DESC,1,50),"N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 5 
							
							MSCBSAYBAR(8,nLin,SUBSTR(_QRY->B1_COD,1,8),'N','MB07',13,.F.,.T.,,,2,1)
							
							MSCBSAY(53,nLin,+'UM: ' + SUBSTR(_QRY->B1_UM,1,3),"N","C","031,014") //esse ้ o correto
								
							nLin := nLin + 15
							
							MSCBSAY(08,nLin,+"|"+Replicate("-",40)+"|","N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 3
							
							MSCBSAY(8,nLin,+"|"+"Qtd/Peso: "+SPACE(30)+"|","N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 5
							
							MSCBSAY(08,nLin,+"|"+Replicate("-",40)+"|","N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 8
							
							MSCBSAY(08,nLin,+Replicate("-",20) + SPACE(3)+Replicate("-",20),"N","C","031,014")
							
							nLin := nLin + 3
							
							MSCBSAY(08,nLin,+"Conferente"+SPACE(13)+"Data","N","C","031,014")
							
							
							MSCBEND() 
							_QRY->(DbSkip())
					   	ENDDO
					
						MSCBEND()
						MSCBCLOSEPRINTER()
						_QRY->(DbCloseArea())
				     ENDIF  
				  ENDIF        
				  _nLinha ++   
				  FT_FSkip()   
		    ENDDO     
			
			FT_FUse()
	    ENDIF
	ENDIF

Return(Nil) 

STATIC FUNCTION EtiqFil02()

	_cFile := cGetFile( "Lista Arquivos CSV|*.csv|Lista Arquivos TXT|*.txt",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)
	
	If ! Empty( _cFile )
	
	   If ( MsgNoYes( "Confirma importacao do arquivo " + _cFile ) )
	
	      	_aFile := Directory( _cFile )
	      
	      	FT_FUse( _cFile ) 
			_nTam := FT_FlastRec()
			_nTam ++
			FT_FGoTop()
			ProcRegua( _nTam )
			
			//campos     12
			//Cod PRoduto      12
			
			_nLinha := 1
			While ! ( FT_FEof() )
			
				  IncProc( 'Aguarde, importando registros..' )
				  _cTxt :=  FT_FReadLN()
				  
				  IF _nLinha <> 1   &&primeira linha de cabe็alho ้ preciso ser pulada            
				     IF LEN(_cTxt) <> 0 .AND. ALLTRIM(SUBSTR(_cTxt,1,1)) <> ';'  
				
						cCodProd := Alltrim(Substr(_cTxt, 01,06))
						cLocal   := STRZERO(VAL(Alltrim(Substr(_cTxt, (AT(";", _cTxt) + 1),LEN(_cTxt)))),2)
						
						If Select("_QRY") > 0
						
							_QRY->(DbCloseArea())
							
						Endif
						 
						cQuery1 := "SELECT B1_COD, B1_DESC,BE_LOCALIZ,B1_UM  "
						cQuery1 += " FROM " + RetSqlName("SB1") + " SB1 "
						cQuery1 += " LEFT JOIN " + RetSqlName("SBE") + " SBE "
						cQuery1 += "        ON BE_FILIAL       = '"+MV_PAR02+"'"
						cQuery1 += "  	   AND BE_CODPRO       = B1_COD " 
						cQuery1 += "  	   AND BE_LOCAL        = '"+cLocal+"'"
						cQuery1 += "  	   AND SBE.D_E_L_E_T_ <> '*' "
						cQuery1 += "     WHERE SB1.B1_COD      = '"+cCodProd+"'"
						cQuery1 += "       AND SB1.D_E_L_E_T_ <> '*' " 
						cQuery1 += " ORDER BY B1_COD " 
						
						TcQuery cQuery1  New Alias "_QRY"
						
						cPorta := "LPT1"
						
						//MSCBPRINTER("ZEBRA",cPorta,,120,.F.,,,,,,.T.)
						MSCBPRINTER("ZEBRA",cPorta,,,.F.,,,,,,.T.)
						 
						ProcRegua(_QRY->(RecCount()))
						
						_QRY->(DBGoTop())
						While ! _QRY->(eof())
						
						 	nCont := mv_par01
						 	
							MSCBBEGIN(1,6)   
							
							// Imprimindo Etiquetas C๓digo de Barra do Produto
						
							nLin := 4
							
							MSCBSAY(8,nLin,+"Contagem: 0" + CVALTOCHAR(nCont)+'  -   '+ 'Almox:' + cLocal,"N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 5
							 
							MSCBSAY(8,nLin,+"Cod: " + SUBSTR(_QRY->B1_COD,1,6)+'   -   '+SUBSTR(_QRY->BE_LOCALIZ,1,30),"N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 5
							 
							MSCBSAY(8,nLin,+'Desc: ' + SUBSTR(_QRY->B1_DESC,1,50),"N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 5 
							
							MSCBSAYBAR(8,nLin,SUBSTR(_QRY->B1_COD,1,8),'N','MB07',13,.F.,.T.,,,2,1)
							
							MSCBSAY(53,nLin,+'UM: ' + SUBSTR(_QRY->B1_UM,1,3),"N","C","031,014") //esse ้ o correto
								
							nLin := nLin + 15
							
							MSCBSAY(08,nLin,+"|"+Replicate("-",40)+"|","N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 3
							
							MSCBSAY(8,nLin,+"|"+"Qtd/Peso: "+SPACE(30)+"|","N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 5
							
							MSCBSAY(08,nLin,+"|"+Replicate("-",40)+"|","N","C","031,014") //esse ้ o correto
							
							nLin := nLin + 8
							
							MSCBSAY(08,nLin,+Replicate("-",20) + SPACE(3)+Replicate("-",20),"N","C","031,014")
							
							nLin := nLin + 3
							
							MSCBSAY(08,nLin,+"Conferente"+SPACE(13)+"Data","N","C","031,014")
							
							
							MSCBEND() 
							_QRY->(DbSkip())
					   	ENDDO
					
						MSCBEND()
						MSCBCLOSEPRINTER()
						_QRY->(DbCloseArea())
				     ENDIF  
				  ENDIF        
				  _nLinha ++   
				  FT_FSkip()   
		    ENDDO     
			
			FT_FUse()
	    ENDIF
	ENDIF


Return(Nil)

Static Function MontaPerg()   
                               
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    u_xPutSx1(cPerg,'01','Qual Contagem Inventแrio  ?','','','mv_ch1','C',01,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	u_xPutSx1(cPerg,'02','Qual Filial               ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
		
	Pergunte(cPerg,.F.)
Return(Nil) 