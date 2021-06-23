#include "rwmake.ch"    
#include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ IMPSZK   บAutor  ณMauricio - MDS TEC  บ Data ณ  23/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa็ใo de dados complementares para tabela SZK         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AD'oro - Solicitado Sr. JAMES                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function IMPSZK()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importa็ใo de dados complementares para tabela SZK ')
                                 
_cFile := cGetFile( "Lista Arquivos PRN|*.prn|Lista Arquivos TXT|*.txt",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)

If ! Empty( _cFile )

   If ( MsgNoYes( "Confirma importacao do arquivo " + _cFile ) )

      _aFile := Directory( _cFile )
      
      Processa( { || ProcFile("Analisando arquivo!!!") } )
     
   End

End

Return( NIL )

Static Function ProcFile()
_cLF     := Chr( 10 )
_cTxt    := ''
_cChr    := ''
_nTam    := 0

FT_FUse( _cFile ) 
_nTam += FT_FlastRec()
_nTam ++
FT_FGoTop()
ProcRegua( _nTam )

_nLinha := 1
While ! ( FT_FEof() )

      IncProc( 'Aguarde, importando registros..' )
      //_cTxt := Alltrim( FT_FReadLN() )
      //_cTxt := Alltrim( _cTxt )
      _cTxt :=  FT_FReadLN()
      
      IF _nLinha <> 1   &&primeira linha de cabe็alho ้ preciso ser pulada            
         If Len( _cTxt ) <> 0 
            _cRoteiro := Alltrim(Substr(_cTxt, 1,12))
            _dData    := CTOD(Alltrim(Substr(_cTxt,13,12)))
            _cPlaca   := Alltrim(Substr(_cTxt,25,12))
            _nKm      := Alltrim(Substr(_cTxt,37,12))            
            _nKm      := Val( _nkm )
            _nEntrega := Val(Alltrim(Substr(_cTxt,52,5)))
            
            dbSelectArea("SZK")
            dbSetOrder(4)
            Dbgotop()
            if dbSeek(xFilial("SZK") + dtos(_dData) + _cPlaca + _cRoteiro)
            
            	//grava log chamado 041202 - WILLIAM COSTA 23/04/2018
				u_GrLogZBE (Date(),TIME(),cUserName," RecLock(SZK,.F.)","LOGISTICA","IMPSZK",;
				"Filial: "+xFilial("SZK")+" Data: "+DTOS(_dData)+" Placa: "+_cPlaca+" Roteiro: "+_cRoteiro+" ZK_ENTREGA: "+ cvaltochar(_nEntrega),ComputerName(),LogUserName())

               _nFrete := fCalFrt(SZK->ZK_TPFRETE,_nKM,SZK->ZK_DTENTR,SZK->ZK_PLACA,SZK->ZK_TABELA,SZK->ZK_KMSAI,_nEntrega - SZK->ZK_ENTRDEV,SZK->ZK_GUIA,SZK->ZK_VALFRET)
               recLock("SZK",.F.)
               SZK->ZK_PESOL   := SZK->ZK_PESFATL
               SZK->ZK_PBRUTO  := SZK->ZK_PESFATB
               SZK->ZK_KMENT   := _nKm
               SZK->ZK_KMSAI   := 0
               SZK->ZK_KMPAG   := _nKm
               SZK->ZK_DTFECH  := SZK->ZK_DTENTR
               SZK->ZK_VALFRET := _nFrete
               SZK->ZK_ENTREGA := _nEntrega
               SZK->ZK_HORA    := TIME()                           
               SZK->(MsUnlock())
            Else
               MsgInfo("Nใo encontrado Roteiro/Data/Placa("+_cRoteiro+"/"+Dtoc(_dData)+"/"+_cPlaca+") no sistema","Aten็ใo")
               
               //grava log chamado 041202 - WILLIAM COSTA 23/04/2018
				u_GrLogZBE (Date(),TIME(),cUserName,"ELSE RecLock(SZK,.F.)","LOGISTICA","IMPSZK",;
				"Filial: "+xFilial("SZK")+" Data: "+DTOS(_dData)+" Placa: "+_cPlaca+" Roteiro: "+_cRoteiro+" ZK_ENTREGA: "+ cvaltochar(_nEntrega),ComputerName(),LogUserName())
				            
            Endif            
         Endif
      Endif   
      _nLinha ++   
      FT_FSkip()   

Enddo     

FT_FUse()
         
Return( NIL )
                   
                    
Static function fCalFrt(_cTpFr,_nKME,_dDatEntr,_cPlac,_TipTabela,_nKMS,_Nentre,_nGuia,_nFrtAnt)
&&Calculo vindo do programa AD0073, conforme gatilho
IF _cTpFr $ "A1/AR/AM/AK/AJ/AI/VI/VE/VL/VR/VS/VV"
	_cCodFor   :=  space(6)
	_cLojFor   :=  space(2)
	_cNomFor   :=  space(30)
	_cTabPrec  :=  space(2)
	
	_kmPag    :=  _nKME    ///_nKME - _nKMS
	
	_Vlvei    := 0
	_Vlentre  := 0
	_Bandeir  := 0
	_vValFret := 0
	
	dbSelectArea("SZG")
	dbSetOrder(1)
	Dbgotop()
	If dbSeek (xFilial("SZG")+_TipTabela)
		dbSelectArea("ZVB")
		dbSetOrder(1)
		DbGotop()
		If dbSeek (xFilial("ZVB")+_TipTabela)
			While ZVB->(!Eof()) .And. _TipTabela = ZVB->ZVB_CODTAB
				If (_dDatEntr >= ZVB->ZVB_DATINI ).AND. (_dDatEntr <= ZVB->ZVB_DATFIM )
					_Vlvei    := ZVB->ZVB_PRECO
					_Vlentre  := ZVB->ZVB_VLENTR
					_Bandeir  := ZVB->ZVB_BANDEI
				Endif
				Dbskip()
			EndDo
		Else                                                       
			Alert("Nใo existe pre็o cadastrado para este tipo de frete.")
		Endif
		
		// Se calcula frete ou nao
		If SZG->ZG_CALFRET = 'S'
			_vValFret  := (_kmPag * _Vlvei) + (_Vlentre * _Nentre ) + _Bandeir 
			
			// ***************** INICIO DO CHAMADO NUM 022650 - William Costa   ********** /
			//SE FOR TABELA TK E MENOR QUE 800 O VALOR DO FRETE TEM QUE SER 800 ********** /
			
			// ***************** INICIO DO CHAMADO NUM 025020 - Luciano Mafra   ********** /
			//SE FOR TABELA TK E MENOR QUE 880 O VALOR DO FRETE TEM QUE SER 880 ********** /			
/*			
			IF ALLTRIM(_TipTabela) == 'TK' .AND. _vValFret < 800
			
				_vValFret  := 800
			
			ENDIF
*/			
			IF ALLTRIM(_TipTabela) == 'TK' .AND. _vValFret < 880
			
				_vValFret  := 880
			
			ENDIF			                                                                            
			
			// ***************** FINAL DO CHAMADO NUM 025020  - Luciano Mafra   ********** /
			//SE FOR TABELA TK E MENOR QUE 880 O VALOR DO FRETE TEM QUE SER 880 ********** /			            

			// ***************** FINAL DO CHAMADO NUM 022650  - William Costa   ********** /
			//SE FOR TABELA TK E MENOR QUE 800 O VALOR DO FRETE TEM QUE SER 800 ********** /			
			                                                                                            
			
			If _vValFret <= 0
				ALERT("Verifique o cadastro de frete para esta data de entrega, pois nao possui pre็o cadastrado para esta data")
			End If
		Else
			_vValFret  := 0
		Endif
	Endif
	
	// Zerar Variaveis
	_Vlvei    := 0
	_Vlentre  := 0
	_Nentre   := 0
	_Bandeir  := 0
Else
	_vValFret := _nFrtAnt
Endif


Return(_vValFret)

