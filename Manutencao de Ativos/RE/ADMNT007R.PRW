#include "protheus.ch"
#include "topconn.ch"                           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ADMNT007R ³ Autor ³Mauricio - MDS Tec     ³ Data ³10/11/2017³±±                 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio projetos chamado 037857                           ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³USO       ³Adoro - Solicitacao Silvana Loberto                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³ Manutencao efetuada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ADMNT007R()
        
	Private cAliasAF8 := "" 
	Private cPerg     := "RELPROJ"
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio projetos chamado 037857')
	
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}
	
u_xPutSX1(cPerg,"01","Projeto De"          ,"Projeto De"          ,"Projeto De"          ,"mv_ch1","C",10,0,0,"G",""         ,"AF8","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
u_xPutSX1(cPerg,"02","Projeto Ate"         ,"Projeto Ate"         ,"Projeto Ate"         ,"mv_ch2","C",10,0,0,"G",""         ,"AF8","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")
	   
	Pergunte(cPerg,.F.)
	
	oReport := ReportDef(@cAliasAF8)                 
	oReport:PrintDialog()
   	
Return()

Static Function ReportDef(cAliasAF8)

	Local oReport
	Local oProjeto
	Local aOrdem := {}
	
	cAliasAF8 := "AF8"
	
	oReport := TReport():New("RELPROJ",OemToAnsi("Relatorio Projetos"), cPerg, ;
			   {|oReport| ReportPrint(cAliasAF8)},;
			   OemToAnsi(" ")+CRLF+;
			   OemToAnsi("")+CRLF+;
			   OemToAnsi("") )
	           oReport:SetLandscape()
	           
	//oReport:SetTotalInLine(.F.)            
	            
	oProjeto := TRSection():New(oReport, OemToAnsi("Projetos"),{"AF8"}, aOrdem /*{}*/, .F., .F.)
	//oProjeto:SetTotalInLine(.F.)
	
	TRCell():New(oProjeto,	"CODPRJ"	,"","PROJETO"/*Titulo*/         ,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"DESPRJ"  	,"","DESCRICAO"/*Titulo*/       ,/*Picture*/,150/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"DTCRIA"	,"","DATA CRIAÇÃO"/*Titulo*/    ,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"UNIDADE"	,"","UNIDADE"/*Titulo*/         ,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"INIPREV"	,"","INICIO PREVISTO"/*Titulo*/ ,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"FIMPREV"	,"","FIM PREVISTO"/*Titulo*/    ,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"PROJANT"	,"","PROJETO ANTERIOR"/*Titulo*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"ENCERRA"	,"","ENCERRADO"/*Titulo*/       ,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	
	//oProjeto:SetLineStyle()                                                    

Return(oReport)

Static Function ReportPrint(cAliasAF8)

	Local oProjeto  := oReport:Section(1)
	
	dbSelectArea("AF8")
	dbSetOrder(1)
	
	MakeSqlExpr(cPerg)
	
	oProjeto:BeginQuery()	
	
	BeginSql Alias cAliasAF8
SELECT *

FROM %table:AF8% AF8
	
WHERE AF8.AF8_FILIAL = %xFilial:AF8% AND 
			   AF8.AF8_PROJET >=%Exp:mv_par01% AND
			   AF8.AF8_PROJET <=%Exp:mv_par02% AND 
			   AF8.%NotDel%
		
		ORDER BY %Order:AF8%
				
	EndSql 
		
	oProjeto:EndQuery()
	
	dbSelectArea(cAliasAF8)
	(cAliasAF8)->(DbGoTop())
	
	Do While (cAliasAF8)->(!EOF())
		
		oReport:SetMeter((cAliasAF8)->(LastRec()))
		
		oProjeto:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
			
		//impressao propriamente dita....
		oProjeto:Cell("CODPRJ")	:SetBlock( {|| (cAliasAF8)->AF8_PROJET} )    
		oProjeto:Cell("DESPRJ")	:SetBlock( {|| (cAliasAF8)->AF8_DESCRI} )
		oProjeto:Cell("DTCRIA")	:SetBlock( {|| (cAliasAF8)->AF8_DATA} )    
		oProjeto:Cell("UNIDADE"):SetBlock( {|| Posicione("SX5",1,"02"+"_K"+(cAliasAF8)->AF8_XUNIDA,"X5_DESCRI")} )
		oProjeto:Cell("INIPREV"):SetBlock( {|| (cAliasAF8)->AF8_START} )    
		oProjeto:Cell("FIMPREV"):SetBlock( {|| (cAliasAF8)->AF8_FINISH} )
		oProjeto:Cell("PROJANT"):SetBlock( {|| (cAliasAF8)->AF8_XPROJA} )
		oProjeto:Cell("ENCERRA"):SetBlock( {|| IIF((cAliasAF8)->AF8_ENCPRJ == "1","Sim","Nao")} )    
			
		oProjeto:PrintLine()
		oReport:IncMeter()
		dbSelectArea(cAliasAF8)
		(cAliasAF8)->(DbSkip())
		
	Enddo
	
	oProjeto:Finish()
	
	(cAliasAF8)->(dbCloseArea())
                   
Return()
