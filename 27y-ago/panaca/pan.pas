{ (c) 29.06.1994 by Mr.Old from Down Raisin, ver. 4.24, 17.02.1995 last upgrade  }
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
    name:string;
const prx:integer=0;
      pry:integer=0;
      ikopred:byte=1;
label znovu;
begin
setcbreak(false);directvideo:=true;checksnow:=false;checkbreak:=false;
otevripak('RES.PAK');
inicializuj;
font:=nahrajfontzpaku('LITTLE.FON');setfont(font);
resetfm;initfm(1);
	{nactipalzpaku('MRNUMO.PAL');
	nacticpszpaku('MRNUMO.CPS',0,0);
	animacezpaku('INTRO.ANM',10);}
nactipalzpaku('MYPALETE.PAL');
{rychlezmiz(0,255);}
animacezpaku('INTRO.ANM');
nacticpszpaku('RMENU.CPS',0,0);
manx:=150;many:=80;sm:=2;nx:=manx;ny:=many;ch:=#0;
man:=novapostava('00MAN.WSA',manx,many,many);p[0].vych.kam:=1;
zobrazinventar;mistnost(0);
repeat
znovu:
ssc:=scenka;
if ikon<6 then stikon:=ikon;
if scenka then begin
	ikon:=6;pozadi(true);playznovu;ukazpage(true);goto znovu;
end;
if (not(scenka)) or (ikon<7) then ikon:=stikon;
if (not(cuchejplac(manx+prx,many+pry))) then begin prx:=0;pry:=0;end;
inc(manx,prx);inc(many,pry);
zmenprepis(man,manx,many,many+50);
if (manx+prx>307) or (manx+prx<4) or (many+pry<20) or (many+pry+rozmerypanacka.maxy>199) then begin
	dec(manx,prx);dec(many,pry);pry:=0;prx:=0;
end;
if (prx=0) and (pry=0) then manstojinafleku:=true else manstojinafleku:=false;
pozadi(true);
if cuchejkod(cismis,curmluv and 31,0,0,0,0) then begin
	case sm of
		1:zmenpostavu(man,'14MAN.WSA');
		2:zmenpostavu(man,'04MAN.WSA');
		3:zmenpostavu(man,'34MAN.WSA');
		4:zmenpostavu(man,'24MAN.WSA');
	end;
end;

case cismis of
  1:begin
	if cuchejkod(1{m¡stnost},1{osoba},{kod:}2,0,0,0) then dodelejdialog;
	if jemluvici(1) then playvoc('SPARK.VOC');
	if cuchejkod(1,1,1,1,0,0) then nastavkod(0,0,0,0);
	if ikon=4 then nechtzastavivesmeru(1);
  end;
  2:begin
  end;
  3:begin
	if pouzij(1,0,3) then pistextman('Co to dˆl ¨?');
  end;
end;
if cismis<>3 then if pouzij(1,0,0) then begin
	pistextman('Je¨tˆ se bude hodit.');zruspouzivani;
end;


{if pouzij(1,0,0) then begin
	pistextman('Pr vˆ ‘eru tohle jabko,');
	pistextman('asi mi bude zle...');
	zrusupl:=1;
end;

if cismis=3 then begin
 if pouzij(2,0,3) then begin
	pistextman('Byl tam nˆjak˜ z mek,');
	pistextman('Tak jsem ho vodem‡el.');zrusupl:=2;
	ukazscenku('PAREZ.WSA');
	zapisbitdostavu(32,0,1);
 end;
end;
if pouzij(2,1,255) then begin
	pistextman('Str‡il jsi kl¡‡ do jabka');zrusupl:=2;
end;
if cismis=1 then begin
 if cuchejkod(1,1,1,1,0,0) then prevedvecdokapsy(3);
 if (cuchejkod(1,1,2,0,0,0)) or (cuchejkod(1,2,1,0,0,0)) then dodelejdialog;
 if cuchejkod(1,1,1,2,1,1) then nastavkod(1,0,0,0);
 if jemluvici(1) then playvoc('FROGS.VOC');
 if pouzij(0,0,1) then begin
	pistextman('Vypla¨il jsi ft ka ...');
	ukazscenku('FTAK.WSA');
 end;
end;
if cismis=2 then begin
 if (pouzij(0,0,2)) then if (nactibitzestavu(32,1)=0) then begin
	pistextman('Otev©u dve©e ...');
	zapisbitdostavu(32,1,1);
 end else if (nactibitzestavu(32,1)>0) then begin
	pistextman('Zav©u dve©e ...');
	zapisbitdostavu(32,1,0);
 end;
end;}

if (keypressed) then c:=readkey else c:=#0;
if (mx>40) and (my>=218) and (mx<86) and (but=1) and (curmluv=255) then begin
	i:=vybersavegame(false);name:='PANACA.SG'+chr(48+i);
	if i>0 then begin restoregame(name);
	manx:=mp[0].x;many:=mp[0].y;nx:=manx;ny:=many;prx:=0;pry:=0;ch:=#0;klb:=false;
	case mp[0].jm[1] of
		'0':sm:=2;'1':sm:=1;'2':sm:=4;'3':sm:=3;
	end;end;
end;
if (mx>10) and (my>=218) and (mx<38) and (but=1) and (curmluv=255) then begin
	i:=vybersavegame(true);name:='PANACA.SG'+chr(48+i);
	if i>0 then savegame(name);
end;
if c='p' then begin
	port[$3c2]:=port[$3cc] xor 8;delay(10);
	port[$3c2]:=port[$3cc] xor 4;delay(10);
	port[$3c2]:=port[$3cc] xor 4;delay(10);
	port[$3c2]:=port[$3cc] xor 8;
end;
if ((prx=0) and (pry=0) and (ch<>#0)) or (ssm<>psm) then dodelej(man);
if (dodelal(man)) then begin
if (prx=0) and (pry=0) and (ch=#0) then begin
  case sm of
	2:zmenpostavu(man,'00MAN.WSA');
	1:zmenpostavu(man,'10MAN.WSA');
	3:zmenpostavu(man,'30MAN.WSA');
	4:zmenpostavu(man,'20MAN.WSA');
  end
end;
if (ch=#80) and (sm=2) then begin
	zmenpostavu(man,'01MAN.WSA');pry:=rozmerypanacka.maxpry;prx:=0;
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
	inc(ikon);if ikon=pocikon-2 then begin
		ikon:=1;use[1]:=mam[0];use[2]:=0;use[3]:=0;klb:=false;
	end;
end;
if (r.bx=4) then begin
	if ikon<>2 then begin ikopred:=ikon;ikon:=2;end else ikon:=ikopred;
end;
if c=#27 then curmluv:=255;
{if c=#32 then begin grsetdisppage(2);readkey;grsetdisppage(ukazovadlo);end;}
if (but=1) and (mx>136) and (mx<165) and (my>=218) and (curmluv=255) then c:=#27;
ssm:=psm;
psm:=cuchejsmer(manx,many,nx,ny);ppsm:=psm;
if smerzastaveni>0 then begin
 case smerzastaveni of
   1:i:=77;2:i:=80;3:i:=75;4:i:=72;end;
 if (smerzastaveni<>sm) and (psm=0) then psm:=i;
 if smerzastaveni=sm then if psm=0 then smerzastaveni:=0;
end;
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
	prx:=0;pry:=0;pozadi(false);ukazpage(false);
	manx:=p[i].vych.obl[5]+(p[i].vych.obl[4] and 128) shl 1;many:=p[i].vych.obl[6];
	nx:=manx;ny:=many;upravbudoucisouradnice;manx:=nx;many:=ny-vysikon;ny:=many;
	zmenprepis(man,manx,many,many+50);mistnost(i);klb:=false;
	dodelej(man);goto znovu;
end;
{if (chr(psm)<>ch) and (ppsm=sm) then sm:=4+sm;}
ch:=chr(psm);
ukazpage(true);
playznovu;
volno:=memavail;
until c=#27;
stopcmf;
zmiz(0,255);
odinicializuj;
asm
	mov	ax,3
	int	10h
end;
writeln(volno,'    ',memavail);
end.