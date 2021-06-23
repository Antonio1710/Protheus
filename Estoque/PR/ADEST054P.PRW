#include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADEST054P
    Gera lote de producao por integração do SAG na empresa Ad'oro filial 04.
    Chamado 7989.
    @type  Function
    @author Everson
    @since 13/01/2021
    @version 01
    /*/
User Function ADEST054P()  // U_ADEST054P()

    //Variáveis.
    Local lAutoJob := .F.

    //
    If Select("SX6") == 0
        lAutoJob := .T.

    EndIf

    //
    If lAutoJob

        RpcClearEnv()
        RpcSetType(3)
        RpcSetEnv("01","04",,,,GetEnvServer(),{})

        //
        If ! LockByName("ADEST054P", .T., .F.)
            ConOut("[ADEST054P] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return Nil 

        EndIf

        PtInternal(1,ALLTRIM(PROCNAME()))

    EndIf

        //
        Conout( DToC(Date()) + " " + Time() + " ADEST054P - Início Job de importação de lotes de criação do SAG. Emp/Fil " + cEmpAnt + "/" + cFilAnt )

        //
        logZBN("1","ADEST054P")

        //
        U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),"Gera lote de producao por integração do SAG")
        
            //
            StaticCall(ADEST034P,procRot)

        //
        logZBN("2","ADEST054P")

        //
        Conout( DToC(Date()) + " " + Time() + " ADEST054P - Fim Job de importação de lotes de criação do SAG. Emp/Fil " + cEmpAnt + "/" + cFilAnt )

     //
    If lAutoJob 

        //
        UnLockByName("ADEST054P")

		RpcClearEnv()

	Endif

Return Nil
/*/{Protheus.doc} logZBN
    Gera log na tabela ZBN. Chamado 058675.
    @type  Static Function
    @author Everson
    @since 04/01/2021
    @version 01
    /*/
Static Function logZBN(cStatus,cJob)

    //Variáveis.
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + cJob))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= cJob 
			ZBN_DATA    := dDataBase
			ZBN_HORA    := Time()
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= cJob 
			ZBN_DATA    := dDataBase
			ZBN_HORA    := Time()
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil
