Unit FieldGeneratorUnit;
Interface
Type
    TFieldCellState = (StImpossible = -1, StFree, StShortShip, StSmallShip, StMiddleShip, StLongShip, StDamaged);
    TField = Array [-1..10, -1..10] Of TFieldCellState;
    TImpossibleCellsMatrix = Array [-1..10, -1..10] Of ShortInt;

    TShip = (TShortShip = 1, TSmallShip, TMiddleShip, TLongShip);
    TShipsArray = Array [0..9] Of TShip;
    TShipsCountArray = Array [TShip] Of Byte;

    TCompareFunction = Function(ShootField: TField; Ship: TShip; Col, Row, I: ShortInt): Boolean;

    Function CreateField(): TField;
    Function CreateImpossibleCellsMatrix(): TImpossibleCellsMatrix;
    Function IinializeShipsCountArray(): TShipsCountArray;
    Function GenerateField(var ImpossibleCellsMatrix: TImpossibleCellsMatrix): TField;
    Procedure FillImpossibleCellsMatrix(var Matrix: TImpossibleCellsMatrix; Ship: TShip; X, Y: ShortInt; IsHorizontal: Boolean);

    Procedure FindSideOfShip(ShootField: TField; Ship: TShip; Col, Row: ShortInt; var SideCol: ShortInt; var SideRow: ShortInt; IsHorizontal: Boolean; DirectionCoef: ShortInt);
    Procedure DeleteShip (var Field: TField; var Matrix: TImpossibleCellsMatrix; Col1, Row1, Col2, Row2: ShortInt; IsHorizontal: Boolean);

    Function CanPlaceShipHere(Field: TField; Ship: TShip; Col, Row: ShortInt; IsHorizontal: Boolean): Boolean;
    Procedure PlaceShipHere(var Field: TField; Ship: TShip; X, Y: ShortInt; IsHorizontal: Boolean);
    Function CanPlaceShipInLine(Field: TField; Ship: TShip; Coord: ShortInt; IsHorizontal: Boolean): Boolean;
    Procedure PlaceShipInLine(var Field: TField; var ImpossibleCellsMatrix: TImpossibleCellsMatrix; Ship: TShip; Coord: ShortInt; IsHorizontal: Boolean);
    Function IsShipInFieldHorizontal(Field: TField; Ship: TShip; Col, Row: ShortInt): Boolean;
    Function IsShipsCountArrayEmpty(Arr: TShipsCountArray): Boolean;

    Function ConvertShipToFieldState(Ship: TShip): TFieldCellState;
    Function ConvertFieldStateToShip(FieldState: TFieldCellState): TShip;

    Function CompareCellsVertically(ShootField: TField; Ship: TShip; Col,Row,I: ShortInt): Boolean;
    Function CompareCellsHorizontally(ShootField: TField; Ship: TShip; Col,Row,I: ShortInt): Boolean;

Implementation

Type
    TReturnCellStateFunction = Function (ShipField: TField; Col, Row, I: ShortInt): TFieldCellState;
    TReturnLineCellStateFunction = Function (ShipField: TField; J, I: ShortInt): TFieldCellState;
    TPlaceShipProcedure = procedure (Var ShipsField: TField; Ship: TShip; X, Y: ShortInt);

Function CreateField(): TField;
Var
    I, J: ShortInt;
    NewField: TField;
Begin
    For J := Low(NewField) To High(NewField) Do
        NewField[-1, J] := StImpossible;

    For I := Low(NewField)+1 To High(NewField)-1 Do
    Begin
        For J := Low(NewField)+1 To High(NewField)-1 Do
            NewField[I, J] := StFree;
        NewField[I, Low(NewField)] := StImpossible;
        NewField[I, High(NewField)] := StImpossible;
    end;

    For J := Low(NewField) To High(NewField) Do
        NewField[High(NewField), J] := StImpossible;

    CreateField := NewField;
End;

Function CreateImpossibleCellsMatrix(): TImpossibleCellsMatrix;
Var
    I, J: ShortInt;
    NewField: TImpossibleCellsMatrix;
Begin
    For J := Low(NewField) To High(NewField) Do
        NewField[-1, J] := 1;

    For I := Low(NewField)+1 to High(NewField)-1 do
    Begin
        For J := Low(NewField)+1 To High(NewField)-1 Do
            NewField[I, J] := 0;
        NewField[I, Low(NewField)] := 1;
        NewField[I, High(NewField)] := 1;
    End;

    For J := Low(NewField) To High(NewField) Do
        NewField[High(NewField), J] := 1;

    CreateImpossibleCellsMatrix := NewField;
End;

Function IinializeShipsCountArray(): TShipsCountArray;
Var
    Arr: TShipsCountArray;
    I: TShip;
Begin
    For I := TShortShip To TLongShip Do
        Arr[I] := 5-Ord(I);

    IinializeShipsCountArray := Arr;
End;

Procedure InitializeShips(Var ShipsArray: TShipsArray);
Var
    CurrShip: TShip;
    I, J: Byte;
Begin
    J := Low(ShipsArray);
    For CurrShip := Low(TShip) To High(TShip) Do
        For I := 5 - Ord(CurrShip) DownTo 1 Do
        Begin
            ShipsArray[J] := CurrShip;
            Inc(J);
        End;
End;

Function ConvertShipToFieldState(Ship: TShip): TFieldCellState;
Const
    TempArr: Array [TShip] Of TFieldCellState = (StShortShip, StSmallShip, StMiddleShip, StLongShip);
Begin
    ConvertShipToFieldState := TempArr[Ship];
End;

Function ConvertFieldStateToShip(FieldState: TFieldCellState): TShip;
Const
    TempArr: Array [stShortShip..stLongShip] Of TShip = (TShortShip, TSmallShip, TMiddleShip, TLongShip);
Begin
    ConvertFieldStateToShip := TempArr[FieldState];
End;

Function CompareCellsVertically(ShootField: TField; Ship: TShip; Col,Row,I: ShortInt): Boolean;
Begin
    CompareCellsVertically := ShootField[Col, Row+I] = ConvertShipToFieldState(Ship);
End;

Function CompareCellsHorizontally(ShootField: TField; Ship: TShip; Col,Row,I: ShortInt): Boolean;
Begin
    CompareCellsHorizontally := ShootField[Col+I, Row] = ConvertShipToFieldState(Ship);
End;

Function ReturnRowElemState(ShipField: TField; Col, Row, I: ShortInt): TFieldCellState;
Begin
    ReturnRowElemState := ShipField[Col+I, Row];
End;

Function ReturnColElemState(ShipField: TField; Col, Row, I: ShortInt): TFieldCellState;
Begin
    ReturnColElemState := ShipField[Col, Row+I];
End;

Function IsShipsCountArrayEmpty(Arr: TShipsCountArray): Boolean;
Var
    I: TShip;
    IsEmpty: Boolean;
Begin
    IsEmpty := True;
    For I := Low(Arr) To High(Arr) Do
        if Arr[I] <> 0 Then
            IsEmpty := False;

    IsShipsCountArrayEmpty := IsEmpty;
End;

Procedure FindSideOfShip(ShootField: TField; Ship: TShip; Col, Row: ShortInt; var SideCol: ShortInt; var SideRow: ShortInt; IsHorizontal: Boolean; DirectionCoef: ShortInt);
Var
    I: ShortInt;
    HasPartOfShip: Boolean;
Begin
    If IsHorizontal Then
    Begin
        I := 0;
        Repeat
            Inc(I);
            HasPartOfShip := CompareCellsHorizontally(ShootField, Ship, Col, Row, DirectionCoef*I);
        Until Not HasPartOfShip;

        SideRow := Row;
        SideCol := Col + DirectionCoef * I;
    End
    Else
    Begin
        I := 0;
        Repeat
            Inc(I);
            HasPartOfShip := CompareCellsVertically(ShootField, Ship, Col, Row, DirectionCoef*I);
        Until Not HasPartOfShip;
        SideCol := Col;
        SideRow := Row + DirectionCoef * I;
    End;
End;

Function IsShipInFieldHorizontal(Field: TField; Ship: TShip; Col, Row: ShortInt): Boolean;
Var
    IsHorizontal: Boolean;
Begin
    If Ship = TShortShip Then
        IsHorizontal := True
    Else
    Begin
        If (Field[Col-1, Row] <> StImpossible) Or (Field[Col+1, Row] <> StImpossible) Then
             IsHorizontal := True
        Else
            IsHorizontal := False;
    End;
    IsShipInFieldHorizontal := IsHorizontal;
End;

Function CanPlaceShipHere(Field: TField; Ship: TShip; Col, Row: ShortInt; IsHorizontal: Boolean): Boolean;
Var
    I: ShortInt;
    CanPlace: Boolean;
    ReturnCellStateFunction: TReturnCellStateFunction;
Begin
    I := 0;
    CanPlace := True;
    If IsHorizontal Then
        ReturnCellStateFunction := ReturnRowElemState
    Else
        ReturnCellStateFunction := ReturnColElemState;

    While (I < Ord(Ship)) And CanPlace Do
    Begin
       CanPlace := ReturnCellStateFunction(Field, Col, Row, I) = StFree;
       Inc(I);
    End;

    CanPlaceShipHere := CanPlace;
End;

Procedure DeleteShipPart (var Field: TField; var Matrix: TImpossibleCellsMatrix; Col, Row: ShortInt);
Begin
    Dec(Matrix[Col, Row]);
    If (Matrix[Col, Row] = 0) Then
        Field[Col, Row] := StFree;
End;

Procedure DeleteShip (Var Field: TField; Var Matrix: TImpossibleCellsMatrix; Col1, Row1, Col2, Row2: ShortInt; IsHorizontal: Boolean);
Var
    I: ShortInt;
Begin
    If IsHorizontal Then
        For I := Col1 To Col2 Do
        Begin
            DeleteShipPart(Field, Matrix, I, Row1-1);
            DeleteShipPart(Field, Matrix, I, Row1);
            DeleteShipPart(Field, Matrix, I, Row1+1);
        End
    Else
        For I := Row1 To Row2 Do
        Begin
            DeleteShipPart(Field, Matrix, Col1-1, I);
            DeleteShipPart(Field, Matrix, Col1, I);
            DeleteShipPart(Field, Matrix, Col1+1, I);
        End;
end;

Procedure FillImpossibleCellsHorizontaly (Var Matrix: TImpossibleCellsMatrix; Ship: TShip; X, Y: ShortInt);
Var
    I: ShortInt;
Begin
    For I := -1 To Ord(Ship) Do
    Begin
        Inc(Matrix[X+I, Y-1]);
        Inc(Matrix[X+I, Y]);
        Inc(Matrix[X+I, Y+1]);
    End;
End;

Procedure FillImpossibleCellsVerticaly (Var Matrix: TImpossibleCellsMatrix; Ship: TShip; X, Y: ShortInt);
Var
    I: ShortInt;
Begin
    For I := -1 To Ord(Ship) Do
    Begin
        Inc(Matrix[X-1, Y+I]);
        Inc(Matrix[X, Y+I]);
        Inc(Matrix[X+1, Y+I]);
    End;
End;

Procedure FillImpossibleCellsMatrix(Var Matrix: TImpossibleCellsMatrix; Ship: TShip; X, Y: ShortInt; IsHorizontal: Boolean);
Begin
    If IsHorizontal Then
        FillImpossibleCellsHorizontaly(Matrix, Ship, X, Y)
    Else
        FillImpossibleCellsVerticaly(Matrix, Ship, X, Y);
End;

Procedure PlaceShipHorizontal (var ShipsField: TField; Ship: TShip; X, Y: ShortInt);
Var
    I: ShortInt;
Begin
    For I := -1 To Ord(Ship) Do
    Begin
        ShipsField[X+I, Y-1] := StImpossible;
        ShipsField[X+I, Y] := ConvertShipToFieldState(Ship);
        ShipsField[X+I, Y+1] := StImpossible;
    End;
    ShipsField[X-1, Y] := StImpossible;
    ShipsField[X+Ord(Ship), Y] := StImpossible;
end;

Procedure PlaceShipVertical (var ShipsField: TField; Ship: TShip; X, Y: ShortInt);
Var
    I: ShortInt;
Begin
    For I := -1 To Ord(Ship) Do
    Begin
        ShipsField[X-1, Y+I] := StImpossible;
        ShipsField[X, Y+I] := ConvertShipToFieldState(Ship);
        ShipsField[X+1, Y+I] := StImpossible;
    End;
    ShipsField[X, Y-1] := StImpossible;
    ShipsField[X, Y+Ord(Ship)] := StImpossible;
End;

Procedure PlaceShipHere(Var Field: TField; Ship: TShip; X, Y: ShortInt; IsHorizontal: Boolean);
Begin
    If IsHorizontal Then
        PlaceShipHorizontal (Field, Ship, X, Y)
    Else
        PlaceShipVertical (Field, Ship, X, Y);
End;

Function ReturnHorizontalLineCellState(ShipField: TField; Row, I: ShortInt): TFieldCellState;
Begin
    ReturnHorizontalLineCellState := ShipField[I, Row];
End;

Function ReturnVerticalLineCellState(ShipField: TField; Col, I: ShortInt): TFieldCellState;
Begin
    ReturnVerticalLineCellState := ShipField[Col, I];
End;

Function CanPlaceShipInLine(Field: TField; Ship: TShip; Coord: ShortInt; IsHorizontal: Boolean): Boolean;
Var
    I, Counter: ShortInt;
    HasFreePlace: Boolean;
    ReturnCellState: TReturnLineCellStateFunction;
Begin
    Counter := 0;
    HasFreePlace := False;
    I := Low(Field)+1;

    If IsHorizontal Then
        ReturnCellState := ReturnHorizontalLineCellState
    Else
        ReturnCellState := ReturnVerticalLineCellState;

    While Not HasFreePlace And (I < High(Field)) Do
    Begin
        If Ord(ReturnCellState(Field, Coord, I)) = 0 Then
            Inc(Counter)
        Else
            Counter := 0;

        If Counter = Ord(Ship) Then
            HasFreePlace := True;
        Inc(I);
    End;

    CanPlaceShipInLine := HasFreePlace;
End;

Function GetSecondCoord(Var Field: TField; Ship: TShip; Coord: ShortInt; IsHorizontal: Boolean): ShortInt;
Var
    I, Counter, StartCell, PossibleCellCount: ShortInt;
    ReturnCellState: TReturnLineCellStateFunction;
Begin
    Counter := 0;
    PossibleCellCount := 0;
    I := Low(Field)+1;

    If IsHorizontal Then
        ReturnCellState := ReturnHorizontalLineCellState
    Else
        ReturnCellState := ReturnVerticalLineCellState;

    While I < High(Field) Do
    Begin
        If Ord(ReturnCellState(Field, Coord, I)) = 0 Then
            Inc(Counter)
        Else
        Begin
            Counter := 0;
            PossibleCellCount := 0;
        End;

        If Counter = Ord(Ship) Then
            StartCell :=  I - Ord(Ship)+1;

        If (Counter - Ord(Ship)) > PossibleCellCount Then
            PossibleCellCount := Counter - Ord(Ship);

        Inc(I);
    End;

    GetSecondCoord := StartCell + Random(PossibleCellCount + 1);
End;

Function PullShip(Var ShipsArray: TShipsArray; CommonShipsCount: Byte): TShip;
Var
    Ship: TShip;
Begin
    Ship := ShipsArray[CommonShipsCount-1];
    PullShip := Ship;
End;

Function GetRandomDirection(): Boolean;
Var
    IsHorizontal: Boolean;
Begin
    IsHorizontal := Random(2) = 0;
    GetRandomDirection := IsHorizontal;
End;

Procedure PlaceShipInLine(Var Field: TField; Var ImpossibleCellsMatrix: TImpossibleCellsMatrix; Ship: TShip; Coord: ShortInt; IsHorizontal: Boolean);
Var
    SecondCoord: ShortInt;
Begin
    SecondCoord := GetSecondCoord(Field, Ship, Coord, IsHorizontal);

    If IsHorizontal Then
    Begin
        PlaceShipHorizontal(Field, Ship, SecondCoord, Coord);
        FillImpossibleCellsHorizontaly(ImpossibleCellsMatrix, Ship, SecondCoord, Coord);
    End
    Else
    Begin
        PlaceShipVertical(Field, Ship, Coord, SecondCoord);
        FillImpossibleCellsVerticaly(ImpossibleCellsMatrix, Ship, Coord, SecondCoord);
    End;
End;

Procedure PutShipToField(Var Field: TField; Var ImpossibleCellsMatrix: TImpossibleCellsMatrix; Ship: TShip);
Var
    Coord: ShortInt;
    IsHorizontal: Boolean;
Begin
    Repeat
        IsHorizontal := GetRandomDirection();
        Coord := Random(10);
    Until CanPlaceShipInLine(Field, Ship, Coord, IsHorizontal);

    PlaceShipInLine(Field, ImpossibleCellsMatrix, Ship, Coord, IsHorizontal);
End;

Procedure FillGameField(Var Field: TField; Var ImpossibleCellsMatrix: TImpossibleCellsMatrix; var ShipsArray: TShipsArray; var CommonShipsCount: Byte);
Var
    Ship: TShip;
    I: ShortInt;
Begin
    For I := 1 To 10 Do
    Begin
        Ship := PullShip(ShipsArray, CommonShipsCount);
        Dec(CommonShipsCount);
        PutShipToField(Field, ImpossibleCellsMatrix, Ship);
    End;
End;

Function GenerateField(Var ImpossibleCellsMatrix: TImpossibleCellsMatrix): TField;
Var
    NewField: TField;
    ShipsArray: TShipsArray;
    CommonShipsCount: Byte;
Begin
    CommonShipsCount := 10;
    NewField := CreateField();
    InitializeShips(ShipsArray);
    FillGameField(NewField, ImpossibleCellsMatrix, ShipsArray, CommonShipsCount);
    GenerateField := NewField;
End;
End.
