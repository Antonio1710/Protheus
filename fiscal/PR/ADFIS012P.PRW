#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "Tbiconn.ch"
#Include "Fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADFIS012P   บAutor  ณEverson           บ Data ณ26/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณNotas Fiscais Espiใo.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADFIS012P() // U_ADFIS012P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Private bImp		:= {||impArq()}
	Private	bLeng		:= {||legenda()}
	Private bHist		:= {||impHist()}
	Private bProcStatus	:= {||statusProth(.F.)}
	Private bBxDoc		:= {||telBaixaDoc()}  // Everson - 24/02/2017. Chamado 033660.
	Private bRelDocBx	:= {||MsAguarde({||relDocBx()},"Aguarde","Imprimindo relat๓rio...")}     // Everson - 24/02/2017. Chamado 033660.
	Private bRelXml		:= {||relatXml()}     // Everson - 03/04/2017. Chamado 034911. 
	Private bDtProc		:= {||dtProc()}
	
	//
	MsAguarde({|| statusProth(.T.,2) },"Aguarde","Verificando registros sem status...") //Everson  - 29/08/2017. Chamado 036876.
	
	Private cCadastro	:= "Notas Fiscais Espiใo"
	Private	aCores		:= {}
	Private aRotina		:= {{"Visualizar"	  ,"AxVisual",0,2},;
							{"Legenda"   	  ,"Eval(bLeng)", 0, 5},;
							{"Import. Arq."   ,"Eval(bImp)",0,7},;
							{"Proc. Status"   ,"Eval(bProcStatus)",0,8},;
							{"Relat๓rio"      ,"U_ADFIS004R()",0,9},;
							{"Baixar Doc"     ,"Eval(bBxDoc)",0,10},;    // Everson  - 24/02/2017. Chamado 033660.
							{"Rel Doc Baixado","Eval(bRelDocBx)",0,11},; // Everson  - 24/02/2017. Chamado 033660.
							{"Rel Xml"        ,"Eval(bRelXml)",0,12}}   // Everson  - 03/04/2017. Chamado 034911.
							//{"Alt Dt Ini"     ,"Eval(bDtProc)",0,13}}    // Everson  - 28/08/2017. Chamado 036876.
							
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Notas Fiscais Espiใo.')
	
	Aadd(aCores,{"Empty(ZBK_STPROT)" ,"BR_BRANCO"})
	Aadd(aCores,{"ZBK_STPROT=='1'","BR_VERDE"})
	Aadd(aCores,{"ZBK_STPROT=='2'","BR_PINK"})
	Aadd(aCores,{"ZBK_STPROT=='3'","BR_VERMELHO"})
	Aadd(aCores,{"ZBK_STPROT=='4'","BR_AMARELO"})
	Aadd(aCores,{"ZBK_STPROT=='5'","BR_LARANJA"})
	Aadd(aCores,{"ZBK_STPROT=='6'","BR_AZUL"})
	Aadd(aCores,{"ZBK_STPROT=='7'","BR_CANCEL"})
	   
	Private cExprFilTop := " ZBK_FILIAL = '" + cFilAnt + "' "  //Everson - 04/07/2017. Chamado 036086.Removido filtro de notas baixadas.
	
	ChkFile("ZBK")
	
	SetKey(VK_F5, {||impArq()})
	
	DbSelectArea("ZBK")

	MBrowse(6,1,22,75,"ZBK",,,,,,aCores,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cExprFilTop)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlegenda     บAutor  ณEverson           บ Data ณ28/08/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera data inicial de processamento.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 036876.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function dtProc()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlegenda     บAutor  ณEverson           บ Data ณ30/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegenda.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function legenda()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Local cTitulo := "Legenda"
     Local aLegenda:= {}
     
     //1=Escriturado;2=Nao Est. e Canc.;3=Nao Escriturado;4=Valor divergente;5=Escrit. e Canc.;6=Filial incorreta;7=Doc baixado
     
     Aadd(aLegenda, {"BR_BRANCO"  ,"''-Status nใo definido"})
     Aadd(aLegenda, {"BR_VERDE"   ," 1-Escriturado"     })
     Aadd(aLegenda, {"BR_PINK"    ," 2-Nใo Est. e Canc."})
     Aadd(aLegenda, {"BR_VERMELHO"," 3-Nใo Escriturado" })
     Aadd(aLegenda, {"BR_AMARELO" ," 4-Valor divergente"})
     Aadd(aLegenda, {"BR_LARANJA" ," 5-Escrit. e Canc." })
     Aadd(aLegenda, {"BR_AZUL"    ," 6-Filial incorreta"})
     Aadd(aLegenda, {"BR_CANCEL"  ," 7-Doc baixado"})
     
     BrwLegenda("Legenda do Browse",cTitulo,aLegenda)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimpHist      บAutor  ณEverson          บ Data ณ31/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta arquivo hist๓rico do espiใo.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function impHist()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
		
	If ! MsgYesNo("Esta rotina deve ser utilizada apenas para importa็ใo do hist๓rico do log Espiใo referente เ versใo anteriror desta rotina. Deseja prosseguir?","Fun็ใo impHist")
		Return Nil
		
	EndIf
	
	Processa({||processaHist()},"Processando Hist๓rico","")
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocessaHist      บAutor  ณEverson     บ Data ณ31/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa hist๓rico do log do espiใo.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function processaHist()	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local cArq 			:= cGetFile('Arquivo txt|*.txt|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)
	Local nHdl
	Local nTotLinhas	:= 0
	Local cBuffer		:= ""
	Local aLinha		:= {}
	Local cTpDoc		:= ""

	Local cFil		:= ""
	Local cChave	:= ""
	Local cDoc		:= ""
	Local cSerie	:= ""
	Local cTipo		:= ""
	Local cEmissao	:= ""
	Local nValorDoc	:= 0
	Local cCNPJ		:= ""
	Local cNome		:= ""
	Local cInscrEst	:= ""
	Local cDtReceb	:= ""
	Local cSituacao	:= ""
	Local nND		:= 0

	//Valida arquivo.  
	If Empty(cArq)
       MsgStop( "Nใo foi possํvel obter o arquivo.","lerArquivo")
       Return Nil
       
    Endif
    
    nHdl := FT_FUse(cArq) // Abre o arquivo

	//Valida abertura do arquivo.
	If nHdl == -1
		MsgStop("Nใo foi possํvel abrir o arquivo " + Chr(13) + Chr(13) + cArq,"Fun็ใo lerArquivo")
		Return Nil
		
	Endif
	
	//
	FT_FGoTop()
	
	//Obt้m a quantidade de linhas.
	nTotLinhas := FT_FLastRec()-7

	//Atribui o tamanho da r้gua.
	ProcRegua(nTotLinhas)

	FT_FGoTop()
	
	FT_FSkip(7)	
	
	//Percorre arquivo.
	While !FT_FEof()
		
		//Converte de UTF8 para ANSI.
		cBuffer:= DecodeUTF8(FT_FReadln())
		
		//
		If "NF-e" $cBuffer
			cTpDoc := "1"
			
		ElseIf "CT-e" $cBuffer
			cTpDoc := "2"
			
		Else
			cTpDoc := "3"
			cBuffer := "|ND" + cBuffer
			nND++
			
		EndIf
		
		//Substitui as strings True e False.
		cBuffer := StrTran(cBuffer,"True","")
		cBuffer := StrTran(cBuffer,"False","")
		
		//Transforma a linha em vetor.
		aLinha := {}	
		aLinha := StrToKarr(cBuffer,'|')
		
		//
		cFil		:= Substr(cBuffer,At("#",cBuffer)+1,2)
		cChave		:= Alltrim(cValToChar(aLinha[2]))
		cDoc		:= Padl(Alltrim(cValToChar(aLinha[3])),9,"0")
		cSerie		:= Substr(Alltrim(cValToChar(aLinha[2])),23,3)
		cTipo		:= Alltrim(cValToChar(aLinha[4]))
		cEmissao	:= CToD(Alltrim(cValToChar(aLinha[5])))
		nValorDoc	:= Val(StrTran(Alltrim(cValToChar(aLinha[6])),",","."))
		cCNPJ		:= Alltrim(cValToChar(aLinha[7]))
		cNome		:= Alltrim(cValToChar(aLinha[8]))
		cInscrEst	:= Alltrim(cValToChar(aLinha[9]))
		cDtReceb	:= CToD(Alltrim(cValToChar(aLinha[10])))
		cSituacao	:= Alltrim(cValToChar(aLinha[11]))
		
		//Grava/atualiza o registro.
		gravarZBK(1,.F.,cFil,cChave,cTpDoc,cDoc,cSerie,cTipo,cEmissao,cDtReceb,nValorDoc,cCNPJ,cInscrEst,cNome,cSituacao,"","","")
		
		//Incrementa regua de processamento.
		IncProc("DOC " + cSerie + "/" + cDoc + " | CNPJ " + cCNPJ)

		FT_FSkip()

	EndDo
	
	//Atribui/altera status aos registros.
	statusProth(.T.)
	
	If nND > 0
		MsgAlert("Para " + cValToChar(nND) + " documentos, nใo foi possํvel determinar o tipo (NF-e ou CT-e). Estes estใo marcados como ND.","Fun็ใo processaHist")
		
	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimpCSV      บAutor  ณEverson           บ Data ณ26/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta็ใo de CSV.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function impArq()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea() 
	Local oTxtTela
	
	 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Define MsDialog oTxtTela Title OemToAnsi("impArq - Importa็ใo de Arquivo") From 20, 1 To 271, 345 COLORS 0, 16777215 Pixel Style 128
	
		@ 010,005 Say " Rotina para importa็ใo dos dados de . "
		@ 024,005 Say " documentos fiscais gerados pelo software Espiใo. "
		@ 038,005 Say " Deseja prosseguir?"
		
		@ 105,110 BMPBUTTON TYPE 01 Action (Processa({||lerArquivo(oTxtTela)},"Importando registros"))
		@ 105,140 BMPBUTTON TYPE 02 Action Close(oTxtTela)
	
	Activate Dialog oTxtTela Centered
	
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlerArquivo  บAutor  ณEverson           บ Data ณ27/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta arquivo texto.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
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
	
	Local cFil			:= ""
	Local cChave		:= ""
	Local cTipo			:= ""
	Local cTpDoc		:= ""
	Local cDoc			:= ""
	Local cSerie		:= ""
	Local cTipo			:= ""
	Local cEmissao		:= ""
	Local nValorDoc		:= ""
	Local cCNPJ			:= ""
	Local cNome			:= ""
	Local cInscrEst		:= ""
	Local cDtReceb		:= ""
	Local cSituacao		:= ""
	Local cFornece		:= ""
	Local cLojaFor		:= ""
	Local cRural		:= ""
	Local cStatusProt	:= ""
	Local lAtualiza
	Local cQuery		:= ""
	Local aDadosZBK		:= {}
	Local nND			:= 0
	
	Private _cArq
	Private nHdl
	Private oObj
		
	//Obt้m arquivo.
	_cArq := cGetFile('Arquivo txt|*.txt|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)
	
	//Valida arquivo.  
	If Empty(_cArq)
       MsgStop( "Nใo foi possํvel obter o arquivo.","lerArquivo")
       Return Nil
       
    Endif
    
    	//Valida o CNPJ na descri็ใo do arquivo.
	If ! ValidaFilial(_cArq)
		Return Nil
	
	EndIf
	     
	nHdl := FT_FUse(_cArq) // Abre o arquivo

	//Valida abertura do arquivo.
	If nHdl == -1
		MsgStop("Nใo foi possํvel abrir o arquivo " + Chr(13) + Chr(13) + _cArq,"Fun็ใo lerArquivo")
		Return Nil
		
	Endif
	
	oTxtTela:End()
	
	FT_FGoTop()
	
	//Obt้m a quantidade de linhas.
	nTotLinhas := FT_FLastRec()-7

	//Atribui o tamanho da r้gua.
	ProcRegua(nTotLinhas)

	FT_FGoTop()
	
	FT_FSkip(7)	
	
	//Percorre arquivo.
	While !FT_FEof()
		
		//Converte de UTF8 para ANSI.
		cBuffer:= DecodeUTF8(FT_FReadln())
		
		//Substitui as strings True e False.
		cBuffer := StrTran(cBuffer,"True","")
		cBuffer := StrTran(cBuffer,"False","")
		
		aLinha := StrToKarr(cBuffer,'|')

		//Everson - 03/05/2017. Chamado 034930.
		If "Resumo NF-e" $cValToChar(aLinha[1])
			cTpDoc := "1"
			
		ElseIf "Arquivo CT-e" $cValToChar(aLinha[1])
			cTpDoc := "2"
			
		Else
			cTpDoc := "3"
			cBuffer := "|ND" + cValToChar(aLinha[1])
			nND++
			
		EndIf
	
		If cTpDoc == "2"
		
			For i := 1 To 30
				cBuffer := StrTran(cBuffer,"||","|***|")	
			Next i
			
		EndIf

		//Transforma a linha em vetor.
		aLinha := {}	
		aLinha := StrToKarr(cBuffer,'|')
		
		//Everson - 02/05/2017. Chamado 034930.
		//Valida o CNPJ do tomador de servi็o.
		If cTpDoc == "2"
			
			If Alltrim(cValToChar(aLinha[9])) <> Alltrim(cValToChar(Substr(_cArq,At("6003705800",_cArq),14)))
				FT_FSkip()
				Loop
			
			EndIf
			
		EndIf
		
		cFil		:= xFilial()
		cChave		:= Alltrim(cValToChar(aLinha[2]))
		cDoc		:= Padl(Alltrim(cValToChar(aLinha[3])),9,"0")
		cSerie		:= Substr(Alltrim(cValToChar(aLinha[2])),23,3)
		
		If	cTpDoc == "2" //CT-e.
			cTipo		:= ""
			cEmissao	:= CToD(Alltrim(cValToChar(aLinha[4])))
			nValorDoc	:= Val(StrTran(Alltrim(cValToChar(aLinha[5])),",","."))
			cCNPJ		:= Alltrim(cValToChar(aLinha[6]))
			cNome		:= Alltrim(cValToChar(aLinha[7]))
			cInscrEst	:= Alltrim(cValToChar(aLinha[8]))
			cDtReceb	:= CToD(Alltrim(cValToChar(aLinha[16])))
			cSituacao	:= Alltrim(cValToChar(aLinha[17]))
			
		Else
			cTipo		:= Alltrim(cValToChar(aLinha[4]))
			cEmissao	:= CToD(Alltrim(cValToChar(aLinha[5])))
			nValorDoc	:= Val(StrTran(Alltrim(cValToChar(aLinha[6])),",","."))
			cCNPJ		:= Alltrim(cValToChar(aLinha[7]))
			cNome		:= Alltrim(cValToChar(aLinha[8]))
			cInscrEst	:= Alltrim(cValToChar(aLinha[9]))
			cDtReceb	:= CToD(Alltrim(cValToChar(aLinha[12]))) //Everson - 04/12/2017. Chamado 038425.
			cSituacao	:= Alltrim(cValToChar(aLinha[13])) //Everson - 04/12/2017. Chamado 038425.
		
		Endif
	
		//Verifica se o registro existe na tabela ZBK.
		lAtualiza	:= existeZBK(cChave)
		
		//Grava/atualiza o registro.
		gravarZBK(1,lAtualiza,cFil,cChave,cTpDoc,cDoc,cSerie,cTipo,cEmissao,cDtReceb,nValorDoc,cCNPJ,cInscrEst,cNome,cSituacao,cFornece,cLojaFor,cStatusProt)
		
		//Incrementa regua de processamento.
		IncProc("DOC " + cSerie + "/" + cDoc + " | CNPJ " + cCNPJ)

		FT_FSkip()

	EndDo
	
	//Atribui/altera status aos registros.
	statusProth(.T.)
	
	If nND > 0
		MsgAlert("Hแ " + cValToChar(nND) + " documentos em que nใo foi possํvel determinar o tipo (NF-e ou CT-e). Estes estใo marcados como ND","Fun็ใo processaHist")
		
	EndIf
	
	//Gera o relat๓rio.
	U_ADFIS004R()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidaFilial บAutor  ณEverson         บ Data ณ  28/10/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o arquivo pelo CNPJ na descri็ใo do arquivo         .บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 031508                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidaFilial(cArquivo)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local aArea		:= GetArea()
	Local cCNPJ		:= ""
	Local cFilArq	:= ""
	Local cFilNmArq	:= ""
	
	//Remove espa็os em branco.
	cArquivo	:= Alltrim(cValToChar(cArquivo))
	
	If Empty(cArquivo)
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//Obt้m o CNPJ no nome do arquivo.
	cCNPJ := Alltrim(cValToChar(Substr(cArquivo,At("6003705800",cArquivo),14)))
	
	DbSelectArea("SM0")
	SM0->(DbGoTop())
	
	While ! SM0->(Eof())
	
		If cCNPJ == Alltrim(cValToChar(SM0->M0_CGC))
			cFilArq 	:= Alltrim(cValToChar(SM0->M0_CODFIL))
			cFilNmArq	:= Alltrim(cValToChar(SM0->M0_NOME))
			Exit
			
		Endif
		
		SM0->(DbSkip())
		
	EndDo
	
	//Valida a filial recuperada.
	If Empty(cFilArq)
		MsgStop("Nใo foi possํvel localizar a filial referente ao CNPJ " + cCNPJ + ".","Fun็ใo ValidaFilial")
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	If cFilArq <> Alltrim(cValToChar(cFilAnt))
		MsgStop("O CNPJ informado no arquivo ้ referente เ filial " + cFilArq + "/" + cFilNmArq + "." + Chr(13) + Chr(10) + ;
				 "A filial corrente ้ a " + cFilAnt + ". Nใo serแ possํvel processar o arquivo.","Fun็ใo ValidaFilial")
		RestArea(aArea)
		Return .F.
			
	EndIf	
	
	RestArea(aArea)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณexisteZBK   บAutor  ณEverson           บ Data ณ27/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณlerArquivo.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function existeZBK(cChave)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 	
	Local aArea	:= GetArea()
	Local lRet	:= .T.
	
	DbSelectArea("ZBK")
	ZBK->(DbSetOrder(2))
	ZBK->(DbGoTop())
	If ! ZBK->(DbSeek(xFilial() + cChave))
		lRet := .F.
		
	EndIf
	DbCloseArea("ZBK")
	
	RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณstatusProth      บAutor  ณEverson      บ Data ณ30/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDetermina o status do documento no Protheus.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function statusProth(lAut,nOpc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aDadosZBK	:= {}
	Local cDtaIn	:= Alltrim(cValToChar(GetMv("MV_#DTIESP")))
	Local cPerg		:= "ADFIS012P"
	Local nOpcP		:= 0
	Local cDtIni	:= ""
	Local cDtFim	:= ""
	
	Default nOpc	:= 1
	
	//
	If nOpc == 1
	
		//
		ValidPerg(cPerg)
		If ! Pergunte(cPerg,.T.)
			RestArea(aArea)
			Return Nil
			
		EndIF
		
		//
		cDtIni	:= DToS(MV_PAR01)
		cDtFim	:= DToS(MV_PAR02)
		nOpcP 	:= Val(cValToChar(MV_PAR03))
		
		//
		cQuery := " SELECT ZBK_FILIAL, ZBK_CNPJ, ZBK_CHAVE, ZBK_DOC, ZBK_SERIE, ZBK_VALOR, ZBK_STATUS, ZBK_STPROT, ZBK_BAIXA "
		cQuery += " FROM " + RetSqlName("ZBK") + " (NOLOCK) AS ZBK WHERE ZBK.D_E_L_E_T_ = '' AND ZBK_FILIAL = '" + cFilAnt + "' AND ZBK_STPROT <> '1' "
		
		If nOpcP == 1 //Nใo considera nota baixada e autorizada.
			cQuery += " AND NOT (ZBK_STATUS IN ('Autorizada','Autorizada','CC-e') AND ZBK_BAIXA = 'X') "
		
		ElseIf nOpcP == 2 // Nใo considera nota baixada e cancelada.
			cQuery += " AND NOT (ZBK_STATUS IN ('Cancelada','Cancelado') AND ZBK_BAIXA = 'X') "
			
		ElseIf nOpcP == 3 // Nใo considera nota baixada.
			cQuery += " AND ZBK_BAIXA <> 'X' "
			
		EndIf
		
		cQuery += " AND ZBK_DATA >= '" + cDtIni + "' "
		cQuery += " AND ZBK_DATA <= '" + cDtFim + "' "
		cQuery += " ORDER BY ZBK_CNPJ, ZBK_DOC, ZBK_SERIE " //Everson - 04/07/2017. Chamado 036086. Considerar as notas baixadas na busca.
		
		
	Else //Everson  - 28/08/2017. Chamado 036876.
		cQuery := " SELECT ZBK_FILIAL, ZBK_CNPJ, ZBK_CHAVE, ZBK_DOC, ZBK_SERIE, ZBK_VALOR, ZBK_STATUS, ZBK_STPROT, ZBK_BAIXA "
		cQuery += " FROM " + RetSqlName("ZBK") + " (NOLOCK) AS ZBK WHERE ZBK.D_E_L_E_T_ = '' AND ZBK_FILIAL = '" + cFilAnt + "' AND ZBK_STPROT = '' ORDER BY ZBK_CNPJ, ZBK_DOC, ZBK_SERIE " //Everson - 04/07/2017. Chamado 036086. Considerar as notas baixadas na busca.
	
	EndIf
	
	//Verifica se o alias jแ existe.
	If Select("DADOSZBK") > 0
		DADOSZBK->(DbCloseArea())
		
	EndIf
	
	//Obt้m dados do BD.
	TcQuery cQuery New Alias "DADOSZBK"
	DbSelectArea("DADOSZBK")
	While ! DADOSZBK->(Eof())
		
		Aadd(aDadosZBK,{;
							DADOSZBK->ZBK_FILIAL,;
							DADOSZBK->ZBK_CNPJ,;
							DADOSZBK->ZBK_CHAVE,;
							DADOSZBK->ZBK_DOC,;
							DADOSZBK->ZBK_SERIE,;
							DADOSZBK->ZBK_VALOR,;
							DADOSZBK->ZBK_STATUS,;
							DADOSZBK->ZBK_STPROT,;
							DADOSZBK->ZBK_BAIXA;
		})
		
		DADOSZBK->(DbSkip())
	EndDo
	DbCloseArea("DADOSZBK")
	
	//Verifica retorno no BD.
	If Len(aDadosZBK) <= 0
		
		If nOpc == 1
			MsgInfo("Nใo hแ documentos a serem verificados.","Fun็ใo statusProth")
		
		EndIf
		
		Return Nil
		
	EndIf
	
	//
	If ! lAut .And. nOpc == 1
	
		If ! MsgYesNo("Serใo processados " + cValToChar(Len(aDadosZBK)) + " registros. Deseja prosseguir?","Fun็ใo statusProth")
			RestArea(aArea)
			Return Nil
						
		EndIf
		
	EndIf
	
	//Processa status.
	Processa({||processaStatus(aDadosZBK)},"Processando status","")
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณstatusProtheus   บAutor  ณEverson      บ Data ณ27/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDetermina o status do documento no Protheus.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function processaStatus(aDadosZBK)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local i				:= 1
	Local cQuery		:= ""
	Local cStatusProt	:= ""
	Local cFil			:= ""
	Local cCNPJ			:= ""
	Local cChave		:= ""
	Local cRural		:= ""
	Local cDoc			:= ""
	Local cSerie		:= ""
	Local nValor		:= 0
	Local cFornece		:= ""
	Local cLojaFor		:= ""
	Local cStatus		:= ""
	Local aStatusAlt	:= {}
	Local cLog			:= ""
	Local nReg			:= 0
	Local cBaixa		:= ""
	Local lChkCli		:= .F.
	
	//Atribui o tamanho da r้gua.
	ProcRegua(Len(aDadosZBK))
	
	For i := 1 To Len(aDadosZBK)
		
		cStatusProt	:= ""
		nReg 	:= 0
		cLog	:= ""
		cFil 	:= Alltrim(cValToChar(aDadosZBK[i][1]))
		cCNPJ	:= Alltrim(cValToChar(aDadosZBK[i][2]))
		cChave 	:= Alltrim(cValToChar(aDadosZBK[i][3]))
		cDoc	:= Alltrim(cValToChar(aDadosZBK[i][4]))
		cSerie	:= Alltrim(cValToChar(aDadosZBK[i][5]))
		nValor	:= Val(Alltrim(cValToChar(aDadosZBK[i][6])))
		cStaEsp	:= Alltrim(cValToChar(aDadosZBK[i][7]))
		cStatus	:= Alltrim(cValToChar(aDadosZBK[i][8]))
		cBaixa	:= Alltrim(cValToChar(aDadosZBK[i][9]))
		
		If Substr(cCNPJ,1,10) == "6003705800"
			
			If ! verifEntrada(cDoc,cSerie,cCNPJ)
				Loop
				
			EndIf
			
		EndIf

		
		//Incrementa regua de processamento.
		IncProc("DOC " + cSerie + "/" + cDoc  + " | CNPJ " + cCNPJ)
		
		cFornece:= Alltrim(cValToChar(Posicione("SA2",3,xFilial("SA2") + cCNPJ,"A2_COD")))
		cLojaFor:= Alltrim(cValToChar(Posicione("SA2",3,xFilial("SA2") + cCNPJ,"A2_LOJA")))
		cRural	:= Alltrim(cValToChar(Posicione("SA2",3,xFilial("SA2") + cCNPJ,"A2_TIPORUR")))
		
		If ! Empty(cRural) //Produtor rural.
		
			If Select("REL1") > 0
				REL1->(DbCloseArea())
				
			EndIf
		
			cQuery := SD1_M_Query(cFornece, cLojaFor,cDoc,cSerie)
			TcQuery cQuery New ALIAS "REL1"
			DbSelectArea("REL1")
			REL1->(DbGoTop())
			
			nReg := Val(cValToChar(Contar("REL1","!EOF()")))
		
		EndIf
		
		//
		If Empty(cRural) .Or. (! Empty(cRural) .And. nReg == 0)
		
			If Select("REL1") > 0
				REL1->(DbCloseArea())
				
			EndIf
			
			cQuery := SF3_M_Query(cChave,cDoc,cSerie)
			TcQuery cQuery New ALIAS "REL1"
			DbSelectArea("REL1")
			REL1->(DbGoTop())
			
		EndIf
		
		REL1->(DbGoTop())
		
		// Everson - 22/06/2017. Chamado 035870. Checa se hแ nota de entrada de cliente utilizando formulแrio pr๓prio.
		If REL1->(Eof()) 
			
			REL1->(DbCloseArea())
			cQuery :=  sqlFormProp(cCNPJ,cDoc,cSerie)
			TcQuery cQuery New ALIAS "REL1"
			DbSelectArea("REL1")
			REL1->(DbGoTop())
		
		EndIf
		//
	
		If REL1->(Eof())//Notas nใo encontradas na base do Protheus.
	
			If  cStaEsp == 'Cancelada' .Or.  cStaEsp == 'Cancelado'//Documentos cancelados, mas nใo escriturados.
				cStatusProt	:= "2"
					
			Else //cStaEsp == 'Autorizada' .Or. cStaEsp == 'Autorizado' .Or. cStaEsp == 'CC-e' //Documentos autorizados, mas nใo escriturados. //Everson - 28/08/2017. Chamado 036876.
				cStatusProt	:= "3"
					
			EndIf
		
		ElseIf (!REL1->(Eof()))//Documentos escriturados no Protheus.
	
			If Val(Alltrim(cValToChar(REL1->TOTAL))) <> nValor  //Documento com valor divergente.
				cStatusProt := "4"
				cLog		:= "Valor: " + Transform(Val(Alltrim(cValToChar(REL1->TOTAL))),"@E 999,999,999.00")
	
			ElseIf cStaEsp == 'Cancelada' .Or.  cStaEsp == 'Cancelado' //Documento escriturado, mas cancelado.
				cStatusProt := "5"
				
			ElseIf Alltrim(cValToChar(REL1->FILIAL)) <> Alltrim(cValToChar(cFilAnt)) //Documento escriturado em outra filial.
				cStatusProt	:= "6"
				cLog		:= "Filial: " + Alltrim(cValToChar(REL1->FILIAL))
				
			Else
				cStatusProt	:= "1"
				
			EndIf
			
		EndIf

		//Grava/atualiza o registro.
		If cStatusProt <> cStatus
			gravarZBK(2,.T.,cFil,cChave,,,,,,,,,,,cStaEsp,REL1->FORNECEDOR,REL1->LOJA,cStatusProt,cLog,cBaixa)

		EndIf
		
		REL1->(DbCloseArea())
	
	Next i	

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSD1_M_Query บAutor  ณEverson          บ Data ณ  27/01/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca dados da nota fiscal pelo Codigo do fornecedor.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 031508                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SD1_M_Query(cCodigo, cLoja, cNF, cSerie)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local	cQuery		:= ""	
	
	//Remove espa็os em branco.
	cCodigo	:= Alltrim(cValToChar(cCodigo))
	cLoja	:= Alltrim(cValToChar(cLoja))
	cNF		:= Alltrim(cValToChar(cNF))
	cSerie	:= Alltrim(cValToChar(cSerie))
	
	cNF		:= Padl(cNF,9,"0")
	cSerie	:= Padl(cSerie,3,"0")
	
	cQuery := " SELECT	'---' 			AS ENTRADA "
	cQuery += "			,D1_EMISSAO 	AS EMISSAO "
	cQuery += "			,D1_FORNECE 	AS FORNECEDOR "
	cQuery += "			,D1_LOJA 		AS LOJA "
	cQuery += "			,'---' 			AS CFO "
	cQuery += "			,D1_NFORI 		AS NOTA "
	cQuery += "			,D1_SERIORI 	AS SERIE "
	cQuery += "			,SUM(D1_TOTAL-D1_VALFUN) 	AS TOTAL "
	cQuery += "			,'---' 			AS OBSERV, D1_FILIAL AS FILIAL "
	cQuery += " FROM	" + RetSqlName("SD1") + " (NOLOCK) " 
	cQuery += " WHERE  "
	cQuery += "		RIGHT('000000000' + CAST(RTRIM(LTRIM(D1_NFRURAL)) AS VARCHAR),9) = '" + cNF + "' " 
	cQuery += "		AND RIGHT('000' + CAST(RTRIM(LTRIM(D1_SRRURAL)) AS VARCHAR),3) = '" + cSerie + "' "  
	cQuery += "		AND D1_FORNECE	= '" + cCodigo + "' "  
	cQuery += "		AND D1_LOJA		= '" + cLoja + "' "  
	cQuery += "		AND D_E_L_E_T_	<> '*'	"
	
	cQuery += " GROUP BY D1_EMISSAO,D1_FORNECE,D1_LOJA,D1_NFORI,D1_SERIORI,D1_FILIAL "
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSF3_M_Query บAutor  ณEverson           บData ณ  27/01/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca dados da nota fiscal pela chave de acesso.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 031508                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SF3_M_Query(cChave,cNF,cSerie)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local	cQuery		:= ""	
	
	//Remove espa็os em branco.
	cChave 	:= Alltrim(cValToChar(cChave))
	cNF		:= Alltrim(cValToChar(cNF))
	cSerie	:= Alltrim(cValToChar(cSerie))
	
	//Adiciona zeros a esquerda.
	cNF 	:= Padl(cNF,9,"0")
	cSerie	:= Padl(cSerie,3,"0")

	cQuery := " SELECT	F3_ENTRADA 		AS ENTRADA "
	cQuery += "			,F3_EMISSAO 	AS EMISSAO "
	cQuery += "			,F3_CLIEFOR 	AS FORNECEDOR "
	cQuery += "			,F3_LOJA 		AS LOJA "
	cQuery += "			,F3_NFISCAL 	AS NOTA "
	cQuery += "			,F3_SERIE 		AS SERIE "
	cQuery += "			,F3_FILIAL 		AS FILIAL, SUM(F3_VALCONT) AS TOTAL "
	cQuery += " FROM	" + RetSqlName("SF3") + " (NOLOCK) " 
	cQuery += " WHERE "
	cQuery += "		F3_CHVNFE		= '" + cChave + "' "  
	cQuery += "		AND D_E_L_E_T_	<> '*'	"
	cQuery += "		AND RIGHT('000000000'+ CAST(RTRIM(LTRIM(F3_NFISCAL)) AS VARCHAR),9) = '" + Alltrim(cValToChar(cNF)) + "' "
	cQuery += "		AND RIGHT('000'+ CAST(RTRIM(LTRIM(F3_SERIE)) AS VARCHAR),3) = '" + Alltrim(cValToChar(cSerie)) + "' "
	cQuery += "		AND F3_CFO < '5000' "
	cQuery += " GROUP BY F3_ENTRADA, F3_EMISSAO, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE, F3_FILIAL "
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgravarZBK   บAutor  ณEverson           บ Data ณ27/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os dados na tabela ZBK.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031508       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function gravarZBK(nOpc,lAtualiza,cFil,cChave,cTpDoc,cDoc,cSerie,cTipo,cEmissao,cDtReceb,nValorDoc,cCNPJ,cInscrEst,cNome,cSituacao,cFornece,cLojaFor,cStatusProt,cLog,cBaixa)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local aArea		:= GetArea()
	Local lNovo		:= Iif(lAtualiza,.F.,.T.)
	Local lMudaStat	:= .F.
	Local cQuery	:= ""
	Local nRecno	:= 0
	
	cFil   := Alltrim(cValToChar(cFil))
	cChave := Alltrim(cValToChar(cChave))
	cBaixa := Alltrim(cValToChar(cBaixa))
	
	//Verifica se ้ atualiza็ใo do registro.
	If lAtualiza
		
		cQuery := ""
		cQuery += " SELECT R_E_C_N_O_ AS REC " 
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZBK") + " (NOLOCK) AS ZBK  " 
		cQuery += " WHERE  " 
		cQuery += " ZBK.D_E_L_E_T_ = ''  " 
		cQuery += " AND ZBK_FILIAL = '" + cFil + "'  " 
		cQuery += " AND ZBK_CHAVE = '" + cChave + "' " 
		
		//
		If Select("D_CHAVE") > 0
			D_CHAVE->(DbCloseArea())
			
		EndIf
		
		TcQuery cQuery New Alias "D_CHAVE"
		DbSelectArea("D_CHAVE")
		D_CHAVE->(DbGoTop())
			
			nRecno := Val(cValToChar(D_CHAVE->REC))
		
		D_CHAVE->(DbCloseArea())
		
		
		If nRecno <= 0
			MsgStop("Nใo foi possํvel gravar o registro referente ao documento " + cValToChar(cChave) + ".","Fun็ใo gravarZBK")
			RestArea(aArea)
			Return Nil
			
		Else
			DbSelectArea("ZBK")
			ZBK->(DbGoTo(nRecno))
			
		EndIf
		
		//Verifica se hแ altera็ใo na situa็ใo do documento.
		If Alltrim(cValToChar(ZBK_STATUS)) <> Alltrim(cValToChar(cSituacao))
			lMudaStat := .T.
		
		EndIf
	
	EndIf
	
	//
	DbSelectArea("ZBK")

	//Cria/altera registro.
	If nOpc == 1 //Processamento do arquivo.
		//BeginTran()
			RecLock("ZBK",lNovo)
				ZBK->ZBK_FILIAL 	:= cFil
				ZBK->ZBK_CHAVE	:= cChave
				ZBK->ZBK_TPDOC	:= cTpDoc
				ZBK->ZBK_DOC		:= cDoc
				ZBK->ZBK_SERIE	:= cSerie
				ZBK->ZBK_TIPO	:= cTipo
				ZBK->ZBK_DATA	:= cEmissao
				ZBK->ZBK_DTRECE	:= cDtReceb
				ZBK->ZBK_VALOR	:= nValorDoc
				ZBK->ZBK_CNPJ	:= cCNPJ
				ZBK->ZBK_INSCES	:= cInscrEst
				ZBK->ZBK_NOME	:= cNome
				ZBK->ZBK_STATUS	:= cSituacao
				ZBK->ZBK_DTPROC	:= Date()
				ZBK->ZBK_HORA	:= Substr(cValToChar(Time()),1,8)
				ZBK->ZBK_USUARI	:= cUserName
				ZBK->ZBK_STPROT	:= Iif(lMudaStat,"",ZBK->ZBK_STPROT)
				
				If cStatusProt == "2" .And. Empty(cBaixa)
				
					ZBK->ZBK_BAIXA	:= "X"
					ZBK->ZBK_MOTBX1	:= "AUTOMATICO"
					ZBK->ZBK_DTBAIX	:= Date()
					ZBK->ZBK_HRBAIX	:= Substr(cValToChar(Time()),1,8)
					ZBK->ZBK_USBAIX	:= "AUTOMATICO"
					
				EndIF
				
			MsUnlock()
		//EndTran()
		
	Else //Defini็ใo do status do documento no Protheus.
		//BeginTran()
		RecLock("ZBK",lNovo)
			ZBK->ZBK_LOG	:= cLog
			ZBK->ZBK_STPROT	:= cStatusProt
			
			If cStatusProt == "2"
			
				ZBK->ZBK_BAIXA	:= "X"
				ZBK->ZBK_MOTBX1	:= "AUTOMATICO"
				ZBK->ZBK_DTBAIX	:= Date()
				ZBK->ZBK_HRBAIX	:= Substr(cValToChar(Time()),1,8)
				ZBK->ZBK_USBAIX	:= "AUTOMATICO"
				
			EndIF
			
		MsUnlock()
		//EndTran()
		
	EndIf
	
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณverifEntrada   บAutor  ณEverson        บ Data ณ02/02/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida nota formulแrio pr๓prio.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 031314       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function verifEntrada(cNota,cSerie,cCNPJ)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 	
	Local aArea		:= GetArea()
	Local cFil		:= ""
	Local cQuery	:= ""
	Local lRet		:= .T.
	
	//Remove espa็os em branco.
	cNota	:= Padl(Alltrim(cValToChar(cNota)),9,"0")
	cSerie	:= Padl(Alltrim(cValToChar(cSerie)),3,"0")
	cCNPJ	:= Alltrim(cValToChar(cCNPJ))
	
	DbSelectArea("SM0")
	SM0->(DbGoTop())
	
	While ! SM0->(Eof())
	
		If cCNPJ == Alltrim(cValToChar(SM0->M0_CGC))
			cFil := Alltrim(cValToChar(SM0->M0_CODFIL))
			
		Endif
		
		SM0->(DbSkip())
		
	EndDo
	
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " DISTINCT F1_DOC+F1_SERIE AS NOTA " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SF1") + " (NOLOCK) AS SF1 " 
	cQuery += " INNER JOIN " 
	cQuery += "  " + RetSqlName("SD1") + " (NOLOCK) AS SD1 " 
	cQuery += " ON F1_FILIAL = D1_FILIAL " 
	cQuery += " AND F1_DOC = D1_DOC " 
	cQuery += " INNER JOIN " 
	cQuery += "  " + RetSqlName("SA2") + " (NOLOCK) AS SA2 " 
	cQuery += " ON D1_FORNECE = A2_COD " 
	cQuery += " AND D1_LOJA = A2_LOJA " 
	cQuery += " WHERE  " 
	cQuery += " SF1.D_E_L_E_T_ = '' "
	cQuery += " AND F1_FILIAL = '" + cFil + "' "  
	cQuery += " AND SD1.D_E_L_E_T_ = '' " 
	cQuery += " AND SA2.D_E_L_E_T_ = '' " 
	cQuery += " AND RIGHT('000000000' + CAST(RTRIM(LTRIM(F1_DOC)) AS VARCHAR),9) = '" + cNota + "' " 
	cQuery += " AND RIGHT('000'+ CAST(RTRIM(LTRIM(F1_SERIE)) AS VARCHAR),3) = '" + cSerie + "' " 
	cQuery += " AND F1_FORMUL = 'S' " 
	cQuery += " AND D1_CF < 5000 " 
	cQuery += " AND D1_NFRURAL = '' " 
	cQuery += " AND A2_CGC LIKE '6003705800%' " 
	
	If Select("VERIFENT") > 0
		VERIFENT->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "VERIFENT"
	
	DbSelectArea("VERIFENT")
	
		If ! Empty(Alltrim(cValToChar(VERIFENT->NOTA)))
			lRet := .F.
			
		EndIf
	
	DbCloseArea("VERIFENT")
	
	RestArea(aArea)
	
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtelBaixaDoc       บAutor  ณEverson     บ Data ณ23/02/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela motivo de baixa Doc com diverg๊ncia.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033660.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function telBaixaDoc()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 	
	Local aArea		:= GetArea()
	Local oButton1
	Local oButton2
	Local oGet1
	Local cGet1 	:= Space(200)
	Local oSay1
	Static oDlg
	
	//Pedi confirma็ใo do usuแrio.
	If ! MsgYesNo("Deseja realizar a baixa do documento?","Fun็ใo telBaixaDoc")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Interface para apontar motivo da baixa do Doc.
	Define MsDialog oDlg TITLE "Motivo Baixa Doc" From 000, 000  TO 180, 395 COLORS 0, 16777215 Pixel Style 128
  	
  	@ 008, 004 Say oSay1 PROMPT "Por favor, informe o motivo da baixa do documento." SIZE 188, 013 Of oDlg COLORS 0, 16777215 Pixel
  	
    @ 030, 005 MSGET oGet1 Var cGet1 SIZE 188, 015 Of oDlg COLORS 0, 16777215 Pixel
    
    @ 063, 110 Button oButton1 Prompt "Ok" SIZE 037, 016 Of oDlg Pixel Action(baixaDoc(cGet1,oDlg))
    @ 063, 153 Button oButton2 Prompt "Cancelar" SIZE 037, 016 Of oDlg Pixel Action(oDlg:End())
    
    Activate MsDialog oDlg Centered
	
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณbaixaDoc       บAutor  ณEverson        บ Data ณ23/02/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBaixa Doc com diverg๊ncia.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033660.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function baixaDoc(cMotivo,oDlg)

	cMotivo := Alltrim(cValToChar(cMotivo))
	
	If Empty(cMotivo)
		MsgStop("ษ necessแrio informar o motivo de baixa do doc.","Fun็ใo baixaDoc")
		Return Nil
		
	EndIf
	
	oDlg:End()
	
	RecLock("ZBK",.F.)
		ZBK_BAIXA 	:= 'X'
		ZBK_MOTBX1	:= cMotivo
		ZBK_DTBAIX	:= Date()
		ZBK_HRBAIX	:= Substr(cValToChar(Time()),1,8)
		ZBK_USBAIX	:= cUserName
	MsUnlock()

	MsgInfo("Documento baixado.","Fun็ใo telBaixaDoc")

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrelDocBx       บAutor  ณEverson        บ Data ณ23/02/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelat๓rio de baixas de Doc com diverg๊ncia.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033660.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function relDocBx()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery		:= ""
	Local cQuery2		:= ""
	Local nNumReg		:= 0
	Local cBuffer		:= ""
	Local cRelName		:= "Relat๓rio Doc Baixados(Espiใo)"
	Local folder		:= "C:\temp\ "
	Local arq			:= "rel_docbx.html"
	Local nHandle	
	
	Local cPulaLin		:= Chr(13) + Chr(10)
	Local nNumExiste	:= 0
	Local nNumNExiste	:= 0
	Local nNumCancel	:= 0
	Local nNumEntOutFil	:= 0
	Local nNumCancEscrit:= 0
	Local nNumVlrDiverg	:= 0
	Local cCabecalho	:= ""
	
	Local cTpDoc		:= ""
	
	Local	cDtBaixa	:= ""
	Local	cUsrBaixa	:= ""
	Local	cMotBaixa	:= ""
	
	cQuery2 := ""
	cQuery2 += " SELECT  " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '' THEN 1 ELSE 0 END) AS  'B', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '2' THEN 1 ELSE 0 END) AS '_2', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '3' THEN 1 ELSE 0 END) AS '_3', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '4' THEN 1 ELSE 0 END) AS '_4', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '5' THEN 1 ELSE 0 END) AS '_5', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '6' THEN 1 ELSE 0 END) AS '_6' " 
	cQuery2 += " FROM " + RetSqlName("ZBK") + " (NOLOCK) AS ZBK  " 
	cQuery2 += " WHERE  " 
	cQuery2 += " ZBK.D_E_L_E_T_ = ''  " 
	cQuery2 += " AND ZBK_BAIXA = 'X'  " 
	cQuery2 += " AND ZBK_FILIAL = '" + xFilial("ZBK") + "' " 
	
	If Select("CABECALHO") > 0
		CABECALHO->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery2 New Alias "CABECALHO"
	
	DbSelectArea("CABECALHO")
	CABECALHO->(DbGoTop())
		nNumNExiste 	:= CABECALHO->_3
		nNumCancel		:= CABECALHO->_2
		nNumEntOutFil	:= CABECALHO->_6
		nNumCancEscrit	:= CABECALHO->_5
		nNumVlrDiverg	:= CABECALHO->_4

	//
	cQuery := "SELECT * FROM " + RetSqlName("ZBK") + " (NOLOCK) AS ZBK WHERE ZBK.D_E_L_E_T_ = '' AND ZBK_BAIXA = 'X' AND ZBK_FILIAL = '" + xFilial("ZBK") + "' ORDER BY ZBK_DTBAIX DESC, ZBK_DTPROC DESC, ZBK_CNPJ, ZBK_SERIE, ZBK_DOC "

	If Select("DADOSZBK") > 0
		DADOSZBK->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "DADOSZBK"
	DbSelectArea("DADOSZBK")
	DADOSZBK->(DbGoTop())
	nNumReg := Contar("DADOSZBK","!Eof()")
	
	//Atribui o tamanho da r้gua.
	ProcRegua(nNumReg)
	
	//Abre o arquivo HTML.
	nHandle	:= FCreate(Alltrim(folder)+arq, FC_NORMAL)
	If nHandle == -1      
		MsgStop('Erro de abertura de arquivo : ' + cPulaLin + 'FERROR ' + cValToChar(ferror(),4),"Fun็ใo Monta_HTML")	
		Return Nil
		  
	Endif   
	
	//Inํcio do HTML.
	cBuffer := ""
	cBuffer += "<html>"
	cBuffer += "<head><title>" + cRelName + "</title><head>"
	cBuffer += "<h1 align='center'><FONT FACE='times' SIZE='6'>" + cRelName + "</FONT></h1>"
	
	cBuffer += "<table>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2><b>Data de emissใo do relat๓rio: 	       </b></td><td align='LEFT'><font face='tahoma' size=2>"+DTOC(DATE())+"	</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2><b>Filial:			       				</b></td><td align='LEFT'><font face='tahoma' size=2>" + cFilAnt + "</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2><b>Relat๓rio emitido por:			                 </b></td><td align='LEFT'><font face='tahoma' size=2>" + cUserName + "			</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='red'><b>Nro Sem Entrada(S/E):	   </b></td><td align='LEFT'><font face='tahoma' size=2>" + cValToChar(nNumNExiste) + "		</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='purple'><b>Nro Canceladas(NC):   </b></td><td align='LEFT'><font face='tahoma' size=2>" + cValToChar(nNumCancel) + "</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='blue'><b>Nro Entrada em outra filial(Filial):	</b></td><td align='LEFT'><font face='tahoma' size=2>" +cValToChar(nNumEntOutFil) + "	</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='orange'><b>Nro Escriturado, mas cancelado(E/C): </b></td><td align='LEFT'><font face='tahoma' size=2>" + cValToChar(nNumCancEscrit) + "</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='yellow'><b>Nro Valor Divergente(V/D): </b></td><td align='LEFT'><font face='tahoma' size=2>" + cValToChar(nNumVlrDiverg) + "</td>"
	cBuffer += "</tr>"
	cBuffer += "</table>"	
	cBuffer += "<br/>"	
	
	cBuffer += "<table id='regProcessado' border=3 cellspacing=1 cellpadding=1 bordercolor='666633'>"
		cBuffer += "<tr><font face='tahoma' size=1>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Processamento				</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Tipo        			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Chave_Acesso			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Doc						</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>S้rie					</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Emissao					</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Total					</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Emitente_CNPJ			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Emitente_Nome			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Data_Recebimento		</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Situacao_NFE			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Obs.					</td>"
			
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Dt. Baixa				</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Usuแrio  				</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Mot Baixa				</td>"
		cBuffer += "</tr>"	

		//Grava no arquivo e limpa a variแvel para nใo dar estouro de variแvel (mแximo 1 MB).
		FWrite(nHandle, cBuffer + cPulaLin)  
		cBuffer := ""
		

	DADOSZBK->(DbGoTop())
	While ! DADOSZBK->(Eof())
	
		cCor := ""
		cObs := ""
		
		If     Alltrim(cValToChar(DADOSZBK->ZBK_TPDOC)) == "1"
			cTpDoc := "NF-e"
		
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_TPDOC)) == "2"
			cTpDoc := "CT-e"
			
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_TPDOC)) == "3"
			cTpDoc := "ND"
			
		EndIf
		
		cDataProc	:= DToC(SToD(cValToChar(DADOSZBK->ZBK_DTPROC)))
		cChave		:= Alltrim(cValToChar(DADOSZBK->ZBK_CHAVE))
		cSerie_cDoc	:= Alltrim(cValToChar(DADOSZBK->ZBK_SERIE + "/" + DADOSZBK->ZBK_DOC))
		cSerie		:= Alltrim(cValToChar(DADOSZBK->ZBK_SERIE))
		cDoc		:= Alltrim(cValToChar(DADOSZBK->ZBK_DOC))
		cEmissao	:= DToC(SToD(Alltrim(cValToChar(DADOSZBK->ZBK_DATA))))
		cValor		:= Transform(Val(Alltrim(cValToChar(DADOSZBK->ZBK_VALOR))),"@E 999,999,999.99")
		cCNPJ		:= Alltrim(cValToChar(DADOSZBK->ZBK_CNPJ))
		cNome		:= Alltrim(cValToChar(DADOSZBK->ZBK_NOME))
		cDtReceb	:= DToC(SToD(Alltrim(cValToChar(DADOSZBK->ZBK_DTRECE))))
		cSituacao	:= Alltrim(cValToChar(DADOSZBK->ZBK_STATUS))
		
		cDtBaixa	:= DToC(SToD(cValToChar(DADOSZBK->ZBK_DTBAIX)))
		cUsrBaixa	:= Alltrim(cValToChar(DADOSZBK->ZBK_USBAIX))
		cMotBaixa	:= Alltrim(cValToChar(DADOSZBK->ZBK_MOTBX1))
		
		If		Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '2'	//Nใo escriturado e cancelado.
			nNumCancel ++
			cObs := "NC"
			cCor := "purple"	
			
		ElseIf  Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '3' 	//Nใo escriturado.
			nNumNExiste ++
			cObs := "S/E"
			cCor := "red"
			
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '4' 	//Valor divergente.
			nNumVlrDiverg++
			cObs := "V/D"
			cCor := "yellow"
			
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '5'    //Escriturado, mas cancelado.
			nNumCancEscrit++
			cObs := "E/C"
			cCor := "orange"
			
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '6'   //Escriturado em filial incorreta.
			nNumEntOutFil++
			cObs := Alltrim(cValToChar(DADOSZBK->ZBK_LOG))
			cCor := "blue"		
			
		EndIf
		
		cBuffer += corpoTabela(cBuffer,cDataProc,cChave,cSerie,cDoc,cEmissao,cValor,cCNPJ,cNome,cDtReceb,cSituacao,cObs,cCor,cTpDoc,cDtBaixa,cUsrBaixa,cMotBaixa)
			
		FWrite(nHandle, cBuffer + cPulaLin)
		
		cBuffer := ""
		
		//Incrementa regua de processamento.
		IncProc("DOC " + cSerie_cDoc + " | CNPJ " + cCNPJ)
		
		DADOSZBK->(DbSkip())
		
	EndDo
	
	cBuffer += "</table>"	
	cBuffer += "<hr>"
	
	cBuffer += scriptCSV()
	cBuffer += "</body>"
	cBuffer += "</html>"

	FWrite(nHandle, cBuffer+cPulaLin)
	FClose(nHandle)
	
	Sleep(1500)
	
	MsAguarde({||shellExecute("Open", "C:\temp\rel_docbx.html", "NULL", "C:\",3)},"Aguarde","Abrindo relat๓rio...")

	MsgInfo("Processo finalizado.","Monta_HTML") 
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcorpoTabela บAutor  ณEverson          บ Data ณ  24/02/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Corpo da tabela.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033660                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function corpoTabela(cBuffer,cDataProc,cChave,cSerie,cDoc,cEmissao,cValor,cCNPJ,cNome,cDtReceb,cSituacao,cObs,cCor,cTpDoc,cDtBaixa,cUsuario,cMotivo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	

	cBuffer += "<tr><font face='tahoma' size=1>" 
		
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cDataProc     + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cTpDoc        + "	</td>"										
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cChave        + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cDoc   		 + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cSerie		 + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cEmissao      + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cValor        + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cCNPJ         + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cNome         + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cDtReceb      + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cSituacao     + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER; background-color:"   + cCor + "'>	"+ cObs +	"	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cDtBaixa     + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cUsuario     + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cMotivo      + "	</td>"
		
	cBuffer += "</tr>

Return cBuffer
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptCSV บAutor  ณEverson            บ Data ณ  25/10/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ JavaScript a ser adicionado na pแgina do relat๓rio        .บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fiscal                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptCSV()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 	
	Local cScript := ""
	
	cScript += " <script src='https://code.jquery.com/jquery-3.1.1.min.js' integrity='sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=' crossorigin='anonymous'></script> "
	cScript += " <script> "
	cScript += " function download(strData, strFileName, strMimeType) {var D = document, a = D.createElement('a');strMimeType= strMimeType || 'application/octet-stream'; "
	cScript += " if (navigator.msSaveBlob) {return navigator.msSaveBlob(new Blob([strData], {type: strMimeType}), strFileName);} "
	cScript += " if ('download' in a) { a.href = 'data:' + strMimeType + ',' + encodeURIComponent(strData); a.setAttribute('download', "
 	cScript += " strFileName); a.innerHTML = 'downloading...';D.body.appendChild(a); setTimeout(function() {a.click(); D.body.removeChild(a);}, 66);return true;} "
 	cScript += " var f = D.createElement('iframe'); "
    cScript += " D.body.appendChild(f); f.src = 'data:' +  strMimeType   + ',' + encodeURIComponent(strData);setTimeout(function() { D.body.removeChild(f);}, 333);return true;} "	
	cScript += " jQuery.fn.table2CSV = function(options){var options = jQuery.extend({separator: ';',header: [],headerSelector: 'th',columnSelector: 'td', "
	cScript += " delivery: 'popup',filename: 'poweredd_by_sinri.csv',transform_gt_lt: true},	options); "
	cScript += " var csvData = [];var headerArr = [];var el = this; "
	cScript += " var numCols = options.header.length;var tmpRow = []; "
	cScript += " if (numCols > 0){for (var i = 0; i < numCols; i++) {tmpRow[tmpRow.length] = formatData(options.header[i]);}"
	cScript += " } else {$(el).filter(':visible').find(options.headerSelector).each(function() {if ($(this).css('display') != 'none') tmpRow[tmpRow.length] = formatData($(this).html());});} "
	cScript += " row2CSV(tmpRow); "
	cScript += " $(el).find('tr').each(function() {var tmpRow = [];$(this).filter(':visible').find(options.columnSelector).each(function() { "
	cScript += " if ($(this).css('display') != 'none') tmpRow[tmpRow.length] = formatData($(this).html());});row2CSV(tmpRow);}); "
	cScript += " if (options.delivery == 'popup') {var mydata = csvData.join('\n');if(options.transform_gt_lt){mydata=sinri_recover_gt_and_lt(mydata);} "
	cScript += " return popup(mydata);}"
	cScript += " else if(options.delivery == 'download') {var mydata = csvData.join('\n');if(options.transform_gt_lt){mydata=sinri_recover_gt_and_lt(mydata);} "
	cScript += " var url='data:text/csv;charset=utf8,' + encodeURIComponent(mydata);	window.open(url);	return true;} "
	cScript += " else {var mydata = csvData.join('\n');if(options.transform_gt_lt){mydata=sinri_recover_gt_and_lt(mydata);}return mydata;} "
	cScript += " function sinri_recover_gt_and_lt(input){var regexp=new RegExp(/&gt;/g);var input=input.replace(regexp,'>'); "
	cScript += " var regexp=new RegExp(/&lt;/g);var input=input.replace(regexp,'<');	return input;} "
	cScript += " function row2CSV(tmpRow) {var tmp = tmpRow.join(''); if (tmpRow.length > 0 && tmp != '') {	var mystr = tmpRow.join(options.separator); "
	cScript += " csvData[csvData.length] = mystr;	}} "
	cScript += " function formatData(input) {
	cScript += " var regexp = new RegExp(/[']/g); "
	cScript += " var output = input.replace(regexp, '“'); "
	cScript += " var regexp = new RegExp(/\<[^\<]+\>/g); "
	cScript += " var output = output.replace(regexp, ''); "
	cScript += " output = output.replace(/&nbsp;/gi,' '); "
	cScript += " if (output == '') return ''; "
	cScript += " return '"
	cScript += '"'
	cScript += " ' "
	cScript += " + output.trim() + '"
	cScript += '"'
	cScript += " '; } "
			
	cScript += " function popup(data) { "
	cScript += " var generator = window.open('', 'csv', 'height=400,width=600'); "
	cScript += " generator.document.write('<html><head><title>CSV</title>'); "
	cScript += " generator.document.write('</head><body >'); "
	cScript += " generator.document.write('<textArea cols=70 "
	cScript += ' rows=15 wrap="off" '
	cScript += " >'); "
	cScript += " generator.document.write(data); "
	cScript += " generator.document.write('</textArea>'); "
	cScript += " generator.document.write('</body></html>'); "
	cScript += " generator.document.close(); "
	cScript += " return true; "
	cScript += " } "
	cScript += " }; "
	
	cScript += " $(document).ready(function () { "
	
	cScript += " $('#regProcessado').each(function () { "
	cScript += " var $table = $(this); "
	cScript += " var $button = $"
	cScript += ' ("<button '
	cScript += " type='button'> "
	cScript += ' "); '
	cScript += ' $button.text("Exportar"); '
	cScript += " $button.insertBefore($table); "
	cScript += " $button.click(function () { "
	cScript += " var csv = $table.table2CSV({ "
	cScript += " delivery: 'value' "
	cScript += " }); "
	cScript += ' download(csv, "processado.csv", "text/csv");'
	cScript += " }); "
	cScript += " }); "
	
	cScript += " $('#regHistorico').each(function () { "
	cScript += " var $table = $(this); "
	cScript += " var $button = $"
	cScript += ' ("<button '
	cScript += " type='button'> "
	cScript += ' "); '
	cScript += ' $button.text("Exportar"); '
	cScript += " $button.insertBefore($table); "
	cScript += " $button.click(function () { "
	cScript += " var csv = $table.table2CSV({ "
	cScript += " delivery: 'value' "
	cScript += " }); "
	cScript += ' download(csv, "historico.csv", "text/csv"); '
	cScript += " }); "
	cScript += " }); "
	
	cScript += " }) "
		
	cScript += "</script>"
		
Return cScript
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrelatXml    บAutor  ณEverson           บ Data ณ03/04/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a leitura de arquivos xml e gera relat๓rio.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911       .                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function relatXml()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cDiretorio	:= ""
	Local aArquivos		:= {}
	Local nProcess		:= 0
	
	Private aStru		:= {}
	Private cNomTr1		:= ""
	Private cIndex		:= ""
	
	/*//Obt้m o diret๓rio.
	cDiretorio := cGetFile("*.XML", "Selecione o diret๓rio com os arquivos XML's",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	//Obt้m a lista de arquivos xml no diret๓rio.
	If ! Empty(Alltrim(cValToChar(cDiretorio)))
		aArquivos := listaDeArquivos(cDiretorio)
		
		If Len(aArquivos) <= 0
			Return Nil
			
		EndIf
		
	Else
		Return Nil
		
	EndIf
	
	//Solicita confirma็ใo do usuแrio.
	If ! MsgYesNo("Serแ(ใo) processado(s) " + cValToChar(Len(aArquivos)) + " arquivo(s). Deseja prosseguir?","Fun็ใo ")
		Return Nil
		
	EndIf
	
	//Cria arquivo temporแrio.
	aStru := {}
	Aadd(aStru,{"TM_DT"  	    , "C",010,0})	
	Aadd(aStru,{"TM_TPDOC"		, "C",004,0})
	Aadd(aStru,{"TM_CNPJ"  		, "C",014,0})
	Aadd(aStru,{"TM_NOTA" 		, "C",009,0})
	Aadd(aStru,{"TM_SERIE" 		, "C",003,0})
	Aadd(aStru,{"TM_NOME" 		, "C",060,0})
	Aadd(aStru,{"TM_CODPR"		, "C",010,0})
	Aadd(aStru,{"TM_PROD" 		, "C",030,0})
	Aadd(aStru,{"TM_EAN" 		, "C",015,0})
	Aadd(aStru,{"TM_CFOP" 		, "C",004,0})
	Aadd(aStru,{"TM_NCM" 		, "C",011,0})
	Aadd(aStru,{"TM_CHAVE" 		, "C",100,0})	
	Aadd(aStru,{"TM_TOTAL" 		, "N",014,2})
	Aadd(aStru,{"TM_STATUS" 	, "C",001,0})
	Aadd(aStru,{"TM_STNF" 	    , "C",060,0})
	Aadd(aStru,{"TM_BAIX" 	    , "C",001,0})
	
	//Cria arquivo temporแrio.
	cNomTr1 := CriaTrab(aStru)
	
	//Define arquivo de dados com แrea de trabalho disponํvel.
	DbUseArea(.T.,,cNomTr1,"TEMP",.F.,.F.)
	
	//Define o ํndice do arquivo temporแrio.
	cIndex   := "TM_CNPJ + TM_NOTA + TM_SERIE"
	
	//Cria ํndice no arquivo temporแrio.
	IndRegua("TEMP", cNomTr1, cIndex,,,"Criando ํndice..." )
	
	//Processa arquivos xml no diret๓rio especํficado.
	Processa({|| nProcess += processaArq(cDiretorio,aArquivos)},"Aguarde","Processando arquivos...")
	*/
	//Se houve arquivos processados, gera o relat๓rio.
	//If nProcess > 0
		//Gera o relat๓rio.
		
		//MsAguarde({||statusXmlDoc()},"Aguarde","Verificando status dos documentos.")
		MsAguarde({||gerarCSV()},"Aguarde","Gerando arquivo CSV.")
	
	//Else
		//MsgStop("Nใo hแ dados a serem exibidos.","Fun็ใo ")
		
	//EndIf
	
	//Fecha arquivo temporแrio.
	/*DbSelectArea("TEMP")
	TEMP->(DbCloseArea())
	
	//Apaga o arquivo temporแrio.
	fErase(cNomTr1 + '.*')*/
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlistaDeArquivos   บ Autor ณ Everson   บ Data ณ  14/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณObt้m a lista de arquivos xml no diret๓rio selecionado.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function listaDeArquivos(cDiretorio)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aFiles 	:= {}
  	Local nX	 	:= 1
  	Local nCount 	:= 0
	Local cArquivos	:= "*.XML"
	Local aArquivos	:= {}
	
	//Valida diret๓rio.
	If Empty(Alltrim(cValToChar(cDiretorio)))
		MsgStop("Diret๓rio nใo selecionado.","Fun็ใo listaDeArquivos")
		Return aArquivos
		
	EndIf
	
	//Obt้m informa็๕es dos arquivos no diret๓rio.
  	aFiles := Directory(cDiretorio+cArquivos)
	
	//Valida se hแ arquivo xml no diret๓rio especificado.
	If Len(aFiles) <= 0
		MsgStop("Nใo hแ arquivos xml no diret๓rio especificado.","Fun็ใo listaDeArquivos")
		Return aArquivos
		
	EndIf
	
	//Insere o nome do arquivo no vetor de retorno.
	nCount := Len(aFiles)
  	For nX := 1 to nCount 
		Aadd(aArquivos,{aFiles[nX,1]})
		
  	Next nX

Return aArquivos
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocessaArq       บ Autor ณ Everson   บ Data ณ  15/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณProcessa arquivos xml.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function processaArq(cDiretorio,aArquivos)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local i		:= 1
	Local aRet	:= {}
	Local oXml
	Local cXml	:= ""
	Local nRet	:= 0
	
	ProcRegua(Len(aArquivos))
	
	//Processa lista de arquivos.
	For i := 1 To Len(aArquivos)
		
		//Incrementa r้gua de processamento.
		IncProc(Alltrim(cValToChar(aArquivos[i][1])) + " | " + cValToChar(i))
		
		//Cria objeto xml.
		aRet := {}
		aRet := criaObjeto(cDiretorio,Alltrim(cValToChar(aArquivos[i][1])))
		
		//Salva Dados do objeto xml no arquivo temporแrio.
		If ValType(aRet) == "A"
		
			oXml := Nil
			cXml := ""
			
			oXml := aRet[1][1]
			cXml := aRet[1][2]
		
		   	nRet += obterDados(oXml,cXml,Alltrim(cValToChar(aArquivos[i][1])))
			     
		Endif
		
	Next i
	
Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcriaObjeto        บ Autor ณ Everson   บ Data ณ  15/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCria objeto xml.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function criaObjeto(cDir,Arq)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aRet		:= {}
	Local cError	:= ""
	Local cWarning  := ""
	Local oXml      := NIL
	Local cFile		:= cDir+Arq
	
	Local nHdl    	:= FOpen(cFile,0)
	Local nTamFile	:= 0
	Local cBuffer	:= ""
	
	//Valida a abertura do arquivo.
	If nHdl == -1

		If ! Empty(cFile)

			MsgAlert("O arquivo " + cFile + " nใo pode ser aberto.","Fun็ใo criaObjeto")

		Endif

		Return Nil

	Endif
	
	//Determina o tamanho do arquivo.
	nTamFile := FSeek(nHdl,0,2)
	
	//Retorna a posi็ใo inicial.
	FSeek(nHdl,0,0)
	
	cBuffer  := Space(nTamFile)               
	
	//L๊ o arquivo.
	FRead(nHdl,@cBuffer,nTamFile)
	
	//Fecha o arquivo.
	FClose(nHdl)
	
	//Cria objeto xml.
	oXml := XmlParser(cBuffer, "_", @cError, @cWarning)
	
	//Valida se foi criado o objeto.
	If ValType(oXml) != "O"
	     MsgStop(Arq + " - " + cError,"Fun็ใo criaObjeto")
	     Return Nil
	     
	Endif
	
	//Verifica erros.
	If ! Empty(cError)
		MsgStop(cError,"Fun็ใo criaObjeto")
		Return Nil
		
	EndIf
	
	//Verifica alertas.
	If ! Empty(cWarning)
		MsgStop(cWarning,"Fun็ใo criaObjeto")
		Return Nil
		
	EndIf
	
	Aadd(aRet,{oXml,cBuffer})
	
Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobterDados       บ Autor ณ Everson   บ Data ณ  15/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณObt้m os dados do objeto xml.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function obterDados(oDoc,cXml,cNomeArq)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oNF
	Local oCTE
	Local nPos1		:= 0
	Local nPos2		:= 0
	Local nPos3		:= 0
	Local nPos4		:= 0
	
	nPos1 := At("<nfeProc",cXml) 
	
	nPos2 := At("<NFe",cXml)   
	
	nPos3 := At("<cteProc",cXml) 
	
	nPos4 := At("<CTe",cXml) 
	
	If nPos1 > 0
		oNF := oDoc:_NFeProc:_NFe
		Return dadosNFE(oNF,oDoc)
		
	ElseIf nPos2 > 0
	 	oNF := oDoc:_NFe
	 	Return dadosNFE(oNF,oDoc)
	 	
	ElseIf nPos3 > 0
		oCTE := oDoc:_CTeProc:_CTe
		Return dadosCTE(oCTE,oDoc)
		
	ElseIf nPos4 > 0
		oCTE := oDoc:_CTe
		Return dadosCTE(oCTE,oDoc)
			
	Else
		MsgStop("Nใo ้ possํvel processar o arquivo " + cValToChar(cNomeArq) + ".","Fun็ใo obterDados")
		Return 0
		
	EndIf              

Return 0
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณdadosNFE          บ Autor ณ Everson   บ Data ณ  15/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณObt้m os dados da NF-e.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function dadosNFE(oNF,oDoc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cVersao	:= ""
	Local cChave	:= ""
	Local cDtEmiss	:= ""
	Local cCgc		:= ""
	Local cNumDoc	:= ""
	Local cSerie	:= ""
	Local cNome		:= ""
	Local cProd		:= ""
	Local cCFOP		:= ""
	Local nTotal	:= 0
	Local oDet
	Local nX 		:= 1
	Local oEmitente
	Local nRet		:= 0
	
	//Obt้m a versใo da NF-e.
	cVersao  := Alltrim(cValToChar(oNF:_InfNfe:_versao:TEXT))
	
	//Obt้m a data de emissใo, conforme a versใo da NF-e.
	If  cVersao == "2.00"
		cDtEmiss := oNF:_InfNfe:_ide:_dEmi:TEXT
	
	ElseIf cVersao == "3.10"
		cDtEmiss := Substr(Alltrim(cValToChar(oNF:_InfNfe:_ide:_dhEmi:TEXT)),1,10)
		
	Else
		MsgStop("Rotina nใo implementada para versใo " + cVersao + " da NF-e","Fun็ใo dadosNFE")
		Return nRet
		
	EndIf
	
	//Obt้m a chave do arquivo.
	cChave	:= Alltrim(cValToChar(oDoc:_NFeProc:_ProtNFe:_infProt:_chNFe:TEXT))

	//Obt้m o emitente.
	oEmitente  := oNF:_InfNfe:_Emit

	//Obt้m o CNPJ/CPF do emitente.
	cCgc 	:= AllTrim(IIf(Type("oEmitente:_CPF") == "U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))
	
	//Obt้m o nome do emitente.
	cNome	:= oEmitente:_xNome:TEXT
	
	//Obt้m o n๚mero da NF.
	cNumDoc	:= oNF:_InfNfe:_ide:_nNF:TEXT
	
	//Obt้m a s้rie da NF.
	cSerie	:= oNF:_InfNfe:_ide:_serie:TEXT
	
	//Converte o formato da data.
	cDtEmiss := cValToChar(StrTran(cDtEmiss,"-",""))
	cDtEmiss := DToC(SToD(cDtEmiss))
	
	//Obt้m os itens da NF-e.
	oDet := oNF:_InfNfe:_Det
	
	//
	If ValType(oDet) == "A" //Se hแ vแrios itens (array.).
	
		For nX := 1 To Len(oDet)
			//Grava dados no arquivo temporแrio.
			grvDados(cCgc,cNumDoc,cSerie,cNome,oDet[nX]:_Prod:_xProd:TEXT ,oDet[nX]:_Prod:_CFOP:TEXT,cValToChar(oDet[nX]:_Prod:_vProd:TEXT),cDtEmiss,"NF-E",;
					oDet[nX]:_Prod:_cProd:TEXT,oDet[nX]:_Prod:_cEAN:TEXT,oDet[nX]:_Prod:_NCM:TEXT,cChave)
			nRet++
			
		Next nX
		
	Else //Se hแ somente um item (objeto).
		grvDados(cCgc,cNumDoc,cSerie,cNome,oDet:_Prod:_xProd:TEXT ,oDet:_Prod:_CFOP:TEXT,cValToChar(oDet:_Prod:_vProd:TEXT),cDtEmiss,"NF-E",;
		         oDet:_Prod:_cProd:TEXT,oDet:_Prod:_cEAN:TEXT,oDet:_Prod:_NCM:TEXT,cChave)
		nRet++
		
	EndIf
	
Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณdadosCTE          บ Autor ณ Everson   บ Data ณ  02/04/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณObt้m dados do CT-e.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function dadosCTE(oCTE,oDoc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cVersao	:= ""
	Local cChave	:= ""
	Local cDtEmiss	:= ""
	Local cCgc		:= ""
	Local cNumDoc	:= ""
	Local cSerie	:= ""
	Local cNome		:= ""
	Local cProd		:= ""
	Local cCFOP		:= ""
	Local nTotal	:= 0
	Local oDet
	Local nX 		:= 1
	Local oEmitente
	Local nRet		:= 0
	
	//Obt้m a versใo da CT-e.
	cVersao  := Alltrim(cValToChar(oCTE:_InfCte:_versao:TEXT))
	
	//Obt้m a data de emissใo, conforme a versใo da CT-e.
	If  cVersao == "2.00"
		cDtEmiss := Substr(Alltrim(cValToChar(oCTE:_InfCte:_ide:_dhEmi:TEXT)),1,10)

	Else
		MsgStop("Rotina nใo implementada para versใo " + cVersao + " do CT-e","Fun็ใo dadosNFE")
		Return nRet
		
	EndIf
	
	//Obt้m a chave do arquivo.
	cChave	:= Alltrim(cValToChar(oDoc:_cteProc:_ProtCTe:_infProt:_chCTe:TEXT))
	
	//Obt้m o emitente.
	oEmitente  := oCTE:_InfCte:_Emit

	//Obt้m o CNPJ/CPF do emitente.
	cCgc 	:= AllTrim(IIf(Type("oEmitente:_CPF") == "U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))
	
	//Obt้m o nome do emitente.
	cNome	:= oEmitente:_xNome:TEXT
	
	//Obt้m o n๚mero da CT-e.
	cNumDoc	:= oCTE:_InfCte:_ide:_nCT:TEXT
	
	//Obt้m a s้rie da NF.
	cSerie	:= oCTE:_InfCte:_ide:_serie:TEXT
	
	//Converte o formato da data.
	cDtEmiss := cValToChar(StrTran(cDtEmiss,"-",""))
	cDtEmiss := DToC(SToD(cDtEmiss))

	grvDados(cCgc,cNumDoc,cSerie,cNome,oCTE:_InfCte:_ide:_natOp:TEXT,oCTE:_InfCte:_ide:_CFOP:TEXT,cValToChar(oCTE:_InfCte:_vPrest:_vTPrest:TEXT),cDtEmiss,"CT-E",;
	         "","","",cChave)
	nRet++

Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgrvDados          บ Autor ณ Everson   บ Data ณ  15/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGrava dados no arquivo temporแrio.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function grvDados(cCgc,cNumDoc,cSerie,cNome,cProduto,cCFOP,cValor,cDtEmiss,cTipoDoc,cCodProd,cEan,cNCM,cChave)

		DbSelectArea("TEMP")
		RecLock("TEMP",.T.)
			TEMP->TM_DT		:= cDtEmiss
			TEMP->TM_CNPJ 	:= cCgc
			TEMP->TM_TPDOC	:= cTipoDoc
			TEMP->TM_NOTA	:= cNumDoc
			TEMP->TM_SERIE	:= cSerie
			TEMP->TM_NOME	:= OEMToAnsi(cNome)
			TEMP->TM_CODPR	:= OEMToAnsi(cCodProd)
			TEMP->TM_PROD	:= OEMToAnsi(cProduto)
			TEMP->TM_EAN	:= cEan
			TEMP->TM_NCM	:= cNCM
			TEMP->TM_CFOP	:= cCFOP
			TEMP->TM_CHAVE	:= cChave
			TEMP->TM_TOTAL	:= Val(cValToChar(cValor))
		MsUnlock()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณstatusXmlDoc      บ Autor ณ Everson   บ Data ณ  27/04/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณVerifica o status do documento fiscal.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034891.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function statusXmlDoc()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cChave	:= ""
	Local cCNPJ		:= ""
	Local cFornece	:= ""
	Local cLojaFor	:= ""
	Local cRural	:= ""
	Local cQuery	:= ""
	Local nReg		:= 0
	Local cDoc		:= ""
	Local cSerie	:= ""
	Local cCNPJ		:= ""
	Local cStatus	:= ""
	Local cBaixa	:= ""
	Local cTpDoc	:= ""
	
	//Preenche o arquivo.
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	While ! TEMP->(Eof())
	
		cCNPJ   := Alltrim(cVAlToChar(TEMP->TM_CNPJ))
		cDoc    := Alltrim(cVAlToChar(TEMP->TM_NOTA))
		cSerie  := Alltrim(cVAlToChar(TEMP->TM_SERIE))
		
		cChave	:= Alltrim(cVAlToChar(TEMP->TM_CHAVE))
		
		//
		cTpDoc	:= Alltrim(cVAlToChar(TEMP->TM_TPDOC))
		
		//Everson - Chamado 035092. 15/05/2017.
		obtStNF(cChave,@cStatus,@cBaixa,cTpDoc)
		
		RecLock("TEMP",.F.)
			TEMP->TM_STNF := Alltrim(cValToChar(cStatus))
			//TEMP->TM_BAIX := Alltrim(cValToChar(cBaixa))
		MsUnlock()

		If Substr(cCNPJ,1,10) == "6003705800"
			
			If ! verifEntrada(cDoc,cSerie,cCNPJ)
				Loop
				
			EndIf
			
		EndIf
		
		cFornece:= Alltrim(cValToChar(Posicione("SA2",3,xFilial("SA2") + cCNPJ,"A2_COD")))
		cLojaFor:= Alltrim(cValToChar(Posicione("SA2",3,xFilial("SA2") + cCNPJ,"A2_LOJA")))
		cRural	:= Alltrim(cValToChar(Posicione("SA2",3,xFilial("SA2") + cCNPJ,"A2_TIPORUR")))
		
		If ! Empty(cRural) //Produtor rural.
			
			If Select("REL1") > 0
				REL1->(DbCloseArea())
				
			EndIf
		
			cQuery := SD1_M_Query(cFornece, cLojaFor,cDoc,cSerie)
			TcQuery cQuery New ALIAS "REL1"
			DbSelectArea("REL1")
			REL1->(DbGoTop())
			
			nReg := Val(cValToChar(Contar("REL1","!EOF()")))
		
		EndIf
		
		
		If Empty(cRural) .Or. (! Empty(cRural) .And. nReg == 0)
		
			If Select("REL1") > 0
				REL1->(DbCloseArea())
				
			EndIf
			
			cQuery := SF3_M_Query(cChave,cDoc,cSerie)
			TcQuery cQuery New ALIAS "REL1"
			DbSelectArea("REL1")
			REL1->(DbGoTop())
			
		EndIf
		
		REL1->(DbGoTop())
		If REL1->(Eof())//Notas nใo encontradas na base do Protheus.
		
			//Everson - 22/06/2017. Chamado 035870.
			If chkForProp(cCNPJ,cDoc,cSerie) //Checa se hแ nota de entrada de cliente utilizando formulแrio pr๓prio.
			
				RecLock("TEMP",.F.)
					TEMP->TM_STATUS := "S"
				MsUnlock()			
			
			Else
			
				RecLock("TEMP",.F.)
					TEMP->TM_STATUS := "N"
				MsUnlock()
			
			EndIf
			
		Else
		
			RecLock("TEMP",.F.)
				TEMP->TM_STATUS := "S"
			MsUnlock()
			
		EndIf
		
		TEMP->(DbSkip())
		
	EndDo
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobtStNF           บ Autor ณ Everson   บ Data ณ  15/05/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGera planilha excel.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 035092.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function obtStNF(cChave,cStatus,cBaixa,cTpDoc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	 := GetArea()	
	Local cQuery := ""
	
	//
	If cTpDoc == "NF-E"
		cQuery := " SELECT XML_STATF1 AS ZBK_STATUS FROM RECNFXML (NOLOCK) AS REC WHERE  XML_CHAVE ='" + cChave + "' AND D_E_L_E_T_ = '' "
	
	ElseIf cTpDoc == "CT-E"
		cQuery := " SELECT XML_STATF1 AS ZBK_STATUS FROM RECNFCTE (NOLOCK) AS RECCTE WHERE XML_CHAVE ='" + cChave + "' AND D_E_L_E_T_ = '' "
		
	EndIf
	
	//
	If Select("ST_XML") > 0
		ST_XML->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "ST_XML"
	DbSelectArea("ST_XML")
		cStatus := ST_XML->ZBK_STATUS
		//cBaixa  := ST_XML->ZBK_BAIXA
	DbCloseArea("ST_XML")
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgerarCSV         บ Autor ณ Everson   บ Data ณ  15/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGera planilha excel.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function gerarCSV()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cDir	:= cGetFile("Arquivo xml.", "Selecione o diret๓rio para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	Local cArq  := "DADOSXML"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl	:= 0
	Local cEof	:= Chr(13) + Chr(10)
	Local cLin	:= ""
	Local cQuery:= ""
	Local nRet  := 0
	Local cStatus := ""
	
	//
	If ! Pergunte("ADFIS012XM",.T.)
		Return Nil
		
	EndIf
	
	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil
		
	EndIf
	
	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)
	
	//Verifica se foi possํvel criar o arquivo.
	If nHdl == -1
    	MsgAlert("O Arquivo nใo " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Fun็ใo gerarCSV")
		Return Nil
		
	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " CAB.XML_EMISSA AS TM_DT, " 
	cQuery += " 'NF-E'         AS TM_TPDOC,  " 
	cQuery += " CAB.XML_EMIT   AS TM_CNPJ, " 
	cQuery += " RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9) AS TM_NOTA, " 
	cQuery += " LEFT(CAB.XML_NUMNF,3) AS TM_SERIE, " 
	cQuery += " CAB.XML_NOMEMT  AS TM_NOME, " 
	cQuery += " ITEM.XIT_CODNFE AS TM_CODPR, " 
	cQuery += " ITEM.XIT_DESCRI AS TM_PROD, " 
	cQuery += " ITEM.XIT_EANXML AS TM_EAN, " 
	cQuery += " ITEM.XIT_CFNFE  AS TM_CFOP, " 
	cQuery += " ITEM.XIT_NCM    AS TM_NCM, " 
	cQuery += " ITEM.XIT_CHAVE  AS TM_CHAVE, " 
	cQuery += " ITEM.XIT_TOTNFE AS TM_TOTAL "
	cQuery += " FROM RECNFXML (NOLOCK) AS CAB " 
	cQuery += " INNER JOIN " 
	cQuery += " RECNFXMLITENS (NOLOCK) AS ITEM ON " 
	cQuery += " XML_CHAVE = XIT_CHAVE " 
	cQuery += " WHERE  " 
	cQuery += " XML_KEYF1 = ''  " 
	cQuery += " AND XML_KEYRUR = '' "
	cQuery += " AND XML_CLIFOR = 'C'  " 
	cQuery += " AND XML_DEST = '60037058000301'  " 
	cQuery += " AND XML_EMISSA >= '" + DToS(MV_PAR01) + "' AND XML_EMISSA <= '" + DToS(MV_PAR02) + "' " 
	cQuery += " AND CAB.D_E_L_E_T_ = ''  AND ITEM.D_E_L_E_T_ = ''  " 
	cQuery += " ORDER BY CAB.XML_EMISSA, XML_EMIT, RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9) "
	
	If Select("TEMP1") > 0
		TEMP1->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "TEMP1"
	
	//Preenche o arquivo.
	DbSelectArea("TEMP1")
	TEMP1->(DbGoTop())
	
	cLin := "EMISSAO;CHAVE;TIPO DOC;CNPJ;DOC;SERIE;NOME;COD PROD;PRODUTO;EAN;NCM;CFOP;VALOR;ESCRITURADO;CANCELADO;" + cEof
	
	While ! TEMP1->(Eof())
		
		cStatus := "N"
		If !xConfCan(Alltrim(cValToChar(TEMP1->TM_CHAVE)),.F.)
			cStatus := "S"
			
		EndIf
		
		cLin += DToC(SToD(Alltrim(cValToChar(TEMP1->TM_DT)))) + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_CHAVE)) + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_TPDOC)) + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_CNPJ))  + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_NOTA))  + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_SERIE)) + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_NOME))  + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_CODPR)) + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_PROD))  + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_EAN))   + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_NCM))   + ";"
		cLin += Alltrim(cValToChar(TEMP1->TM_CFOP))  + ";"
		cLin += Transform(Val(cValToChar(TEMP1->TM_TOTAL)),"@E 999,999,999.99") + ";"
		cLin += "N"      + ";"
		cLin += cStatus  +";" + cEof
		
		FWrite(nHdl,cLin,Len(cLin))
		
		cLin := ""
		
		TEMP1->(DbSkip())
		
	EndDo
	
	//Fecha o arquivo.
	FClose(nHdl)
	
	//Tenta abrir o arquivo.
    nRet := ShellExecute("open", cArq, "", cDir, 1)
     
    //Se houver algum erro.
    If nRet <= 32
        MsgStop("Nใo foi possํvel abrir o arquivo " +cDirP+cNomeArqP+ ".","Fun็ใo gerarReenv")
        
    EndIf

Return Nil
/*/{Protheus.doc} xConfCan
@description 	Confere cancelamento da NF no espiao
@author 		Amedeo D. Paoli Filho
@version		1.0
@return			Nil
@type 			Function
/*/
Static Function xConfCan( cChave, lAlerta )
	Local aAreaAT	:= GetArea()
	Local aAreaC0	:= C00->( GetArea() )
	Local lRetorno	:= .T.
	
	Default lAlerta	:= .T.
	
	DbSelectarea("C00")
	C00->( DbSetorder(1) )
	If C00->( DbSeek( xFilial("C00") + cChave ) )
		If C00->C00_SITDOC == "3"
			lRetorno := .F.
			If lAlerta
				//Alert( "Nota " + C00->C00_NUMNFE + " S้rie " + C00->C00_SERNFE + " Cancelada, verifique o status no espiใo" )
			EndIf
		Else
			
			//Valida Manifestacao nao realizada / desconhecida
			If Alltrim( C00->C00_STATUS ) == "2"
				lRetorno := .F.
				If lAlerta
					//Alert( "Nota " + C00->C00_NUMNFE + " S้rie " + C00->C00_SERNFE + " com status de manifesta็ใo desconhecida, verifique espiใo" )
				EndIf
			ElseIf Alltrim( C00->C00_STATUS ) == "3"
				lRetorno := .F.
				If lAlerta
					//Alert( "Nota " + C00->C00_NUMNFE + " S้rie " + C00->C00_SERNFE + " com status de manifesta็ใo nใo realizada, verifique espiใo" )
				EndIf
			EndIf
			
		EndIf
	EndIf

	RestArea( aAreaC0 )
	RestArea( aAreaAT )
	
Return lRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณabreCSV           บ Autor ณ Everson   บ Data ณ  15/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAbre aquivo csv.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034911.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function abreCSV(cCaminho,cArquivo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	//Tenta abrir o arquivo.
    nRet := ShellExecute("open", cArq, "", cDir, 1)
     
    //Se houver algum erro.
    If nRet <= 32
        MsgStop("Nใo foi possํvel abrir o arquivo " +cDirP+cNomeArqP+ ".","Fun็ใo gerarReenv")
        
    EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณchkForProp        บ Autor ณ Everson   บ Data ณ  22/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCheca entrada por formulแrio pr๓prio (cliente).             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 035870.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function chkForProp(cCGC,cNota,cSerie)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	 := GetArea()
	Local cQuery := ""
	
	//
	cCGC 	:= Alltrim(cValToChar(cCGC))
	cNota	:= Padl(Alltrim(cValToChar(cNota)),9,"0")
	cSerie	:= Padl(Alltrim(cValToChar(cSerie)),3,"0")
	
	//
	cQuery  := sqlFormProp(cCGC,cNota,cSerie)
	
	//
	If Select("CHK_CLI") > 0
		CHK_CLI->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "CHK_CLI"
	DbSelectArea("CHK_CLI")
	CHK_CLI->(DbGoTop())
	
	//
	If ! CHK_CLI->(Eof())
		CHK_CLI->(DbCloseArea())
		RestArea(aArea)
		Return .T.
	EndIf
	
	CHK_CLI->(DbCloseArea())
	
	//
	RestArea(aArea)
	
Return .F.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsqlFormProp       บ Autor ณ Everson   บ Data ณ  22/03/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCheca entrada por formulแrio pr๓prio (cliente).             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 035870.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function sqlFormProp(cCGC,cNota,cSerie)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	 := GetArea()
	Local cQuery := ""
	
	//
	cCGC 	:= Alltrim(cValToChar(cCGC))
	cNota	:= Padl(Alltrim(cValToChar(cNota)),9,"0")
	cSerie	:= Padl(Alltrim(cValToChar(cSerie)),3,"0")
	
	//
	cQuery := ""
	cQuery += " SELECT   " 
	cQuery += " F3_ENTRADA  AS ENTRADA  " 
	cQuery += " ,F3_EMISSAO AS EMISSAO  " 
	cQuery += " ,F3_CLIEFOR AS FORNECEDOR " 
	cQuery += " ,F3_LOJA    AS LOJA  " 
	cQuery += " ,F3_NFISCAL AS NOTA  " 
	cQuery += " ,F3_SERIE   AS SERIE  " 
	cQuery += " ,F3_FILIAL  AS FILIAL, SUM(F3_VALCONT) AS TOTAL " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " SD1.* " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SD2") + " AS SD2 " 
	cQuery += " INNER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " SD1.D1_FILIAL, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_NFORI, SD1.D1_SERIORI, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_COD, SD1.D1_EMISSAO " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SD1") + " AS SD1 " 
	cQuery += " WHERE " 
	cQuery += " SD1.D_E_L_E_T_ = '' " 
	cQuery += " AND RIGHT('0000000000' + RTRIM(LTRIM(D1_NFRURAL)),9) = '" + cNota + "' " //Everson - 01/09/2017. Chamado 036962.
	cQuery += " AND RIGHT('000' + RTRIM(LTRIM(D1_SRRURAL)),3) = '" + cSerie + "'  "  //Everson - 01/09/2017. Chamado 036962.
	cQuery += " ) AS SD1 ON " 
	cQuery += " D2_FILIAL =  D1_FILIAL " 
	cQuery += " AND SD1.D1_NFORI = D2_DOC " 
	cQuery += " AND SD1.D1_SERIORI = D2_SERIE " 
	cQuery += " AND SD1.D1_COD = D2_COD " 
	cQuery += " WHERE " 
	cQuery += " SD2.D_E_L_E_T_ = '' " 
	cQuery += " ) " 
	cQuery += " AS FONTE   " 
	cQuery += " INNER JOIN   " 
	cQuery += " " + RetSqlName("SF3") + "  (NOLOCK) AS SF3   " 
	cQuery += " ON FONTE.D1_FILIAL = F3_FILIAL   " 
	cQuery += " AND D1_FORNECE = F3_CLIEFOR   " 
	cQuery += " AND D1_LOJA = F3_LOJA   " 
	cQuery += " AND D1_DOC = F3_NFISCAL   " 
	cQuery += " AND D1_SERIE = F3_SERIE   " 
	cQuery += " AND D1_EMISSAO = F3_EMISSAO   " 
	cQuery += " INNER JOIN " 
	cQuery += " (SELECT * FROM " + RetSqlName("SA1") + " AS SA1 WHERE SA1.D_E_L_E_T_ = '' AND A1_CGC = '" + cCGC + "') AS SA1 " 
	cQuery += " ON F3_CLIEFOR = SA1.A1_COD " 
	cQuery += " AND F3_LOJA = SA1.A1_LOJA " 
	cQuery += " GROUP BY F3_ENTRADA, F3_EMISSAO, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE, F3_FILIAL " 

	RestArea(aArea)
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg         บ Autor ณ Everson   บ Data ณ  05/09/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCria pergunta na SX1.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037007.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg(cPerg)
	
	//
	PutSX1(cPerg,"01","Emissใo de "         ,"Emissใo de ","Emissใo de " ,"mv_ch1","D",08,00,00 ,"G","","","","","mv_par01" ,"","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"02","Emissใo at้"         ,"Emissใo at้","Emissใo at้" ,"mv_ch2","D",08,00,00 ,"G","","","","","mv_par02" ,"","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"03","Nใo considera Baixa?","Baixa?"     ,"Baixa?"      ,"mv_ch3","N",01,00,01 ,"C","","","","","mv_par03" ,"Bx autorizada","Bx autorizada","Bx autorizada","","Bx cancelada","Bx cancelada","Bx cancelada","Todas Bx","Todas Bx","Todas Bx","Sem filtro Bx","Sem filtro Bx","Sem filtro Bx")

Return Nil