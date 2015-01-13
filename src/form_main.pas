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
    procedure Compile;
    procedure ShowExitDlg;
    procedure FormCreate(Sender: TObject);
    procedure MainFrm_Menu_File_ExitClick(Sender: TObject);
    procedure MainFrm_Menu_File_OpenClick(Sender: TObject);
    procedure MainFrm_Menu_File_SaveClick(Sender: TObject);
    function ListToStr: string;
    procedure updateRAM;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  mainFrm: TmainFrm;
  SavePath: String;
  Saved: Boolean;

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
  MessagesMemo.Text:='Hit "Run" to test your program!';
  Saved:=True; // Don't ask for save when program just started
end;

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

procedure TmainFrm.MainFrm_Menu_Edit_CopyClick(Sender: TObject);
begin
  InputSynEdit.CopyToClipboard;
end;

procedure TmainFrm.InputSynEditChange(Sender: TObject);
begin
  Saved:=False;
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


function TmainFrm.ListToStr: string;
var
  Code: String;
  i : Cardinal;
begin
  for i:=0 to InputSynEdit.Lines.Count do
    Code += InputSynEdit.Text[i];
  result:=Code;
end;

procedure TmainFrm.Compile;
var
  RAM : TRAM;
  CPU : TCPU;
  Comp : TCompiler;
  Thread : TCPUThread;
  i : Cardinal;
begin
  //Compiler wird erstellt, RAM als Rückgabe, CPU wird mit RAM erstellt, Thread wird mit CPU erstellt
  RAM:=TRAM.Create((65536));            //TODO use size instead
  // init RAM viewer:
  for i:=0 to 255 do //TODO use size instead
    begin
      RAMValueList.Row := i;
      RAMValueList.InsertRow(FloatToStr(i),'0000000000000000',true);
    end;
  Comp:=TCompiler.Create(RAM);
  Comp.Compile(mainFrm.ListToStr);
  CPU:=CPU.Create(RAM);
  Thread:=TCPUThread.Create(CPU);
end;

procedure TmainFrm.updateRAM;
var
  size : Cardinal;
  i : Cardinal;
  RAM : TRAM;
  b : Byte;
  c : Char;
begin
  size:=65536; //TODO get size
  for i:=0 to size-1 do
    begin
      RAMValueList.Row := i;
      b := RAM.ReadByte(i);
      c := chr(b);
      RAMValueList.InsertRow(FloatToStr(i),c,true);
    end;
end;

end.
