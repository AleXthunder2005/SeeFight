Unit ManualUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
  TManualForm = Class(TForm)
    BackLabel: TLabel;
    RuleLabel: TLabel;
    DescribeLabel: TLabel;
    ConstructorInfoLabel: TLabel;
    BattleInfoLabel: TLabel;
    Procedure BackLabelMouseEnter(Sender: TObject);
    Procedure BackLabelMouseLeave(Sender: TObject);
    Procedure BackLabelClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
    ManualForm: TManualForm;
Implementation
{$R *.dfm}

Procedure TManualForm.BackLabelClick(Sender: TObject);
Begin
    ManualForm.Close;
End;

Procedure TManualForm.BackLabelMouseEnter(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClBlack;
    End;
End;

Procedure TManualForm.BackLabelMouseLeave(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClGrayText;
    End;
End;

Procedure TManualForm.FormCreate(Sender: TObject);
Begin
    DescribeLabel.Caption := '        Целью игры является полное уничтожение вражеского флота.';
    ConstructorInfoLabel.Caption := '        Для начала игры воспользуйтесь конструктором поля боя, чтобы расставить свои корабли. Перетаскивайте корабли с формы на поле, чтобы установить их. Чтобы повернуть или удалить корабль - нажмите ПКМ и выберите соответствующий пункт меню.';
    BattleInfoLabel.Caption := '        Расставив корабли, можно начинать игру! Чтобы нанести удар по полю соперника - кликните по ячейке на его поле. В течение игры, один раз вы можете использовать "Авиаудар", чтобы произвести по полю соперника выстрел 3x3 клетки.'
End;

End.
