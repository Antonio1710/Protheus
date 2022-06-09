#include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADEST052P
    Gera lote de producao por integração do SAG na empresa Ad'oro filial 03.
    Chamado 7087.
    @type  Function
    @author Everson
    @since 04/01/2021
    @version 01
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
    /*/
User Function ADEST052P()  // U_ADEST052P()

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
        RpcSetEnv("01","03",,,,GetEnvServer(),{})

        //
        If ! LockByName("ADEST052P", .T., .F.)
            ConOut("[ADEST052P] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return Nil 

        EndIf

        //	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
        //FWMonitorMsg(ALLTRIM(PROCNAME()))

    EndIf

        //
        Conout( DToC(Date()) + " " + Time() + " ADEST052P - Início Job de importação de lotes de criação do SAG. Emp/Fil " + cEmpAnt + "/" + cFilAnt )

        //
        logZBN("1","ADEST052P")

        //
        U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),"Gera lote de producao por integração do SAG")
        
            //
            StaticCall(ADEST034P,procRot)

        //
        logZBN("2","ADEST052P")

        //
        Conout( DToC(Date()) + " " + Time() + " ADEST052P - Fim Job de importação de lotes de criação do SAG. Emp/Fil " + cEmpAnt + "/" + cFilAnt )

     //
    If lAutoJob 

        //
        UnLockByName("ADEST052P")

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
