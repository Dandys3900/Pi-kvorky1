{   (c)  19.02.1995 by Mr.Old,  ver.: 1.12,  last upgrade: 24.02.1995   }
uses crt,dos,copyriht,comokno,drivers;
type tfil=array[0..35000] of byte;
     pfil=^tfil;
     tfil2=array[0..30000] of word;
     pfil2=^tfil2;
     tradek2=array[0..15,0..2] of byte;
     tradek=record
	del,sir:byte;
	p:array[0..5] of tradek2;
     end;
     pradek=^tradek;
var ii,i,j,nw,offins,off,offtit,offrem,offcom,pocnas,basictmp,vybhl,vybvedl:word;
    k,l,kurs,pissiz,vybmod,vybbit,max,maxrad:word;
    f:file;
    name,title,remark,composer,s:string;
    r:registers;
    nas:array[1..255,0..15] of byte;
    na:array[1..255,1..26] of byte;
    a:array[0..35000] of byte;
    sbfmdrv:pointer;
    func:boolean;
    pi:pfil;
    map,rad:pfil2;
    q:pradek;
    c:char;
const novy:boolean=false;
      zmenan:boolean=false;
      tiks:word=96;
      ver:string[4]='1.01';
      tikn:word=120;
      x:word=0;sx:word=0;
      y:word=0;sy:word=0;
      z:word=0;sz:word=0;
      w:integer=0;sw:integer=0;
      chanuse:array[0..15] of byte=(1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0);
      chan:array[0..10] of byte=(0,1,2,3,4,5,6,7,8,0,0);
      prstr:string='                                                                                ';
      maxchan:byte=9;
      play:array[0..14] of byte=(0,$c0,1,0,$b0,$69,0,0,$90,$24,$78,20,$ff,$2f,0);
      hlmenu:array[1..5] of string[10]=('N zvy','Tempo','N stroje','Noty','Konec');
      vedlmenu:array[1..2,1..4] of string[30]=(('N zev p¡sni‡ky','Skladatel','Pozn mky','Zpˆt'),
	('Tik– za sekundu','Tik– na ‡tvrt noty','Zpˆt',''));
       nasmenu:array[1..11] of string=('Modulator Characteristic','Carrier Characteristic','Modulator Scaling/Output Level',
	'Carrier Scaling/Output Level','Modulator Attack/Delay','Carrier Attack/Delay','Modulator Sustain Level/Release',
	'Carrier Sustain Level/Release','Modulator Wave Select','Carrier Wave Select','Feedback/Connection');
      nasmenu2:array[1..6,1..5] of string[20]=(('Pitch Vibrato','Amplitude Vibrato','Sustaining Sound','Envelope Scaling',
	'Frequency Mutliplier'),('Level Scaling','Output Level','','',''),('Attack Rate','Delay Rate','','',''),
	('Sustain Level','Release Rate','','',''),('Wave Select','','','',''),('Modulator Feedback','Connection','','',''));
      nasmenu2siz:array[1..6] of byte=(5,2,2,2,1,2);
      nasmenu2pol:array[1..11] of byte=(0,5,10,12,14,16,18,20,22,23,24);
procedure rozmapuj;
var i:word;
begin
max:=0;i:=1;
repeat
 map^[max]:=i;
 case ((pi^[i] and $f0) shr 4) of
  $9:inc(i,4);
  $c:inc(i,3);
  $f:inc(i,3);
  $b:inc(i,4)
  else inc(i,1);
 end;inc(max);
until i>=pissiz;map^[max]:=pissiz;
end;
procedure rozradkuj;
var i:word;
begin
i:=0;maxrad:=0;
repeat
 rad^[maxrad]:=i;inc(i);
 while pi^[map^[i]-1]=0 do inc(i);
 inc(maxrad);
until i>=max-1;rad^[maxrad]:=max-1;
end;
procedure vyberradek(x:word);
var i,j,k,l,last:word;
begin
for k:=0 to 5 do for i:=0 to 15 do for j:=0 to 2 do q^.p[k,i,j]:=0;q^.del:=0;q^.sir:=0;
for i:=rad^[x] to rad^[x+1]-1 do begin
 last:=j;j:=pi^[map^[i]] and $f;l:=0;while q^.p[l,j,0]>0 do inc(l);
 if pi^[map^[i]]=$ff then begin
	for k:=0 to 2 do q^.p[l,chan[0],k]:=pi^[k+map^[i]];
 end else
 if pi^[map^[i]] in [1..$8f] then begin
	q^.p[l,last,0]:=$90+last;for k:=1 to 2 do q^.p[l,last,k]:=pi^[k-1+map^[i]];
 end else for k:=0 to 2 do q^.p[l,j,k]:=pi^[k+map^[i]];if l>q^.sir then q^.sir:=l;
end;q^.del:=pi^[map^[rad^[x+1]]-1];
end;
procedure zapisradek(x:word);
var i,j,k,l,m:word;
begin
i:=map^[rad^[x]];for l:=0 to q^.sir do begin
 for k:=0 to 15 do begin
  if q^.p[l,k,0]>0 then begin
   for j:=0 to 2 do begin
	pi^[i+j]:=q^.p[l,k,j];
   end;pi^[i+3]:=0;case q^.p[l,k,0] shr 4 of
	1..8,$c,$f:begin inc(i,3);pi^[i-1]:=0 end;
	9,$b:begin inc(i,4);pi^[i-1]:=0 end;
	else inc(i,3);
   end;
  end;
 end;
end;pi^[i-1]:=q^.del;rozmapuj;rozradkuj;
end;
function prevednapismenko(cis:byte):string;
var o:byte;
const prevodnistr='C C#D D#E F F#G G#A A#B ';
begin
o:=0;while cis>11 do begin dec(cis,12);inc(o) end;
prevednapismenko:=copy(prevodnistr,cis shl 1+1,2)+chr(48+o)+',';
end;
function prevedzpismenka(s:string):byte;
var o,i:byte;
const prevodnistr='F F#G G#A A#B C C#D D#E ';
begin
for i:=0 to 11 do if upcase(s[1])=copy(prevodnistr,i shl 1+1,1) then if s[2]=copy(prevodnistr,i shl 1+2,1) then o:=i;
o:=o+(ord(s[3])-48)*12;prevedzpismenka:=o;
end;
procedure insertbyte(poc:byte;poz,pozr:word);
var i,j:word;
begin
if poc=0 then exit;j:=map^[pozr];
for i:=pissiz+poc downto poz+poc do pi^[i]:=pi^[i-poc];
for i:=max+1 downto j+1 do map^[i]:=map^[i-1];map^[j]:=poz;j:=pozr;
for i:=maxrad downto j+1 do rad^[i]:=rad^[i]+1;inc(pissiz,poc);
if poc=3 then pi^[poz]:=$c0;if poc=4 then pi^[poz]:=$b0;
rozmapuj;rozradkuj;
end;
procedure deletebyte(poc:byte;poz,pozr:word);
var i,j:word;
begin
if poc=0 then exit;j:=map^[pozr];
for i:=poz to pissiz do pi^[i]:=pi^[i+poc];
for i:=j to max do map^[i]:=map^[i+1];j:=pozr;
for i:=j+1 to maxrad do rad^[i]:=rad^[i]-1;dec(pissiz,poc);
rozmapuj;rozradkuj;
end;
procedure zobraz(w,y2,x:word);
var i,j,k,l,m,n,o:word;
begin
setcolor(11,1);m:=0;l:=x;o:=79-(11-maxchan)*7;if o=79 then dec(o);
str(max:6,s);writexy(2,2,s);str(maxrad:6,s);writexy(9,2,s);
repeat
vyberradek(l);if l<max-1 then begin
for n:=0 to q^.sir do begin for i:=0 to maxchan-1 do if chanuse[chan[i]]=1 then begin
 k:=chan[i];
 j:=(q^.p[n,k,0] and $f0) shr 4;case j of
  $9:begin
	setcolor(11,1);s:=prevednapismenko(q^.p[n,k,1]);writexy(2+i*7,4+m,s);
	s:='%02x';formatstr(s,s,q^.p[n,k,2]);writexy(6+i*7,4+m,s);
  end;
  $c:begin
	setcolor(14,1);s:='C%02x ';formatstr(s,s,q^.p[n,k,1]);writexy(2+i*7,4+m,s);
	setcolor(11,1);writexy(6+i*7,4+m,'..');
  end;
  $b:begin
	setcolor(0,1);s:='B%02x,%02x';formatstr(s,s,q^.p[n,k,1]);writexy(2+i*7,4+m,s);
  end;
  $f:if q^.p[n,k,0]=$ff then if q^.p[n,k,1]=$2f then begin
	setcolor(12,1);writexy(2+i*7,4+m,'Konec!');
  end;
  0..8:if q^.p[n,k,0]=0 then begin
	setcolor(11,1);writexy(2+i*7,4+m,'... ..');
  end else begin
	setcolor(11,1);s:=prevednapismenko(q^.p[n,k,0]);writexy(2+i*7,4+m,s);
	s:='%02x';formatstr(s,s,q^.p[n,k,1]);writexy(5+i*7,3+m,s);
  end;
 end;
end;inc(m);if n<q^.sir then begin
	setcolor(10,1);s:='%02x';j:=0;formatstr(s,s,j);writexy(o,3+m,s);
end;if m>18 then n:=q^.sir;
end;
end else begin
 setcolor(11,1);for i:=0 to maxchan-1 do writexy(2+i*7,m+4,'      ');
end;setcolor(10,1);s:='%02x';formatstr(s,s,q^.del);writexy(o,3+m,s);inc(l);
until (m>19) or (l>maxrad-1);if m<=19 then begin
 setcolor(11,1);for i:=0 to 10 do for j:=m+1 to 19 do writexy(i*7+2,j+4,'      ');
end;
while y2>maxchan-1 do begin dec(y2,maxchan);inc(w);end;
setcolor(0,7);setcolorxy(y2*7+2,w+4,6);kurs:=w+4;
end;
procedure zobrazmisc;
begin
setcolor(15,5);writexy(25,5,'Jm‚no:');writexy(25,7,'Autor:');
writexy(25,9,'Pozn.:');setcolor(11,0);writexy(31,5,copy(' '+title+prstr,1,26));
writexy(31,7,copy(' '+composer+prstr,1,26));writexy(31,9,copy(' '+remark+prstr,1,26));
end;
procedure zobraznapovedu(napo:string);
begin
setcolor(14,3);writexy(1,25,prstr);writexy(2,25,napo);
end;
procedure playnastroj(x,vys:byte);
begin
play[9]:=$24;
play[2]:=x-1;play[9]:=play[9]+vys*12;r.bx:=6;r.dx:=seg(play);r.ax:=ofs(play);intr($80,r);
end;
procedure prevedznastr;
var i:byte;
begin
i:=vybvedl;na[i,1]:=nas[i,0] and $80 shr 7;na[i,2]:=nas[i,0] and $40 shr 6;na[i,3]:=nas[i,0] and $20 shr 5;
na[i,4]:=nas[i,0] and 16 shr 4;na[i,5]:=nas[i,0] and 15;na[i,8]:=nas[i,1] and $20 shr 5;
na[i,6]:=nas[i,1] and $80 shr 7;na[i,7]:=nas[i,1] and $40 shr 6;na[i,9]:=nas[i,1] and 16 shr 4;
na[i,10]:=nas[i,1] and 15;na[i,11]:=nas[i,2] and $c0 shr 6;na[i,12]:=nas[i,2] and $3f;
na[i,13]:=nas[i,3] and $c0 shr 6;na[i,14]:=nas[i,3] and $3f;
na[i,15]:=nas[i,4] shr 4;na[i,16]:=nas[i,4] and 15;na[i,17]:=nas[i,5] shr 4;
na[i,18]:=nas[i,5] and 15;na[i,19]:=nas[i,6] shr 4;na[i,20]:=nas[i,6] and 15;
na[i,21]:=nas[i,7] shr 4;na[i,22]:=nas[i,7] and 15;na[i,23]:=nas[i,8] and 3;na[i,24]:=nas[i,9] and 3;
na[i,25]:=nas[i,10] and 14 shr 1;na[i,26]:=nas[i,10] and 1;
end;
procedure preveddonastr;
var i:byte;
begin
for i:=0 to 15 do nas[vybvedl,i]:=0;i:=vybvedl;
nas[i,0]:=na[i,1] shl 7+na[i,2] shl 6+na[i,3] shl 5+na[i,4] shl 4+na[i,5];
nas[i,1]:=na[i,6] shl 7+na[i,7] shl 6+na[i,8] shl 5+na[i,9] shl 4+na[i,10];
nas[i,2]:=na[i,11] shl 6+na[i,12];nas[i,3]:=na[i,13] shl 6+na[i,14];
nas[i,4]:=na[i,15] shl 4+na[i,16];nas[i,5]:=na[i,17] shl 4+na[i,18];
nas[i,6]:=na[i,19] shl 4+na[i,20];nas[i,7]:=na[i,21] shl 4+na[i,22];
nas[i,8]:=na[i,23];nas[i,9]:=na[i,24];nas[i,10]:=na[i,25] shl 1+na[i,26];
end;
procedure resetfm;
begin
r.bx:=8;intr($80,r);
r.bx:=3;r.ax:=$ffff;intr($80,r);r.bx:=4;r.ax:=$ffff;intr($80,r);
end;
procedure stopcmf;
begin
r.bx:=7;intr($80,r);
r.bx:=3;r.ax:=$ffff;intr($80,r);r.bx:=4;r.ax:=$ffff;intr($80,r);
end;
procedure nahrajnastroje;
var i:byte;
begin
if pocnas=0 then exit;
for i:=0 to pocnas-1 do begin
	r.bx:=2;r.cx:=i;r.dx:=seg(nas[i+1]);r.ax:=ofs(nas[i+1]);intr($80,r);
end;
r.bx:=2;r.cx:=pocnas;r.dx:=seg(nas[1]);r.ax:=ofs(nas[1]);intr($80,r);
r.bx:=4;r.ax:=tiks shl 7;intr($80,r);
r.bx:=3;r.ax:=tikn xor $ffff;intr($80,r);
end;
procedure playznovu;
begin
if (pocnas=0) or (pissiz<21) then exit;
r.bx:=6;r.dx:=seg(pi^);r.ax:=ofs(pi^);intr($80,r);
r.bx:=4;r.ax:=tiks shl 7;intr($80,r);r.bx:=3;r.ax:=tikn xor $ffff;intr($80,r);
end;
procedure pis(x:byte);
begin
a[nw]:=x;inc(nw);
end;
procedure uloz;
var i,j:word;
begin
reset(f,1);nw:=0;
pis(ord('C'));pis(ord('T'));pis(ord('M'));pis(ord('F'));i:=ord(ver[1])-48;j:=(ord(ver[3])-48)*16+ord(ver[4])-48;
pis(i);pis(j);pis(lo(offins));pis(hi(offins));pis(lo(off));pis(hi(off));
pis(lo(tikn));pis(hi(tikn));pis(lo(tiks));pis(hi(tiks));pis(lo(offtit));
pis(hi(offtit));pis(lo(offcom));pis(hi(offcom));pis(lo(offrem));pis(hi(offrem));
for i:=0 to 15 do pis(chanuse[i]);pis(lo(pocnas));pis(hi(pocnas));
pis(lo(basictmp));pis(hi(basictmp));nw:=offtit;for i:=1 to length(title) do pis(ord(title[i]));pis(0);
nw:=offcom;for i:=1 to length(composer) do pis(ord(composer[i]));pis(0);
nw:=offrem;for i:=1 to length(remark) do pis(ord(remark[i]));pis(0);
nw:=offins;if pocnas>0 then for i:=1 to pocnas do for j:=0 to 15 do pis(nas[i,j]);
nw:=off;move(pi^[0],a[nw],pissiz);nw:=nw+pissiz-1;a[0]:=ord('C');
if a[nw-1]<>0 then begin a[nw]:=0;inc(nw);end;
blockwrite(f,a[0],nw);
close(f);
end;
function cti:byte;
begin
cti:=a[nr];inc(nr);
end;
procedure nahraj;
var s:string;i,j:word;
begin
reset(f,1);blockread(f,a[0],sizeof(a),nw);nr:=0;
s:=chr(cti)+chr(cti)+chr(cti)+chr(cti);if s<>'CTMF' then begin closemode;writeln('Neni .CMF!');halt end;
i:=cti;j:=cti;ver:=chr(i+48)+'.'+chr((j div 16)+48)+chr(j-(j div 16)*16+48);
offins:=cti shl 8+cti;off:=cti shl 8+cti;tikn:=cti shl 8+cti;tiks:=cti shl 8+cti;
offtit:=cti shl 8+cti;offcom:=cti shl 8+cti;offrem:=cti shl 8+cti;for i:=0 to 15 do chanuse[i]:=cti;
pocnas:=cti shl 8+cti;basictmp:=cti shl 8+cti;
nr:=offtit;title:='';if offtit>0 then repeat j:=cti;if j>0 then title:=title+chr(j);until j=0;
nr:=offcom;composer:='';if offcom>0 then repeat j:=cti;if j>0 then composer:=composer+chr(j);until j=0;
nr:=offrem;remark:='';if offrem>0 then repeat j:=cti;if j>0 then remark:=remark+chr(j);until j=0;
nr:=offins;if pocnas>0 then for i:=1 to pocnas do for j:=0 to 15 do nas[i,j]:=a[offins+(i-1) shl 4+j];
nr:=off;pissiz:=filesize(f)-nr;move(a[nr],pi^[0],pissiz);
maxchan:=0;for i:=0 to 15 do if chanuse[i]=1 then begin chan[maxchan]:=i;inc(maxchan);end;
rozmapuj;rozradkuj;
close(f);
end;

begin
initmode;setclockdesign(74,1,0,3,false);setclockstatus(true);setscreensaver(false,0);
getintvec($80,sbfmdrv);if sbfmdrv=nil then begin closemode;writeln('SBFMDRV nenainstalov n, u¨ ku!');halt;end;
if paramcount<1 then begin closemode;writeln('Norm lnˆ se tam p¡¨e je¨tˆ parametr...');halt;end;name:=paramstr(1);
getmem(pi,35000);getmem(map,30000);getmem(rad,30000);getmem(q,500);resetfm;move(play,pi^,15);pissiz:=15;
if pos('.',name)=0 then name:=name+'.cmf';offtit:=$28;title:='Super Song';pocnas:=1;basictmp:=tiks;
remark:='All Rights Reserved';composer:='Mr.Old';offcom:=offtit+length(title)+1;offrem:=offcom+length(composer)+1;
offins:=offrem+length(remark)+1;off:=offins+pocnas shl 4;
assign(f,name);{$I-}reset(f,1);if ioresult<>0 then begin novy:=true;rewrite(f,1);end;{I+}
close(f);
setcolor(11,1);openwindow(1,1,80,24,false,false,true,0,'Edit CMF by Mr.Old');
for i:=1 to 10 do begin
	for j:=2 to 23 do writexy(i*7+1,j,#$B3);writexy(i*7+1,24,#$cf);if not(i in[5,6]) then writexy(i*7+1,1,#$d1);
end;
for i:=2 to 79 do writexy(i,3,#$C4);writexy(1,3,#$c7);writexy(80,3,#$b6);
for i:=1 to 10 do writexy(i*7+1,3,#$c5);
if novy then uloz;nahraj;vybmod:=1;vybbit:=1;vybvedl:=1;setcolor(15,1);
for i:=0 to maxchan-1 do if chanuse[chan[i]]=1 then begin s:='  %02x';formatstr(s,s,i);writexy(i*7+2,2,s);end;
zobraz(0,0,0);setcolor(15,5);openwindow(20,3,61,11,false,true,true,1,'N zvy');zobrazmisc;
setcolor(15,4);openwindow(23,14,58,22,true,true,true,1,'Hlavn¡ menu');vybhl:=1;
nahrajnastroje;vybvedl:=0;playznovu;
repeat
zobraznapovedu('Esc ... Konec bez ulo‘en¡');deleteitems;for i:=1 to 5 do additem(hlmenu[i]);
if vybhl=0 then vybhl:=5;setcolor(15,4);setmenucolor(14,4);setmenucursor(1,7);
if (vybvedl=4) and (vybhl=2) then dec(vybvedl);
if (vybhl=4) or (vybvedl=0) or ((vybvedl=4) and (vybhl=1)) or ((vybvedl=3)and(vybhl=2)) then vybhl:=lo(menu(27,16,28,5,vybhl));
setcolor(15,4);if (vybvedl=4) and (vybhl<>3) then dec(vybvedl);playznovu;
if vybhl in [1,2] then begin deleteitems;if vybhl=1 then nw:=4 else nw:=3;
	for i:=1 to nw do additem(vedlmenu[vybhl,i]);
	openwindow(23,14,58,22,true,true,true,1,'Vedl. menu');vybvedl:=menu(27,16,28,nw,vybvedl) end;
if (vybhl=3) and (pocnas>0) then begin
	setcolor(15,4);setmenucolor(14,4);setmenucursor(1,7);
	openwindow(23,14,58,23,true,true,true,1,'N str. menu');zobraznapovedu('F1-4 ... Play instrument');
 repeat
	deleteitems;for i:=1 to pocnas do begin str((i-1):3,s);additem(s+'.n stroj');end;
	setmenucolor(14,4);setmenucursor(1,7);vybvedl:=menu(27,16,28,6,vybvedl);
	if hi(vybvedl) in [1,2,3,4] then begin stopcmf;playnastroj(lo(vybvedl),hi(vybvedl)) end;zmenan:=false;
	if (hi(vybvedl) in [5,6,7]) and (pocnas<255) then begin
		stopcmf;inc(pocnas);for i:=0 to 15 do nas[pocnas,i]:=0;prevedznastr;nahrajnastroje;
	end;
	if (hi(vybvedl)=8) and (pocnas>1) then begin
		stopcmf;if lo(vybvedl)<pocnas-1 then for j:=lo(vybvedl) to pocnas-1 do for i:=0 to 15 do nas[j,i]:=nas[j+1,i];
		dec(pocnas);nahrajnastroje;if lo(vybvedl)>pocnas then vybvedl:=pocnas+8 shl 8;setcolor(14,4);clrscr;
	end;
	if (vybvedl>0) and (hi(vybvedl)=0) then begin prevedznastr;
	 setcolor(15,3);openwindow(4,5,44,19,true,true,true,1,'Vyber byte');
	 repeat setmenucolor(15,3);setmenucursor(11,0);
	  deleteitems;for i:=1 to 11 do additem(nasmenu[i]);
	  vybmod:=lo(menu(8,7,33,11,vybmod));if vybmod>0 then begin
	   ii:=((vybmod-1) shr 1)+1;setcolor(14,2);openwindow(35,8,76,11+nasmenu2siz[ii],true,true,true,1,'Vyber bit');vybbit:=1;
	   repeat deleteitems;
	    for j:=1 to nasmenu2siz[ii] do begin str(na[vybvedl,nasmenu2pol[vybmod]+j]:4,s);
			additem(copy(nasmenu2[ii,j]+prstr,1,28)+s)end;
	    setmenucolor(14,2);setmenucursor(4,0);vybbit:=menu(39,10,34,nasmenu2siz[ii],vybbit);
	    if hi(vybbit) in[1,2,3,4] then begin stopcmf;playnastroj(lo(vybvedl),hi(vybbit))end;
	    if (vybbit>0) and (hi(vybbit)=0) then begin
		setcolor(0,7);openwindow(24,13,57,18,true,true,true,1,'Zad v n¡');j:=nasmenu2pol[vybmod]+vybbit;
		s:='Zadej ‡¡s¡lko (';case (j) of
		 1,2,3,4,6,7,8,9,26:s:=s+'0..1):';5,10,15,16,17,18,19,20,21,22:s:=s+'0..15):';
		 11,13,23,24:s:=s+'0..3)';12,14:s:=s+'0..63):';25:s:=s+'0..7):';
		end;writexy(29,15,s);
		j:=nasmenu2pol[vybmod]+vybbit;str(na[vybvedl,j],s);
		setcolor(0,3);repeat i:=0;if readxy(29,16,s,24) then val(s,na[vybvedl,j],i) until i=0;closewindow;
		preveddonastr;prevedznastr;zmenan:=true;stopcmf;
	    end;
	   until vybbit=0;closewindow;
	  end;
	 until vybmod=0;closewindow;if zmenan then begin stopcmf;{resetfm;nahrajnastroje;}end;
	end;
 until vybvedl=0;closewindow;
end;
if (vybvedl in [1,2,3]) and (vybhl=1) then begin
	setcolor(11,0);if vybvedl=1 then begin
		i:=length(title);readxy(32,5,title,24);j:=length(title);
	end;
	if vybvedl=2 then begin
		i:=length(composer);readxy(32,7,composer,24);j:=length(composer);
	end;
	if vybvedl=3 then begin
		i:=length(remark);readxy(32,9,remark,24);j:=length(remark);
	end;
end;
offtit:=$28;offcom:=offtit+length(title)+1;offrem:=offcom+length(composer)+1;
offins:=offrem+length(remark)+1;off:=offins+pocnas shl 4;
if (vybvedl in [1,2]) and (vybhl=2) then begin
	setcolor(0,7);if vybvedl=1 then begin
		openwindow(10,7,71,12,true,true,true,1,'Tik– za sekundu');writexy(15,9,'Zadej men¨¡ ‡¡sl¡‡ko:');
	end else begin
		openwindow(10,7,71,12,true,true,true,1,'Tik– za ‡tvrt noty');writexy(15,9,'Zadej men¨¡ ‡¡sl¡‡ko:');
	end;setcolor(0,3);if vybvedl=1 then begin
		str(tiks,s);repeat if readxy(15,10,s,51) then val(s,tiks,i) else i:=0;until i=0;
	end else begin
		str(tikn,s);repeat if readxy(15,10,s,51) then val(s,tikn,i) else i:=0;until i=0;
	end;r.bx:=3;r.ax:=tikn xor $ffff;intr($80,r);
	r.bx:=4;r.ax:=tiks shl 8;intr($80,r);closewindow;
end;
if vybhl=4 then begin
closewindow;closewindow;zobraz(w,y,z);
repeat
c:=readkey;vyberradek(x);if c=#0 then begin func:=true;c:=readkey end else func:=false;
ii:=0;j:=y;while j>=maxchan do begin inc(ii);dec(j,maxchan);end;
if func then begin
if (c=#80) and (x<maxrad-1) then begin inc(w,q^.sir);inc(w);inc(x);end;
if (c=#81) then for i:=1 to 18 do if x<maxrad-2 then begin vyberradek(x);inc(x);inc(w,q^.sir+1);if x=maxrad-2 then i:=18 end;
if (c=#73) then for i:=1 to 18 do if x>0 then begin vyberradek(x-1);dec(w,q^.sir+1);dec(x);
	if x=0 then begin x:=0;y:=0;z:=0;w:=0;i:=18 end end;
if (c=#72) and (x>0) then begin vyberradek(x-1);dec(w,q^.sir);dec(w);dec(x);end;
if (c=#71) and (x>0) then begin x:=0;y:=0;z:=0;sx:=0;sy:=0;sz:=0;w:=0;sw:=0;end;
if (c=#77) and (y<(q^.sir+1)*maxchan-1) then inc(y);
if (c=#83) and (q^.p[ii,j,0]>0) and (pissiz>15) then begin
	case (q^.p[ii,j,0] shr 4) of 0..8,12:l:=3;9,11:l:=4 else l:=3;end;
	vyberradek(x);deletebyte(l,map^[rad^[x]],x);q^.p[ii,j,0]:=0;zapisradek(x);
	stopcmf;rozmapuj;rozradkuj;while y>=maxchan do dec(y,maxchan);
end;
if (c=#82) and (q^.p[ii,j,0]=0) then begin
	insertbyte(3,map^[rad^[x]],x);q^.p[ii,j,0]:=$c0+j;q^.p[ii,j,1]:=0;q^.p[ii,j,2]:=0;
	stopcmf;zapisradek(x);rozmapuj;rozradkuj;
end;
if (c=#75) and (y>0) then dec(y);end else begin
if (c=#13) then begin
 i:=q^.p[ii,j,0] shr 4;vyberradek(x);
 case i of
  9:begin
	setcolor(0,3);s:=prevednapismenko(q^.p[ii,j,1]);
	s:=copy(s,1,3)+',%02x';formatstr(s,s,q^.p[ii,j,2]);readxy(j*7+2,kurs,s,6);
	s:=copy(s,1,4)+upcase(s[5])+upcase(s[6]);if ord(s[6])>64 then s[6]:=chr(ord(s[6])-7);
	q^.p[ii,j,1]:=prevedzpismenka(copy(s,1,3));if ord(s[5])>64 then s[5]:=chr(ord(s[5])-7);
	q^.p[ii,j,2]:=(ord(s[5])-48)*16+ord(s[6])-48;zapisradek(x);
  end;
  1..8:begin
	setcolor(0,3);s:=prevednapismenko(q^.p[ii,j,0]);
	s:=copy(s,1,3)+',%02x';formatstr(s,s,q^.p[ii,j,2]);readxy(j*7+2,kurs,s,6);
	s:=copy(s,1,4)+upcase(s[5])+upcase(s[6]);if ord(s[6])>64 then s[6]:=chr(ord(s[6])-7);
	q^.p[ii,j,0]:=prevedzpismenka(copy(s,1,3));if ord(s[5])>64 then s[5]:=chr(ord(s[5])-7);
	q^.p[ii,j,1]:=(ord(s[5])-48)*16+ord(s[6])-48;zapisradek(x);
  end;
  $c:begin
	setcolor(0,3);k:=q^.p[ii,j,1];s:=chr(48+k div 10)+chr(48+k mod 10);readxy(j*7+3,kurs,s,2);
	q^.p[ii,j,1]:=(ord(s[1])-48)*10+(ord(s[2])-48);zapisradek(x);
  end;
  $b:begin
  end;
  $0:begin
	setcolor(14,2);openwindow(30,12,51,18,true,true,true,1,'Typ');
	setmenucolor(14,2);setmenucursor(4,6);deleteitems;additem('Nota');additem('Kanal');additem('Nesmysl');
	l:=lo(menu(35,14,10,3,1));closewindow;case l of
	 1:begin
		vyberradek(x);insertbyte(4,map^[rad^[x]],x);q^.p[ii,j,0]:=$90+j;q^.p[ii,j,1]:=$40;q^.p[ii,j,2]:=$78;
		zapisradek(x);stopcmf;
	 end;
	end;
  end;
 end;rozmapuj;rozradkuj;
end;
if (y>maxchan-1) and (c in [#80,#72]) then y:=maxchan-1;playznovu;
end;
if (w<0) and (z>0) then while (w<0) and (z>0) do begin dec(z);vyberradek(z);inc(w,q^.sir+1);end;
if w>19 then while w>19 do begin vyberradek(z);dec(w,q^.sir+1);inc(z);end;
zobraz(w,y,z);playznovu;
until c=#27;vybhl:=4;setcolor(15,5);openwindow(20,3,61,11,false,true,true,1,'N zvy');zobrazmisc;
setcolor(15,4);openwindow(23,14,58,22,true,true,true,1,'Hlavn¡ menu');
end;playznovu;

if (vybhl in [1,2]) then closewindow;if vybhl=1 then zobrazmisc;
until vybhl in [5,0];stopcmf;
if vybhl=5 then uloz;
j:=rad^[0];i:=pi^[map^[max-1]];
freemem(q,500);freemem(rad,30000);freemem(map,30000);freemem(pi,35000);
closemode;setcolor(7,0);writeln(i,j:6,max:6,maxrad:6,maxchan:6);
end.