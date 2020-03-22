{ (c) 15.03.1994 by Mr.Old from Down Raisin, ver. 6.11, last upgrade 18.02.1995  }
unit ctecka;
interface
{$S-}{$R-}{$X+}{$I-}{$D+}
uses crt,dos,sbdsp,voc,memunit,playcmfu;
type typ2=array[1..65533] of byte;
     typ3=array[0..65533] of byte;
     pakid=record
	jm:array[1..12] of char;
	poz,del:longint;
     end;       
     typpakbez=array[1..2048] of pakid;
     typpak=^typpakbez;
     typp=^typ3;
     typ=^typ2;
     itid=record
	c:byte;
	i:integer;
     end;
     panakid=record
	maxx,maxy,maxprx,maxpry:integer;
     end;
     winitemid=record
	x1,y1,x2,y2:word;
     end;
     id=record
	nem:array[0..4] of byte;
	vych:record
		obl:array[0..6] of byte;
		kam:byte;
	end;
	scen:record
		jm:array[1..8] of char;
		obl:array[0..4] of integer;
	end;
	anim:record
		jm:array[1..8] of char;
		prep:byte;
	end;
	prek:record
		jm:array[1..8] of char;
		prep:byte;
	end;
	t:record
		del:byte;
		text:array[1..48] of char;
		obl:array[0..3] of integer;
	end;
	use:record
		obl:array[0..3] of integer;
		kam:array[0..1] of integer;
	end;
	mluv:record
		obl:array[0..3] of integer;
		kam:array[0..1] of integer;
		jm:array[1..8] of char;
		kod,prep:byte;
	end;
	dial:record
		del:byte;
		text:array[1..48] of char;
		kod:word;
	end;
     end;
     animid=record
	n,s:word;
	p:pointer;
     end;
     postid=record
	n,s:word;
	jm:string[12];
	x,y:integer;
	pr:byte;
	p:pointer;
	d:boolean;
	o:array[1..4] of integer;
	pp:pointer;
     end;
     cpsid=record
	n:word;
	p:typ;
     end;
     cpsid2=record
	n:word;
	p:typ;
     end;
     fontid=record
	p:typ;
	n:word;
	sir,vys:byte;
     end;
var i,j,k,l:integer;
    x1,y1,x2,y2,mx,my,smx,smy,nx,ny:integer;
    pb,pj,delkacps,soundsize:longint;
    poz,poznr,pocvec,pocit,cismis,stavsiz,starycx,staryes,starydx,nr,nw,podklsiz:word;
    pak:typpak;
    mousebuffer:cpsid;
    pocpak:integer;
    postavarozhovoru:byte;
    pr:array[0..4] of integer;
    pp:array[1..11] of byte;
    p:array[0..63] of id;
    m:array[0..63] of animid;
    mc:array[0..47] of cpsid;
    mp:array[0..15] of postid;
    tabit:array[0..47] of itid;
    mam:array[0..15] of integer;
    use:array[1..3] of integer;
    sc:animid;
    sound:psound;
    por:array[0..15] of byte;
    fon:array[0..3] of fontid;
    f,f2,fp:file;
    klx,kly:word;
    items,itemstxt,textptr:cpsid2;
    s,jmmis:string;
    mys:pointer;
    w,w2,pal,stav,podkl:typ;
    jm:array[1..8] of char;
    a:array[1..32768] of byte;
    ikon,smz,mz,but:byte;
    ikony:array[1..8] of cpsid;
    pomikon:pointer;
    r:registers;
const scenka:boolean=false;
      jmikon:array[1..8] of string[12]=('SIPKA.ICN','NOHA.ICN','RUKA.ICN','VOKO.ICN','MLUV.ICN','CLOCK.ICN','UKDIAL.ICN'
		,'MENU.ICN');
      pocikon=8;
      stikon:byte=1;
      sirikon=16;
      vysikon=16;
      smerzastaveni:byte=0;
      prvnivoc:boolean=true;
      speaker:boolean=false;
      klb:boolean=false;
      curmluv:byte=255;
      puvprikaz:boolean=false;
      selectedfont:byte=0;
      curkod:word=$0;
      manstojinafleku:boolean=true;
      znehybnenamysina:boolean=false;
      curotazka:byte=4;
      rozmerypanacka:panakid=(maxx:20;maxy:52;maxprx:4;maxpry:3);
      windowofitem:winitemid=(x1:182;y1:209;x2:294;y2:225);
      windowsr:winitemid=(x1:96;y1:65;x2:222;y2:164);
      mezeraodshora:byte=26;                                    {po‡et bod– od okraje r me‡ku savegamu}
      delkajmenasavegamu=24;
      maxcountofitem=8;
      pocitadlo:byte=0;ukazovadlo:byte=1;mazadlo:byte=0;
      maxodch:shortint=4;					{p©i obch zen¡ p©ek ‘ek - maxim ln¡ odchylka smˆru}
      lastsmer:byte=0;
      cuchmys:boolean=true;
      soundbl:boolean=true;
      fmsound:boolean=true;
      zacalhovorit:boolean=true;
      mys_state:boolean=true;
      zrus:integer=0;
      zrusupl:byte=0;
      prvnimis:boolean=true;
      zmizelapal:boolean=false;
      pauza486:byte=15;
procedure nastav;
procedure closegraph;
procedure inicializuj;
procedure odinicializuj;
procedure nastavpal(s:string);
procedure nastavpalmem;
procedure nacticps(s:string;x,y:integer);
procedure nacticpsmem(a:typ;x,y:integer;nr:word);
function nactiwsa(b:typ;x,y,od,nr:word):integer;
procedure pozadi(jo:boolean);
procedure nactishp(name:string);
procedure ulozpozadi;
procedure ukazpage(jo:boolean);
function jemluvici(cis:byte):boolean;
function nahraj(name:string):word;
function novapostava(s:string;x,y:integer;prep:byte):byte;
procedure zmenpostavu(cis:byte;name:string);
procedure umazpostavu(cis:byte);
function dodelal(cis:byte):boolean;
procedure dodelej(cis:byte);
procedure zmenprepis(cis:byte;x,y,prep:integer);
function nahrajzpaku(name:string):word;
procedure otevripak(name:string);
procedure zavripak;
function loadvoc(name:string;var sound:psound):longint;
procedure nacticpszpaku(name:string;x,y:integer);
procedure nactipalzpaku(name:string);
procedure nactishpzpaku(name:string);
procedure nahrajikonu(x:byte;name:string);
function cuchejplac(ox,oy:word):boolean;
function cuchejvychod(ox,oy:word):byte;
function cuchejsmer(ox,oy,nx2,ny2:word):byte;
procedure zrusvec(cis:byte);
procedure pausecmf;
procedure continuecmf;
procedure resetfm;
procedure pozadiin(jo:boolean);
procedure putpixel(sox,soy:integer;bar:byte);
procedure playcmf;
function playznovu:word;
procedure stopcmf;
function nahrajfontzpaku(name:string):byte;
procedure zobraz(x,y:word;s:array of char;del,font:byte);
procedure zmiz(od,po:byte);
procedure objevse(od,po:byte);
procedure rychlezmiz(od,po:byte);
procedure rychleobjevse(od,po:byte);
procedure mistnost(kam:byte);
procedure refreshpostavu(cis:byte;x,y:integer);
procedure animacezpaku(s:string);
procedure upravbudoucisouradnice;
procedure dodelejdialog;
procedure myska(jo:boolean);
procedure pistext(x,y:integer;s:array of char;del:byte);
procedure zruspouzivani;
procedure pistextman(s:array of char);
procedure ukazscenku(s:string);
procedure zobrazinventar;
procedure setfont(cis:byte);
function pouzij(po1,po2,po3:byte):boolean;
function cuchejkod(cis,cismluv,kod1,kod2,kod3,kod4:byte):boolean;
procedure nastavkod(kod1,kod2,kod3,kod4:byte);
procedure zrusvecuplne(cis:byte);
procedure prevedvecdokapsy(cis:byte);
procedure obnovroomshp;
procedure zapisbitdostavu(poz:word;bit,b:byte);
procedure zapisbytedostavu(poz:word;b:byte);
function nactibitzestavu(poz:word;bit:byte):byte;
function nactibytezestavu(poz:word):byte;
procedure savegame(s:string);
procedure restoregame(s:string);
function playvoc(name:string):boolean;
function vybersavegame(volpoz:boolean):byte;
procedure nechtzastavivesmeru(sm:byte);
procedure ikonahodinon(poc:word);
procedure ikonahodinoff;
implementation
{$L x1.obj}
procedure setxmode;external;
{$L xgraf.obj}
procedure grinit;external;
procedure grclose;external;
procedure grputpixel(x,y:word;col:byte);external;
procedure grsetworkpage(pg:byte);external;
procedure grsetdisppage(pg:byte);external;
procedure grmoveimage(x0,y0,x1,y1,dx0,dy0:word;srcpage,destpage:byte);external;
procedure grgetimage(x0,y0,x1,y1:word;img:pointer);external;
procedure grputimage(x0,y0,x1,y1:word;img:pointer);external;
procedure grputimagem(x0,y0,x1,y1:word;img:pointer;imgwid:word);external;
function grgetworkpage:byte;external;
function grgetdisppage:byte;external;
function grgetpixel(x,y:word):byte;external;
procedure grsetcolor(col:byte);external;
procedure grblock(x0,y0,x1,y1:word);external;
procedure obnovpozadi;forward;
procedure spravsouradnice;forward;
procedure spravtyhlesouradnice(var ox,oy:word);forward;
procedure mouseproc;far;
var puvodne:byte;
    xx2,yy2:word;
label nakon;
begin
xx2:=seg(mys^);
asm
	mov     ds,xx2
	mov     xx2,cx
	mov     yy2,dx
	mov     i,ax
end;
if (mys_state=false) and (i<>1) then goto nakon;
mys_state:=false;
puvodne:=grgetworkpage;
grsetworkpage(puvodne);
mys_state:=true;
nakon:
end;
const ikonpredhodinama:byte=0;
      pocsnimkunahod:word=0;
procedure ikonahodinon(poc:word);
begin
if ikon<>6 then ikonpredhodinama:=ikon;ikon:=6;pocsnimkunahod:=poc;
end;
procedure ikonahodinoff;
begin
if (ikonpredhodinama>0) and (pocsnimkunahod=0) then begin ikon:=ikonpredhodinama;end;
if pocsnimkunahod>0 then dec(pocsnimkunahod);
end;
function nactiwsaanm(b:typ;od,nr:word):integer;
var poz,pozm,i,j,k,l,l2,m,n:word;
label kon;
begin
poz:=od;
repeat
case b^[poz] of
	$2c:begin
		inc(poz);nw:=b^[poz]+b^[poz+1]*256-1;inc(poz,2);
		x1:=b^[poz]+(b^[poz+4] and 1) shl 8;y1:=b^[poz+1];x2:=b^[poz+2]+(b^[poz+4] and 16) shl 4;y2:=b^[poz+3];
		poz:=poz+5;i:=0;pozm:=poz+nw;
		k:=poz;m:=1;repeat
		 l:=b^[k];if l>$c0 then begin
		   l2:=b^[succ(k)];for n:=m to pred(m+l-$c0) do if l2>0 then w2^[n]:=l2 else w2^[n]:=255;
		 inc(m,l-$c0);inc(k,2);
		 end else begin if l>0 then w2^[m]:=l else w2^[m]:=255;inc(m);inc(k);end;
		until k>pozm;grputimagem(x1,y1,succ(x2),succ(y2),@w2^,succ(x2-x1));
		poz:=poz+nw+1;
	end;
	$00:begin
		inc(poz);nactiwsaanm:=poz;if poz>=nr then nactiwsaanm:=0;goto kon;end;
	else inc(poz);
end;
until poz>=nr;
nactiwsaanm:=0;
kon:
end;
procedure nacticpsmemanm(a:typ;nr:word);
var k,l,l2,m,n:word;
begin
x1:=a^[1]+(a^[5] and 1) shl 8;y1:=a^[2];x2:=a^[3]+(a^[5] and 16) shl 4;y2:=a^[4];
k:=6;m:=1;repeat
 l:=a^[k];if l>$c0 then begin
   l2:=a^[succ(k)];for n:=m to pred(m+l-$c0) do if l2>0 then w2^[n]:=l2 else w2^[n]:=255;
   inc(m,l-$c0);inc(k,2);
 end else begin if l>0 then w2^[m]:=l else w2^[m]:=255;inc(m);inc(k);end;
until k>nr;grputimagem(x1,y1,succ(x2),succ(y2),@w2^,succ(x2-x1));
end;
procedure zruspouzivani;
begin
use[1]:=0;use[2]:=0;use[3]:=0;
if mam[0]>0 then nahrajikonu(1,jmikon[1]);
end;
function playvoc(name:string):boolean;
begin
if not soundbl then exit;
playvoc:=true;if soundplaying then begin playvoc:=false;exit;end;
if not prvnivoc then freebuffer(sound,soundsize) else prvnivoc:=false;
soundsize:=loadvoc(name,sound);
if soundsize=0 then halt;
turnspeakeron;speaker:=true;playsound(sound);
end;
procedure setfont(cis:byte);
begin
selectedfont:=cis;
end;
procedure nahrajikonu(x:byte;name:string);
var i,j:integer;
    puvodne:byte;
    puvstate:boolean;
begin
if ikony[x].p<>nil then freemem(ikony[x].p,ikony[x].n);
nr:=nahrajzpaku(name);puvodne:=grgetworkpage;grsetworkpage(3);puvstate:=mys_state;
grsetcolor(255);grblock(0,0,sirikon,vysikon);
nacticpsmem(@w^,0,0,nr);ikony[x].n:=(sirikon+1)*(vysikon+2);
getmem(ikony[x].p,ikony[x].n);grgetimage(0,0,sirikon,vysikon,@ikony[x].p^);
if x=1 then begin
  for j:=0 to 1 do begin
	grsetworkpage(j);
	nr:=nahrajzpaku('VECFF.ICN');nacticpsmem(@w^,26,209,nr);
	grputimagem(26,209,26+sirikon,209+vysikon,@ikony[1].p^,sirikon);
  end;
end;
grsetworkpage(puvodne);
end;
procedure nechtzastavivesmeru(sm:byte);
begin
smerzastaveni:=sm;
end;
function vybersavegame(volpoz:boolean):byte;
var pommm,i,j:byte;
    sr:searchrec;
    fs:file;
    savy:array[1..5,1..delkajmenasavegamu] of char;
    savycis:array[1..5] of byte;
    zadam:array[1..delkajmenasavegamu] of char;
    bame,delzadam:byte;
procedure smazpozadicko(jojo:boolean);
var i,j:word;
begin
if jojo then grsetcolor(bame);
if jojo then grblock(windowsr.x1+2,windowsr.y1+mezeraodshora+(pommm-2)*15,
	windowsr.x2-2,windowsr.y1+mezeraodshora+(pommm-1)*15-4);
zobraz(windowsr.x1+3,windowsr.y1+(pommm-2)*15+mezeraodshora,zadam,delzadam,0);
end;
begin
pausecmf;nahrajikonu(2,'SIPKA.ICN');zadam:='Co chce¨ restorovat?    ';if volpoz then zadam:='Co chce¨ savit?         ';
ukazpage(true);pozadi(false);smx:=mx;smy:=my;grsetworkpage(pocitadlo);grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);
grsetworkpage(ukazovadlo);grputimage(mx,my,mx+sirikon,my+vysikon,@mys^);grsetworkpage(pocitadlo);
grgetimage(windowsr.x1,windowsr.y1,windowsr.x2,windowsr.y2,@podkl^);for i:=1 to 5 do savycis[i]:=0;
nacticpszpaku('SAVEREST.CPS',0,0);i:=1;zobraz(windowsr.x1+6,windowsr.y1+6,zadam,20,0);
grsetdisppage(pocitadlo);bame:=grgetpixel((windowsr.x1+windowsr.x2) shr 1,(windowsr.y1+windowsr.y2) shr 1);pommm:=0;repeat
	findfirst('panaca.sg'+chr(48+i),1,sr);if doserror=0 then begin
	assign(fs,sr.name);reset(fs,1);blockread(fs,savy[i],delkajmenasavegamu);savycis[i]:=1;close(fs);end;
	inc(i);
until (i=6);dec(i);
for j:=1 to i do if savycis[j]=0 then savy[j]:='Voln  pozice            ';i:=5;
for j:=1 to i do zobraz(windowsr.x1+3,windowsr.y1+mezeraodshora+(j-1)*15,savy[j],delkajmenasavegamu,0);
grgetimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);grsetdisppage(pocitadlo);grsetworkpage(pocitadlo);mx:=smx;my:=smy;
grputimagem(mx,my,mx+sirikon,my+vysikon,@ikony[2].p^,sirikon);
repeat
	r.ax:=3;intr($33,r);smx:=mx;smy:=my;mx:=r.cx;my:=r.dx;if (mx<>smx) or (smy<>my) then begin
		grputimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);
		grputimagem(mx,my,mx+sirikon,my+vysikon,@ikony[2].p^,sirikon);end;
	if r.bx=1 then begin
		r.ax:=5;r.bx:=0;intr($33,r);if r.bx>0 then begin
			if (mx>windowsr.x1) and (my>windowsr.y1) and (mx<windowsr.x2) and (my<windowsr.y2) then begin
				i:=trunc((my+2-windowsr.y1-mezeraodshora)/15)+1;if i>5 then i:=5;if i=0 then i:=1;
				if (savycis[i]=1) or (volpoz) then pommm:=i+1 else pommm:=0;
			end else pommm:=1;
		end;
	end;
until pommm>0;
grputimage(mx,my,mx+sirikon,my+vysikon,@mys^);nahrajikonu(2,jmikon[2]);
if (volpoz) and (pommm>1) then begin
	delzadam:=0;fillchar(zadam,delkajmenasavegamu,' ');smazpozadicko(true);
	repeat
		if keypressed then i:=ord(readkey) else i:=0;
		if (i>31) and (i<176) and (delzadam<delkajmenasavegamu) then begin
			inc(delzadam);zadam[delzadam]:=chr(i);smazpozadicko(false);end;
		if (i=8) and (delzadam>0) then begin zadam[delzadam]:=' ';dec(delzadam);smazpozadicko(true);end;
	until i in [13,10];
	for i:=1 to delkajmenasavegamu do a[i]:=ord(zadam[i]);
end;
grputimage(windowsr.x1,windowsr.y1,windowsr.x2,windowsr.y2,@podkl^);
grsetdisppage(ukazovadlo);grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);
ukazpage(false);pozadi(false);ukazpage(false);vybersavegame:=pommm-1;pozadi(true);nahrajikonu(2,jmikon[2]);
if (volpoz) or (pommm=1) then continuecmf;
end;
procedure savegame(s:string);
begin
assign(f,s);
if scenka then exit;rewrite(f,1);
blockwrite(f,a,delkajmenasavegamu);
a[1]:=cismis;a[2]:=pp[7];for i:=0 to pp[7] do begin
	a[3+i*28]:=lo(mp[i].x);a[4+i*28]:=hi(mp[i].x);
	a[5+i*28]:=lo(mp[i].y);a[6+i*28]:=hi(mp[i].y);
	a[7+i*28]:=lo(mp[i].s);a[8+i*28]:=hi(mp[i].s);
	for j:=0 to 3 do begin
		a[9+i*28+j*2]:=lo(mp[i].o[j+1]);
		a[10+i*28+j*2]:=hi(mp[i].o[j+1]);
	end;
	if mp[i].d then a[17+i*28]:=1 else a[17+i*28]:=0;
	a[18+i*28]:=mp[i].pr;
	for j:=1 to 12 do a[18+j+i*28]:=ord(mp[i].jm[j]);
end;
blockwrite(f,a,pp[7]*28+2);
a[1]:=stikon;a[2]:=lo(items.n);a[3]:=hi(items.n);for i:=0 to maxcountofitem do a[4+i]:=mam[i];
blockwrite(f,a,4+maxcountofitem);delay(10);blockwrite(f,items.p^,items.n);
a[1]:=lo(stavsiz);a[2]:=hi(stavsiz);
blockwrite(f,a,2);for j:=1 to stavsiz do a[j]:=stav^[j];
blockwrite(f,a,stavsiz);
close(f);
end;
procedure restoregame(s:string);
var p1,p2,p3:word;
    nam:string;
begin
zmiz(0,255);
for i:=1 to 3 do use[i]:=0;for i:=0 to maxcountofitem do mam[i]:=255;
while pp[7]>0 do umazpostavu(pp[7]-1);
grputimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);
assign(f,s);reset(f,1);blockread(f,a,delkajmenasavegamu);
blockread(f,a,2);cismis:=a[1];pp[7]:=a[2];blockread(f,a,28*pp[7]);
if pp[7]>0 then for i:=0 to pp[7]-1 do begin
	mp[i+8].x:=a[1+i*28]+a[2+i*28] shl 8;mp[i+8].y:=a[3+i*28]+a[4+i*28] shl 8;mp[i+8].jm:='';
	for j:=1 to 12 do mp[i+8].jm:=mp[i+8].jm+chr(a[16+i*28+j]);
	mp[i+8].pr:=a[16+i*28];
	mp[i+8].s:=a[5+i*28]+a[6+i*28] shl 8;if a[15+i*28]=1 then mp[i+8].d:=true else mp[i+8].d:=false;
	for j:=0 to 3 do mp[i+8].o[j+1]:=a[7+i*28+j*2]+a[8+i*28+j*2] shl 8;
end;
freemem(items.p,items.n);
blockread(f,a,4+maxcountofitem);ikon:=a[1];stikon:=a[1];items.n:=a[2]+(a[3] shl 8);
for i:=0 to maxcountofitem do mam[i]:=a[4+i];getmem(items.p,items.n);
blockread(f,items.p^,items.n);pocvec:=items.n shr 3;
freemem(stav,stavsiz);mam[0]:=0;nahrajikonu(1,'SIPKA.ICN');
blockread(f,a,2);stavsiz:=a[1]+(a[2] shl 8);getmem(stav,stavsiz);
blockread(f,stav^,stavsiz);
close(f);zobrazinventar;
p[0].vych.kam:=cismis;p1:=pp[7];
if p1>0 then for i:=0 to p1-1 do begin
	pp[7]:=i;
	novapostava(mp[i+8].jm,mp[i+8].x,mp[i+8].y,mp[i+8].pr);
	mp[i].s:=mp[i+8].s;
end;
pp[7]:=p1;
mistnost(0);pozadi(true);
end;
procedure ukazscenku(s:string);
begin
scenka:=true;sc.n:=nahrajzpaku(s);getmem(sc.p,sc.n);move(w^,sc.p^,sc.n);sc.s:=1;
end;
procedure zapisbitdostavu(poz:word;bit,b:byte);
var pom,pom2:byte;
    k,k2:integer;
begin
inc(poz);k2:=k;
pom:=1;if bit>0 then for k:=1 to bit do pom:=pom*2;k:=stav^[poz];
pom2:=(stav^[poz] and pom);
if ((pom2=0) and (b>0)) or ((pom2>0) and (b=0)) then stav^[poz]:=stav^[poz] xor pom;
obnovroomshp;k:=k2;
end;
procedure zapisbytedostavu(poz:word;b:byte);
begin
inc(poz);stav^[poz]:=b;obnovroomshp;
end;
function nactibitzestavu(poz:word;bit:byte):byte;
var pom,k:byte;
begin
inc(poz);
pom:=1;if bit>0 then for k:=1 to bit do pom:=pom*2;
pom:=(stav^[poz] and pom);if pom>0 then nactibitzestavu:=1 else nactibitzestavu:=0;
end;
function nactibytezestavu(poz:word):byte;
begin
inc(poz);nactibytezestavu:=stav^[poz];
end;
function pouzij(po1,po2,po3:byte):boolean;
var smazat:boolean;
begin
pouzij:=false;smazat:=false;
if not manstojinafleku then exit;
if (po1=use[1]) and (po2=use[2]) and (po3=use[3]) then begin
	pouzij:=true;if (use[2]=0) and (use[3]=0) then smazat:=true;end;
if smazat then begin
	use[1]:=0;mam[0]:=0;nahrajikonu(1,jmikon[1]);
end else if ikon=1 then begin use[1]:=mam[0];use[2]:=0;use[3]:=0;end
end;
procedure zobrazinventar;
var i,j,k,l:byte;
    nr:word;
begin
mazadlo:=pocitadlo;
for j:=0 to 1 do begin
  grsetworkpage(j);
  for i:=1 to maxcountofitem do begin
	nr:=nahrajzpaku('VECFF.ICN');nacticpsmem(@w^,(i-1)*(sirikon+4)+windowofitem.x1,windowofitem.y1,nr);
	jm[1]:='V';jm[2]:='E';jm[3]:='C';
	k:=mam[i] shr 4;l:=mam[i]-(k*16);jm[4]:=chr(k+48);if k>9 then jm[4]:=chr(k+55);
	jm[5]:=chr(l+48);if l>9 then jm[5]:=chr(l+55);
	s:=jm;s:=copy(s,1,5)+'.ICN';
	if mam[i]<255 then begin
		nr:=nahrajzpaku(s);nacticpsmem(@w^,(i-1)*(sirikon+4)+windowofitem.x1,windowofitem.y1,nr);
	end;
	if mam[i]=255 then i:=maxcountofitem;
  end;
  nr:=nahrajzpaku('VECFF.ICN');nacticpsmem(@w^,22,windowofitem.y1-1,nr);
  for i:=1 to pocikon-3 do
	grputimagem((i-1)*(sirikon+13)+22,208,(i-1)*(sirikon+13)+sirikon+22,208+vysikon,@ikony[i].p^,sirikon);
end;
grsetworkpage(mazadlo);
end;
procedure animacezpaku(s:string);
var anr,poc,max,i,j,k,akt:word;
    ba:typ;
    tabk:array[1..999] of word;
    speed,typ:byte;
const hudba:boolean=false;
label jestejeden;
begin
rychlezmiz(0,255);stopcmf;
grsetworkpage(0);grsetcolor(0);grblock(0,0,319,240);
if pp[4]>0 then for i:=0 to pp[4]-1 do freemem(m[i].p,m[i].n);
if pp[5]>0 then for i:=0 to pp[5]-1 do freemem(mc[i].p,mc[i].n);
for i:=1 to 6 do pp[i]:=0;for i:=9 to 11 do pp[i]:=0;
anr:=nahrajzpaku(s);getmem(ba,anr);move(w^,ba^,anr);for i:=1 to anr do ba^[i]:=ba^[i] xor $dc;
max:=ba^[1]+ba^[2] shl 8;speed:=ba^[3];k:=4;typ:=ba^[k];if typ in [1,2,4,5] then akt:=ba^[k+9]+ba^[k+10] shl 8 else
 begin i:=ba^[k+1]+5;akt:=ba^[k+i]+ba^[k+i+1] shl 8;end;
grsetworkpage(1);grsetdisppage(0);
for poc:=1 to max do begin
if poc=2 then objevse(0,255);
if akt=poc then jestejeden:
  if typ in [1,2,4,5] then begin
	s:='';for j:=1 to 8 do s:=s+chr(ba^[k+j]);inc(k,11);s:=copy(s,1,pos(' ',s)-1);
  end;
  if typ=1 then begin
	s:=s+'.WSA';m[pp[4]].n:=nahrajzpaku(s);getmem(m[pp[4]].p,m[pp[4]].n);
	move(w^,m[pp[4]].p^,m[pp[4]].n);m[pp[4]].s:=1;
	inc(pp[4]);
  end;
  if typ=2 then begin
	s:=s+'.CPS';nacticpsmemanm(@w^,nahrajzpaku(s));
  end;
  if typ=3 then begin
  end;
  if typ=4 then begin
	s:=s+'.VOC';playvoc(s);
  end;
  if typ=5 then begin
	s:=s+'.CMF';stopcmf;pissiz:=nahrajzpaku(s);move(w^,cmf^,pissiz);
	resetfm;playcmf;hudba:=true;
  end;
if pp[4]>0 then for i:=0 to pp[4]-1 do begin
	m[i].s:=nactiwsaanm(@m[i].p^,m[i].s,m[i].n);
	if m[i].s=0 then begin
		dec(pp[4]);if pp[4]>1 then begin
			m[i].p:=@m[pp[4]].p^;
			m[i].s:=m[pp[4]].s;m[i].n:=m[pp[4]].n;
		end;
		freemem(m[pp[4]].p,m[pp[4]].n);
	end;
end;
delay(speed);
typ:=ba^[k];if typ in [1,2,4,5] then akt:=ba^[k+9]+ba^[k+10] shl 8 else
 begin i:=ba^[k+1]+5;akt:=ba^[k+i]+ba^[k+i+1] shl 8;end;
if hudba then playznovu;
if (not soundplaying) and (speaker) and (soundbl) then begin
	speaker:=false;turnspeakeroff;freebuffer(pointer(sound),soundsize);getbuffer(pointer(sound),1);soundsize:=1;
end;
if akt=poc then goto jestejeden;
end;
if pp[4]>0 then for i:=0 to pp[4]-1 do freemem(m[i].p,m[i].n);pp[4]:=0;
grsetworkpage(0);freemem(ba,anr);zmiz(0,255);if hudba then stopcmf;grsetcolor(0);grblock(0,0,319,239);
grsetworkpage(pocitadlo);grsetdisppage(ukazovadlo);if soundbl then turnspeakeroff;speaker:=false;
end;
procedure nastav;
begin
grinit;
end;
procedure closegraph;
begin
grclose;
asm
	mov     ax,3
	int     10h
end;
end;
procedure pausecmf;
begin
playcmfu.pausecmf;
end;
procedure continuecmf;
begin
playznovu;
end;
procedure resetfm;
begin
if not(fmsound) then exit;playcmfu.resetfm;
end;
procedure playcmf;
begin
if (not(fmsound)) or (pissiz=0) then exit;
instruments_table;playsong;
end;
function playznovu:word;
begin
if not(fmsound) then exit;
if playsong then playznovu:=1 else playznovu:=0;
end;
procedure stopcmf;
begin
if (not(fmsound)) or (pissiz=0) then exit;playcmfu.stopcmf;
end;
procedure preved;
begin
if (pr[4] and 1<>0) then pr[0]:=pr[0]+256;
if (pr[4] and 16<>0) then pr[2]:=pr[2]+256;
end;
function cuchejplac(ox,oy:word):boolean;
var pr:array[0..4] of integer;
    puvx,puvy:word;
begin
cuchejplac:=true;spravtyhlesouradnice(ox,oy);
if pp[1]>0 then begin
	for i:=0 to pp[1]-1 do begin
		for j:=0 to 4 do pr[j]:=p[i].nem[j];
		if (pr[4] and 1<>0) then inc(pr[0],256);
		if (pr[4] and 16<>0) then inc(pr[2],256);
		if (pr[0]<=ox) and (pr[2]>=ox) and (oy>=pr[1]) and (oy<=pr[3]) then cuchejplac:=false;
	end;
end;
if pp[3]>0 then begin
	for i:=0 to pp[3]-1 do begin
	  for j:=0 to 4 do pr[j]:=p[i].scen.obl[j];preved;
	  if (pr[4] and 128<>0) and (mp[0].x>pr[0]) and (mp[0].x<pr[2]) and (mp[0].pr>pr[1]) and (mp[0].pr<pr[3]) then begin
			s:=p[i].scen.jm+' ';pr[0]:=1;while s[pr[0]]<>' ' do inc(pr[0]);
			s:=copy(s,1,pr[0]-1)+'.WSA';
			scenka:=true;sc.n:=nahrajzpaku(s);getmem(sc.p,sc.n);move(w^,sc.p^,sc.n);sc.s:=1;
	  end;
	end;
end;
end;
function cuchejvychod(ox,oy:word):byte;
begin
cuchejvychod:=255;
spravtyhlesouradnice(ox,oy);
if pp[2]>0 then begin
	for i:=0 to pp[2]-1 do begin
		for j:=0 to 4 do pr[j]:=p[i].vych.obl[j];
		if (pr[4] and 1<>0) then inc(pr[0],256);
		if (pr[4] and 16<>0) then inc(pr[2],256);
		if (pr[0]<=ox) and (pr[2]>=ox) and (oy>=pr[1]) and (oy<=pr[3]) then begin
			cuchejvychod:=i;
		end;
	end;
end;
end;
function cuchejsmer(ox,oy,nx2,ny2:word):byte;
var smsm,ssmsm,i,prx,pry:shortint;
    odch:shortint;
const kr:array[71..81,0..1] of shortint=((-2,-1),(0,-2),(2,-1),(0,0),(-2,0),(0,0),(2,0),(0,0),(-2,1),(0,2),(2,1));
      smer:array[1..8] of shortint=(71,72,73,77,81,80,79,75);
begin
smsm:=76;
if (abs(ox-nx2)>rozmerypanacka.maxprx+1) then begin
	if ox>nx2 then smsm:=75;
	if ox<nx2 then smsm:=77;
end;
if (abs(oy-ny2)>rozmerypanacka.maxpry+1) then begin
	if oy>ny2 then dec(smsm,4);
	if oy<ny2 then inc(smsm,4);
end;odch:=0;if smsm<>76 then begin for i:=1 to 8 do if smsm=smer[i] then ssmsm:=i;smsm:=ssmsm;end;
if smsm=76 then begin lastsmer:=0;cuchejsmer:=0;end else begin
 prx:=shortint(kr[smer[smsm],0]*shortint(rozmerypanacka.maxprx)) shr 1;
 pry:=shortint(kr[smer[smsm],1]*shortint(rozmerypanacka.maxpry)) shr 1;
 if (cuchejplac(ox+integer(prx),oy+integer(pry))=false) and (lastsmer>0) then begin
	prx:=shortint(kr[lastsmer,0]*shortint(rozmerypanacka.maxprx)) shr 1;
	pry:=shortint(kr[lastsmer,1]*shortint(rozmerypanacka.maxpry)) shr 1;
	if cuchejplac(ox+integer(prx),oy+integer(pry))=true then begin
		for i:=1 to 8 do if lastsmer=smer[i] then begin ssmsm:=i;smsm:=ssmsm;end;
	end;
 end;
 while(cuchejplac(ox+integer(prx),oy+integer(pry))=false)
          and (abs(odch)<abs(maxodch)) do begin
  smsm:=ssmsm;inc(smsm,odch);
  if smsm<1 then inc(smsm,8);if smsm>8 then dec(smsm,8);
  odch:=-odch;if odch>=0 then inc(odch);
  prx:=shortint(kr[smer[smsm],0]*shortint(rozmerypanacka.maxprx)) shr 1;
  pry:=shortint(kr[smer[smsm],1]*shortint(rozmerypanacka.maxpry)) shr 1;
 end;smsm:=smer[smsm];
 if odch=maxodch then begin cuchejsmer:=0;lastsmer:=0;end else begin cuchejsmer:=smsm;lastsmer:=smsm;end
end;
end;
function dodelal(cis:byte):boolean;
begin
if cis>=pp[7] then exit;
dodelal:=mp[cis].d;
end;
procedure dodelej(cis:byte);
begin
mp[cis].d:=true;
end;
function jemluvici(cis:byte):boolean;
begin
if (cis=curmluv and 31) and (curmluv<255) then jemluvici:=true else jemluvici:=false;
end;
procedure dodelejdialog;
begin
curmluv:=255;curkod:=0;curotazka:=4;ikon:=5;umazpostavu(postavarozhovoru);
obnovpozadi;
end;
function cuchejkod(cis,cismluv,kod1,kod2,kod3,kod4:byte):boolean;
var hledejkod,maskahledani:word;
    delkakodu:byte;
begin
cuchejkod:=false;delkakodu:=4;if kod4=0 then delkakodu:=3;if kod3=0 then delkakodu:=2;if kod2=0 then delkakodu:=1;
inc(kod4);inc(kod3);inc(kod2);
if delkakodu>1 then dec(kod2);if delkakodu>2 then dec(kod3);if delkakodu=4 then dec(kod4);
if (cismluv<>curmluv and 31) or (curmluv=255) then exit;
if (kod1>0) and ((curmluv and $60) shr 5=delkakodu-1) and (cis=cismis) then begin
	maskahledani:=($ff shr (2*(4-delkakodu)));hledejkod:=(kod1-1+(kod2-1) shl 2+(kod3-1) shl 4+(kod4-1) shl 6);
	if curkod and maskahledani=hledejkod and maskahledani then cuchejkod:=true;
end;
if kod1=0 then cuchejkod:=not zacalhovorit;
if (kod1=1) and (delkakodu=1) and (not zacalhovorit) then cuchejkod:=false;
end;
procedure nastavkod(kod1,kod2,kod3,kod4:byte);
var delkakodu:byte;
begin
curmluv:=curmluv and 31;delkakodu:=4;if kod4=0 then delkakodu:=3;if kod3=0 then delkakodu:=2;if kod2=0 then delkakodu:=1;
inc(kod4);inc(kod3);inc(kod2);
if delkakodu>1 then dec(kod2);if delkakodu>2 then dec(kod3);if delkakodu=4 then dec(kod4);
curmluv:=curmluv+(delkakodu-1) shl 5;curkod:=kod1-1+(kod2-1) shl 2+(kod3-1) shl 4+(kod4-1) shl 6;
end;
procedure savnipozadi;
begin
pozadi(false);ukazpage(false);smx:=mx;smy:=my;my:=210;smy:=210;
grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);grsetworkpage(ukazovadlo);
grputimage(mx,my,mx+sirikon,my+vysikon,@mys^);grsetworkpage(pocitadlo);
grmoveimage(0,200,319,239,0,30,ukazovadlo,3);
r.ax:=8;r.cx:=0;r.dx:=39;intr($33,r);
r.ax:=7;r.cx:=0;r.dx:=0;intr($33,r);r.ax:=4;r.cx:=0;r.dx:=10;intr($33,r);mx:=0;smx:=0;
end;
procedure vyberotazku;
var hledejkod,maskahledani:word;
begin
pozadi(false);ukazpage(true);smx:=mx;smy:=my;
grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);grsetworkpage(ukazovadlo);
grputimage(mx,my,mx+sirikon,my+vysikon,@mys^);grsetworkpage(pocitadlo);pozadi(false);
for i:=0 to 1 do begin
	grsetworkpage(i);grsetcolor(0);grblock(0,200,319,239);
end;
grgetimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);
grsetworkpage(ukazovadlo);
i:=(curmluv and $60) shr 5;
maskahledani:=$FF+($FF shr (2*(4-i))) shl 8;hledejkod:=(curmluv+curkod shl 8) and maskahledani;j:=0;
ukazpage(true);smx:=mx;smy:=my;grgetimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);
grsetworkpage(ukazovadlo);grputimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);grsetworkpage(pocitadlo);
for l:=0 to pp[11]-1 do begin
	if (hledejkod=p[l].dial.kod and maskahledani) then begin
		grsetworkpage(pocitadlo);zobraz(sirikon,200+j*10,p[l].dial.text,p[l].dial.del,0);
		grsetworkpage(pocitadlo xor 1);zobraz(sirikon,200+j*10,p[l].dial.text,p[l].dial.del,0);inc(j);
	end;
end;
pozadi(false);ukazpage(false);grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);
if j>1 then begin
	r.ax:=8;r.cx:=0;r.dx:=9+(j-1)*10;intr($33,r);
end;
if j>1 then repeat
	playznovu;pozadi(false);
	r.ax:=3;intr($33,r);smx:=mx;smy:=my;mx:=r.cx;my:=trunc(r.dx/10)*10+200;
	grputimagem(mx,my,mx+sirikon,my+vysikon,@ikony[ikon].p^,sirikon);
	ukazpage(true);
until (r.bx=1) and (my+vysikon>200);
curotazka:=(my-200) div 10 and 3;i:=(curmluv and $60) shr 5;hledejkod:=0;
if j=1 then curotazka:=0;
if (curotazka>j-1) and (j>0) then curotazka:=j-1;
hledejkod:=curkod and ($ff shr (3-i));hledejkod:=hledejkod+(curotazka and 3) shl (2*i);
curkod:=hledejkod;
pozadi(false);ukazpage(true);smx:=mx;smy:=my;grgetimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);
grputimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);pozadi(false);
end;
procedure obnovpozadi;
begin
grmoveimage(0,30,319,69,0,200,3,ukazovadlo);grmoveimage(0,30,319,69,0,200,3,pocitadlo);
grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);
ukazpage(true);grsetworkpage(pocitadlo);pozadi(false);
zobrazinventar;
r.ax:=8;r.cx:=1;r.dx:=239-vysikon;intr($33,r);
r.ax:=7;r.cx:=1;r.dx:=319-sirikon;intr($33,r);
r.ax:=4;r.cx:=mx;r.dx:=my-20;intr($33,r);
end;
procedure upravkodpoodpovedi;
var hledejkod,maskahledani:word;
begin
curmluv:=curmluv+$20;if curmluv>127 then begin
	curmluv:=curmluv xor 128;curkod:=0;
end;i:=(curmluv and $60) shr 5;
maskahledani:=$7f+($ff shr (2*(3-i))) shl 8;hledejkod:=(curmluv+lo(curkod) shl 8) and maskahledani;j:=0;
for l:=0 to pp[11]-1 do begin
	if (hledejkod<>p[l].dial.kod and maskahledani) then inc(j);
end;
if j=pp[11] then begin
	curkod:=0;curmluv:=curmluv and $1f;
end;
end;
procedure spravtyhlesouradnice(var ox,oy:word);
begin
ox:=ox-(rozmerypanacka.maxx-sirikon) shr 1+3;
oy:=oy+rozmerypanacka.maxy-3;
end;
procedure spravsouradnice;
begin
mp[0].x:=mp[0].x-(rozmerypanacka.maxx-sirikon) shr 1+3;
mp[0].y:=mp[0].y+rozmerypanacka.maxy-vysikon-3;
end;
procedure upravbudoucisouradnice;
begin
nx:=nx+(rozmerypanacka.maxx-sirikon) shr 1-3;
ny:=ny-rozmerypanacka.maxy+vysikon+3;
if nx<4 then nx:=4;if nx>307 then nx:=307;if ny<20 then ny:=20;if ny>179 then ny:=179;
end;
procedure myska(jo:boolean);
var p1,p2:integer;
    po:pointer;
    puvodne:byte;
    zmena:boolean;
    puvx,puvy,i,j,k,l,mx2,my2:word;
begin
if (curmluv=255) and (not klb) then begin
	if ikon<8 then stikon:=ikon;
	if ((my>196) and (my<204)) or ((my>203) and ((mx<10) or (mx>295) or (((mx>163) and (mx<175))))) or (my>217)
	then ikon:=8 else ikon:=stikon;
end;
puvx:=mp[0].x;puvy:=mp[0].y;spravsouradnice;
if jo then begin
mys_state:=true;puvodne:=grgetworkpage;if ikon=6 then ikonahodinoff;
r.ax:=5;r.bx:=0;intr($33,r);if r.bx>1 then r.bx:=1;but:=r.bx;
r.ax:=3;intr($33,r);smx:=mx;smy:=my;if curmluv<255 then r.dx:=trunc(r.dx/10)*10+200;
if not znehybnenamysina then begin mx:=r.cx;my:=r.dx end else znehybnenamysina:=false;
if not zacalhovorit then my:=210;
grsetworkpage(pocitadlo);
grputimagem(mx,my,mx+sirikon,my+vysikon,@ikony[ikon].p^,sirikon);
zrus:=0
end;
if (but=1) and (mx>12) and (mx<165) and (my>199) and (ikon<6) then begin
	ikon:=trunc((mx-12)/(sirikon+13))+1;klb:=false;
	if ikon=1 then begin
		use[1]:=mam[0];use[2]:=0;use[3]:=0
	end
end;
if (but=1) and (ikon=2) and (jo) and (my<196) and (my>20) then begin
	nx:=mx;ny:=my;upravbudoucisouradnice;dodelej(0);if (cuchejplac(nx,ny)=false) or (my<20+rozmerypanacka.maxy-vysikon) then begin
		nx:=mp[0].x;ny:=mp[0].y;upravbudoucisouradnice;klb:=false end
end;
if (curmluv<128) and (jo) and (zacalhovorit) then begin
	mp[0].x:=puvx;mp[0].y:=puvy;upravkodpoodpovedi;klb:=false
end;
if ((but=1) or (klb)) and (pp[10]>0) and (jo) and (ikon=5) and (curmluv=255) then begin
	if klb then begin my2:=my;mx2:=mx;mx:=klx;my:=kly;zmena:=true;end else zmena:=false;
	for k:=0 to pp[10]-1 do begin
		if (mx>=p[k].mluv.obl[0]) and (my>=p[k].mluv.obl[1]) then
		if (mx<=p[k].mluv.obl[2]) and (my<=p[k].mluv.obl[3]) then begin
			if (abs(mp[0].x-p[k].mluv.kam[0])<=rozmerypanacka.maxprx+1) and
				(abs(mp[0].y-p[k].mluv.kam[1])<=rozmerypanacka.maxpry+1) then begin
				  if manstojinafleku then begin
					mp[0].x:=puvx;mp[0].y:=puvy;curmluv:=p[k].mluv.kod and $1f;curkod:=0;ikon:=7;jo:=false;
					s:=p[k].mluv.jm+' ';j:=0;while s[j]<>' ' do inc(j);dec(j);
					r.ax:=4;r.cx:=319-sirikon;r.dx:=239-vysikon;intr($33,r);
					if zmena then begin mx:=mx2;my:=my2;zmena:=false end;
					s:=copy(s,1,j)+'.WSA';ukazpage(true);smx:=mx;smy:=my;
					grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);grsetworkpage(ukazovadlo);
					grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);grsetworkpage(pocitadlo);dodelej(0);
					zacalhovorit:=false;postavarozhovoru:=novapostava(s,p[k].mluv.obl[0],p[k].mluv.obl[1],
						p[k].mluv.prep);pozadi(false);klb:=false;
				  end
			end else begin
				nx:=p[k].mluv.kam[0];ny:=p[k].mluv.kam[1];upravbudoucisouradnice;if not klb then begin klb:=true;klx:=mx;kly:=my;end;
			end;
		end;
	end;
	if zmena then begin mx:=mx2;my:=my2;end;
end;
if ((but=1) or (klb)) and (pocit>0) and (ikon=3) and (jo) then begin
	if klb then begin mx2:=mx;my2:=my;mx:=klx;my:=kly;zmena:=true;end else zmena:=false;
	for k:=0 to pocit-1 do begin
		i:=(tabit[k].i-1)*8;p1:=items.p^[i+3];p2:=items.p^[i+4];if items.p^[i+7] and 1<>0 then inc(p1,256);
		if (mx>=p1) and (my>=p2) then begin
			p1:=items.p^[i+5];p2:=items.p^[i+6];if items.p^[i+7] and 16<>0 then inc(p1,256);
			if (mx<=p1) and (my<=p2) and (items.p^[i+2]<255) then begin
			   if (abs(mp[0].x-mx)<=rozmerypanacka.maxprx+1) and (abs(mp[0].y-my)<=rozmerypanacka.maxpry+1) then begin
				    if manstojinafleku then begin
					zrus:=(k+1);items.p^[i+2]:=255;mp[0].x:=puvx;mp[0].y:=puvy;jo:=false;znehybnenamysina:=true;
					for j:=1 to maxcountofitem do if mam[j]=$ff then begin mam[j]:=items.p^[i+1];j:=maxcountofitem;
					k:=pocit-1 end;if zmena then begin mx:=mx2;my:=my2;zmena:=false;end;
					zobrazinventar;{grgetimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);}klb:=false;
				    end
			   end else begin
					nx:=p1-8;ny:=p2-8;k:=pocit-1;upravbudoucisouradnice;if not klb then begin klb:=true;klx:=mx;kly:=my;end;
			   end;
			end;
		end;
	end;
	if zmena then begin mx:=mx2;my:=my2;end;
end;
if (curmluv<128) and (jo) then begin
	mp[0].x:=puvx;mp[0].y:=puvy;if not zacalhovorit then savnipozadi;
	ikon:=7;vyberotazku;zacalhovorit:=true;
	for k:=0 to pp[11]-1 do begin
		if (hi(p[k].dial.kod)=curkod) and (lo(p[k].dial.kod)=curmluv) then begin
			inc(textptr.n);textptr.p^[textptr.n]:=p[k].dial.del;
			for i:=1 to p[k].dial.del do textptr.p^[textptr.n+i]:=ord(p[k].dial.text[i]);
			inc(textptr.n,p[k].dial.del);
		end;
	end;
	curmluv:=curmluv xor 128;klb:=false;
end;
if (curmluv>127) and (curmluv<255) and (jo) then begin
	mp[0].x:=puvx;mp[0].y:=puvy;for k:=0 to pp[11]-1 do begin
		if (hi(p[k].dial.kod)=curkod) and (lo(p[k].dial.kod)=curmluv) then begin
			inc(textptr.n);textptr.p^[textptr.n]:=p[k].dial.del+128;i:=0;
			if pp[10]>0 then for l:=0 to pp[10]-1 do if curmluv and 31=p[l].mluv.kod and 31 then i:=l;
			textptr.p^[textptr.n+1]:=lo((p[i].mluv.obl[0]+p[i].mluv.obl[2]) shr 1);
			textptr.p^[textptr.n+2]:=hi((p[i].mluv.obl[0]+p[i].mluv.obl[2]) shr 1);
			textptr.p^[textptr.n+3]:=p[i].mluv.obl[1]-16;inc(textptr.n,3);
			for i:=1 to p[k].dial.del do textptr.p^[textptr.n+i]:=ord(p[k].dial.text[i]);
			inc(textptr.n,p[k].dial.del);
		end;
	end;
	curmluv:=curmluv xor 128;klb:=false;
end;
if (but=1) and (pp[6]>0) and (ikon=4) and (jo) and (manstojinafleku) then begin
	for k:=0 to pp[6]-1 do begin
		if (mx>=p[k].t.obl[0]) and (mx<=p[k].t.obl[2]) then
		if (my>=p[k].t.obl[1]) and (my<=p[k].t.obl[3]) then begin
			inc(textptr.n);textptr.p^[textptr.n]:=p[k].t.del;
			for i:=1 to p[k].t.del do textptr.p^[textptr.n+i]:=ord(p[k].t.text[i]);
			inc(textptr.n,p[k].t.del);
		end;klb:=false;
	end;
end;
if (but=1) and (pp[3]>0) and (not(scenka)) and (ikon=3) and (jo) then begin
	for k:=0 to pp[3]-1 do begin
		p1:=p[k].scen.obl[0];p2:=p[k].scen.obl[2];
		if (mx>=p1) and (mx<=p2) then begin
			p1:=p[k].scen.obl[1];p2:=p[k].scen.obl[3];
			if (my>=p1) and (my<=p2) and (p[k].scen.obl[4] and 128=0) then begin
				s:=p[k].scen.jm+' ';j:=1;
				while copy(s,j,1)<>' ' do inc(j);
				s:=copy(s,1,j-1)+'.WSA';
				sc.n:=nahrajzpaku(s);getmem(sc.p,sc.n);move(w^,sc.p^,sc.n);
				scenka:=true;sc.s:=1;
			end;
		end;
	end;
end;
if (but=1) and (mam[1]<255) and (ikon=3) and (jo) and (mx>windowofitem.x1) and (my>windowofitem.y1) then
   if (mx<windowofitem.x2) and (my<windowofitem.y2) then begin
	nr:=nahrajzpaku('VECFF.ICN');j:=grgetworkpage;for i:=0 to 1 do begin
		grsetworkpage(i);nacticpsmem(@w^,22,windowofitem.y1-1,nr);end;grsetworkpage(j);
	use[1]:=mam[trunc((mx-windowofitem.x1)/(sirikon+2))+1];mam[0]:=use[1];ikon:=1;use[2]:=0;use[3]:=0;
	{freemem(ikony[1].p,ikony[1].n);}jm[1]:='V';jm[2]:='E';jm[3]:='C';
	i:=mam[0] shr 4;j:=mam[0]-(i shl 4);jm[4]:=chr(i+48);if i>9 then jm[4]:=chr(i+55);
	jm[5]:=chr(j+48);if j>9 then jm[5]:=chr(j+55);s:=jm;s:=copy(s,1,5)+'.ICN';
	if (mam[0]=255) or (mam[0]=0) then begin s:=jmikon[1];use[1]:=0;mam[0]:=use[1];end;
	nahrajikonu(1,s);klb:=false
end;
if (but=1) and (itemstxt.n>4) and (ikon=4) and (jo) and (mx+5>windowofitem.x1) and (my+5>windowofitem.y1) then
   if (mx+5<windowofitem.x2) and (my+5<windowofitem.y2) then begin
	l:=mam[trunc((mx+sirikon shr 1-windowofitem.x1)/(sirikon+4))+1];
	k:=1;repeat
		if itemstxt.p^[k]=l then begin
			for j:=1 to itemstxt.p^[k+1]+1 do textptr.p^[textptr.n+j]:=itemstxt.p^[k+j];
			inc(textptr.n,itemstxt.p^[k+1]+1);inc(k,itemstxt.p^[k+1]+4)
		end else begin
			inc(k,itemstxt.p^[k+1]+4)
		end;
	until k>=itemstxt.n;klb:=false
end;
if ((but=1) or (klb)) and (pp[9]>0) and (jo) and (((use[1]>0) and (ikon=1)) or (ikon=3)) then begin
	if ikon=3 then use[1]:=0;
	if klb then begin mx2:=mx;my2:=my;mx:=klx;my:=kly;zmena:=true end else zmena:=false;
	for k:=0 to pp[9]-1 do begin
		if (mx>=p[k].use.obl[0]) and (mx<=p[k].use.obl[2]) and (my>=p[k].use.obl[1]) and 
				(my<=p[k].use.obl[3]) and (my<160) then begin
		  if (abs(mp[0].x-p[k].use.kam[0])<=rozmerypanacka.maxprx+1) and
		    (abs(mp[0].y-p[k].use.kam[1])<=rozmerypanacka.maxpry+1) then begin 
		      if mp[0].jm[2]='0' then begin
			if zmena then begin mx:=mx2;my:=my2;zmena:=false;end;
			use[3]:=cismis;use[2]:=k;klb:=false;jo:=false
		      end
		  end else begin
			nx:=p[k].use.kam[0];ny:=p[k].use.kam[1];upravbudoucisouradnice;
			if not klb then begin klb:=true;kly:=my;klx:=mx end
		  end
		end
	end;
	if zmena then begin mx:=mx2;my:=my2 end
end;
if (but=1) and (jo) and (ikon=1) and (use[1]>0) and (use[1]<255) and (my>160) then begin
	if (my>windowofitem.y1) and (mx>windowofitem.x1) and (my<windowofitem.y2) and (mx<windowofitem.x2) then begin
		use[3]:=255;i:=mam[trunc((mx-windowofitem.x1)/(sirikon+2))+1];if (i>0) and (i<255) then use[2]:=i;
		if use[1]=use[2] then begin use[2]:=0;use[3]:=0;end;
	end;klb:=false;
end;
mp[0].x:=puvx;mp[0].y:=puvy;
end;
procedure refreshpostavu(cis:byte;x,y:integer);
begin
mp[cis].o[1]:=x-rozmerypanacka.maxprx;mp[cis].o[2]:=y-rozmerypanacka.maxpry;
mp[cis].o[3]:=x+rozmerypanacka.maxx+rozmerypanacka.maxprx;mp[cis].o[4]:=y+rozmerypanacka.maxy+rozmerypanacka.maxpry;
grgetimage(mp[cis].o[1],mp[cis].o[2],mp[cis].o[3],mp[cis].o[4],@mp[cis].pp^);
end;
function novapostava(s:string;x,y:integer;prep:byte):byte;
begin
mp[pp[7]].n:=nahrajzpaku(s);
while length(s)<12 do s:=s+' ';
mp[pp[7]].jm:=s;getmem(mp[pp[7]].p,mp[pp[7]].n);move(w^,mp[pp[7]].p^,mp[pp[7]].n);
mp[pp[7]].s:=1;mp[pp[7]].x:=x;mp[pp[7]].y:=y;mp[pp[7]].d:=false;
mp[pp[7]].pr:=prep;novapostava:=pp[7];
getmem(mp[pp[7]].pp,4096);
mp[pp[7]].o[1]:=x-rozmerypanacka.maxprx;mp[pp[7]].o[2]:=y-rozmerypanacka.maxpry;
mp[pp[7]].o[3]:=x+rozmerypanacka.maxx+rozmerypanacka.maxprx;mp[pp[7]].o[4]:=y+rozmerypanacka.maxy+rozmerypanacka.maxpry;
grgetimage(mp[pp[7]].o[1],mp[pp[7]].o[2],mp[pp[7]].o[3],mp[pp[7]].o[4],@mp[pp[7]].pp^);
inc(pp[7]);
end;
procedure zmenpostavu(cis:byte;name:string);
begin
freemem(mp[cis].p,mp[cis].n);
mp[cis].n:=nahrajzpaku(name);while length(name)<12 do name:=name+' ';
mp[cis].jm:=name;getmem(mp[cis].p,mp[cis].n);move(w^,mp[cis].p^,mp[cis].n);
mp[cis].s:=1;mp[cis].d:=false;
end;
procedure zmenprepis(cis:byte;x,y,prep:integer);
begin
mp[cis].pr:=prep;mp[cis].x:=x;mp[cis].y:=y;
end;
procedure umazpostavu(cis:byte);
var l:byte;
begin
grsetworkpage(pocitadlo);grputimage(mp[cis].o[1],mp[cis].o[2],mp[cis].o[3],mp[cis].o[4],@mp[cis].pp^);
grsetworkpage(ukazovadlo);grputimage(mp[cis].o[1],mp[cis].o[2],mp[cis].o[3],mp[cis].o[4],@mp[cis].pp^);
for l:=1 to 4 do mp[cis].o[l]:=mp[pp[7]].o[l];
pp[7]:=pp[7]-1;mp[cis].p:=@mp[pp[7]].p^;mp[cis].s:=mp[pp[7]].s;mp[cis].pr:=mp[pp[7]].pr;
mp[cis].n:=mp[pp[7]].n;mp[cis].x:=mp[pp[7]].x;mp[cis].y:=mp[pp[7]].y;mp[cis].jm:=mp[pp[7]].jm;
freemem(mp[pp[7]].p,mp[pp[7]].n);freemem(mp[pp[7]].pp,4096);
end;
procedure ukazpage(jo:boolean);
var i:word;
begin
delay(pauza486);grsetdisppage(pocitadlo);r.ax:=3;intr($33,r);
inc(pocitadlo);inc(ukazovadlo);if pocitadlo=2 then pocitadlo:=0;
if ukazovadlo=2 then ukazovadlo:=0;
grsetworkpage(pocitadlo);
if pp[7]>0 then for i:=0 to pp[7]-1 do grputimage(mp[i].o[1],mp[i].o[2],mp[i].o[3],mp[i].o[4],@mp[i].pp^);
if jo then grputimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);
mys_state:=true;
if zrusupl=255 then begin zobrazinventar;zrusupl:=0;end;
grsetworkpage(pocitadlo);
if (not soundplaying) and (speaker) and (soundbl) then begin
	speaker:=false;turnspeakeroff;freebuffer(pointer(sound),soundsize);getbuffer(pointer(sound),1);soundsize:=1;
end;
end;
procedure putpixel(sox,soy:integer;bar:byte);
begin
if bar>0 then grputpixel(sox,soy,bar);
end;
procedure inicializuj;
begin
getmem(pal,1536);soundsize:=0;
if environmentset then if not initsbfromenv then begin
	writeln('Nen¡ Nastavenej Sound Blaster! Hoƒ ‡u‡ku do autoexecu!');
	writeln('Spou¨t¡m bez hudby a zvuk–...');soundbl:=false;
end;if soundbl then turnspeakeroff;speaker:=false;
r.ah:=$35;r.al:=$80;intr($21,r);
if r.es=0 then begin
	writeln('Nen¡ Nahranej SBFMDRV, u¨ ku');writeln('Spou¨t¡m bez hudby ...');fmsound:=false;
end;
if (not(soundbl)) or (not(fmsound)) then begin writeln;writeln('Do nˆ‡eho m zni !!!');readkey;end;
for i:=0 to 47 do m[i].n:=1;mx:=0;my:=0;mz:=0;
for i:=1 to 9 do pp[i]:=0;jm:=' .CMF   ';
for i:=0 to maxcountofitem do mam[i]:=$ff;
for i:=0 to 15 do begin
	mp[i].pr:=0;por[i]:=i;
end;
r.ax:=0;intr($33,r);if r.ax=0 then begin
	writeln('Nen¡ my¨ka, ... !');halt;
end;setxmode;
r.ax:=7;r.cx:=0;r.dx:=318-sirikon;intr($33,r);new(w);new(w2);
r.ax:=8;r.cx:=0;r.dx:=238-vysikon;intr($33,r);
r.ax:=$15;intr($33,r);mousebuffer.n:=r.bx;getmem(mousebuffer.p,mousebuffer.n);
r.ax:=$16;r.es:=seg(mousebuffer.p^);r.dx:=ofs(mousebuffer.p^);intr($33,r);mys_state:=false;
{starycx:=r.cx;staryes:=r.es;starydx:=r.dx;}rychlezmiz(0,255);
use[1]:=0;use[2]:=0;use[3]:=0;getmem(pomikon,400);getmem(textptr.p,4000);textptr.n:=0;
getmem(mys,((sirikon+1)*(vysikon+2)));grgetimage(0,0,sirikon,vysikon,@mys^);
grsetworkpage(3);grputimage(0,vysikon+1,sirikon,vysikon shl 1+1,@mys^);grsetworkpage(0);
grsetdisppage(1);grsetworkpage(0);
rychlezmiz(0,255);for i:=pocikon downto 1 do nahrajikonu(i,jmikon[i]);
for i:=0 to 1 do begin grsetworkpage(i);grsetcolor(0);grblock(0,200,160,239);end;
items.n:=nahrajzpaku('ITEMS.ALL');getmem(items.p,items.n);move(w^,items.p^,items.n);pocvec:=items.n shr 3;
itemstxt.n:=nahrajzpaku('ITEMS.TXT');getmem(itemstxt.p,itemstxt.n);move(w^,itemstxt.p^,itemstxt.n);
for i:=1 to itemstxt.n do itemstxt.p^[i]:=itemstxt.p^[i] xor $C7;
for i:=1 to pocvec do if items.p^[(i-1)*8+2]=255 then begin
	for j:=1 to maxcountofitem do if mam[j]=255 then begin
		k:=j;j:=maxcountofitem;
	end;
	mam[k]:=items.p^[(i-1)*8+1];
end;grsetdisppage(ukazovadlo);grsetworkpage(pocitadlo);
ikon:=1;resetfm;podklsiz:=(windowsr.x2-windowsr.x1+1)*(windowsr.y2-windowsr.y1+1)+1;
stavsiz:=nahrajzpaku('NEW.POS');getmem(stav,stavsiz);move(w^,stav^,stavsiz);getmem(podkl,podklsiz);
end;
procedure odinicializuj;
begin
mys_state:=false;freemem(podkl,podklsiz);
freemem(stav,stavsiz);freemem(items.p,items.n);freemem(mys,((sirikon+1)*(vysikon+2)));freemem(pal,1536);
freemem(textptr.p,4000);if pp[4]>0 then for i:=0 to pp[4]-1 do freemem(m[i].p,m[i].n);freemem(itemstxt.p,itemstxt.n);
if pp[8]>0 then for i:=0 to pp[8]-1 do freemem(fon[i].p,fon[i].n);
for i:=1 to pocikon do freemem(ikony[i].p,ikony[i].n);dispose(w2);dispose(w);
zavripak;
freemem(mousebuffer.p,mousebuffer.n);r.ax:=0;intr($33,r);release(heaporg);
if soundbl then begin turnspeakeroff;speaker:=false;shutdownsb;end;
end;
procedure nastavpalmem;
begin
r.es:=seg(pal^);r.dx:=ofs(pal^);r.ah:=$10;r.al:=$12;r.bx:=0;r.cx:=256;
if not zmizelapal then intr($10,r);
end;
procedure nastavpal(s:string);
begin
assign(f,s);reset(f,1);
blockread(f,pal^,768);
close(f);
end;
procedure nacticpsmem(a:typ;x,y:integer;nr:word);
var k,l,l2,m,n:word;
begin
x1:=a^[1]+x+(a^[5] and 1) shl 8;y1:=a^[2]+y;x2:=a^[3]+x+(a^[5] and 16) shl 4;y2:=a^[4]+y;
k:=6;m:=1;repeat
 l:=a^[k];if l>$c0 then begin
   l2:=a^[succ(k)];for n:=m to pred(m+l-$c0) do if l2>0 then w2^[n]:=l2 else w2^[n]:=255;
   inc(m,l-$c0);inc(k,2);
 end else begin if l>0 then w2^[m]:=l else w2^[m]:=255;inc(m);inc(k);end;
until k>nr;grputimagem(x1,y1,succ(x2),succ(y2),@w2^,succ(x2-x1));
end;
procedure nactidlouhycps(x,y:integer);
var poz,konpoz:longint;
    i,nr:word;
label tam;
begin
blockread(fp,a,5);x1:=a[1];y1:=a[2];x2:=a[3];y2:=a[4];if (a[5] and 1<>0) then inc(x1,256);
if (a[5] and 16<>0) then inc(x2,256);k:=y1;j:=x1;poz:=filepos(fp);konpoz:=poz+delkacps-5;
repeat
blockread(fp,a,32768,nr);
for i:=1 to nr do begin
	if a[i]<$c0 then begin if a[i]>0 then putpixel(j+x,k+y,a[i]);end else begin
		for l:=1 to a[i]-$c0 do begin if a[i+1]>0 then putpixel(j+x,k+y,a[i+1]);inc(j);
		end;dec(j);inc(i);inc(poz);end;
		inc(j);
		if j>x2 then begin
			j:=x1;inc(k);
		end;inc(poz);if i>32760 then goto tam;
end;
tam:
seek(fp,poz-1);
until poz>=konpoz;
end;
procedure nacticps(s:string;x,y:integer);
var poc:byte;
    i,poz:longint;
    nr:word;
label tam;
begin
assign(f,s);reset(f,1);
blockread(f,a,32768,nr);
poc:=6;poz:=poc;
x1:=a[1];y1:=a[2];x2:=a[3];y2:=a[4];if a[5] and 1=1 then x1:=x1+256;if a[5]and 16=16 then x2:=x2+256;
k:=y1;j:=x1;
repeat
if poc<>6 then blockread(f,a,32768,nr);
if nr>=poc then for i:=poc to nr do begin
	if a[i]<$c0 then begin if a[i]>0 then putpixel(j+x,k+y,a[i]);end else begin
		for l:=1 to a[i]-$c0 do begin if a[i+1]>0 then putpixel(j+x,k+y,a[i+1]);j:=j+1;
		end;j:=j-1;i:=i+1;inc(poz);end;
		j:=j+1;
		if j>x2 then begin
		j:=x1;k:=k+1;
	end;inc(poz);if i>32700 then goto tam;
end;
tam:
seek(f,poz-1);
poc:=1;
until nr=0;
close(f);
end;
function nactiwsa(b:typ;x,y,od,nr:word):integer;
var pozm,poz,i,j,k,l,l2,m,n:word;
label kon;
begin
poz:=od;
repeat
case b^[poz] of
	$1a:begin
		putpixel(x+b^[poz+1],y+b^[poz+2],b^[poz+3]);poz:=poz+4;end;
	$1b:begin
		putpixel(x+b^[poz+1]+256,y+b^[poz+2],b^[poz+3]);poz:=poz+4;end;
	$2c:begin
		inc(poz);nw:=b^[poz]+b^[poz+1]*256-1;inc(poz,2);
		x1:=x+b^[poz]+(b^[poz+4] and 1)shl 8;y1:=y+b^[poz+1];x2:=x+b^[poz+2]+(b^[poz+4] and 16)shl 4;y2:=y+b^[poz+3];
		poz:=poz+5;i:=0;pozm:=poz+nw;
		k:=poz;m:=1;repeat
		 l:=b^[k];if l>$c0 then begin
		   l:=l-$c0;l2:=b^[succ(k)];for n:=m to pred(m+l) do if l2>0 then w2^[n]:=l2 else w2^[n]:=255;
		   inc(m,l);inc(k,2);
		 end else begin if l>0 then w2^[m]:=l else w2^[m]:=255;inc(m);inc(k);end;
		until k>pozm;grputimagem(x1,y1,succ(x2),succ(y2),@w2^,succ(x2-x1));
		poz:=succ(poz+nw);
	end;
	$00:begin
		poz:=poz+1;nactiwsa:=poz;if poz>=nr then nactiwsa:=0;goto kon;end;
	else inc(poz);
end;
until poz>=nr;
nactiwsa:=0;
kon:
end;
procedure mistnost(kam:byte);
var stm:string[8];
    st2:array[1..8] of char;
    p1,p2:byte;
    nam:string;
begin
if not prvnimis then ukazpage(true);grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);grsetworkpage(ukazovadlo);
grputimage(mx,my,mx+sirikon,my+vysikon,@mys^);smx:=mx;smy:=my;if soundbl then turnspeakeroff;speaker:=false;
st2:='        ';stopcmf;nam:='ROOM';i:=p[kam].vych.kam;p1:=0;p2:=0;cismis:=i;
p1:=i shr 4;p2:=i-p1 shl 4;inc(p1,48);if p1>57 then inc(p1,7);
inc(p2,48);if p2>57 then inc(p2,7);st2[1]:=chr(p1);st2[2]:=chr(p2);
for i:=1 to 4 do st2[i+4]:=st2[i];st2[1]:='R';st2[2]:='O';st2[3]:='O';st2[4]:='M';
nam:=st2;nam:=copy(nam,1,6);if scenka then freemem(sc.p,sc.n);
scenka:=false;cuchmys:=false;
stm:=jm;pocit:=0;jmmis:=nam;
if not(prvnimis) then begin
	grsetworkpage(pocitadlo);grputimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);
end else prvnimis:=false;
smx:=mx;smy:=my;
grsetdisppage(ukazovadlo);
pocitadlo:=0;ukazovadlo:=1;
zmiz(0,255);grsetdisppage(2);
grsetworkpage(pocitadlo);grsetcolor(0);grblock(0,0,319,199);
nacticpszpaku(nam+'.CPS',0,0);
nactishpzpaku(nam+'.SHP');
for i:=1 to pocvec do if (items.p^[(i-1)*8+2])=cismis then begin
	st2[1]:='V';st2[2]:='E';st2[3]:='C';j:=items.p^[(i-1)*8+1];p1:=j shr 4;
	p2:=j-p1 shl 4;inc(p1,48);if p1>57 then inc(p1,7);inc(p2,48);if p2>57 then inc(p2,7);
	st2[4]:=chr(p1);st2[5]:=chr(p2);nam:=st2;nam:=copy(nam,1,5)+'.CPS';
	mc[pp[5]].n:=nahrajzpaku(nam);getmem(mc[pp[5]].p,mc[pp[5]].n);move(w^,mc[pp[5]].p^,mc[pp[5]].n);
	p[pp[5]].prek.prep:=items.p^[(i-1)*8+8];
	for j:=0 to 4 do pr[j]:=items.p^[(i-1)*8+j+3];preved;grsetworkpage(0);
	tabit[pocit].c:=pp[5];tabit[pocit].i:=i;inc(pocit);inc(pp[5]);
	grmoveimage(pr[0]-8,pr[1]-8,pr[2]+16,pr[3]+16,pr[0]-8,pr[1]-8,0,2);
	nacticpsmem(@mc[pp[5]-1].p^,0,0,mc[pp[5]-1].n);
end;
grsetworkpage(pocitadlo);
ulozpozadi;
pozadi(true);ukazpage(true);pozadi(true);ukazpage(true);
obnovroomshp;
objevse(0,255);
resetfm;playcmf;cuchmys:=true;
end;
procedure obnovroomshp;
var st2:array[1..8] of char;
    p1,p2:byte;
    i,j:integer;
    nam:string;
begin
s:=jmmis+'.SHP';nactishpzpaku(s);
for i:=1 to pocvec do if (items.p^[(i-1)*8+2])=cismis then begin
	st2[1]:='V';st2[2]:='E';st2[3]:='C';j:=items.p^[(i-1)*8+1];p1:=j shr 4;
	p2:=j-p1 shl 4;inc(p1,48);if p1>57 then inc(p1,7);inc(p2,48);if p2>57 then inc(p2,7);
	st2[4]:=chr(p1);st2[5]:=chr(p2);nam:=st2;nam:=copy(nam,1,5)+'.CPS';
	mc[pp[5]].n:=nahrajzpaku(nam);getmem(mc[pp[5]].p,mc[pp[5]].n);move(w^,mc[pp[5]].p^,mc[pp[5]].n);
	p[pp[5]].prek.prep:=items.p^[(i-1)*8+8];inc(pp[5]);
end;
end;
procedure nactishp(name:string);
var i,j:integer;
    f:file;
    a:typ;
    pov,op:boolean;
    pr:array[0..4] of integer;
    nr2,poz:word;
begin
if pp[4]>0 then for j:=0 to pp[4]-1 do freemem(m[j].p,m[j].n);
if pp[5]>0 then for j:=0 to pp[5]-1 do freemem(mc[j].p,mc[j].n);
for i:=1 to 6 do pp[i]:=0;for i:=9 to 11 do pp[i]:=0;
nr2:=nahrajzpaku(name);getmem(a,nr2);move(w^,a^,nr2);for i:=1 to nr2 do a^[i]:=a^[i] xor $C7;i:=1;
repeat
if a^[i]>15 then begin
	poz:=a^[i+1]+(a^[i+2] shl 8);pov:=false;op:=false;
	if a^[i] and 8<>0 then begin op:=true;dec(a^[i],8);end;
	if nactibitzestavu(poz,a^[i] and 7)>0 then pov:=true;
	if op then pov:=not(pov);
	inc(i,2);a^[i]:=a^[i-2] shr 4;
end else pov:=true;
case a^[i] of
	1:begin
		inc(i);
		for j:=0 to 4 do p[pp[1]].nem[j]:=a^[i+j];
		if pov then inc(pp[1]);i:=i+5;
	  end;
	2:begin
		inc(i);
		for j:=0 to 6 do p[pp[2]].vych.obl[j]:=a^[i+j];i:=i+7;
		p[pp[2]].vych.kam:=a^[i];
		if pov then inc(pp[2]);inc(i);
	  end;
	3:begin
		inc(i);
		for j:=0 to 7 do p[pp[3]].scen.jm[j+1]:=chr(a^[i+j]);
		i:=i+8;
		for j:=0 to 4 do p[pp[3]].scen.obl[j]:=a^[i+j];
		for j:=0 to 4 do pr[j]:=p[pp[3]].scen.obl[j];
		if (pr[4] and 1<>0) then inc(pr[0],256);
		if (pr[4] and 16<>0) then inc(pr[2],256);
		for j:=0 to 3 do p[pp[3]].scen.obl[j]:=pr[j];
		i:=i+5;if pov then inc(pp[3]);
	  end;
	4:begin
		inc(i);
		for j:=0 to 7 do p[pp[4]].anim.jm[j+1]:=chr(a^[i+j]);
		i:=i+8;
		p[pp[4]].anim.prep:=a^[i];s:=p[pp[4]].anim.jm+' ';j:=1;
		while copy(s,j,1)<>' ' do inc(j);s:=copy(s,1,j-1)+'.WSA';
		if pov then begin
			nr:=nahrajzpaku(s);getmem(m[pp[4]].p,nr);move(w^,m[pp[4]].p^,nr);m[pp[4]].s:=1;
		m[pp[4]].n:=nr;
		end;
		inc(i);if pov then inc(pp[4]);
	  end;
	5:begin
		inc(i);
		for j:=0 to 7 do p[pp[5]].prek.jm[j+1]:=chr(a^[i+j]);
		i:=i+8;
		p[pp[5]].prek.prep:=a^[i];
		s:=p[pp[5]].prek.jm+' ';j:=1;
		while copy(s,j,1)<>' ' do inc(j);s:=copy(s,1,j-1)+'.CPS';
		if pov then begin
			nr:=nahrajzpaku(s);getmem(mc[pp[5]].p,nr);move(w^,mc[pp[5]].p^,nr);mc[pp[5]].n:=nr;
		end;
		inc(i);if pov then inc(pp[5]);
	  end;
	6:begin
		inc(i);
		p[pp[6]].t.del:=a^[i];inc(i);
		for j:=1 to p[pp[6]].t.del do p[pp[6]].t.text[j]:=chr(a^[i+j-1]);
		i:=i+p[pp[6]].t.del;
		for j:=0 to 4 do pr[j]:=a^[i+j];i:=i+5;
		if pr[4] and 1<>0 then inc(pr[0],256);
		if pr[4] and 16<>0 then inc(pr[2],256);
		for j:=0 to 3 do p[pp[6]].t.obl[j]:=pr[j];
		if pov then inc(pp[6]);
	  end;
	7:begin
		if (pov) and (playznovu=0) then begin
		inc(i);resetfm;
		for j:=1 to 8 do jm[j]:=chr(a^[i+j-1]);s:=jm+' ';j:=1;
		while copy(s,j,1)<>' ' do inc(j);s:=copy(s,1,j-1)+'.CMF';
		if pov then begin
			nr:=nahrajzpaku(s);move(w^,cmf^,nr);pissiz:=nr;
		end;
		inc(i,8);
		end else inc(i,9);
	  end;
	8:inc(i);
	9:begin
		inc(i);
		for j:=0 to 4 do pr[j]:=a^[i+j];preved;
		for j:=0 to 3 do p[pp[9]].use.obl[j]:=pr[j];
		inc(i,5);
		for j:=0 to 1 do p[pp[9]].use.kam[j]:=a^[i+j];
		if pr[4] and $80<>0 then inc(p[pp[9]].use.kam[0],256);
		inc(i,2);if pov then inc(pp[9]);
	  end;
	10:begin
		inc(i);
		for j:=0 to 4 do pr[j]:=a^[i+j];if a^[i+4] and 1<>0 then inc(pr[0],256);
		if a^[i+4] and 16<>0 then inc(pr[2],256);
		for j:=0 to 3 do p[pp[10]].mluv.obl[j]:=pr[j];
		inc(i,5);p[pp[10]].mluv.kod:=a^[i];inc(i);
		for j:=1 to 8 do p[pp[10]].mluv.jm[j]:=chr(a^[i+j-1]);inc(i,8);
		p[pp[10]].mluv.prep:=a^[i];inc(i);
		for j:=0 to 1 do pr[j]:=a^[i+j];if pr[4] and $80<>0 then inc(pr[0],256);
		for j:=0 to 1 do p[pp[10]].mluv.kam[j]:=pr[j];inc(i,2);
		if pov then inc(pp[10]);
	  end;
	11:begin
		inc(i);
		p[pp[11]].dial.del:=a^[i];inc(i);
		for j:=0 to p[pp[11]].dial.del-1 do p[pp[11]].dial.text[j+1]:=chr(a^[i+j]);
		inc(i,p[pp[11]].dial.del);p[pp[11]].dial.kod:=a^[i]+a^[i+1] shl 8;inc(i,2);
		if pov then inc(pp[11]);
	  end
	else inc(i);
end;
until a^[i]=0;
freemem(a,nr2);
end;
procedure kontrolapostav;
var k,l,p1:integer;
begin
if pp[7]>0 then for l:=0 to pp[7]-1 do por[l]:=l;
if pp[7]>1 then for l:=1 to pp[7]-1 do for k:=0 to pp[7]-2 do
	if mp[por[k]].pr>mp[por[k+1]].pr then begin
		p1:=por[k];por[k]:=por[k+1];por[k+1]:=p1;
	end;
end;
procedure pozadi(jo:boolean);
var pomstr:array[1..64] of char;
    pomdel:byte;
    pompoz,pomxx,pomyy,i:word;
begin
pozadiin(jo);if (textptr.n>0) and (jo=true) then begin pompoz:=1;
	repeat
	pomdel:=textptr.p^[pompoz];if pomdel>127 then begin
		pomdel:=pomdel-128;pomxx:=textptr.p^[pompoz+1]+textptr.p^[pompoz+2] shl 8;
		pomyy:=textptr.p^[pompoz+3];inc(pompoz,3);
	end else begin pomxx:=mp[0].x;pomyy:=mp[0].y-20;end;
	for i:=1 to pomdel do pomstr[i]:=chr(textptr.p^[pompoz+i]);
	inc(pompoz,pomdel);inc(pompoz);
	pistext(pomxx,pomyy,pomstr,pomdel);
	until pompoz>=textptr.n;textptr.n:=0;
end;
end;
procedure pozadiin(jo:boolean);
var k,l,min,cur,p1,zxc:integer;
    i:word;
begin
kontrolapostav;mys_state:=true;
cur:=0;
if zrusupl>0 then begin
	zrusvecuplne(zrusupl);zrusupl:=255;znehybnenamysina:=true;
end;
grgetimage(mx,my,mx+sirikon,my+vysikon,@mys^);
for l:=0 to pp[7] do begin
min:=cur;if l<pp[7] then cur:=mp[por[l]].pr else cur:=256;
if pp[4]>0 then for k:=0 to pp[4]-1 do begin
	p1:=p[k].anim.prep;
	if (p1>=min) and (p1<cur) then begin
			m[k].s:=nactiwsa(@m[k].p^,0,0,m[k].s,m[k].n);
			if m[k].s=0 then m[k].s:=1;
	end;
end;
if pp[5]>0 then for k:=0 to pp[5]-1 do begin
	p1:=p[k].prek.prep;
	if (p1>=min) and (p1<cur) then begin
		nacticpsmem(@mc[k].p^,0,0,mc[k].n);
	end;
end;
if (zrus>0) and (l=0) then zrusvec(zrus);zxc:=por[l];
if l<pp[7] then begin
	mp[zxc].o[1]:=mp[zxc].x-rozmerypanacka.maxprx;mp[zxc].o[2]:=mp[zxc].y-rozmerypanacka.maxpry;
	mp[zxc].o[3]:=mp[zxc].x+rozmerypanacka.maxx+rozmerypanacka.maxprx;mp[zxc].o[4]:=mp[zxc].y+rozmerypanacka.maxy+
	rozmerypanacka.maxpry;grsetworkpage(pocitadlo);
	if curmluv=255 then grgetimage(mp[zxc].o[1],mp[zxc].o[2],mp[zxc].o[3],
	mp[zxc].o[4],@mp[zxc].pp^);
	k:=l;mp[zxc].s:=nactiwsa(@mp[zxc].p^,mp[zxc].x,mp[zxc].y,mp[zxc].s,mp[zxc].n);
	if mp[zxc].s=0 then begin mp[zxc].s:=1;mp[zxc].d:=true;end else mp[zxc].d:=false;
end;            
end;mys_state:=true;
if (scenka) then begin
	sc.s:=nactiwsa(@sc.p^,0,0,sc.s,sc.n);if sc.s=0 then begin
		scenka:=false;freemem(sc.p,sc.n);
	end;
end;
myska(jo);
end;
procedure ulozpozadi;
begin
grmoveimage(0,0,319,240,0,0,pocitadlo,ukazovadlo);
end;
function nahraj(name:string):word;
var f:file;
    nr:word;
begin
assign(f,name);reset(f,1);blockread(f,w^,65533,nr);
close(f);nahraj:=nr;
end;
function loadvoc(name:string;var sound:psound):longint;
var dummy:pointer;
    lefttoread:longint;
    header:PVOCHeader;
    i,j,k:word;
    nas:boolean;
begin
if length(name)<12 then for i:=length(name)+1 to 12 do name:=name+' ';
for i:=1 to pocpak do begin
	nas:=true;for j:=1 to 12 do if name[j]<>pak^[i].jm[j] then nas:=false;
	if nas then begin k:=i;i:=pocpak;end;
end;
if nas then begin
	seek(fp,pak^[k].poz);
	lefttoread:=pak^[k].del-sizeof(header^);
	loadvoc:=lefttoread;new(header);blockread(fp,header^,sizeof(header^));
	if getbuffer(pointer(sound),lefttoread)=true then begin
		dummy:=sound;
	end;
	while lefttoread>0 do begin
		if lefttoread<64000 then begin
			blockread(fp,dummy^,lefttoread);lefttoread:=0;
		end else begin
			blockread(fp,dummy^,64000);lefttoread:=lefttoread-64000;
			incrementptr(dummy,64000);
		end;
	end;
	dispose(header);
end else loadvoc:=0;
end;
function nahrajzpaku(name:string):word;
var i,j,k:word;
    nas:boolean;
begin
if length(name)<12 then for i:=length(name)+1 to 12 do name:=name+' ';
for i:=1 to pocpak do begin
	nas:=true;
	for j:=1 to 12 do if name[j]<>pak^[i].jm[j] then nas:=false;
	if nas=true then begin k:=i;i:=pocpak;end;
end;
if nas then begin
seek(fp,pak^[k].poz);
if pak^[k].del<65533 then begin
	blockread(fp,w^,pak^[k].del,nr);nahrajzpaku:=nr;
end else begin nahrajzpaku:=65535;delkacps:=pak^[k].del;seek(fp,pak^[k].poz);end;
end else nahrajzpaku:=0;
end;
procedure otevripak(name:string);
const bajt:array[1..4] of longint=(1,256,65536,16777216);
var poc:word;
begin
getmem(pak,40960);{$I-}assign(fp,name);reset(fp,1);
if ioresult<>0 then begin
	writeln('Erora 1.© du: nena¨el jsem soubor ',name,'.');
	writeln('Program se zhroutil....');freemem(pak,40960);halt;
end;
{$I+}blockread(fp,a,4);pb:=0;
reset(fp,1);
for i:=1 to 4 do pb:=pb+bajt[i]*a[i];pj:=1;pb:=pb-4;poc:=0;
blockread(fp,a,pb);
repeat
inc(poc);
pak^[poc].poz:=0;for i:=1 to 4 do pak^[poc].poz:=pak^[poc].poz+bajt[i]*a[i-1+pj];
pj:=pj+4;i:=1;
repeat
if a[pj]<>0 then pak^[poc].jm[i]:=chr(a[pj]);inc(pj);inc(i);
until a[pj]=0;inc(pj);
if (i-1)<12 then for j:=i to 12 do pak^[poc].jm[j]:=' ';
pak^[poc].del:=0;
until pj>=pb;
pj:=filesize(fp);
for i:=1 to poc do begin
	if i<poc then pak^[i].del:=pak^[i+1].poz-pak^[i].poz;
	if i=poc then pak^[i].del:=pj-pak^[i].poz;
end;
pocpak:=poc;
end;
procedure zavripak;
begin
freemem(pak,40960);close(fp);
end;
procedure nactipalzpaku(name:string);
begin
nr:=nahrajzpaku(name);move(w^,pal^,768);
for i:=769 to 768+769 do pal^[i]:=0;
nastavpalmem;
end;
procedure nacticpszpaku(name:string;x,y:integer);
begin
nr:=nahrajzpaku(name);if nr<=65533 then nacticpsmem(@w^,x,y,nr) else nactidlouhycps(x,y);
end;
procedure nactishpzpaku(name:string);
begin
nactishp(name);if memavail<4000 then begin
	closegraph;resetfm;writeln('Out of hunk, Apeshit!');halt;
end;
end;
procedure zrusvecuplne(cis:byte);
begin
for k:=0 to pocvec-1 do if (items.p^[k*8+1]=cis) and (items.p^[k*8+2]=255) then begin
	k:=pocvec-1;l:=cis;zapisbitdostavu(l shr 3,l and 7,0);l:=k;
end;
items.p^[l*8+2]:=0;zrusupl:=0;znehybnenamysina:=true;
if (ikon=1) and (mam[0]=cis) then begin
	freemem(ikony[1].p,ikony[1].n);nahrajikonu(1,jmikon[1]);
end;l:=0;
for k:=1 to maxcountofitem-l do begin
	if mam[k]=cis then l:=1;
	if l>0 then mam[k]:=mam[k+l];
end;if l>0 then for k:=maxcountofitem-l to maxcountofitem do mam[k]:=$ff;
if mam[0]=cis then begin
	freemem(ikony[1].p,ikony[1].n);
	nahrajikonu(1,jmikon[1]);
end;
use[1]:=0;use[2]:=0;use[3]:=0;
end;
procedure prevedvecdokapsy(cis:byte);
begin
for k:=0 to pocvec-1 do begin
	i:=k shl 3+1;if (items.p^[i]=cis) and (items.p^[i+1]<255) then begin
		for j:=1 to maxcountofitem do if mam[j]=$ff then begin
			mam[j]:=items.p^[i];items.p^[i+1]:=255;j:=maxcountofitem;k:=items.p^[i];
			zapisbitdostavu((k-1) shr 3,(k-1) and 7,1);k:=pocvec-1;
		end;
	end;
end;
if curmluv=255 then zobrazinventar;
end;
procedure zrusvec(cis:byte);
begin
dec(cis);grputimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);
freemem(mc[tabit[cis].c].p,mc[tabit[cis].c].n);zrus:=0;
mc[tabit[cis].c].n:=nahrajzpaku('VECFF.CPS');znehybnenamysina:=true;
p[tabit[cis].c].prek.prep:=0;getmem(mc[tabit[cis].c].p,mc[tabit[cis].c].n);move(w^,mc[tabit[cis].c].p^,mc[tabit[cis].c].n);
{j:=grgetworkpage;grsetworkpage(2);nactiwsa(@mp[0].p^,mp[0].x,mp[0].y,mp[0].s,mp[0].n);
grsetworkpage(j);}
for j:=0 to 4 do pr[j]:=items.p^[((tabit[cis].i-1) shl 3)+3+j];preved;
grmoveimage(pr[0]-8,pr[1]-8,pr[2]+16,pr[3]+16,pr[0]-8,pr[1]-8,2,pocitadlo);
pozadi(true);ukazpage(true);j:=items.p^[(tabit[cis].i-1) shl 3+1];zapisbitdostavu(((j-1) shr 3) and 31,(j-1) and 7,1);
grmoveimage(pr[0]-8,pr[1]-8,pr[2]+16,pr[3]+16,pr[0]-8,pr[1]-8,2,pocitadlo);znehybnenamysina:=true;
end;
procedure zobrazchar(x,y:integer;zn,font:byte);
var i,j:integer;
begin
for i:=0 to fon[font].sir-1 do for j:=0 to fon[font].vys-1 do
putpixel(x+i,y+j,fon[font].p^[(141+j*fon[font].sir+i+fon[font].sir*fon[font].vys*ord(zn-32))]);
end;
procedure zobraz(x,y:word;s:array of char;del,font:byte);
var pom:integer;
    x2:integer;
begin
x2:=x;
for pom:=0 to del-1 do begin
	zobrazchar(x2,y,ord(s[pom]),font);inc(x2,fon[font].p^[ord(s[pom])-29]);
end;
end;
function nahrajfontzpaku(name:string):byte;
begin
fon[pp[8]].n:=nahrajzpaku(name);getmem(fon[pp[8]].p,fon[pp[8]].n);
move(w^,fon[pp[8]].p^,fon[pp[8]].n);fon[pp[8]].sir:=fon[pp[8]].p^[1];fon[pp[8]].vys:=fon[pp[8]].p^[2];
inc(pp[8]);nahrajfontzpaku:=pp[8]-1;
end;
procedure zmiz(od,po:byte);
label tam2;
begin
if zmizelapal then goto tam2;
r.es:=seg(pal^);r.dx:=ofs(pal^)+768+od*3;r.ah:=$10;r.al:=$12;r.bx:=od;r.cx:=po-od+1;
for j:=0 to 64 do begin
	for i:=od*3 to po*3+2 do begin
			pal^[i+769]:=((pal^[i+1]*(64-j)) shr 6) and 63;
	end;
	intr($10,r);if j<60 then inc(j);
end;
rychlezmiz(od,po);
tam2:
zmizelapal:=true;
end;
procedure objevse(od,po:byte);
label tam;
begin
if not zmizelapal then goto tam;
r.es:=seg(pal^);r.dx:=ofs(pal^)+768+od*3;r.ah:=$10;r.al:=$12;r.bx:=od;r.cx:=po-od+1;
for j:=0 to 64 do begin
	for i:=od*3 to po*3+2 do begin
			pal^[i+769]:=((pal^[i+1]*j) shr 6) and 63;
	end;
	intr($10,r);if j<60 then inc(j);
end;
rychleobjevse(od,po);
tam:
zmizelapal:=false;
end;
procedure rychlezmiz(od,po:byte);
begin
r.es:=seg(pal^);r.dx:=ofs(pal^)+768+od*3;r.ah:=$10;r.al:=$12;r.bx:=od;r.cx:=po-od+1;
for i:=od*3 to po*3+2 do pal^[i+769]:=0;
intr($10,r);zmizelapal:=true;
end;
procedure rychleobjevse(od,po:byte);
begin
r.es:=seg(pal^);r.dx:=ofs(pal^)+768+od*3;r.ah:=$10;r.al:=$12;r.bx:=od;r.cx:=po-od+1;
for i:=od*3 to po*3+2 do pal^[i+769]:=pal^[i+1];
intr($10,r);zmizelapal:=false;
end;
procedure pistextman(s:array of char);
begin
pistext(mp[0].x,mp[0].y-20,s,sizeof(s));
end;
procedure pistext(x,y:integer;s:array of char;del:byte);
var p1,p2,p3,p4:integer;
    po:pointer;
    zmackkey:byte;
    minim:byte;
begin
p1:=x-del*(fon[0].sir shr 1-1)+4;p2:=y;
p3:=p1+del*(fon[0].sir)+1;p4:=p2+fon[0].vys;
if p1<5 then begin p3:=p3-(p1-5);p1:=5;end;
if p3>314 then begin p1:=p1-(p3-314);p3:=314;end;
ukazpage(true);smx:=mx;smy:=my;
grgetimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);grsetworkpage(ukazovadlo);
grputimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);
grsetworkpage(pocitadlo);
grmoveimage(p1,p2,p3,p4,20,0,pocitadlo,3);
mazadlo:=pocitadlo;
r.ax:=5;r.bx:=0;intr($33,r);r.ax:=3;intr($33,r);minim:=2;
repeat
	pozadi(false);if minim>0 then dec(minim);
	zobraz(p1,p2,s,del,selectedfont);ukazpage(false);
	if keypressed then zmackkey:=ord(readkey) else zmackkey:=0;
	r.ax:=5;r.bx:=0;intr($33,r);
until ((r.bx>0) or (zmackkey=13)) and (minim=0);
if pocitadlo<>mazadlo then begin pozadi(false);ukazpage(false);end;
grmoveimage(20,0,20+p3-p1,p4-p2,p1,p2,3,ukazovadlo);
grsetworkpage(pocitadlo);grmoveimage(20,0,20+p3-p1,p4-p2,p1,p2,3,pocitadlo);
grputimage(smx,smy,smx+sirikon,smy+vysikon,@mys^);pozadi(false);ukazpage(false);pozadi(false);
end;

begin
setcbreak(false);checkbreak:=false;
end.