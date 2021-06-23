#include 'protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} User Function ADINFLIB
	Rotina para gravar log e colocar texto na consulta especifica SD1ORD
	@type  Function
	@author Fernando Sigoli 
	@since 06/07/17 
	@version version
	@history Chamado T.I - FERNANDO SIGOLI - 22/04/2020 - Comentado a funcao U_ADINF009P 
/*/    

#Define STR_PULA        Chr(13)+ Chr(10)

User Function GrLogZBE(dDate,cTime,cUser,cLog,cModulo,cRotina,cParamer,cEquipam,cUserRed)

Local aArea := GetArea()

//U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina padrao da TI')  //Chamado T.I - FERNANDO SIGOLI - 22/04/2020 - Comentado a funcao U_ADINF009P 

  //log de alteração de data de entrega	
  DbSelectArea("ZBE")
  If RecLock("ZBE",.T.)//incluido if para certificar que o registro foi travado em 23/08/2017 por Adriana 
	Replace ZBE_FILIAL 	WITH xFilial("ZBE")
  	Replace ZBE_DATA 	WITH dDate
  	Replace ZBE_HORA 	WITH cTime
  	Replace ZBE_USUARI	WITH UPPER(Alltrim(cUser))
  	Replace ZBE_LOG	    WITH ALLTRIM(cLog)
  	Replace ZBE_MODULO	WITH cModulo
  	Replace ZBE_ROTINA	WITH cRotina
  	Replace ZBE_PARAME  WITH ALLTRIM(cParamer)
  	Replace ZBE_EQUIPA  WITH UPPER(Alltrim(cEquipam))
  	Replace ZBE_USURED  WITH UPPER(Alltrim(cUserRed))
  	ZBE->(MsUnlock())    
  endif	

RestArea(aArea)

Return .T. 


/*/{Protheus.doc} User Function ConsultEspecif 
	O retorno da consulta é pública (__cRetorno) para ser usada em consultas específicas
	A consulta não pode ter ORDER BY, pois ele já é especificado em um parâmetro  
	@type  Function
	@author Daniel Atilio    
	@since 15/12/2016 
	@version version
/*/    
User Function ConsultEspecif(cConsSQLM, cRetorM, cAgrupM, cOrderM)

	Local aArea      := GetArea()
    Local nTamBtn    := 50
    Local oGrpPesqui
    Local oGrpDados
    Local oGrpAcoes
    Local oBtnConf
    Local oBtnLimp
    Local oBtnCanc   
    
    //Defaults
    Default cConsSQLM := ""
    Default cRetorM   := ""
    Default cOrderM   := ""
    
    //Privates
    Private cConsSQL  := cConsSQLM
    Private cCampoRet := cRetorM
    Private cAgrup    := cAgrupM
    Private cOrder    := cOrderM
    Private nTamanRet := 0
    Private aStruAux  := {}
    Private oMsNew
    Private aHeadAux := {}
    Private aColsAux := {}
    
    //Tamanho da janela
    Private nJanLarg := 0800
    Private nJanAltu := 0500
    
    //Gets e Dialog
    Private oDlgEspe
    Private oGetPesq, cGetPesq := Space(100)
    
    //Retorno
    Private lRetorn := .F.
    Public  __cRetorno := ""

    U_ADINF009P('ADINFLIBP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina padrao da TI')
     
    //Se tiver o alias em branco ou não tiver campos
    If Empty(cConsSQLM) .Or. Empty(cRetorM)
    
        MsgStop("SQL e / ou retorno em branco!", "Atenção")
        Return lRetorn
        
    EndIf
     
    //Criando a estrutura para a MsNewGetDados
    fCriaMsNew()
    __cRetorno := Space(nTamanRet)
     
    //Criando a janela
    DEFINE MSDIALOG oDlgEspe TITLE "Consulta de Dados" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
    
        //Pesquisar
        @ 003, 003 GROUP oGrpPesqui TO 025, (nJanLarg/2)-3 PROMPT "Pesquisar: "    OF oDlgEspe COLOR 0, 16777215 PIXEL
            @ 010, 006 MSGET oGetPesq VAR cGetPesq SIZE (nJanLarg/2)-12, 010 OF oDlgEspe COLORS 0, 16777215  VALID (fVldPesq())      PIXEL
         
        //Dados
        @ 028, 003 GROUP oGrpDados TO (nJanAltu/2)-28, (nJanLarg/2)-3 PROMPT "Dados: "    OF oDlgEspe COLOR 0, 16777215 PIXEL
            oMsNew := MsNewGetDados():New(    035,;                                        //nTop
                                                006,;                                        //nLeft
                                                (nJanAltu/2)-31,;                            //nBottom
                                                (nJanLarg/2)-6,;                            //nRight
                                                GD_INSERT+GD_DELETE+GD_UPDATE,;            //nStyle
                                                "AllwaysTrue()",;                            //cLinhaOk
                                                ,;                                            //cTudoOk
                                                "",;                                        //cIniCpos
                                                ,;                                            //aAlter
                                                ,;                                            //nFreeze
                                                999,;                                        //nMax
                                                ,;                                            //cFieldOK
                                                ,;                                            //cSuperDel
                                                ,;                                            //cDelOk
                                                oDlgEspe,;                                    //oWnd
                                                aHeadAux,;                                    //aHeader
                                                aColsAux)                                    //aCols                                   
            oMsNew:lActive := .F.
            oMsNew:oBrowse:blDblClick := {|| fConfirm()}
         
            //Populando os dados da MsNewGetDados
            fPopula()
         
        //Ações
        @ (nJanAltu/2)-25, 003 GROUP oGrpAcoes TO (nJanAltu/2)-3, (nJanLarg/2)-3 PROMPT "Ações: "    OF oDlgEspe COLOR 0, 16777215 PIXEL
        @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Confirmar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fConfirm())     PIXEL
        @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Limpar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fLimpar())     PIXEL
        @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*3)+12) BUTTON oBtnCanc PROMPT "Cancelar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fCancela())     PIXEL
         
        oMsNew:oBrowse:SetFocus()
    	
    //Ativando a janela
    ACTIVATE MSDIALOG oDlgEspe CENTERED
     
    RestArea(aArea)
Return lRetorn
 

/*/{Protheus.doc} User Function fCriaMsNew
	Função para criar a estrutura da MsNewGetDados  
	@type  Function
	@author Daniel Atilio  
	@since 15/12/2016 
	@version version
/*/    

Static Function fCriaMsNew()

    Local aAreaX3 := SX3->(GetArea())
    Local cQuery  := ""
    Local nAtual  := 0
 
    //Zerando o cabeçalho e a estrutura
    aHeadAux := {}
    aColsAux := {}
     
    //Monta a consulta e pega a estrutura
    cQuery := cConsSQL
     
    //Group By
    If !Empty(cAgrup)
    
        cQuery += cAgrup + STR_PULA
        
    EndIf
     
    //Order By
    cQuery += " ORDER BY "    + STR_PULA
    
    If !Empty(cOrder)
    
        cQuery += "   "+cOrder
        
    Else
    
        cQuery += "   "+cCampoRet
        
    EndIf
    
    TCQuery cQuery New Alias "QRY_DAD"
    
    aStruAux := QRY_DAD->(DbStruct())
    
    QRY_DAD->(DbCloseArea())
     
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2)) // Campo
    SX3->(DbGoTop())
     
    //Percorrendo os campos
    For nAtual := 1 To Len(aStruAux)
        cCampoAtu := aStruAux[nAtual][1]
     
        //Se coneguir posicionar no campo
        If SX3->(DbSeek(cCampoAtu))
        
            //Cabeçalho ...    Titulo        Campo        Mask                                    Tamanho                Dec                    Valid    Usado    Tip                F3    CBOX
            aAdd(aHeadAux,{    X3Titulo(),    cCampoAtu,    PesqPict(SX3->X3_ARQUIVO, cCampoAtu),    SX3->X3_TAMANHO,    SX3->X3_DECIMAL,    ".F.",    ".F.",    SX3->X3_TIPO,    "",    ""})
             
            //Se o campo atual for retornar, aumenta o tamanho do retorno
            If cCampoAtu $ cCampoRet
            
                nTamanRet += SX3->X3_TAMANHO
                
            EndIf
             
        Else    
        
            //Cabeçalho ...    Titulo                                    Campo        Mask    Tamanho                    Dec                        Valid    Usado    Tip                        F3    CBOX
            aAdd(aHeadAux,{    Capital(StrTran(cCampoAtu, '_', ' ')),    cCampoAtu,    "",        aStruAux[nAtual][3],    aStruAux[nAtual][4],    ".F.",    ".F.",    aStruAux[nAtual][2],    "",    ""})
             
            //Se o campo atual for retornar, aumenta o tamanho do retorno
            If cCampoAtu $ cCampoRet            
            
                nTamanRet += aStruAux[nAtual][3]
                
            EndIf
        EndIf
    Next
     
    RestArea(aAreaX3)
    
Return


/*/{Protheus.doc} User Function fPopula 
	Função que popula a tabela auxiliar da MsNewGetDados 
	@type  Function
	@author Daniel Atilio    
	@since 15/12/2016 
	@version version
/*/  
Static Function fPopula()

    Local cQuery := ""
    Local nAtual := 0
    
    aColsAux := {}
    nCampAux := 1
 
    //Faz a consulta
    cQuery := cConsSQL + STR_PULA
     
    //Se tiver Filtro
    If !Empty(cGetPesq)
    
        If 'WHERE' $ cQuery
        
            cQuery += "   AND "
            
        Else
        
            cQuery += "   WHERE "
            
        EndIf
        
        cQuery += " ( "
        
        For nAtual := 1 To Len(aStruAux)
        
            cCampoAtu := aStruAux[nAtual][1]
            
            If aStruAux[nAtual][2] == 'C'
            
                cQuery += " UPPER("+cCampoAtu+") LIKE '%"+Upper(Alltrim(cGetPesq))+"%' OR"
                
            EndIf
            
        Next
        
        cQuery := SubStr(cQuery, 1, Len(cQuery)-2)
        cQuery += ")"+STR_PULA
        
    EndIf
     
    //Group By
    If !Empty(cAgrup)
    
        cQuery += cAgrup + STR_PULA
        
    EndIf
     
    //Order By
    cQuery += " ORDER BY "    + STR_PULA
    
    If !Empty(cOrder)
    
        cQuery += "   "+cOrder
        
    Else
    
        cQuery += "   "+cCampoRet
        
    EndIf
    
    TCQuery cQuery New Alias "QRY_DAD"
     
    //Percorrendo a estrutura, procurando campos de data
    For nAtual := 1 To Len(aHeadAux)
    
        //Se for data
        If aHeadAux[nAtual][8] == "D"
        
            TCSetField('QRY_DAD', aHeadAux[nAtual][2], 'D')
            
        //Se for data
        ElseIf aHeadAux[nAtual][8] == "N"
        
            TCSetField('QRY_DAD', aHeadAux[nAtual][2], 'N', aHeadAux[nAtual][4], aHeadAux[nAtual][5])
            
        EndIf
    Next
     
    //Enquanto tiver dados
    While ! QRY_DAD->(EoF())
    
        nCampAux := 1
        aAux := {}
        //Percorrendo os campos e adicionando no acols e com o delet
        For nAtual := 1 To Len(aStruAux)
        
            cCampoAtu := aStruAux[nAtual][1]
             
            If aStruAux[nAtual][2] $ "N;D"
            
                aAdd(aAux,  &("QRY_DAD->"+cCampoAtu) )
                
            Else
            
                aAdd(aAux, cValToChar( &("QRY_DAD->"+cCampoAtu) ))
                
            EndIf
        Next    
        
        aAdd(aAux, .F.)
     
        aAdd(aColsAux, aClone(aAux))
        QRY_DAD->(DbSkip())
    EndDo
    
    QRY_DAD->(DbCloseArea())
     
    //Se não tiver dados, adiciona linha em branco
    If Len(aColsAux) == 0
        aAux := {}
         
        //Percorrendo os campos e adicionando no acols e com o delet
        For nAtual := 1 To Len(aStruAux)
        
            aAdd(aAux, '')
            
        Next
        
        aAdd(aAux, .F.)
     
        aAdd(aColsAux, aClone(aAux))
    EndIf
     
    //Posiciona no topo e atualiza grid
    oMsNew:SetArray(aColsAux)
    oMsNew:oBrowse:Refresh()
Return
 

/*/{Protheus.doc} User Function fConfirm
	Função de confirmação da rotina  
	@type  Function
	@author Daniel Atilio 
	@since 15/12/2016 
	@version version
/*/ 

Static Function fConfirm()

    Local aAreaX3  := SX3->(GetArea())
    Local cAux     := "" 
    Local aColsNov := oMsNew:aCols
    Local nLinAtu  := oMsNew:nAt
    Local nAtual
 
    //Percorrendo os campos
    For nAtual := 1 To Len(aHeadAux)
    
        cCampoAtu := aHeadAux[nAtual][2]
     
        //Se o campo atual for retornar, soma com o auxiliar
        If cCampoAtu $ cCampoRet
        
            cAux += aColsNov[nLinAtu][nAtual]
            
        EndIf
    Next
 
    //Setando o retorno conforme auxiliar e finalizando a tela
    lRetorn    := .T.
    __cRetorno := cAux
     
    //Se tiver retorno
    If Len(__cRetorno) != 0
    
        //Se o tamanho for menor, adiciona
        If Len(__cRetorno) < nTamanRet
        
            __cRetorno += Space(nTamanRet - Len(__cRetorno))
         
        //Senão se for maior, diminui
        ElseIf Len(__cRetorno) > nTamanRet
        
            __cRetorno := SubStr(__cRetorno, 1, nTamanRet)
            
        EndIf
    EndIf
     
    oDlgEspe:End()
    RestArea(aAreaX3)
Return
 


/*/{Protheus.doc} User Function fLimpar
	Função que limpa os dados da rotina    
	@type  Function
	@author Daniel Atilio 
	@since 15/12/2016 
	@version version
/*/
               
Static Function fLimpar()

    //Zerando gets
    cGetPesq := Space(100)
    oGetPesq:Refresh()
 
    //Atualiza grid
    fPopula()
     
    //Setando o foco na pesquisa
    oGetPesq:SetFocus()
    
Return
 

/*/{Protheus.doc} User Function fCancela
	Função de cancelamento da rotina     
	@type  Function
	@author Daniel Atilio 
	@since 15/12/2016 
	@version version
/*/               

Static Function fCancela()

    //Setando o retorno em branco e finalizando a tela
    lRetorn := .F.
    __cRetorno := Space(nTamanRet)
    oDlgEspe:End()
    
Return
 


/*/{Protheus.doc} User Function fVldPesq
	unção que valida o campo digitado    
	@type  Function
	@author Daniel Atilio 
	@since 15/12/2016 
	@version version
/*/               
 
Static Function fVldPesq()

    Local lRet := .T.
     
    //Se tiver apóstrofo ou porcentagem, a pesquisa não pode prosseguir
    If "'" $ cGetPesq .Or. "%" $ cGetPesq
    
        lRet := .F.
        MsgAlert("<b>Pesquisa inválida!</b><br>A pesquisa não pode ter <b>'</b> ou <b>%</b>.", "Atenção")
        
    EndIf
     
    //Se houver retorno, atualiza grid
    If lRet
    
        fPopula()
        
    EndIf
    
Return lRet


User Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
				      cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
				      cF3, cGrpSxg,cPyme,; 
				      cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
				      cDef02,cDefSpa2,cDefEng2,; 
				      cDef03,cDefSpa3,cDefEng3,; 
				      cDef04,cDefSpa4,cDefEng4,; 
				      cDef05,cDefSpa5,cDefEng5,; 
				      aHelpPor,aHelpEng,aHelpSpa,cHelp) 

	LOCAL aArea := GetArea() 
	Local cKey 
	Local lPort := .F. 
	Local lSpa  := .F. 
	Local lIngl := .F. 

    U_ADINF009P('ADINFLIBP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina padrao da TI')
	
	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 
	
	cPyme    := Iif(cPyme   == Nil, " ", cPyme) 
	cF3      := Iif(cF3     == NIl, " ", cF3) 
	cGrpSxg  := Iif(cGrpSxg == Nil, " ", cGrpSxg) 
	cCnt01   := Iif(cCnt01  == Nil, "" , cCnt01) 
	cHelp    := Iif(cHelp   == Nil, "" , cHelp) 
	
	dbSelectArea( "SX1" ) 
	dbSetOrder( 1 ) 
	
	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
	// RFC - 15/03/2007 
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 
	
	If !( DbSeek( cGrupo + cOrdem )) 
	
		cPergunt := IIF(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
	    cPerSpa  := IIF(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
	    cPerEng  := IIF(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 
	
	    Reclock( "SX1" , .T. ) 
	
	    Replace X1_GRUPO   With cGrupo 
	    Replace X1_ORDEM   With cOrdem 
	    Replace X1_PERGUNT With cPergunt 
	    Replace X1_PERSPA  With cPerSpa 
	    Replace X1_PERENG  With cPerEng 
	    Replace X1_VARIAVL With cVar 
	    Replace X1_TIPO    With cTipo 
	    Replace X1_TAMANHO With nTamanho 
	    Replace X1_DECIMAL With nDecimal 
	    Replace X1_PRESEL  With nPresel 
	    Replace X1_GSC     With cGSC 
	    Replace X1_VALID   With cValid 
	    Replace X1_VAR01   With cVar01 
	    Replace X1_F3      With cF3 
	    Replace X1_GRPSXG  With cGrpSxg 
	
	    If Fieldpos("X1_PYME") > 0 
	    	If cPyme != Nil 
	    		Replace X1_PYME With cPyme 
	        Endif 
	    Endif 
	
	    Replace X1_CNT01   With cCnt01
	     
	    If cGSC == "C"               // Mult Escolha
	     
	    	Replace X1_DEF01   With cDef01 
	        Replace X1_DEFSPA1 With cDefSpa1 
	        Replace X1_DEFENG1 With cDefEng1 
	        Replace X1_DEF02   With cDef02 
	        Replace X1_DEFSPA2 With cDefSpa2 
	        Replace X1_DEFENG2 With cDefEng2 
	        Replace X1_DEF03   With cDef03 
	        Replace X1_DEFSPA3 With cDefSpa3 
	        Replace X1_DEFENG3 With cDefEng3 
	        Replace X1_DEF04   With cDef04 
	        Replace X1_DEFSPA4 With cDefSpa4 
	        Replace X1_DEFENG4 With cDefEng4 
	        Replace X1_DEF05   With cDef05 
	        Replace X1_DEFSPA5 With cDefSpa5 
	        Replace X1_DEFENG5 With cDefEng5
	         
	    Endif 
	
	    Replace X1_HELP With cHelp 
	
	    PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 
	
	    MsUnlock()
	     
	Else 
	
		lPort := !"?" $ X1_PERGUNT .And. !Empty(SX1->X1_PERGUNT) 
	    lSpa  := !"?" $ X1_PERSPA  .And. !Empty(SX1->X1_PERSPA) 
	    lIngl := !"?" $ X1_PERENG  .And. !Empty(SX1->X1_PERENG) 
	
	If lPort .Or. lSpa .Or. lIngl
	 
		RecLock("SX1",.F.) 
	    If lPort 
	    	SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
	    EndIf 
	    If lSpa 
	    	SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
	    EndIf 
	    If lIngl 
	    	SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
	    EndIf 
	    	SX1->(MsUnLock()) 
	    EndIf 
	Endif 
	
	RestArea( aArea ) 

Return

//SIGAESP WILLIAM COSTA
User Function ESPNOME

Return ("PORTARIA/DIMEP")