unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynCompletion, RTTICtrls,
  Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, LCLType, ExtCtrls,
  ValEdit, Grids, ActnList, StdActns, Spin, uRAM, uCPU,
  uCompiler, form_options, uCPUThread, strutils, uTypen,
  asmHighlighter, types, lclintf, Math, form_screen, SynEditMarks;

type

  { TmainFrm }

  TmainFrm = class(TForm)
    A1: TEdit;
    A2: TEdit;
    ClearLogBtn: TButton;
    FileNew: TAction;
    FileSave: TAction;
    Button1: TButton;
    FLAGS1: TEdit;
    ActionList: TActionList;
    AssembleBtn: TButton;
    B1: TEdit;
    Flag_O: TCheckBox;
    Flag_K: TCheckBox;
    Flag_S: TCheckBox;
    Flag_Z: TCheckBox;
    EditCopyAct: TEditCopy;
    EditCutAct: TEditCut;
    EditPasteAct: TEditPaste;
    EditUndoAct: TEditUndo;
    FileOpenAct: TFileOpen;
    FileSaveAsAct: TFileSaveAs;
    H_Menu_CodeSplitter: TSplitter;
    ImageList1: TImageList;
    IP2: TEdit;
    IP1: TEdit;
    WaitingMessageLbl: TLabel;
    Label9: TLabel;
    MainFrm_Menu_Options: TMenuItem;
    Panel1: TPanel;
    VP2: TEdit;
    VP1: TEdit;
    BP1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Log_lb: TListBox;
    RunPauseBtn: TButton;
    SearchFindAct: TSearchFind;
    SP2: TEdit;
    BP2: TEdit;
    B2: TEdit;
    SP1: TEdit;
    C2: TEdit;
    C1: TEdit;
    D2: TEdit;
    D1: TEdit;
    RAMGrid: TStringGrid;
    FileExitAct: TFileExit;
    FrequencyType: TComboBox;
    MainFrm_Menu: TMainMenu;
    MainFrm_Menu_File: TMenuItem;
    MainFrm_Menu_File_New: TMenuItem;
    MainFrm_Menu_Edit: TMenuItem;
    MainFrm_Menu_Edit_Undo: TMenuItem;
    MainFrm_Menu_Edit_Redo: TMenuItem;
    MainFrm_Menu_Edit_Spacer1: TMenuItem;
    MainFrm_Menu_Edit_Cut: TMenuItem;
    MainFrm_Menu_Edit_Copy: TMenuItem;
    MainFrm_Menu_Edit_Paste: TMenuItem;
    MainFrm_Menu_File_Spacer1: TMenuItem;
    MainFrm_Menu_Help: TMenuItem;
    MainFrm_Menu_Help_Wiki: TMenuItem;
    MainFrm_Menu_Help_Tutorial: TMenuItem;
    MainFrm_Menu_Help_Spacer1: TMenuItem;
    MainFrm_Menu_Help_About: TMenuItem;
    MainFrm_Menu_File_Open: TMenuItem;
    MainFrm_Menu_File_Save: TMenuItem;
    MainFrm_Menu_File_SaveAs: TMenuItem;
    MainFrm_Menu_File_Spacer2: TMenuItem;
    MainFrm_Menu_File_Exit: TMenuItem;
    ReplaceDialog1: TReplaceDialog;
    speedEdt: TFloatSpinEdit;
    Splitter1: TSplitter;
    StepBtn: TButton;
    StepOverBtn: TButton;
    Timer1: TTimer;
    InputSynEdit: TSynEdit;
    RAMValueList: TValueListEditor;
    procedure AssembleBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ClearLogBtnClick(Sender: TObject);
    procedure compileClick(Sender: TObject);
    procedure FileOpenActAccept(Sender: TObject);
    procedure FileSaveAsActAccept(Sender: TObject);
    //function FileSave_ExitActExecute(Sender: TObject) : Boolean;
    function FileExitActExecute(Sender: TObject): boolean;
    procedure FileSaveExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormResize(Sender: TObject);
    procedure FrequencyTypeChange(Sender: TObject);
    procedure InputSynEditGutterClick(Sender: TObject; X, Y, Line: integer;
      mark: TSynEditMark);
    procedure MainFrm_Menu_Help_TutorialClick(Sender: TObject);
    procedure Log_lbDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure MainFrm_Menu_OptionsClick(Sender: TObject);
    procedure FileNewExecute(Sender: TObject);
    procedure RAMGridSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure RunPauseBtnClick(Sender: TObject);
    procedure InputSynEditChange(Sender: TObject);
    procedure InputSynEditSpecialLineColors(Sender: TObject; Line: integer;
      var Special: boolean; var FG, BG: TColor);
    procedure MainFrm_Menu_Edit_CopyClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_CutClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_PasteClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_RedoClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_UndoClick(Sender: TObject);
    procedure MainFrm_Menu_File_NewClick(Sender: TObject);
    procedure MainFrm_Menu_File_OpenRecentClick(Sender: TObject);
    procedure MainFrm_Menu_File_SaveAsClick(Sender: TObject);
    procedure MainFrm_Menu_Help_AboutClick(Sender: TObject);
    procedure MainFrm_Menu_Help_WikiClick(Sender: TObject);
    procedure DoCompile;
    procedure RAMGridDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure RunClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MainFrm_Menu_File_SaveClick(Sender: TObject);
    procedure OnCPUTerminate(Sender: TObject);
    //procedure SearchFindActAccept(Sender: TObject);
    //procedure SearchFindActBeforeExecute(Sender: TObject);
    procedure speedEdtChange(Sender: TObject);
    procedure StepBtnClick(Sender: TObject);
    procedure StepOverBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure TFindDialogFind(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure setupRAM;
    procedure updateREG;
    procedure resume;
    procedure Step;
    procedure StepOver;
    procedure Stop;
    procedure setVel;
    procedure OnRAMChange(addr: word);
  private
    screenForm: TScreenForm;
  public
    { public declarations }
    RAMSize: cardinal;
    VRAMSize: cardinal;
    numInMode: TNumberInputMode;
    assembled: boolean;
    CPU: TCPU;
    ClearLog :Boolean;
    ShowBreakpoints : Boolean; //unimplemented
    trackTime: boolean;    // true when elapsed time should be printed; the time will *always* be tracked
  end;

var
  comp: TCompiler;
  mainFrm: TmainFrm;
  SavePath: string;
  Saved: boolean;
  startTime: QWord;
  drawCodeIPHighlighting: boolean;
  Thread: TCPUThread;
  hlt: TAsmHighlighter;
  RAM: TRAM;
  // 0, wenn nicht bereit für Play/StepBtn -- 1, wenn kompiliert und initialisiert,
  // bereit für Play/StepBtn -- 2, wenn play aktiv, bereit für StopBtn
  RAMSize: cardinal;
  oldIP: word;
  oldBP: word;
  oldSP: word;
  oldVP: word;
  oldHl: longInt;
  closeOnStop: Boolean;
  SelectedLineFromRam: Cardinal;
  SelectedCellFromRam: word;
  CPUCreated: Boolean;
  ThreadCreated: Boolean;
const
  InitCaption = 'Herder CPU Simulator';
implementation

{$R *.lfm}

{ TmainFrm }

procedure TmainFrm.FormCreate(Sender: TObject);
begin
  screenForm := TScreenForm.Create(self);

  InputSynEdit.ClearAll;

  hlt := TAsmHighlighter.Create(self);
  InputSynEdit.Highlighter := hlt;
  numInMode:=Hexadecimal;

  RAMSize := 1024;
  VRAMSize := 128;
  Saved := True; // Don't ask for save when program just started
  assembled := False;
  InputSynEdit.ReadOnly := False;
  InputSynEdit.Color := clWhite;
  CPUCreated:=false;
  CPUCreated:=false;
  trackTime:=false;
  closeOnStop:=false;
  InputSynEdit.TabWidth:=4;
  if (Paramcount > 0) and (FileExists(ParamStr(1))) then
  begin
    InputSynEdit.Lines.LoadFromFile(ParamStr(1));
    SavePath:=ParamStr(1);
    Caption:= InitCaption + ' - ' + SavePath;
  end;
  if (Paramcount > 1) and (ParamStr(2) = 'true') then
  begin
    AssembleBtnClick(nil);
    closeOnStop:=true;
  end;
end;

procedure TmainFrm.DoCompile;
var
  temp_savepath : String;
  i : word;
  warning : string;
begin
  try
    {$IFDEF Windows}
      temp_savepath:='temp.asm';
    {$ELSE}
      temp_savepath:='/tmp/temp.asm';
    {$ENDIF}
    if SavePath = '' then
     InputSynEdit.Lines.SaveToFile(temp_savepath)
    else
      MainFrm_Menu_File_SaveClick(nil);
  except
      Log_lb.Items.Insert(0, '[warning] Program could not be saved.');
  end;

  if RAM <> nil then
  begin
    RAM.Destroy;
    //WriteLn('ram destr');
  end;
  if comp <> nil then
  begin
    comp.Destroy;
    //WriteLn('comp destr');
  end;


  if (Trim(UpperCase(InputSynEdit.Lines[0])) = 'SNAKE') then
  begin
    //this is the snake source code but just hard coded...
    InputSynEdit.Text := ';#RAM: 1024' + sLineBreak + ';#VRAM: 2000' + sLineBreak + ';#CLOCK: 2' +
    sLineBreak + ';#CLOCK_UNIT: kHz' + sLineBreak + '' + sLineBreak + '' + sLineBreak +
    '; VRAM Size: 2000' + sLineBreak + '; Taktung: 1 KHz' + sLineBreak + '' +
    sLineBreak + 'jmp start' + sLineBreak + '' + sLineBreak + 'spawnpoints:' +
    sLineBreak + 'db 1,0F, 5,80, 7,41, 5,b8, 2,16, 3,e0, 4,67, 5,7d, 6,b1, 2,8d,5,bf,6,83' +
    sLineBreak + 'db 2,a5,2,2d,2,d7,5,22,2,7c,0,66,0,35,6,13, 0, 0' + sLineBreak +
    '' + sLineBreak + 'snakepos:  ;pos, dir, len' + sLineBreak + 'db 0, 0' +
    sLineBreak + '' + sLineBreak + 'snakedir:' + sLineBreak + 'db 0, 1' + sLineBreak +
    '' + sLineBreak + 'snakelen:' + sLineBreak + 'db 5' + sLineBreak + '' + sLineBreak +
    'queuepos:' + sLineBreak + 'db 0' + sLineBreak + '' + sLineBreak + 'randompos:' +
    sLineBreak + 'db 0, 0' + sLineBreak + '' + sLineBreak + 'gameovermessage:' +
    sLineBreak + 'db "GAME OVER", 0' + sLineBreak + 'db "Points: ", 0' + sLineBreak + '' +
    sLineBreak + 'start:' + sLineBreak + '' + sLineBreak + 'MOV AX,VP' + sLineBreak +
    'ADD AX,7D0' + sLineBreak + '' + sLineBreak + 'initloop0:' + sLineBreak + '  DEC AX' +
    sLineBreak + '  MOVB [AX],20' + sLineBreak + '  CMP AX,VP' + sLineBreak +
    'JNZ initloop0' + sLineBreak + '' + sLineBreak + 'MOV AX, 4F' + sLineBreak +
    'initloop1:' + sLineBreak + '  MOV BX,AX' + sLineBreak + '  ADD BX,VP' +
    sLineBreak + '  MOVB [BX],23' + sLineBreak + '  ADD BX, 780' + sLineBreak +
    '  MOVB [BX],23' + sLineBreak + '  DEC AX' + sLineBreak + 'JNS initloop1' +
    sLineBreak + '' + sLineBreak + 'MOV AX,780' + sLineBreak + 'initloop2:' + sLineBreak +
    '  MOV BX,AX' + sLineBreak + '  ADD BX,VP' + sLineBreak + '  MOVB [BX],23' +
    sLineBreak + '  ADD BX, 4F' + sLineBreak + '  MOVB [BX],23' + sLineBreak +
    '  SUB AX, 50' + sLineBreak + 'JNZ initloop2' + sLineBreak + '' + sLineBreak +
    '' + sLineBreak + 'MOV AX, VP   ; \ Start' + sLineBreak + 'ADD AX, 3E8  ; / Position' +
    sLineBreak + 'MOV [snakepos], AX' + sLineBreak + '' + sLineBreak + 'MOV AX, randompos' +
    sLineBreak + 'MOV AX, [AX]' + sLineBreak + 'MOV BX, spawnpoints' + sLineBreak +
    'ADD AX,BX' + sLineBreak + 'MOV AX, [AX]' + sLineBreak + 'ADD AX, VP' + sLineBreak +
    'MOVB [AX], 4F' + sLineBreak + '' + sLineBreak + 'loop:' + sLineBreak + '' +
    sLineBreak + '  ;---- collision detection' + sLineBreak + '  MOV AX, snakepos' +
    sLineBreak + '  MOV AX, [AX]' + sLineBreak + '  MOVB BL,[AX]' + sLineBreak +
    '  CMP BL, 4F' + sLineBreak + '  JNZ noCoin' + sLineBreak + '' + sLineBreak +
    '  ;---- coin' + sLineBreak + '  coin:' + sLineBreak + '  MOV BX, randompos' +
    sLineBreak + '  MOV AX, [BX]' + sLineBreak + '  ADD AX, 02' + sLineBreak +
    '  MOV [BX],AX' + sLineBreak + '  MOV BX, spawnpoints' + sLineBreak +
    '  ADD AX,BX' + sLineBreak + '  MOV AX, [AX]' + sLineBreak + '  CMP AX, 00' +
    sLineBreak + '  JZ newcoin' + sLineBreak + '  ADD AX, VP' + sLineBreak +
    '  MOVB [AX], 4F' + sLineBreak + '' + sLineBreak + '  MOV BX, snakelen' +
    sLineBreak + '  MOVB AL, [BX]' + sLineBreak + '  INC AL' + sLineBreak +
    '  MOVB [BX],AL' + sLineBreak + '' + sLineBreak + '  JMP afterCoin' + sLineBreak +
    '' + sLineBreak + '  newcoin:' + sLineBreak + '  MOV BX, randompos' + sLineBreak +
    '  MOV [BX], 0' + sLineBreak + '  JMP coin' + sLineBreak + '' + sLineBreak +
    '  ;---- wall' + sLineBreak + '  noCoin:' + sLineBreak + '' + sLineBreak +
    '  CMP BL, 20' + sLineBreak + '  JNZ ende' + sLineBreak + '' + sLineBreak +
    '  afterCoin:' + sLineBreak + '  ; Snake queue' + sLineBreak + '' + sLineBreak +
    '' + sLineBreak + '  ;---- snake saving' + sLineBreak + '  MOV AX,queuepos' +
    sLineBreak + '  MOVB AX, [AX]' + sLineBreak + '  MOV BX, snakepos' + sLineBreak +
    '  MOV BX, [BX]' + sLineBreak + '  ADD AX, snakearraypos' + sLineBreak +
    '  MOV [AX], BX' + sLineBreak + '' + sLineBreak + '  ;---- snake removal' +
    sLineBreak + '  MOV AX, queuepos' + sLineBreak + '  MOVB AL, [AX]' + sLineBreak +
    '  MOV BX, snakelen' + sLineBreak + '  MOVB BL, [BX]' + sLineBreak +
    '  SUB AL, BL' + sLineBreak + '  SUB AL, BL' + sLineBreak + '  ADD AX, snakearraypos' +
    sLineBreak + '  MOV CX, [AX]' + sLineBreak + '  MOVB [CX], 20' + sLineBreak +
    '' + sLineBreak + '  ;---- snake saving queue update' + sLineBreak +
    '  MOV BX, queuepos' + sLineBreak + '  MOVB AL,[BX]' + sLineBreak + '  ADD AL, 02' +
    sLineBreak + '  MOVB [BX], AL' + sLineBreak + '' + sLineBreak + '  ;---- Display' +
    sLineBreak + '  MOV AX, snakepos' + sLineBreak + '  MOV AX, [AX]' + sLineBreak +
    '  MOVB [AX],2B' + sLineBreak + '' + sLineBreak + '  ;---- Movement' + sLineBreak +
    '  MOV BX, snakedir' + sLineBreak + '  MOV BX, [BX]' + sLineBreak +
    '  ADD AX, BX    ; Movement' + sLineBreak + '  MOV CX, snakepos' + sLineBreak +
    '  MOV [CX], AX' + sLineBreak + '' + sLineBreak + '' + sLineBreak + '  ;---- slow down loop' +
    sLineBreak + '  MOV AX,F0' + sLineBreak + '  wloop:' + sLineBreak + '    DEC AX' +
    sLineBreak + '  JNZ wloop' + sLineBreak + '' + sLineBreak + '  ;---- keyboard input' +
    sLineBreak + '  jnk KeyEnd' + sLineBreak + '' + sLineBreak + '  in AX' + sLineBreak + '' +
    sLineBreak + '  cmp AX,57' + sLineBreak + '  jz up' + sLineBreak + '' + sLineBreak +
    '  cmp AX,77' + sLineBreak + '  jz up' + sLineBreak + '' + sLineBreak + '  cmp AX,41' +
    sLineBreak + '  jz left' + sLineBreak + '' + sLineBreak + '  cmp AX,61' + sLineBreak +
    '  jz left' + sLineBreak + '' + sLineBreak + '  cmp AX,53' + sLineBreak +
    '  jz down' + sLineBreak + '' + sLineBreak + '  cmp AX,73' + sLineBreak +
    '  jz down' + sLineBreak + '' + sLineBreak + '  cmp AX,44' + sLineBreak + '  jz right' +
    sLineBreak + '' + sLineBreak + '  cmp AX,64' + sLineBreak + '  jz right' +
    sLineBreak + '' + sLineBreak + '  KeyEnd:' + sLineBreak + '' + sLineBreak + 'jmp loop' +
    sLineBreak + ';================' + sLineBreak + '' + sLineBreak + 'left:' +
    sLineBreak + 'mov CX, snakedir' + sLineBreak + 'mov [CX], FFFF' + sLineBreak +
    'jmp KeyEnd' + sLineBreak + '' + sLineBreak + 'right:' + sLineBreak + 'mov CX, snakedir' +
    sLineBreak + 'mov [CX], 1' + sLineBreak + 'jmp KeyEnd' + sLineBreak + '' +
    sLineBreak + 'up:' + sLineBreak + 'mov CX, snakedir' + sLineBreak + 'mov [CX], FFB0' +
    sLineBreak + 'jmp KeyEnd' + sLineBreak + '' + sLineBreak + 'down:' + sLineBreak +
    'mov CX, snakedir' + sLineBreak + 'mov [CX], 50' + sLineBreak + 'jmp KeyEnd' +
    sLineBreak + '' + sLineBreak + 'ende:' + sLineBreak + '' + sLineBreak + 'ADD VP, AA' +
    sLineBreak + 'MOV CX, VP' + sLineBreak + 'MOV AX,gameovermessage' + sLineBreak +
    'endloop1:' + sLineBreak + 'MOVB BX,[AX]' + sLineBreak + 'INC AX' + sLineBreak +
    'CMP BX,0' + sLineBreak + 'JZ endloop2start' + sLineBreak + 'OUT BX' + sLineBreak +
    'jmp endloop1' + sLineBreak + '' + sLineBreak + 'endloop2start:' + sLineBreak +
    'MOV VP, CX' + sLineBreak + 'ADD VP, 50' + sLineBreak + '' + sLineBreak +
    'endloop2:' + sLineBreak + 'MOVB BX,[AX]' + sLineBreak + 'INC AX' + sLineBreak +
    'CMP BX,0' + sLineBreak + 'JZ punktzahlausgabe' + sLineBreak + 'OUT BX' +
    sLineBreak + 'jmp endloop2' + sLineBreak + '' + sLineBreak + 'punktzahlausgabe:' +
    sLineBreak + '' + sLineBreak + 'MOV AX,snakelen' + sLineBreak + 'MOVB AX,[AX]' +
    sLineBreak + 'SUB AX,5' + sLineBreak + 'PUSH AX' + sLineBreak + 'CALL mehrstelligeAusgabe' +
    sLineBreak + 'POP' + sLineBreak + '' + sLineBreak + 'end' + sLineBreak + '' + sLineBreak +
    '' + sLineBreak + 'mehrstelligeAusgabe:' + sLineBreak + 'push BP' + sLineBreak +
    'mov BP, SP' + sLineBreak + '  mov ax, [BP + 5]' + sLineBreak + '  ;zahl aufteilen' +
    sLineBreak + '  msAaufteilen:' + sLineBreak + '  cmp ax, 0A' + sLineBreak +
    '  js msAausgabe1  ;wenn ax kleiner als 10 ist, ax pushen und die Zahl ausgeben' + sLineBreak
    +
    '  mod bx, 0A' + sLineBreak + '  push bx      ;diese pushen' + sLineBreak +
    '  sub ax, bx' + sLineBreak + '  div ax, 0A   ;diese "eintfernen" und neu aufteilen' +
    sLineBreak + '  jmp msAaufteilen' + sLineBreak + '' + sLineBreak +
    '  ;gepushte Zahl ausgeben' + sLineBreak + '  msAausgabe1:' + sLineBreak +
    '  push ax      ;ax pushen, um alles auszugeben' + sLineBreak + '  msAausgabe:' +
    sLineBreak + '  cmp SP, BP   ;wenn der stack leer ist, nichts mehr ausgeben' +
    sLineBreak + '  jz msAende' + sLineBreak + '  pop ax       ;in ax poppen' +
    sLineBreak + '  add ax, 30' + sLineBreak + '  out ax' + sLineBreak + '  jmp msAausgabe' +
    sLineBreak + '' + sLineBreak + '  msAende:' + sLineBreak + '  mov SP, BP' +
    sLineBreak + '  pop BP' + sLineBreak + '  ret' + sLineBreak + '' + sLineBreak +
    'snakearraypos:' + sLineBreak + ';keep 256 bytes free';
  end;

  i:= 0;
  while (LeftStr(InputSynEdit.Lines[i],2) = ';#') do
  begin
    if (LeftStr(InputSynEdit.Lines[i], 6) = ';#RAM:') then begin
      RAMSize:=StrToInt(Trim(MidStr(InputSynEdit.Lines[i],7,20)));
      //OptionsFrm.setRAMSize(RAMSize);
    end else if (LeftStr(InputSynEdit.Lines[i], 7) = ';#VRAM:') then begin
      VRAMSize:=StrToInt(Trim(MidStr(InputSynEdit.Lines[i],8,20)));
      //OptionsFrm.setVRAMSize(VRAMSize);
    end else if (LeftStr(InputSynEdit.Lines[i], 8) = ';#CLOCK:') then begin
      speedEdt.Value:=StrToFloat(Trim(MidStr(InputSynEdit.Lines[i],9,20)));
    end else if (LeftStr(InputSynEdit.Lines[i], 13) = ';#CLOCK_UNIT:') then begin
      case UpperCase(Trim(MidStr(InputSynEdit.Lines[i],14,20))) of
        'HZ' : FrequencyType.ItemIndex:=0;
        'KHZ': FrequencyType.ItemIndex:=1;
        'MHZ': FrequencyType.ItemIndex:=2;
        'MAX': FrequencyType.ItemIndex:=3;
      end;
    end;
    inc(i);
  end;


  RAM := TRAM.Create(RAMSize + VRAMSize, RAMSize);
  //WriteLn('ram created');
  comp := TCompiler.Create(RAM);
  //WriteLn('comp created');
  comp.NumberInputMode := numInMode;
  try
    comp.Compile(InputSynEdit.Text);
    for warning in comp.GetWarnings() do begin
      Log_lb.Items.Insert(0, '[warning] ' + warning);
    end;
    Log_lb.Items.Insert(0, '[success] compilation completed');
    CPU := TCPU.Create(RAM);
    CPUcreated:=true;
    //WriteLN('cpu created');
    Thread := TCPUThread.Create(CPU);
    Threadcreated:=true;
    //WriteLn('cputhread created');
    Thread.OnTerminate := @OnCPUTerminate;
    assembled := True;
    Caption:= Caption + ' (assembled)';
    //trackTime := True;
    drawCodeIPHighlighting := True;
    InputSynEdit.ReadOnly := True;
    InputSynEdit.Color := clSilver;

    oldIP := CPU.ReadRegister(RegisterIndex.IP);
    oldBP := CPU.ReadRegister(RegisterIndex.BP);
    oldSP := CPU.ReadRegister(RegisterIndex.SP);
    oldVP := CPU.ReadRegister(RegisterIndex.VP);
    oldHl := -1;

    InputSynEdit.Invalidate;
    setupRAM;
    RAM.ChangeCallback := @OnRAMChange;

    for i := 0 to RAM.GetSize() - 1 do begin
      RAM.setBreakpoint(i,InputSynEdit.Marks.Line[comp.GetCodePosition(i)] <> nil);
    end;

  except
    on e: Exception do
      Log_lb.Items.Insert(0, '[error] compilation failed: ' + e.Message);
  end;
end;

procedure TmainFrm.RAMGridDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (aCol > 0) and (aRow > 0) then
  begin
    with TStringGrid(Sender) do
    begin
      if (aCol - 1) + ((aRow - 1) shl 4) = oldIP then
      begin
        Canvas.Brush.Color := clYellow;
      end
      else if (aCol - 1) + ((aRow - 1) shl 4) = oldBP then
      begin
        Canvas.Brush.Color := $FF8888;
      end
      else if (aCol - 1) + ((aRow - 1) shl 4) = oldSP then
      begin
        Canvas.Brush.Color := clGreen;
      end
      else if (aCol - 1) + ((aRow - 1) shl 4) = oldVP then
      begin
        Canvas.Brush.Color := clLime;
      end
      else if assembled then begin
        if ((aCol - 1) + ((aRow - 1) shl 4) = CPU.getHighlightAddress()) then
        begin
          Canvas.Brush.Color := $FF69FF;
        end;
      end
      else if (aCol - 1) + ((aRow - 1) shl 4) = SelectedCellFromRam then
      begin
        Canvas.Brush.Color:= $FF9933;
      end
      else
      begin
        Canvas.Brush.Color:= $FFFFFF;
      end;
      Canvas.FillRect(aRect);
      Canvas.TextOut(aRect.Left + 2, aRect.Top + 2, Cells[ACol, ARow]);
    end;
  end;
end;

procedure TmainFrm.RunClick(Sender: TObject);
begin
  DoCompile;
  resume;
end;


procedure TmainFrm.setupRAM;
var
  i: cardinal;
begin
  RAMGrid.RowCount := (RAMSize + VRAMSize - 1) div 16 + 2;
  for i := 0 to RAMSize + VRAMSize - 1 do
  begin
    RAMGrid.Cells[i and 15 + 1, i shr 4 + 1] := IntToHex(Byte(Ram.ReadByte(i)), 2);
  end;
  for i := 1 to RAMGrid.RowCount - 1 do
  begin
    RAMGrid.Cells[0, i] := IntToHex((i - 1) shl 4, 4);
  end;
  screenForm.SetRAM(Ram);
  screenForm.SetVRAMStart(cpu.ReadRegister(RegisterIndex.VP));
end;

procedure TmainFrm.updateREG;
var
  newIP: word;
  newBP: word;
  newSP: word;
  newVP: word;
  newHl: longint;
begin
  newIP := CPU.ReadRegister(RegisterIndex.IP);
  newBP := CPU.ReadRegister(RegisterIndex.BP);
  newSP := CPU.ReadRegister(RegisterIndex.SP);
  newVP := CPU.ReadRegister(RegisterIndex.VP);
  newHl := CPU.getHighlightAddress();

  if (newIP <> oldIP) then
  begin
    RAMGrid.InvalidateCell(oldIP and 15 + 1, oldIP shr 4 + 1);
    InputSynEdit.InvalidateLine(comp.GetCodePosition(oldIP));
    oldIP := newIP;
    RAMGrid.InvalidateCell(oldIP and 15 + 1, oldIP shr 4 + 1);
    InputSynEdit.Invalidate;
    InputSynEdit.InvalidateLine(comp.GetCodePosition(oldIP));
  end;

  if (newBP <> oldBP) then
  begin
    RAMGrid.InvalidateCell(oldBP and 15 + 1, oldBP shr 4 + 1);
    oldBP := newBP;
    RAMGrid.InvalidateCell(oldBP and 15 + 1, oldBP shr 4 + 1);
  end;

  if (newSP <> oldSP) then
  begin
    RAMGrid.InvalidateCell(oldSP and 15 + 1, oldSP shr 4 + 1);
    oldSP := newSP;
    RAMGrid.InvalidateCell(oldSP and 15 + 1, oldSP shr 4 + 1);
  end;

  if (newVP <> oldVP) then
  begin
    RAMGrid.InvalidateCell(oldVP and 15 + 1, oldVP shr 4 + 1);
    oldVP := newVP;
    RAMGrid.InvalidateCell(oldVP and 15 + 1, oldVP shr 4 + 1);
  end;

  if (newHl <> oldHl) then
  begin
    if oldHl <> -1 then
       RAMGrid.InvalidateCell(oldHl and 15 + 1, oldHl shr 4 + 1);
    oldHl:=newHl;
    if oldHl <> -1 then
       RAMGrid.InvalidateCell(oldHl and 15 + 1, oldHl shr 4 + 1);
  end;


  A1.Text := IntTOBin(CPU.ReadRegister(AX), 16, 8);
  A2.Text := IntToHex(CPU.ReadRegister(AX), 4);
  B1.Text := IntTOBin(CPU.ReadRegister(BX), 16, 8);
  B2.Text := IntToHex(CPU.ReadRegister(BX), 4);
  C1.Text := IntTOBin(CPU.ReadRegister(CX), 16, 8);
  C2.Text := IntToHex(CPU.ReadRegister(CX), 4);
  D1.Text := IntTOBin(CPU.ReadRegister(DX), 16, 8);
  D2.Text := IntToHex(CPU.ReadRegister(DX), 4);
  IP1.Text := IntTOBin(CPU.ReadRegister(IP), 16, 8);
  IP2.Text := IntToHex(CPU.ReadRegister(IP), 4);
  SP1.Text := IntTOBin(CPU.ReadRegister(SP), 16, 8);
  SP2.Text := IntToHex(CPU.ReadRegister(SP), 4);
  BP1.Text := IntTOBin(CPU.ReadRegister(BP), 16, 8);
  BP2.Text := IntToHex(CPU.ReadRegister(BP), 4);
  VP1.Text := IntTOBin(CPU.ReadRegister(VP), 16, 8);
  VP2.Text := IntToHex(CPU.ReadRegister(VP), 4);
  FLAGS1.Text := IntToBin(CPU.ReadRegister(FLAGS), 16, 8);
  Flag_S.Checked := (CPU.ReadRegister(FLAGS) and integer(S)) > 0;
  Flag_Z.Checked := (CPU.ReadRegister(FLAGS) and integer(Z)) > 0;
  Flag_O.Checked := (CPU.ReadRegister(FLAGS) and integer(O)) > 0;
  Flag_K.Checked := (CPU.ReadRegister(FLAGS) and integer(K)) > 0;

  //  F1.Text := IntTOBin(CPU.ReadRegister(FLAGS), 16, 8);
  //   F2.Text := IntToHex(CPU.ReadRegister(FLAGS), 4);
end;

procedure TmainFrm.resume;
begin
  setVel;
  Thread.Fortsetzen;
end;

procedure TmainFrm.OnCPUTerminate(Sender: TObject);
begin
  //TODO
  if (Thread.getException() = '') then
  begin
    if mainFrm.trackTime then
      Log_lb.Items.Insert(0, '[success] simulation ended in ' +
        FloatToStr(round(Thread.getElapsedTime() * 100000) / 100) +
        ' ms and executed ' + IntToStr(Thread.getBefehlCount()) + ' OP-codes.')
    else
      Log_lb.Items.Insert(0, '[success] simulation ended');
  end
  else
  begin
    Log_lb.Items.Insert(0, '[error] simulation failed on line ' +
      IntToStr(comp.GetCodePosition(cpu.ReadRegister(IP))) + ' (Address ' +
      IntToHex(cpu.ReadRegister(IP), 4) + '): ' + Thread.getException());
  end;

  WaitingMessageLbl.Caption := '';

  InputSynEdit.ReadOnly := False;
  InputSynEdit.Color := clWhite;
  assembled := False;
  if (SavePath <> '') then
    Caption:= InitCaption + ' - ' + SavePath
  else
    Caption:= InitCaption;

  RunPauseBtn.Enabled := False;
  speedEdt.Enabled := False;
  FrequencyType.Enabled := False;
  StepBtn.Enabled := False;
  MainFrm_Menu_Edit.Enabled := true;
  StepOverBtn.Enabled := False;
  AssembleBtn.Caption := 'Assemble';
  RunPauseBtn.Caption := 'Run';
  RunPauseBtn.Hint := 'Runs the program';
end;

//procedure TmainFrm.SearchFindActAccept(Sender: TObject);
//begin

//end;

//procedure TmainFrm.SearchFindActBeforeExecute(Sender: TObject);
//begin
//end;

procedure TmainFrm.speedEdtChange(Sender: TObject);
begin
  if assembled then
  begin
    setVel;
  end;
end;

procedure TmainFrm.StepBtnClick(Sender: TObject);
begin
  //WriteLn('step clk');
  Timer1.Enabled := True;

  Step;
  RunPauseBtn.Caption := 'Run';
  RunPauseBtn.Hint := 'Runs the program';
  //trackTime := False;
end;

procedure TmainFrm.StepOverBtnClick(Sender: TObject);
begin
  //WriteLn('stebO clk');
  Timer1.Enabled := True;

  StepOver;
  RunPauseBtn.Caption := 'Run';
  RunPauseBtn.Hint:= 'Runs the program';
  //trackTime := False;
end;

procedure TmainFrm.StopBtnClick(Sender: TObject);
begin
  //WriteLn('stop clk');
  Stop;
  //trackTime := False;
end;

procedure TmainFrm.FrequencyTypeChange(Sender: TObject);
begin
  if FrequencyType.ItemIndex = 3 then
  begin
    speedEdt.Enabled := False;
  end
  else
  begin
    speedEdt.Enabled := True;
  end;
  if assembled then
    setVel;
end;

procedure TmainFrm.InputSynEditGutterClick(Sender: TObject; X, Y,
  Line: integer; mark: TSynEditMark);
var
  m: TSynEditMark;
begin
  if InputSynEdit.Marks.Line[line] = nil then
  begin
    m := TSynEditMark.Create(InputSynEdit);
    m.Line := line;
    m.ImageList := ImageList1;
    m.ImageIndex := 0;
    m.Visible := true;
    InputSynEdit.Marks.Add(m);
    if (assembled) then
       RAM.setBreakpoint(comp.GetCodeAddrOfLine(Line),true);
  end
  else begin
    InputSynEdit.Marks.ClearLine(Line);
    if (assembled) then
       RAM.setBreakpoint(comp.GetCodeAddrOfLine(Line),false);
  end;
end;

procedure TmainFrm.MainFrm_Menu_Help_TutorialClick(Sender: TObject);
var
  unixpath: String;
begin
  {$IFDEF Win32}
  FileOpenAct.Dialog.InitialDir:='../Examples';
  {$ELSE}
  unixpath:= '/usr/share/cpusim/Examples/';
  if DirectoryExistsUTF8(unixpath) then
     FileOpenAct.Dialog.InitialDir:=unixpath;
  {$ENDIF}
  FileOpenAct.Execute;
  FileOpenAct.Dialog.InitialDir:='';
end;

procedure TmainFrm.Log_lbDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  myColor: TColor;
  myBrush: TBrush;
begin
  myBrush := TBrush.Create;
  with (Control as TListBox).Canvas do // draw on control canvas, not on the form
  begin

    if LeftStr(Log_lb.Items[Index],9) = '[success]' then
      myColor := clGreen
    else if LeftStr(Log_lb.Items[Index],9) = '[warning]' then
      myColor := TColor($0066FF)
    else if LeftStr(Log_lb.Items[Index],7) = '[error]' then
      myColor := clRed;

    Brush.Color:=TColor($FFFFFF);
    Font.Color:=mycolor;

    FillRect(ARect);

    Brush.Style := TBrushStyle.bsSolid;
    // display the text
    TextOut(ARect.Left, ARect.Top, (Control as TListBox).Items[Index]);
    MyBrush.Free;
  end;
end;

procedure TmainFrm.TFindDialogFind(Sender: TObject);
var
  findtext: string;
begin
  SearchFindAct.Dialog.FindText := findtext;
  InputSynEdit.SearchReplace(findtext, '', []);
end;

procedure TmainFrm.Timer1Timer(Sender: TObject);
begin
  updateREG;
  ScreenForm.Repaint;

  WaitingMessageLbl.Caption := CPU.waitingMessage();
  if WaitingMessageLbl.Caption <> '' then
    InputSynEdit.CaretY:= comp.GetCodePosition(CPU.ReadRegister(IP));

  if Thread.Suspended then
  begin
    Timer1.Enabled := False;
    RunPauseBtn.Caption := 'Run';
    RunPauseBtn.Hint:= 'Runs the program';
    InputSynEdit.CaretY:= comp.GetCodePosition(CPU.ReadRegister(IP));
  end;
end;


procedure TmainFrm.Step;
begin
  Thread.setVel(-1);
  Thread.Fortsetzen;
end;

procedure TmainFrm.StepOver;
begin
  Thread.setVel(-2);
  Thread.Fortsetzen;
end;

procedure TmainFrm.Stop;
begin
  if CPUCreated then
  begin
    CPU.Destroy;
    CPUcreated:=false;
    //WriteLn('cpu destr');
  end;
  if ThreadCreated then
  begin
    Thread.term();
    Threadcreated:=false;
    //WriteLn('cput term');
  end;

  if closeOnStop then
    Application.Terminate;

  assembled := False;
  if (SavePath <> '') then
    Caption:= InitCaption + ' - ' + SavePath
  else
    Caption:= InitCaption;
  InputSynEdit.ReadOnly := False;
  InputSynEdit.Color := clWhite;

  RunPauseBtn.Enabled := False;
  speedEdt.Enabled := False;
  FrequencyType.Enabled := False;
  StepBtn.Enabled := False;
  MainFrm_Menu_Edit.Enabled := true;
  StepOverBtn.Enabled := False;
  AssembleBtn.Caption := 'Assemble';
  RunPauseBtn.Caption := 'Run';
  screenForm.Hide;
end;

procedure TmainFrm.setVel;
begin
  if FrequencyType.ItemIndex = 3 then
  begin
    Thread.setVel(0);
  end
  else
  begin
    Thread.setVel(speedEdt.Value * power(1000, FrequencyType.ItemIndex));
  end;

  //trackTime := False;

end;

procedure TmainFrm.OnRAMChange(addr: word);
var
  row, col: integer;
begin
  row := addr and 15 + 1;
  col := addr shr 4 + 1;
  RAMGrid.Cells[row, col] := IntToHex(Byte(Ram.ReadByte(addr)), 2);
  RAMGrid.InvalidateCell(row, col);
  if addr >= RAMSize then
  begin
    screenForm.Refresh(addr - RAMSize);
  end;
 { if (col-1) + ((row-1) shl 4) = CPU.ReadRegister(IP) then
    begin
      Canvas.Brush.Color := clYellow;
    end
    else if (Col-1) + ((Row-1) shl 4) = CPU.ReadRegister(BP) then
    begin
      Canvas.Brush.Color := $FF8888;
    end
    else if (Col-1) + ((Row-1) shl 4) = CPU.ReadRegister(SP) then
    begin
      Canvas.Brush.Color := clGreen;
    end;  }
end;

// standard actions:------------------------------------------------------------

procedure TmainFrm.MainFrm_Menu_File_NewClick(Sender: TObject);
var
  answer: longint;
begin
  if not saved then
  begin
    answer := MessageDlg('Do you want to save changes?', mtConfirmation,
      mbYesNoCancel, 0);
    if answer = mrYes then
    begin
      MainFrm_Menu_File_SaveClick(nil);
    end;
  end;
  SavePath:= '';
  InputSynEdit.ClearAll;
  Saved:= true;
  Caption:= InitCaption;
end;

procedure TmainFrm.MainFrm_Menu_File_OpenRecentClick(Sender: TObject);
begin
  //TODO Keep track of recent files?
end;

procedure TmainFrm.MainFrm_Menu_File_SaveAsClick(Sender: TObject);
begin
  FileSaveAsAct.Execute;
end;

procedure TmainFrm.MainFrm_Menu_Help_AboutClick(Sender: TObject);
var
  AboutStr: PChar;
begin
  AboutStr := 'CPU Simulator Herder 14' + sLineBreak +
    'by Informatik-LK 14/15 (4.Sem) of the Herder-Gymnasium Berlin' + sLineBreak +
    'E-Mail: HerderLK2015@gmx.de';
  MessageDlg('About', AboutStr, mtInformation, [mbClose], '0');
end;

procedure TmainFrm.MainFrm_Menu_Help_WikiClick(Sender: TObject);
begin
  OpenURL('https://github.com/HERDER2014/CPUSim/wiki');
end;

procedure TmainFrm.MainFrm_Menu_File_SaveClick(Sender: TObject);
begin
  if SavePath = '' then
  begin
    MainFrm_Menu_File_SaveAsClick(MainFrm_Menu_File_Save);
  end
  else
    InputSynEdit.Lines.SaveToFile(SavePath);
  saved := True;
  Caption:= InitCaption + ' - ' + SavePath;
end;


procedure TmainFrm.MainFrm_Menu_Edit_CopyClick(Sender: TObject);
begin
  InputSynEdit.CopyToClipboard;
end;

procedure TmainFrm.InputSynEditChange(Sender: TObject);
begin
  Saved := False;
  drawCodeIPHighlighting := False;
end;

procedure TmainFrm.InputSynEditSpecialLineColors(Sender: TObject;
  Line: integer; var Special: boolean; var FG, BG: TColor);
begin
  if (drawCodeIPHighlighting) and (Line = comp.GetCodePosition(oldIP)) then
  begin
    Special := True;
    BG := clYellow;
  end
  else if (Line = SelectedLineFromRam) and (SelectedLineFromRam <> 0) then
  begin
    Special := True;
    BG := $FF9933;
  end
  else if (InputSynEdit.Marks.Line[line] <> nil) then
  begin
    Special := True;
    BG := clRed;
  end;
end;

procedure TmainFrm.compileClick(Sender: TObject);
begin
  MainFrm.DoCompile;
end;

procedure TmainFrm.FileOpenActAccept(Sender: TObject);
var
  path: string;
begin
  path := FileOpenAct.Dialog.FileName;
  InputSynEdit.Lines.LoadFromFile(path);
  SavePath := path;
  Saved := True;
  Caption:= InitCaption + ' - ' + SavePath;
end;

procedure TmainFrm.FileSaveAsActAccept(Sender: TObject);
begin
  SavePath := FileSaveAsAct.Dialog.FileName;
  InputSynEdit.Lines.SaveToFile(SavePath);
  Saved := True;
    Caption:= InitCaption + ' - ' + SavePath;
end;

function TmainFrm.FileExitActExecute(Sender: TObject): boolean;
begin
  mainFrm.Close;
end;

procedure TmainFrm.FileSaveExecute(Sender: TObject);
begin
  MainFrm_Menu_File_SaveClick(nil);
end;

procedure TmainFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TmainFrm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  answer: longint;
begin
  if Saved then
  begin
    CanClose := True;
  end
  else
  begin
    answer := MessageDlg('Do you want to save changes?', mtConfirmation,
      mbYesNoCancel, 0);
    if answer = mrYes then
    begin
      if SavePath = '' then
      begin
        FileSaveAsAct.Execute;
        CanClose := Saved;
      end
      else
      begin
        InputSynEdit.Lines.SaveToFile(SavePath);
        Saved := True;
        CanClose := True;
      end;
    end
    else if answer = mrNo then
    begin
      CanClose := True;
    end
    else
    begin
      CanClose := False;
    end;
  end;
end;

procedure TmainFrm.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
begin
  if Low(FileNames) = High(FileNames) then
    InputSynEdit.Lines.LoadFromFile(FileNames[Low(FileNames)]);
end;

procedure TmainFrm.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin

  //f5 to assemble or run, depending on what is done
  if (Key = LCLType.VK_F5) then
  begin
    if assembled then
      RunPauseBtnClick(nil)
    else
      AssembleBtnClick(nil);
  end;
  //f9 to assemble and then run
  if (Key = LCLType.VK_F9) then
  begin
    if not assembled then
      AssembleBtnClick(nil);
    if assembled then
      RunPauseBtnClick(nil);
  end;
  //f8 zum stepOver
  if (key = LCLType.VK_F8) then
  begin
    if not assembled then
      AssembleBtnClick(nil);
    if assembled then
      StepOverBtnClick(nil);
  end;
  //f7 zum step
  if (key = LCLType.VK_F7) then
  begin
    if not assembled then
      AssembleBtnClick(nil);
    if assembled then
      StepBtnClick(nil);
  end;
end;

procedure TmainFrm.FormKeyPress(Sender: TObject; var Key: char);
begin
  if assembled then
    CPU.SendKeyInput(Key);
end;

procedure TmainFrm.FormResize(Sender: TObject);
begin
  if (mainFrm.Width > 900) then
  begin
    RAMGrid.AnchorSide[akBottom].Control := mainFrm;
    RAMGrid.AnchorSide[akBottom].Side := asrBottom;
    Log_lb.AnchorSide[akRight].Control := RAMGrid;
    Log_lb.AnchorSide[akRight].Side := asrLeft;
    H_Menu_CodeSplitter.AnchorSide[akRight].Control := RAMGrid;
    H_Menu_CodeSplitter.AnchorSide[akRight].Side := asrLeft;
  end
  else
  begin
    RAMGrid.AnchorSide[akBottom].Control := H_Menu_CodeSplitter;
    RAMGrid.AnchorSide[akBottom].Side := asrTop;
    Log_lb.AnchorSide[akRight].Control := mainFrm;
    Log_lb.AnchorSide[akRight].Side := asrRight;
    H_Menu_CodeSplitter.AnchorSide[akRight].Control := mainFrm;
    H_Menu_CodeSplitter.AnchorSide[akRight].Side := asrRight;
  end;
end;

procedure TmainFrm.MainFrm_Menu_OptionsClick(Sender: TObject);
begin
  OptionsFrm.ShowModal;
end;

procedure TmainFrm.FileNewExecute(Sender: TObject);
begin
  MainFrm_Menu_File_NewClick(nil);
end;

procedure TmainFrm.RAMGridSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
var
  i: integer;
  oldCell: word;
begin
  if (RAMGrid.Cells[aCol, 0] <> '') and (RAMGrid.Cells[0, aRow] <> '') then
  begin
    oldCell := SelectedCellFromRam;
     SelectedCellFromRam := StrToInt('$' + RAMGrid.Cells[aCol, 0]) + StrToInt('$' + RAMGrid.Cells[0, aRow]);
     i := 0;
     SelectedLineFromRam:= 0;
     while (i < SelectedCellFromRam) and (SelectedLineFromRam = 0) do
     begin
       SelectedLineFromRam:= comp.GetCodePosition(SelectedCellFromRam - i);
       inc(i);
     end;
     if SelectedLineFromRam <> 0 then
     begin
       RamGrid.InvalidateCell(oldCell and 15 + 1, oldCell shr 4 + 1);
       RamGrid.InvalidateCell(SelectedCellFromRam and 15 + 1, SelectedCellFromRam shr 4 + 1);
       InputSynEdit.CaretY:= SelectedLineFromRam;
     end;
     InputSynEdit.Invalidate;
  end;
end;

procedure TmainFrm.RunPauseBtnClick(Sender: TObject);
begin
  //WriteLn('run clk');
  if RunPauseBtn.Caption = 'Run' then
  begin
    Timer1.Enabled := True;
    resume;
    RunPauseBtn.Caption := 'Pause';
    RunPauseBtn.Hint:= 'Pauses program execution';
  end
  else
  begin
    Step;
    RunPauseBtn.Caption := 'Run';
    RunPauseBtn.Hint:= 'Runs the program';
    //trackTime := False;
  end;
end;


procedure TmainFrm.AssembleBtnClick(Sender: TObject);
begin
  //WriteLn('assemble clk');
  if ClearLog then ClearLogBtn.Click;
  if AssembleBtn.Caption = 'Assemble' then
  begin
    DoCompile;
    if assembled then
    begin
      Timer1Timer(nil); // update ram and register once
      AssembleBtn.Caption := 'Stop';
      RunPauseBtn.Enabled := True;
      FrequencyType.Enabled := True;
      if FrequencyType.ItemIndex <> 3 then
        speedEdt.Enabled := True;
      StepBtn.Enabled := True;
      StepOverBtn.Enabled := True;
      MainFrm_Menu_Edit.Enabled := false;
    end;
  end
  else
  begin
    Stop;
    Log_lb.Items.Insert(0, 'Simulation canceled by user');
  end;
end;

procedure TmainFrm.Button1Click(Sender: TObject);
begin
  screenForm.Show;
end;

procedure TmainFrm.ClearLogBtnClick(Sender: TObject);
begin
  Log_lb.Items.Clear;
  Log_lb.Items.Insert(0,'Hit "Assemble" to compile your program');
end;

procedure TmainFrm.MainFrm_Menu_Edit_CutClick(Sender: TObject);
begin
  InputSynEdit.CutToClipboard;
end;

procedure TmainFrm.MainFrm_Menu_Edit_PasteClick(Sender: TObject);
begin
  InputSynEdit.PasteFromClipboard;
end;

procedure TmainFrm.MainFrm_Menu_Edit_RedoClick(Sender: TObject);
begin
  InputSynEdit.Redo;
end;

procedure TmainFrm.MainFrm_Menu_Edit_UndoClick(Sender: TObject);
begin
  InputSynEdit.Undo;
end;


end.
