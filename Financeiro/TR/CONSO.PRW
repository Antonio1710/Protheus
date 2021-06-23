#include "rwmake.ch"

/*{Protheus.doc} User Function REDEACLC
	Programa para atualizacao dos campos A1_LCREDE e A1_SLDREDE Estes campos se referem respectivamente a Limite de Credito e Saldo da "Rede" (todas as lojas de um mesmo CNPJ) 
	@type  Function
	@author Rogerio Nutti
	@since 11/09/2009
	@version 01
	@history Chamado 056381 - William Costa - 17/03/2020 - Adicionado log em todos os reclock do campo ZF_LCREDE para descobrir seu valor antes e depois 
*/        

User Function CONSO()     

        U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para atualizacao dos campos A1_LCREDE e A1_SLDREDE')

        SetPrvt("_CALI,_NORD,_NREC,")

        @ 200,51 TO 380,380 DIALOG oDlg1 TITLE "Atencao "
        @ 30,010 SAY "Esta rotina executa a atualizacao dos Saldos e Limites de "
        @ 40,010 SAY "Credito para as redes de lojas. "
        @ 75,040 BMPBUTTON TYPE 01 ACTION Continua()
        @ 75,095 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
        ACTIVATE DIALOG oDlg1 CENTERED

Return()

Static Function Continua()

        #IFDEF WINDOWS
                Close(oDlg1)
        #ENDIF

        //Processamento do SA1                                                

        dbSelectArea("SE1")
        dbSetOrder(8)

        dbSelectArea("SA1")
        dbSetOrder(3)
        dbgotop()

        Processa( {|| RunCont()},"Aguarde ..." )
        Return
        Static Function RunCont()
        ProcRegua(RecCount())

        Do While !Eof()

                XNOME     := A1_NOME
                _nMaiorLC := A1_LC
                _nSldRede := 0        

                IF A1_IMPENT=="S"  // cozinha industrial

                XCGCMAT   := SUBSTR(A1_CGCENT,1,8)

                        IncProc("Proces: "+SUBSTR(SA1->A1_NOME,1,15)+"  CNPJ: "+XCGCMAT)
                
                        Do While !Eof() .and. SA1->A1_FILIAL  == xFilial("SA1") .and. Subs(SA1->A1_CGCENT,1,8) == XCGCMAT

                                dbSelectArea("SE1")

                                If dbSeek( xFilial("SE1") + SA1->A1_COD + SA1->A1_LOJA )

                                Do While !Eof() .and. SA1->A1_COD==SE1->E1_CLIENTE .and.;
                                SA1->A1_LOJA==SE1->E1_LOJA

                                        // despreza provisorios

                                        If Alltrim(SE1->E1_TIPO) == "PR"
                                                dbSelectArea("SE1")
                                                dbSkip()
                                                Loop
                                        Endif

                                        // Se RA ou NCC, ou abatimentos subtrai
                                        If Alltrim(SE1->E1_TIPO) $ "RA/NCC" .or. Subs(SE1->E1_TIPO,1,3)=="-"
                                                _nSldRede := _nSldRede - SE1->E1_SALDO
                                        Else
                                                _nSldRede := _nSldRede + SE1->E1_SALDO
                                        Endif

                                        dbSelectArea("SE1")
                                        dbSkip()
                                Enddo

                                Endif
                                dbSelectArea("SA1")
                                dbSkip()
                        Enddo

                        IF _nSldRede > _nMaiorLc

                                u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 1","FINANCEIRO","CONSO",;
                                        "CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(_nMaiorLC),ComputerName(),LogUserName())

                                dbSelectArea("SZF")
                                RecLock("SZF",.T.)
                                Replace ZF_LCREDE  With _nMaiorLC
                                Replace ZF_SLDREDE With _nSldRede
                                Replace ZF_CGCMAT  With xCgcMat
                                Replace ZF_NOMERED With xNome
                                MsUnlock()
                        Endif
                else
                        XCGCMAT   := SUBSTR(A1_CGC,1,8)
                
                        IncProc("Proces: "+SUBSTR(SA1->A1_NOME,1,15)+"  CNPJ: "+XCGCMAT)
                
                        Do While !Eof() .and. SA1->A1_FILIAL  == xFilial("SA1") .and. Subs(SA1->A1_CGC,1,8) == XCGCMAT
                                
                                dbSelectArea("SE1")

                                If dbSeek( xFilial("SE1") + SA1->A1_COD + SA1->A1_LOJA )

                                        Do While !Eof() .and. SA1->A1_COD==SE1->E1_CLIENTE .and.;
                                        SA1->A1_LOJA==SE1->E1_LOJA
                                        
                                                // despreza provisorios

                                                If Alltrim(SE1->E1_TIPO) == "PR"
                                                        dbSelectArea("SE1")
                                                        dbSkip()
                                                        Loop
                                                Endif
                                                
                                                // Se RA ou NCC, ou abatimentos subtrai
                                                If Alltrim(SE1->E1_TIPO) $ "RA/NCC" .or. Subs(SE1->E1_TIPO,1,3)=="-"
                                                        _nSldRede := _nSldRede - SE1->E1_SALDO
                                                Else
                                                        _nSldRede := _nSldRede + SE1->E1_SALDO
                                                Endif
                                                
                                                dbSelectArea("SE1")
                                                dbSkip()					
                                        Enddo
                                        
                                Endif
                                
                                dbSelectArea("SA1")
                                dbSkip()
                        Enddo
                                
                        IF _nSldRede > _nMaiorLc 

                                u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 2","FINANCEIRO","CONSO",;
                                        "CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(_nMaiorLC),ComputerName(),LogUserName())

                                dbSelectArea("SZF")
                                RecLock("SZF",.T.)
                                Replace ZF_LCREDE  With _nMaiorLC
                                Replace ZF_SLDREDE With _nSldRede
                                Replace ZF_CGCMAT  With xCgcMat
                                Replace ZF_NOMERED With xNome
                                MsUnlock()
                        Endif
                ENDIF

                dbSelectArea("SA1")
        Enddo
        
Return