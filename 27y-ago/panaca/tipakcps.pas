{$M $800,0,0}{$D+}
uses CRT,DOS;
var
casintvec:procedure;
obsl:procedure;
reg:registers;
aa,ab,mflag,adr,i,j,adr1:word;
f:file;
s:string[3];
poc:byte;
a:array[1..1024] of byte;
const max=319;
      may=199;

label kon;
{$f+}
function getpixel(x,y:word):byte;
begin
getpixel:=mem[$a000:y*320+x];
end;
procedure uloz(jm:string);
var nr,nw,l,k,mo:word;
begin
assign(f,jm);rewrite(f,1);
a[1]:=0;a[3]:=max and 255;a[2]:=0;a[4]:=may;a[5]:=(max shr 8) shl 4;
blockwrite(f,a,5);k:=0;l:=0;
repeat
nr:=0;
repeat
	inc(nr);j:=getpixel(k,l);
	if (j<$c0) and (getpixel(k+1,l)<>j) then a[nr]:=j else begin
		mo:=0;repeat
			inc(mo);
		until (getpixel(k+mo,l)<>j) or (k+mo>max) or (mo=63);
		a[nr]:=$c0+mo;inc(nr);a[nr]:=j;inc(k,mo-1);
	end;
	inc(k);if k>max then begin k:=0;inc(l);end;
until (nr>1020) or (l>may);
blockwrite(f,a,nr,nw);
until (l>may) or (nw=0);
close(f);
end;
procedure ulozpal(jm:string);
begin
assign(f,jm);rewrite(f,1);
i:=seg(a[1]);j:=ofs(a[1]);
asm
 mov ah,10h
 mov al,17h
 mov es,i
 mov dx,j
 mov bx,0
 mov cx,100h
 int 10h
end;
blockwrite(f,a,768);close(f);
end;
procedure budik;interrupt;
begin
with reg do begin
if (mem[aa:ab]=0) and (mflag=0) then begin
     port[$20]:=$20;
     mflag:=1;
     if mem[aa:ab]=0 then intr(adr,reg);
     end;
inline($9c);
casintvec;
end;end;{$f-}
{$f+}
procedure obsluha;interrupt;
begin
port[$20]:=$20;
if port[$60]=11 then begin 
 str(poc,s);inc(poc);port[$60]:=0;
 ulozpal('C:\TIPAK'+s+'.PAL');uloz('C:\TIPAK'+s+'.CPS');
end;
inline($9c);
casintvec;
mflag:=0;
end;{$f-}

begin
with reg do begin
getintvec($1c,@casintvec);
setintvec($1c,addr(budik));
adr1:=$60;adr1:=adr1*4;j:=10;
for i:=0 to 8 do
if (memw[0:adr1+4*i]=0) and (memw[0:adr1+2+4*i]=0) then j:=i;
adr:=$60+j;
if j=10 then begin write('Neni volne preruseni');goto kon;end;
writeln('Obsazeno preruseni: ',adr);
getintvec(adr,@obsl);
setintvec(adr,addr(obsluha));
ah:=$34;
msdos(reg);
aa:=es;
ab:=bx;
mflag:=0;
end;poc:=0;
keep(0);
kon:
end.