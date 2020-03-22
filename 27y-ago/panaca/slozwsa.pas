{ (c) 06.07.1994 by Mr.Old from Down Raisin, ver. 1.01  }
uses crt,dos;
type typid=array[1..65533] of byte;
     typptr=^typid;
var p:typptr;
    f1,f2:file;
    i,j:word;
    s,jm:string;
    fs:searchrec;
const nenasel:boolean=false;
      poc:array[1..2] of char=('0','1');
begin
if paramcount<1 then begin
	writeln('All Rights Reserved (c) by Mr.Old.  Proficka skladacka wsacek.');
	writeln('Usage: SLOZWSA.EXE filename.WSA');
	halt(1);
end;
assign(f1,paramstr(1));rewrite(f1,1);getmem(p,sizeof(typid));
s:=copy(paramstr(1),1,length(paramstr(1))-4);
repeat
jm:=s+poc[1]+poc[2]+'.cps';
findfirst(jm,$3f,fs);
if doserror<>0 then nenasel:=true;
if not(nenasel) then begin
  assign(f2,jm);
  reset(f2,1);
  if (poc[1]<>'0') or (poc[2]<>'1') then begin
	p^[1]:=0;blockwrite(f1,p^,1);
  end;
  p^[1]:=$2c;i:=filesize(f2)-5;
  p^[3]:=trunc(i/256);p^[2]:=i-256*p^[3];
  blockwrite(f1,p^,3,i);
  blockread(f2,p^,sizeof(typid),i);close(f2);
  blockwrite(f1,p^,i,j);
  if i<>j then nenasel:=true;
end;
poc[2]:=chr(ord(poc[2])+1);if ord(poc[2])>57 then begin
  poc[1]:=chr(ord(poc[1])+1);poc[2]:='0';
end;
until nenasel;
writeln(poc[1],poc[2]);
p^[1]:=0;blockwrite(f1,p^,1);freemem(p,sizeof(typid));
close(f1);
end.