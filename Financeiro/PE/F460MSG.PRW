#include "rwmake.ch"
#include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"             

//Ú---------Â------------------Â------Â----------------------------------------Â----Â-----------¿
//|PROGRAMA | F460VER          |AUTOR | RICARDO - HC                           |DATA| 11.04.07  |
//Ã---------+------------------Á------Á----------------------------------------Á----Á-----------´
//|DESCRICAO|Após a Impressão da Frente do cheque, retorna os dados do Banco, Agência e Conta   |
//|         |para ser Impresso no Verso!                                                        |
//|         |                                                                                   |
//|         |                                                                                   |
//|         |                                                                                   |
//Ã---------+----------------------Â-----Â------------------------------------------------------´
//|MODULO   |FINANCEIRO            |TIPO | [ ] - PROCESSAMENTO          [ ] - TRANSACAO         |
//|         |                      |     | [X] - PONTO DE ENTRADA       [ ] - VALIDACAO         |
//|         |                      |     | [ ] - GATILHO                [ ] - CONSULTA          |
//|         |                      |     | [ ] - RELATORIO                                      |
//Ã---------+--------------Â-------Á-----Á----Â-------------------------------------------------´
//|MANUT.   |DATA          | AUTOR            |DESCRICAO                                        |
//Ã---------+--------------+------------------+-------------------------------------------------´
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//À---------Á--------------Á------------------Á-------------------------------------------------Ù

User Function F460MSG()   

	_cRet :=""

	_aArea:=GetArea()

	dbSelectArea("SEF")
                            
   dbSelectArea("SA2")
	dbSetOrder(1)
	dbgotop()   	                              
	
   If 	 !Empty(SEF->EF_FORNECE)                                                                    
   
         //---- Caso a Microsiga volte a posicionar no Cabeçalho da Tabela de Cheque	
			If dbSeek(xFilial("SA2")+SEF->EF_FORNECE+SEF->EF_LOJA)                                                                                 

		   	 _cRet := "Banco:" + SA2->A2_BANCO + " - Agencia:" + ALLTRIM(SA2->A2_AGENCIA) + Iif( !Empty( SA2->A2_DIGAG ), "-", "" ) + AllTrim( SA2->A2_DIGAG ) + " - Conta:" + AllTrim( SA2->A2_NUMCON ) + Iif( !Empty( SA2->A2_DIGCTA ), "-", "" ) + AllTrim( SA2->A2_DIGCTA )

		   Else              
		   			          
		       _cRet := "Banco:" + Space(12) + " - Agencia:" + Space(16) + " - Conta:" 			 

		       
			Endif            

	Else    //--- Na segunda vez ele está posicionado no Detalhe da Tabela de Cheque	 
		        Dbselectarea("SEF")		        		        
		        xNum:=SEF->EF_NUM		   		        

		        //-- Pega Posição Atual		        
				  //_cAlias := Alias()
				  //_nOrder := IndexOrd()		
				  //_nRecno := Recno() 		        

					cQuery :=" SELECT EF_NUM , EF_FORNECE, EF_LOJA " 
										
					cQuery +=" FROM "+RetSqlName("SEF")+" "
						
					cQuery +=" WHERE EF_FILIAL 	= '" + xFilial("SEF") + "' "
					
					cQuery += " AND Ef_NUM     =   '" +  XNUM  + "' "  "
					
				   cQuery +=" AND EF_FORNECE  <> '' AND EF_LOJA  <>''  " 
				   							
					cQuery +=" AND D_E_L_E_T_ <> '*'  "
					
					cQuery +=" ORDER BY EF_NUM , EF_FORNECE, EF_LOJA
				   
					cQuery := ChangeQuery(cQuery)

					TCQUERY cQuery Alias TRA New
					
				   dbSelectArea("TRA")
					dbGotop()
					nRegTrf :=0
					dbEval({|| nRegTrf++})
					dbGotop()
								  
		        If nRegTrf  = 1

					   dbSelectArea("SA2")
						dbSetOrder(1)
						dbgotop()  

                  lAchouDA:=.F.	//--- Se tem digito Agência
						If dbSeek( xFilial("SA2") + TRA->EF_FORNECE + TRA->EF_LOJA  )                                                                                 
						
						         If  Alltrim(SUBSTR(SA2->A2_DIGAG,1,1))<>"."   .And.  Alltrim(SA2->A2_DIGAG)<>"" .And. !Empty(SA2->A2_DIGAG)  
						              _cRet := "Banco:" + SA2->A2_BANCO + " - Agencia:" + Alltrim(SA2->A2_AGENCIA) + "-" +SA2->A2_DIGAG  + " - Conta:" +SA2->A2_NUMCON	       							   	   				 
						              lAchouDA:=.T.
						         Endif						                   

						         If  Alltrim(SUBSTR(SA2->A2_DIGCTA,1,1))<>"."   .And.  Alltrim(SA2->A2_DIGCTA)<>""  .And.  !Empty(SA2->A2_DIGCTA)  

						               If lAchouDA  
						                    _cRet += "-" +SA2->A2_DIGCTA
						               Else
						                   _cRet := "Banco:" + SA2->A2_BANCO + " - Agencia:" + SA2->A2_AGENCIA + " - Conta:" +Alltrim(SA2->A2_NUMCON) + "-" +SA2->A2_DIGCTA
						               Endif							
						               			    
                           Else
                           
						               If lAchouDA  
						                    _cRet := "Banco:" + SA2->A2_BANCO + " - Agencia:" + Alltrim(SA2->A2_AGENCIA) + "-" +SA2->A2_DIGAG  + " - Conta:" +SA2->A2_NUMCON	       							   	   				 
						               Else
						                   _cRet := "Banco:" + SA2->A2_BANCO + " - Agencia:" + SA2->A2_AGENCIA + " - Conta:" + SA2->A2_NUMCON
						               Endif							
											
						        Endif	

						Else 		

					          _cRet := "Banco:" + Space(12) + " - Agencia:" + Space(16) + " - Conta:" 				

				      Endif      

			       //dbSelectArea(_cAlias)	
			       //dbSetOrder(_nOrder)
			       //dbGoto(_nRecno) 
			   
			   Endif    
			   
				TRA->(dbCloseArea())
				TCDelFile("TRA")
					   
   Endif

RestArea(_aArea)

Return (_cRet)   