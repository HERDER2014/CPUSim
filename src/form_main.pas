unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynCompletion, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Menus, LCLType, ExtCtrls, ValEdit, Grids,
  ComCtrls, ActnList, StdActns, uRAM, uCPU, uCPUThread, uCompiler;

type

  { TmainFrm }

  TmainFrm = class(TForm)
    ActionList: TActionList;
    FileExit1: TFileExit;
    FindDlg: TFindDialog;
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
    MainFrm_Menu_Play: TMenuItem;
    MainFrm_Menu_Misc: TMenuItem;
    MainFrm_menu_Misc_updateRAM: TMenuItem;
    compile: TMenuItem;
    MessagesMemo: TMemo;
    OpenDlg: TOpenDialog;
    ReplaceDialog1: TReplaceDialog;
    SaveDlg: TSaveDialog;
    BottomVSplitter: TSplitter;
    StatusBar1: TStatusBar;
    TopVSplitter: TSplitter;
    HSplitter: TSplitter;
    InputSynEdit: TSynEdit;
    RegistersValueList: TValueListEditor;
    RAMValueList: TValueListEditor;
    procedure compileClick(Sender: TObject);
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
    procedure MainFrm_menu_Misc_updateRAMClick(Sender: TObject);
    procedure MainFrm_Menu_PlayClick(Sender: TObject);
    procedure ShowExitDlg;
    procedure FormCreate(Sender: TObject);
    procedure MainFrm_Menu_File_ExitClick(Sender: TObject);
    procedure MainFrm_Menu_File_OpenClick(Sender: TObject);
    procedure MainFrm_Menu_File_SaveClick(Sender: TObject);

    procedure OnCPUTerminate(Sender: TObject);
    function ListToStr: string;
    procedure updateRAM;
    procedure Play;
    procedure step;
    procedure stop;
    procedure delete;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  mainFrm: TmainFrm;
  SavePath: String;
  Saved: Boolean;
  Thread: TCPUThread;
  RAM: TRAM;
  CPU: TCPU;
  RunStatus: integer;
  // 0, wenn nicht bereit für Play/Step -- 1, wenn kompiliert und initialisiert,
  // bereit für Play/Step -- 2, wenn play aktiv, bereit für Stop
  RAMSize: Cardinal;

implementation

{$R *.lfm}

{ TmainFrm }

procedure TmainFrm.FormCreate(Sender: TObject);
begin
  // init:
  RegistersValueList.Row := 0;
  RegistersValueList.InsertRow('AX','0000000000000000',true);
  RegistersValueList.Row := 1;
  RegistersValueList.InsertRow('BX','0000000000000000',true);
  RegistersValueList.Row := 2;
  RegistersValueList.InsertRow('CX','0000000000000000',true);
  RegistersValueList.Row := 3;
  RegistersValueList.InsertRow('DX','0000000000000000',true);
  RegistersValueList.Row := 4;
  RegistersValueList.InsertRow('BP','0000000000000000',true); // BasePointer
  RegistersValueList.Row := 5;
  RegistersValueList.InsertRow('IP','0000000000000000',true); // InstructionPointer
  RegistersValueList.Row := 6;
  RegistersValueList.InsertRow('SP','0000000000000000',true); // StackPointer
  RegistersValueList.Row := 7;
  RegistersValueList.InsertRow('FLAGS','0000000000000000',true);
  InputSynEdit.ClearAll;
  RAMSize:=256; //TODO: getRAMSize
  MessagesMemo.Text:='Hit "Run" to test your program!';
  Saved:=True; // Don't ask for save when program just started
  RAM:=TRAM.Create(RAMSize);
  CPU:=TCPU.Create(RAM);
end;



function TmainFrm.ListToStr: string;
var
  i : Cardinal;
begin
  //for i:=0 to InputSynEdit.Lines.Count do
    //Code += InputSynEdit.Text[i] + #13#10;
  result := InputSynEdit.Text;
  //result:=Code;
end;

procedure TmainFrm.DoCompile;
var
  Comp : TCompiler;
  i : Cardinal;
begin
  //Compiler wird erstellt, RAM als Rückgabe, CPU wird mit RAM erstellt, Thread wird mit CPU erstellt
  if RunStatus=0 then
  begin
    RAM:=TRAM.Create(RAMSize);
    for i:=0 to RAMSize-1 do
    begin
      RAM.WriteByte(i,0);
    end;
    updateRAM;
    Comp:=TCompiler.Create(RAM);
    Comp.Compile(mainFrm.ListToStr);
    CPU.free;
    CPU := TCPU.Create(RAM);
    Thread := TCPUThread.Create(CPU);
    //Button5Click(nil);
    Thread.OnTerminate := @OnCPUTerminate;
    Thread.Start;
    RunStatus:=1;
  end; //TODO else at Messegebox: not possible when old thread isn't closed
end;

procedure TmainFrm.updateRAM;
var
  i : Cardinal;
begin
  for i:=0 to RAMSize-1 do
  begin
    RAMValueList.Cells[1,i+1]:=IntToStr(RAM.ReadByte(i));
    RAMValueList.Cells[0,i+1]:=IntToStr(i);
  end;
end;

procedure TmainFrm.Play;
var
  v: int64;              //v step velocity in ms
begin
  v := 0;                //TODO get from settings
  if RunStatus=1 then
  begin
    Thread.setVel(v);
    Thread.resume;
    RunStatus:=2;
  end; //TODO else at Messagebox: not possible when thread isn't initialized and code isn't compiled
  CPU.free;
  CPU := TCPU.Create(RAM);
  Thread := TCPUThread.Create(CPU);
  Thread.OnTerminate := @OnCPUTerminate;
  Thread.Start;
end;

procedure TmainFrm.OnCPUTerminate(Sender: TObject);
begin
  if (Thread.getException() = '') then
     //Label9.Caption:='Program ended Successfully'
  else
     //Label9.Caption:= cpuThread.getException();
  Thread.free;
end;

procedure TmainFrm.Step;
begin
  if RunStatus=1 then
  begin
    mainFrm.Update;
  end; //TODO else at Messagebox: same as in TmainFrm.Play
end;

procedure TmainFrm.Stop;
begin
  if RunStatus=2 then
  begin
    RunStatus:=1;
  end; //TODO else at Messagebox: not possible when thread isn't running
end;

procedure TmainFrm.Delete;
begin
  if RunStatus=1 then
  begin
    Thread.Destroy();
    RunStatus:=0;
  end else if RunStatus=2 then
  begin
    mainFrm.Stop;
    mainFrm.Delete;
  end; //TODO else at Messagebox: not possible when there is no initialized thread
end;

// standard actions:------------------------------------------------------------

procedure TmainFrm.ShowExitDlg;
var
  answer : LongInt;
begin
  if saved then
  begin
    Application.Terminate;
  end else
  begin
    answer := MessageDlg('Unsaved Changes! Do you really want to quit?', mtConfirmation, mbYesNoCancel, 0);
    if answer = mrYes then
      Application.Terminate else
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
  path: String;
begin
  SaveDlg.Execute;
  path:=SaveDlg.FileName;
  InputSynEdit.Lines.SaveToFile(path);
  SavePath:=path;
end;

procedure TmainFrm.MainFrm_Menu_Help_AboutClick(Sender: TObject);
var
  AboutStr : PChar;
begin
  AboutStr:='CPU Simulator Herder 14' + sLineBreak + 'by Informatik-LK 14/15 (3.Sem) of the Herder-Gymnasium Berlin';
  MessageDlg('About', AboutStr, mtInformation, [mbClose], '0');
end;

procedure TmainFrm.MainFrm_Menu_Help_ContentsClick(Sender: TObject);
begin

end;


procedure TmainFrm.MainFrm_Menu_File_OpenClick(Sender: TObject);
var
  path: String;
begin
  OpenDlg.Execute;
  path:=OpenDlg.FileName;
  InputSynEdit.Lines.LoadFromFile(path);
end;

procedure TmainFrm.MainFrm_Menu_File_SaveClick(Sender: TObject);
begin
  if SavePath = '' then
  begin
    MainFrm_Menu_File_SaveAsClick(MainFrm_Menu_File_Save);
  end else InputSynEdit.Lines.SaveToFile(SavePath);
end;


procedure TmainFrm.MainFrm_Menu_Edit_CopyClick(Sender: TObject);
begin
  InputSynEdit.CopyToClipboard;
end;

procedure TmainFrm.InputSynEditChange(Sender: TObject);
begin
  Saved:=False;
end;

procedure TmainFrm.compileClick(Sender: TObject);
begin
  MainFrm.DoCompile;
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

procedure TmainFrm.MainFrm_menu_Misc_updateRAMClick(Sender: TObject);
begin
  updateRAM;
end;

procedure TmainFrm.MainFrm_Menu_PlayClick(Sender: TObject);
begin
  Play;
end;


end.
