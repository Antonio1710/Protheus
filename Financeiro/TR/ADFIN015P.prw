#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADFIN015P บAutor  ณFernando Sigoli     บ Data ณ  23/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIntegra dados da tabela SA1 para a PB3                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                
	
User Function ADFIN015P() 

Local cQry 		:= ""        

Private cPerg   := "ADFIN015P"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integra dados da tabela SA1 para a PB3')

ValidPerg(cPerg)  

If !Pergunte(cPerg,.T.) 
	Return
Else 
	cQry += " SELECT *, "
	cQry += " (SELECT COUNT(*) " 
	cQry += " FROM "+retsqlname("SA1")+" WHERE "   
	cQry += " D_E_L_E_T_ = '' and A1_COD <> '' AND  A1_COD+A1_LOJA NOT IN (SELECT PB3_CODSA1+PB3_LOJSA1 FROM "+retsqlname("PB3")+" WHERE D_E_L_E_T_ = '' and PB3_CODSA1 <>'') "
	If !Empty(MV_PAR01) 
		cQry += " AND A1_COD = '"+MV_PAR01+"' AND A1_LOJA = '"+MV_PAR02+"' "
	EndIF
	cQry += "	) AS A1_TOTAL "
	cQry += " FROM " +retsqlname("SA1")+" WHERE "  
	cQry += " D_E_L_E_T_ = '' and A1_COD <> '' AND  A1_COD+A1_LOJA NOT IN (SELECT PB3_CODSA1+PB3_LOJSA1 FROM "+retsqlname("PB3")+" WHERE D_E_L_E_T_ = '' and PB3_CODSA1 <>'') "
	If !Empty(MV_PAR01) 
		cQry += " AND A1_COD  = '"+MV_PAR01+"' AND A1_LOJA = '"+MV_PAR02+"'"
	EndIf
	cQry += " ORDER BY A1_COD, A1_LOJA "
	
	If Select("QA1PB3") > 0
		DbCloseArea("QA1PB3")
	Endif  
	
	TCQUERY cQry new alias "QA1PB3"
	
	DbSelectArea("QA1PB3")
	Contador := cvaltochar(QA1PB3->A1_TOTAL)
		
	If QA1PB3->A1_TOTAL > 0
    	IF !MSGBOX("Encontrado "+cvaltochar(QA1PB3->A1_TOTAL)+" Cliente(s) na tabela SA1 que nใo existe na PB3. Deseja Integrar?","CONFIRMACAO","YESNO")
			Return
		Endif
		Processa( { || U_RECLOKPB3() }, "Transferindo Cadastro de Cliente","Aguarde...",.T.)
 	Else
 		Alert("Nใo encontrado nenhuma Divergencia entrea SA1 e PB3")
 		Return
 	EndIf
 	
EndIF

Return

//------------------------------------------------------|
//Rotina para gerar registro do cliente SA1 PARA A PB3  | 
//------------------------------------------------------|
User Function RECLOKPB3() 

Local aVetor
Local nFor
Local lExistPb3 :=	.F.

U_ADINF009P('ADFIN015P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integra dados da tabela SA1 para a PB3')

dbSelectArea("PB3")
dbSetOrder(11) 

    
DbSelectArea("QA1PB3")
QA1PB3->(dbgotop())
While !EOF()
//while !Eof() .and. QA1PB3->A1_COD = cCliente .and. QA1PB3->A1_LOJA = cLoja
            
	Alert("Cliente: "+QA1PB3->A1_COD+" Loja: "+QA1PB3->A1_LOJA)

	if !PB3->(dbSeek(xFilial("PB3")+QA1PB3->A1_COD+QA1PB3->A1_LOJA))
		
		RecLock("PB3",.T.)
		lExistPb3 :=	.F. 

	else                   

		RecLock("PB3",.F.)
		lExistPb3 :=	.T.
	endif
	
	
	dbSelectArea("SA1")

	aVetor := APB3VET(lExistPb3)

	dbSelectArea("PB3")
		 
	for nFor := 1 To len(aVetor) 
		FieldPut( FieldPos(aVetor[nFor,1]),aVetor[nFor,2] ) 
	next	
	Confirmsx8()
	msUnlock()
	
	//-----------------------|
	//log de registro        |
	//-----------------------|
	dbSelectArea("ZBE")
	RecLock("ZBE",.T.)
	Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
	Replace ZBE_DATA 	   	WITH dDataBase
	Replace ZBE_HORA 	   	WITH TIME()
	Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
	Replace ZBE_LOG	        WITH ("INTEGRADO CLIENTE : "+QA1PB3->A1_COD+ " LOJA : "+QA1PB3->A1_LOJA)  
	Replace ZBE_MODULO	    WITH "FINANCEIRO"
	Replace ZBE_ROTINA	    WITH "RECLOKPB3" 
	
	
dbSelectArea("QA1PB3")
dbSkip()
enddo   

DbCloseArea("QA1PB3")

Return


//---------------------------------------------------------------------------|
//Retorna um aray com os campos e valores do registro a ser incluido na PB3  |
//---------------------------------------------------------------------------|                                            
Static function APB3VET(lExistPb3)   

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
			Aadd(aVetor , { aCampPB3[nCntFor, 1] , Iif( QA1PB3->A1_IMPENT = "S",'1','2'), NIL }  ) 
		elseif "PB3_TEL" == Alltrim(aCampPB3[nCntFor, 1])
   	 		Aadd(aVetor, {aCampPB3[nCntFor, 1], QA1PB3->A1_DDD + QA1PB3->A1_TEL, 'AllwaysTrue()'})
		elseif "PB3_END" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],  Left(QA1PB3->A1_END,(At(',',QA1PB3->A1_END)-1)),NIL})
		elseif "PB3_NUMERO" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1], Substr(QA1PB3->A1_END,(At(',',QA1PB3->A1_END)+1)),NIL})
		elseif "PB3_ENDENT" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],Left(QA1PB3->A1_ENDENT,(At(',',QA1PB3->A1_ENDENT)-1)),NIL})
		elseif "PB3_NUMENT" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],Substr(QA1PB3->A1_ENDENT,(At(',',QA1PB3->A1_ENDENT)+1)),NIL})
		elseif "PB3_ENDCOB" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],Left(QA1PB3->A1_ENDCOB,(At(',',QA1PB3->A1_ENDCOB)-1)),NIL})
		elseif "PB3_NUMCOB" == Alltrim(aCampPB3[nCntFor, 1])
			Aadd(aVetor, {aCampPB3[nCntFor, 1],Substr(QA1PB3->A1_ENDCOB,(At(',',QA1PB3->A1_ENDCOB)+1)),NIL})
		elseif  Alltrim(aCampPB3[nCntFor, 1]) == "PB3_VEND"
			Aadd(aVetor , { aCampPB3[nCntFor, 1] , Posicione("SA3",1,xFilial("SA3")+QA1PB3->A1_VEND,"A3_CODUSR"), NIL }  ) 
		elseif  Alltrim(aCampPB3[nCntFor, 1]) == "PB3_CODVEN"
			Aadd(aVetor , { aCampPB3[nCntFor, 1] , QA1PB3->A1_VEND, NIL }  ) 
		else
	    
    		nPosPb3 := Ascan( aDifPB3SA1, {|x| Alltrim(x[1]) == Alltrim(aCampPB3[nCntFor, 1]) }) 
	
			if nPosPb3 > 0 
				Aadd(aVetor , { aCampPB3[nCntFor, 1] , &("QA1PB3->"+aDifPB3SA1[nPosPb3,2]), NIL }  )
			else	
				nPosPb3 := Ascan(aCampSA1, {|x| Substr(x[1],4,nLastCar) ==  Substr(aCampPB3[nCntFor, 1],5,nLastCar) } )
					
				If nPosPb3 > 0 
					Aadd( aVetor,{ aCampPB3[nCntFor][1], &("QA1PB3->"+aCampSA1[nPosPb3][1]), NIL } )
				EndIf
			endif
		             
			
	    endif
	endif    
Next nCntFor
                                                 
Return (aVetor) 

//--------------------------------|
//Pergunta                        | 
//--------------------------------|
Static Function ValidPerg(cPerg)
	_sAlias = ALIAS()
	aRegs := {}
	cPerg:= PADR(cPerg,10)

	DbSelectarea("SX1")
	DbsetOrder(1)
	Aadd(aRegs,{cPerg,"01",	"Cliente Cod  "	,"","","mv_ch1","C",06,00,00,"C","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
	Aadd(aRegs,{cPerg,"02",	"Cliente Loja "	,"","","mv_ch2","C",02,00,00,"C","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","",""," ","","","",""})

	For  i := 1 to Len(aRegs)
		If !dbseek(cPerg+aRegs[i,2])
			RECLOCK("SX1", .T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FIELDPUT(j, aRegs[i,j])
				EndIF
			Next
			MSUNLOCK()
		EndIf
	Next
	DbSelectarea(_sAlias)
Return
