Attribute VB_Name = "Module1"
Option Explicit

' Return a cell by named range

Private Function GetCell(nm As String, ByRef r As Range) As Boolean
    On Error Resume Next
    Set r = Nothing
    If Not ThisWorkbook.Names(nm) Is Nothing Then
        Set r = ThisWorkbook.Names(nm).RefersToRange
    End If
    If r Is Nothing Then
        Set r = ThisWorkbook.Worksheets("Shock_Simulator").Range(nm)
    End If
    GetCell = Not r Is Nothing
End Function

' Read a number

Private Function NumVal(r As Range) As Double
    NumVal = CDbl(r.Value2)
End Function

' Read percent as fraction

Private Function PctVal(r As Range, Optional ByVal lower As Double = -1E+308, Optional ByVal upper As Double = 1E+308) As Double
    Dim v As Double
    v = CDbl(r.Value2)
    If InStr(1, r.NumberFormat, "%") = 0 Then v = v / 100#
    If v < lower Then v = lower
    If v > upper Then v = upper
    PctVal = v
End Function

' Resolve named ranges

Public Sub RunScenario()
  
    Dim rA As Range, rE As Range, rNI As Range, rC As Range, rL As Range
    Dim rSA As Range, rSE As Range, rSNI As Range, rMinC As Range, rMinL As Range
    Dim oA2 As Range, oE2 As Range, oNI2 As Range, oC2 As Range, oL2 As Range, oComp As Range
    Dim missing As String

    If Not GetCell("cur_Assets", rA) Then missing = missing & vbLf & "cur_Assets"
    If Not GetCell("cur_Equity", rE) Then missing = missing & vbLf & "cur_Equity"
    If Not GetCell("cur_NetIncome", rNI) Then missing = missing & vbLf & "cur_NetIncome"
    If Not GetCell("cur_CET1", rC) Then missing = missing & vbLf & "cur_CET1"
    If Not GetCell("cur_Leverage", rL) Then missing = missing & vbLf & "cur_Leverage"

    If Not GetCell("shock_Assets", rSA) Then missing = missing & vbLf & "shock_Assets"
    If Not GetCell("shock_Equity", rSE) Then missing = missing & vbLf & "shock_Equity"
    If Not GetCell("shock_NetIncome", rSNI) Then missing = missing & vbLf & "shock_NetIncome"

    If Not GetCell("min_CET1", rMinC) Then missing = missing & vbLf & "min_CET1"
    If Not GetCell("min_Leverage", rMinL) Then missing = missing & vbLf & "min_Leverage"

    If Not GetCell("res_Assets", oA2) Then missing = missing & vbLf & "res_Assets"
    If Not GetCell("res_Equity", oE2) Then missing = missing & vbLf & "res_Equity"
    If Not GetCell("res_NetIncome", oNI2) Then missing = missing & vbLf & "res_NetIncome"
    If Not GetCell("res_CET1", oC2) Then missing = missing & vbLf & "res_CET1"
    If Not GetCell("res_Leverage", oL2) Then missing = missing & vbLf & "res_Leverage"
    If Not GetCell("res_Compliance", oComp) Then missing = missing & vbLf & "res_Compliance"

    If Len(missing) > 0 Then
        MsgBox "Missing named cells:" & missing, vbExclamation, "Fix names"
        Exit Sub
    End If

    Application.ScreenUpdating = False

    ' Read base values
    
    Dim A As Double, E As Double, NI As Double, CET1 As Double, LEV As Double
    A = NumVal(rA): E = NumVal(rE): NI = NumVal(rNI)
    CET1 = PctVal(rC): LEV = PctVal(rL)

    ' Read shocks and minima
    
    Dim SA_ As Double, SE_ As Double, SNI_ As Double, MINC_ As Double, MINL_ As Double
    SA_ = PctVal(rSA, 0, 0.99)
    SNI_ = PctVal(rSNI, 0, 0.99)
    SE_ = PctVal(rSE, -0.99, 0.99)
    MINC_ = PctVal(rMinC)
    MINL_ = PctVal(rMinL)

    ' Apply shocks to assets, equity, net Income
    
    Dim A2 As Double, E2 As Double, NI2 As Double
    A2 = A * (1 - SA_)
    NI2 = NI * (1 - SNI_)
    E2 = (E + (NI2 - NI) - (A - A2)) * (1 - SE_)

    ' Recalculate stressed ratios
    
    Dim k As Double, CET1_2 As Double, LEV_2 As Double
    If (A <= 0#) Or (E <= 0#) Or (A2 <= 0#) Or (E2 <= 0#) Then
        CET1_2 = 0#: LEV_2 = 0#
    Else
        k = (E2 / E) / (A2 / A)
        CET1_2 = CET1 * k
        LEV_2 = LEV * k
    End If

    ' Write results with fixed formats
    
    oA2.Value = A2:     oA2.NumberFormat = "#,##0.00"
    oE2.Value = E2:     oE2.NumberFormat = "#,##0.00"
    oNI2.Value = NI2:   oNI2.NumberFormat = "#,##0.00"
    oC2.Value = CET1_2: oC2.NumberFormat = "0.00%"
    oL2.Value = LEV_2:  oL2.NumberFormat = "0.00%"

    ' PASS/FAIL box
    
    Dim rng As Range, txtCell As Range, ok As Boolean, fillColor As Long
    ok = (CET1_2 >= MINC_) And (LEV_2 >= MINL_) And (A2 > 0#) And (E2 > 0#)
    fillColor = IIf(ok, RGB(145, 209, 172), RGB(227, 144, 114))
    If oComp.MergeCells Then Set rng = oComp.MergeArea Else Set rng = oComp
    Set txtCell = rng.Cells(1, 1)
    If rng.FormatConditions.Count > 0 Then rng.FormatConditions.Delete
    rng.Value = ""
    txtCell.Value = IIf(ok, "PASS", "FAIL")
    With rng
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Font.Bold = True
        With .Interior
            .Pattern = xlSolid
            .Color = fillColor
        End With
    End With

    Application.ScreenUpdating = True
End Sub

' Set default shocks and minima

Public Sub ResetScenario()
   
    Dim rSA As Range, rSE As Range, rSNI As Range, rMinC As Range, rMinL As Range
    Dim oA2 As Range, oE2 As Range, oNI2 As Range, oC2 As Range, oL2 As Range, oComp As Range

    GetCell "shock_Assets", rSA:       rSA.Value = 0
    GetCell "shock_Equity", rSE:       rSE.Value = 0
    GetCell "shock_NetIncome", rSNI:   rSNI.Value = 0
    GetCell "min_CET1", rMinC:         rMinC.Value = 0.105
    GetCell "min_Leverage", rMinL:     rMinL.Value = 0.03

    GetCell "res_Assets", oA2:         oA2.ClearContents
    GetCell "res_Equity", oE2:         oE2.ClearContents
    GetCell "res_NetIncome", oNI2:     oNI2.ClearContents
    GetCell "res_CET1", oC2:           oC2.ClearContents
    GetCell "res_Leverage", oL2:       oL2.ClearContents

    If GetCell("res_Compliance", oComp) Then
        Dim rng As Range
        If oComp.MergeCells Then Set rng = oComp.MergeArea Else Set rng = oComp
        rng.Value = ""
        rng.HorizontalAlignment = xlCenter
        rng.Interior.Pattern = xlNone
        If rng.FormatConditions.Count > 0 Then rng.FormatConditions.Delete
    End If
End Sub


