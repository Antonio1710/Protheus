#include "rwmake.ch"      
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

User Function A103BRCC()

Local aRet :=    {}

//-- Recuperar a posicao dos campos no aHeader do Item da NFE - SD1
//-- Local _nPCC     := aScan( aHeader, {|x| AllTrim(x[2]) == "D1_CC" } )

Local _XRateio := aScan(aHeader,  {|x| AllTrim(x[2])== "D1_RATEIO" } )
Local _XPTES    := aScan( aHeader, {|x| x[2] = "D1_TES" } )                             
Local _XPCONTA  := aScan( aHeader, {|x| AllTrim(x[2]) == "D1_CONTA" } )
Local _XPITCTA  := aScan( aHeader, {|x| AllTrim(x[2]) == "D1_ITEMCTA" } )                  
Local _XPosItem := aScan(aHeader,  {|x| AllTrim(x[2])== "D1_ITEM" } ) 

Local _XPosProd := aScan(aHeader,  {|x| AllTrim(x[2])== "D1_COD" } )


//-- Alert("A103BRCC")

Public xPCONTA  :=""  //-- Pega Conta Contabil
Public xPITCTA	:=""  //-- Pega Item Conta Contabil
Public xPosItem	:=""  //-- Pega Item da Nota Fiscal     

_aArea:=GetArea()

If (Empty(aCols[n][_XPCONTA]) .Or. Empty(aCols[n][_XPITCTA])) .And. aCols[n][_XRateio]=="2" //Rateio = 2 = Não Rateado
  MsgBox("Por Gentileza Entre com a Conta Contabil e o Item Conta para que o Sistema possa dar a carga desses dados no Rateio!Saia da Tela de Rateio e Tecle F9 novamente")
  Return .F.
Endif

If Empty(aCols[n][_XPCONTA]) .And. aCols[n][_XRateio]=="1"  

	//--- Pega pela TES a Conta Contabil e Zera o Item Contabil, pois o Item da NFE já foi Rateado e o Usuário deseja alterar novamente ---//

	dbSelectAreA('SF4')
	dbSetOrder(1)
	dbSeek( XFilial() + aCols[n][_XPTES] )
  

	dbSelectAreA('SB1')
	dbSetOrder(1)
	dbSeek( XFilial() + aCols[n][_XPosProd] )
	
	If SF4->F4_ESTOQUE = 'S'	                                      
	     
		  xPCONTA := SB1->B1_CONTA		
	
	ElseIf SF4->F4_ESTOQUE = 'N'
	
		  xPCONTA := SB1->B1_CONTAR
	
	EndIf

   //-- Pega Item Contabil 
   xPITCTA := SB1->B1_ITEMCC
                                          

	//------------------------------------------- Fim  -----------------------------------------//
	
Else	

	xPCONTA	:=aCols[n][_XPCONTA]
	xPITCTA	:=aCols[n][_XPITCTA]

Endif

XPosItem :=aCols[n][_XPosItem]

RestArea(_aArea)

Return .T.       