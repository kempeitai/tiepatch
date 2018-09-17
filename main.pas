unit main;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.IOUtils, Windows;

var
ZT_PatchFile :string;
ZT_DestFile: string [12];
buf:Tbytes;
offset,nextpos,startpos:DWORD;
ZT_PatchNumbers:WORD;
ZT_PatchDataLength:byte;
ZT_PatchData:Tbytes;
fp,fd:TFileStream;
cmd:string;

procedure ZT_Init();//Initialization
procedure ZT_AnalizeCmd(); //Getting patch filename from parameters used to run the current program
procedure ZT_CheckPatchFile(); ////Cheking if patch file exists. Exit the program if the file is missing
procedure ZT_OpenPatchFile(); //Now opening patch file
procedure ZT_GetDestFileName();//Reading first 12 bytes tat contain the name of destination file and assign it to ZT_DestFile
procedure ZT_GetNumberOfPatches();// Read the number of patches and assigning the value to ZT_PatchNumbers
procedure ZT_CheckDestFile();//Checking if destination file exists. Exit the program if the file is missing
procedure ZT_OpenDestFile(); //Now opening destination file
procedure ZT_Process();//reading patch offsets, number of bytes to write, data to write and writing in to corresponding offsets in destination file
procedure ZT_Finish();//closing both files

implementation

procedure ZT_Init();//Initialization
begin
  SetConsoleTitle('TIE Corps patcher');
  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
end;

procedure ZT_AnalizeCmd();//Getting patch filename from parameters used to run the current program
begin
  if paramcount=0 then begin //Display usage info screen if no arguement was specified in command line}
    writeln('======================================================');
    writeln('TIE Corps patcher v 1.0');
    writeln('32bit Windows remake by COL Impulse (#11597)');
    write('Usage: ');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
    write('TIEPATCH ');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14);
    writeln('<filetopatch>');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
    writeln('======================================================');
    System.SysUtils.Beep;
    halt;
  end;
  if paramcount>1 then begin //If there are more than 1 command line arguement
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 4 or FOREGROUND_INTENSITY);
    writeln('Error: Wrong number of arguements!');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
    write('Usage: ');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
    write('TIEPATCH ');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14);
    writeln('<filetopatch>');
    System.SysUtils.Beep;
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
    writeln;write('Press Enter to close the patcher...');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
    readln;
    halt;
  end;
  if paramcount=1 then begin //Checking if filename have valid characters if there is 1 command line arguement
    if TPath.HasValidFileNameChars(ExtractFileName(paramstr(1)),false)=true then begin
      writeln('======================================================');
      writeln('TIE Corps patcher v 1.0');
      writeln('32bit Windows remake by COL Impulse (#11597)');
      writeln('======================================================');
      ZT_PatchFile:=paramstr(1)
    end
    else begin
      SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 4 or FOREGROUND_INTENSITY);
      writeln('Error: Illegal character in file name!');
      SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
      write('Usage: ');
      SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
      write('TIEPATCH ');
      SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14);
      writeln('<filetopatch>');
      System.SysUtils.Beep;
      SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
      writeln;write('Press Enter to close the patcher...');
      SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
      readln;
      halt;
    end;
  end;
end;

procedure ZT_CheckPatchFile();////Cheking if patch file exists. Exit the program if the file is missing
begin
  if fileexists(ZT_PatchFile)=false then begin
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 4 or FOREGROUND_INTENSITY);
    write('Error: ');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
    write('patch file ');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14);
    write(ExtractFileName(ZT_PatchFile));
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
    writeln(' not found!');
    System.SysUtils.Beep;
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
    writeln;write('Press Enter to close the patcher...');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
    readln;
    halt;
  end;
end;

procedure ZT_OpenPatchFile(); //Now opening patch file
begin
// write('Opening patch file... ');
  fp:= TFileStream.Create(ZT_PatchFile, fmOpenRead);
// SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14);
// write('Done.');
// SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
// writeln(' ('+ExtractFileName(ZT_PatchFile)+')');
// SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
end;

procedure ZT_GetDestFileName();//Reading first 12 bytes from patch that contain the name of destination file and assign it to ZT_DestFile
  begin
//  write('Reading destination file name... ');
  SetLength(Buf, 12);
  fp.ReadBuffer(Pointer(Buf)^, 12);
  SetString(ZT_DestFile, PAnsiChar(@buf[0]), 12);
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14);
//  write('Done.');
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
//  writeln(' ('+Zt_DestFile+')');
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
end;

procedure ZT_GetNumberOfPatches();// Read the number of patches and assigning the value to ZT_PatchNumbers
begin
//  write('Looking for patch records number... ');
  fp.Seek($0D,soFromBeginning);
  fp.ReadBuffer(ZT_PatchNumbers, sizeof(ZT_PatchNumbers));
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14);
//  write('Done.');
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
//  writeln(' ('+inttostr(ZT_PatchNumbers)+')');
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
end;

procedure ZT_CheckDestFile();//Checking if destination file exists. Exit the program if the file is missing
begin
//  write('Opening destination file... ');
  if fileexists(GetCurrentDir+'\'+ZT_DestFile)=false then begin
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 4 or FOREGROUND_INTENSITY);
//  writeln('Fail');
  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 4 or FOREGROUND_INTENSITY);
    write('Error: ');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
    write('patch file ');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14);
    write(ExtractFileName(ZT_DestFile));
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
    writeln(' not found!');
    System.SysUtils.Beep;
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
    writeln;write('Press Enter to close the patcher...');
    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
    readln;
    halt;
  end;
end;

procedure ZT_OpenDestFile(); //Now opening destination file
begin
  fd:= TFileStream.Create(GetCurrentDir+'\'+ZT_DestFile, fmOpenReadWrite);
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14);
//  writeln('Done.');
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
end;

procedure ZT_Process();//reading patch offsets, number of bytes to write, data to write and writing in to corresponding offsets in destination file
var i: integer;
begin
//  writeln('Processing records from patch file and patching the destination file');
//  writeln;
  startpos:=$0F; //always the same.
  nextpos:=startpos;
  fp.Seek($00,soFromBeginning);
  for i := 1 to ZT_PatchNumbers do begin
    fp.Seek(nextpos,soFromBeginning);
    fp.ReadBuffer(offset,sizeof(offset)); //getting offset
    fp.ReadBuffer(ZT_PatchDataLength,sizeof(ZT_PatchDataLength)); //getting record length
    SetLength(ZT_PatchData, ZT_PatchDataLength);
    fp.ReadBuffer(Pointer(ZT_PatchData)^,ZT_PatchDataLength); //getting record length
    nextpos:=nextpos+(5+1*ZT_PatchDataLength); //calculating next record position
//    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
//    write('Offset: ');
//    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14 );
//    write(inttohex(offset,sizeof(offset)*2)); //!!FOR DEBUG ONLY
//    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
//    write('   '+'Data: ');
//    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 14 );
//    write(inttohex(ZT_PatchData[0],2)); //!!FOR DEBUG ONLY
//    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
//    if odd(i)=true then write('   ||   ');
//    if odd(i)=false then writeln;
    fd.Seek(offset,soFromBeginning);
 // write(inttohex(fd.Position,sizeof(offset)*2)); //FOR DEBUG ONLY
    fd.WriteBuffer(Pointer(ZT_PatchData)^,ZT_PatchDataLength);
 // writeln(' '+ inttohex(ZT_PatchData[0],2)); //FOR DEBUG ONLY
//    SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
  end;
end;

procedure ZT_Finish();//closing both files
begin
  fp.free;
  fd.Free;
  writeln;
  write('Patching of ');
  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
  write(ZT_DestFile);
  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
  writeln(' has been completed.');
  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7 or FOREGROUND_INTENSITY);
//  writeln;write('Press Enter to close the patcher...');
//  SetConsoleTextAttribute(GetStdHandle( STD_OUTPUT_HANDLE), 7);
//  readln;
end;

end.
