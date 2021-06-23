#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRotina    บAutor  ณEverson             บ Data ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalendแrio de entregas.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN040P() // U_ADVEN040P()

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Private aPeriod	:= {"JAN","FEV","MARC","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"}
	Private aDadosZBJ	:= {} 
	Private cNomTr1		:= ""
	Private aCampos		:= {}
	Private bVisu		:= {||operacao(2)}
	Private bIncl		:= {||operacao(3)}
	Private bAlte		:= {||operacao(4)}
	Private bExcl		:= {||operacao(5)}
	Private bRel		:= {||impCal()}
	
	Private cCadastro 	:= "Calendแrio de Entregas"
	
	Private aRotina   	:= {{"Visualizar" 	,"Eval(bVisu)" ,0,2},; 
							{"Incluir"     	,"Eval(bIncl)" ,0,3},; 
							{"Alterar"     	,"Eval(bAlte)" ,0,4},;
                            {"Excluir"     	,"Eval(bExcl)" ,0,5},;
                            {"Imp. Cal."    ,"Eval(bRel)"  ,0,7}} 
							
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calendแrio de entregas.')
    
    arqTemp()
    
    aCampos:={{"Filial "  ,"T_FILIAL" ,"C", 2,0,"@!"},;
          	  {"Ano  "    ,"T_ANO"    ,"C", 4,0,"@!"},;
              {"Descri็ใo","T_DESC"   ,"C",40,0,"@!"}}
              
    SetKey(VK_F5, {||impCSV()})
    
    MBrowse(6,1,22,75,"T_ZBJ",aCampos)
	
	fErase(cNomTr1 + '.*')  

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณincluir   บAutor  ณEverson           บData    ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIncluir calendแrio.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function arqTemp()

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
	Local aStru 	:= {}
	Local cIndex	:= ""
	Local i			:= 1
	
	If Select("T_ZBJ") > 0
		T_ZBJ->(DbCloseArea())
	
	EndIf

	Aadd(aStru,{"T_FILIAL"  , "C",06,0})
	Aadd(aStru,{"T_ANO" 	, "C",06,0})
	Aadd(aStru,{"T_DESC" 	, "C",30,0})
	Aadd(aStru,{"T_USER" 	, "C",20,0})
	
	cNomTr1 := CriaTrab(aStru)
	
	DbUseArea(.T.,,cNomTr1,"T_ZBJ",.F.,.F.)
	
	//Obt้m os resumos dos calendแrios.
	aDadosZBJ := tabZBJ()
	
	DbSelectArea("T_ZBJ")
	For i := 1 To Len(aDadosZBJ)
		RecLock("T_ZBJ",.T.)
			T_ZBJ->T_FILIAL := aDadosZBJ[i][1]
			T_ZBJ->T_ANO	:= aDadosZBJ[i][2]
			T_ZBJ->T_DESC	:= aDadosZBJ[i][3]
			T_ZBJ->T_USER	:= aDadosZBJ[i][4]
		MsUnlock()
		
	Next i
	
	cIndex   := "T_FILIAL+T_ANO"
	IndRegua( "T_ZBJ",cNomTr1,cIndex,,,"Criando ํndice..." )

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtabZBJ   บAutor  ณEverson           บData    ณ11/01/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObt้m os resumos dos calendแrio criados.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function tabZBJ()

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aRetorno 	:= {}
	Local cQuery 	:= ""
	
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " DISTINCT ZBJ_FILIAL, ZBJ_ANO, ZBJ_DESC, ZBJ_USUARI " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZBJ") + " AS ZBJ " 
	cQuery += " WHERE " 
	cQuery += " ZBJ.D_E_L_E_T_ = '' " 
	
	If Select("DADOSZBJ") > 0
		DADOSZBJ->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "DADOSZBJ"
	
	DbSelectArea("DADOSZBJ")
	DADOSZBJ->(DbGoTop())
	
	While ! DADOSZBJ->(Eof())
		Aadd(aRetorno,{;
						DADOSZBJ->ZBJ_FILIAL,;
						DADOSZBJ->ZBJ_ANO,;
						DADOSZBJ->ZBJ_DESC,;
						DADOSZBJ->ZBJ_USUARI;
		})
		DADOSZBJ->(DbSkip())
		
	EndDo
	
	DbCloseArea("DADOSZBJ")

Return aRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณoperacao   บAutor  ณEverson         บData    ณ11/01/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCRUD.                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function operacao(nOpcx)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local dData
	Local i			:= 1
	Local aDadosCal	:= {}
	Local lEdtAno	:= .T.
	
	Private cFil	:= ""
	Private cUsuario:= ""
	Private nUsado	:= 0
	Private cTitulo := "Calendแrio"
	Private aHeader	:= {}
	Private aCols	:= {}
	Private aC		:= {}
	Private cAno	:= ""
	Private cDescCad:= Space(20)
	Private aAtivo	:= {}
	Private aR		:= {}
	Private aCGD	:= {}
	Private aGetsD	:= {"ZBJ_DTINIC","ZBJ_DTFIM","ZBJ_DENT"}
	Private cLinhaOk:= "AlwaysTrue()"
	Private cTudoOk := "AlwaysTrue()"
	Private aButtons:= {}
	Private lRetMod2:= .F.
	Private bValAno	:= {||vldAno(Alltrim(T_ZBJ->T_FILIAL),cAno)}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta aHeader.                                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aHeader := montarHeader(nOpcx)
	If Len(aHeader) == 0
		Return Nil
		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta aCols.                                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCols := {}//ontarAcols(nOpcx)
	//If Len(aCols) == 0
		//Return Nil
		
	//EndIf
	
	If nOpcx == 3
		
		cAno 	:= proxAno()
		cFil 	:= xFilial("ZBJ")
		cUsuario:= cUserName
		
		For i := 1 To Len(aPeriod)
		
			dData := CToD("01/" + Padl(cValToChar(i),2,"0") + "/" + cAno)
			
			Aadd(aCols,{;
						aPeriod[i],;
						FirstDate(dData),;
						LastDate(dData),;
						0,;
						.F.})
		
		Next i
	
	Else
		
		lEdtAno := .F.
		cFil	:= Alltrim(T_ZBJ->T_FILIAL) 
		cAno	:= Alltrim(T_ZBJ->T_ANO)
		cDescCad:= Alltrim(cValToChar(T_ZBJ->T_DESC)) + Space(Iif(20- Len(Alltrim(cValToChar(T_ZBJ->T_DESC))) < 0,0,20- Len(Alltrim(cValToChar(T_ZBJ->T_DESC)))))
		cUsuario:= T_ZBJ->T_USER
		
		aDadosCal := obtCalend(cFil,cAno)
		
		If Len(aDadosCal) == 0
			MsgStop("Nใo foi possํvel realizar a opera็ใo.","Fun็ใo operacao")
			Return Nil
			
		EndIf
		
		For i := 1 To Len(aDadosCal)
			
			Aadd(aCols,{;
						aDadosCal[i][4],;
						SToD(aDadosCal[i][5]),;
						SToD(aDadosCal[i][6]),;
						aDadosCal[i][7],;
						.F.})
		
			ZBJ->(DbSkip())
			
		Next i
	
	
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Array com os campos do cabecalho.                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Aadd(aC,{"cFil"    , {20,002}, "Filial: "     , "@!", "NaoVazio()",,.F.})
	Aadd(aC,{"cAno"    , {20,038}, "Ano: "        , "@!", "Eval(bValAno)",,lEdtAno})
	Aadd(aC,{"cDescCad", {20,116}, "Descri็ใo: "  , "@!", "",,.T.})
	Aadd(aC,{"cUsuario", {20,350}, "Usuแrio: "    , "@!", "",,.F.})
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Array com descri็๕es dos campos do rodap้ do Modelo 2.       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aR := {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Array com coordenadas da GetDados do Modelo 2.               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCGD := {60,5,118,315}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida็๕es na GetDados do Modelo 2.                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cLinhaOk	:=	""
	cTudoOk		:=	""
	
	//Aadd(aButtons,{"", {||metas()},"Metas"})
	
	DbSelectArea("T_ZBJ")
	lRetMod2 :=	Modelo2(cTitulo,aC,aR,aCGD,nOpcx,Nil,Nil,aGetsD,Nil,Nil,12,Nil,.F.,.T.,aButtons)
	
	If lRetMod2 .And. (nOpcx == 3 .Or. nOpcx == 4)
		MsAguarde({||grvDados(nOpcx,aCols,cFil,cValToChar(cAno),cDescCad)},"Aguarde...","Gravando dados...")
	
	ElseIf nOpcx == 5
		If	MsgYesNo("Deseja excluir o calendแrio?","Fun็ใo ")
			MsAguarde({||exclDados(cValToChar(cAno))},"Aguarde...","Excluindo calendแrio...")
			
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณproxAno     บAutor  ณEverson        บData    ณ11/01/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo retorna o pr๓ximo ano a ser criado o calendแrio.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function proxAno()

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cAno		:= ""
	Local cQuery	:= ""
	
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " MAX(ZBJ_ANO) AS ANO " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZBJ") + " AS ZBJ " 
	cQuery += " WHERE " 
	cQuery += " ZBJ.D_E_L_E_T_ = '' " 
	
	If Select("PROXANO") > 0
		PROXANO->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "PROXANO"
	DbSelectArea("PROXANO")
		cAno := Alltrim(cValToChar(PROXANO->ANO))
		
	DbCloseArea("PROXANO")
	
	If Empty(cAno)
		cAno := Alltrim(cValToChar(Year(Date())))
	
	Else
		cAno := cValToChar(Val(cAno) + 1)
		
	EndIf

Return cAno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณvldAno      บAutor  ณEverson        บData    ณ11/01/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o ano informado pelo usuแrio.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function vldAno(cFil,cAno)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:=  GetArea()
	
	cAno := Alltrim(cValToChar(cAno))
	
	If Empty(cAno)
		MsgStop("ษ necessแrio informar o ano.","Fun็ใo vldAno")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	DbSelectArea("ZBJ")
	ZBJ->(DbSetOrder(2))
	ZBJ->(DbGoTop())
	
	If ZBJ->(DbSeek(cFil + cAno))
		MsgStop("Jแ hแ cadastro de calendแrio para o ano informado.","Fun็ใo vldAno")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	RestArea(aArea)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobtCalend   บAutor  ณEverson        บData    ณ11/01/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObt้m dados de um calendแrio especํfico.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function obtCalend(cFil,cAno)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aRetorno	:= {}
	Local cQuery	:= ""
	
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ZBJ_FILIAL, ZBJ_ANO, ZBJ_DESC, ZBJ_PERIOD, ZBJ_DTINIC, ZBJ_DTFIM, ZBJ_DENT, ZBJ.D_E_L_E_T_ AS DEL, ZBJ.R_E_C_N_O_  AS RECNO " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZBJ") + " AS ZBJ " 
	cQuery += " WHERE " 
	cQuery += " ZBJ.D_E_L_E_T_ = '' " 
	cQuery += " AND ZBJ_FILIAL = '" + cFil + "' " 
	cQuery += " AND ZBJ_ANO = '" + cAno + "'  ORDER BY ZBJ_DTINIC " 
	
	If Select("CALENDARIO") > 0
		CALENDARIO->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "CALENDARIO"
	
	DbSelectArea("CALENDARIO")
	CALENDARIO->(DbGoTop())
	
	While ! CALENDARIO->(Eof())
	
		Aadd(aRetorno,{;
						CALENDARIO->ZBJ_FILIAL,;
						CALENDARIO->ZBJ_ANO,;
						CALENDARIO->ZBJ_DESC,;
						CALENDARIO->ZBJ_PERIOD,;
						CALENDARIO->ZBJ_DTINIC,;
						CALENDARIO->ZBJ_DTFIM,;
						CALENDARIO->ZBJ_DENT,;
						CALENDARIO->DEL,;
						CALENDARIO->RECNO;
		})
		
		CALENDARIO->(DbSkip())
		
	EndDo
		
	DbCloseArea("CALENDARIO")

Return aRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgrvDados   บAutor  ณEverson          บData    ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os dados na tabela ZBJ.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function grvDados(nOpcx,aDados,cFil,cAno,cDescCad)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local i				:= 1
	Local lNvReg		:= .T.
	
	Begintran() 
		For i := 1 To Len(aDados)
			
			DbSelectArea("ZBJ")
			ZBJ->(DbSetOrder(2))
			ZBJ->(DbGoTop())
			
			lNvReg := .T.
			
			If nOpcx <> 3 .And. ZBJ->(DbSeek(cFil + cAno + Alltrim(cValToChar(aDados[i][1]))))
				lNvReg := .F.
				
			EndIf
				
			RecLock("ZBJ",lNvReg)
				ZBJ->ZBJ_FILIAL := cFil
				ZBJ->ZBJ_ANO    := cValToChar(cAno)
				ZBJ->ZBJ_DESC	:= Alltrim(cValToChar(cDescCad))
				ZBJ->ZBJ_PERIOD := aDados[i][1]
				ZBJ->ZBJ_DTINIC := aDados[i][2]
				ZBJ->ZBJ_DTFIM  := aDados[i][3]
				ZBJ->ZBJ_DENT   := aDados[i][4]
				ZBJ->ZBJ_USUARI	:= cUserName
			MsUnlock()
		
		Next i
		
		lNvReg := .T.
	
		If nOpcx <> 3
			lNvReg := .F.
			
		EndIf
		
		DbSelectArea("T_ZBJ")
		RecLock("T_ZBJ",lNvReg)
			T_ZBJ->T_FILIAL := cFil
			T_ZBJ->T_ANO	:= cAno
			T_ZBJ->T_DESC	:= Alltrim(cValToChar(cDescCad))
			T_ZBJ->T_USER	:= cUserName
		MsUnlock()
	
	EndTran()
	
	_oObj := GetObjBrow()
	_oObj:Default()
	_oObj:Refresh()
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณexclDados   บAutor  ณEverson         บData    ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os dados na tabela ZBJ.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function exclDados(cAno)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBJ")
	ZBJ->(DbSetOrder(2))
	ZBJ->(DbGoTop())
	If ! ZBJ->(DbSeek(cFil + cValToChar(cAno)))
		MsgStop("Nใo foi possํvel excluir o calendแrio.","Fun็ใo operacao")
		Return Nil
		
	EndIf
	
	While ! ZBJ->(Eof()) .And. ZBJ->ZBJ_FILIAL == cFil .And. ZBJ->ZBJ_ANO == cValToChar(cAno)
		RecLock("ZBJ",.F.)
			ZBJ->(DbDelete())
		MsUnlock()
		
		ZBJ->(DbSkip())
		
	EndDo
	
	DbSelectArea("T_ZBJ")
	RecLock("T_ZBJ",.F.)
		DbDelete()
	MsUnlock()
	
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimpCSV   บAutor  ณEverson            บData    ณ11/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para importar calendแrio via CSV.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function impCSV()

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Define MsDialog oTxtTela Title OemToAnsi("impCSV - Importa็ใo de Calendแrio") From 20, 1 To 271, 345 COLORS 0, 16777215 Pixel Style 128
	
		@ 010,005 Say " Rotina para importa็ใo de calendแrios de entrega. "
		@ 024,005 Say " As dados do arquivo devem estar separados por ';' . "
		@ 038,005 Say " Deseja prosseguir?"
		
		@ 105,110 BMPBUTTON TYPE 01 Action (Processa({||lerArquivo(oTxtTela)}))
		@ 105,140 BMPBUTTON TYPE 02 Action Close(oTxtTela)
	
	Activate Dialog oTxtTela Centered

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlerArquivo   บAutor  ณEverson        บData    ณ11/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo efetua leitura do arquivo txt.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function lerArquivo(oTxtTela)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cTipo    		:= "Todos(*.*) |*.* | " 
	Local nBytes		:= 0
	Local nTamArquivo	:= 0
	Local nTotLinhas	:= 0
	Local nTamLin		:= 0
	Local aBuffer		:= {}
	Local aAno			:= {}
	Local i				:= 0
	Local nPos			:= 0
	
	Private _cArq
	Private nHdl
	
	//Obt้m arquivo.
	_cArq := cGetFile( cTipo , "lerArquivo - Selecione o arquivo")
	
	//Valida arquivo.  
	If Empty(_cArq)
       MsgStop( "Nใo foi possํvel obter o arquivo.","lerArquivo")
       Return Nil
       
    Endif
	     
	nHdl := FT_FUse(_cArq) // Abre o arquivo

	//Valida abertura do arquivo.
	If nHdl == -1
		MsgStop("Nใo foi possํvel abrir o arquivo " + Chr(13) + Chr(13) + _cArq,"Fun็ใo lerArquivo")
		Return Nil
		
	Endif
	
	FT_FGoTop()
	
	//Obt้m a quantidade de linhas.
	nTotLinhas := FT_FLastRec()
	
	//Valida quantidade de registros.
	If nTotLinhas <> 12
		MsgStop("Nใo foi possํvel efetuar a leitura do arquivo. Por favor, ้ necessแrio que o arquivo tenha a informa็ใo de todos os meses.","Fun็ใo lerArquivo")
		Return Nil
		
	EndIf

	//Atribui o tamanho da r้gua.
	ProcRegua(nTotLinhas)

	FT_FGoTop()
	
	//Percorre arquivo.
	While !FT_FEof()
	
		i++
		
		IncProc("Processando arquivo.")
		
		//L๊ linha.
		cLinha := FT_FReadLn() 
		
		//Transforma string em array.
		aDadosArq	:= StrToKarr(cLinha,";")
		
		//Verifica o tamanho do array e se todos os dados estใo preenchidos.
		If Len(aDadosArq) <> 5 .Or.  Empty(Alltrim(cValToChar(aDadosArq[1]))) .Or. Empty(Alltrim(cValToChar(aDadosArq[2]))) .Or.;
		 							 Empty(Alltrim(cValToChar(aDadosArq[3]))) .Or. Empty(Alltrim(cValToChar(aDadosArq[4]))) .Or.;
		 							 Empty(Alltrim(cValToChar(aDadosArq[5])))
		 							 
			MsgStop("Nใo foi possํvel efetuar a leitura do arquivo. Por favor, verifique a linha " + cValToChar(FT_FRecno()) + " do arquivo.","Fun็ใo lerArquivo")
			Return Nil
			
		EndIf

		//Valida o ano informado.
		if ! vldAno(xFilial("ZBJ"),Alltrim(cValToChar(aDadosArq[1])))
			Return Nil
			
		EndIf
		
		//Valida o m๊s informado.
		If aPeriod[i] <> Alltrim(cValToChar(aDadosArq[2]))
			MsgStop("Nใo foi possํvel efetuar a leitura do arquivo. Os meses devem estar ordenados no arquivo. Por favor, verifique a linha " + cValToChar(i) + " do arquivo.","Fun็ใo lerArquivo")
			Return Nil
			
		EndIf
		
		cAno := Alltrim(cValToChar(aDadosArq[1]))
		
		//Valida se o ano ้ o mesmo em todos registros.
		If Len(aAno) > 0 .And. Ascan(aAno,{|x| x[1] == cAno}) == 0
		
			MsgStop("O ano deve ser o mesmo para todos registros do arquivo. Por favor, verifique a linha " + cValToChar(i) + " do arquivo.","Fun็ใo lerArquivo")
			Return Nil
		
		EndIf
		
		Aadd(aAno,{cAno})
		
		//Salva no array.
		Aadd(aBuffer,{;
						Alltrim(cValToChar(aDadosArq[2])),;
						CToD(Alltrim(cValToChar(aDadosArq[3]))),;
						CToD(Alltrim(cValToChar(aDadosArq[4]))),;
						Val(aDadosArq[5]);
		})
		
		FT_FSkip()
		
	EndDo
	
	FT_Fuse()
	
	oTxtTela:End()
	
	grvDados(3,aBuffer,xFilial("ZBJ"),cAno,"Entreg. de " + cAno)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimpCal      บAutor  ณEverson         บData    ณ11/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprimir calendแrio.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function impCal()

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cFil			:= Alltrim(cValToChar(T_ZBJ->T_FILIAL))
	Local cAno			:= Alltrim(cValToChar(T_ZBJ->T_ANO))
	Local cDesc			:= Alltrim(cValToChar(T_ZBJ->T_DESC))
	Local aDados		:= {}
	Local oPrint
	Local oFCabecalho	:= TFont():New('Courier new',,-18,.T.)
	Local oFCabeSub		:= TFont():New('Courier new',,-16,.T.)
	Local oFTexto		:= TFont():New('Courier new',,-14,.T.)
	Local oFTextoExp	:= TFont():New('Courier new',,-14,.T.)
	Local nTotalPDV		:= 0
	Local nTotalSPDV	:= 0
	Local cPorc			:= ""
	
	//
	If Empty(cFil) .Or. Empty(cAno)
		Return Nil
		
	EndIf
	
	//Obt้m dados do relat๓rio.
	aDados := obtCalend(cFil,cAno)
	
	//
	If Len(aDados) == 0
		Return Nil
		
	EndIf

    //Monta objeto para impressใo.
    oPrint := TMSPrinter():New("impCal")

    //Define orienta็ใo da pแgina para Retrato.
    oPrint:SetPortrait()
    
    //Mostra janela de configura็ใo de impressใo.
    oPrint:Setup()

    //Inicia pแgina.
    oPrint:StartPage()            

    //Insere texto formatado.
    oFCabecalho:Bold := .T.
    oPrint:Say(100,200,"Calendแrio de Entregas - " + cAno + Iif(Empty(cDesc),""," | " + cDesc),oFCabecalho)
    
    //Imprime uma linha
    oPrint:Line(200,10,200,2600)
    
    nLinha := 300
    
    oFTextoExp:italic := .T.
    oPrint:Say(nLinha,200,"Calendแrio criado/alterado por: " + Alltrim(cValToChar(T_ZBJ->T_USER)),oFTextoExp)
    
    nLinha += 200
    
    oFCabeSub:Bold := .T.
    oPrint:Say(nLinha,200,"Perํodo",oFCabeSub)
	oPrint:Say(nLinha,550,"Dt. Inicial",oFCabeSub)
	oPrint:Say(nLinha,950,"Dt. Final",oFCabeSub)
	oPrint:Say(nLinha,1330,"Qtd. Dias de Entrega",oFCabeSub)
    
    nLinha += 100
    For i := 1 To Len(aDados)
    	oPrint:Say(nLinha,200,aDados[i][4],oFTexto)
    	oPrint:Say(nLinha,550,DToC(SToD(aDados[i][5])),oFTexto)
    	oPrint:Say(nLinha,950,DToC(SToD(aDados[i][6])),oFTexto)
    	oPrint:Say(nLinha,1330,cValToChar(aDados[i][7]),oFTexto)
    	
    	nLinha += 080
    	
    Next i
    
    nLinha += 300
    oPrint:Say(nLinha,200,"Gerado em: " + DToC(Date()) + " | " + cValToChar(Time()) + " -  Por: " + cUserName,oFTextoExp)
    
    // Termina a pแgina
    oPrint:EndPage()
                       
    // Mostra tela de visualiza็ใo de impressใo
    oPrint:Preview()
       
	MS_Flush() 
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmetas   บAutor  ณEverson             บData    ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetas diแrias definidas dentro do calendแrio.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function metas()

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aRetorno	:= {} 
	Local cQuery	:= ""
	Local cDtIni	:= DToS(aCols[n][2])
	Local cDtFim	:= DToS(aCols[n][3])

	If Empty(cDtIni) .Or. Empty(cDtFim)
		Return Nil
		
	EndIf
	
	cQuery += " SELECT " 
		cQuery += " ZZT_DATA,SUM(ZZT_VALOR) AS VALOR, SUM(ZZT_PESMET) AS PESO " 
	cQuery += " FROM " 
		cQuery += " " + RetSqlName("ZZT") + " AS ZZT " 
	cQuery += " WHERE " 
		cQuery += " ZZT.D_E_L_E_T_ = '' " 
		cQuery += " AND ZZT_DATA >= '" + cDtIni + "' " 
		cQuery += " AND ZZT_DATA <= '" + cDtFim + "' " 
	cQuery += " GROUP BY ZZT_DATA " 
	cQuery += " ORDER BY ZZT_DATA " 
	
	If Select("METAS_DIARIAS") > 0
		METAS_DIARIAS->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "METAS_DIARIAS"
	DbSelectArea("METAS_DIARIAS")
	METAS_DIARIAS->(DbGoTop())
	
	While ! METAS_DIARIAS->(Eof())
		
		Aadd(aRetorno,{;
						METAS_DIARIAS->ZZT_DATA,;
						METAS_DIARIAS->VALOR,;
						METAS_DIARIAS->PESO;
		})
		
		METAS_DIARIAS->(DbSkip())
		
	EndDo
	
	DbCloseArea("METAS_DIARIAS")
	
	If Len(aRetorno) == 0
		MsgStop("Nใo hแ dados a serem exibidos.","Fun็ใo metas")
		Return Nil
		
	EndIf
	
	telaMetas(aRetorno)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtelaMetas   บAutor  ณEverson         บData    ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe interface com os dados das metas.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function telaMetas(aDados)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oButton1
	Local oGet1
	Local nGet1 	:= 0
	Local oGet2
	Local nGet2 	:= 0
	Local oListBox1
	Local nListBox1 := 1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oMetas
	Local aHMetas	:= {}
	Local aColsMetas:= {}
	Local oDlg
	
	//Cria Header.
	Aadd(aHMetas,{"Data"	,"DATA"	,""	, 10,0,"","" ,"D","",""})
	Aadd(aHMetas,{"Valor"	,"VALOR","@E 999,999,999.99"	, 15,2,"","" ,"N","",""})
	Aadd(aHMetas,{"Volume"	,"VOL"	,"@E 999,999,999,999"	, 15,0,"","" ,"N","",""})

	Define MsDialog oDlg Title "Metas Diแrias" From 000, 000  To 450, 500 Colors 0, 16777215 Pixel Style 128
	
		@ 004, 010 Say oSay3 Prompt "Metas diแrias de " + cValToChar(ZBJ->ZBJ_PERIOD) Size 240, 013 Of oDlg Colors 0, 16777215 Pixel
		
		oMetas := MsNewGetDados():New(020,010,180,245,Nil,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oDlg,aHMetas,@aColsMetas)
		
		@ 192, 010 Say oSay1 Prompt "Total Valor" Size 060, 008 Of oDlg Colors 0, 16777215 Pixel
		@ 202, 010 MsGet oGet1 Var nGet1 Size 060, 015 Of oDlg Colors 0, 16777215 Pixel Picture "@E 999,999,999.99" When .F.
		
		@ 192, 080 Say oSay2 Prompt "Total Volume" Size 060, 008 Of oDlg Colors 0, 16777215 Pixel
		@ 202, 080 MsGet oGet2 Var nGet2 Size 060, 015 Of oDlg Colors 0, 16777215 Pixel Picture "@E 999,999,999,999" When .F.
		
		@ 202, 196 Button oButton1 PROMPT "Ok" Size 048, 015 Of oDlg Pixel Action(oDlg:End())
	
	oDlg:Activate(,,,.T.,{||.T.},,{|| cargaMetas(oMetas,aHMetas,aDados,oGet1,@nGet1,oGet2,@nGet2)})

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcargaMetas   บAutor  ณEverson        บData    ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega dados de metas.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cargaMetas(oMetas,aHMetas,aDados,oGet1,nGet1,oGet2,nGet2)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local i	:= 1
	
	oMetas:aCols := {}
	
	For i := 1 To Len(aDados)
	
		Aadd(oMetas:aCols, Array(Len(aHMetas)+1) )
		
		oMetas:aCols[Len(oMetas:aCols), Len(oMetas:aCols[1]) ] := .F.
		oMetas:aCols[Len(oMetas:aCols),Ascan(aHMetas,{|x| AllTrim(x[2]) == "DATA"	})] := SToD(cValToChar(aDados[i][1]))
		oMetas:aCols[Len(oMetas:aCols),Ascan(aHMetas,{|x| AllTrim(x[2]) == "VALOR" 	})] := Val(cValToChar(aDados[i][2]))
		oMetas:aCols[Len(oMetas:aCols),Ascan(aHMetas,{|x| AllTrim(x[2]) == "VOL" 	})] := Val(cValToChar(aDados[i][3]))
		
		nGet1 += aDados[i][2]
		nGet2 += aDados[i][3]
		
	Next i
	
	oGet1:Refresh()
	oGet2:Refresh()
	oMetas:Refresh()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmontarHeader   บAutor  ณEverson      บData    ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta cabeca็alho.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function montarHeader(nOpcx)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea() 
	Local aCabecalho:= {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Montando aHeader.                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	If ! SX3->(DbSeek("ZBJ"))
		MsgStop("Nใo foi possํvel montar o cabe็alho.","Fun็ใo montarHeader")
		Return aCabecalho
		
	EndIf

	While ! SX3->(Eof()) .And. (X3_ARQUIVO == "ZBJ")
	
		If (AllTrim(X3_CAMPO) = "ZBJ_PERIOD" .Or.;
		    AllTrim(X3_CAMPO) = "ZBJ_DTINIC" .Or.;
		    AllTrim(X3_CAMPO) = "ZBJ_DTFIM"  .Or.;
		    AllTrim(X3_CAMPO) = "ZBJ_DENT")  .And. X3USO(X3_USADO)
		   
			nUsado++
			Aadd(aCabecalho,{;
							AllTrim(x3_titulo), AllTrim(x3_campo), x3_picture,;
							x3_tamanho, x3_decimal," ",;
							x3_usado, x3_tipo, x3_arquivo, x3_context;
			})
			
		EndIf
		
		SX3->(DbSkip())
		
	EndDo

	RestArea(aArea)
	
Return aCabecalho
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmontarAcols    บAutor  ณEverson      บData    ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta grid.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function montarAcols(nOpcx)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local aGrid		:= {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณ Montando aCols                                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aGrid := Array(1,nUsado + 1)
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	
	If ! SX3->(DbSeek("ZBJ"))
		MsgStop("Nใo foi possํvel montar a grid.","Fun็ใo montarAcols")
		Return aGrid
		
	EndIf
	
	nUsado := 0
	
	While ! SX3->(Eof()) .AND. (X3_ARQUIVO == "ZBJ")
	
		If (AllTrim(X3_CAMPO) = "ZBJ_PERIOD" .Or.;
		    AllTrim(X3_CAMPO) = "ZBJ_DTINIC" .Or.;
		    AllTrim(X3_CAMPO) = "ZBJ_DTFIM"  .Or. AllTrim(X3_CAMPO) = "ZBJ_DENT") .And. X3USO(X3_USADO)
		    
				nUsado++
				
				If nOpcx == 3
					If X3_TIPO == "C"
						aGrid[1][nUsado] := Space(X3_TAMANHO)
						
					ElseIf x3_tipo == "N"
						aGrid[1][nUsado] := 0
						
					ElseIf x3_tipo == "D"
						aGrid[1][nUsado] := dDataBase
						
					ElseIf x3_tipo == "M"
						aGrid[1][nUsado] := ""
						
					Else
						aGrid[1][nUsado] := .F.
						
					EndIf
					
				EndIf

		EndIf
		
		SX3->(dbSkip())
		
	EndDo

	aGrid[1][nUsado + 1] := .F.
	
	RestArea(aArea)

Return aGrid
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณx3ComboBox     บAutor  ณEverson      บData    ณ10/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o conte๚do de um campo combobox.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033362.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function x3ComboBox(cCampo)

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local aArea		:= GetArea()
	Local cValores	:= ""
	 
	DbSelectArea('SX3')
	SX3->(DbSetOrder(2) )
	If SX3->(DbSeek( cCampo ) )
		cValores := X3CBox()
	
	EndIf
	
	RestArea(aArea)
 
Return cValores