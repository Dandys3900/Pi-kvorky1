{  (c) by Mr.Old from Down Raisin, 08.09.94, ver 3.01   }
uses dos,crt;
var f,f2:file;
    fa:searchrec;
    c:char;
    nd,pr,del:byte;
    r:registers;
    st:string;
    s,text:array[1..48] of char;
    i,j,k,nr,max,x,y:integer;
    o:array[1..6] of word;
    p:array[1..5] of integer;
    mis,driv:byte;
    pov:boolean;
    nam:array[1..12] of char;
    jm:array[1..8] of char;
    poz,cp,vyb,kod:word;
    po,akt:byte;
    bit:byte;
    a:array[1..32768] of byte;
    aa:array[1..63] of byte;
    b:array[1..2048] of word;
    op,chyb:boolean;
label konec,padejdolu;
procedure prepare;forward;
procedure preved;forward;
const tab:array[0..11] of byte=(1,6,9,14,10,10,7,9,1,8,18,4);
      bp=1;
      mx=18;
      my=5;
      bt=11;
      bzp=0;
      bzt=14;
      m:array[0..11,1..10] of byte=((0,0,0,0,0,0,0,0,0,0),(1,0,0,0,0,0,0,0,1,1),(1,1,1,0,0,0,0,0,1,1),(1,0,0,1,0,1,0,0,1,1),
	(0,0,0,0,0,1,1,0,1,1),(0,0,0,0,0,1,1,0,1,1),(1,0,0,0,1,0,0,0,1,1),(0,0,0,0,0,1,0,0,1,1),(0,0,0,0,0,0,0,0,0,0),
	(1,1,0,0,0,0,0,0,1,1),(1,1,0,0,0,1,1,1,1,1),(0,0,0,0,1,0,0,1,1,1));
      naz:array[0..11] of string=(' Konec SHP        ',' Oblasti kam se nemuze ',' Vychody              ',
	' Scenky               ',' Animace na pozadi    ',' Prekryvajici casti   ',' Texty pro ikonu Oka   ',
	' Pisnicka na pozadi     ',' Nova polozka       ',' Oblast pouzivani        ',' Parametry mluvitele    ',
	' Texty dialogu           ');
      nazakt:array[0..2] of string=('Kliknutim','Slapnutim','Zadna');
      nazpov:array[0..2] of string=('Bez povoleni','S povolenim 1','S opacnym povolenim 0');
      xy:array[1..17,1..2] of byte=((39,1),(13,4),(27,4),(41,4),(55,4),(13,7),(27,7),(27,9),(58,9),
	(59,11),(28,13),(56,13),(22,15),(58,15),(46,17),(21,19),(33,19));
procedure prevedzpatky;
var k2:byte;
begin
for k2:=1 to 4 do o[k2]:=p[k2];
if p[5] and 1<>0 then inc(o[1],256);if p[5] and 16<>0 then inc(o[3],256);
end;
procedure upravpol;
var i,j:word;k:byte;
begin
j:=b[cp];if (m[x,9]=1) or (po>0) then begin
	k:=x shl 4;k:=k+bit;if po=2 then inc(k,8);
end else k:=x;a[j]:=k;
if k>15 then begin
	a[j+1]:=lo(poz);a[j+2]:=hi(poz);inc(j,2);
end;
k:=x;
if k in [1,2,9,10] then begin
	for i:=1 to 4 do p[i]:=o[i];preved;
	for i:=1 to 5 do a[i+j]:=p[i];
end;
if k=10 then begin
	a[16+j]:=lo(o[5]);a[17+j]:=o[6];if o[5]>255 then inc(a[5+j],128);
end;
if k in [2,9] then begin
	a[j+7]:=o[6];if o[5]>255 then begin
		dec(o[5],256);a[j+5]:=a[j+5] or 128;end;
	a[j+6]:=o[5];
	if k=2 then a[j+8]:=mis;
end;
if k in [3,4,5,7] then for i:=1 to 8 do a[j+i]:=ord(jm[i]);
if k=10 then for i:=1 to 8 do a[j+i+6]:=ord(jm[i]);
if k in [4,5] then a[j+9]:=pr;
if k=10 then a[j+15]:=pr;
if k=3 then begin
	a[j+13]:=0;
	for i:=1 to 4 do p[i]:=o[i];preved;
	for i:=1 to 5 do a[i+j+8]:=p[i];
	if akt=1 then a[j+13]:=a[j+13]+128;
end;
if k=10 then a[j+6]:=kod;
if k in [6,11] then begin
	a[j+1]:=del;for i:=1 to del do a[i+j+1]:=ord(text[i]);
end;
if k=11 then begin
	a[j+del+2]:=lo(kod);a[j+del+3]:=hi(kod);
end;
if k=6 then begin
	for i:=1 to 4 do p[i]:=o[i];preved;
	for i:=1 to 5 do a[i+j+1+del]:=p[i];
end;
end;
procedure nactipol;
var i,j:word;
    k:byte;
begin
for i:=1 to 48 do text[i]:=' ';for i:=1 to 8 do jm[i]:=' ';
for i:=1 to 6 do o[i]:=0;pr:=0;mis:=0;akt:=2;kod:=0;
j:=b[cp];k:=a[j];poz:=0;bit:=0;
if k>15 then begin
	if k and 8<>0 then po:=2 else po:=1;
	poz:=a[j+1]+a[j+2] shl 8;bit:=k and $7;k:=trunc(k/16);
	inc(j,2);
end else po:=0;
x:=k;
if k in [1,2,9,10] then begin
	for i:=1 to 5 do p[i]:=a[i+j];prevedzpatky;
end;
if k=10 then begin
	o[5]:=a[j+16];o[6]:=a[j+17];if a[j+5] and $80<>0 then inc(o[5],256);
end;
if k in [2,9] then begin
	o[5]:=a[j+6];o[6]:=a[j+7];if a[j+5] and 128<>0 then inc(o[5],256);
	if k=2 then mis:=a[j+8];
end;
if k in [3,4,5,7] then for i:=1 to 8 do jm[i]:=chr(a[i+j]);
if k=10 then for i:=1 to 8 do jm[i]:=chr(a[i+j+6]);
if k in [4,5] then pr:=a[j+9];
if k=10 then pr:=a[j+15];
if k=3 then begin
	for i:=1 to 5 do p[i]:=a[j+i+8];prevedzpatky;
	akt:=0;if a[j+13] and 128<>0 then akt:=1;
end;
if k in [6,11] then begin
	del:=a[j+1];for i:=1 to del do text[i]:=chr(a[j+1+i]);
end;
if k=11 then kod:=a[j+del+2]+a[j+del+3] shl 8;
if k=10 then kod:=a[j+6];
if k=6 then begin
	for i:=1 to 5 do p[i]:=a[j+i+del+1];prevedzpatky;
end;
end;	
procedure vloz(pozic:word;cis:byte);
var i:word;
begin
for i:=pozic to nr do a[nr-i+pozic+cis]:=a[nr-i+pozic];inc(nr,cis);for i:=0 to cis-1 do a[pozic+i]:=0;
end;
procedure delete(pozic:word;cis:byte);
var i:word;
begin
for i:=pozic+cis to nr do a[i-cis]:=a[i];dec(nr,cis);
a[nr]:=0;
end;
procedure preved;
begin
p[5]:=0;
if o[1]>255 then begin
	p[5]:=1;dec(o[1],256);
end;if o[3]>255 then begin
	inc(p[5],16);dec(o[3],256);end;
p[1]:=o[1];p[2]:=o[2];p[3]:=o[3];p[4]:=o[4];
end;
procedure za(cis:byte);
begin
textcolor(bt);if (m[x,cis]=0) and (cis<8) then textcolor(bzp);
if cis in [8,9] then begin
	if po>0 then begin
		m[x,10]:=1;m[x,9]:=1;
	end else begin
		m[x,10]:=0;m[x,9]:=0;textcolor(bzp);
	end;
end;
if cis=10 then if m[x,8]=0 then textcolor(bzp);
end;
procedure ukaz;
var i,j:integer;
begin
textcolor(bt);textbackground(bp);
clrscr;
textcolor(bt+128);textbackground(bp);gotoxy(xy[y,1],xy[y,2]);write(#174);textcolor(bt);
if x=0 then za(1);gotoxy(1,1);write('Typ:');
za(1);gotoxy(1,3);write('Souradnice rohu oblasti:');
gotoxy(2,4);write('X1:');gotoxy(16,4);write('Y1:');gotoxy(30,4);write('X2:');gotoxy(44,4);write('Y2:');
za(2);gotoxy(1,6);write('Pujde na souradnice:');
gotoxy(2,7);write('X:');gotoxy(16,7);write('Y:');
za(3);gotoxy(1,9);write('Cislo mistnosti:');za(4);gotoxy(34,9);write('Aktivace:');
za(5);gotoxy(1,11);write('Text:');
za(6);gotoxy(1,13);write('Jmeno souboru:');
za(7);gotoxy(34,13);write('Cislo prepisu:');
za(10);gotoxy(1,15);write('Kod:');if m[x,8]=1 then za(5);gotoxy(34,15);write('Typ textu:');
textcolor(bt);if x in [0,8] then za(7);gotoxy(1,17);write('Typ povoleni:');
za(8);gotoxy(1,19);write('Pozice:');za(8);gotoxy(20,19);write('.');gotoxy(22,19);write('bajt');
za(8);gotoxy(32,19);write('.');gotoxy(34,19);write('bit');
textbackground(bzp);textcolor(bzt);
gotoxy(6,1);write('                                 ');
gotoxy(7,1);write(naz[x]);
gotoxy(6,4);write('       ');gotoxy(20,4);write('       ');gotoxy(34,4);write('       ');gotoxy(48,4);write('       ');
for i:=1 to 4 do begin
	gotoxy(8+(i-1)*14,4);write(o[i]:3);
end;
gotoxy(6,7);write('       ');gotoxy(20,7);write('       ');gotoxy(8,7);write(o[5]:3);
gotoxy(22,7);write(o[6]:3);
gotoxy(20,9);write('       ');gotoxy(45,9);write('             ');
gotoxy(22,9);write(mis:3);gotoxy(47,9);write(nazakt[akt and 3]);
gotoxy(7,11);write('                                                    ');
gotoxy(8,11);write(text);
gotoxy(16,13);write('            ');gotoxy(18,13);write(jm);
gotoxy(49,13);write('       ');gotoxy(51,13);write(pr:3);
gotoxy(7,15);write('     :         ');gotoxy(9,15);write(lo(kod and $1f):3);gotoxy(13,15);write((hi(kod) and 3)+1:1);
gotoxy(14,15);if kod and $60>0 then write('-',(hi(kod) shr 2) and 3+1);gotoxy(16,15);if kod and $60>$20 then
write('-',(hi(kod) shr 4) and 3+1);gotoxy(18,15);if kod and $60=$60 then write('-',(hi(kod) shr 6) and 3+1);
gotoxy(47,15);write('           ');gotoxy(48,15);if (m[x,8]=1) and (x=11) then begin
	if (x=11) and (kod and 128<>0) then write('Odpoved') else write('Otazka');
end else write('None');
gotoxy(16,17);write('                              ');gotoxy(18,17);write(nazpov[po]);
gotoxy(11,19);write('         ');gotoxy(27,19);write('     ');gotoxy(13,19);write(poz:5);gotoxy(29,19);write(bit:1);
textbackground(bp);
window(1,1,80,25);textcolor(bt);textbackground(0);
gotoxy(59,25);write((32768-nr):5,' bytes free');
gotoxy(5,25);write('Edit: ',nam,' ',nr,' bytes');
window(8,3,72,23);textbackground(bp);textcolor(bzt);gotoxy(50,1);
for i:=50 to 60 do write('Í');gotoxy(52,1);write(' ',cp,' ');
window(9,4,71,22);
end;
procedure smaz;
begin
r.ah:=1;r.ch:=$20;r.cl:=32;intr($10,r);
end;
procedure kurzor;
begin
r.ah:=1;r.ch:=$18;r.cl:=$19;intr($10,r);
end;
procedure zrusram(x1,y1,x2,y2:word);
begin
window(x1,y1,x2,y2);textbackground(0);clrscr;textcolor(bt);
window(1,1,80,25);
end;
procedure ramecek(x1,y1,x2,y2:word);
var i,j:integer;
begin
window(x1,y1,x2,y2);if y2-y1=9 then textbackground(1) else
textbackground(bp);clrscr;textcolor(bzt);
window(1,1,80,25);
for i:=x1 to x2 do begin
	gotoxy(i,y2);write('Í');
	gotoxy(i,y1);write('Í');
end;
for j:=y1 to y2 do begin
	gotoxy(x1,j);write('º');
	gotoxy(x2,j);write('º');
end;
gotoxy(x1,y2);write('È');gotoxy(x1,y1);write('É');
gotoxy(x2,y1);write('»');gotoxy(x2,y2);write('¼');
window(x1+1,y1+1,x2-1,y2-1);
end;
procedure prepare;
var si:integer;
begin
j:=0;i:=1;a[nr]:=0;
repeat
inc(j);si:=i;
b[j]:=i;k:=a[i];
if (k=6) or (k and $F0=$60) or (k=11) or (k and $f0=$b0) then inc(i,a[i+1]);
if k<16 then inc(i,tab[k]) else inc(i,(tab[k shr 4]+2));
if si=i then inc(i);
until i>=nr;max:=j+1;b[max]:=nr;
end;
procedure nacti(del:byte;ss:string);
var x,y:integer;
    func:boolean;
    snd:byte;
begin
x:=wherex;y:=wherey;textbackground(bzp);textcolor(bzt);kurzor;
for  i:=1 to del do s[i]:=' ';i:=1;
for j:=1 to length(ss) do s[j]:=ss[j];nd:=del;
for j:=1 to length(ss) do if s[del-j+1]=' ' then dec(nd) else j:=length(ss);snd:=nd;
repeat
if keypressed then begin c:=readkey;
if c<>#0 then func:=false else func:=true;
if func then c:=readkey;
if del<48 then c:=upcase(c);
if not func then begin
  if (ord(c)>=32) then begin
	if i<del then for j:=i+1 to del do s[del-j+i+1]:=s[del-j+i];
	s[i]:=c;inc(i);inc(nd);
  end;
end;
if func then begin
  if (c=#77) and (i<del) then inc(i);
  if (c=#75) and (i>1) then dec(i);
  if (c=#83) then begin
	if i<del then for j:=i+1 to del do s[j-1]:=s[j];s[del]:=' ';dec(nd);
  end;
end;
if (c=#8) and (i>1) then begin
	for j:=i to del do s[j-1]:=s[j];s[del]:=' ';dec(i);dec(nd);
end;
if (c=#13) and (del=48) then begin
	i:=49;
end;
if (c=#13) and (del=8) then begin
	nd:=8;i:=9;
end;
if (c=#27) then begin
	for j:=1 to length(ss) do s[j]:=ss[j];nd:=snd;i:=del+1;
end;
gotoxy(x,y);for j:=1 to del do write(s[j]);gotoxy(x+i-1,y);
end;
until i=del+1;
writeln;if nd>48 then nd:=48;c:=#0;smaz;
end;
procedure inccu(cis:shortint);
var jo:boolean;
begin
jo:=false;
repeat
inc(y,cis);if y>=18 then y:=1;if y=0 then y:=17;
if ((y in [2,3,4,5]) and (x in [1,2,3,6,9,10])) or ((y in [6,7]) and (x in [2,9,10])) or ((y in [13,14]) and (x=11)) or
	((y=8) and (x=2)) or ((y=9) and (x=3)) or ((y=10) and (x in [6,11])) or ((y=11) and (x in [3,4,5,7,10])) or
	((y=12) and (x in [4,5,10])) or ((y=15) and (x>0)) or ((po>0) and (y in [16,17])) or (y=1) or ((y=13) and (x=10))
	then jo:=true;
until jo;
end;
procedure vyberx;
var xxx:byte;
procedure ukazmenu;
begin
for i:=1 to 10 do begin
	gotoxy(1,i);
	if i>7 then inc(i);
	if xxx<>i then begin
		textcolor(14);textbackground(1);end else begin
		textcolor(0);textbackground(7);end;
	write(copy(naz[i],1,22));
	if i>8 then dec(i);
end;
end;
var sx:byte;
begin
xxx:=x;if x=8 then xxx:=1;sx:=x;
ramecek(mx,my,mx+24,my+11);textbackground(1);clrscr;ukazmenu;
repeat
c:=readkey;
if c=#72 then begin
	dec(xxx);if xxx=8 then xxx:=7;
end;
if c=#80 then begin
	inc(xxx);if xxx=8 then xxx:=9;
end;
if xxx<=0 then xxx:=11;
if xxx>11 then xxx:=1;
ukazmenu;
until (c=#13) or (c=#27);
zrusram(mx,my,mx+24,my+9);
ramecek(8,3,72,23);
if c=#27 then x:=sx else begin x:=xxx;if x=8 then x:=9;end;c:=#0;
end;

begin
chyb:=false;
if paramcount<1 then begin chyb:=true;goto konec;end;st:=paramstr(1);
for i:=1 to 12 do nam[i]:=' ';if length(st)>12 then st:=copy(st,1,12);
for i:=1 to length(st) do nam[i]:=upcase(st[i]);
for i:=1 to 12 do if nam[i]=' ' then begin
	j:=i;i:=12;end;i:=j;
while i<12 do begin inc(i);nam[i]:=' ';end;
for i:=1 to 9 do if nam[i]='.' then begin j:=i+1;i:=9;end else j:=0;
if (j=0) and (length(st)>8) then begin st:=copy(st,1,8);nam[9]:=' ';end;
if j>9 then begin j:=0;nam[9]:=' ';end;
if j=0 then for i:=1 to 9 do if nam[i]=' ' then begin
	nam[i]:='.';nam[i+1]:='S';nam[i+2]:='H';nam[i+3]:='P';i:=9;
end;
if j>1 then if (nam[j]<>'S') or (nam[j+1]<>'H') or (nam[j+2]<>'P') then begin
	chyb:=true;goto konec;
end;
findfirst(nam,$3f,fa);nr:=1;a[1]:=4;
if doserror<>0 then begin
	assign(f,nam);rewrite(f,1);end else begin
	assign(f,nam);reset(f,1);
	blockread(f,a,32768,nr);
end;
if (nr<3) or (filesize(f)<3) then begin
	rewrite(f,1);a[1]:=8 xor $c7;a[2]:=$c7;nr:=2;
end;
for i:=1 to nr do a[i]:=a[i] xor $c7;
prepare;
textmode(co80);clrscr;textcolor(bzt);
gotoxy(26,1);write('SHaPe Editor v3.01 by Mr.Old');
x:=2;y:=1;po:=0;c:='8';pov:=false;
cp:=1;
ramecek(8,3,72,23);smaz;nactipol;ukaz;
repeat
if keypressed then c:=readkey else c:=#0;
if c=#73 then begin
	dec(cp);if cp=0 then cp:=max;nactipol;
	inccu(-1);inccu(1);ukaz;
end;
if c=#81 then begin
	inc(cp);if cp=max+1 then cp:=1;nactipol;
	inccu(-1);inccu(1);ukaz;
end;
if c in [#72,#75] then begin
	inccu(-1);if y=0 then y:=17;ukaz;
end;
padejdolu:
if c in [#80,#77] then begin
	inccu(1);if y=18 then y:=1;ukaz;
end;
if (c=#82) then begin
	j:=b[cp];vloz(j,1);a[j]:=8;po:=0;za(8);prepare;nactipol;ukaz;
end;
if (c=#83) and (cp<max) and (max>2) then begin
	j:=tab[x];if (x=6) or (x and $F0=$60) or (x=11) or (x and $f0=$B0) then inc(j,a[b[cp]+1]);
	if a[b[cp]]>15 then inc(j,2);
	delete(b[cp],j);prepare;nactipol;ukaz;
end;
if (c=#13) then begin
	if ((y in [2,3,4,5]) and (m[x,1]=1)) or ((y in [6,7]) and (m[x,2]=1)) or ((y in [1,15]) and (x>0)) or
	  ((y=8) and (m[x,3]=1)) or ((y=9) and (m[x,4]=1)) or ((y=10) and (m[x,5]=1)) or ((y in [13,14]) and (m[x,8]=1)) or
	  ((y=11) and (m[x,6]=1)) or ((y=12) and (m[x,7]=1)) or ((y in [16,17]) and (po>0)) then begin
		j:=b[cp];
		if y in [16,15,2,3,4,5,6,7,8,12,13] then kurzor;
		if y=10 then begin
			i:=a[j+1]+tab[x];if a[j]>15 then inc(i,2);vyb:=j;k:=a[j];
			delete(vyb,i);
			gotoxy(8,11);nacti(48,text);del:=nd;if po>0 then inc(nd,2);vloz(vyb,nd+tab[x]);
			text:=s;a[vyb]:=x;if po>0 then a[vyb]:=a[vyb] shl 4+bit+8*(po-1);
		end;textbackground(bzp);textcolor(bzt);
		if y in [2,3,4,5] then begin
			gotoxy(xy[y,1]-5,xy[y,2]);readln(o[y-1]);
		end;
		if y in [6,7] then begin
			gotoxy(xy[y,1]-5,xy[y,2]);readln(o[y-1]);
		end;
		if y=15 then begin
			driv:=a[b[cp]];
			k:=po;vyb:=b[cp];
			inc(po);if po=3 then po:=0;if po=0 then delete(vyb,2);
			if po=1 then vloz(vyb,2);if po=1 then a[vyb]:=driv shl 4+bit;
			if po=2 then a[vyb]:=driv+8;if po=0 then a[vyb]:=x;
			za(8);
		end;
		if (y=1) and (cp<max) and (x>0) then begin
			vyb:=b[cp];j:=tab[x];if po>0 then inc(j,2);
			if (x=6) or (x=11) then inc(j,del);
			delete(vyb,j);vyberx;
			text[1]:=' ';del:=1;po:=0;j:=tab[x];if (x in [6,11]) then inc(j,del);za(8);
			vloz(vyb,j);a[vyb]:=x;
		end;
		if y=13 then begin
			gotoxy(xy[y,1]-13,xy[y,2]);readln(i);kod:=i and $1f;
			gotoxy(xy[y,1]-13,xy[y,2]);write(kod:3);
			if x=11 then for i:=0 to 3 do begin
				gotoxy(xy[y,1]-10+i*2,xy[y,2]);
				repeat c:=readkey until (c in ['4','1','2','3']) or ((c=#13) and (i>0));
				if (i=3) and (c<>#13) then kod:=kod or $60;
				if c=#13 then begin
					kod:=kod or (((i-1) shl 5) and $60);i:=3;
				end else
				if c<>#13 then begin if i>0 then write('-',c) else write(':',c);
					kod:=kod+(ord(c)-49) shl (8+i*2);
				end
			end;
		end;
		if (y=17) and (po>0) then begin
			gotoxy(xy[17,1]-4,xy[17,2]);readln(bit);while bit>7 do dec(bit,8);
		end;
		if (y=16) and (po>0) then begin
			gotoxy(xy[16,1]-8,xy[16,2]);readln(poz);
		end;
		if (y=14) and (x=11) then kod:=kod xor 128;
		if y=12 then begin
			gotoxy(xy[12,1]-5,xy[12,2]);readln(pr);
		end;
		if y=11 then begin
			gotoxy(xy[11,1]-10,xy[11,2]);nacti(8,jm);
			for i:=1 to 8 do jm[i]:=s[i];
		end;
		if y=8 then begin
			gotoxy(xy[8,1]-5,xy[8,2]);readln(mis);mis:=mis and $ff;
		end;
		if y=9 then akt:=1-akt;
		smaz;
		upravpol;prepare;
		nactipol;c:=#80;goto padejdolu;
	end;
end;
until (c=#27) or (c=#68);
if c=#27 then begin
	close(f);assign(f,nam);rewrite(f,1);
	for i:=1 to nr do a[i]:=a[i] xor $C7;
	blockwrite(f,a,nr);
end;close(f);
kurzor;
konec:
if chyb then begin
	writeln('Musis zadat jmeno souboru s priponou .SHP !!!');
end;
end.