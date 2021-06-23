#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADEST049P
    CHAMADO:058675 - Gera ordem de produção e aponta a mesma por integração do SAG         
    Quando a OP for excluida no SAG e gravado um log, a partir                             
    desse log, o protheus estorna o apontamento e faz a exclusao                            
    @type  Function
    @author Everson
    @since 23/06/2020.
    @version 01
    /*/
User Function ADEST049P  // U_ADEST049P()

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
        RpcSetEnv("09","01")
        
        // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
        If !LockByName("ADEST049P", .T., .F.)
            ConOut("[ADEST049P] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return
        EndIf

        ConOut( DToC(Date()) + " " + Time() + " ADEST049P - Início Job importação de Ops.")

        PtInternal(1,ALLTRIM(PROCNAME()))

    EndIf

        //
        U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera ordem de produção e aponta a mesmo por integração do SAG Quando a OP for excluida no SAG e gravado um log, a partir desse log, o protheus estorna o apontamento e faz a exclusao')

        //
        StaticCall(ADEST033P,procRot,lAutoJob)

    //
    If lAutoJob 

        ConOut( DToC(Date()) + " " + Time() + " ADEST049P - Fim Job importação de Ops.")
	
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        //³Destrava a rotina para o usuário	    ?
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        UnLockByName("ADEST049P")
    
    	RpcClearEnv()

	EndIf

Return Nil