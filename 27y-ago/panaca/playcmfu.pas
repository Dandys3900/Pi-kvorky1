unit playcmfu;
interface

uses dos;
var sblast:boolean;
function initfmdriver:boolean;
procedure stopcmf;
procedure resetfm;
function playsong:boolean;		{true...now playing}
procedure instruments_table;
procedure loadcmf(name:string);		{vol  Instruments_table}
procedure pausecmf;
type cmfid=array[0..32768] of byte;
     cmfptr=^cmfid;
var pissiz:word;
    cmf:cmfptr;
implementation

var r:registers;
    pom:pointer;
    pocnas,tiks,tikn,offpis,offnas:word;
const drvint:word=$80;
      drvintstd=$80;
      drvintmax=$84;
function initfmdriver:boolean;
var s:string[250];
    i,j:byte;
    se,off:word;
begin
for j:=drvintstd to drvintmax do begin
	getintvec(j,pom);if pom=nil then initfmdriver:=false else begin
	s:='';se:=seg(pom^);off:=$103;for i:=0 to 4 do s:=s+chr(mem[se:off+i]);
	if s='FMDRV' then begin initfmdriver:=true;drvint:=j;exit end else initfmdriver:=false;
end;
end;
end;
procedure resetfm;
begin
if not sblast then exit;r.bx:=8;intr(drvint,r);
r.bx:=3;r.ax:=$ffff;intr(drvint,r);r.bx:=4;r.ax:=$ffff;intr(drvint,r);
end;
procedure stopcmf;
begin
if not sblast then exit;r.bx:=7;intr(drvint,r);
r.bx:=3;r.ax:=$ffff;intr(drvint,r);r.bx:=4;r.ax:=$ffff;intr(drvint,r);
end;
procedure instruments_table;
var i,j:byte;
begin
if (pissiz<20) or (not sblast) then exit;
offnas:=cmf^[6]+cmf^[7] shl 8;offpis:=cmf^[8]+cmf^[9] shl 8;
tikn:=cmf^[10]+cmf^[11] shl 8;tiks:=cmf^[12]+cmf^[13] shl 8;
pocnas:=cmf^[$24]+cmf^[$25] shl 8;if pocnas=0 then exit;
for i:=0 to pocnas-1 do begin
	j:=offnas+i*16;r.bx:=2;r.cx:=i;r.dx:=seg(cmf^[j]);r.ax:=ofs(cmf^[j]);intr(drvint,r);
end;
r.bx:=2;r.cx:=pocnas;r.dx:=seg(cmf^[offnas]);r.ax:=ofs(cmf^[offnas]);intr(drvint,r);
r.bx:=4;r.ax:=tiks shl 7;intr(drvint,r);
r.bx:=3;r.ax:=tikn xor $ffff;intr(drvint,r);
end;
function playsong:boolean;
begin
if (pocnas=0) or (pissiz<21) or (not sblast) then exit;
r.bx:=6;r.dx:=seg(cmf^[offpis]);r.ax:=ofs(cmf^[offpis]);intr(drvint,r);
if r.ax=0 then playsong:=false else playsong:=true;
r.bx:=4;r.ax:=tiks shl 7;intr(drvint,r);r.bx:=3;r.ax:=tikn xor $ffff;intr(drvint,r);
end;
procedure loadcmf(name:string);
var f:file;
begin
pissiz:=0;if cmf=nil then new(cmf);assign(f,name);reset(f,1);if ioresult<>0 then exit;
blockread(f,cmf^,32768,pissiz);close(f);
stopcmf;instruments_table;playsong;
end;
procedure pausecmf;
begin
if not sblast then exit;r.bx:=7;intr(drvint,r);
end;

begin
cmf:=nil;sblast:=initfmdriver;if sblast then begin
  resetfm;new(cmf);pissiz:=0;
end;
end.