#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADEST053P
    CHAMADO:058675 - Gera ordem de produção e aponta a mesma por integração do SAG         
    Quando a OP for excluida no SAG e gravado um log, a partir                             
    desse log, o protheus estorna o apontamento e faz a exclusao                            
    @type  Function
    @author Everson
    @since 04/01/2021.
    @version 01
    @history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
    /*/
User Function ADEST053P  // U_ADEST053P()

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
        RpcSetEnv("01","03")
        
        //
        If !LockByName("ADEST053P", .T., .F.)
            ConOut("[ADEST053P] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return
        EndIf

        ConOut( DToC(Date()) + " " + Time() + " ADEST053P - Início Job importação de Ops.")

        //	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
        //FWMonitorMsg(ALLTRIM(PROCNAME()))

    EndIf

        //
        U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera ordem de produção e aponta a mesmo por integração do SAG Quando a OP for excluida no SAG e gravado um log, a partir desse log, o protheus estorna o apontamento e faz a exclusao')

        //
        //Static Call(ADEST033P,procRot,lAutoJob)
        //@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
        u_EST033A0(lAutoJob)

    //
    If lAutoJob 

        ConOut( DToC(Date()) + " " + Time() + " ADEST053P - Fim Job importação de Ops.")

        //
        UnLockByName("ADEST053P")
    
        RpcClearEnv()

	EndIf

Return Nil
