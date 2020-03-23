uses comokno,crt,dos;
type ptyp=^ttyp;
     ttyp=record
	p:array[1..64] of byte;
	typ:byte;
	x,y,a:word;
	pr,po:ptyp;
     end;
     psoub=^tsoub;
     tsoub=array[1..64000] of byte;
var f:file;
    i,j,volno,frames,nr,akt,speed,x,y:word;
    name:string;
    c:char;
    func:boolean;
    tab:array[1..999] of ptyp;
    pom:ptyp;
    fil:psoub;
    s,ss:string;
const
 zmeny:boolean=false;
 novysoubor:boolean=false;
 idnic=255;
 idanim=1;
 idobr=2;
 idtext=3;
 idvoc=4;
 idcmf=5;
 hlmenu:array[1..6] of string=('Editace','Po‡et sn¡mk–','Rychlost animace','Anal˜za','Ulo‘ aktu ln¡ stav','Konec');
 vybhl:word=1;
 typy:array[1..5] of string=
	('Animace       [.WSA]','Obr zek       [.CPS]','Text¡k','Zvu‡ek        [.VOC]','Hudba         [.CMF]');

procedure chyba(st1,st2,st3:string);forward;
procedure cls;
begin
setcolor(11,1);fillchar(s,54,' ');s[0]:=#53;
for i:=8 to 15 do writexy(14,i,s);
end;
procedure zobrazvolnoupamet;
var s:string;
begin
setcolor(15,5);str(volno,s);s:=s+' blok– voln˜ch';writexy(68-length(s) shr 1,21,s);
setcolor(0,3);if zmeny then writexy(76,1,'(*)') else writexy(76,1,'( )');
end;
procedure zobrazinformace;
var s:string;
begin
setcolor(15,5);str(frames:5,s);s:='Po‡et sn¡mk–: '+s;writexy(31,21,s);
str(speed:5,s);s:='Rychlost ANM: '+s;writexy(31,22,s);
end;
procedure uloz;
begin
reset(f,1);tmpwindow('Ulo‘en¡');setcolor(0,7);writexy(32,12,'Ukl d m dat¡‡ka...');
fil^[1]:=lo(frames);fil^[2]:=hi(frames);fil^[3]:=speed;akt:=4;i:=0;
repeat
	inc(i);fil^[akt]:=tab[i]^.typ;inc(akt);case tab[i]^.typ of
		idanim,idobr,idvoc,idcmf:begin
			for j:=1 to 8 do fil^[akt+j-1]:=tab[i]^.p[j];inc(akt,8);
			fil^[akt]:=lo(tab[i]^.a);fil^[akt+1]:=hi(tab[i]^.a);inc(akt,2);
		end;
		idtext:begin
			for j:=0 to tab[i]^.p[1] do fil^[akt+j]:=tab[i]^.p[j+1];inc(akt,tab[i]^.p[1]+1);
			fil^[akt]:=lo(tab[i]^.x);fil^[akt+1]:=hi(tab[i]^.x);inc(akt,2);
			fil^[akt]:=lo(tab[i]^.y);fil^[akt+1]:=hi(tab[i]^.y);inc(akt,2);
			fil^[akt]:=lo(tab[i]^.a);fil^[akt+1]:=hi(tab[i]^.a);inc(akt,2);
		end;
	end;
until tab[i]^.typ=idnic;
for i:=1 to akt-1 do fil^[i]:=fil^[i] xor $dc;delay(20);
blockwrite(f,fil^,akt-1,nr);close(f);if akt-1<>nr then begin
	chyba('','     Chyba z pisu !','');closemode;halt;
end;closewindow;zmeny:=false;zobrazvolnoupamet;
end;
function vybertyp(puv:byte):byte;
var i:byte;
begin
setcolor(14,4);openwindow(20,8,50,15,true,true,true,0,'Vyber typ');
deleteitems;for i:=1 to 5 do additem(typy[i]);setmenucolor(14,4);setmenucursor(4,3);
additem('Zru¨it akci');
repeat i:=byte(menu(22,9,27,6,puv)) until i in [0,1,2,3,4,5,6];
case i of
 0,6:vybertyp:=idnic;
 1:vybertyp:=idanim;
 2:vybertyp:=idobr;
 3:vybertyp:=idtext;
 4:vybertyp:=idvoc;
 5:vybertyp:=idcmf;
end;closewindow;
end;
procedure prohod(k1,k2:word);
var k3:word;
begin
pom:=tab[k1];tab[k1]:=tab[k2];tab[k2]:=pom;
if k1=x then begin
	k3:=x;x:=k2;k2:=k3;
end;
if k2=x then begin
	k3:=x;x:=k1;k1:=k3;
end;
if x>999-volno then x:=999-volno;
end;
procedure serad;
var i,j,k:word;
begin
tmpwindow('žazen¡');
writexy(35,11,'O‡uch v m...');
k:=999;for i:=1 to 999 do if tab[i]^.typ=idnic then begin k:=i-1;i:=999;end;
if k>1 then begin
 writexy(37,13,'ž d¡m...');
 for i:=k downto 2 do for j:=1 to i-1 do begin
  if (tab[j]^.typ=idnic) and (tab[i]^.typ<>idnic) then prohod(i,j);
  if (tab[j]^.a>tab[i]^.a) then prohod(i,j);
  if (tab[j]^.a=tab[i]^.a) and (not(tab[j]^.typ in [idobr,idcmf])) and (tab[i]^.typ in [idobr,idcmf]) then prohod(i,j);
 end;
end;
closewindow;
end;
function udelejstring(cis:word):string;
var s:string;
    i:byte;
begin
s:='';for i:=1 to tab[cis]^.p[1] do s:=s+chr(tab[cis]^.p[1+i]);
s[0]:=chr(tab[cis]^.p[1]);udelejstring:=s;
end;
function udelejjmeno(cis:word):string;
var s:string;
    i:byte;
begin
s:='';for i:=1 to 8 do s:=s+chr(tab[cis]^.p[i]);s[0]:=#8;udelejjmeno:=s;
end;
const sour:array[1..8,1..3] of byte=((15,9,4),(47,9,9),(15,11,14),(15,13,5),(15,15,4),(31,15,4),(53,15,3),(65,15,3));
procedure zobraz(x,y:word);
begin
setcolor(11,1);writexy(15,9,'Typ:');setcolor(11,0);writexy(20,9,'                       ');
if tab[x]^.typ=idtext then setcolor(7,1) else setcolor(11,1);
writexy(15,11,'Jm‚no souboru:');setcolor(11,0);writexy(31,11,'            ');
if tab[x]^.typ=idtext then setcolor(11,1) else setcolor(7,1);
writexy(15,13,'Text:');writexy(15,15,' X: ');writexy(31,15,' Y: ');
setcolor(11,0);writexy(20,13,'                                               ');
writexy(20,15,'       ');writexy(36,15,'       ');
setcolor(11,1);writexy(47,9,'Aktivace:');setcolor(1,0);writexy(58,9,'         ');
setcolor(11,0);if tab[x]^.typ<>idnic then writexy(22,9,typy[tab[x]^.typ]);str(tab[x]^.a:5,s);
writexy(60,9,s);str(x:3,s);s:=s+'. blok';setcolor(10,1);writexy(56,15,s);
writexy(54,15,' ');writexy(66,15,' ');
if x>1 then writexy(54,15,'');if tab[x+1]^.typ<>idnic then writexy(66,15,'');
setcolor(11,0);
if tab[x]^.typ=idtext then begin
	writexy(21,13,udelejstring(x));str(tab[x]^.x:3,s);writexy(22,15,s);
	str(tab[x]^.y:3,s);writexy(38,15,s);
end else begin
	writexy(33,11,udelejjmeno(x));setcolor(8,0);writexy(40,15,'0');writexy(24,15,'0');
end;
setcolor(14,3);setcolorxy(sour[y,1],sour[y,2],sour[y,3]);
end;
procedure rozmapuj;
var i,pan,pob,pcls,pte,pvo,pcm:word;
    s,s2:string;
begin
volno:=0;pan:=0;pob:=0;pcls:=0;pte:=0;pvo:=0;pcm:=0;
setcolor(0,7);openwindow(17,5,64,20,true,true,true,1,'Anal˜za');
for i:=1 to 999 do case tab[i]^.typ of
 idnic:inc(volno);
 idanim:inc(pan);
 idobr:inc(pob);
 idtext:inc(pte);
 idvoc:inc(pvo);
 idcmf:inc(pcm);
end;
s2:=' kousk–.';str(pan:5,s);s:='Animac¡ je  '+s+s2;writexy(28,8,s);
str(pob:5,s);s:='Obr zk– je  '+s+s2;writexy(28,10,s);str(pte:5,s);s:='Text¡k– je  '+s+s2;writexy(28,12,s);
str(pvo:5,s);s:='Zvuk– je    '+s+s2;writexy(28,14,s);str(pcm:5,s);s:='Hudbinek je '+s+s2;writexy(28,16,s);
setmenucursor(0,3);zobrazvolnoupamet;vyzadejpotvrzeni(37,18);closewindow;zobrazvolnoupamet;
end;
procedure chyba(st1,st2,st3:string);
begin
setcolor(15,4);openwindow(24,13,55,21,true,true,true,1,'Chyba');
writexy(28,15,st1);writexy(28,16,st2);writexy(28,17,st3);
setmenucursor(0,7);vyzadejpotvrzeni(37,19);closewindow
end;


begin
openwindow(78,25,78,25,false,false,false,0,'');frames:=1;speed:=0;
for i:=1 to 80 do for j:=1 to 25 do screen[j,i]:=(screen[j,i] or $0e00) and $feff;
setcolor(11,1);openwindow(25,9,56,16,true,true,true,1,'Welcome');
writexy(30,12,'AŸ ‘ije nov˜ produkt...');setmenucursor(14,3);
vyzadejpotvrzeni(37,14);closewindow;
if paramcount<1 then begin
 chyba('     Chyb¡ parametr!',' Sta‡¡ udat pouze jm‚no','      bez p©¡pony.');
 closemode;halt;
end;
name:=paramstr(1);if pos('.',name)=0 then name:=name+'.ANM';
for i:=1 to length(name) do name[i]:=upcase(name[i]);
{$I-}
assign(f,name);reset(f,1);
if (doserror<>0) or (ioresult<>0) or (filesize(f)<12) then begin
 chyba('Zadan˜ soubor neexistuje',' S Va¨¡m dovolen¡m bych',' se pokusil ho vytvo©it');
 rewrite(f,1);novysoubor:=true;
 if (doserror<>0) or (ioresult<>0) then begin
  chyba('  Zadan˜ soubor nelze','    za nic na svˆtˆ','       otev©¡t!');closemode;halt;
 end;
end;
{$I+}
setcolor(11,1);openwindow(10,6,71,17,true,true,true,1,'Editace ANM');
setcolor(15,5);openwindow(2,20,22,22,true,true,true,0,'Soubor');s:=name;
openwindow(30,20,50,23,true,true,true,0,'Informace');
if length(s)>19 then s:=copy(s,length(s)-18,19);writexy(12-length(s) shr 1,21,s);
openwindow(58,20,78,22,true,true,true,0,'PamˆŸ');zobrazvolnoupamet;zobrazinformace;
setcolor(0,3);writexy(1,1,'  (c) Edit ANM  by Mr.Old,   ver. 1.01,  All Rights Reserved                    ');
new(fil);tmpwindow('Inicializace');volno:=0;
writexy(31,12,'Alokuji tabulku...');
for i:=1 to 999 do begin
	new(tab[i]);if i>1 then tab[i]^.pr:=tab[i-1] else tab[i]^.pr:=nil;
	if i<999 then tab[i]^.po:=tab[i+1] else tab[i]^.po:=nil;
	tab[i]^.typ:=idnic;tab[i]^.a:=1;inc(volno);zobrazvolnoupamet;
end;
if not novysoubor then begin
 setcolor(0,7);writexy(30,12,'A na‡¡t m dat¡‡ka...');
 blockread(f,fil^,64000,nr);close(f);i:=0;akt:=4;for j:=1 to nr do fil^[j]:=fil^[j] xor $dc;
 frames:=fil^[1]+fil^[2] shl 8;speed:=fil^[3];zobrazinformace;
 if fil^[nr]<idnic then begin
  chyba('   Neo‡ek van˜ znak !','       Kon‡¡m....','');closemode;halt;
 end;
 repeat
  inc(i);tab[i]^.typ:=fil^[akt];case fil^[akt] of
	idanim:begin
		for j:=1 to 8 do tab[i]^.p[j]:=fil^[akt+j];inc(akt,9);dec(volno);
		tab[i]^.a:=fil^[akt]+fil^[akt+1] shl 8;inc(akt,2);
	end;
	idobr:begin
		for j:=1 to 8 do tab[i]^.p[j]:=fil^[akt+j];inc(akt,9);dec(volno);
		tab[i]^.a:=fil^[akt]+fil^[akt+1] shl 8;inc(akt,2);
	end;
	idtext:begin
		tab[i]^.p[1]:=fil^[akt+1];inc(akt);
		for j:=1 to tab[i]^.p[1] do tab[i]^.p[j+1]:=fil^[akt+j];inc(akt,tab[i]^.p[1]+1);
		tab[i]^.x:=fil^[akt]+fil^[akt+1] shl 8;inc(akt,2);dec(volno);
		tab[i]^.y:=fil^[akt]+fil^[akt+1] shl 8;inc(akt,2);
		tab[i]^.a:=fil^[akt]+fil^[akt+1] shl 8;inc(akt,2);
	end;
	idvoc:begin
		for j:=1 to 8 do tab[i]^.p[j]:=fil^[akt+j];inc(akt,9);dec(volno);
		tab[i]^.a:=fil^[akt]+fil^[akt+1] shl 8;inc(akt,2);
	end;
	idcmf:begin
		for j:=1 to 8 do tab[i]^.p[j]:=fil^[akt+j];inc(akt,9);dec(volno);
		tab[i]^.a:=fil^[akt]+fil^[akt+1] shl 8;inc(akt,2);
	end;
  end;delay(5);zobrazvolnoupamet;
 until tab[i]^.typ=idnic;rozmapuj;delay(100);
end;
closewindow;repeat
zobrazvolnoupamet;zobrazinformace;
deleteitems;setcolor(11,1);writexy(15,8,'Vyber pr vˆ jednu polo‘ku:');
for i:=1 to 6 do additem(hlmenu[i]);if vybhl=0 then vybhl:=6;
setmenucolor(11,1);setmenucursor(0,3);vybhl:=menu(15,10,52,6,vybhl);
if hi(vybhl)=10 then vybhl:=6;
if (hi(vybhl)=2) and (volno<999) then uloz;
if vybhl=4 then begin delay(80);rozmapuj;end;
if vybhl=2 then begin
	setcolor(0,7);openwindow(4,10,76,15,true,true,true,1,'Po‡et sn¡mk–');
	writexy(9,12,'Zadej po‡et sn¡mk– animace (max. 65535):');
	str(frames,s);ss:=s;
	repeat
	  i:=0;setcolor(0,3);if readxy(9,13,s,63) then val(s,frames,i);if i<>0 then chyba('',' To nen¡ ‡¡slo, parde !','')
	until (i=0) and (frames>0);
	for i:=1 to 999 do begin
		if tab[i]^.typ<>idnic then if tab[i]^.a>frames then tab[i]^.a:=frames;
	end;
	closewindow;if ss<>s then zmeny:=true;zobrazinformace
end;
if vybhl=3 then begin
	setcolor(0,7);openwindow(4,10,76,15,true,true,true,1,'Rychlost animac¡');
	writexy(9,12,'Zadej pauzu v [ms] mezi dvˆma sn¡mky (max. 255):');
	str(speed,s);ss:=s;
	repeat
	  i:=0;setcolor(0,3);if readxy(9,13,s,63) then val(s,speed,i);if i<>0 then chyba('',' To nen¡ ‡¡slo, padre !','')
	until i=0;
	closewindow;if s<>ss then zmeny:=true;zobrazinformace
end;
if vybhl=1 then begin
	cls;x:=1;y:=1;if (not novysoubor) or (volno<999) then zobraz(x,y);
	setcolor(11,1);writexy(15,7,'[þ]');
	repeat
	  c:=#0;if (novysoubor) and (volno=999) then begin c:=#82;func:=true end;
	  if keypressed then begin c:=readkey;if c=#0 then begin func:=true;c:=readkey end else func:=false;end else begin
		testmouse;if mtt<>0 then c:=#$ff;
	  end;
	  if mtt=1 then begin
		for i:=1 to 8 do if sour[i,2]=my then if (mx>=sour[i,1]) and (mx<sour[i,1]+sour[i,3]) then if i<7 then begin
			j:=y;y:=i;if i=j then c:=#13;
			if tab[x]^.typ=idtext then begin
				if y=3 then y:=j;
			end else if y in [4,5,6] then y:=j;
		end else begin c:=chr(73+(i-7) shl 3);func:=true;end;
		if (my=7) and (mx=16) then c:=#27;delay(30);
	  end;
	  if (func) and (c=#15) then c:=#75;if (not func) and (c=#9) then begin func:=true;c:=#77;end;
	  if func then begin
		if c in[#80,#77] then begin
			inc(y);if tab[x]^.typ=idtext then if y=3 then inc(y) else
				if y>6 then y:=1;
			if tab[x]^.typ<>idtext then if y>3 then y:=1;
		end;
		if c in [#72,#75] then begin
			dec(y);if tab[x]^.typ=idtext then if y=3 then y:=2 else
				if y=0 then y:=6;
			if tab[x]^.typ<>idtext then if y=0 then y:=3;
		end;
		if c=#73 then begin
			if x>1 then dec(x);
			if (tab[x+1]^.typ=idtext) and (tab[x]^.typ<>idtext) then begin
				if y in [4,5,6] then y:=3;
			end;
			if (tab[x+1]^.typ<>idtext) and (tab[x]^.typ=idtext) then begin
				if y=3 then y:=4;
			end;
		end;
		if c=#81 then begin
			if (x<999) and (tab[x+1]^.typ<>idnic) then inc(x);
			if (tab[x-1]^.typ=idtext) and (tab[x]^.typ<>idtext) then begin
				if y in [4,5,6] then y:=3;
			end;
			if (tab[x-1]^.typ<>idtext) and (tab[x]^.typ=idtext) then begin
				if y=3 then y:=4;
			end;
		end;
		if c=#82 then begin
			i:=1;while tab[i]^.typ<>idnic do inc(i);
			j:=vybertyp(1);if j<>idnic then begin
				tab[i]^.typ:=j;zmeny:=true;dec(volno);if j=idtext then begin
					tab[i]^.p[1]:=0;tab[i]^.x:=0;tab[i]^.y:=0
				end else begin
					for j:=1 to 8 do tab[i]^.p[j]:=32;
				end;tab[i]^.a:=1;
				zobrazvolnoupamet;x:=i;y:=1;serad;
			end;
		end;
		if (c=#83) and (tab[2]^.typ<>idnic) and (volno<998) then begin
			i:=999-volno;prohod(i,x);
			tab[x]^.a:=1;tab[x]^.typ:=idnic;if x>1 then dec(x);y:=1;inc(volno);zmeny:=true;zobrazvolnoupamet;y:=1;serad;
		end;
	  end;
	  if c=#13 then begin
		case y of
		  1:begin
			i:=tab[x]^.typ;j:=vybertyp(i);if (j<>i) and (j<>idnic) then begin
				tab[x]^.typ:=j;y:=1;zmeny:=true;if j=idtext then begin
					tab[x]^.p[1]:=0;tab[x]^.x:=0;tab[x]^.y:=0
				end else begin
					for i:=1 to 8 do tab[x]^.p[i]:=32
				end;zobrazvolnoupamet;zobrazinformace;
			end;
		  end;
		  2:begin
			str(tab[x]^.a,s);ss:=s;
			repeat
			  i:=0;setcolor(14,4);if readxy(60,9,s,5) then val(s,tab[x]^.a,i);
			  if i<>0 then chyba('',' To nen¡ ‡¡slo, padre !','');
			  if (i=0) and (tab[x]^.a>frames) then begin
				chyba('   Tolik sn¡mk– nem ¨','    nadefinovan˜ch !','');tab[x]^.a:=frames;
			  end;
			until (i=0) and (tab[x]^.a>0);if ss<>s then zmeny:=true;serad;
		  end;
		  5:begin
			str(tab[x]^.x,s);ss:=s;
			repeat
			  i:=0;setcolor(14,4);if readxy(22,15,s,3) then val(s,tab[x]^.x,i);
			  if i<>0 then chyba('',' To nen¡ ‡¡slo, padre !','');
			until i=0;serad;if ss<>s then zmeny:=true;
		  end;
		  6:begin
			str(tab[x]^.y,s);ss:=s;
			repeat
			  i:=0;setcolor(14,4);if readxy(38,15,s,3) then val(s,tab[x]^.y,i);
			  if i<>0 then chyba('',' To nen¡ ‡¡slo, srabe !','');
			until i=0;serad;if ss<>s then zmeny:=true;
		  end;
		  3:begin
			setcolor(14,4);s:=udelejjmeno(x);ss:=s;readxy(33,11,s,8);
			s:=copy(s+'        ',1,8);for i:=1 to 8 do tab[x]^.p[i]:=ord(upcase(s[i]));
			if ss<>s then zmeny:=true;
		  end;
		  4:begin
			setcolor(14,4);s:=udelejstring(x);ss:=s;readxy(21,13,s,45);
			tab[x]^.p[1]:=length(s);for i:=1 to length(s) do tab[x]^.p[i+1]:=ord(s[i]);
			if ss<>s then zmeny:=true;
		  end;
		end;
	  end;
	  if (c=#60) and (volno<999) then uloz;
	  if (c<>#0) and (volno<999) then begin zobrazvolnoupamet;zobraz(x,y);end;delay(10);
	until c in [#27,#68];
	cls;setcolor(11,1);writexy(15,7,'ÍÍÍ');
end;
if (vybhl=5) and (volno<999) then uloz;
if (vybhl=6) and (zmeny) then begin
	setcolor(15,4);openwindow(16,10,65,17,true,true,true,1,'Editace');
	writexy(21,12,'Byly provedeny zmˆny od posledn¡ho savu.');
	deleteitems;setmenucolor(15,4);setmenucursor(0,7);
	additem('Ulo‘it');additem('Neukl dat! Proboha!');additem('Je¨tˆ jsem neskon‡il...');
	repeat j:=menu(21,13,40,3,1) until j in[0,1,2,3];
	if j=1 then uloz;if j in [0,3] then vybhl:=1;closewindow;
end;
until vybhl=6;
closemode;
dispose(fil);
end.