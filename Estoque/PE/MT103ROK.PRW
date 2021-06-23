#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT103ROK  บ Autor ณ Juliano Rodrigues  บ Data ณ  21/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function MT103ROK()
                                                                                                
Local   _nPosItem	    := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_ITEM" })
Local   _nPosCONTA    := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_CONTA" }) 
Local   _nPosPerc	    := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_PERC" })
Local   _nPosItemNF	 := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_ITEMNF" })

Local   _nPosITCTA	 := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_ITEMCTA" })


Local _cItem		:= ""
Local _cError 

Private AVerCC := {}

Private  _lRet			:= .T.

Private  _nPosCC	  	     := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_CC" })

//-- ALERT("MT103ROK")
                                         
For nx:= 1 to Len(Acols)	

	  If  aCols[nx][Len(aHeader)+1] //Se algun Item do Rateio estiver Deletado
		    Exit                         
	  Endif
	  
     If  Empty(aCols[Len(aCols)][_nPosPerc])  //-- Nใo achou o Rateio pelo Percentual
			  Exit 		 
	  Endif	
	  
	  _XPos:=Ascan( AVerCC , {|x| (x[1])== aCols[nx][_nPosCC] })
	   
	  If  _XPos = 0 			//-- Nใo Achou                                         
	      AAdd( AVerCC , { aCols[nx][_nPosCC] , 1 , Acols[nx][_nPosItem] }  ) // Adiciona no Array Centro de Custo, Contador de CC e Posi็ใo do Item 
	  Else   						//-- Achou
	      AVerCC[_xPos,2]+=1  //-- Se jแ existir Adiciona 1 no Contador de CC  
	  Endif   
	  
	 _cItem	 := " "+Transform(Acols[nx][_nPosItem],"@!") 
                                  
     //--- Checa se todas as Contas Contabeis sใo Iguais
	  If  nx=1	 	                                
	      _UConta:=aCols[nx][_nPosCONTA]
	  Else
	      If  aCols[nx][_nPosCONTA] <> _UConta
			     _lRet:=.F.
				 _cError := "Cta Ctbil = " + Alltrim(aCols[nx][_nPosCONTA]) + " difere das outras Contas no Item = "+_cItem+" - Verifique!" 
				 Aviso("Erro:Cta Ctbil, Voc๊ alterou a TES - Verifique",_cError,{"Fechar"},2) 		      
			Endif		  	  
	  Endif
	  //--- Fim # Checa se todas as Contas Contabeis sใo Iguais

   //-- Solicita็ใo do Usuแrio = Maurํcio (Controladoria) - em : 29-03-2007--//
   //-- Validar o Item de Conta Contabil pela Filial correspondente --------//
   xItemFil  := GetMV("MV_ITEMFIL")   

   If !Empty(Alltrim(xItemFil))

	   If .Not. Alltrim(aCols[NX][_nPosITCTA]) $ xItemFil 
	      _lRet:=.F.
	      _cError := "Item Ctbil = " + Alltrim(aCols[nx][_nPosITCTA]) + " nใo corresponde a Filial Atual = " + Alltrim(SM0->M0_FILIAL) + " - " + Alltrim(SM0->M0_CODFIL) + " - Verifique Item = "+_cItem
			Aviso("Erro:Item Conta Contแbil - Verifique",_cError,{"Fechar"},2) 		            
			Exit
	   Endif
	
	Endif
	
Next nX
                    

Verif_CC()  //---- Verifica se Existe Algum Centro de Custo com Contador de CC > 1


Return _lRet                           

Static Function Verif_CC()
		
		For nZ:= 1 to Len(AVerCC)	
		
			  _Pos:=Ascan( AVerCC , {|x| (x[1])== aCols[nZ][_nPosCC] })
			   
			  If  _Pos > 0    //-- Achou
			      If  AVerCC[_Pos,2] > 1    
				        _lRet:=.F.
					     _cError := "Centro de Custo = " + Alltrim(AVerCC[_Pos,1]) + " jแ existe no Item = " + AVerCC[_Pos,3] + " Verifique!" 
					     Aviso("Aten็ใo Centro de Custo jแ Utilizado-Impossivel Ratear para um mesmo C.C.",_cError,{"Fechar"},2) 		      	  
					     Exit
				  Endif
			  Endif
			  	 			  	  		
     Next nZ

Return 