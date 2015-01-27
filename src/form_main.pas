unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynCompletion, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Menus, LCLType, ExtCtrls, ValEdit, Grids,
  ComCtrls, ActnList, StdActns, Spin, uRAM, uCPU, uCPUThread, uCompiler;

type

  { TmainFrm }

  TmainFrm = class(TForm)
    ActionList: TActionList;
    Assemble: TButton;
    RAMGrid: TStringGrid;
    ContinueBtn: TButton;
    Run: TButton;
    speed: TSpinEdit;
    StopBtn: TButton;
    StepBtn: TButton;
    FileExit1: TFileExit;
    FindDlg: TFindDialog;
    HSplitterTop: TSplitter;
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
    MainFrm_Menu_Help_Contents: TMenuItem;
    MainFrm_Menu_Help_Tutorial: TMenuItem;
    MainFrm_Menu_Help_Spacer1: TMenuItem;
    MainFrm_Menu_Help_About: TMenuItem;
    MainFrm_Menu_File_Open: TMenuItem;
    MainFrm_Menu_File_OpenRecent: TMenuItem;
    MainFrm_Menu_File_Save: TMenuItem;
    MainFrm_Menu_File_SaveAs: TMenuItem;
    MainFrm_Menu_File_Spacer2: TMenuItem;
    MainFrm_Menu_File_Exit: TMenuItem;
    MessagesMemo: TMemo;
    OpenDlg: TOpenDialog;
    ActionBox: TPanel;
    RegistersValueList2: TValueListEditor;
    ReplaceDialog1: TReplaceDialog;
    SaveDlg: TSaveDialog;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    TopVSplitter: TSplitter;
    HSplitterBot: TSplitter;
    InputSynEdit: TSynEdit;
    RegistersValueList1: TValueListEditor;
    RAMValueList: TValueListEditor;
    procedure ActionBoxClick(Sender: TObject);
    procedure AssembleClick(Sender: TObject);
    procedure compileClick(Sender: TObject);
    procedure ContinueBtnClick(Sender: TObject);
    procedure InputSynEditChange(Sender: TObject);
    procedure MainFrm_Menu_Edit_CopyClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_CutClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_FindClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_PasteClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_RedoClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_UndoClick(Sender: TObject);
    procedure MainFrm_Menu_File_NewClick(Sender: TObject);
    procedure MainFrm_Menu_File_OpenRecentClick(Sender: TObject);
    procedure MainFrm_Menu_File_SaveAsClick(Sender: TObject);
    procedure MainFrm_Menu_Help_AboutClick(Sender: TObject);
    procedure MainFrm_Menu_Help_ContentsClick(Sender: TObject);
    procedure DoCompile;
    procedure RunClick(Sender: TObject);
    procedure ShowExitDlg;
    procedure FormCreate(Sender: TObject);
    procedure MainFrm_Menu_File_ExitClick(Sender: TObject);
    procedure MainFrm_Menu_File_OpenClick(Sender: TObject);
    procedure MainFrm_Menu_File_SaveClick(Sender: TObject);

    procedure OnCPUTerminate(Sender: TObject);
    procedure speedChange(Sender: TObject);
    procedure StepBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure updateRAM;
    procedure resume;
    procedure Step;
    procedure StepOver;
    procedure Stop;
  private
  public
    { public declarations }
  end;

var
  mainFrm: TmainFrm;
  SavePath: string;
  Saved: boolean;
  runStatus: boolean;
  Thread: TCPUThread;
  RAM: TRAM;
  CPU: TCPU;
  // 0, wenn nicht bereit für Play/StepBtn -- 1, wenn kompiliert und initialisiert,
  // bereit für Play/StepBtn -- 2, wenn play aktiv, bereit für StopBtn
  RAMSize: cardinal;

implementation

{$R *.lfm}

{ TmainFrm }

procedure TmainFrm.FormCreate(Sender: TObject);
begin
  // init:
  RegistersValueList1.Row := 0;
  RegistersValueList1.InsertRow('AX', '0000000000000000', True);
  RegistersValueList1.Row := 1;
  RegistersValueList1.InsertRow('BX', '0000000000000000', True);
  RegistersValueList1.Row := 2;
  RegistersValueList1.InsertRow('CX', '0000000000000000', True);
  RegistersValueList1.Row := 3;
  RegistersValueList1.InsertRow('DX', '0000000000000000', True);
  RegistersValueList1.Row := 0;
  RegistersValueList2.InsertRow('BP', '0000000000000000', True); // BasePointer
  RegistersValueList2.Row := 1;
  RegistersValueList2.InsertRow('IP', '0000000000000000', True); // InstructionPointer
  RegistersValueList2.Row := 2;
  RegistersValueList2.InsertRow('SP', '0000000000000000', True); // StackPointer
  RegistersValueList2.Row := 3;
  RegistersValueList2.InsertRow('FLAGS', '0000000000000000', True);
  InputSynEdit.ClearAll;
  RAMSize := 512; //TODO: getRAMSize
  MessagesMemo.Text := 'Hit "Run" to test your program!';
  Saved := True; // Don't ask for save when program just started
  RAM := TRAM.Create(RAMSize);
  CPU := TCPU.Create(RAM);
  runStatus := False;
end;

procedure TmainFrm.DoCompile;
var
  comp: TCompiler;
  i: cardinal;
begin
  RAM := TRAM.Create(RAMSize);
  comp := TCompiler.Create(RAM);
  comp.Compile(InputSynEdit.Text);
  CPU.Destroy;
  CPU := TCPU.Create(RAM);
  Thread := TCPUThread.Create(CPU);
  Thread.OnTerminate := @OnCPUTerminate;
  runStatus := True;
  updateRAM;
end;

procedure TmainFrm.RunClick(Sender: TObject);
begin
  DoCompile;
  resume;
end;

procedure TmainFrm.UpdateRAM;
var
  i: cardinal;
begin
  RAMGrid.RowCount:= (RAMSize-1) div 16 + 2;
  for i := 0 to RAMSize - 1 do
  begin
    RAMGrid.Cells[i and 15 + 1, i shr 4 + 1] := IntToHex(Ram.ReadByte(i), 2);
  end;
  for i:= 1 to RAMGrid.RowCount-1 do
  begin
    RAMGrid.Cells[0, i]:= IntToHex((i-1) shl 4, 4);
  end;
end;

procedure TmainFrm.resume;
begin
  Thread.setVel(speed.Value);
  Thread.resume;
end;

procedure TmainFrm.OnCPUTerminate(Sender: TObject);
begin
  //TODO
  if (Thread.getException() = '') then
  begin

  end
  else
  begin

  end;

  Thread.Destroy;
end;

procedure TmainFrm.speedChange(Sender: TObject);
begin
  if runStatus then
     Thread.setVel(speed.Value);
end;

procedure TmainFrm.StepBtnClick(Sender: TObject);
begin
   Step;
end;

procedure TmainFrm.StopBtnClick(Sender: TObject);
begin
   Stop;
end;

procedure TmainFrm.Timer1Timer(Sender: TObject);
begin
  //Update register todo
  updateRAM;
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
  runStatus := False;
end;

// standard actions:------------------------------------------------------------

procedure TmainFrm.ShowExitDlg;
var
  answer: longint;
begin
  if saved then
  begin
    Application.Terminate;
  end
  else
  begin
    answer := MessageDlg('Unsaved Changes! Do you really want to quit?',
      mtConfirmation, mbYesNoCancel, 0);
    if answer = mrYes then
      Application.Terminate
    else
    if answer = mrNo then
      SaveDlg.Execute;
  end;
end;

procedure TmainFrm.MainFrm_Menu_File_ExitClick(Sender: TObject);
begin
  ShowExitDlg;
  //TODO use TAction
  //  ActionList.;
  //  TFileExit.ActionList.;
end;

procedure TmainFrm.MainFrm_Menu_File_NewClick(Sender: TObject);
begin
  //TODO
end;

procedure TmainFrm.MainFrm_Menu_File_OpenRecentClick(Sender: TObject);
begin
  //TODO Keep track of recent files?
end;

procedure TmainFrm.MainFrm_Menu_File_SaveAsClick(Sender: TObject);
var
  path: string;
begin
  SaveDlg.Execute;
  path := SaveDlg.FileName;
  InputSynEdit.Lines.SaveToFile(path);
  SavePath := path;
end;

procedure TmainFrm.MainFrm_Menu_Help_AboutClick(Sender: TObject);
var
  AboutStr: PChar;
begin
  AboutStr := 'CPU Simulator Herder 14' + sLineBreak +
    'by Informatik-LK 14/15 (3.Sem) of the Herder-Gymnasium Berlin';
  MessageDlg('About', AboutStr, mtInformation, [mbClose], '0');
end;

procedure TmainFrm.MainFrm_Menu_Help_ContentsClick(Sender: TObject);
begin

end;


procedure TmainFrm.MainFrm_Menu_File_OpenClick(Sender: TObject);
var
  path: string;
begin
  OpenDlg.Execute;
  path := OpenDlg.FileName;
  InputSynEdit.Lines.LoadFromFile(path);
end;

procedure TmainFrm.MainFrm_Menu_File_SaveClick(Sender: TObject);
begin
  if SavePath = '' then
  begin
    MainFrm_Menu_File_SaveAsClick(MainFrm_Menu_File_Save);
  end
  else
    InputSynEdit.Lines.SaveToFile(SavePath);
end;


procedure TmainFrm.MainFrm_Menu_Edit_CopyClick(Sender: TObject);
begin
  InputSynEdit.CopyToClipboard;
end;

procedure TmainFrm.InputSynEditChange(Sender: TObject);
begin
  Saved := False;
end;

procedure TmainFrm.compileClick(Sender: TObject);
begin
  MainFrm.DoCompile;
end;

procedure TmainFrm.ContinueBtnClick(Sender: TObject);
begin

end;

procedure TmainFrm.AssembleClick(Sender: TObject);
begin
  DoCompile;
end;

procedure TmainFrm.ActionBoxClick(Sender: TObject);
begin

end;

procedure TmainFrm.MainFrm_Menu_Edit_CutClick(Sender: TObject);
begin
  InputSynEdit.CutToClipboard;
end;

procedure TmainFrm.MainFrm_Menu_Edit_FindClick(Sender: TObject);
begin
  FindDlg.Execute;
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
