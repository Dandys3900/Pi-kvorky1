{  (c)  by Mr.Old, 24.09.94, ver 1.01, last upgrade: 24.09.94    }
program PakView;
uses crt,dos,okno,voc,sbdsp,memunit;
{$R-,S-}
type tabnamptr=^tabnamid;
     tabnamid=record
	name:string[12];
	pos,siz:longint;
	ozn:boolean;
	typ:byte;
	pr,po:tabnamptr;
     end;
     hlavaid=array[1..65533] of byte;
     hlavaptr=^hlavaid;
     savscrptr=^savscrid;
     savscrid=record
	a:array[1..25,1..80] of word;
	adrpred:savscrptr;
	x1,x2,y1,y2:byte;
     end;
var i,j,nr,nw,x,y,max,po,k:word;
    f,g:file;
    stshift:byte;
    shift:byte absolute 0:$417;
    rr:real;
    b:hlavaptr;
    r:registers;
    c:char;
    myspress:boolean;
    t,pom,prv,tx,ty,posl:tabnamptr;
    marker:pointer;
    leftcur,lefttoread:longint;
    name,s,s2,puvdir:string;
    maska:string[12];
    cast:array[1..2,1..2] of string[8];
    s3:string[30];
    poz,pocopak,celksiz,oznsiz:longint;
    styl:boolean;
    cnt:word;
    sound:psound;
    soundsize:longint;
    savscr,pomscr:savscrptr;
    screen:array[1..25,1..80] of word absolute $b800:0;
const maxfiles:word=3855;
      verze:string[4]='1.02';
      pauza:word=0;
      barvakurz=3;
      sb:boolean=true;
      barvapoz=1;
      bar:array[0..1,1..10] of string[6]=(('      ','Se©ad ','      ','Dekomp','Pauza ','      ','      ','      ','      ',
'Konec '),('      ','      ','View..','Dekomp ','      ','      ','      ','      ','      ','      '));
      seradnaz:array[1..2] of string[20]=('Podle jm‚na','Podle velikosti');
label tam,prec,za;
procedure prohod(t1,t2:tabnamptr);
var tn:string[12];
    ts,tp:longint;
    to2:boolean;
    tt:byte;
begin
tn:=t1^.name;t1^.name:=t2^.name;t2^.name:=tn;
ts:=t1^.siz;t1^.siz:=t2^.siz;t2^.siz:=ts;
tp:=t1^.pos;t1^.pos:=t2^.pos;t2^.pos:=tp;
to2:=t1^.ozn;t1^.ozn:=t2^.ozn;t2^.ozn:=to2;
tt:=t1^.typ;t1^.typ:=t2^.typ;t2^.typ:=tt;
end;
function loadvoc(pom:tabnamptr;var sound:psound):longint;
var dummy:pointer;
    header:PVOCHeader;
    i,j,k:word;
    nas:boolean;
begin
if not sb then exit;
seek(f,pom^.pos);delay(10);
lefttoread:=pom^.siz-sizeof(header^);
loadvoc:=lefttoread;new(header);blockread(f,header^,sizeof(header^));
if getbuffer(pointer(sound),lefttoread)=true then begin
	dummy:=sound;
end;
while lefttoread>0 do begin
	if lefttoread<64000 then begin
		blockread(f,dummy^,lefttoread);lefttoread:=0;
	end else begin
		blockread(f,dummy^,64000);lefttoread:=lefttoread-64000;delay(10);
		incrementptr(dummy,64000);
	end;
end;
dispose(header);
end;
procedure zobraz;forward;
procedure zobrazsouradnice;forward;
procedure setcolor(bi,bb:byte);
begin
textattr:=(bi and 15)+(bb and 7) shl 4;
end;
function preved:longint;
var pom:longint;
begin
pom:=a[1]+(a[2] shl 8)+(a[3]+(a[4] shl 8))*65536;if pom and $8000<>0 then pom:=pom+65536;
preved:=pom;
end;
procedure doplncarky(var s:string);
var puvmez:byte;
begin
puvmez:=0;while s[1]=' ' do begin delete(s,1,1);inc(puvmez);end;
for i:=1 to 4 do begin
	j:=(5-i)*3;
	if length(s)>j then s:=copy(s,1,length(s)-j)+','+copy(s,length(s)-(j-1),j);
end;
while puvmez>0 do begin insert(' ',s,1);dec(puvmez);end;
end;
procedure zobrazbar(cis:byte);
var s:string[2];
begin
j:=1;
for i:=1 to 10 do begin
	if i=10 then j:=0;
	setcolor(7,0);str(i,s);writexy((i-1)*8+1,25,s);
	setcolor(0,barvakurz);writexy((i-1)*8+3-j,25,bar[cis,i]);
end;
end;
procedure openpak(name:string);
var prev:longint;
begin
{$I-}assign(f,name);reset(f,1);if doserror<>0 then showerror(1);{$I+}
blockread(f,a,4);getmem(prv,sizeof(tabnamid));prv^.pr:=nil;prv^.pos:=preved;pom:=prv;
reset(f,1);blockread(f,b^,prv^.pos,nr);cnt:=0;poz:=5;tx:=prv;ty:=prv;celksiz:=0;
if nr>8 then repeat
	pom^.name:='';if b^[poz]>0 then begin
		repeat pom^.name:=pom^.name+chr(b^[poz]);inc(poz);
		until b^[poz]=0;for i:=1 to 4 do a[i]:=b^[poz+i];inc(poz,5);prev:=preved;
		if prev=0 then prev:=filesize(f);
		pom^.siz:=prev-pom^.pos;pom^.ozn:=false;inc(celksiz,pom^.siz);pom^.typ:=0;
		if copy(pom^.name,length(pom^.name)-2,3)='VOC' then pom^.typ:=1;
		getmem(pom^.po,sizeof(tabnamid));t:=pom;
		pom:=pom^.po;pom^.pos:=prev;pom^.pr:=t;
		inc(cnt);{if cnt and 31=16 then begin zobraz;zobrazsouradnice;end;}
	end else poz:=nr+1;
until poz>nr;
pom^.po:=nil;posl:=pom^.pr;
end;
procedure zobraz;
var i,j:word;
    s,s4:string[78];
    s2:string;
begin
setcolor(14,1);writexy(3,3,'  D‚lka        Jm‚no               Pozn mky');setcolor(11,1);
fillchar(s4,78,' ');
if cnt>0 then begin
	pom:=ty;i:=1;
	repeat
		if pom^.ozn then setcolor(14,barvapoz) else setcolor(11,barvapoz);
		if i=x then begin
			if pom^.ozn then setcolor(14,barvakurz) else setcolor(0,barvakurz);
		end;
		str(pom^.siz:10,s);s:=s+'     '+pom^.name+'                    ';
		if pom^.typ=1 then begin
			s:=copy(s,1,35)+'Creative Voice File';
		end;
		s:=s+'                                                     ';s:=copy(s,1,78);
		writexy(2,3+i,s);
		inc(i);pom:=pom^.po;
	until (i=19) or (y+i>cnt);
end;
setcolor(0,barvapoz);writexy(2,23,'                                                                              ');
if po=0 then begin
  setcolor(11,barvapoz);str(celksiz:10,s2);doplncarky(s2);
  str(cnt,s);s:=s2+'     '+s+' soubor–.';writexy(2,23,s)
end else begin
  setcolor(14,barvapoz);str(oznsiz:10,s2);str(po,s);doplncarky(s2);
  s2:=s2+' byt– v '+s+' vybran˜ch souborech.';writexy(40-(length(s2) shr 1),23,s2);
end;
end;
procedure hlaschybu(chyba:byte);
var s1,s2,s3:string[23];
    x1,x2,x3:byte;
begin
setcolor(15,4);openwindow(25,14,55,21);doborder('Error',1,true);
case chyba of
	1:begin
		s1:='Nena¨el jsem soubor';
		s2:=paramstr(1);s3:='Program se zhroutil';
	end;
	2:begin
		s1:='Nen¡ dostatek m¡sta';
		s2:='na c¡lov‚m disku.';
		s3:='Rozbalov n¡ p©eru¨eno';
	end;
end;
x2:=40-length(s2) shr 1;x3:=40-length(s3) shr 1;x1:=40-length(s1) shr 1;
writexy(x1,sy1,s1);writexy(x2,sy1+1,s2);writexy(x3,sy1+2,s3);
setcolor(0,7);writexy(38,sy1+3,' OK ');
repeat repeat until keypressed;i:=ord(readkey) until i in [27,13,32];
closewindow;
end;
procedure zobrazsouradnice;
var s,s2:string;
begin
setcolor(0,barvakurz);str(x+y,s);str(cnt,s2);s:='   '+s+'/'+s2;writexy(66-length(s),1,s);
rr:=maxavail/1024;i:=trunc(rr+0.5);str(i,s2);setcolor(11,1);
s:='Í '+s2+'k Í';writexy(77-length(s),2,s);setcolor(0,barvakurz);
end;

begin
checkbreak:=false;getdir(0,puvdir);getmem(b,sizeof(hlavaid));x:=1;po:=0;oznsiz:=0;
if environmentset then if not initsbfromenv then sb:=false;if sb then turnspeakeroff;
if paramcount<1 then begin
	closemode;writeln('PAKView Version '+verze+', Copyright (c) 1994 by Mr.Old.');
	writeln('Syntax: PAKView filename[.PAK]');halt(1);
end;
name:=paramstr(1);setcolor(11,barvapoz);openwindow(1,2,80,24);
x:=1;max:=10;doborder('',0,false);writexy(1,22,'Ç');writexy(80,22,'¶');for i:=2 to 79 do writexy(i,22,'Ä');
setcolor(0,barvakurz);tx:=nil;y:=0;maska:='*.*';stshift:=shift;
writexy(1,1,' PAKView '+verze+', Copyright (c) 1994 by Mr. Old                                    ');
zobrazsouradnice;writexy(80-length(name),1,name);
openpak(name);zobrazsouradnice;if cnt>0 then tx:=prv;x:=1;y:=0;ty:=prv;
zobrazbar(0);zobraz;
repeat
tam:
if shift<>stshift then begin
	stshift:=shift;if shift and 3>0 then zobrazbar(1) else zobrazbar(0);
end;myspress:=false;{delay(20);i:=gettab;
if i>0 then begin
	if (gety=25) then c:=chr(trunc((getx-1) shr 3)+59);
	myspress:=true;if i=2 then c:=chr(ord(c)+25);
end;}
if myspress then goto za;
if (keypressed) then begin c:=readkey;if c=#0 then c:=readkey;end else c:=#0;
if c=#0 then goto tam;
za:
if (c=#82) then begin
	if tx^.ozn then begin dec(po);oznsiz:=oznsiz-tx^.siz;end else begin
	inc(po);inc(oznsiz,tx^.siz);end;
	tx^.ozn:=not tx^.ozn;c:=#80;
end;
if (c=#81) or (c=#73) then pocopak:=17 else pocopak:=1;
if (c in[#80,#81]) and (x+y<cnt) then begin
	repeat
		if x+y>=cnt-1 then pocopak:=1;
		if x>17 then begin inc(y);ty:=ty^.po;x:=18;end else inc(x);
		tx:=tx^.po;dec(pocopak);
	until pocopak=0;
end;
if (c in[#72,#73]) and (x+y>1) then begin
	repeat
		if x+y<=2 then pocopak:=1;
		if x<2 then begin dec(y);ty:=ty^.pr;x:=1;end else dec(x);
		tx:=tx^.pr;dec(pocopak);
	until pocopak=0;
end;
if c=#71 then begin
	tx:=prv;ty:=prv;x:=1;y:=0;
end;
if (c=#79) and (x<cnt) then begin
	x:=cnt;tx:=posl;if cnt<18 then begin y:=0;ty:=prv;end else begin
		ty:=posl;for i:=1 to 17 do ty:=ty^.pr;y:=x-18;x:=cnt-y;
	end;
end;
if (c in[#61,#86]) and (sb) then begin
  setcolor(0,7);openwindow(24,6,56,13);doborder('P©ehr v n¡',1,true);
  repeat
  k:=3;pom:=prv;if po=0 then pom:=tx;gotoxy(1,1);
  repeat
	if ((po=0) or (pom^.ozn)) and (pom^.typ=1) then begin
	  setcolor(0,7);if k<3 then writeln;
	  writexy(28,11-k,'                         ');setcolor(14,3);writexy(40-length(pom^.name) shr 1,11-k,pom^.name);
	  soundsize:=loadvoc(pom,sound);if soundsize>0 then begin
		turnspeakeron;zobrazsouradnice;hidemouse;
		playsound(sound);repeat until not soundplaying;
		turnspeakeroff;freebuffer(pointer(sound),soundsize);
	  end;if c<>#86 then begin pom^.ozn:=false;if po>0 then dec(po);if oznsiz>0 then dec(oznsiz,pom^.siz);
		end else delay(pauza shl 3);
	  setcolor(0,7);writexy(40-length(pom^.name) shr 1,11-k,pom^.name);if k>0 then dec(k);
	end;
	pom:=pom^.po;if keypressed then if readkey=#27 then goto prec;turnspeakeroff;showmouse;
  until (pom^.po=nil) or (po=0);
  until (keypressed) or (c<>#86);if c=#86 then readkey;
Prec:
  closewindow;
end;
if (c=#62) then begin
	if po=0 then begin po:=1;tx^.ozn:=true;oznsiz:=tx^.siz;end;pom:=prv;k:=0;
	repeat
		if pom^.ozn then begin
			setcolor(0,7);openwindow(20,5,60,13);doborder('Rozbalov n¡',1,true);
			writexy(35,7,'Rozbaluji');writexy(40-(length(pom^.name) shr 1),8,pom^.name);
			writexy(39,9,'do');getdir(0,s);if length(s)>32 then s:='..'+copy(s,length(s)-27,28);
			writexy(40-(length(s) shr 1),10,s);
			fillchar(s3,32,'±');writexy(25,11,copy(s3,1,31));setcolor(0,0);
			assign(g,pom^.name);{$I-}reset(f,1);if ioresult=0 then ;
			rewrite(g,1);{$I+}
			lefttoread:=pom^.siz;
			repeat
				seek(f,pom^.pos+pom^.siz-lefttoread);delay(5);
				leftcur:=sizeof(hlavaid);if lefttoread<leftcur then leftcur:=lefttoread;
				blockread(f,b^[1],leftcur,nr);delay(5);
				blockwrite(g,b^[1],nr,nw);lefttoread:=lefttoread-nr;
				if pom^.siz>0 then rr:=(pom^.siz-lefttoread)/pom^.siz*31 else begin rr:=31;lefttoread:=0;end;i:=trunc(rr);
				s3:='';fillchar(s3,i,'±');writexy(25,11,copy(s3,1,i));
			until (nw<>nr) or (lefttoread=0);
			close(g);if nw<>nr then k:=1;dec(po);dec(oznsiz,pom^.siz);
			closewindow;
		end;
		pom^.ozn:=false;seek(f,pom^.pos);
		pom:=pom^.po;
		if keypressed then if readkey=#27 then k:=2;
		setcolor(11,1);
	until (po=0) or (k>0);
	if k=1 then begin hlaschybu(2);po:=0;end;
end;
if (c in [#43,#45]) then if (port[$60] in [78,74]) then begin
	setcolor(0,7);openwindow(27,6,53,11);doborder('Ozna‡',1,true);
	if c=#43 then styl:=true else styl:=false;
	write(' Ozna‡it soubory:');setcolor(0,3);window(32,9,44,9);clrscr;write(maska);
	s:=readxy(32,9);if s<>'' then maska:=s;for i:=1 to length(maska) do maska[i]:=upcase(maska[i]);
	cast[1,1]:=copy(maska,1,pos('.',maska)-1);cast[1,2]:=copy(maska,length(cast[1,1])+2,3);
	pom:=prv;
	repeat
		cast[2,1]:=copy(pom^.name,1,pos('.',pom^.name)-1);cast[2,2]:=copy(pom^.name,length(cast[2,1])+2,3);
		for i:=1 to length(cast[1,1]) do if cast[1,1,i]='!' then cast[2,1,i]:=cast[1,1,i];
		for i:=1 to length(cast[1,2]) do if cast[1,2,i]='!' then cast[2,2,i]:=cast[1,2,i];
		for i:=1 to length(cast[1,2]) do if cast[1,2,i]='*' then
			cast[2,2]:=copy(cast[2,2],1,i-1)+copy(cast[1,2],i,length(cast[1,2])-i+1);
		for i:=1 to length(cast[1,1]) do if cast[1,1,i]='*' then
			cast[2,1]:=copy(cast[2,1],1,i-1)+copy(cast[1,1],i,length(cast[1,1])-i+1);
		if (cast[1,1]=cast[2,1]) and (cast[2,2]=cast[1,2]) then if pom^.ozn=not styl then begin
			if styl then inc(po) else dec(po);if styl then inc(oznsiz,pom^.siz) else dec(oznsiz,pom^.siz);pom^.ozn:=styl;
		end;
		pom:=pom^.po;
	until pom^.po=nil;
	closewindow;
end;
if c=#60 then begin
	setmenucolor(0,7);setcolor(0,7);openwindow(24,7,56,12);deleteitems;
	for i:=1 to 2 do additem(seradnaz[i]);doborder('žazen¡',1,true);
	i:=menu(29,9,23,2);pom:=prv;t:=pom^.po;pom:=pom^.po;
	repeat
		pom:=pom^.pr;
		case i of
			2:if pom^.siz<t^.siz then prohod(pom,t);
			1:if pom^.name>t^.name then prohod(pom,t);
		end;
		t:=t^.po;if t^.po=nil then begin pom:=pom^.po;t:=pom^.po;end;
		pom:=pom^.po;
	until (pom^.po=nil);closewindow;
end;
if c=#63 then begin
	setcolor(0,7);openwindow(24,7,56,12);doborder('Nastaven¡ pauzy',1,true);
	write(' Nastav pauzu:');setcolor(0,3);window(29,10,39,10);clrscr;s:=readxy(29,10);val(s,pauza,i);
	closewindow;
end;
zobraz;zobrazsouradnice;
until (c=#27) or (c=#68);
closewindow;
closemode;
pom:=prv;
{for i:=1 to 20 do begin writeln(pom^.name:15,pom^.pos:10,pom^.siz:10);pom:=pom^.po;end;}
if sb then turnspeakeroff;
chdir(puvdir);
end.