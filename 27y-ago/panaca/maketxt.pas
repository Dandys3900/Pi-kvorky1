uses dos,crt;
var a:array[1..32767] of byte;
    i,j,k,l,nr:integer;
    s:string[255];
    f:file;
label tam;
function dotaz(st:string):boolean;
var c:char;
begin
write(st+' (a/n)');repeat c:=upcase(readkey) until c in ['A','Y','N'];
if c='N' then dotaz:=false else dotaz:=true;writeln;
end;
procedure zobraz;
begin
clrscr;i:=1;repeat
	write(a[i]:3,'  ');for j:=1 to a[i+1] do write(chr(a[i+j+1]));
	inc(i,4+a[i+1]);writeln;if wherey=25 then begin
		write('Neco zmackni !');readkey;clrscr;
	end;
until i>=nr;
writeln('-----------------------------------------------------------');
end;
begin
assign(f,paramstr(1));reset(f,1);blockread(f,a,32000,nr);
{for i:=1 to nr do a[i]:=a[i] xor $c7;}
zobraz;
if (dotaz('Chces smazat nejakou polozku ?')) and (nr>4) then repeat
	write('Zadej cislo veci pro smazani: ');readln(j);i:=1;
	repeat
	  tam:
		if a[i]=j then begin
			k:=a[i+1]+4;if nr-k>=i then for l:=i+k to nr do a[l-k]:=a[l];
			dec(nr,k);if nr-k shl 1>=i then goto tam;
		end;
		inc(i,a[i+1]+4);
	until i>=nr;zobraz;
until (not dotaz('Chces smazat jeste nejakou polozku ?')) or (nr<5);
if dotaz('Chces neco pridat ?') then repeat
	write('Zadej cislo veci: ');readln(j);
	write('Zadej text: ');readln(s);
	k:=length(s);for i:=nr+3 to nr+k+2 do a[i]:=ord(s[i-nr-2]);
	a[nr+1]:=j;a[nr+2]:=k;a[nr+k+3]:=$d;a[nr+k+4]:=$a;nr:=nr+k+4;zobraz;
until not dotaz('Chces jeste neco pridat ?');
{for i:=1 to nr do a[i]:=a[i] xor $c7;}
rewrite(f,1);blockwrite(f,a,nr);close(f);
end.