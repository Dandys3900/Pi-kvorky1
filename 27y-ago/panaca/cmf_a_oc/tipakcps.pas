{$M $800,0,400}
uses dos;

type
 ptrstr=^string;
const copyright:string='Tipak CPS by Mr.Old ';	     {musi byt ruzne u kazdeho TSR}
      aktscancode:byte=68;
      aktshifts:byte=12;	{1...Lshift, 2...Pshift, 4...ctrl, 8...alt}
      deaktscancode:byte=67;
      deaktshifts:byte=4;
      akttime=0;
      max=319;
      may=199;
var mytask,j,i:word;
    r:registers;
    f:file;
    a:array[1..1024] of byte;
    myPSP,nr,nw,time,k,l,mo:word;
    s:string[16];
    oldkb,oldtimer,oldcriterr,oldmultiplex:procedure;
    flagoff,runflag,run,x,y,tip:byte;
    dosflag:^byte;
    shifts:byte absolute 0:$417;
function terminate:word;forward;

{$F+}
function comparestr(s1,s2:ptrstr):boolean;
begin
if s1^=s2^ then comparestr:=true else comparestr:=false;
end;

procedure newcriterr(_flags,_CS,_IP,_AX,_BX,_CX,_DX,_SI,_DI,_DS,_ES,_BP:word);interrupt;
begin
_AX:=(_AX and $FF00)+3;
end;

procedure newkb;interrupt;
var x:byte;
begin
if (run=0) and (port[$60]=deaktscancode) and ((shifts and deaktshifts)=deaktshifts) then begin
  runflag:=0;
  {lze rozsirit}

  x:=port[$61];port[$61]:=(x or $80);
  port[$61]:=x;port[$20]:=$20;
end else
if (run=0) and (port[$60]=aktscancode) and ((shifts and aktshifts)=aktshifts) then begin
  runflag:=1;
  {lze rozsirit}

  x:=port[$61];port[$61]:=(x or $80);
  port[$61]:=x;port[$20]:=$20;
end else begin
  inline($9c);
  oldkb;
end
end;

procedure newtimer;interrupt;
begin
inline($9c);oldtimer;
inc(time);if time=0 then time:=1;	    {100 ...  5,5 s}
if time=akttime then runflag:=1;
if (runflag=1) and (dosflag^=0) and (run=0) and (flagoff=0) then begin
 run:=1;
 getintvec($24,@oldcriterr);setintvec($24,@newcriterr);
 {telo residentu}
 inc(tip);str(tip,s);s:='c:\tipak'+s+'.';
 assign(f,s+'cps');rewrite(f,1);
 a[1]:=0;a[3]:=max and 255;a[2]:=0;a[4]:=may;a[5]:=(max shr 8) shl 4;
 blockwrite(f,a,5);k:=0;l:=0;
 repeat
 nr:=0;
 repeat
	inc(nr);j:=mem[$a000:l*320+k];
	if (j<$c0) and (mem[$a000:l*320+k+1]<>j) then a[nr]:=j else begin
		mo:=0;repeat
			inc(mo);
		until (mem[$a000:320*l+k+mo]<>j) or (k+mo>max) or (mo=63);
		a[nr]:=$c0+mo;inc(nr);a[nr]:=j;inc(k,mo-1);
	end;
	inc(k);if k>max then begin k:=0;inc(l);end;
 until (nr>1020) or (l>may);
 blockwrite(f,a,nr,nw);
 until (l>may) or (nw=0);
 close(f);
 assign(f,s+'pal');rewrite(f,1);
 i:=seg(a[1]);j:=ofs(a[1]);
 asm
  push es
  mov ah,10h
  mov al,17h
  mov es,i
  mov dx,j
  mov bx,0
  mov cx,100h
  int 10h
  pop es
 end;
 blockwrite(f,a,768,i);close(f);
 setintvec($24,@oldcriterr);runflag:=0;
 run:=0;
end;
end;

procedure newmultiplex(_flags,_CS,_IP,_AX,_BX,_CX,_DX,_SI,_DI,_DS,_ES,_BP:word);interrupt;
begin
if (_AX and $FF00)=mytask then begin
  case (_AX and $ff) of
    0:begin
    	_AX:=_AX or $ff;_ES:=seg(copyright);_BX:=ofs(copyright)
      end;
    $C0:_AX:=terminate;
  end;
end else asm
	mov ax,word ptr OldMultiplex
        mov word ptr cs:[@O],ax
        mov ax,word ptr OldMultiplex+2
        mov word ptr cs:[@S],ax
        pop bp
        pop es
        pop ds
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        jmp dword ptr cs:[@O]
 @O:dw $0000
 @S:dw $0000
end;
end;

function terminate:word;
var intkb,intmultiplex,inttimer:pointer;
begin
getintvec($1c,intkb);getintvec($2f,intmultiplex);getintvec($8,inttimer);
if (intkb=@newkb) and (intmultiplex=@newmultiplex) and (inttimer=@newtimer) then begin
  flagoff:=1;
  setintvec($1c,@oldkb);setintvec($2f,@oldmultiplex);setintvec($8,@oldtimer);
  r.ah:=$49;r.es:=myPSP;msdos(r);
  terminate:=0;
end else terminate:=$fe;
end;
{$F-}
procedure install;
begin
flagoff:=0;runflag:=0;run:=0;time:=0;
r.ah:=$34;msdos(r);dosflag:=ptr(r.es,r.bx);
r.ah:=$62;msdos(r);myPSP:=r.bx;
getintvec($1c,@oldkb);getintvec($2f,@oldmultiplex);getintvec($8,@oldtimer);
setintvec($1c,@newkb);setintvec($2f,@newmultiplex);setintvec($8,@newtimer);
writeln('£spˆ¨nˆ nainstalov n.');
r.ah:=$49;r.es:=mem[myPSP:$2c];msdos(r);	{uvolni environment z PSP}
keep(0);
end;

begin
x:=$FF;mytask:=0;write(copyright);
while (x>$7f) do begin
  r.ah:=x;r.al:=0;intr($2f,r);
  if r.al=$FF then begin
    if comparestr(@copyright,ptr(r.es,r.bx)) then begin
      r.ah:=x;r.al:=$C0;intr($2f,r);
      if r.ax=$FE then begin
        writeln('nelze odinstalovat!!!');halt(3);
      end else begin
        writeln('odinstalov n.');halt(2);
      end;
    end;
  end else if (mytask=0) and (r.al=0) then mytask:=x shl 8;
  dec(x);
end;
if mytask<>0 then install else writeln('nelze nainstalovat !!!');tip:=0;
end.