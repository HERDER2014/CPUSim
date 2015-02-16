unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynCompletion, SynMemo, RTTICtrls,
  Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, LCLType, ExtCtrls,
  ValEdit, Grids, ComCtrls, ActnList, StdActns, Spin, ColorBox, uRAM, uCPU,
  uCompiler, form_options, uCPUThread, strutils, uTypen,
  asmHighlighter, eventlog, types, lclintf, Math;

type

  { TmainFrm }

  TmainFrm = class(TForm)
    A1: TEdit;
    A2: TEdit;
    FLAGS1: TEdit;
    ActionList: TActionList;
    AssembleBtn: TButton;
    B1: TEdit;
    Flag_O: TCheckBox;
    Flag_S: TCheckBox;
    Flag_Z: TCheckBox;
    EditCopyAct: TEditCopy;
    EditCutAct: TEditCut;
    EditPasteAct: TEditPaste;
    EditUndoAct: TEditUndo;
    FileOpenAct: TFileOpen;
    FileSaveAsAct: TFileSaveAs;
    H_Menu_CodeSplitter: TSplitter;
    IP2: TEdit;
    IP1: TEdit;
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
    MainFrm_Menu_Edit_Spacer2: TMenuItem;
    MainFrm_Menu_Edit_Find: TMenuItem;
    MainFrm_Menu_Edit_FindNext: TMenuItem;
    MainFrm_Menu_File_Spacer1: TMenuItem;
    MainFrm_Menu_Help: TMenuItem;
    MainFrm_Menu_Help_Wiki: TMenuItem;
    MainFrm_Menu_Help_Tutorial: TMenuItem;
    MainFrm_Menu_Help_Spacer1: TMenuItem;
    MainFrm_Menu_Help_About: TMenuItem;
    MainFrm_Menu_File_Open: TMenuItem;
    MainFrm_Menu_File_OpenRecent: TMenuItem;
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
    procedure compileClick(Sender: TObject);
    procedure FileOpenActAccept(Sender: TObject);
    procedure FileSaveAsActAccept(Sender: TObject);
    //function FileSave_ExitActExecute(Sender: TObject) : Boolean;
    function FileExitActExecute(Sender: TObject) : Boolean;
    procedure Flag_OChange(Sender: TObject);
    procedure Flag_SChange(Sender: TObject);
    procedure Flag_ZChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FrequencyTypeChange(Sender: TObject);
    procedure MainFrm_Menu_OptionsClick(Sender: TObject);
    procedure Panel1Click(Sender: TObject);

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
    procedure RAMGridDrawCell(Sender: TObject; aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
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
    procedure OnRAMChange(addr: Word);
  private
  public
    { public declarations }
    RAMSize: cardinal;
    VRAMSize: cardinal;
  end;

var
  comp: TCompiler;
  mainFrm: TmainFrm;
  SavePath: string;
  Saved: boolean;
  startTime: QWord;
  assembled: boolean;
  trackTime: boolean;
  drawCodeIPHighlighting: boolean;
  Thread: TCPUThread;
  hlt : TAsmHighlighter;
  RAM: TRAM;
  CPU: TCPU;
  // 0, wenn nicht bereit für Play/StepBtn -- 1, wenn kompiliert und initialisiert,
  // bereit für Play/StepBtn -- 2, wenn play aktiv, bereit für StopBtn
  RAMSize: cardinal;
  oldIP : Word;
  oldBP : Word;
  oldSP : Word;
  oldVP : Word;
implementation

{$R *.lfm}

{ TmainFrm }

procedure TmainFrm.FormCreate(Sender: TObject);
begin
	 InputSynEdit.ClearAll;

	 hlt := TAsmHighlighter.Create(self);
	 InputSynEdit.Highlighter := hlt;

	 RAMSize := 512;
   VRAMSize := 64;
	 Saved := True; // Don't ask for save when program just started
	 assembled := False;
	 InputSynEdit.ReadOnly := False;
end;

procedure TmainFrm.DoCompile;
begin
  if RAM <> NIL then
    RAM.Destroy;
  if comp <> NIL then
    comp.Destroy;
  if CPU <> NIL then
    CPU.Destroy;

  RAM := TRAM.Create(RAMSize + VRAMSize, RAMSize);
  RAM.ChangeCallback:=@OnRAMChange;

  comp := TCompiler.Create(RAM);
  comp.NumberInputMode := TNumberInputMode.Hexadecimal;
  try
    comp.Compile(InputSynEdit.Text);
    Log_lb.Items.Insert(0,'[success] compilation completed');
    CPU := TCPU.Create(RAM);
    Thread := TCPUThread.Create(CPU);
    Thread.OnTerminate := @OnCPUTerminate;
    assembled := True;
    trackTime:= True;
    drawCodeIPHighlighting:= true;
    InputSynEdit.ReadOnly:= true;

    oldIP := CPU.ReadRegister(RegisterIndex.IP);
    oldBP := CPU.ReadRegister(RegisterIndex.BP);
    oldSP := CPU.ReadRegister(RegisterIndex.SP);
    oldVP := CPU.ReadRegister(RegisterIndex.VP);

    InputSynEdit.Invalidate;

    setupRAM;
  except
    on e: Exception do
      Log_lb.Items.Insert(0,'[error] compilation failed: ' + e.Message);
  end;
end;

procedure TmainFrm.RAMGridDrawCell(Sender: TObject; aCol, aRow: integer;
	 aRect: TRect; aState: TGridDrawState);
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
			 end;
			 Canvas.FillRect(aRect);
			 Canvas.TextOut(aRect.Left + 2, aRect.Top + 2, Cells[ACol, ARow]);
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
			 RAMGrid.Cells[i and 15 + 1, i shr 4 + 1] := IntToHex(Ram.ReadByte(i), 2);
	 end;
	 for i := 1 to RAMGrid.RowCount - 1 do
	 begin
			 RAMGrid.Cells[0, i] := IntToHex((i - 1) shl 4, 4);
	 end;
end;

procedure TmainFrm.updateREG;
var
   newIP : word;
   newBP : word;
   newSP : word;
   newVP : word;
begin
  newIP := CPU.ReadRegister(RegisterIndex.IP);
  newBP := CPU.ReadRegister(RegisterIndex.BP);
  newSP := CPU.ReadRegister(RegisterIndex.SP);
  newVP := CPU.ReadRegister(RegisterIndex.VP);

  if (newIP <> oldIP) then begin
    RAMGrid.InvalidateCell(oldIP and 15 + 1, oldIP shr 4 + 1);
    InputSynEdit.InvalidateLine(comp.GetCodePosition(oldIP));
    oldIP := newIP;
    RAMGrid.InvalidateCell(oldIP and 15 + 1, oldIP shr 4 + 1);
    InputSynEdit.Invalidate;
    InputSynEdit.InvalidateLine(comp.GetCodePosition(oldIP));
  end;

  if (newBP <> oldBP) then begin
    RAMGrid.InvalidateCell(oldBP and 15 + 1, oldBP shr 4 + 1);
    oldBP := newBP;
    RAMGrid.InvalidateCell(oldBP and 15 + 1, oldBP shr 4 + 1);
  end;

  if (newSP <> oldSP) then begin
    RAMGrid.InvalidateCell(oldSP and 15 + 1, oldSP shr 4 + 1);
    oldSP := newSP;
    RAMGrid.InvalidateCell(oldSP and 15 + 1, oldSP shr 4 + 1);
  end;

  if (newVP <> oldVP) then begin
    RAMGrid.InvalidateCell(oldVP and 15 + 1, oldVP shr 4 + 1);
    oldVP := newVP;
    RAMGrid.InvalidateCell(oldVP and 15 + 1, oldVP shr 4 + 1);
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
   Flag_S.Checked:=(CPU.ReadRegister(FLAGS) and Integer(S))>0;
   Flag_Z.Checked:=(CPU.ReadRegister(FLAGS) and Integer(Z))>0;
   Flag_O.Checked:=(CPU.ReadRegister(FLAGS) and Integer(O))>0;

 //  F1.Text := IntTOBin(CPU.ReadRegister(FLAGS), 16, 8);
//	 F2.Text := IntToHex(CPU.ReadRegister(FLAGS), 4);
end;

procedure TmainFrm.resume;
begin
	 setVel;
	 Thread.resume;
end;

procedure TmainFrm.OnCPUTerminate(Sender: TObject);
begin
	 //TODO
	 if (Thread.getException() = '') then
	 begin
			 if (trackTime) then
					 Log_lb.Items.Insert(0, '[success] simulation ended in ' +
							 FloatToStr(round(Thread.getElapsedTime()*100000)/100) + ' ms and executed ' + IntToStr(Thread.getBefehlCount()) + ' OP-codes.')
			 else
					 Log_lb.Items.Insert(0, '[success] simulation ended');
	 end
	 else
	 begin
			 Log_lb.Items.Insert(0, '[error] simulation failed on line ' +
					 IntToStr(comp.GetCodePosition(cpu.ReadRegister(IP))) + ' (Address ' +
					 IntToHex(cpu.ReadRegister(IP), 4) + '): ' + Thread.getException());
	 end;

	 InputSynEdit.ReadOnly := False;
	 assembled := False;

	 RunPauseBtn.Enabled := False;
	 speedEdt.Enabled := False;
	 FrequencyType.Enabled := False;
	 StepBtn.Enabled := False;
	 StepOverBtn.Enabled := False;
	 AssembleBtn.Caption := 'Assemble';
	 RunPauseBtn.Caption := 'Run';
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
	 Timer1.Enabled := True;

   Step;
	 RunPauseBtn.Caption := 'Run';
	 trackTime := False;
end;

procedure TmainFrm.StepOverBtnClick(Sender: TObject);
begin
  Timer1.Enabled := True;

  StepOver;
	RunPauseBtn.Caption := 'Run';
	trackTime := False;
end;

procedure TmainFrm.StopBtnClick(Sender: TObject);
begin
	 Stop;
	 trackTime := False;
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

  if Thread.Suspended then begin
    Timer1.Enabled:=false;
    RunPauseBtn.Caption:='Run';
  end;
end;


procedure TmainFrm.Step;
begin
	 Thread.setVel(-1);
	 Thread.resume;
end;

procedure TmainFrm.StepOver;
begin
	 Thread.setVel(-2);
	 Thread.resume;
end;

procedure TmainFrm.Stop;
begin
	 Thread.terminate;

	 assembled := False;
	 InputSynEdit.ReadOnly := False;

	 RunPauseBtn.Enabled := False;
	 speedEdt.Enabled := False;
	 FrequencyType.Enabled := False;
	 StepBtn.Enabled := False;
	 StepOverBtn.Enabled := False;
	 AssembleBtn.Caption := 'Assemble';
	 RunPauseBtn.Caption := 'Run';
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

   trackTime:=false;

end;

procedure TmainFrm.OnRAMChange(addr: Word);
var
  row, col : Integer;
begin
  row := addr and 15 + 1;
  col := addr shr 4 + 1;
  RAMGrid.Cells[row, col] := IntToHex(Ram.ReadByte(addr), 2);
  RAMGrid.InvalidateCell(row, col);
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
begin
	 //TODO
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
			 'by Informatik-LK 14/15 (3.Sem) of the Herder-Gymnasium Berlin';
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
end;

procedure TmainFrm.FileSaveAsActAccept(Sender: TObject);
begin
	 SavePath := FileSaveAsAct.Dialog.FileName;
	 InputSynEdit.Lines.SaveToFile(SavePath);
	 Saved := True;
end;

//function TmainFrm.FileSave_ExitActExecute(Sender: TObject) : Boolean;
//var
//  testbool : Boolean;
//begin
//  mainFrm.Close;
//end;
//
function TmainFrm.FileExitActExecute(Sender: TObject) : Boolean;
begin
  mainFrm.Close;
end;

procedure TmainFrm.Flag_OChange(Sender: TObject);
begin
  Flag_O.Checked:= false;
end;

procedure TmainFrm.Flag_SChange(Sender: TObject);
begin
   Flag_S.Checked:= false;
end;

procedure TmainFrm.Flag_ZChange(Sender: TObject);
begin
  Flag_Z.Checked:= false;
end;

procedure TmainFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
end;

procedure TmainFrm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  answer: longint;
begin
  if Saved then
  begin
    CanClose:=True;
  end else
  begin
    answer := MessageDlg('Do you want to save changes?',
      mtConfirmation, mbYesNoCancel, 0);
    if answer = mrYes then
    begin
      if SavePath='' then
      begin
        FileSaveAsAct.Execute;
        CanClose:=Saved;
      end else
      begin
        InputSynEdit.Lines.SaveToFile(SavePath);
        Saved:=true;
        CanClose:=True;
      end
    end else if answer = mrNo then
    begin
      CanClose:=true;
    end else
    begin
      CanClose:=False;
    end;
  end;
end;

procedure TmainFrm.FormKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin

  //f5 to assemble or run, depending on what is done
  if (Key=LCLType.VK_F5) then
  begin
    if assembled then
        RunPauseBtnClick(nil)
    else
        AssembleBtnClick(nil);
  end;
  //f9 to assemble and then run
  if (Key=LCLType.VK_F9) then
  begin
    if not assembled then
        AssembleBtnClick(nil);
    if assembled then
       RunPauseBtnClick(nil);
  end;
  //f8 zum stepOver
  if (key=LCLType.VK_F8) then
  begin
    if not assembled then
        AssembleBtnClick(nil);
    if assembled then
        StepOverBtnClick(nil);
  end;
  //f7 zum step
  if (key=LCLType.VK_F7) then
  begin
    if not assembled then
        AssembleBtnClick(nil);
    if assembled then
        StepBtnClick(nil);
  end;
end;

procedure TmainFrm.MainFrm_Menu_OptionsClick(Sender: TObject);
begin
  OptionsFrm:=TOptionsFrm.Create(mainFrm);
  OptionsFrm.Show;
end;

procedure TmainFrm.Panel1Click(Sender: TObject);
begin

end;


procedure TmainFrm.RunPauseBtnClick(Sender: TObject);
begin
	 if RunPauseBtn.Caption = 'Run' then
	 begin
			 Timer1.Enabled := True;
			 resume;
			 RunPauseBtn.Caption := 'Pause';
	 end
	 else
	 begin
			 Step;
			 RunPauseBtn.Caption := 'Run';
			 trackTime := False;
	 end;
end;


procedure TmainFrm.AssembleBtnClick(Sender: TObject);
begin
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
			 end;
	 end
	 else
	 begin
			 Stop;
			 Log_lb.Items.Insert(0, 'Simulation canceled by user');
	 end;
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
