Unit AboutDeveloperUnit;
Interface
Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;
Type
  TAboutDeveloperForm = Class(TForm)
    BackLabel: TLabel;
    DeveloperLabel: TLabel;
    AboutDeveloperLabel: TLabel;
    Procedure BackLabelClick(Sender: TObject);
    Procedure BackLabelMouseEnter(Sender: TObject);
    Procedure BackLabelMouseLeave(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
    AboutDeveloperForm: TAboutDeveloperForm;

Implementation
{$R *.dfm}
Procedure TAboutDeveloperForm.BackLabelClick(Sender: TObject);
Begin
    AboutDeveloperForm.Close;
End;

Procedure TAboutDeveloperForm.BackLabelMouseEnter(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClBlack;
    End;
End;

Procedure TAboutDeveloperForm.BackLabelMouseLeave(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClGrayText;
    End;
End;

Procedure TAboutDeveloperForm.FormCreate(Sender: TObject);
Begin
    AboutDeveloperLabel.Caption := 'Студент гр. 351004, Наривончик Александр';
End;

End.
