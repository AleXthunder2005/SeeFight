Unit BattleDescribeUnit;

Interface
Uses
    FieldGeneratorUnit;
Type
    TCellsArray = Array [0..99] Of Byte;

Var
    UserShipsCountArray: TShipsCountArray;
    IsBotPlaneActive: Boolean;

Procedure InitializeBot(Field: TField);
Procedure ChangeFieldAroundShootPlace(Var ShootField: TField; Var DisplayedField: TField; Col, Row: ShortInt);
Procedure ChangeFieldForDestroyedShip(Var ShootField: TField; Var DisplayedShip: TField; Ship: TShip; Col, Row: ShortInt; IsHorizontal: Boolean);
Function IsShipDestroyed(ShootField: TField; Ship: TShip; Col, Row: ShortInt; IsHorizontal: Boolean): Boolean;
Procedure MakeShoot(Var DisplayedUserField: TField; Var WasHit: Boolean);
Implementation
Uses
    BattleUnit, ListUnit, MMSystem;
Var
    FreeCellsCount: ShortInt;
    CellsIndex, FreeCells: TCellsArray;
    PriorityCellsListHeader: PListElem;
    ShootUserField, UserField: TField;
    WasPlaneUsed: Boolean;

Function CellsArrayInitialize(): TCellsArray;
Var
    I, J, Temp: Byte;
    FreeCells: TCellsArray;
Begin
    For I := 0 To 9 Do
        For J := 0 To 9 Do
        Begin
            Temp := I + 9 * I + J;
            FreeCells[Temp] := Temp;
        End;

    CellsArrayInitialize := FreeCells;
End;

Procedure EditFreeCells(ShootField: TField; Col, Row: ShortInt);
Var
    LastFreeCellsValue, Coord: Byte;
Begin
    If ShootField[Col, Row] = StFree Then
    Begin
        Coord := 10 * Col + Row;
        LastFreeCellsValue := FreeCells[FreeCellsCount-1];
        FreeCells[CellsIndex[Coord]] := LastFreeCellsValue;
        CellsIndex[LastFreeCellsValue] := CellsIndex[Coord];
        Dec(FreeCellsCount);
    End;
End;

Procedure ChangeFieldAroundShootPlace(Var ShootField: TField; Var DisplayedField: TField; Col, Row: ShortInt);
Var
    I, J: ShortInt;
Begin
    I := -1;
    While I < 2 Do
    Begin
        J := -1;
        While J < 2 Do
        Begin
            ShootField[Col+I, Row+J] := StImpossible;
            DisplayedField[Col+I, Row+J] := StImpossible;
            Inc(J, 2);
        End;
        Inc(I, 2);
    End;
End;

Procedure EditCellsAroundShootPlaceInArray(ShootField: TField; Col, Row: ShortInt);
Var
    I, J: ShortInt;
Begin
    I := -1;
    While I < 2 Do
    Begin
        J := -1;
        While J < 2 Do
        Begin
            EditFreeCells(ShootField, Col+I, Row+J);
            Inc(J, 2);
        End;
        Inc(I, 2);
    End;
End;

Procedure ChangeFieldForDestroyedShip(Var ShootField: TField; Var DisplayedShip: TField; Ship: TShip; Col, Row: ShortInt; IsHorizontal: Boolean);
Var
    FirstSideCol, FirstSideRow, SecondSideCol, SecondSideRow, I: ShortInt;
Begin
    If Ship = TShortShip Then
    Begin
        I := -1;
        While I < 2 do
        Begin
            ShootField[Col+I, Row] := StImpossible;
            ShootField[Col, Row+I] := StImpossible;
            DisplayedShip[Col+I, Row] := StImpossible;
            DisplayedShip[Col, Row+I] := StImpossible;
            Inc(I, 2);
        End;
    End
    Else
    Begin
        FindSideOfShip(ShootField, Ship, Col, Row, FirstSideCol, FirstSideRow, IsHorizontal, -1);
        FindSideOfShip(ShootField, Ship, Col, Row, SecondSideCol, SecondSideRow, IsHorizontal, 1);

        ShootField[FirstSideCol, FirstSideRow] := StImpossible;
        ShootField[SecondSideCol, SecondSideRow] := StImpossible;
        DisplayedShip[FirstSideCol, FirstSideRow] := StImpossible;
        DisplayedShip[SecondSideCol, SecondSideRow] := StImpossible;
    End;
End;

Procedure EditCellsForDestroyedShipInArray(ShootField: TField; Ship: TShip; Col, Row: ShortInt; IsHorizontal: Boolean);
Var
    FirstSideCol, FirstSideRow, SecondSideCol, SecondSideRow, I: ShortInt;
Begin
    If Ship = TShortShip Then
    Begin
        I := -1;
        While I < 2 Do
        Begin
            EditFreeCells(ShootField, Col+I, Row);
            EditFreeCells(ShootField, Col, Row+I);
            Inc(I, 2);
        End;
    End
    Else
    Begin
        FindSideOfShip(ShootField, Ship, Col, Row, FirstSideCol, FirstSideRow, IsHorizontal, -1);
        FindSideOfShip(ShootField, Ship, Col, Row, SecondSideCol, SecondSideRow, IsHorizontal, 1);

        EditFreeCells(ShootField, FirstSideCol, FirstSideRow);
        EditFreeCells(ShootField, SecondSideCol, SecondSideRow);
    End;
End;

Function IsShipDestroyed(ShootField: TField; Ship: TShip; Col, Row: ShortInt; IsHorizontal: Boolean): Boolean;
Var
    I, DamagedDecksCount: ShortInt;
    IsDestroyed, HasPartOfShip: Boolean;
    CompareFieldCellAndShipsDeck: TCompareFunction;
Begin
    If IsHorizontal Then
        CompareFieldCellAndShipsDeck := CompareCellsHorizontally
    Else
        CompareFieldCellAndShipsDeck := CompareCellsVertically;

    DamagedDecksCount := 0;
    I := 0;
    Repeat
        HasPartOfShip := CompareFieldCellAndShipsDeck(ShootField, Ship, Col, Row, -I);
        If HasPartOfShip then
           Inc(DamagedDecksCount);
        Inc(I);
    Until (I = Ord(Ship)) Or Not HasPartOfShip;
    IsDestroyed := DamagedDecksCount = Ord(Ship);

    If Not IsDestroyed Then
    Begin
        I := 1;
        Repeat
            HasPartOfShip := CompareFieldCellAndShipsDeck(ShootField, Ship, Col, Row, I);
            if HasPartOfShip Then
                Inc(DamagedDecksCount);
            Inc(I);
        Until (I = Ord(Ship)) Or Not HasPartOfShip;
        IsDestroyed := DamagedDecksCount = Ord(Ship);
    End;

    IsShipDestroyed := IsDestroyed;
End;

Function IsFieldCellFree(ShootField: TField; Col, Row: ShortInt): Boolean;
Begin
    IsFieldCellFree := ShootField [Col, Row] = StFree;
End;

Procedure AddPriorityCellsToList (ListHeader: PListElem; ShootField: TField; Col, Row: ShortInt);
Var
    I: ShortInt;
Begin
    I := -1;
    While I < 2 do
    Begin
        If IsFieldCellFree(ShootField, Col+I, Row) Then
            AddListElem(ListHeader, 10 * (Col+I) + Row);
        If IsFieldCellFree(ShootField, Col, Row+I) Then
            AddListElem(ListHeader, 10 * Col + (Row+I));

        Inc(I, 2);
    End;
End;

Function ReturnFreeCellCoord(): ShortInt;
Var
    Col, Row, Coord, I: ShortInt;
    ListElem: PListElem;
Begin
    If (PriorityCellsListHeader^.Next = Nil) Then
    Begin
        I := Random(FreeCellsCount);
        Coord := FreeCells[I];
    End
    Else
    Begin
        Repeat
            ListElem := ExtractElem(PriorityCellsListHeader);
            Coord := ListElem^.Coord;
            Col := Coord Div 10;
            Row := Coord Mod 10;
        Until(PriorityCellsListHeader^.Next = Nil) Or (ShootUserField[Col, Row] = StFree);

        If ShootUserField[Col, Row] <> StFree Then
            Coord := ReturnFreeCellCoord();
    End;
    ReturnFreeCellCoord := Coord;
End;

Procedure ShootUserFieldOnCoord(Var DisplayedUserField: TField; Var WasHit: Boolean; Col, Row: ShortInt);
Var
    State: TFieldCellState;
    Ship: TShip;
    IsHorizontal: Boolean;
Begin
    State := UserField[Col, Row];
    Case State Of
        StFree, StImpossible:
        Begin
            ShootUserField[Col, Row] := stImpossible;
            DisplayedUserField[Col, Row] := stImpossible;
            WasHit := False;
        End;
    Else
        Begin
            WasHit := True;
            Ship := ConvertFieldStateToShip(State);
            ShootUserField[Col, Row] := State;
            DisplayedUserField[Col, Row] := stDamaged;
            EditCellsAroundShootPlaceInArray(ShootUserField, Col, Row);
            ChangeFieldAroundShootPlace(ShootUserField, DisplayedUserField, Col, Row);
            If Ship <> tShortShip Then
                AddPriorityCellsToList(PriorityCellsListHeader, ShootUserField, Col, Row);
            IsHorizontal := IsShipInFieldHorizontal(UserField, Ship, Col, Row);
            If IsShipDestroyed(ShootUserField, Ship, Col, Row, IsHorizontal) Then
            Begin
                EditCellsForDestroyedShipInArray(ShootUserField, Ship, Col, Row, IsHorizontal);
                ChangeFieldForDestroyedShip(ShootUserField, DisplayedUserField, Ship, Col, Row, IsHorizontal);
                Dec(UserShipsCountArray[Ship]);
            End;
        End;
    End;
End;

Procedure MakeShoot(Var DisplayedUserField: TField; Var WasHit: Boolean);
Var
    Coord, Col, Row, I, J: ShortInt;
Begin
    Coord := ReturnFreeCellCoord();
    Col := Coord Div 10;
    Row := Coord Mod 10;

    IsBotPlaneActive := False;
    If Not WasPlaneUsed  And (PriorityCellsListHeader^.Next = Nil) Then
        IsBotPlaneActive := Random(10) = 1;

    If IsBotPlaneActive Then
    Begin
        For I := Col-1 To Col+1 Do
            For J := Row-1 To Row+1 Do
            Begin
                EditFreeCells(ShootUserField, I, J);
                ShootUserFieldOnCoord (DisplayedUserField, WasHit, I, J);
            End;
        WasPlaneUsed := True;
        WasHit := False;
    End
    Else
    Begin
        EditFreeCells(ShootUserField, Col, Row);
        ShootUserFieldOnCoord(DisplayedUserField, WasHit, Col, Row);
    End;
End;

Procedure InitializeBot(Field: TField);
Begin
    FreeCells := CellsArrayInitialize();
    CellsIndex := CellsArrayInitialize();
    UserField := Field;
    FreeCellsCount := 100;
    ShootUserField := CreateField();
    PriorityCellsListHeader := InitializeList();
    UserShipsCountArray := IinializeShipsCountArray();
    WasPlaneUsed := False;
End;
End.
