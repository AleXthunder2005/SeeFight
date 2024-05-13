program Sea_fight;

uses
  Vcl.Forms,
  StartUnit in 'StartUnit.pas' {StartForm},
  ConstructorUnit in 'ConstructorUnit.pas' {ConstructorForm},
  GridUnit in 'GridUnit.pas',
  FieldGeneratorUnit in 'FieldGeneratorUnit.pas',
  BattleUnit in 'BattleUnit.pas' {BattleForm},
  BattleDescribeUnit in 'BattleDescribeUnit.pas',
  ListUnit in 'ListUnit.pas',
  SettingsUnit in 'SettingsUnit.pas' {SettingsForm},
  ManualUnit in 'ManualUnit.pas' {ManualForm},
  AboutDeveloperUnit in 'AboutDeveloperUnit.pas' {AboutDeveloperForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TStartForm, StartForm);
  Application.CreateForm(TConstructorForm, ConstructorForm);
  Application.CreateForm(TBattleForm, BattleForm);
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.CreateForm(TManualForm, ManualForm);
  Application.CreateForm(TAboutDeveloperForm, AboutDeveloperForm);
  Application.Run;
end.
