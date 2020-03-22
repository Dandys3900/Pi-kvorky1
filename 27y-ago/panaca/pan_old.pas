{ (c) 29.06.1994 by Mr.Old from Down Raisin, ver. 4.22, 17.09.1994 last upgrade  }
uses crt,dos,ctecka,memunit,voc,sbdsp;
{$L x1.obj}
{$S-}{$R-}
{$M 16384,0,419430}
{$L xgraf.obj}
procedure grsetdisppage(pg:byte);external;
procedure setxmode;external;
var c,ch:char;
    nr:word;
    man,stikon:byte;
    font:byte;
    volno:longint;
    ppsm,psm,sm,ssm:byte;
    manx,many:integer;
    ssc:boolean;
const prx:integer=0;
      pry:integer=0;
      ikopred:byte=1;
label znovu;
begin
setxmode;
setcbreak(false);directvideo:=true;checksnow:=false;checkbreak:=false;
otevripak('resource.pak');
inicializuj;
resetfm;initfm(1);
nactipalzpaku('MRNUMO.PAL');
nacticpszpaku('MRNUMO.CPS',0,0);
{animacezpaku('INTRO.ANM',10);}
nactipalzpaku('MYPALETE.PAL');
rychlezmiz(0,255);
nacticpszpaku('ROOM.CPS',0,0);zobrazinventar;
freemem(w,nr);
font:=nahrajfontzpaku('LITTLE.FON');
manx:=150;many:=120;sm:=2;nx:=manx;ny:=many;ch:=#0;
man:=novapostava('00MAN.WSA',manx,many,many);p[0].vych.kam:=1;
mistnost(0);zobrazinventar;setfont(0);
repeat
znovu:
ssc:=scenka;
if ikon<6 then stikon:=ikon;
if scenka then begin
	ikon:=6;pozadi(true);playznovu;ukazpage(true);goto znovu;
end;
if (not(scenka)) or (ikon<7) then ikon:=stikon;
if (not(cuchejplac(manx+prx,many+pry))) then begin
	prx:=0;pry:=0;
end;
inc(manx,prx);inc(many,pry);
zmenprepis(man,manx,many,many+50);
if (not(cuchejplac(manx+prx,many+pry))) then begin
	nx:=manx;ny:=many;prx:=0;pry:=0;
end;
if (manx+prx>307) or (manx+prx<4) or (many+pry<24) or (many+pry+rozmerypanacka.maxy>199) then begin
	dec(manx,prx);dec(many,pry);pry:=0;prx:=0;
end;
pozadi(true);
if cuchejkod(cismis,curmluv and 31,0,0,0,0) then begin
	case sm of
		1:zmenpostavu(man,'14MAN.WSA');
		2:zmenpostavu(man,'04MAN.WSA');
		3:zmenpostavu(man,'34MAN.WSA');
		4:zmenpostavu(man,'24MAN.WSA');
	end;
end;

if pouzij(1,0,0) then begin
	pistext(manx,many-20,'Se‘ral jsem jabko',17);zrusupl:=1;
end;
if cismis=3 then begin
 if pouzij(2,0,3) then begin
	pistext(manx,many-20,'Byl tam nˆjak˜ z mek,',21);
	pistext(manx,many-20,'Tak jsem ho vodem‡el.',21);zrusupl:=2;
	ukazscenku('PAREZ.WSA');
	zapisbitdostavu(32,0,1);
 end;
end;
if pouzij(2,1,255) then begin
	pistext(manx,many-20,'Str‡il jsi kl¡‡ do jabka',24);zrusupl:=2;
end;
if cismis=1 then begin
 if cuchejkod(1,1,1,1,0,0) then prevedvecdokapsy(3);
 if (cuchejkod(1,1,2,0,0,0)) or (cuchejkod(1,2,1,0,0,0)) then dodelejdialog;
 if cuchejkod(1,1,1,2,1,1) then nastavkod(1,0,0,0);
 if jemluvici(1) then playvoc('FROGS.VOC');
 if pouzij(0,0,1) then begin
	pistext(manx,many-20,'Vypla¨il jsi ft ka ...',22);
	ukazscenku('FTAK.WSA');
 end;
end;
if cismis=2 then begin
 if (pouzij(0,0,2)) then if (nactibitzestavu(32,1)=0) then begin
	pistext(manx,many-20,'Otev©u dve©e ...',16);
	zapisbitdostavu(32,1,1);
 end else if (nactibitzestavu(32,1)>0) then begin
	pistext(manx,many-20,'Zav©u dve©e ...',15);
	zapisbitdostavu(32,1,0);
 end;
end;
if (keypressed) then c:=readkey else c:=#0;
if (mx>40) and (my>=218) and (mx<86) and (but=1) and (curmluv=255) then begin
	restoregame('now.sav');
	manx:=mp[0].x;many:=mp[0].y;nx:=manx;ny:=many;prx:=0;pry:=0;ch:=#0;
	case mp[0].jm[1] of
		'0':sm:=2;'1':sm:=1;'2':sm:=4;'3':sm:=3;
	end;
end;
if (mx>10) and (my>=218) and (mx<38) and (but=1) and (curmluv=255) then savegame('now.sav');
if c='p' then begin
	port[$3c2]:=port[$3cc] xor 8;delay(10);
	port[$3c2]:=port[$3cc] xor 4;delay(10);
	port[$3c2]:=port[$3cc] xor 4;delay(10);
	port[$3c2]:=port[$3cc] xor 8;
end;
if ((prx=0) and (pry=0) and (ch<>#0)) or (ssm<>psm) then dodelej(man);
if (dodelal(man)) then begin
if (prx=0) and (pry=0) and (ch=#0) then case sm of
	2:zmenpostavu(man,'00MAN.WSA');
	1:zmenpostavu(man,'10MAN.WSA');
	3:zmenpostavu(man,'30MAN.WSA');
	4:zmenpostavu(man,'20MAN.WSA');
end;
if (ch=#80) and (sm=2) then begin
	zmenpostavu(man,'01MAN.WSA');pry:=rozmerypanacka.maxpry-1;prx:=0;
end;
if (ch in [#77,#73,#81]) and (sm=1) then begin
	zmenpostavu(man,'11MAN.WSA');prx:=rozmerypanacka.maxprx;pry:=trunc((ord(ch)-77)/4)*rozmerypanacka.maxpry shr 1;
	if ch<>#77 then dec(prx);
end;
if (ch in [#75,#71,#79]) and (sm=3) then begin
	zmenpostavu(man,'31MAN.WSA');prx:=-rozmerypanacka.maxprx;pry:=trunc((ord(ch)-75)/4)*rozmerypanacka.maxpry shr 1;
	if ch<>#75 then inc(prx);
end;
if (ch=#72) and (sm=4) then begin
	zmenpostavu(man,'21MAN.WSA');pry:=-rozmerypanacka.maxpry;prx:=0;
end;
if (ch in [#75,#71,#79]) and (sm=2) then begin
	zmenpostavu(man,'03MAN.WSA');prx:=0;sm:=3;pry:=0;
end;
if (ch in [#77,#73,#81]) and (sm=2) then begin
	zmenpostavu(man,'02MAN.WSA');prx:=0;sm:=1;pry:=0;
end;
if (ch=#80) and (sm=3) then begin
	zmenpostavu(man,'33MAN.WSA');pry:=0;sm:=2;prx:=0;
end;
if (ch=#80) and (sm=1) then begin 
	zmenpostavu(man,'12MAN.WSA');pry:=0;sm:=2;prx:=0;
end;
if (ch in [#77,#73,#81]) and (sm=4) then begin
	zmenpostavu(man,'22MAN.WSA');pry:=0;prx:=0;sm:=1;
end;
if (ch in [#75,#71,#79]) and (sm=4) then begin
	zmenpostavu(man,'23MAN.WSA');prx:=0;sm:=3;pry:=0;
end;
if (ch=#72) and (sm=3) then begin
	zmenpostavu(man,'32MAN.WSA');pry:=0;sm:=4;prx:=0;
end;
if (ch=#72) and (sm=1) then begin
	zmenpostavu(man,'13MAN.WSA');pry:=0;sm:=4;prx:=0;
end;
end;
i:=0;
r.ax:=6;r.bx:=1;intr($33,r);if r.bx>0 then inc(i,2);
r.ax:=6;r.bx:=2;intr($33,r);if r.bx>0 then inc(i,4);
r.bx:=i;
if (r.bx=2) then begin
	inc(ikon);if ikon=pocikon-2 then ikon:=1;
end;
if (r.bx=4) then begin
	if ikon<>2 then begin ikopred:=ikon;ikon:=2;end else ikon:=ikopred;
end;
if c=#27 then curmluv:=255;
if c=#32 then begin grsetdisppage(2);readkey;grsetdisppage(ukazovadlo);end;
if (but=1) and (mx>136) and (mx<165) and (my>=218) and (curmluv=255) then c:=#27;
ssm:=psm;
psm:=cuchejsmer(manx,many,nx,ny);ppsm:=psm;
if psm in [71,75,79] then ppsm:=3;if psm in [73,77,81] then ppsm:=1;
if psm=72 then ppsm:=4;if psm=80 then ppsm:=2;
if (abs(ppsm-sm)=2) and (ppsm>0) then begin
	inc(ppsm);if ppsm>4 then dec(ppsm,4);psm:=0;
end else ppsm:=0;
if (ppsm>0) and (psm=0) then case ppsm of
	1:psm:=77;2:psm:=80;3:psm:=75;4:psm:=72;
end;
if psm=0 then begin nx:=manx;ny:=many;prx:=0;pry:=0;ch:=#0;end;
i:=cuchejvychod(manx,many);
if i<255 then begin
	prx:=0;pry:=0;manx:=p[i].vych.obl[5];many:=p[i].vych.obl[6];if p[i].vych.obl[4] and 128<>0 then inc(manx,256);
	zmenprepis(man,manx,many,many+50);nx:=manx;ny:=many;
	mistnost(i);dodelej(man);goto znovu;
end;
ch:=chr(psm);
ukazpage(true);
playznovu;
volno:=memavail;
until c=#27;
stopcmf;resetfm;
zmiz(0,255);
odinicializuj;
asm
	mov	ax,3
	int	10h
end;
writeln(volno,'    ',memavail);
end.