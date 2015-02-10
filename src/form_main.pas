unit form_main;

{$mode objfpc}{$H+}

interface

uses
	 Classes, SysUtils, FileUtil, SynEdit, SynCompletion,
	 Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, LCLType, ExtCtrls,
	 ValEdit, Grids, ActnList, StdActns, Spin, types, lclintf, Math,
	 uRAM, uCPU, uCPUThread, uCompiler, strutils, uTypen, asmHighlighter;

type

	 { TmainFrm }

	 TmainFrm = class(TForm)
			 A1: TEdit;
			 A2: TEdit;
			 VP1: TEdit;
			 VP2: TEdit;
			 FrequencyType: TComboBox;
			 FileSave_ExitAct: TAction;
			 ActionList: TActionList;
			 AssembleBtn: TButton;
			 B1: TEdit;
			 EditCopyAct: TEditCopy;
			 EditCutAct: TEditCut;
			 EditPasteAct: TEditPaste;
			 EditUndoAct: TEditUndo;
			 FileOpenAct: TFileOpen;
			 FileSaveAsAct: TFileSaveAs;
			 speedEdt: TFloatSpinEdit;
			 H_Menu_CodeSplitter: TSplitter;
			 IP2: TEdit;
			 IP1: TEdit;
			 BP1: TEdit;
			 F1: TEdit;
			 Label1: TLabel;
			 Label2: TLabel;
			 Label3: TLabel;
			 Label4: TLabel;
			 Label5: TLabel;
			 Label6: TLabel;
			 Label7: TLabel;
			 Label8: TLabel;
			 Label9: TLabel;
			 Log_lb: TListBox;
			 RunPauseBtn: TButton;
			 SearchFindAct: TSearchFind;
			 SP2: TEdit;
			 BP2: TEdit;
			 F2: TEdit;
			 B2: TEdit;
			 SP1: TEdit;
			 C2: TEdit;
			 C1: TEdit;
			 D2: TEdit;
			 D1: TEdit;
			 RAMGrid: TStringGrid;
			 FileExitAct: TFileExit;
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
			 ReplaceDialog1: TReplaceDialog;
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
			 function FileSave_ExitActExecute(Sender: TObject): boolean;
			 procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
			 procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
			 procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
			 procedure FrequencyTypeChange(Sender: TObject);
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
			 procedure MainFrm_Menu_Help_ContentsClick(Sender: TObject);
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
			 procedure updateRAM;
			 procedure updateREG;
			 procedure resume;
			 procedure Step;
			 procedure StepOver;
			 procedure Stop;
			 procedure setVel;
	 private
	 public
			 { public declarations }
	 end;

var
	 comp: TCompiler;
	 mainFrm: TmainFrm;
	 SavePath: string;
	 Saved: boolean;
	 assembled: boolean;
	 trackTime: boolean;
	 drawCodeIPHighlighting: boolean;
	 Thread: TCPUThread;
	 hlt: TAsmHighlighter;
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
	 InputSynEdit.ClearAll;

	 hlt := TAsmHighlighter.Create(self);
	 InputSynEdit.Highlighter := hlt;

	 RAMSize := 512;
	 Saved := True; // Don't ask for save when program just started
	 RAM := TRAM.Create(RAMSize);
	 CPU := TCPU.Create(RAM);
	 assembled := False;
	 InputSynEdit.ReadOnly := False;
end;

procedure TmainFrm.DoCompile;
begin
	 RAM := TRAM.Create(RAMSize);
	 comp := TCompiler.Create(RAM);
	 comp.NumberInputMode := TNumberInputMode.Hexadecimal;
	 try
			 comp.Compile(InputSynEdit.Text);
			 Log_lb.Items.Insert(0, '[success] compilation completed');
			 CPU.Destroy;
			 CPU := TCPU.Create(RAM);
			 Thread := TCPUThread.Create(CPU);
			 Thread.OnTerminate := @OnCPUTerminate;
			 assembled := True;
			 trackTime := True;
			 drawCodeIPHighlighting := True;
			 InputSynEdit.ReadOnly := True;
			 updateRAM;
	 except
			 on e: Exception do
					 Log_lb.Items.Insert(0, '[error] compilation failed: ' + e.Message);
	 end;
end;

procedure TmainFrm.RAMGridDrawCell(Sender: TObject; aCol, aRow: integer;
	 aRect: TRect; aState: TGridDrawState);
begin
	 with TStringGrid(Sender) do
	 begin
			 if (aCol - 1) + ((aRow - 1) shl 4) = CPU.ReadRegister(IP) then
			 begin
					 Canvas.Brush.Color := clYellow;
			 end
			 else if (aCol - 1) + ((aRow - 1) shl 4) = CPU.ReadRegister(BP) then
			 begin
					 Canvas.Brush.Color := $FF8888;
			 end
			 else if (aCol - 1) + ((aRow - 1) shl 4) = CPU.ReadRegister(SP) then
			 begin
					 Canvas.Brush.Color := clGreen;
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


procedure TmainFrm.updateRAM;
var
	 i: cardinal;
begin
	 RAMGrid.RowCount := (RAMSize - 1) div 16 + 2;
	 for i := 0 to RAMSize - 1 do
	 begin
			 RAMGrid.Cells[i and 15 + 1, i shr 4 + 1] := IntToHex(Ram.ReadByte(i), 2);
	 end;
	 for i := 1 to RAMGrid.RowCount - 1 do
	 begin
			 RAMGrid.Cells[0, i] := IntToHex((i - 1) shl 4, 4);
	 end;
end;

procedure TmainFrm.updateREG;
begin
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
	 F1.Text := IntTOBin(CPU.ReadRegister(FLAGS), 16, 8);
	 F2.Text := IntToHex(CPU.ReadRegister(FLAGS), 4);
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
	 Step;
	 RunPauseBtn.Caption := 'Run';
	 Sleep(100);
	 trackTime := False;
	 Timer1Timer(nil);
end;

procedure TmainFrm.StepOverBtnClick(Sender: TObject);
begin
	 StepOver;
	 RunPauseBtn.Caption := 'Run';
	 Sleep(100);
	 trackTime := False;
	 Timer1Timer(nil);
end;

procedure TmainFrm.StopBtnClick(Sender: TObject);
begin
	 Stop;
	 trackTime := False;
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
	 updateRAM;
	 InputSynEdit.Invalidate;
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
	 ;
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
	 if (drawCodeIPHighlighting) and (Line = comp.GetCodePosition(Hex2Dec(IP2.Text))) then
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

function TmainFrm.FileSave_ExitActExecute(Sender: TObject): boolean;
var
	 answer: longint;
begin
	 if saved then
	 begin
			 //Application.Terminate;
			 Result := True;
	 end
	 else
	 begin
			 answer := MessageDlg('Do you want to save changes?', mtConfirmation,
					 mbYesNoCancel, 0);
			 if answer = mrYes then
			 begin
					 if SavePath = '' then
					 begin
							 Result := FileSaveAsAct.Execute;
					 end
					 else
					 begin
							 InputSynEdit.Lines.SaveToFile(SavePath);
							 Saved := True;
							 Result := False;
					 end;
			 end
			 else if answer = mrNo then
			 begin
					 Result := True;
					 //Application.Terminate;
			 end
			 else
			 begin
					 Result := False;
			 end;
	 end;
end;

procedure TmainFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
	 CloseAction := caFree;
end;

procedure TmainFrm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
	 if FileSave_ExitActExecute(mainFrm) then
	 begin
			 CanClose := True;
	 end
	 else
	 begin
			 CanClose := False;
	 end;
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
			 Timer1.Enabled := False;
			 trackTime := False;
	 end;
end;


procedure TmainFrm.AssembleBtnClick(Sender: TObject);
begin
	 if AssembleBtn.Caption = 'Assemble' then
	 begin
			 RAM.Destroy;
			 RAM := TRAM.Create(RAMSize);
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
