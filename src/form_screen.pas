unit form_screen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, uRAM, fgl;

type
  TChangeList = specialize TFPGList<Word>;

type
  { TScreenForm }

  TScreenForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { private declarations }
  var
    w, cw, h, ch: integer;
    m_ram: TRAM;
    vram_start: word;
    bitmap: TBitmap;
    chgList: TChangeList;
  public
    procedure SetRAM(ram: TRAM);
    procedure SetVRAMStart(addr: word);
    procedure Refresh(vram_addr: word);
    { public declarations }
  end;

implementation

{$R *.lfm}

{ TScreenForm }

procedure TScreenForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  m_ram := nil;
  w := 80;
  cw := 9;
  h := 25;
  ch := 14;
  chgList := TChangeList.Create;

  Self.Width := w * cw;
  Self.Height := h * ch;

  bitmap := TBitmap.Create;
  bitmap.SetSize(self.Width, self.Height);
  //bitmap.PixelFormat:=TPixelFormat.pf24bit;
  bitmap.Canvas.Font := self.Font;
  bitmap.Canvas.Brush.Color := clBlack;
  bitmap.Canvas.Font.Color := clWhite;
  bitmap.Canvas.Font.Quality := TFontQuality.fqNonAntialiased;
end;

procedure TScreenForm.FormPaint(Sender: TObject);
var
  c, l: integer;
  b: byte;
  addr: word;
begin
  if m_ram = nil then
    exit;

  while chgList.Count <> 0 do
  begin
    addr := chgList[0];
    c := addr mod w;
    l := addr div w;
    b := m_ram.ReadByte(vram_start + addr);
    bitmap.Canvas.TextOut(c * cw, l * ch, AnsiToUtf8(char(b)));
    chgList.Delete(0);
  end;
  canvas.Draw(0, 0, bitmap);
end;

procedure TScreenForm.SetRAM(ram: TRAM);
begin
  self.m_ram := ram;
  bitmap.Canvas.FillRect(0, 0, bitmap.Width, bitmap.Height);
end;

procedure TScreenForm.SetVRAMStart(addr: word);
begin
  vram_start := addr;
end;


procedure TScreenForm.Refresh(vram_addr: word);
begin
  chgList.Add(vram_addr);
  //Repaint();
end;

end.
