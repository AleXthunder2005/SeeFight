Unit ListUnit;

Interface
Type
    PListElem = ^TPriorityCellsList;
    TPriorityCellsList = Record
        Coord: ShortInt;
        Next: PListElem;
    End;
    Function CreateListElem(Coord: ShortInt): PListElem;
    Procedure AddListElem(var Header: PListElem; Coord: ShortInt);
    Function ExtractElem (var Header: PListElem): PListElem;
    Procedure DisposeList(var Header: PListElem);
    Function InitializeList(): PListElem;

Implementation
Function CreateListElem(Coord: ShortInt): PListElem;
Var
    NewElem: PListElem;
Begin
    New(NewElem);
    NewElem^.Coord := Coord;
    NewElem^.Next := Nil;
    CreateListElem := NewElem;
End;

Procedure AddListElem(var Header: PListElem; Coord: ShortInt);
Var
    Temp: PListElem;
Begin
    Temp := Header^.Next;
    Header^.Next := CreateListElem(Coord);
    Header^.Next^.Next := Temp;
End;

Function ExtractElem (var Header: PListElem): PListElem;
Var
    Temp: PListElem;
Begin
    If Header^.Next <> Nil Then
    Begin
        Temp := Header^.Next;
        Header^.Next := Temp^.Next;
        Temp^.Next := nil;
    End
    Else
        Temp := Nil;
    ExtractElem := Temp;
End;

Procedure DisposeList(var Header: PListElem);
Var
    Prev, Curr: PListElem;
Begin
    Curr := Header^.Next;
    While Curr <> Nil Do
    Begin
        Prev := Curr;
        Curr := Curr^.Next;
        Dispose(Prev);
    End;
    Header^.Next := Nil;
End;

Function InitializeList(): PListElem;
Var
    PriorityCellsListHeader: PListElem;
Begin
    New(PriorityCellsListHeader);
    PriorityCellsListHeader^.Next := Nil;

    InitializeList := PriorityCellsListHeader;
End;
End.
