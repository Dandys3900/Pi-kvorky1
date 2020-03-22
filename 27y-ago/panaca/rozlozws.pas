uses dos,crt;
type typid=array[1..65533] of byte;
     typptr=^typid;
var i,j,nr:word;
    f,g:file;
    cis:string[2];
    a:typptr;
    cis2:byte;
    jm:string;
procedure preved;
begin
str(cis2,cis);if length(cis)<2 then cis:='0'+cis;
end;
begin
if paramcount<1 then begin
	writeln('All Rights Reserved (c) by Mr.Old.  Proficka rozdelovacka wsacek.');
	writeln('Usage:   ROZLOZWS.EXE filename.WSA');halt;
end;
{$I-}assign(f,paramstr(1));reset(f,1);if doserror<>0 then begin
	writeln('Soubor ',paramstr(1),' nenalezen');
end;{$I+}
jm:=paramstr(1);jm:=copy(jm,1,pos('.',jm)-1);
writeln('Rozkladam soubor: ',jm+'.WSA');
cis2:=1;preved;getmem(a,sizeof(typid));assign(g,jm+cis+'.CPS');rewrite(g,1);write('.');
repeat
	blockread(f,a^,1,nr);
	if nr>0 then case a^[1] of
	 $2c:begin
		blockread(f,a^,7,nr);i:=a^[1]+a^[2] shl 8;blockwrite(g,a^[3],5,j);
		blockread(f,a^,i,nr);blockwrite(g,a^,nr,j);if j<nr then writeln('Disk Full');
	 end;
	 0:begin
		close(g);if filepos(f)<filesize(f) then begin
			inc(cis2);preved;assign(g,jm+cis+'.CPS');rewrite(g,1);write('.');
		end;
	 end;
	end;
until nr=0;
freemem(a,sizeof(typid));
writeln(cis2,' snimku.');
end.