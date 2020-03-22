program nacteni_wsa_s_cps;
uses crt,dos;
type typid=array[1..65533] of byte;
    typptr=^typid;
var i,j,k,l,nr,nw,p,s:word;
    x1,x2,y1,y2:word;
    poz,pom,pom2,pb:longint;
    f,g:file;
    a:array[1..32768] of byte;
    b:typptr;
    r:registers;
const hod:byte=$c0;
      par:boolean=false;
      obrzac:boolean=false;
      pauza:byte=0;
{$L x1.obj}
procedure setxmode;external;
{$L xgraf.obj}
procedure grclose;external;
procedure grputpixel(x,y:word;col:byte);external;
function grgetpixel(x,y:word):byte;external;
procedure grmoveimage(x1,y1,x2,y2,x0,y0:word;src,dest:byte);external;
procedure putp(x,y:word;col:byte);
begin
if (par) or (col>0) then grputpixel(x,y,col);
end;
procedure ukaz;
var pos,pos2:longint;
    x1,y1,x2,y2,nr,i,j,k,l:word;
begin
reset(g,1);blockread(g,a,5,nr);
x1:=a[1]+(a[5] and 1) shl 8;x2:=a[3]+(a[5] and 16) shl 4;y1:=a[2];y2:=a[4];
k:=x1;l:=y1;pos2:=5;
repeat
seek(g,pos2);blockread(g,a,32768,nr);if nr=32768 then dec(nr,2);pos:=1;
repeat
	if a[pos]>$c0 then begin if a[pos+1]>0 then for i:=1 to a[pos]-$c0 do grputpixel(k+i-1,l,a[pos+1]);
		k:=k+a[pos]-$c1;inc(pos);inc(pos2);
	end else grputpixel(k,l,a[pos]);
	inc(k);if k>x2 then begin inc(l);k:=x1;end;
	inc(pos);inc(pos2);
until pos>nr;
until nr<32766;
close(g);
end;

procedure cleardevice;
begin
grmoveimage(0,0,319,240,0,0,2,0);delay(50);
end;

begin
if paramcount<2 then begin
	writeln('All Rights Reserved (c) by Mr.Old');writeln('Usage:  CTIWSA.EXE filename.PAL filename.WSA [filename.CPS] [/p]');
	writeln('        Parameter /p means that in each frame of WSA is whole picture again');
	writeln('        This parameter have to be at end of line');
	halt;
end;
if (paramcount>2) then
	if (paramcount>3) or (paramstr(3)<>'/p') then begin assign(g,paramstr(3));obrzac:=true;end;
if paramcount>2 then if (paramstr(3)='/p') or (paramcount=4) then par:=true;
setxmode;getmem(b,sizeof(b));
assign(f,paramstr(1));reset(f,1);
blockread(f,b^,768);
r.es:=seg(b^);r.dx:=ofs(b^);r.ah:=$10;r.al:=$12;r.bx:=0;r.cx:=256;
intr($10,r);close(f);
if obrzac then begin
	ukaz;
end;
grmoveimage(0,0,319,240,0,0,0,2);
repeat
k:=y1;j:=x1;
assign(f,paramstr(2));reset(f,1);poz:=filepos(f);if filesize(f)<65533 then begin
blockread(f,b^,sizeof(typid),nr);poz:=1;
repeat
  p:=b^[poz];
  if p=$2c then begin
	inc(poz);nw:=b^[poz]+b^[poz+1] shl 8;inc(poz,2);
	x1:=b^[poz]+(b^[poz+4] and 1) shl 8;x2:=b^[poz+2]+(b^[poz+4] and 16) shl 4;
	y1:=b^[poz+1];y2:=b^[poz+3];inc(poz,4);j:=x1;k:=y1;
	for i:=1 to nw do begin
		if b^[i+poz]<=hod then putp(j,k,b^[i+poz]) else begin
			for l:=1 to b^[i+poz]-hod do begin putp(j+l-1,k,b^[i+poz+1]);end;
			j:=j+b^[i+poz]-hod-1;inc(i);end;
		inc(j);if j>x2 then begin j:=x1;inc(k);end;
	end;inc(poz,nw);inc(poz);
  end;
  if p=0 then begin 
	delay(pauza);inc(poz);inc(pauza);end;
  if not p in[0,$2c] then inc(poz);
until (poz>nr) or (keypressed);
end else begin{$I-}
poz:=0;repeat
seek(f,poz);blockread(f,a,1,nr);inc(poz);
if nr>0 then case a[1] of
	$2c:if nr=1 then begin
		blockread(f,a,7,nr);inc(poz,7);
		nw:=a[1]+a[2]*256;blockread(f,b^,nw);inc(poz,nw);
                x1:=a[3]+(a[7] and 1) shl 8;y1:=a[4];x2:=a[5]+(a[7] and 16) shl 4;y2:=a[6];j:=x1;k:=y1;
		for i:=1 to nw do begin
                    if b^[i]<hod then begin if b^[i]>0 then grputpixel(j,k,b^[i]);end else begin
                       if b^[i+1]>0 then for l:=0 to b^[i]-hod-1 do begin grputpixel(j+l,k,b^[i+1]);
			   end;inc(j,b^[i]-$c0);dec(j);inc(i);end;
                       j:=j+1;if j>x2 then begin
                                 j:=x1;k:=k+1;end;{if keypressed then i:=nw;}if i>nw then i:=nw;
		end;
        end;
	$00:begin
	end;
end;
until (nr=0) or (keypressed);
end;
close(f);if not par then cleardevice;
until keypressed;freemem(b,sizeof(b));
grclose;asm
	mov	ax,3
	int	10h
end;
i:=ord(readkey);
end.