#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADMNT009R � Autor � WILLIAM COSTA      � Data �  26/06/2018 ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio que gera grafico de tipos de analises de         ���
���          � solicita�oes de servi�os                                   ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAMNT - MANUTENCAO DE ATIVOS                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
 
User Function ADMNT009R()

    Local aArea       := GetArea()
    Local cNomeRel    := "rel_grafico_"+dToS(Date())+StrTran(Time(), ':', '-')
    Local cDiretorio  := GetTempPath()
    Local nLinCab     := 025
    Local nAltur      := 250
    Local nLargur     := 1050
    Local aRand       := {}
    Private cHoraEx    := Time()
    Private nPagAtu    := 1
    Private oPrintPvt
    //Fontes
    Private cNomeFont  := "Arial"
    Private oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
    Private oFontTit   := TFont():New(cNomeFont, , -20, , .T.)
    Private oFontSubN  := TFont():New(cNomeFont, , -17, , .T.)
    //Linhas e colunas
    Private nLinAtu    := 0
    Private nLinFin    := 820
    Private nColIni    := 010
    Private nColFin    := 550
    Private nColMeio   := (nColFin-nColIni)/2
    Private _cPerg     := "ADMNT009R"

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio que gera grafico de tipos de analises de solicita�oes de servi�os')
    
    u_xPutSx1(_cPerg,"01","Data de  ?" , "Data de  ?" , "Data de  ?" , "mv_ch1","D",8 ,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","")
	u_xPutSx1(_cPerg,"02","Data Ate ?" , "Data Ate ?" , "Data Ate ?" , "mv_ch2","D",8 ,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","")
	
	pergunte(_cPerg,.T.)
     
    //Criando o objeto de impress�o
    oPrintPvt          := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
    oPrintPvt:cPathPDF := GetTempPath()
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)
    oPrintPvt:StartPage()
     
    //Cabe�alho
    oPrintPvt:SayAlign(nLinCab, nColMeio-150, "Gr�fico Solicita��o de Servi�o ", oFontTit, 300, 20, RGB(0,0,255), PAD_CENTER, 0)
    nLinCab += 35
    nLinAtu := nLinCab
     
    //Se o arquivo existir, exclui ele
    If File(cDiretorio+"_grafico.png")
        FErase(cDiretorio+"_grafico.png")
    EndIf
     
    //Cria a Janela
    DEFINE MSDIALOG oDlgChar PIXEL FROM 0,0 TO nAltur,nLargur
        //Inst�ncia a classe
        oChart := FWChartBar():New()
          
        //Inicializa pertencendo a janela
        oChart:Init(oDlgChar, .T., .T. )
          
        //Seta o t�tulo do gr�fico
        oChart:SetTitle("Tipo de An�lise", CONTROL_ALIGN_CENTER)
        
        SqlTipos()
        While TRC->(!EOF())
         	
         	//Adiciona as s�ries, com as descri��es e valores
	        oChart:addSerie("Pendente"  , TRC->PENDENTE)
	        oChart:addSerie("Satisfa��o", TRC->SATISFACAO)
	        oChart:addSerie("Os Geradas", TRC->OS_GERADAS)
	        oChart:addSerie("Atendidas" , TRC->ATENDIDAS)
        	
	            
        	TRC->(dbSkip())
		ENDDO
		TRC->(dbCloseArea())
          
        //Define que a legenda ser� mostrada na esquerda
        oChart:setLegend( CONTROL_ALIGN_LEFT )
          
        //Seta a m�scara mostrada na r�gua
        oChart:cPicture := "@E 999,999,999,999,999.99"
          
        //Define as cores que ser�o utilizadas no gr�fico
        aAdd(aRand, {"084,120,164", "007,013,017"})
        aAdd(aRand, {"171,225,108", "017,019,010"})
        aAdd(aRand, {"207,136,077", "020,020,006"})
        aAdd(aRand, {"166,085,082", "017,007,007"})
          
        //Seta as cores utilizadas
        oChart:oFWChartColor:aRandom := aRand
        oChart:oFWChartColor:SetColor("Random")
          
        //Constr�i o gr�fico
        oChart:Build()
    ACTIVATE MSDIALOG oDlgChar CENTERED ON INIT (oChart:SaveToPng(0, 0, nLargur, nAltur, cDiretorio+"_grafico.png"), oDlgChar:End())
     
    oPrintPvt:SayBitmap(nLinAtu, nColIni, cDiretorio+"_grafico.png", nLargur/2, nAltur/1.6)
    nLinAtu += nAltur/1.6 + 3
     
    //Impress�o do Rodap�
    fImpRod()
     
    //Gera o pdf para visualiza��o
    oPrintPvt:Preview()
     
    RestArea(aArea)
Return(NIL)
 
/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Fun��o para impress�o do rodap�                              |
 *---------------------------------------------------------------------*/
 
Static Function fImpRod()
    Local nLinRod := nLinFin + 10
    Local cTexto  := ""
 
    //Linha Separat�ria
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, RGB(200, 200, 200))
    nLinRod += 3
     
    //Dados da Esquerda
    cTexto := "Relat�rio Gr�fico    |    "+dToC(dDataBase)+"     "+cHoraEx+"     "+FunName()+"     "+cUserName
    oPrintPvt:SayAlign(nLinRod, nColIni,    cTexto, oFontRod, 250, 07, , PAD_LEFT, )
     
    //Direita
    cTexto := "P�gina "+cValToChar(nPagAtu)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , PAD_RIGHT, )
     
    //Finalizando a p�gina e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return(NIL)

Static Function SqlTipos()

	Local cFilAtual := FWFILIAL("TQB")

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT (
			        SELECT COUNT(TQB_SOLICI) AS 'PENDENTE'
						FROM %Table:TQB% TQB WITH (NOLOCK)
					WHERE TQB_FILIAL    = %EXP:cFilAtual% 
						AND TQB_DTABER >= %EXP:MV_PAR01%
						AND TQB_DTABER <= %EXP:MV_PAR02%
						AND TQB_SOLUCA  = 'D'
						AND D_E_L_E_T_ <> '*') AS 'PENDENTE',
			
					(SELECT COUNT(TQB_SOLICI) AS 'SATISFACAO'
						FROM %Table:TQB% TQB WITH (NOLOCK)
					WHERE TQB_FILIAL    = %EXP:cFilAtual%
						AND TQB_DTABER >= %EXP:MV_PAR01%
						AND TQB_DTABER <= %EXP:MV_PAR02%
						AND TQB_SOLUCA  = 'E'
						AND TQB_PSAP   <> ''
						AND TQB_PSAN   <> ''
						AND D_E_L_E_T_ <> '*') AS 'SATISFACAO',
			
					(SELECT COUNT(TQB_SOLICI) AS 'OS_GERADAS'
						FROM %Table:TQB% TQB WITH (NOLOCK)
					WHERE TQB_FILIAL    = %EXP:cFilAtual%
						AND TQB_DTABER >= %EXP:MV_PAR01%
						AND TQB_DTABER <= %EXP:MV_PAR02%
						AND TQB_ORDEM  <> ''
						AND D_E_L_E_T_ <> '*') AS 'OS_GERADAS',
			
			
					(SELECT COUNT(TQB_SOLICI) AS 'ATENDIDAS'
						FROM %Table:TQB% TQB WITH (NOLOCK)
					WHERE TQB_FILIAL    = %EXP:cFilAtual%
						AND TQB_DTABER >= %EXP:MV_PAR01%
						AND TQB_DTABER <= %EXP:MV_PAR02%
						AND TQB_SOLUCA  = 'E'
						AND D_E_L_E_T_ <> '*') AS 'ATENDIDAS'
	EndSQl             
RETURN(NIL)