uses crt,dos,copyriht;
var f:file;
    a:array[1..32768] of byte;
    nr,nw,i,j,k,l,x1,y1,x2,y2,mo:word;
    pos2,pos:longint;
    r:registers;
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
procedure ukaz(jm:string);
begin
assign(f,jm);reset(f,1);blockread(f,a,5,nr);
x1:=a[1]+(a[5] and 1) shl 8;x2:=a[3]+(a[5] and 16) shl 4;y1:=a[2];y2:=a[4];
k:=x1;l:=y1;pos2:=5;grsetdisppage(2);
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
j:=1;
for i:=y2 downto 0 do begin r.ax:=$4f07;r.bx:=0;r.cx:=0;r.dx:=i;intr($10,r);if j>i then j:=i;dec(i,j);inc(j);end;
grmoveimage(x1,y1,x2+1,y2+1,x1,y1,0,2);grsetdisppage(0);
end;
procedure uloz(jm:string);
begin
assign(f,jm);rewrite(f,1);
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
procedure roztahni2;
begin
j:=239;
for i:=199 downto 0 do begin
 grmoveimage(0,i,320,i+2,0,j,0,0);
 dec(j);if i/5=i div 5 then dec(j);
end;y2:=239;
end;

begin
writeln;
if paramcount<1 then begin writeln('Chybi parametr!');halt end;
grinit;
ukaz(paramstr(1));roztahni2;uloz(paramstr(1));
r.ax:=3;intr($10,r);
end.