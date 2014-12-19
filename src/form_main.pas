unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus;

type

  { TmainFrm }

  TmainFrm = class(TForm)
    Button1: TButton;
    MainFrm_Menu: TMainMenu;
    MainFrm_Menu_File: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  mainFrm: TmainFrm;

implementation

{$R *.lfm}

{ TmainFrm }

procedure TmainFrm.FormCreate(Sender: TObject);
begin

end;

procedure TmainFrm.Button1Click(Sender: TObject);
begin

end;

end.

