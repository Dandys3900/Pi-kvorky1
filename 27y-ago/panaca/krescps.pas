{  (c) by Mr.Old 20.10.94, ver. 2.08, last upgrade: 11.01.95   }
uses dos,crt;
{$R-,S-}
{$L x1.obj}
procedure setxmode;external;
{$L xgraf.obj}
procedure grclose;external;
procedure grsetworkpage(pg:byte);external;
procedure grsetdisppage(pg:byte);external;
function grgetdisppage:byte;external;
function grgetworkpage:byte;external;
procedure grgetimage(x1,y1,x2,y2:word;img:pointer);external;
procedure grputimage(x1,y1,x2,y2:word;img:pointer);external;
procedure grputimagem(x1,y1,x2,y2:word;img:pointer;width:byte);external;
procedure grmoveimage(x1,y1,x2,y2,x,y:word;src,dest:byte);external;
procedure grputpixel(x,y:word;col:byte);external;
procedure grline(x1,y1,x2,y2:word);external;
procedure grsetcolor(col:byte);external;
procedure grtext(x,y:word;st:string);external;
procedure grprintfore(col:byte);external;
type typptr=^typid;
     typid=array[1..32768] of byte;
     typscr=^typscrid;
     typscrid=array[0..65533] of byte;
var i,i2,j,k,l,x1,x2,y1,y2,nr,mx,my,smx,smy,ssx,ssy,mo,nw,sir,vys,sx1,sx2,sy1,sy2:word;
    sirik,vysik,but,but2,pauza:byte;
    pos,pos2:longint;
    c:char;
    f:file;
    fs:searchrec;
    a:array[1..32768] of byte;
    pal:array[0..767] of byte;
    zv:array[0..15,0..15] of byte;
    mys,myspo:pointer;
    vzorek:array [0..159] of byte;
    vzx,vzy,vzs:byte;
    r:registers;
    scr:typscr;
    b:typptr;
    cara,zvet,barva,stcara:boolean;
const ba:byte=63;
      sour:boolean=false;
      tl:byte=1;
      panel=48;			{barva podkladu u vyberu barev nebo pri zobrazovani souradnic}
      aktivni=29;		{barva aktivniho nastaveni RGB}
      mrizka=1;			{barva site barev nebo pri zvetseni}
      hranice=128;		{barva os RGB}
      novapaleta:boolean=false;
      novyobrazek:boolean=false;
      cesta:string='c:\prog\panaca\';	{TADY, konci lomitkem}
      vzmx:byte=31;		{sirka textury}
      vzmy:byte=63;		{vyska textury}
      xin:boolean=true;
      yin:boolean=true;
function grgetpixel(x,y:word):byte;external;
procedure putpixel(x,y:word;col:byte);
begin
if col>0 then grputpixel(x,y,col);
end;
procedure smaz(x,y:word);
begin
grputimage(x,y,x+sirik,y+vysik,@myspo^);
end;
procedure sipka(x,y:word);
begin
grgetimage(x,y,x+sirik,y+vysik,@myspo^);grputimagem(x,y,x+sirik,y+vysik,@mys^,sirik);
end;
procedure vlozdovzorku(pol,cis:byte);
var i:byte;
begin
if vzs>pol then for i:=vzs downto pol do vzorek[i+1]:=vzorek[i];vzorek[pol]:=cis;inc(vzs);
end;
procedure umazzevzorku(pol:byte);
var i:byte;
begin
if pol<vzs-1 then for i:=pol to vzs-1 do vzorek[i]:=vzorek[i+1];dec(vzs);
end;
procedure nactivzorek;
var i:byte;
begin
for i:=0 to vzmx do vzorek[i]:=grgetpixel(i,vzy);vzs:=vzmx;
end;
procedure zobrazcarku(x,y:word;typ:byte);
var i:byte;
begin
typ:=typ and 7;if typ<4 then for i:=1 to 4 do grputpixel(x+i,y+(typ-1)*5,hranice);
if typ in [4,5] then  for i:=1 to 4 do grputpixel(x+(typ-4)*5,y+i,hranice);
if typ>5 then for i:=6 to 9 do grputpixel(x+(typ-6)*5,y+i,hranice);
end;
procedure zobrazcislici(x,y:word;cisl:byte);
begin
if cisl in[0,2,3,5,6,7,8,9]then zobrazcarku(x,y,1);if cisl in[2,3,4,5,6,8,9]then zobrazcarku(x,y,2);if cisl in [0,2,3,5,6,8,9]
then zobrazcarku(x,y,3);if cisl in [0,4,5,6,8,9] then zobrazcarku(x,y,4);if cisl in [0,1,2,3,4,7,8,9]
then zobrazcarku(x,y,5);if cisl in [0,2,6,8] then zobrazcarku(x,y,6);if cisl in [0,1,3,4,5,6,7,8,9] then zobrazcarku(x,y,7);
end;
procedure zobrazcislo(x,y:word;cis:word);
var i,zac:byte;
const rady:array[1..5] of word=(10000,1000,100,10,1);
begin
zac:=1;while (cis<rady[zac]) and (zac<5) do inc(zac);
for i:=zac to 5 do begin
	zobrazcislici(x+(i-1) shl 3,y,trunc(cis/rady[i]));cis:=cis-trunc(cis/rady[i])*rady[i];
end;
end;
procedure nactiikonu(jm:string);
begin
assign(f,jm);reset(f,1);grsetworkpage(3);blockread(f,a,32000,nr);
x1:=a[1];y1:=a[2];x2:=a[3];y2:=a[4];pos:=6;k:=x1;l:=y1;
repeat
	if a[pos]>$c0 then begin for i:=1 to a[pos]-$c0 do putpixel(k+i-1,l,a[pos+1]);
		inc(pos);k:=k+a[pos-1]-$c1;
	end else begin putpixel(k,l,a[pos]);end;
	inc(k);if k>x2 then begin k:=k-x2+x1-1;inc(l);end;
	inc(pos);
until pos>nr;
getmem(mys,4096);getmem(myspo,4096);
grgetimage(x1,y1,x2,y2,@mys^);grsetworkpage(0);grsetdisppage(0);
sirik:=x2-x1;vysik:=y2-y1;
close(f);
r.ax:=7;r.cx:=0;r.dx:=639;intr($33,r);r.ax:=8;r.cx:=0;r.dx:=239;intr($33,r);
r.ax:=3;intr($33,r);r.ax:=4;r.cx:=0;intr($33,r);
mx:=r.cx;my:=r.dx;smx:=mx;smy:=my;
sipka(mx,my);
end;
procedure nastavpal(od,po:byte);
begin
for i:=od*3+1 to po*3+3 do b^[i-od*3]:=pal[i-1];
r.ah:=16;r.al:=$12;r.es:=seg(b^);r.dx:=ofs(b^);r.bx:=od;r.cx:=po-od+1;intr($10,r);
end;
procedure nactipal(od,po:byte);
begin
r.ah:=16;r.al:=$17;r.es:=seg(b^);r.dx:=ofs(b^);r.bx:=od;r.cx:=po-od+1;intr($10,r);
for i:=od*3+1 to po*3+3 do pal[i-1]:=b^[i-od*3];
end;
procedure nactipaletu(jm:string);
begin
assign(f,jm);reset(f,1);blockread(f,pal,768,nr);nastavpal(0,255);
close(f);
end;
procedure ulozpaletu(jm:string);
begin
assign(f,jm);rewrite(f,1);blockwrite(f,pal,768,nr);close(f);
end;
procedure osyrgb;
begin
{for i:=40 to 103 do for j:=131 to 159 do grputpixel(i,j,panel);}
for i:=0 to 2 do for j:=40 to 103 do begin
	if j and 7=0 then for k:=0 to 4 do grputpixel(j,133+i*10+k,mrizka) else
	if j and 3=0 then for k:=1 to 3 do grputpixel(j,133+i*10+k,mrizka) else
	grputpixel(j,133+i*10+2,mrizka);
end;
end;
procedure ukazhranice(zp:byte);
begin
if x1>0 then for i:=y1 to y2 do grputpixel(x1-1,i,hranice*zp);
if x2<319 then for i:=y1 to y2 do grputpixel(x2+1,i,hranice*zp);
if y1>0 then for i:=x1 to x2 do grputpixel(i,y1-1,hranice*zp);
if y2<239 then for i:=x1 to x2 do grputpixel(i,y2+1,hranice*zp);
end;
procedure ukaz(jm:string);
begin
smaz(mx,my);
assign(f,jm);reset(f,1);blockread(f,a,5,nr);
x1:=a[1]+(a[5] and 1) shl 8;x2:=a[3]+(a[5] and 16) shl 4;y1:=a[2];y2:=a[4];
k:=x1;l:=y1;pos2:=5;ukazhranice(1);grsetdisppage(2);
repeat
seek(f,pos2);blockread(f,a,32768,nr);if nr=32768 then dec(nr,2);pos:=1;
repeat
	if a[pos]>$c0 then begin if a[pos+1]>0 then for i:=1 to a[pos]-$c0 do grputpixel(k+i-1,l,a[pos+1]);
		k:=k+a[pos]-$c1;inc(pos);inc(pos2);
	end else grputpixel(k,l,a[pos]);
	inc(k);if k>x2 then begin inc(l);k:=x1;end;
	inc(pos);inc(pos2);
until pos>nr;
until nr<32766;
sx1:=x1;sy1:=y1;sx2:=x2;sy2:=y2;j:=1;
for i:=y2 downto 0 do begin r.ax:=$4f07;r.bx:=0;r.cx:=0;r.dx:=i;intr($10,r);if j>i then j:=i;dec(i,j);inc(j);end;
grmoveimage(x1,y1,x2+1,y2+1,x1,y1,0,2);sipka(mx,my);grsetdisppage(0);
end;
procedure uloz(jm:string);
begin
assign(f,jm);rewrite(f,1);smaz(mx,my);
a[1]:=x1 and 255;a[3]:=x2 and 255;a[2]:=y1;a[4]:=y2;a[5]:=x1 shr 8+(x2 shr 8) shl 4;
blockwrite(f,a,5);k:=x1;l:=y1;
repeat
nr:=0;
repeat
	inc(nr);j:=grgetpixel(k,l);
	if (j<$c0) and (grgetpixel(k+1,l)<>j) then a[nr]:=j else begin
		mo:=0;repeat
			inc(mo);
		until (grgetpixel(k+mo,l)<>j) or (k+mo>x2) or (mo=63);
		a[nr]:=$c0+mo;inc(nr);a[nr]:=j;inc(k,mo-1);
	end;
	inc(k);if k>x2 then begin k:=x1;inc(l);end;
until (nr>32760) or (l>y2);
blockwrite(f,a,nr,nw);
until (l>y2) or (nw=0);
close(f);
end;

begin
if paramcount<2 then begin
	writeln('KRESCPS,  ALL RIGHTS RESERVED (c) by Mr.Old.');
	writeln('Usage:  KRESCPS.EXE picture.cps pallete.pal');
	writeln;writeln('Ovladani z klavesnice:');
	writeln('F1 ... F3     Tloustka cary');writeln('F4            Posunuje cely obrazek do aktualnich souradnic');
	writeln('F5            Uklada paletu');writeln('F6, F7        Oznacovani L&U rohu a R&B rohu');
	writeln('F8            Zobrazovat / nezobrazovat aktualni pozici kurzoru');
	writeln('F9            Vyplni plochu barvou (aspon se snazi)');writeln('F10           Exit bez ulozeni');
	writeln('X, Y          Vypnou (zapnou) urcitou souradnici');writeln('R             Zameni barvu za aktualni');
	writeln('S             Zkus stereogram');writeln('ESC           Exit s ulozenim obrazku');
	halt;
end;getmem(b,32768);pauza:=5;getmem(scr,sizeof(typscrid));
findfirst(paramstr(1),$2f,fs);if doserror<>0 then begin
	writeln('Error: Picture file "',paramstr(1),'" not found.');
	writeln('Zakladam novy soubor ...');novyobrazek:=true;
end;
findfirst(paramstr(2),$2f,fs);if doserror<>0 then begin
	writeln('Error: File with pallete "',paramstr(2),'" not found.');
	writeln('Zakladam novou paletu ...');novapaleta:=true;
end;
if (novyobrazek) or (novapaleta) then begin
	writeln('Press any key to continue ...');readkey;
end;
setxmode;cara:=true;zvet:=false;barva:=false;
if not novapaleta then nactipaletu(paramstr(2));
nactiikonu(cesta+'myska.icn');
if not novyobrazek then ukaz(paramstr(1));
if novyobrazek then begin
	x1:=0;sx1:=0;y1:=0;sy1:=0;x2:=319;sx2:=x2;y2:=239;sy2:=y2;
end;
if novapaleta then nactipal(0,255);
repeat
smx:=mx;smy:=my;r.ax:=3;intr($33,r);but2:=r.bx;r.cx:=r.cx shr 1;
	if ((r.cx<>mx) and (xin)) or ((r.dx<>my) and (yin)) then begin
	smaz(mx,my);if xin then mx:=r.cx;if yin then my:=r.dx;if (sour) and (not barva) then begin
		if (mx<230) or (my<200) then sipka(mx,my);
		for i:=250 to 319 do for j:=220 to 239 do grputpixel(i,j,panel);
		zobrazcislo(237,226,mx);zobrazcislo(277,226,my);
		if (mx<230) or (my<200) then smaz(mx,my);
	end;
	sipka(mx,my);
end;if pauza>0 then begin i:=0;dec(pauza);delay(60);but:=0;end;
if keypressed then c:=readkey else c:=#0;stcara:=cara;
but:=0;r.ax:=5;r.bx:=0;intr($33,r);if r.bx>0 then but:=1;
r.ax:=5;r.bx:=1;intr($33,r);if r.bx>0 then inc(but,2);r.ax:=5;r.bx:=2;intr($33,r);if r.bx>0 then inc(but,4);
if (not barva) and (((not zvet) and (cara)) or ((zvet) and (not cara))) then
	but:=(but and 6)+but2 and 1;
if (not barva) and (zvet) and (not cara) then but:=(but and 5)+but2 and 2;
if pauza>0 then but:=0;
if (but=1) and (not zvet) and (not barva) and (cara) then begin
	smaz(mx,my);
	for i:=1 to 3 do for k:=0 to tl-1 do for l:=0 to tl-1 do
		grputpixel(((4-i)*smx+i*mx) shr 2+k-tl shr 1,((4-i)*smy+i*my) shr 2+l-tl shr 1,ba);
	sipka(mx,my);but:=0;
end;
if (but=4) and (not barva) then begin
	smaz(mx,my);
	if sour then grmoveimage(250,220,319,240,250,220,1,0);
	grmoveimage(32,130,289,239,32,130,0,1);
	for i:=32 to 288 do grputpixel(i,130,mrizka);
	for i:=130 to 159 do for j:=0 to 1 do grputpixel(j*256+32,i,mrizka);
	for i:=33 to 287 do for j:=131 to 159 do grputpixel(i,j,panel);
	for i:=32 to 288 do for j:=160 to 224 do begin
		if (i and 7=0) or (j and 7=0) then grputpixel(i,j,mrizka) else
			grputpixel(i,j,(i-32) shr 3+((j-160) shr 3) shl 5);
	end;barva:=true;grputpixel(36+(ba and 31) shl 3,164+(ba shr 5) shl 3,ba xor 192);
	for i:=264 to 280 do for j:=136 to 153 do grputpixel(i,j,ba);
	for i:=263 to 281 do begin grputpixel(i,135,0);grputpixel(i,154,0);end;
	for i:=136 to 153 do begin grputpixel(263,i,0);grputpixel(281,i,0);end;
	osyrgb;zobrazcislo(202,138,ba);
	for i:=0 to 2 do for j:=132+i*10 to 138+i*10 do grputpixel(40+pal[ba*3+i],j,aktivni);
	sipka(mx,my);but:=0;
end;
if (but=2) and (barva) and ((mx<32) or (mx>288) or (my<160) or (my>224)) then begin
	smaz(mx,my);
	for l:=0 to 2 do for i:=132+l*10 to 138+l*10 do grputpixel(40+pal[ba*3+l],i,panel);
	for i:=200 to 250 do for j:=136 to 153 do grputpixel(i,j,panel);
	grputpixel(36+(ba and 31) shl 3,164+(ba shr 5) shl 3,ba);ba:=grgetpixel(mx,my);
	zobrazcislo(202,138,ba);
	grputpixel(36+(ba and 31) shl 3,164+(ba shr 5) shl 3,ba xor 192);
	for i:=264 to 280 do for j:=136 to 153 do grputpixel(i,j,ba);
	osyrgb;for i:=0 to 2 do for j:=132+i*10 to 138+i*10 do grputpixel(40+pal[ba*3+i],j,aktivni);
	sipka(mx,my);but:=0;
end;
if (but=1) and (barva) and (mx>32) and (my>160) and (mx<288) and (my<224) then begin
	smaz(mx,my);
	for l:=0 to 2 do for i:=132+l*10 to 138+l*10 do grputpixel(40+pal[ba*3+l],i,panel);
	for i:=200 to 250 do for j:=136 to 153 do grputpixel(i,j,panel);
	grputpixel(36+(ba and 31) shl 3,164+(ba shr 5) shl 3,ba);ba:=(mx-32) shr 3+((my-160) shr 3) shl 5;
	zobrazcislo(202,138,ba);
	grputpixel(36+(ba and 31) shl 3,164+(ba shr 5) shl 3,ba xor 192);
	for i:=264 to 280 do for j:=136 to 153 do grputpixel(i,j,ba);
	osyrgb;for i:=0 to 2 do for j:=132+i*10 to 138+i*10 do grputpixel(40+pal[ba*3+i],j,aktivni);
	sipka(mx,my);but:=0;
end;
if (but=1) and (barva) and ((mx<32) or (mx>288) or (my<130) or (my>224)) then begin
	smaz(mx,my);
	grmoveimage(32,130,289,239,32,130,1,0);barva:=false;pauza:=5;
	if sour then grmoveimage(250,220,319,240,250,220,0,1);
	sipka(mx,my);but:=0;pauza:=5;
end;
if (but=1) and (barva) and (mx>39) and (my>130) and (mx<104) and (my<160) then begin
	smaz(mx,my);l:=trunc((my-130)/10);
	for i:=132+l*10 to 138+l*10 do grputpixel(40+pal[ba*3+l],i,panel);
	pal[ba*3+l]:=mx-40;nastavpal(ba,ba);
	osyrgb;
	for i:=0 to 2 do for j:=132+i*10 to 138+i*10 do grputpixel(40+pal[ba*3+i],j,aktivni);
	sipka(mx,my);but:=0;
end;
if (but=1) and (not barva) and (not zvet) and (not cara) then begin
	smaz(mx,my);ssx:=mx;ssy:=my;
	for i:=mx to mx+15 do for j:=my to my+15 do zv[i-mx,j-my]:=grgetpixel(i,j);
	grmoveimage(0,0,130,129,0,0,0,1);for i:=0 to 16 do for j:=0 to 128 do grputpixel(i shl 3,j,mrizka);
	for i:=0 to 16 do for j:=0 to 128 do grputpixel(j,i shl 3,mrizka);
	for i:=0 to 15 do for j:=0 to 15 do for k:=i shl 3+1 to i shl 3+7 do
		for l:=j shl 3+1 to j shl 3+7 do grputpixel(k,l,zv[i,j]);
	sipka(mx,my);zvet:=true;grsetworkpage(0);pauza:=4;but:=0;
end;
if (but=1) and (not barva) and (zvet) and ((mx>127) or (my>127)) then begin
	smaz(mx,my);
	grmoveimage(0,0,130,129,0,0,1,0);
	for i:=ssx to ssx+15 do for j:=ssy to ssy+15 do grputpixel(i,j,zv[i-ssx,j-ssy]);
	sipka(mx,my);zvet:=false;pauza:=4;but:=0;
end;
if (but in [1,2]) and (not barva) and (zvet) and (mx<128) and (my<128) then begin
	smaz(mx,my);
	i:=mx shr 3;j:=my shr 3;if but=1 then zv[i,j]:=ba else zv[i,j]:=0;
	for k:=i shl 3+1 to i shl 3+7 do for l:=j shl 3+1 to j shl 3+7 do grputpixel(k,l,zv[i,j]);
	sipka(mx,my);but:=0;
end;
if (but=2) and (not zvet) and (not barva) then begin cara:=not cara;pauza:=2;end;
if c=#63 then ulozpaletu(paramstr(2));
if c in [#59,#60,#61] then tl:=ord(c)-58;
if (c=#62) and (not barva) and (not zvet) then begin
	smaz(mx,my);ukazhranice(0);sir:=x2-x1;vys:=y2-y1;grsetworkpage(2);grgetimage(sx1,sy1,sx2+1,sy2+1,@scr^);
	grsetworkpage(0);grputimage(mx,my,sx2-sx1+1+mx,sy2-sy1+1+my,@scr^);
	x2:=sir+mx;y2:=vys+my;x1:=mx;y1:=my;
	ukazhranice(1);sipka(mx,my);
end;
if c=#64 then begin
	smaz(mx,my);ukazhranice(0);x1:=mx;y1:=my;ukazhranice(1);sipka(mx,my);
end;
if c=#65 then begin
	smaz(mx,my);ukazhranice(0);x2:=mx;y2:=my;ukazhranice(1);sipka(mx,my);
end;
if c in [#68,#27] then if sour then c:=#66;
if c=#66 then begin
	smaz(mx,my);
	sour:=not sour;
	if sour then grmoveimage(250,220,319,240,250,220,0,1) else grmoveimage(250,220,319,240,250,220,1,0);
	sipka(mx,my);
end;
if (c=#67) and (not zvet) and (not barva) then begin
	smaz(mx,my);j:=grgetpixel(mx,my);
	k:=my;if my>0 then begin while (grgetpixel(mx,k-1)=j) and (k>0) do dec(k);end;
	while (grgetpixel(mx,k)=j) and (k<239) do begin
		i:=mx+1;if mx<319 then while (grgetpixel(i,k)=j) and (i<319) do begin grputpixel(i,k,ba);inc(i);end;
		i:=mx-1;if mx>0 then while (grgetpixel(i,k)=j) and (i>0) do begin grputpixel(i,k,ba);dec(i);end;
		grputpixel(mx,k,ba);inc(k);
	end;
	sipka(mx,my);
end;
if upcase(c)='X' then xin:=not xin;
if upcase(c)='Y' then yin:=not yin;
if (upcase(c)='R') and (not zvet) and (not barva) then begin
	smaz(mx,my);k:=grgetpixel(mx,my);for i:=x1 to x2 do for j:=y1 to y2 do if grgetpixel(i,j)=k then grputpixel(i,j,ba);
	sipka(mx,my);
end;
if (upcase(c)='S') and (not zvet) and (not barva) then begin
	smaz(mx,my);vzx:=0;vzy:=0;randomize;ukazhranice(0);k:=0;
	for i:=0 to vzmx do for j:=0 to 239 do grputpixel(i,j,0);
	for i:=0 to vzmx do for j:=0 to vzmy do grputpixel(i,j,random(8));
	for j:=0 to 239 do begin
	  nactivzorek;for i:=0 to vzs do grputpixel(i,j,vzorek[i]);
	  vzx:=0;
	  for i:=vzmx+1 to 319 do begin
		l:=k;
		k:=grgetpixel(i,j) and 7;if l<>k then begin
			if l<k then for i2:=1 to k-l do umazzevzorku(vzx);
			if l>k then for i2:=1 to l-k do vlozdovzorku(vzx,random(8));
		end;
		grputpixel(i,j,vzorek[vzx]);inc(vzx);if vzx>vzs then vzx:=0;
	  end;
		inc(vzy);if vzy>vzmy then vzy:=0;
	end;
	sipka(mx,my);
end;
if cara<>stcara then begin if not cara then begin sound(200);delay(10);nosound;delay(10);end;
	sound(200);delay(10);nosound;
end;
until (c=#68) or ((c=#27) and (not barva) and (not zvet) and (not sour));
if (c=#27) or (novyobrazek) then uloz(paramstr(1));
if novapaleta then ulozpaletu(paramstr(2));
grsetworkpage(1);for i:=0 to 320 do for j:=0 to 40 do grputpixel(i,j,0);
for i:=1 to 7 do grmoveimage(0,0,319,39,0,i*40,1,1);
j:=0;for i:=0 to y2 do begin r.ax:=$4f07;r.bx:=0;r.cx:=0;r.dx:=i;if j+i>y2 then j:=y2-i;inc(i,j);intr($10,r);inc(j);
end;
grclose;freemem(myspo,4096);freemem(mys,4096);freemem(scr,sizeof(typscrid));freemem(b,32768);
asm
	mov	ax,3
	int	10h
end;
writeln(x1,' ',y1,' ',x2,' ',y2);
end.