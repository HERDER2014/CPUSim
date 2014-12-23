unit form_main;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, uCompiler, uRAM;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  comp: TCompiler;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  ram: TRAM;
begin
  ram := TRAM.Create(2 shl 16); // 2^16 bytes (2B-Adressen)
  comp := TCompiler.Create(ram);
  try
    comp.Compile(Memo1.Text);
  except
    on CE: TCompilerException do
    begin
      MessageDlg('Error while compiling', CE.Message, mtError, [mbOK], 0);
      exit;
    end;
  end;
  Button2.Enabled := True;
  ShowMessage('Compilation successful.'#13'Binary image size: '+IntToStr(comp.LastSize)+' bytes');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  comp.GetCodePosition(0);
end;

end.
