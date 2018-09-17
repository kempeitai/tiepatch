program tiepatch;
{tiepatch.exe}
{TIE Corps patcher v 1.0}
{By COL Impulse (#11597) from TIE Fighter Corps}


//{$SetPEFlags 1}  //USE IT TO REDUCE EXE SIZE!!!!!NO ONE NEES RELOC TABLE ANYWAY!
{$APPTYPE CONSOLE}

{$R *.res}


{$R 'Versioninfo.res' 'Versioninfo.rc'}

uses
  System.SysUtils, main in 'main.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }

ZT_Init();//Initialization
ZT_AnalizeCmd(); //Getting patch filename from parameters used to run the current program
ZT_CheckPatchFile(); //Cheking if patch file exists. Exit the program if the file is missing
ZT_OpenPatchFile(); //Now opening patch file
ZT_GetDestFileName();//Reading first 12 bytes tat contain the name of destination file and assign it to ZT_DestFile
ZT_GetNumberOfPatches();// Read the number of patches and assigning the value to ZT_PatchNumbers
ZT_CheckDestFile();//Checking if destination file exists.Exit the program if the file is missing
ZT_OpenDestFile(); //Now opening destination file
ZT_Process();//reading patch offsets, number of bytes to write, data to write and writing in to corresponding offsets in destination file
ZT_Finish();//closing both files


  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);

  end;
end.
