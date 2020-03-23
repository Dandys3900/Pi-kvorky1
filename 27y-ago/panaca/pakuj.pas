{ (c) by Mr.Old, 27.09.1994, ver 1.03, last upgrade: 01.10.1994  }
uses dos,crt;
type prvptr=^prvek;
     prvek=record
	d:byte;
	po:prvptr;
	s:array[1..255] of byte;
     end;
     posloupnost=record
	d:byte;
	s:array[1..255] of byte;
     end;
var i,j,po:word;
    ec,ic,volno,max,nr,kodpr,poz,nw:word;
    bpp,hodn,bit,sx,sy:byte;
    zac:pointer;
    posl,pref,p:posloupnost;
    tab,prv,pom,vol,prvvol,odtud:prvptr;
    fsiz,gsiz,pampred,pampo:longint;
    f,g:file;
    s:string;
    command:char;
    a,b:array[1..25740] of byte;
const maxbpp=12;
      minbpp=9;
      ver:string[4]='1.01';
      tocit:array[0..3] of char=('-','\','|','/');
procedure vystup(kod:word);forward;
procedure inicializujtabulku;
begin
release(zac);getmem(tab,6);tab^.s[1]:=0;tab^.d:=1;prv:=tab;
memw[$B800:158]:=ord(tocit[0])+textattr shl 8;
for i:=1 to (1 shl (bpp-1)-1) do begin
	getmem(tab^.po,6);tab:=tab^.po;tab^.s[1]:=i;tab^.d:=1;
end;
ec:=1 shl (bpp-1)+1;ic:=1 shl (bpp-1);
for i:=1 to 2 do begin
	getmem(tab^.po,5);tab:=tab^.po;tab^.s[1]:=0;tab^.d:=0;
end;
tab^.po:=nil;tab^.s[1]:=0;vol:=tab;volno:=1 shl (bpp-1)+2;max:=1 shl bpp-1;
odtud:=prv;for i:=0 to 255 do odtud:=odtud^.po;
end;
procedure rozsirtabulku;
begin
if bpp=maxbpp then begin vystup(ic);bpp:=minbpp;inicializujtabulku;end else inc(bpp);
max:=1 shl bpp-1;memw[$B800:158]:=ord(tocit[bpp-minbpp])+textattr shl 8;
end;
function hledejvtabulce(pp:posloupnost):word;
var ppp:word;
    i,j:byte;
label vyskoc,preskoc;
begin
ppp:=256;
if pp.d=1 then begin hledejvtabulce:=pp.s[1];exit;end;
pom:=odtud;
repeat
	if pom^.d=pp.d then begin
		j:=0;
		for i:=1 to pp.d do if pp.s[i]<>pom^.s[i] then begin inc(j);i:=pp.d;end;
		if j=0 then goto vyskoc;
	end;
	inc(ppp);pom:=pom^.po;
until pom=nil;
hledejvtabulce:=65535;goto preskoc;
vyskoc:
hledejvtabulce:=ppp;
preskoc:
end;
procedure zapisdotabulky(pp:posloupnost);
var i:byte;
begin
getmem(vol^.po,pp.d+5);vol:=vol^.po;inc(volno);
vol^.d:=pp.d;for i:=1 to pp.d do vol^.s[i]:=pp.s[i];vol^.po:=nil;
if volno>max then rozsirtabulku;
end;
procedure pridejhodnotudoprefixu;
begin
inc(pref.d);pref.s[pref.d]:=hodn;
end;
procedure presunhodnotudoprefixu;
begin
pref.d:=1;pref.s[1]:=hodn;
end;
procedure vystup(kod:word);
var pom:longint;
begin
pom:=kod shl bit;a[poz]:=a[poz]+pom and 255;a[poz+1]:=(pom and $ff00) shr 8;a[poz+2]:=(pom and $ff0000) shr 16;
inc(bit,bpp);while bit>7 do begin dec(bit,8);inc(poz);end;
if bit=0 then if poz>25555 then begin
	blockwrite(f,a,poz-1,nw);poz:=poz-nw;
end;
if kod=ec then blockwrite(f,a,poz);
end;

begin
bpp:=minbpp;mark(zac);bit:=0;poz:=1;pampred:=memavail;
inicializujtabulku;
writeln('PAKUJ '+ver+' Copyright (c)  1994-9 by Mr.Old, 28-Sep-1994');
writeln('All rights reserved.  U. S. Patent no.4,226,357 and patent pending.');
if paramcount<2 then begin
	writeln;writeln('List of frequently used commands:   Type PAKUJ /? for less help.');writeln;
	writeln('Usage:     PAKUJ <command> <archiv_name>[.PAK] [<directory_name>]');
	writeln('              [<!list_name>|<file_name>|<wild_name>...]');
	writeln('Examples:  PAKUJ a archive, PAKUJ e archive, PAKUJ l archive');writeln;
	writeln('<Commands>');
	writeln('  a: Add files to archive               l: List contents of archive');
	writeln('  d: Delete files from archive          m: Move files to archive');
	writeln('  e: Extract files from archive         t: Test integrity of archive');
	writeln('  f: Freshen files in archive           x: eXtract files with full pathname');
	halt;
end;
s:=paramstr(1);command:=upcase(s[1]);
if command='A' then begin
assign(f,'archiv.pak');rewrite(f,1);assign(g,paramstr(2));reset(g,1);
gsiz:=filesize(g);
blockread(g,b,sizeof(b),nr);po:=1;pref.d:=0;pref.s[1]:=0;hodn:=b[1];kodpr:=$ffff;
write(paramstr(2),'  ');sx:=wherex;sy:=wherey;
repeat
	p.d:=pref.d+1;if p.d>0 then for j:=1 to pref.d do p.s[j]:=pref.s[j];p.s[p.d]:=hodn;
	j:=hledejvtabulce(p);
	if j=65535 then begin
		zapisdotabulky(p);if kodpr=65535 then j:=hledejvtabulce(pref) else j:=kodpr;
		vystup(j);
		presunhodnotudoprefixu;kodpr:=65535;
	end else begin
		pridejhodnotudoprefixu;kodpr:=j;
	end;
	if po and 511=0 then begin
		gotoxy(sx,sy);write((po/gsiz*100):4:1,'% ');
	end;
	inc(po);hodn:=b[po];if po>25555 then begin blockread(g,b,sizeof(b),nr);po:=0;end;
until po>nr;
vystup(ec);pampo:=memavail;
release(zac);fsiz:=filesize(f);
close(f);close(g);
gotoxy(sx,sy);writeln('OK  ',100*fsiz/gsiz:5:2);
writeln('Uzralo to ',pampred-pampo,' bytu pameti !');
end;
if command in ['E','X'] then begin
assign(f,'archiv.pak');reset(f,1);assign(g,paramstr(2));rewrite(g,1);
blockread(f,a,sizeof(a),nr);po:=1;
repeat
until po>nr;
close(f);close(g);
end;
end.