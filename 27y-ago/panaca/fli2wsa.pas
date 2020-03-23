{  (c) by Mr.Old 25.10.94, ver. 1.01, last upgrade: 25.10.94      }
uses dos,crt;
{$L xgraf.obj}
procedure grputpixel(x,y:word;col:byte);external;
function grgetpixel(x,y:word):byte;external;
procedure grsetworkpage(pg:byte);external;
procedure grsetdisppage(pg:byte);external;
procedure grclose;external;
procedure grmoveimage(x1,y1,x2,y2,x0,y0:word;src,dest:byte);external;
{$L x1.obj}
procedure setxmode;external;
type typptr=^typid;
     typid=array[0..65533] of byte;
var markedpointer:pointer;
    a,b:typptr;
    f:file;
    g,h,ch:file;
    r:registers;
    nr,nw,i,j,k,l,frames,speed,size,chunks,pos,typ,top,bottom,minx,maxx:word;
    packets,skip,kolik:byte;
    pal:array[0..767] of byte;
    siz,poz:longint;
    hlaska,jmeno:string;
const black:byte=128;
      ver='1.01';
      pocet:word=65535;
label konec;
procedure grputpixelmm(x,y:word;col:byte);
begin
if x<minx then begin
	minx:=x;if minx>0 then dec(minx);end;
if x>maxx then begin
	maxx:=x;if maxx<319 then inc(maxx);end;
grputpixel(x,y,col);
end;
procedure uloz;
var i,j,k,l,mo,nr:word;
begin
k:=0;l:=0;
repeat
nr:=0;
repeat
	j:=grgetpixel(k,l);
	if (j<$c0) and (grgetpixel(k+1,l)<>j) then b^[nr]:=j else begin
		mo:=0;repeat
			inc(mo);
		until (grgetpixel(k+mo,l)<>j) or (k+mo>319) or (mo=63);
		b^[nr]:=$c0+mo;inc(nr);b^[nr]:=j;inc(k,mo-1);
	end;
	inc(k);inc(nr);if k>319 then begin k:=0;inc(l);end;
until (nr>32760) or (l>199);
blockwrite(h,b^,nr,nw);
until (l>199) or (nw=0);
end;
procedure ulozcastwsa(x1,y1,x2,y2:word);
var i,j,k,l,mo,nr:word;
function getpix(x,y:word):byte;
var vr:byte;
begin
grsetworkpage(1);if grgetpixel(x,y)=1 then begin
	vr:=0;grsetworkpage(0);
end else begin
	grsetworkpage(0);vr:=grgetpixel(x,y);if vr=0 then vr:=black;
end;
getpix:=vr;
end;
begin
k:=x1;l:=y1;b^[3]:=x1 and 255;b^[4]:=y1;b^[5]:=x2 and 255;b^[6]:=y2;b^[7]:=x1 shr 8+(x2 shr 8) shl 4;
b^[0]:=$2c;nr:=8;repeat
	j:=getpix(k,l);
	if (j<$c0) and (getpix(k+1,l)<>j) then b^[nr]:=j else begin
		mo:=0;repeat inc(mo);until (getpix(k+mo,l)<>j) or (k+mo>319) or (mo=63);
		b^[nr]:=$c0+mo;inc(nr);b^[nr]:=j;inc(k,mo-1);
	end;
	inc(k);inc(nr);if k>x2 then begin k:=x1;inc(l);end;
until (nr>65528) or (l>y2);
b^[1]:=lo(nr-8);b^[2]:=hi(nr-8);
blockwrite(g,b^,nr,nw);
end;

begin
mark(markedpointer);hlaska:='';
getmem(a,65533);getmem(b,65533);
if paramcount<1 then begin
	writeln('FLI to WSA, '+ver+ ', All Rights Reserved.');writeln;
	writeln('Usage:  FLI2WSA.EXE eltaarts.fli [color]  - instead of textbackground'+#$27+'s color');halt;
end;
if paramcount=2 then begin
	jmeno:=paramstr(2);val(jmeno,black,i);if i<>0 then black:=128;
end;
jmeno:=paramstr(1);for i:=2 to length(jmeno) do if jmeno[i]='.' then jmeno:=copy(jmeno,1,i);
setxmode;
grsetworkpage(1);for i:=0 to 319 do for j:=0 to 239 do grputpixel(i,j,0);
grmoveimage(0,0,319,240,0,0,1,2);grsetworkpage(0);
assign(f,jmeno+'fli');assign(g,jmeno+'wsa');assign(h,jmeno+'cps');assign(ch,jmeno+'pal');
reset(f,1);rewrite(g,1);rewrite(h,1);
blockread(f,a^,128,nr);frames:=a^[6]+a^[7] shl 8;speed:=a^[16]+a^[17] shl 8;
repeat
  blockread(f,a^,16,nr);chunks:=a^[6]+a^[7] shl 8;size:=a^[0]+a^[1] shl 8;
  if a^[4]+a^[5] shl 8<>$f1fa then goto konec;
  blockread(f,a^[16],size-16,nr);pos:=16;
  if size>pos then repeat
    if a^[pos]+a^[pos+1] shl 8>size then goto konec;
    typ:=a^[pos+4]+a^[pos+5] shl 8;if typ in [11,12,13,15,16] then inc(pos,6) else inc(pos);
    case typ of	
	11:begin
	  r.ah:=16;r.al:=18;r.es:=seg(pal);r.dx:=ofs(pal);r.bx:=a^[pos]-1;
	  r.cx:=a^[pos+2];if r.cx=0 then r.cx:=256;for i:=r.bx to r.cx+r.bx-1 do for j:=0 to 2 do pal[(i and 255)*3+j]:=
			a^[pos+4+j+(i-r.bx)*3];r.bx:=0;r.cx:=256;
	  pos:=pos+4+r.cx*3;rewrite(ch,1);blockwrite(ch,pal,768);close(ch);
	  intr($10,r);
	end;
	12:begin
	  top:=a^[pos]+a^[pos+1] shl 8;bottom:=a^[pos+2]+a^[pos+3] shl 8+top-1;inc(pos,4);
	  i:=top;minx:=319;maxx:=0;grsetworkpage(0);
	  repeat
		packets:=a^[pos];inc(pos);l:=0;if packets>0 then for j:=1 to packets do begin grsetworkpage(1);
		  skip:=a^[pos];kolik:=a^[pos+1];inc(pos,2);if skip>0 then for k:=l to l+skip-1 do grputpixel(k,i,1);
		  inc(l,skip);
		  if kolik and 128=0 then begin grsetworkpage(0);
			if kolik>0 then for k:=0 to kolik-1 do grputpixelmm(k+l,i,a^[pos+k]);
			inc(pos,kolik);inc(l,kolik);
		  end else begin
			if kolik>127 then for k:=0 to 127-(kolik and 127) do begin grsetworkpage(0);
				if a^[pos]=0 then a^[pos]:=black;grputpixelmm(k+l,i,a^[pos]);
			end;
			inc(pos);inc(l,128-(kolik and 127));
		  end;
	 	end;
		inc(i);
	  until i>bottom;ulozcastwsa(minx,top,maxx,i);
	end;
	13:begin
		for i:=0 to 319 do for j:=0 to 239 do grputpixel(i,j,0);
	end;
	15:begin
	  b^[0]:=0;b^[1]:=0;b^[2]:=319-256;b^[3]:=199;b^[4]:=16;blockwrite(h,b^,5);
	  for i:=0 to 199 do begin
		packets:=a^[pos];inc(pos);l:=0;if packets>0 then for j:=1 to packets do begin
		  kolik:=a^[pos];inc(pos);
		  if kolik and 128=0 then begin
			for k:=0 to kolik-1 do begin grputpixel(l+k,i,a^[pos]);end;inc(pos);
			inc(l,kolik)
		  end else begin
			for k:=0 to 127-(kolik and 127) do begin grputpixel(l+k,i,a^[pos+k]);end;
			inc(pos,128-(kolik and 127));inc(l,128-(kolik and 127));
		  end;
		end;
	  end;uloz;
	end;
	16:begin
	  for i:=0 to 319 do for j:=0 to 199 do grputpixel(i,j,a^[pos+j*200+i]);
	  inc(pos,64000);
	end;
	else goto konec;
    end;
	dec(chunks);dec(pocet);
  until (chunks=0) or (pocet=0);
  dec(frames);delay(speed shl 2);b^[0]:=0;blockwrite(g,b^,1);
  grmoveimage(0,0,319,240,0,0,2,1);
until (frames=0) or (pocet=0) or (keypressed);
if keypressed then readkey;hlaska:='OK';
konec:
if hlaska<>'OK' then begin readln;hlaska:='Chyba !';end;
grclose;
asm
	mov	ax,3
	int	10h
end;
writeln(hlaska);
release(markedpointer);close(f);close(g);close(h);
end.