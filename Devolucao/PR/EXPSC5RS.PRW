/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ ENV2RS   º Autor ³ Marcos Bido        º Data ³Wed  17/12/01º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Programa para geracao de um arquivo .TXT                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico Ad'oro                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

user function expsc5rs() 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

cPerg := "GERABO"
Pergunte(cPerg,.T.)

If !MsgYesNo(OemToAnsi("Inicia a Exportacao do Pedidos ? "))
  ExitProc()
EndIf

#IFDEF WINDOWS
  Processa({|| RptDetail()})
  Return
Static Function RptDetail()
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda Area do Siga                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAli := Alias()
_nOrd := IndexOrd()
_nRec := Recno()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria um nome para o arquivo texto                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_nPro := 9999
_nVal := 0
_Dia := str(day(date()),2)
_Mes := StrZero(month(date()),2)
_Hora:= SubStr(Time(),1,2)
_Minu:= Substr(time(),4,2)
_File := ALLTRIM(GETMV("MV_ROADSHO"))+"\RT"+STRZERO(VAL(_Dia+_Mes+_Hora+_Minu),8) + ".txt"
_Eof  := CHR(13)+CHR(10)
nHdl  := fCreate(_File)

If nHdl == -1
    MsgAlert("O arquivo de nome "+_file+" n„o p“de ser CRIADO! Verifique .....","Aten‡„o!")
    Return
Endif

dBSelectArea('SC5')
SET FILTER TO val(C5_ROTEIRO) >= val(MV_PAR01) .AND. val(C5_ROTEIRO) <= val(MV_PAR02) .AND.;
              C5_DTENTR >= MV_PAR03 .AND. C5_DTENTR <= MV_PAR04 .AND.;
              empty(C5_NOTA)

//              C5_LIBEROK == 'S' .and. empty(C5_NOTA)

dbGoTop()

ProcRegua( Reccount())

While !EOF()

    _nPro := _nPro + 1
    IncProc("Lidos " + str(_nPro,9)+"   Gravados - "+str(_nVal,9))
    //
    //Lay-Out do arquivo Texto gerado:
    //
    //Campo        Inicio  Tamanho  Formato 
    //

    //comando        001      01        X E-> add U->Update D->Delete
    //cod.cliente    002      08        99999999
    //num.pedido     010      08        XXXXXXXX
    //tipo embalagem 018      01        A    conforme Adoro
    //qtd.por pedido 019      08        9999999
    //classe roteriz.027      01        A    conforme Adoro
    //data entrega   028      06        999999

    cLin := "E"  + C5_CLIENTE + C5_LOJACLI            // cliente + loja
    cLin := cLin + "00" + C5_NUM			             // num.pedido
    cLin := cLin + "A"                                // tipo embalagem
    cLin := cLin + STRZERO(C5_PESOL,8)                // peso liquido
    cLin := cLin + "A"                                // classe roterizacao
    cLin := cLin + Gravadata(C5_DTENTR,.f.)            // data entrega

    cLin := cLin + _EOF
    _nVal := _nVal + 1

    If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
            If !MsgAlert("Ocorreu um erro na grava‡„o do arquivo "+_file+".   Continua?","Aten‡„o!")
                Exit
            Endif
    Endif
    dbSkip()

EndDo

fClose(nHdl)

dBSelectArea('SC5')
SET FILTER TO
MsgStop("Fim do Processamento")
Return

