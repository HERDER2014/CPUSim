unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, uRAM;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  rahm: TRam;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  rahm := TRam.create(64);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  rahm.WriteByte(1,3);
  rahm.WriteByte(2,232);
  rahm.ReadByte(5);
  Button1.caption := IntToStr(rahm.ReadByte(1));
end;

end.

