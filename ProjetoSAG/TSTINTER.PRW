#INCLUDE "rwmake.ch"  
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "JPEG.CH" 

User Function TSTINTER() // U_TSTINTER()

    AppBringToFront ( )
    oWnd := getWdw()

    oWnd:Activate()

Return Nil

Static Function getWdw()
    
    Local oWnd          := Nil
    Local aAdvSize      := {}
    Local aInfoAdvSize  := {}
    Local aObjCoords    := {}
    Local aObjSize      := {}

    aAdvSize := MsAdvSize()
    VarInfo("aAdvSize",aAdvSize)
    aInfoAdvSize:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
    aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
    aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
    VarInfo("aObjSize",aObjSize)

    DEFINE MSDIALOG oWnd TITLE "Segunda Pesagem de Ração" FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL STYLE DS_MODALFRAME

Return oWnd