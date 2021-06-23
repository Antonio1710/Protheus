#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³USA1TOPB3 ºAutor  ³Alexandre Circenis  º Data ³  08/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte os dados da tabela SA1 para a PB3                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                

User Function SA1TOPB3()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Converte os dados da tabela SA1 para a PB3')
Processa( { || U_GravaPB3() }, "Transferindo Cadastro de Cliente","Aguarde...",.T.)

Return

User Function GravaPB3()

Local aVetor
Local nFor
Local lExistPb3 :=	.F.

U_ADINF009P('SA1TOPB3' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Converte os dados da tabela SA1 para a PB3')

dbSelectArea("PB3")
dbSetOrder(11) // filial+codigo e loja no SA1

dbSelectArea("SA1")
dbGotop()
ProcRegua(SA1->(RecCount()))

while !Eof()

	IncProc()
	

//	aVetor := APB3NEW()
	
	if !PB3->(dbSeek(xFilial("PB3")+SA1->A1_COD+SA1->A1_LOJA))
		
		RecLock("PB3",.T.)
		lExistPb3 :=	.F. 

	else                   

		RecLock("PB3",.F.)
		lExistPb3 :=	.T.
	endif
	
	
	dbSelectArea("SA1")

	aVetor := APB3NEW(lExistPb3)

	dbSelectArea("PB3")
		 
	for nFor := 1 To len(aVetor) 
		FieldPut( FieldPos(aVetor[nFor,1]),aVetor[nFor,2] ) 
	next	
	Confirmsx8()
	msUnlock()
	
	dbSelectArea("SA1")
	dbSkip()
	
enddo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³APB3NEW   ºAutor  ³Microsiga           º Data ³  08/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna um aray com os campos e valores do registro a ser  º±±
±±º          ³ incluido na PB3                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function APB3NEW(lExistPb3)   

Local aCli := {}

Local lRet     := .T.
Local aCampPB3 := PB3->(dbStruct())
Local aCampSA1 := SA1->(dbStruct())
Local aVetor   := {}
Local nLastCar := Len(SX3->X3_CAMPO)-4
Local nCntFor  := 0
Local nPosPb3  := 0
Local cAlias   := Alias()
Local aDifPB3SA1 := U_DFPB3SA1()
Local cIgnorar := "PB3_DDD"

dbSelectArea("PB3")

For nCntFor := 1 To Len(aCampPB3)
	
	if !Alltrim(aCampPB3[nCntFor, 1]) $ cIgnorar
    
		if Alltrim(aCampPb3[nCntFor, 1]) == "PB3_COD"
			Aadd(aVetor , { aCampPB3[nCntFor, 1] , Iif(lExistPb3,PB3->PB3_COD,GetSxeNum("PB3","PB3_COD")), NIL }  ) 
		elseif "PB3_LOJA" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor , { aCampPB3[nCntFor, 1] , Iif(lExistPb3,PB3->PB3_LOJA,'00'), NIL }  ) 
		elseif "PB3_IMPEND" == Alltrim(aCampPB3[nCntFor, 1]) 
			Aadd(aVetor , { aCampPB3[nCntFor, 1] , Iif( SA1->A1_IMPENT = "S",'1','2'), NIL }  ) 
		elseif "PB3_TEL" == Alltrim(aCampPB3[nCntFor, 1])
   	 		Aadd(aVetor, {aCampPB3[nCntFor, 1], SA1->A1_DDD + SA1->A1_TEL, 'AllwaysTrue()'})
		elseif "PB3_END" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],  Left(SA1->A1_END,(At(',',SA1->A1_END)-1)),NIL})
		elseif "PB3_NUMERO" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1], Substr(SA1->A1_END,(At(',',SA1->A1_END)+1)),NIL})
		elseif "PB3_ENDENT" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],Left(SA1->A1_ENDENT,(At(',',SA1->A1_ENDENT)-1)),NIL})
		elseif "PB3_NUMENT" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],Substr(SA1->A1_ENDENT,(At(',',SA1->A1_ENDENT)+1)),NIL})
		elseif "PB3_ENDCOB" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],Left(SA1->A1_ENDCOB,(At(',',SA1->A1_ENDCOB)-1)),NIL})
		elseif "PB3_NUMCOB" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],Substr(SA1->A1_ENDCOB,(At(',',SA1->A1_ENDCOB)+1)),NIL})
		elseif  Alltrim(aCampPB3[nCntFor, 1]) == "PB3_VEND"
			Aadd(aVetor , { aCampPB3[nCntFor, 1] , Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_CODUSR"), NIL }  ) 
		elseif  Alltrim(aCampPB3[nCntFor, 1]) == "PB3_CODVEN"
			Aadd(aVetor , { aCampPB3[nCntFor, 1] , SA1->A1_VEND, NIL }  ) 
		else
	    
    		nPosPb3 := Ascan( aDifPB3SA1, {|x| Alltrim(x[1]) == Alltrim(aCampPB3[nCntFor, 1]) }) 
	
			if nPosPb3 > 0 // .and. !Empty(&("PB3->"+aDifPB3SA1[nPosPb3,1]))
				Aadd(aVetor , { aCampPB3[nCntFor, 1] , &("SA1->"+aDifPB3SA1[nPosPb3,2]), NIL }  )
			else	
				nPosPb3 := Ascan(aCampSA1, {|x| Substr(x[1],4,nLastCar) ==  Substr(aCampPB3[nCntFor, 1],5,nLastCar) } )
					
				If nPosPb3 > 0 //.and. !Empty(&("PB3->"+aCampPB3[nPosPb3][1])) 
					Aadd( aVetor,{ aCampPB3[nCntFor][1], &("SA1->"+aCampSA1[nPosPb3][1]), NIL } )
				EndIf
			endif
		             
			
	    endif
	endif    
Next nCntFor
                                                 
Return (aVetor)

User Function CheckVer()

cVersao := "W.1.0.1"

U_ADINF009P('SA1TOPB3' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Converte os dados da tabela SA1 para a PB3')

Return(cVersao) 


User Function ShowVer()

Local cVersão := U_CheckVer()

U_ADINF009P('SA1TOPB3' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Converte os dados da tabela SA1 para a PB3')

ApMsgAlert("Versão atual: " + cVersão, "Versão")

Return Nil