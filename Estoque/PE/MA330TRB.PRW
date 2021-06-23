
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#DEFINE ENTER CHR(13)+CHR(10)


/*/{Protheus.doc} User Function MA330TRB
	Ponto de Entrada Recalculo Custo Medio Altera ordem de processamento de movimentos  
	https://tdn.totvs.com/pages/releaseview.action?pageId=340361781
	@type  Function 
	@author Fernando Macieira
	@since  09/04/18 
	@version version
	@history 01/12/2020, Andre Mendes, TKT:3515- Ajustar a ordem das transferЙncias, colocando as mesmas em primeiro lugar, ou seja 100.               

/*/


User Function MA330TRB()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis												  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aArea 	:= GetArea()
Local aAreaSD3 	:= SD3->( GetArea() )
Local cEmpProc	:= GetMV("MV_#CMEMP",,"01") // Caso necessario adicionar mais de uma empresa usar como o exemplo "01#02"...
Local cTMProc	:= GetMV("MV_#CMTM",,"503") // Caso necessario adicionar mais de um tipo de movimeentaГЦo usar como o exemplo "503#504"...


// Muda ordem apenas das empresas autorizadas
If cEmpAnt $ cEmpProc 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Loop principal da rotina no arquivo de trabalho				  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("TRB")
	dbGoTop()
	
	Copy to "CMTEMP1"+GETDBEXTENSION()
	Do While !(TRB->(EOF()))
   
		If TRB->TRB_ALIAS == "SD3" .And. Left(TRB->TRB_CF,3) $ "RE0"
			dbSelectArea( "SD3" )
			dbGoTo( TRB->TRB_RECNO )
			
			// Muda ordem apenas dos tipos de movimentacoes autorizados
			If !SD3->( Eof() ) .and. SD3->D3_COD = TRB->TRB_COD .and. SD3->D3_NUMSEQ = TRB->TRB_SEQ .and. SD3->D3_TM $ cTMProc
				RecLock( "TRB" , .F. )                            
					TRB_ORDEM := "601"
					TRB_NIVEL := Subs(TRB_NIVEL,1,2)+"z"     	
				MsUnlock()
			Endif
		
		Endif      
		
		dbSelectArea("TRB")
		TRB->( dbSkip() )                                                                                              
	
	EndDo
	

EndIf     
   

/*
TKT:3515- Ajustar a ordem das transferЙncias, colocando as mesmas em primeiro lugar, ou seja 100.  
*/

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Loop principal da rotina no arquivo de trabalho				  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("TRB")
	dbGoTop()

	Do While !(TRB->(EOF()))
   
		If TRB->TRB_ALIAS == "SD1" .and. TRB->TRB_ORDEM == "300" .and. TRB->TRB_USATRA == "S"


			RecLock( "TRB" , .F. )                            
				TRB_ORDEM := "100"
				
			TRB->(MsUnlock())

		
		Endif      
		
		dbSelectArea("TRB")
		TRB->( dbSkip() )                                                                                              
	
	EndDo
	Copy to "CMTEMP2"+GETDBEXTENSION()


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorna areas possivelmente alteradas								  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea( aAreaSD3 )
RestArea( aArea )

Return
