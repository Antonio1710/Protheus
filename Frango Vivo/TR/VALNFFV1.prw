#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#include "FiveWin.ch"

/*/{Protheus.doc} User Function VALNFFV1
	Validacao chamada pelo campo ZV1_NUMNFS (SX3)
	@type  Function
	@author Mauricio da Silva
	@since 13/05/2010
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
	@history Ticket 71370 - Adriano Savoine   - 22/04/2022 - Corrigido a variavel para carregar a filial correta
/*/
User Function VALNFFV1()  

	Local _lRet    := .T.
	Local _cQuery  := "" 
	
	Local cFilPV   	:= Posicione("ZFC",4,xFilial("ZFC")+ZV1->ZV1_NUMOC ,"ZFC_FILORI") //Ticket 71370 - Adriano Savoine   - 22/04/2022
	Local cCliCod  	:= GetMV("MV_#LFVCLI",,"027601")
	Local cCliLoj  	:= GetMV("MV_#LFVLOJ",,"00")
	Local cProdPV  	:= GetMV("MV_#LFVPRD",,"300042")
	Local cQryEXT 	:= " "
	Local cQryCAN 	:= " "
	
	Private _aArea    := GetArea()
	Private cAliasZV1 := Alias()
	Private cOrderZV1 := IndexOrd()
	Private cRecnoZV1 := Recno()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Validacao chamada pelo campo ZV1_NUMNFS (SX3)')

	_nCODFNF	:= ZV1->ZV1_FORREC
	_nLojNF		:= ZV1->ZV1_LOJREC
	_cSerie   	:= ZV1->ZV1_SERIE
	_nNumNf     := M->ZV1_NUMNFS
	_cPlac		:= ZV1->ZV1_PPLACA
	_ORDEM		:= ZV1->ZV1_NUMOC 
	
	_cQuery := " SELECT ZV1_NUMOC, ZV1_NUMNFS, ZV1_SERIE, ZV1_CODFOR, ZV1_LOJFOR "
	_cQuery += " FROM "+retsqlname("ZV1") + " (NOLOCK) " 
	_cQuery += " WHERE ZV1_FILIAL='"+FWxFilial("ZV1")+"' AND " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
	_cQuery += " RTRIM(LTRIM(ZV1_NUMNFS)) = '"+ALLTRIM(_nNumNF)+"' and "
	_cQuery += " RTRIM(LTRIM(ZV1_SERIE)) = '"+ALLTRIM(_cSerie)+"' and "
	_cQuery += " ZV1_FORREC = '"+_nCODFNF+"' and ZV1_LOJREC = '"+_nLojNF+"' and "
	_cQuery += " D_E_L_E_T_ <> '*' ORDER BY ZV1_NUMOC"
	
	TcQuery _cQuery New Alias "VZV1"
	 
	DbSelectArea("VZV1")
	VZV1->(dbGoTop())
	While !VZV1->(eof())
	   If VZV1->ZV1_NUMOC <> _ORDEM      //&& Verifica se nao esta alterando uma OC.
	      MsgInfo("A NF/SERIE "+_nNumNf+" / "+_cSerie+" informada ja foi utilizada na OC: "+VZV1->ZV1_NUMOC+" para o Fornecedor/loja: "+_nCODFNF+" / "+_nLojNF+" .Favor Verificar!!!")
	      VZV1->(DbCloseArea())
	      dbSelectArea(cAliasZV1)
	      dbSetOrder(cOrderZV1)
	      dbGoto(cRecnoZV1)
	      RestArea(_aArea)
	      Return(.F.)
	   endif
	   
	   VZV1->(dbSkip())
	EndDo
	    
	VZV1->(DbCloseArea())
    
    //inicio - Fernando Sigoli Chamado:043085 13/08/2018
	//verificar se a nota que esta sendo lançada existe
	cQryEXT := " SELECT COUNT(*)  AS RECNFEXT "
	cQryEXT += " 	    FROM "+retsqlname("SF2") +" SF2 WITH (NOLOCK) "
	cQryEXT += " JOIN "+retsqlname("SD2") +" SD2 WITH (NOLOCK) "
	cQryEXT += " ON SF2.F2_FILIAL = SD2.D2_FILIAL "
	cQryEXT += " AND SF2.F2_DOC = SD2.D2_DOC   "
	cQryEXT += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
	cQryEXT += " AND SF2.F2_LOJA = SD2.D2_LOJA  "
	cQryEXT += " WHERE SF2.F2_FILIAL  = '"+cFilPV+"'  "    
	cQryEXT += " AND SF2.F2_CLIENTE = '"+cCliCod+"' "
	cQryEXT += " AND SF2.F2_LOJA 	= '"+cCliLoj+"' "
	cQryEXT += " AND SF2.F2_DOC     = '"+PADL(_nNumNf,9,"0")+"' "  
	cQryEXT += " AND SD2.D2_COD     = '"+cProdPV+"'"
	cQryEXT += " AND SF2.D_E_L_E_T_ = '' "	
	cQryEXT += " AND SD2.D_E_L_E_T_ = '' " 
	
	If Select("VEXT") > 0
		VEXT->(DbCloseArea())
	EndIf
	
	TcQuery cQryEXT New Alias "VEXT"
	
	DbSelectArea("VEXT")
	VEXT->(dbGoTop())  
	If VEXT->RECNFEXT <= 0
		MsgInfo ("Atenção. Nota Fiscal: " +PADL(_nNumNf,9,"0")+ " Cliente:" +cCliCod+"-"+cCliLoj+ " não localizada. Por favor, verificar")
		dbSelectArea(cAliasZV1)
	    dbSetOrder(cOrderZV1)
	    dbGoto(cRecnoZV1)
	    RestArea(_aArea)    
		Return(.F.)
	EndIF
	
	VEXT->(DbCloseArea())
	
    //verificar se a nota que esta sendo lançada nao esta cancelada.
    cQryCAN :=  " SELECT COUNT(SF2.F2_DOC) AS RECNFCAN  "
	cQryCAN +=  " FROM "+retsqlname("SF2") +" SF2 WITH (NOLOCK) INNER JOIN "+retsqlname("C00") +" C00 WITH (NOLOCK) ON " 
	cQryCAN +=  " SF2.F2_CHVNFE = C00.C00_CHVNFE  "
	cQryCAN +=  " WHERE  "
	cQryCAN +=  " SF2.F2_FILIAL = '"+cFilPV+"'  "
	cQryCAN +=  " AND C00.C00_SITDOC = '3'  "
	cQryCAN +=  " AND SF2.D_E_L_E_T_ = '*' "
	cQryCAN +=  " AND C00.D_E_L_E_T_ = '' "
	cQryCAN +=  " AND SF2.F2_DOC = '"+PADL(_nNumNf,9,"0")+"'"   
	cQryCAN +=  " GROUP BY F2_DOC "  
	
	If Select("VSF2") > 0
		VSF2->(DbCloseArea())
	EndIf
	
	TcQuery cQryCAN New Alias "VSF2" 
	
	DbSelectArea("VSF2")
	VSF2->(dbGoTop()) 
					
	If VSF2->RECNFCAN > 0
		MsgInfo ("Atenção. Nota Fiscal " +PADL(_nNumNf,9,"0")+ " com situação Cancelada . Por favor, verificar") 
		dbSelectArea(cAliasZV1)
	 	dbSetOrder(cOrderZV1)
	  	dbGoto(cRecnoZV1)
	    RestArea(_aArea)  
		Return(.F.)
	EndIF
	//Fim - Fernando Sigoli Chamado:043085 13/08/2018  
	
	VSF2->(DbCloseArea()) 
	
	//Inicio: fernando sigoli 30/08/2018
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT ZV5_NUMNFS, ZV5_NUMOC "
	cQuery += " FROM " + RetSqlName("ZV5") + " (NOLOCK) "
	cQuery += " WHERE ZV5_FILIAL='"+xFilial("ZV5")+"' "
	cQuery += " AND ZV5_NUMNFS='"+PADL(_nNumNf,9,"0")+"' "
	cQuery += " AND D_E_L_E_T_='' "                                      
	
	tcQuery cQuery new alias "Work"
	
	Work->( dbGoTop() )
	
	If Work->( !EOF() )
	
		If !Empty(Work->ZV5_NUMNFS) .AND. Work->ZV5_NUMOC  <> _ORDEM
	
			MsgInfo ("Atenção. Nota Fiscal " +PADL(_nNumNf,9,"0")+ " ja utilizada nos apontamentos de Apanha. OC: "+Work->ZV5_NUMOC+ " . Por favor, verificar") 
			dbSelectArea(cAliasZV1)
	 		dbSetOrder(cOrderZV1)
	  		dbGoto(cRecnoZV1)
	    	RestArea(_aArea)  
			Return(.F.)
		  
		EndIf
	
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	//Fim:fernando sigoli 30/08/2018	
		
	dbSelectArea(cAliasZV1)
	dbSetOrder(cOrderZV1)
	dbGoto(cRecnoZV1)
	
	RestArea(_aArea)

RETURN(_lRet)   
