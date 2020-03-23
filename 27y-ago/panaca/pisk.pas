uses crt,dos,graph,svga256;
var i,j,k,l,max,maxx,maxy:integer;
    r:registers;
    p:array[0..43,0..27] of byte;
    v:array[0..43,0..27] of integer;
    sm:byte;
    st:string;
const natahu:byte=1;
      tah:integer=1;
      poc:word=1;
      konec:boolean=false;
      tab:array[1..8,1..2] of shortint=((1,0),(1,1),(0,1),(-1,1),(-1,0),(-1,-1),(0,-1),(1,-1));
      human:byte=1;
      comp:byte=2;
      done:boolean=false;
procedure uvod;
begin
for i:=0 to 43 do for j:=0 to 27 do p[i,j]:=0;
cleardevice;randomize;
setcolor(7);
for i:=0 to 40 do line(i*8,0,i*8,192);
for i:=0 to 25 do line (0,i*8,312,i*8);
end;
procedure sipka;
begin
r.ax:=1;intr($33,r);
end;
procedure smaz;
begin
r.ax:=2;intr($33,r);
end;
procedure zobraz(sx,sy:integer;b:byte);
var i,j:integer;
begin
smaz;
for i:=0 to 39 do for j:=0 to 25 do begin
sx:=i;sy:=j;b:=p[i,j];
setfillstyle(1,0);
bar(sx*8+1,sy*8+1,sx*8+7,sy*8+7);
if b=1 then begin
	setcolor(12);line(sx*8+2,sy*8+2,sx*8+6,sy*8+6);
	line(sx*8+2,sy*8+6,sx*8+6,sy*8+2);
end;
if b=2 then begin
	setcolor(14);setfillstyle(1,14);fillellipse(sx*8+4,sy*8+4,2,2);
end;
end;
sipka;
end;
procedure vaz(ja:byte);
var on:byte;
    s:array[1..8,0..5] of byte;
    t:array[1..8] of byte;
    o:array[1..8] of boolean;
    m1,m2:integer;
label tam;
begin
if poc<3 then exit;
on:=ja+1;if on=3 then on:=1;
for i:=0 to 38 do begin
  for j:=0 to 23 do begin
    if p[i,j]=0 then 
    for sm:=1 to 8 do begin
      for k:=0 to 5 do begin
	m1:=k*tab[sm,1];m2:=k*tab[sm,2];
	if (i+m1>38) or (j+m2>23) or (i-m1<0) or (j-m2<0) then s[sm,k]:=0 else
	s[sm,k]:=p[i+m1,j+m2];
      end;
    end;
    for sm:=1 to 8 do begin
      t[sm]:=0;
      for k:=1 to 4 do begin
	o[sm]:=false;
	if s[sm,k]=ja then inc(t[sm]);
	if (k=1) and (s[sm,k]=on) then begin o[sm]:=false;goto tam;end;
	if (k>1) and (s[sm,k]=on) and (s[sm,k-1]=ja) then begin o[sm]:=true;goto tam;end;
	if (k>1) and (s[sm,k]=on) and (s[sm,k-1]=0) and (t[sm]>0) then begin inc(t[sm]);o[sm]:=false;goto tam;end;
      end;
      inc(t[sm]);if (s[sm,5]=on) and ((t[sm]>3) and (s[sm,4]=ja)) then dec(t[sm]);
tam:
      if (s[sm,1]=0) and (s[sm,2]=0) then t[sm]:=0;
      if (s[sm,1]=0) and (s[sm,2]=on) and (s[sm,3]=ja) then t[sm]:=0;
    end;
    for k:=1 to 4 do begin
	if (t[k]>3) and (t[k+4]>0) then inc(v[i,j],200);
	if (t[k]>2) and (t[k+4]>1) then inc(v[i,j],200);
	if (t[k+4]>3) and (t[k]>0) then inc(v[i,j],200);
	if (t[k+4]>2) and (t[k]>1) then inc(v[i,j],200);
	if (t[k]>2) and (t[k+4]>2) then inc(v[i,j],200);
	if (t[k+4]>2) and (t[k]>2) then inc(v[i,j],200);
	if ((t[k]>3) and (s[k,2]=ja) and (s[k,3]=ja))or((t[k+4]>3) and (s[k+4,2]=ja) and (s[k+4,3]=ja)) then inc(v[i,j],1000);
	if ((t[k]=4) and (not(o[k]))) or ((t[k+4]=4) and (not(o[k]))) then dec(v[i,j],200);
	if (t[k]>1) and (t[k+4]>1) and ((s[k,1]=ja) or (s[k+4,1]=ja)) then inc(v[i,j],200);
	if ((t[k]=2) and (t[k+4]>1) and (s[k,2]=ja) and (s[k+4,2]=ja) and (s[k,1]=ja)) or ((t[k+4]=2) and (t[k]>1) and 
		(s[k+4,2]=ja) and (s[k,2]=ja) and (s[k+4,1]=ja)) then inc(v[i,j],400);
	if (t[k]>2) or (t[k+4]>2) then inc(v[i,j],5);
    end;
    l:=0;for k:=1 to 4 do if ((t[k]>2) and (s[k+4,1]<>on)) or ((t[k+4]>2) and (s[k,1]<>on)) then inc(l,t[k]);
    if l>5 then inc(v[i,j],500);
    for k:=5 to 8 do t[k-4]:=t[k-4]+t[k]+1;
    for k:=1 to 4 do begin
	if t[k]>=5 then inc(t[k],1000);
	if t[k]>=6 then inc(t[k],2000);
	if t[k]<2 then t[k]:=0;
    end;
    v[i,j]:=v[i,j]+t[1]+t[2]+t[3]+t[4];
    if p[i,j]<>0 then v[i,j]:=0;
  end;
end;
end;
procedure odvaz;
begin
for i:=0 to 40 do for j:=0 to 25 do v[i,j]:=0;
max:=0;maxx:=20;maxy:=12;
end;
procedure cuchej(i,j:integer;text:string);
var srov:byte;
    on:byte;
begin
on:=tah+1;if on=3 then on:=1;
for sm:=1 to 4 do begin
	srov:=0;
	for k:=0 to 4 do begin
		if p[i+k*tab[sm,1],j+k*tab[sm,2]]=tah then inc(srov);
		if p[i+k*tab[sm,1],j+k*tab[sm,2]] in[on,0] then k:=4;
	end;
	for k:=1 to 4 do begin
		if p[i-k*tab[sm,1],j-k*tab[sm,2]]=tah then inc(srov);
		if p[i-k*tab[sm,1],j-k*tab[sm,2]] in [on,0] then k:=4;
	end;
	smaz;
	if srov>4 then begin
                setfillstyle(1,9);bar(60,80,260,100);
		outtextxy((160-4*length(text)),85,text);konec:=true;
		repeat i:=ord(readkey) until (i=13) or (i=27);
	end;
	sipka;
end;
end;
procedure tahni(pom:byte);
begin
if poc<3 then exit;
for i:=0 to 39 do begin
  for j:=0 to 25 do begin
    if v[i,j]>max then begin
	v[maxx,maxy]:=0;max:=v[i,j];maxx:=i;maxy:=j;
    end;
    if v[i,j]=max then begin
	if random(100)<40 then begin
		v[maxx,maxy]:=0;maxx:=i;maxy:=j;
	end else v[i,j]:=0;
    end;
    if v[i,j]<max then v[i,j]:=0;
  end;
end;
if pom=2 then begin
  p[maxx,maxy]:=comp;
  zobraz(maxx,maxy,comp);
  cuchej(maxx,maxy,'Vyhral jsem JA !!!');tah:=human;
  str(max,st);setcolor(15);outtextxy(0,188,st);
end;
end;

begin
nastav(0);
uvod;
r.ax:=0;intr($33,r);
r.ax:=7;r.cx:=0;r.dx:=640;intr($33,r);
r.ax:=8;r.cx:=0;r.dx:=200;intr($33,r);
if r.ax=0 then halt;
r.ax:=1;intr($33,r);
r.ax:=$d;intr($33,r);
repeat
if keypressed then i:=ord(readkey) else i:=0;
if i=27 then konec:=true;
if tah=human then begin
{zobraz(39,24,tah);}
repeat
	r.ax:=3;intr($33,r);
	if keypressed then begin
		i:=ord(readkey);
		if i=27 then konec:=true;
	end;
	if (r.cx<624) and (r.dx<192) and (r.bx=1) then begin
		i:=trunc(r.cx/16);j:=trunc(r.dx/8);
		if p[i,j]=0 then begin
			p[i,j]:=human;done:=true;
			cuchej(i,j,'No, tak jsi vyhral !');
			zobraz(i,j,human);
		end;
	end else done:=false;
	if (r.bx=2) then begin
		i:=trunc(r.cx/16);j:=trunc(r.dx/8);
		zobraz(1,1,0);
		str(v[i,j],st);setcolor(15);outtextxy(0,170,st);
	end;
until done;
tah:=comp;inc(poc);
end;
if tah=comp then begin
	odvaz;{zobraz(39,24,tah);}
	if poc<3 then begin
		for i:=0 to 39 do for j:=0 to 23 do if p[i,j]=human then begin
			sm:=random(8)+1;k:=i+tab[sm,1];l:=j+tab[sm,2];p[k,l]:=comp;
			zobraz(k,l,comp);
		end;
	end;
	vaz(comp);tahni(1);vaz(human);tahni(2);
	tah:=human;inc(poc);
end;
until konec;
closegraph;
end.