#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fMedFer  ³ Autor ³ Equipe - RH     		³ Data ³ 15/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Buscar as medias no TRP									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

User Function FASRMEDFER(nMediaOut,nMediaHrs,nMedia13s,nAntec13o,lFerias)

Local nIdade,lIdade,lProp
Local nDsrHrsAtiv 	:= 0
Local nPosPd	  	:= 0
Local cCodPgMed		:= ""
Local cCodMedFMs 	:= ""
Local nMedHrDis 	:= 0
Local nMedVlDis 	:= 0
Local aPerFOL		:= {}

DEFAULT lFerias := .T.

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Buscar as medias no TRP')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a Idade do Funcionario								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIdade := Int((dDataBase - SRA->RA_NASC) / 365)
lIdade := If (nIdade < 18 .Or. nIdade > 50,.T.,.F.)
lProp  := .F.
     
//Uso de variavel private porque o mnemonico lMenUmAno tem o valor redefinido na executacao do roteiro.
lMenUmAno := If( Type("lSvMen1Ano") == "U", lMenUmAno, lSvMen1Ano )
     
            
If lMenUmAno .And. nColPro == 1 .And. cPerFeAc # "S"
	lProp := .T.
ElseIf MesAno(GetMemVar("RH_DATAINI")) <= MesAno(GetMemVar("RH_DBASEAT"))
	lProp := .T.
ElseIf GetMvRH("MV_DTMDFER",,"1") == "1"
	FGetPerAtual(@aPerFOL,XFilial( "RCH",SRA->RA_FILIAL),cProcesso,fGetCalcRot("1"))
	If Len(aPerFOL) > 0 .And. MesAno(GetMemVar("RH_DBASEAT")) == MesAno(aPerFOL[1][6])
		lProp := .T.
	EndIf
EndIf

dbSelectArea("TRP")

// Medias
If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"1"+"999"+"97MD")   // Outros Adic.
	nMediaOut := TRP->RP_VALATU
ElseIf lProp
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"2"+"999"+"97MD")  
		nMediaOut := TRP->RP_VALATU
	EndIf		
EndIf

If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"1"+"999"+"98MD")   // H.Extras
	nMediaHrs := TRP->RP_VALATU
ElseIf lProp
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"2"+"999"+"98MD")  
		nMediaHrs := TRP->RP_VALATU
	EndIf
EndIf

If GetMvRH("MV_MED1OP") == "S"
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"3"+"999"+"99MD")
		nMedia13s := TRP->RP_VALATU + fDsrHrsAtiv("3",aCodFol)
	EndIf
	// Calcula Peric. / Insalub Sobre Verba de Medias 13.Salario que tem Incidencia
	nMedPer13 := nMedIns13 := 0.00
	fXMedPerIns(@nMedPer13,@nMedIns13,'3',SalHora,Val_BInsal,aCodFol) 
	nMedia13s += (nMedPer13+nMedIns13)
EndIf

If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"1"+"999"+"99MD")
	nDsrHrsAtiv := fDsrHrsAtiv("1",aCodFol,"99MD") //Calculo do DSR / Horas Atividade de professores
ElseIf lProp
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"2"+"999"+"99MD")
		nDsrHrsAtiv := fDsrHrsAtiv("2",aCodFol,"99MD") //Calculo do DSR / Horas Atividade de professores
	EndIf
EndIf

nMediaOut += nDsrHrsAtiv //Soma DSR / Horas Atividade p/ gerar na verba de media de professores(id.636)

// Calcula Peric. / Insalub Sobre Verba de Medias Ferias que tem Incidencia
nMedPer := nMedIns := 0.00
fXMedPerIns(@nMedPer,@nMedIns,'1',SalHora,Val_BInsal,aCodFol)  

If Type("nMedAdcI") != "U" .And. (!Empty(aCodFol[639,1]) .Or. !Empty(aCodFol[640,1]))//Pagto Peric. Sobre Medias Ferias##Pagto Insalub. Sobre Medias Ferias
	nMedAdcI := nMedIns
	nMedAdcP := nMedPer
Else
	nMediaHrs += (nMedPer+nMedIns)
EndIf

// Antecipacao 13o Salario
If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"3"+"997"+"9598")
	nAntec13o := TRP->RP_VALATU 
EndIf

//Caso seja dissidio, valida se a media apurada e' menor do que a media paga no mes original ou se foi selecionado para nao apurar a diferenca da media
If lDissidio
	If SRA->RA_CATFUNC == "C"
		cCodPgMed	:= aCodFol[343,1]//Media Ferias de Comissiao no Mes
		cCodMedFMs	:= aCodFol[344,1]//Media Ferias de Comissiao no Mes Seguinte
	ElseIf SRA->RA_CATFUNC == "T"
		cCodPgMed	:= aCodFol[345,1]//Media Ferias de Tarefa no Mes
		cCodMedFMs	:= aCodFol[346,1]//Media Ferias de Tarefa no Mes Seguinte
	ElseIf SRA->RA_CATFUNC $ "I*J"
		cCodPgMed	:= aCodFol[636,1]//Media Ferias (calculo professor)
		cCodMedFMs	:= aCodFol[637,1]//Media Ferias Mes Seguinte (calculo professor)
	Else
		cCodPgMed	:= aCodFol[075,1]//Media Ferias Valor
		cCodMedFMs	:= aCodFol[076,1]//Media Ferias Valor Mes Seguinte
	EndIf

	//Verifica o valor da media de valor que foi paga no mes original
	aEval( aDif_Fer, { |x| nMedVlDis += If( x[1] $ cCodPgMed + "/" + cCodMedFMs + "/" + aCodFol[623,1] + "/" + aCodFol[634,1], x[2], 0 ) } )
	//Verifica o valor da media de horas que foi paga no mes original
	aEval( aDif_Fer, { |x| nMedHrDis += If( x[1] $ aCodFol[082,1] + "/" + aCodFol[083,1] + "/" + aCodFol[622,1] + "/" + aCodFol[633,1], x[2], 0 ) } )

	If nMediaOut > 0 .Or. nMedVlDis > 0	
		If PosSrv(cCodPgMed, xFilial("SRV", SRA->RA_FILIAL), "RV_COMPL_") != "S" .Or. nMediaOut < nMedVlDis
			nPosPd := aScan( aDif_Fer, { |x| x[1] == cCodPgMed } )
			If nPosPd > 0
				fGeraVerba(cCodPgMed, aDif_Fer[nPosPd, 2])
			EndIf
			
			nPosPd := aScan( aDif_Fer, { |x| x[1] == cCodMedFMs } )
			If nPosPd > 0
				fGeraVerba(cCodMedFMs, aDif_Fer[nPosPd, 2])
			EndIf	
			
			nPosPd := aScan( aDif_Fer, { |x| x[1] == aCodFol[623,1] } )//Media Valor sobre Abono
			If nPosPd > 0
				fGeraVerba(aCodFol[623,1], aDif_Fer[nPosPd, 2])
			EndIf	
			
			nPosPd := aScan( aDif_Fer, { |x| x[1] == aCodFol[634,1] } )//Media valor sobre Abono Mes seguinte
			If nPosPd > 0
				fGeraVerba(aCodFol[634,1], aDif_Fer[nPosPd, 2])
			EndIf	
		EndIf
	EndIf
	
	If nMediaHrs > 0 .Or. nMedHrDis > 0
		If PosSrv(aCodFol[082,1], xFilial("SRV", SRA->RA_FILIAL), "RV_COMPL_") != "S" .Or. nMediaHrs < nMedHrDis
			nPosPd := aScan( aDif_Fer, { |x| x[1] == aCodFol[082,1] } )//Medias s/ Horas Extras Mes
			If nPosPd > 0
				fGeraVerba(aCodFol[082,1], aDif_Fer[nPosPd, 2])
			EndIf
			
			nPosPd := aScan( aDif_Fer, { |x| x[1] == aCodFol[083,1] } )//Medias s/ Horas Mes Seguinte
			If nPosPd > 0
				fGeraVerba(aCodFol[083,1], aDif_Fer[nPosPd, 2])
			EndIf	
			
			nPosPd := aScan( aDif_Fer, { |x| x[1] == aCodFol[622,1] } )//Media Horas sobre Abono
			If nPosPd > 0
				fGeraVerba(aCodFol[622,1], aDif_Fer[nPosPd, 2])
			EndIf	
			
			nPosPd := aScan( aDif_Fer, { |x| x[1] == aCodFol[633,1] } )//Media Horas sobre Abono Mes seguinte
			If nPosPd > 0
				fGeraVerba(aCodFol[633,1], aDif_Fer[nPosPd, 2])
			EndIf	
		EndIf
	EndIf
EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADGPEXTST ºAutor  ³Microsiga           º Data ³  04/06/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function fXMedPerIns(nMedPer,nMedIns,cTipMed,SalHora,nValMin,aCodFol,cTipTot,nValPer,nValIns)

Local nMinHora  	:= 0.00
Local nBMedPer  	:= nBMedIns := 0.00
Local nHMedIns		:= 0                       // total das horas (media) qdo utilizado parametro MV_INSALVH como 'H'
Local cGetInSal 	:= GetMvRH("MV_INSALVH")
Local cGetPeric 	:= GetMvRH("MV_PERICVH")
Local nFatorInsal	:= 0
Local lCalInV		:= (SRA->RA_ADCINS $ "2*3*4" .and. Posicione("RCE",1,xFilial("RCE")+SRA->RA_SINDICA,"RCE_BCALIN") == "3")
Local lCalPerV		:= 	SRA->RA_ADCPERI == "2" .and. Posicione("RCE",1,xFilial("RCE")+SRA->RA_SINDICA,"RCE_BCALPE") == "2"	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Tratamento para o fator multiplicador do sal.minimo na insalubridade (radiologista).				|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GETNEWPAR("MV_USASMIN",.T.) 

	nFatorInsal	:= 1
    IF 	SRA->( FieldPos( 'RA_FTINSAL' ) > 0 )  .AND.  !Empty(SRA->RA_FTINSAL)
    	nFatorInsal	:= SRA->RA_FTINSAL
    EndIf
	nMinHora  	:= (Round( ( nValMin *nFatorInsal)  , 2)/SRA->RA_HRSMES)
Else
	nMinHora	:= SalHora
EndIf	

// Verifica se Foram Passados os Parametros da Funcao
cTipTot := If (cTipTot= Nil,'99MD',cTipTot)
nValPer := If (nValPer= Nil,0.00  ,nValPer)
nValIns := If (nValIns= Nil,0.00  ,nValIns)

If lCalInV .or. lCalPerV
	
	If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cTipMed)
		While ! Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT+cTipMed = TRP->RP_FILIAL+TRP->RP_MAT+TRP->RP_TIPO
			If TRP->RP_PD > "900"
				dbSkip( 1 )
				Loop
			EndIf
			// Verifica se e o registro de total de medias
			If TRP->RP_DATARQ = cTipTot
				cVerba := TRP->RP_PD
				// Salva Registro para Procurar o tipo da Verba
				nRegAnt := Recno()
				dbselectArea("TRP")
				If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cTipMed + cVerba)
					cTipHV := TRP->RP_TIPO1
				Else
					cTipHV := "V"
				EndIf
				// Volta no Registro onde estava processando
				dbGoTo(nRegAnt)
				
				// Verifica Incidencia Para Periculosidade
				If PosSrv(TRP->RP_PD,SRA->RA_FILIAL,"RV_PERICUL") == "S"
	  				nBMedPer += If (cTipHV = 'H'.And. cGetPeric = 'H',TRP->RP_HORAS * SalHora,TRP->RP_VALATU)
				EndIf
				
				// Verifica Incidencia para Insalubridade
				If PosSrv(TRP->RP_PD,SRA->RA_FILIAL,"RV_INSALUB") == "S"
					nHMedIns += If (cTipHV = 'H' .And. cGetInsal = 'H',TRP->RP_HORAS,0)   // SE UTILIZAR PARAMETRO MV_INSALVH como 'H', armazenar o total de horas para o calculo da media de insal.
					nBMedIns += If (! cGetInsal = 'H',TRP->RP_VALATU,0)
				EndIf
			EndIf
			dbSkip(1)
		Enddo
		// Calculo do Valor da Insalubridade sobre Media
		If (nBMedIns > 0.00 .or. nHMedIns > 0) .And. lCalInV
			PosSrv(cCodIns,SRA->RA_FILIAL)
			nPerc_adi := SRV->RV_PERC
			If cGetInsal = 'H' // se utiliza parametro MV_INSALVH como 'H', efetuar calculo da media igual na folha ( (tot. horas (media) *  sal.hora min * % insalub. ))
				nMedIns := ((nHMedIns * nMinHora) * nPerc_adi) /100      
	    	Else
 				nMedIns := ((( (nBMedIns+nValIns) / SRA->RA_HRSMES) * nMinHora) * nPerc_adi) /100
	 		EndIf	
		EndIf
		// Calculo do Valor da Periculosidade sobre a Media
		If nBMedPer > 0.00 .And. lCalPerV
			PosSrv(aCodfol[36,1],SRA->RA_FILIAL)
			nPerc_adi := SRV->RV_PERC
			nMedPer   := ( (nBMedPer+nValPer) * nPerc_adi) /100				
		EndIf
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADGPEXTST ºAutor  ³Microsiga           º Data ³  04/06/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FASRBUSCAMED(nMedFerv,nMedFerp,nMed13o,nMedAviso,nDesc13,nMedDobra)

Local nDsrm_fv := nDsrm_fp := nDsrm_av := nDsrm_13 := 0.00
Local nMedPer  := nMedIns  := nBasePer := nBasIns  := 0.00
Local cTipMed,nPosDsr,k
Local nDiasFer	  := aTabFer[3]
Local nAnos	   	  :=	0
Local cMesAnoRef  := cAnoMes // Mnemonico com o Mes/Ano Referencia
Local nDsrHrsAtiv := 0
Local nPosSemana  := 0
Local nPosValor   := 0
Local nPosMed	  := 0
Local nMedAux	  := 0
Local lCalInV	  := (SRA->RA_ADCINS $ "2*3*4" .and. Posicione("RCE",1,xFilial("RCE")+SRA->RA_SINDICA,"RCE_BCALIN") == "3")
Local lCalPerV	  := 	SRA->RA_ADCPERI == "2" .and. Posicione("RCE",1,xFilial("RCE")+SRA->RA_SINDICA,"RCE_BCALPE") == "2"
Local nMedFp	  := 0

U_ADINF009P('ADGPE032P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Buscar as medias no TRP')

If cPaisLoc == "PAR"
	IF Year(dDataBase) - Year(SRA->RA_NASC) <= 17  .Or. ;
		(Year(dDataBase) - Year(SRA->RA_NASC) == 18 .And.;
	 	Substr(Dtos(dDataBase),5,4) <=Substr(Dtos(SRA->RA_NASC),5,4))
		nDiasFer	:=	aTabFer[3]
	Else		
		nAnos	:= (Year(dDataBase) - Year(SRA->RA_ADMISSA)) - If(Substr(Dtos(dDataBase),5,4) <= Substr(Dtos(SRA->RA_ADMISSA),5,4),1,0 )
		Do Case
			Case nAnos > 10
				nDiasFer	:=	aTabFer[3]
			Case nAnos > 5 .And. nAnos <= 10
				nDiasFer	:=	18
			Case nAnos <= 5
				nDiasFer	:=	12
		EndCase					
	EndIf
ElseIf cPaisLoc == "CHI"
	nAnos	:= (Year(dDataBase) - Year(SRA->RA_ADMISSA)) - If(Substr(Dtos(dDataBase),5,4) <= Substr(Dtos(SRA->RA_ADMISSA),5,4),1,0 )
	nDiasFer	:=	15
	If nAnos >= 13
		nDiasFer	+=	Int((nAnos-10)/3)
	EndIf
EndIf	

dbSelectArea("TRP")
If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "3" + "997" + "9598" )
	nDesc13 := TRP->RP_VALATU
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a rescisao for no mes seguinte ao mes que esta aberto  ³
//³soma o valor da 1a parcela paga nas ferias na variavel de ³
//³desconto da 1a parcela do 13o salario e exclui a verba de ³
//³1a parcela que esta no aPd quando esta verba foi gerada   ³
//³pelo sistema ("V").                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !( cMesAnoRef == MesAno( dDataDem ) ) .And. !lRecRes
	If Type("oSrr") == "U"
		Aeval(aPd,{|x| nDesc13 += If(x[1] == aCodFol[022,1] .And. x[3] == cSemana,x[5],0)})
		Aeval(aPd,{|x| x[9] := If(x[1] == aCodFol[022,1] .And. x[3] == cSemana .And. x[7] == "V","D",x[9])})
	Else
		nDesc13 := FO_SOMAALLREGS(@&cObjeto,cCpoValor,{cCpoPd,cCpoNPagto},{FGETCODFOL("0022"),cSemana})
	EndIf
ElseIf !( cMesAnoRef == MesAno( dDataDem ) ) .And. lRecRes .And. Type("aCols") == "A" .And. nDesc13 == 0
	nPosSemana	:= GdFieldPos("RR_SEMANA")
	nPosValor 	:= GdFieldPos("RR_VALOR")
	Aeval(aCols,{|x| nDesc13 += If(x[1] == aCodFol[116,1] .And. x[nPosSemana] == cSemana,x[nPosValor],0)})
	Aeval(aCols,{|x| nDesc13 += If(x[1] == aCodFol[183,1] .And. x[nPosSemana] == cSemana,x[nPosValor],0)})
EndIf

dbSelectArea("TRP")
If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
	While ! Eof() .and. SRA->RA_FILIAL+SRA->RA_MAT = TRP->RP_FILIAL+TRP->RP_MAT
		IF TRP->RP_PD > "900"
			dbSkip( 1 )
			Loop
		EndIf
		IF TRP->RP_TIPO $ "156789" .and. TRP->RP_DATARQ = "99MD"
			nDsrm_fv += TRP->RP_VALATU				
		ElseIf TRP->Rp_TIPO $ "2" .and. TRP->RP_DATARQ = "9999"
			nDsrm_fp += TRP->RP_VALATU
		ElseIf TRP->RP_TIPO $ "3" .and. TRP->RP_DATARQ = "9999"
			nDsrm_13 += TRP->RP_VALATU
		ElseIf TRP->RP_TIPO $ "4" .and. TRP->RP_DATARQ = "9999"
			nDsrm_av += TRP->RP_VALATU
		EndIf
		dbSkip(1)
	End While
	
	If cPaisLoc == "ARG"
		lFerVen := ( FTABELA("S012",VAL(CTIPRES),9) == "S" )
		lFerPro := lFerVen
		l13Sal  := ( FTABELA("S012",VAL(CTIPRES),10) == "S" )
		lAviso  := ( FTABELA("S012",VAL(CTIPRES),7) == "S" )
	ElseIf !Empty(aIncRes)
		lFerVen := ( aIncRes[8] = "S" )
		lFerPro := lFerVen
		l13Sal  := ( aIncRes[9] = "S" )
		lAviso  := ( aIncRes[10] = "S" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do Dsr s/ Medias                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDsrm_fv := IF(nDsrm_fv > 0.00 .and. lFerVen,(nDsrm_fv * Descanso) / Normal,0.00)
	nDsrm_fp := IF(nDsrm_fp > 0.00 .and. lFerPro,(nDsrm_fp * Descanso) / Normal,0.00)
	nDsrm_13 := IF(nDsrm_13 > 0.00 .and. l13Sal	 ,(nDsrm_13 * Descanso) / Normal,0.00)
	nDsrm_av := IF(nDsrm_av > 0.00 .and. lAviso ,(nDsrm_av * Descanso) / Normal,0.00)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Media de Ferias Vencidas (Tratamento de Mais de Um Periodo)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For k := 1 To 6
		cTipMed	:= Str( IF(k ==1, 1,k+3), 1)
		IF dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTipMed + "999" + "99MD" )
			nMedAux  := TRP->RP_VALATU + IF(k = 1,nDsrm_fv,0) + fDsrHrsAtiv(cTipMed,aCodFol)
			nMedFerv += nMedAux
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Peric./Insalub Sobre Verba de Medias  incidencia   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMedPer := nMedIns := 0.00
			fXMedPerIns(@nMedPer,@nMedIns,cTipMed,SalHora,Val_BInsal,aCodFol)
			nMedFerv += (nMedPer+nMedIns)
			If Type("aPerMedia") != "U" .and. ( nPosMed := aScan(aPerMedia, {|x| x[1] = cTipMed}) ) > 0
				aPerMedia[nPosMed,4] += nMedFerv
			EndIf			
			//-- Iguala a media do primeiro periodo para pagamento da Dobra se houver
			If K = 1
				nMedDobra := nMedFerv
			EndIf	
			//If nGComisFv > 0
			//	nGComisFv := If(nMedFerv > nGComisFv, 0, nGComisFv - nMedFerv)
			//Endif
			//If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTipMed + "999" + "98MD" )
			//	nGComisFv += TRP->RP_VALATU + IF(k = 1,nDsrm_fv,0)
			//EndIf
		EndIf
	Next k
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Media de Ferias Proporcionais                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("TRP")
	If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "2" + "999" + "9999" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salva Registro da Media                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRecFerp := Recno()
		nMedPer := nMedIns := 0.00
		
		If lCalInV .or. lCalPerV
			
			nBasPer := nBasIns := 0.00
		
			If lCalInV //Insalubridade sobre verbas
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma Para Ferias Verbas Devem Ser Somadas Per. S/ Media    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("oSrr") == "U"
					aEval( aPd ,{ |X| SomaInc(X,10,@nBasIns,8,"S", , , , ,aCodFol) })
				Else
					nBasIns := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_INSALUB","RV_MEDFER"},{"S","S"})
				EndIf
				nBasIns  := (nBasIns /  12 )
			EndIf
			
			If lCalPerV //Periculosidade sobre verbas
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma Para Ferias Verbas Devem Ser Somadas Per. S/ Media    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("oSrr") == "U"
					aEval( aPd ,{ |X| SomaInc(X, 9,@nBasPer,8,"S", , , , ,aCodFol) })
				Else
					nBasPer := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_PERICUL","RV_MEDFER"},{"S","S"})
				EndIf
				nBasPer  := (nBasePer / 12)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Peric./Insalub Verba de Medias Tem Incidencia      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMedPer := nMedIns := 0.00
			fXMedPerIns(@nMedPer,@nMedIns,"2",SalHora,Val_BInsal,aCodFol,'9999',nBasPer,nBasIns)
			dbGoto(nRecFerp)
		EndIf
		
		nDsrHrsAtiv := fDsrHrsAtiv("2",aCodFol,"9999") //Calculo do DSR / Horas Atividade de professores
		
		lDFerAvi := !(SRG->RG_DFERAVI == 0 .and. nDiasAv > 0 .and. cCompl == "S")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ A rotina de media gera os periodos de acordo com a data de demissao sem   ³
		//³ o aviso previo e o periodo para media pode ser proporcional e com o aviso ³
		//³ as ferias mudou de proporcional para vencidas e a media ficou gravada no  ³
		//³ periodo proporcional, nessa situacao utilizar media proporcional para o   ³
		//³ calculo das ferias vencidas.                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lDFerAvi
			If ( (nDFerV == 0 .And. nMedFerv = 0) .Or. (nDFerV > 0 .And. (nDFerA + nDFerInd ) == aTabFer[3]) ) .And. nDFerA > 0 .And. nDFerVen > 0
				nMedFerv := TRP->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv
			ElseIf cMedDir == "S"
				nMedFerp := ( TRP->RP_VALATU + nDsrm_fp + nMedIns + nMedPer + nDsrHrsAtiv )
			Else
				nMedFerp := (( (TRP->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv) * M->RG_DFERPRO ) / nDiasFer )
			EndIf
		Else
			IF cMedDir == "S"
				nMedFerp := ( TRP->RP_VALATU + nDsrm_fp + nMedIns + nMedPer + nDsrHrsAtiv )
			Else 
				//Para o calculo da media, devemos considerar os dias de aviso, limitando a 30 dias
				nMedFp := ( (TRP->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv) * M->RG_DFERPRO ) / nDiasFer
				nMedFerp := (( (TRP->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv) * Min(M->RG_DFERPRO + M->RG_DFERAVI,30) ) / nDiasFer )
			EndIf
		EndIf	
   		//If nGComisFp > 0
		//	nGComisFp := If(nMedFp > nGComisFp, 0, nGComisFp - nMedFp)
		//Endif
		//If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "2" + "999" + "9899" )
		//	nGComisFp += TRP->RP_VALATU 
		//EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Media de 13§ Salario                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("TRP")
	IF dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "3" + "999" + "9999" )
		nRec13 := Recno()
		nMedPer := nMedIns := 0.00
		If lCalInV .or. lCalPerV
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma Para 13§ Verbas Devem Ser Somadas Para Per. S/ Media  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nBasPer := nBasIns := 0.00
			
			If lCalInV
				If Type("oSrr") == "U"
					aEval( aPd ,{ |X| SomaInc(X,10,@nBasIns,7,"S", , , , ,aCodFol) })
				Else
					nBasIns := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_INSALUB","RV_MED13"},{"S","S"})
				EndIf
				nBasIns := (nBasIns /  12 )
			EndIf
			If lCalPerV
				If Type("oSrr") == "U"
					aEval( aPd ,{ |X| SomaInc(X, 9,@nBasPer,7,"S", , , , ,aCodFol) })
				Else
					nBasPer := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_PERICUL","RV_MED13"},{"S","S"})
				EndIf
				nBasPer  := (nBasePer / 12)
			EndIf			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Peric./Insalub Verba de Medias Que Tem Incidencia  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fXMedPerIns(@nMedPer,@nMedIns,"3",SalHora,Val_BInsal,aCodFol,'9999',nBasPer,nBasIns)
			dbGoto(nRec13)
		EndIf
		nMed13o := TRP->RP_VALATU + nDsrm_13 + nMedPer + nMedIns + fDsrHrsAtiv("3",aCodFol,"9999")
		//If nGComis13 > 0
		//	nGComis13 := If(nMed13o > nGComis13, 0, nGComis13 - nMed13o)
		//Endif
		//If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "3" + "999" + "9899" )
		//	nGComis13 += TRP->RP_VALATU
		//EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faltas 13§ Salario                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("TRP")
	IF dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "3" + "998" + "9998" )
		nAvosFal13  := TRP->RP_HORAS
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Media Aviso Previo                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("TRP")
	IF dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "4" + "999" + "9999" )
		nRecAv  := Recno()
		nMedPer := nMedIns := 0.00
		If lCalInV .or. lCalPerV
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma Para Aviso Verbas Devem Ser Somadas Para Per. S/ Media³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nBasPer := nBasIns := 0.00
			If dDataDem - SRA->RA_ADMISSA < 365
				If lCalInV
					If Type("oSrr") == "U"
						aEval( aPd ,{ |X| SomaInc(X,10,@nBasIns,23,"S", , , , ,aCodFol) })
					Else
						nBasIns := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_INSALUB","RV_MEDAVI"},{"S","S"})
					EndIf
					nBasIns  := (nBasIns /  12 )
				EndIf
				If lCalPerV
					If Type("oSrr") == "U"
						aEval( aPd ,{ |X| SomaInc(X, 9,@nBasPer,23,"S", , , , ,aCodFol) })
					Else
						nBasPer := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_PERICUL","RV_MEDAVI"},{"S","S"})
					EndIf
					nBasPer  := (nBasePer / 12)
				EndIf
				
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Peric./Insalub Verba de Medias Que Tem Incidencia  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMedPer := nMedIns := 0.00
			fXMedPerIns(@nMedPer,@nMedIns,"4",SalHora,Val_BInsal,aCodFol,'9999',nBasPer,nBasIns)
			dbGoto(nRecAv)
		EndIf
		nMedAviso   := TRP->RP_VALATU + nDsrm_av + nMedPer + nMedIns + fDsrHrsAtiv("4",aCodFol,"9999")
   		//If nGComisAv > 0
		//	nGComisAv := If(nMedAviso > nGComisAv, 0, nGComisAv - nMedAviso)
		//Endif
		//If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "4" + "999" + "9899" )
		//	nGComisAv += TRP->RP_VALATU
		//EndIf
	EndIf
EndIf

Return( NIL )
