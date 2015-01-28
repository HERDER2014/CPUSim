unit asmHighlighter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, SynEditTypes, SynEditHighlighter;

type

  { TSynDemoHl }


  TAsmHighlighter = class(TSynCustomHighlighter)
  private
    fOPCodeAttri: TSynHighlighterAttributes;
    fRegisterAttri: TSynHighlighterAttributes;
    fNumberAttri: TSynHighlighterAttributes;
    fAdressAttri: TSynHighlighterAttributes;
    fCommentAttri: TSynHighlighterAttributes;
    fNormalAttri: TSynHighlighterAttributes;
    FCurRange: Integer;
    procedure SetOPCodeAttri(AValue: TSynHighlighterAttributes);
    procedure SetRegisterAttri(AValue: TSynHighlighterAttributes);
    procedure SetNumberAttri(AValue: TSynHighlighterAttributes);
    procedure SetAdressAttri(AValue: TSynHighlighterAttributes);
    procedure SetCommentAttri(AValue: TSynHighlighterAttributes);
    procedure SetNormalAttri(AValue: TSynHighlighterAttributes);
  protected
    // accesible for the other examples
    FTokenPos, FTokenEnd: Integer;
    FLineText: String;
  public
    procedure SetLine(const NewValue: String; LineNumber: Integer); override;
    procedure Next; override;
    function  GetEol: Boolean; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function  GetTokenAttribute: TSynHighlighterAttributes; override;
  public
    function GetToken: String; override;
    function GetTokenPos: Integer; override;
    function GetTokenKind: integer; override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
    constructor Create(AOwner: TComponent); override;
    procedure SetRange(Value: Pointer); override;
    procedure ResetRange; override;
    function GetRange: Pointer; override;
  published
    (* Define 4 Attributes, for the different highlights. *)
    property OPCodeAttri: TSynHighlighterAttributes read fOPCodeAttri
      write SetOPCodeAttri;
    property RegisterAttri: TSynHighlighterAttributes read fRegisterAttri
      write SetRegisterAttri;
    property NumberAttri: TSynHighlighterAttributes read fNumberAttri
      write SetNumberAttri;
    property AdressAttri: TSynHighlighterAttributes read fAdressAttri
      write SetAdressAttri;
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri
      write SetCommentAttri;
    property NormalAttri: TSynHighlighterAttributes read fNormalAttri
      write SetNormalAttri;
  end;

implementation

constructor TAsmHighlighter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  (* Create and initialize the attributes *)
  fOPCodeAttri := TSynHighlighterAttributes.Create('opCode', 'opCode');
  AddAttribute(fOPCodeAttri);
  fOPCodeAttri.Style := [fsBold];

  fRegisterAttri := TSynHighlighterAttributes.Create('register', 'register');
  AddAttribute(fRegisterAttri);
  fRegisterAttri.Foreground:=clRed;

  fNumberAttri := TSynHighlighterAttributes.Create('number', 'number');
  AddAttribute(fNumberAttri);
  fNumberAttri.Foreground:=clBlue;

  fAdressAttri := TSynHighlighterAttributes.Create('adress', 'adress');
  AddAttribute(fAdressAttri);
  fAdressAttri.Foreground:=clGreen;

  fCommentAttri := TSynHighlighterAttributes.Create('comment', 'comment');
  AddAttribute(fCommentAttri);
  fCommentAttri.Style := [fsItalic];
  fCommentAttri.Foreground:=clGray;

  fNormalAttri := TSynHighlighterAttributes.Create('normal', 'normal');
  AddAttribute(fNormalAttri);
end;

(* Setters for attributes / This allows using in Object inspector*)
procedure TAsmHighlighter.SetOPCodeAttri(AValue: TSynHighlighterAttributes);
begin
  fOPCodeAttri.Assign(AValue);
end;

procedure TAsmHighlighter.SetRegisterAttri(AValue: TSynHighlighterAttributes);
begin
  fRegisterAttri.Assign(AValue);
end;

procedure TAsmHighlighter.SetNumberAttri(AValue: TSynHighlighterAttributes);
begin
  fNumberAttri.Assign(AValue);
end;

procedure TAsmHighlighter.SetAdressAttri(AValue: TSynHighlighterAttributes);
begin
  fAdressAttri.Assign(AValue);
end;

procedure TAsmHighlighter.SetCommentAttri(AValue: TSynHighlighterAttributes);
begin
  fCommentAttri.Assign(AValue);
end;

procedure TAsmHighlighter.SetNormalAttri(AValue: TSynHighlighterAttributes);
begin
  fNormalAttri.Assign(AValue);
end;

procedure TAsmHighlighter.SetLine(const NewValue: String; LineNumber: Integer);
begin
  inherited;
  FLineText := NewValue;
  // Next will start at "FTokenEnd", so set this to 1
  FTokenEnd := 1;
  Next;
end;

procedure TAsmHighlighter.Next;
var
  l: Integer;
  i: Integer;
begin
  // FTokenEnd should be at the start of the next Token (which is the Token we want)
  FTokenPos := FTokenEnd;
  // assume empty, will only happen for EOL
  FTokenEnd := FTokenPos;

  // Scan forward
  // FTokenEnd will be set 1 after the last char. That is:
  // - The first char of the next token
  // - or past the end of line (which allows GetEOL to work)

  l := length(FLineText);
  If FTokenPos > l then
    // At line end
    exit
  else
  if FLineText[FTokenEnd] in [#9, ' ', ','] then
    // At Space? Find end of spaces
    while (FTokenEnd <= l) and (FLineText[FTokenEnd] in [#9, ' ', ',']) do inc (FTokenEnd)
  else if FLineText[FTokenEnd] = '[' then begin
    // At Address? Find end ]
    while (FTokenEnd <= l) and (FLineText[FTokenEnd] <> ']') do inc (FTokenEnd);
    inc (FTokenEnd);
  end
  else if FLineText[FTokenEnd] = ';' then
    // At Comment? Find end of line
    while (FTokenEnd <= l) do inc (FTokenEnd)
  else begin
    // At OPCode, Register or number? Find end of None-spaces
    while (FTokenEnd <= l) and not(FLineText[FTokenEnd] in [#9, ' ', ',', '[', ';', ':']) do inc (FTokenEnd);
    // At Label? Add : to Token
    if (FTokenEnd <= l) and (FLineText[FTokenEnd] = ':') then
       inc (FTokenEnd);
  end;
end;

function TAsmHighlighter.GetEol: Boolean;
begin
  Result := FTokenPos > length(FLineText);
end;

procedure TAsmHighlighter.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
begin
  TokenStart := @FLineText[FTokenPos];
  TokenLength := FTokenEnd - FTokenPos;
end;

function TAsmHighlighter.GetTokenAttribute: TSynHighlighterAttributes;
var i : Integer;
begin
  // Match the text, specified by FTokenPos and FTokenEnd

  if FLineText[FTokenPos] in [#9, ' '] then
    Result := NormalAttri
  else if FLineText[FTokenPos] = '[' then
    Result := AdressAttri
  else if FLineText[FTokenPos] = ';' then
    Result := CommentAttri
  else if FLineText[FTokenEnd-1] = ':' then
    Result := AdressAttri
  else
    case LowerCase(copy(FLineText, FTokenPos, FTokenEnd - FTokenPos)) of
      'mov','add','sub', 'mul', 'div', 'mod', 'cmp', 'jmp','jz','jnz','je','jne','js','jns','jo','jno','call','ret','push','pop','not','and','or','xor', 'in', 'out', 'inc', 'dec', 'org', 'end':
        Result:= OPCodeAttri;
      'ax','bx','cx','dx','al','bl','cl','dl','ah','bh','ch','dh','ip','sp','bp','flags':
        Result:= RegisterAttri;
      else begin
        if TryStrToInt('$'+copy(FLineText, FTokenPos, FTokenEnd - FTokenPos), i) then
          Result := NumberAttri
        else
          Result := NormalAttri;
      end;
    end;
end;

function TAsmHighlighter.GetToken: String;
begin
  Result := copy(FLineText, FTokenPos, FTokenEnd - FTokenPos);
end;

function TAsmHighlighter.GetTokenPos: Integer;
begin
  Result := FTokenPos - 1;
end;

function TAsmHighlighter.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
begin
  result:=nil;
end;

function TAsmHighlighter.GetTokenKind: integer;
var
  a: TSynHighlighterAttributes;
begin
  // Map Attribute into a unique number
  a := GetTokenAttribute;
  Result := 0;
  if a = fOPCodeAttri then Result := 1;
  if a = fAdressAttri then Result := 2;
  if a = fRegisterAttri then Result := 3;
  if a = fNumberAttri then Result := 4;
  if a = fCommentAttri then Result := 5;
end;

procedure TAsmHighlighter.SetRange(Value: Pointer);
begin
  // Set the current range (for current line)
  // The value is provided from an internal storage, where it was kept since the last scan
  // This is the and value of the previous line, which is used as start for the new line
  FCurRange := PtrInt(Value);
end;

procedure TAsmHighlighter.ResetRange;
begin
  FCurRange := 0;
end;

function TAsmHighlighter.GetRange: Pointer;
begin
  // Get a storable copy of the cuurent (working) range
  Result := Pointer(PtrInt(FCurRange));
end;

end.

