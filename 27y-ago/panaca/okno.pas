{  (c)  by Mr.Old, 01.10.94, ver 1.01, last upgrade: 01.10.94    }
unit okno;
interface
uses dos;
procedure setcolor(bi,bb:byte);
procedure writexy(x1,y1:byte;s:string);
function readxy(x1,y1:byte):string;
procedure openwindow(x1,y1,x2,y2:byte);
procedure doborder(naz:string;tl:byte;shadow:boolean);
procedure closewindow;
procedure showkursor;
procedure hidekursor;
procedure initmode;
procedure closemode;
procedure showerror(chyba:byte);
procedure showmouse;
procedure hidemouse;
function getx:byte;
function gety:byte;
function gettab:byte;
function menu(x1,y1,x2,y2:byte):word;
procedure deleteitems;
procedure additem(s:string);
procedure setmenucolor(bi,bp:byte);
procedure readmenufile(nam:string);
procedure readtextfile(nam:string);
procedure savemenufile(nam:string);
type menuid=array[1..256] of string[201];
     menuptr=^menuid;
     treeptr=^treeid;
     treeid=record
	h,hs,d:byte;
	po:treeptr;
	k,ks:array[1..32] of byte;
	jm:array[1..78] of char;
     end;
     textptr=^textid;
     textid=record
	po:textptr;
	p:longint;
	k:array[1..32] of byte;
	h:byte;
     end;
     memtextptr=^memtextid;
     memtextid=array[0..255] of string[78];
var m:menuptr;
    tree,pomtr:treeid;
    km,km2,pom,prv,last:treeptr;
    kt,pot,prvt:textptr;
    text:memtextptr;
    nr,nw,max:word;
    fs:searchrec;
    f,g,f2,g2:file;
    a:array[1..50000] of byte;
    posls:array[0..32] of byte;
    sx1,sy1,sx2,sy2:byte;
function compare(tr1,tr2:treeid):boolean;
procedure viewtext(nam:string;strom:treeid);
implementation
uses crt;
type scrid=array[1..25,1..80] of word;
     savscrptr=^savscrid;
     savscrid=record
	a:scrid;
	adrpred:savscrptr;
	x1,x2,y1,y2:byte;
     end;
var i,j:word;
    savex,savey,saveb,maxst,menui,menup:byte;
    marker:pointer;
    r:registers;
    savscr,pomscr:savscrptr;
    screen:scrid absolute $b800:0;
const barvakurz=15;
      barvapoz=0;
procedure setcolor(bi,bb:byte);
begin
textattr:=(bi and 15)+(bb and 7) shl 4;
end;
procedure setmenucolor(bi,bp:byte);
begin
menui:=bi;menup:=bp;
end;
procedure writexy(x1,y1:byte;s:string);
var i:byte;
begin
hidemouse;if length(s)>0 then for i:=0 to length(s)-1 do
	screen[y1,x1+i]:=ord(s[i+1])+textattr shl 8;showmouse;
end;
function readxy(x1,y1:byte):string;
var ss:string;
    i,j:byte;
    c:char;
label sem;
begin
ss:='';j:=0;showkursor;
repeat
Sem:
	c:=#0;showkursor;gotoxy(j+1,1);
	if (keypressed) and (c=#0) then c:=readkey else if c=#0 then goto sem;
	if (ord(c)>31) then begin ss:=ss+c;if j=0 then clrscr;writexy(x1,y1,ss);inc(j);end;
	if (c=#8) and (length(ss)>0) then begin ss:=copy(ss,1,length(ss)-1);dec(j);writexy(x1,y1,ss+' ');end;
until c in [#27,#13];
if c=#13 then readxy:=ss else ss:='';
hidekursor;
end;
procedure doborder(naz:string;tl:byte;shadow:boolean);
var rx1,ry1,rx2,ry2:byte;
begin
hidemouse;rx1:=sx1+tl shl 1+tl;ry1:=sy1+tl;ry2:=sy2-tl;rx2:=sx2-tl shl 1-tl;
if shadow then begin j:=sy2+1;
	for i:=sx1+2 to sx2+2 do screen[j,i]:=lo(screen[j,i])+({hi(screen[j,i]) and} $7) shl 8;
	for i:=sx2+1 to sx2+2 do for j:=sy1+1 to sy2+1 do screen[j,i]:=lo(screen[j,i])+({hi(screen[j,i]) and} $7) shl 8;
end;
for i:=rx1+1 to rx2-1 do begin
	writexy(i,ry1,'Í');writexy(i,ry2,'Í');
end;
for i:=ry1+1 to ry2-1 do begin
	writexy(rx1,i,'º');writexy(rx2,i,'º');
end;
writexy(rx2,ry2,'¼');writexy(rx2,ry1,'»');
writexy(rx1,ry1,'É');writexy(rx1,ry2,'È');
rx2:=rx1+(rx2-rx1-length(naz)-2) shr 1;
if length(naz)>0 then writexy(rx2,ry1,' '+naz+' ');showmouse;
inc(sx1,tl*3+1);dec(sx2,tl*3+1);inc(sy1,tl+1);dec(sy2,tl+1);
window(sx1,sy1,sx2,sy2);
end;
procedure openwindow(x1,y1,x2,y2:byte);
begin
hidemouse;getmem(pomscr,sizeof(savscrid));
pomscr^.adrpred:=@savscr^;
pomscr^.x1:=sx1;pomscr^.x2:=sx2;pomscr^.y1:=sy1;pomscr^.y2:=sy2;
pomscr^.a:=screen;
window(x1,y1,x2,y2);clrscr;
savscr:=pomscr;
sx1:=x1;sy1:=y1;sx2:=x2;sy2:=y2;showmouse;
end;
procedure closewindow;
begin
hidemouse;pomscr:=savscr;
sx1:=pomscr^.x1;sy1:=pomscr^.y1;sx2:=pomscr^.x2;sy2:=pomscr^.y2;
window(sx1,sy1,sx2,sy2);pomscr:=savscr^.adrpred;
screen:=savscr^.a;
if pomscr<>nil then begin
	{pomscr:=savscr^.adrpred;}
	freemem(savscr,sizeof(savscrid));
	savscr:=pomscr;
end;showmouse;
end;
procedure initmode;
begin
mark(marker);getmem(text,sizeof(memtextid));
savex:=wherex;savey:=wherey;saveb:=textattr;for i:=0 to 32 do posls[i]:=1;
getmem(m,sizeof(menuid));gettab;gettab;tree.h:=0;
getmem(savscr,sizeof(savscrid));savscr^.adrpred:=nil;
savscr^.a:=screen;
savscr^.x1:=1;savscr^.y1:=1;savscr^.x2:=80;savscr^.y2:=25;
sx1:=1;sx2:=80;sy1:=1;sy2:=25;
textmode(co80);
hidekursor;showmouse;
end;
procedure showkursor;
begin
asm
	mov	ah,1
	mov	ch,1eh
	mov	cl,1fh
	int	10h
end;
end;
procedure hidekursor;
begin
asm
	mov	ah,1
	mov	ch,20h
	mov	cl,20h
	int	10h
end;
end;
procedure closemode;
begin
while savscr^.adrpred<>nil do begin pomscr:=savscr^.adrpred;freemem(savscr,sizeof(savscrid));savscr:=pomscr;end;
hidemouse;setcolor(7,0);window(savscr^.x1,savscr^.y1,savscr^.x2,savscr^.y2);clrscr;
screen:=savscr^.a;
showkursor;release(marker);gotoxy(savex,savey);textattr:=saveb;
end;
procedure showerror(chyba:byte);
var s1,s2,s3:string[23];
    x1,x2,x3:byte;
begin
setcolor(15,4);openwindow(25,14,55,21);doborder('Error',1,true);
case chyba of
	1:begin
		s1:='Nedostatek mista';
		s2:='na disku';s3:='Program se zhroutil';
	end;
	2:begin
		s1:='Nelze vytvorit';s2:='dalsi directory!';s3:='';
	end;
	3:begin
		s1:='Struktura adresaru';s2:='je maximalne mozna !';s3:='';
	end;
	4:begin
		s1:='Parameter Missing';s2:='For Czechs';s3:='Chybi parametr!';
	end;
	5:begin
		s1:='File ';s2:=paramstr(1);s3:='Not Found';
	end;
end;
x2:=40-length(s2) shr 1;x3:=40-length(s3) shr 1;x1:=40-length(s1) shr 1;
writexy(x1,16,s1);writexy(x2,17,s2);writexy(x3,18,s3);
setcolor(0,7);writexy(38,19,' OK ');
repeat repeat r.ax:=5;r.bx:=0;intr($33,r);j:=r.bx;
	if (j>0) and (getx>37) and (getx<42) and (gety=19) then
	 else j:=0;
until (keypressed) or (j>0);if keypressed then i:=ord(readkey) until (i in [27,13,32]) or (r.bx>0);
closewindow;
if chyba in [1,4,5] then begin closemode;halt(chyba);end;
end;
procedure showmouse;
begin
asm
	mov	ax,1
	int	33h
end;
end;
procedure hidemouse;
begin
asm
	mov	ax,2
	int	33h
end;
end;
function getx:byte;
begin
r.ax:=3;intr($33,r);r.cx:=r.cx shr 3+1;getx:=r.cx;
end;
function gety:byte;
begin
r.ax:=3;intr($33,r);r.dx:=r.dx shr 3+1;gety:=r.dx;
end;
function gettab:byte;
var i:byte;
begin
i:=0;r.ax:=6;r.bx:=0;intr($33,r);if r.bx>0 then inc(i,1);
r.ax:=6;r.bx:=1;intr($33,r);if r.bx>0 then inc(i,2);
r.ax:=6;r.bx:=2;intr($33,r);if r.bx>0 then inc(i,4);
gettab:=i;
end;
procedure view(x1,y1,x2,y2,od,ku:byte);
var i,j:byte;
begin
i:=od+1;
repeat
if i-od=ku then setcolor(barvakurz,barvapoz)else setcolor(menui,menup);
writexy(x1,y1+i-od-1,copy(m^[i],1,x2));
inc(i);
until (i>y2+od) or (i>max);setcolor(menui,menup);
{if y2+od>max then for i:=y2+od-max+y2+od to max do for j:=1 to x2 do writexy(x1+j-1,y1+i-y2-1-od,'a');}
end;
function menu(x1,y1,x2,y2:byte):word;
var c:char;
    kod,i,j,x,y:byte;
label pred;
begin
y:=0;x:=posls[tree.h];
for i:=1 to 200 do if m^[i]='' then begin max:=i-1;i:=200;end;if x>max then x:=max;
if x=0 then x:=1;while x>y2 do begin dec(x);inc(y);end;
view(x1,y1,x2,y2,y,x);
repeat
pred:
delay(20);c:=#0;
if gettab=1 then begin
	if (getx>=x1) and (getx<x1+x2) and (gety<y1+y2+1) and (gety>=y1-1) then begin
		if gety=y1+y2 then c:=#80 else if gety=y1-1 then c:=#72 else c:=#13;
		if c=#13 then x:=gety-y1+1;if (c=#80) and (max>y2) then x:=y2;if c=#72 then x:=1;
	end else c:=#27;
end;
if (keypressed) and (c=#0) then c:=readkey else if c=#0 then goto pred;
if (c=#80) and (x<y2) and (x+y<max) then begin inc(x);c:=#0;end;
if (c=#81) then begin i:=1;while (x+y<max) and (i<y2) do begin inc(i);inc(x);if x>y2 then begin dec(x);inc(y);end;end;end;
if (c=#80) and (y<max-y2) and (x=y2) then inc(y);
if (c=#72) and (x>1) then begin dec(x);c:=#0;end;
if (c=#72) and (y>0) and (x=1) then dec(y);
if (c=#73) then begin i:=1;while (x+y>1) and (i<y2) do begin inc(i);dec(x);if x=0 then begin x:=1;dec(y);end;end;end;
if c=#71 then begin x:=1;y:=0;end;
if c=#79 then begin x:=y2;if x>max then x:=max;y:=max-x;end;
view(x1,y1,x2,y2,y,x);
until c in [#13,#27,#64,#65,#66,#63,#68,#61];i:=x+y;
if c=#13 then menu:=i else menu:=0;
if ord(c)>58 then menu:=i+(ord(c)-58) shl 8;
posls[tree.h]:=i;
end;
procedure deleteitems;
begin
m^[1]:='';m^[201]:='';setcolor(menui,menup);clrscr;
end;
procedure additem(s:string);
var i:byte;
begin
i:=1;while m^[i]<>'' do inc(i);s:=s+'                                                                                ';
s:=copy(s,1,80);m^[i]:=s;m^[i+1]:='';
end;
procedure readmenufile(nam:string);
var po,i,j:word;
const max=32000;
begin
assign(f,nam);reset(f,1);if filesize(f)<3 then begin
	rewrite(f,1);for i:=1 to 3 do a[i]:=0;blockwrite(f,a,3);reset(f,1);
end;
blockread(f,a,1,nr);blockread(f,a[2],a[1],nr);
getmem(prv,sizeof(treeid));prv^.h:=a[1];if a[1]>0 then for i:=1 to a[1] do prv^.k[i]:=a[i+1];
blockread(f,a,1,nr);blockread(f,a[2],a[1],nr);
prv^.hs:=a[1];if a[1]>0 then for i:=1 to a[1] do prv^.ks[i]:=a[i+1];
blockread(f,a,1,nr);blockread(f,a[2],a[1],nr);
prv^.d:=a[1];if a[1]>0 then for i:=1 to a[1] do prv^.jm[i]:=chr(a[i+1]);
pom:=prv;km:=prv;po:=1;
if filepos(f)<=filesize(f) then repeat
blockread(f,a[po],max,nr);
repeat
	getmem(pom^.po,sizeof(treeid));pom:=pom^.po;pom^.h:=a[po];if a[po]>0 then for i:=1 to a[po] do pom^.k[i]:=a[po+i];
	inc(po,a[po]);inc(po);pom^.hs:=a[po];if a[po]>0 then for i:=1 to a[po] do pom^.ks[i]:=a[i+po];
	inc(po,a[po]);inc(po);pom^.d:=a[po];if a[po]>0 then for i:=1 to a[po] do pom^.jm[i]:=chr(a[i+po]);inc(po,a[po]);inc(po);
until ((po+150>nr) and (nr=max)) or (po>=nr);
po:=nr-po;
until nr<max;
close(f);pom^.po:=nil;last:=pom;
end;
procedure readtextfile(nam:string);
var i,j,po:word;
    celdel,celdel2:longint;
const max=32000;
      jeprvni:boolean=true;
begin
assign(f,nam);reset(f,1);celdel2:=filesize(f);celdel:=0;
repeat
blockread(f,a[po],1,nr);blockread(f,a[po+1],a[po],nr);
if not(jeprvni) then begin getmem(pot^.po,sizeof(textid));pot:=pot^.po;end else getmem(pot,sizeof(textid));
pot^.p:=filepos(f);blockread(f,a[po+2],1,nr);seek(f,pot^.p+a[po+2]*78);
pot^.h:=a[po];for i:=1 to a[po] do pot^.k[i]:=a[1+i];
if jeprvni then begin jeprvni:=false;prvt:=pot;end;
inc(celdel,a[po]+1);inc(po,a[po]+1);
until celdel>=celdel2;
close(f);
end;
function readtextfromfile(nam:string;pozice:longint):byte;
var i,j,po,max:word;
begin
assign(f,nam);reset(f,1);seek(f,pozice);
blockread(f,a,1,nr);
readtextfromfile:=a[1];i:=0;max:=a[1];
repeat
	inc(i);blockread(f,a,78,nr);if nr=78 then for j:=1 to 78 do text^[i,j]:=chr(a[j]);
until i=max;
close(f);
end;
function compare(tr1,tr2:treeid):boolean;
var i,j:byte;
begin
compare:=false;j:=0;
if tr1.h=tr2.h then begin
	if tr1.h>0 then for i:=1 to tr1.h do if tr1.k[i]<>tr2.k[i] then inc(j);
	if j=0 then compare:=true;
end;
end;
procedure savemenufile(nam:string);
var po,i,j:word;
const max=32000;
begin
assign(f,'hatla_pa.tla');rewrite(f,1);
pom:=prv;po:=1;
repeat
	a[po]:=pom^.h;if a[po]>0 then for i:=1 to a[po] do a[po+i]:=pom^.k[i];inc(po,a[po]+1);
	a[po]:=pom^.hs;if a[po]>0 then for i:=1 to a[po] do a[po+i]:=pom^.ks[i];inc(po,a[po]+1);
	a[po]:=pom^.d;if a[po]>0 then for i:=1 to a[po] do a[po+i]:=ord(pom^.jm[i]);inc(po,a[po]+1);
	if po>max then begin
		blockwrite(f,a,po-1,nr);if po-1<>nr then showerror(1);
		po:=1;
	end;
	pom:=pom^.po;
until pom=nil;
blockwrite(f,a,po-1,nr);if po-1<>nr then showerror(1);
close(f);findfirst(nam,$27,fs);if doserror=0 then begin
	assign(f2,nam);erase(f2);
end;
rename(f,nam);
end;
procedure viewtextmain;
var x,y:word;
    rx1,rx2,ry1,ry2:byte;
    c:char;
procedure viewpartoftext;
var i:byte;
begin
if ry2<maxst then for i:=1 to ry2 do writexy(rx1,i+ry1-1,text^[i+y]) else
	for i:=1 to maxst do writexy(rx1,i+ry1-1,text^[i+y]);
end;
begin
x:=1;y:=0;rx1:=sx1;rx2:=sx2;ry2:=sy2-sy1+1;rx2:=sx2-sx1+1;setcolor(7,1);
rx1:=1;ry1:=2;ry2:=80;rx2:=24;
inc(rx1);inc(ry1);dec(rx2,2);dec(ry2,2);
viewpartoftext;
repeat
if keypressed then c:=readkey else c:=#0;
if (c=#80) and (ry2+y<maxst) then inc(y);
if (c=#72) and (x+y>1) then dec(y);
if (c=#71) then y:=0;
if (c=#79) then y:=maxst-x;
if c<>#0 then viewpartoftext;
until c in [#27,#68];
end;
procedure viewtext(nam:string;strom:treeid);
label escapefromview;
begin
pot:=prvt;repeat
	pomtr.h:=pot^.h;if pot^.h>0 then for i:=1 to pom^.h do pomtr.k[i]:=pom^.k[i];
	if compare(strom,pomtr) then begin
		maxst:=readtextfromfile(nam,pot^.p);viewtextmain;
		goto escapefromview;
	end;
	pot:=pot^.po;
until pot=nil;
escapefromview:
end;


begin
checkbreak:=false;
initmode;
end.