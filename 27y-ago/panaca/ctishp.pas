uses crt,dos,graph,svga256;
type typ=array[0..32767] of byte;
     typp=^typ;
     id=record
	nem:array[0..4] of byte;
	vych:record
		obl:array[0..6] of byte;
		kam:byte;
	end;
	scen:record
		jm:array[1..8] of char;
		obl:array[0..4] of byte;
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
		text:array[1..64] of char;
		obl:array[0..3] of integer;
	end;
	use:record
		obl:array[0..3] of integer;
		kam:array[0..1] of integer;
	end;
	mluv:record
		obl:array[0..3] of integer;
		kod:byte;
		jm:array[1..8] of char;
		prep:byte;
	end;
	dial:record
		del:byte;
		text:array[1..64] of char;
		kod:word;
	end;
     end;
var i,j:integer;
    f:file;
    a:typp;
    jm:array[1..8] of char;
    p:array[0..47] of id;
    pp:array[1..15] of byte;
    pr:array[0..4] of integer;
procedure preved;
begin
if (pr[4] and 1<>0) then pr[0]:=pr[0]+256;
if (pr[4] and 16<>0) then pr[2]:=pr[2]+256;
end;
procedure kontr;
var c:char;
begin
if wherey=25 then begin
	gotoxy(1,25);write('Zmackni Enter');
	repeat
		c:=readkey;
	until c in [#13,#27,#10,#32];
	clrscr;
end;
end;

begin
if paramcount<1 then halt;jm:='        ';
for i:=1 to 15 do pp[i]:=0;
assign(f,paramstr(1));reset(f,1);getmem(a,filesize(f));
blockread(f,a^,32768,i);for j:=0 to i do a^[j]:=a^[j] xor $c7;i:=0;
repeat
if a^[i]>15 then begin
	inc(i,2);a^[i]:=a^[i-2] shr 4;
end;
case a^[i] of
	1:begin
		inc(i);
		for j:=0 to 4 do p[pp[1]].nem[j]:=a^[i+j];
		inc(pp[1]);i:=i+5;
	  end;
	2:begin
		inc(i);
		for j:=0 to 6 do p[pp[2]].vych.obl[j]:=a^[i+j];i:=i+7;
		p[pp[2]].vych.kam:=a^[i];inc(i);
		inc(pp[2]);
	  end;
	3:begin
		inc(i);
		for j:=0 to 7 do p[pp[3]].scen.jm[j+1]:=chr(a^[i+j]);
		i:=i+8;
		for j:=0 to 4 do p[pp[3]].scen.obl[j]:=a^[i+j];
		i:=i+5;inc(pp[3]);
	  end;
	4:begin
		inc(i);
		for j:=0 to 7 do p[pp[4]].anim.jm[j+1]:=chr(a^[i+j]);
		i:=i+8;
		p[pp[4]].anim.prep:=a^[i];inc(i);inc(pp[4]);
	  end;
	5:begin
		inc(i);
		for j:=0 to 7 do p[pp[5]].prek.jm[j+1]:=chr(a^[i+j]);
		i:=i+8;
		p[pp[5]].prek.prep:=a^[i];inc(i);inc(pp[5]);
	  end;
	6:begin
		inc(i);
		p[pp[6]].t.del:=a^[i];inc(i);
		for j:=1 to p[pp[6]].t.del do p[pp[6]].t.text[j]:=chr(a^[i+j-1]);
		i:=i+p[pp[6]].t.del;
		for j:=0 to 4 do pr[j]:=a^[i+j];preved;
		for j:=0 to 3 do p[pp[6]].t.obl[j]:=pr[j];i:=i+5;
		inc(pp[6]);
	  end;
	7:begin
		for j:=1 to 8 do jm[j]:=chr(a^[i+j]);inc(i,9);
	  end;
	9:begin
		inc(i);for j:=0 to 4 do pr[j]:=a^[i+j];preved;
		for j:=0 to 3 do p[pp[9]].use.obl[j]:=pr[j];inc(i,5);
		for j:=0 to 1 do p[pp[9]].use.kam[j]:=a^[i+j];if pr[4] and $80<>0 then inc(p[pp[9]].use.kam[1]);
		inc(pp[9]);inc(i,2);
	end;
	10:begin
		inc(i);for j:=0 to 4 do pr[j]:=a^[i+j];preved;
		for j:=0 to 3 do p[pp[10]].mluv.obl[j]:=pr[j];inc(i,5);
		p[pp[10]].mluv.kod:=a^[i];inc(i);for j:=1 to 8 do p[pp[10]].mluv.jm[j]:=chr(a^[i+j-1]);
		inc(i,8);p[pp[10]].mluv.prep:=a^[i];inc(i,3);
	end;
	11:begin
		inc(i);p[pp[11]].dial.del:=a^[i];inc(i);
		for j:=1 to p[pp[11]].dial.del do p[pp[11]].dial.text[j]:=chr(a^[i+j-1]);
		inc(i,p[pp[11]].dial.del);p[pp[11]].dial.kod:=a^[i]+a^[i+1] shl 8;inc(i,2);
	end;
	else inc(i);
end;
until a^[i]=0;
freemem(a,filesize(f));close(f);
nastav(0);
setfillstyle(1,12);if pp[1]>0 then
	for i:=0 to pp[1]-1 do begin
		for j:=0 to 4 do pr[j]:=p[i].nem[j];preved;
		bar(pr[0],pr[1],pr[2],pr[3]);
	end;
setfillstyle(1,10);if pp[2]>0 then
	for i:=0 to pp[2]-1 do begin
		for j:=0 to 4 do pr[j]:=p[i].vych.obl[j];preved;
		bar(pr[0],pr[1],pr[2],pr[3]);
		for j:=0 to 1 do pr[j]:=p[i].vych.obl[j+5];
		if (p[i].vych.obl[4] and $ee<>0) then inc(pr[0],256);
		fillellipse(pr[0],pr[1],3,3);
	end;
if pp[3]>0 then
	for i:=0 to pp[3]-1 do begin
		setfillstyle(1,3);if (p[i].scen.obl[4] and 128<>0) then setfillstyle(1,9);
		for j:=0 to 4 do pr[j]:=p[i].scen.obl[j];preved;
		bar(pr[0],pr[1],pr[2],pr[3]);
	end;
if pp[6]>0 then
	for i:=0 to pp[6]-1 do begin
		setfillstyle(1,15);for j:=0 to 3 do pr[j]:=p[i].t.obl[j];
		bar(pr[0],pr[1],pr[2],pr[3]);
	end;
if pp[9]>0 then
	for i:=0 to pp[9]-1 do begin
		setfillstyle(9,3);bar(p[i].use.obl[0],p[i].use.obl[1],p[i].use.obl[2],p[i].use.obl[3]);
		putpixel(p[i].use.kam[0],p[i].use.kam[1],15);
	end;
readln;
closegraph;
if pp[2]>0 then begin
	writeln('Vychody:');
	for i:=0 to pp[2]-1 do begin
		writeln('Do mistnosti: ',p[i].vych.kam);kontr;
	end;
	writeln;kontr;
end;
if pp[3]>0 then begin
	writeln('Scenky:');
	for i:=0 to pp[3]-1 do begin
		for j:=1 to 8 do write(p[i].scen.jm[j]);
		write('.WSA     Aktivace ');
		if (p[i].scen.obl[4] and 128<>0) then writeln('stoupnutim') else writeln('kliknutim');
		kontr;
	end;
	writeln;kontr;
end;
if pp[4]>0 then begin
	writeln('Animace:');
	for i:=0 to pp[4]-1 do begin
		for j:=1 to 8 do write(p[i].anim.jm[j]);
		writeln('.WSA     Priorita=',p[i].anim.prep);
		kontr;
	end;
	writeln;kontr;
end;
if pp[5]>0 then begin
	writeln('Prekryvani:');
	for i:=0 to pp[5]-1 do begin
		for j:=1 to 8 do write(p[i].prek.jm[j]);
		writeln('.CPS     Priorita=',p[i].prek.prep);
		kontr;
	end;
	writeln;kontr;
end;
if pp[6]>0 then begin
	writeln('Texty pro Oko:');
	for i:=0 to pp[6]-1 do begin
		for j:=1 to p[i].t.del do write(p[i].t.text[j]);
		writeln;kontr;
	end;
	writeln;kontr;
end;
if pp[10]>0 then begin
	writeln('Mluvidla:');
	for i:=0 to pp[10]-1 do begin
		for j:=1 to 8 do write(p[i].mluv.jm[j]);
		writeln('.WSA    Cislo=',p[i].mluv.kod:3);kontr;
	end;
	writeln;kontr;
end;
if pp[11]>0 then begin
	writeln('Texty dialogu:');
	for i:=0 to pp[11]-1 do begin
		for j:=1 to p[i].dial.del do write(p[i].dial.text[j]);
		writeln;kontr;
	end;
	writeln;kontr;
end;
if jm[1]<>' ' then begin
	writeln('Pisnicka na pozadi:');kontr;
	writeln(jm,'.CMF');kontr;
	writeln;kontr;
end;
end.